From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  8 Apr 2014 09:02:38 +0000 (UTC)
Subject: master - libdm: simplify segtype search
Message-ID: <20140408090238.942F960EFA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6190ded5f1e7862758ff4a18f8a4030331e655d4
Commit:        6190ded5f1e7862758ff4a18f8a4030331e655d4
Parent:        6d3d2d5e3da3e870e2df07c32cea4dfbbeab572c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 4 22:34:22 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 8 11:00:13 2014 +0200

libdm: simplify segtype search

For cache target use directly SEG_CACHE.
Hide dm_segtypes as internal static variable _dm_segtypes,
since noone is supposed to use it.
---
 libdm/libdm-deptree.c |   47 ++++++++++++++++++-----------------------------
 1 files changed, 18 insertions(+), 29 deletions(-)

diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 8336249..7c4da9b 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -51,15 +51,14 @@ enum {
 	SEG_RAID6_ZR,
 	SEG_RAID6_NR,
 	SEG_RAID6_NC,
-	SEG_LAST,
 };
 
 /* FIXME Add crypt and multipath support */
 
-struct {
+static const struct {
 	unsigned type;
-	const char *target;
-} dm_segtypes[] = {
+	const char target[16];
+} _dm_segtypes[] = {
 	{ SEG_CACHE, "cache" },
 	{ SEG_CRYPT, "crypt" },
 	{ SEG_ERROR, "error" },
@@ -91,7 +90,6 @@ struct {
 	 */
 	{ SEG_RAID5_LS, "raid5"}, /* same as "raid5_ls" (default for MD also) */
 	{ SEG_RAID6_ZR, "raid6"}, /* same as "raid6_zr" */
-	{ SEG_LAST, NULL },
 };
 
 /* Some segment types have a list of areas of other devices attached */
@@ -2243,7 +2241,7 @@ static int _raid_emit_segment_line(struct dm_task *dmt, uint32_t major,
 	if ((seg->type == SEG_RAID1) && seg->stripe_size)
 		log_error("WARNING: Ignoring RAID1 stripe size");
 
-	EMIT_PARAMS(pos, "%s %d %u", dm_segtypes[seg->type].target,
+	EMIT_PARAMS(pos, "%s %d %u", _dm_segtypes[seg->type].target,
 		    param_count, seg->stripe_size);
 
 	if (seg->flags & DM_NOSYNC)
@@ -2509,7 +2507,7 @@ static int _emit_segment_line(struct dm_task *dmt, uint32_t major,
 		}
 		if (!params[0]) {
 			log_error("No parameters supplied for %s target "
-				  "%u:%u.", dm_segtypes[seg->type].target,
+				  "%u:%u.", _dm_segtypes[seg->type].target,
 				  major, minor);
 			return 0;
 		}
@@ -2519,11 +2517,11 @@ static int _emit_segment_line(struct dm_task *dmt, uint32_t major,
 	log_debug_activation("Adding target to (%" PRIu32 ":%" PRIu32 "): %" PRIu64
 			     " %" PRIu64 " %s %s", major, minor,
 			     *seg_start, seg->size, target_type_is_raid ? "raid" :
-			     dm_segtypes[seg->type].target, params);
+			     _dm_segtypes[seg->type].target, params);
 
 	if (!dm_task_add_target(dmt, *seg_start, seg->size,
 				target_type_is_raid ? "raid" :
-				dm_segtypes[seg->type].target, params))
+				_dm_segtypes[seg->type].target, params))
 		return_0;
 
 	*seg_start += seg->size;
@@ -3110,12 +3108,11 @@ int dm_tree_node_add_raid_target_with_params(struct dm_tree_node *node,
 	int i;
 	struct load_segment *seg = NULL;
 
-	for (i = 0; dm_segtypes[i].target && !seg; i++)
-		if (!strcmp(p->raid_type, dm_segtypes[i].target))
+	for (i = 0; i < DM_ARRAY_SIZE(_dm_segtypes) && !seg; ++i)
+		if (!strcmp(p->raid_type, _dm_segtypes[i].target))
 			if (!(seg = _add_segment(node,
-						 dm_segtypes[i].type, size)))
+						 _dm_segtypes[i].type, size)))
 				return_0;
-
 	if (!seg)
 		return_0;
 
@@ -3242,17 +3239,9 @@ int dm_tree_node_add_cache_target(struct dm_tree_node *node,
 				  unsigned policy_argc,
 				  const char *const *policy_argv)
 {
-	int i;
-	struct load_segment *seg = NULL;
-
-	for (i = 0; dm_segtypes[i].target && !seg; i++) {
-		if (strcmp("cache", dm_segtypes[i].target))
-			continue;
-		if (!(seg = _add_segment(node, dm_segtypes[i].type, size)))
-			return_0;
-	}
+	struct load_segment *seg;
 
-	if (!seg)
+	if (!(seg = _add_segment(node, SEG_CACHE, size)))
 		return_0;
 
 	if (!(seg->pool = dm_tree_find_node_by_uuid(node->dtree,
@@ -3485,7 +3474,7 @@ int dm_tree_node_add_replicator_target(struct dm_tree_node *node,
 	rseg = dm_list_item(dm_list_last(&node->props.segs), struct load_segment);
 	if (rseg->type != SEG_REPLICATOR) {
 		log_error(INTERNAL_ERROR "Attempt to use non replicator segment %s.",
-			  dm_segtypes[rseg->type].target);
+			  _dm_segtypes[rseg->type].target);
 		return 0;
 	}
 
@@ -3540,7 +3529,7 @@ int dm_tree_node_add_replicator_dev_target(struct dm_tree_node *node,
 		rep_seg = dm_list_item(dm_list_last(&rseg->replicator->props.segs), struct load_segment);
 		if (rep_seg->type != SEG_REPLICATOR) {
 			log_error(INTERNAL_ERROR "Attempt to use non replicator segment %s.",
-				  dm_segtypes[rep_seg->type].target);
+				  _dm_segtypes[rep_seg->type].target);
 			return 0;
 		}
 		rep_seg->rdevice_count++;
@@ -3559,7 +3548,7 @@ int dm_tree_node_add_replicator_dev_target(struct dm_tree_node *node,
 		rseg = dm_list_item(dm_list_last(&node->props.segs), struct load_segment);
 		if (rseg->type != SEG_REPLICATOR_DEV) {
 			log_error(INTERNAL_ERROR "Attempt to use non replicator-dev segment %s.",
-				  dm_segtypes[rseg->type].target);
+				  _dm_segtypes[rseg->type].target);
 			return 0;
 		}
 	}
@@ -3598,15 +3587,15 @@ static struct load_segment *_get_single_load_segment(struct dm_tree_node *node,
 
 	if (node->props.segment_count != 1) {
 		log_error("Node %s must have only one segment.",
-			  dm_segtypes[type].target);
+			  _dm_segtypes[type].target);
 		return NULL;
 	}
 
 	seg = dm_list_item(dm_list_last(&node->props.segs), struct load_segment);
 	if (seg->type != type) {
 		log_error("Node %s has segment type %s.",
-			  dm_segtypes[type].target,
-			  dm_segtypes[seg->type].target);
+			  _dm_segtypes[type].target,
+			  _dm_segtypes[seg->type].target);
 		return NULL;
 	}
 


