From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 30 Mar 2021 11:10:09 +0000 (GMT)
Subject: main - device_mapper: remove unused lines
Message-ID: <20210330111009.AAEEF3860C39@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f1e8437c59882a71a9a6e005d188a12a35f0cf9b
Commit:        f1e8437c59882a71a9a6e005d188a12a35f0cf9b
Parent:        1cedbaf13778de02e38b5dc80a7af246b7ec83e5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 29 22:02:45 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 30 13:07:51 2021 +0200

device_mapper: remove unused lines

No need for versioning history in internal version.
---
 device_mapper/datastruct/bitset.c | 15 -----------
 device_mapper/ioctl/libdm-iface.c | 49 ----------------------------------
 device_mapper/libdm-deptree.c     | 55 ---------------------------------------
 3 files changed, 119 deletions(-)

diff --git a/device_mapper/datastruct/bitset.c b/device_mapper/datastruct/bitset.c
index fc2c3c39c..c99927cc1 100644
--- a/device_mapper/datastruct/bitset.c
+++ b/device_mapper/datastruct/bitset.c
@@ -242,18 +242,3 @@ bad:
 	}
 	return NULL;
 }
-
-#if defined(__GNUC__)
-/*
- * Maintain backward compatibility with older versions that did not
- * accept a 'min_num_bits' argument to dm_bitset_parse_list().
- */
-dm_bitset_t dm_bitset_parse_list_v1_02_129(const char *str, struct dm_pool *mem);
-dm_bitset_t dm_bitset_parse_list_v1_02_129(const char *str, struct dm_pool *mem)
-{
-	return dm_bitset_parse_list(str, mem, 0);
-}
-
-#else /* if defined(__GNUC__) */
-
-#endif
diff --git a/device_mapper/ioctl/libdm-iface.c b/device_mapper/ioctl/libdm-iface.c
index 536e4b238..a2a56be45 100644
--- a/device_mapper/ioctl/libdm-iface.c
+++ b/device_mapper/ioctl/libdm-iface.c
@@ -2209,52 +2209,3 @@ void dm_lib_exit(void)
 	_version_ok = 1;
 	_version_checked = 0;
 }
-
-#if defined(__GNUC__)
-/*
- * Maintain binary backward compatibility.
- * Version script mechanism works with 'gcc' compatible compilers only.
- */
-
-/*
- * This following code is here to retain ABI compatibility after adding
- * the field deferred_remove to struct dm_info in version 1.02.89.
- *
- * Binaries linked against version 1.02.88 of libdevmapper or earlier
- * will use this function that returns dm_info without the
- * deferred_remove field.
- *
- * Binaries compiled against version 1.02.89 onwards will use
- * the new function dm_task_get_info_with_deferred_remove due to the
- * #define.
- *
- * N.B. Keep this function at the end of the file to make sure that
- * no code in this file accidentally calls it.
- */
-
-int dm_task_get_info_base(struct dm_task *dmt, struct dm_info *info);
-int dm_task_get_info_base(struct dm_task *dmt, struct dm_info *info)
-{
-	struct dm_info new_info;
-
-	if (!dm_task_get_info(dmt, &new_info))
-		return 0;
-
-	memcpy(info, &new_info, offsetof(struct dm_info, deferred_remove));
-
-	return 1;
-}
-
-int dm_task_get_info_with_deferred_remove(struct dm_task *dmt, struct dm_info *info);
-int dm_task_get_info_with_deferred_remove(struct dm_task *dmt, struct dm_info *info)
-{
-	struct dm_info new_info;
-
-	if (!dm_task_get_info(dmt, &new_info))
-		return 0;
-
-	memcpy(info, &new_info, offsetof(struct dm_info, internal_suspend));
-
-	return 1;
-}
-#endif
diff --git a/device_mapper/libdm-deptree.c b/device_mapper/libdm-deptree.c
index ede75ef77..70acfb093 100644
--- a/device_mapper/libdm-deptree.c
+++ b/device_mapper/libdm-deptree.c
@@ -4328,61 +4328,6 @@ void dm_tree_node_set_callback(struct dm_tree_node *dnode,
 	dnode->callback_data = data;
 }
 
-#if defined(__GNUC__)
-/*
- * Backward compatible implementations.
- *
- * Keep these at the end of the file to make sure that
- * no code in this file accidentally calls it.
- */
-
-/* Backward compatible dm_tree_node_size_changed() implementations. */
-int dm_tree_node_size_changed_base(const struct dm_tree_node *dnode);
-int dm_tree_node_size_changed_base(const struct dm_tree_node *dnode)
-{
-	/* Base does not make difference between smaller and bigger */
-	return dm_tree_node_size_changed(dnode) ? 1 : 0;
-}
-
-/*
- * Retain ABI compatibility after adding the DM_CACHE_FEATURE_METADATA2
- * in version 1.02.138.
- *
- * Binaries compiled against version 1.02.138 onwards will use
- * the new function dm_tree_node_add_cache_target which detects unknown
- * feature flags and returns error for them.
- */
-int dm_tree_node_add_cache_target_base(struct dm_tree_node *node,
-				       uint64_t size,
-				       uint64_t feature_flags, /* DM_CACHE_FEATURE_* */
-				       const char *metadata_uuid,
-				       const char *data_uuid,
-				       const char *origin_uuid,
-				       const char *policy_name,
-				       const struct dm_config_node *policy_settings,
-				       uint32_t data_block_size);
-int dm_tree_node_add_cache_target_base(struct dm_tree_node *node,
-				       uint64_t size,
-				       uint64_t feature_flags,
-				       const char *metadata_uuid,
-				       const char *data_uuid,
-				       const char *origin_uuid,
-				       const char *policy_name,
-				       const struct dm_config_node *policy_settings,
-				       uint32_t data_block_size)
-{
-	/* Old version supported only these FEATURE bits, others were ignored so masked them */
-	static const uint64_t _mask =
-		DM_CACHE_FEATURE_WRITEBACK |
-		DM_CACHE_FEATURE_WRITETHROUGH |
-		DM_CACHE_FEATURE_PASSTHROUGH;
-
-	return dm_tree_node_add_cache_target(node, size, feature_flags & _mask,
-					     metadata_uuid, data_uuid, origin_uuid,
-					     policy_name, policy_settings, 0, 0, 0, 0, data_block_size);
-}
-#endif
-
 int dm_tree_node_add_vdo_target(struct dm_tree_node *node,
 				uint64_t size,
 				const char *vdo_pool_name,


