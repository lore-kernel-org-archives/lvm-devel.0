From: agk@sourceware.org <agk@sourceware.org>
Date: 19 Aug 2011 15:59:16 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/raid_manip.c lib ...
Message-ID: <20110819155916.30336.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-08-19 15:59:15

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : raid_manip.c 
	lib/raid       : raid.c 

Log message:
	_ for static fns

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2079&r2=1.2080
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/raid_manip.c.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/raid/raid.c.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/WHATS_NEW	2011/08/18 19:43:08	1.2079
+++ LVM2/WHATS_NEW	2011/08/19 15:59:15	1.2080
@@ -1,10 +1,10 @@
 Version 2.02.88 - 
 ==================================
-  Add --merge support for RAID1 images that were split with --trackchanges
-  Add support for m-way to n-way up-convert in RAID1 (no linear to n-way yet)
-  Add --trackchanges support to --splitmirrors option for RAID1
-  Add --splitmirrors support for RAID1 (1 image only)
-  When down-converting RAID1, don't activate sub-lvs between suspend/resume
+  Add lvconvert --merge support for raid1 devices split with --trackchanges.
+  Support lvconvert of -m1 raid1 devices to a higher number.
+  Add --trackchanges support to lvconvert --splitmirrors option for raid1.
+  Support splitting off a single raid1 rimage in lvconvert --splitmirrors.
+  Use sync_local_dev_names when reducing number of raid rimages in lvconvert.
   Add -V as short form of --virtualsize in lvcreate.
   Fix make clean not to remove Makefile.  (2.02.87)
 
--- LVM2/lib/metadata/raid_manip.c	2011/08/18 19:43:08	1.9
+++ LVM2/lib/metadata/raid_manip.c	2011/08/19 15:59:15	1.10
@@ -51,7 +51,7 @@
 }
 
 /*
- * lv_is_on_pv
+ * _lv_is_on_pv
  * @lv:
  * @pv:
  *
@@ -65,7 +65,7 @@
  * and be put in lv_manip.c.  'for_each_sub_lv' does not yet allow us to
  * short-circuit execution or pass back the values we need yet though...
  */
-static int lv_is_on_pv(struct logical_volume *lv, struct physical_volume *pv)
+static int _lv_is_on_pv(struct logical_volume *lv, struct physical_volume *pv)
 {
 	uint32_t s;
 	struct physical_volume *pv2;
@@ -79,7 +79,7 @@
 		return 0;
 
 	/* Check mirror log */
-	if (lv_is_on_pv(seg->log_lv, pv))
+	if (_lv_is_on_pv(seg->log_lv, pv))
 		return 1;
 
 	/* Check stack of LVs */
@@ -95,14 +95,14 @@
 			}
 
 			if ((seg_type(seg, s) == AREA_LV) &&
-			    lv_is_on_pv(seg_lv(seg, s), pv))
+			    _lv_is_on_pv(seg_lv(seg, s), pv))
 				return 1;
 
 			if (!seg_is_raid(seg))
 				continue;
 
 			/* This is RAID, so we know the meta_area is AREA_LV */
-			if (lv_is_on_pv(seg_metalv(seg, s), pv))
+			if (_lv_is_on_pv(seg_metalv(seg, s), pv))
 				return 1;
 		}
 	}
@@ -110,12 +110,12 @@
 	return 0;
 }
 
-static int lv_is_on_pvs(struct logical_volume *lv, struct dm_list *pvs)
+static int _lv_is_on_pvs(struct logical_volume *lv, struct dm_list *pvs)
 {
 	struct pv_list *pvl;
 
 	dm_list_iterate_items(pvl, pvs)
-		if (lv_is_on_pv(lv, pvl->pv)) {
+		if (_lv_is_on_pv(lv, pvl->pv)) {
 			log_debug("%s is on %s", lv->name,
 				  pv_dev_name(pvl->pv));
 			return 1;
@@ -125,7 +125,7 @@
 	return 0;
 }
 
-static int raid_in_sync(struct logical_volume *lv)
+static int _raid_in_sync(struct logical_volume *lv)
 {
 	percent_t sync_percent;
 
@@ -139,7 +139,7 @@
 }
 
 /*
- * raid_remove_top_layer
+ * _raid_remove_top_layer
  * @lv
  * @removal_list
  *
@@ -149,8 +149,8 @@
  *
  * Returns: 1 on succes, 0 on failure
  */
-static int raid_remove_top_layer(struct logical_volume *lv,
-				 struct dm_list *removal_list)
+static int _raid_remove_top_layer(struct logical_volume *lv,
+				  struct dm_list *removal_list)
 {
 	struct lv_list *lvl_array, *lvl;
 	struct lv_segment *seg = first_seg(lv);
@@ -196,7 +196,7 @@
 }
 
 /*
- * clear_lv
+ * _clear_lv
  * @lv
  *
  * If LV is active:
@@ -206,7 +206,7 @@
  *
  * Returns: 1 on success, 0 on failure
  */
-static int clear_lv(struct logical_volume *lv)
+static int _clear_lv(struct logical_volume *lv)
 {
 	int was_active = lv_is_active(lv);
 
@@ -237,7 +237,7 @@
 }
 
 /* Makes on-disk metadata changes */
-static int clear_lvs(struct dm_list *lv_list)
+static int _clear_lvs(struct dm_list *lv_list)
 {
 	struct lv_list *lvl;
 	struct volume_group *vg = NULL;
@@ -264,7 +264,7 @@
 		return_0;
 
 	dm_list_iterate_items(lvl, lv_list)
-		if (!clear_lv(lvl->lv))
+		if (!_clear_lv(lvl->lv))
 			return 0;
 
 	return 1;
@@ -452,8 +452,8 @@
 	return 1;
 }
 
-static int raid_add_images(struct logical_volume *lv,
-			   uint32_t new_count, struct dm_list *pvs)
+static int _raid_add_images(struct logical_volume *lv,
+			    uint32_t new_count, struct dm_list *pvs)
 {
 	uint32_t s;
 	uint32_t old_count = lv_raid_image_count(lv);
@@ -479,7 +479,7 @@
 	}
 
 	/* Metadata LVs must be cleared before being added to the array */
-	if (!clear_lvs(&meta_lvs))
+	if (!_clear_lvs(&meta_lvs))
 		goto fail;
 
 /*
@@ -650,7 +650,7 @@
 }
 
 /*
- * raid_extract_images
+ * _raid_extract_images
  * @lv
  * @new_count:  The absolute count of images (e.g. '2' for a 2-way mirror)
  * @target_pvs:  The list of PVs that are candidates for removal
@@ -666,10 +666,10 @@
  *
  * Returns: 1 on success, 0 on failure
  */
-static int raid_extract_images(struct logical_volume *lv, uint32_t new_count,
-			       struct dm_list *target_pvs, int shift,
-			       struct dm_list *extracted_meta_lvs,
-			       struct dm_list *extracted_data_lvs)
+static int _raid_extract_images(struct logical_volume *lv, uint32_t new_count,
+			        struct dm_list *target_pvs, int shift,
+			        struct dm_list *extracted_meta_lvs,
+			        struct dm_list *extracted_data_lvs)
 {
 	int s, extract, lvl_idx = 0;
 	struct lv_list *lvl_array;
@@ -687,10 +687,10 @@
 		return_0;
 
 	for (s = seg->area_count - 1; (s >= 0) && extract; s--) {
-		if (!lv_is_on_pvs(seg_lv(seg, s), target_pvs) ||
-		    !lv_is_on_pvs(seg_metalv(seg, s), target_pvs))
+		if (!_lv_is_on_pvs(seg_lv(seg, s), target_pvs) ||
+		    !_lv_is_on_pvs(seg_metalv(seg, s), target_pvs))
 			continue;
-		if (!raid_in_sync(lv) &&
+		if (!_raid_in_sync(lv) &&
 		    (!seg_is_mirrored(seg) || (s == 0))) {
 			log_error("Unable to extract %sRAID image"
 				  " while RAID array is not in-sync",
@@ -724,15 +724,15 @@
 	return 1;
 }
 
-static int raid_remove_images(struct logical_volume *lv,
-			      uint32_t new_count, struct dm_list *pvs)
+static int _raid_remove_images(struct logical_volume *lv,
+			       uint32_t new_count, struct dm_list *pvs)
 {
 	struct dm_list removal_list;
 	struct lv_list *lvl;
 
 	dm_list_init(&removal_list);
 
-	if (!raid_extract_images(lv, new_count, pvs, 1,
+	if (!_raid_extract_images(lv, new_count, pvs, 1,
 				 &removal_list, &removal_list)) {
 		log_error("Failed to extract images from %s/%s",
 			  lv->vg->name, lv->name);
@@ -740,7 +740,7 @@
 	}
 
 	/* Convert to linear? */
-	if ((new_count == 1) && !raid_remove_top_layer(lv, &removal_list)) {
+	if ((new_count == 1) && !_raid_remove_top_layer(lv, &removal_list)) {
 		log_error("Failed to remove RAID layer after linear conversion");
 		return 0;
 	}
@@ -824,9 +824,9 @@
 	}
 
 	if (old_count > new_count)
-		return raid_remove_images(lv, new_count, pvs);
+		return _raid_remove_images(lv, new_count, pvs);
 
-	return raid_add_images(lv, new_count, pvs);
+	return _raid_add_images(lv, new_count, pvs);
 }
 
 int lv_raid_split(struct logical_volume *lv, const char *split_name,
@@ -859,13 +859,13 @@
 		return 0;
 	}
 
-	if (!raid_in_sync(lv)) {
+	if (!_raid_in_sync(lv)) {
 		log_error("Unable to split %s/%s while it is not in-sync.",
 			  lv->vg->name, lv->name);
 		return 0;
 	}
 
-	if (!raid_extract_images(lv, new_count, splittable_pvs, 1,
+	if (!_raid_extract_images(lv, new_count, splittable_pvs, 1,
 				 &removal_list, &data_list)) {
 		log_error("Failed to extract images from %s/%s",
 			  lv->vg->name, lv->name);
@@ -873,7 +873,7 @@
 	}
 
 	/* Convert to linear? */
-	if ((new_count == 1) && !raid_remove_top_layer(lv, &removal_list)) {
+	if ((new_count == 1) && !_raid_remove_top_layer(lv, &removal_list)) {
 		log_error("Failed to remove RAID layer after linear conversion");
 		return 0;
 	}
@@ -961,14 +961,14 @@
 		return 0;
 	}
 
-	if (!raid_in_sync(lv)) {
+	if (!_raid_in_sync(lv)) {
 		log_error("Unable to split image from %s/%s while not in-sync",
 			  lv->vg->name, lv->name);
 		return 0;
 	}
 
 	for (s = seg->area_count - 1; s >= 0; s--) {
-		if (!lv_is_on_pvs(seg_lv(seg, s), splittable_pvs))
+		if (!_lv_is_on_pvs(seg_lv(seg, s), splittable_pvs))
 			continue;
 		lv_set_visible(seg_lv(seg, s));
 		seg_lv(seg, s)->status &= ~LVM_WRITE;
--- LVM2/lib/raid/raid.c	2011/08/18 19:41:21	1.7
+++ LVM2/lib/raid/raid.c	2011/08/19 15:59:15	1.8
@@ -43,9 +43,9 @@
 	return 1;
 }
 
-static int
-_raid_text_import_areas(struct lv_segment *seg, const struct config_node *sn,
-			const struct config_node *cn)
+static int _raid_text_import_areas(struct lv_segment *seg,
+				   const struct config_node *sn,
+				   const struct config_node *cn)
 {
 	unsigned int s;
 	const struct config_value *cv;
@@ -100,9 +100,9 @@
 	return 1;
 }
 
-static int
-_raid_text_import(struct lv_segment *seg, const struct config_node *sn,
-		  struct dm_hash_table *pv_hash)
+static int _raid_text_import(struct lv_segment *seg,
+			     const struct config_node *sn,
+			     struct dm_hash_table *pv_hash)
 {
 	const struct config_node *cn;
 
@@ -139,8 +139,7 @@
 	return 1;
 }
 
-static int
-_raid_text_export(const struct lv_segment *seg, struct formatter *f)
+static int _raid_text_export(const struct lv_segment *seg, struct formatter *f)
 {
 	outf(f, "device_count = %u", seg->area_count);
 	if (seg->region_size)
@@ -151,15 +150,14 @@
 	return out_areas(f, seg, "raid");
 }
 
-static int
-_raid_add_target_line(struct dev_manager *dm __attribute__((unused)),
-		      struct dm_pool *mem __attribute__((unused)),
-		      struct cmd_context *cmd __attribute__((unused)),
-		      void **target_state __attribute__((unused)),
-		      struct lv_segment *seg,
-		      const struct lv_activate_opts *laopts __attribute__((unused)),
-		      struct dm_tree_node *node, uint64_t len,
-		      uint32_t *pvmove_mirror_count __attribute__((unused)))
+static int _raid_add_target_line(struct dev_manager *dm __attribute__((unused)),
+				 struct dm_pool *mem __attribute__((unused)),
+				 struct cmd_context *cmd __attribute__((unused)),
+				 void **target_state __attribute__((unused)),
+				 struct lv_segment *seg,
+				 const struct lv_activate_opts *laopts __attribute__((unused)),
+				 struct dm_tree_node *node, uint64_t len,
+				 uint32_t *pvmove_mirror_count __attribute__((unused)))
 {
 	uint32_t s;
 	uint64_t rebuilds = 0;
@@ -245,10 +243,9 @@
 }
 
 
-static int
-_raid_target_present(struct cmd_context *cmd,
-		     const struct lv_segment *seg __attribute__((unused)),
-		     unsigned *attributes __attribute__((unused)))
+static int _raid_target_present(struct cmd_context *cmd,
+				const struct lv_segment *seg __attribute__((unused)),
+				unsigned *attributes __attribute__((unused)))
 {
 	static int _raid_checked = 0;
 	static int _raid_present = 0;
@@ -261,10 +258,9 @@
 	return _raid_present;
 }
 
-static int
-_raid_modules_needed(struct dm_pool *mem,
-		     const struct lv_segment *seg __attribute__((unused)),
-		     struct dm_list *modules)
+static int _raid_modules_needed(struct dm_pool *mem,
+				const struct lv_segment *seg __attribute__((unused)),
+				struct dm_list *modules)
 {
 	if (!str_list_add(mem, modules, "raid")) {
 		log_error("raid module string list allocation failed");


