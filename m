From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon,  5 Oct 2009 16:00:29 +0200
Subject: [PATCH 02/13] Replicator: add libdm support
In-Reply-To: <1254751240-17431-1-git-send-email-zkabelac@redhat.com>
References: <1254751240-17431-1-git-send-email-zkabelac@redhat.com>
Message-ID: <1254751240-17431-2-git-send-email-zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Introducing dm_tree_node_add_replicator_target() and
dm_tree_node_add_replicator_dev_target()

Modifing API dm_tree_suspend_children() to support prioritized suspend
and update lvm activation.

Avoid preloading childrens with nonzero activation priority

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/activate/dev_manager.c |    2 +-
 libdm/.exported_symbols    |    3 +
 libdm/libdevmapper.h       |   34 +++++-
 libdm/libdm-deptree.c      |  296 ++++++++++++++++++++++++++++++++++++++++++--
 4 files changed, 323 insertions(+), 12 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 13cec36..19deab8 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1221,7 +1221,7 @@ static int _tree_action(struct dev_manager *dm, struct logical_volume *lv, actio
 		if (!dm->flush_required && (lv->status & MIRRORED) && !(lv->status & PVMOVE))
 			dm_tree_use_no_flush_suspend(root);
 	case SUSPEND_WITH_LOCKFS:
-		if (!dm_tree_suspend_children(root, dlid, ID_LEN + sizeof(UUID_PREFIX) - 1))
+		if (!dm_tree_suspend_children(root, dlid, ID_LEN + sizeof(UUID_PREFIX) - 1, 0))
 			goto_out;
 		break;
 	case PRELOAD:
diff --git a/libdm/.exported_symbols b/libdm/.exported_symbols
index c357131..5fd81ec 100644
--- a/libdm/.exported_symbols
+++ b/libdm/.exported_symbols
@@ -64,6 +64,7 @@ dm_tree_next_parent
 dm_tree_deactivate_children
 dm_tree_activate_children
 dm_tree_preload_children
+dm_tree_set_priority
 dm_tree_suspend_children
 dm_tree_children_use_uuid
 dm_tree_node_add_snapshot_origin_target
@@ -76,6 +77,8 @@ dm_tree_node_add_crypt_target
 dm_tree_node_add_mirror_target
 dm_tree_node_add_mirror_target_log
 dm_tree_node_add_target_area
+dm_tree_node_add_replicator_target
+dm_tree_node_add_replicator_dev_target
 dm_tree_node_set_read_ahead
 dm_tree_skip_lockfs
 dm_tree_use_no_flush_suspend
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 204372a..4e0103a 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -341,8 +341,9 @@ int dm_tree_activate_children(struct dm_tree_node *dnode,
  * Ignores devices that don't have a uuid starting with uuid_prefix.
  */
 int dm_tree_suspend_children(struct dm_tree_node *dnode,
-				   const char *uuid_prefix,
-				   size_t uuid_prefix_len);
+			     const char *uuid_prefix,
+			     size_t uuid_prefix_len,
+			     int priority);
 
 /*
  * Skip the filesystem sync when suspending.
@@ -421,11 +422,40 @@ int dm_tree_node_add_mirror_target_log(struct dm_tree_node *node,
 					  const char *log_uuid,
 					  unsigned area_count,
 					  uint32_t flags);
+
+int dm_tree_node_add_replicator_target(struct dm_tree_node *node,
+				       uint64_t size,
+				       const char *rlog_uuid,
+				       const char *rlog_type,
+				       unsigned site_index,
+				       int async_action,
+/* Replicator async action flags */
+#define DM_REPLICATOR_SYNC	0		/* use synchronous replication */
+#define DM_REPLICATOR_WARN	1		/* warn if replicator is slow */
+#define DM_REPLICATOR_STALL	2		/* stall replicator if not fast enough */
+#define DM_REPLICATOR_DROP	3		/* drop legs */
+#define DM_REPLICATOR_FAIL	4		/* fail replicator if slow */
+				       uint32_t async_timeout,
+				       uint64_t fall_behind_data,
+				       uint32_t fall_behind_ios);
+
+int dm_tree_node_add_replicator_dev_target(struct dm_tree_node *node,
+					   uint64_t size,
+					   const char *replog_uuid,	/* replicator-log device */
+					   uint64_t rdevice_index,
+					   const char *rdev_uuid,	/* remove/rimage device name/uuid */
+					   unsigned rsite_index,
+					   const char *llog_uuid,
+					   uint32_t llog_flags,		/* Mirror log flags */
+					   uint32_t llog_size);
+
 int dm_tree_node_add_target_area(struct dm_tree_node *node,
 				    const char *dev_name,
 				    const char *dlid,
 				    uint64_t offset);
 
+int dm_tree_set_priority(struct dm_tree *dtree, const char *uuid, int priority);
+
 /*
  * Set readahead (in sectors) after loading the node.
  */
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 75fb201..4fc625f 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -33,6 +33,8 @@ enum {
 	SEG_ERROR,
 	SEG_LINEAR,
 	SEG_MIRRORED,
+	SEG_REPLICATOR,
+	SEG_REPLICATOR_DEV,
 	SEG_SNAPSHOT,
 	SEG_SNAPSHOT_ORIGIN,
 	SEG_STRIPED,
@@ -49,6 +51,8 @@ struct {
 	{ SEG_ERROR, "error" },
 	{ SEG_LINEAR, "linear" },
 	{ SEG_MIRRORED, "mirror" },
+	{ SEG_REPLICATOR, "replicator" },
+	{ SEG_REPLICATOR_DEV, "replicator-dev" },
 	{ SEG_SNAPSHOT, "snapshot" },
 	{ SEG_SNAPSHOT_ORIGIN, "snapshot-origin" },
 	{ SEG_STRIPED, "striped" },
@@ -62,6 +66,23 @@ struct seg_area {
 	struct dm_tree_node *dev_node;
 
 	uint64_t offset;
+
+	unsigned rsite_index;		/* Replicator site index */
+	struct dm_tree_node *llog;	/* Replicator link log node */
+	uint64_t region_size;		/* Replicator link log size */
+	uint32_t flags;			/* Replicator link log flags */
+};
+
+/* Replicator-log has a list of sites */
+/* CHECKME: maybe move to seg_area too ?? */
+struct replicator_site {
+	struct dm_list list;
+
+	unsigned rsite_index;
+	int async_action;
+	uint32_t async_timeout;
+	uint32_t fall_behind_ios;
+	uint64_t fall_behind_data;
 };
 
 /* Per-segment properties */
@@ -72,8 +93,8 @@ struct load_segment {
 
 	uint64_t size;
 
-	unsigned area_count;		/* Linear + Striped + Mirrored + Crypt */
-	struct dm_list areas;		/* Linear + Striped + Mirrored + Crypt */
+	unsigned area_count;		/* Linear + Striped + Mirrored + Crypt + Replicator */
+	struct dm_list areas;		/* Linear + Striped + Mirrored + Crypt + Replicator */
 
 	uint32_t stripe_size;		/* Striped */
 
@@ -82,7 +103,7 @@ struct load_segment {
 	struct dm_tree_node *cow;	/* Snapshot */
 	struct dm_tree_node *origin;	/* Snapshot + Snapshot origin */
 
-	struct dm_tree_node *log;	/* Mirror */
+	struct dm_tree_node *log;	/* Mirror + Replicator + Replicator-dev */
 	uint32_t region_size;		/* Mirror */
 	unsigned clustered;		/* Mirror */
 	unsigned mirror_area_count;	/* Mirror */
@@ -94,6 +115,12 @@ struct load_segment {
 	const char *iv;			/* Crypt */
 	uint64_t iv_offset;		/* Crypt */
 	const char *key;		/* Crypt */
+
+	const char *rlog_type;		/* Replicator */
+	struct dm_list rsites;		/* Replicator */
+	unsigned rsite_count;		/* Replicator */
+	unsigned rdevice_count;		/* Replicator */
+	uint64_t rdevice_index;		/* Replicator-dev */
 };
 
 /* Per-device properties */
@@ -625,6 +652,18 @@ void dm_tree_node_set_read_ahead(struct dm_tree_node *dnode,
 	dnode->props.read_ahead_flags = read_ahead_flags;
 }
 
+int dm_tree_set_priority(struct dm_tree *dtree, const char *uuid, int priority)
+{
+	struct dm_tree_node *dnode;
+
+	if ((dnode = dm_tree_find_node_by_uuid(dtree, uuid))) {
+		log_verbose("Setting activation priority %d for %s", priority, dnode->name);
+		dnode->activation_priority = priority;
+	}
+
+        return 1;
+}
+
 int dm_tree_add_dev(struct dm_tree *dtree, uint32_t major, uint32_t minor)
 {
 	return _add_dev(dtree, &dtree->root, major, minor) ? 1 : 0;
@@ -1036,8 +1075,9 @@ void dm_tree_use_no_flush_suspend(struct dm_tree_node *dnode)
 }
 
 int dm_tree_suspend_children(struct dm_tree_node *dnode,
-				   const char *uuid_prefix,
-				   size_t uuid_prefix_len)
+			     const char *uuid_prefix,
+			     size_t uuid_prefix_len,
+			     int priority)
 {
 	void *handle = NULL;
 	struct dm_tree_node *child = dnode;
@@ -1068,13 +1108,17 @@ int dm_tree_suspend_children(struct dm_tree_node *dnode,
 			continue;
 
 		/* Ensure immediate parents are already suspended */
-		if (!_children_suspended(child, 1, uuid_prefix, uuid_prefix_len))
+		if (priority == 0 &&
+		    !_children_suspended(child, 1, uuid_prefix, uuid_prefix_len))
 			continue;
 
 		if (!_info_by_dev(dinfo->major, dinfo->minor, 0, &info) ||
 		    !info.exists || info.suspended)
 			continue;
 
+		if (child->activation_priority != priority)
+			continue;
+
 		if (!_suspend_node(name, info.major, info.minor,
 				   child->dtree->skip_lockfs,
 				   child->dtree->no_flush, &newinfo)) {
@@ -1102,7 +1146,7 @@ int dm_tree_suspend_children(struct dm_tree_node *dnode,
 			continue;
 
 		if (dm_tree_node_num_children(child, 0))
-			dm_tree_suspend_children(child, uuid_prefix, uuid_prefix_len);
+			dm_tree_suspend_children(child, uuid_prefix, uuid_prefix_len, priority);
 	}
 
 	return 1;
@@ -1270,13 +1314,49 @@ static int _emit_areas_line(struct dm_task *dmt __attribute((unused)),
 	struct seg_area *area;
 	char devbuf[DM_FORMAT_DEV_BUFSIZE];
 	unsigned first_time = 1;
+	const char *logtype;
+	unsigned log_parm_count;
 
 	dm_list_iterate_items(area, &seg->areas) {
 		if (!_build_dev_string(devbuf, sizeof(devbuf), area->dev_node))
 			return_0;
 
-		EMIT_PARAMS(*pos, "%s%s %" PRIu64, first_time ? "" : " ",
-			    devbuf, area->offset);
+		switch (seg->type) {
+		case SEG_REPLICATOR_DEV:
+			EMIT_PARAMS(*pos, " %d 1 %s", area->rsite_index, devbuf);
+			if (!first_time) {
+				/* remote devices */
+				log_parm_count = (area->flags & (DM_NOSYNC | DM_FORCESYNC)) ? 2 : 1;
+
+				if (!area->llog) {
+					devbuf[0] = 0;		/* only core log parameters */
+					logtype = "core";
+				} else {
+					devbuf[0] = ' ';	/* extra space before device name */
+					if (!_build_dev_string(devbuf + 1, sizeof(devbuf) - 1,
+							       area->llog))
+						return_0;
+					logtype = "disk";
+					log_parm_count++;	/* extra link log device name parameter */
+				}
+
+				EMIT_PARAMS(*pos, " %s %u%s %" PRIu64, logtype,
+					    log_parm_count, devbuf, area->region_size);
+
+				logtype = (area->flags & DM_NOSYNC) ?
+					" nosync" : (area->flags & DM_FORCESYNC) ?
+					" sync" : NULL;
+
+                                if (logtype)
+					EMIT_PARAMS(*pos, logtype);
+			} else
+				EMIT_PARAMS(*pos, " nolog 0");
+
+			break;
+		default:
+			EMIT_PARAMS(*pos, "%s%s %" PRIu64, first_time ? "" : " ",
+				    devbuf, area->offset);
+		}
 
 		first_time = 0;
 	}
@@ -1284,6 +1364,42 @@ static int _emit_areas_line(struct dm_task *dmt __attribute((unused)),
 	return 1;
 }
 
+static int _replicator_emit_segment_line(const struct load_segment *seg, char *params,
+					 size_t paramsize, int *pos)
+{
+	const struct load_segment *rlog_seg;
+	const struct replicator_site *rsite;
+	char rlogbuf[DM_FORMAT_DEV_BUFSIZE];
+	unsigned parm_count;
+
+	if (!seg->log || !_build_dev_string(rlogbuf, sizeof(rlogbuf), seg->log))
+		return_0;
+
+	rlog_seg = dm_list_item(dm_list_last(&seg->log->props.segs),
+				struct load_segment);
+
+	EMIT_PARAMS(*pos, "%s 4 %s 0 auto %" PRIu64,
+		    seg->rlog_type, rlogbuf, rlog_seg->size);
+
+	dm_list_iterate_items(rsite, &seg->rsites) {
+		parm_count = (rsite->fall_behind_data
+			      || rsite->fall_behind_ios
+			      || rsite->async_timeout) ? 4 : 2;
+
+		EMIT_PARAMS(*pos, " blockdev %u %u %s", parm_count, rsite->rsite_index,
+			    (rsite->async_action == DM_REPLICATOR_SYNC) ? "sync" : "async");
+
+		if (rsite->fall_behind_data)
+			EMIT_PARAMS(*pos, " data %" PRIu64, rsite->fall_behind_data);
+		else if (rsite->fall_behind_ios)
+			EMIT_PARAMS(*pos, " ios %" PRIu32, rsite->fall_behind_ios);
+		else if (rsite->async_timeout)
+			EMIT_PARAMS(*pos, " timeout %" PRIu32, rsite->async_timeout);
+	}
+
+	return 1;
+}
+
 /*
  * Returns: 1 on success, 0 on failure
  */
@@ -1424,6 +1540,19 @@ static int _emit_segment_line(struct dm_task *dmt, uint32_t major,
 		if (!r)
 			return_0;
 		break;
+	case SEG_REPLICATOR:
+		if ((r = _replicator_emit_segment_line(seg, params, paramsize, &pos))
+		    <= 0) {
+			stack;
+			return r;
+		}
+		break;
+	case SEG_REPLICATOR_DEV:
+		if (!seg->log || !_build_dev_string(originbuf, sizeof(originbuf), seg->log))
+			return_0;
+
+		EMIT_PARAMS(pos, "%s %" PRIu64, originbuf, seg->rdevice_index);
+		break;
 	case SEG_SNAPSHOT:
 		if (!_build_dev_string(originbuf, sizeof(originbuf), seg->origin))
 			return_0;
@@ -1451,12 +1580,14 @@ static int _emit_segment_line(struct dm_task *dmt, uint32_t major,
 
 	switch(seg->type) {
 	case SEG_ERROR:
+	case SEG_REPLICATOR:
 	case SEG_SNAPSHOT:
 	case SEG_SNAPSHOT_ORIGIN:
 	case SEG_ZERO:
 		break;
 	case SEG_CRYPT:
 	case SEG_LINEAR:
+	case SEG_REPLICATOR_DEV:
 	case SEG_STRIPED:
 		if ((r = _emit_areas_line(dmt, seg, params, paramsize, &pos)) <= 0) {
 			stack;
@@ -1609,6 +1740,9 @@ int dm_tree_preload_children(struct dm_tree_node *dnode,
 			}
 		}
 
+		if (child->activation_priority != 0)
+			continue;
+
 		/* Propagate device size change change */
 		if (child->props.size_changed)
 			dnode->props.size_changed = 1;
@@ -1871,6 +2005,150 @@ int dm_tree_node_add_mirror_target(struct dm_tree_node *node,
 	return 1;
 }
 
+int dm_tree_node_add_replicator_target(struct dm_tree_node *node,
+				       uint64_t size,
+				       const char *rlog_uuid,
+				       const char *rlog_type,
+				       unsigned rsite_index,
+				       int async_action,
+				       uint32_t async_timeout,
+				       uint64_t fall_behind_data,
+				       uint32_t fall_behind_ios)
+{
+	struct load_segment *rseg;
+	struct replicator_site *rsite;
+
+	if (rsite_index == 0) {
+		/* local site0 - add replog segment and set rlog device */
+		if (!(rseg = _add_segment(node, SEG_REPLICATOR, size)))
+			return_0;
+
+		if (!(rseg->log = dm_tree_find_node_by_uuid(node->dtree, rlog_uuid))) {
+			log_error("Missing replicator log uuid %s.", rlog_uuid);
+			return 0;
+		}
+
+		if (!_link_tree_nodes(node, rseg->log))
+			return_0;
+
+		if (strcmp(rlog_type, "ringbuffer") != 0) {
+			log_error("Unsupported rlog type %s.", rlog_type);
+			return 0;
+		}
+
+		if (!(rseg->rlog_type = dm_pool_strdup(node->dtree->mem, rlog_type)))
+			return_0;
+
+		dm_list_init(&rseg->rsites);
+		rseg->rdevice_count = 0;
+		node->activation_priority = 1;
+	}
+
+	if (!node->props.segment_count) {
+		log_error("Internal error: Attempt to add remote site area before replog.");
+		return 0;
+	}
+
+	/* new remote site */
+	if (async_action == DM_REPLICATOR_SYNC
+	    && (async_timeout || fall_behind_ios || fall_behind_data)) {
+		log_error("Unsupported combination of sync options passed.");
+		return 0;
+	}
+
+	rseg = dm_list_item(dm_list_last(&node->props.segs), struct load_segment);
+
+	if (!(rsite = dm_pool_zalloc(node->dtree->mem, sizeof (*rsite)))) {
+		log_error("Failed to allocate remote site segment.");
+		return 0;
+	}
+	dm_list_add(&rseg->rsites, &rsite->list);
+	rseg->rsite_count++;
+
+	rsite->async_action = async_action;
+	rsite->async_timeout = async_timeout;
+	rsite->fall_behind_data = fall_behind_data;
+	rsite->fall_behind_ios = fall_behind_ios;
+	rsite->rsite_index = rsite_index;
+
+	return 1;
+}
+
+/* Appends device node to Replicator */
+int dm_tree_node_add_replicator_dev_target(struct dm_tree_node *node,
+					   uint64_t size,
+					   const char *replog_uuid,
+					   uint64_t rdevice_index,
+					   const char *rdev_uuid,
+					   unsigned rsite_index,
+					   const char *llog_uuid,
+					   uint32_t llog_flags,
+					   uint32_t llog_size)
+{
+	struct seg_area *area;
+	struct load_segment *rseg;
+	int is_uuid = (rdev_uuid) ? (strchr(rdev_uuid, '/') == NULL) : 0;
+
+	if (rsite_index == 0) {
+		/* site index for local target */
+		if (!(rseg = _add_segment(node, SEG_REPLICATOR_DEV, size)))
+			return_0;
+
+		if (!(rseg->log = dm_tree_find_node_by_uuid(node->dtree, replog_uuid))) {
+			log_error("Missing replicator log uuid %s.", replog_uuid);
+			return 0;
+		}
+
+		if (!rseg->log->props.segment_count) {
+			/* local slink 0 for replicator must be always initialized first */
+			log_error("Internal error: Attempt to use empty replog segment.");
+			return 0;
+		}
+		dm_list_item(dm_list_last(&rseg->log->props.segs),
+			     struct load_segment)->rdevice_count++;
+
+		if (!_link_tree_nodes(node, rseg->log))
+			return_0;
+
+		rseg->rdevice_index = rdevice_index;
+	} else {
+		if (!node->props.segment_count) {
+			/* local slink 0 for replicator must be always initialized first */
+			log_error("Internal error: Attempt to add incorrrect remote target segment.");
+			return 0;
+		}
+
+		rseg = dm_list_item(dm_list_last(&node->props.segs), struct load_segment);
+	}
+
+	if (!(llog_flags & DM_CORELOG) && !llog_uuid) {
+		log_error("Unspecified link log uuid.");
+		return 0;
+	}
+
+	if (!dm_tree_node_add_target_area(node, (is_uuid) ? NULL : rdev_uuid,
+					  (is_uuid) ? rdev_uuid :  NULL, 0))
+		return 0;
+
+	area = dm_list_item(dm_list_last(&rseg->areas), struct seg_area);
+
+	if (!(llog_flags & DM_CORELOG)) {
+		if (!(area->llog = dm_tree_find_node_by_uuid(node->dtree, llog_uuid))) {
+			log_error("Couldn't find link log uuid %s.", llog_uuid);
+			return 0;
+		}
+
+		if (!_link_tree_nodes(node, area->llog))
+			return_0;
+	}
+
+	area->flags = llog_flags;
+	area->region_size = llog_size;
+	area->rsite_index = rsite_index;
+
+	return 1;
+}
+
 static int _add_area(struct dm_tree_node *node, struct load_segment *seg, struct dm_tree_node *dev_node, uint64_t offset)
 {
 	struct seg_area *area;
-- 
1.6.5.rc2


