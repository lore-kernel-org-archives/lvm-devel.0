From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 11 Apr 2012 01:23:30 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/raid_manip.c
Message-ID: <20120411012330.22012.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2012-04-11 01:23:29

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : raid_manip.c 

Log message:
	RAID LVs could not handle a down-convert if a device other than the last one
	in the array was specified for removal.  This change addresses that (bz806111).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2376&r2=1.2377
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/raid_manip.c.diff?cvsroot=lvm2&r1=1.25&r2=1.26

--- LVM2/WHATS_NEW	2012/04/10 23:34:41	1.2376
+++ LVM2/WHATS_NEW	2012/04/11 01:23:29	1.2377
@@ -1,5 +1,6 @@
 Version 2.02.96 - 
 ================================
+  Fix problems when specifying PVs during RAID down-converts.
   Fix ability to handle failures in mirrored log (regression intro 2.02.89).
   Fix unlocking volume group in vgreduce in error path.
   Exit immediately if LISTEN_PID env var incorrect during systemd handover.
--- LVM2/lib/metadata/raid_manip.c	2012/03/15 20:00:54	1.25
+++ LVM2/lib/metadata/raid_manip.c	2012/04/11 01:23:29	1.26
@@ -975,6 +975,8 @@
 static int _raid_remove_images(struct logical_volume *lv,
 			       uint32_t new_count, struct dm_list *pvs)
 {
+	uint32_t s;
+	struct lv_segment *seg;
 	struct dm_list removal_list;
 	struct lv_list *lvl;
 
@@ -1024,9 +1026,21 @@
 	}
 
 	/*
-	 * Resume original LV
-	 * This also resumes all other sub-LVs
+	 * Resume the remaining LVs
+	 * We must start by resuming the sub-LVs first (which would
+	 * otherwise be handled automatically) because the shifting
+	 * of positions could otherwise cause name collisions.  For
+	 * example, if position 0 of a 3-way array is removed, position
+	 * 1 and 2 must be shifted and renamed 0 and 1.  If position 2
+	 * tries to rename first, it will collide with the existing
+	 * position 1.
 	 */
+	seg = first_seg(lv);
+	for (s = 0; (new_count > 1) && (s < seg->area_count); s++) {
+		if (!resume_lv(lv->vg->cmd, seg_lv(seg, s)) ||
+		    !resume_lv(lv->vg->cmd, seg_metalv(seg, s)))
+			return_0;
+	}
 	if (!resume_lv(lv->vg->cmd, lv)) {
 		log_error("Failed to resume %s/%s after committing changes",
 			  lv->vg->name, lv->name);


