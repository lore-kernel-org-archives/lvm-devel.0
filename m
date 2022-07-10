From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sun, 10 Jul 2022 23:22:21 +0000 (GMT)
Subject: main - vdo: support v4 kernel target line
Message-ID: <20220710232221.C5996385734A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1c18ed3b4ab2f2d5a15995b8f0a18d7d1c4d60ca
Commit:        1c18ed3b4ab2f2d5a15995b8f0a18d7d1c4d60ca
Parent:        a477490e812639fed3be495f215fcf1a7b65b7ee
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jul 8 23:35:06 2022 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 11 01:18:24 2022 +0200

vdo: support v4 kernel target line

Check and use new available table line v4, if kernel supports it.
---
 device_mapper/all.h           |  1 +
 device_mapper/libdm-deptree.c | 37 +++++++++++++++++++++++++------------
 lib/metadata/segtype.h        |  1 +
 lib/vdo/vdo.c                 | 10 ++++++++--
 test/shell/vdo-convert.sh     |  2 ++
 5 files changed, 37 insertions(+), 14 deletions(-)

diff --git a/device_mapper/all.h b/device_mapper/all.h
index c8f040b80..34d65885e 100644
--- a/device_mapper/all.h
+++ b/device_mapper/all.h
@@ -1049,6 +1049,7 @@ int dm_tree_node_add_integrity_target(struct dm_tree_node *node,
  */
 int dm_tree_node_add_vdo_target(struct dm_tree_node *node,
 				uint64_t size,
+				uint32_t vdo_version,
 				const char *vdo_pool_name,
 				const char *data_uuid,
 				uint64_t data_size,
diff --git a/device_mapper/libdm-deptree.c b/device_mapper/libdm-deptree.c
index e4bf4c814..2d382037c 100644
--- a/device_mapper/libdm-deptree.c
+++ b/device_mapper/libdm-deptree.c
@@ -214,6 +214,7 @@ struct load_segment {
 	uint32_t device_id;		/* Thin */
 
 	// VDO params
+	uint32_t vdo_version;		/* VDO - version of target table line */
 	struct dm_tree_node *vdo_data;  /* VDO */
 	struct dm_vdo_target_params vdo_params; /* VDO */
 	const char *vdo_name;           /* VDO - device name is ALSO passed as table arg */
@@ -2865,18 +2866,28 @@ static int _vdo_emit_segment_line(struct dm_task *dmt,
 		return 0;
 	}
 
-	EMIT_PARAMS(pos, "V2 %s " FMTu64 " %u " FMTu64 " %u %s %s %s "
-		    "maxDiscard %u ack %u bio %u bioRotationInterval %u cpu %u hash %u logical %u physical %u",
-		    data_dev,
-		    seg->vdo_data_size / 8, // this parameter is in 4K units
-		    seg->vdo_params.minimum_io_size * UINT32_C(512), //  sector to byte units
-		    seg->vdo_params.block_map_cache_size_mb * UINT64_C(256),	// 1MiB -> 4KiB units
-		    seg->vdo_params.block_map_era_length,
-		    seg->vdo_params.use_metadata_hints ? "on" : "off" ,
-		    (seg->vdo_params.write_policy == DM_VDO_WRITE_POLICY_SYNC) ? "sync" :
-			(seg->vdo_params.write_policy == DM_VDO_WRITE_POLICY_ASYNC) ? "async" :
-			(seg->vdo_params.write_policy == DM_VDO_WRITE_POLICY_ASYNC_UNSAFE) ? "async-unsafe" : "auto", // policy
-		    seg->vdo_name,
+	if (seg->vdo_version < 4) {
+		EMIT_PARAMS(pos, "V2 %s " FMTu64 " %u " FMTu64 " %u %s %s %s ",
+			    data_dev,
+			    seg->vdo_data_size / 8, // this parameter is in 4K units
+			    seg->vdo_params.minimum_io_size * UINT32_C(512), //  sector to byte units
+			    seg->vdo_params.block_map_cache_size_mb * UINT64_C(256),	// 1MiB -> 4KiB units
+			    seg->vdo_params.block_map_era_length,
+			    seg->vdo_params.use_metadata_hints ? "on" : "off" ,
+			    (seg->vdo_params.write_policy == DM_VDO_WRITE_POLICY_SYNC) ? "sync" :
+			    (seg->vdo_params.write_policy == DM_VDO_WRITE_POLICY_ASYNC) ? "async" :
+			    (seg->vdo_params.write_policy == DM_VDO_WRITE_POLICY_ASYNC_UNSAFE) ? "async-unsafe" : "auto", // policy
+			    seg->vdo_name);
+	} else {
+		EMIT_PARAMS(pos, "V4 %s " FMTu64 " %u " FMTu64 " %u ",
+			    data_dev,
+			    seg->vdo_data_size / 8, // this parameter is in 4K units
+			    seg->vdo_params.minimum_io_size * UINT32_C(512), //  sector to byte units
+			    seg->vdo_params.block_map_cache_size_mb * UINT64_C(256),	// 1MiB -> 4KiB units
+			    seg->vdo_params.block_map_era_length);
+	}
+
+	EMIT_PARAMS(pos, "maxDiscard %u ack %u bio %u bioRotationInterval %u cpu %u hash %u logical %u physical %u",
 		    seg->vdo_params.max_discard,
 		    seg->vdo_params.ack_threads,
 		    seg->vdo_params.bio_threads,
@@ -4323,6 +4334,7 @@ void dm_tree_node_set_callback(struct dm_tree_node *dnode,
 
 int dm_tree_node_add_vdo_target(struct dm_tree_node *node,
 				uint64_t size,
+				uint32_t vdo_version,
 				const char *vdo_pool_name,
 				const char *data_uuid,
 				uint64_t data_size,
@@ -4344,6 +4356,7 @@ int dm_tree_node_add_vdo_target(struct dm_tree_node *node,
 	if (!_link_tree_nodes(node, seg->vdo_data))
 		return_0;
 
+	seg->vdo_version = vdo_version;
 	seg->vdo_params = *vtp;
 	seg->vdo_name = vdo_pool_name;
 	seg->vdo_data_size = data_size;
diff --git a/lib/metadata/segtype.h b/lib/metadata/segtype.h
index 2f4949267..3e52f04a1 100644
--- a/lib/metadata/segtype.h
+++ b/lib/metadata/segtype.h
@@ -353,6 +353,7 @@ int init_vdo_segtypes(struct cmd_context *cmd, struct segtype_library *seglib);
 #endif
 
 #define VDO_FEATURE_ONLINE_RENAME		(1U << 0) /* version 6.2.3 */
+#define VDO_FEATURE_VERSION4			(1U << 1) /* version 8.2.0 */
 
 int init_writecache_segtypes(struct cmd_context *cmd, struct segtype_library *seglib);
 
diff --git a/lib/vdo/vdo.c b/lib/vdo/vdo.c
index b9bcc044f..9efb424f0 100644
--- a/lib/vdo/vdo.c
+++ b/lib/vdo/vdo.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2018-2019 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2018-2022 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -364,6 +364,10 @@ static int _vdo_pool_add_target_line(struct dev_manager *dm,
 				     uint32_t *pvmove_mirror_count __attribute__((unused)))
 {
 	char *vdo_pool_name, *data_uuid;
+	unsigned attrs = 0;
+
+	if (seg->segtype->ops->target_present)
+		seg->segtype->ops->target_present(cmd, NULL, &attrs);
 
 	if (!seg_is_vdo_pool(seg)) {
 		log_error(INTERNAL_ERROR "Passed segment is not VDO pool.");
@@ -381,6 +385,7 @@ static int _vdo_pool_add_target_line(struct dev_manager *dm,
 
 	/* VDO uses virtual size instead of its physical size */
 	if (!dm_tree_node_add_vdo_target(node, get_vdo_pool_virtual_size(seg),
+					 !(attrs & VDO_FEATURE_VERSION4) ? 2 : 4,
 					 vdo_pool_name, data_uuid, seg_lv(seg, 0)->size,
 					 &seg->vdo_params))
 		return_0;
@@ -390,7 +395,7 @@ static int _vdo_pool_add_target_line(struct dev_manager *dm,
 
 static int _vdo_target_present(struct cmd_context *cmd,
 			       const struct lv_segment *seg __attribute__((unused)),
-			       unsigned *attributes __attribute__((unused)))
+			       unsigned *attributes)
 {
 	/* List of features with their kernel target version */
 	static const struct feature {
@@ -401,6 +406,7 @@ static int _vdo_target_present(struct cmd_context *cmd,
 		const char *feature;
 	} _features[] = {
 		{ 6, 2, 3, VDO_FEATURE_ONLINE_RENAME, "online_rename" },
+		{ 8, 2, 0, VDO_FEATURE_VERSION4, "version4" },
 	};
 	static const char _lvmconf[] = "global/vdo_disabled_features";
 	static int _vdo_checked = 0;
diff --git a/test/shell/vdo-convert.sh b/test/shell/vdo-convert.sh
index 8b03344a7..f1d04d596 100644
--- a/test/shell/vdo-convert.sh
+++ b/test/shell/vdo-convert.sh
@@ -174,6 +174,8 @@ vdo create $VDOCONF --name "$VDONAME" --device "$LOOP" --vdoSlabSize 128M --vdoL
 # Get VDO table line
 dmsetup table "$VDONAME" | tr " " "\n" | sed -e '5,6d' -e '12d' | tee vdo-orig
 
+aux lvmconf 'global/vdo_disabled_features = [ "version4" ]'
+
 lvm_import_vdo -y --name $vg/$lv "$LOOP"
 lvs -a $vg
 

