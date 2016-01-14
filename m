From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 14 Jan 2016 10:35:18 +0000 (UTC)
Subject: master - snapshot: relocate alloc_snapshot_seg
Message-ID: <20160114103518.9D01660DBC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=753a496348828fd296f79af2cf4803eade5c375b
Commit:        753a496348828fd296f79af2cf4803eade5c375b
Parent:        8857b227645e97b7cb52ae8d007e87e07db58b4e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jan 7 12:16:18 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jan 14 11:34:05 2016 +0100

snapshot: relocate alloc_snapshot_seg

Move alloc_snapshot_seg to snapshot_manip and make it local static.
---
 lib/metadata/lv_alloc.h       |    3 ---
 lib/metadata/lv_manip.c       |   26 --------------------------
 lib/metadata/snapshot_manip.c |   24 +++++++++++++++++++++++-
 3 files changed, 23 insertions(+), 30 deletions(-)

diff --git a/lib/metadata/lv_alloc.h b/lib/metadata/lv_alloc.h
index 1ac3f1f..062a385 100644
--- a/lib/metadata/lv_alloc.h
+++ b/lib/metadata/lv_alloc.h
@@ -31,9 +31,6 @@ struct lv_segment *alloc_lv_segment(const struct segment_type *segtype,
 				    uint32_t extents_copied,
 				    struct lv_segment *pvmove_source_seg);
 
-struct lv_segment *alloc_snapshot_seg(struct logical_volume *lv,
-				      uint64_t status, uint32_t old_le_count);
-
 int set_lv_segment_area_pv(struct lv_segment *seg, uint32_t area_num,
 			   struct physical_volume *pv, uint32_t pe);
 int set_lv_segment_area_lv(struct lv_segment *seg, uint32_t area_num,
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 76e7895..dd9df3b 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1038,32 +1038,6 @@ struct lv_segment *alloc_lv_segment(const struct segment_type *segtype,
 	return seg;
 }
 
-struct lv_segment *alloc_snapshot_seg(struct logical_volume *lv,
-				      uint64_t status, uint32_t old_le_count)
-{
-	struct lv_segment *seg;
-	const struct segment_type *segtype;
-
-	segtype = get_segtype_from_string(lv->vg->cmd, SEG_TYPE_NAME_SNAPSHOT);
-	if (!segtype) {
-		log_error("Failed to find snapshot segtype");
-		return NULL;
-	}
-
-	if (!(seg = alloc_lv_segment(segtype, lv, old_le_count,
-				     lv->le_count - old_le_count, status, 0,
-				     NULL, 0, lv->le_count - old_le_count,
-				     0, 0, 0, NULL))) {
-		log_error("Couldn't allocate new snapshot segment.");
-		return NULL;
-	}
-
-	dm_list_add(&lv->segments, &seg->list);
-	lv->status |= VIRTUAL;
-
-	return seg;
-}
-
 static int _release_and_discard_lv_segment_area(struct lv_segment *seg, uint32_t s,
 						uint32_t area_reduction, int with_discard)
 {
diff --git a/lib/metadata/snapshot_manip.c b/lib/metadata/snapshot_manip.c
index 515a698..5c0aaed 100644
--- a/lib/metadata/snapshot_manip.c
+++ b/lib/metadata/snapshot_manip.c
@@ -214,6 +214,28 @@ void clear_snapshot_merge(struct logical_volume *origin)
 	origin->status &= ~MERGING;
 }
 
+static struct lv_segment *_alloc_snapshot_seg(struct logical_volume *lv)
+{
+	struct lv_segment *seg;
+	const struct segment_type *segtype;
+
+	segtype = get_segtype_from_string(lv->vg->cmd, SEG_TYPE_NAME_SNAPSHOT);
+	if (!segtype) {
+		log_error("Failed to find snapshot segtype");
+		return NULL;
+	}
+
+	if (!(seg = alloc_lv_segment(segtype, lv, 0, lv->le_count, 0, 0,
+				     NULL, 0, lv->le_count, 0, 0, 0, NULL))) {
+		log_error("Couldn't allocate new snapshot segment.");
+		return NULL;
+	}
+
+	dm_list_add(&lv->segments, &seg->list);
+
+	return seg;
+}
+
 int vg_add_snapshot(struct logical_volume *origin,
 		    struct logical_volume *cow, union lvid *lvid,
 		    uint32_t extent_count, uint32_t chunk_size)
@@ -241,7 +263,7 @@ int vg_add_snapshot(struct logical_volume *origin,
 
 	snap->le_count = extent_count;
 
-	if (!(seg = alloc_snapshot_seg(snap, 0, 0)))
+	if (!(seg = _alloc_snapshot_seg(snap)))
 		return_0;
 
 	init_snapshot_seg(seg, origin, cow, chunk_size, 0);


