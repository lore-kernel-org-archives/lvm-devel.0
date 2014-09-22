From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 22 Sep 2014 15:37:57 +0000 (UTC)
Subject: dev-dct-process-latest - cleanup: plain code reindent
Message-ID: <20140922153757.5376A60EE6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=126463ad1fd653f76d5cd112e02d5214e0433587
Commit:        126463ad1fd653f76d5cd112e02d5214e0433587
Parent:        ad376e9e00eaa453e7d8ba1ffdc763345ec49d0e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 11 20:08:56 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 12 13:51:30 2014 +0200

cleanup: plain code reindent

Just simple reindent and brace changes.
---
 lib/metadata/raid_manip.c |  119 ++++++++++++++++++++++-----------------------
 1 files changed, 58 insertions(+), 61 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index d0740e8..2369f5f 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2011 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2011-2014 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -26,10 +26,9 @@ static int _lv_is_raid_with_tracking(const struct logical_volume *lv,
 				     struct logical_volume **tracking)
 {
 	uint32_t s;
-	struct lv_segment *seg;
+	const struct lv_segment *seg = first_seg(lv);
 
 	*tracking = NULL;
-	seg = first_seg(lv);
 
 	if (!(lv->status & RAID))
 		return 0;
@@ -39,7 +38,6 @@ static int _lv_is_raid_with_tracking(const struct logical_volume *lv,
 		    !(seg_lv(seg, s)->status & LVM_WRITE))
 			*tracking = seg_lv(seg, s);
 
-
 	return *tracking ? 1 : 0;
 }
 
@@ -130,11 +128,8 @@ static int _raid_remove_top_layer(struct logical_volume *lv,
 		return 0;
 	}
 
-	lvl_array = dm_pool_alloc(lv->vg->vgmem, 2 * sizeof(*lvl));
-	if (!lvl_array) {
-		log_error("Memory allocation failed.");
-		return 0;
-	}
+	if (!(lvl_array = dm_pool_alloc(lv->vg->vgmem, 2 * sizeof(*lvl))))
+		return_0;
 
 	/* Add last metadata area to removal_list */
 	lvl_array[0].lv = seg_metalv(seg, 0);
@@ -154,6 +149,7 @@ static int _raid_remove_top_layer(struct logical_volume *lv,
 		return_0;
 
 	lv->status &= ~(MIRRORED | RAID);
+
 	return 1;
 }
 
@@ -385,9 +381,8 @@ static int _alloc_image_component(struct logical_volume *lv,
 	}
 
 	status = LVM_READ | LVM_WRITE | LV_REBUILD | type;
-	tmp_lv = lv_create_empty(img_name, NULL, status, ALLOC_INHERIT, lv->vg);
-	if (!tmp_lv) {
-		log_error("Failed to allocate new raid component, %s", img_name);
+	if (!(tmp_lv = lv_create_empty(img_name, NULL, status, ALLOC_INHERIT, lv->vg))) {
+		log_error("Failed to allocate new raid component, %s.", img_name);
 		return 0;
 	}
 
@@ -419,9 +414,8 @@ static int _alloc_image_components(struct logical_volume *lv,
 	struct logical_volume *tmp_lv;
 	struct lv_list *lvl_array;
 
-	lvl_array = dm_pool_alloc(lv->vg->vgmem,
-				  sizeof(*lvl_array) * count * 2);
-	if (!lvl_array)
+	if (!(lvl_array = dm_pool_alloc(lv->vg->vgmem,
+					sizeof(*lvl_array) * count * 2)))
 		return_0;
 
 	if (!(parallel_areas = build_parallel_areas_from_lv(lv, 0, 1)))
@@ -454,7 +448,7 @@ static int _alloc_image_components(struct logical_volume *lv,
 				    lv->alloc, 0, parallel_areas)))
 		return_0;
 
-	for (s = 0; s < count; s++) {
+	for (s = 0; s < count; ++s) {
 		/*
 		 * The allocation areas are grouped together.  First
 		 * come the rimage allocated areas, then come the metadata
@@ -473,7 +467,9 @@ static int _alloc_image_components(struct logical_volume *lv,
 		lvl_array[s].lv = tmp_lv;
 		dm_list_add(new_data_lvs, &(lvl_array[s].list));
 	}
+
 	alloc_destroy(ah);
+
 	return 1;
 }
 
@@ -523,6 +519,7 @@ static int _alloc_rmeta_for_lv(struct logical_volume *data_lv,
 		return_0;
 
 	alloc_destroy(ah);
+
 	return 1;
 }
 
@@ -736,13 +733,14 @@ to be left for these sub-lvs.
 
 fail:
 	/* Cleanly remove newly-allocated LVs that failed insertion attempt */
-
 	dm_list_iterate_items(lvl, &meta_lvs)
 		if (!lv_remove(lvl->lv))
 			return_0;
+
 	dm_list_iterate_items(lvl, &data_lvs)
 		if (!lv_remove(lvl->lv))
 			return_0;
+
 	return 0;
 }
 
@@ -841,9 +839,8 @@ static int _raid_extract_images(struct logical_volume *lv, uint32_t new_count,
 		return 0;
 	}
 
-	lvl_array = dm_pool_alloc(lv->vg->vgmem,
-				  sizeof(*lvl_array) * extract * 2);
-	if (!lvl_array)
+	if (!(lvl_array = dm_pool_alloc(lv->vg->vgmem,
+					sizeof(*lvl_array) * extract * 2)))
 		return_0;
 
 	if (!(error_segtype = get_segtype_from_string(lv->vg->cmd, "error")))
@@ -1096,14 +1093,14 @@ int lv_raid_split(struct logical_volume *lv, const char *split_name,
 				  "while tracking changes for %s",
 				  lv->name, tracking->name);
 			return 0;
-		} else {
-			/* Ensure we only split the tracking image */
-			dm_list_init(&tracking_pvs);
-			splittable_pvs = &tracking_pvs;
-			if (!get_pv_list_for_lv(tracking->vg->cmd->mem,
-						tracking, splittable_pvs))
-				return_0;
 		}
+
+		/* Ensure we only split the tracking image */
+		dm_list_init(&tracking_pvs);
+		splittable_pvs = &tracking_pvs;
+		if (!get_pv_list_for_lv(tracking->vg->cmd->mem,
+					tracking, splittable_pvs))
+			return_0;
 	}
 
 	if (!_raid_extract_images(lv, new_count, splittable_pvs, 1,
@@ -1152,6 +1149,7 @@ int lv_raid_split(struct logical_volume *lv, const char *split_name,
 	 */
 	if (!activate_lv_excl_local(cmd, lvl->lv))
 		return_0;
+
 	dm_list_iterate_items(lvl, &removal_list)
 		if (!activate_lv_excl_local(cmd, lvl->lv))
 			return_0;
@@ -1217,7 +1215,7 @@ int lv_raid_split_and_track(struct logical_volume *lv,
 		return 0;
 	}
 
-	for (s = seg->area_count - 1; s >= 0; s--) {
+	for (s = seg->area_count - 1; s >= 0; --s) {
 		if (!lv_is_on_pvs(seg_lv(seg, s), splittable_pvs))
 			continue;
 		lv_set_visible(seg_lv(seg, s));
@@ -1277,13 +1275,13 @@ int lv_raid_merge(struct logical_volume *image_lv)
 			  vg->name, image_lv->name);
 		return 0;
 	}
+
 	lv = lvl->lv;
 	seg = first_seg(lv);
-	for (s = 0; s < seg->area_count; s++) {
-		if (seg_lv(seg, s) == image_lv) {
+	for (s = 0; s < seg->area_count; ++s)
+		if (seg_lv(seg, s) == image_lv)
 			meta_lv = seg_metalv(seg, s);
-		}
-	}
+
 	if (!meta_lv)
 		return_0;
 
@@ -1327,10 +1325,9 @@ static int _convert_mirror_to_raid1(struct logical_volume *lv,
 		return 0;
 	}
 
-	meta_areas = dm_pool_zalloc(lv->vg->vgmem,
-				    lv_mirror_count(lv) * sizeof(*meta_areas));
-	if (!meta_areas) {
-		log_error("Failed to allocate memory");
+	if (!(meta_areas = dm_pool_zalloc(lv->vg->vgmem,
+					  lv_mirror_count(lv) * sizeof(*meta_areas)))) {
+		log_error("Failed to allocate meta areas memory.");
 		return 0;
 	}
 
@@ -1821,29 +1818,29 @@ static int _partial_raid_lv_is_redundant(struct logical_volume *lv)
 	uint32_t failed_components = 0;
 
 	if (!strcmp(raid_seg->segtype->name, "raid10")) {
-                /* FIXME: We only support 2-way mirrors in RAID10 currently */
+		/* FIXME: We only support 2-way mirrors in RAID10 currently */
 		copies = 2;
-                for (i = 0; i < raid_seg->area_count * copies; i++) {
-                        s = i % raid_seg->area_count;
+		for (i = 0; i < raid_seg->area_count * copies; i++) {
+			s = i % raid_seg->area_count;
 
-                        if (!(i % copies))
-                                rebuilds_per_group = 0;
+			if (!(i % copies))
+				rebuilds_per_group = 0;
 
-                        if ((seg_lv(raid_seg, s)->status & PARTIAL_LV) ||
-                            (seg_metalv(raid_seg, s)->status & PARTIAL_LV) ||
-                            lv_is_virtual(seg_lv(raid_seg, s)) ||
-                            lv_is_virtual(seg_metalv(raid_seg, s)))
-                                rebuilds_per_group++;
+			if ((seg_lv(raid_seg, s)->status & PARTIAL_LV) ||
+			    (seg_metalv(raid_seg, s)->status & PARTIAL_LV) ||
+			    lv_is_virtual(seg_lv(raid_seg, s)) ||
+			    lv_is_virtual(seg_metalv(raid_seg, s)))
+				rebuilds_per_group++;
 
-                        if (rebuilds_per_group >= copies) {
-				log_verbose("An entire mirror group has failed in %s",
+			if (rebuilds_per_group >= copies) {
+				log_verbose("An entire mirror group has failed in %s.",
 					    display_lvname(lv));
-                		return 0;	/* Insufficient redundancy to activate */
+				return 0;	/* Insufficient redundancy to activate */
 			}
-                }
+		}
 
 		return 1; /* Redundant */
-        }
+	}
 
 	for (s = 0; s < raid_seg->area_count; s++) {
 		if ((seg_lv(raid_seg, s)->status & PARTIAL_LV) ||
@@ -1853,18 +1850,18 @@ static int _partial_raid_lv_is_redundant(struct logical_volume *lv)
 			failed_components++;
 	}
 
-        if (failed_components == raid_seg->area_count) {
-		log_verbose("All components of raid LV %s have failed",
+	if (failed_components == raid_seg->area_count) {
+		log_verbose("All components of raid LV %s have failed.",
 			    display_lvname(lv));
-                return 0;	/* Insufficient redundancy to activate */
-        } else if (raid_seg->segtype->parity_devs &&
-                   (failed_components > raid_seg->segtype->parity_devs)) {
-                log_verbose("More than %u components from %s %s have failed",
+		return 0;	/* Insufficient redundancy to activate */
+	} else if (raid_seg->segtype->parity_devs &&
+		   (failed_components > raid_seg->segtype->parity_devs)) {
+		log_verbose("More than %u components from %s %s have failed.",
 			    raid_seg->segtype->parity_devs,
-                          raid_seg->segtype->ops->name(raid_seg),
-                          display_lvname(lv));
-                return 0;	/* Insufficient redundancy to activate */
-        }
+			    raid_seg->segtype->ops->name(raid_seg),
+			    display_lvname(lv));
+		return 0;	/* Insufficient redundancy to activate */
+	}
 
 	return 1;
 }


