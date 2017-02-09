From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Thu,  9 Feb 2017 21:44:08 +0000 (UTC)
Subject: master - lvreduce/lvresize: add ability to reduce the size of a RaidLV
Message-ID: <20170209214408.7C7B06090A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=55eaabd1183042b8e03b3a969eadf624623c4b62
Commit:        55eaabd1183042b8e03b3a969eadf624623c4b62
Parent:        79f31008fa10cc4893b6f98ad3e0de188aa5e7b0
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Feb 9 22:41:28 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Feb 9 22:42:03 2017 +0100

lvreduce/lvresize: add ability to reduce the size of a RaidLV

- support shrinking of raid0/1/4/5/6/10 LVs
- enhance lvresize-raid.sh tests: add raid0* and raid10
- fix have_raid4 in aux.sh to allow lv_resize-raid.sh
  and other scripts to test raid4

Resolves: rhbz1394048
---
 WHATS_NEW                           |    1 +
 lib/metadata/lv_manip.c             |  148 +++++++++++++++++++++++++----------
 lib/metadata/metadata-exported.h    |    6 ++
 lib/metadata/raid_manip.c           |  109 +++++++++++++++++++-------
 test/lib/aux.sh                     |    6 +-
 test/shell/lvconvert-repair-raid.sh |    2 +-
 test/shell/lvresize-raid.sh         |    9 ++-
 7 files changed, 204 insertions(+), 77 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index c6994ca..7a32777 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.169 - 
 =====================================
+  Support shrinking of RaidLvs
   Support region size changes on existing RaidLVs
   Avoid parallel usage of cpg_mcast_joined() in clvmd with corosync.
   Support raid6_{ls,rs,la,ra}_6 segment types and conversions from/to it.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 3feec20..2e96740 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -891,8 +891,9 @@ static uint32_t _round_to_stripe_boundary(struct volume_group *vg, uint32_t exte
 	/* Round up extents to stripe divisible amount */
 	if ((size_rest = extents % stripes)) {
 		new_extents += extend ? stripes - size_rest : -size_rest;
-		log_print_unless_silent("Rounding size %s (%u extents) up to stripe boundary size %s (%u extents).",
+		log_print_unless_silent("Rounding size %s (%u extents) %s to stripe boundary size %s(%u extents).",
 					display_size(vg->cmd, (uint64_t) extents * vg->extent_size), extents,
+					new_extents < extents ? "down" : "up",
 					display_size(vg->cmd, (uint64_t) new_extents * vg->extent_size), new_extents);
 	}
 
@@ -967,6 +968,37 @@ struct lv_segment *alloc_lv_segment(const struct segment_type *segtype,
 	return seg;
 }
 
+/*
+ * Temporary helper to return number of data copies for
+ * RAID segment @seg until seg->data_copies got added
+ */
+static uint32_t _raid_data_copies(struct lv_segment *seg)
+{
+	/*
+	 * FIXME: needs to change once more than 2 are supported.
+	 *	  I.e. use seg->data_copies then
+	 */
+	if (seg_is_raid10(seg))
+		return 2;
+	else if (seg_is_raid1(seg))
+		return seg->area_count;
+
+	return seg->segtype->parity_devs + 1;
+}
+
+/* Data image count for RAID segment @seg */
+static uint32_t _raid_stripes_count(struct lv_segment *seg)
+{
+	/*
+	 * FIXME: raid10 needs to change once more than
+	 *	  2 data_copies and odd # of legs supported.
+	 */
+	if (seg_is_raid10(seg))
+		return seg->area_count / _raid_data_copies(seg);
+
+	return seg->area_count - seg->segtype->parity_devs;
+}
+
 static int _release_and_discard_lv_segment_area(struct lv_segment *seg, uint32_t s,
 						uint32_t area_reduction, int with_discard)
 {
@@ -1007,33 +1039,41 @@ static int _release_and_discard_lv_segment_area(struct lv_segment *seg, uint32_t
 	}
 
 	if (lv_is_raid_image(lv)) {
-		/*
-		 * FIXME: Use lv_reduce not lv_remove
-		 *  We use lv_remove for now, because I haven't figured out
-		 *  why lv_reduce won't remove the LV.
-		lv_reduce(lv, area_reduction);
-		*/
-		if (area_reduction != seg->area_len) {
-			log_error("Unable to reduce RAID LV - operation not implemented.");
+		/* Calculate the amount of extents to reduce per rmate/rimage LV */
+		uint32_t rimage_extents;
+
+		/* FIXME: avoid extra seg_is_*() conditonals */
+		area_reduction =_round_to_stripe_boundary(lv->vg, area_reduction,
+							  (seg_is_raid1(seg) || seg_is_any_raid0(seg)) ? 0 : _raid_stripes_count(seg), 0);
+		rimage_extents = raid_rimage_extents(seg->segtype, area_reduction, seg_is_any_raid0(seg) ? 0 : _raid_stripes_count(seg),
+						     seg_is_raid10(seg) ? 1 :_raid_data_copies(seg));
+		if (!rimage_extents)
 			return 0;
-		} else {
-			if (!lv_remove(lv)) {
-				log_error("Failed to remove RAID image %s.",
-					  display_lvname(lv));
-				return 0;
-			}
-		}
 
-		/* Remove metadata area if image has been removed */
-		if (seg->meta_areas && seg_metalv(seg, s) && (area_reduction == seg->area_len)) {
-			if (!lv_reduce(seg_metalv(seg, s),
-				       seg_metalv(seg, s)->le_count)) {
-				log_error("Failed to remove RAID meta-device %s.",
-					  display_lvname(seg_metalv(seg, s)));
+		if (seg->meta_areas) {
+			uint32_t meta_area_reduction;
+			struct logical_volume *mlv;
+			struct volume_group *vg = lv->vg;
+
+			if (seg_metatype(seg, s) != AREA_LV ||
+			    !(mlv = seg_metalv(seg, s)))
 				return 0;
-			}
+
+			meta_area_reduction = raid_rmeta_extents_delta(vg->cmd, lv->le_count, lv->le_count - rimage_extents,
+								       seg->region_size, vg->extent_size);
+			/* Limit for raid0_meta not having region size set */
+			if (meta_area_reduction > mlv->le_count ||
+			    !(lv->le_count - rimage_extents))
+				meta_area_reduction = mlv->le_count;
+
+			if (meta_area_reduction &&
+			    !lv_reduce(mlv, meta_area_reduction))
+				return_0; /* FIXME: any upper level reporting */
 		}
 
+		if (!lv_reduce(lv, rimage_extents))
+			return_0; /* FIXME: any upper level reporting */
+
 		return 1;
 	}
 
@@ -1439,6 +1479,13 @@ int lv_refresh_suspend_resume(const struct logical_volume *lv)
  */
 int lv_reduce(struct logical_volume *lv, uint32_t extents)
 {
+	struct lv_segment *seg = first_seg(lv);
+
+	/* Ensure stipe boundary extents on RAID LVs */
+	if (lv_is_raid(lv) && extents != lv->le_count)
+		extents =_round_to_stripe_boundary(lv->vg, extents,
+						   seg_is_raid1(seg) ? 0 : _raid_stripes_count(seg), 0);
+
 	return _lv_reduce(lv, extents, 1);
 }
 
@@ -3302,19 +3349,24 @@ static struct alloc_handle *_alloc_init(struct cmd_context *cmd,
 
 	if (segtype_is_raid(segtype)) {
 		if (metadata_area_count) {
+			uint32_t cur_rimage_extents, new_rimage_extents;
+
 			if (metadata_area_count != area_count)
 				log_error(INTERNAL_ERROR
 					  "Bad metadata_area_count");
-			ah->metadata_area_count = area_count;
-			ah->alloc_and_split_meta = 1;
-
-			ah->log_len = RAID_METADATA_AREA_LEN;
 
+			/* Calculate log_len (i.e. length of each rmeta device) for RAID */
+			cur_rimage_extents = raid_rimage_extents(segtype, existing_extents, stripes, mirrors);
+			new_rimage_extents = raid_rimage_extents(segtype, existing_extents + new_extents, stripes, mirrors),
+			ah->log_len = raid_rmeta_extents_delta(cmd, cur_rimage_extents, new_rimage_extents,
+							       region_size, extent_size);
+			ah->metadata_area_count = metadata_area_count;
+			ah->alloc_and_split_meta = !!ah->log_len;
 			/*
 			 * We need 'log_len' extents for each
 			 * RAID device's metadata_area
 			 */
-			total_extents += (ah->log_len * ah->area_multiple);
+			total_extents += ah->log_len * (segtype_is_raid1(segtype) ? 1 : ah->area_multiple);
 		} else {
 			ah->log_area_count = 0;
 			ah->log_len = 0;
@@ -4011,19 +4063,6 @@ static int _lv_extend_layered_lv(struct alloc_handle *ah,
 	if (!_setup_lv_size(lv, lv->le_count + extents))
 		return_0;
 
-	/*
-	 * The MD bitmap is limited to being able to track 2^21 regions.
-	 * The region_size must be adjusted to meet that criteria
-	 * unless raid0/raid0_meta, which doesn't have a bitmap.
-	 */
-	if (seg_is_raid(seg) && !seg_is_any_raid0(seg))
-		while (seg->region_size < (lv->size / (1 << 21))) {
-			seg->region_size *= 2;
-			log_very_verbose("Adjusting RAID region_size from %uS to %uS"
-					 " to support large LV size",
-					 seg->region_size/2, seg->region_size);
-		}
-
 	return 1;
 }
 
@@ -4071,6 +4110,22 @@ int lv_extend(struct logical_volume *lv,
 	}
 	/* FIXME log_count should be 1 for mirrors */
 
+	if (segtype_is_raid(segtype) && !segtype_is_any_raid0(segtype)) {
+		uint64_t lv_size = ((uint64_t) lv->le_count + extents) * lv->vg->extent_size;
+
+		/*
+		 * The MD bitmap is limited to being able to track 2^21 regions.
+		 * The region_size must be adjusted to meet that criteria
+		 * unless raid0/raid0_meta, which doesn't have a bitmap.
+		 */
+
+		region_size = raid_ensure_min_region_size(lv, lv_size, region_size);
+
+		if (first_seg(lv))
+			first_seg(lv)->region_size = region_size;
+
+	}
+
 	if (!(ah = allocate_extents(lv->vg, lv, segtype, stripes, mirrors,
 				    log_count, region_size, extents,
 				    allocatable_pvs, alloc, approx_alloc, NULL)))
@@ -4651,6 +4706,11 @@ static uint32_t lvseg_get_stripes(struct lv_segment *seg, uint32_t *stripesize)
 		return seg->area_count;
 	}
 
+	if (seg_is_raid(seg)) {
+		*stripesize = seg->stripe_size;
+		return _raid_stripes_count(seg);
+	}
+
 	*stripesize = 0;
 	return 0;
 }
@@ -5316,6 +5376,7 @@ int lv_resize(struct logical_volume *lv,
 	struct logical_volume *lock_lv = (struct logical_volume*) lv_lock_holder(lv);
 	struct logical_volume *aux_lv = NULL; /* Note: aux_lv never resizes fs */
 	struct lvresize_params aux_lp;
+	struct lv_segment *seg = first_seg(lv);
 	int activated = 0;
 	int ret = 0;
 	int status;
@@ -5357,6 +5418,11 @@ int lv_resize(struct logical_volume *lv,
 		}
 	}
 
+	/* Ensure stipe boundary extents! */
+	if (!lp->percent && lv_is_raid(lv))
+		lp->extents =_round_to_stripe_boundary(lv->vg, lp->extents,
+						       seg_is_raid1(seg) ? 0 : _raid_stripes_count(seg),
+						       lp->resize == LV_REDUCE ? 0 : 1);
 	if (aux_lv && !_lvresize_prepare(&aux_lv, &aux_lp, pvh))
 		return_0;
 
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 4e05885..05771d8 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1217,6 +1217,12 @@ int lv_raid_replace(struct logical_volume *lv, int force,
 		    struct dm_list *remove_pvs, struct dm_list *allocate_pvs);
 int lv_raid_remove_missing(struct logical_volume *lv);
 int partial_raid_lv_supports_degraded_activation(const struct logical_volume *lv);
+uint32_t raid_rmeta_extents_delta(struct cmd_context *cmd,
+				  uint32_t rimage_extents_cur, uint32_t rimage_extents_new,
+				  uint32_t region_size, uint32_t extent_size);
+uint32_t raid_rimage_extents(const struct segment_type *segtype,
+			     uint32_t extents, uint32_t stripes, uint32_t data_copies);
+uint32_t raid_ensure_min_region_size(const struct logical_volume *lv, uint64_t lv_size, uint32_t region_size);
 /* --  metadata/raid_manip.c */
 
 /* ++  metadata/cache_manip.c */
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index ae779fe..288802e 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -50,24 +50,26 @@ static int _check_num_areas_in_lv_segments(struct logical_volume *lv, unsigned n
 	return 1;
 }
 
-/* Ensure region size exceeds the minimum for lv */
-static void _ensure_min_region_size(const struct logical_volume *lv)
+/*
+ * Ensure region size exceeds the minimum for @lv because
+ * MD's bitmap is limited to tracking 2^21 regions.
+ *
+ * Pass in @lv_size, because funcion can be called with an empty @lv.
+ */
+uint32_t raid_ensure_min_region_size(const struct logical_volume *lv, uint64_t lv_size, uint32_t region_size)
 {
-	struct lv_segment *seg = first_seg(lv);
-	uint32_t min_region_size, region_size;
-
-	/* MD's bitmap is limited to tracking 2^21 regions */
-	min_region_size = lv->size / (1 << 21);
-	region_size = seg->region_size;
+	uint32_t min_region_size = lv_size / (1 << 21);
+	uint32_t region_size_sav = region_size;
 
 	while (region_size < min_region_size)
 		region_size *= 2;
 
-	if (seg->region_size != region_size) {
-		log_very_verbose("Setting region_size to %u for %s.",
-				 seg->region_size, display_lvname(lv));
-		seg->region_size = region_size;
-	}
+	if (region_size != region_size_sav)
+		log_very_verbose("Adjusting region_size from %s to %s for %s.",
+				 display_size(lv->vg->cmd, region_size_sav),
+				 display_size(lv->vg->cmd, region_size),
+				 display_lvname(lv));
+	return region_size;
 }
 
 /*
@@ -106,8 +108,7 @@ static void _check_and_adjust_region_size(const struct logical_volume *lv)
 	struct lv_segment *seg = first_seg(lv);
 
 	seg->region_size = seg->region_size ? : get_default_region_size(lv->vg->cmd);
-
-	return _ensure_min_region_size(lv);
+	seg->region_size = raid_ensure_min_region_size(lv, lv->size, seg->region_size);
 }
 
 /* Strip any raid suffix off LV name */
@@ -672,7 +673,7 @@ static int _alloc_image_components(struct logical_volume *lv,
 		return_0;
 
 	if (seg_is_linear(seg))
-		region_size = get_default_region_size(lv->vg->cmd);
+		region_size = seg->region_size ? : get_default_region_size(lv->vg->cmd);
 	else
 		region_size = seg->region_size;
 
@@ -757,7 +758,7 @@ static uint32_t _raid_rmeta_extents(struct cmd_context *cmd, uint32_t rimage_ext
 	uint64_t bytes, regions, sectors;
 
 	region_size = region_size ?: get_default_region_size(cmd);
-	regions = (uint64_t) rimage_extents * extent_size / region_size;
+	regions = ((uint64_t) rimage_extents) * extent_size / region_size;
 
 	/* raid and bitmap superblocks + region bytes */
 	bytes = 2 * 4096 + dm_div_up(regions, 8);
@@ -767,6 +768,53 @@ static uint32_t _raid_rmeta_extents(struct cmd_context *cmd, uint32_t rimage_ext
 }
 
 /*
+ * Returns raid metadata device size _change_ in extents, algorithm from dm-raid ("raid" target) kernel code.
+ */
+uint32_t raid_rmeta_extents_delta(struct cmd_context *cmd,
+				  uint32_t rimage_extents_cur, uint32_t rimage_extents_new,
+				  uint32_t region_size, uint32_t extent_size)
+{
+	uint32_t rmeta_extents_cur = _raid_rmeta_extents(cmd, rimage_extents_cur, region_size, extent_size);
+	uint32_t rmeta_extents_new = _raid_rmeta_extents(cmd, rimage_extents_new, region_size, extent_size);
+
+	/* Need minimum size on LV creation */
+	if (!rimage_extents_cur)
+		return rmeta_extents_new;
+
+	/* Need current size on LV deletion */
+	if (!rimage_extents_new)
+		return rmeta_extents_cur;
+
+	if (rmeta_extents_new == rmeta_extents_cur)
+		return 0;
+
+	/* Extending/reducing... */
+	return rmeta_extents_new > rmeta_extents_cur ?
+		rmeta_extents_new - rmeta_extents_cur :
+		rmeta_extents_cur - rmeta_extents_new;
+}
+
+/* Calculate raid rimage extents required based on total @extents for @segtype, @stripes and @data_copies */
+uint32_t raid_rimage_extents(const struct segment_type *segtype,
+			     uint32_t extents, uint32_t stripes, uint32_t data_copies)
+{
+	uint64_t r;
+
+	if (!extents ||
+	    segtype_is_mirror(segtype) ||
+	    segtype_is_raid1(segtype))
+		return extents;
+
+	r = extents;
+	if (segtype_is_any_raid10(segtype))
+		r *= (data_copies ?: 1); /* Caller should ensure data_copies > 0 */
+
+	r = dm_div_up(r, stripes ?: 1); /* Caller should ensure stripes > 0 */
+
+	return r > UINT_MAX ? 0 : (uint32_t) r;
+}
+
+/*
  * _alloc_rmeta_for_lv
  * @lv
  *
@@ -806,7 +854,8 @@ static int _alloc_rmeta_for_lv(struct logical_volume *data_lv,
 
 	if (!(ah = allocate_extents(data_lv->vg, NULL, seg->segtype, 0, 1, 0,
 				    seg->region_size,
-				    1 /*RAID_METADATA_AREA_LEN*/,
+				    raid_rmeta_extents_delta(data_lv->vg->cmd, 0, data_lv->le_count,
+							     seg->region_size, data_lv->vg->extent_size),
 				    allocate_pvs, data_lv->alloc, 0, NULL)))
 		return_0;
 
@@ -866,6 +915,11 @@ static int _raid_add_images_without_commit(struct logical_volume *lv,
 		/* A complete resync will be done, no need to mark each sub-lv */
 		status_mask = ~(LV_REBUILD);
 
+		/* FIXME: allow setting region size on upconvert from linear */
+		seg->region_size = get_default_region_size(lv->vg->cmd);
+		/* MD's bitmap is limited to tracking 2^21 regions */
+		seg->region_size = raid_ensure_min_region_size(lv, lv->size, seg->region_size);
+
 		if (!(lvl = dm_pool_alloc(lv->vg->vgmem, sizeof(*lvl)))) {
 			log_error("Memory allocation failed.");
 			return 0;
@@ -912,7 +966,9 @@ static int _raid_add_images_without_commit(struct logical_volume *lv,
 		goto fail;
 
 	if (seg_is_linear(seg)) {
-		first_seg(lv)->status |= RAID_IMAGE;
+		uint32_t region_size = seg->region_size;
+
+		seg->status |= RAID_IMAGE;
 		if (!insert_layer_for_lv(lv->vg->cmd, lv,
 					 RAID | LVM_READ | LVM_WRITE,
 					 "_rimage_0"))
@@ -920,15 +976,8 @@ static int _raid_add_images_without_commit(struct logical_volume *lv,
 
 		lv->status |= RAID;
 		seg = first_seg(lv);
+		seg->region_size = region_size;
 		seg_lv(seg, 0)->status |= RAID_IMAGE | LVM_READ | LVM_WRITE;
-		seg->region_size = get_default_region_size(lv->vg->cmd);
-
-		/* MD's bitmap is limited to tracking 2^21 regions */
-		while (seg->region_size < (lv->size / (1 << 21))) {
-			seg->region_size *= 2;
-			log_very_verbose("Setting RAID1 region_size to %uS.",
-					 seg->region_size);
-		}
 		if (!(seg->segtype = get_segtype_from_string(lv->vg->cmd, SEG_TYPE_NAME_RAID1)))
 			return_0;
 	}
@@ -3875,7 +3924,8 @@ replaced:
  * Change region size on raid @lv to @region_size if
  * different from current region_size and adjusted region size
  */
-static int _region_size_change_requested(struct logical_volume *lv, int yes, uint32_t region_size)
+static int _region_size_change_requested(struct logical_volume *lv, int yes, uint32_t region_size,
+					 struct dm_list *allocate_pvs)
 {
 	uint32_t old_region_size;
 	const char *seg_region_size_str;
@@ -3937,6 +3987,7 @@ static int _region_size_change_requested(struct logical_volume *lv, int yes, uin
 	    _raid_rmeta_extents(lv->vg->cmd, lv->le_count, seg->region_size, lv->vg->extent_size)) {
 		log_error("Region size %s on %s is too small for metadata LV size.",
 			  seg_region_size_str, display_lvname(lv));
+if (!lv_extend(lv, seg->segtype, seg->area_count - seg->segtype->parity_devs, seg->stripe_size, 1, seg->region_size, 0, allocate_pvs, lv->vg->alloc, 0))
 		return 0;
 	}
 
@@ -4035,7 +4086,7 @@ int lv_raid_convert(struct logical_volume *lv,
 	       if (new_segtype == seg->segtype &&
 	           new_region_size != seg->region_size &&
 		   seg_is_raid(seg) && !seg_is_any_raid0(seg))
-			return _region_size_change_requested(lv, yes, new_region_size);
+			return _region_size_change_requested(lv, yes, new_region_size, allocate_pvs);
 	} else
 		new_region_size = seg->region_size ? : get_default_region_size(lv->vg->cmd);
 
diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 027e3f4..7c3daa5 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1413,10 +1413,10 @@ have_raid() {
 }
 
 have_raid4 () {
-	local r=1
+	local r=0
 
-	have_raid 1 8 0 && r=0
-	have_raid 1 9 1 && r=1
+	have_raid 1 8 0 && r=1
+	have_raid 1 9 1 && r=0
 
 	return $r
 }
diff --git a/test/shell/lvconvert-repair-raid.sh b/test/shell/lvconvert-repair-raid.sh
index 26bca3d..3052f5c 100644
--- a/test/shell/lvconvert-repair-raid.sh
+++ b/test/shell/lvconvert-repair-raid.sh
@@ -20,7 +20,7 @@ aux raid456_replace_works || skip
 aux lvmconf 'allocation/maximise_cling = 0' \
 	    'allocation/mirror_logs_require_separate_pvs = 1'
 
-aux prepare_vg 8
+aux prepare_vg 8 80
 
 function delay
 {
diff --git a/test/shell/lvresize-raid.sh b/test/shell/lvresize-raid.sh
index 4eabe4c..4f22740 100644
--- a/test/shell/lvresize-raid.sh
+++ b/test/shell/lvresize-raid.sh
@@ -16,8 +16,8 @@ SKIP_WITH_LVMPOLLD=1
 
 aux have_raid 1 3 0 || skip
 
-levels="5 6"
-aux have_raid4 && levels="4 5 6"
+levels="5 6 10"
+aux have_raid4 && levels="0 0_meta 4 $levels"
 
 aux prepare_pvs 6 80
 
@@ -39,9 +39,10 @@ for deactivate in true false; do
 
 	#check raid_images_contiguous $vg $lv1
 
-# Extend and reduce 3-striped RAID 4/5/6
+# Extend and reduce 3-striped RAID 4/5/6/10
 	for i in $levels ; do
 		lvcreate --type raid$i -i 3 -l 3 -n $lv2 $vg
+		check lv_field $vg/$lv2 "seg_size" "768.00k"
 
 		test $deactivate && {
 			aux wait_for_sync $vg $lv2
@@ -49,10 +50,12 @@ for deactivate in true false; do
 		}
 
 		lvresize -l +3 $vg/$lv2
+		check lv_field $vg/$lv2 "seg_size" "1.50m"
 
 		#check raid_images_contiguous $vg $lv1
 
 		should lvresize -y -l -3 $vg/$lv2
+		should check lv_field $vg/$lv2 "seg_size" "768.00k"
 
 		#check raid_images_contiguous $vg $lv1
 


