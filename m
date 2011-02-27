From: agk@sourceware.org <agk@sourceware.org>
Date: 27 Feb 2011 00:38:33 -0000
Subject: LVM2 ./WHATS_NEW doc/example.conf.in lib/confi ...
Message-ID: <20110227003833.23186.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-02-27 00:38:32

Modified files:
	.              : WHATS_NEW 
	doc            : example.conf.in 
	lib/config     : defaults.h 
	lib/metadata   : lv_manip.c 

Log message:
	Various changes to the allocation algorithms: Expect some fallout.
	There is a lot to test.
	
	Two new config settings added that are intended to make the code behave
	closely to the way it did before - worth a try if you find problems.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1926&r2=1.1927
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.in.diff?cvsroot=lvm2&r1=1.18&r2=1.19
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/defaults.h.diff?cvsroot=lvm2&r1=1.71&r2=1.72
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.248&r2=1.249

--- LVM2/WHATS_NEW	2011/02/25 14:08:54	1.1926
+++ LVM2/WHATS_NEW	2011/02/27 00:38:31	1.1927
@@ -1,5 +1,9 @@
 Version 2.02.85 - 
 ===================================
+  Extend normal policy to allow mirror logs on same devs as images if necessary.
+  Improve cling policy to recognise devs already allocated in the transaction.
+  Improve normal allocation algorithm to include clinging to existing areas.
+  Add allocation/maximise_cling & mirror_logs_require_separate_pvs to lvm.conf.
   Fix metadata balance code to work with recent changes in metadata handling.
   Add old_uuid field to physical_volume and fix pvchange -u for recent changes.
   Allow pvresize on a PV with two metadata areas (for PVs not in a VG).
--- LVM2/doc/example.conf.in	2011/02/18 14:11:22	1.18
+++ LVM2/doc/example.conf.in	2011/02/27 00:38:32	1.19
@@ -171,6 +171,19 @@
 #
 #    cling_tag_list = [ "@site1", "@site2" ]
 #    cling_tag_list = [ "@*" ]
+#
+#    Changes made in version 2.02.85 extended the reach of the 'cling'
+#    policies to detect more situations where data can be grouped
+#    onto the same disks.  Set this to 0 to revert to the previous
+#    algorithm.
+#
+#    maximise_cling = 1
+#
+#    Set to 1 to guarantee that mirror logs will always be placed on 
+#    different PVs from the mirror images.  This was the default
+#    until version 2.02.85.
+#
+#    mirror_logs_require_separate_pvs = 0
 #}
 
 # This section that allows you to configure the nature of the
--- LVM2/lib/config/defaults.h	2010/10/25 11:20:55	1.71
+++ LVM2/lib/config/defaults.h	2011/02/27 00:38:32	1.72
@@ -79,6 +79,8 @@
 #define DEFAULT_MAX_PV 0
 #define DEFAULT_MAX_LV 0
 #define DEFAULT_ALLOC_POLICY ALLOC_NORMAL
+#define DEFAULT_MIRROR_LOGS_REQUIRE_SEPARATE_PVS 0
+#define DEFAULT_MAXIMISE_CLING 1
 #define DEFAULT_CLUSTERED 0
 
 #define DEFAULT_MSG_PREFIX "  "
--- LVM2/lib/metadata/lv_manip.c	2011/02/18 14:47:30	1.248
+++ LVM2/lib/metadata/lv_manip.c	2011/02/27 00:38:32	1.249
@@ -26,6 +26,41 @@
 #include "archiver.h"
 #include "activate.h"
 #include "str_list.h"
+#include "defaults.h"
+
+typedef enum {
+	PREFERRED,
+	USE_AREA,
+	NEXT_PV,
+	NEXT_AREA
+} area_use_t;
+
+/* FIXME These ended up getting used differently from first intended.  Refactor. */
+#define A_CONTIGUOUS		0x01
+#define A_CLING			0x02
+#define A_CLING_BY_TAGS		0x04
+#define A_CLING_TO_ALLOCED	0x08	/* Only for ALLOC_NORMAL */
+#define A_CAN_SPLIT		0x10
+
+/*
+ * Constant parameters during a single allocation attempt.
+ */
+struct alloc_parms {
+	alloc_policy_t alloc;
+	unsigned flags;		/* Holds A_* */
+	struct lv_segment *prev_lvseg;
+	uint32_t extents_still_needed;
+};
+
+/*
+ * Holds varying state of each allocation attempt.
+ */
+struct alloc_state {
+	struct pv_area_used *areas;
+	uint32_t areas_size;
+	uint32_t log_area_count_still_needed;	/* Number of areas still needing to be allocated for the log */
+	uint32_t allocated;	/* Total number of extents allocated so far */
+};
 
 struct lv_names {
 	const char *old;
@@ -526,6 +561,9 @@
 	uint32_t region_size;		/* Mirror region size */
 	uint32_t total_area_len;	/* Total number of parallel extents */
 
+	unsigned maximise_cling;
+	unsigned mirror_logs_separate;	/* Must mirror logs be on separate PVs? */
+
 	const struct config_node *cling_tag_list_cn;
 
 	struct dm_list *parallel_areas;	/* PVs to avoid */
@@ -644,6 +682,10 @@
 
 	ah->cling_tag_list_cn = find_config_tree_node(cmd, "allocation/cling_tag_list");
 
+	ah->maximise_cling = find_config_tree_bool(cmd, "allocation/maximise_cling", DEFAULT_MAXIMISE_CLING);
+
+	ah->mirror_logs_separate = find_config_tree_bool(cmd, "allocation/mirror_logs_require_separate_pvs", DEFAULT_MIRROR_LOGS_REQUIRE_SEPARATE_PVS);
+
 	return ah;
 }
 
@@ -653,6 +695,69 @@
 		dm_pool_destroy(ah->mem);
 }
 
+/* Is there enough total space or should we give up immediately? */
+static int _sufficient_pes_free(struct alloc_handle *ah, struct dm_list *pvms, uint32_t allocated, uint32_t extents_still_needed)
+{
+	uint32_t total_extents_needed = (extents_still_needed - allocated) * ah->area_count / ah->area_multiple;
+	uint32_t free_pes = pv_maps_size(pvms);
+
+	if (total_extents_needed > free_pes) {
+		log_error("Insufficient free space: %" PRIu32 " extents needed,"
+			  " but only %" PRIu32 " available",
+			  total_extents_needed, free_pes);
+		return 0;
+	}
+
+	return 1;
+}
+
+/* For striped mirrors, all the areas are counted, through the mirror layer */
+static uint32_t _stripes_per_mimage(struct lv_segment *seg)
+{
+	struct lv_segment *last_lvseg;
+
+	if (seg_is_mirrored(seg) && seg->area_count && seg_type(seg, 0) == AREA_LV) {
+		last_lvseg = dm_list_item(dm_list_last(&seg_lv(seg, 0)->segments), struct lv_segment);
+		if (seg_is_striped(last_lvseg))
+			return last_lvseg->area_count;
+	}
+
+	return 1;
+}
+
+static void _init_alloc_parms(struct alloc_handle *ah, struct alloc_parms *alloc_parms, alloc_policy_t alloc,
+			      struct lv_segment *prev_lvseg, unsigned can_split,
+			      uint32_t allocated, uint32_t extents_still_needed)
+{
+	alloc_parms->alloc = alloc;
+	alloc_parms->prev_lvseg = prev_lvseg;
+	alloc_parms->flags = 0;
+	alloc_parms->extents_still_needed = extents_still_needed;
+
+	/* Are there any preceding segments we must follow on from? */
+	if (alloc_parms->prev_lvseg) {
+		if ((alloc_parms->alloc == ALLOC_CONTIGUOUS))
+			alloc_parms->flags |= A_CONTIGUOUS;
+		else if ((alloc_parms->alloc == ALLOC_CLING))
+			alloc_parms->flags |= A_CLING;
+		else if ((alloc_parms->alloc == ALLOC_CLING_BY_TAGS)) {
+			alloc_parms->flags |= A_CLING;
+			alloc_parms->flags |= A_CLING_BY_TAGS;
+		}
+	}
+
+	/*
+	 * For normal allocations, if any extents have already been found 
+	 * for allocation, prefer to place further extents on the same disks as
+	 * have already been used.
+	 */
+	if (ah->maximise_cling && alloc_parms->alloc == ALLOC_NORMAL && allocated != alloc_parms->extents_still_needed)
+		alloc_parms->flags |= A_CLING_TO_ALLOCED;
+
+	if (can_split)
+		alloc_parms->flags |= A_CAN_SPLIT;
+}
+
 static int _log_parallel_areas(struct dm_pool *mem, struct dm_list *parallel_areas)
 {
 	struct seg_pvs *spvs;
@@ -759,14 +864,13 @@
  * If the complete area is not needed then it gets split.
  * The part used is removed from the pv_map so it can't be allocated twice.
  */
-static int _alloc_parallel_area(struct alloc_handle *ah, uint32_t needed,
-				struct pv_area_used *areas, uint32_t *allocated,
-				unsigned log_needs_allocating, uint32_t ix_log_offset)
+static int _alloc_parallel_area(struct alloc_handle *ah, uint32_t max_to_allocate,
+				struct alloc_state *alloc_state, uint32_t ix_log_offset)
 {
-	uint32_t area_len, len, remaining;
+	uint32_t area_len, len;
 	uint32_t s;
 	uint32_t ix_log_skip = 0; /* How many areas to skip in middle of array to reach log areas */
-	uint32_t total_area_count = ah->area_count + (log_needs_allocating ? ah->log_area_count : 0);
+	uint32_t total_area_count = ah->area_count + alloc_state->log_area_count_still_needed;
 	struct alloced_area *aa;
 
 	if (!total_area_count) {
@@ -774,13 +878,12 @@
 		return 1;
 	}
 
-	remaining = needed - *allocated;
-	area_len = remaining / ah->area_multiple;
+	area_len = max_to_allocate / ah->area_multiple;
 
 	/* Reduce area_len to the smallest of the areas */
 	for (s = 0; s < ah->area_count; s++)
-		if (area_len > areas[s].used)
-			area_len = areas[s].used;
+		if (area_len > alloc_state->areas[s].used)
+			area_len = alloc_state->areas[s].used;
 
 	if (!(aa = dm_pool_alloc(ah->mem, sizeof(*aa) * total_area_count))) {
 		log_error("alloced_area allocation failed");
@@ -799,36 +902,22 @@
 			len = ah->log_len;
 		}
 
-		aa[s].pv = areas[s + ix_log_skip].pva->map->pv;
-		aa[s].pe = areas[s + ix_log_skip].pva->start;
+		aa[s].pv = alloc_state->areas[s + ix_log_skip].pva->map->pv;
+		aa[s].pe = alloc_state->areas[s + ix_log_skip].pva->start;
 		aa[s].len = len;
 
 		log_debug("Allocating parallel area %" PRIu32
 			  " on %s start PE %" PRIu32 " length %" PRIu32 ".",
 			  s, dev_name(aa[s].pv->dev), aa[s].pe, len);
 
-		consume_pv_area(areas[s + ix_log_skip].pva, len);
+		consume_pv_area(alloc_state->areas[s + ix_log_skip].pva, len);
 
 		dm_list_add(&ah->alloced_areas[s], &aa[s].list);
 	}
 
 	ah->total_area_len += area_len;
 
-	*allocated += area_len * ah->area_multiple;
-
-	return 1;
-}
-
-/* For striped mirrors, all the areas are counted, through the mirror layer */
-static uint32_t _stripes_per_mimage(struct lv_segment *seg)
-{
-	struct lv_segment *last_lvseg;
-
-	if (seg_is_mirrored(seg) && seg->area_count && seg_type(seg, 0) == AREA_LV) {
-		last_lvseg = dm_list_item(dm_list_last(&seg_lv(seg, 0)->segments), struct lv_segment);
-		if (seg_is_striped(last_lvseg))
-			return last_lvseg->area_count;
-	}
+	alloc_state->allocated += area_len * ah->area_multiple;
 
 	return 1;
 }
@@ -1026,12 +1115,28 @@
 	return 1;
 }
 
+static void _reserve_area(struct pv_area_used *area_used, struct pv_area *pva, uint32_t required,
+			  uint32_t ix_pva, uint32_t unreserved)
+{
+	log_debug("%s allocation area %" PRIu32 " %s %s start PE %" PRIu32
+		  " length %" PRIu32 " leaving %" PRIu32 ".",
+		  area_used->pva ? "Changing   " : "Considering", 
+		  ix_pva - 1, area_used->pva ? "to" : "as", 
+		  dev_name(pva->map->pv->dev), pva->start, required, unreserved);
+
+	area_used->pva = pva;
+	area_used->used = required;
+}
+
 static int _is_condition(struct cmd_context *cmd __attribute__((unused)),
 			 struct pv_segment *pvseg, uint32_t s,
 			 void *data)
 {
 	struct pv_match *pvmatch = data;
 
+	if (pvmatch->areas[s].pva)
+		return 1;	/* Area already assigned */
+
 	if (!pvmatch->condition(pvmatch, pvseg, pvmatch->pva))
 		return 1;	/* Continue */
 
@@ -1039,16 +1144,10 @@
 		return 1;
 
 	/*
-	 * Only used for cling and contiguous policies so it's safe to say all
-	 * the available space is used.
+	 * Only used for cling and contiguous policies (which only make one allocation per PV)
+	 * so it's safe to say all the available space is used.
 	 */
-	pvmatch->areas[s].pva = pvmatch->pva;
-	pvmatch->areas[s].used = pvmatch->pva->count;
-
-	log_debug("Trying allocation area %" PRIu32 " on %s start PE %" PRIu32
-		  " length %" PRIu32 ".",
-		  s, dev_name(pvmatch->pva->map->pv->dev), pvmatch->pva->start, 
-		  pvmatch->pva->count);
+	_reserve_area(&pvmatch->areas[s], pvmatch->pva, pvmatch->pva->count, s + 1, 0);
 
 	return 2;	/* Finished */
 }
@@ -1056,23 +1155,33 @@
 /*
  * Is pva on same PV as any existing areas?
  */
-static int _check_cling(struct cmd_context *cmd,
+static int _check_cling(struct alloc_handle *ah,
 			const struct config_node *cling_tag_list_cn,
 			struct lv_segment *prev_lvseg, struct pv_area *pva,
-			struct pv_area_used *areas, uint32_t areas_size)
+			struct alloc_state *alloc_state)
 {
 	struct pv_match pvmatch;
 	int r;
+	uint32_t le, len;
 
 	pvmatch.condition = cling_tag_list_cn ? _has_matching_pv_tag : _is_same_pv;
-	pvmatch.areas = areas;
-	pvmatch.areas_size = areas_size;
+	pvmatch.areas = alloc_state->areas;
+	pvmatch.areas_size = alloc_state->areas_size;
 	pvmatch.pva = pva;
 	pvmatch.cling_tag_list_cn = cling_tag_list_cn;
 
+	if (ah->maximise_cling) {
+		/* Check entire LV */
+		le = 0;
+		len = prev_lvseg->le + prev_lvseg->len;
+	} else {
+		/* Only check 1 LE at end of previous LV segment */
+		le = prev_lvseg->le + prev_lvseg->len - 1;
+		len = 1;
+	}
+
 	/* FIXME Cope with stacks by flattening */
-	if (!(r = _for_each_pv(cmd, prev_lvseg->lv,
-			       prev_lvseg->le + prev_lvseg->len - 1, 1, NULL, NULL,
+	if (!(r = _for_each_pv(ah->cmd, prev_lvseg->lv, le, len, NULL, NULL,
 			       0, 0, -1, 1,
 			       _is_condition, &pvmatch)))
 		stack;
@@ -1088,14 +1197,14 @@
  */
 static int _check_contiguous(struct cmd_context *cmd,
 			     struct lv_segment *prev_lvseg, struct pv_area *pva,
-			     struct pv_area_used *areas, uint32_t areas_size)
+			     struct alloc_state *alloc_state)
 {
 	struct pv_match pvmatch;
 	int r;
 
 	pvmatch.condition = _is_contiguous;
-	pvmatch.areas = areas;
-	pvmatch.areas_size = areas_size;
+	pvmatch.areas = alloc_state->areas;
+	pvmatch.areas_size = alloc_state->areas_size;
 	pvmatch.pva = pva;
 	pvmatch.cling_tag_list_cn = NULL;
 
@@ -1113,262 +1222,465 @@
 }
 
 /*
- * Choose sets of parallel areas to use, respecting any constraints.
+ * Is pva on same PV as any areas already used in this allocation attempt?
+ */
+static int _check_cling_to_alloced(struct alloc_handle *ah, struct pv_area *pva, struct alloc_state *alloc_state)
+{
+	unsigned s;
+	struct alloced_area *aa;
+
+	/*
+	 * Ignore log areas.  They are always allocated whole as part of the
+	 * first allocation.  If they aren't yet set, we know we've nothing to do.
+	 */
+	if (alloc_state->log_area_count_still_needed)
+		return 0;
+
+	for (s = 0; s < ah->area_count; s++) {
+		if (alloc_state->areas[s].pva)
+			continue;	/* Area already assigned */
+		dm_list_iterate_items(aa, &ah->alloced_areas[s]) {
+			if (pva->map->pv == aa[0].pv) {
+				_reserve_area(&alloc_state->areas[s], pva, pva->count, s + 1, 0);
+				return 1;
+			}
+		}
+	}
+
+	return 0;
+}
+
+static int _pv_is_parallel(struct physical_volume *pv, struct dm_list *parallel_pvs)
+{
+	struct pv_list *pvl;
+
+	dm_list_iterate_items(pvl, parallel_pvs)
+		if (pv == pvl->pv)
+			return 1;
+
+	return 0;
+}
+
+/*
+ * Decide whether or not to try allocation from supplied area pva.
+ * alloc_state->areas may get modified.
+ */
+static area_use_t _check_pva(struct alloc_handle *ah, struct pv_area *pva, uint32_t still_needed,
+			     const struct alloc_parms *alloc_parms, struct alloc_state *alloc_state,
+			     unsigned already_found_one, unsigned iteration_count, unsigned log_iteration_count)
+{
+	unsigned s;
+
+	/* Skip fully-reserved areas (which are not currently removed from the list). */
+	if (!pva->unreserved)
+		return NEXT_AREA;
+
+	if (iteration_count + log_iteration_count) {
+		/*
+		 * Don't use an area twice.
+		 * Only ALLOC_ANYWHERE currently supports that, by destroying the data structures,
+		 * which is OK because they are not needed again afterwards.
+		 */
+		for (s = 0; s < alloc_state->areas_size; s++)
+			if (alloc_state->areas[s].pva == pva)
+				return NEXT_AREA;
+	}
+
+	/* If maximise_cling is set, perform several checks, otherwise perform exactly one. */
+	if (!iteration_count && !log_iteration_count && alloc_parms->flags & (A_CONTIGUOUS | A_CLING | A_CLING_TO_ALLOCED)) {
+		/* Contiguous? */
+		if (((alloc_parms->flags & A_CONTIGUOUS) || ah->maximise_cling) &&
+		    alloc_parms->prev_lvseg && _check_contiguous(ah->cmd, alloc_parms->prev_lvseg, pva, alloc_state))
+			return PREFERRED;
+	
+		/* Try next area on same PV if looking for contiguous space */
+		if (alloc_parms->flags & A_CONTIGUOUS)
+			return NEXT_AREA;
+	
+		/* Cling_to_alloced? */
+		if ((alloc_parms->flags & A_CLING_TO_ALLOCED) &&
+		    _check_cling_to_alloced(ah, pva, alloc_state))
+			return PREFERRED;
+
+		/* Cling? */
+		if (!(alloc_parms->flags & A_CLING_BY_TAGS) &&
+		    alloc_parms->prev_lvseg && _check_cling(ah, NULL, alloc_parms->prev_lvseg, pva, alloc_state))
+			/* If this PV is suitable, use this first area */
+			return PREFERRED;
+
+		if (!ah->maximise_cling && !(alloc_parms->flags & A_CLING_BY_TAGS))
+			return NEXT_PV;
+
+		/* Cling_by_tags? */
+		if ((alloc_parms->flags & (A_CLING_BY_TAGS | A_CLING_TO_ALLOCED)) && ah->cling_tag_list_cn &&
+		    alloc_parms->prev_lvseg && _check_cling(ah, ah->cling_tag_list_cn, alloc_parms->prev_lvseg, pva, alloc_state))
+			return PREFERRED;
+	
+		if (alloc_parms->flags & A_CLING_BY_TAGS)
+			return NEXT_PV;
+
+		/* All areas on this PV give same result so pointless checking more */
+		return NEXT_PV;
+	}
+
+	/* Normal/Anywhere */
+
+	/* Is it big enough on its own? */
+	if (pva->unreserved * ah->area_multiple < still_needed &&
+	    ((!(alloc_parms->flags & A_CAN_SPLIT) && !ah->log_area_count) ||
+	     (already_found_one && alloc_parms->alloc != ALLOC_ANYWHERE)))
+		return NEXT_PV;
+
+	return USE_AREA;
+}
+
+/*
+ * Decide how many extents we're trying to obtain from a given area.
+ * Removes the extents from further consideration.
+ */
+static uint32_t _calc_required_extents(struct alloc_handle *ah, struct pv_area *pva, unsigned ix_pva, uint32_t max_to_allocate, alloc_policy_t alloc)
+{
+	uint32_t required = max_to_allocate / ah->area_multiple;
+
+	/* FIXME Maintain unreserved all the time, so other policies can split areas too. */
+
+	if (alloc == ALLOC_ANYWHERE) {
+		/*
+		 * Update amount unreserved - effectively splitting an area 
+		 * into two or more parts.  If the whole stripe doesn't fit,
+		 * reduce amount we're looking for.
+		 */
+		if (ix_pva - 1 >= ah->area_count)
+			required = ah->log_len;
+		if (required >= pva->unreserved) {
+			required = pva->unreserved;
+			pva->unreserved = 0;
+		} else {
+			pva->unreserved -= required;
+			reinsert_reduced_pv_area(pva);
+		}
+	} else {
+		if (required < ah->log_len)
+			required = ah->log_len;
+		if (required > pva->count)
+			required = pva->count;
+	}
+
+	return required;
+}
+
+static int _reserve_required_area(struct alloc_handle *ah, uint32_t max_to_allocate,
+				  unsigned ix_pva, struct pv_area *pva,
+				  struct alloc_state *alloc_state, alloc_policy_t alloc)
+{
+	uint32_t required = _calc_required_extents(ah, pva, ix_pva, max_to_allocate, alloc);
+	uint32_t s;
+
+	/* Expand areas array if needed after an area was split. */
+	if (ix_pva > alloc_state->areas_size) {
+		alloc_state->areas_size *= 2;
+		if (!(alloc_state->areas = dm_realloc(alloc_state->areas, sizeof(*alloc_state->areas) * (alloc_state->areas_size)))) {
+			log_error("Memory reallocation for parallel areas failed.");
+			return 0;
+		}
+		for (s = alloc_state->areas_size / 2; s < alloc_state->areas_size; s++)
+			alloc_state->areas[s].pva = NULL;
+	}
+
+	_reserve_area(&alloc_state->areas[ix_pva - 1], pva, required, ix_pva, 
+		  (alloc == ALLOC_ANYWHERE) ? pva->unreserved : pva->count - required);
+
+	return 1;
+}
+
+static void _clear_areas(struct alloc_state *alloc_state)
+{
+	uint32_t s;
+
+	for (s = 0; s < alloc_state->areas_size; s++)
+		alloc_state->areas[s].pva = NULL;
+}
+
+/*
+ * Returns 1 regardless of whether any space was found, except on error.
  */
-static int _find_parallel_space(struct alloc_handle *ah, alloc_policy_t alloc,
-				struct dm_list *pvms, struct pv_area_used **areas_ptr,
-				uint32_t *areas_size_ptr, unsigned can_split,
-				struct lv_segment *prev_lvseg,
-				uint32_t *allocated, uint32_t *log_needs_allocating, uint32_t needed)
+static int _find_some_parallel_space(struct alloc_handle *ah, const struct alloc_parms *alloc_parms,
+				     struct dm_list *pvms, struct alloc_state *alloc_state,
+				     struct dm_list *parallel_pvs, uint32_t max_to_allocate)
 {
+	unsigned ix = 0;
+	unsigned last_ix;
 	struct pv_map *pvm;
 	struct pv_area *pva;
-	struct pv_list *pvl;
-	unsigned already_found_one = 0;
-	unsigned contiguous = 0, cling = 0, use_cling_tags = 0, preferred_count = 0;
-	unsigned ix, last_ix;
+	unsigned preferred_count = 0;
+	unsigned already_found_one;
 	unsigned ix_offset = 0;	/* Offset for non-preferred allocations */
 	unsigned ix_log_offset; /* Offset to start of areas to use for log */
 	unsigned too_small_for_log_count; /* How many too small for log? */
-	uint32_t max_parallel;	/* Maximum extents to allocate */
-	uint32_t next_le;
-	uint32_t required;	/* Extents we're trying to obtain from a given area */
-	struct seg_pvs *spvs;
-	struct dm_list *parallel_pvs;
-	uint32_t free_pes;
+	unsigned iteration_count = 0; /* cling_to_alloced may need 2 iterations */
+	unsigned log_iteration_count = 0; /* extra iteration for logs on data devices */
 	struct alloced_area *aa;
 	uint32_t s;
-	uint32_t total_extents_needed = (needed - *allocated) * ah->area_count / ah->area_multiple;
-
-	/* Is there enough total space? */
-	free_pes = pv_maps_size(pvms);
-	if (total_extents_needed > free_pes) {
-		log_error("Insufficient free space: %" PRIu32 " extents needed,"
-			  " but only %" PRIu32 " available",
-			  total_extents_needed, free_pes);
-		return 0;
-	}
-
-	/* FIXME Select log PV appropriately if there isn't one yet */
 
-	/* Are there any preceding segments we must follow on from? */
-	if (prev_lvseg) {
-		ix_offset = _stripes_per_mimage(prev_lvseg) * prev_lvseg->area_count;
-		if ((alloc == ALLOC_CONTIGUOUS))
-			contiguous = 1;
-		else if ((alloc == ALLOC_CLING))
-			cling = 1;
-		else if ((alloc == ALLOC_CLING_BY_TAGS)) {
-			cling = 1;
-			use_cling_tags = 1;
-		} else
-			ix_offset = 0;
-	}
+	/* ix_offset holds the number of parallel allocations that must be contiguous/cling */
+	if (alloc_parms->flags & (A_CONTIGUOUS | A_CLING) && alloc_parms->prev_lvseg)
+		ix_offset = _stripes_per_mimage(alloc_parms->prev_lvseg) * alloc_parms->prev_lvseg->area_count;
+
+	if (alloc_parms->flags & A_CLING_TO_ALLOCED)
+		ix_offset = ah->area_count;
+
+	if (alloc_parms->alloc == ALLOC_NORMAL)
+		log_debug("Cling_to_allocated is %sset",
+			  alloc_parms->flags & A_CLING_TO_ALLOCED ? "" : "not ");
+
+	_clear_areas(alloc_state);
+
+	log_debug("Still need %" PRIu32 " extents for %" PRIu32 " parallel areas and %" PRIu32 " log areas of %" PRIu32 " extents. "
+		  "(Total %" PRIu32 " extents.)",
+		  (ah->new_extents - alloc_state->allocated) / ah->area_multiple,
+		  ah->area_count, alloc_state->log_area_count_still_needed,
+		  alloc_state->log_area_count_still_needed ? ah->log_len : 0,
+		  (ah->new_extents - alloc_state->allocated) * ah->area_count / ah->area_multiple +
+			alloc_state->log_area_count_still_needed * ah->log_len);
 
-	/* FIXME This algorithm needs a lot of cleaning up! */
-	/* FIXME anywhere doesn't find all space yet */
-	/* ix_offset holds the number of allocations that must be contiguous */
 	/* ix holds the number of areas found on other PVs */
 	do {
-		ix = 0;
-		preferred_count = 0;
+		if (log_iteration_count) {
+			log_debug("Found %u areas for %" PRIu32 " parallel areas and %" PRIu32 " log areas so far.", ix, ah->area_count, alloc_state->log_area_count_still_needed);
+		} else if (iteration_count)
+			log_debug("Filled %u out of %u preferred areas so far.", preferred_count, ix_offset);
 
-		parallel_pvs = NULL;
-		max_parallel = needed;
+		/*
+		 * Provide for escape from the loop if no progress is made.
+		 * This should not happen: ALLOC_ANYWHERE should be able to use
+		 * all available space. (If there aren't enough extents, the code
+		 * should not reach this point.)
+		 */
+		last_ix = ix;
 
 		/*
-		 * If there are existing parallel PVs, avoid them and reduce
-		 * the maximum we can allocate in one go accordingly.
+		 * Put the smallest area of each PV that is at least the
+		 * size we need into areas array.  If there isn't one
+		 * that fits completely and we're allowed more than one
+		 * LV segment, then take the largest remaining instead.
 		 */
-		if (ah->parallel_areas) {
-			next_le = (prev_lvseg ? prev_lvseg->le + prev_lvseg->len : 0) + *allocated / ah->area_multiple;
-			dm_list_iterate_items(spvs, ah->parallel_areas) {
-				if (next_le >= spvs->le + spvs->len)
-					continue;
+		dm_list_iterate_items(pvm, pvms) {
+			/* PV-level checks */
+			if (dm_list_empty(&pvm->areas))
+				continue;	/* Next PV */
+
+			if (alloc_parms->alloc != ALLOC_ANYWHERE) {
+				/* Don't allocate onto the log PVs */
+				if (ah->log_area_count)
+					dm_list_iterate_items(aa, &ah->alloced_areas[ah->area_count])
+						for (s = 0; s < ah->log_area_count; s++)
+							if (!aa[s].pv)
+								goto next_pv;
 
-				if (max_parallel > (spvs->le + spvs->len) * ah->area_multiple)
-					max_parallel = (spvs->le + spvs->len) * ah->area_multiple;
-				parallel_pvs = &spvs->pvs;
-				break;
+				/* FIXME Split into log and non-log parallel_pvs and only check the log ones if log_iteration? */
+				/* (I've temporatily disabled the check.) */
+				/* Avoid PVs used by existing parallel areas */
+				if (!log_iteration_count && parallel_pvs && _pv_is_parallel(pvm->pv, parallel_pvs))
+					goto next_pv;
+
+				/*
+				 * Avoid PVs already set aside for log.  
+				 * We only reach here if there were enough PVs for the main areas but
+				 * not enough for the logs.
+				 */
+				if (log_iteration_count) {
+					for (s = ah->area_count; s < ix + ix_offset; s++)
+						if (alloc_state->areas[s].pva && alloc_state->areas[s].pva->map->pv == pvm->pv)
+							goto next_pv;
+				/* On a second pass, avoid PVs already used in an uncommitted area */
+ 				} else if (iteration_count)
+					for (s = 0; s < ah->area_count; s++)
+						if (alloc_state->areas[s].pva && alloc_state->areas[s].pva->map->pv == pvm->pv)
+							goto next_pv;
 			}
-		}
 
-		do {
-			/*
-			 * Provide for escape from the loop if no progress is made.
-			 * This should not happen: ALLOC_ANYWHERE should be able to use
-			 * all available space. (If there aren't enough extents, the code
-			 * should not reach this point.)
-			 */
-			last_ix = ix;
-
-			/*
-			 * Put the smallest area of each PV that is at least the
-			 * size we need into areas array.  If there isn't one
-			 * that fits completely and we're allowed more than one
-			 * LV segment, then take the largest remaining instead.
-			 */
-			dm_list_iterate_items(pvm, pvms) {
-				if (dm_list_empty(&pvm->areas))
-					continue;	/* Next PV */
-
-				if (alloc != ALLOC_ANYWHERE) {
-					/* Don't allocate onto the log pv */
-					if (ah->log_area_count)
-						dm_list_iterate_items(aa, &ah->alloced_areas[ah->area_count])
-							for (s = 0; s < ah->log_area_count; s++)
-								if (!aa[s].pv)
-									goto next_pv;
-
-					/* Avoid PVs used by existing parallel areas */
-					if (parallel_pvs)
-						dm_list_iterate_items(pvl, parallel_pvs)
-							if (pvm->pv == pvl->pv)
-								goto next_pv;
-				}
+			already_found_one = 0;
+			/* First area in each list is the largest */
+			dm_list_iterate_items(pva, &pvm->areas) {
+				/*
+				 * There are two types of allocations, which can't be mixed at present.
+				 * PREFERRED are stored immediately in a specific parallel slot.
+				 * USE_AREA are stored for later, then sorted and chosen from.
+				 */
+				switch(_check_pva(ah, pva, max_to_allocate, alloc_parms,
+						  alloc_state, already_found_one, iteration_count, log_iteration_count)) {
 
-				already_found_one = 0;
-				/* First area in each list is the largest */
-				dm_list_iterate_items(pva, &pvm->areas) {
-					/* Skip fully-reserved areas (which are not currently removed from the list). */
-					if (!pva->unreserved)
-						continue;
-					if (contiguous) {
-						if (prev_lvseg &&
-						    _check_contiguous(ah->cmd,
-								      prev_lvseg,
-								      pva, *areas_ptr,
-								      *areas_size_ptr)) {
-							preferred_count++;
-							goto next_pv;
-						}
-						continue;
-					}
+				case PREFERRED:
+					preferred_count++;
 
-					if (cling) {
-						if (prev_lvseg &&
-						    _check_cling(ah->cmd,
-								 use_cling_tags ? ah->cling_tag_list_cn : NULL,
-								 prev_lvseg,
-								 pva, *areas_ptr,
-								 *areas_size_ptr)) {
-							preferred_count++;
-						}
-						goto next_pv;
-					}
+				case NEXT_PV:
+					goto next_pv;
 
-					/* Is it big enough on its own? */
-					if (pva->unreserved * ah->area_multiple <
-					    max_parallel - *allocated &&
-					    ((!can_split && !ah->log_area_count) ||
-					     (already_found_one &&
-					      !(alloc == ALLOC_ANYWHERE))))
-						goto next_pv;
+				case NEXT_AREA:
+					continue;
 
+				case USE_AREA:
 					/*
 					 * Except with ALLOC_ANYWHERE, replace first area with this
 					 * one which is smaller but still big enough.
 					 */
 					if (!already_found_one ||
-					    alloc == ALLOC_ANYWHERE) {
+					    alloc_parms->alloc == ALLOC_ANYWHERE) {
 						ix++;
 						already_found_one = 1;
 					}
 
-					required = (max_parallel - *allocated) / ah->area_multiple;
-
-					if (alloc == ALLOC_ANYWHERE) {
-						/*
-						 * Update amount unreserved - effectively splitting an area 
-						 * into two or more parts.  If the whole stripe doesn't fit,
-						 * reduce amount we're looking for.
-						 */
-						if (ix + ix_offset - 1 >= ah->area_count)
-							required = ah->log_len;
-						if (required >= pva->unreserved) {
-							required = pva->unreserved;
-							pva->unreserved = 0;
-						} else {
-							pva->unreserved -= required;
-							reinsert_reduced_pv_area(pva);
-						}
-					} else {
-						if (required < ah->log_len)
-							required = ah->log_len;
-						if (required > pva->count)
-							required = pva->count;
-					}
-
-					/* Expand areas array if needed after an area was split. */
-					if (ix + ix_offset > *areas_size_ptr) {
-						*areas_size_ptr *= 2;
-						if (!(*areas_ptr = dm_realloc(*areas_ptr,
-									     sizeof(**areas_ptr) *
-									     (*areas_size_ptr)))) {
-							log_error("Memory reallocation for parallel areas failed.");
-							return 0;
-						}
-					}
-					(*areas_ptr)[ix + ix_offset - 1].pva = pva;
-						(*areas_ptr)[ix + ix_offset - 1].used = required;
-					log_debug("Trying allocation area %" PRIu32 " on %s start PE %" PRIu32
-						  " length %" PRIu32 " leaving %" PRIu32 ".",
-						  ix + ix_offset - 1, dev_name(pva->map->pv->dev), pva->start, required,
-						  (alloc == ALLOC_ANYWHERE) ? pva->unreserved : pva->count - required);
+					/* Reserve required amount of pva */
+					if (!_reserve_required_area(ah, max_to_allocate, ix + ix_offset,
+								    pva, alloc_state, alloc_parms->alloc))
+						return_0;
 				}
-			next_pv:
-				/* With ALLOC_ANYWHERE we ignore further PVs once we have at least enough areas */
-				/* With cling and contiguous we stop if we found a match for *all* the areas */
-				/* FIXME Rename these variables! */
-				if ((alloc == ALLOC_ANYWHERE &&
-				    ix + ix_offset >= ah->area_count + (*log_needs_allocating ? ah->log_area_count : 0)) ||
-				    (preferred_count == ix_offset &&
-				     (ix_offset == ah->area_count + (*log_needs_allocating ? ah->log_area_count : 0))))
-					break;
+
 			}
-		} while (alloc == ALLOC_ANYWHERE && last_ix != ix && ix < ah->area_count + (*log_needs_allocating ? ah->log_area_count : 0));
 
-		if (preferred_count < ix_offset)
-			break;
+		next_pv:
+			/* With ALLOC_ANYWHERE we ignore further PVs once we have@least enough areas */
+			/* With cling and contiguous we stop if we found a match for *all* the areas */
+			/* FIXME Rename these variables! */
+			if ((alloc_parms->alloc == ALLOC_ANYWHERE &&
+			    ix + ix_offset >= ah->area_count + alloc_state->log_area_count_still_needed) ||
+			    (preferred_count == ix_offset &&
+			     (ix_offset == ah->area_count + alloc_state->log_area_count_still_needed)))
+				break;
+		}
+	} while ((alloc_parms->alloc == ALLOC_ANYWHERE && last_ix != ix && ix < ah->area_count + alloc_state->log_area_count_still_needed) ||
+		/* With cling_to_alloced, if there were gaps in the preferred areas, have a second iteration */
+		 (alloc_parms->alloc == ALLOC_NORMAL && preferred_count &&
+		  (preferred_count < ix_offset || alloc_state->log_area_count_still_needed) &&
+		  (alloc_parms->flags & A_CLING_TO_ALLOCED) && !iteration_count++) ||
+		/* Extra iteration needed to fill log areas on PVs already used? */
+		 (alloc_parms->alloc == ALLOC_NORMAL && preferred_count == ix_offset && !ah->mirror_logs_separate &&
+		  (ix + preferred_count < ah->area_count + alloc_state->log_area_count_still_needed) && !log_iteration_count++));
 
-		if (ix + ix_offset < ah->area_count +
-		   (*log_needs_allocating ? ah->log_area_count : 0))
-			break;
 
-		/* Sort the areas so we allocate from the biggest */
-		if (ix > 1)
-			qsort((*areas_ptr) + ix_offset, ix, sizeof(**areas_ptr),
+	if (preferred_count < ix_offset && !(alloc_parms->flags & A_CLING_TO_ALLOCED))
+		return 1;
+
+	if (ix + preferred_count < ah->area_count + alloc_state->log_area_count_still_needed)
+		return 1;
+
+	/* Sort the areas so we allocate from the biggest */
+	if (log_iteration_count) {
+		if (ix > ah->area_count + 1) {
+			log_debug("Sorting %u log areas", ix - ah->area_count);
+			qsort(alloc_state->areas + ah->area_count, ix - ah->area_count, sizeof(*alloc_state->areas),
 			      _comp_area);
+		}
+	} else if (ix > 1) {
+		log_debug("Sorting %u areas", ix);
+		qsort(alloc_state->areas + ix_offset, ix, sizeof(*alloc_state->areas),
+		      _comp_area);
+	}
+
+	/* If there are gaps in our preferred areas, fill then from the sorted part of the array */
+	if (preferred_count && preferred_count != ix_offset) {
+		for (s = 0; s < ah->area_count; s++)
+			if (!alloc_state->areas[s].pva) {
+				alloc_state->areas[s].pva = alloc_state->areas[ix_offset].pva;
+				alloc_state->areas[s].used = alloc_state->areas[ix_offset].used;
+				alloc_state->areas[ix_offset++].pva = NULL;
+			}
+	}
+	
+	/*
+	 * First time around, if there's a log, allocate it on the
+	 * smallest device that has space for it.
+	 */
+	too_small_for_log_count = 0;
+	ix_log_offset = 0;
+
+	/* FIXME This logic is due to its heritage and can be simplified! */
+	if (alloc_state->log_area_count_still_needed) {
+		/* How many areas are too small for the log? */
+		while (too_small_for_log_count < ix_offset + ix &&
+		       (*(alloc_state->areas + ix_offset + ix - 1 -
+			  too_small_for_log_count)).used < ah->log_len)
+			too_small_for_log_count++;
+		ix_log_offset = ix_offset + ix - too_small_for_log_count - ah->log_area_count;
+	}
+
+	if (ix + ix_offset < ah->area_count +
+	    (alloc_state->log_area_count_still_needed ? alloc_state->log_area_count_still_needed +
+				    too_small_for_log_count : 0))
+		return 1;
+
+	/*
+	 * Finally add the space identified to the list of areas to be used.
+	 */
+	if (!_alloc_parallel_area(ah, max_to_allocate, alloc_state, ix_log_offset))
+		return_0;
+
+	/*
+	 * Log is always allocated first time.
+	 */
+	alloc_state->log_area_count_still_needed = 0;
+
+	return 1;
+}
+
+/*
+ * Choose sets of parallel areas to use, respecting any constraints 
+ * supplied in alloc_parms.
+ */
+static int _find_max_parallel_space_for_one_policy(struct alloc_handle *ah, struct alloc_parms *alloc_parms,
+						   struct dm_list *pvms, struct alloc_state *alloc_state)
+{
+	uint32_t max_to_allocate;	/* Maximum extents to allocate this time */
+	uint32_t old_allocated;
+	uint32_t next_le;
+	struct seg_pvs *spvs;
+	struct dm_list *parallel_pvs;
+
+	/* FIXME This algorithm needs a lot of cleaning up! */
+	/* FIXME anywhere doesn't find all space yet */
+	do {
+		parallel_pvs = NULL;
+		max_to_allocate = alloc_parms->extents_still_needed - alloc_state->allocated;
 
 		/*
-		 * First time around, if there's a log, allocate it on the
-		 * smallest device that has space for it.
+		 * If there are existing parallel PVs, avoid them and reduce
+		 * the maximum we can allocate in one go accordingly.
 		 */
-		too_small_for_log_count = 0;
-		ix_log_offset = 0;
+		if (ah->parallel_areas) {
+			next_le = (alloc_parms->prev_lvseg ? alloc_parms->prev_lvseg->le + alloc_parms->prev_lvseg->len : 0) + alloc_state->allocated / ah->area_multiple;
+			dm_list_iterate_items(spvs, ah->parallel_areas) {
+				if (next_le >= spvs->le + spvs->len)
+					continue;
 
-		/* FIXME This logic is due to its heritage and can be simplified! */
-		if (*log_needs_allocating) {
-			/* How many areas are too small for the log? */
-			while (too_small_for_log_count < ix_offset + ix &&
-			       (*((*areas_ptr) + ix_offset + ix - 1 -
-				  too_small_for_log_count)).used < ah->log_len)
-				too_small_for_log_count++;
-			ix_log_offset = ix_offset + ix - too_small_for_log_count - ah->log_area_count;
-		}
-
-		if (ix + ix_offset < ah->area_count +
-		    (*log_needs_allocating ? ah->log_area_count +
-					    too_small_for_log_count : 0))
-			break;
+				if (max_to_allocate + alloc_state->allocated > (spvs->le + spvs->len) * ah->area_multiple)
+					max_to_allocate = (spvs->le + spvs->len) * ah->area_multiple - alloc_state->allocated;
+				parallel_pvs = &spvs->pvs;
+				break;
+			}
+		}
 
-		if (!_alloc_parallel_area(ah, max_parallel, *areas_ptr, allocated,
-					  *log_needs_allocating, ix_log_offset))
-			return_0;
+		old_allocated = alloc_state->allocated;
 
-		*log_needs_allocating = 0;
+		if (!_find_some_parallel_space(ah, alloc_parms, pvms, alloc_state, parallel_pvs, max_to_allocate))
+			return_0;
 
-	} while ((alloc != ALLOC_CONTIGUOUS) && *allocated != needed && can_split);
+		/*
+		 * If we didn't allocate anything this time and had
+		 * A_CLING_TO_ALLOCED set, try again without it.
+		 *
+		 * For ALLOC_NORMAL, if we did allocate something without the
+		 * flag set, set it and continue so that further allocations
+		 * remain on the same disks where possible.
+		 */
+		if (old_allocated == alloc_state->allocated) {
+			if (alloc_parms->flags & A_CLING_TO_ALLOCED)
+				alloc_parms->flags &= ~A_CLING_TO_ALLOCED;
+			else
+				break;	/* Give up */
+		} else if (ah->maximise_cling && alloc_parms->alloc == ALLOC_NORMAL &&
+			   !(alloc_parms->flags & A_CLING_TO_ALLOCED))
+			alloc_parms->flags |= A_CLING_TO_ALLOCED;
+	} while ((alloc_parms->alloc != ALLOC_CONTIGUOUS) && alloc_state->allocated != alloc_parms->extents_still_needed && (alloc_parms->flags & A_CAN_SPLIT));
 
 	return 1;
 }
@@ -1384,23 +1696,22 @@
 		     unsigned can_split,
 		     struct dm_list *allocatable_pvs)
 {
-	struct pv_area_used *areas;
-	uint32_t allocated = lv ? lv->le_count : 0;
 	uint32_t old_allocated;
 	struct lv_segment *prev_lvseg = NULL;
 	int r = 0;
 	struct dm_list *pvms;
-	uint32_t areas_size;
 	alloc_policy_t alloc;
-	unsigned log_needs_allocating = 0;
+	struct alloc_parms alloc_parms;
+	struct alloc_state alloc_state;
+
+	alloc_state.allocated = lv ? lv->le_count : 0;
 
-	if (allocated >= ah->new_extents && !ah->log_area_count) {
+	if (alloc_state.allocated >= ah->new_extents && !ah->log_area_count) {
 		log_error("_allocate called with no work to do!");
 		return 1;
 	}
 
-	if (ah->log_area_count)
-		log_needs_allocating = 1;
+	alloc_state.log_area_count_still_needed = ah->log_area_count;
 
 	if (ah->alloc == ALLOC_CONTIGUOUS)
 		can_split = 0;
@@ -1417,24 +1728,24 @@
 	if (!_log_parallel_areas(ah->mem, ah->parallel_areas))
 		stack;
 
-	areas_size = dm_list_size(pvms);
-	if (areas_size && areas_size < (ah->area_count + ah->log_area_count)) {
-		if (ah->alloc != ALLOC_ANYWHERE) {
+	alloc_state.areas_size = dm_list_size(pvms);
+	if (alloc_state.areas_size && alloc_state.areas_size < (ah->area_count + ah->log_area_count)) {
+		if (ah->alloc != ALLOC_ANYWHERE && ah->mirror_logs_separate) {
 			log_error("Not enough PVs with free space available "
 				  "for parallel allocation.");
 			log_error("Consider --alloc anywhere if desperate.");
 			return 0;
 		}
-		areas_size = ah->area_count + ah->log_area_count;
+		alloc_state.areas_size = ah->area_count + ah->log_area_count;
 	}
 
 	/* Upper bound if none of the PVs in prev_lvseg is in pvms */
 	/* FIXME Work size out properly */
 	if (prev_lvseg)
-		areas_size += _stripes_per_mimage(prev_lvseg) * prev_lvseg->area_count;
+		alloc_state.areas_size += _stripes_per_mimage(prev_lvseg) * prev_lvseg->area_count;
 
 	/* Allocate an array of pv_areas to hold the largest space on each PV */
-	if (!(areas = dm_malloc(sizeof(*areas) * areas_size))) {
+	if (!(alloc_state.areas = dm_malloc(sizeof(*alloc_state.areas) * alloc_state.areas_size))) {
 		log_error("Couldn't allocate areas array.");
 		return 0;
 	}
@@ -1451,36 +1762,33 @@
 		/* Skip cling_by_tags if no list defined */
 		if (alloc == ALLOC_CLING_BY_TAGS && !ah->cling_tag_list_cn)
 			continue;
-		old_allocated = allocated;
-		log_debug("Trying allocation using %s policy.  "
-			  "Need %" PRIu32 " extents for %" PRIu32 " parallel areas and %" PRIu32 " log areas of %" PRIu32 " extents. "
-			  "(Total %" PRIu32 " extents.)",
-			  get_alloc_string(alloc),
-			  (ah->new_extents - allocated) / ah->area_multiple,
-			  ah->area_count, log_needs_allocating ? ah->log_area_count : 0,
-			  log_needs_allocating ? ah->log_len : 0,
-			  (ah->new_extents - allocated) * ah->area_count / ah->area_multiple +
-				(log_needs_allocating ? ah->log_area_count * ah->log_len : 0));
-		if (!_find_parallel_space(ah, alloc, pvms, &areas,
-					  &areas_size, can_split,
-					  prev_lvseg, &allocated, &log_needs_allocating, ah->new_extents))
+		old_allocated = alloc_state.allocated;
+		log_debug("Trying allocation using %s policy.", get_alloc_string(alloc));
+
+		if (!_sufficient_pes_free(ah, pvms, alloc_state.allocated, ah->new_extents))
 			goto_out;
-		if ((allocated == ah->new_extents && !log_needs_allocating) || (ah->alloc == alloc) ||
-		    (!can_split && (allocated != old_allocated)))
+
+		_init_alloc_parms(ah, &alloc_parms, alloc, prev_lvseg, can_split, alloc_state.allocated, ah->new_extents);
+
+		if (!_find_max_parallel_space_for_one_policy(ah, &alloc_parms, pvms, &alloc_state))
+			goto_out;
+
+		if ((alloc_state.allocated == ah->new_extents && !alloc_state.log_area_count_still_needed) || (ah->alloc == alloc) ||
+		    (!can_split && (alloc_state.allocated != old_allocated)))
 			break;
 	}
 
-	if (allocated != ah->new_extents) {
+	if (alloc_state.allocated != ah->new_extents) {
 		log_error("Insufficient suitable %sallocatable extents "
 			  "for logical volume %s: %u more required",
 			  can_split ? "" : "contiguous ",
 			  lv ? lv->name : "",
-			  (ah->new_extents - allocated) * ah->area_count
+			  (ah->new_extents - alloc_state.allocated) * ah->area_count
 			  / ah->area_multiple);
 		goto out;
 	}
 
-	if (log_needs_allocating) {
+	if (alloc_state.log_area_count_still_needed) {
 		log_error("Insufficient free space for log allocation "
 			  "for logical volume %s.",
 			  lv ? lv->name : "");
@@ -1490,7 +1798,7 @@
 	r = 1;
 
       out:
-	dm_free(areas);
+	dm_free(alloc_state.areas);
 	return r;
 }
 


