From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 21 May 2010 12:24:16 -0000
Subject: LVM2 ./WHATS_NEW libdm/.exported_symbols libdm ...
Message-ID: <20100521122416.5723.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-05-21 12:24:15

Modified files:
	.              : WHATS_NEW 
	libdm          : .exported_symbols libdevmapper.h 
	                 libdm-deptree.c 

Log message:
	Replicator: libdm support
	
	Introducing new API calls:
	dm_tree_node_add_replicator_target()
	dm_tree_node_add_replicator_dev_target().
	
	Define new typedef dm_replicator_mode_t.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1576&r2=1.1577
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/.exported_symbols.diff?cvsroot=lvm2&r1=1.52&r2=1.53
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.113&r2=1.114
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.75&r2=1.76

--- LVM2/WHATS_NEW	2010/05/21 12:21:51	1.1576
+++ LVM2/WHATS_NEW	2010/05/21 12:24:15	1.1577
@@ -1,5 +1,6 @@
 Version 2.02.67 -
 ===============================
+  Initial libdm support for Replicator target (API is not stable yet).
   Extend process_each_lv_in_vg() with support for list of failed lvnames.
   Return ECMD_FAILED for break in process_each_lv() and process_each_segment_in_lv().
 
--- LVM2/libdm/.exported_symbols	2010/05/06 10:10:16	1.52
+++ LVM2/libdm/.exported_symbols	2010/05/21 12:24:15	1.53
@@ -80,6 +80,8 @@
 dm_tree_node_add_mirror_target
 dm_tree_node_add_mirror_target_log
 dm_tree_node_add_target_area
+dm_tree_node_add_replicator_target
+dm_tree_node_add_replicator_dev_target
 dm_tree_node_set_read_ahead
 dm_tree_skip_lockfs
 dm_tree_use_no_flush_suspend
--- LVM2/libdm/libdevmapper.h	2010/05/06 10:10:16	1.113
+++ LVM2/libdm/libdevmapper.h	2010/05/21 12:24:15	1.114
@@ -439,6 +439,41 @@
 					  const char *log_uuid,
 					  unsigned area_count,
 					  uint32_t flags);
+
+/*
+ * Replicator operation mode
+ * Note: API for Replicator is not yet stable
+ */
+typedef enum {
+	DM_REPLICATOR_SYNC,			/* Synchronous replication */
+	DM_REPLICATOR_ASYNC_WARN,		/* Warn if async replicator is slow */
+	DM_REPLICATOR_ASYNC_STALL,		/* Stall replicator if not fast enough */
+	DM_REPLICATOR_ASYNC_DROP,		/* Drop sites out of sync */
+	DM_REPLICATOR_ASYNC_FAIL,		/* Fail replicator if slow */
+	NUM_DM_REPLICATOR_MODES
+} dm_replicator_mode_t;
+
+int dm_tree_node_add_replicator_target(struct dm_tree_node *node,
+				       uint64_t size,
+				       const char *rlog_uuid,
+				       const char *rlog_type,
+				       unsigned rsite_index,
+				       dm_replicator_mode_t mode,
+				       uint32_t async_timeout,
+				       uint64_t fall_behind_data,
+				       uint32_t fall_behind_ios);
+
+int dm_tree_node_add_replicator_dev_target(struct dm_tree_node *node,
+					   uint64_t size,
+					   const char *replicator_uuid,	/* Replicator control device */
+					   uint64_t rdevice_index,
+					   const char *rdev_uuid,	/* Rimage device name/uuid */
+					   unsigned rsite_index,
+					   const char *slog_uuid,
+					   uint32_t slog_flags,		/* Mirror log flags */
+					   uint32_t slog_region_size);
+/* End of Replicator API */
+
 int dm_tree_node_add_target_area(struct dm_tree_node *node,
 				    const char *dev_name,
 				    const char *dlid,
--- LVM2/libdm/libdm-deptree.c	2010/04/07 23:51:34	1.75
+++ LVM2/libdm/libdm-deptree.c	2010/05/21 12:24:15	1.76
@@ -27,12 +27,16 @@
 /* FIXME Fix interface so this is used only by LVM */
 #define UUID_PREFIX "LVM-"
 
+#define REPLICATOR_LOCAL_SITE 0
+
 /* Supported segment types */
 enum {
 	SEG_CRYPT,
 	SEG_ERROR,
 	SEG_LINEAR,
 	SEG_MIRRORED,
+	SEG_REPLICATOR,
+	SEG_REPLICATOR_DEV,
 	SEG_SNAPSHOT,
 	SEG_SNAPSHOT_ORIGIN,
 	SEG_SNAPSHOT_MERGE,
@@ -50,6 +54,8 @@
 	{ SEG_ERROR, "error" },
 	{ SEG_LINEAR, "linear" },
 	{ SEG_MIRRORED, "mirror" },
+	{ SEG_REPLICATOR, "replicator" },
+	{ SEG_REPLICATOR_DEV, "replicator-dev" },
 	{ SEG_SNAPSHOT, "snapshot" },
 	{ SEG_SNAPSHOT_ORIGIN, "snapshot-origin" },
 	{ SEG_SNAPSHOT_MERGE, "snapshot-merge" },
@@ -64,6 +70,23 @@
 	struct dm_tree_node *dev_node;
 
 	uint64_t offset;
+
+	unsigned rsite_index;		/* Replicator site index */
+	struct dm_tree_node *slog;	/* Replicator sync log node */
+	uint64_t region_size;		/* Replicator sync log size */
+	uint32_t flags;			/* Replicator sync log flags */
+};
+
+/* Replicator-log has a list of sites */
+/* FIXME: maybe move to seg_area too? */
+struct replicator_site {
+	struct dm_list list;
+
+	unsigned rsite_index;
+	dm_replicator_mode_t mode;
+	uint32_t async_timeout;
+	uint32_t fall_behind_ios;
+	uint64_t fall_behind_data;
 };
 
 /* Per-segment properties */
@@ -74,8 +97,8 @@
 
 	uint64_t size;
 
-	unsigned area_count;		/* Linear + Striped + Mirrored + Crypt */
-	struct dm_list areas;		/* Linear + Striped + Mirrored + Crypt */
+	unsigned area_count;		/* Linear + Striped + Mirrored + Crypt + Replicator */
+	struct dm_list areas;		/* Linear + Striped + Mirrored + Crypt + Replicator */
 
 	uint32_t stripe_size;		/* Striped */
 
@@ -85,7 +108,7 @@
 	struct dm_tree_node *origin;	/* Snapshot + Snapshot origin */
 	struct dm_tree_node *merge;	/* Snapshot */
 
-	struct dm_tree_node *log;	/* Mirror */
+	struct dm_tree_node *log;	/* Mirror + Replicator */
 	uint32_t region_size;		/* Mirror */
 	unsigned clustered;		/* Mirror */
 	unsigned mirror_area_count;	/* Mirror */
@@ -97,6 +120,13 @@
 	const char *iv;			/* Crypt */
 	uint64_t iv_offset;		/* Crypt */
 	const char *key;		/* Crypt */
+
+	const char *rlog_type;		/* Replicator */
+	struct dm_list rsites;		/* Replicator */
+	unsigned rsite_count;		/* Replicator */
+	unsigned rdevice_count;		/* Replicator */
+	struct dm_tree_node *replicator;/* Replicator-dev */
+	uint64_t rdevice_index;		/* Replicator-dev */
 };
 
 /* Per-device properties */
@@ -1342,13 +1372,51 @@
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
+			if (first_time)
+				EMIT_PARAMS(*pos, " nolog 0");
+			else {
+				/* Remote devices */
+				log_parm_count = (area->flags &
+						  (DM_NOSYNC | DM_FORCESYNC)) ? 2 : 1;
+
+				if (!area->slog) {
+					devbuf[0] = 0;		/* Only core log parameters */
+					logtype = "core";
+				} else {
+					devbuf[0] = ' ';	/* Extra space before device name */
+					if (!_build_dev_string(devbuf + 1,
+							       sizeof(devbuf) - 1,
+							       area->slog))
+						return_0;
+					logtype = "disk";
+					log_parm_count++;	/* Extra sync log device name parameter */
+				}
+
+				EMIT_PARAMS(*pos, " %s %u%s %" PRIu64, logtype,
+					    log_parm_count, devbuf, area->region_size);
+
+				logtype = (area->flags & DM_NOSYNC) ?
+					" nosync" : (area->flags & DM_FORCESYNC) ?
+					" sync" : NULL;
+
+				if (logtype)
+					EMIT_PARAMS(*pos, logtype);
+			}
+			break;
+		default:
+			EMIT_PARAMS(*pos, "%s%s %" PRIu64, first_time ? "" : " ",
+				    devbuf, area->offset);
+		}
 
 		first_time = 0;
 	}
@@ -1356,6 +1424,42 @@
 	return 1;
 }
 
+static int _replicator_emit_segment_line(const struct load_segment *seg, char *params,
+					 size_t paramsize, int *pos)
+{
+	const struct load_segment *rlog_seg;
+	struct replicator_site *rsite;
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
+			    (rsite->mode == DM_REPLICATOR_SYNC) ? "synchronous" : "asynchronous");
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
@@ -1499,6 +1603,21 @@
 		if (!r)
 			return_0;
 		break;
+	case SEG_REPLICATOR:
+		if ((r = _replicator_emit_segment_line(seg, params, paramsize,
+						       &pos)) <= 0) {
+			stack;
+			return r;
+		}
+		break;
+	case SEG_REPLICATOR_DEV:
+		if (!seg->replicator || !_build_dev_string(originbuf,
+							   sizeof(originbuf),
+							   seg->replicator))
+			return_0;
+
+		EMIT_PARAMS(pos, "%s %" PRIu64, originbuf, seg->rdevice_index);
+		break;
 	case SEG_SNAPSHOT:
 	case SEG_SNAPSHOT_MERGE:
 		if (!_build_dev_string(originbuf, sizeof(originbuf), seg->origin))
@@ -1527,6 +1646,7 @@
 
 	switch(seg->type) {
 	case SEG_ERROR:
+	case SEG_REPLICATOR:
 	case SEG_SNAPSHOT:
 	case SEG_SNAPSHOT_ORIGIN:
 	case SEG_SNAPSHOT_MERGE:
@@ -1534,6 +1654,7 @@
 		break;
 	case SEG_CRYPT:
 	case SEG_LINEAR:
+	case SEG_REPLICATOR_DEV:
 	case SEG_STRIPED:
 		if ((r = _emit_areas_line(dmt, seg, params, paramsize, &pos)) <= 0) {
 			stack;
@@ -1996,6 +2117,171 @@
 	return 1;
 }
 
+int dm_tree_node_add_replicator_target(struct dm_tree_node *node,
+				       uint64_t size,
+				       const char *rlog_uuid,
+				       const char *rlog_type,
+				       unsigned rsite_index,
+				       dm_replicator_mode_t mode,
+				       uint32_t async_timeout,
+				       uint64_t fall_behind_data,
+				       uint32_t fall_behind_ios)
+{
+	struct load_segment *rseg;
+	struct replicator_site *rsite;
+
+	/* Local site0 - adds replicator segment and links rlog device */
+	if (rsite_index == REPLICATOR_LOCAL_SITE) {
+		if (node->props.segment_count) {
+			log_error(INTERNAL_ERROR "Attempt to add replicator segment to already used node.");
+			return 0;
+		}
+
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
+			log_error("Unsupported replicator log type %s.", rlog_type);
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
+	/* Add site to segment */
+	if (mode == DM_REPLICATOR_SYNC
+	    && (async_timeout || fall_behind_ios || fall_behind_data)) {
+		log_error("Async parameters passed for synchronnous replicator.");
+		return 0;
+	}
+
+	if (node->props.segment_count != 1) {
+		log_error(INTERNAL_ERROR "Attempt to add remote site area before setting replicator log.");
+		return 0;
+	}
+
+	rseg = dm_list_item(dm_list_last(&node->props.segs), struct load_segment);
+	if (rseg->type != SEG_REPLICATOR) {
+		log_error(INTERNAL_ERROR "Attempt to use non replicator segment %s.",
+			  dm_segtypes[rseg->type].target);
+		return 0;
+	}
+
+	if (!(rsite = dm_pool_zalloc(node->dtree->mem, sizeof(*rsite)))) {
+		log_error("Failed to allocate remote site segment.");
+		return 0;
+	}
+
+	dm_list_add(&rseg->rsites, &rsite->list);
+	rseg->rsite_count++;
+
+	rsite->mode = mode;
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
+					   const char *replicator_uuid,
+					   uint64_t rdevice_index,
+					   const char *rdev_uuid,
+					   unsigned rsite_index,
+					   const char *slog_uuid,
+					   uint32_t slog_flags,
+					   uint32_t slog_region_size)
+{
+	struct seg_area *area;
+	struct load_segment *rseg;
+	struct load_segment *rep_seg;
+
+	if (rsite_index == REPLICATOR_LOCAL_SITE) {
+		/* Site index for local target */
+		if (!(rseg = _add_segment(node, SEG_REPLICATOR_DEV, size)))
+			return_0;
+
+		if (!(rseg->replicator = dm_tree_find_node_by_uuid(node->dtree, replicator_uuid))) {
+			log_error("Missing replicator uuid %s.", replicator_uuid);
+			return 0;
+		}
+
+		/* Local slink0 for replicator must be always initialized first */
+		if (rseg->replicator->props.segment_count != 1) {
+			log_error(INTERNAL_ERROR "Attempt to use non replicator segment.");
+			return 0;
+		}
+
+		rep_seg = dm_list_item(dm_list_last(&rseg->replicator->props.segs), struct load_segment);
+		if (rep_seg->type != SEG_REPLICATOR) {
+			log_error(INTERNAL_ERROR "Attempt to use non replicator segment %s.",
+				  dm_segtypes[rep_seg->type].target);
+			return 0;
+		}
+		rep_seg->rdevice_count++;
+
+		if (!_link_tree_nodes(node, rseg->replicator))
+			return_0;
+
+		rseg->rdevice_index = rdevice_index;
+	} else {
+		/* Local slink0 for replicator must be always initialized first */
+		if (node->props.segment_count != 1) {
+			log_error(INTERNAL_ERROR "Attempt to use non replicator-dev segment.");
+			return 0;
+		}
+
+		rseg = dm_list_item(dm_list_last(&node->props.segs), struct load_segment);
+		if (rseg->type != SEG_REPLICATOR_DEV) {
+			log_error(INTERNAL_ERROR "Attempt to use non replicator-dev segment %s.",
+				  dm_segtypes[rseg->type].target);
+			return 0;
+		}
+	}
+
+	if (!(slog_flags & DM_CORELOG) && !slog_uuid) {
+		log_error("Unspecified sync log uuid.");
+		return 0;
+	}
+
+	if (!dm_tree_node_add_target_area(node, NULL, rdev_uuid, 0))
+		return_0;
+
+	area = dm_list_item(dm_list_last(&rseg->areas), struct seg_area);
+
+	if (!(slog_flags & DM_CORELOG)) {
+		if (!(area->slog = dm_tree_find_node_by_uuid(node->dtree, slog_uuid))) {
+			log_error("Couldn't find sync log uuid %s.", slog_uuid);
+			return 0;
+		}
+
+		if (!_link_tree_nodes(node, area->slog))
+			return_0;
+	}
+
+	area->flags = slog_flags;
+	area->region_size = slog_region_size;
+	area->rsite_index = rsite_index;
+
+	return 1;
+}
+
 static int _add_area(struct dm_tree_node *node, struct load_segment *seg, struct dm_tree_node *dev_node, uint64_t offset)
 {
 	struct seg_area *area;


