From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 20 Jan 2016 12:53:56 +0000 (UTC)
Subject: master - cleanup: adjust once
Message-ID: <20160120125356.C8C2760D1E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ca878a3426197b629c76e98cfc049948da470cd7
Commit:        ca878a3426197b629c76e98cfc049948da470cd7
Parent:        178cbb580a9c07b777a2abf1e82d250310531e86
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jan 19 11:44:11 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jan 20 13:44:47 2016 +0100

cleanup: adjust once

---
 lib/metadata/lv_manip.c |  151 +++++++++++++++++++++++------------------------
 1 files changed, 73 insertions(+), 78 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 13e088c..b283756 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4680,32 +4680,30 @@ static int _lvresize_check_lv(struct cmd_context *cmd, struct logical_volume *lv
 	return 1;
 }
 
-static int _lvresize_adjust_size(struct cmd_context *cmd, struct logical_volume *lv,
-				 struct lvresize_params *lp)
+static int _lvresize_adjust_size(struct volume_group *vg,
+				 uint64_t size, sign_t sign,
+				 uint32_t *extents)
 {
-	struct volume_group *vg = lv->vg;
+	uint32_t extent_size = vg->extent_size;
+	uint32_t adjust;
 
 	/*
 	 * First adjust to an exact multiple of extent size.
+	 * When changing to an absolute size, we round that size up.
 	 * When extending by a relative amount we round that amount up.
 	 * When reducing by a relative amount we remove at most that amount.
-	 * When changing to an absolute size, we round that size up.
 	 */
-	if (lp->size) {
-		if (lp->size % vg->extent_size) {
-			if (lp->sign == SIGN_MINUS)
-				lp->size -= lp->size % vg->extent_size;
-			else
-				lp->size += vg->extent_size -
-				    (lp->size % vg->extent_size);
+	if ((adjust = (size % extent_size))) {
+		if (sign != SIGN_MINUS) /* not reducing */
+			size += extent_size;
 
-			log_print_unless_silent("Rounding size to boundary between physical extents: %s",
-						display_size(cmd, lp->size));
-		}
-
-		lp->extents = lp->size / vg->extent_size;
+		size -= adjust;
+		log_print_unless_silent("Rounding size to boundary between physical extents: %s.",
+					display_size(vg->cmd, size));
 	}
 
+	*extents = size / extent_size;
+
 	return 1;
 }
 
@@ -4813,7 +4811,7 @@ static int _lvresize_adjust_extents(struct cmd_context *cmd, struct logical_volu
 	uint32_t physical_extents_used = 0;
 	uint32_t seg_stripes = 0, seg_stripesize = 0;
 	uint32_t seg_mirrors = 0;
-	struct lv_segment *seg, *mirr_seg;
+	struct lv_segment *seg, *seg_last;
 	uint32_t sz, str;
 	uint32_t seg_logical_extents;
 	uint32_t seg_physical_extents;
@@ -4822,19 +4820,18 @@ static int _lvresize_adjust_extents(struct cmd_context *cmd, struct logical_volu
 	uint32_t size_rest;
 	uint32_t existing_logical_extents = lv->le_count;
 	uint32_t existing_physical_extents, saved_existing_physical_extents;
+	uint32_t existing_extents;
 	uint32_t seg_size = 0;
 	uint32_t new_extents;
 	int reducing = 0;
 
-	if (!_lvresize_extents_from_percent(lv, lp, pvh))
-		return_0;
-
 	if (lv_is_thin_pool(lv))
 		/* Manipulate the thin data layer underneath */
 		lv = seg_lv(first_seg(lv), 0);
 
+	seg_last = last_seg(lv);
 	/* Use segment type of last segment */
-	lp->segtype = last_seg(lv)->segtype;
+	lp->segtype = seg_last->segtype;
 
 	/* FIXME Support LVs with mixed segment types */
 	if (lp->segtype != get_segtype_from_string(cmd, lp->ac_type ? : lp->segtype->name)) {
@@ -4849,17 +4846,17 @@ static int _lvresize_adjust_extents(struct cmd_context *cmd, struct logical_volu
 		lp->extents_are_pes = 0;
 	}
 
+	existing_extents = (lp->extents_are_pes)
+		? existing_physical_extents : existing_logical_extents;
+
 	/* Initial decision on whether we are extending or reducing */
 	if (lp->sign == SIGN_MINUS ||
-	    (lp->sign == SIGN_NONE &&
-	     ((lp->extents_are_pes && lp->extents < existing_physical_extents) ||
-	      (!lp->extents_are_pes && lp->extents < existing_logical_extents))))
+	    (lp->sign == SIGN_NONE && (lp->extents < existing_extents)))
 		reducing = 1;
 
 	/* If extending, find properties of last segment */
 	if (!reducing) {
-		mirr_seg = last_seg(lv);
-		seg_mirrors = seg_is_mirrored(mirr_seg) ? lv_mirror_count(mirr_seg->lv) : 0;
+		seg_mirrors = seg_is_mirrored(seg_last) ? lv_mirror_count(lv) : 0;
 
 		if (!lp->ac_mirrors && seg_mirrors) {
 			log_print_unless_silent("Extending %" PRIu32 " mirror images.", seg_mirrors);
@@ -4872,21 +4869,21 @@ static int _lvresize_adjust_extents(struct cmd_context *cmd, struct logical_volu
 			return 0;
 		}
 
-		if (seg_is_raid10(mirr_seg)) {
+		if (seg_is_raid10(seg_last)) {
 			if (!seg_mirrors) {
 				log_error(INTERNAL_ERROR "Missing mirror segments for %s.",
 					  display_lvname(lv));
 				return 0;
 			}
 			/* FIXME Warn if command line values are being overridden? */
-			lp->stripes = mirr_seg->area_count / seg_mirrors;
-			lp->stripe_size = mirr_seg->stripe_size;
+			lp->stripes = seg_last->area_count / seg_mirrors;
+			lp->stripe_size = seg_last->stripe_size;
 		} else if (!(lp->stripes == 1 || (lp->stripes > 1 && lp->stripe_size))) {
 			/* If extending, find stripes, stripesize & size of last segment */
 			/* FIXME Don't assume mirror seg will always be AREA_LV */
 			/* FIXME We will need to support resize for metadata LV as well,
 			 *       and data LV could be any type (i.e. mirror)) */
-			dm_list_iterate_items(seg, seg_mirrors ? &seg_lv(mirr_seg, 0)->segments : &lv->segments) {
+			dm_list_iterate_items(seg, seg_mirrors ? &seg_lv(seg_last, 0)->segments : &lv->segments) {
 				/* Allow through "striped" and RAID 4/5/6/10 */
 				if (!seg_is_striped(seg) &&
 				    (!seg_is_raid(seg) || seg_is_mirrored(seg)) &&
@@ -4931,35 +4928,61 @@ static int _lvresize_adjust_extents(struct cmd_context *cmd, struct logical_volu
 			}
 		}
 
+		if (lp->stripes > 1 && !lp->stripe_size) {
+			log_error("Stripesize for striped segment should not be 0!");
+			return 0;
+		}
+
 		/* Determine the amount to extend by */
 		if (lp->sign == SIGN_PLUS)
 			seg_size = lp->extents;
-		else if (lp->extents_are_pes)
-			seg_size = lp->extents - existing_physical_extents;
 		else
-			seg_size = lp->extents - existing_logical_extents;
+			seg_size = lp->extents - existing_extents;
 
 		/* Convert PEs to LEs */
-		if (lp->extents_are_pes && !seg_is_striped(last_seg(lv)) && !seg_is_virtual(last_seg(lv))) {
-			area_multiple = _calc_area_multiple(last_seg(lv)->segtype, last_seg(lv)->area_count, 0);
-			seg_size = seg_size * area_multiple / (last_seg(lv)->area_count - last_seg(lv)->segtype->parity_devs);
+		if (lp->extents_are_pes && !seg_is_striped(seg_last) && !seg_is_virtual(seg_last)) {
+			area_multiple = _calc_area_multiple(seg_last->segtype, seg_last->area_count, 0);
+			seg_size = seg_size * area_multiple / (seg_last->area_count - seg_last->segtype->parity_devs);
 			seg_size = (seg_size / area_multiple) * area_multiple;
 		}
-	}
 
-	/* If reducing, find stripes, stripesize & size of last segment */
-	if (reducing) {
-		if (lp->stripes || lp->stripe_size || lp->mirrors)
+		if (seg_size >= (MAX_EXTENT_COUNT - existing_logical_extents)) {
+			log_error("Unable to extend %s by %u logical extents: exceeds limit (%u).",
+				  lp->lv_name, seg_size, MAX_EXTENT_COUNT);
+			return 0;
+		}
+
+		lp->extents = existing_logical_extents + seg_size;
+
+		/* Don't allow a cow to grow larger than necessary. */
+		if (lv_is_cow(lv)) {
+			logical_extents_used = cow_max_extents(origin_from_cow(lv), find_snapshot(lv)->chunk_size);
+			if (logical_extents_used < lp->extents) {
+				log_print_unless_silent("Reached maximum COW size %s (%" PRIu32 " extents).",
+							display_size(vg->cmd, (uint64_t) vg->extent_size * logical_extents_used),
+							logical_extents_used);
+				lp->extents = logical_extents_used;	// CHANGES lp->extents
+				seg_size = lp->extents - existing_logical_extents;	// Recalculate
+				if (lp->extents == existing_logical_extents) {
+					/* Signal that normal resizing is not required */
+					lp->sizeargs = 0;
+					return 1;
+				}
+			}
+		}
+	} else {  /* If reducing, find stripes, stripesize & size of last segment */
+		if (lp->stripes || lp->stripe_size || lp->mirrors) {
+			lp->stripes = lp->stripe_size = lp->mirrors = 0;
 			log_print_unless_silent("Ignoring stripes, stripesize and mirrors "
 						"arguments when reducing.");
+		}
 
 		if (lp->sign == SIGN_MINUS)  {
-			new_extents = lp->extents_are_pes ? existing_physical_extents : existing_logical_extents;
-			if (lp->extents >= new_extents) {
+			if (lp->extents >= existing_extents) {
 				log_error("Unable to reduce %s below 1 extent.", lp->lv_name);
 				return 0;
 			}
-			new_extents -= lp->extents;
+			new_extents = existing_extents - lp->extents;
 		} else
 			new_extents = lp->extents;
 
@@ -4999,37 +5022,6 @@ static int _lvresize_adjust_extents(struct cmd_context *cmd, struct logical_volu
 		lp->mirrors = seg_mirrors;
 	}
 
-	if (lp->stripes > 1 && !lp->stripe_size) {
-		log_error("Stripesize for striped segment should not be 0!");
-		return 0;
-	}
-
-	if (!reducing) {
-		if (seg_size >= (MAX_EXTENT_COUNT - existing_logical_extents)) {
-			log_error("Unable to extend %s by %u logical extents: exceeds limit (%u).",
-				  lp->lv_name, seg_size, MAX_EXTENT_COUNT);
-			return 0;
-		}
-		lp->extents = existing_logical_extents + seg_size;
-
-		/* Don't allow a cow to grow larger than necessary. */
-		if (lv_is_cow(lv)) {
-			logical_extents_used = cow_max_extents(origin_from_cow(lv), find_snapshot(lv)->chunk_size);
-			if (logical_extents_used < lp->extents) {
-				log_print_unless_silent("Reached maximum COW size %s (%" PRIu32 " extents).",
-							display_size(vg->cmd, (uint64_t) vg->extent_size * logical_extents_used),
-							logical_extents_used);
-				lp->extents = logical_extents_used;	// CHANGES lp->extents
-				seg_size = lp->extents - existing_logical_extents;	// Recalculate
-				if (lp->extents == existing_logical_extents) {
-					/* Signal that normal resizing is not required */
-					lp->sizeargs = 0;
-					return 1;
-				}
-			}
-		}
-	}
-
 	/* At this point, lp->extents should hold the correct NEW logical size required. */
 
 	if (!lp->extents) {
@@ -5274,10 +5266,13 @@ int lv_resize_prepare(struct cmd_context *cmd, struct logical_volume *lv,
 	if (lp->ac_policy && !_adjust_policy_params(cmd, lv, lp))
 		return_0;
 
-	if (!_lvresize_adjust_size(cmd, lv, lp))
+	if (lp->size && !_lvresize_adjust_size(lv->vg, lp->size, lp->sign,
+					       &lp->extents))
+		return_0;
+	else if (lp->extents && !_lvresize_extents_from_percent(lv, lp, pvh))
 		return_0;
 
-	if (lp->sizeargs && !_lvresize_adjust_extents(cmd, lv, lp, pvh))
+	if (lp->extents && !_lvresize_adjust_extents(cmd, lv, lp, pvh))
 		return_0;
 
 	if ((lp->extents == lv->le_count) && lp->ac_policy) {
@@ -5286,7 +5281,7 @@ int lv_resize_prepare(struct cmd_context *cmd, struct logical_volume *lv,
 		lp->poolmetadatasize = 0;
 	}
 
-	if (lp->sizeargs && !_lvresize_check_type(cmd, lv, lp))
+	if (lp->extents && !_lvresize_check_type(cmd, lv, lp))
 		return_0;
 
 	if (lp->poolmetadatasize &&
@@ -5316,7 +5311,7 @@ int lv_resize(struct cmd_context *cmd, struct logical_volume *lv,
 	if (!lockd_lv(cmd, lv, "ex", 0))
 		return_0;
 
-	if (lp->sizeargs &&
+	if (lp->extents &&
 	    !(lock_lv = _lvresize_volume(cmd, lv, lp, pvh)))
 		return_0;
 


