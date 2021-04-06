From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  6 Apr 2021 20:07:20 +0000 (GMT)
Subject: main - symver: restore and uncomment some symbols
Message-ID: <20210406200720.843C13858012@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=60eb608d66c2056a78e81f27db3da14139d9faab
Commit:        60eb608d66c2056a78e81f27db3da14139d9faab
Parent:        c23f4c8075655aeaef96b3e19ad44c0be78020c9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Apr 3 21:51:06 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 6 21:26:57 2021 +0200

symver: restore and uncomment some symbols

---
 libdm/.exported_symbols.Base        | 2 ++
 libdm/.exported_symbols.DM_1_02_104 | 1 +
 libdm/.exported_symbols.DM_1_02_106 | 2 +-
 libdm/.exported_symbols.DM_1_02_129 | 2 +-
 4 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/libdm/.exported_symbols.Base b/libdm/.exported_symbols.Base
index 4dc5c936c..f6018ec84 100644
--- a/libdm/.exported_symbols.Base
+++ b/libdm/.exported_symbols.Base
@@ -183,6 +183,7 @@ dm_task_destroy
 dm_task_enable_checks
 dm_task_get_deps
 dm_task_get_driver_version
+dm_task_get_info
 dm_task_get_info_with_deferred_remove
 dm_task_get_message_response
 dm_task_get_name
@@ -234,6 +235,7 @@ dm_tree_free
 dm_tree_get_cookie
 dm_tree_children_use_uuid
 dm_tree_next_child
+dm_tree_node_add_cache_target
 dm_tree_node_add_crypt_target
 dm_tree_node_add_error_target
 dm_tree_node_add_linear_target
diff --git a/libdm/.exported_symbols.DM_1_02_104 b/libdm/.exported_symbols.DM_1_02_104
index f0a8ed9aa..712fcf2d5 100644
--- a/libdm/.exported_symbols.DM_1_02_104
+++ b/libdm/.exported_symbols.DM_1_02_104
@@ -6,6 +6,7 @@ dm_stats_bind_uuid
 dm_stats_buffer_destroy
 dm_stats_clear_region
 dm_stats_create
+dm_stats_create_region
 dm_stats_delete_region
 dm_stats_destroy
 dm_stats_get_area_start
diff --git a/libdm/.exported_symbols.DM_1_02_106 b/libdm/.exported_symbols.DM_1_02_106
index 88bba0225..0bec54428 100644
--- a/libdm/.exported_symbols.DM_1_02_106
+++ b/libdm/.exported_symbols.DM_1_02_106
@@ -1,5 +1,5 @@
 dm_message_supports_precise_timestamps
-#dm_stats_create_region
+dm_stats_create_region
 dm_stats_driver_supports_precise
 dm_stats_get_current_region_precise_timestamps
 dm_stats_get_region_precise_timestamps
diff --git a/libdm/.exported_symbols.DM_1_02_129 b/libdm/.exported_symbols.DM_1_02_129
index a5133ddb0..88d3f1b6b 100644
--- a/libdm/.exported_symbols.DM_1_02_129
+++ b/libdm/.exported_symbols.DM_1_02_129
@@ -1,4 +1,4 @@
-#dm_bitset_parse_list
+dm_bitset_parse_list
 dm_stats_create_group
 dm_stats_current_object_type
 dm_stats_delete_group


