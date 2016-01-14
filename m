From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 14 Jan 2016 10:35:12 +0000 (UTC)
Subject: master - lvmanip: add lv_is_snapshot
Message-ID: <20160114103512.41A6460DBC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=526297296fb05bd8aea58f8b3d08a14045bf74e2
Commit:        526297296fb05bd8aea58f8b3d08a14045bf74e2
Parent:        01228b692be6850645b91811bbf30366241b036c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jan 7 14:30:21 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jan 14 11:34:04 2016 +0100

lvmanip: add lv_is_snapshot

Add new test for  lv_is_snapshot().
Also move few other bitchecks into same place as remaining bit tests.

TODO: drop lv_is_merging_origin() and keep using lv_is_merging().
---
 lib/metadata/metadata-exported.h |    9 +++++----
 lib/metadata/metadata.h          |    1 -
 lib/metadata/snapshot_manip.c    |   16 +++-------------
 3 files changed, 8 insertions(+), 18 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 8242db1..8785f99 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -84,7 +84,7 @@
 
 //#define POSTORDER_FLAG	UINT64_C(0x0000000002000000) /* Not real flags, reserved for
 //#define POSTORDER_OPEN_FLAG	UINT64_C(0x0000000004000000)    temporary use inside vg_read_internal. */
-//#define VIRTUAL_ORIGIN	UINT64_C(0x0000000008000000)	/* LV - internal use only */
+#define VIRTUAL_ORIGIN		UINT64_C(0x0000000008000000)	/* LV - internal use only */
 
 #define MERGING			UINT64_C(0x0000000010000000)	/* LV SEG */
 
@@ -191,8 +191,11 @@
 #define lv_is_locked(lv)	(((lv)->status & LOCKED) ? 1 : 0)
 #define lv_is_virtual(lv)	(((lv)->status & VIRTUAL) ? 1 : 0)
 #define lv_is_merging(lv)	(((lv)->status & MERGING) ? 1 : 0)
+#define lv_is_merging_origin(lv) (lv_is_merging(lv))
+#define lv_is_snapshot(lv)	(((lv)->status & SNAPSHOT) ? 1 : 0)
 #define lv_is_converting(lv)	(((lv)->status & CONVERTING) ? 1 : 0)
 #define lv_is_external_origin(lv)	(((lv)->external_count > 0) ? 1 : 0)
+#define lv_is_virtual_origin(lv) (((lv)->status & VIRTUAL_ORIGIN) ? 1 : 0)
 
 #define lv_is_thin_volume(lv)	(((lv)->status & THIN_VOLUME) ? 1 : 0)
 #define lv_is_thin_pool(lv)	(((lv)->status & THIN_POOL) ? 1 : 0)
@@ -1004,12 +1007,10 @@ struct lv_segment *get_only_segment_using_this_lv(const struct logical_volume *l
 * Useful functions for managing snapshots.
 */
 int lv_is_origin(const struct logical_volume *lv);
-int lv_is_virtual_origin(const struct logical_volume *lv);
 int lv_is_thin_origin(const struct logical_volume *lv, unsigned *snapshot_count);
 int lv_is_cache_origin(const struct logical_volume *lv);
 int lv_is_cow(const struct logical_volume *lv);
-int lv_is_merging_origin(const struct logical_volume *origin);
-int lv_is_merging_cow(const struct logical_volume *snapshot);
+int lv_is_merging_cow(const struct logical_volume *cow);
 uint32_t cow_max_extents(const struct logical_volume *origin, uint32_t chunk_size);
 int cow_has_min_chunks(const struct volume_group *vg, uint32_t cow_extents, uint32_t chunk_size);
 int lv_is_cow_covering_origin(const struct logical_volume *lv);
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index e19bd16..f154d5c 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -61,7 +61,6 @@
 #define PRECOMMITTED		UINT64_C(0x00200000)	/* VG - internal use only */
 #define POSTORDER_FLAG		UINT64_C(0x02000000) /* Not real flags, reserved for  */
 #define POSTORDER_OPEN_FLAG	UINT64_C(0x04000000) /* temporary use inside vg_read_internal. */
-#define VIRTUAL_ORIGIN		UINT64_C(0x08000000)	/* LV - internal use only */
 
 #define SHARED            	UINT64_C(0x00000800)	/* VG */
 
diff --git a/lib/metadata/snapshot_manip.c b/lib/metadata/snapshot_manip.c
index 8245619..515a698 100644
--- a/lib/metadata/snapshot_manip.c
+++ b/lib/metadata/snapshot_manip.c
@@ -129,21 +129,11 @@ int lv_is_visible(const struct logical_volume *lv)
 	return lv->status & VISIBLE_LV ? 1 : 0;
 }
 
-int lv_is_virtual_origin(const struct logical_volume *lv)
+int lv_is_merging_cow(const struct logical_volume *cow)
 {
-	return (lv->status & VIRTUAL_ORIGIN) ? 1 : 0;
-}
-
-int lv_is_merging_origin(const struct logical_volume *origin)
-{
-	return lv_is_merging(origin);
-}
-
-int lv_is_merging_cow(const struct logical_volume *snapshot)
-{
-	struct lv_segment *snap_seg = find_snapshot(snapshot);
+	struct lv_segment *snap_seg = find_snapshot(cow);
 
-	/* checks lv_segment's status to see if cow is merging */
+	/* checks lv_segment's status to see if snapshot is merging */
 	return (snap_seg && (snap_seg->status & MERGING)) ? 1 : 0;
 }
 


