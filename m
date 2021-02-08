From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon,  8 Feb 2021 22:45:03 +0000 (GMT)
Subject: main - lv_resize: support resizing of cached volumes
Message-ID: <20210208224503.DC767389681C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5ec24dfb0bb0c9e48d59d6fbb83262a7087964e1
Commit:        5ec24dfb0bb0c9e48d59d6fbb83262a7087964e1
Parent:        39dec265084c05aaa086288863710148d28d1ccb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Feb 7 20:12:00 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 8 23:43:10 2021 +0100

lv_resize: support resizing of cached volumes

Automatically figure out resizable layer in the LV stack and
resize it online.

Split check for reshaped raids and postpone removal of
unused space after finished reshaping after metadata archiving.

Drop warning about unsupported automatic resize of monitored thin-pool.

Currently there is not yet support for resize of writecache.
---
 lib/metadata/cache_manip.c |   5 --
 lib/metadata/lv_manip.c    | 182 +++++++++++++++++++++++++++------------------
 2 files changed, 110 insertions(+), 77 deletions(-)

diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 90ebd9404..f29442358 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -169,11 +169,6 @@ void cache_check_for_warns(const struct lv_segment *seg)
 	    first_seg(seg->pool_lv)->cache_mode == CACHE_MODE_WRITEBACK)
 		log_warn("WARNING: Data redundancy could be lost with writeback "
 			 "caching of raid logical volume!");
-
-	if (lv_is_thin_pool_data(seg->lv)) {
-		log_warn("WARNING: thin pool data will not be automatically extended when cached.");
-		log_warn("WARNING: manual splitcache is required before extending thin pool data.");
-	}
 }
 
 /*
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 346a50ca5..833d7f8c5 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1458,6 +1458,48 @@ static int _lv_segment_reduce(struct lv_segment *seg, uint32_t reduction)
 	return 1;
 }
 
+/* Find the bottommost resizable LV in the stack.
+ * It does not matter which LV is used in this stack for cmdline tool. */
+static struct logical_volume *_get_resizable_layer_lv(struct logical_volume *lv)
+{
+	while (lv_is_cache(lv) || /* _corig */
+	       lv_is_integrity(lv) ||
+	       lv_is_thin_pool(lv) || /* _tdata */
+	       lv_is_vdo_pool(lv)) /* _vdata */
+		lv = seg_lv(first_seg(lv), 0);  /* component-level down */
+
+	return lv;
+}
+
+/* Check if LV is component of resizable LV.
+ * When resize changes size of LV this also changes the size whole stack upward.
+ * Support syntax suggar - so user can pick any LV in stack for resize. */
+static int _is_layered_lv(struct logical_volume *lv)
+{
+	return (lv_is_cache_origin(lv) ||
+		lv_is_integrity_origin(lv) ||
+		lv_is_thin_pool_data(lv) ||
+		lv_is_vdo_pool_data(lv));
+}
+
+/* Find the topmost LV in the stack - usually such LV is visible. */
+static struct logical_volume *_get_top_layer_lv(struct logical_volume *lv)
+{
+	struct lv_segment *seg;
+
+	while (_is_layered_lv(lv)) {
+		if (!(seg = get_only_segment_using_this_lv(lv))) {
+			log_error(INTERNAL_ERROR "No single component user of logical volume %s.",
+				  display_lvname(lv));
+			return NULL;
+		}
+		lv = seg->lv; /* component-level up */
+	}
+
+	return lv;
+}
+
+
 /* Handles also stacking */
 static int _setup_lv_size(struct logical_volume *lv, uint32_t extents)
 {
@@ -1466,17 +1508,15 @@ static int _setup_lv_size(struct logical_volume *lv, uint32_t extents)
 	lv->le_count = extents;
 	lv->size = (uint64_t) extents * lv->vg->extent_size;
 
-	if (lv->size &&
-	    (lv_is_thin_pool_data(lv) ||
-	     lv_is_vdo_pool_data(lv))) {
+	while (lv->size && _is_layered_lv(lv)) {
 		if (!(seg = get_only_segment_using_this_lv(lv)))
 			return_0;
 
-		/* Update pool segment from the layered LV */
 		seg->lv->le_count =
 			seg->len =
 			seg->area_len = lv->le_count;
 		seg->lv->size = lv->size;
+		lv = seg->lv;
 	}
 
 	return 1;
@@ -5160,7 +5200,7 @@ static int _lvresize_check(struct logical_volume *lv,
 		return 0;
 	}
 
-	if (seg && (seg_is_raid4(seg) || seg_is_any_raid5(seg)) && seg->area_count < 3) {
+	if ((seg_is_raid4(seg) || seg_is_any_raid5(seg)) && seg->area_count < 3) {
 		log_error("Cannot resize %s LV %s. Convert to more stripes first.",
 			  lvseg_name(seg), display_lvname(lv));
 		return 0;
@@ -5179,20 +5219,6 @@ static int _lvresize_check(struct logical_volume *lv,
 		}
 	}
 
-	if (lp->use_policies &&
-	    !lv_is_cow(lv) &&
-	    !lv_is_thin_pool(lv) &&
-	    !lv_is_vdo_pool(lv)) {
-		log_error("Policy-based resize is supported only for snapshot, thin pool and vdo pool volumes.");
-		return 0;
-	}
-
-	if (lv_is_cache_type(lv) ||
-	    (lv_is_thin_pool(lv) && lv_is_cache_type(seg_lv(first_seg(lv), 0)))) {
-		log_error("Unable to resize logical volumes of cache type.");
-		return 0;
-	}
-
 	if (!lv_is_visible(lv) &&
 	    !lv_is_thin_pool_metadata(lv) &&
 	    !lv_is_vdo_pool_data(lv) &&
@@ -5212,11 +5238,6 @@ static int _lvresize_check(struct logical_volume *lv,
 		return 0;
 	}
 
-	if (!lv_is_thin_pool(lv) && lp->poolmetadata_size) {
-		log_error("--poolmetadatasize can be used only with thin pools.");
-		return 0;
-	}
-
 	if (lp->stripe_size) {
 		if (!(vg->fid->fmt->features & FMT_SEGMENTS)) {
 			log_print_unless_silent("Varied stripesize not supported. Ignoring.");
@@ -5665,8 +5686,8 @@ static int _lvresize_adjust_extents(struct logical_volume *lv,
 		return 0;
 	}
 
-	if (lp->extents == existing_logical_extents) {
-		if (!lp->resizefs) {
+	if ((lp->extents == existing_logical_extents) && !lp->use_policies) {
+		if (!lp->resizefs && !lp->poolmetadata_size) {
 			log_error("New size (%d extents) matches existing size (%d extents).",
 				  lp->extents, existing_logical_extents);
 			return 0;
@@ -5726,7 +5747,7 @@ static int _lvresize_adjust_extents(struct logical_volume *lv,
 		}
 		lp->resize = LV_EXTEND;
 	} else if ((lp->extents == existing_logical_extents) && !lp->use_policies) {
-		if (!lp->resizefs) {
+		if (!lp->resizefs && !lp->poolmetadata_size) {
 			log_error("New size (%d extents) matches existing size "
 				  "(%d extents)", lp->extents, existing_logical_extents);
 			return 0;
@@ -5800,6 +5821,12 @@ static int _lvresize_check_type(const struct logical_volume *lv,
 		}
 	}
 
+	/* Prevent resizing on out-of-sync reshapable raid */
+	if (first_seg(lv)->reshape_len && !lv_raid_in_sync(lv)) {
+		log_error("Can't resize reshaping LV %s.", display_lvname(lv));
+		return 0;
+	}
+
 	return 1;
 }
 
@@ -5848,28 +5875,26 @@ static int _lvresize_volume(struct logical_volume *lv,
 	return 1;
 }
 
-static int _lvresize_prepare(struct logical_volume **lv,
+static int _lvresize_prepare(struct logical_volume *lv,
 			     struct lvresize_params *lp,
 			     struct dm_list *pvh)
 {
-	struct volume_group *vg = (*lv)->vg;
-
-	if (lv_is_thin_pool(*lv) || lv_is_vdo_pool(*lv))
-		*lv = seg_lv(first_seg(*lv), 0); /* switch to data LV */
-
-	if (lv_is_integrity(*lv))
-		*lv = seg_lv(first_seg(*lv), 0);
-
 	/* Resolve extents from size */
-	if (lp->size && !_lvresize_adjust_size(vg, lp->size, lp->sign, &lp->extents))
+	if (lp->size && !_lvresize_adjust_size(lv->vg, lp->size, lp->sign, &lp->extents))
 		return_0;
-	else if (lp->extents && !_lvresize_extents_from_percent(*lv, lp, pvh))
+	else if (lp->extents && !_lvresize_extents_from_percent(lv, lp, pvh))
 		return_0;
 
-	if (!_lvresize_adjust_extents(*lv, lp, pvh))
+	/* Ensure stripe boundary extents! */
+	if (!lp->percent && lv_is_raid(lv))
+		lp->extents =_round_to_stripe_boundary(lv->vg, lp->extents,
+						       seg_is_raid1(first_seg(lv)) ? 0 : _raid_stripes_count(first_seg(lv)),
+						       lp->resize == LV_REDUCE ? 0 : 1);
+
+	if (!_lvresize_adjust_extents(lv, lp, pvh))
 		return_0;
 
-	if (!_lvresize_check_type(*lv, lp))
+	if (!_lvresize_check_type(lv, lp))
 		return_0;
 
 	return 1;
@@ -5900,6 +5925,7 @@ int lv_resize(struct logical_volume *lv,
 	struct cmd_context *cmd = vg->cmd;
 	struct logical_volume *lock_lv = (struct logical_volume*) lv_lock_holder(lv);
 	struct logical_volume *aux_lv = NULL; /* Note: aux_lv never resizes fs */
+	struct logical_volume *resizable_layer_lv;
 	struct lvresize_params aux_lp;
 	struct lv_segment *seg = first_seg(lv);
 	int activated = 0;
@@ -5908,21 +5934,14 @@ int lv_resize(struct logical_volume *lv,
 	struct device *dev;
 	char name[PATH_MAX];
 
-	if (!_lvresize_check(lv, lp))
-		return_0;
-
-	if (seg->reshape_len) {
-		/* Prevent resizing on out-of-sync reshapable raid */
-		if (!lv_raid_in_sync(lv)) {
-			log_error("Can't resize reshaping LV %s.", display_lvname(lv));
+	if (lp->use_policies) {
+		if (!lv_is_cow(lv) &&
+		    !lv_is_thin_pool(lv) &&
+		    !lv_is_vdo_pool(lv)) {
+			log_error("Policy-based resize is supported only for snapshot, thin pool and vdo pool volumes.");
 			return 0;
 		}
-		/* Remove any striped raid reshape space for LV resizing */
-		if (!lv_raid_free_reshape_space(lv))
-			return_0;
-	}
 
-	if (lp->use_policies) {
 		lp->extents = 0;
 		lp->sign = SIGN_PLUS;
 		lp->percent = PERCENT_LV;
@@ -5935,57 +5954,68 @@ int lv_resize(struct logical_volume *lv,
 			if (!aux_lp.extents)
 				return 1;  /* Nothing to do */
 			/* Resize thin-pool metadata as mainlv */
-			lv = first_seg(lv)->metadata_lv; /* metadata LV */
+			lv = seg->metadata_lv; /* metadata LV */
 			lp->extents = aux_lp.extents;
 		} else if (aux_lp.extents) {
 			/* Also resize thin-pool metadata */
-			aux_lv = _lvresize_setup_aux(first_seg(lv)->metadata_lv, &aux_lp);
+			aux_lv = _lvresize_setup_aux(seg->metadata_lv, &aux_lp);
 		}
 	} else if (lp->poolmetadata_size) {
+		/* Validate --poolmetadata_size supported volumes here */
+		if (!lv_is_thin_pool(lv) && !lv_is_thin_pool_metadata(lv)) {
+			log_error("--poolmetadatasize can be used only with thin pools.");
+			return 0;
+		}
 		if (!lp->extents && !lp->size) {
-			/* When only --poolmetadatasize given and not --size
+			/* When only --poolmetadatasize given and any size option
 			 * switch directly to resize metadata LV */
-			lv = first_seg(lv)->metadata_lv;
+			if (lv_is_thin_pool(lv))
+				lv = seg->metadata_lv;
 			lp->size = lp->poolmetadata_size;
 			lp->sign = lp->poolmetadata_sign;
-		} else {
+			lp->poolmetadata_size = 0;
+		} else if (lv_is_thin_pool(lv)) {
 			aux_lp = *lp;
-			aux_lv = _lvresize_setup_aux(first_seg(lv)->metadata_lv, &aux_lp);
+			aux_lv = _lvresize_setup_aux(seg->metadata_lv, &aux_lp);
 			aux_lp.size = lp->poolmetadata_size;
 			aux_lp.sign = lp->poolmetadata_sign;
+		} else {
+			log_error("--poolmetadatasize for thin-pool metadata cannot be used with size.");
+			return 0;
 		}
 	}
 
-	/* Ensure stripe boundary extents! */
-	if (!lp->percent && lv_is_raid(lv))
-		lp->extents =_round_to_stripe_boundary(lv->vg, lp->extents,
-						       seg_is_raid1(seg) ? 0 : _raid_stripes_count(seg),
-						       lp->resize == LV_REDUCE ? 0 : 1);
-	if (aux_lv && !_lvresize_prepare(&aux_lv, &aux_lp, pvh))
+	resizable_layer_lv = _get_resizable_layer_lv(lv);
+	if (!(lv = _get_top_layer_lv(lv)))
+		return_0;
+
+	if (!_lvresize_check(lv, lp))
 		return_0;
 
 	/* Always should have lp->size or lp->extents */
-	if (!_lvresize_prepare(&lv, lp, pvh))
+	if (!_lvresize_prepare(resizable_layer_lv, lp, pvh))
 		return_0;
 
-	if (lp->resize != LV_REDUCE && !aux_lv && !lp->poolmetadata_size &&
-	    &lv->vg->pvs == pvh && lv_is_thin_pool_data(lv)) {
+	if ((lp->resize != LV_REDUCE) && !aux_lv && !lp->poolmetadata_size &&
+	    (&vg->pvs == pvh) && lv_is_thin_pool(lv)) {
 		/* When thin-pool data part is extended, automatically extend also metadata part
 		 * to have the metadata chunks for adressing all data blocks
 		 * Do this only when PV list is not defined and --poolmetadatasize is unspecified */
 		aux_lp = *lp;
-		seg = get_only_segment_using_this_lv(lv);
-		aux_lp.size = estimate_thin_pool_metadata_size(lp->extents, lv->vg->extent_size, seg->chunk_size);
+		seg = first_seg(lv);
+		aux_lp.size = estimate_thin_pool_metadata_size(lp->extents, vg->extent_size, seg->chunk_size);
 		if (aux_lp.size > seg->metadata_lv->size) {
 			log_verbose("Also going to resize thin-pool metadata to match bigger data.");
 			aux_lv = _lvresize_setup_aux(seg->metadata_lv, &aux_lp);
 			aux_lp.sign = SIGN_NONE;
-			if (!_lvresize_prepare(&aux_lv, &aux_lp, pvh))
-				return_0;
 		} else
 			aux_lp.size = 0;
 	}
 
+	if (aux_lv && (aux_lv = _get_resizable_layer_lv(aux_lv)) &&
+	    !_lvresize_prepare(aux_lv, &aux_lp, pvh))
+		return_0;
+
 	if (((lp->resize == LV_REDUCE) ||
 	     (aux_lv && aux_lp.resize == LV_REDUCE)) &&
 	    (pvh != &vg->pvs))
@@ -6090,6 +6120,14 @@ int lv_resize(struct logical_volume *lv,
 	if (!archive(vg))
 		return_0;
 
+	/* Remove any striped raid reshape space for LV resizing */
+	if (aux_lv && first_seg(aux_lv)->reshape_len)
+		if (!lv_raid_free_reshape_space(aux_lv))
+			return_0;
+	if (first_seg(resizable_layer_lv)->reshape_len)
+		if (!lv_raid_free_reshape_space(resizable_layer_lv))
+			return_0;
+
 	if (aux_lv) {
 		if (!_lvresize_volume(aux_lv, &aux_lp, pvh))
 			goto_bad;
@@ -6099,7 +6137,7 @@ int lv_resize(struct logical_volume *lv,
 			goto_bad;
 	}
 
-	if (!_lvresize_volume(lv, lp, pvh))
+	if (!_lvresize_volume(resizable_layer_lv, lp, pvh))
 		goto_bad;
 
 	/* store vg on disk(s) */


