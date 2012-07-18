From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 18 Jul 2012 12:39:13 +0000 (UTC)
Subject: master - libdm: add support for external origin and discard
Message-ID: <20120718123913.148AA8A1@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=dcd4afc7163fa08b8bd43aeb4cabe3d8a792e20b
Commit:        dcd4afc7163fa08b8bd43aeb4cabe3d8a792e20b
Parent:        00d9bf8107b47e51fc966dd5bd78789190c6e846
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Feb 4 13:49:40 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 18 14:33:37 2012 +0200

libdm: add support for external origin and discard

---
 WHATS_NEW_DM          |    1 +
 libdm/libdevmapper.h  |   14 +++++
 libdm/libdm-deptree.c |  140 +++++++++++++++++++++++++++++++++++++++++-------
 3 files changed, 134 insertions(+), 21 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 711104b..e11ebcb 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.76 - 
 ===============================
+  Add support for thin pool discard and external origin.
   Add configure --enable-udev-rule-exec-detection to detect exec path in rules.
   Use sbindir in udev rules by default and remove executable path detection.
   Remove hard-coded paths for dmeventd fifos and use default-dm-run-dir.
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index a8bf885..6eeaf87 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -657,6 +657,17 @@ int dm_tree_node_add_thin_pool_message(struct dm_tree_node *node,
 				       uint64_t id1, uint64_t id2);
 
 /*
+ * Set thin pool discard features
+ *   ignore      - Disable discard support
+ *   no_passdown - Don't pass discard down to underlaying data device,
+ *                 just remove the mapping
+ * Feature is available for 1.1
+ */
+int dm_tree_node_set_thin_pool_discard(struct dm_tree_node *node,
+				       unsigned ignore,
+				       unsigned no_passdown);
+
+/*
  * FIXME: Defines bellow are based on kernel's dm-thin.c defines
  * MAX_DEV_ID ((1 << 24) - 1)
  */
@@ -666,6 +677,9 @@ int dm_tree_node_add_thin_target(struct dm_tree_node *node,
 				 const char *pool_uuid,
 				 uint32_t device_id);
 
+int dm_tree_node_set_thin_external_origin(struct dm_tree_node *node,
+					  const char *external_uuid);
+
 void dm_tree_node_set_udev_flags(struct dm_tree_node *node, uint16_t udev_flags);
 
 void dm_tree_node_set_presuspend_node(struct dm_tree_node *node,
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 91bafe5..a43b6a2 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -186,11 +186,14 @@ struct load_segment {
 
 	struct dm_tree_node *metadata;	/* Thin_pool */
 	struct dm_tree_node *pool;	/* Thin_pool, Thin */
+	struct dm_tree_node *external;	/* Thin */
 	struct dm_list thin_messages;	/* Thin_pool */
 	uint64_t transaction_id;	/* Thin_pool */
 	uint64_t low_water_mark;	/* Thin_pool */
 	uint32_t data_block_size;       /* Thin_pool */
 	unsigned skip_block_zeroing;	/* Thin_pool */
+	unsigned ignore_discard;	/* Thin_pool 1.1 */
+	unsigned no_discard_passdown;	/* Thin_pool 1.1 */
 	uint32_t device_id;		/* Thin */
 
 };
@@ -2145,6 +2148,57 @@ static int _raid_emit_segment_line(struct dm_task *dmt, uint32_t major,
 	return 1;
 }
 
+static int _thin_pool_emit_segment_line(struct dm_task *dmt,
+					struct load_segment *seg,
+					char *params, size_t paramsize)
+{
+	int pos = 0;
+	char pool[DM_FORMAT_DEV_BUFSIZE], metadata[DM_FORMAT_DEV_BUFSIZE];
+	int features = (seg->skip_block_zeroing ? 1 : 0) +
+			(seg->ignore_discard ? 1 : 0) +
+			(seg->no_discard_passdown ? 1 : 0);
+
+	if (!_build_dev_string(metadata, sizeof(metadata), seg->metadata))
+		return_0;
+
+	if (!_build_dev_string(pool, sizeof(pool), seg->pool))
+		return_0;
+
+	EMIT_PARAMS(pos, "%s %s %d %" PRIu64 " %d%s%s%s", metadata, pool,
+		    seg->data_block_size, seg->low_water_mark, features,
+		    seg->skip_block_zeroing ? " skip_block_zeroing" : "",
+		    seg->ignore_discard ? " ignore_discard" : "",
+		    seg->no_discard_passdown ? " no_discard_passdown" : ""
+		   );
+
+	return 1;
+}
+
+static int _thin_emit_segment_line(struct dm_task *dmt,
+				   struct load_segment *seg,
+				   char *params, size_t paramsize)
+{
+	int pos = 0;
+	char pool[DM_FORMAT_DEV_BUFSIZE];
+	char external[DM_FORMAT_DEV_BUFSIZE + 1];
+
+	if (!_build_dev_string(pool, sizeof(pool), seg->pool))
+		return_0;
+
+	if (!seg->external)
+		*external = 0;
+	else {
+		*external = ' ';
+		if (!_build_dev_string(external + 1, sizeof(external) - 1,
+				       seg->external))
+			return_0;
+	}
+
+	EMIT_PARAMS(pos, "%s %d%s", pool, seg->device_id, external);
+
+	return 1;
+}
+
 static int _emit_segment_line(struct dm_task *dmt, uint32_t major,
 			      uint32_t minor, struct load_segment *seg,
 			      uint64_t *seg_start, char *params,
@@ -2154,7 +2208,6 @@ static int _emit_segment_line(struct dm_task *dmt, uint32_t major,
 	int r;
 	int target_type_is_raid = 0;
 	char originbuf[DM_FORMAT_DEV_BUFSIZE], cowbuf[DM_FORMAT_DEV_BUFSIZE];
-	char pool[DM_FORMAT_DEV_BUFSIZE], metadata[DM_FORMAT_DEV_BUFSIZE];
 
 	switch(seg->type) {
 	case SEG_ERROR:
@@ -2223,18 +2276,12 @@ static int _emit_segment_line(struct dm_task *dmt, uint32_t major,
 
 		break;
 	case SEG_THIN_POOL:
-		if (!_build_dev_string(metadata, sizeof(metadata), seg->metadata))
-			return_0;
-		if (!_build_dev_string(pool, sizeof(pool), seg->pool))
+		if (!_thin_pool_emit_segment_line(dmt, seg, params, paramsize))
 			return_0;
-		EMIT_PARAMS(pos, "%s %s %d %" PRIu64 " %s", metadata, pool,
-			    seg->data_block_size, seg->low_water_mark,
-			    seg->skip_block_zeroing ? "1 skip_block_zeroing" : "0");
 		break;
 	case SEG_THIN:
-		if (!_build_dev_string(pool, sizeof(pool), seg->pool))
+		if (!_thin_emit_segment_line(dmt, seg, params, paramsize))
 			return_0;
-		EMIT_PARAMS(pos, "%s %d", pool, seg->device_id);
 		break;
 	}
 
@@ -2956,6 +3003,28 @@ int dm_tree_node_add_replicator_dev_target(struct dm_tree_node *node,
 	return 1;
 }
 
+static struct load_segment *_get_single_load_segment(struct dm_tree_node *node,
+						     unsigned type)
+{
+	struct load_segment *seg;
+
+	if (node->props.segment_count != 1) {
+		log_error("Node %s must have only one segment.",
+			  dm_segtypes[type].target);
+		return NULL;
+	}
+
+	seg = dm_list_item(dm_list_last(&node->props.segs), struct load_segment);
+	if (seg->type != type) {
+		log_error("Node %s has segment type %s.",
+			  dm_segtypes[type].target,
+			  dm_segtypes[seg->type].target);
+		return NULL;
+	}
+
+	return seg;
+}
+
 static int _thin_validate_device_id(uint32_t device_id)
 {
 	if (device_id > DM_THIN_MAX_DEVICE_ID) {
@@ -3043,20 +3112,11 @@ int dm_tree_node_add_thin_pool_message(struct dm_tree_node *node,
 				       dm_thin_message_t type,
 				       uint64_t id1, uint64_t id2)
 {
-	struct load_segment *seg;
 	struct thin_message *tm;
+	struct load_segment *seg;
 
-	if (node->props.segment_count != 1) {
-		log_error("Thin pool node must have only one segment.");
-		return 0;
-	}
-
-	seg = dm_list_item(dm_list_last(&node->props.segs), struct load_segment);
-	if (seg->type != SEG_THIN_POOL) {
-		log_error("Thin pool node has segment type %s.",
-			  dm_segtypes[seg->type].target);
-		return 0;
-	}
+	if (!(seg = _get_single_load_segment(node, SEG_THIN_POOL)))
+		return_0;
 
 	if (!(tm = dm_pool_zalloc(node->dtree->mem, sizeof (*tm)))) {
 		log_error("Failed to allocate thin message.");
@@ -3111,6 +3171,21 @@ int dm_tree_node_add_thin_pool_message(struct dm_tree_node *node,
 	return 1;
 }
 
+int dm_tree_node_set_thin_pool_discard(struct dm_tree_node *node,
+				       unsigned ignore,
+				       unsigned no_passdown)
+{
+	struct load_segment *seg;
+
+	if (!(seg = _get_single_load_segment(node, SEG_THIN_POOL)))
+		return_0;
+
+	seg->ignore_discard = ignore;
+	seg->no_discard_passdown = no_passdown;
+
+	return 1;
+}
+
 int dm_tree_node_add_thin_target(struct dm_tree_node *node,
 				 uint64_t size,
 				 const char *pool_uuid,
@@ -3139,6 +3214,29 @@ int dm_tree_node_add_thin_target(struct dm_tree_node *node,
 	return 1;
 }
 
+int dm_tree_node_set_thin_external_origin(struct dm_tree_node *node,
+					  const char *external_uuid)
+{
+	struct dm_tree_node *external;
+	struct load_segment *seg;
+
+	if (!(seg = _get_single_load_segment(node, SEG_THIN)))
+		return_0;
+
+	if (!(external = dm_tree_find_node_by_uuid(node->dtree,
+						   external_uuid))) {
+		log_error("Missing thin external origin uuid %s.",
+			  external_uuid);
+		return 0;
+	}
+
+	if (!_link_tree_nodes(node, external))
+		return_0;
+
+	seg->external = external;
+
+	return 1;
+}
 
 int dm_get_status_thin_pool(struct dm_pool *mem, const char *params,
 			    struct dm_status_thin_pool **status)


