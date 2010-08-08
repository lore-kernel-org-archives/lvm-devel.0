From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Sun,  8 Aug 2010 10:57:13 +0200
Subject: [PATCH 01/25] Update libdm for replicator
In-Reply-To: <cover.1281256234.git.zkabelac@redhat.com>
References: <cover.1281256234.git.zkabelac@redhat.com>
Message-ID: <b1e321fc04e86957bcdd6200379477f1a1798ca8.1281256235.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add units to passed parameters data & timeout
Switch fall_behind_data->fall_behind_size
Switch async_timeout->fall_behind_timeout
Keep ordered as in lvm library.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 libdm/libdevmapper.h  |   12 ++++++------
 libdm/libdm-deptree.c |   48 +++++++++++++++++++++++++-----------------------
 2 files changed, 31 insertions(+), 29 deletions(-)

diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index e535d2b..b1bfbf3 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -459,18 +459,18 @@ typedef enum {
 	DM_REPLICATOR_ASYNC_STALL,		/* Stall replicator if not fast enough */
 	DM_REPLICATOR_ASYNC_DROP,		/* Drop sites out of sync */
 	DM_REPLICATOR_ASYNC_FAIL,		/* Fail replicator if slow */
-	NUM_DM_REPLICATOR_MODES
-} dm_replicator_mode_t;
+	NUM_DM_REPLICATOR_POLICIES
+} dm_replicator_policy_t;
 
 int dm_tree_node_add_replicator_target(struct dm_tree_node *node,
 				       uint64_t size,
 				       const char *rlog_uuid,
 				       const char *rlog_type,
 				       unsigned rsite_index,
-				       dm_replicator_mode_t mode,
-				       uint32_t async_timeout,
-				       uint64_t fall_behind_data,
-				       uint32_t fall_behind_ios);
+				       dm_replicator_policy_t policy,
+				       uint32_t fall_behind_ios,
+				       uint64_t fall_behind_size,
+				       uint32_t fall_behind_timeout);
 
 int dm_tree_node_add_replicator_dev_target(struct dm_tree_node *node,
 					   uint64_t size,
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 0e49127..5a12c5f 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -83,10 +83,10 @@ struct replicator_site {
 	struct dm_list list;
 
 	unsigned rsite_index;
-	dm_replicator_mode_t mode;
-	uint32_t async_timeout;
+	dm_replicator_policy_t policy;
 	uint32_t fall_behind_ios;
-	uint64_t fall_behind_data;
+	uint64_t fall_behind_size;
+	uint32_t fall_behind_timeout;
 };
 
 /* Per-segment properties */
@@ -1512,19 +1512,19 @@ static int _replicator_emit_segment_line(const struct load_segment *seg, char *p
 		    seg->rlog_type, rlogbuf, rlog_seg->size);
 
 	dm_list_iterate_items(rsite, &seg->rsites) {
-		parm_count = (rsite->fall_behind_data
-			      || rsite->fall_behind_ios
-			      || rsite->async_timeout) ? 4 : 2;
+		parm_count = (rsite->fall_behind_ios ||
+			      rsite->fall_behind_size ||
+			      rsite->fall_behind_timeout) ? 4 : 2;
 
 		EMIT_PARAMS(*pos, " blockdev %u %u %s", parm_count, rsite->rsite_index,
-			    (rsite->mode == DM_REPLICATOR_SYNC) ? "synchronous" : "asynchronous");
+			    (rsite->policy == DM_REPLICATOR_SYNC) ? "synchronous" : "asynchronous");
 
-		if (rsite->fall_behind_data)
-			EMIT_PARAMS(*pos, " data %" PRIu64, rsite->fall_behind_data);
-		else if (rsite->fall_behind_ios)
+		if (rsite->fall_behind_ios)
 			EMIT_PARAMS(*pos, " ios %" PRIu32, rsite->fall_behind_ios);
-		else if (rsite->async_timeout)
-			EMIT_PARAMS(*pos, " timeout %" PRIu32, rsite->async_timeout);
+		else if (rsite->fall_behind_size)
+			EMIT_PARAMS(*pos, " size %" PRIu64 "s", rsite->fall_behind_size);
+		else if (rsite->fall_behind_timeout)
+			EMIT_PARAMS(*pos, " timeout %" PRIu32 "s", rsite->fall_behind_timeout);
 	}
 
 	return 1;
@@ -2214,10 +2214,10 @@ int dm_tree_node_add_replicator_target(struct dm_tree_node *node,
 				       const char *rlog_uuid,
 				       const char *rlog_type,
 				       unsigned rsite_index,
-				       dm_replicator_mode_t mode,
-				       uint32_t async_timeout,
-				       uint64_t fall_behind_data,
-				       uint32_t fall_behind_ios)
+				       dm_replicator_policy_t policy,
+				       uint32_t fall_behind_ios,
+				       uint64_t fall_behind_size,
+				       uint32_t fall_behind_timeout)
 {
 	struct load_segment *rseg;
 	struct replicator_site *rsite;
@@ -2245,8 +2245,10 @@ int dm_tree_node_add_replicator_target(struct dm_tree_node *node,
 			return 0;
 		}
 
-		if (!(rseg->rlog_type = dm_pool_strdup(node->dtree->mem, rlog_type)))
-			return_0;
+		if (!(rseg->rlog_type = dm_pool_strdup(node->dtree->mem, rlog_type))) {
+			log_error("Failed to allocate replicator log type.");
+			return 0;
+		}
 
 		dm_list_init(&rseg->rsites);
 		rseg->rdevice_count = 0;
@@ -2254,8 +2256,8 @@ int dm_tree_node_add_replicator_target(struct dm_tree_node *node,
 	}
 
 	/* Add site to segment */
-	if (mode == DM_REPLICATOR_SYNC
-	    && (async_timeout || fall_behind_ios || fall_behind_data)) {
+	if ((policy == DM_REPLICATOR_SYNC) &&
+	    (fall_behind_ios || fall_behind_size || fall_behind_timeout)) {
 		log_error("Async parameters passed for synchronnous replicator.");
 		return 0;
 	}
@@ -2280,10 +2282,10 @@ int dm_tree_node_add_replicator_target(struct dm_tree_node *node,
 	dm_list_add(&rseg->rsites, &rsite->list);
 	rseg->rsite_count++;
 
-	rsite->mode = mode;
-	rsite->async_timeout = async_timeout;
-	rsite->fall_behind_data = fall_behind_data;
+	rsite->policy = policy;
 	rsite->fall_behind_ios = fall_behind_ios;
+	rsite->fall_behind_size = fall_behind_size;
+	rsite->fall_behind_timeout = fall_behind_timeout;
 	rsite->rsite_index = rsite_index;
 
 	return 1;
-- 
1.7.2.1


