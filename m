From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 10 Mar 2017 13:36:56 -0500
Subject: master - libdm: maintain binary interface for new FEATURE flag
Message-ID: <201703101836.v2AIau3I004681@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bb20fac4ab65454dd4cabc90426546c25254d927
Commit:        bb20fac4ab65454dd4cabc90426546c25254d927
Parent:        ddd5a7680153486c4edebb8a7946827e7abe93a0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Feb 24 22:41:42 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 10 19:33:01 2017 +0100

libdm: maintain binary interface for new FEATURE flag

Older library version was not detecting unknown 'feature' bits
and could let start target without needed option.

New versioned symbol now checks for supported feature bits.
_Base version keeps accepting only previously known features and
mask/ignores unknown bits.

NB: if the older binary passed in 'random' bits, it will not get
metadata2 by chance. New linked binary get new validation function.
Library user is required to not pass 'trash' for unsupported bits,
as such calls will be rejected.
---
 WHATS_NEW_DM                        |    1 +
 libdm/.exported_symbols.Base        |    1 -
 libdm/.exported_symbols.DM_1_02_138 |    1 +
 libdm/libdm-deptree.c               |   49 ++++++++++++++++++++++++++++++++---
 4 files changed, 47 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 6a56b3d..91fd8f9 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.138 - 
 =====================================
+  Provide dm_tree_node_add_cache_target at base compatible symbol.
   Support DM_CACHE_FEATURE_METADATA2, new cache metadata format 2.
   Improve code to handle mode mask for cache nodes.
   Cache status check for passthrough also require trailing space.
diff --git a/libdm/.exported_symbols.Base b/libdm/.exported_symbols.Base
index ee7c4f2..4dc5c93 100644
--- a/libdm/.exported_symbols.Base
+++ b/libdm/.exported_symbols.Base
@@ -234,7 +234,6 @@ dm_tree_free
 dm_tree_get_cookie
 dm_tree_children_use_uuid
 dm_tree_next_child
-dm_tree_node_add_cache_target
 dm_tree_node_add_crypt_target
 dm_tree_node_add_error_target
 dm_tree_node_add_linear_target
diff --git a/libdm/.exported_symbols.DM_1_02_138 b/libdm/.exported_symbols.DM_1_02_138
index 0468294..21e9ad8 100644
--- a/libdm/.exported_symbols.DM_1_02_138
+++ b/libdm/.exported_symbols.DM_1_02_138
@@ -6,3 +6,4 @@ dm_bitset_parse_list
 dm_stats_bind_from_fd
 dm_stats_start_filemapd
 dm_tree_node_add_raid_target_with_params_v2
+dm_tree_node_add_cache_target
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index ea8d5ef..832d8de 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -4034,13 +4034,15 @@ void dm_tree_node_set_callback(struct dm_tree_node *dnode,
 	dnode->callback_data = data;
 }
 
+#if defined(__GNUC__)
 /*
- * Backward compatible dm_tree_node_size_changed() implementations.
+ * Backward compatible implementations.
  *
- * Keep these at the end of the file to avoid adding clutter around the
- * current dm_tree_node_size_changed() version.
+ * Keep these at the end of the file to make sure that
+ * no code in this file accidentally calls it.
  */
-#if defined(__GNUC__)
+
+/* Backward compatible dm_tree_node_size_changed() implementations. */
 int dm_tree_node_size_changed_base(const struct dm_tree_node *dnode);
 DM_EXPORT_SYMBOL_BASE(dm_tree_node_size_changed);
 int dm_tree_node_size_changed_base(const struct dm_tree_node *dnode)
@@ -4048,4 +4050,43 @@ int dm_tree_node_size_changed_base(const struct dm_tree_node *dnode)
 	/* Base does not make difference between smaller and bigger */
 	return dm_tree_node_size_changed(dnode) ? 1 : 0;
 }
+
+/*
+ * Retain ABI compatibility after adding the DM_CACHE_FEATURE_METADATA2
+ * in version 1.02.138.
+ *
+ * Binaries compiled against version 1.02.138 onwards will use
+ * the new function dm_tree_node_add_cache_target which detects unknown
+ * feature flags and returns error for them.
+ */
+int dm_tree_node_add_cache_target_base(struct dm_tree_node *node,
+				       uint64_t size,
+				       uint64_t feature_flags, /* DM_CACHE_FEATURE_* */
+				       const char *metadata_uuid,
+				       const char *data_uuid,
+				       const char *origin_uuid,
+				       const char *policy_name,
+				       const struct dm_config_node *policy_settings,
+				       uint32_t data_block_size);
+DM_EXPORT_SYMBOL_BASE(dm_tree_node_add_cache_target);
+int dm_tree_node_add_cache_target_base(struct dm_tree_node *node,
+				       uint64_t size,
+				       uint64_t feature_flags,
+				       const char *metadata_uuid,
+				       const char *data_uuid,
+				       const char *origin_uuid,
+				       const char *policy_name,
+				       const struct dm_config_node *policy_settings,
+				       uint32_t data_block_size)
+{
+	/* Old version supported only these FEATURE bits, others were ignored so masked them */
+	static const uint64_t _mask =
+		DM_CACHE_FEATURE_WRITEBACK |
+		DM_CACHE_FEATURE_WRITETHROUGH |
+		DM_CACHE_FEATURE_PASSTHROUGH;
+
+	return dm_tree_node_add_cache_target(node, size, feature_flags & _mask,
+					     metadata_uuid, data_uuid, origin_uuid,
+					     policy_name, policy_settings, data_block_size);
+}
 #endif


