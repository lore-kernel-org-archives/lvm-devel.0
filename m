From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 4 Dec 2017 09:57:31 -0500
Subject: master - libdm: support for replicator target is dropped
Message-ID: <201712041457.vB4EvVh5007091@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e447d7ca5e178bc7b13d5aabaef3d160b4655f07
Commit:        e447d7ca5e178bc7b13d5aabaef3d160b4655f07
Parent:        63368a5064dd20a1fb5a2f4110704059c79b3ced
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Dec 4 15:27:05 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Dec 4 15:38:50 2017 +0100

libdm: support for replicator target is dropped

Replicator never really existed in upstream kernel and its support
got deprecated.

Also its support never got finished so no code is supposed to be
using it anyway.

Libdm symbols are remaining, just the implementation will always
return failure - so any user of:

dm_tree_node_add_replicator_dev_target()
dm_tree_node_add_replicator_target().

will now always recieve error message.
---
 WHATS_NEW_DM          |    1 +
 libdm/libdm-deptree.c |  271 ++-----------------------------------------------
 2 files changed, 8 insertions(+), 264 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 56b8153..dfa5a97 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.146 -
 ====================================
+  Remove code supporting replicator target.
   Do not ignore failure of _info_by_dev().
   Propagate delayed resume for pvmove subvolumes.
   Suppress integrity encryption keys in 'table' output unless --showkeys supplied.
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index ff7e9b4..d6c2693 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -24,8 +24,6 @@
 
 #define MAX_TARGET_PARAMSIZE 500000
 
-#define REPLICATOR_LOCAL_SITE 0
-
 /* Supported segment types */
 enum {
 	SEG_CACHE,
@@ -33,8 +31,6 @@ enum {
 	SEG_ERROR,
 	SEG_LINEAR,
 	SEG_MIRRORED,
-	SEG_REPLICATOR,
-	SEG_REPLICATOR_DEV,
 	SEG_SNAPSHOT,
 	SEG_SNAPSHOT_ORIGIN,
 	SEG_SNAPSHOT_MERGE,
@@ -73,8 +69,6 @@ static const struct {
 	{ SEG_ERROR, "error" },
 	{ SEG_LINEAR, "linear" },
 	{ SEG_MIRRORED, "mirror" },
-	{ SEG_REPLICATOR, "replicator" },
-	{ SEG_REPLICATOR_DEV, "replicator-dev" },
 	{ SEG_SNAPSHOT, "snapshot" },
 	{ SEG_SNAPSHOT_ORIGIN, "snapshot-origin" },
 	{ SEG_SNAPSHOT_MERGE, "snapshot-merge" },
@@ -118,11 +112,6 @@ struct seg_area {
 	struct dm_tree_node *dev_node;
 
 	uint64_t offset;
-
-	unsigned rsite_index;		/* Replicator site index */
-	struct dm_tree_node *slog;	/* Replicator sync log node */
-	uint64_t region_size;		/* Replicator sync log size */
-	uint32_t flags;			/* Replicator sync log flags */
 };
 
 struct dm_thin_message {
@@ -151,18 +140,6 @@ struct thin_message {
 	int expected_errno;
 };
 
-/* Replicator-log has a list of sites */
-/* FIXME: maybe move to seg_area too? */
-struct replicator_site {
-	struct dm_list list;
-
-	unsigned rsite_index;
-	dm_replicator_mode_t mode;
-	uint32_t async_timeout;
-	uint32_t fall_behind_ios;
-	uint64_t fall_behind_data;
-};
-
 /* Per-segment properties */
 struct load_segment {
 	struct dm_list list;
@@ -171,8 +148,8 @@ struct load_segment {
 
 	uint64_t size;
 
-	unsigned area_count;		/* Linear + Striped + Mirrored + Crypt + Replicator */
-	struct dm_list areas;		/* Linear + Striped + Mirrored + Crypt + Replicator */
+	unsigned area_count;		/* Linear + Striped + Mirrored + Crypt */
+	struct dm_list areas;		/* Linear + Striped + Mirrored + Crypt */
 
 	uint32_t stripe_size;		/* Striped + raid */
 
@@ -182,7 +159,7 @@ struct load_segment {
 	struct dm_tree_node *origin;	/* Snapshot + Snapshot origin + Cache */
 	struct dm_tree_node *merge;	/* Snapshot */
 
-	struct dm_tree_node *log;	/* Mirror + Replicator */
+	struct dm_tree_node *log;	/* Mirror */
 	uint32_t region_size;		/* Mirror + raid */
 	unsigned clustered;		/* Mirror */
 	unsigned mirror_area_count;	/* Mirror */
@@ -199,13 +176,6 @@ struct load_segment {
 	uint64_t iv_offset;		/* Crypt */
 	const char *key;		/* Crypt */
 
-	const char *rlog_type;		/* Replicator */
-	struct dm_list rsites;		/* Replicator */
-	unsigned rsite_count;		/* Replicator */
-	unsigned rdevice_count;		/* Replicator */
-	struct dm_tree_node *replicator;/* Replicator-dev */
-	uint64_t rdevice_index;		/* Replicator-dev */
-
 	int delta_disks;		/* raid reshape number of disks */
 	int data_offset;		/* raid reshape data offset on disk to set */
 	uint64_t rebuilds[RAID_BITMAP_SIZE];	/* raid */
@@ -2099,47 +2069,9 @@ static int _emit_areas_line(struct dm_task *dmt __attribute__((unused)),
 	struct seg_area *area;
 	char devbuf[DM_FORMAT_DEV_BUFSIZE];
 	unsigned first_time = 1;
-	const char *logtype, *synctype;
-	unsigned log_parm_count;
 
 	dm_list_iterate_items(area, &seg->areas) {
 		switch (seg->type) {
-		case SEG_REPLICATOR_DEV:
-			if (!_build_dev_string(devbuf, sizeof(devbuf), area->dev_node))
-				return_0;
-
-			EMIT_PARAMS(*pos, " %d 1 %s", area->rsite_index, devbuf);
-			if (first_time)
-				EMIT_PARAMS(*pos, " nolog 0");
-			else {
-				/* Remote devices */
-				log_parm_count = (area->flags &
-						  (DM_NOSYNC | DM_FORCESYNC)) ? 2 : 1;
-
-				if (!area->slog) {
-					devbuf[0] = 0;		/* Only core log parameters */
-					logtype = "core";
-				} else {
-					devbuf[0] = ' ';	/* Extra space before device name */
-					if (!_build_dev_string(devbuf + 1,
-							       sizeof(devbuf) - 1,
-							       area->slog))
-						return_0;
-					logtype = "disk";
-					log_parm_count++;	/* Extra sync log device name parameter */
-				}
-
-				EMIT_PARAMS(*pos, " %s %u%s %" PRIu64, logtype,
-					    log_parm_count, devbuf, area->region_size);
-
-				synctype = (area->flags & DM_NOSYNC) ?
-						" nosync" : (area->flags & DM_FORCESYNC) ?
-								" sync" : NULL;
-
-				if (synctype)
-					EMIT_PARAMS(*pos, "%s", synctype);
-			}
-			break;
 		case SEG_RAID0:
 		case SEG_RAID0_META:
 		case SEG_RAID1:
@@ -2181,42 +2113,6 @@ static int _emit_areas_line(struct dm_task *dmt __attribute__((unused)),
 	return 1;
 }
 
-static int _replicator_emit_segment_line(const struct load_segment *seg, char *params,
-					 size_t paramsize, int *pos)
-{
-	const struct load_segment *rlog_seg;
-	struct replicator_site *rsite;
-	char rlogbuf[DM_FORMAT_DEV_BUFSIZE];
-	unsigned parm_count;
-
-	if (!seg->log || !_build_dev_string(rlogbuf, sizeof(rlogbuf), seg->log))
-		return_0;
-
-	rlog_seg = dm_list_item(dm_list_last(&seg->log->props.segs),
-				struct load_segment);
-
-	EMIT_PARAMS(*pos, "%s 4 %s 0 auto %" PRIu64,
-		    seg->rlog_type, rlogbuf, rlog_seg->size);
-
-	dm_list_iterate_items(rsite, &seg->rsites) {
-		parm_count = (rsite->fall_behind_data
-			      || rsite->fall_behind_ios
-			      || rsite->async_timeout) ? 4 : 2;
-
-		EMIT_PARAMS(*pos, " blockdev %u %u %s", parm_count, rsite->rsite_index,
-			    (rsite->mode == DM_REPLICATOR_SYNC) ? "synchronous" : "asynchronous");
-
-		if (rsite->fall_behind_data)
-			EMIT_PARAMS(*pos, " data %" PRIu64, rsite->fall_behind_data);
-		else if (rsite->fall_behind_ios)
-			EMIT_PARAMS(*pos, " ios %" PRIu32, rsite->fall_behind_ios);
-		else if (rsite->async_timeout)
-			EMIT_PARAMS(*pos, " timeout %" PRIu32, rsite->async_timeout);
-	}
-
-	return 1;
-}
-
 /*
  * Returns: 1 on success, 0 on failure
  */
@@ -2677,21 +2573,6 @@ static int _emit_segment_line(struct dm_task *dmt, uint32_t major,
 		if (!r)
 			return_0;
 		break;
-	case SEG_REPLICATOR:
-		if ((r = _replicator_emit_segment_line(seg, params, paramsize,
-						       &pos)) <= 0) {
-			stack;
-			return r;
-		}
-		break;
-	case SEG_REPLICATOR_DEV:
-		if (!seg->replicator || !_build_dev_string(originbuf,
-							   sizeof(originbuf),
-							   seg->replicator))
-			return_0;
-
-		EMIT_PARAMS(pos, "%s %" PRIu64, originbuf, seg->rdevice_index);
-		break;
 	case SEG_SNAPSHOT:
 	case SEG_SNAPSHOT_MERGE:
 		if (!_build_dev_string(originbuf, sizeof(originbuf), seg->origin))
@@ -2757,7 +2638,6 @@ static int _emit_segment_line(struct dm_task *dmt, uint32_t major,
 
 	switch(seg->type) {
 	case SEG_ERROR:
-	case SEG_REPLICATOR:
 	case SEG_SNAPSHOT:
 	case SEG_SNAPSHOT_ORIGIN:
 	case SEG_SNAPSHOT_MERGE:
@@ -2768,7 +2648,6 @@ static int _emit_segment_line(struct dm_task *dmt, uint32_t major,
 		break;
 	case SEG_CRYPT:
 	case SEG_LINEAR:
-	case SEG_REPLICATOR_DEV:
 	case SEG_STRIPED:
 		if ((r = _emit_areas_line(dmt, seg, params, paramsize, &pos)) <= 0) {
 			stack;
@@ -3573,74 +3452,8 @@ int dm_tree_node_add_replicator_target(struct dm_tree_node *node,
 				       uint64_t fall_behind_data,
 				       uint32_t fall_behind_ios)
 {
-	struct load_segment *rseg;
-	struct replicator_site *rsite;
-
-	/* Local site0 - adds replicator segment and links rlog device */
-	if (rsite_index == REPLICATOR_LOCAL_SITE) {
-		if (node->props.segment_count) {
-			log_error(INTERNAL_ERROR "Attempt to add replicator segment to already used node.");
-			return 0;
-		}
-
-		if (!(rseg = _add_segment(node, SEG_REPLICATOR, size)))
-			return_0;
-
-		if (!(rseg->log = dm_tree_find_node_by_uuid(node->dtree, rlog_uuid))) {
-			log_error("Missing replicator log uuid %s.", rlog_uuid);
-			return 0;
-		}
-
-		if (!_link_tree_nodes(node, rseg->log))
-			return_0;
-
-		if (strcmp(rlog_type, "ringbuffer") != 0) {
-			log_error("Unsupported replicator log type %s.", rlog_type);
-			return 0;
-		}
-
-		if (!(rseg->rlog_type = dm_pool_strdup(node->dtree->mem, rlog_type)))
-			return_0;
-
-		dm_list_init(&rseg->rsites);
-		rseg->rdevice_count = 0;
-		node->activation_priority = 1;
-	}
-
-	/* Add site to segment */
-	if (mode == DM_REPLICATOR_SYNC
-	    && (async_timeout || fall_behind_ios || fall_behind_data)) {
-		log_error("Async parameters passed for synchronnous replicator.");
-		return 0;
-	}
-
-	if (node->props.segment_count != 1) {
-		log_error(INTERNAL_ERROR "Attempt to add remote site area before setting replicator log.");
-		return 0;
-	}
-
-	rseg = dm_list_item(dm_list_last(&node->props.segs), struct load_segment);
-	if (rseg->type != SEG_REPLICATOR) {
-		log_error(INTERNAL_ERROR "Attempt to use non replicator segment %s.",
-			  _dm_segtypes[rseg->type].target);
-		return 0;
-	}
-
-	if (!(rsite = dm_pool_zalloc(node->dtree->mem, sizeof(*rsite)))) {
-		log_error("Failed to allocate remote site segment.");
-		return 0;
-	}
-
-	dm_list_add(&rseg->rsites, &rsite->list);
-	rseg->rsite_count++;
-
-	rsite->mode = mode;
-	rsite->async_timeout = async_timeout;
-	rsite->fall_behind_data = fall_behind_data;
-	rsite->fall_behind_ios = fall_behind_ios;
-	rsite->rsite_index = rsite_index;
-
-	return 1;
+	log_error("Replicator segment is unsupported.");
+	return 0;
 }
 
 /* Appends device node to Replicator */
@@ -3654,78 +3467,8 @@ int dm_tree_node_add_replicator_dev_target(struct dm_tree_node *node,
 					   uint32_t slog_flags,
 					   uint32_t slog_region_size)
 {
-	struct seg_area *area;
-	struct load_segment *rseg;
-	struct load_segment *rep_seg;
-
-	if (rsite_index == REPLICATOR_LOCAL_SITE) {
-		/* Site index for local target */
-		if (!(rseg = _add_segment(node, SEG_REPLICATOR_DEV, size)))
-			return_0;
-
-		if (!(rseg->replicator = dm_tree_find_node_by_uuid(node->dtree, replicator_uuid))) {
-			log_error("Missing replicator uuid %s.", replicator_uuid);
-			return 0;
-		}
-
-		/* Local slink0 for replicator must be always initialized first */
-		if (rseg->replicator->props.segment_count != 1) {
-			log_error(INTERNAL_ERROR "Attempt to use non replicator segment.");
-			return 0;
-		}
-
-		rep_seg = dm_list_item(dm_list_last(&rseg->replicator->props.segs), struct load_segment);
-		if (rep_seg->type != SEG_REPLICATOR) {
-			log_error(INTERNAL_ERROR "Attempt to use non replicator segment %s.",
-				  _dm_segtypes[rep_seg->type].target);
-			return 0;
-		}
-		rep_seg->rdevice_count++;
-
-		if (!_link_tree_nodes(node, rseg->replicator))
-			return_0;
-
-		rseg->rdevice_index = rdevice_index;
-	} else {
-		/* Local slink0 for replicator must be always initialized first */
-		if (node->props.segment_count != 1) {
-			log_error(INTERNAL_ERROR "Attempt to use non replicator-dev segment.");
-			return 0;
-		}
-
-		rseg = dm_list_item(dm_list_last(&node->props.segs), struct load_segment);
-		if (rseg->type != SEG_REPLICATOR_DEV) {
-			log_error(INTERNAL_ERROR "Attempt to use non replicator-dev segment %s.",
-				  _dm_segtypes[rseg->type].target);
-			return 0;
-		}
-	}
-
-	if (!(slog_flags & DM_CORELOG) && !slog_uuid) {
-		log_error("Unspecified sync log uuid.");
-		return 0;
-	}
-
-	if (!dm_tree_node_add_target_area(node, NULL, rdev_uuid, 0))
-		return_0;
-
-	area = dm_list_item(dm_list_last(&rseg->areas), struct seg_area);
-
-	if (!(slog_flags & DM_CORELOG)) {
-		if (!(area->slog = dm_tree_find_node_by_uuid(node->dtree, slog_uuid))) {
-			log_error("Couldn't find sync log uuid %s.", slog_uuid);
-			return 0;
-		}
-
-		if (!_link_tree_nodes(node, area->slog))
-			return_0;
-	}
-
-	area->flags = slog_flags;
-	area->region_size = slog_region_size;
-	area->rsite_index = rsite_index;
-
-	return 1;
+	log_error("Replicator targer is unsupported.");
+	return 0;
 }
 
 static struct load_segment *_get_single_load_segment(struct dm_tree_node *node,


