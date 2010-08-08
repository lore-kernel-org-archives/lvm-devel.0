From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Sun,  8 Aug 2010 10:57:14 +0200
Subject: [PATCH 02/25] SEG_REPLICATED dm-deptree
In-Reply-To: <cover.1281256234.git.zkabelac@redhat.com>
References: <cover.1281256234.git.zkabelac@redhat.com>
Message-ID: <a11ddab4e5108d37770265d5457db3c681a2a913.1281256235.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 libdm/libdevmapper.h  |   18 +++++++++---------
 libdm/libdm-deptree.c |   40 ++++++++++++++++++++--------------------
 2 files changed, 29 insertions(+), 29 deletions(-)

diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index b1bfbf3..942a30a 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -472,15 +472,15 @@ int dm_tree_node_add_replicator_target(struct dm_tree_node *node,
 				       uint64_t fall_behind_size,
 				       uint32_t fall_behind_timeout);
 
-int dm_tree_node_add_replicator_dev_target(struct dm_tree_node *node,
-					   uint64_t size,
-					   const char *replicator_uuid,	/* Replicator control device */
-					   uint64_t rdevice_index,
-					   const char *rdev_uuid,	/* Rimage device name/uuid */
-					   unsigned rsite_index,
-					   const char *slog_uuid,
-					   uint32_t slog_flags,		/* Mirror log flags */
-					   uint32_t slog_region_size);
+int dm_tree_node_add_replicated_target(struct dm_tree_node *node,
+				       uint64_t size,
+				       const char *replicator_uuid,	/* Replicator control device */
+				       uint64_t rdevice_index,
+				       const char *rdev_uuid,	/* Rimage device name/uuid */
+				       unsigned rsite_index,
+				       const char *slog_uuid,
+				       uint32_t slog_flags,		/* Mirror log flags */
+				       uint32_t slog_region_size);
 /* End of Replicator API */
 
 void dm_tree_node_set_presuspend_node(struct dm_tree_node *node,
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 5a12c5f..c009209 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -36,7 +36,7 @@ enum {
 	SEG_LINEAR,
 	SEG_MIRRORED,
 	SEG_REPLICATOR,
-	SEG_REPLICATOR_DEV,
+	SEG_REPLICATED,
 	SEG_SNAPSHOT,
 	SEG_SNAPSHOT_ORIGIN,
 	SEG_SNAPSHOT_MERGE,
@@ -55,7 +55,7 @@ struct {
 	{ SEG_LINEAR, "linear" },
 	{ SEG_MIRRORED, "mirror" },
 	{ SEG_REPLICATOR, "replicator" },
-	{ SEG_REPLICATOR_DEV, "replicator-dev" },
+	{ SEG_REPLICATED, "replicator-dev" },
 	{ SEG_SNAPSHOT, "snapshot" },
 	{ SEG_SNAPSHOT_ORIGIN, "snapshot-origin" },
 	{ SEG_SNAPSHOT_MERGE, "snapshot-merge" },
@@ -125,8 +125,8 @@ struct load_segment {
 	struct dm_list rsites;		/* Replicator */
 	unsigned rsite_count;		/* Replicator */
 	unsigned rdevice_count;		/* Replicator */
-	struct dm_tree_node *replicator;/* Replicator-dev */
-	uint64_t rdevice_index;		/* Replicator-dev */
+	struct dm_tree_node *replicator;/* Replicated */
+	uint64_t rdevice_index;		/* Replicated */
 };
 
 /* Per-device properties */
@@ -1450,7 +1450,7 @@ static int _emit_areas_line(struct dm_task *dmt __attribute__((unused)),
 			return_0;
 
 		switch (seg->type) {
-		case SEG_REPLICATOR_DEV:
+		case SEG_REPLICATED:
 			EMIT_PARAMS(*pos, " %d 1 %s", area->rsite_index, devbuf);
 			if (first_time)
 				EMIT_PARAMS(*pos, " nolog 0");
@@ -1682,7 +1682,7 @@ static int _emit_segment_line(struct dm_task *dmt, uint32_t major,
 			return r;
 		}
 		break;
-	case SEG_REPLICATOR_DEV:
+	case SEG_REPLICATED:
 		if (!seg->replicator || !_build_dev_string(originbuf,
 							   sizeof(originbuf),
 							   seg->replicator))
@@ -1726,7 +1726,7 @@ static int _emit_segment_line(struct dm_task *dmt, uint32_t major,
 		break;
 	case SEG_CRYPT:
 	case SEG_LINEAR:
-	case SEG_REPLICATOR_DEV:
+	case SEG_REPLICATED:
 	case SEG_STRIPED:
 		if ((r = _emit_areas_line(dmt, seg, params, paramsize, &pos)) <= 0) {
 			stack;
@@ -2292,15 +2292,15 @@ int dm_tree_node_add_replicator_target(struct dm_tree_node *node,
 }
 
 /* Appends device node to Replicator */
-int dm_tree_node_add_replicator_dev_target(struct dm_tree_node *node,
-					   uint64_t size,
-					   const char *replicator_uuid,
-					   uint64_t rdevice_index,
-					   const char *rdev_uuid,
-					   unsigned rsite_index,
-					   const char *slog_uuid,
-					   uint32_t slog_flags,
-					   uint32_t slog_region_size)
+int dm_tree_node_add_replicated_target(struct dm_tree_node *node,
+				       uint64_t size,
+				       const char *replicator_uuid,
+				       uint64_t rdevice_index,
+				       const char *rdev_uuid,
+				       unsigned rsite_index,
+				       const char *slog_uuid,
+				       uint32_t slog_flags,
+				       uint32_t slog_region_size)
 {
 	struct seg_area *area;
 	struct load_segment *rseg;
@@ -2308,7 +2308,7 @@ int dm_tree_node_add_replicator_dev_target(struct dm_tree_node *node,
 
 	if (rsite_index == REPLICATOR_LOCAL_SITE) {
 		/* Site index for local target */
-		if (!(rseg = _add_segment(node, SEG_REPLICATOR_DEV, size)))
+		if (!(rseg = _add_segment(node, SEG_REPLICATED, size)))
 			return_0;
 
 		if (!(rseg->replicator = dm_tree_find_node_by_uuid(node->dtree, replicator_uuid))) {
@@ -2337,13 +2337,13 @@ int dm_tree_node_add_replicator_dev_target(struct dm_tree_node *node,
 	} else {
 		/* Local slink0 for replicator must be always initialized first */
 		if (node->props.segment_count != 1) {
-			log_error(INTERNAL_ERROR "Attempt to use non replicator-dev segment.");
+			log_error(INTERNAL_ERROR "Attempt to use non replicated segment.");
 			return 0;
 		}
 
 		rseg = dm_list_item(dm_list_last(&node->props.segs), struct load_segment);
-		if (rseg->type != SEG_REPLICATOR_DEV) {
-			log_error(INTERNAL_ERROR "Attempt to use non replicator-dev segment %s.",
+		if (rseg->type != SEG_REPLICATED) {
+			log_error(INTERNAL_ERROR "Attempt to use non replicated segment %s.",
 				  dm_segtypes[rseg->type].target);
 			return 0;
 		}
-- 
1.7.2.1


