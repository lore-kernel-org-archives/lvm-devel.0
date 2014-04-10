From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu, 10 Apr 2014 19:50:35 +0000 (UTC)
Subject: master - alloc: Refactor area reservation code.
Message-ID: <20140410195035.BDC8760268@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a8d63994ea1d7faea83c8a8d79bf36cb8b746ffa
Commit:        a8d63994ea1d7faea83c8a8d79bf36cb8b746ffa
Parent:        6320c3b9052004397faf1687198756ac7914fecc
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Apr 10 20:48:59 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Apr 10 20:48:59 2014 +0100

alloc: Refactor area reservation code.

No functional changes intended to be included in this patch.
---
 lib/metadata/lv_manip.c |  106 +++++++++++++++++++++++-----------------------
 1 files changed, 53 insertions(+), 53 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 740eef0..18fa7e6 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1419,7 +1419,7 @@ static int _alloc_parallel_area(struct alloc_handle *ah, uint32_t max_to_allocat
 				struct alloc_state *alloc_state, uint32_t ix_log_offset)
 {
 	uint32_t area_len, len;
-	uint32_t s;
+	uint32_t s, smeta;
 	uint32_t ix_log_skip = 0; /* How many areas to skip in middle of array to reach log areas */
 	uint32_t total_area_count;
 	struct alloced_area *aa;
@@ -1469,21 +1469,20 @@ static int _alloc_parallel_area(struct alloc_handle *ah, uint32_t max_to_allocat
 			 * allocation, we store the images at the beginning
 			 * of the areas array and the metadata at the end.
 			 */
-			s += ah->area_count + ah->parity_count;
-			aa[s].pv = pva->map->pv;
-			aa[s].pe = pva->start;
-			aa[s].len = ah->log_len;
+			smeta = s + ah->area_count + ah->parity_count;
+			aa[smeta].pv = pva->map->pv;
+			aa[smeta].pe = pva->start;
+			aa[smeta].len = ah->log_len;
 
 			log_debug_alloc("Allocating parallel metadata area %" PRIu32
 					" on %s start PE %" PRIu32
 					" length %" PRIu32 ".",
-					(s - (ah->area_count + ah->parity_count)),
-					pv_dev_name(aa[s].pv), aa[s].pe,
+					(smeta - (ah->area_count + ah->parity_count)),
+					pv_dev_name(aa[smeta].pv), aa[smeta].pe,
 					ah->log_len);
 
 			consume_pv_area(pva, ah->log_len);
-			dm_list_add(&ah->alloced_areas[s], &aa[s].list);
-			s -= ah->area_count + ah->parity_count;
+			dm_list_add(&ah->alloced_areas[smeta], &aa[smeta].list);
 		}
 		aa[s].len = (ah->alloc_and_split_meta && !ah->split_metadata_is_allocated) ? len - ah->log_len : len;
 		/* Skip empty allocations */
@@ -1613,9 +1612,8 @@ static int _comp_area(const void *l, const void *r)
 struct pv_match {
 	int (*condition)(struct pv_match *pvmatch, struct pv_segment *pvseg, struct pv_area *pva);
 
-	struct pv_area_used *areas;
+	struct alloc_state *alloc_state;
 	struct pv_area *pva;
-	uint32_t areas_size;
 	const struct dm_config_node *cling_tag_list_cn;
 	int s;	/* Area index of match */
 };
@@ -1711,39 +1709,62 @@ static int _is_contiguous(struct pv_match *pvmatch __attribute((unused)), struct
 	return 1;
 }
 
-static void _reserve_area(struct pv_area_used *area_used, struct pv_area *pva, uint32_t required,
+static void _reserve_area(struct alloc_state *alloc_state, struct pv_area *pva, uint32_t required,
 			  uint32_t ix_pva, uint32_t unreserved)
 {
+	struct pv_area_used *area_used = &alloc_state->areas[ix_pva];
+
 	log_debug_alloc("%s allocation area %" PRIu32 " %s %s start PE %" PRIu32
 			" length %" PRIu32 " leaving %" PRIu32 ".",
 			area_used->pva ? "Changing   " : "Considering", 
-			ix_pva - 1, area_used->pva ? "to" : "as", 
+			ix_pva, area_used->pva ? "to" : "as", 
 			dev_name(pva->map->pv->dev), pva->start, required, unreserved);
 
 	area_used->pva = pva;
 	area_used->used = required;
 }
 
+static int _reserve_required_area(struct alloc_state *alloc_state, struct pv_area *pva, uint32_t required,
+				  uint32_t ix_pva, uint32_t unreserved)
+{
+	uint32_t s;
+
+	/* Expand areas array if needed after an area was split. */
+	if (ix_pva >= alloc_state->areas_size) {
+		alloc_state->areas_size *= 2;
+		if (!(alloc_state->areas = dm_realloc(alloc_state->areas, sizeof(*alloc_state->areas) * (alloc_state->areas_size)))) {
+			log_error("Memory reallocation for parallel areas failed.");
+			return 0;
+		}
+		for (s = alloc_state->areas_size / 2; s < alloc_state->areas_size; s++)
+			alloc_state->areas[s].pva = NULL;
+	}
+
+	_reserve_area(alloc_state, pva, required, ix_pva, unreserved);
+
+	return 1;
+}
+
 static int _is_condition(struct cmd_context *cmd __attribute__((unused)),
 			 struct pv_segment *pvseg, uint32_t s,
 			 void *data)
 {
 	struct pv_match *pvmatch = data;
 
-	if (pvmatch->areas[s].pva)
+	if (pvmatch->alloc_state->areas[s].pva)
 		return 1;	/* Area already assigned */
 
 	if (!pvmatch->condition(pvmatch, pvseg, pvmatch->pva))
 		return 1;	/* Continue */
 
-	if (s >= pvmatch->areas_size)
+	if (s >= pvmatch->alloc_state->areas_size)
 		return 1;
 
 	/*
 	 * Only used for cling and contiguous policies (which only make one allocation per PV)
 	 * so it's safe to say all the available space is used.
 	 */
-	_reserve_area(&pvmatch->areas[s], pvmatch->pva, pvmatch->pva->count, s + 1, 0);
+	_reserve_required_area(pvmatch->alloc_state, pvmatch->pva, pvmatch->pva->count, s, 0);
 
 	return 2;	/* Finished */
 }
@@ -1761,8 +1782,7 @@ static int _check_cling(struct alloc_handle *ah,
 	uint32_t le, len;
 
 	pvmatch.condition = cling_tag_list_cn ? _has_matching_pv_tag : _is_same_pv;
-	pvmatch.areas = alloc_state->areas;
-	pvmatch.areas_size = alloc_state->areas_size;
+	pvmatch.alloc_state = alloc_state;
 	pvmatch.pva = pva;
 	pvmatch.cling_tag_list_cn = cling_tag_list_cn;
 
@@ -1799,8 +1819,7 @@ static int _check_contiguous(struct cmd_context *cmd,
 	int r;
 
 	pvmatch.condition = _is_contiguous;
-	pvmatch.areas = alloc_state->areas;
-	pvmatch.areas_size = alloc_state->areas_size;
+	pvmatch.alloc_state = alloc_state;
 	pvmatch.pva = pva;
 	pvmatch.cling_tag_list_cn = NULL;
 
@@ -1839,7 +1858,7 @@ static int _check_cling_to_alloced(struct alloc_handle *ah, const struct dm_conf
 		dm_list_iterate_items(aa, &ah->alloced_areas[s]) {
 			if ((!cling_tag_list_cn && (pva->map->pv == aa[0].pv)) ||
 			    (cling_tag_list_cn && _pvs_have_matching_tag(cling_tag_list_cn, pva->map->pv, aa[0].pv))) {
-				_reserve_area(&alloc_state->areas[s], pva, pva->count, s + 1, 0);
+				_reserve_required_area(alloc_state, pva, pva->count, s, 0);
 				return 1;
 			}
 		}
@@ -1888,7 +1907,7 @@ static area_use_t _check_pva(struct alloc_handle *ah, struct pv_area *pva, uint3
 		if (((alloc_parms->flags & A_CONTIGUOUS_TO_LVSEG) ||
 		     (ah->maximise_cling && alloc_parms->prev_lvseg && (alloc_parms->flags & A_AREA_COUNT_MATCHES))) &&
 		    _check_contiguous(ah->cmd, alloc_parms->prev_lvseg, pva, alloc_state))
-			return PREFERRED;
+			goto found;
 
 		/* Try next area on same PV if looking for contiguous space */
 		if (alloc_parms->flags & A_CONTIGUOUS_TO_LVSEG)
@@ -1899,12 +1918,12 @@ static area_use_t _check_pva(struct alloc_handle *ah, struct pv_area *pva, uint3
 		     (ah->maximise_cling && alloc_parms->prev_lvseg && (alloc_parms->flags & A_AREA_COUNT_MATCHES))) &&
 		    _check_cling(ah, NULL, alloc_parms->prev_lvseg, pva, alloc_state))
 			/* If this PV is suitable, use this first area */
-			return PREFERRED;
+			goto found;
 
 		/* Cling_to_alloced? */
 		if ((alloc_parms->flags & A_CLING_TO_ALLOCED) &&
 		    _check_cling_to_alloced(ah, NULL, pva, alloc_state))
-			return PREFERRED;
+			goto found;
 
 		/* Cling_by_tags? */
 		if (!(alloc_parms->flags & A_CLING_BY_TAGS) || !ah->cling_tag_list_cn)
@@ -1912,9 +1931,9 @@ static area_use_t _check_pva(struct alloc_handle *ah, struct pv_area *pva, uint3
 
 		if (alloc_parms->prev_lvseg && (alloc_parms->flags & A_AREA_COUNT_MATCHES)) {
 			if (_check_cling(ah, ah->cling_tag_list_cn, alloc_parms->prev_lvseg, pva, alloc_state))
-				return PREFERRED;
+				goto found;
 		} else if (_check_cling_to_alloced(ah, ah->cling_tag_list_cn, pva, alloc_state))
-			return PREFERRED;
+			goto found;
 
 		/* All areas on this PV give same result so pointless checking more */
 		return NEXT_PV;
@@ -1929,6 +1948,9 @@ static area_use_t _check_pva(struct alloc_handle *ah, struct pv_area *pva, uint3
 		return NEXT_PV;
 
 	return USE_AREA;
+
+found:
+	return PREFERRED;
 }
 
 /*
@@ -1945,7 +1967,7 @@ static uint32_t _calc_required_extents(struct alloc_handle *ah, struct pv_area *
 	 * reduce amount we're looking for.
 	 */
 	if (alloc == ALLOC_ANYWHERE) {
-		if (ix_pva - 1 >= ah->area_count)
+		if (ix_pva >= ah->area_count)
 			required = ah->log_len;
 	} else if (required < ah->log_len)
 		required = ah->log_len;
@@ -1961,29 +1983,6 @@ static uint32_t _calc_required_extents(struct alloc_handle *ah, struct pv_area *
 	return required;
 }
 
-static int _reserve_required_area(struct alloc_handle *ah, uint32_t max_to_allocate,
-				  unsigned ix_pva, struct pv_area *pva,
-				  struct alloc_state *alloc_state, alloc_policy_t alloc)
-{
-	uint32_t required = _calc_required_extents(ah, pva, ix_pva, max_to_allocate, alloc);
-	uint32_t s;
-
-	/* Expand areas array if needed after an area was split. */
-	if (ix_pva > alloc_state->areas_size) {
-		alloc_state->areas_size *= 2;
-		if (!(alloc_state->areas = dm_realloc(alloc_state->areas, sizeof(*alloc_state->areas) * (alloc_state->areas_size)))) {
-			log_error("Memory reallocation for parallel areas failed.");
-			return 0;
-		}
-		for (s = alloc_state->areas_size / 2; s < alloc_state->areas_size; s++)
-			alloc_state->areas[s].pva = NULL;
-	}
-
-	_reserve_area(&alloc_state->areas[ix_pva - 1], pva, required, ix_pva, pva->unreserved);
-
-	return 1;
-}
-
 static void _clear_areas(struct alloc_state *alloc_state)
 {
 	uint32_t s;
@@ -2062,6 +2061,7 @@ static int _find_some_parallel_space(struct alloc_handle *ah, const struct alloc
 	struct alloced_area *aa;
 	uint32_t s;
 	uint32_t devices_needed = ah->area_count + ah->parity_count;
+	uint32_t required;
 
 	/* ix_offset holds the number of parallel allocations that must be contiguous/cling */
 	/* At most one of A_CONTIGUOUS_TO_LVSEG, A_CLING_TO_LVSEG or A_CLING_TO_ALLOCED may be set */
@@ -2173,8 +2173,8 @@ static int _find_some_parallel_space(struct alloc_handle *ah, const struct alloc
 					}
 
 					/* Reserve required amount of pva */
-					if (!_reserve_required_area(ah, max_to_allocate, ix + ix_offset,
-								    pva, alloc_state, alloc_parms->alloc))
+					required = _calc_required_extents(ah, pva, ix + ix_offset - 1, max_to_allocate, alloc_parms->alloc);
+					if (!_reserve_required_area(alloc_state, pva, required, ix + ix_offset - 1, pva->unreserved))
 						return_0;
 				}
 
@@ -4511,7 +4511,7 @@ static int _add_pvs(struct cmd_context *cmd, struct pv_segment *peg,
 
 	/* Don't add again if it's already on list. */
 	if (find_pv_in_pv_list(&spvs->pvs, peg->pv))
-			return 1;
+		return 1;
 
 	if (!(pvl = dm_pool_alloc(cmd->mem, sizeof(*pvl)))) {
 		log_error("pv_list allocation failed");


