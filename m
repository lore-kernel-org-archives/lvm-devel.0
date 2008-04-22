From: agk@sourceware.org <agk@sourceware.org>
Date: 22 Apr 2008 12:54:33 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata.c lib/m ...
Message-ID: <20080422125433.19007.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-04-22 12:54:33

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata.c lv_manip.c 

Log message:
	Check lv_count in vg_validate.
	Fix internal LV counter when a snapshot is removed.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.856&r2=1.857
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.171&r2=1.172
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.153&r2=1.154

--- LVM2/WHATS_NEW	2008/04/22 11:47:22	1.856
+++ LVM2/WHATS_NEW	2008/04/22 12:54:32	1.857
@@ -1,5 +1,7 @@
 Version 2.02.36 - 
 =================================
+  Check lv_count in vg_validate.
+  Fix internal LV counter when a snapshot is removed.
   Fix metadata corruption writing lvm1-formatted metadata with snapshots.
   Add --prefixes to reporting tools for field name prefix output format.
   Fix lvconvert -m0 allocatable space check.
--- LVM2/lib/metadata/metadata.c	2008/04/15 14:46:19	1.171
+++ LVM2/lib/metadata/metadata.c	2008/04/22 12:54:33	1.172
@@ -1177,6 +1177,7 @@
 	struct lv_list *lvl, *lvl2;
 	char uuid[64] __attribute((aligned(8)));
 	int r = 1;
+	uint32_t lv_count;
 
 	/* FIXME Also check there's no data/metadata overlap */
 
@@ -1210,6 +1211,15 @@
 		r = 0;
 	}
 
+	if ((lv_count = (uint32_t) list_size(&vg->lvs)) !=
+	    vg->lv_count + 2 * vg->snapshot_count) {
+		log_error("Internal error: #internal LVs (%u) != #LVs (%"
+			  PRIu32 ") + 2 * #snapshots (%" PRIu32 ") in VG %s",
+			  list_size(&vg->lvs), vg->lv_count,
+			  vg->snapshot_count, vg->name);
+		r = 0;
+	}
+
 	list_iterate_items(lvl, &vg->lvs) {
 		list_iterate_items(lvl2, &vg->lvs) {
 			if (lvl == lvl2)
--- LVM2/lib/metadata/lv_manip.c	2008/04/10 17:09:31	1.153
+++ LVM2/lib/metadata/lv_manip.c	2008/04/22 12:54:33	1.154
@@ -439,7 +439,8 @@
 
 		list_del(&lvl->list);
 
-		lv->vg->lv_count--;
+		if (!(lv->status & SNAPSHOT))
+			lv->vg->lv_count--;
 	} else if (lv->vg->fid->fmt->ops->lv_setup &&
 		   !lv->vg->fid->fmt->ops->lv_setup(lv->vg->fid, lv))
 		return_0;


