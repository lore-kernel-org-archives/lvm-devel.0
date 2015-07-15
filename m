From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 15 Jul 2015 22:15:01 +0000 (UTC)
Subject: master - alloc: Fix lvextend failure when varying stripes.
Message-ID: <20150715221501.2F21B6180A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b93b85378d119e8396b0469574770cd097a988f0
Commit:        b93b85378d119e8396b0469574770cd097a988f0
Parent:        e15db1592642d5eb0a2a76b35882502c541302c7
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Jul 15 23:12:54 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Jul 15 23:12:54 2015 +0100

alloc: Fix lvextend failure when varying stripes.

A segfault was reported when extending an LV with a smaller number of
stripes than originally used.  Under unusual circumstances, the cling
detection code could successfully find a match against the excess
stripe positions and think it had finished prematurely leading to an
allocation being pursued with a length of zero.

Rename ix_offset to num_positional_areas and move it to struct
alloc_state so that _is_condition() can obtain access to it.

In _is_condition(), areas_size can no longer be assumed to match the
number of positional slots being filled so check this newly-exposed
num_positional_areas directly instead.  If the slot is outside the
range we are trying to fill, just ignore the match for now.

(Also note that the code still only performs cling detection against
the first segment of the LV.)
---
 WHATS_NEW               |    3 ++
 lib/metadata/lv_manip.c |   72 ++++++++++++++++++++++++++---------------------
 2 files changed, 43 insertions(+), 32 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 43fa004..596a92f 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,10 +1,13 @@
 Version 2.02.126 -
 ================================
+  Fix alloc segfault when extending LV with fewer stripes than in first seg.
   Fix handling of cache policy name.
   Set cache policy before with the first lvm2 cache pool metadata commit.
   Fix detection of thin-pool overprovisioning (2.02.124).
   Fix lvmpolld segfaults on 32 bit architectures.
+  Add lvmlockd lock_args validation to vg_validate.
   Fix ignored --startstopservices option if running lvmconf with systemd.
+  Hide sanlock LVs when processing LVs in VG unless named or --all used.
 
 Version 2.02.125 - 7th July 2015
 ================================
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 19d0ca7..86411d5 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -74,6 +74,7 @@ struct alloc_state {
 	uint32_t areas_size;
 	uint32_t log_area_count_still_needed;	/* Number of areas still needing to be allocated for the log */
 	uint32_t allocated;	/* Total number of extents allocated so far */
+	uint32_t num_positional_areas;	/* Number of parallel allocations that must be contiguous/cling */
 };
 
 struct lv_names {
@@ -2242,6 +2243,10 @@ static int _is_condition(struct cmd_context *cmd __attribute__((unused)),
 	if (!pvmatch->condition(pvmatch, pvseg, pvmatch->pva))
 		return 1;	/* Continue */
 
+	if (positional && (s >= pvmatch->alloc_state->num_positional_areas))
+		return 1;
+
+	/* FIXME The previous test should make this one redundant. */
 	if (positional && (s >= pvmatch->alloc_state->areas_size))
 		return 1;
 
@@ -2479,6 +2484,8 @@ static void _clear_areas(struct alloc_state *alloc_state)
 {
 	uint32_t s;
 
+	alloc_state->num_positional_areas = 0;
+
 	for (s = 0; s < alloc_state->areas_size; s++)
 		alloc_state->areas[s].pva = NULL;
 }
@@ -2521,9 +2528,10 @@ static void _report_needed_allocation_space(struct alloc_handle *ah,
 		metadata_count = alloc_state->log_area_count_still_needed;
 	}
 
-	log_debug_alloc("Still need %s%" PRIu32 " total extents from %" PRIu32 " remaining:",
+	log_debug_alloc("Still need %s%" PRIu32 " total extents from %" PRIu32 " remaining (%" PRIu32 " positional slots):",
 			ah->approx_alloc ? "up to " : "",
-			parallel_area_size * parallel_areas_count + metadata_size * metadata_count, pv_maps_size(pvms));
+			parallel_area_size * parallel_areas_count + metadata_size * metadata_count, pv_maps_size(pvms),
+			alloc_state->num_positional_areas);
 	log_debug_alloc("  %" PRIu32 " (%" PRIu32 " data/%" PRIu32
 			" parity) parallel areas of %" PRIu32 " extents each",
 			parallel_areas_count, ah->area_count, ah->parity_count, parallel_area_size);
@@ -2578,7 +2586,6 @@ static int _find_some_parallel_space(struct alloc_handle *ah,
 	struct pv_area *pva;
 	unsigned preferred_count = 0;
 	unsigned already_found_one;
-	unsigned ix_offset = 0;	/* Offset for non-preferred allocations */
 	unsigned ix_log_offset; /* Offset to start of areas to use for log */
 	unsigned too_small_for_log_count; /* How many too small for log? */
 	unsigned iteration_count = 0; /* cling_to_alloced may need 2 iterations */
@@ -2588,27 +2595,28 @@ static int _find_some_parallel_space(struct alloc_handle *ah,
 	uint32_t devices_needed = ah->area_count + ah->parity_count;
 	uint32_t required;
 
-	/* ix_offset holds the number of parallel allocations that must be contiguous/cling */
+	_clear_areas(alloc_state);
+	_reset_unreserved(pvms);
+
+	/* num_positional_areas holds the number of parallel allocations that must be contiguous/cling */
+	/* These appear first in the array, so it is also the offset to the non-preferred allocations */
 	/* At most one of A_CONTIGUOUS_TO_LVSEG, A_CLING_TO_LVSEG or A_CLING_TO_ALLOCED may be set */
 	if (!(alloc_parms->flags & A_POSITIONAL_FILL))
-		ix_offset = 0;
+		alloc_state->num_positional_areas = 0;
 	else if (alloc_parms->flags & (A_CONTIGUOUS_TO_LVSEG | A_CLING_TO_LVSEG))
-		ix_offset = _stripes_per_mimage(alloc_parms->prev_lvseg) * alloc_parms->prev_lvseg->area_count;
+		alloc_state->num_positional_areas = _stripes_per_mimage(alloc_parms->prev_lvseg) * alloc_parms->prev_lvseg->area_count;
 	else if (alloc_parms->flags & A_CLING_TO_ALLOCED)
-		ix_offset = ah->area_count;
+		alloc_state->num_positional_areas = ah->area_count;
 
 	if (alloc_parms->alloc == ALLOC_NORMAL || (alloc_parms->flags & A_CLING_TO_ALLOCED))
 		log_debug_alloc("Cling_to_allocated is %sset",
 				alloc_parms->flags & A_CLING_TO_ALLOCED ? "" : "not ");
 
 	if (alloc_parms->flags & A_POSITIONAL_FILL)
-		log_debug_alloc("%u preferred area(s) to be filled positionally.", ix_offset);
+		log_debug_alloc("%u preferred area(s) to be filled positionally.", alloc_state->num_positional_areas);
 	else
 		log_debug_alloc("Areas to be sorted and filled sequentially.");
 
-	_clear_areas(alloc_state);
-	_reset_unreserved(pvms);
-
 	_report_needed_allocation_space(ah, alloc_state, pvms);
 
 	/* ix holds the number of areas found on other PVs */
@@ -2616,7 +2624,7 @@ static int _find_some_parallel_space(struct alloc_handle *ah,
 		if (log_iteration_count) {
 			log_debug_alloc("Found %u areas for %" PRIu32 " parallel areas and %" PRIu32 " log areas so far.", ix, devices_needed, alloc_state->log_area_count_still_needed);
 		} else if (iteration_count)
-			log_debug_alloc("Filled %u out of %u preferred areas so far.", preferred_count, ix_offset);
+			log_debug_alloc("Filled %u out of %u preferred areas so far.", preferred_count, alloc_state->num_positional_areas);
 
 		/*
 		 * Provide for escape from the loop if no progress is made.
@@ -2657,7 +2665,7 @@ static int _find_some_parallel_space(struct alloc_handle *ah,
 				 * not enough for the logs.
 				 */
 				if (log_iteration_count) {
-					for (s = devices_needed; s < ix + ix_offset; s++)
+					for (s = devices_needed; s < ix + alloc_state->num_positional_areas; s++)
 						if (alloc_state->areas[s].pva && alloc_state->areas[s].pva->map->pv == pvm->pv)
 							goto next_pv;
 				/* On a second pass, avoid PVs already used in an uncommitted area */
@@ -2705,8 +2713,8 @@ static int _find_some_parallel_space(struct alloc_handle *ah,
 					}
 
 					/* Reserve required amount of pva */
-					required = _calc_required_extents(ah, pva, ix + ix_offset - 1, max_to_allocate, alloc_parms->alloc);
-					if (!_reserve_required_area(ah, alloc_state, pva, required, ix + ix_offset - 1, pva->unreserved))
+					required = _calc_required_extents(ah, pva, ix + alloc_state->num_positional_areas - 1, max_to_allocate, alloc_parms->alloc);
+					if (!_reserve_required_area(ah, alloc_state, pva, required, ix + alloc_state->num_positional_areas - 1, pva->unreserved))
 						return_0;
 				}
 
@@ -2717,23 +2725,23 @@ static int _find_some_parallel_space(struct alloc_handle *ah,
 			/* With cling and contiguous we stop if we found a match for *all* the areas */
 			/* FIXME Rename these variables! */
 			if ((alloc_parms->alloc == ALLOC_ANYWHERE &&
-			    ix + ix_offset >= devices_needed + alloc_state->log_area_count_still_needed) ||
-			    (preferred_count == ix_offset &&
-			     (ix_offset == devices_needed + alloc_state->log_area_count_still_needed)))
+			    ix + alloc_state->num_positional_areas >= devices_needed + alloc_state->log_area_count_still_needed) ||
+			    (preferred_count == alloc_state->num_positional_areas &&
+			     (alloc_state->num_positional_areas == devices_needed + alloc_state->log_area_count_still_needed)))
 				break;
 		}
 	} while ((alloc_parms->alloc == ALLOC_ANYWHERE && last_ix != ix && ix < devices_needed + alloc_state->log_area_count_still_needed) ||
 		/* With cling_to_alloced and normal, if there were gaps in the preferred areas, have a second iteration */
 		 (alloc_parms->alloc == ALLOC_NORMAL && preferred_count &&
-		  (preferred_count < ix_offset || alloc_state->log_area_count_still_needed) &&
+		  (preferred_count < alloc_state->num_positional_areas || alloc_state->log_area_count_still_needed) &&
 		  (alloc_parms->flags & A_CLING_TO_ALLOCED) && !iteration_count++) ||
 		/* Extra iteration needed to fill log areas on PVs already used? */
-		 (alloc_parms->alloc == ALLOC_NORMAL && preferred_count == ix_offset && !ah->mirror_logs_separate &&
+		 (alloc_parms->alloc == ALLOC_NORMAL && preferred_count == alloc_state->num_positional_areas && !ah->mirror_logs_separate &&
 		  (ix + preferred_count >= devices_needed) &&
 		  (ix + preferred_count < devices_needed + alloc_state->log_area_count_still_needed) && !log_iteration_count++));
 
 	/* Non-zero ix means at least one USE_AREA was returned */
-	if (preferred_count < ix_offset && !(alloc_parms->flags & A_CLING_TO_ALLOCED) && !ix)
+	if (preferred_count < alloc_state->num_positional_areas && !(alloc_parms->flags & A_CLING_TO_ALLOCED) && !ix)
 		return 1;
 
 	if (ix + preferred_count < devices_needed + alloc_state->log_area_count_still_needed)
@@ -2748,17 +2756,17 @@ static int _find_some_parallel_space(struct alloc_handle *ah,
 		}
 	} else if (ix > 1) {
 		log_debug_alloc("Sorting %u areas", ix);
-		qsort(alloc_state->areas + ix_offset, ix, sizeof(*alloc_state->areas),
+		qsort(alloc_state->areas + alloc_state->num_positional_areas, ix, sizeof(*alloc_state->areas),
 		      _comp_area);
 	}
 
 	/* If there are gaps in our preferred areas, fill them from the sorted part of the array */
-	if (preferred_count && preferred_count != ix_offset) {
+	if (preferred_count && preferred_count != alloc_state->num_positional_areas) {
 		for (s = 0; s < devices_needed; s++)
 			if (!alloc_state->areas[s].pva) {
-				alloc_state->areas[s].pva = alloc_state->areas[ix_offset].pva;
-				alloc_state->areas[s].used = alloc_state->areas[ix_offset].used;
-				alloc_state->areas[ix_offset++].pva = NULL;
+				alloc_state->areas[s].pva = alloc_state->areas[alloc_state->num_positional_areas].pva;
+				alloc_state->areas[s].used = alloc_state->areas[alloc_state->num_positional_areas].used;
+				alloc_state->areas[alloc_state->num_positional_areas++].pva = NULL;
 			}
 	}
 
@@ -2772,14 +2780,14 @@ static int _find_some_parallel_space(struct alloc_handle *ah,
 	/* FIXME This logic is due to its heritage and can be simplified! */
 	if (alloc_state->log_area_count_still_needed) {
 		/* How many areas are too small for the log? */
-		while (too_small_for_log_count < ix_offset + ix &&
-		       (*(alloc_state->areas + ix_offset + ix - 1 -
+		while (too_small_for_log_count < alloc_state->num_positional_areas + ix &&
+		       (*(alloc_state->areas + alloc_state->num_positional_areas + ix - 1 -
 			  too_small_for_log_count)).used < ah->log_len)
 			too_small_for_log_count++;
-		ix_log_offset = ix_offset + ix - too_small_for_log_count - ah->log_area_count;
+		ix_log_offset = alloc_state->num_positional_areas + ix - too_small_for_log_count - ah->log_area_count;
 	}
 
-	if (ix + ix_offset < devices_needed +
+	if (ix + alloc_state->num_positional_areas < devices_needed +
 	    (alloc_state->log_area_count_still_needed ? alloc_state->log_area_count_still_needed +
 				    too_small_for_log_count : 0))
 		return 1;
@@ -2793,12 +2801,12 @@ static int _find_some_parallel_space(struct alloc_handle *ah,
 	/*
 	 * This code covers the initial allocation - after that there is something to 'cling' to
 	 * and we shouldn't get this far.
-	 * ix_offset is assumed to be 0 with A_PARTITION_BY_TAGS.
+	 * alloc_state->num_positional_areas is assumed to be 0 with A_PARTITION_BY_TAGS.
 	 *
 	 * FIXME Consider a second attempt with A_PARTITION_BY_TAGS if, for example, the largest area
 	 * had all the tags set, but other areas don't.
 	 */
-	if ((alloc_parms->flags & A_PARTITION_BY_TAGS) && !ix_offset) {
+	if ((alloc_parms->flags & A_PARTITION_BY_TAGS) && !alloc_state->num_positional_areas) {
 		if (!_limit_to_one_area_per_tag(ah, alloc_state, ix_log_offset, &ix))
 			return_0;
 


