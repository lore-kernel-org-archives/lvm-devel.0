From: Guangliang Zhao <gzhao@suse.com>
Date: Mon, 17 Dec 2012 20:44:24 +0800
Subject: [PATCH 2/2] mirror: improve mirror legs on different tag pvs
In-Reply-To: <1355748264-17077-1-git-send-email-gzhao@suse.com>
References: <1355748264-17077-1-git-send-email-gzhao@suse.com>
Message-ID: <1355748264-17077-3-git-send-email-gzhao@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch will find the biggest eligible area every time,
and add it to the parallel areas.

The previous just find the different tag pv area with all
found ones, if the new area's tag has appeared, just throw
it. The new will compare the length, and choose the longer
one.

Signed-off-by: Guangliang Zhao <gzhao@suse.com>
---
 lib/metadata/lv_manip.c |   25 ++++++++++++++++++++++---
 1 file changed, 22 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index fb0199f..edafdf1 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1658,6 +1658,21 @@ static uint32_t _calc_required_extents(struct alloc_handle *ah, struct pv_area *
 	return required;
 }
 
+static void _replace_required_area(struct alloc_handle *ah, uint32_t max_to_allocate,
+				   unsigned ix_pva, struct pv_area *pva,
+				   struct alloc_state *alloc_state, alloc_policy_t alloc)
+{
+	uint32_t required = _calc_required_extents(ah, pva, ix_pva, max_to_allocate, alloc);
+
+	/*
+	 * We don't worry about the area replaced, because _clear_areas() and
+	 * _reset_unreserved() called by _find_some_parallel_space() will clear
+	 * the alloc_state and reserved areas every time.
+	 */
+	if (required > alloc_state->areas[ix_pva - 1].used)
+		_reserve_area(&alloc_state->areas[ix_pva - 1], pva, required, ix_pva, pva->unreserved);
+}
+
 static int _reserve_required_area(struct alloc_handle *ah, uint32_t max_to_allocate,
 				  unsigned ix_pva, struct pv_area *pva,
 				  struct alloc_state *alloc_state, alloc_policy_t alloc)
@@ -1767,6 +1782,7 @@ static int _find_some_parallel_space(struct alloc_handle *ah, const struct alloc
 {
 	unsigned ix = 0;
 	unsigned last_ix;
+	int ret;
 	struct pv_map *pvm;
 	struct pv_area *pva;
 	unsigned preferred_count = 0;
@@ -1875,9 +1891,12 @@ static int _find_some_parallel_space(struct alloc_handle *ah, const struct alloc
 					continue;
 
 				case USE_AREA:
-					if(check_areas_separate_tags(ah, alloc_state, ix_offset,
-								     ix + ix_offset, pva) >= 0)
-						goto next_pv;
+					if((ret = check_areas_separate_tags(ah, alloc_state, ix_offset,
+									    ix + ix_offset, pva)) >= 0) {
+						_replace_required_area(ah, max_to_allocate, ret + 1,
+								       pva, alloc_state, alloc_parms->alloc);
+						continue;
+					}
 
 					/*
 					 * Except with ALLOC_ANYWHERE, replace first area with this
-- 
1.7.10.4


