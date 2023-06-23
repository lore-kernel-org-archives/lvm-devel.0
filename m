From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Jun 2023 16:09:41 +0000 (GMT)
Subject: main - thin: add cfg support for thin_restore and cache_restore
Message-ID: <20230623160941.52EF93858288@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fec3087eefc752036a40d854c373132d25ffd30f
Commit:        fec3087eefc752036a40d854c373132d25ffd30f
Parent:        8d09124c6204d49f6bda833229c96e8a76665127
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 23 14:39:44 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 23 18:06:22 2023 +0200

thin: add cfg support for thin_restore and cache_restore

Add configurable paths for thin_restore and cache_restore.
---
 lib/config/config_settings.h | 20 +++++++++++++++++++-
 lib/config/defaults.h        |  4 ++++
 2 files changed, 23 insertions(+), 1 deletion(-)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 2d6d957af..51e11857e 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -1177,7 +1177,7 @@ cfg(global_lvmlockctl_kill_command_CFG, "lvmlockctl_kill_command", global_CFG_SE
 
 cfg(global_thin_check_executable_CFG, "thin_check_executable", global_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, THIN_CHECK_CMD, vsn(2, 2, 94), "@THIN_CHECK_CMD@", 0, NULL,
 	"The full path to the thin_check command.\n"
-	"LVM uses this command to check that a thin metadata device is in a\n"
+	"LVM uses this command to check that a thin pool metadata device is in a\n"
 	"usable state. When a thin pool is activated and after it is\n"
 	"deactivated, this command is run. Activation will only proceed if\n"
 	"the command has an exit status of 0. Set to \"\" to skip this check.\n"
@@ -1195,6 +1195,12 @@ cfg(global_thin_repair_executable_CFG, "thin_repair_executable", global_CFG_SECT
 	"an unusable state. Also see thin_repair_options.\n"
 	"(See package device-mapper-persistent-data or thin-provisioning-tools)\n")
 
+cfg(global_thin_restore_executable_CFG, "thin_restore_executable", global_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, THIN_RESTORE_CMD, vsn(2, 3, 22), "@THIN_RESTORE_CMD@", 0, NULL,
+	"The full path to the thin_restore command.\n"
+	"LVM uses this command to restore generated data for a thin pool metadata device.\n"
+	"Also see thin_restore_options.\n"
+	"(See package device-mapper-persistent-data or thin-provisioning-tools)\n")
+
 cfg_array(global_thin_check_options_CFG, "thin_check_options", global_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_THIN_CHECK_OPTIONS_CONFIG, vsn(2, 2, 96), NULL, 0, NULL,
 	"List of options passed to the thin_check command.\n"
 	"With thin_check version 2.1 or newer you can add the option\n"
@@ -1205,6 +1211,9 @@ cfg_array(global_thin_check_options_CFG, "thin_check_options", global_CFG_SECTIO
 cfg_array(global_thin_repair_options_CFG, "thin_repair_options", global_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_THIN_REPAIR_OPTIONS_CONFIG, vsn(2, 2, 100), NULL, 0, NULL,
 	"List of options passed to the thin_repair command.\n")
 
+cfg_array(global_thin_restore_options_CFG, "thin_restore_options", global_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_THIN_RESTORE_OPTIONS_CONFIG, vsn(2, 3, 22), NULL, 0, NULL,
+	"List of options passed to the thin_restore command.\n")
+
 cfg_array(global_thin_disabled_features_CFG, "thin_disabled_features", global_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 99), NULL, 0, NULL,
 	"Features to not use in the thin driver.\n"
 	"This can be helpful for testing, or to avoid using a feature that is\n"
@@ -1245,6 +1254,12 @@ cfg(global_cache_repair_executable_CFG, "cache_repair_executable", global_CFG_SE
 	"an unusable state. Also see cache_repair_options.\n"
 	"(See package device-mapper-persistent-data or thin-provisioning-tools)\n")
 
+cfg(global_cache_restore_executable_CFG, "cache_restore_executable", global_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, CACHE_RESTORE_CMD, vsn(2, 3, 22), "@CACHE_RESTORE_CMD@", 0, NULL,
+	"The full path to the cache_restore command.\n"
+	"LVM uses this command to restore generated data for a cache metadata device.\n"
+	"Also see cache_restore_options.\n"
+	"(See package device-mapper-persistent-data or thin-provisioning-tools)\n")
+
 cfg_array(global_cache_check_options_CFG, "cache_check_options", global_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_CACHE_CHECK_OPTIONS_CONFIG, vsn(2, 2, 108), NULL, 0, NULL,
 	"List of options passed to the cache_check command.\n"
 	"With cache_check version 5.0 or newer you should include the option\n"
@@ -1253,6 +1268,9 @@ cfg_array(global_cache_check_options_CFG, "cache_check_options", global_CFG_SECT
 cfg_array(global_cache_repair_options_CFG, "cache_repair_options", global_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_CACHE_REPAIR_OPTIONS_CONFIG, vsn(2, 2, 108), NULL, 0, NULL,
 	"List of options passed to the cache_repair command.\n")
 
+cfg_array(global_cache_restore_options_CFG, "cache_restore_options", global_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_CACHE_RESTORE_OPTIONS_CONFIG, vsn(2, 3, 22), NULL, 0, NULL,
+	"List of options passed to the cache_restore command.\n")
+
 cfg(global_vdo_format_executable_CFG, "vdo_format_executable", global_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, VDO_FORMAT_CMD, VDO_1ST_VSN, "@VDO_FORMAT_CMD@", 0, NULL,
 	"The full path to the vdoformat command.\n"
 	"LVM uses this command to initial data volume for VDO type logical volume\n")
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 571054dc4..dd40ff3bf 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -117,6 +117,8 @@
 
 #define DEFAULT_THIN_REPAIR_OPTION1 ""
 #define DEFAULT_THIN_REPAIR_OPTIONS_CONFIG "#S" DEFAULT_THIN_REPAIR_OPTION1
+#define DEFAULT_THIN_RESTORE_OPTION1 ""
+#define DEFAULT_THIN_RESTORE_OPTIONS_CONFIG "#S" DEFAULT_THIN_RESTORE_OPTION1
 #define DEFAULT_THIN_POOL_METADATA_REQUIRE_SEPARATE_PVS 0
 #define DEFAULT_THIN_POOL_CROP_METADATA 0
 #define DEFAULT_THIN_POOL_MAX_METADATA_SIZE_V1_KB (UINT64_C(255) * ((1 << 14) - 64) * 4)  /* KB */ /* 0x3f8040 blocks */
@@ -145,6 +147,8 @@
 
 #define DEFAULT_CACHE_REPAIR_OPTION1 ""
 #define DEFAULT_CACHE_REPAIR_OPTIONS_CONFIG "#S" DEFAULT_CACHE_REPAIR_OPTION1
+#define DEFAULT_CACHE_RESTORE_OPTION1 ""
+#define DEFAULT_CACHE_RESTORE_OPTIONS_CONFIG "#S" DEFAULT_CACHE_RESTORE_OPTION1
 #define DEFAULT_CACHE_POOL_METADATA_REQUIRE_SEPARATE_PVS 0
 #define DEFAULT_CACHE_POOL_CHUNK_SIZE 64 /* KB */
 #define DEFAULT_CACHE_POOL_MAX_CHUNKS 1000000

