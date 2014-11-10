From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 10 Nov 2014 21:06:27 +0000 (UTC)
Subject: master - libdm: tunning cache API
Message-ID: <20141110210627.A414360799@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=824019531cbba02c722cb0bf0957ac84eccef3b9
Commit:        824019531cbba02c722cb0bf0957ac84eccef3b9
Parent:        3dbcd2a1c9027c08faab726a1f1a24085046f0df
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Nov 8 23:20:25 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 10 22:05:48 2014 +0100

libdm: tunning cache API

Support new PASSTHROUGH 'feature' flag.

Add dm_config_node to pass in policy args.

Really use origin_uuid instead of using extra call
to pass seg_areas.

Switch to 64bit feature flag bit set so there is
enough space in future for new bits...
---
 WHATS_NEW_DM              |    1 +
 lib/cache_segtype/cache.c |    9 +---
 libdm/libdevmapper.h      |   30 ++++++++++---
 libdm/libdm-deptree.c     |  103 +++++++++++++++++++++++----------------------
 4 files changed, 79 insertions(+), 64 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 0305077..f4148bc 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.91 - 
 ====================================
+  Update API for cache creation and dm_config_node to pass policy.
   Allow activation of any thin-pool with passed transaction_id == 0.
   Don't print uninitialized stack bytes when non-root uses dm_check_version().
   Fix selection criteria to not match reserved values when using >, <, >=, <.
diff --git a/lib/cache_segtype/cache.c b/lib/cache_segtype/cache.c
index e5512bf..ea480de 100644
--- a/lib/cache_segtype/cache.c
+++ b/lib/cache_segtype/cache.c
@@ -332,16 +332,13 @@ static int _cache_add_target_line(struct dev_manager *dm,
 		return_0;
 
 	if (!dm_tree_node_add_cache_target(node, len,
+					   cache_pool_seg->feature_flags,
 					   metadata_uuid,
 					   data_uuid,
 					   origin_uuid,
-					   cache_pool_seg->chunk_size,
-					   cache_pool_seg->feature_flags,
-					   cache_pool_seg->core_argc,
-					   cache_pool_seg->core_argv,
+					   NULL,
 					   cache_pool_seg->policy_name,
-					   cache_pool_seg->policy_argc,
-					   cache_pool_seg->policy_argv))
+					   cache_pool_seg->chunk_size))
 		return_0;
 
 	return add_areas_line(dm, seg, node, 0u, seg->area_count);
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 76c4eee..62a5941 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -320,7 +320,7 @@ struct dm_status_cache {
 	uint64_t demotions;
 	uint64_t promotions;
 
-	uint32_t feature_flags;
+	uint64_t feature_flags;
 
 	int core_argc;
 	char **core_argv;
@@ -774,19 +774,35 @@ int dm_tree_node_add_raid_target_with_params(struct dm_tree_node *node,
 /* Cache feature_flags */
 #define DM_CACHE_FEATURE_WRITEBACK    0x00000001
 #define DM_CACHE_FEATURE_WRITETHROUGH 0x00000002
+#define DM_CACHE_FEATURE_PASSTHROUGH  0x00000004
 
+struct dm_config_node;
+/*
+ * Use for passing cache policy and all its args e.g.:
+ *
+ *   mq {
+ *	migration_threshold=2048
+ *	sequention_threashold=100
+ *	...
+ *   }
+ *
+ * For policy without any parameters simply specify policy_name.
+ */
 int dm_tree_node_add_cache_target(struct dm_tree_node *node,
 				  uint64_t size,
+				  uint64_t feature_flags, /* DM_CACHE_FEATURE_* */
 				  const char *metadata_uuid,
 				  const char *data_uuid,
 				  const char *origin_uuid,
-				  uint32_t chunk_size,
-				  uint32_t feature_flags, /* DM_CACHE_FEATURE_* */
-				  unsigned core_argc,
-				  const char *const *core_argv,
+				  const struct dm_config_node *policy,
 				  const char *policy_name,
-				  unsigned policy_argc,
-				  const char *const *policy_argv);
+				  uint32_t chunk_size);
+
+/*
+ * TODO: Add individual cache policy pairs  <key> = value, like:
+ *int dm_tree_node_add_cache_policy_arg(struct dm_tree_node *dnode,
+ *				      const char *key, uint64_t value);
+ */
 
 /*
  * Replicator operation mode
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index d120bf5..6521360 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -171,11 +171,9 @@ struct load_segment {
 	uint32_t flags;			/* Mirror + raid + Cache */
 	char *uuid;			/* Clustered mirror log */
 
-	unsigned core_argc;		/* Cache */
-	const char *const *core_argv;	/* Cache */
 	const char *policy_name;	/* Cache */
 	unsigned policy_argc;		/* Cache */
-	const char *const *policy_argv;	/* Cache */
+	struct dm_config_node *policy;	/* Cache */
 
 	const char *cipher;		/* Crypt */
 	const char *chainmode;		/* Crypt */
@@ -2366,25 +2364,23 @@ static int _cache_emit_segment_line(struct dm_task *dmt,
 				    char *params, size_t paramsize)
 {
 	int pos = 0;
-	unsigned i = 0;
-	unsigned feature_count;
-	struct seg_area *area;
+	/* unsigned feature_count; */
 	char data[DM_FORMAT_DEV_BUFSIZE];
 	char metadata[DM_FORMAT_DEV_BUFSIZE];
 	char origin[DM_FORMAT_DEV_BUFSIZE];
+	const char *name;
+	struct dm_config_node *cn;
 
-	/* Metadata Dev */
-	if (!_build_dev_string(metadata, sizeof(metadata), seg->metadata))
+	/* Cache Dev */
+	if (!_build_dev_string(data, sizeof(data), seg->pool))
 		return_0;
 
-	/* Cache Dev */
-	if (!_build_dev_string(data, sizeof(origin), seg->pool))
+	/* Metadata Dev */
+	if (!_build_dev_string(metadata, sizeof(metadata), seg->metadata))
 		return_0;
 
 	/* Origin Dev */
-	dm_list_iterate_items(area, &seg->areas)
-		break; /* There is only ever 1 area */
-	if (!_build_dev_string(origin, sizeof(data), area->dev_node))
+	if (!_build_dev_string(origin, sizeof(origin), seg->origin))
 		return_0;
 
 	EMIT_PARAMS(pos, " %s %s %s", metadata, data, origin);
@@ -2393,34 +2389,24 @@ static int _cache_emit_segment_line(struct dm_task *dmt,
 	EMIT_PARAMS(pos, " %u", seg->chunk_size);
 
 	/* Features */
-	feature_count = hweight32(seg->flags);
-	EMIT_PARAMS(pos, " %u", feature_count);
-	if (seg->flags & DM_CACHE_FEATURE_WRITETHROUGH)
-		EMIT_PARAMS(pos, " writethrough");
+	/* feature_count = hweight32(seg->flags); */
+	/* EMIT_PARAMS(pos, " %u", feature_count); */
+	if (seg->flags & DM_CACHE_FEATURE_PASSTHROUGH)
+		EMIT_PARAMS(pos, " 1 passthrough");
+	else if (seg->flags & DM_CACHE_FEATURE_WRITETHROUGH)
+		EMIT_PARAMS(pos, " 1 writethrough");
 	else if (seg->flags & DM_CACHE_FEATURE_WRITEBACK)
-		EMIT_PARAMS(pos, " writeback");
-
-	/* Core Arguments (like 'migration_threshold') */
-	if (seg->core_argc) {
-		EMIT_PARAMS(pos, " %u", seg->core_argc);
-		for (i = 0; i < seg->core_argc; i++)
-			EMIT_PARAMS(pos, " %s", seg->core_argv[i]);
-	}
+		EMIT_PARAMS(pos, " 1 writeback");
 
 	/* Cache Policy */
-	if (!seg->policy_name)
-		EMIT_PARAMS(pos, " default 0");
-	else {
-		EMIT_PARAMS(pos, " %s %u", seg->policy_name, seg->policy_argc);
-		if (seg->policy_argc % 2) {
-			log_error(INTERNAL_ERROR
-				  "Cache policy arguments must be in "
-				  "<key> <value> pairs");
-			return 0;
-		}
-		for (i = 0; i < seg->policy_argc; i++)
-			EMIT_PARAMS(pos, " %s", seg->policy_argv[i]);
-	}
+	name = seg->policy_name ? : seg->policy ? seg->policy->key : "default";
+
+	EMIT_PARAMS(pos, " %s", name);
+
+	EMIT_PARAMS(pos, " %u", seg->policy_argc * 2);
+	if (seg->policy)
+		for (cn = seg->policy->child; cn; cn = cn->sib)
+			EMIT_PARAMS(pos, " %s %" PRIu64, cn->key, cn->v->v.i);
 
 	return 1;
 }
@@ -3313,17 +3299,15 @@ bad:
 
 int dm_tree_node_add_cache_target(struct dm_tree_node *node,
 				  uint64_t size,
+				  uint64_t feature_flags, /* DM_CACHE_FEATURE_* */
 				  const char *metadata_uuid,
 				  const char *data_uuid,
 				  const char *origin_uuid,
-				  uint32_t chunk_size,
-				  uint32_t feature_flags, /* DM_CACHE_FEATURE_* */
-				  unsigned core_argc,
-				  const char *const *core_argv,
+				  const struct dm_config_node *policy,
 				  const char *policy_name,
-				  unsigned policy_argc,
-				  const char *const *policy_argv)
+				  uint32_t chunk_size)
 {
+	struct dm_config_node *cn;
 	struct load_segment *seg;
 
 	if (!(seg = _add_segment(node, SEG_CACHE, size)))
@@ -3347,18 +3331,35 @@ int dm_tree_node_add_cache_target(struct dm_tree_node *node,
 	if (!_link_tree_nodes(node, seg->metadata))
 		return_0;
 
-	seg->chunk_size = chunk_size;
 
+	if (!(seg->origin = dm_tree_find_node_by_uuid(node->dtree,
+						      origin_uuid))) {
+		log_error("Missing cache's origin uuid %s.",
+			  metadata_uuid);
+		return 0;
+	}
+	if (!_link_tree_nodes(node, seg->origin))
+		return_0;
+
+	seg->chunk_size = chunk_size;
 	seg->flags = feature_flags;
+	seg->policy_name = policy_name;
 
-	/* FIXME: validation missing */
+	/* FIXME: better validation missing */
+	if (policy) {
+		if (!(seg->policy = dm_config_clone_node_with_mem(node->dtree->mem, policy, 0)))
+			return_0;
 
-	seg->core_argc = core_argc;
-	seg->core_argv = core_argv;
+		for (cn = seg->policy->child; cn; cn = cn->sib) {
+			if (!cn->v || (cn->v->type != DM_CFG_INT)) {
+				/* For now only  <key> = <int>  pairs are supported */
+				log_error("Cache policy parameter %s is without integer value.", cn->key);
+				return 0;
+			}
+			seg->policy_argc++;
+		}
+	}
 
-	seg->policy_name = policy_name;
-	seg->policy_argc = policy_argc;
-	seg->policy_argv = policy_argv;
 
 	return 1;
 }


