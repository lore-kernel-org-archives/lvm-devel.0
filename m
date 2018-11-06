From: David Teigland <teigland@sourceware.org>
Date: Tue, 6 Nov 2018 16:43:54 -0500
Subject: master - Allow dm-cache cache device to be standard LV
Message-ID: <201811062143.wA6LhsZ8004842@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cac4a9743acb826d785c0e51e9a752d8959ced80
Commit:        cac4a9743acb826d785c0e51e9a752d8959ced80
Parent:        8c9d9a744605e37799a2475932ae7dfd43831d08
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Aug 17 15:45:52 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Nov 6 13:44:54 2018 -0600

Allow dm-cache cache device to be standard LV

If a single, standard LV is specified as the cache, use
it directly instead of converting it into a cache-pool
object with two separate LVs (for data and metadata).

With a single LV as the cache, lvm will use blocks at the
beginning for metadata, and the rest for data.  Separate
dm linear devices are set up to point at the metadata and
data areas of the LV.  These dm devs are given to the
dm-cache target to use.

The single LV cache cannot be resized without recreating it.

If the --poolmetadata option is used to specify an LV for
metadata, then a cache pool will be created (with separate
LVs for data and metadata.)

Usage:

$ lvcreate -n main -L 128M vg /dev/loop0

$ lvcreate -n fast -L 64M vg /dev/loop1

$ lvs -a vg
  LV   VG Attr       LSize   Type   Devices
  main vg -wi-a----- 128.00m linear /dev/loop0(0)
  fast vg -wi-a-----  64.00m linear /dev/loop1(0)

$ lvconvert --type cache --cachepool fast vg/main

$ lvs -a vg
  LV           VG Attr       LSize   Origin       Pool  Type   Devices
  [fast]       vg Cwi---C---  64.00m                     linear /dev/loop1(0)
  main         vg Cwi---C--- 128.00m [main_corig] [fast] cache  main_corig(0)
  [main_corig] vg owi---C--- 128.00m                     linear /dev/loop0(0)

$ lvchange -ay vg/main

$ dmsetup ls
vg-fast_cdata   (253:4)
vg-fast_cmeta   (253:5)
vg-main_corig   (253:6)
vg-main (253:24)
vg-fast (253:3)

$ dmsetup table
vg-fast_cdata: 0 98304 linear 253:3 32768
vg-fast_cmeta: 0 32768 linear 253:3 0
vg-main_corig: 0 262144 linear 7:0 2048
vg-main: 0 262144 cache 253:5 253:4 253:6 128 2 metadata2 writethrough mq 0
vg-fast: 0 131072 linear 7:1 2048

$ lvchange -an vg/min

$ lvconvert --splitcache vg/main

$ lvs -a vg
  LV   VG Attr       LSize   Type   Devices
  fast vg -wi-------  64.00m linear /dev/loop1(0)
  main vg -wi------- 128.00m linear /dev/loop0(0)
---
 device_mapper/all.h                |    4 +
 device_mapper/libdm-deptree.c      |   15 +-
 lib/activate/dev_manager.c         |  269 ++++++++++++++++++++-
 lib/activate/dev_manager.h         |   10 +
 lib/cache_segtype/cache.c          |  125 +++++++++-
 lib/format_text/flags.c            |    1 +
 lib/locking/lvmlockd.c             |    3 +
 lib/metadata/cache_manip.c         |  478 +++++++++++++++++++++++++++++++++---
 lib/metadata/lv.c                  |   18 +-
 lib/metadata/lv_manip.c            |   10 +-
 lib/metadata/merge.c               |   43 +++-
 lib/metadata/metadata-exported.h   |   24 ++-
 lib/report/report.c                |   20 ++-
 test/shell/cache-single-options.sh |  269 ++++++++++++++++++++
 test/shell/cache-single-thin.sh    |   43 ++++
 test/shell/cache-single-types.sh   |   88 +++++++
 test/shell/cache-single-usage.sh   |  129 ++++++++++
 test/shell/lvconvert-cache-raid.sh |   41 ++--
 test/shell/lvconvert-cache.sh      |    1 +
 test/shell/lvrename-cache-thin.sh  |    2 +
 tools/lvchange.c                   |    5 +-
 tools/lvconvert.c                  |  174 ++++++++++++--
 tools/vgsplit.c                    |    5 +-
 23 files changed, 1666 insertions(+), 111 deletions(-)

diff --git a/device_mapper/all.h b/device_mapper/all.h
index e56bae9..0f01075 100644
--- a/device_mapper/all.h
+++ b/device_mapper/all.h
@@ -912,6 +912,10 @@ int dm_tree_node_add_cache_target(struct dm_tree_node *node,
 				  const char *origin_uuid,
 				  const char *policy_name,
 				  const struct dm_config_node *policy_settings,
+				  uint64_t metadata_start,
+				  uint64_t metadata_len,
+				  uint64_t data_start,
+				  uint64_t data_len,
 				  uint32_t data_block_size);
 
 /*
diff --git a/device_mapper/libdm-deptree.c b/device_mapper/libdm-deptree.c
index 5d03545..13239c7 100644
--- a/device_mapper/libdm-deptree.c
+++ b/device_mapper/libdm-deptree.c
@@ -189,6 +189,11 @@ struct load_segment {
 	uint32_t min_recovery_rate;	/* raid kB/sec/disk */
 	uint32_t data_copies;		/* raid10 data_copies */
 
+	uint64_t metadata_start;	/* Cache */
+	uint64_t metadata_len;		/* Cache */
+	uint64_t data_start;		/* Cache */
+	uint64_t data_len;		/* Cache */
+
 	struct dm_tree_node *metadata;	/* Thin_pool + Cache */
 	struct dm_tree_node *pool;	/* Thin_pool, Thin */
 	struct dm_tree_node *external;	/* Thin */
@@ -3473,6 +3478,10 @@ int dm_tree_node_add_cache_target(struct dm_tree_node *node,
 				  const char *origin_uuid,
 				  const char *policy_name,
 				  const struct dm_config_node *policy_settings,
+				  uint64_t metadata_start,
+				  uint64_t metadata_len,
+				  uint64_t data_start,
+				  uint64_t data_len,
 				  uint32_t data_block_size)
 {
 	struct dm_config_node *cn;
@@ -3548,6 +3557,10 @@ int dm_tree_node_add_cache_target(struct dm_tree_node *node,
 	if (!_link_tree_nodes(node, seg->origin))
 		return_0;
 
+	seg->metadata_start = metadata_start;
+	seg->metadata_len = metadata_len;
+	seg->data_start = data_start;
+	seg->data_len = data_len;
 	seg->data_block_size = data_block_size;
 	seg->flags = feature_flags;
 	seg->policy_name = policy_name;
@@ -4026,7 +4039,7 @@ int dm_tree_node_add_cache_target_base(struct dm_tree_node *node,
 
 	return dm_tree_node_add_cache_target(node, size, feature_flags & _mask,
 					     metadata_uuid, data_uuid, origin_uuid,
-					     policy_name, policy_settings, data_block_size);
+					     policy_name, policy_settings, 0, 0, 0, 0, data_block_size);
 }
 #endif
 
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 15dec6f..1249581 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -827,6 +827,113 @@ static int _info(struct cmd_context *cmd,
 	return 1;
 }
 
+/* FIXME: could we just use dev_manager_info instead of this? */
+
+int get_cache_single_meta_data(struct cmd_context *cmd,
+				    struct logical_volume *lv,
+				    struct logical_volume *pool_lv,
+				    struct dm_info *info_meta, struct dm_info *info_data)
+{
+	struct lv_segment *lvseg = first_seg(lv);
+	union lvid lvid_meta;
+	union lvid lvid_data;
+	char *name_meta;
+	char *name_data;
+	char *dlid_meta;
+	char *dlid_data;
+
+	memset(&lvid_meta, 0, sizeof(lvid_meta));
+	memset(&lvid_data, 0, sizeof(lvid_meta));
+	memcpy(&lvid_meta.id[0], &lv->vg->id, sizeof(struct id));
+	memcpy(&lvid_meta.id[1], &lvseg->metadata_id, sizeof(struct id));
+	memcpy(&lvid_data.id[0], &lv->vg->id, sizeof(struct id));
+	memcpy(&lvid_data.id[1], &lvseg->data_id, sizeof(struct id));
+
+	if (!(dlid_meta = dm_build_dm_uuid(cmd->mem, UUID_PREFIX, (const char *)&lvid_meta.s, NULL)))
+		return_0;
+	if (!(dlid_data = dm_build_dm_uuid(cmd->mem, UUID_PREFIX, (const char *)&lvid_data.s, NULL)))
+		return_0;
+	if (!(name_meta = dm_build_dm_name(cmd->mem, lv->vg->name, pool_lv->name, "_cmeta")))
+		return_0;
+	if (!(name_data = dm_build_dm_name(cmd->mem, lv->vg->name, pool_lv->name, "_cdata")))
+		return_0;
+
+	if (!_info(cmd, name_meta, dlid_meta, 1, 0, info_meta, NULL, NULL))
+		return_0;
+
+	if (!_info(cmd, name_data, dlid_data, 1, 0, info_data, NULL, NULL))
+		return_0;
+
+	return 1;
+}
+
+/*
+ * FIXME: isn't there a simpler, more direct way to just remove these two dm
+ * devs?
+ */
+
+int remove_cache_single_meta_data(struct cmd_context *cmd,
+				       struct dm_info *info_meta, struct dm_info *info_data)
+{
+	struct dm_tree *dtree;
+	struct dm_tree_node *root;
+	struct dm_tree_node *child;
+	const char *uuid;
+	void *handle = NULL;
+
+	if (!(dtree = dm_tree_create()))
+		goto_out;
+
+	if (!dm_tree_add_dev(dtree, info_meta->major, info_meta->minor))
+		goto_out;
+
+	if (!dm_tree_add_dev(dtree, info_data->major, info_data->minor))
+		goto_out;
+
+	if (!(root = dm_tree_find_node(dtree, 0, 0)))
+		goto_out;
+
+	while ((child = dm_tree_next_child(&handle, root, 0))) {
+		if (!(uuid = dm_tree_node_get_uuid(child))) {
+			stack;
+			continue;
+		}
+
+		if (!dm_tree_deactivate_children(root, uuid, strlen(uuid))) {
+			stack;
+			continue;
+		}
+	}
+
+	dm_tree_free(dtree);
+	return 1;
+ out:
+	dm_tree_free(dtree);
+	return 0;
+}
+
+int dev_manager_remove_dm_major_minor(uint32_t major, uint32_t minor)
+{
+	struct dm_task *dmt;
+	int r = 0;
+
+	log_verbose("Removing dm dev %u:%u", major, minor);
+
+	if (!(dmt = dm_task_create(DM_DEVICE_REMOVE)))
+		return_0;
+
+	if (!dm_task_set_major(dmt, major) || !dm_task_set_minor(dmt, minor)) {
+		log_error("Failed to set device number for remove %u:%u", major, minor);
+		goto out;
+	}
+
+	r = dm_task_run(dmt);
+out:
+	dm_task_destroy(dmt);
+
+	return r;
+}
+
 static int _info_by_dev(uint32_t major, uint32_t minor, struct dm_info *info)
 {
 	return _info_run(NULL, info, NULL, 0, 0, 0, major, minor);
@@ -2236,6 +2343,10 @@ static int _pool_register_callback(struct dev_manager *dm,
 		return 1;
 #endif
 
+	/* Skip for single-device cache pool */
+	if (lv_is_cache(lv) && lv_is_cache_single(first_seg(lv)->pool_lv))
+		return 1;
+
 	if (!(data = dm_pool_zalloc(dm->mem, sizeof(*data)))) {
 		log_error("Failed to allocated path for callback.");
 		return 0;
@@ -2303,6 +2414,53 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		/* Unused cache pool is activated as metadata */
 	}
 
+	if (lv_is_cache(lv) && lv_is_cache_single(first_seg(lv)->pool_lv) && dm->activation) {
+		struct logical_volume *pool_lv = first_seg(lv)->pool_lv;
+		struct lv_segment *lvseg = first_seg(lv);
+		struct dm_info info_meta;
+		struct dm_info info_data;
+		union lvid lvid_meta;
+		union lvid lvid_data;
+		char *name_meta;
+		char *name_data;
+		char *dlid_meta;
+		char *dlid_data;
+
+		memset(&lvid_meta, 0, sizeof(lvid_meta));
+		memset(&lvid_data, 0, sizeof(lvid_meta));
+		memcpy(&lvid_meta.id[0], &lv->vg->id, sizeof(struct id));
+		memcpy(&lvid_meta.id[1], &lvseg->metadata_id, sizeof(struct id));
+		memcpy(&lvid_data.id[0], &lv->vg->id, sizeof(struct id));
+		memcpy(&lvid_data.id[1], &lvseg->data_id, sizeof(struct id));
+
+		if (!(dlid_meta = dm_build_dm_uuid(dm->mem, UUID_PREFIX, (const char *)&lvid_meta.s, NULL)))
+			return_0;
+		if (!(dlid_data = dm_build_dm_uuid(dm->mem, UUID_PREFIX, (const char *)&lvid_data.s, NULL)))
+			return_0;
+		if (!(name_meta = dm_build_dm_name(dm->mem, lv->vg->name, pool_lv->name, "_cmeta")))
+			return_0;
+		if (!(name_data = dm_build_dm_name(dm->mem, lv->vg->name, pool_lv->name, "_cdata")))
+			return_0;
+
+		if (!_info(dm->cmd, name_meta, dlid_meta, 1, 0, &info_meta, NULL, NULL))
+			return_0;
+
+		if (!_info(dm->cmd, name_data, dlid_data, 1, 0, &info_data, NULL, NULL))
+			return_0;
+
+		if (info_meta.exists &&
+		    !dm_tree_add_dev_with_udev_flags(dtree, info_meta.major, info_meta.minor,
+						     _get_udev_flags(dm, lv, NULL, 0, 0, 0))) {
+			log_error("Failed to add device (%" PRIu32 ":%" PRIu32") to dtree.", info_meta.major, info_meta.minor);
+		}
+
+		if (info_data.exists &&
+		    !dm_tree_add_dev_with_udev_flags(dtree, info_data.major, info_data.minor,
+						     _get_udev_flags(dm, lv, NULL, 0, 0, 0))) {
+			log_error("Failed to add device (%" PRIu32 ":%" PRIu32") to dtree.", info_data.major, info_data.minor);
+		}
+	}
+
 	if (!origin_only && !_add_dev_to_dtree(dm, dtree, lv, NULL))
 		return_0;
 
@@ -2444,7 +2602,7 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		    !_add_lv_to_dtree(dm, dtree, seg->metadata_lv, 0))
 			return_0;
 		if (seg->pool_lv &&
-		    (lv_is_cache_pool(seg->pool_lv) || dm->track_external_lv_deps) &&
+		    (lv_is_cache_pool(seg->pool_lv) || lv_is_cache_single(seg->pool_lv) || dm->track_external_lv_deps) &&
 		    /* When activating and not origin_only detect linear 'overlay' over pool */
 		    !_add_lv_to_dtree(dm, dtree, seg->pool_lv, dm->activation ? origin_only : 1))
 			return_0;
@@ -2941,6 +3099,14 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 	int save_pending_delete = dm->track_pending_delete;
 	int merge_in_progress = 0;
 
+	if (!(lvlayer = dm_pool_alloc(dm->mem, sizeof(*lvlayer)))) {
+		log_error("_add_new_lv_to_dtree: pool alloc failed for %s %s.",
+			  display_lvname(lv), layer);
+		return 0;
+	}
+	lvlayer->lv = lv;
+	lvlayer->visible_component = (laopts->component_lv == lv) ? 1 : 0;
+
 	log_debug_activation("Adding new LV %s%s%s to dtree", display_lvname(lv),
 			     layer ? "-" : "", layer ? : "");
 	/* LV with pending delete is never put new into a table */
@@ -2957,6 +3123,99 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		return 1;
 	}
 
+	if (lv_is_cache(lv) && lv_is_cache_single(first_seg(lv)->pool_lv)) {
+		struct logical_volume *pool_lv = first_seg(lv)->pool_lv;
+		struct lv_segment *lvseg = first_seg(lv);
+		struct volume_group *vg = lv->vg;
+		struct dm_tree_node *dnode_meta;
+		struct dm_tree_node *dnode_data;
+		union lvid lvid_meta;
+		union lvid lvid_data;
+		char *name_meta;
+		char *name_data;
+		char *dlid_meta;
+		char *dlid_data;
+		char *dlid_pool;
+		uint64_t meta_len = first_seg(lv)->metadata_len;
+		uint64_t data_len = first_seg(lv)->data_len;
+		uint16_t udev_flags = _get_udev_flags(dm, lv, layer,
+					     laopts->noscan, laopts->temporary,
+					     0);
+
+		log_debug("Add cache pool %s to dtree before cache %s", pool_lv->name, lv->name);
+
+		if (!_add_new_lv_to_dtree(dm, dtree, pool_lv, laopts, NULL)) {
+			log_error("Failed to add cachepool to dtree before cache");
+			return_0;
+		}
+
+		memset(&lvid_meta, 0, sizeof(lvid_meta));
+		memset(&lvid_data, 0, sizeof(lvid_meta));
+		memcpy(&lvid_meta.id[0], &vg->id, sizeof(struct id));
+		memcpy(&lvid_meta.id[1], &lvseg->metadata_id, sizeof(struct id));
+		memcpy(&lvid_data.id[0], &vg->id, sizeof(struct id));
+		memcpy(&lvid_data.id[1], &lvseg->data_id, sizeof(struct id));
+
+		if (!(dlid_meta = dm_build_dm_uuid(dm->mem, UUID_PREFIX, (const char *)&lvid_meta.s, NULL)))
+			return_0;
+		if (!(dlid_data = dm_build_dm_uuid(dm->mem, UUID_PREFIX, (const char *)&lvid_data.s, NULL)))
+			return_0;
+
+		if (!(name_meta = dm_build_dm_name(dm->mem, vg->name, pool_lv->name, "_cmeta")))
+			return_0;
+		if (!(name_data = dm_build_dm_name(dm->mem, vg->name, pool_lv->name, "_cdata")))
+			return_0;
+
+		if (!(dlid_pool = build_dm_uuid(dm->mem, pool_lv, NULL)))
+			return_0;
+
+		/* add meta dnode */
+		if (!(dnode_meta = dm_tree_add_new_dev_with_udev_flags(dtree,
+								  name_meta,
+								  dlid_meta,
+								  -1, -1,
+								  read_only_lv(lv, laopts, layer),
+								  ((lv->vg->status & PRECOMMITTED) | laopts->revert) ? 1 : 0,
+								  lvlayer,
+								  udev_flags)))
+			return_0;
+
+		/* add load_segment to meta dnode: linear, size of meta area */
+		if (!add_linear_area_to_dtree(dnode_meta,
+					      meta_len,
+					      lv->vg->extent_size,
+					      lv->vg->cmd->use_linear_target,
+					      lv->vg->name, lv->name))
+			return_0;
+
+		/* add seg_area to prev load_seg: offset 0 maps to cachepool lv offset 0 */
+		if (!dm_tree_node_add_target_area(dnode_meta, NULL, dlid_pool, 0))
+			return_0;
+
+		/* add data dnode */
+		if (!(dnode_data = dm_tree_add_new_dev_with_udev_flags(dtree,
+								  name_data,
+								  dlid_data,
+								  -1, -1,
+								  read_only_lv(lv, laopts, layer),
+								  ((lv->vg->status & PRECOMMITTED) | laopts->revert) ? 1 : 0,
+								  lvlayer,
+								  udev_flags)))
+			return_0;
+
+		/* add load_segment to data dnode: linear, size of data area */
+		if (!add_linear_area_to_dtree(dnode_data,
+					      data_len,
+					      lv->vg->extent_size,
+					      lv->vg->cmd->use_linear_target,
+					      lv->vg->name, lv->name))
+			return_0;
+
+		/* add seg_area to prev load_seg: offset 0 maps to cachepool lv after meta */
+		if (!dm_tree_node_add_target_area(dnode_data, NULL, dlid_pool, meta_len))
+			return_0;
+	}
+
 	/* FIXME Seek a simpler way to lay out the snapshot-merge tree. */
 
 	if (!layer && lv_is_merging_origin(lv)) {
@@ -3025,12 +3284,6 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 	    dm_tree_node_get_context(dnode))
 		return 1;
 
-	if (!(lvlayer = dm_pool_alloc(dm->mem, sizeof(*lvlayer)))) {
-		log_error("_add_new_lv_to_dtree: pool alloc failed for %s %s.",
-			  display_lvname(lv), layer);
-		return 0;
-	}
-
 	lvlayer->lv = lv;
 	lvlayer->visible_component = (laopts->component_lv == lv) ? 1 : 0;
 
@@ -3121,7 +3374,7 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 	    !_pool_register_callback(dm, dnode, lv))
 		return_0;
 
-	if (lv_is_cache(lv) &&
+	if (lv_is_cache(lv) && !lv_is_cache_single(first_seg(lv)->pool_lv) &&
 	    /* Register callback only for layer activation or non-layered cache LV */
 	    (layer || !lv_layer(lv)) &&
 	    /* Register callback when metadata LV is NOT already active */
diff --git a/lib/activate/dev_manager.h b/lib/activate/dev_manager.h
index bd96832..b669bd2 100644
--- a/lib/activate/dev_manager.h
+++ b/lib/activate/dev_manager.h
@@ -103,4 +103,14 @@ int dev_manager_execute(struct dev_manager *dm);
 int dev_manager_device_uses_vg(struct device *dev,
 			       struct volume_group *vg);
 
+int dev_manager_remove_dm_major_minor(uint32_t major, uint32_t minor);
+
+int get_cache_single_meta_data(struct cmd_context *cmd,
+                                    struct logical_volume *lv,
+                                    struct logical_volume *pool_lv,
+                                    struct dm_info *info_meta, struct dm_info *info_data);
+
+int remove_cache_single_meta_data(struct cmd_context *cmd,
+                                       struct dm_info *info_meta, struct dm_info *info_data);
+
 #endif
diff --git a/lib/cache_segtype/cache.c b/lib/cache_segtype/cache.c
index 17f94d1..8a97b30 100644
--- a/lib/cache_segtype/cache.c
+++ b/lib/cache_segtype/cache.c
@@ -49,7 +49,10 @@ static void _cache_display(const struct lv_segment *seg)
 	const struct dm_config_node *n;
 	const struct lv_segment *setting_seg = NULL;
 
-	if (seg_is_cache_pool(seg))
+	if (seg_is_cache(seg) && lv_is_cache_single(seg->pool_lv))
+		setting_seg = seg;
+
+	else if (seg_is_cache_pool(seg))
 		setting_seg = seg;
 
 	else if (seg_is_cache(seg))
@@ -474,6 +477,7 @@ static int _cache_text_import(struct lv_segment *seg,
 {
 	struct logical_volume *pool_lv, *origin_lv;
 	const char *name;
+	const char *uuid;
 
 	if (!dm_config_has_node(sn, "cache_pool"))
 		return SEG_LOG_ERROR("cache_pool not specified in");
@@ -503,9 +507,44 @@ static int _cache_text_import(struct lv_segment *seg,
 	if (!attach_pool_lv(seg, pool_lv, NULL, NULL, NULL))
 		return_0;
 
-	/* load order is unknown, could be cache origin or pool LV, so check for both */
-	if (!dm_list_empty(&pool_lv->segments))
-		_fix_missing_defaults(first_seg(pool_lv));
+	if (!_settings_text_import(seg, sn))
+		return_0;
+
+	if (dm_config_has_node(sn, "metadata_format")) {
+		if (!dm_config_get_uint32(sn, "metadata_format", &seg->cache_metadata_format))
+			return SEG_LOG_ERROR("Couldn't read cache metadata_format in");
+		if (seg->cache_metadata_format != CACHE_METADATA_FORMAT_2)
+			return SEG_LOG_ERROR("Unknown cache metadata format %u number in",
+					     seg->cache_metadata_format);
+	}
+
+	if (dm_config_has_node(sn, "metadata_start")) {
+		if (!dm_config_get_uint64(sn, "metadata_start", &seg->metadata_start))
+			return SEG_LOG_ERROR("Couldn't read metadata_start in");
+		if (!dm_config_get_uint64(sn, "metadata_len", &seg->metadata_len))
+			return SEG_LOG_ERROR("Couldn't read metadata_len in");
+		if (!dm_config_get_uint64(sn, "data_start", &seg->data_start))
+			return SEG_LOG_ERROR("Couldn't read data_start in");
+		if (!dm_config_get_uint64(sn, "data_len", &seg->data_len))
+			return SEG_LOG_ERROR("Couldn't read data_len in");
+
+		if (!dm_config_get_str(sn, "metadata_id", &uuid))
+			return SEG_LOG_ERROR("Couldn't read metadata_id in");
+
+		if (!id_read_format(&seg->metadata_id, uuid))
+			return SEG_LOG_ERROR("Couldn't format metadata_id in");
+
+		if (!dm_config_get_str(sn, "data_id", &uuid))
+			return SEG_LOG_ERROR("Couldn't read data_id in");
+
+		if (!id_read_format(&seg->data_id, uuid))
+			return SEG_LOG_ERROR("Couldn't format data_id in");
+	} else {
+		/* Do not call this when LV is cache_single. */
+		/* load order is unknown, could be cache origin or pool LV, so check for both */
+		if (!dm_list_empty(&pool_lv->segments))
+			_fix_missing_defaults(first_seg(pool_lv));
+	}
 
 	return 1;
 }
@@ -520,6 +559,8 @@ static int _cache_text_import_area_count(const struct dm_config_node *sn,
 
 static int _cache_text_export(const struct lv_segment *seg, struct formatter *f)
 {
+	char buffer[40];
+
 	if (!seg_lv(seg, 0))
 		return_0;
 
@@ -529,6 +570,26 @@ static int _cache_text_export(const struct lv_segment *seg, struct formatter *f)
 	if (seg->cleaner_policy)
 		outf(f, "cleaner = 1");
 
+	if (lv_is_cache_single(seg->pool_lv)) {
+		outf(f, "metadata_format = " FMTu32, seg->cache_metadata_format);
+
+		if (!_settings_text_export(seg, f))
+			return_0;
+
+		outf(f, "metadata_start = " FMTu64, seg->metadata_start);
+		outf(f, "metadata_len = " FMTu64, seg->metadata_len);
+		outf(f, "data_start = " FMTu64, seg->data_start);
+		outf(f, "data_len = " FMTu64, seg->data_len);
+
+		if (!id_write_format(&seg->metadata_id, buffer, sizeof(buffer)))
+			return_0;
+		outf(f, "metadata_id = \"%s\"", buffer);
+
+		if (!id_write_format(&seg->data_id, buffer, sizeof(buffer)))
+			return_0;
+		outf(f, "data_id = \"%s\"", buffer);
+	}
+
 	return 1;
 }
 
@@ -544,6 +605,8 @@ static int _cache_add_target_line(struct dev_manager *dm,
 {
 	struct lv_segment *cache_pool_seg;
 	struct lv_segment *setting_seg;
+	union lvid metadata_lvid;
+	union lvid data_lvid;
 	char *metadata_uuid, *data_uuid, *origin_uuid;
 	uint64_t feature_flags = 0;
 	unsigned attr;
@@ -557,7 +620,10 @@ static int _cache_add_target_line(struct dev_manager *dm,
 
 	cache_pool_seg = first_seg(seg->pool_lv);
 
-	setting_seg = cache_pool_seg;
+	if (lv_is_cache_single(seg->pool_lv))
+		setting_seg = seg;
+	else
+		setting_seg = cache_pool_seg;
 
 	if (seg->cleaner_policy)
 		/* With cleaner policy always pass writethrough */
@@ -599,14 +665,45 @@ static int _cache_add_target_line(struct dev_manager *dm,
 		return 0;
 	}
 
-	if (!(metadata_uuid = build_dm_uuid(mem, cache_pool_seg->metadata_lv, NULL)))
+	if (!(origin_uuid = build_dm_uuid(mem, seg_lv(seg, 0), NULL)))
 		return_0;
 
-	if (!(data_uuid = build_dm_uuid(mem, seg_lv(cache_pool_seg, 0), NULL)))
-		return_0;
+	if (!lv_is_cache_single(seg->pool_lv)) {
+		/* We don't use start/len when using separate data/meta devices. */
+		if (seg->metadata_len || seg->data_len) {
+			log_error(INTERNAL_ERROR "LV %s using unsupported ranges with cache pool.",
+				 display_lvname(seg->lv));
+			return 0;
+		}
 
-	if (!(origin_uuid = build_dm_uuid(mem, seg_lv(seg, 0), NULL)))
-		return_0;
+		if (!(metadata_uuid = build_dm_uuid(mem, cache_pool_seg->metadata_lv, NULL)))
+			return_0;
+
+		if (!(data_uuid = build_dm_uuid(mem, seg_lv(cache_pool_seg, 0), NULL)))
+			return_0;
+	} else {
+		if (!seg->metadata_len || !seg->data_len || (seg->metadata_start == seg->data_start)) {
+			log_error(INTERNAL_ERROR "LV %s has invalid ranges metadata %llu %llu data %llu %llu.",
+				 display_lvname(seg->lv),
+				 (unsigned long long)seg->metadata_start,
+				 (unsigned long long)seg->metadata_len,
+				 (unsigned long long)seg->data_start,
+				 (unsigned long long)seg->data_len);
+			return 0;
+		}
+
+		memset(&metadata_lvid, 0, sizeof(metadata_lvid));
+		memset(&data_lvid, 0, sizeof(data_lvid));
+		memcpy(&metadata_lvid.id[0], &seg->lv->vg->id, sizeof(struct id));
+		memcpy(&metadata_lvid.id[1], &seg->metadata_id, sizeof(struct id));
+		memcpy(&data_lvid.id[0], &seg->lv->vg->id, sizeof(struct id));
+		memcpy(&data_lvid.id[1], &seg->data_id, sizeof(struct id));
+
+		if (!(metadata_uuid = dm_build_dm_uuid(mem, UUID_PREFIX, (const char *)&metadata_lvid.s, NULL)))
+			return_0;
+		if (!(data_uuid = dm_build_dm_uuid(mem, UUID_PREFIX, (const char *)&data_lvid.s, NULL)))
+			return_0;
+	}
 
 	if (!dm_tree_node_add_cache_target(node, len,
 					   feature_flags,
@@ -616,8 +713,12 @@ static int _cache_add_target_line(struct dev_manager *dm,
 					   seg->cleaner_policy ? "cleaner" :
 						   /* undefined policy name -> likely an old "mq" */
 						   cache_pool_seg->policy_name ? : "mq",
-					   seg->cleaner_policy ? NULL : cache_pool_seg->policy_settings,
-					   cache_pool_seg->chunk_size))
+					   seg->cleaner_policy ? NULL : setting_seg->policy_settings,
+					   seg->metadata_start,
+					   seg->metadata_len,
+					   seg->data_start,
+					   seg->data_len,
+					   setting_seg->chunk_size))
 		return_0;
 
 	return 1;
diff --git a/lib/format_text/flags.c b/lib/format_text/flags.c
index 6f5ff9f..d7c4318 100644
--- a/lib/format_text/flags.c
+++ b/lib/format_text/flags.c
@@ -72,6 +72,7 @@ static const struct flag _lv_flags[] = {
 	{LV_ACTIVATION_SKIP, "ACTIVATION_SKIP", COMPATIBLE_FLAG},
 	{LV_ERROR_WHEN_FULL, "ERROR_WHEN_FULL", COMPATIBLE_FLAG},
 	{LV_METADATA_FORMAT, "METADATA_FORMAT", SEGTYPE_FLAG},
+	{LV_CACHE_SINGLE, "CACHE_SINGLE", STATUS_FLAG},
 	{LV_NOSCAN, NULL, 0},
 	{LV_TEMPORARY, NULL, 0},
 	{POOL_METADATA_SPARE, NULL, 0},
diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index 969a7fe..530378c 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -2779,6 +2779,9 @@ int lockd_lv_uses_lock(struct logical_volume *lv)
 	if (lv_is_pool_metadata_spare(lv))
 		return 0;
 
+	if (lv_is_cache_single(lv))
+		return 0;
+
 	if (lv_is_cache_pool(lv))
 		return 0;
 
diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 8e8e704..6cf945b 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -23,6 +23,7 @@
 #include "lib/config/defaults.h"
 #include "lib/metadata/lv_alloc.h"
 #include "lib/misc/lvm-signal.h"
+#include "lib/activate/dev_manager.h"
 
 /* https://github.com/jthornber/thin-provisioning-tools/blob/master/caching/cache_metadata_size.cc */
 #define DM_TRANSACTION_OVERHEAD		4096  /* KiB */
@@ -44,12 +45,26 @@ const char *cache_mode_num_to_str(cache_mode_t mode)
 	}
 }
 
+const char *get_cache_mode_name(const struct lv_segment *pool_seg)
+{
+	const char *str;
+		
+	if (!(str = cache_mode_num_to_str(pool_seg->cache_mode))) {
+		log_error(INTERNAL_ERROR "Cache pool %s has undefined cache mode, using writethrough instead.",
+			  display_lvname(pool_seg->lv));
+		str = "writethrough";
+	}
+	return str;
+}
+
 const char *display_cache_mode(const struct lv_segment *seg)
 {
 	const struct lv_segment *setting_seg = NULL;
-	const char *str;
 
-	if (seg_is_cache_pool(seg))
+	if (seg_is_cache(seg) && lv_is_cache_single(seg->pool_lv))
+		setting_seg = seg;
+
+	else if (seg_is_cache_pool(seg))
 		setting_seg = seg;
 
 	else if (seg_is_cache(seg))
@@ -58,25 +73,7 @@ const char *display_cache_mode(const struct lv_segment *seg)
 	if (!setting_seg || (setting_seg->cache_mode == CACHE_MODE_UNSELECTED))
 		return "";
 
-	if (!(str = cache_mode_num_to_str(setting_seg->cache_mode))) {
-		log_error(INTERNAL_ERROR "Cache pool %s has undefined cache mode, using writethrough instead.",
-			  display_lvname(seg->lv));
-		str = "writethrough";
-	}
-
-	return str;
-}
-
-const char *get_cache_mode_name(const struct lv_segment *pool_seg)
-{
-	const char *str;
-		
-	if (!(str = cache_mode_num_to_str(pool_seg->cache_mode))) {
-		log_error(INTERNAL_ERROR "Cache pool %s has undefined cache mode, using writethrough instead.",
-			  display_lvname(pool_seg->lv));
-		str = "writethrough";
-	}
-	return str;
+	return cache_mode_num_to_str(setting_seg->cache_mode);
 }
 
 int set_cache_mode(cache_mode_t *mode, const char *cache_mode)
@@ -134,7 +131,10 @@ int cache_set_cache_mode(struct lv_segment *seg, cache_mode_t mode)
 	if (seg_is_cache_pool(seg) && (mode == CACHE_MODE_UNSELECTED))
 		return 1;
 
-	if (seg_is_cache_pool(seg))
+	if (seg_is_cache(seg) && lv_is_cache_single(seg->pool_lv))
+		setting_seg = seg;
+
+	else if (seg_is_cache_pool(seg))
 		setting_seg = seg;
 
 	else if (seg_is_cache(seg))
@@ -334,7 +334,7 @@ int validate_lv_cache_create_pool(const struct logical_volume *pool_lv)
 {
 	struct lv_segment *seg;
 
-	if (!lv_is_cache_pool(pool_lv)) {
+	if (!lv_is_cache_pool(pool_lv) && !lv_is_cache_single(pool_lv)) {
 		log_error("Logical volume %s is not a cache pool.",
 			  display_lvname(pool_lv));
 		return 0;
@@ -555,6 +555,187 @@ int lv_cache_wait_for_clean(struct logical_volume *cache_lv, int *is_clean)
 
 	return 1;
 }
+
+static int _lv_detach_cache_single_while_active(struct cmd_context *cmd, struct logical_volume *cache_lv)
+{
+	struct lv_segment *cache_seg = first_seg(cache_lv);
+	struct logical_volume *corigin_lv;
+	struct logical_volume *cache_pool_lv;
+	struct lvinfo corigin_info;
+	struct dm_info info_meta;
+	struct dm_info info_data;
+	int is_clear;
+
+	cache_pool_lv = cache_seg->pool_lv;
+
+	corigin_lv = seg_lv(cache_seg, 0);
+
+	/*
+	 * This info is needed to remove the corigin lv at the end.
+	 */
+	if (!lv_info(cmd, corigin_lv, 1, &corigin_info, 0, 0))
+		log_error("Failed to get info about corigin %s", display_lvname(corigin_lv));
+
+	/*
+	 * This info is needed to remove the cmeta/cdata devs at the end.
+	 */
+	if (!get_cache_single_meta_data(cmd, cache_lv, cache_pool_lv, &info_meta, &info_data)) {
+		log_error("Failed to get info about cdata/cmeta for %s", display_lvname(cache_pool_lv));
+		return 0;
+	}
+
+	/*
+	 * Flush the cache.
+	 */
+	if (!lv_cache_wait_for_clean(cache_lv, &is_clear)) {
+		log_error("Failed to flush cache for detaching LV %s.", display_lvname(cache_lv));
+		return_0;
+	}
+
+	/*
+	 * The main job of detaching the cache.
+	 */
+
+	if (!detach_pool_lv(cache_seg)) {
+		log_error("Failed to detach cache from %s", display_lvname(cache_lv));
+		return_0;
+	}
+
+	cache_pool_lv->status &= ~LV_CACHE_SINGLE;
+
+	if (!remove_layer_from_lv(cache_lv, corigin_lv)) {
+		log_error("Failed to remove cache layer from %s", display_lvname(cache_lv));
+		return_0;
+	}
+
+	if (!lv_update_and_reload(cache_lv)) {
+		log_error("Failed to update and reload after detaching cache from %s", display_lvname(cache_lv));
+		return 0;
+	}
+
+	/*
+	 * Detaching the cache is done, now finish cleaning up what's left over
+	 * from when the cache was attached: deactivate the cache_pool_lv, and
+	 * remove the unused dm dev for corigin_lv.
+	 */
+
+	/* These cmeta/cdata dm devs need to be removed since they are using cache_pool_lv. */
+	if (!remove_cache_single_meta_data(cmd, &info_meta, &info_data))
+		log_error("Failed to remove cdata/cmeta devs for %s", display_lvname(cache_pool_lv));
+
+	if (!deactivate_lv(cmd, cache_pool_lv))
+		log_error("Failed to deactivate the detached cache %s", display_lvname(cache_pool_lv));
+
+	if (!corigin_info.major || !corigin_info.minor) {
+		log_error("Invalid device number %u:%u for corigin %s",
+			  corigin_info.major, corigin_info.minor, display_lvname(corigin_lv));
+		return 1;
+	}
+
+	dm_udev_set_sync_support(0);
+
+	if (!dev_manager_remove_dm_major_minor(corigin_info.major, corigin_info.minor))
+		log_error("Failed to remove the unused corigin dev %s", display_lvname(corigin_lv));
+
+	dm_udev_set_sync_support(1);
+
+	if (!lv_remove(corigin_lv)) {
+		log_error("Failed to remove unused cache layer %s for %s",
+			  display_lvname(corigin_lv),
+			  display_lvname(cache_lv));
+		return_0;
+	}
+
+	return 1;
+}
+
+static int _lv_detach_cache_single_while_inactive(struct cmd_context *cmd, struct logical_volume *cache_lv)
+{
+	struct lv_segment *cache_seg = first_seg(cache_lv);
+	struct logical_volume *corigin_lv;
+	struct logical_volume *cache_pool_lv;
+	int cache_mode;
+	int is_clear;
+
+	cache_pool_lv = cache_seg->pool_lv;
+
+	corigin_lv = seg_lv(cache_seg, 0);
+
+	cache_mode = cache_seg->cache_mode;
+
+	/*
+	 * With these modes there is no flush needed so we can immediately
+	 * detach without temporarily activating the LV to flush it.
+	 */
+	if ((cache_mode == CACHE_MODE_WRITETHROUGH) || (cache_mode == CACHE_MODE_PASSTHROUGH))
+		goto detach;
+
+	/*
+	 * With mode WRITEBACK we need to activate the cache LV to flush/clean
+	 * it before detaching the cache.
+	 *
+	 * LV_TEMPORARY should prevent the active LV from being exposed and
+	 * used outside of lvm.
+	 */
+
+	log_debug("Activating %s internally for cache flush.", display_lvname(cache_lv));
+
+	cache_lv->status |= LV_TEMPORARY;
+
+	if (!activate_lv(cmd, cache_lv)) {
+		log_error("Failed to activate LV %s to flush cache.", display_lvname(cache_lv));
+		return 0;
+	}
+
+	if (!lv_cache_wait_for_clean(cache_lv, &is_clear)) {
+		log_error("Failed to flush cache for detaching LV %s.", display_lvname(cache_lv));
+		return_0;
+	}
+
+	if (!deactivate_lv(cmd, cache_lv)) {
+		log_error("Failed to deactivate LV %s for detaching cache.", display_lvname(cache_lv));
+		return 0;
+	}
+	cache_lv->status &= ~LV_TEMPORARY;
+
+ detach:
+	if (!detach_pool_lv(cache_seg)) {
+		log_error("Failed to detach cache from %s", display_lvname(cache_lv));
+		return_0;
+	}
+
+	cache_pool_lv->status &= ~LV_CACHE_SINGLE;
+
+	if (!remove_layer_from_lv(cache_lv, corigin_lv)) {
+		log_error("Failed to remove cache layer from %s", display_lvname(cache_lv));
+		return_0;
+	}
+
+	if (!lv_remove(corigin_lv)) {
+		log_error("Failed to remove unused cache layer %s for %s",
+			  display_lvname(corigin_lv),
+			  display_lvname(cache_lv));
+		return_0;
+	}
+
+	return 1;
+}
+
+int lv_detach_cache_single(struct logical_volume *cache_lv)
+{
+	struct cmd_context *cmd = cache_lv->vg->cmd;
+
+	if (lv_is_pending_delete(cache_lv)) {
+		log_error("Already detaching cache pool from %s.", display_lvname(cache_lv));
+		return 0;
+	}
+
+	if (lv_is_active(cache_lv))
+		return _lv_detach_cache_single_while_active(cmd, cache_lv);
+	else
+		return _lv_detach_cache_single_while_inactive(cmd, cache_lv);
+}
+
 /*
  * lv_cache_remove
  * @cache_lv
@@ -579,6 +760,11 @@ int lv_cache_remove(struct logical_volume *cache_lv)
 		return 0;
 	}
 
+	if (lv_is_cache_single(cache_seg->pool_lv)) {
+		log_error(INTERNAL_ERROR "Incorrect remove for cache single");
+		return 0;
+	}
+
 	if (lv_is_pending_delete(cache_lv)) {
 		log_debug(INTERNAL_ERROR "LV %s is already dropped cache volume.",
 			  display_lvname(cache_lv));
@@ -763,7 +949,10 @@ int cache_set_policy(struct lv_segment *lvseg, const char *name,
 			return 1; /* Policy and settings can be selected later when caching LV */
 	}
 
-	if (seg_is_cache_pool(lvseg))
+	if (seg_is_cache(lvseg) && lv_is_cache_single(lvseg->pool_lv))
+		seg = lvseg;
+
+	else if (seg_is_cache_pool(lvseg))
 		seg = lvseg;
 
 	else if (seg_is_cache(lvseg))
@@ -933,10 +1122,241 @@ int cache_set_metadata_format(struct lv_segment *seg, cache_metadata_format_t fo
 	return 1;
 }
 
-/*
- * Universal 'wrapper' function  do-it-all
- * to update all commonly specified cache parameters
- */
+#define ONE_MB_S 2048 /* 1MB in sectors */
+#define ONE_GB_S 2097152 /* 1GB in sectors */
+
+int cache_single_set_params(struct cmd_context *cmd,
+		     struct logical_volume *cache_lv,
+		     struct logical_volume *pool_lv,
+		     uint64_t poolmetadatasize,
+		     uint32_t chunk_size,
+		     cache_metadata_format_t format,
+		     cache_mode_t mode,
+		     const char *policy,
+		     const struct dm_config_tree *settings)
+{
+	struct dm_pool *mem = cache_lv->vg->vgmem;
+	struct profile *profile = cache_lv->profile;
+	struct lv_segment *cache_seg = first_seg(cache_lv);
+	struct logical_volume *corig_lv = seg_lv(cache_seg, 0);
+	const char *policy_name = NULL;
+	struct dm_config_node *policy_settings = NULL;
+	const struct dm_config_node *cns;
+	struct dm_config_node *cn;
+	uint64_t meta_size = 0;
+	uint64_t data_size = 0;
+	uint64_t max_chunks;
+	uint32_t min_meta_size;
+	uint32_t max_meta_size;
+	uint32_t extent_size;
+
+	/* all _size variables in units of sectors (512 bytes) */
+
+
+	/*
+	 * cache format: only create new cache LVs with 2.
+	 */
+
+	if (format == CACHE_METADATA_FORMAT_UNSELECTED)
+		format = CACHE_METADATA_FORMAT_2;
+	if (format == CACHE_METADATA_FORMAT_1) {
+		log_error("Use cache metadata format 2.");
+		return 0;
+	}
+
+
+	/*
+	 * cache mode: get_cache_params() gets mode from --cachemode or sets
+	 * UNSEL.  When unspecified, it comes from config.
+	 */
+
+	if (mode == CACHE_MODE_UNSELECTED)
+		mode = _get_cache_mode_from_config(cmd, profile, cache_lv);
+
+	cache_seg->cache_mode = mode;
+
+
+	/*
+	 * chunk size: get_cache_params() get chunk_size from --chunksize or
+	 * sets 0.  When unspecified it comes from config or default.
+	 *
+	 * cache_pool_chunk_size in lvm.conf, DEFAULT_CACHE_POOL_CHUNK_SIZE,
+	 * and DEFAULT_CACHE_POOL_MAX_METADATA_SIZE are in KiB, so *2 turn
+	 * them into sectors.
+	 */
+
+	if (!chunk_size)
+		chunk_size = find_config_tree_int(cmd, allocation_cache_pool_chunk_size_CFG, cache_lv->profile) * 2;
+
+	if (!chunk_size)
+		chunk_size = get_default_allocation_cache_pool_chunk_size_CFG(cmd, profile);
+
+	if (!validate_cache_chunk_size(cmd, chunk_size))
+		return_0;
+
+
+	/*
+	 * metadata size: can be specified with --poolmetadatasize,
+	 * otherwise it's set according to the size of the cache.
+	 * data size: the LV size minus the metadata size.
+	 */
+
+	extent_size = pool_lv->vg->extent_size;
+	min_meta_size = extent_size;
+	max_meta_size = 2 * DEFAULT_CACHE_POOL_MAX_METADATA_SIZE; /* 2x for KiB to sectors */
+
+	if (pool_lv->size < (extent_size * 2)) {
+		log_error("The minimum cache size is two extents (%s bytes).",
+			  display_size(cmd, extent_size * 2));
+		return 0;
+	}
+
+	if (poolmetadatasize) {
+		meta_size = poolmetadatasize; /* in sectors, from --poolmetadatasize, see _size_arg() */
+
+		if (meta_size > max_meta_size) {
+			meta_size = max_meta_size;
+			log_print_unless_silent("Rounding down metadata size to max size %s",
+						display_size(cmd, meta_size));
+		}
+		if (meta_size < min_meta_size) {
+			meta_size = min_meta_size;
+			log_print_unless_silent("Rounding up metadata size to min size %s",
+						display_size(cmd, meta_size));
+		}
+
+		if (meta_size % extent_size) {
+			meta_size += extent_size - meta_size % extent_size;
+			log_print_unless_silent("Rounding up metadata size to full physical extent %s",
+						display_size(cmd, meta_size));
+		}
+	}
+
+	if (!meta_size) {
+		if (pool_lv->size < (128 * ONE_MB_S))
+			meta_size = 16 * ONE_MB_S;
+
+		else if (pool_lv->size < ONE_GB_S)
+			meta_size = 32 * ONE_MB_S;
+
+		else if (pool_lv->size < (128 * ONE_GB_S))
+			meta_size = 64 * ONE_MB_S;
+
+		if (meta_size > (pool_lv->size / 2))
+			meta_size = pool_lv->size / 2;
+
+		if (meta_size < min_meta_size)
+			meta_size = min_meta_size;
+
+		if (meta_size % extent_size)
+			meta_size += extent_size - meta_size % extent_size;
+	}
+
+	data_size = pool_lv->size - meta_size;
+
+	max_chunks = get_default_allocation_cache_pool_max_chunks_CFG(cmd, profile);
+
+	if (data_size / chunk_size > max_chunks) {
+		log_error("Cache data blocks %llu and chunk size %u exceed max chunks %llu.",
+			  (unsigned long long)data_size, chunk_size, (unsigned long long)max_chunks);
+		log_error("Use smaller cache, larger --chunksize or increase max chunks setting.");
+		return 0;
+	}
+
+
+	/*
+	 * cache policy: get_cache_params() gets policy from --cachepolicy,
+	 * or sets NULL.
+	 */
+
+	if (!policy)
+		policy = find_config_tree_str(cmd, allocation_cache_policy_CFG, profile);
+
+	if (!policy)
+		policy = _get_default_cache_policy(cmd);
+
+	if (!policy) {
+		log_error(INTERNAL_ERROR "Missing cache policy name.");
+		return 0;
+	}
+
+	if (!(policy_name = dm_pool_strdup(mem, policy)))
+		return_0;
+
+
+	/*
+	 * cache settings: get_cache_params() gets policy from --cachesettings,
+	 * or sets NULL.
+	 * FIXME: code for this is a mess, mostly copied from cache_set_policy
+	 * which is even worse.
+	 */
+
+	if (settings) {
+		if ((cn = dm_config_find_node(settings->root, "policy_settings"))) {
+			if (!(policy_settings = dm_config_clone_node_with_mem(mem, cn, 0)))
+				return_0;
+		}
+	} else {
+		if ((cns = find_config_tree_node(cmd, allocation_cache_settings_CFG_SECTION, profile))) {
+			/* Try to find our section for given policy */
+			for (cn = cns->child; cn; cn = cn->sib) {
+				if (!cn->child)
+					continue; /* Ignore section without settings */
+
+				if (cn->v || strcmp(cn->key, policy_name) != 0)
+					continue; /* Ignore mismatching sections */
+
+				/* Clone nodes with policy name */
+				if (!(policy_settings = dm_config_clone_node_with_mem(mem, cn, 0)))
+					return_0;
+
+				/* Replace policy name key with 'policy_settings' */
+				policy_settings->key = "policy_settings";
+				break; /* Only first match counts */
+			}
+		}
+	}
+  restart: /* remove any 'default" nodes */
+	cn = policy_settings ? policy_settings->child : NULL;
+	while (cn) {
+		if (cn->v->type == DM_CFG_STRING && !strcmp(cn->v->v.str, "default")) {
+			dm_config_remove_node(policy_settings, cn);
+			goto restart;
+		}
+		cn = cn->sib;
+	}
+
+
+	log_debug("Setting LV %s cache on %s meta start 0 len %llu data start %llu len %llu sectors",
+		  display_lvname(cache_lv), display_lvname(pool_lv),
+		  (unsigned long long)meta_size,
+		  (unsigned long long)meta_size,
+		  (unsigned long long)data_size);
+	log_debug("Setting LV %s cache format %u policy %s chunk_size %u sectors",
+		  display_lvname(cache_lv), format, policy_name, chunk_size);
+
+	if (lv_is_raid(corig_lv) && (mode == CACHE_MODE_WRITEBACK))
+		log_warn("WARNING: Data redundancy could be lost with writeback caching of raid logical volume!");
+
+	if (lv_is_thin_pool_data(cache_lv)) {
+		log_warn("WARNING: thin pool data will not be automatically extended when cached.");
+		log_warn("WARNING: manual splitcache is required before extending thin pool data.");
+	}
+
+	cache_seg->chunk_size = chunk_size;
+	cache_seg->metadata_start = 0;
+	cache_seg->metadata_len = meta_size;
+	cache_seg->data_start = meta_size;
+	cache_seg->data_len = data_size;
+	cache_seg->cache_metadata_format = format;
+	cache_seg->policy_name = policy_name;
+	cache_seg->policy_settings = policy_settings;
+	id_create(&cache_seg->metadata_id);
+	id_create(&cache_seg->data_id);
+
+	return 1;
+}
+
 int cache_set_params(struct lv_segment *seg,
 		     uint32_t chunk_size,
 		     cache_metadata_format_t format,
@@ -1002,7 +1422,7 @@ int wipe_cache_pool(struct logical_volume *cache_pool_lv)
 	int r;
 
 	/* Only unused cache-pool could be activated and wiped */
-	if (!lv_is_cache_pool(cache_pool_lv) ||
+	if ((!lv_is_cache_pool(cache_pool_lv) && !lv_is_cache_single(cache_pool_lv)) ||
 	    !dm_list_empty(&cache_pool_lv->segs_using_this_lv)) {
 		log_error(INTERNAL_ERROR "Failed to wipe cache pool for volume %s.",
 			  display_lvname(cache_pool_lv));
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 9c8b028..cb064d8 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -333,6 +333,8 @@ uint64_t lvseg_chunksize(const struct lv_segment *seg)
 
 	if (lv_is_cow(seg->lv))
 		size = (uint64_t) find_snapshot(seg->lv)->chunk_size;
+	else if (seg_is_cache(seg) && lv_is_cache_single(seg->pool_lv))
+		size = (uint64_t) seg->chunk_size;
 	else if (seg_is_pool(seg))
 		size = (uint64_t) seg->chunk_size;
 	else if (seg_is_cache(seg))
@@ -932,10 +934,18 @@ uint64_t lv_origin_size(const struct logical_volume *lv)
 
 uint64_t lv_metadata_size(const struct logical_volume *lv)
 {
-	struct lv_segment *seg = (lv_is_thin_pool(lv) || lv_is_cache_pool(lv)) ?
-		first_seg(lv) : NULL;
+	struct lv_segment *seg;
+
+	if (!(seg = first_seg(lv)))
+		return 0;
+
+	if (seg_is_cache(seg) && lv_is_cache_single(seg->pool_lv))
+		return seg->metadata_len;
 
-	return seg ? seg->metadata_lv->size : 0;
+	if (lv_is_thin_pool(lv) || lv_is_cache_pool(lv))
+		return seg->metadata_lv->size;
+
+	return 0;
 }
 
 char *lv_path_dup(struct dm_pool *mem, const struct logical_volume *lv)
@@ -1297,7 +1307,7 @@ char *lv_attr_dup_with_info_and_seg_status(struct dm_pool *mem, const struct lv_
 
 	if (lv_is_thin_pool(lv) || lv_is_thin_volume(lv))
 		repstr[6] = 't';
-	else if (lv_is_cache_pool(lv) || lv_is_cache(lv) || lv_is_cache_origin(lv))
+	else if (lv_is_cache_pool(lv) || lv_is_cache_single(lv) || lv_is_cache(lv) || lv_is_cache_origin(lv))
 		repstr[6] = 'C';
 	else if (lv_is_raid_type(lv))
 		repstr[6] = 'r';
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 43e09a4..8e64dac 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -422,7 +422,7 @@ static int _lv_layout_and_role_cache(struct dm_pool *mem,
 	if (lv_is_cache(lv) &&
 	    !str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_CACHE]))
 		goto_bad;
-	else if (lv_is_cache_pool(lv)) {
+	else if (lv_is_cache_pool(lv) || lv_is_cache_single(lv)) {
 		if (!str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_CACHE]) ||
 		    !str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_POOL]))
 			goto_bad;
@@ -4449,6 +4449,7 @@ static int _rename_skip_pools_externals_cb(struct logical_volume *lv, void *data
 {
 	if (lv_is_pool(lv) ||
 	    lv_is_vdo_pool(lv) ||
+	    lv_is_cache_single(lv) ||
 	    lv_is_external_origin(lv))
 		return -1; /* and skip subLVs */
 
@@ -6147,6 +6148,13 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 	if (!lockd_lv(cmd, lock_lv, "ex", LDLV_PERSISTENT))
 		return_0;
 
+	if (lv_is_cache(lv) && lv_is_cache_single(first_seg(lv)->pool_lv)) {
+		if (!lv_detach_cache_single(lv)) {
+			log_error("Failed to detach cache from %s", display_lvname(lv));
+			return 0;
+		}
+	}
+
 	/* FIXME Ensure not referred to by another existing LVs */
 	ask_discard = find_config_tree_bool(cmd, devices_issue_discards_CFG, NULL);
 
diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index 035a56c..d95da1f 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -321,6 +321,8 @@ static void _check_lv_segment(struct logical_volume *lv, struct lv_segment *seg,
 			      unsigned seg_count, int *error_count)
 {
 	struct lv_segment *seg2;
+	struct lv_segment *cache_setting_seg = NULL;
+	int no_metadata_format = 0;
 
 	if (lv_is_mirror_image(lv) &&
 	    (!(seg2 = find_mirror_seg(seg)) || !seg_is_mirrored(seg2)))
@@ -332,23 +334,31 @@ static void _check_lv_segment(struct logical_volume *lv, struct lv_segment *seg,
 
 		if (!seg->pool_lv) {
 			seg_error("is missing cache pool LV");
-		} else if (!lv_is_cache_pool(seg->pool_lv))
+		} else if (!lv_is_cache_pool(seg->pool_lv) && !lv_is_cache_single(seg->pool_lv))
 			seg_error("is not referencing cache pool LV");
 	} else { /* !cache */
 		if (seg->cleaner_policy)
 			seg_error("sets cleaner_policy");
 	}
 
-	if (seg_is_cache_pool(seg)) {
-		if (!dm_list_empty(&seg->lv->segs_using_this_lv)) {
-			switch (seg->cache_metadata_format) {
+	if (lv_is_cache(lv) && seg->pool_lv && lv_is_cache_single(seg->pool_lv)) {
+		cache_setting_seg = seg;
+		no_metadata_format = 1;
+	}
+
+	else if (lv_is_cache_pool(lv))
+		cache_setting_seg = seg;
+
+	if (cache_setting_seg) {
+		if (!dm_list_empty(&cache_setting_seg->lv->segs_using_this_lv)) {
+			switch (cache_setting_seg->cache_metadata_format) {
 			case CACHE_METADATA_FORMAT_2:
 			case CACHE_METADATA_FORMAT_1:
 				break;
 			default:
 				seg_error("has invalid cache metadata format");
 			}
-			switch (seg->cache_mode) {
+			switch (cache_setting_seg->cache_mode) {
 			case CACHE_MODE_WRITETHROUGH:
 			case CACHE_MODE_WRITEBACK:
 			case CACHE_MODE_PASSTHROUGH:
@@ -356,17 +366,24 @@ static void _check_lv_segment(struct logical_volume *lv, struct lv_segment *seg,
 			default:
 				seg_error("has invalid cache's feature flag");
 			}
-			if (!seg->policy_name)
+			if (!cache_setting_seg->policy_name)
 				seg_error("is missing cache policy name");
 		}
-		if (!validate_cache_chunk_size(lv->vg->cmd, seg->chunk_size))
+
+		if (!validate_cache_chunk_size(lv->vg->cmd, cache_setting_seg->chunk_size))
 			seg_error("has invalid chunk size.");
-		if (seg->lv->status & LV_METADATA_FORMAT) {
-			if (seg->cache_metadata_format != CACHE_METADATA_FORMAT_2)
+
+		if (cache_setting_seg->lv->status & LV_METADATA_FORMAT) {
+			if (cache_setting_seg->cache_metadata_format != CACHE_METADATA_FORMAT_2)
 				seg_error("sets METADATA_FORMAT flag");
-		} else if (seg->cache_metadata_format == CACHE_METADATA_FORMAT_2)
+		}
+
+		if (!no_metadata_format &&
+		    (cache_setting_seg->cache_metadata_format == CACHE_METADATA_FORMAT_2) &&
+		    !(cache_setting_seg->lv->status & LV_METADATA_FORMAT))
 			seg_error("is missing METADATA_FORMAT flag");
-	} else { /* !cache_pool */
+
+	} else {
 		if (seg->cache_metadata_format)
 			seg_error("sets cache metadata format");
 		if (seg->cache_mode)
@@ -519,7 +536,8 @@ static void _check_lv_segment(struct logical_volume *lv, struct lv_segment *seg,
 	if (!seg_is_pool(seg) &&
 	    /* FIXME: format_pool/import_export.c  _add_linear_seg() sets chunk_size */
 	    !seg_is_linear(seg) &&
-	    !seg_is_snapshot(seg)) {
+	    !seg_is_snapshot(seg) &&
+	    !seg_is_cache(seg)) {
 		if (seg->chunk_size)
 			seg_error("sets chunk_size");
 	}
@@ -757,6 +775,7 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 		if ((seg_count != 1) &&
 		    (lv_is_cache(lv) ||
 		     lv_is_cache_pool(lv) ||
+		     lv_is_cache_single(lv) ||
 		     lv_is_raid(lv) ||
 		     lv_is_snapshot(lv) ||
 		     lv_is_thin_pool(lv) ||
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 76c164b..30ab356 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -151,6 +151,8 @@
 #define LV_VDO_POOL		UINT64_C(0x0000000040000000)    /* LV - Internal user only */
 #define LV_VDO_POOL_DATA	UINT64_C(0x8000000000000000)    /* LV - Internal user only */
 
+#define LV_CACHE_SINGLE		UINT64_C(0x0010000000000000)	/* LV - also a PV flag */
+
 
 /* Format features flags */
 #define FMT_SEGMENTS		0x00000001U	/* Arbitrary segment params? */
@@ -245,10 +247,11 @@
 
 #define lv_is_cache(lv)		(((lv)->status & CACHE) ? 1 : 0)
 #define lv_is_cache_pool(lv)	(((lv)->status & CACHE_POOL) ? 1 : 0)
+#define lv_is_cache_single(lv)	(((lv)->status & LV_CACHE_SINGLE) ? 1 : 0)
 #define lv_is_used_cache_pool(lv)	(lv_is_cache_pool(lv) && !dm_list_empty(&(lv)->segs_using_this_lv))
 #define lv_is_cache_pool_data(lv)	(((lv)->status & CACHE_POOL_DATA) ? 1 : 0)
 #define lv_is_cache_pool_metadata(lv)	(((lv)->status & CACHE_POOL_METADATA) ? 1 : 0)
-#define lv_is_cache_type(lv)	(((lv)->status & (CACHE | CACHE_POOL | CACHE_POOL_DATA | CACHE_POOL_METADATA)) ? 1 : 0)
+#define lv_is_cache_type(lv)	(((lv)->status & (CACHE | CACHE_POOL | LV_CACHE_SINGLE | CACHE_POOL_DATA | CACHE_POOL_METADATA)) ? 1 : 0)
 
 #define lv_is_pool(lv)		(((lv)->status & (CACHE_POOL | THIN_POOL)) ? 1 : 0)
 #define lv_is_pool_data(lv)		(((lv)->status & (CACHE_POOL_DATA | THIN_POOL_DATA)) ? 1 : 0)
@@ -493,6 +496,13 @@ struct lv_segment {
 	struct logical_volume *pool_lv;		/* For thin, cache */
 	uint32_t device_id;			/* For thin, 24bit */
 
+	uint64_t metadata_start;		/* For cache */
+	uint64_t metadata_len;			/* For cache */
+	uint64_t data_start;			/* For cache */
+	uint64_t data_len;			/* For cache */
+	struct id metadata_id;			/* For cache */
+	struct id data_id;			/* For cache */
+
 	cache_metadata_format_t cache_metadata_format;/* For cache_pool */
 	cache_mode_t cache_mode;		/* For cache_pool */
 	const char *policy_name;		/* For cache_pool */
@@ -1218,7 +1228,7 @@ struct lv_status_cache {
 
 const char *cache_mode_num_to_str(cache_mode_t mode);
 const char *display_cache_mode(const struct lv_segment *seg);
-const char *get_cache_mode_name(const struct lv_segment *pool_seg);
+const char *get_cache_mode_name(const struct lv_segment *seg);
 int set_cache_mode(cache_mode_t *mode, const char *cache_mode);
 int cache_set_cache_mode(struct lv_segment *seg, cache_mode_t mode);
 int cache_set_metadata_format(struct lv_segment *seg, cache_metadata_format_t format);
@@ -1230,6 +1240,15 @@ int cache_set_params(struct lv_segment *seg,
 		     cache_mode_t mode,
 		     const char *policy_name,
 		     const struct dm_config_tree *policy_settings);
+int cache_single_set_params(struct cmd_context *cmd,
+		     struct logical_volume *cache_lv,
+		     struct logical_volume *pool_lv,
+		     uint64_t poolmetadatasize,
+                     uint32_t chunk_size,
+                     cache_metadata_format_t format,
+                     cache_mode_t mode,
+                     const char *policy,
+                     const struct dm_config_tree *settings);
 void cache_check_for_warns(const struct lv_segment *seg);
 int update_cache_pool_params(struct cmd_context *cmd,
 			     struct profile *profile,
@@ -1246,6 +1265,7 @@ struct logical_volume *lv_cache_create(struct logical_volume *pool_lv,
 				       struct logical_volume *origin_lv);
 int lv_cache_wait_for_clean(struct logical_volume *cache_lv, int *is_clean);
 int lv_cache_remove(struct logical_volume *cache_lv);
+int lv_detach_cache_single(struct logical_volume *cache_lv);
 int wipe_cache_pool(struct logical_volume *cache_pool_lv);
 /* --  metadata/cache_manip.c */
 
diff --git a/lib/report/report.c b/lib/report/report.c
index 52baa6c..ecec0a3 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1430,7 +1430,10 @@ static int _cache_settings_disp(struct dm_report *rh, struct dm_pool *mem,
 	struct _str_list_append_baton baton;
 	struct dm_list dummy_list; /* dummy list to display "nothing" */
 
-	if (seg_is_cache_pool(seg))
+	if (seg_is_cache(seg) && lv_is_cache_single(seg->pool_lv))
+		setting_seg = seg;
+
+	else if (seg_is_cache_pool(seg))
 		setting_seg = seg;
 
 	else if (seg_is_cache(seg))
@@ -1565,7 +1568,10 @@ static int _cache_policy_disp(struct dm_report *rh, struct dm_pool *mem,
 	const struct lv_segment *seg = (const struct lv_segment *) data;
 	const struct lv_segment *setting_seg = NULL;
 
-	if (seg_is_cache_pool(seg))
+	if (seg_is_cache(seg) && lv_is_cache_single(seg->pool_lv))
+		setting_seg = seg;
+
+	else if (seg_is_cache_pool(seg))
 		setting_seg = seg;
 
 	else if (seg_is_cache(seg))
@@ -2747,7 +2753,10 @@ static int _cachemetadataformat_disp(struct dm_report *rh, struct dm_pool *mem,
 	const struct lv_segment *setting_seg = NULL;
 	const uint64_t *fmt;
 
-	if (seg_is_cache_pool(seg))
+	if (seg_is_cache(seg) && lv_is_cache_single(seg->pool_lv))
+		setting_seg = seg;
+
+	else if (seg_is_cache_pool(seg))
 		setting_seg = seg;
 
 	else if (seg_is_cache(seg))
@@ -3222,6 +3231,11 @@ static int _lvmetadatasize_disp(struct dm_report *rh, struct dm_pool *mem,
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 	uint64_t size;
 
+	if (lv_is_cache(lv) && lv_is_cache_single(first_seg(lv)->pool_lv)) {
+		size = lv_metadata_size(lv);
+		return _size64_disp(rh, mem, field, &size, private);
+	}
+
 	if (lv_is_thin_pool(lv) || lv_is_cache_pool(lv)) {
 		size = lv_metadata_size(lv);
 		return _size64_disp(rh, mem, field, &size, private);
diff --git a/test/shell/cache-single-options.sh b/test/shell/cache-single-options.sh
new file mode 100644
index 0000000..f8dde12
--- /dev/null
+++ b/test/shell/cache-single-options.sh
@@ -0,0 +1,269 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2017 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+# Test single lv cache options
+
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+mount_dir="mnt"
+mkdir -p $mount_dir
+
+# generate random data
+dmesg > pattern1
+ps aux >> pattern1
+
+aux prepare_devs 5 64
+
+vgcreate $SHARED $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
+
+lvcreate -n $lv1 -l 8 -an $vg "$dev1"
+lvcreate -n $lv2 -l 4 -an $vg "$dev2"
+lvcreate -n $lv3 -l 4 -an $vg "$dev3"
+lvcreate -n $lv4 -l 4 -an $vg "$dev4"
+lvcreate -n $lv5 -l 8 -an $vg "$dev5"
+
+mkfs_mount_umount()
+{
+	lvt=$1
+
+	lvchange -ay $vg/$lvt
+
+	mkfs.xfs -f -s size=4096 "$DM_DEV_DIR/$vg/$lvt"
+	mount "$DM_DEV_DIR/$vg/$lvt" $mount_dir
+	cp pattern1 $mount_dir/pattern1
+	dd if=/dev/zero of=$mount_dir/zeros2M bs=1M count=2 oflag=sync
+	umount $mount_dir
+
+	lvchange -an $vg/$lvt
+}
+
+mount_umount()
+{
+	lvt=$1
+
+	lvchange -ay $vg/$lvt
+
+	mount "$DM_DEV_DIR/$vg/$lvt" $mount_dir
+	diff pattern1 $mount_dir/pattern1
+	dd if=$mount_dir/zeros2M of=/dev/null bs=1M count=2
+	umount $mount_dir
+
+	lvchange -an $vg/$lvt
+}
+
+#
+# Test --cachemetadataformat
+#
+
+# 1 shouldn't be used any longer
+not lvconvert --cachemetadataformat 1 -y --type cache --cachepool $lv2 $vg/$lv1
+
+# 3 doesn't exist
+not lvconvert --cachemetadataformat 3 -y --type cache --cachepool $lv2 $vg/$lv1
+
+# 2 is used by default
+lvconvert -y --type cache --cachepool $lv2 $vg/$lv1
+
+check lv_field $vg/$lv1 cachemetadataformat "2"
+
+lvconvert --splitcache $vg/$lv1
+check lv_field $vg/$lv1 segtype linear
+check lv_field $vg/$lv2 segtype linear
+
+# 2 can be set explicitly
+lvconvert --cachemetadataformat 2 -y --type cache --cachepool $lv2 $vg/$lv1
+
+check lv_field $vg/$lv1 cachemetadataformat "2"
+
+lvconvert --splitcache $vg/$lv1
+
+# "auto" means 2
+lvconvert --cachemetadataformat auto -y --type cache --cachepool $lv2 $vg/$lv1
+
+check lv_field $vg/$lv1 cachemetadataformat "2"
+
+mkfs_mount_umount $lv1
+
+lvconvert --splitcache $vg/$lv1
+check lv_field $vg/$lv1 segtype linear
+check lv_field $vg/$lv2 segtype linear
+mount_umount $lv1
+
+
+#
+# Test --poolmetadatasize
+#
+
+lvconvert -y --type cache --cachepool $lv2 --poolmetadatasize 4m $vg/$lv1
+
+check lv_field $vg/$lv1 lv_metadata_size "4.00m"
+
+mkfs_mount_umount $lv1
+
+lvconvert --splitcache $vg/$lv1
+check lv_field $vg/$lv1 segtype linear
+check lv_field $vg/$lv2 segtype linear
+mount_umount $lv1
+
+
+#
+# Test --chunksize
+#
+
+lvconvert -y --type cache --cachepool $lv2 --chunksize 32k $vg/$lv1
+
+check lv_field $vg/$lv1 chunksize "32.00k"
+
+mkfs_mount_umount $lv1
+
+lvconvert --splitcache $vg/$lv1
+check lv_field $vg/$lv1 segtype linear
+check lv_field $vg/$lv2 segtype linear
+mount_umount $lv1
+
+
+#
+# Test --cachemode
+#
+
+lvconvert -y --type cache --cachepool $lv2 --cachemode writethrough $vg/$lv1
+
+check lv_field $vg/$lv1 cachemode "writethrough"
+
+mkfs_mount_umount $lv1
+
+lvconvert --splitcache $vg/$lv1
+check lv_field $vg/$lv1 segtype linear
+check lv_field $vg/$lv2 segtype linear
+mount_umount $lv1
+
+# FIXME: kernel errors for other cache modes
+
+#lvconvert -y --type cache --cachepool $lv2 --cachemode passthrough $vg/$lv1
+
+#check lv_field $vg/$lv1 cachemode "passthrough"
+
+#mkfs_mount_umount $lv1
+
+#lvconvert --splitcache $vg/$lv1
+#check lv_field $vg/$lv1 segtype linear
+#check lv_field $vg/$lv2 segtype linear
+#mount_umount $lv1
+
+
+#lvconvert -y --type cache --cachepool $lv2 --cachemode writeback $vg/$lv1
+
+#check lv_field $vg/$lv1 cachemode "writeback"
+
+#mkfs_mount_umount $lv1
+
+#lvconvert --splitcache $vg/$lv1
+#check lv_field $vg/$lv1 segtype linear
+#check lv_field $vg/$lv2 segtype linear
+#mount_umount $lv1
+
+
+#
+# Test --cachepolicy
+#
+
+lvconvert -y --type cache --cachepool $lv2 --cachepolicy smq $vg/$lv1
+
+check lv_field $vg/$lv1 cachepolicy "smq"
+
+mkfs_mount_umount $lv1
+
+# FIXME: lvchange_cachepolicy sets wrong lv
+#lvchange --cachepolicy cleaner $vg/$lv1
+#lvchange -ay $vg/$lv1
+#check lv_field $vg/$lv1 cachepolicy "cleaner"
+#lvchange -an $vg/$lv1
+
+lvconvert --splitcache $vg/$lv1
+check lv_field $vg/$lv1 segtype linear
+check lv_field $vg/$lv2 segtype linear
+mount_umount $lv1
+
+
+#
+# Test --cachesettings
+# (only for mq policy, no settings for smq)
+#
+
+lvconvert -y --type cache --cachepool $lv2 --cachemode writethrough --cachepolicy mq --cachesettings 'migration_threshold = 233 sequential_threshold=13 random_threshold =1' $vg/$lv1
+
+check lv_field $vg/$lv1 cachemode "writethrough"
+check lv_field $vg/$lv1 cachepolicy "mq"
+
+lvs -o cachesettings $vg/$lv1 > settings
+grep "migration_threshold=233" settings
+grep "sequential_threshold=13" settings
+grep "random_threshold=1" settings
+
+mkfs_mount_umount $lv1
+
+lvconvert --splitcache $vg/$lv1
+check lv_field $vg/$lv1 segtype linear
+check lv_field $vg/$lv2 segtype linear
+mount_umount $lv1
+
+
+#
+# Test lvchange of --cachemode, --cachepolicy, --cachesettings
+#
+
+lvconvert -y --type cache --cachepool $lv2 $vg/$lv1
+
+lvchange -ay $vg/$lv1
+
+lvchange --cachemode writeback $vg/$lv1
+
+check lv_field $vg/$lv1 cachemode "writeback"
+
+lvchange --cachemode writethrough $vg/$lv1
+
+check lv_field $vg/$lv1 cachemode "writethrough"
+
+lvchange -an $vg/$lv1
+
+lvchange --cachepolicy mq --cachesettings 'migration_threshold=100' $vg/$lv1
+
+check lv_field $vg/$lv1 cachepolicy "mq"
+check lv_field $vg/$lv1 cachesettings "migration_threshold=100"
+
+lvconvert --splitcache $vg/$lv1
+
+
+#
+# Test --poolmetadata
+#
+
+# causes a cache-pool type LV to be created
+lvconvert -y --type cache --cachepool $lv3 --poolmetadata $lv4 $vg/$lv5
+
+lvs -a -o+segtype $vg
+
+check lv_field $vg/$lv5 segtype cache
+
+# check lv_field doesn't work for hidden lvs
+lvs -a -o segtype $vg/$lv3 > segtype
+grep cache-pool segtype
+
+lvconvert --splitcache $vg/$lv5
+check lv_field $vg/$lv5 segtype linear
+check lv_field $vg/$lv3 segtype cache-pool
+
+
+vgremove -ff $vg
+
diff --git a/test/shell/cache-single-thin.sh b/test/shell/cache-single-thin.sh
new file mode 100644
index 0000000..25c232f
--- /dev/null
+++ b/test/shell/cache-single-thin.sh
@@ -0,0 +1,43 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2017 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+# Test single lv cache
+
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+aux prepare_devs 5 80
+
+vgcreate $SHARED $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
+
+# lv1 starts as a standard linear LV
+# lv1 is then sped up by attaching fast device lv2 using dm-cache
+# lv1 is then used as the data device in a thin pool
+
+lvcreate -L10 -an -n $lv1 $vg "$dev1"
+lvcreate -L10 -an -n $lv2 $vg "$dev2"
+
+lvconvert -y --type cache --cachepool $lv2 $vg/$lv1
+lvconvert -y --type thin-pool $vg/$lv1
+
+lvcreate --type thin -V10 -n lvthin --thinpool $vg/$lv1
+
+lvchange -an $vg/lvthin
+lvchange -an $vg/$lv1
+
+# detach the cache (lv2) from lv1
+
+lvconvert --splitcache $vg/$lv1
+
+vgremove -ff $vg
+
diff --git a/test/shell/cache-single-types.sh b/test/shell/cache-single-types.sh
new file mode 100644
index 0000000..472970a
--- /dev/null
+++ b/test/shell/cache-single-types.sh
@@ -0,0 +1,88 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2017 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+# Test single lv cache with non-linear lvs
+
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+mount_dir="mnt"
+mkdir -p $mount_dir
+
+# generate random data
+dmesg > pattern1
+ps aux >> pattern1
+
+aux prepare_devs 4 64
+
+vgcreate $SHARED $vg "$dev1" "$dev2" "$dev3" "$dev4"
+
+lvcreate --type raid1 -n $lv1 -l 8 -an $vg "$dev1" "$dev2"
+
+lvcreate --type raid1 -n $lv2 -l 4 -an $vg "$dev3" "$dev4"
+
+# test1: create fs on LV before cache is attached
+
+lvchange -ay $vg/$lv1
+
+mkfs.xfs -f -s size=4096 "$DM_DEV_DIR/$vg/$lv1"
+
+mount "$DM_DEV_DIR/$vg/$lv1" $mount_dir
+
+cp pattern1 $mount_dir/pattern1
+
+umount $mount_dir
+lvchange -an $vg/$lv1
+
+lvconvert -y --type cache --cachepool $lv2 $vg/$lv1
+
+check lv_field $vg/$lv1 segtype cache
+
+lvs -a $vg/$lv2 --noheadings -o segtype >out
+grep raid1 out
+
+lvchange -ay $vg/$lv1
+
+mount "$DM_DEV_DIR/$vg/$lv1" $mount_dir
+
+diff pattern1 $mount_dir/pattern1
+
+cp pattern1 $mount_dir/pattern1b
+
+ls -l $mount_dir
+
+umount $mount_dir
+
+lvchange -an $vg/$lv1
+
+lvconvert --splitcache $vg/$lv1
+
+check lv_field $vg/$lv1 segtype raid1
+check lv_field $vg/$lv2 segtype raid1 
+
+lvchange -ay $vg/$lv1
+lvchange -ay $vg/$lv2
+
+mount "$DM_DEV_DIR/$vg/$lv1" $mount_dir
+
+ls -l $mount_dir
+
+diff pattern1 $mount_dir/pattern1
+diff pattern1 $mount_dir/pattern1b
+
+umount $mount_dir
+lvchange -an $vg/$lv1
+lvchange -an $vg/$lv2
+
+vgremove -ff $vg
+
diff --git a/test/shell/cache-single-usage.sh b/test/shell/cache-single-usage.sh
new file mode 100644
index 0000000..9636932
--- /dev/null
+++ b/test/shell/cache-single-usage.sh
@@ -0,0 +1,129 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2017 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+# Test single lv cache
+
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+mount_dir="mnt"
+mkdir -p $mount_dir
+
+# generate random data
+dmesg > pattern1
+ps aux >> pattern1
+
+aux prepare_devs 2 64
+
+vgcreate $SHARED $vg "$dev1"
+
+vgextend $vg "$dev2"
+
+lvcreate -n $lv1 -l 8 -an $vg "$dev1"
+
+lvcreate -n $lv2 -l 4 -an $vg "$dev2"
+
+# test1: create fs on LV before cache is attached
+
+lvchange -ay $vg/$lv1
+
+mkfs.xfs -f -s size=4096 "$DM_DEV_DIR/$vg/$lv1"
+
+mount "$DM_DEV_DIR/$vg/$lv1" $mount_dir
+
+cp pattern1 $mount_dir/pattern1
+
+umount $mount_dir
+lvchange -an $vg/$lv1
+
+lvconvert -y --type cache --cachepool $lv2 $vg/$lv1
+
+check lv_field $vg/$lv1 segtype cache
+
+lvs -a $vg/$lv2 --noheadings -o segtype >out
+grep linear out
+
+lvchange -ay $vg/$lv1
+
+mount "$DM_DEV_DIR/$vg/$lv1" $mount_dir
+
+diff pattern1 $mount_dir/pattern1
+
+cp pattern1 $mount_dir/pattern1b
+
+ls -l $mount_dir
+
+umount $mount_dir
+
+lvchange -an $vg/$lv1
+
+lvconvert --splitcache $vg/$lv1
+
+check lv_field $vg/$lv1 segtype linear
+check lv_field $vg/$lv2 segtype linear
+
+lvchange -ay $vg/$lv1
+lvchange -ay $vg/$lv2
+
+mount "$DM_DEV_DIR/$vg/$lv1" $mount_dir
+
+ls -l $mount_dir
+
+diff pattern1 $mount_dir/pattern1
+diff pattern1 $mount_dir/pattern1b
+
+umount $mount_dir
+lvchange -an $vg/$lv1
+lvchange -an $vg/$lv2
+
+# test2: create fs on LV after cache is attached
+
+lvconvert -y --type cache --cachepool $lv2 $vg/$lv1
+
+check lv_field $vg/$lv1 segtype cache
+
+lvs -a $vg/$lv2 --noheadings -o segtype >out
+grep linear out
+
+lvchange -ay $vg/$lv1
+
+mkfs.xfs -f -s size=4096 "$DM_DEV_DIR/$vg/$lv1"
+
+mount "$DM_DEV_DIR/$vg/$lv1" $mount_dir
+
+cp pattern1 $mount_dir/pattern1
+ls -l $mount_dir
+
+umount $mount_dir
+lvchange -an $vg/$lv1
+
+lvconvert --splitcache $vg/$lv1
+
+check lv_field $vg/$lv1 segtype linear
+check lv_field $vg/$lv2 segtype linear
+
+lvchange -ay $vg/$lv1
+lvchange -ay $vg/$lv2
+
+mount "$DM_DEV_DIR/$vg/$lv1" $mount_dir
+
+ls -l $mount_dir
+
+diff pattern1 $mount_dir/pattern1
+
+umount $mount_dir
+lvchange -an $vg/$lv1
+lvchange -an $vg/$lv2
+
+vgremove -ff $vg
+
diff --git a/test/shell/lvconvert-cache-raid.sh b/test/shell/lvconvert-cache-raid.sh
index fa49163..465def7 100644
--- a/test/shell/lvconvert-cache-raid.sh
+++ b/test/shell/lvconvert-cache-raid.sh
@@ -84,22 +84,31 @@ lvremove -f $vg
 
 
 # Test up/down raid conversion of cache pool data and metadata
-lvcreate --type cache-pool $vg/cpool -l 10
-lvcreate -H -n corigin --cachepool $vg/cpool -l 20 $vg
-
-lvconvert -y -m +1 --type raid1 $vg/cpool_cmeta
-check lv_field $vg/cpool_cmeta layout "raid,raid1"
-check lv_field $vg/cpool_cmeta role "private,cache,pool,metadata"
-
-lvconvert -y -m +1 --type raid1 $vg/cpool_cdata
-check lv_field $vg/cpool_cdata layout "raid,raid1"
-check lv_field $vg/cpool_cdata role "private,cache,pool,data"
-
-not lvconvert -m -1  $vg/cpool_cmeta
-lvconvert -y -m -1  $vg/cpool_cmeta
-check lv_field $vg/cpool_cmeta layout "linear"
-lvconvert -y -m -1  $vg/cpool_cdata
-check lv_field $vg/cpool_cdata layout "linear"
+
+lvcreate -l 10 -n cp1 $vg
+lvconvert -y --type cache-pool $vg/cp1
+
+lvcreate -l 20 -n co1 $vg
+lvconvert -y --type cache --cachepool cp1 $vg/co1
+
+lvconvert -y -m +1 --type raid1 $vg/cp1_cmeta
+check lv_field $vg/cp1_cmeta layout "raid,raid1"
+check lv_field $vg/cp1_cmeta role "private,cache,pool,metadata"
+
+lvconvert -y -m +1 --type raid1 $vg/cp1_cdata
+check lv_field $vg/cp1_cdata layout "raid,raid1"
+check lv_field $vg/cp1_cdata role "private,cache,pool,data"
+
+sleep 5
+
+lvs -a -o+devices $vg
+
+not lvconvert -m -1  $vg/cp1_cmeta
+
+lvconvert -y -m -1  $vg/cp1_cmeta
+check lv_field $vg/cp1_cmeta layout "linear"
+lvconvert -y -m -1  $vg/cp1_cdata
+check lv_field $vg/cp1_cdata layout "linear"
 
 lvremove -f $vg
 
diff --git a/test/shell/lvconvert-cache.sh b/test/shell/lvconvert-cache.sh
index b2a2920..0c38dd0 100644
--- a/test/shell/lvconvert-cache.sh
+++ b/test/shell/lvconvert-cache.sh
@@ -104,6 +104,7 @@ lvcreate -n pool -l 10 $vg
 lvs -a -o +devices
 fail lvconvert --type cache --cachepool $vg/pool $vg/corigin
 lvconvert --yes --cache --cachepool $vg/pool $vg/corigin
+lvconvert --splitcache $vg/corigin
 lvremove -ff $vg
 
 # Check we also support conversion that uses 'cleaner' cache policy
diff --git a/test/shell/lvrename-cache-thin.sh b/test/shell/lvrename-cache-thin.sh
index 8e9bd78..0697d1c 100644
--- a/test/shell/lvrename-cache-thin.sh
+++ b/test/shell/lvrename-cache-thin.sh
@@ -26,6 +26,8 @@ lvcreate -L10 -n cpool $vg
 lvcreate -L10 -n tpool $vg
 lvcreate -L10 -n $lv1 $vg
 
+lvconvert --yes --type cache-pool $vg/cpool
+
 lvconvert --yes --cache --cachepool cpool $vg/tpool
 
 # currently the only allowed stacking is cache thin data volume
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 52b3bda..537e582 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -643,7 +643,10 @@ static int _lvchange_cache(struct cmd_context *cmd,
 
 	seg = first_seg(lv);
 
-	if (seg_is_cache_pool(seg))
+	if (seg_is_cache(seg) && lv_is_cache_single(seg->pool_lv))
+		setting_seg = seg;
+
+	else if (seg_is_cache_pool(seg))
 		setting_seg = seg;
 
 	else if (seg_is_cache(seg))
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index dbc5ab0..7382ce0 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1844,14 +1844,20 @@ static int _lvconvert_split_and_keep_cachepool(struct cmd_context *cmd,
 				   struct logical_volume *lv,
 				   struct logical_volume *cachepool_lv)
 {
-	log_debug("Detaching cache pool %s from cache LV %s.",
-		  display_lvname(cachepool_lv), display_lvname(lv));
+	struct lv_segment *cache_seg = first_seg(lv);
+
+	log_debug("Detaching cache %s from LV %s.", display_lvname(cachepool_lv), display_lvname(lv));
 
 	if (!archive(lv->vg))
 		return_0;
 
-	if (!lv_cache_remove(lv))
-		return_0;
+	if (lv_is_cache_single(cache_seg->pool_lv)) {
+		if (!lv_detach_cache_single(lv))
+			return_0;
+	} else {
+		if (!lv_cache_remove(lv))
+			return_0;
+	}
 
 	if (!vg_write(lv->vg) || !vg_commit(lv->vg))
 		return_0;
@@ -2429,6 +2435,11 @@ static int _lvconvert_cache_repair(struct cmd_context *cmd,
 	struct logical_volume *pmslv;
 	struct logical_volume *mlv;
 
+	if (lv_is_cache(cache_lv) && lv_is_cache_single(first_seg(cache_lv)->pool_lv)) {
+		log_error("Manual repair required.");
+		return_0;
+	}
+
 	pool_lv = lv_is_cache_pool(cache_lv) ? cache_lv : first_seg(cache_lv)->pool_lv;
 	mlv = first_seg(pool_lv)->metadata_lv;
 
@@ -3357,25 +3368,100 @@ revert_new_lv:
 #endif
 }
 
-static int _lvconvert_to_cache_vol(struct cmd_context *cmd,
-				   struct logical_volume *lv,
-				   struct logical_volume *cachepool_lv)
+static int _cache_single_attach(struct cmd_context *cmd,
+			        struct logical_volume *lv,
+			        struct logical_volume *lv_fast)
 {
+	struct volume_group *vg = lv->vg;
 	struct logical_volume *cache_lv;
 	uint32_t chunk_size = 0;
+	uint64_t poolmetadatasize = 0;
 	cache_metadata_format_t cache_metadata_format;
 	cache_mode_t cache_mode;
 	const char *policy_name;
 	struct dm_config_tree *policy_settings = NULL;
+	char *lockd_fast_args = NULL;
+	char *lockd_fast_name = NULL;
+	struct id lockd_fast_id;
 	int r = 0;
 
-	if (_raid_split_image_conversion(lv))
-		return 0;
-
-	/* If LV is inactive here, ensure it's not active elsewhere. */
-	if (!lockd_lv(cmd, lv, "ex", 0))
+	if (!validate_lv_cache_create_pool(lv_fast))
 		return_0;
 
+	if (!get_cache_params(cmd, &chunk_size, &cache_metadata_format, &cache_mode, &policy_name, &policy_settings))
+		goto_out;
+
+	if (!archive(vg))
+		goto_out;
+
+	/*
+	 * Changes the vg struct to match the desired state.
+	 *
+	 * - lv == cache_lv, which keeps existing lv name and id, gets new
+	 *   segment with segtype "cache".
+	 *
+	 * - lv_fast keeps its existing name and id, becomes hidden.
+	 *
+	 * - lv_corig gets new name (existing name + _corig suffix),
+	 *   gets new id, becomes hidden, gets segments from lv.
+	 */
+
+	if (!(cache_lv = lv_cache_create(lv_fast, lv)))
+		goto_out;
+
+	if (arg_is_set(cmd, poolmetadatasize_ARG))
+		poolmetadatasize = arg_uint64_value(cmd, poolmetadatasize_ARG, 0);
+
+	if (!cache_single_set_params(cmd, cache_lv, lv_fast, poolmetadatasize, chunk_size, cache_metadata_format, cache_mode, policy_name, policy_settings))
+		goto_out;
+
+	/*
+	 * lv/cache_lv keeps the same lockd lock it had before, the lock for
+	 * lv_fast is freed, and lv_corig has no lock.
+	 */
+
+	if (vg_is_shared(vg) && lv_fast->lock_args) {
+		lockd_fast_args = dm_pool_strdup(cmd->mem, lv_fast->lock_args);
+		lockd_fast_name = dm_pool_strdup(cmd->mem, lv_fast->name);
+		memcpy(&lockd_fast_id, &lv_fast->lvid.id[1], sizeof(struct id));
+		lv_fast->lock_args = NULL;
+	}
+
+	/*
+	 * vg_write(), suspend_lv(), vg_commit(), resume_lv(),
+	 * where the old LV is suspended and the new LV is resumed.
+	 */
+
+	if (!lv_update_and_reload(cache_lv))
+		goto_out;
+
+	if (lockd_fast_name) {
+		/* unlock and free lockd lock for lv_fast */
+		if (!lockd_lv_name(cmd, vg, lockd_fast_name, &lockd_fast_id, lockd_fast_args, "un", LDLV_PERSISTENT))
+			log_error("Failed to unlock fast LV %s/%s", vg->name, lockd_fast_name);
+		lockd_free_lv(cmd, vg, lockd_fast_name, &lockd_fast_id, lockd_fast_args);
+	}
+
+	r = 1;
+out:
+	if (policy_settings)
+		dm_config_destroy(policy_settings);
+
+	return r;
+}
+
+static int _cache_pool_attach(struct cmd_context *cmd,
+			      struct logical_volume *lv,
+			      struct logical_volume *cachepool_lv)
+{
+	struct logical_volume *cache_lv;
+	uint32_t chunk_size = 0;
+	cache_metadata_format_t cache_metadata_format;
+	cache_mode_t cache_mode;
+	const char *policy_name;
+	struct dm_config_tree *policy_settings = NULL;
+	int r = 0;
+
 	if (!validate_lv_cache_create_pool(cachepool_lv))
 		return_0;
 
@@ -3394,8 +3480,6 @@ static int _lvconvert_to_cache_vol(struct cmd_context *cmd,
 	if (!lv_update_and_reload(cache_lv))
 		goto_bad;
 
-	log_print_unless_silent("Logical volume %s is now cached.",
-				display_lvname(cache_lv));
 	r = 1;
 bad:
 	if (policy_settings)
@@ -4018,9 +4102,9 @@ int lvconvert_to_pool_cmd(struct cmd_context *cmd, int argc, char **argv)
 			       NULL, NULL, &_lvconvert_to_pool_single);
 }
 
-static int _lvconvert_to_cache_vol_single(struct cmd_context *cmd,
-					 struct logical_volume *lv,
-					 struct processing_handle *handle)
+static int _lvconvert_cache_attach_single(struct cmd_context *cmd,
+					  struct logical_volume *lv,
+					  struct processing_handle *handle)
 {
 	struct volume_group *vg = lv->vg;
 	struct logical_volume *cachepool_lv;
@@ -4037,12 +4121,16 @@ static int _lvconvert_to_cache_vol_single(struct cmd_context *cmd,
 		goto out;
 	}
 
+	/* Ensure the LV is not active elsewhere. */
+	if (!lockd_lv(cmd, lv, "ex", 0))
+		goto_out;
+
 	/*
 	 * If cachepool_lv is not yet a cache pool, convert it to one.
 	 * If using an existing cache pool, wipe it.
 	 */
 
-	if (!lv_is_cache_pool(cachepool_lv)) {
+	if (!lv_is_cache_pool(cachepool_lv) && arg_is_set(cmd, poolmetadata_ARG)) {
 		int lvt_enum = get_lvt_enum(cachepool_lv);
 		struct lv_type *lvtype = get_lv_type(lvt_enum);
 
@@ -4073,6 +4161,28 @@ static int _lvconvert_to_cache_vol_single(struct cmd_context *cmd,
 			log_error("LV %s is not a cache pool.", display_lvname(cachepool_lv));
 			goto out;
 		}
+
+	} else if (!lv_is_cache_pool(cachepool_lv)) {
+
+		if (!dm_list_empty(&cachepool_lv->segs_using_this_lv)) {
+			log_error("LV %s is already in use.", display_lvname(cachepool_lv));
+			goto out;
+		}
+
+		if (!arg_is_set(cmd, yes_ARG) &&
+		    yes_no_prompt("Erase all existing data on %s? [y/n]: ", display_lvname(cachepool_lv)) == 'n') {
+			log_error("Conversion aborted.");
+			goto out;
+		}
+
+		/* Ensure the LV is not active elsewhere. */
+		if (!lockd_lv(cmd, cachepool_lv, "ex", LDLV_PERSISTENT))
+			goto_out;
+
+		cachepool_lv->status |= LV_CACHE_SINGLE;
+
+		if (!wipe_cache_pool(cachepool_lv))
+			goto_out;
 	} else {
 		if (!dm_list_empty(&cachepool_lv->segs_using_this_lv)) {
 			log_error("Cache pool %s is already in use.", cachepool_name);
@@ -4108,10 +4218,25 @@ static int _lvconvert_to_cache_vol_single(struct cmd_context *cmd,
 		log_verbose("Redirecting operation to data sub LV %s.", display_lvname(lv));
 	}
 
-	/* Convert lv to cache vol using cachepool_lv. */
+	if (_raid_split_image_conversion(lv))
+		goto_out;
+
+	/* Attach the cache to the main LV. */
+
+	if (lv_is_cache_single(cachepool_lv)) {
+		if (!_cache_single_attach(cmd, lv, cachepool_lv))
+			goto_out;
+
+	} else if (lv_is_cache_pool(cachepool_lv)) {
+		if (!_cache_pool_attach(cmd, lv, cachepool_lv))
+			goto_out;
 
-	if (!_lvconvert_to_cache_vol(cmd, lv, cachepool_lv))
+	} else {
+		log_error(INTERNAL_ERROR "Invalid cache pool state for %s", cachepool_lv->name);
 		goto_out;
+	}
+
+	log_print_unless_silent("Logical volume %s is now cached.", display_lvname(lv));
 
 	return ECMD_PROCESSED;
 
@@ -4122,7 +4247,7 @@ static int _lvconvert_to_cache_vol_single(struct cmd_context *cmd,
 int lvconvert_to_cache_vol_cmd(struct cmd_context *cmd, int argc, char **argv)
 {
 	return process_each_lv(cmd, 1, cmd->position_argv, NULL, NULL, READ_FOR_UPDATE,
-			       NULL, NULL, &_lvconvert_to_cache_vol_single);
+			       NULL, NULL, &_lvconvert_cache_attach_single);
 }
 
 static int _lvconvert_to_thin_with_external_single(struct cmd_context *cmd,
@@ -4415,6 +4540,13 @@ static int _lvconvert_split_cachepool_single(struct cmd_context *cmd,
 		return ECMD_FAILED;
 	}
 
+	if ((cmd->command->command_enum == lvconvert_split_and_remove_cachepool_CMD) &&
+	    lv_is_cache_single(cachepool_lv)) {
+		log_error("Detach cache from %s with --splitcache.", display_lvname(lv));
+		log_error("The cache %s may then be removed with lvremove.", display_lvname(cachepool_lv));
+		return 0;
+	}
+
 	/* If LV is inactive here, ensure it's not active elsewhere. */
 	if (!lockd_lv(cmd, cache_lv, "ex", 0))
 		return_0;
diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index 5824c82..fc99d2e 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -402,7 +402,10 @@ static int _move_cache(struct volume_group *vg_from,
 
 		/* NOTREACHED */
 
-		if (lv_is_cache(lv)) {
+		if (lv_is_cache(lv) && lv_is_cache_single(seg->pool_lv)) {
+			log_error("Cannot split while LV %s has cache attached.", display_lvname(lv));
+			return 0;
+		} else if (lv_is_cache(lv)) {
 			orig = seg_lv(seg, 0);
 			data = seg_lv(first_seg(seg->pool_lv), 0);
 			meta = first_seg(seg->pool_lv)->metadata_lv;


