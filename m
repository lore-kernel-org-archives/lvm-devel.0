From: agk@sourceware.org <agk@sourceware.org>
Date: 26 Oct 2009 10:02:00 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/dev_manager.c li ...
Message-ID: <20091026100200.24575.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-10-26 10:01:58

Modified files:
	.              : WHATS_NEW 
	lib/activate   : dev_manager.c 
	lib/display    : display.c 
	lib/metadata   : lv_manip.c 
	lib/report     : report.c 
	tools          : lvconvert.c vgsplit.c 

Log message:
	Permit snapshots of mirrors.  (brassow)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1302&r2=1.1303
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.160&r2=1.161
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/display/display.c.diff?cvsroot=lvm2&r1=1.105&r2=1.106
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.184&r2=1.185
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.104&r2=1.105
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.95&r2=1.96
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.94&r2=1.95

--- LVM2/WHATS_NEW	2009/10/23 01:24:17	1.1302
+++ LVM2/WHATS_NEW	2009/10/26 10:01:56	1.1303
@@ -1,5 +1,6 @@
 Version 2.02.54 -
 =====================================
+  Permit snapshots of mirrors.
   Cleanup mimagetmp LV if allocation fails for new lvconvert mimage.
   Fix clvmd segfault when refresh_toolcontext fails.
   Remember to clear 'global lock held during cache refresh' state after use.
--- LVM2/lib/activate/dev_manager.c	2009/10/22 13:00:07	1.160
+++ LVM2/lib/activate/dev_manager.c	2009/10/26 10:01:57	1.161
@@ -551,16 +551,17 @@
 {
 	char *name;
 	const char *dlid;
+	const char *suffix = (lv_is_origin(lv)) ? "real" : NULL;
 
 	/*
 	 * Build a name for the top layer.
 	 */
-	if (!(name = build_dm_name(dm->mem, lv->vg->name, lv->name, NULL)))
+	if (!(name = build_dm_name(dm->mem, lv->vg->name, lv->name, suffix)))
 		return_0;
 
 	/* FIXME dm_pool_free ? */
 
-	if (!(dlid = build_dlid(dm, lv->lvid.s, NULL))) {
+	if (!(dlid = build_dlid(dm, lv->lvid.s, suffix))) {
 		log_error("dlid build failed for %s", lv->name);
 		return 0;
 	}
--- LVM2/lib/display/display.c	2009/10/01 00:35:29	1.105
+++ LVM2/lib/display/display.c	2009/10/26 10:01:57	1.106
@@ -480,7 +480,7 @@
 	struct lvinfo info;
 	int inkernel, snap_active = 0;
 	char uuid[64] __attribute((aligned(8)));
-	struct lv_segment *snap_seg = NULL;
+	struct lv_segment *snap_seg = NULL, *mirror_seg = NULL;
 	float snap_percent;	/* fused, fsize; */
 	percent_range_t percent_range;
 
@@ -563,6 +563,13 @@
 			  display_size(cmd, (uint64_t) snap_seg->chunk_size));
 	}
 
+	if (lv->status & MIRRORED) {
+ 		mirror_seg = first_seg(lv);
+		log_print("Mirrored volumes       %" PRIu32, mirror_seg->area_count);
+		if (lv->status & CONVERTING)
+			log_print("LV type        Mirror undergoing conversion");
+	}
+
 	log_print("Segments               %u", dm_list_size(&lv->segments));
 
 /********* FIXME Stripes & stripesize for each segment
--- LVM2/lib/metadata/lv_manip.c	2009/09/28 17:46:16	1.184
+++ LVM2/lib/metadata/lv_manip.c	2009/10/26 10:01:57	1.185
@@ -2936,11 +2936,12 @@
 					  "supported yet");
 				return 0;
 			}
-			if (org->status & MIRROR_IMAGE ||
-			    org->status & MIRROR_LOG ||
-			    org->status & MIRRORED) {
-				log_error("Snapshots and mirrors may not yet "
-					  "be mixed.");
+			if ((org->status & MIRROR_IMAGE) ||
+			    (org->status & MIRROR_LOG)) {
+				log_error("Snapshots of mirror %ss "
+					  "are not supported",
+					  (org->status & MIRROR_LOG) ?
+					  "log" : "image");
 				return 0;
 			}
 
--- LVM2/lib/report/report.c	2009/10/01 01:04:27	1.104
+++ LVM2/lib/report/report.c	2009/10/26 10:01:57	1.105
@@ -311,6 +311,11 @@
 		repstr[0] = 'p';
 	else if (lv->status & CONVERTING)
 		repstr[0] = 'c';
+	else if (lv->status & VIRTUAL)
+		repstr[0] = 'v';
+	/* Origin takes precedence over Mirror */
+	else if (lv_is_origin(lv))
+		repstr[0] = 'o';
 	else if (lv->status & MIRRORED) {
 		if (lv->status & MIRROR_NOTSYNCED)
 			repstr[0] = 'M';
@@ -323,10 +328,6 @@
 			repstr[0] = 'I';
 	else if (lv->status & MIRROR_LOG)
 		repstr[0] = 'l';
-	else if (lv->status & VIRTUAL)
-		repstr[0] = 'v';
-	else if (lv_is_origin(lv))
-		repstr[0] = 'o';
 	else if (lv_is_cow(lv))
 		repstr[0] = 's';
 	else
--- LVM2/tools/lvconvert.c	2009/10/23 01:24:17	1.95
+++ LVM2/tools/lvconvert.c	2009/10/26 10:01:57	1.96
@@ -713,6 +713,20 @@
 				  "LV: use lvchange --resync first.");
 			return 0;
 		}
+
+		/*
+		 * We allow snapshots of mirrors, but for now, we
+		 * do not allow up converting mirrors that are under
+		 * snapshots.  The layering logic is somewhat complex,
+		 * and preliminary test show that the conversion can't
+		 * seem to get the correct %'age of completion.
+		 */
+		if (lv_is_origin(lv)) {
+			log_error("Can't add additional mirror images to "
+				  "mirrors that are under snapshots");
+			return 0;
+		}
+
 		/*
 		 * Log addition/removal should be done before the layer
 		 * insertion to make the end result consistent with
@@ -891,12 +905,6 @@
 		return ECMD_FAILED;
 	}
 
-	if (lv_is_origin(lv)) {
-		log_error("Can't convert logical volume \"%s\" under snapshot",
-			  lv->name);
-		return ECMD_FAILED;
-	}
-
 	if (lv_is_cow(lv)) {
 		log_error("Can't convert snapshot logical volume \"%s\"",
 			  lv->name);
--- LVM2/tools/vgsplit.c	2009/09/14 22:47:50	1.94
+++ LVM2/tools/vgsplit.c	2009/10/26 10:01:57	1.95
@@ -411,14 +411,15 @@
 	if (!(_move_lvs(vg_from, vg_to)))
 		goto_bad;
 
-	/* Move required snapshots across */
-	if (!(_move_snapshots(vg_from, vg_to)))
-		goto_bad;
-
+	/* FIXME Separate the 'move' from the 'validation' to fix dev stacks */
 	/* Move required mirrors across */
 	if (!(_move_mirrors(vg_from, vg_to)))
 		goto_bad;
 
+	/* Move required snapshots across */
+	if (!(_move_snapshots(vg_from, vg_to)))
+		goto_bad;
+
 	/* Split metadata areas and check if both vgs have at least one area */
 	if (!(vg_split_mdas(cmd, vg_from, vg_to)) && vg_from->pv_count) {
 		log_error("Cannot split: Nowhere to store metadata for new Volume Group");


