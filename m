From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 16 Mar 2009 14:34:59 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata.c lib/m ...
Message-ID: <20090316143459.32209.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-03-16 14:34:58

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata.c snapshot_manip.c 
	test           : t-lvcreate-usage.sh 
	tools          : lvcreate.c vgck.c 

Log message:
	Fix lv_count when manipulating with snapshots and max_lv is set.
	
	Patch fixes these problems:
	- during the snapshot creation process, it needs create 2 LVs,
	one is cow, second becomes snapshot.
	If the code fails in vg_add_snapshot, code lvcreate will not remove
	LV cow volume.
	
	- if max_lv is set and VG contains snapshot, it can happen that
	during the activation lv_count is temporarily increased over the limit
	and VG metadata are not properly processed
	see https://bugzilla.redhat.com/show_bug.cgi?id=490298
	
	- vgcfgrestore alows restore with max_lv set to lower valuer that actual
	LV count. This later leads to situation that max_lv is completely ignored.
	
	- vgck doesn't call vg_validate(). It should at least try:-)
	
	Signed-off-by: Milan Broz <mbroz@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1065&r2=1.1066
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.206&r2=1.207
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/snapshot_manip.c.diff?cvsroot=lvm2&r1=1.33&r2=1.34
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvcreate-usage.sh.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.179&r2=1.180
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgck.c.diff?cvsroot=lvm2&r1=1.18&r2=1.19

--- LVM2/WHATS_NEW	2009/03/09 15:42:10	1.1065
+++ LVM2/WHATS_NEW	2009/03/16 14:34:57	1.1066
@@ -1,5 +1,7 @@
 Version 2.02.46 - 
 ================================
+  Fix maximal volume count check for snapshots if max_lv set for volume group.
+  Fix lvcreate to remove cow volume if the snapshot creation fails.
   Fix error messages when PV uuid or pe_start reading fails.
   Rename liblvm.a to liblvm-internal.a and build new application library.
   Flush memory pool and fix locking in clvmd refresh and backup command.
--- LVM2/lib/metadata/metadata.c	2009/02/25 23:29:06	1.206
+++ LVM2/lib/metadata/metadata.c	2009/03/16 14:34:58	1.207
@@ -1461,6 +1461,13 @@
 		r = 0;
 	}
 
+	if (vg->max_lv && (vg->max_lv < vg->lv_count)) {
+		log_error("Internal error: Volume group %s contains %u volumes"
+			  " but the limit is set to %u.",
+			  vg->name, vg->lv_count, vg->max_lv);
+		r = 0;
+	}
+
 	return r;
 }
 
--- LVM2/lib/metadata/snapshot_manip.c	2008/12/04 15:54:27	1.33
+++ LVM2/lib/metadata/snapshot_manip.c	2009/03/16 14:34:58	1.34
@@ -76,10 +76,18 @@
 		return 0;
 	}
 
+	/*
+	 * Set origin lv count in advance to prevent fail because
+	 * of temporary violation of LV limits.
+	 */
+	origin->vg->lv_count--;
+
 	if (!(snap = lv_create_empty(name ? name : "snapshot%d",
 				     lvid, LVM_READ | LVM_WRITE | VISIBLE_LV,
-				     ALLOC_INHERIT, 1, origin->vg)))
+				     ALLOC_INHERIT, 1, origin->vg))) {
+		origin->vg->lv_count++;
 		return_0;
+	}
 
 	snap->le_count = extent_count;
 
@@ -93,7 +101,6 @@
 
 	origin->origin_count++;
 	origin->vg->snapshot_count++;
-	origin->vg->lv_count--;
 	cow->snapshot = seg;
 
 	cow->status &= ~VISIBLE_LV;
--- LVM2/test/t-lvcreate-usage.sh	2008/11/10 12:37:03	1.9
+++ LVM2/test/t-lvcreate-usage.sh	2009/03/16 14:34:58	1.10
@@ -58,3 +58,12 @@
 grep "^  Invalid stripe size 3\.00 KB\$" err
 case $(lvdisplay $vg) in "") true ;; *) false ;; esac
 
+# Setting max_lv works. (bz490298)
+vgchange -l 4 $vg
+lvcreate -l1 -n $lv1 $vg
+lvcreate -l1 -s -n $lv2 $vg/$lv1
+lvcreate -l1 -n $lv3 $vg
+not lvcreate -l1 -n $lv4 $vg
+vgs $vg
+lvremove -ff $vg
+vgchange -l 0 $vg
--- LVM2/tools/lvcreate.c	2009/02/28 20:04:25	1.179
+++ LVM2/tools/lvcreate.c	2009/03/16 14:34:58	1.180
@@ -836,7 +836,7 @@
 		if (!vg_add_snapshot(NULL, org, lv, NULL,
 				     org->le_count, lp->chunk_size)) {
 			log_error("Couldn't create snapshot.");
-			return 0;
+			goto deactivate_and_revert_new_lv;
 		}
 
 		/* store vg on disk(s) */
--- LVM2/tools/vgck.c	2008/01/30 14:00:02	1.18
+++ LVM2/tools/vgck.c	2009/03/16 14:34:58	1.19
@@ -33,6 +33,9 @@
 	if (!vg_check_status(vg, EXPORTED_VG))
 		return ECMD_FAILED;
 
+	if (!vg_validate(vg))
+		return ECMD_FAILED;
+
 	return ECMD_PROCESSED;
 }
 


