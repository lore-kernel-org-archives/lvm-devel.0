From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 10 Nov 2014 23:56:29 +0000 (UTC)
Subject: master - libdm: still better API
Message-ID: <20141110235629.3C1EA6030A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=20b22cd023bdfd30301305ba5b78655619d965f1
Commit:        20b22cd023bdfd30301305ba5b78655619d965f1
Parent:        ca509c97467f5f077463c54fee185442cb98f817
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 10 23:41:03 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Nov 11 00:54:03 2014 +0100

libdm: still better API

Do not use 'any' policy name as a value in config tree - so we stick
with 'policy_settings' and extra 'policy_name' for libdm params.

Update lvm2 API as well.

Example of supported metadata:

 policy = "mq"
 policy_settings {
      migration_threshold = 2048
      sequential_threshold = 512
      random_threshold = 4
      read_promote_adjustment = 10
 }
---
 lib/cache_segtype/cache.c        |   43 +++++++++++++++++++++++++------------
 lib/config/defaults.h            |    1 +
 lib/metadata/metadata-exported.h |    3 +-
 libdm/libdevmapper.h             |   14 ++++++------
 libdm/libdm-deptree.c            |   16 +++++++-------
 5 files changed, 47 insertions(+), 30 deletions(-)

diff --git a/lib/cache_segtype/cache.c b/lib/cache_segtype/cache.c
index ab9d4a0..b42a529 100644
--- a/lib/cache_segtype/cache.c
+++ b/lib/cache_segtype/cache.c
@@ -71,9 +71,18 @@ static int _cache_pool_text_import(struct lv_segment *seg,
 			return SEG_LOG_ERROR("Unknown cache_mode in");
 	}
 
+	if (dm_config_has_node(sn, "policy")) {
+		if (!(str = dm_config_find_str(sn, "policy", NULL)))
+			return SEG_LOG_ERROR("policy must be a string in");
+		if (!(seg->policy_name = dm_pool_strdup(mem, str)))
+			return SEG_LOG_ERROR("Failed to duplicate policy in");
+	} else
+		/* Cannot use 'just' default, so pick one */
+		seg->policy_name = DEFAULT_CACHE_POOL_POLICY; /* TODO: configurable default */
+
 	/*
 	 * Read in policy args:
-	 *   mq {
+	 *   policy_settings {
 	 *	migration_threshold=2048
 	 *	sequention_threashold=100
 	 *	random_threashold=200
@@ -88,14 +97,13 @@ static int _cache_pool_text_import(struct lv_segment *seg,
 	 *
 	 *   If the policy is not present, default policy is used.
 	 */
-	for (; sn; sn = sn->sib)
-		if (!sn->v) {
-			if (seg->policy_args)
-				return SEG_LOG_ERROR("only a singly policy is supported for");
+	if ((sn = dm_config_find_node(sn, "policy_settings"))) {
+		if (sn->v)
+			return SEG_LOG_ERROR("policy_settings must be a section in");
 
-			if (!(seg->policy_args = dm_config_clone_node_with_mem(mem, sn, 0)))
-				return_0;
-		}
+		if (!(seg->policy_settings = dm_config_clone_node_with_mem(mem, sn, 0)))
+			return_0;
+	}
 
 	if (!attach_pool_data_lv(seg, data_lv))
 		return_0;
@@ -126,8 +134,17 @@ static int _cache_pool_text_export(const struct lv_segment *seg,
 	outf(f, "chunk_size = %" PRIu32, seg->chunk_size);
 	outf(f, "cache_mode = \"%s\"", cache_mode);
 
-	if (seg->policy_args)
-		out_config_node(f, seg->policy_args);
+	if (seg->policy_name)
+		outf(f, "policy = \"%s\"", seg->policy_name);
+
+	if (seg->policy_settings) {
+		if (strcmp(seg->policy_settings->key, "policy_settings")) {
+			log_error(INTERNAL_ERROR "Incorrect policy_settings tree, %s.",
+				  seg->policy_settings->key);
+			return 0;
+		}
+		out_config_node(f, seg->policy_settings);
+	}
 
 	return 1;
 }
@@ -266,8 +283,6 @@ static int _cache_add_target_line(struct dev_manager *dm,
 {
 	struct lv_segment *cache_pool_seg = first_seg(seg->pool_lv);
 	char *metadata_uuid, *data_uuid, *origin_uuid;
-	const char *policy_name = seg->cleaner_policy ? "cleaner" :
-		cache_pool_seg->policy_args ? cache_pool_seg->policy_args->key : NULL;
 
 	if (!(metadata_uuid = build_dm_uuid(mem, cache_pool_seg->metadata_lv, NULL)))
 		return_0;
@@ -283,8 +298,8 @@ static int _cache_add_target_line(struct dev_manager *dm,
 					   metadata_uuid,
 					   data_uuid,
 					   origin_uuid,
-					   seg->cleaner_policy ? NULL : cache_pool_seg->policy_args,
-					   policy_name,
+					   seg->cleaner_policy ? "cleaner" : cache_pool_seg->policy_name,
+					   seg->cleaner_policy ? NULL : cache_pool_seg->policy_settings,
 					   cache_pool_seg->chunk_size))
 		return_0;
 
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index acf768b..cbc95fb 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -96,6 +96,7 @@
 #define DEFAULT_CACHE_POOL_MIN_METADATA_SIZE 2048  /* KB */
 #define DEFAULT_CACHE_POOL_MAX_METADATA_SIZE (16 * 1024 * 1024)  /* KB */
 #define DEFAULT_CACHE_POOL_CACHEMODE "writethrough"
+#define DEFAULT_CACHE_POOL_POLICY "mq"
 
 #define DEFAULT_UMASK 0077
 
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 0ba1ed5..375f7be 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -432,7 +432,8 @@ struct lv_segment {
 	uint32_t device_id;			/* For thin, 24bit */
 
 	uint64_t feature_flags;			/* For cache_pool */
-	struct dm_config_node *policy_args;	/* For cache_pool  (-> policy_name) */
+	const char *policy_name;		/* For cache_pool */
+	struct dm_config_node *policy_settings;	/* For cache_pool */
 	unsigned cleaner_policy;		/* For cache */
 
 	struct logical_volume *replicator;/* For replicator-devs - link to replicator LV */
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 62a5941..9ea7dbe 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -780,13 +780,13 @@ struct dm_config_node;
 /*
  * Use for passing cache policy and all its args e.g.:
  *
- *   mq {
- *	migration_threshold=2048
- *	sequention_threashold=100
- *	...
- *   }
+ * policy_settings {
+ *    migration_threshold=2048
+ *    sequention_threashold=100
+ *    ...
+ * }
  *
- * For policy without any parameters simply specify policy_name.
+ * For policy without any parameters use NULL.
  */
 int dm_tree_node_add_cache_target(struct dm_tree_node *node,
 				  uint64_t size,
@@ -794,8 +794,8 @@ int dm_tree_node_add_cache_target(struct dm_tree_node *node,
 				  const char *metadata_uuid,
 				  const char *data_uuid,
 				  const char *origin_uuid,
-				  const struct dm_config_node *policy,
 				  const char *policy_name,
+				  const struct dm_config_node *policy_settings,
 				  uint32_t chunk_size);
 
 /*
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 70373a2..c3a5df6 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -173,7 +173,7 @@ struct load_segment {
 
 	const char *policy_name;	/* Cache */
 	unsigned policy_argc;		/* Cache */
-	struct dm_config_node *policy;	/* Cache */
+	struct dm_config_node *policy_settings;	/* Cache */
 
 	const char *cipher;		/* Crypt */
 	const char *chainmode;		/* Crypt */
@@ -2399,13 +2399,13 @@ static int _cache_emit_segment_line(struct dm_task *dmt,
 		EMIT_PARAMS(pos, " 1 writeback");
 
 	/* Cache Policy */
-	name = seg->policy_name ? : seg->policy ? seg->policy->key : "default";
+	name = seg->policy_name ? : "default";
 
 	EMIT_PARAMS(pos, " %s", name);
 
 	EMIT_PARAMS(pos, " %u", seg->policy_argc * 2);
-	if (seg->policy)
-		for (cn = seg->policy->child; cn; cn = cn->sib)
+	if (seg->policy_settings)
+		for (cn = seg->policy_settings->child; cn; cn = cn->sib)
 			EMIT_PARAMS(pos, " %s %" PRIu64, cn->key, cn->v->v.i);
 
 	return 1;
@@ -3303,8 +3303,8 @@ int dm_tree_node_add_cache_target(struct dm_tree_node *node,
 				  const char *metadata_uuid,
 				  const char *data_uuid,
 				  const char *origin_uuid,
-				  const struct dm_config_node *policy,
 				  const char *policy_name,
+				  const struct dm_config_node *policy_settings,
 				  uint32_t chunk_size)
 {
 	struct dm_config_node *cn;
@@ -3346,11 +3346,11 @@ int dm_tree_node_add_cache_target(struct dm_tree_node *node,
 	seg->policy_name = policy_name;
 
 	/* FIXME: better validation missing */
-	if (policy) {
-		if (!(seg->policy = dm_config_clone_node_with_mem(node->dtree->mem, policy, 0)))
+	if (policy_settings) {
+		if (!(seg->policy_settings = dm_config_clone_node_with_mem(node->dtree->mem, policy_settings, 0)))
 			return_0;
 
-		for (cn = seg->policy->child; cn; cn = cn->sib) {
+		for (cn = seg->policy_settings->child; cn; cn = cn->sib) {
 			if (!cn->v || (cn->v->type != DM_CFG_INT)) {
 				/* For now only  <key> = <int>  pairs are supported */
 				log_error("Cache policy parameter %s is without integer value.", cn->key);


