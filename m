From: agk@sourceware.org <agk@sourceware.org>
Date: 20 Dec 2011 00:02:19 -0000
Subject: LVM2 lib/metadata/lv_manip.c lib/metadata/snap ...
Message-ID: <20111220000219.345.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-12-20 00:02:19

Modified files:
	lib/metadata   : lv_manip.c snapshot_manip.c 
	.              : WHATS_NEW 

Log message:
	Reinstate support for format1 snapshots, but issue deprecated warning.
	
	I anticipate removing support for snapshots with lvm1-formatted metadata in a
	future release.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.338&r2=1.339
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/snapshot_manip.c.diff?cvsroot=lvm2&r1=1.51&r2=1.52
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2205&r2=1.2206

--- LVM2/lib/metadata/lv_manip.c	2011/11/18 19:25:20	1.338
+++ LVM2/lib/metadata/lv_manip.c	2011/12/20 00:02:18	1.339
@@ -3138,6 +3138,8 @@
 {
 	struct volume_group *vg;
 	struct lvinfo info;
+	struct logical_volume *format1_origin = NULL;
+	int format1_reload_required = 0;
 
 	vg = lv->vg;
 
@@ -3195,6 +3197,10 @@
 		return 0;
 
 	if (lv_is_cow(lv)) {
+		/* Old format1 code */
+		if (!(lv->vg->fid->fmt->features & FMT_MDAS))
+			format1_origin = origin_from_cow(lv);
+
 		log_verbose("Removing snapshot %s", lv->name);
 		/* vg_remove_snapshot() will preload origin/former snapshots */
 		if (!vg_remove_snapshot(lv))
@@ -3214,12 +3220,31 @@
 		return 0;
 	}
 
+	/*
+	 * Old format1 code: If no snapshots left reload without -real.
+	 */
+	if (format1_origin && !lv_is_origin(format1_origin)) {
+		log_warn("WARNING: Support for snapshots with old LVM1-style metadata is deprecated.");
+		log_warn("WARNING: Please use lvconvert to update to lvm2 metadata at your convenience.");
+		format1_reload_required = 1;
+	}
+
 	/* store it on disks */
 	if (!vg_write(vg))
 		return_0;
 
+	/* format1 */
+	if (format1_reload_required && !suspend_lv(cmd, format1_origin))
+		log_error("Failed to refresh %s without snapshot.", format1_origin->name);
+
 	if (!vg_commit(vg))
 		return_0;
+ 
+	/* format1 */
+	if (format1_reload_required && !resume_lv(cmd, format1_origin)) {
+		log_error("Failed to resume %s.", format1_origin->name);
+		return 0;
+	}
 
 	backup(vg);
 
--- LVM2/lib/metadata/snapshot_manip.c	2011/07/19 16:23:52	1.51
+++ LVM2/lib/metadata/snapshot_manip.c	2011/12/20 00:02:18	1.52
@@ -208,6 +208,10 @@
 	cow->snapshot = NULL;
 	lv_set_visible(cow);
 
+	/* format1 must do the change in one step, with the commit last. */
+	if (!(origin->vg->fid->fmt->features & FMT_MDAS))
+		return 1;
+
 	if (!vg_write(origin->vg))
 		return_0;
 	if (!suspend_lv(origin->vg->cmd, origin)) {
--- LVM2/WHATS_NEW	2011/12/08 21:24:08	1.2205
+++ LVM2/WHATS_NEW	2011/12/20 00:02:19	1.2206
@@ -1,5 +1,7 @@
 Version 2.02.89 - 
 ==================================
+  Issue deprecation warning when removing last lvm1-format snapshot.
+  Reinstate support for snapshot removal with lvm1 format. (2.02.86)
   Add policy based automated repair of RAID logical volumes
   Don't allow two images to be split and tracked from a RAID LV at one time
   Don't allow size change of RAID LV that is tracking changes for a split image


