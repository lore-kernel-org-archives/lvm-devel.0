From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 15 Apr 2014 00:14:41 +0000 (UTC)
Subject: master - alloc: Access alloc_parms from alloc_state.
Message-ID: <20140415001441.32BD1610A7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c9a8264b8be4ab09fb2082cd2a424419cc80c63a
Commit:        c9a8264b8be4ab09fb2082cd2a424419cc80c63a
Parent:        3c82a37aee6ff266145bd2dd865763adf4f7187a
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Apr 15 01:05:34 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Apr 15 01:05:34 2014 +0100

alloc: Access alloc_parms from alloc_state.

alloc_parms is constant while allocating.
---
 lib/metadata/lv_manip.c |   13 +++++++++----
 1 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 0d87b70..0e65847 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -63,6 +63,7 @@ struct alloc_parms {
  * Holds varying state of each allocation attempt.
  */
 struct alloc_state {
+	const struct alloc_parms *alloc_parms;
 	struct pv_area_used *areas;
 	uint32_t areas_size;
 	uint32_t log_area_count_still_needed;	/* Number of areas still needing to be allocated for the log */
@@ -1883,9 +1884,10 @@ static int _pv_is_parallel(struct physical_volume *pv, struct dm_list *parallel_
  * alloc_state->areas may get modified.
  */
 static area_use_t _check_pva(struct alloc_handle *ah, struct pv_area *pva, uint32_t still_needed,
-			     const struct alloc_parms *alloc_parms, struct alloc_state *alloc_state,
+			     struct alloc_state *alloc_state,
 			     unsigned already_found_one, unsigned iteration_count, unsigned log_iteration_count)
 {
+	const struct alloc_parms *alloc_parms = alloc_state->alloc_parms;
 	unsigned s;
 
 	/* Skip fully-reserved areas (which are not currently removed from the list). */
@@ -2043,10 +2045,11 @@ static void _report_needed_allocation_space(struct alloc_handle *ah,
 /*
  * Returns 1 regardless of whether any space was found, except on error.
  */
-static int _find_some_parallel_space(struct alloc_handle *ah, const struct alloc_parms *alloc_parms,
+static int _find_some_parallel_space(struct alloc_handle *ah,
 				     struct dm_list *pvms, struct alloc_state *alloc_state,
 				     struct dm_list *parallel_pvs, uint32_t max_to_allocate)
 {
+	const struct alloc_parms *alloc_parms = alloc_state->alloc_parms;
 	unsigned ix = 0;
 	unsigned last_ix;
 	struct pv_map *pvm;
@@ -2148,7 +2151,7 @@ static int _find_some_parallel_space(struct alloc_handle *ah, const struct alloc
 				 *
 				 * USE_AREA are stored for later, then sorted and chosen from.
 				 */
-				switch(_check_pva(ah, pva, max_to_allocate, alloc_parms,
+				switch(_check_pva(ah, pva, max_to_allocate, 
 						  alloc_state, already_found_one, iteration_count, log_iteration_count)) {
 
 				case PREFERRED:
@@ -2279,6 +2282,8 @@ static int _find_max_parallel_space_for_one_policy(struct alloc_handle *ah, stru
 	struct seg_pvs *spvs;
 	struct dm_list *parallel_pvs;
 
+	alloc_state->alloc_parms = alloc_parms;
+
 	/* FIXME This algorithm needs a lot of cleaning up! */
 	/* FIXME anywhere doesn't find all space yet */
 	do {
@@ -2316,7 +2321,7 @@ static int _find_max_parallel_space_for_one_policy(struct alloc_handle *ah, stru
 
 		old_allocated = alloc_state->allocated;
 
-		if (!_find_some_parallel_space(ah, alloc_parms, pvms, alloc_state, parallel_pvs, max_to_allocate))
+		if (!_find_some_parallel_space(ah, pvms, alloc_state, parallel_pvs, max_to_allocate))
 			return_0;
 
 		/*


