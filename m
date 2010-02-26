From: Mike Snitzer <snitzer@redhat.com>
Date: Fri, 26 Feb 2010 16:04:22 -0500
Subject: [PATCH 3/3] Eliminate 'shared_snapshot' from 'struct logical_volume'.
In-Reply-To: <1267218262-23954-1-git-send-email-snitzer@redhat.com>
References: <1267218262-23954-1-git-send-email-snitzer@redhat.com>
Message-ID: <1267218262-23954-4-git-send-email-snitzer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Just use 'snapshot' for origin lv's reference to the shared snapshot
store; also set SNAPSHOT_SHARED in the origin lv's status.

Move SNAPSHOT_SHARED flag so it doesn't overlap with legacy hole in
flags.  Change 'snapshot_flags' to be 64bit.

Signed-off-by: Mike Snitzer <snitzer@gmail.com>
---
 lib/format_text/flags.c          |    1 +
 lib/metadata/lv_alloc.h          |    2 +-
 lib/metadata/lv_manip.c          |    3 +--
 lib/metadata/metadata-exported.h |    7 ++-----
 lib/metadata/snapshot_manip.c    |   17 ++++++++++++-----
 5 files changed, 17 insertions(+), 13 deletions(-)

diff --git a/lib/format_text/flags.c b/lib/format_text/flags.c
index a41dc1a..76095a6 100644
--- a/lib/format_text/flags.c
+++ b/lib/format_text/flags.c
@@ -61,6 +61,7 @@ static const struct flag _lv_flags[] = {
 	{MIRRORED, NULL, 0},
 	{VIRTUAL, NULL, 0},
 	{SNAPSHOT, NULL, 0},
+	{SNAPSHOT_SHARED, NULL, 0},
 	{MERGING, NULL, 0},
 	{ACTIVATE_EXCL, NULL, 0},
 	{CONVERTING, NULL, 0},
diff --git a/lib/metadata/lv_alloc.h b/lib/metadata/lv_alloc.h
index e65a08f..b6c9f86 100644
--- a/lib/metadata/lv_alloc.h
+++ b/lib/metadata/lv_alloc.h
@@ -30,7 +30,7 @@ struct lv_segment *alloc_lv_segment(struct dm_pool *mem,
 
 struct lv_segment *alloc_snapshot_seg(struct logical_volume *lv,
 				      uint64_t status, uint32_t old_le_count,
-				      uint32_t snapshot_flags);
+				      uint64_t snapshot_flags);
 
 int set_lv_segment_area_pv(struct lv_segment *seg, uint32_t area_num,
 			   struct physical_volume *pv, uint32_t pe);
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 77ccedb..dc32956 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -216,7 +216,7 @@ struct lv_segment *alloc_lv_segment(struct dm_pool *mem,
 
 struct lv_segment *alloc_snapshot_seg(struct logical_volume *lv,
 				      uint64_t status, uint32_t old_le_count,
-				      uint32_t snapshot_flags)
+				      uint64_t snapshot_flags)
 {
 	struct lv_segment *seg;
 	const struct segment_type *segtype;
@@ -1890,7 +1890,6 @@ struct logical_volume *alloc_lv(struct dm_pool *mem)
 	}
 
 	lv->snapshot = NULL;
-	lv->shared_snapshot = NULL;
 	dm_list_init(&lv->snapshot_segs);
 	dm_list_init(&lv->segments);
 	dm_list_init(&lv->tags);
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index c6ad213..b0d3f85 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -61,7 +61,6 @@
 //#define ACTIVATE_EXCL		0x00100000U	/* LV - internal use only */
 //#define PRECOMMITTED		0x00200000U	/* VG - internal use only */
 #define CONVERTING		0x00400000U	/* LV */
-#define SNAPSHOT_SHARED		0x02000000U	/* SEG */
 
 #define MISSING_PV              0x00800000U	/* PV */
 #define PARTIAL_LV              0x01000000U	/* LV - derived flag, not
@@ -72,6 +71,7 @@
 //#define VIRTUAL_ORIGIN	0x08000000U	/* LV - internal use only */
 
 #define MERGING			0x10000000U	/* LV SEG */
+#define SNAPSHOT_SHARED		0x20000000U	/* LV SEG */
 
 #define LVM_READ              	0x00000100U	/* LV VG */
 #define LVM_WRITE             	0x00000200U	/* LV VG */
@@ -335,9 +335,6 @@ struct logical_volume {
 	struct dm_list snapshot_segs;
 	struct lv_segment *snapshot;
 
-	/* A shared-snapshot segment for this origin */
-	struct lv_segment *shared_snapshot;
-
 	struct dm_list segments;
 	struct dm_list tags;
 	struct dm_list segs_using_this_lv;
@@ -661,7 +658,7 @@ void clear_snapshot_merge(struct logical_volume *origin);
 int vg_add_snapshot(struct logical_volume *origin, struct logical_volume *cow,
 		    union lvid *lvid, uint32_t extent_count,
 		    const char *exception_store, uint32_t chunk_size,
-		    unsigned snapshot_flags);
+		    uint64_t snapshot_flags);
 
 int vg_remove_snapshot(struct logical_volume *cow);
 
diff --git a/lib/metadata/snapshot_manip.c b/lib/metadata/snapshot_manip.c
index 66adfeb..443fffa 100644
--- a/lib/metadata/snapshot_manip.c
+++ b/lib/metadata/snapshot_manip.c
@@ -32,7 +32,7 @@ int lv_is_cow(const struct logical_volume *lv)
 
 int lv_is_multisnap_origin(const struct logical_volume *lv)
 {
-	return lv_is_origin(lv) && lv->shared_snapshot;
+	return lv_is_origin(lv) && (lv->status & SNAPSHOT_SHARED);
 }
 
 int lv_is_multisnap_cow(const struct logical_volume *lv)
@@ -58,6 +58,9 @@ int lv_is_visible(const struct logical_volume *lv)
 		if (lv_is_merging_cow(lv))
 			return 0;
 
+		if (lv_is_shared_cow(lv))
+			return 0;
+
 		return lv_is_visible(origin_from_cow(lv));
 	}
 
@@ -99,7 +102,7 @@ struct lv_segment *find_shared_cow(const struct logical_volume *origin)
 	if (!lv_is_multisnap_origin(origin))
 		return NULL;
 
-	return origin->shared_snapshot;
+	return find_cow(origin);
 }
 
 /* Given a cow LV, return its origin */
@@ -111,12 +114,16 @@ struct logical_volume *origin_from_cow(const struct logical_volume *lv)
 static void init_shared_snapshot(struct lv_segment *cow_seg,
 				 struct logical_volume *origin)
 {
-	origin->shared_snapshot = cow_seg;
+	/* Clear VISIBLE_LV for the same reasons as init_snapshot_merge */
+	cow_seg->lv->status &= ~VISIBLE_LV;
+	origin->snapshot = cow_seg;
+	origin->status |= SNAPSHOT_SHARED;
 }
 
 static void clear_shared_snapshot(struct logical_volume *origin)
 {
-	origin->shared_snapshot = NULL;
+	origin->snapshot = NULL;
+	origin->status &= ~SNAPSHOT_SHARED;
 }
 
 int init_snapshot_seg(struct lv_segment *seg, struct logical_volume *origin,
@@ -194,7 +201,7 @@ void clear_snapshot_merge(struct logical_volume *origin)
 int vg_add_snapshot(struct logical_volume *origin,
 		    struct logical_volume *cow, union lvid *lvid,
 		    uint32_t extent_count, const char *exception_store,
-		    uint32_t chunk_size, unsigned snapshot_flags)
+		    uint32_t chunk_size, uint64_t snapshot_flags)
 {
 	struct logical_volume *snap;
 	struct lv_segment *seg;
-- 
1.6.5.2


