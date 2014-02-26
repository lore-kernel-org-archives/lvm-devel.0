From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 26 Feb 2014 13:25:48 +0000 (UTC)
Subject: master - snapshots: fix incorrect calculation of cow size
Message-ID: <20140226132548.511EA612BE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=40e6176d251b68f5be8ca7925a2f073982de6cec
Commit:        40e6176d251b68f5be8ca7925a2f073982de6cec
Parent:        014ba37cb19c9172b1b81af3f31897939f72b1d2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 25 19:43:07 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 26 14:25:09 2014 +0100

snapshots: fix incorrect calculation of cow size

Code uses target driver version for better estimation of
max size of COW device for snapshot.

The bug can be tested with this script:
VG=vg1
lvremove -f $VG/origin
set -e
lvcreate -L 2143289344b -n origin $VG
lvcreate -n snap -c 8k -L 2304M -s $VG/origin
dd if=/dev/zero of=/dev/$VG/snap bs=1M count=2044 oflag=direct

The bug happens when these two conditions are met
* origin size is divisible by (chunk_size/16) - so that the last
  metadata area is filled completely
* the miscalculated snapshot metadata size is divisible by extent size -
  so that there is no padding to extent boundary which would otherwise
  save us

Signed-off-by:Mikulas Patocka <mpatocka@redhat.com>
---
 WHATS_NEW                     |    1 +
 lib/activate/activate.h       |    5 ++++
 lib/metadata/snapshot_manip.c |   43 ++++++++++++++++++++++++++++++----------
 lib/snapshot/snapshot.c       |   15 ++++++++++++-
 test/shell/snapshot-usage.sh  |    2 +-
 5 files changed, 52 insertions(+), 14 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 9a3da75..224e351 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Fix calculation of maximum size of COW device for snapshot (2.02.99).
   Do not allow stripe size to be bigger then extent size for lvresize.
   Zero snapshot COW header when creating read-only snapshot.
   Comment out config lines in dumpconfig output without default values defined.
diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index c3cf3d9..ad14a57 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -55,6 +55,11 @@ struct lv_activate_opts {
 /* target attribute flags */
 #define MIRROR_LOG_CLUSTERED	0x00000001U
 
+/* snapshot target attribute flags */
+enum {
+	SNAPSHOT_FEATURE_FIXED_LEAK		= (1 << 0), /* version 1.12 */
+};
+
 /* thin target attribute flags */
 enum {
 	/* bitfields - new features from 1.1 version */
diff --git a/lib/metadata/snapshot_manip.c b/lib/metadata/snapshot_manip.c
index 362c805..25fee76 100644
--- a/lib/metadata/snapshot_manip.c
+++ b/lib/metadata/snapshot_manip.c
@@ -32,7 +32,26 @@ int lv_is_cow(const struct logical_volume *lv)
 	return (!lv_is_thin_volume(lv) && !lv_is_origin(lv) && lv->snapshot) ? 1 : 0;
 }
 
-static uint64_t _cow_max_size(uint64_t origin_size, uint32_t chunk_size)
+/*
+ * Some kernels have a bug that they may leak space in the snapshot on crash.
+ * If the kernel is buggy, we add some extra space.
+ */
+static uint64_t _cow_extra_chunks(struct cmd_context *cmd, uint64_t n_chunks)
+{
+	const struct segment_type *segtype;
+	unsigned attrs;
+
+	if (activation() &&
+	    (segtype = get_segtype_from_string(cmd, "snapshot")) &&
+	    segtype->ops->target_present &&
+	    segtype->ops->target_present(cmd, NULL, &attrs) &&
+	    (attrs & SNAPSHOT_FEATURE_FIXED_LEAK))
+		return (n_chunks + 63) / 64;
+
+	return 0;
+}
+
+static uint64_t _cow_max_size(struct cmd_context *cmd, uint64_t origin_size, uint32_t chunk_size)
 {
 	/* Snapshot disk layout:
 	 *    COW is divided into chunks
@@ -41,21 +60,22 @@ static uint64_t _cow_max_size(uint64_t origin_size, uint32_t chunk_size)
 	 *        3rd. chunk is the 1st. data chunk
 	 */
 
-	/* Size of metadata for snapshot in sectors */
-	uint64_t mdata_size = ((origin_size + chunk_size - 1) / chunk_size * 16 + 511) >> SECTOR_SHIFT;
+	uint64_t origin_chunks = (origin_size + chunk_size - 1) / chunk_size;
+	uint64_t chunks_per_metadata_area = (uint64_t)chunk_size << (SECTOR_SHIFT - 4);
 
-	/* Sum all chunks - header + metadata size + origin size (aligned on chunk boundary) */
-	uint64_t size = chunk_size +
-		((mdata_size + chunk_size - 1) & ~(uint64_t)(chunk_size - 1)) +
-		((origin_size + chunk_size - 1) & ~(uint64_t)(chunk_size - 1));
+	/*
+	 * Note: if origin_chunks is divisible by chunks_per_metadata_area, we
+	 * need one extra metadata chunk as a terminator.
+	 */
+	uint64_t metadata_chunks = (origin_chunks + chunks_per_metadata_area) / chunks_per_metadata_area;
+	uint64_t n_chunks = 1 + origin_chunks + metadata_chunks;
 
-	/* Does not overflow since size is in sectors (9 bits) */
-	return size;
+	return (n_chunks + _cow_extra_chunks(cmd, n_chunks)) * chunk_size;
 }
 
 uint32_t cow_max_extents(const struct logical_volume *origin, uint32_t chunk_size)
 {
-	uint64_t size = _cow_max_size(origin->size, chunk_size);
+	uint64_t size = _cow_max_size(origin->vg->cmd, origin->size, chunk_size);
 	uint32_t extent_size = origin->vg->extent_size;
 	uint64_t max_size = (uint64_t) MAX_EXTENT_COUNT * extent_size;
 
@@ -71,7 +91,8 @@ uint32_t cow_max_extents(const struct logical_volume *origin, uint32_t chunk_siz
 int lv_is_cow_covering_origin(const struct logical_volume *lv)
 {
 	return lv_is_cow(lv) &&
-		(lv->size >= _cow_max_size(origin_from_cow(lv)->size, find_snapshot(lv)->chunk_size));
+		(lv->size >= _cow_max_size(lv->vg->cmd, origin_from_cow(lv)->size,
+					   find_snapshot(lv)->chunk_size));
 }
 
 int lv_is_visible(const struct logical_volume *lv)
diff --git a/lib/snapshot/snapshot.c b/lib/snapshot/snapshot.c
index 91e778f..0b7b845 100644
--- a/lib/snapshot/snapshot.c
+++ b/lib/snapshot/snapshot.c
@@ -142,19 +142,30 @@ static int _snap_target_percent(void **target_state __attribute__((unused)),
 
 static int _snap_target_present(struct cmd_context *cmd,
 				const struct lv_segment *seg,
-				unsigned *attributes __attribute__((unused)))
+				unsigned *attributes)
 {
 	static int _snap_checked = 0;
 	static int _snap_merge_checked = 0;
 	static int _snap_present = 0;
 	static int _snap_merge_present = 0;
+	static unsigned _snap_attrs = 0;
+	uint32_t maj, min, patchlevel;
 
 	if (!_snap_checked) {
+		_snap_checked = 1;
 		_snap_present = target_present(cmd, "snapshot", 1) &&
 		    target_present(cmd, "snapshot-origin", 0);
-		_snap_checked = 1;
+
+		if (_snap_present &&
+		    target_version("snapshot", &maj, &min, &patchlevel) &&
+		    (maj > 1 ||
+		     (maj == 1 && (min >= 12 || (min == 10 && patchlevel >= 2)))))
+			_snap_attrs |= SNAPSHOT_FEATURE_FIXED_LEAK;
+		else
+			log_very_verbose("Target snapshot may leak metadata.");
 	}
 
+	/* TODO: test everything at once */
 	if (seg && (seg->status & MERGING)) {
 		if (!_snap_merge_checked) {
 			_snap_merge_present = target_present(cmd, "snapshot-merge", 0);
diff --git a/test/shell/snapshot-usage.sh b/test/shell/snapshot-usage.sh
index 4d15fb1..cb60556 100644
--- a/test/shell/snapshot-usage.sh
+++ b/test/shell/snapshot-usage.sh
@@ -110,7 +110,7 @@ lvextend --use-policies $vg1/lvol1
 check lv_field $vg1/lvol1 size "18.00k"
 
 lvextend -l+33 $vg1/lvol1
-check lv_field $vg1/lvol1 size "28.00k"
+check lv_field $vg1/lvol1 size "32.00k"
 
 fill 20K
 lvremove -f $vg1


