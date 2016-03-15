From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 15 Mar 2016 22:23:44 +0000 (UTC)
Subject: master - lvresize: fix stacked resize
Message-ID: <20160315222344.D88C260D3A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=51ed48f8551cf32539765b5057bb20cc8d9a8777
Commit:        51ed48f8551cf32539765b5057bb20cc8d9a8777
Parent:        746f8af2a836e662e5588a37feb29c27ed02261b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 15 23:13:28 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 15 23:21:16 2016 +0100

lvresize: fix stacked resize

Commit b64703401da1f4bef60579a0b3766c087fcfe96a cause regression
when handling stacked resize of pool metadata volume that would
be a raid LV.

Fix it by properly setting up size also for layer extension.
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |   43 ++++++++++++++++++++++++++++---------------
 2 files changed, 29 insertions(+), 15 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 23d8787..d49e935 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.147 - 
 ==================================
+  Fix resize of stacked raid thin data volume (2.02.141).
   Fix test for lvremove failure in lvconvert --uncache (2.02.146).
 
 Version 2.02.146 - 11th March 2016
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 91a010c..1baf548 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1704,6 +1704,28 @@ static int _log_parallel_areas(struct dm_pool *mem, struct dm_list *parallel_are
 	return 1;
 }
 
+/* Handles also stacking */
+static int _setup_lv_size(struct logical_volume *lv, uint32_t extents)
+{
+	struct lv_segment *thin_pool_seg;
+
+	lv->le_count = extents;
+	lv->size = (uint64_t) extents * lv->vg->extent_size;
+
+	if (lv_is_thin_pool_data(lv)) {
+		if (!(thin_pool_seg = get_only_segment_using_this_lv(lv)))
+			return_0;
+
+		/* Update thin pool segment from the layered LV */
+		thin_pool_seg->lv->le_count =
+			thin_pool_seg->len =
+			thin_pool_seg->area_len = lv->le_count;
+		thin_pool_seg->lv->size = lv->size;
+	}
+
+	return 1;
+}
+
 static int _setup_alloced_segment(struct logical_volume *lv, uint64_t status,
 				  uint32_t area_count,
 				  uint32_t stripe_size,
@@ -1712,7 +1734,7 @@ static int _setup_alloced_segment(struct logical_volume *lv, uint64_t status,
 				  uint32_t region_size)
 {
 	uint32_t s, extents, area_multiple;
-	struct lv_segment *seg, *thin_pool_seg;
+	struct lv_segment *seg;
 
 	area_multiple = _calc_area_multiple(segtype, area_count, 0);
 	extents = aa[0].len * area_multiple;
@@ -1732,19 +1754,9 @@ static int _setup_alloced_segment(struct logical_volume *lv, uint64_t status,
 	dm_list_add(&lv->segments, &seg->list);
 
 	extents = aa[0].len * area_multiple;
-	lv->le_count += extents;
-	lv->size += (uint64_t) extents * lv->vg->extent_size;
-
-	if (lv_is_thin_pool_data(lv)) {
-		if (!(thin_pool_seg = get_only_segment_using_this_lv(lv)))
-			return_0;
 
-		/* Update thin pool segment from the layered LV */
-		thin_pool_seg->lv->le_count =
-			thin_pool_seg->len =
-			thin_pool_seg->area_len = lv->le_count;
-		thin_pool_seg->lv->size = lv->size;
-	}
+	if (!_setup_lv_size(lv, lv->le_count + extents))
+		return_0;
 
 	return 1;
 }
@@ -3875,8 +3887,9 @@ static int _lv_extend_layered_lv(struct alloc_handle *ah,
 
 	seg->area_len += extents;
 	seg->len += extents;
-	lv->le_count += extents;
-	lv->size += (uint64_t) extents * lv->vg->extent_size;
+
+	if (!_setup_lv_size(lv, lv->le_count + extents))
+		return_0;
 
 	/*
 	 * The MD bitmap is limited to being able to track 2^21 regions.


