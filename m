From: agk@sourceware.org <agk@sourceware.org>
Date: 26 Jan 2008 00:25:05 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c lib/m ...
Message-ID: <20080126002505.4254.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-01-26 00:25:04

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c metadata-exported.h mirror.c 
	tools          : lvchange.c 

Log message:
	Refactor mirror log attachment code.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.777&r2=1.778
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.146&r2=1.147
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.41&r2=1.42
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.65&r2=1.66
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvchange.c.diff?cvsroot=lvm2&r1=1.86&r2=1.87

--- LVM2/WHATS_NEW	2008/01/26 00:13:44	1.777
+++ LVM2/WHATS_NEW	2008/01/26 00:25:04	1.778
@@ -1,5 +1,6 @@
 Version 2.02.32 -
 ===================================
+  Refactor mirror log attachment code.
   Fix internal metadata corruption in lvchange --resync. (2.02.30)
   Fix new parameter validation in vgsplit and test mode. (2.02.30)
   Remove redundant cnxman-socket.h file from clvmd directory.
--- LVM2/lib/metadata/lv_manip.c	2008/01/18 22:00:46	1.146
+++ LVM2/lib/metadata/lv_manip.c	2008/01/26 00:25:04	1.147
@@ -208,11 +208,8 @@
 	seg->log_lv = log_lv;
 	list_init(&seg->tags);
 
-	if (log_lv) {
-		log_lv->status |= MIRROR_LOG;
-		if (!add_seg_to_segs_using_this_lv(log_lv, seg))
-			return_NULL;
-	}
+	if (log_lv && !attach_mirror_log(seg, log_lv))
+		return_NULL;
 
 	return seg;
 }
--- LVM2/lib/metadata/metadata-exported.h	2008/01/18 22:02:37	1.41
+++ LVM2/lib/metadata/metadata-exported.h	2008/01/26 00:25:04	1.42
@@ -495,6 +495,8 @@
 		      uint32_t mirrors, uint32_t stripes, uint32_t region_size,
 		      struct list *allocatable_pvs, alloc_policy_t alloc,
 		      uint32_t log_count);
+struct logical_volume *detach_mirror_log(struct lv_segment *seg);
+int attach_mirror_log(struct lv_segment *seg, struct logical_volume *lv);
 int remove_mirror_log(struct cmd_context *cmd, struct logical_volume *lv,
 		      struct list *removable_pvs);
 int add_mirror_log(struct cmd_context *cmd, struct logical_volume *lv,
--- LVM2/lib/metadata/mirror.c	2008/01/18 22:02:37	1.65
+++ LVM2/lib/metadata/mirror.c	2008/01/26 00:25:04	1.66
@@ -355,17 +355,20 @@
 }
 
 /* Unlink the relationship between the segment and its log_lv */
-static void _remove_mirror_log(struct lv_segment *mirrored_seg)
+struct logical_volume *detach_mirror_log(struct lv_segment *mirrored_seg)
 {
 	struct logical_volume *log_lv;
 
 	if (!mirrored_seg->log_lv)
-		return;
+		return NULL;
 
 	log_lv = mirrored_seg->log_lv;
 	mirrored_seg->log_lv = NULL;
+	log_lv->status |= VISIBLE_LV;
 	log_lv->status &= ~MIRROR_LOG;
 	remove_seg_from_segs_using_this_lv(log_lv, mirrored_seg);
+
+	return log_lv;
 }
 
 /* Check if mirror image LV is removable with regard to given removable_pvs */
@@ -438,7 +441,7 @@
 	uint32_t m;
 	uint32_t s;
 	struct logical_volume *sub_lv;
-	struct logical_volume *log_lv = NULL;
+	struct logical_volume *detached_log_lv = NULL;
 	struct logical_volume *lv1 = NULL;
 	struct lv_segment *mirrored_seg = first_seg(lv);
 	struct lv_segment_area area;
@@ -495,22 +498,17 @@
 	}
 	mirrored_seg->area_count = new_area_count;
 
-	/* Save log_lv as mirrored_seg may not be available after
-	 * remove_layer_from_lv(), */
-	log_lv = mirrored_seg->log_lv;
-
 	/* If no more mirrors, remove mirror layer */
 	/* As an exceptional case, if the lv is temporary layer,
 	 * leave the LV as mirrored and let the lvconvert completion
 	 * to remove the layer. */
 	if (new_area_count == 1 && !is_temporary_mirror_layer(lv)) {
 		lv1 = seg_lv(mirrored_seg, 0);
-		_remove_mirror_log(mirrored_seg);
+		detached_log_lv = detach_mirror_log(mirrored_seg);
 		if (!remove_layer_from_lv(lv, lv1))
 			return_0;
 		lv->status &= ~MIRRORED;
 		lv->status &= ~MIRROR_NOTSYNCED;
-		remove_log = 1;
 		if (collapse && !_merge_mirror_images(lv, &tmp_orphan_lvs)) {
 			log_error("Failed to add mirror images");
 			return 0;
@@ -520,17 +518,13 @@
 
 		/* All mirror images are gone.
 		 * It can happen for vgreduce --removemissing. */
-		_remove_mirror_log(mirrored_seg);
+		detached_log_lv = detach_mirror_log(mirrored_seg);
 		lv->status &= ~MIRRORED;
 		lv->status &= ~MIRROR_NOTSYNCED;
 		if (!replace_lv_with_error_segment(lv))
 			return_0;
-		remove_log = 1;
 	} else if (remove_log)
-		_remove_mirror_log(mirrored_seg);
-
-	if (remove_log && log_lv)
-		log_lv->status |= VISIBLE_LV;
+		detached_log_lv = detach_mirror_log(mirrored_seg);
 
 	/*
 	 * To successfully remove these unwanted LVs we need to
@@ -565,19 +559,20 @@
 	if (!collapse) {
 		list_iterate_items(lvl, &tmp_orphan_lvs)
 			if (!_delete_lv(lv, lvl->lv))
-				return 0;
+				return_0;
 	}
 
 	if (lv1 && !_delete_lv(lv, lv1))
-		return 0;
+		return_0;
 
-	if (remove_log && log_lv && !_delete_lv(lv, log_lv))
-		return 0;
+	if (detached_log_lv && !_delete_lv(lv, detached_log_lv))
+		return_0;
 
 	/* Mirror with only 1 area is 'in sync'. */
-	if (!remove_log && log_lv &&
-	    new_area_count == 1 && is_temporary_mirror_layer(lv)) {
-		if (!_init_mirror_log(lv->vg->cmd, log_lv, 1, &lv->tags, 0)) {
+	if (new_area_count == 1 && is_temporary_mirror_layer(lv)) {
+		if (first_seg(lv)->log_lv &&
+		    !_init_mirror_log(lv->vg->cmd, first_seg(lv)->log_lv,
+				      1, &lv->tags, 0)) {
 			/* As a result, unnecessary sync may run after
 			 * collapsing. But safe.*/
 			log_error("Failed to initialize log device");
@@ -1245,12 +1240,12 @@
 	return log_lv;
 }
 
-static void _add_mirror_log(struct logical_volume *lv,
-			    struct logical_volume *log_lv)
+int attach_mirror_log(struct lv_segment *seg, struct logical_volume *log_lv)
 {
-	first_seg(lv)->log_lv = log_lv;
+	seg->log_lv = log_lv;
 	log_lv->status |= MIRROR_LOG;
-	add_seg_to_segs_using_this_lv(log_lv, first_seg(lv));
+	log_lv->status &= ~VISIBLE_LV;
+	return add_seg_to_segs_using_this_lv(log_lv, seg);
 }
 
 int add_mirror_log(struct cmd_context *cmd,
@@ -1310,7 +1305,8 @@
 					  region_size, alloc, in_sync)))
 		return_0;
 
-	_add_mirror_log(lv, log_lv);
+	if (!attach_mirror_log(first_seg(lv), log_lv))
+		return_0;
 
 	alloc_destroy(ah);
 	return 1;
@@ -1392,8 +1388,8 @@
 		goto out_remove_imgs;
 	}
 
-	if (log_count)
-		_add_mirror_log(lv, log_lv);
+	if (log_count && !attach_mirror_log(first_seg(lv), log_lv))
+		stack;
 
 	alloc_destroy(ah);
 	return 1;
--- LVM2/tools/lvchange.c	2008/01/26 00:13:45	1.86
+++ LVM2/tools/lvchange.c	2008/01/26 00:25:04	1.87
@@ -271,21 +271,14 @@
 
 	if (log_lv) {
 		/* Separate mirror log so we can clear it */
-		first_seg(lv)->log_lv = NULL;
-		log_lv->status &= ~MIRROR_LOG;
-		log_lv->status |= VISIBLE_LV;
-		remove_seg_from_segs_using_this_lv(log_lv, first_seg(lv));
+		detach_mirror_log(first_seg(lv));
 
 		if (!vg_write(lv->vg)) {
 			log_error("Failed to write intermediate VG metadata.");
-			if (active) {
-				first_seg(lv)->log_lv = log_lv;
-				log_lv->status |= MIRROR_LOG;
-				log_lv->status &= ~VISIBLE_LV;
-				add_seg_to_segs_using_this_lv(log_lv, first_seg(lv));
-				if (!activate_lv(cmd, lv))
-					stack;
-			}
+			if (!attach_mirror_log(first_seg(lv), log_lv))
+				stack;
+			if (active && !activate_lv(cmd, lv))
+				stack;
 			return 0;
 		}
 
@@ -293,14 +286,10 @@
 
 		if (!vg_commit(lv->vg)) {
 			log_error("Failed to commit intermediate VG metadata.");
-			if (active) {
-				first_seg(lv)->log_lv = log_lv;
-				log_lv->status |= MIRROR_LOG;
-				log_lv->status &= ~VISIBLE_LV;
-				add_seg_to_segs_using_this_lv(log_lv, first_seg(lv));
-				if (!activate_lv(cmd, lv))
-					stack;
-			}
+			if (!attach_mirror_log(first_seg(lv), log_lv))
+				stack;
+			if (active && !activate_lv(cmd, lv))
+				stack;
 			return 0;
 		}
 
@@ -326,10 +315,8 @@
 		}
 
 		/* Put mirror log back in place */
-		first_seg(lv)->log_lv = log_lv;
-		log_lv->status |= MIRROR_LOG;
-		log_lv->status &= ~VISIBLE_LV;
-		add_seg_to_segs_using_this_lv(log_lv, first_seg(lv));
+		if (!attach_mirror_log(first_seg(lv), log_lv))
+			stack;
 	}
 
 	log_very_verbose("Updating logical volume \"%s\" on disk(s)", lv->name);


