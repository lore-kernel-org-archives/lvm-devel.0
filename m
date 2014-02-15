From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat, 15 Feb 2014 10:38:59 +0000 (UTC)
Subject: master - cache: convert libdm to use plain function call
Message-ID: <20140215103859.37A9E60E70@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=da268eb4cc297d42d123821df3ce441fa4bec293
Commit:        da268eb4cc297d42d123821df3ce441fa4bec293
Parent:        7ec8e691c40e0b42a328366e3201cf4264108434
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Feb 14 22:09:39 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Feb 15 11:36:53 2014 +0100

cache: convert libdm to use plain function call

Avoid introducing libdm structure allocated in library user.
Use direct call with all currently supported args.
When new arg is added, new function will cover it.
---
 lib/cache_segtype/cache.c |   37 ++++++++++++++++---------------------
 libdm/libdevmapper.h      |   29 ++++++++++-------------------
 libdm/libdm-deptree.c     |   44 +++++++++++++++++++++++++++-----------------
 3 files changed, 53 insertions(+), 57 deletions(-)

diff --git a/lib/cache_segtype/cache.c b/lib/cache_segtype/cache.c
index 2217922..78a23d7 100644
--- a/lib/cache_segtype/cache.c
+++ b/lib/cache_segtype/cache.c
@@ -359,34 +359,29 @@ static int _cache_add_target_line(struct dev_manager *dm,
 				 struct dm_tree_node *node, uint64_t len,
 				 uint32_t *pvmove_mirror_count __attribute__((unused)))
 {
-	struct logical_volume *data, *metadata, *origin;
 	struct lv_segment *cache_pool_seg = first_seg(seg->pool_lv);
-	struct dm_tree_node_cache_params params = {
-		.chunk_size = cache_pool_seg->chunk_size,
-
-		/* Cache features, core args, and policy are stored in the cache_pool */
-		.feature_flags = cache_pool_seg->feature_flags,
-		.core_argc = cache_pool_seg->core_argc,
-		.core_argv = cache_pool_seg->core_argv,
-		.policy_name = cache_pool_seg->policy_name,
-		.policy_argc = cache_pool_seg->policy_argc,
-		.policy_argv = cache_pool_seg->policy_argv
-	};
-
-	data = seg_lv(cache_pool_seg, 0);
-	metadata = cache_pool_seg->metadata_lv;
-	origin = seg_lv(seg, 0);
-
-	if (!(params.data_uuid = build_dm_uuid(mem, data->lvid.s, NULL)))
+	char *metadata_uuid, *data_uuid, *origin_uuid;
+
+	if (!(metadata_uuid = build_dm_uuid(mem, cache_pool_seg->metadata_lv->lvid.s, NULL)))
 		return_0;
 
-	if (!(params.metadata_uuid = build_dm_uuid(mem, metadata->lvid.s, NULL)))
+	if (!(data_uuid = build_dm_uuid(mem, seg_lv(cache_pool_seg, 0)->lvid.s, NULL)))
 		return_0;
 
-	if (!(params.origin_uuid = build_dm_uuid(mem, origin->lvid.s, NULL)))
+	if (!(origin_uuid = build_dm_uuid(mem, seg_lv(seg, 0)->lvid.s, NULL)))
 		return_0;
 
-	if (!dm_tree_node_add_cache_target(node, len, &params))
+	if (!dm_tree_node_add_cache_target(node, len,
+					   metadata_uuid,
+					   data_uuid,
+					   origin_uuid,
+					   cache_pool_seg->chunk_size,
+					   cache_pool_seg->feature_flags,
+					   cache_pool_seg->core_argc,
+					   cache_pool_seg->core_argv,
+					   cache_pool_seg->policy_name,
+					   cache_pool_seg->policy_argc,
+					   cache_pool_seg->policy_argv))
 		return_0;
 
 	return add_areas_line(dm, seg, node, 0u, seg->area_count);
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index b50501e..112ec27 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -764,28 +764,19 @@ int dm_tree_node_add_raid_target_with_params(struct dm_tree_node *node,
 /* Cache feature_flags */
 #define DM_CACHE_FEATURE_WRITEBACK    0x00000001
 #define DM_CACHE_FEATURE_WRITETHROUGH 0x00000002
-struct dm_tree_node_cache_params {
-	uint32_t version;
-
-	uint32_t chunk_size;
-	uint32_t feature_flags; /* DM_CACHE_FEATURE_* */
-
-	int core_argc;
-	char **core_argv;
-
-	char *policy_name;
-	int   policy_argc;
-	char **policy_argv;
-
-	const char *data_uuid;
-	const char *metadata_uuid;
-	const char *origin_uuid;
-	/* 'version == 0' end */
-};
 
 int dm_tree_node_add_cache_target(struct dm_tree_node *node,
 				  uint64_t size,
-				  struct dm_tree_node_cache_params *p);
+				  const char *metadata_uuid,
+				  const char *data_uuid,
+				  const char *origin_uuid,
+				  uint32_t chunk_size,
+				  uint32_t feature_flags, /* DM_CACHE_FEATURE_* */
+				  int core_argc,
+				  char **core_argv,
+				  char *policy_name,
+				  int   policy_argc,
+				  char **policy_argv);
 
 /*
  * Replicator operation mode
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 72c30a2..d2a54eb 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -2284,19 +2284,18 @@ static int _cache_emit_segment_line(struct dm_task *dmt,
 	/* Metadata Dev */
 	if (!_build_dev_string(metadata, sizeof(metadata), seg->metadata))
 		return_0;
-	EMIT_PARAMS(pos, " %s", metadata);
 
 	/* Cache Dev */
 	if (!_build_dev_string(data, sizeof(origin), seg->pool))
 		return_0;
-	EMIT_PARAMS(pos, " %s", data);
 
 	/* Origin Dev */
 	dm_list_iterate_items(area, &seg->areas)
 		break; /* There is only ever 1 area */
 	if (!_build_dev_string(origin, sizeof(data), area->dev_node))
 		return_0;
-	EMIT_PARAMS(pos, " %s", origin);
+
+	EMIT_PARAMS(pos, " %s %s %s", metadata, data, origin);
 
 	/* Chunk size */
 	EMIT_PARAMS(pos, " %u", seg->chunk_size);
@@ -3202,7 +3201,16 @@ bad:
 
 int dm_tree_node_add_cache_target(struct dm_tree_node *node,
 				  uint64_t size,
-				  struct dm_tree_node_cache_params *p)
+				  const char *metadata_uuid,
+				  const char *data_uuid,
+				  const char *origin_uuid,
+				  uint32_t chunk_size,
+				  uint32_t feature_flags, /* DM_CACHE_FEATURE_* */
+				  int core_argc,
+				  char **core_argv,
+				  char *policy_name,
+				  int   policy_argc,
+				  char **policy_argv)
 {
 	int i;
 	struct load_segment *seg = NULL;
@@ -3218,33 +3226,35 @@ int dm_tree_node_add_cache_target(struct dm_tree_node *node,
 		return_0;
 
 	if (!(seg->pool = dm_tree_find_node_by_uuid(node->dtree,
-						    p->data_uuid))) {
-		log_error("Missing cache's data uuid, %s",
-			  p->data_uuid);
+						    data_uuid))) {
+		log_error("Missing cache's data uuid %s.",
+			  data_uuid);
 		return 0;
 	}
 	if (!_link_tree_nodes(node, seg->pool))
 		return_0;
 
 	if (!(seg->metadata = dm_tree_find_node_by_uuid(node->dtree,
-							p->metadata_uuid))) {
-		log_error("Missing cache's metadata uuid, %s",
-			  p->metadata_uuid);
+							metadata_uuid))) {
+		log_error("Missing cache's metadata uuid %s.",
+			  metadata_uuid);
 		return 0;
 	}
 	if (!_link_tree_nodes(node, seg->metadata))
 		return_0;
 
-	seg->chunk_size = p->chunk_size;
+	seg->chunk_size = chunk_size;
+
+	seg->flags = feature_flags;
 
-	seg->flags = p->feature_flags;
+	/* FIXME: validation missing */
 
-	seg->core_argc = p->core_argc;
-	seg->core_argv = p->core_argv;
+	seg->core_argc = core_argc;
+	seg->core_argv = core_argv;
 
-	seg->policy_name = p->policy_name;
-	seg->policy_argc = p->policy_argc;
-	seg->policy_argv = p->policy_argv;
+	seg->policy_name = policy_name;
+	seg->policy_argc = policy_argc;
+	seg->policy_argv = policy_argv;
 
 	return 1;
 }


