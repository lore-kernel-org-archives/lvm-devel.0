From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 20 May 2014 14:28:49 +0000 (UTC)
Subject: master - config: add CFG_PROFILABLE_METADATA flag
Message-ID: <20140520142849.B7E676011B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c5fbd2c59f1248b1315aae71dee032878d8476f8
Commit:        c5fbd2c59f1248b1315aae71dee032878d8476f8
Parent:        22cab9c481c853cb58aef4b5836f74b3ddfd586c
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon May 19 16:29:50 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon May 19 16:31:15 2014 +0200

config: add CFG_PROFILABLE_METADATA flag

Mark profilable settings with a separate CFG_PROFILABLE_METADATA
flag where the profile can be attached to VG/LV. This makes it possible
to differentiate global command-profilable settings (CFG_PROFILABLE flag)
and contextual metadata-profilable (per VG/LV) settings (CFG_PROFILABLE_METADATA flag).
---
 lib/config/config.h          |    8 ++++++--
 lib/config/config_settings.h |   13 +++++++------
 2 files changed, 13 insertions(+), 8 deletions(-)

diff --git a/lib/config/config.h b/lib/config/config.h
index df5841c..f06fb68 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -97,10 +97,14 @@ typedef union {
 #define CFG_UNSUPPORTED		0x08
 /* whether the configuration item is customizable by a profile */
 #define CFG_PROFILABLE		0x10
+/* whether the configuration item is customizable by a profile */
+/* and whether it can be attached to VG/LV metadata at the same time
+ * The CFG_PROFILABLE_METADATA flag incorporates CFG_PROFILABLE flag!!! */
+#define CFG_PROFILABLE_METADATA 0x30
 /* whether the default value is undefned */
-#define CFG_DEFAULT_UNDEFINED	0x20
+#define CFG_DEFAULT_UNDEFINED	0x40
 /* whether the defualt value is calculated during run time */
-#define CFG_DEFAULT_RUN_TIME	0x40
+#define CFG_DEFAULT_RUN_TIME	0x80
 
 /* configuration definition item structure */
 typedef struct cfg_def_item {
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 3792238..d277e0e 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -41,6 +41,7 @@
  * 				CFG_ADVANCED - this node belongs to advanced config set
  * 				CFG_UNSUPPORTED - this node belongs to unsupported config set
  * 				CFG_PROFILABLE - this node is customizable by a profile
+ * 				CFG_PROFILABLE_METADATA - profilable and attachable to VG/LV metadata
  * 				CFG_DEFAULT_UNDEFINED - node's default value is undefined
  * type:		allowed type for the value of simple configuation setting, one of:
  * 				CFG_TYPE_BOOL
@@ -121,10 +122,10 @@ cfg(allocation_mirror_logs_require_separate_pvs_CFG, "mirror_logs_require_separa
 cfg(allocation_cache_pool_metadata_require_separate_pvs_CFG, "cache_pool_metadata_require_separate_pvs", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_CACHE_POOL_METADATA_REQUIRE_SEPARATE_PVS, vsn(2, 2, 106), NULL)
 cfg_runtime(allocation_cache_pool_chunk_size_CFG, "cache_pool_chunk_size", allocation_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_INT, vsn(2, 2, 106), NULL)
 cfg(allocation_thin_pool_metadata_require_separate_pvs_CFG, "thin_pool_metadata_require_separate_pvs", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_THIN_POOL_METADATA_REQUIRE_SEPARATE_PVS, vsn(2, 2, 89), NULL)
-cfg(allocation_thin_pool_zero_CFG, "thin_pool_zero", allocation_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_THIN_POOL_ZERO, vsn(2, 2, 99), NULL)
-cfg(allocation_thin_pool_discards_CFG, "thin_pool_discards", allocation_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_THIN_POOL_DISCARDS, vsn(2, 2, 99), NULL)
-cfg(allocation_thin_pool_chunk_size_policy_CFG, "thin_pool_chunk_size_policy", allocation_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_THIN_POOL_CHUNK_SIZE_POLICY, vsn(2, 2, 101), NULL)
-cfg_runtime(allocation_thin_pool_chunk_size_CFG, "thin_pool_chunk_size", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_UNDEFINED, CFG_TYPE_INT, vsn(2, 2, 99), NULL)
+cfg(allocation_thin_pool_zero_CFG, "thin_pool_zero", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA, CFG_TYPE_BOOL, DEFAULT_THIN_POOL_ZERO, vsn(2, 2, 99), NULL)
+cfg(allocation_thin_pool_discards_CFG, "thin_pool_discards", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA, CFG_TYPE_STRING, DEFAULT_THIN_POOL_DISCARDS, vsn(2, 2, 99), NULL)
+cfg(allocation_thin_pool_chunk_size_policy_CFG, "thin_pool_chunk_size_policy", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA, CFG_TYPE_STRING, DEFAULT_THIN_POOL_CHUNK_SIZE_POLICY, vsn(2, 2, 101), NULL)
+cfg_runtime(allocation_thin_pool_chunk_size_CFG, "thin_pool_chunk_size", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_UNDEFINED, CFG_TYPE_INT, vsn(2, 2, 99), NULL)
 
 
 cfg(log_verbose_CFG, "verbose", log_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_VERBOSE, vsn(1, 0, 0), NULL)
@@ -204,8 +205,8 @@ cfg(activation_mirror_log_fault_policy_CFG, "mirror_log_fault_policy", activatio
 cfg_runtime(activation_mirror_image_fault_policy_CFG, "mirror_image_fault_policy", activation_CFG_SECTION, 0, CFG_TYPE_STRING, vsn(2, 2, 57), NULL)
 cfg(activation_snapshot_autoextend_threshold_CFG, "snapshot_autoextend_threshold", activation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_SNAPSHOT_AUTOEXTEND_THRESHOLD, vsn(2, 2, 75), NULL)
 cfg(activation_snapshot_autoextend_percent_CFG, "snapshot_autoextend_percent", activation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_SNAPSHOT_AUTOEXTEND_PERCENT, vsn(2, 2, 75), NULL)
-cfg(activation_thin_pool_autoextend_threshold_CFG, "thin_pool_autoextend_threshold", activation_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_INT, DEFAULT_THIN_POOL_AUTOEXTEND_THRESHOLD, vsn(2, 2, 89), NULL)
-cfg(activation_thin_pool_autoextend_percent_CFG, "thin_pool_autoextend_percent", activation_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_INT, DEFAULT_THIN_POOL_AUTOEXTEND_PERCENT, vsn(2, 2, 89), NULL)
+cfg(activation_thin_pool_autoextend_threshold_CFG, "thin_pool_autoextend_threshold", activation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA, CFG_TYPE_INT, DEFAULT_THIN_POOL_AUTOEXTEND_THRESHOLD, vsn(2, 2, 89), NULL)
+cfg(activation_thin_pool_autoextend_percent_CFG, "thin_pool_autoextend_percent", activation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA, CFG_TYPE_INT, DEFAULT_THIN_POOL_AUTOEXTEND_PERCENT, vsn(2, 2, 89), NULL)
 cfg_array(activation_mlock_filter_CFG, "mlock_filter", activation_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 62), NULL)
 cfg(activation_use_mlockall_CFG, "use_mlockall", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_USE_MLOCKALL, vsn(2, 2, 62), NULL)
 cfg(activation_monitoring_CFG, "monitoring", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_DMEVENTD_MONITOR, vsn(2, 2, 63), NULL)


