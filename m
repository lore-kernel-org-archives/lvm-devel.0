From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  6 Apr 2021 20:07:15 +0000 (GMT)
Subject: main - libdm: symbol versioning with -flto
Message-ID: <20210406200715.EBF7B3857823@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a8480f0f6e2585a66fb0a9e25135fde8fb11d997
Commit:        a8480f0f6e2585a66fb0a9e25135fde8fb11d997
Parent:        12949ea886259ead84597a1d4de37c8715d8edb7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Apr 3 21:49:37 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 6 21:26:57 2021 +0200

libdm: symbol versioning with -flto

Gcc10 introduced different strategy how to build
shared libraries with their new LTO optimizer.

Insired by:

https://akkadia.org/drepper/symbol-versioning
https://sourceware.org/pipermail/elfutils-devel/attachments/20200414/1c0c2903/attachment.bin
https://github.com/InBetweenNames/gentooLTO/issues/459
https://github.com/linux-rdma/rdma-core/blob/master/util/symver.h
https://gcc.gnu.org/bugzilla/show_bug.cgi?id=48200
---
 libdm/datastruct/bitset.c |  2 +-
 libdm/ioctl/libdm-iface.c |  5 +++--
 libdm/libdm-deptree.c     | 23 ++++++++++++-----------
 libdm/libdm-stats.c       | 15 +++++++++------
 libdm/misc/dmlib.h        | 27 ++++++++++++++++++++++-----
 5 files changed, 47 insertions(+), 25 deletions(-)

diff --git a/libdm/datastruct/bitset.c b/libdm/datastruct/bitset.c
index 8f36ec715..220ea2f26 100644
--- a/libdm/datastruct/bitset.c
+++ b/libdm/datastruct/bitset.c
@@ -247,11 +247,11 @@ bad:
  * Maintain backward compatibility with older versions that did not
  * accept a 'min_num_bits' argument to dm_bitset_parse_list().
  */
+DM_EXPORT_SYMBOL(dm_bitset_parse_list, 1_02_129)
 dm_bitset_t dm_bitset_parse_list_v1_02_129(const char *str, struct dm_pool *mem);
 dm_bitset_t dm_bitset_parse_list_v1_02_129(const char *str, struct dm_pool *mem)
 {
 	return dm_bitset_parse_list(str, mem, 0);
 }
-DM_EXPORT_SYMBOL(dm_bitset_parse_list, 1_02_129);
 
 #endif
diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index e459db88d..5b17614e6 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -709,7 +709,8 @@ int dm_format_dev(char *buf, int bufsize, uint32_t dev_major,
 	return 1;
 }
 
-int dm_task_get_info(struct dm_task *dmt, struct dm_info *info)
+DM_EXPORT_NEW_SYMBOL(int, dm_task_get_info, 1_02_97)
+	(struct dm_task *dmt, struct dm_info *info)
 {
 	if (!dmt->dmi.v4)
 		return 0;
@@ -2210,8 +2211,8 @@ void dm_lib_exit(void)
  * no code in this file accidentally calls it.
  */
 
+DM_EXPORT_SYMBOL_BASE(dm_task_get_info)
 int dm_task_get_info_base(struct dm_task *dmt, struct dm_info *info);
-DM_EXPORT_SYMBOL_BASE(dm_task_get_info);
 int dm_task_get_info_base(struct dm_task *dmt, struct dm_info *info)
 {
 	struct dm_info new_info;
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index e4cb6e5c0..06ebdc0c0 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -3311,15 +3311,16 @@ int dm_tree_node_add_raid_target_with_params_v2(struct dm_tree_node *node,
 	return 1;
 }
 
-int dm_tree_node_add_cache_target(struct dm_tree_node *node,
-				  uint64_t size,
-				  uint64_t feature_flags, /* DM_CACHE_FEATURE_* */
-				  const char *metadata_uuid,
-				  const char *data_uuid,
-				  const char *origin_uuid,
-				  const char *policy_name,
-				  const struct dm_config_node *policy_settings,
-				  uint32_t data_block_size)
+DM_EXPORT_NEW_SYMBOL(int, dm_tree_node_add_cache_target, 1_02_138)
+	(struct dm_tree_node *node,
+	 uint64_t size,
+	 uint64_t feature_flags, /* DM_CACHE_FEATURE_* */
+	 const char *metadata_uuid,
+	 const char *data_uuid,
+	 const char *origin_uuid,
+	 const char *policy_name,
+	 const struct dm_config_node *policy_settings,
+	 uint32_t data_block_size)
 {
 	struct dm_config_node *cn;
 	struct load_segment *seg;
@@ -3858,8 +3859,8 @@ void dm_tree_node_set_callback(struct dm_tree_node *dnode,
  */
 
 /* Backward compatible dm_tree_node_size_changed() implementations. */
+DM_EXPORT_SYMBOL_BASE(dm_tree_node_size_changed)
 int dm_tree_node_size_changed_base(const struct dm_tree_node *dnode);
-DM_EXPORT_SYMBOL_BASE(dm_tree_node_size_changed);
 int dm_tree_node_size_changed_base(const struct dm_tree_node *dnode)
 {
 	/* Base does not make difference between smaller and bigger */
@@ -3874,6 +3875,7 @@ int dm_tree_node_size_changed_base(const struct dm_tree_node *dnode)
  * the new function dm_tree_node_add_cache_target which detects unknown
  * feature flags and returns error for them.
  */
+DM_EXPORT_SYMBOL_BASE(dm_tree_node_add_cache_target)
 int dm_tree_node_add_cache_target_base(struct dm_tree_node *node,
 				       uint64_t size,
 				       uint64_t feature_flags, /* DM_CACHE_FEATURE_* */
@@ -3883,7 +3885,6 @@ int dm_tree_node_add_cache_target_base(struct dm_tree_node *node,
 				       const char *policy_name,
 				       const struct dm_config_node *policy_settings,
 				       uint32_t data_block_size);
-DM_EXPORT_SYMBOL_BASE(dm_tree_node_add_cache_target);
 int dm_tree_node_add_cache_target_base(struct dm_tree_node *node,
 				       uint64_t size,
 				       uint64_t feature_flags,
diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 49d06802e..120ad4d68 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -2011,10 +2011,11 @@ out:
 	return r;
 }
 
-int dm_stats_create_region(struct dm_stats *dms, uint64_t *region_id,
-			   uint64_t start, uint64_t len, int64_t step,
-			   int precise, struct dm_histogram *bounds,
-			   const char *program_id, const char *user_data)
+DM_EXPORT_NEW_SYMBOL(int, dm_stats_create_region, 1_02_107)
+	(struct dm_stats *dms, uint64_t *region_id,
+	 uint64_t start, uint64_t len, int64_t step,
+	 int precise, struct dm_histogram *bounds,
+	 const char *program_id, const char *user_data)
 {
 	char *hist_arg = NULL;
 	int r = 0;
@@ -2037,6 +2038,7 @@ out:
 	return r;
 }
 
+
 static void _stats_clear_group_regions(struct dm_stats *dms, uint64_t group_id)
 {
 	struct dm_stats_group *group;
@@ -5070,6 +5072,8 @@ int dm_stats_start_filemapd(int fd, uint64_t group_id, const char *path,
  */
 
 #if defined(GNU_SYMVER)
+
+DM_EXPORT_SYMBOL(dm_stats_create_region, 1_02_106)
 int dm_stats_create_region_v1_02_106(struct dm_stats *dms, uint64_t *region_id,
 				     uint64_t start, uint64_t len, int64_t step,
 				     int precise, const char *program_id,
@@ -5083,8 +5087,8 @@ int dm_stats_create_region_v1_02_106(struct dm_stats *dms, uint64_t *region_id,
 	return _stats_create_region(dms, region_id, start, len, step, precise,
 				    NULL, program_id, aux_data);
 }
-DM_EXPORT_SYMBOL(dm_stats_create_region, 1_02_106);
 
+DM_EXPORT_SYMBOL(dm_stats_create_region, 1_02_104)
 int dm_stats_create_region_v1_02_104(struct dm_stats *dms, uint64_t *region_id,
 				     uint64_t start, uint64_t len, int64_t step,
 				     const char *program_id, const char *aux_data);
@@ -5096,5 +5100,4 @@ int dm_stats_create_region_v1_02_104(struct dm_stats *dms, uint64_t *region_id,
 	return _stats_create_region(dms, region_id, start, len, step, 0, NULL,
 				    program_id, aux_data);
 }
-DM_EXPORT_SYMBOL(dm_stats_create_region, 1_02_104);
 #endif
diff --git a/libdm/misc/dmlib.h b/libdm/misc/dmlib.h
index 85a22c50f..95f4b8ecb 100644
--- a/libdm/misc/dmlib.h
+++ b/libdm/misc/dmlib.h
@@ -22,6 +22,7 @@
 /*
  * Symbol export control macros
  *
+ *   DM_EXPORT_NEW_SYMBOL(rettype, func, ver)
  *   DM_EXPORT_SYMBOL(func,ver)
  *   DM_EXPORT_SYMBOL_BASE(func,ver)
  *
@@ -40,19 +41,19 @@
  * compatibility version should be enclosed in '#if defined(GNU_SYMVER)',
  * for example:
  *
- *   int dm_foo(int bar)
+ *   DM_EXPORT_NEW_SYMBOL(int, dm_foo, 1_02_107)(int bar)
  *   {
  *     return bar;
  *   }
  *
- *   #if defined(__GNUC__)
+ *   #if defined(GNU_SYMVER)
  *   // Backward compatible dm_foo() version 1.02.104
+ *   DM_EXPORT_SYMBOL(dm_foo,1_02_104)
  *   int dm_foo_v1_02_104(void);
  *   int dm_foo_v1_02_104(void)
  *   {
  *     return 0;
  *   }
- *   DM_EXPORT_SYMBOL(dm_foo,1_02_104)
  *   #endif
  *
  * A prototype for the compatibility version is required as these
@@ -63,11 +64,27 @@
  * versioning: it must never be used for new symbols.
  */
 #if defined(GNU_SYMVER)
+# ifdef __has_attribute
+#  if __has_attribute(symver)
+#   define DM_EXPORT_NEW_SYMBOL(rettype, func, ver) \
+	__attribute__((__symver__( #func "@@DM_" #ver ))) \
+	__typeof__(func) func ##_v ##ver; \
+	rettype func ##_v ##ver
+#   define DM_EXPORT_SYMBOL(func, ver) \
+	__attribute__((__symver__( #func "@DM_" #ver )))
+#   define DM_EXPORT_SYMBOL_BASE(func) \
+	__attribute__((__symver__( #func "@Base" )))
+#  endif
+# endif
+#ifndef DM_EXPORT_NEW_SYMBOL
+#define DM_EXPORT_NEW_SYMBOL(rettype, func, ver) rettype func
 #define DM_EXPORT_SYMBOL(func, ver) \
-	__asm__(".symver " #func "_v" #ver ", " #func "@DM_" #ver )
+	__asm__(".symver " #func "_v" #ver ", " #func "@DM_" #ver );
 #define DM_EXPORT_SYMBOL_BASE(func) \
-	__asm__(".symver " #func "_base, " #func "@Base" )
+	__asm__(".symver " #func "_base, " #func "@Base" );
+#endif
 #else
+#define DM_EXPORT_NEW_SYMBOL(rettype, func, ver) rettype func
 #define DM_EXPORT_SYMBOL(func, ver)
 #define DM_EXPORT_SYMBOL_BASE(func)
 #endif


