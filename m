From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu, 26 Mar 2015 21:15:29 +0000 (UTC)
Subject: master - alloc: Pass alloc_handle through to _reserve_area.
Message-ID: <20150326211529.869FF601C4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e8fa3354f09c137b14fe2d11f0892de5f7cedec6
Commit:        e8fa3354f09c137b14fe2d11f0892de5f7cedec6
Parent:        f9d74ba3d1601e55da48e34a3a9d7587d0ec3fe4
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Mar 26 20:32:59 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Mar 26 20:32:59 2015 +0000

alloc: Pass alloc_handle through to _reserve_area.

---
 lib/metadata/lv_manip.c |   25 ++++++++++++++-----------
 1 files changed, 14 insertions(+), 11 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 67f5f91..b80bcae 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1955,6 +1955,7 @@ static int _comp_area(const void *l, const void *r)
 struct pv_match {
 	int (*condition)(struct pv_match *pvmatch, struct pv_segment *pvseg, struct pv_area *pva);
 
+	struct alloc_handle *ah;
 	struct alloc_state *alloc_state;
 	struct pv_area *pva;
 	const struct dm_config_node *cling_tag_list_cn;
@@ -2077,8 +2078,8 @@ static int _is_contiguous(struct pv_match *pvmatch __attribute((unused)), struct
 	return 1;
 }
 
-static void _reserve_area(struct alloc_state *alloc_state, struct pv_area *pva, uint32_t required,
-			  uint32_t ix_pva, uint32_t unreserved)
+static void _reserve_area(struct alloc_handle *ah, struct alloc_state *alloc_state, struct pv_area *pva,
+			  uint32_t required, uint32_t ix_pva, uint32_t unreserved)
 {
 	struct pv_area_used *area_used = &alloc_state->areas[ix_pva];
 
@@ -2092,8 +2093,8 @@ static void _reserve_area(struct alloc_state *alloc_state, struct pv_area *pva,
 	area_used->used = required;
 }
 
-static int _reserve_required_area(struct alloc_state *alloc_state, struct pv_area *pva, uint32_t required,
-				  uint32_t ix_pva, uint32_t unreserved)
+static int _reserve_required_area(struct alloc_handle *ah, struct alloc_state *alloc_state, struct pv_area *pva,
+				  uint32_t required, uint32_t ix_pva, uint32_t unreserved)
 {
 	uint32_t s;
 
@@ -2108,7 +2109,7 @@ static int _reserve_required_area(struct alloc_state *alloc_state, struct pv_are
 			alloc_state->areas[s].pva = NULL;
 	}
 
-	_reserve_area(alloc_state, pva, required, ix_pva, unreserved);
+	_reserve_area(ah, alloc_state, pva, required, ix_pva, unreserved);
 
 	return 1;
 }
@@ -2134,7 +2135,7 @@ static int _is_condition(struct cmd_context *cmd __attribute__((unused)),
 	 * so it's safe to say all the available space is used.
 	 */
 	if (positional)
-		_reserve_required_area(pvmatch->alloc_state, pvmatch->pva, pvmatch->pva->count, s, 0);
+		_reserve_required_area(pvmatch->ah, pvmatch->alloc_state, pvmatch->pva, pvmatch->pva->count, s, 0);
 
 	return 2;	/* Finished */
 }
@@ -2151,6 +2152,7 @@ static int _check_cling(struct alloc_handle *ah,
 	int r;
 	uint32_t le, len;
 
+	pvmatch.ah = ah;
 	pvmatch.condition = cling_tag_list_cn ? _has_matching_pv_tag : _is_same_pv;
 	pvmatch.alloc_state = alloc_state;
 	pvmatch.pva = pva;
@@ -2181,20 +2183,21 @@ static int _check_cling(struct alloc_handle *ah,
 /*
  * Is pva contiguous to any existing areas or on the same PV?
  */
-static int _check_contiguous(struct cmd_context *cmd,
+static int _check_contiguous(struct alloc_handle *ah,
 			     struct lv_segment *prev_lvseg, struct pv_area *pva,
 			     struct alloc_state *alloc_state)
 {
 	struct pv_match pvmatch;
 	int r;
 
+	pvmatch.ah = ah;
 	pvmatch.condition = _is_contiguous;
 	pvmatch.alloc_state = alloc_state;
 	pvmatch.pva = pva;
 	pvmatch.cling_tag_list_cn = NULL;
 
 	/* FIXME Cope with stacks by flattening */
-	if (!(r = _for_each_pv(cmd, prev_lvseg->lv,
+	if (!(r = _for_each_pv(ah->cmd, prev_lvseg->lv,
 			       prev_lvseg->le + prev_lvseg->len - 1, 1, NULL, NULL,
 			       0, 0, -1, 1,
 			       _is_condition, &pvmatch)))
@@ -2230,7 +2233,7 @@ static int _check_cling_to_alloced(struct alloc_handle *ah, const struct dm_conf
 			if ((!cling_tag_list_cn && (pva->map->pv == aa[0].pv)) ||
 			    (cling_tag_list_cn && _pvs_have_matching_tag(cling_tag_list_cn, pva->map->pv, aa[0].pv))) {
 				if (positional)
-					_reserve_required_area(alloc_state, pva, pva->count, s, 0);
+					_reserve_required_area(ah, alloc_state, pva, pva->count, s, 0);
 				return 1;
 			}
 		}
@@ -2279,7 +2282,7 @@ static area_use_t _check_pva(struct alloc_handle *ah, struct pv_area *pva, uint3
 		/* Contiguous? */
 		if (((alloc_parms->flags & A_CONTIGUOUS_TO_LVSEG) ||
 		     (ah->maximise_cling && (alloc_parms->flags & A_AREA_COUNT_MATCHES))) &&
-		    _check_contiguous(ah->cmd, alloc_parms->prev_lvseg, pva, alloc_state))
+		    _check_contiguous(ah, alloc_parms->prev_lvseg, pva, alloc_state))
 			goto found;
 
 		/* Try next area on same PV if looking for contiguous space */
@@ -2556,7 +2559,7 @@ static int _find_some_parallel_space(struct alloc_handle *ah,
 
 					/* Reserve required amount of pva */
 					required = _calc_required_extents(ah, pva, ix + ix_offset - 1, max_to_allocate, alloc_parms->alloc);
-					if (!_reserve_required_area(alloc_state, pva, required, ix + ix_offset - 1, pva->unreserved))
+					if (!_reserve_required_area(ah, alloc_state, pva, required, ix + ix_offset - 1, pva->unreserved))
 						return_0;
 				}
 


