From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 4 Feb 2020 11:23:08 -0500
Subject: master - lv_manip: add error handling for _reserve_area
Message-ID: <85430.120020411230201027@us-mta-77.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=409362c127222640cd2d1fe3e1b62b50867741c1
Commit:        409362c127222640cd2d1fe3e1b62b50867741c1
Parent:        e6a3c0901703bf98827e2da456daf0ced42dd96c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jan 30 15:23:47 2020 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 4 17:22:06 2020 +0100

lv_manip: add error handling for _reserve_area

Since _reserve_area() may fail due to error allocation failure,
add support to report this already reported failure upward.

FIXME: it's log_error() without causing direct command failure.
---
 lib/metadata/lv_manip.c | 29 +++++++++++++++++++----------
 1 file changed, 19 insertions(+), 10 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index b4daa56..ad9c756 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -2428,20 +2428,22 @@ static int _is_contiguous(struct pv_match *pvmatch __attribute((unused)), struct
 	return 1;
 }
 
-static void _reserve_area(struct alloc_handle *ah, struct alloc_state *alloc_state, struct pv_area *pva,
+static int _reserve_area(struct alloc_handle *ah, struct alloc_state *alloc_state, struct pv_area *pva,
 			  uint32_t required, uint32_t ix_pva, uint32_t unreserved)
 {
 	struct pv_area_used *area_used = &alloc_state->areas[ix_pva];
 	const char *pv_tag_list = NULL;
 
 	if (ah->cling_tag_list_cn) {
-		if (!dm_pool_begin_object(ah->mem, 256))
-			log_error("PV tags string allocation failed");
-		else if (!_tags_list_str(ah->mem, pva->map->pv, ah->cling_tag_list_cn))
+		if (!dm_pool_begin_object(ah->mem, 256)) {
+			log_error("PV tags string allocation failed.");
+			return 0;
+		} else if (!_tags_list_str(ah->mem, pva->map->pv, ah->cling_tag_list_cn))
 			dm_pool_abandon_object(ah->mem);
 		else if (!dm_pool_grow_object(ah->mem, "\0", 1)) {
 			dm_pool_abandon_object(ah->mem);
 			log_error("PV tags string extension failed.");
+			return 0;
 		} else
 			pv_tag_list = dm_pool_end_object(ah->mem);
 	}
@@ -2459,25 +2461,30 @@ static void _reserve_area(struct alloc_handle *ah, struct alloc_state *alloc_sta
 
 	area_used->pva = pva;
 	area_used->used = required;
+
+	return 1;
 }
 
 static int _reserve_required_area(struct alloc_handle *ah, struct alloc_state *alloc_state, struct pv_area *pva,
 				  uint32_t required, uint32_t ix_pva, uint32_t unreserved)
 {
 	uint32_t s;
+	struct pv_area_used *new_state;
 
 	/* Expand areas array if needed after an area was split. */
 	if (ix_pva >= alloc_state->areas_size) {
 		alloc_state->areas_size *= 2;
-		if (!(alloc_state->areas = realloc(alloc_state->areas, sizeof(*alloc_state->areas) * (alloc_state->areas_size)))) {
+		if (!(new_state = realloc(alloc_state->areas, sizeof(*alloc_state->areas) * (alloc_state->areas_size)))) {
 			log_error("Memory reallocation for parallel areas failed.");
 			return 0;
 		}
+		alloc_state->areas = new_state;
 		for (s = alloc_state->areas_size / 2; s < alloc_state->areas_size; s++)
 			alloc_state->areas[s].pva = NULL;
 	}
 
-	_reserve_area(ah, alloc_state, pva, required, ix_pva, unreserved);
+	if (!_reserve_area(ah, alloc_state, pva, required, ix_pva, unreserved))
+		return_0;
 
 	return 1;
 }
@@ -2506,8 +2513,9 @@ static int _is_condition(struct cmd_context *cmd __attribute__((unused)),
 	 * Only used for cling and contiguous policies (which only make one allocation per PV)
 	 * so it's safe to say all the available space is used.
 	 */
-	if (positional)
-		_reserve_required_area(pvmatch->ah, pvmatch->alloc_state, pvmatch->pva, pvmatch->pva->count, s, 0);
+	if (positional &&
+	    !_reserve_required_area(pvmatch->ah, pvmatch->alloc_state, pvmatch->pva, pvmatch->pva->count, s, 0))
+		return_0;
 
 	return 2;	/* Finished */
 }
@@ -2604,8 +2612,9 @@ static int _check_cling_to_alloced(struct alloc_handle *ah, const struct dm_conf
 		dm_list_iterate_items(aa, &ah->alloced_areas[s]) {
 			if ((!cling_tag_list_cn && (pva->map->pv == aa[0].pv)) ||
 			    (cling_tag_list_cn && _pvs_have_matching_tag(cling_tag_list_cn, pva->map->pv, aa[0].pv, 0))) {
-				if (positional)
-					_reserve_required_area(ah, alloc_state, pva, pva->count, s, 0);
+				if (positional &&
+				    !_reserve_required_area(ah, alloc_state, pva, pva->count, s, 0))
+					return_0;
 				return 1;
 			}
 		}



