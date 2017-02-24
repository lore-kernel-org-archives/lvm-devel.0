From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Fri, 24 Feb 2017 06:32:15 +0000 (UTC)
Subject: master - lvconvert: add infrastructure for RaidLV reshaping support
Message-ID: <20170224063215.8735760AA7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fe18e5e77a488618510648c7801ea3375ce5aac4
Commit:        fe18e5e77a488618510648c7801ea3375ce5aac4
Parent:        929cf4b73ca6112e59e5e85cf3a2f3992747883b
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Feb 24 02:53:18 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Feb 24 05:20:58 2017 +0100

lvconvert: add infrastructure for RaidLV reshaping support

In order to support striped raid5/6/10 LV reshaping (change
of LV type, stripesize or number of legs), this patch
introduces more local infrastructure to raid_manip.c
used by followup patches.

Changes:
- add _raid_reshape() using the pre/post callbacks and
  the stripes add/remove reshape functions introduced before
- and _reshape_requested function checking if a reshape
  was requested

Related: rhbz834579
Related: rhbz1191935
Related: rhbz1191978
---
 lib/metadata/raid_manip.c |  362 ++++++++++++++++++++++++++++++++++++++++++---
 1 files changed, 339 insertions(+), 23 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 63588ad..cc074f6 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -57,7 +57,6 @@ static int _check_num_areas_in_lv_segments(struct logical_volume *lv, unsigned n
 /*
  * Check if reshape is supported in the kernel.
  */
-__attribute__ ((__unused__))
 static int _reshape_is_supported(struct cmd_context *cmd, const struct segment_type *segtype)
 {
 	unsigned attrs;
@@ -255,7 +254,6 @@ static int _deactivate_and_remove_lvs(struct volume_group *vg, struct dm_list *r
  *
  * report health string in @*raid_health for @lv from kernel reporting # of devs in @*kernel_devs
  */
-__attribute__ ((__unused__))
 static int _get_dev_health(struct logical_volume *lv, uint32_t *kernel_devs,
 			   uint32_t *devs_health, uint32_t *devs_in_sync,
 			   char **raid_health)
@@ -934,6 +932,7 @@ static char *_generate_raid_name(struct logical_volume *lv,
 
 	return lvname;
 }
+
 /*
  * Create an LV of specified type.  Set visible after creation.
  * This function does not make metadata changes.
@@ -1016,7 +1015,7 @@ static int _alloc_image_components(struct logical_volume *lv,
 		region_size = seg->region_size;
 
 	if (seg_is_raid(seg))
-		segtype = seg->segtype;
+		segtype = get_segtype_from_string(lv->vg->cmd, SEG_TYPE_NAME_RAID0_META);
 	else if (!(segtype = get_segtype_from_string(lv->vg->cmd, SEG_TYPE_NAME_RAID1)))
 		return_0;
 
@@ -1032,17 +1031,13 @@ static int _alloc_image_components(struct logical_volume *lv,
 		/* FIXME Workaround for segment type changes where new segtype is unknown here */
 		/* Only for raid0* to raid4 */
 		extents = (lv->le_count / seg->area_count) * count;
-	else if (segtype_is_raid10(segtype)) {
-		if (seg->area_count < 2) {
-			log_error(INTERNAL_ERROR "LV %s needs@least 2 areas.",
-				  display_lvname(lv));
-			return 0;
-		}
-		extents = lv->le_count / (seg->area_count / 2); /* we enforce 2 mirrors right now */
-	} else
-		extents = (segtype->parity_devs) ?
-			   (lv->le_count / (seg->area_count - segtype->parity_devs)) :
-			   lv->le_count;
+
+	else {
+		if (seg_type(seg, 0) == AREA_LV)
+			extents = seg_lv(seg, 0)->le_count * count;
+		else
+			extents = lv->le_count / (seg->area_count - segtype->parity_devs);
+	}
 
 	/* Do we need to allocate any extents? */
 	if (pvs && !dm_list_empty(pvs) &&
@@ -1214,7 +1209,6 @@ static int _cmp_level(const struct segment_type *t1, const struct segment_type *
  *
  * Return 1 if same, else != 1
  */
-__attribute__ ((__unused__))
 static int is_same_level(const struct segment_type *t1, const struct segment_type *t2)
 {
 	return _cmp_level(t1, t2);
@@ -1602,7 +1596,6 @@ static int _lv_free_reshape_space(struct logical_volume *lv)
  * 	3: kernel dev count > @dev_count
  *
  */
-__attribute__ ((__unused__))
 static int _reshaped_state(struct logical_volume *lv, const unsigned dev_count,
 			   unsigned *devs_health, unsigned *devs_in_sync)
 {
@@ -1656,7 +1649,6 @@ static int _lv_reshape_get_new_len(struct logical_volume *lv,
 /*
  * Extend/reduce size of @lv and it's first segment during reshape to @extents
  */
-__attribute__ ((__unused__))
 static int _reshape_adjust_to_size(struct logical_volume *lv,
 				   uint32_t old_image_count, uint32_t new_image_count)
 {
@@ -1693,7 +1685,6 @@ static int _reshape_adjust_to_size(struct logical_volume *lv,
 static int _lv_raid_change_image_count(struct logical_volume *lv, uint32_t new_count,
 				       struct dm_list *allocate_pvs, struct dm_list *removal_lvs,
 				       int commit, int use_existing_area_len);
-__attribute__ ((__unused__))
 static int _raid_reshape_add_images(struct logical_volume *lv,
 				    const struct segment_type *new_segtype, int yes,
 				    uint32_t old_image_count, uint32_t new_image_count,
@@ -1789,7 +1780,6 @@ static int _raid_reshape_add_images(struct logical_volume *lv,
  * Reshape: remove images from existing raid lv
  *
  */
-__attribute__ ((__unused__))
 static int _raid_reshape_remove_images(struct logical_volume *lv,
 				       const struct segment_type *new_segtype,
 				       int yes, int force,
@@ -1947,7 +1937,6 @@ static int _raid_reshape_remove_images(struct logical_volume *lv,
  * Reshape: keep images in RAID @lv but change stripe size or data copies
  *
  */
-__attribute__ ((__unused__))
 static int _raid_reshape_keep_images(struct logical_volume *lv,
 				     const struct segment_type *new_segtype,
 				     int yes, int force, int *force_repair,
@@ -2018,7 +2007,6 @@ static int _vg_write_lv_suspend_commit_backup(struct volume_group *vg,
 	return r;
 }
 
-__attribute__ ((__unused__))
 static int _vg_write_commit_backup(struct volume_group *vg)
 {
 	return _vg_write_lv_suspend_commit_backup(vg, NULL, 1, 1);
@@ -2084,7 +2072,6 @@ static int _activate_sub_lvs_excl_local_list(struct logical_volume *lv, struct d
 }
 
 /* Helper: callback function to activate any new image component pairs @lv */
-__attribute__ ((__unused__))
 static int _pre_raid_add_legs(struct logical_volume *lv, void *data)
 {
 	if (!_vg_write_lv_suspend_vg_commit(lv, 1))
@@ -2111,13 +2098,342 @@ static int _pre_raid0_remove_rmeta(struct logical_volume *lv, void *data)
 }
 
 /* Helper: callback dummy needed for */
-__attribute__ ((__unused__))
 static int _post_raid_dummy(struct logical_volume *lv, void *data)
 {
 	return 1;
 }
 
 /*
+ * Reshape logical volume @lv by adding/removing stripes
+ * (absolute new stripes given in @new_stripes), changing
+ * layout (e.g. raid5_ls -> raid5_ra) or changing
+ * stripe size to @new_stripe_size.
+ *
+ * In case of disk addition, any PVs listed in mandatory
+ * @allocate_pvs will be used for allocation of new stripes.
+ */
+__attribute__ ((__unused__))
+static int _raid_reshape(struct logical_volume *lv,
+			 const struct segment_type *new_segtype,
+			 int yes, int force,
+			 const unsigned new_data_copies,
+			 const unsigned new_region_size,
+			 const unsigned new_stripes,
+			 const unsigned new_stripe_size,
+			 struct dm_list *allocate_pvs)
+{
+	int force_repair = 0, r, too_few = 0;
+	unsigned devs_health, devs_in_sync;
+	uint32_t new_image_count, old_image_count;
+	enum alloc_where where_it_was;
+	struct lv_segment *seg = first_seg(lv);
+	struct dm_list removal_lvs;
+
+	if (!seg_is_reshapable_raid(seg))
+		return_0;
+
+	if (!is_same_level(seg->segtype, new_segtype))
+		return_0;
+
+	if (!(old_image_count = seg->area_count))
+		return_0;
+
+	if ((new_image_count = new_stripes + seg->segtype->parity_devs) < 2)
+		return_0;
+
+	if (!_check_max_raid_devices(new_image_count))
+		return_0;
+
+	if (!_raid_in_sync(lv)) {
+		log_error("Unable to convert %s while it is not in-sync.",
+			  display_lvname(lv));
+		return 0;
+	}
+
+	dm_list_init(&removal_lvs);
+
+	/* No change in layout requested ? */
+	if (seg->segtype == new_segtype &&
+	    seg->data_copies == new_data_copies &&
+	    seg->region_size == new_region_size &&
+	    old_image_count == new_image_count &&
+	    seg->stripe_size == new_stripe_size) {
+		/*
+		 * No change in segment type, image count, region or stripe size has been requested ->
+		 * user requests this to remove any reshape space from the @lv
+		 */
+		if (!_lv_free_reshape_space_with_status(lv, &where_it_was)) {
+			log_error(INTERNAL_ERROR "Failed to free reshape space of %s.",
+				  display_lvname(lv));
+			return 0;
+		}
+
+		log_print_unless_silent("No change in RAID LV %s layout, freeing reshape space.", display_lvname(lv));
+
+		if (where_it_was == alloc_none) {
+			log_print_unless_silent("LV %s does not have reshape space allocated.",
+						display_lvname(lv));
+			return 1;
+		}
+
+		if (!_lv_update_reload_fns_reset_eliminate_lvs(lv, 0, NULL, NULL))
+			return_0;
+
+		return 1;
+	}
+
+	/* raid4/5 with N image component pairs (i.e. N-1 stripes): allow for raid4/5 reshape to 2 devices, i.e. raid1 layout */
+	if (seg_is_raid4(seg) || seg_is_any_raid5(seg)) {
+		if (new_stripes < 1)
+			too_few = 1;
+
+	/* raid6 (raid10 can't shrink reshape) device count: check for 2 stripes minimum */
+	} else if (new_stripes < 2)
+		too_few = 1;
+
+	if (too_few) {
+		log_error("Too few stripes requested.");
+		return 0;
+	}
+
+	switch ((r = _reshaped_state(lv, old_image_count, &devs_health, &devs_in_sync))) {
+	case 1:
+		/*
+		 * old_image_count == kernel_dev_count
+		 *
+		 * Check for device health
+		 */
+		if (devs_in_sync < devs_health) {
+			log_error("Can't reshape out of sync LV %s.", display_lvname(lv));
+			return 0;
+		}
+
+		/* device count and health are good -> ready to go */
+		break;
+
+	case 2:
+		if (devs_in_sync == new_image_count)
+			break;
+
+		/* Possible after a shrinking reshape and forgotten device removal */
+		log_error("Device count is incorrect. "
+			  "Forgotten \"lvconvert --stripes %d %s\" to remove %u images after reshape?",
+			  devs_in_sync - seg->segtype->parity_devs, display_lvname(lv),
+			  old_image_count - devs_in_sync);
+		return 0;
+
+	default:
+		log_error(INTERNAL_ERROR "Bad return=%d provided to %s.", r, __func__);
+		return 0;
+	}
+
+	if (seg->stripe_size != new_stripe_size)
+		log_print_unless_silent("Converting stripesize %s of %s LV %s to %s.",
+					display_size(lv->vg->cmd, seg->stripe_size),
+					lvseg_name(seg), display_lvname(lv),
+					display_size(lv->vg->cmd, new_stripe_size));
+
+	/* Handle disk addition reshaping */
+	if (old_image_count < new_image_count) {
+		if (!_raid_reshape_add_images(lv, new_segtype, yes,
+					      old_image_count, new_image_count,
+					      new_stripes, new_stripe_size, allocate_pvs))
+			return 0;
+
+	/* Handle disk removal reshaping */
+	} else if (old_image_count > new_image_count) {
+		if (!_raid_reshape_remove_images(lv, new_segtype, yes, force,
+						 old_image_count, new_image_count,
+						 new_stripes, new_stripe_size,
+						 allocate_pvs, &removal_lvs))
+			return 0;
+
+	/*
+	 * Handle raid set layout reshaping w/o changing # of legs (allocation algorithm or stripe size change)
+	 * (e.g. raid5_ls -> raid5_n or stripe size change)
+	 */
+	} else if (!_raid_reshape_keep_images(lv, new_segtype, yes, force, &force_repair,
+					      new_data_copies, new_stripe_size, allocate_pvs))
+		return 0;
+
+	/* HM FIXME: workaround for not resetting "nosync" flag */
+	init_mirror_in_sync(0);
+
+	seg->region_size = new_region_size;
+
+	if (seg->area_count != 2 || old_image_count != seg->area_count) {
+		if (!_lv_update_reload_fns_reset_eliminate_lvs(lv, 0, &removal_lvs,
+							       _post_raid_dummy, NULL,
+							       _pre_raid_add_legs, NULL))
+			return 0;
+	} if (!_vg_write_commit_backup(lv->vg))
+		return 0;
+
+	return 1; // force_repair ? _lv_cond_repair(lv) : 1;
+}
+
+/*
+ * Check for reshape request defined by:
+ *
+ * - raid type is reshape capable
+ * - no raid level change
+ * - # of stripes requested to change
+ *   (i.e. add/remove disks from a striped raid set)
+ *   -or-
+ * - stripe size change requestd
+ *   (e.g. 32K -> 128K)
+ *
+ * Returns:
+ *
+ * 0 -> no reshape request
+ * 1 -> allowed reshape request
+ * 2 -> prohibited reshape request
+ * 3 -> allowed region size change request
+ */
+__attribute__ ((__unused__))
+static int _reshape_requested(const struct logical_volume *lv, const struct segment_type *segtype,
+			      const int data_copies, const uint32_t region_size,
+			      const uint32_t stripes, const uint32_t stripe_size)
+{
+	struct lv_segment *seg = first_seg(lv);
+
+	/* This segment type is not reshapable */
+	if (!seg_is_reshapable_raid(seg))
+		return 0;
+
+	if (!_reshape_is_supported(lv->vg->cmd, seg->segtype))
+		return 0;
+
+	/* Switching raid levels is a takeover, no reshape */
+	if (!is_same_level(seg->segtype, segtype))
+		return 0;
+
+	/* Possible takeover in case #data_copies == #stripes */
+	if (seg_is_raid10_near(seg) && segtype_is_raid1(segtype))
+		return 0;
+
+	/* No layout change -> allow for removal of reshape space */
+	if (seg->segtype == segtype &&
+	    data_copies == seg->data_copies &&
+	    region_size == seg->region_size &&
+	    stripes == _data_rimages_count(seg, seg->area_count) &&
+	    stripe_size == seg->stripe_size)
+		return 1;
+
+	/* Ensure region size is >= stripe size */
+	if (!seg_is_striped(seg) &&
+	    !seg_is_any_raid0(seg) &&
+	    (region_size || stripe_size) &&
+	    ((region_size ?: seg->region_size) < (stripe_size ?: seg->stripe_size))) {
+		log_error("region size may not be smaller than stripe size on LV %s.",
+			  display_lvname(lv));
+		return 2;
+	}
+#if 0
+	if ((_lv_is_duplicating(lv) || lv_is_duplicated(lv)) &&
+	    ((seg_is_raid1(seg) ? 0 : (stripes != _data_rimages_count(seg, seg->area_count))) ||
+	     data_copies != seg->data_copies))
+		goto err;
+	if ((!seg_is_striped(seg) && segtype_is_raid10_far(segtype)) ||
+	    (seg_is_raid10_far(seg) && !segtype_is_striped(segtype))) {
+		if (data_copies == seg->data_copies &&
+		    region_size == seg->region_size) {
+			log_error("Can't convert %sraid10_far.",
+				  seg_is_raid10_far(seg) ? "" : "to ");
+			goto err;
+		}
+	}
+
+	if (seg_is_raid10_far(seg)) {
+		if (stripes != _data_rimages_count(seg, seg->area_count)) {
+			log_error("Can't change stripes in raid10_far.");
+			goto err;
+		}
+
+		if (stripe_size != seg->stripe_size) {
+			log_error("Can't change stripe size in raid10_far.");
+			goto err;
+		}
+	}
+#endif
+
+	if (seg_is_any_raid10(seg) && seg->area_count > 2 &&
+	    stripes && stripes < seg->area_count - seg->segtype->parity_devs) {
+		log_error("Can't remove stripes from raid10");
+		goto err;
+	}
+
+	if (data_copies != seg->data_copies) {
+		if (seg_is_raid10_near(seg))
+			return 0;
+#if 0
+		if (seg_is_raid10_far(seg))
+			return segtype_is_raid10_far(segtype) ? 1 : 0;
+
+		if (seg_is_raid10_offset(seg)) {
+			log_error("Can't change number of data copies on %s LV %s.",
+				  lvseg_name(seg), display_lvname(lv));
+			goto err;
+		}
+#endif
+	}
+
+#if 0
+	/* raid10_{near,offset} case */
+	if ((seg_is_raid10_near(seg) && segtype_is_raid10_offset(segtype)) ||
+	    (seg_is_raid10_offset(seg) && segtype_is_raid10_near(segtype))) {
+		if (stripes >= seg->area_count)
+			return 1;
+
+		goto err;
+	}
+
+	/*
+	 * raid10_far is not reshapable in MD at all;
+	 * lvm/dm adds reshape capability to add/remove data_copies
+	 */
+	if (seg_is_raid10_far(seg) && segtype_is_raid10_far(segtype)) {
+		if (stripes && stripes == seg->area_count &&
+		    data_copies > 1 &&
+		    data_copies <= seg->area_count &&
+		    data_copies != seg->data_copies)
+			return 1;
+
+		goto err;
+
+	} else if (seg_is_any_raid10(seg) && segtype_is_any_raid10(segtype) &&
+		   data_copies > 1 && data_copies != seg->data_copies)
+		goto err;
+#endif
+
+	/* Change layout (e.g. raid5_ls -> raid5_ra) keeping # of stripes */
+	if (seg->segtype != segtype) {
+		if (stripes && stripes != _data_rimages_count(seg, seg->area_count))
+			goto err;
+
+		return 1;
+	}
+
+	if (stripes && stripes == _data_rimages_count(seg, seg->area_count) &&
+	    stripe_size == seg->stripe_size) {
+		log_error("LV %s already has %u stripes.",
+			  display_lvname(lv), stripes);
+		return 2;
+	}
+
+	return (stripes || stripe_size) ? 1 : 0;
+
+err:
+#if 0
+	if (lv_is_duplicated(lv))
+		log_error("Conversion of duplicating sub LV %s rejected.", display_lvname(lv));
+	else
+		log_error("Use \"lvconvert --duplicate --type %s ... %s.", segtype->name, display_lvname(lv));
+#endif
+	return 2;
+}
+
+/*
  * _alloc_rmeta_for_lv
  * @lv
  *


