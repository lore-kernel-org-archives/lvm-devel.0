From: Jonathan Brassow <jbrassow@redhat.com>
Date: Mon, 10 Jan 2011 14:56:48 -0600
Subject: [PATCH 3 of 4] LVM: allow disk to mirror log conversion
Message-ID: <201101102056.p0AKum46012036@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Patch name: lvm-allow-disk-to-mirror-log-conversion.patch

Add ability to convert disk log to mirrored log

We can convert between any combination of mirror logs except
disk -> mirrored.  This patch fixes that.
Index: LVM2/lib/metadata/mirror.c
===================================================================
--- LVM2.orig/lib/metadata/mirror.c
+++ LVM2/lib/metadata/mirror.c
@@ -1322,7 +1322,9 @@ static int _create_mimage_lvs(struct all
 		}
 
 		if (log) {
-			if (!lv_add_log_segment(ah, m * stripes + 1, img_lvs[m], 0)) {
+			uint32_t first_area = m * stripes + (log - 1);
+
+			if (!lv_add_log_segment(ah, first_area, img_lvs[m], 0)) {
 				log_error("Aborting. Failed to add mirror image segment "
 					  "to %s. Remove new LV and retry.",
 					  img_lvs[m]->name);
@@ -1760,7 +1762,7 @@ static struct logical_volume *_set_up_mi
 	}
 
 	if ((log_count > 1) &&
-	    !_form_mirror(cmd, ah, log_lv, log_count-1, 1, 0, region_size, 1)) {
+	    !_form_mirror(cmd, ah, log_lv, log_count-1, 1, 0, region_size, 2)) {
 		log_error("Failed to form mirrored log.");
 		return NULL;
 	}
@@ -1792,6 +1794,7 @@ int add_mirror_log(struct cmd_context *c
 	int in_sync;
 	struct logical_volume *log_lv;
 	struct lvinfo info;
+	int old_log_count;
 	int r = 0;
 
 	if (dm_list_size(&lv->segments) != 1) {
@@ -1811,6 +1814,11 @@ int add_mirror_log(struct cmd_context *c
 		return 0;
 	}
 
+	log_lv = first_seg(lv)->log_lv;
+	old_log_count = (log_lv) ? lv_mirror_count(log_lv) : 0;
+	if (old_log_count == log_count)
+		return_0;
+
 	if (!(parallel_areas = build_parallel_areas_from_lv(cmd, lv, 0)))
 		return_0;
 
@@ -1826,13 +1834,24 @@ int add_mirror_log(struct cmd_context *c
 
 	/* allocate destination extents */
 	ah = allocate_extents(lv->vg, NULL, segtype,
-			      0, 0, log_count, region_size, 0,
+			      0, 0, log_count - old_log_count, region_size, 0,
 			      allocatable_pvs, alloc, parallel_areas);
 	if (!ah) {
 		log_error("Unable to allocate extents for mirror log.");
 		return 0;
 	}
 
+	if (old_log_count) {
+		/* Converting from disk to mirrored log */
+		if (!_form_mirror(cmd, ah, log_lv, log_count - 1, 1, 0,
+				  region_size, 1)) {
+			log_error("Failed to convert mirror log");
+			return 0;
+		}
+		r = 1;
+		goto out;
+	}
+
 	/* check sync status */
 	if (lv_mirror_percent(cmd, lv, 0, &sync_percent, NULL) &&
 	    (sync_percent == PERCENT_100))
Index: LVM2/tools/lvconvert.c
===================================================================
--- LVM2.orig/tools/lvconvert.c
+++ LVM2/tools/lvconvert.c
@@ -718,6 +718,7 @@ static int _lv_update_mirrored_log(struc
 				    operable_pvs, 0U);
 }
 
+static int _reload_lv(struct cmd_context *cmd, struct logical_volume *lv);
 static int _lv_update_log_type(struct cmd_context *cmd,
 			       struct lvconvert_params *lp,
 			       struct logical_volume *lv,
@@ -738,14 +739,6 @@ static int _lv_update_log_type(struct cm
 						  lv->le_count,
 						  lp->region_size);
 
-	/* Add a log where there is none */
-	if (!old_log_count) {
-		if (!add_mirror_log(cmd, original_lv, log_count,
-				    region_size, operable_pvs, lp->alloc))
-			return_0;
-		return 1;
-	}
-
 	/* Remove an existing log completely */
 	if (!log_count) {
 		if (!remove_mirror_log(cmd, original_lv, operable_pvs,
@@ -759,9 +752,17 @@ static int _lv_update_log_type(struct cm
 
 	/* Adding redundancy to the log */
 	if (old_log_count < log_count) {
-		log_error("Adding log redundancy not supported yet.");
-		log_error("Try converting the log to 'core' first.");
-		return_0;
+		if (!add_mirror_log(cmd, original_lv, log_count,
+				    region_size, operable_pvs, lp->alloc))
+			return_0;
+		/*
+		 * FIXME: This simple approach won't work in cluster mirrors,
+		 *        but it doesn't matter because we don't support
+		 *        mirrored logs in cluster mirrors.
+		 */
+		if (old_log_count)
+			return _reload_lv(cmd, log_lv);
+		return 1;
 	}
 
 	/* Reducing redundancy of the log */
@@ -1109,7 +1110,8 @@ static int _lvconvert_mirrors_aux(struct
 
 		/* FIXME: can't have multiple mlogs. force corelog. */
 		if (!lv_add_mirrors(cmd, lv,
-				    new_mimage_count - old_mimage_count, lp->stripes, lp->stripe_size,
+				    new_mimage_count - old_mimage_count,
+				    lp->stripes, lp->stripe_size,
 				    region_size, 0U, operable_pvs, lp->alloc,
 				    MIRROR_BY_LV)) {
 			layer_lv = seg_lv(first_seg(lv), 0);


