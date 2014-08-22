From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 22 Aug 2014 00:37:53 +0000 (UTC)
Subject: master - lvresize: Fix raid/mirror and %PE handling code.
Message-ID: <20140822003753.1E0C660E7F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0b3d0e79f694ac9dc5a29270b2f791a250980058
Commit:        0b3d0e79f694ac9dc5a29270b2f791a250980058
Parent:        7e208d65043118907ff657c30f1423e96911fbbe
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Aug 22 01:26:14 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Aug 22 01:26:14 2014 +0100

lvresize: Fix raid/mirror and %PE handling code.

Sort out the lvresize calculation code to handle size changes
specified as physical extents as well as logical extents
and to process mirror resizing and raid extensions correctly.

The 'approx alloc' option was masking the underlying problem.
---
 WHATS_NEW                        |    1 +
 lib/display/display.c            |    2 +-
 lib/metadata/lv_manip.c          |  502 +++++++++++++++++++++++---------------
 lib/metadata/metadata-exported.h |    1 +
 4 files changed, 311 insertions(+), 195 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index f5a1dcf..79dbf01 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.110 -
 ==================================
+  Modify lvresize code to handle raid/mirrors and physical extents.
   Allow conversion of raid1 LV into a snapshot LV or snapshot origin LV.
   Cleanly error when creating RAID with stripe size < PAGE_SIZE.
   Print name of LV which on activation triggers delayed snapshot merge.
diff --git a/lib/display/display.c b/lib/display/display.c
index 6cdd07b..1b92b31 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -86,7 +86,7 @@ alloc_policy_t get_alloc_from_string(const char *str)
 	return ALLOC_INVALID;
 }
 
-static const char *_percent_types[7] = { "NONE", "VGS", "FREE", "LVS", "PVS", "ORIGIN" };
+static const char *_percent_types[7] = { "NONE", "VG", "FREE", "LV", "PVS", "ORIGIN" };
 
 const char *get_percent_string(percent_type_t def)
 {
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index db70818..d85f536 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1453,6 +1453,7 @@ static struct alloc_handle *_alloc_init(struct cmd_context *cmd,
 					struct dm_pool *mem,
 					const struct segment_type *segtype,
 					alloc_policy_t alloc, int approx_alloc,
+					uint32_t existing_extents,
 					uint32_t new_extents,
 					uint32_t mirrors,
 					uint32_t stripes,
@@ -1462,7 +1463,7 @@ static struct alloc_handle *_alloc_init(struct cmd_context *cmd,
 					struct dm_list *parallel_areas)
 {
 	struct alloc_handle *ah;
-	uint32_t s, area_count, alloc_count, parity_count;
+	uint32_t s, area_count, alloc_count, parity_count, total_extents;
 	size_t size = 0;
 
 	/* FIXME Caller should ensure this */
@@ -1493,8 +1494,7 @@ static struct alloc_handle *_alloc_init(struct cmd_context *cmd,
 	 * account for the extra parity devices because the array already
 	 * exists and they only want replacement drives.
 	 */
-	parity_count = (area_count <= segtype->parity_devs) ? 0 :
-		segtype->parity_devs;
+	parity_count = (area_count <= segtype->parity_devs) ? 0 : segtype->parity_devs;
 	alloc_count = area_count + parity_count;
 	if (segtype_is_raid(segtype) && metadata_area_count)
 		/* RAID has a meta area for each device */
@@ -1525,10 +1525,6 @@ static struct alloc_handle *_alloc_init(struct cmd_context *cmd,
 		return NULL;
 	}
 
-	if (mirrors || stripes)
-		ah->new_extents = new_extents;
-	else
-		ah->new_extents = 0;
 	ah->area_count = area_count;
 	ah->parity_count = parity_count;
 	ah->region_size = region_size;
@@ -1542,9 +1538,14 @@ static struct alloc_handle *_alloc_init(struct cmd_context *cmd,
 	 * a correct area_multiple.
 	 */
 	ah->area_multiple = _calc_area_multiple(segtype, area_count + parity_count, stripes);
-	//FIXME: s/mirror_logs_separate/metadata_separate/ so it can be used by otehrs?
+	//FIXME: s/mirror_logs_separate/metadata_separate/ so it can be used by others?
 	ah->mirror_logs_separate = find_config_tree_bool(cmd, allocation_mirror_logs_require_separate_pvs_CFG, NULL);
 
+	if (mirrors || stripes)
+		total_extents = new_extents;
+	else
+		total_extents = 0;
+
 	if (segtype_is_raid(segtype)) {
 		if (metadata_area_count) {
 			if (metadata_area_count != area_count)
@@ -1559,17 +1560,11 @@ static struct alloc_handle *_alloc_init(struct cmd_context *cmd,
 			 * We need 'log_len' extents for each
 			 * RAID device's metadata_area
 			 */
-			if (!approx_alloc)
-				ah->new_extents += (ah->log_len * ah->area_multiple);
+			total_extents += (ah->log_len * ah->area_multiple);
 		} else {
 			ah->log_area_count = 0;
 			ah->log_len = 0;
 		}
-		if (approx_alloc) {
-			ah->new_extents = ah->new_extents * ah->area_multiple / (ah->area_count + ah->parity_count);
-			ah->new_extents = (ah->new_extents / ah->area_multiple) * ah->area_multiple;
-			log_debug("Adjusted allocation request to %" PRIu32 " data extents.", ah->new_extents);
-		}
 	} else if (segtype_is_thin_pool(segtype)) {
 		/*
 		 * thin_pool uses ah->region_size to
@@ -1591,23 +1586,23 @@ static struct alloc_handle *_alloc_init(struct cmd_context *cmd,
 		ah->region_size = 0;
 		ah->mirror_logs_separate =
 			find_config_tree_bool(cmd, allocation_cache_pool_metadata_require_separate_pvs_CFG, NULL);
-		if (!ah->mirror_logs_separate) {
+		if (!ah->mirror_logs_separate)
 			ah->alloc_and_split_meta = 1;
-			if (!approx_alloc)
-				ah->new_extents += ah->log_len;
-		}
 	} else {
 		ah->log_area_count = metadata_area_count;
 		ah->log_len = !metadata_area_count ? 0 :
 			mirror_log_extents(ah->region_size, extent_size,
-					   new_extents / ah->area_multiple);
-		if (approx_alloc) {
-			ah->new_extents = ah->new_extents * ah->area_multiple / ah->area_count;
-			ah->new_extents = (ah->new_extents / ah->area_multiple) * ah->area_multiple;
-			log_debug("Adjusted allocation request to %" PRIu32 " data extents.", ah->new_extents);
-		}
+					   (existing_extents + total_extents) / ah->area_multiple);
 	}
 
+	log_debug("Adjusted allocation request to %" PRIu32 " logical extents. Existing size %" PRIu32 ". New size %" PRIu32 ".",
+		  total_extents, existing_extents, total_extents + existing_extents);
+
+	if (mirrors || stripes)
+		total_extents += existing_extents;
+
+	ah->new_extents = total_extents;
+
 	for (s = 0; s < alloc_count; s++)
 		dm_list_init(&ah->alloced_areas[s]);
 
@@ -1925,6 +1920,7 @@ static int _alloc_parallel_area(struct alloc_handle *ah, uint32_t max_to_allocat
  * reduced to cover only the first.
  * fn should return 0 on error, 1 to continue scanning or >1 to terminate without error.
  * In the last case, this function passes on the return code.
+ * FIXME I think some callers are expecting this to check all PV segments used by an LV.
  */
 static int _for_each_pv(struct cmd_context *cmd, struct logical_volume *lv,
 			uint32_t le, uint32_t len, struct lv_segment *seg,
@@ -1994,7 +1990,20 @@ static int _for_each_pv(struct cmd_context *cmd, struct logical_volume *lv,
 			return r;
 	}
 
-	/* FIXME Add snapshot cow LVs etc. */
+	/* FIXME Add snapshot cow, thin meta etc. */
+
+/*
+	if (!only_single_area_segments && !max_areas && seg_is_raid(seg)) {
+		for (s = first_area; s < seg->area_count; s++) {
+			if (seg_metalv(seg, s))
+				if (!(r = _for_each_pv(cmd, seg_metalv(seg, s), 0, seg_metalv(seg, s)->le_count, NULL,
+						       NULL, 0, 0, 0, 0, fn, data)))
+					stack;
+			if (r != 1)
+				return r;
+		}
+	}
+*/
 
 	return 1;
 }
@@ -2979,7 +2988,6 @@ struct alloc_handle *allocate_extents(struct volume_group *vg,
 				      struct dm_list *parallel_areas)
 {
 	struct alloc_handle *ah;
-	uint32_t new_extents;
 
 	if (segtype_is_virtual(segtype)) {
 		log_error("allocate_extents does not handle virtual segments");
@@ -3004,9 +3012,8 @@ struct alloc_handle *allocate_extents(struct volume_group *vg,
 	if (alloc >= ALLOC_INHERIT)
 		alloc = vg->alloc;
 
-	new_extents = (lv ? lv->le_count : 0) + extents;
 	if (!(ah = _alloc_init(vg->cmd, vg->cmd->mem, segtype, alloc, approx_alloc,
-			       new_extents, mirrors, stripes, log_count,
+			       lv ? lv->le_count : 0, extents, mirrors, stripes, log_count,
 			       vg->extent_size, region_size,
 			       parallel_areas)))
 		return_NULL;
@@ -3617,11 +3624,9 @@ int lv_extend(struct logical_volume *lv,
 				    allocatable_pvs, alloc, approx_alloc, NULL)))
 		return_0;
 
-	if (ah->approx_alloc) {
-		extents = ah->new_extents;
-		if (segtype_is_raid(segtype))
-			extents -= ah->log_len * ah->area_multiple;
-	}
+	extents = ah->new_extents;
+	if (segtype_is_raid(segtype))
+		extents -= ah->log_len * ah->area_multiple;
 
 	if (segtype_is_thin_pool(segtype) || segtype_is_cache_pool(segtype)) {
 		if (lv->le_count) {
@@ -3654,7 +3659,7 @@ int lv_extend(struct logical_volume *lv,
 			goto out;
 		}
 
-		if (!(r = _lv_extend_layered_lv(ah, lv, extents, 0,
+		if (!(r = _lv_extend_layered_lv(ah, lv, extents - lv->le_count, 0,
 						stripes, stripe_size)))
 			goto_out;
 
@@ -3852,7 +3857,6 @@ int for_each_sub_lv(struct logical_volume *lv,
 	return 1;
 }
 
-
 /*
  * Core of LV renaming routine.
  * VG must be locked by caller.
@@ -4350,45 +4354,39 @@ static int _lvresize_adjust_size(struct cmd_context *cmd, struct logical_volume
 		lp->extents = lp->size / vg->extent_size;
 	}
 
-
 	return 1;
 }
 
-static int _lvresize_adjust_extents(struct cmd_context *cmd, struct logical_volume *lv, 
-				    struct lvresize_params *lp, struct dm_list *pvh)
+/*
+ * If percent options were used, convert them into actual numbers of extents.
+ */
+static int _lvresize_extents_from_percent(struct logical_volume *lv, struct lvresize_params *lp,
+					  struct dm_list *pvh)
 {
 	struct volume_group *vg = lv->vg;
 	uint32_t pv_extent_count;
-	uint32_t extents_used, extents;
-	uint32_t seg_stripes = 0, seg_stripesize = 0, seg_size;
-	uint32_t seg_mirrors = 0;
-	struct lv_segment *seg, *uninitialized_var(mirr_seg);
-	uint32_t sz, str;
-	uint32_t seg_extents;
-	uint32_t stripesize_extents;
-	uint32_t size_rest;
+	uint32_t old_extents = lp->extents;
 
-	/* If percent options were used, convert them into actual numbers of extents */
 	switch (lp->percent) {
 		case PERCENT_VG:
-			extents = percent_of_extents(lp->extents, vg->extent_count,
+			lp->extents = percent_of_extents(lp->extents, vg->extent_count,
 							 (lp->sign != SIGN_MINUS));
 			break;
 		case PERCENT_FREE:
-			extents = percent_of_extents(lp->extents, vg->free_count,
+			lp->extents = percent_of_extents(lp->extents, vg->free_count,
 							 (lp->sign != SIGN_MINUS));
 			break;
 		case PERCENT_LV:
-			extents = percent_of_extents(lp->extents, lv->le_count,
+			lp->extents = percent_of_extents(lp->extents, lv->le_count,
 							 (lp->sign != SIGN_MINUS));
 			break;
 		case PERCENT_PVS:
 			if (lp->argc) {
 				pv_extent_count = pv_list_extents_free(pvh);
-				extents = percent_of_extents(lp->extents, pv_extent_count,
+				lp->extents = percent_of_extents(lp->extents, pv_extent_count,
 								 (lp->sign != SIGN_MINUS));
 			} else
-				extents = percent_of_extents(lp->extents, vg->extent_count,
+				lp->extents = percent_of_extents(lp->extents, vg->extent_count,
 								 (lp->sign != SIGN_MINUS));
 			break;
 		case PERCENT_ORIGIN:
@@ -4396,186 +4394,228 @@ static int _lvresize_adjust_extents(struct cmd_context *cmd, struct logical_volu
 				log_error("Specified LV does not have an origin LV.");
 				return 0;
 			}
-			extents = percent_of_extents(lp->extents, origin_from_cow(lv)->le_count,
+			lp->extents = percent_of_extents(lp->extents, origin_from_cow(lv)->le_count,
 							 (lp->sign != SIGN_MINUS));
 			break;
 		case PERCENT_NONE:
-			extents = lp->extents;
-			break;
+			return 1;	/* Nothing to do */
 		default:
 			log_error(INTERNAL_ERROR "Unsupported percent type %u.", lp->percent);
 			return 0;
 	}
 
-	if (lp->percent != PERCENT_NONE) {
-		log_verbose("Converted %" PRIu32 "%%%s into %" PRIu32 " extents.", lp->extents, get_percent_string(lp->percent), extents);
-		lp->extents = extents;
-		if (lp->sign == SIGN_NONE && (lp->percent != PERCENT_LV && lp->percent != PERCENT_ORIGIN))
-			lp->approx_alloc = 1;
-		/* FIXME Adjust for parallel areas here before processing relative allocations */
-		if (lp->sign == SIGN_PLUS && lp->percent == PERCENT_FREE)
-			lp->approx_alloc = 1;
-	}
+	if (lp->percent == PERCENT_VG || lp->percent == PERCENT_FREE || lp->percent == PERCENT_PVS)
+		lp->extents_are_pes = 1;
 
-	if (lp->sign == SIGN_PLUS) {
-		if (lp->extents >= (MAX_EXTENT_COUNT - lv->le_count)) {
-			log_error("Unable to extend %s by %u extents, exceeds limit (%u).",
-				  lp->lv_name, lv->le_count, MAX_EXTENT_COUNT);
-			return 0;
-		}
-		lp->extents += lv->le_count;
-		if (lv_is_cow(lv)) {
-			extents_used = cow_max_extents(origin_from_cow(lv), find_snapshot(lv)->chunk_size);
-			if (extents_used < lp->extents) {
-				log_print_unless_silent("Reached maximum COW size %s.",
-							display_size(vg->cmd, (uint64_t) vg->extent_size * extents_used));
-				lp->extents = extents_used;
-				if (lp->extents == lv->le_count) {
-					/* Signal that normal resizing is not required */
-					lp->sizeargs = 0;
-					return 1;
-				}
-			}
-		}
-	} else if (lp->sign == SIGN_MINUS) {
-		if (lp->extents >= lv->le_count) {
-			log_error("Unable to reduce %s below 1 extent",
-				  lp->lv_name);
-			return 0;
-		}
+	if (lp->sign == SIGN_NONE && (lp->percent == PERCENT_VG || lp->percent == PERCENT_FREE || lp->percent == PERCENT_PVS))
+		lp->approx_alloc = 1;
 
-		lp->extents = lv->le_count - lp->extents;
-	}
+	if (lp->sign == SIGN_PLUS && lp->percent == PERCENT_FREE)
+		lp->approx_alloc = 1;
 
-	if (!lp->extents) {
-		log_error("New size of 0 not permitted");
-		return 0;
-	}
+	log_verbose("Converted %" PRIu32 "%%%s into %s%" PRIu32 " %s extents.", old_extents, get_percent_string(lp->percent),
+		    lp->approx_alloc ? "at most " : "", lp->extents, lp->extents_are_pes ? "physical" : "logical");
 
-	if (lp->extents == lv->le_count) {
-		if (lp->poolmetadatasize || lp->ac_policy) {
-			/* Signal that normal resizing is not required */
-			lp->sizeargs = 0;
-			return 1;
-		}
+	return 1;
+}
 
-		if (!lp->resizefs) {
-			log_error("New size (%d extents) matches existing size "
-				  "(%d extents)", lp->extents, lv->le_count);
-			return 0;
+static int _add_pes(struct logical_volume *lv, void *data)
+{
+	uint32_t *pe_total = data;
+	struct lv_segment *seg;
+	uint32_t s;
+
+	dm_list_iterate_items(seg, &lv->segments) {
+		for (s = 0; s < seg->area_count; s++) {
+			if (seg_type(seg, s) != AREA_PV)
+				continue;
+
+			*pe_total += seg_pvseg(seg, s)->len;
 		}
-		lp->resize = LV_EXTEND; /* lets pretend zero size extension */
 	}
 
-	seg_size = lp->extents - lv->le_count;
+	return 1;
+}
+
+static uint32_t _lv_pe_count(struct logical_volume *lv)
+{
+	uint32_t pe_total = 0;
+
+	/* Top-level LV first */
+	if (!_add_pes(lv, &pe_total))
+		stack;
+
+	/* Any sub-LVs */
+	if (!for_each_sub_lv(lv, _add_pes, &pe_total))
+		stack;
+
+	return pe_total;
+}
+
+/* FIXME Avoid having variables like lp->extents mean different things at different places */
+static int _lvresize_adjust_extents(struct cmd_context *cmd, struct logical_volume *lv, 
+				    struct lvresize_params *lp, struct dm_list *pvh)
+{
+	struct volume_group *vg = lv->vg;
+	uint32_t logical_extents_used = 0;
+	uint32_t physical_extents_used = 0;
+	uint32_t seg_stripes = 0, seg_stripesize = 0;
+	uint32_t seg_mirrors = 0;
+	struct lv_segment *seg, *mirr_seg;
+	uint32_t sz, str;
+	uint32_t seg_logical_extents;
+	uint32_t seg_physical_extents;
+	uint32_t area_multiple;
+	uint32_t stripesize_extents;
+	uint32_t size_rest;
+	uint32_t existing_logical_extents = lv->le_count;
+	uint32_t existing_physical_extents, saved_existing_physical_extents;
+	uint32_t seg_size = 0;
+	uint32_t new_extents;
+	int reducing = 0;
+
+	if (!_lvresize_extents_from_percent(lv, lp, pvh))
+		return_0;
 
 	if (lv_is_thin_pool(lv))
-		/* Now prepare args like we would be resizing _tdata layer */
+		/* Manipulate the thin data layer underneath */
 		lv = seg_lv(first_seg(lv), 0);
 
 	/* Use segment type of last segment */
 	lp->segtype = last_seg(lv)->segtype;
 
 	/* FIXME Support LVs with mixed segment types */
-	if (lp->segtype != get_segtype_from_string(cmd, (lp->ac_type)?lp->ac_type:lp->segtype->name)) {
+	if (lp->segtype != get_segtype_from_string(cmd, lp->ac_type ? : lp->segtype->name)) {
 		log_error("VolumeType does not match (%s)", lp->segtype->name);
 		return 0;
 	}
 
-	/* If extending, find mirrors of last segment */
-	if ((lp->extents > lv->le_count)) {
-		/*
-		 * Has the user specified that they would like the additional
-		 * extents of a mirror not to have an initial sync?
-		 */
-		if (seg_is_mirrored(first_seg(lv)) && lp->ac_no_sync)
-			lv->status |= LV_NOTSYNCED;
+	/* For virtual devices, just pretend the physical size matches. */
+	existing_physical_extents = saved_existing_physical_extents = _lv_pe_count(lv);
+	if (!existing_physical_extents) {
+		existing_physical_extents = lv->le_count;
+		lp->extents_are_pes = 0;
+	}
 
-		dm_list_iterate_back_items(mirr_seg, &lv->segments) {
-			seg_mirrors = seg_is_mirrored(mirr_seg) ?
-				lv_mirror_count(mirr_seg->lv) : 0;
-			break;
-		}
+	/* Initial decision on whether we are extending or reducing */
+	if (lp->sign == SIGN_MINUS ||
+	    (lp->sign == SIGN_NONE && 
+	     ((lp->extents_are_pes && lp->extents < existing_physical_extents) ||
+	      (!lp->extents_are_pes && lp->extents < existing_logical_extents))))
+		reducing = 1;
+
+	/* If extending, find properties of last segment */
+	if (!reducing) {
+		mirr_seg = last_seg(lv);
+		seg_mirrors = seg_is_mirrored(mirr_seg) ? lv_mirror_count(mirr_seg->lv) : 0;
 
 		if (!lp->ac_mirrors && seg_mirrors) {
-			log_print_unless_silent("Extending %" PRIu32 " mirror images.",
-						seg_mirrors);
+			log_print_unless_silent("Extending %" PRIu32 " mirror images.", seg_mirrors);
 			lp->mirrors = seg_mirrors;
 		}
+
 		if ((lp->ac_mirrors || seg_mirrors) &&
 		    (lp->mirrors != seg_mirrors)) {
 			log_error("Cannot vary number of mirrors in LV yet.");
 			return 0;
 		}
 
-		if (seg_mirrors && !strcmp(mirr_seg->segtype->name, "raid10")) {
+		if (!strcmp(mirr_seg->segtype->name, "raid10")) {
+			/* FIXME Warn if command line values are being overridden? */
 			lp->stripes = mirr_seg->area_count / seg_mirrors;
 			lp->stripe_size = mirr_seg->stripe_size;
-		}
-	}
-
-	/* If extending, find stripes, stripesize & size of last segment */
-	if ((lp->extents > lv->le_count) &&
-	    !(lp->stripes == 1 || (lp->stripes > 1 && lp->stripe_size)) &&
-	    strcmp(mirr_seg->segtype->name, "raid10")) {
-		/* FIXME Don't assume mirror seg will always be AREA_LV */
-		/* FIXME We will need to support resize for metadata LV as well,
-		 *       and data LV could be any type (i.e. mirror)) */
-		dm_list_iterate_items(seg, seg_mirrors ? &seg_lv(mirr_seg, 0)->segments :
-				      lv_is_thin_pool(lv) ? &seg_lv(first_seg(lv), 0)->segments : &lv->segments) {
-			/* Allow through "striped" and RAID 4/5/6/10 */
-			if (!seg_is_striped(seg) &&
-			    (!seg_is_raid(seg) || seg_is_mirrored(seg)) &&
-			    strcmp(seg->segtype->name, "raid10"))
-				continue;
-
-			sz = seg->stripe_size;
-			str = seg->area_count - lp->segtype->parity_devs;
-
-			if ((seg_stripesize && seg_stripesize != sz &&
-			     sz && !lp->stripe_size) ||
-			    (seg_stripes && seg_stripes != str && !lp->stripes)) {
-				log_error("Please specify number of "
-					  "stripes (-i) and stripesize (-I)");
+		} else if (!(lp->stripes == 1 || (lp->stripes > 1 && lp->stripe_size))) {
+			/* If extending, find stripes, stripesize & size of last segment */
+			/* FIXME Don't assume mirror seg will always be AREA_LV */
+			/* FIXME We will need to support resize for metadata LV as well,
+			 *       and data LV could be any type (i.e. mirror)) */
+			dm_list_iterate_items(seg, seg_mirrors ? &seg_lv(mirr_seg, 0)->segments : &lv->segments) {
+				/* Allow through "striped" and RAID 4/5/6/10 */
+				if (!seg_is_striped(seg) &&
+				    (!seg_is_raid(seg) || seg_is_mirrored(seg)) &&
+				    strcmp(seg->segtype->name, "raid10"))
+					continue;
+	
+				sz = seg->stripe_size;
+				str = seg->area_count - lp->segtype->parity_devs;
+	
+				if ((seg_stripesize && seg_stripesize != sz &&
+				     sz && !lp->stripe_size) ||
+				    (seg_stripes && seg_stripes != str && !lp->stripes)) {
+					log_error("Please specify number of "
+						  "stripes (-i) and stripesize (-I)");
+					return 0;
+				}
+	
+				seg_stripesize = sz;
+				seg_stripes = str;
+			}
+	
+			if (!lp->stripes)
+				lp->stripes = seg_stripes;
+			else if (seg_is_raid(first_seg(lv)) &&
+				 (lp->stripes != seg_stripes)) {
+				log_error("Unable to extend \"%s\" segment type with different number of stripes.",
+					  first_seg(lv)->segtype->ops->name(first_seg(lv)));
 				return 0;
 			}
-
-			seg_stripesize = sz;
-			seg_stripes = str;
+	
+			if (!lp->stripe_size && lp->stripes > 1) {
+				if (seg_stripesize) {
+					log_print_unless_silent("Using stripesize of last segment %s",
+								display_size(cmd, (uint64_t) seg_stripesize));
+					lp->stripe_size = seg_stripesize;
+				} else {
+					lp->stripe_size =
+						find_config_tree_int(cmd, metadata_stripesize_CFG, NULL) * 2;
+					log_print_unless_silent("Using default stripesize %s",
+								display_size(cmd, (uint64_t) lp->stripe_size));
+				}
+			}
 		}
 
-		if (!lp->stripes)
-			lp->stripes = seg_stripes;
-		else if (seg_is_raid(first_seg(lv)) &&
-			 (lp->stripes != seg_stripes)) {
-			log_error("Unable to extend \"%s\" segment type with different number of stripes.", first_seg(lv)->segtype->ops->name(first_seg(lv)));
-			return 0;
-		}
+		/* Determine the amount to extend by */
+		if (lp->sign == SIGN_PLUS)
+			seg_size = lp->extents;
+		else if (lp->extents_are_pes)
+			seg_size = lp->extents - existing_physical_extents;
+		else
+			seg_size = lp->extents - existing_logical_extents;
 
-		if (!lp->stripe_size && lp->stripes > 1) {
-			if (seg_stripesize) {
-				log_print_unless_silent("Using stripesize of last segment %s",
-							display_size(cmd, (uint64_t) seg_stripesize));
-				lp->stripe_size = seg_stripesize;
-			} else {
-				lp->stripe_size =
-					find_config_tree_int(cmd, metadata_stripesize_CFG, NULL) * 2;
-				log_print_unless_silent("Using default stripesize %s",
-							display_size(cmd, (uint64_t) lp->stripe_size));
-			}
+		/* Convert PEs to LEs */
+		if (lp->extents_are_pes && !seg_is_striped(last_seg(lv)) && !seg_is_virtual(last_seg(lv))) {
+			area_multiple = _calc_area_multiple(last_seg(lv)->segtype, last_seg(lv)->area_count, 0);
+			seg_size = seg_size * area_multiple / (last_seg(lv)->area_count - last_seg(lv)->segtype->parity_devs);
+			seg_size = (seg_size / area_multiple) * area_multiple;
 		}
 	}
 
 	/* If reducing, find stripes, stripesize & size of last segment */
-	if (lp->extents < lv->le_count) {
-		extents_used = 0;
-
+	if (reducing) {
 		if (lp->stripes || lp->stripe_size || lp->mirrors)
 			log_error("Ignoring stripes, stripesize and mirrors "
 				  "arguments when reducing");
 
+		if (lp->sign == SIGN_MINUS) 
+			if (lp->extents_are_pes) {
+				if (lp->extents >= existing_physical_extents) {
+					log_error("Unable to reduce %s below 1 extent.", lp->lv_name);
+					return_0;
+				}
+				new_extents = existing_physical_extents - lp->extents;
+			} else {
+				new_extents = existing_logical_extents - lp->extents;
+				if (lp->extents >= existing_logical_extents) {
+					log_error("Unable to reduce %s below 1 extent.", lp->lv_name);
+					return_0;
+				}
+			}
+		else
+			new_extents = lp->extents;
+
 		dm_list_iterate_items(seg, &lv->segments) {
-			seg_extents = seg->len;
+			seg_logical_extents = seg->len;
+			seg_physical_extents = seg->area_len * seg->area_count;	/* FIXME Also metadata, cow etc. */
 
 			/* Check for underlying stripe sizes */
 			seg_stripes = lvseg_get_stripes(seg, &seg_stripesize);
@@ -4585,13 +4625,25 @@ static int _lvresize_adjust_extents(struct cmd_context *cmd, struct logical_volu
 			else
 				seg_mirrors = 0;
 
-			if (lp->extents <= extents_used + seg_extents)
+			/* Have we reached the final segment of the new LV? */
+			if (lp->extents_are_pes) {
+				if (new_extents <= physical_extents_used + seg_physical_extents) {
+					seg_size = new_extents - physical_extents_used;
+					if (seg_mirrors)
+						seg_size /= seg_mirrors;
+					lp->extents = logical_extents_used + seg_size;
+					break;
+				}
+			} else if (new_extents <= logical_extents_used + seg_logical_extents) {
+				seg_size = new_extents - logical_extents_used;
+				lp->extents = new_extents;
 				break;
+			}
 
-			extents_used += seg_extents;
+			logical_extents_used += seg_logical_extents;
+			physical_extents_used += seg_physical_extents;
 		}
 
-		seg_size = lp->extents - extents_used;
 		lp->stripe_size = seg_stripesize;
 		lp->stripes = seg_stripes;
 		lp->mirrors = seg_mirrors;
@@ -4602,6 +4654,55 @@ static int _lvresize_adjust_extents(struct cmd_context *cmd, struct logical_volu
 		return 0;
 	}
 
+	if (!reducing) {
+		if (seg_size >= (MAX_EXTENT_COUNT - existing_logical_extents)) {
+			log_error("Unable to extend %s by %u logical extents: exceeds limit (%u).",
+				  lp->lv_name, seg_size, MAX_EXTENT_COUNT);
+			return 0;
+		}
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
+	} 
+
+	/* At this point, lp->extents should hold the correct NEW logical size required. */
+
+	if (!lp->extents) {
+		log_error("New size of 0 not permitted");
+		return 0;
+	}
+
+	if (lp->extents == existing_logical_extents) {
+		if (lp->poolmetadatasize || lp->ac_policy) {
+			/* Signal that normal resizing is not required */
+			lp->sizeargs = 0;
+			return 1;
+		}
+
+		if (!lp->resizefs) {
+			log_error("New size (%d extents) matches existing size "
+				  "(%d extents)", lp->extents, existing_logical_extents);
+			return 0;
+		}
+		lp->resize = LV_EXTEND; /* lets pretend zero size extension */
+	}
+
+	/* Perform any rounding to produce complete stripes. */
 	if (lp->stripes > 1) {
 		if (lp->stripe_size < STRIPE_SIZE_MIN) {
 			log_error("Invalid stripe size %s",
@@ -4615,9 +4716,9 @@ static int _lvresize_adjust_extents(struct cmd_context *cmd, struct logical_volu
 		size_rest = seg_size % (lp->stripes * stripesize_extents);
 		/* Round toward the original size. */
 		if (size_rest &&
-		    ((lp->extents < lv->le_count) ||
+		    ((lp->extents < existing_logical_extents) ||
 		     !lp->percent ||
-		     (vg->free_count >= (lp->extents - lv->le_count - size_rest +
+		     (vg->free_count >= (lp->extents - existing_logical_extents - size_rest +
 					 (lp->stripes * stripesize_extents))))) {
 			log_print_unless_silent("Rounding size (%d extents) up to stripe "
 						"boundary size for segment (%d extents)",
@@ -4633,31 +4734,44 @@ static int _lvresize_adjust_extents(struct cmd_context *cmd, struct logical_volu
 		}
 	}
 
-	if (lp->extents < lv->le_count) {
+	/* Final sanity checking */
+	if (lp->extents < existing_logical_extents) {
 		if (lp->resize == LV_EXTEND) {
 			log_error("New size given (%d extents) not larger "
 				  "than existing size (%d extents)",
-				  lp->extents, lv->le_count);
+				  lp->extents, existing_logical_extents);
 			return 0;
 		}
 		lp->resize = LV_REDUCE;
-	} else if (lp->extents > lv->le_count) {
+	} else if (lp->extents > existing_logical_extents) {
 		if (lp->resize == LV_REDUCE) {
 			log_error("New size given (%d extents) not less than "
 				  "existing size (%d extents)", lp->extents,
-				  lv->le_count);
+				  existing_logical_extents);
 			return 0;
 		}
 		lp->resize = LV_EXTEND;
-	} else if ((lp->extents == lv->le_count) && !lp->ac_policy) {
+	} else if ((lp->extents == existing_logical_extents) && !lp->ac_policy) {
 		if (!lp->resizefs) {
 			log_error("New size (%d extents) matches existing size "
-				  "(%d extents)", lp->extents, lv->le_count);
+				  "(%d extents)", lp->extents, existing_logical_extents);
 			return 0;
 		}
 		lp->resize = LV_EXTEND;
 	}
 
+	/*
+	 * Has the user specified that they would like the additional
+	 * extents of a mirror not to have an initial sync?
+	 */
+	if ((lp->extents > existing_logical_extents)) {
+		if (seg_is_mirrored(first_seg(lv)) && lp->ac_no_sync)
+			lv->status |= LV_NOTSYNCED;
+	}
+
+	log_debug("New size for %s: %" PRIu32 ". Existing logical extents: %" PRIu32 " / physical extents: %" PRIu32 ".",
+		  display_lvname(lv), lp->extents, existing_logical_extents, saved_existing_physical_extents);
+
 	return 1;
 }
 
@@ -4779,14 +4893,14 @@ static struct logical_volume *_lvresize_volume(struct cmd_context *cmd,
 		return_NULL;
 
 	if (old_extents == lv->le_count)
-		log_print_unless_silent("Size of logical volume %s unchanged from %s.",
+		log_print_unless_silent("Size of logical volume %s unchanged from %s (%" PRIu32 " extents).",
 					display_lvname(lv),
-					display_size(cmd, (uint64_t) old_extents * vg->extent_size));
+					display_size(cmd, (uint64_t) old_extents * vg->extent_size), old_extents);
 	else
-		log_print_unless_silent("Size of logical volume %s changed from %s to %s.",
+		log_print_unless_silent("Size of logical volume %s changed from %s (%" PRIu32 " extents) to %s (%" PRIu32 " extents).",
 					display_lvname(lv),
-					display_size(cmd, (uint64_t) old_extents * vg->extent_size),
-					display_size(cmd, (uint64_t) lv->le_count * vg->extent_size));
+					display_size(cmd, (uint64_t) old_extents * vg->extent_size), old_extents,
+					display_size(cmd, (uint64_t) lv->le_count * vg->extent_size), lv->le_count);
 
 	if (lock_lv) {
 		/* Update thin pool segment from the layered LV */
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 61bb140..ff24911 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -494,6 +494,7 @@ struct lvresize_params {
 	sign_t poolmetadatasign;
 	uint32_t poolmetadataextents;
 	int approx_alloc;
+	int extents_are_pes;	/* Is 'extents' counting PEs or LEs? */
 	percent_type_t percent;
 
 	enum {


