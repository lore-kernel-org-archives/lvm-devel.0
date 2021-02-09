From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  9 Feb 2021 14:06:50 +0000 (GMT)
Subject: stable-2.02 - lv_manip: reuse function also during reduction
Message-ID: <20210209140650.07B4E383543D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d3a9bf4a56716072dbb2d9fdc6abe4d0d89dc95e
Commit:        d3a9bf4a56716072dbb2d9fdc6abe4d0d89dc95e
Parent:        619ad644ccfe08e91be98ef10f13ecd0caeb956b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Feb 5 11:37:52 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 9 14:56:10 2021 +0100

lv_manip: reuse function also during reduction

Move function _setup_lv_size() in front of _lv_reduce() so
it can be reused also in this function.
Avoid propagating 0 length to upper layer.
---
 lib/metadata/lv_manip.c | 58 ++++++++++++++++++++++++-------------------------
 1 file changed, 28 insertions(+), 30 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index e0bc61fa2..6f21d10b9 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1317,6 +1317,29 @@ static int _lv_segment_reduce(struct lv_segment *seg, uint32_t reduction)
 	return 1;
 }
 
+/* Handles also stacking */
+static int _setup_lv_size(struct logical_volume *lv, uint32_t extents)
+{
+	struct lv_segment *seg;
+
+	lv->le_count = extents;
+	lv->size = (uint64_t) extents * lv->vg->extent_size;
+
+	if (lv->size &&
+	    (lv_is_thin_pool_data(lv))) {
+		if (!(seg = get_only_segment_using_this_lv(lv)))
+			return_0;
+
+		/* Update pool segment from the layered LV */
+		seg->lv->le_count =
+			seg->len =
+			seg->area_len = lv->le_count;
+		seg->lv->size = lv->size;
+	}
+
+	return 1;
+}
+
 /*
  * Entry point for all LV reductions in size.
  */
@@ -1397,18 +1420,15 @@ static int _lv_reduce(struct logical_volume *lv, uint32_t extents, int delete)
 		count -= reduction;
 	}
 
-	seg = first_seg(lv);
+	if (!_setup_lv_size(lv, lv->le_count - extents * (is_raid10 ? data_copies : 1)))
+		return_0;
 
-	if (is_raid10) {
-		lv->le_count -= extents * data_copies;
-		if (seg)
+	if ((seg = first_seg(lv))) {
+		if (is_raid10)
 			seg->len = seg->area_len = lv->le_count;
-	} else
-		lv->le_count -= extents;
 
-	lv->size = (uint64_t) lv->le_count * lv->vg->extent_size;
-	if (seg)
 		seg->extents_copied = seg->len;
+	}
 
 	if (!delete)
 		return 1;
@@ -1795,28 +1815,6 @@ static void _init_alloc_parms(struct alloc_handle *ah,
 		alloc_parms->flags |= A_CAN_SPLIT;
 }
 
-/* Handles also stacking */
-static int _setup_lv_size(struct logical_volume *lv, uint32_t extents)
-{
-	struct lv_segment *thin_pool_seg;
-
-	lv->le_count = extents;
-	lv->size = (uint64_t) extents * lv->vg->extent_size;
-
-	if (lv_is_thin_pool_data(lv)) {
-		if (!(thin_pool_seg = get_only_segment_using_this_lv(lv)))
-			return_0;
-
-		/* Update thin pool segment from the layered LV */
-		thin_pool_seg->lv->le_count =
-			thin_pool_seg->len =
-			thin_pool_seg->area_len = lv->le_count;
-		thin_pool_seg->lv->size = lv->size;
-	}
-
-	return 1;
-}
-
 static int _setup_alloced_segment(struct logical_volume *lv, uint64_t status,
 				  uint32_t area_count,
 				  uint32_t stripe_size,


