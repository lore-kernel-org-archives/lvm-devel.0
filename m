From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 20 Jan 2010 21:53:10 -0000
Subject: LVM2/lib/metadata lv_manip.c
Message-ID: <20100120215310.28008.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-01-20 21:53:10

Modified files:
	lib/metadata   : lv_manip.c 

Log message:
	Preload the origin prior to suspend IFF snapshot(s) still exist after a
	merge completes.  This narrows the scope of this "hack" (which still
	needs a proper fix within the deptree).
	
	This stops dmeventd from trying to access snapshot devices that were
	already removed.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.206&r2=1.207

--- LVM2/lib/metadata/lv_manip.c	2010/01/14 14:39:57	1.206
+++ LVM2/lib/metadata/lv_manip.c	2010/01/20 21:53:10	1.207
@@ -2064,7 +2064,7 @@
 	struct volume_group *vg;
 	struct lvinfo info;
 	struct logical_volume *origin = NULL;
-	int was_merging = 0;
+	int was_merging = 0, preload_origin = 0;
 
 	vg = lv->vg;
 
@@ -2130,6 +2130,11 @@
 		log_verbose("Removing snapshot %s", lv->name);
 		if (!vg_remove_snapshot(lv))
 			return_0;
+		if (was_merging && lv_is_origin(origin)) {
+			/* snapshot(s) still exist. preload new origin prior to suspend. */
+			/* FIXME Seek a simpler way of dealing with this within the tree. */
+			preload_origin = 1;
+		}
 	}
 
 	log_verbose("Releasing logical volume \"%s\"", lv->name);
@@ -2142,22 +2147,21 @@
 	if (!vg_write(vg))
 		return_0;
 
-	/* FIXME Seek a simpler way of dealing with this within the tree. */
+	if (!preload_origin && !vg_commit(vg))
+		return_0;
+
 	/* If no snapshots left or if we stopped merging, reload */
 	if (origin && (!lv_is_origin(origin) || was_merging)) {
 		if (!suspend_lv(cmd, origin)) {
 			log_error("Failed to refresh %s without snapshot.", origin->name);
 			return 0;
 		}
-		if (!vg_commit(vg))
+		if (preload_origin && !vg_commit(vg))
 			return_0;
 		if (!resume_lv(cmd, origin)) {
 			log_error("Failed to resume %s.", origin->name);
 			return 0;
 		}
-	} else {
-		if (!vg_commit(vg))
-			return_0;
 	}
 
 	backup(vg);


