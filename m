From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 15 Apr 2014 00:14:43 +0000 (UTC)
Subject: master - alloc: Introduce A_POSITIONAL_FILL.
Message-ID: <20140415001443.4ECC5610A7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1bf4c3a1fabb6864564fdc42437db424bcfa06f4
Commit:        1bf4c3a1fabb6864564fdc42437db424bcfa06f4
Parent:        c9a8264b8be4ab09fb2082cd2a424419cc80c63a
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Apr 15 01:13:47 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Apr 15 01:13:47 2014 +0100

alloc: Introduce A_POSITIONAL_FILL.

Set A_POSITIONAL_FILL if the array of areas is being filled
positionally (with a slot corresponding to each 'leg') rather
than sequentially (with all suitable areas found, to be sorted
and selected from).
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |   32 +++++++++++++++++++++++---------
 2 files changed, 24 insertions(+), 9 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 61723e5..f3da48c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.107 - 
 ==================================
+  Refactor allocation code to make A_POSITIONAL_FILL explicit.
   Use thread-safe ctime_r() for clvmd debug logging.
   Skip adding replies to already finished reply thread.
   Use mutex to check number of replies in request_timed_out() in clvmd.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 0e65847..46431a9 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -49,6 +49,8 @@ typedef enum {
 #define A_CAN_SPLIT		0x10
 #define A_AREA_COUNT_MATCHES	0x20	/* Existing lvseg has same number of areas as new segment */
 
+#define A_POSITIONAL_FILL	0x40	/* Slots are positional and filled using PREFERRED */
+
 /*
  * Constant parameters during a single allocation attempt.
  */
@@ -1280,6 +1282,7 @@ static void _init_alloc_parms(struct alloc_handle *ah,
 	/* Are there any preceding segments we must follow on from? */
 	if (alloc_parms->prev_lvseg &&
 	    (alloc_parms->flags & A_AREA_COUNT_MATCHES)) {
+		alloc_parms->flags |= A_POSITIONAL_FILL;
 		if (alloc_parms->alloc == ALLOC_CONTIGUOUS)
 			alloc_parms->flags |= A_CONTIGUOUS_TO_LVSEG;
 		else if ((alloc_parms->alloc == ALLOC_CLING) ||
@@ -1291,8 +1294,10 @@ static void _init_alloc_parms(struct alloc_handle *ah,
 		 * allocation must use the same PVs (or else fail).
 		 */
 		if ((alloc_parms->alloc == ALLOC_CLING) ||
-		    (alloc_parms->alloc == ALLOC_CLING_BY_TAGS))
+		    (alloc_parms->alloc == ALLOC_CLING_BY_TAGS)) {
 			alloc_parms->flags |= A_CLING_TO_ALLOCED;
+			alloc_parms->flags |= A_POSITIONAL_FILL;
+		}
 
 	if (alloc_parms->alloc == ALLOC_CLING_BY_TAGS)
 		alloc_parms->flags |= A_CLING_BY_TAGS;
@@ -1751,21 +1756,23 @@ static int _is_condition(struct cmd_context *cmd __attribute__((unused)),
 			 void *data)
 {
 	struct pv_match *pvmatch = data;
+	int positional = pvmatch->alloc_state->alloc_parms->flags & A_POSITIONAL_FILL;
 
-	if (pvmatch->alloc_state->areas[s].pva)
+	if (positional && pvmatch->alloc_state->areas[s].pva)
 		return 1;	/* Area already assigned */
 
 	if (!pvmatch->condition(pvmatch, pvseg, pvmatch->pva))
 		return 1;	/* Continue */
 
-	if (s >= pvmatch->alloc_state->areas_size)
+	if (positional && (s >= pvmatch->alloc_state->areas_size))
 		return 1;
 
 	/*
 	 * Only used for cling and contiguous policies (which only make one allocation per PV)
 	 * so it's safe to say all the available space is used.
 	 */
-	_reserve_required_area(pvmatch->alloc_state, pvmatch->pva, pvmatch->pva->count, s, 0);
+	if (positional)
+		_reserve_required_area(pvmatch->alloc_state, pvmatch->pva, pvmatch->pva->count, s, 0);
 
 	return 2;	/* Finished */
 }
@@ -1845,6 +1852,7 @@ static int _check_cling_to_alloced(struct alloc_handle *ah, const struct dm_conf
 {
 	unsigned s;
 	struct alloced_area *aa;
+	int positional = alloc_state->alloc_parms->flags & A_POSITIONAL_FILL;
 
 	/*
 	 * Ignore log areas.  They are always allocated whole as part of the
@@ -1854,12 +1862,13 @@ static int _check_cling_to_alloced(struct alloc_handle *ah, const struct dm_conf
 		return 0;
 
 	for (s = 0; s < ah->area_count; s++) {
-		if (alloc_state->areas[s].pva)
+		if (positional && alloc_state->areas[s].pva)
 			continue;	/* Area already assigned */
 		dm_list_iterate_items(aa, &ah->alloced_areas[s]) {
 			if ((!cling_tag_list_cn && (pva->map->pv == aa[0].pv)) ||
 			    (cling_tag_list_cn && _pvs_have_matching_tag(cling_tag_list_cn, pva->map->pv, aa[0].pv))) {
-				_reserve_required_area(alloc_state, pva, pva->count, s, 0);
+				if (positional)
+					_reserve_required_area(alloc_state, pva, pva->count, s, 0);
 				return 1;
 			}
 		}
@@ -1949,10 +1958,11 @@ static area_use_t _check_pva(struct alloc_handle *ah, struct pv_area *pva, uint3
 	     (already_found_one && alloc_parms->alloc != ALLOC_ANYWHERE)))
 		return NEXT_PV;
 
-	return USE_AREA;
-
 found:
-	return PREFERRED;
+	if (alloc_parms->flags & A_POSITIONAL_FILL)
+		return PREFERRED;
+
+	return USE_AREA;
 }
 
 /*
@@ -2078,6 +2088,9 @@ static int _find_some_parallel_space(struct alloc_handle *ah,
 		log_debug_alloc("Cling_to_allocated is %sset",
 				alloc_parms->flags & A_CLING_TO_ALLOCED ? "" : "not ");
 
+	if (alloc_parms->flags & A_POSITIONAL_FILL)
+		log_debug_alloc("Preferred areas are filled positionally.");
+
 	_clear_areas(alloc_state);
 	_reset_unreserved(pvms);
 
@@ -2146,6 +2159,7 @@ static int _find_some_parallel_space(struct alloc_handle *ah,
 				 * There are two types of allocations, which can't be mixed at present:
 				 *
 				 * PREFERRED are stored immediately in a specific parallel slot.
+				 *   This is only used if the A_POSITIONAL_FILL flag is set.
 				 *   This requires the number of slots to match, so if comparing with
 				 *   prev_lvseg then A_AREA_COUNT_MATCHES must be set.
 				 *


