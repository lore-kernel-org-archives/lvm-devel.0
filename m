From: Mike Snitzer <snitzer@redhat.com>
Date: Fri, 20 Nov 2009 17:35:43 -0500
Subject: [PATCH 03/15] Add support for "snapshot-merge" target.
In-Reply-To: <1258756555-14486-1-git-send-email-snitzer@redhat.com>
References: <1258756555-14486-1-git-send-email-snitzer@redhat.com>
Message-ID: <1258756555-14486-4-git-send-email-snitzer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Introduces new libdevmapper function dm_tree_node_add_snapshot_merge_target

Verifies that the kernel (dm-snapshot) provides the 'snapshot-merge'
target.

Activate origin LV as snapshot-merge target.  Using snapshot-origin
target would be pointless because the origin contains volatile data
while a merge is in progress.

Because snapshot-merge target is activated in place of the
snapshot-origin target it must be resumed after all other snapshots
(just like snapshot-origin does) --- otherwise small window for data
corruption would exist.

Ideally the merging snapshot would not be activated at all but if it is
to be activated (because snapshot was already active) it _must_ be done
after the snapshot-merge.  This insures that DM's snapshot-merge target
will perform exception handover in the proper order (new->resume before
old->resume).  DM's snapshot-merge does support handover if the reverse
sequence is used (old->resume before new->resume) but DM will fail to
resume the old snapshot; leaving it suspended.

To insure the proper activation sequence dm_tree_activate_children() was
updated to accommodate an additional 'activation_priority' level.  All
regular snapshots are 0, snapshot-merge is 1, and merging snapshot is 2.

Signed-off-by: Mike Snitzer <snitzer@redhat.com>
Cc: Mikulas Patocka <mpatocka@redhat.com>
---
 lib/snapshot/snapshot.c |    8 ++++-
 libdm/.exported_symbols |    1 +
 libdm/libdevmapper.h    |    6 ++++
 libdm/libdm-deptree.c   |   72 ++++++++++++++++++++++++++++++++++++++++------
 4 files changed, 76 insertions(+), 11 deletions(-)

diff --git a/lib/snapshot/snapshot.c b/lib/snapshot/snapshot.c
index 8a3378c..d058e4c 100644
--- a/lib/snapshot/snapshot.c
+++ b/lib/snapshot/snapshot.c
@@ -125,16 +125,22 @@ static int _snap_target_percent(void **target_state __attribute((unused)),
 }
 
 static int _snap_target_present(struct cmd_context *cmd,
-				const struct lv_segment *seg __attribute((unused)),
+				const struct lv_segment *seg,
 				unsigned *attributes __attribute((unused)))
 {
 	static int _snap_checked = 0;
+	static int _snap_merge_checked = 0;
 	static int _snap_present = 0;
 
 	if (!_snap_checked)
 		_snap_present = target_present(cmd, "snapshot", 1) &&
 		    target_present(cmd, "snapshot-origin", 0);
 
+	if (!_snap_merge_checked && seg && (seg->status & SNAPSHOT_MERGE)) {
+		_snap_present &= target_present(cmd, "snapshot-merge", 0);
+		_snap_merge_checked = 1;
+	}
+
 	_snap_checked = 1;
 
 	return _snap_present;
diff --git a/libdm/.exported_symbols b/libdm/.exported_symbols
index 554b90a..4f051e9 100644
--- a/libdm/.exported_symbols
+++ b/libdm/.exported_symbols
@@ -70,6 +70,7 @@ dm_tree_suspend_children
 dm_tree_children_use_uuid
 dm_tree_node_add_snapshot_origin_target
 dm_tree_node_add_snapshot_target
+dm_tree_node_add_snapshot_merge_target
 dm_tree_node_add_error_target
 dm_tree_node_add_zero_target
 dm_tree_node_add_linear_target
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index c6546a6..1c4afa5 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -392,6 +392,12 @@ int dm_tree_node_add_snapshot_target(struct dm_tree_node *node,
 					const char *cow_uuid,
 					int persistent,
 					uint32_t chunk_size);
+int dm_tree_node_add_snapshot_merge_target(struct dm_tree_node *node,
+					     uint64_t size,
+					     const char *origin_uuid,
+					     const char *cow_uuid,
+					     const char *merge_uuid,
+					     uint32_t chunk_size);
 int dm_tree_node_add_error_target(struct dm_tree_node *node,
 				     uint64_t size);
 int dm_tree_node_add_zero_target(struct dm_tree_node *node,
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 91f7177..5207f0d 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -35,6 +35,7 @@ enum {
 	SEG_MIRRORED,
 	SEG_SNAPSHOT,
 	SEG_SNAPSHOT_ORIGIN,
+	SEG_SNAPSHOT_MERGE,
 	SEG_STRIPED,
 	SEG_ZERO,
 };
@@ -51,6 +52,7 @@ struct {
 	{ SEG_MIRRORED, "mirror" },
 	{ SEG_SNAPSHOT, "snapshot" },
 	{ SEG_SNAPSHOT_ORIGIN, "snapshot-origin" },
+	{ SEG_SNAPSHOT_MERGE, "snapshot-merge" },
 	{ SEG_STRIPED, "striped" },
 	{ SEG_ZERO, "zero"},
 };
@@ -81,6 +83,7 @@ struct load_segment {
 	uint32_t chunk_size;		/* Snapshot */
 	struct dm_tree_node *cow;	/* Snapshot */
 	struct dm_tree_node *origin;	/* Snapshot + Snapshot origin */
+	struct dm_tree_node *merge;	/* Snapshot */
 
 	struct dm_tree_node *log;	/* Mirror */
 	uint32_t region_size;		/* Mirror */
@@ -1166,7 +1169,7 @@ int dm_tree_activate_children(struct dm_tree_node *dnode,
 
 	handle = NULL;
 
-	for (priority = 0; priority < 2; priority++) {
+	for (priority = 0; priority < 3; priority++) {
 		while ((child = dm_tree_next_child(&handle, dnode, 0))) {
 			if (!(uuid = dm_tree_node_get_uuid(child))) {
 				stack;
@@ -1457,6 +1460,7 @@ static int _emit_segment_line(struct dm_task *dmt, uint32_t major,
 			return_0;
 		break;
 	case SEG_SNAPSHOT:
+	case SEG_SNAPSHOT_MERGE:
 		if (!_build_dev_string(originbuf, sizeof(originbuf), seg->origin))
 			return_0;
 		if (!_build_dev_string(cowbuf, sizeof(cowbuf), seg->cow))
@@ -1485,6 +1489,7 @@ static int _emit_segment_line(struct dm_task *dmt, uint32_t major,
 	case SEG_ERROR:
 	case SEG_SNAPSHOT:
 	case SEG_SNAPSHOT_ORIGIN:
+	case SEG_SNAPSHOT_MERGE:
 	case SEG_ZERO:
 		break;
 	case SEG_CRYPT:
@@ -1719,6 +1724,7 @@ static struct load_segment *_add_segment(struct dm_tree_node *dnode, unsigned ty
 	seg->chunk_size = 0;
 	seg->cow = NULL;
 	seg->origin = NULL;
+	seg->merge = NULL;
 
 	dm_list_add(&dnode->props.segs, &seg->list);
 	dnode->props.segment_count++;
@@ -1751,17 +1757,21 @@ int dm_tree_node_add_snapshot_origin_target(struct dm_tree_node *dnode,
 	return 1;
 }
 
-int dm_tree_node_add_snapshot_target(struct dm_tree_node *node,
-                                        uint64_t size,
-                                        const char *origin_uuid,
-                                        const char *cow_uuid,
-                                        int persistent,
-                                        uint32_t chunk_size)
+static int _add_snapshot_target(struct dm_tree_node *node,
+				   uint64_t size,
+				   const char *origin_uuid,
+				   const char *cow_uuid,
+				   const char *merge_uuid,
+				   int persistent,
+				   uint32_t chunk_size)
 {
 	struct load_segment *seg;
-	struct dm_tree_node *origin_node, *cow_node;
+	struct dm_tree_node *origin_node, *cow_node, *merge_node;
+	unsigned seg_type;
+
+	seg_type = !merge_uuid ? SEG_SNAPSHOT : SEG_SNAPSHOT_MERGE;
 
-	if (!(seg = _add_segment(node, SEG_SNAPSHOT, size)))
+	if (!(seg = _add_segment(node, seg_type, size)))
 		return_0;
 
 	if (!(origin_node = dm_tree_find_node_by_uuid(node->dtree, origin_uuid))) {
@@ -1774,7 +1784,7 @@ int dm_tree_node_add_snapshot_target(struct dm_tree_node *node,
 		return_0;
 
 	if (!(cow_node = dm_tree_find_node_by_uuid(node->dtree, cow_uuid))) {
-		log_error("Couldn't find snapshot origin uuid %s.", cow_uuid);
+		log_error("Couldn't find snapshot COW device uuid %s.", cow_uuid);
 		return 0;
 	}
 
@@ -1782,12 +1792,54 @@ int dm_tree_node_add_snapshot_target(struct dm_tree_node *node,
 	if (!_link_tree_nodes(node, cow_node))
 		return_0;
 
+	if (merge_uuid) {
+		if (!(merge_node = dm_tree_find_node_by_uuid(node->dtree, merge_uuid))) {
+			/* not a pure error, merging snapshot may have been deactivated */
+			log_verbose("Couldn't find merging snapshot uuid %s.", merge_uuid);
+		} else {
+			seg->merge = merge_node;
+			/* must not link merging snapshot, would undermine activation_priority below */
+		}
+	}
+
 	seg->persistent = persistent ? 1 : 0;
 	seg->chunk_size = chunk_size;
 
+	if (merge_uuid) {
+		/* Resume snapshot-merge (acting origin) after other snapshots */
+		node->activation_priority = 1;
+		if (seg->merge) {
+			/* Resume merging snapshot after snapshot-merge */
+			seg->merge->activation_priority = 2;
+		}
+	}
+
 	return 1;
 }
 
+
+int dm_tree_node_add_snapshot_target(struct dm_tree_node *node,
+				     uint64_t size,
+				     const char *origin_uuid,
+				     const char *cow_uuid,
+				     int persistent,
+				     uint32_t chunk_size)
+{
+	return _add_snapshot_target(node, size, origin_uuid, cow_uuid,
+				    NULL, persistent, chunk_size);
+}
+
+int dm_tree_node_add_snapshot_merge_target(struct dm_tree_node *node,
+					   uint64_t size,
+					   const char *origin_uuid,
+					   const char *cow_uuid,
+					   const char *merge_uuid,
+					   uint32_t chunk_size)
+{
+	return _add_snapshot_target(node, size, origin_uuid, cow_uuid,
+				    merge_uuid, 1, chunk_size);
+}
+
 int dm_tree_node_add_error_target(struct dm_tree_node *node,
                                      uint64_t size)
 {
-- 
1.6.5.2


