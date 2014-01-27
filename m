From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Mon, 27 Jan 2014 22:21:43 +0000 (UTC)
Subject: master - cache: New 'cache' segment type
Message-ID: <20140127222143.A950061171@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1ff7e214e0cf0e7ef0280b71ab128e029172a1d9
Commit:        1ff7e214e0cf0e7ef0280b71ab128e029172a1d9
Parent:        90bbed325544365efa177a9823019c44f5109dbb
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Mon Jan 27 05:29:35 2014 -0600
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Mon Jan 27 05:29:35 2014 -0600

cache:  New 'cache' segment type

This patch adds the cache segment type - the second of two necessary
to create cache logical volumes.  This segment type references the
cachepool (the small fast device) and the origin (the large slow device);
linking them to create the cache device.  The cache device is the
hierarchical device-mapper device that the user ulitmately makes use
of.

The cache segment sources the information necessary to construct the
device-mapper cache target from the origin and cachepool segments to
which it links.
---
 lib/cache_segtype/cache.c |  126 +++++++++++++++++++++++++++++++++++++++++
 libdm/libdevmapper.h      |   22 +++++++
 libdm/libdm-deptree.c     |  137 +++++++++++++++++++++++++++++++++++++++++++--
 3 files changed, 279 insertions(+), 6 deletions(-)

diff --git a/lib/cache_segtype/cache.c b/lib/cache_segtype/cache.c
index 0c60b7e..c12ac2f 100644
--- a/lib/cache_segtype/cache.c
+++ b/lib/cache_segtype/cache.c
@@ -284,6 +284,116 @@ static struct segtype_handler _cache_pool_ops = {
 	.destroy = _destroy,
 };
 
+static int _cache_text_import(struct lv_segment *seg,
+			      const struct dm_config_node *sn,
+			      struct dm_hash_table *pv_hash __attribute__((unused)))
+{
+	struct logical_volume *pool_lv, *origin_lv;
+	const char *name = NULL;
+
+	if (!dm_config_has_node(sn, "cache_pool"))
+		return SEG_LOG_ERROR("cache_pool not specified in");
+	if (!(name = dm_config_find_str(sn, "cache_pool", NULL)))
+		return SEG_LOG_ERROR("cache_pool must be a string in");
+	if (!(pool_lv = find_lv(seg->lv->vg, name)))
+		return SEG_LOG_ERROR("Unknown logical volume %s specified for "
+			  "cache_pool in", name);
+
+	if (!dm_config_has_node(sn, "origin"))
+		return SEG_LOG_ERROR("Cache origin not specified in");
+	if (!(name = dm_config_find_str(sn, "origin", NULL)))
+		return SEG_LOG_ERROR("Cache origin must be a string in");
+	if (!(origin_lv = find_lv(seg->lv->vg, name)))
+		return SEG_LOG_ERROR("Unknown logical volume %s specified for "
+			  "cache origin in", name);
+
+	if (!set_lv_segment_area_lv(seg, 0, origin_lv, 0, 0))
+		return_0;
+	if (!attach_pool_lv(seg, pool_lv, NULL, NULL))
+		return_0;
+
+	return 1;
+}
+
+static int _cache_text_import_area_count(const struct dm_config_node *sn,
+					 uint32_t *area_count)
+{
+	*area_count = 1;
+
+	return 1;
+}
+
+static int _cache_text_export(const struct lv_segment *seg, struct formatter *f)
+{
+	if (!seg_lv(seg, 0))
+		return_0;
+
+	outf(f, "cache_pool = \"%s\"", seg->pool_lv->name);
+	outf(f, "origin = \"%s\"", seg_lv(seg, 0)->name);
+
+	return 1;
+}
+
+static int _cache_add_target_line(struct dev_manager *dm,
+				 struct dm_pool *mem,
+				 struct cmd_context *cmd __attribute__((unused)),
+				 void **target_state __attribute__((unused)),
+				 struct lv_segment *seg,
+				 const struct lv_activate_opts *laopts __attribute__((unused)),
+				 struct dm_tree_node *node, uint64_t len,
+				 uint32_t *pvmove_mirror_count __attribute__((unused)))
+{
+	struct lv_segment *cache_pool_seg;
+	struct logical_volume *data, *metadata, *origin;
+	struct dm_tree_node_cache_params params;
+
+	cache_pool_seg = first_seg(seg->pool_lv);
+	data = seg_lv(cache_pool_seg, 0);
+	metadata = cache_pool_seg->metadata_lv;
+	origin = seg_lv(seg, 0);
+
+	memset(&params, 0, sizeof(params));
+
+	params.chunk_size = cache_pool_seg->chunk_size;
+
+	if (!(params.data_uuid = build_dm_uuid(mem, data->lvid.s, NULL)))
+		return_0;
+
+	if (!(params.metadata_uuid = build_dm_uuid(mem, metadata->lvid.s, NULL)))
+		return_0;
+
+	if (!(params.origin_uuid = build_dm_uuid(mem, origin->lvid.s, NULL)))
+		return_0;
+
+	/* Cache features, core args, and policy are stored in the cache_pool */
+	params.feature_flags = cache_pool_seg->feature_flags;
+	params.policy_argc = cache_pool_seg->core_argc;
+	params.policy_argv = cache_pool_seg->core_argv;
+	params.policy_name = cache_pool_seg->policy_name;
+	params.policy_argc = cache_pool_seg->policy_argc;
+	params.policy_argv = cache_pool_seg->policy_argv;
+
+	if (!dm_tree_node_add_cache_target(node, len, &params))
+		return_0;
+
+	return add_areas_line(dm, seg, node, 0u, seg->area_count);
+}
+
+static struct segtype_handler _cache_ops = {
+	.name = _name,
+	.text_import = _cache_text_import,
+	.text_import_area_count = _cache_text_import_area_count,
+	.text_export = _cache_text_export,
+	.add_target_line = _cache_add_target_line,
+#ifdef DEVMAPPER_SUPPORT
+	.target_present = _target_present,
+#  ifdef DMEVENTD
+#  endif        /* DMEVENTD */
+#endif
+	.modules_needed = _modules_needed,
+	.destroy = _destroy,
+};
+
 #ifdef CACHE_INTERNAL /* Shared */
 int init_cache_segtypes(struct cmd_context *cmd,
 			struct segtype_library *seglib)
@@ -311,6 +421,22 @@ int init_cache_segtypes(struct cmd_context *cmd,
 		return_0;
 	log_very_verbose("Initialised segtype: %s", segtype->name);
 
+	segtype = dm_zalloc(sizeof(*segtype));
+	if (!segtype) {
+		log_error("Failed to allocate memory for cache segtype");
+		return 0;
+	}
+	segtype->cmd = cmd;
+
+	segtype->name = "cache";
+	segtype->flags = SEG_CACHE;
+	segtype->ops = &_cache_ops;
+	segtype->private = NULL;
+
+	if (!lvm_register_segtype(seglib, segtype))
+		return_0;
+	log_very_verbose("Initialised segtype: %s", segtype->name);
+
 	return 1;
 }
 
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 3074500..ae9a91a 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -715,6 +715,28 @@ int dm_tree_node_add_raid_target_with_params(struct dm_tree_node *node,
 /* Cache feature_flags */
 #define DM_CACHE_FEATURE_WRITEBACK    0x00000001
 #define DM_CACHE_FEATURE_WRITETHROUGH 0x00000002
+struct dm_tree_node_cache_params {
+	uint32_t version;
+
+	uint32_t chunk_size;
+	uint32_t feature_flags; /* DM_CACHE_FEATURE_* */
+
+	int core_argc;
+	char **core_argv;
+
+	char *policy_name;
+	int   policy_argc;
+	char **policy_argv;
+
+	const char *data_uuid;
+	const char *metadata_uuid;
+	const char *origin_uuid;
+	/* 'version == 0' end */
+};
+
+int dm_tree_node_add_cache_target(struct dm_tree_node *node,
+				  uint64_t size,
+				  struct dm_tree_node_cache_params *p);
 
 /*
  * Replicator operation mode
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 42bb9e7..d3f6640 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2005-2013 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2005-2014 Red Hat, Inc. All rights reserved.
  *
  * This file is part of the device-mapper userspace tools.
  *
@@ -27,6 +27,7 @@
 
 /* Supported segment types */
 enum {
+	SEG_CACHE,
 	SEG_CRYPT,
 	SEG_ERROR,
 	SEG_LINEAR,
@@ -59,6 +60,7 @@ struct {
 	unsigned type;
 	const char *target;
 } dm_segtypes[] = {
+	{ SEG_CACHE, "cache" },
 	{ SEG_CRYPT, "crypt" },
 	{ SEG_ERROR, "error" },
 	{ SEG_LINEAR, "linear" },
@@ -158,18 +160,24 @@ struct load_segment {
 	uint32_t stripe_size;		/* Striped + raid */
 
 	int persistent;			/* Snapshot */
-	uint32_t chunk_size;		/* Snapshot */
+	uint32_t chunk_size;		/* Snapshot + cache */
 	struct dm_tree_node *cow;	/* Snapshot */
-	struct dm_tree_node *origin;	/* Snapshot + Snapshot origin */
+	struct dm_tree_node *origin;	/* Snapshot + Snapshot origin + Cache */
 	struct dm_tree_node *merge;	/* Snapshot */
 
 	struct dm_tree_node *log;	/* Mirror + Replicator */
 	uint32_t region_size;		/* Mirror + raid */
 	unsigned clustered;		/* Mirror */
 	unsigned mirror_area_count;	/* Mirror */
-	uint32_t flags;			/* Mirror log */
+	uint32_t flags;			/* Mirror + raid + Cache */
 	char *uuid;			/* Clustered mirror log */
 
+	int   core_argc;		/* Cache */
+	char **core_argv;		/* Cache */
+	char *policy_name;		/* Cache */
+	int   policy_argc;		/* Cache */
+	char **policy_argv;		/* Cache */
+
 	const char *cipher;		/* Crypt */
 	const char *chainmode;		/* Crypt */
 	const char *iv;			/* Crypt */
@@ -189,7 +197,7 @@ struct load_segment {
 	uint32_t max_recovery_rate;	/* raid kB/sec/disk */
 	uint32_t min_recovery_rate;	/* raid kB/sec/disk */
 
-	struct dm_tree_node *metadata;	/* Thin_pool */
+	struct dm_tree_node *metadata;	/* Thin_pool + Cache */
 	struct dm_tree_node *pool;	/* Thin_pool, Thin */
 	struct dm_tree_node *external;	/* Thin */
 	struct dm_list thin_messages;	/* Thin_pool */
@@ -2262,6 +2270,70 @@ static int _raid_emit_segment_line(struct dm_task *dmt, uint32_t major,
 	return 1;
 }
 
+static int _cache_emit_segment_line(struct dm_task *dmt,
+				    struct load_segment *seg,
+				    char *params, size_t paramsize)
+{
+	int i, pos = 0;
+	unsigned feature_count;
+	struct seg_area *area;
+	char data[DM_FORMAT_DEV_BUFSIZE];
+	char metadata[DM_FORMAT_DEV_BUFSIZE];
+	char origin[DM_FORMAT_DEV_BUFSIZE];
+
+	/* Metadata Dev */
+	if (!_build_dev_string(metadata, sizeof(metadata), seg->metadata))
+		return_0;
+	EMIT_PARAMS(pos, " %s", metadata);
+
+	/* Cache Dev */
+	if (!_build_dev_string(data, sizeof(origin), seg->pool))
+		return_0;
+	EMIT_PARAMS(pos, " %s", data);
+
+	/* Origin Dev */
+	dm_list_iterate_items(area, &seg->areas)
+		break; /* There is only ever 1 area */
+	if (!_build_dev_string(origin, sizeof(data), area->dev_node))
+		return_0;
+	EMIT_PARAMS(pos, " %s", origin);
+
+	/* Chunk size */
+	EMIT_PARAMS(pos, " %u", seg->chunk_size);
+
+	/* Features */
+	feature_count = hweight32(seg->flags);
+	EMIT_PARAMS(pos, " %d", feature_count);
+	if (seg->flags & DM_CACHE_FEATURE_WRITETHROUGH)
+		EMIT_PARAMS(pos, " writethrough");
+	else if (seg->flags & DM_CACHE_FEATURE_WRITEBACK)
+		EMIT_PARAMS(pos, " writeback");
+
+	/* Core Arguments (like 'migration_threshold') */
+	if (seg->core_argc) {
+		EMIT_PARAMS(pos, " %d", seg->core_argc);
+		for (i = 0; i < seg->core_argc; i++)
+			EMIT_PARAMS(pos, " %s", seg->core_argv[i]);
+	}
+
+	/* Cache Policy */
+	if (!seg->policy_name)
+		EMIT_PARAMS(pos, " default 0");
+	else {
+		EMIT_PARAMS(pos, " %s %d", seg->policy_name, seg->policy_argc);
+		if (seg->policy_argc % 2) {
+			log_error(INTERNAL_ERROR
+				  "Cache policy arguments must be in "
+				  "<key> <value> pairs");
+			return 0;
+		}
+		for (i = 0; i < seg->policy_argc; i++)
+			EMIT_PARAMS(pos, " %s", seg->policy_argv[i]);
+	}
+
+	return 1;
+}
+
 static int _thin_pool_emit_segment_line(struct dm_task *dmt,
 					struct load_segment *seg,
 					char *params, size_t paramsize)
@@ -2398,6 +2470,10 @@ static int _emit_segment_line(struct dm_task *dmt, uint32_t major,
 		if (!_thin_emit_segment_line(dmt, seg, params, paramsize))
 			return_0;
 		break;
+	case SEG_CACHE:
+		if (!_cache_emit_segment_line(dmt, seg, params, paramsize))
+			return_0;
+		break;
 	}
 
 	switch(seg->type) {
@@ -2409,6 +2485,7 @@ static int _emit_segment_line(struct dm_task *dmt, uint32_t major,
 	case SEG_ZERO:
 	case SEG_THIN_POOL:
 	case SEG_THIN:
+	case SEG_CACHE:
 		break;
 	case SEG_CRYPT:
 	case SEG_LINEAR:
@@ -3045,7 +3122,6 @@ int dm_tree_node_add_raid_target(struct dm_tree_node *node,
 	return dm_tree_node_add_raid_target_with_params(node, size, &params);
 }
 
-
 /*
  * Various RAID status versions include:
  * Versions < 1.5.0 (4 fields):
@@ -3124,6 +3200,55 @@ bad:
 	return 0;
 }
 
+int dm_tree_node_add_cache_target(struct dm_tree_node *node,
+				  uint64_t size,
+				  struct dm_tree_node_cache_params *p)
+{
+	int i;
+	struct load_segment *seg = NULL;
+
+	for (i = 0; dm_segtypes[i].target && !seg; i++) {
+		if (strcmp("cache", dm_segtypes[i].target))
+			continue;
+		if (!(seg = _add_segment(node, dm_segtypes[i].type, size)))
+			return_0;
+	}
+
+	if (!seg)
+		return_0;
+
+	if (!(seg->pool = dm_tree_find_node_by_uuid(node->dtree,
+						    p->data_uuid))) {
+		log_error("Missing cache's data uuid, %s",
+			  p->data_uuid);
+		return 0;
+	}
+	if (!_link_tree_nodes(node, seg->pool))
+		return_0;
+
+	if (!(seg->metadata = dm_tree_find_node_by_uuid(node->dtree,
+							p->metadata_uuid))) {
+		log_error("Missing cache's metadata uuid, %s",
+			  p->metadata_uuid);
+		return 0;
+	}
+	if (!_link_tree_nodes(node, seg->metadata))
+		return_0;
+
+	seg->chunk_size = p->chunk_size;
+
+	seg->flags = p->feature_flags;
+
+	seg->core_argc = p->core_argc;
+	seg->core_argv = p->core_argv;
+
+	seg->policy_name = p->policy_name;
+	seg->policy_argc = p->policy_argc;
+	seg->policy_argv = p->policy_argv;
+
+	return 1;
+}
+
 int dm_tree_node_add_replicator_target(struct dm_tree_node *node,
 				       uint64_t size,
 				       const char *rlog_uuid,


