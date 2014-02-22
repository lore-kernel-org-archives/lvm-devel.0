From: Alasdair Kergon <agk@fedoraproject.org>
Date: Sat, 22 Feb 2014 00:26:46 +0000 (UTC)
Subject: master - allocation: misc fixes for percent/raid rounding
Message-ID: <20140222002646.BC1D7603F7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=13c3f53f55288fcd2dbab1cfc0dd30380521e1cf
Commit:        13c3f53f55288fcd2dbab1cfc0dd30380521e1cf
Parent:        294671fa629fb1d2e3580a411cc3ada3acce6626
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Sat Feb 22 00:26:01 2014 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Sat Feb 22 00:26:01 2014 +0000

allocation: misc fixes for percent/raid rounding

Several fixes for the recent changes that treat allocation percentages
as upper limits.
Improve messages to make it easier to see what is happening.
Fix some cases that failed with errors when they didn't need to.
Fix crashes when first_seg() returns NULL.
Remove a couple of log_errors that were actually debugging messages.
---
 lib/display/display.c     |    7 +++
 lib/display/display.h     |    2 +
 lib/metadata/lv.c         |   19 ++++++---
 lib/metadata/lv_manip.c   |   97 ++++++++++++++++++++++++++++-----------------
 lib/metadata/thin_manip.c |    4 +-
 tools/lvcreate.c          |   19 ++++++---
 6 files changed, 96 insertions(+), 52 deletions(-)

diff --git a/lib/display/display.c b/lib/display/display.c
index 9b4f828..66acb88 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -182,6 +182,13 @@ alloc_policy_t get_alloc_from_string(const char *str)
 	return ALLOC_INVALID;
 }
 
+static const char *_percent_types[7] = { "NONE", "VGS", "FREE", "LVS", "PVS", "ORIGIN" };
+
+const char *get_percent_string(percent_type_t def)
+{
+	return _percent_types[def];
+}
+
 #define BASE_UNKNOWN 0
 #define BASE_SHARED 1
 #define BASE_1024 8
diff --git a/lib/display/display.h b/lib/display/display.h
index c58df45..41fba03 100644
--- a/lib/display/display.h
+++ b/lib/display/display.h
@@ -64,6 +64,8 @@ const char *get_alloc_string(alloc_policy_t alloc);
 char alloc_policy_char(alloc_policy_t alloc);
 alloc_policy_t get_alloc_from_string(const char *str);
 
+const char *get_percent_string(percent_type_t def);
+
 char yes_no_prompt(const char *prompt, ...) __attribute__ ((format(printf, 1, 2)));
 
 #endif
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 2d78dec..2f2b7cb 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -393,9 +393,13 @@ uint64_t lv_size(const struct logical_volume *lv)
 static int _lv_mimage_in_sync(const struct logical_volume *lv)
 {
 	percent_t percent;
-	struct lv_segment *mirror_seg = find_mirror_seg(first_seg(lv));
+	struct lv_segment *seg = first_seg(lv);
+	struct lv_segment *mirror_seg;
 
-	if (!(lv->status & MIRROR_IMAGE) || !mirror_seg)
+	if (seg)
+		mirror_seg = find_mirror_seg(seg);
+
+	if (!(lv->status & MIRROR_IMAGE) || !seg || !mirror_seg)
 		return_0;
 
 	if (!lv_mirror_percent(lv->vg->cmd, mirror_seg->lv, 0, &percent,
@@ -410,7 +414,7 @@ static int _lv_raid_image_in_sync(const struct logical_volume *lv)
 	unsigned s;
 	percent_t percent;
 	char *raid_health;
-	struct lv_segment *raid_seg;
+	struct lv_segment *seg, *raid_seg = NULL;
 
 	/*
 	 * If the LV is not active locally,
@@ -424,7 +428,8 @@ static int _lv_raid_image_in_sync(const struct logical_volume *lv)
 		return 0;
 	}
 
-	raid_seg = get_only_segment_using_this_lv(first_seg(lv)->lv);
+	if ((seg = first_seg(lv)))
+		raid_seg = get_only_segment_using_this_lv(seg->lv);
 	if (!raid_seg) {
 		log_error("Failed to find RAID segment for %s", lv->name);
 		return 0;
@@ -472,7 +477,7 @@ static int _lv_raid_healthy(const struct logical_volume *lv)
 {
 	unsigned s;
 	char *raid_health;
-	struct lv_segment *raid_seg;
+	struct lv_segment *seg, *raid_seg = NULL;
 
 	/*
 	 * If the LV is not active locally,
@@ -488,8 +493,8 @@ static int _lv_raid_healthy(const struct logical_volume *lv)
 
 	if (lv->status & RAID)
 		raid_seg = first_seg(lv);
-	else
-		raid_seg = get_only_segment_using_this_lv(first_seg(lv)->lv);
+	else if ((seg = first_seg(lv)))
+		raid_seg = get_only_segment_using_this_lv(seg->lv);
 
 	if (!raid_seg) {
 		log_error("Failed to find RAID segment for %s", lv->name);
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 2b1cdcc..e25dd17 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -346,6 +346,11 @@ struct lv_segment *get_only_segment_using_this_lv(struct logical_volume *lv)
 {
 	struct seg_list *sl;
 
+	if (!lv) {
+		log_error(INTERNAL_ERROR "get_only_segment_using_this_lv() called with NULL LV.");
+		return NULL;
+	}
+
 	if (dm_list_size(&lv->segs_using_this_lv) != 1) {
 		log_error("%s is expected to have only one segment using it, "
 			  "while it has %d", lv->name,
@@ -943,6 +948,7 @@ struct alloc_handle {
 	 * and data device allocated together.
 	 */
 	unsigned alloc_and_split_meta;
+	unsigned split_metadata_is_allocated;	/* Metadata has been allocated */
 
 	const struct dm_config_node *cling_tag_list_cn;
 
@@ -1149,11 +1155,17 @@ static struct alloc_handle *_alloc_init(struct cmd_context *cmd,
 			 * We need 'log_len' extents for each
 			 * RAID device's metadata_area
 			 */
-			ah->new_extents += (ah->log_len * ah->area_multiple);
+			if (!approx_alloc)
+				ah->new_extents += (ah->log_len * ah->area_multiple);
 		} else {
 			ah->log_area_count = 0;
 			ah->log_len = 0;
 		}
+		if (approx_alloc) {
+			ah->new_extents = ah->new_extents * ah->area_multiple / (ah->area_count + ah->parity_count);
+			ah->new_extents = (ah->new_extents / ah->area_multiple) * ah->area_multiple;
+			log_debug("Adjusted allocation request to %" PRIu32 " data extents.", ah->new_extents);
+		}
 	} else if (segtype_is_thin_pool(segtype)) {
 		/*
 		 * thin_pool uses ah->region_size to
@@ -1177,13 +1189,17 @@ static struct alloc_handle *_alloc_init(struct cmd_context *cmd,
 			find_config_tree_bool(cmd, allocation_cache_pool_metadata_require_separate_pvs_CFG, NULL);
 		if (!ah->mirror_logs_separate) {
 			ah->alloc_and_split_meta = 1;
-			ah->new_extents += ah->log_len;
+			if (!approx_alloc)
+				ah->new_extents += ah->log_len;
 		}
 	} else {
 		ah->log_area_count = metadata_area_count;
 		ah->log_len = !metadata_area_count ? 0 :
 			mirror_log_extents(ah->region_size, extent_size,
 					   new_extents / ah->area_multiple);
+		ah->new_extents = ah->new_extents * ah->area_multiple / ah->area_count;
+		ah->new_extents = (ah->new_extents / ah->area_multiple) * ah->area_multiple;
+		log_debug("Adjusted allocation request to %" PRIu32 " data extents.", ah->new_extents);
 	}
 
 	for (s = 0; s < alloc_count; s++)
@@ -1196,6 +1212,7 @@ static struct alloc_handle *_alloc_init(struct cmd_context *cmd,
 	ah->maximise_cling = find_config_tree_bool(cmd, allocation_maximise_cling_CFG, NULL);
 
 	ah->approx_alloc = approx_alloc;
+
 	return ah;
 }
 
@@ -1216,18 +1233,10 @@ static int _sufficient_pes_free(struct alloc_handle *ah, struct dm_list *pvms,
 	uint32_t free_pes = pv_maps_size(pvms);
 
 	if (total_extents_needed > free_pes) {
-		if (!ah->approx_alloc) {
-			log_error("Insufficient free space: %" PRIu32
-				  " extents needed,"
-				  " but only %" PRIu32 " available",
-				  total_extents_needed, free_pes);
-
-			return 0;
-		}
-		log_verbose("Insufficient free space: %" PRIu32
-			    " extents needed, but only %" PRIu32
-			    " available: amount will be reduced",
-			    total_extents_needed, free_pes);
+		log_error("Insufficient free space: %" PRIu32 " extents needed,"
+			  " but only %" PRIu32 " available",
+			  total_extents_needed, free_pes);
+		return 0;
 	}
 
 	return 1;
@@ -1429,7 +1438,7 @@ static int _alloc_parallel_area(struct alloc_handle *ah, uint32_t max_to_allocat
 		if (area_len > alloc_state->areas[s].used)
 			area_len = alloc_state->areas[s].used;
 
-	len = (ah->alloc_and_split_meta) ? total_area_count * 2 : total_area_count;
+	len = (ah->alloc_and_split_meta && !ah->split_metadata_is_allocated) ? total_area_count * 2 : total_area_count;
 	len *= sizeof(*aa);
 	if (!(aa = dm_pool_alloc(ah->mem, len))) {
 		log_error("alloced_area allocation failed");
@@ -1449,7 +1458,7 @@ static int _alloc_parallel_area(struct alloc_handle *ah, uint32_t max_to_allocat
 		}
 
 		pva = alloc_state->areas[s + ix_log_skip].pva;
-		if (ah->alloc_and_split_meta) {
+		if (ah->alloc_and_split_meta && !ah->split_metadata_is_allocated) {
 			/*
 			 * The metadata area goes at the front of the allocated
 			 * space for now, but could easily go at the end (or
@@ -1475,7 +1484,7 @@ static int _alloc_parallel_area(struct alloc_handle *ah, uint32_t max_to_allocat
 			dm_list_add(&ah->alloced_areas[s], &aa[s].list);
 			s -= ah->area_count + ah->parity_count;
 		}
-		aa[s].len = (ah->alloc_and_split_meta) ? len - ah->log_len : len;
+		aa[s].len = (ah->alloc_and_split_meta && !ah->split_metadata_is_allocated) ? len - ah->log_len : len;
 		/* Skip empty allocations */
 		if (!aa[s].len)
 			continue;
@@ -1493,7 +1502,8 @@ static int _alloc_parallel_area(struct alloc_handle *ah, uint32_t max_to_allocat
 	}
 
 	/* Only need to alloc metadata from the first batch */
-	ah->alloc_and_split_meta = 0;
+	if (ah->alloc_and_split_meta)
+		ah->split_metadata_is_allocated = 1;
 
 	ah->total_area_len += area_len;
 
@@ -1995,7 +2005,8 @@ static void _reset_unreserved(struct dm_list *pvms)
 }
 
 static void _report_needed_allocation_space(struct alloc_handle *ah,
-					    struct alloc_state *alloc_state)
+					    struct alloc_state *alloc_state,
+					    struct dm_list *pvms)
 {
 	const char *metadata_type;
 	uint32_t parallel_areas_count, parallel_area_size;
@@ -2003,7 +2014,7 @@ static void _report_needed_allocation_space(struct alloc_handle *ah,
 
 	parallel_area_size = ah->new_extents - alloc_state->allocated;
 	parallel_area_size /= ah->area_multiple;
-	parallel_area_size -= (ah->alloc_and_split_meta) ? ah->log_len : 0;
+	parallel_area_size -= (ah->alloc_and_split_meta && !ah->split_metadata_is_allocated) ? ah->log_len : 0;
 
 	parallel_areas_count = ah->area_count + ah->parity_count;
 
@@ -2011,14 +2022,16 @@ static void _report_needed_allocation_space(struct alloc_handle *ah,
 	if (ah->alloc_and_split_meta) {
 		metadata_type = "metadata area";
 		metadata_count = parallel_areas_count;
+		if (ah->split_metadata_is_allocated)
+			metadata_size = 0;
 	} else {
 		metadata_type = "mirror log";
 		metadata_count = alloc_state->log_area_count_still_needed;
 	}
 
-	log_debug_alloc("Still need %s%" PRIu32 " total extents:",
+	log_debug_alloc("Still need %s%" PRIu32 " total extents from %" PRIu32 " remaining:",
 			ah->approx_alloc ? "up to " : "",
-			parallel_area_size * parallel_areas_count + metadata_size * metadata_count);
+			parallel_area_size * parallel_areas_count + metadata_size * metadata_count, pv_maps_size(pvms));
 	log_debug_alloc("  %" PRIu32 " (%" PRIu32 " data/%" PRIu32
 			" parity) parallel areas of %" PRIu32 " extents each",
 			parallel_areas_count, ah->area_count, ah->parity_count, parallel_area_size);
@@ -2064,7 +2077,7 @@ static int _find_some_parallel_space(struct alloc_handle *ah, const struct alloc
 	_clear_areas(alloc_state);
 	_reset_unreserved(pvms);
 
-	_report_needed_allocation_space(ah, alloc_state);
+	_report_needed_allocation_space(ah, alloc_state, pvms);
 
 	/* ix holds the number of areas found on other PVs */
 	do {
@@ -2289,11 +2302,11 @@ static int _find_max_parallel_space_for_one_policy(struct alloc_handle *ah, stru
 				 * data together will be split, we must adjust
 				 * the comparison accordingly.
 				 */
-				if (ah->alloc_and_split_meta)
+				if (ah->alloc_and_split_meta && !ah->split_metadata_is_allocated)
 					max_tmp -= ah->log_len;
 				if (max_tmp > (spvs->le + spvs->len) * ah->area_multiple) {
 					max_to_allocate = (spvs->le + spvs->len) * ah->area_multiple - alloc_state->allocated;
-					max_to_allocate += ah->alloc_and_split_meta ? ah->log_len : 0;
+					max_to_allocate += (ah->alloc_and_split_meta && !ah->split_metadata_is_allocated) ? ah->log_len : 0;
 				}
 				parallel_pvs = &spvs->pvs;
 				break;
@@ -2321,7 +2334,7 @@ static int _find_max_parallel_space_for_one_policy(struct alloc_handle *ah, stru
 		} else if (ah->maximise_cling && alloc_parms->alloc == ALLOC_NORMAL &&
 			   !(alloc_parms->flags & A_CLING_TO_ALLOCED))
 			alloc_parms->flags |= A_CLING_TO_ALLOCED;
-	} while ((alloc_parms->alloc != ALLOC_CONTIGUOUS) && alloc_state->allocated != alloc_parms->extents_still_needed && (alloc_parms->flags & A_CAN_SPLIT));
+	} while ((alloc_parms->alloc != ALLOC_CONTIGUOUS) && alloc_state->allocated != alloc_parms->extents_still_needed && (alloc_parms->flags & A_CAN_SPLIT) && (!ah->approx_alloc || pv_maps_size(pvms)));
 
 	return 1;
 }
@@ -2415,7 +2428,7 @@ static int _allocate(struct alloc_handle *ah,
 		old_allocated = alloc_state.allocated;
 		log_debug_alloc("Trying allocation using %s policy.", get_alloc_string(alloc));
 
-		if (!_sufficient_pes_free(ah, pvms, alloc_state.allocated, ah->new_extents))
+		if (!ah->approx_alloc && !_sufficient_pes_free(ah, pvms, alloc_state.allocated, ah->new_extents))
 			goto_out;
 
 		_init_alloc_parms(ah, &alloc_parms, alloc, prev_lvseg,
@@ -2441,12 +2454,19 @@ static int _allocate(struct alloc_handle *ah,
 				  ah->area_count / ah->area_multiple);
 			goto out;
 		}
-		log_verbose("Insufficient suitable %sallocatable extents "
-			    "for logical volume %s: size reduced by %u extents",
+		if (!alloc_state.allocated) {
+			log_error("Insufficient suitable %sallocatable extents "
+				  "found for logical volume %s.",
+				  can_split ? "" : "contiguous ",
+				  lv ? lv->name : "");
+			goto out;
+		}
+		log_verbose("Found fewer %sallocatable extents "
+			    "for logical volume %s than requested: using %" PRIu32 " extents (reduced by %u).",
 			    can_split ? "" : "contiguous ",
 			    lv ? lv->name : "",
-			    (ah->new_extents - alloc_state.allocated) *
-			    ah->area_count / ah->area_multiple);
+			    alloc_state.allocated,
+			    (ah->new_extents - alloc_state.allocated) * ah->area_count / ah->area_multiple);
 		ah->new_extents = alloc_state.allocated;
 	}
 
@@ -3014,6 +3034,12 @@ static int _lv_extend_layered_lv(struct alloc_handle *ah,
 
 /*
  * Entry point for single-step LV allocation + extension.
+ * Extents is the number of logical extents to append to the LV unless
+ * approx_alloc is set when it is an upper limit for the total number of
+ * extents to use from the VG.
+ *
+ * FIXME The approx_alloc raid/stripe conversion should be performed
+ * before calling this function.
  */
 int lv_extend(struct logical_volume *lv,
 	      const struct segment_type *segtype,
@@ -3028,7 +3054,7 @@ int lv_extend(struct logical_volume *lv,
 	struct alloc_handle *ah;
 	uint32_t sub_lv_count;
 
-	log_very_verbose("Extending segment type, %s", segtype->name);
+	log_very_verbose("Adding segment of type %s to LV %s.", segtype->name, lv->name);
 
 	if (segtype_is_virtual(segtype))
 		return lv_add_virtual_segment(lv, 0u, extents, segtype, thin_pool_name);
@@ -3054,11 +3080,8 @@ int lv_extend(struct logical_volume *lv,
 
 	if (ah->approx_alloc) {
 		extents = ah->new_extents;
-		if (segtype_is_raid(segtype)) {
-			log_error("Extents before: %u", extents);
+		if (segtype_is_raid(segtype))
 			extents -= ah->log_len * ah->area_multiple;
-			log_error("Extents after : %u", extents);
-		}
 	}
 
 	if (segtype_is_thin_pool(segtype) || segtype_is_cache_pool(segtype)) {
@@ -6025,7 +6048,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 	}
 
 	if (!seg_is_virtual(lp) &&
-	    vg->free_count < lp->extents) {
+	    vg->free_count < lp->extents && !lp->approx_alloc) {
 		log_error("Volume group \"%s\" has insufficient free space "
 			  "(%u extents): %u required.",
 			  vg->name, vg->free_count, lp->extents);
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 1ae893a..b28f5a0 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -140,7 +140,9 @@ int detach_thin_external_origin(struct lv_segment *seg)
 
 int lv_is_merging_thin_snapshot(const struct logical_volume *lv)
 {
-	return (first_seg(lv)->status & MERGING) ? 1 : 0;
+	struct lv_segment *seg = first_seg(lv);
+
+	return (seg && seg->status & MERGING) ? 1 : 0;
 }
 
 /*
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 7e61203..c56cc7c 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -363,21 +363,19 @@ static int _update_extents_params(struct volume_group *vg,
 	} else
 		lp->pvh = &vg->pvs;
 
-	if (lcp->percent)
-		lp->approx_alloc = 1;
 	switch(lcp->percent) {
 		case PERCENT_VG:
-			lp->extents = percent_of_extents(lp->extents, vg->extent_count, 0);
+			extents = percent_of_extents(lp->extents, vg->extent_count, 0);
 			break;
 		case PERCENT_FREE:
-			lp->extents = percent_of_extents(lp->extents, vg->free_count, 0);
+			extents = percent_of_extents(lp->extents, vg->free_count, 0);
 			break;
 		case PERCENT_PVS:
 			if (lcp->pv_count) {
 				pv_extent_count = pv_list_extents_free(lp->pvh);
-				lp->extents = percent_of_extents(lp->extents, pv_extent_count, 0);
+				extents = percent_of_extents(lp->extents, pv_extent_count, 0);
 			} else
-				lp->extents = percent_of_extents(lp->extents, vg->extent_count, 0);
+				extents = percent_of_extents(lp->extents, vg->extent_count, 0);
 			break;
 		case PERCENT_LV:
 			log_error("Please express size as %%VG, %%PVS, or "
@@ -394,12 +392,19 @@ static int _update_extents_params(struct volume_group *vg,
 				log_error(INTERNAL_ERROR "Couldn't find origin volume.");
 				return 0;
 			}
-			lp->extents = percent_of_extents(lp->extents, origin->le_count, 0);
+			extents = percent_of_extents(lp->extents, origin->le_count, 0);
 			break;
 		case PERCENT_NONE:
+			extents = lp->extents;
 			break;
 	}
 
+	if (lcp->percent) {
+		lp->approx_alloc = 1;
+		log_verbose("Converted %" PRIu32 "%%%s into %" PRIu32 " extents.", lp->extents, get_percent_string(lcp->percent), extents);
+		lp->extents = extents;
+	}
+
 	if (lp->snapshot && lp->origin && lp->extents) {
 		if (!lp->chunk_size) {
 			log_error(INTERNAL_ERROR "Missing snapshot chunk size.");


