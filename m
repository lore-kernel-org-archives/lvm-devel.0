From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 15 Apr 2014 01:43:34 +0000 (UTC)
Subject: master - alloc: Correct existing use of positional fill.
Message-ID: <20140415014334.6559760CE0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=898059251442a89fc039cd49486771b6816df475
Commit:        898059251442a89fc039cd49486771b6816df475
Parent:        1bf4c3a1fabb6864564fdc42437db424bcfa06f4
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Apr 15 02:34:35 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Apr 15 02:34:35 2014 +0100

alloc: Correct existing use of positional fill.

Perform two allocation attempts with cling if maximise_cling is set,
first with then without positional fill.

Avoid segfaults from confusion between positional and sorted sequential
allocation when number of stripes varies as reported here:
https://www.redhat.com/archives/linux-lvm/2014-March/msg00001.html
---
 lib/metadata/lv_manip.c |   44 +++++++++++++++++++++++++++-----------------
 1 files changed, 27 insertions(+), 17 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 46431a9..85f7a39 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1276,18 +1276,18 @@ static void _init_alloc_parms(struct alloc_handle *ah,
 	 * areas if the number of areas matches.
 	 */
 	if (alloc_parms->prev_lvseg &&
-	    ((ah->area_count + ah->parity_count) == prev_lvseg->area_count))
+	    ((ah->area_count + ah->parity_count) == prev_lvseg->area_count)) {
 		alloc_parms->flags |= A_AREA_COUNT_MATCHES;
 
-	/* Are there any preceding segments we must follow on from? */
-	if (alloc_parms->prev_lvseg &&
-	    (alloc_parms->flags & A_AREA_COUNT_MATCHES)) {
-		alloc_parms->flags |= A_POSITIONAL_FILL;
-		if (alloc_parms->alloc == ALLOC_CONTIGUOUS)
+		/* Are there any preceding segments we must follow on from? */
+		if (alloc_parms->alloc == ALLOC_CONTIGUOUS) {
 			alloc_parms->flags |= A_CONTIGUOUS_TO_LVSEG;
-		else if ((alloc_parms->alloc == ALLOC_CLING) ||
-			 (alloc_parms->alloc == ALLOC_CLING_BY_TAGS))
+			alloc_parms->flags |= A_POSITIONAL_FILL;
+		} else if ((alloc_parms->alloc == ALLOC_CLING) ||
+			   (alloc_parms->alloc == ALLOC_CLING_BY_TAGS)) {
 			alloc_parms->flags |= A_CLING_TO_LVSEG;
+			alloc_parms->flags |= A_POSITIONAL_FILL;
+		}
 	} else
 		/*
 		 * A cling allocation that follows a successful contiguous
@@ -1916,7 +1916,7 @@ static area_use_t _check_pva(struct alloc_handle *ah, struct pv_area *pva, uint3
 	if (!iteration_count && !log_iteration_count && alloc_parms->flags & (A_CONTIGUOUS_TO_LVSEG | A_CLING_TO_LVSEG | A_CLING_TO_ALLOCED)) {
 		/* Contiguous? */
 		if (((alloc_parms->flags & A_CONTIGUOUS_TO_LVSEG) ||
-		     (ah->maximise_cling && alloc_parms->prev_lvseg && (alloc_parms->flags & A_AREA_COUNT_MATCHES))) &&
+		     (ah->maximise_cling && (alloc_parms->flags & A_AREA_COUNT_MATCHES))) &&
 		    _check_contiguous(ah->cmd, alloc_parms->prev_lvseg, pva, alloc_state))
 			goto found;
 
@@ -1926,7 +1926,7 @@ static area_use_t _check_pva(struct alloc_handle *ah, struct pv_area *pva, uint3
 
 		/* Cling to prev_lvseg? */
 		if (((alloc_parms->flags & A_CLING_TO_LVSEG) ||
-		     (ah->maximise_cling && alloc_parms->prev_lvseg && (alloc_parms->flags & A_AREA_COUNT_MATCHES))) &&
+		     (ah->maximise_cling && (alloc_parms->flags & A_AREA_COUNT_MATCHES))) &&
 		    _check_cling(ah, NULL, alloc_parms->prev_lvseg, pva, alloc_state))
 			/* If this PV is suitable, use this first area */
 			goto found;
@@ -1940,7 +1940,7 @@ static area_use_t _check_pva(struct alloc_handle *ah, struct pv_area *pva, uint3
 		if (!(alloc_parms->flags & A_CLING_BY_TAGS) || !ah->cling_tag_list_cn)
 			return NEXT_PV;
 
-		if (alloc_parms->prev_lvseg && (alloc_parms->flags & A_AREA_COUNT_MATCHES)) {
+		if ((alloc_parms->flags & A_AREA_COUNT_MATCHES)) {
 			if (_check_cling(ah, ah->cling_tag_list_cn, alloc_parms->prev_lvseg, pva, alloc_state))
 				goto found;
 		} else if (_check_cling_to_alloced(ah, ah->cling_tag_list_cn, pva, alloc_state))
@@ -2078,10 +2078,11 @@ static int _find_some_parallel_space(struct alloc_handle *ah,
 
 	/* ix_offset holds the number of parallel allocations that must be contiguous/cling */
 	/* At most one of A_CONTIGUOUS_TO_LVSEG, A_CLING_TO_LVSEG or A_CLING_TO_ALLOCED may be set */
-	if (alloc_parms->flags & (A_CONTIGUOUS_TO_LVSEG | A_CLING_TO_LVSEG))
+	if (!(alloc_parms->flags & A_POSITIONAL_FILL))
+		ix_offset = 0;
+	else if (alloc_parms->flags & (A_CONTIGUOUS_TO_LVSEG | A_CLING_TO_LVSEG))
 		ix_offset = _stripes_per_mimage(alloc_parms->prev_lvseg) * alloc_parms->prev_lvseg->area_count;
-
-	if (alloc_parms->flags & A_CLING_TO_ALLOCED)
+	else if (alloc_parms->flags & A_CLING_TO_ALLOCED)
 		ix_offset = ah->area_count;
 
 	if (alloc_parms->alloc == ALLOC_NORMAL || (alloc_parms->flags & A_CLING_TO_ALLOCED))
@@ -2089,7 +2090,9 @@ static int _find_some_parallel_space(struct alloc_handle *ah,
 				alloc_parms->flags & A_CLING_TO_ALLOCED ? "" : "not ");
 
 	if (alloc_parms->flags & A_POSITIONAL_FILL)
-		log_debug_alloc("Preferred areas are filled positionally.");
+		log_debug_alloc("%u preferred area(s) to be filled positionally.", ix_offset);
+	else
+		log_debug_alloc("Areas to be sorted and filled sequentially.");
 
 	_clear_areas(alloc_state);
 	_reset_unreserved(pvms);
@@ -2217,7 +2220,8 @@ static int _find_some_parallel_space(struct alloc_handle *ah,
 		  (ix + preferred_count >= devices_needed) &&
 		  (ix + preferred_count < devices_needed + alloc_state->log_area_count_still_needed) && !log_iteration_count++));
 
-	if (preferred_count < ix_offset && !(alloc_parms->flags & A_CLING_TO_ALLOCED))
+	/* Non-zero ix means at least one USE_AREA was returned */
+	if (preferred_count < ix_offset && !(alloc_parms->flags & A_CLING_TO_ALLOCED) && !ix)
 		return 1;
 
 	if (ix + preferred_count < devices_needed + alloc_state->log_area_count_still_needed)
@@ -2339,6 +2343,9 @@ static int _find_max_parallel_space_for_one_policy(struct alloc_handle *ah, stru
 			return_0;
 
 		/*
+		 * For ALLOC_CLING, if the number of areas matches and maximise_cling is
+		 * set we allow two passes, first with A_POSITIONAL_FILL then without.
+		 *
 		 * If we didn't allocate anything this time with ALLOC_NORMAL and had
 		 * A_CLING_TO_ALLOCED set, try again without it.
 		 *
@@ -2347,7 +2354,10 @@ static int _find_max_parallel_space_for_one_policy(struct alloc_handle *ah, stru
 		 * remain on the same disks where possible.
 		 */
 		if (old_allocated == alloc_state->allocated) {
-			if ((alloc_parms->alloc == ALLOC_NORMAL) && (alloc_parms->flags & A_CLING_TO_ALLOCED))
+			if (ah->maximise_cling && ((alloc_parms->alloc == ALLOC_CLING) || (alloc_parms->alloc == ALLOC_CLING_BY_TAGS)) &&
+			    (alloc_parms->flags & A_CLING_TO_LVSEG) && (alloc_parms->flags & A_POSITIONAL_FILL))
+				alloc_parms->flags &= ~A_POSITIONAL_FILL;
+			else if ((alloc_parms->alloc == ALLOC_NORMAL) && (alloc_parms->flags & A_CLING_TO_ALLOCED))
 				alloc_parms->flags &= ~A_CLING_TO_ALLOCED;
 			else
 				break;	/* Give up */


