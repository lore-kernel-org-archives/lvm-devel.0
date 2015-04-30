From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 30 Apr 2015 13:40:35 +0000 (UTC)
Subject: master - config: preparation for marking configuration nodes as deprecated
Message-ID: <20150430134035.63D156104D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b769183a98ca942c8252c8571241ac62d7476a26
Commit:        b769183a98ca942c8252c8571241ac62d7476a26
Parent:        9c39d635b62aa4f27e3f9ff31f171e501bb8a874
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Apr 30 15:34:07 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Apr 30 15:39:34 2015 +0200

config: preparation for marking configuration nodes as deprecated

A preparatory code for marking configuration nodes as deprecated:
  - struct cfg_def_item gains 2 new fields ("deprecated_since_version" and "deprecation_comment"
  - cfg* macros to handle new fields
  - related config_settings.h edits to add new fields for each item (null for all at the moment)

Patch with implementation will follow...
---
 lib/config/config.c          |   10 +-
 lib/config/config.h          |   12 +-
 lib/config/config_settings.h |  412 +++++++++++++++++++++---------------------
 3 files changed, 221 insertions(+), 213 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index bab7f8b..41f13a0 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -65,11 +65,11 @@ struct config_source {
  * Map each ID to respective definition of the configuration item.
  */
 static struct cfg_def_item _cfg_def_items[CFG_COUNT + 1] = {
-#define cfg_section(id, name, parent, flags, since_version, comment) {id, parent, name, CFG_TYPE_SECTION, {0}, flags, since_version, {0}, comment},
-#define cfg(id, name, parent, flags, type, default_value, since_version, unconfigured_value, comment) {id, parent, name, type, {.v_##type = default_value}, flags, since_version, {.v_UNCONFIGURED = unconfigured_value}, comment},
-#define cfg_runtime(id, name, parent, flags, type, since_version, comment) {id, parent, name, type, {.fn_##type = get_default_##id}, flags | CFG_DEFAULT_RUN_TIME, since_version, {.fn_UNCONFIGURED = get_default_unconfigured_##id}, comment},
-#define cfg_array(id, name, parent, flags, types, default_value, since_version, unconfigured_value, comment) {id, parent, name, CFG_TYPE_ARRAY | types, {.v_CFG_TYPE_STRING = default_value}, flags, since_version, {.v_UNCONFIGURED = unconfigured_value}, comment},
-#define cfg_array_runtime(id, name, parent, flags, types, since_version, comment) {id, parent, name, CFG_TYPE_ARRAY | types, {.fn_CFG_TYPE_STRING = get_default_##id}, flags | CFG_DEFAULT_RUN_TIME, since_version, {.fn_UNCONFIGURED = get_default_unconfigured_##id}, comment},
+#define cfg_section(id, name, parent, flags, since_version, deprecated_since_version, deprecation_comment, comment) {id, parent, name, CFG_TYPE_SECTION, {0}, flags, since_version, {0}, deprecated_since_version, deprecation_comment, comment},
+#define cfg(id, name, parent, flags, type, default_value, since_version, unconfigured_value, deprecated_since_version, deprecation_comment, comment) {id, parent, name, type, {.v_##type = default_value}, flags, since_version, {.v_UNCONFIGURED = unconfigured_value}, deprecated_since_version, deprecation_comment, comment},
+#define cfg_runtime(id, name, parent, flags, type, since_version, deprecated_since_version, deprecation_comment, comment) {id, parent, name, type, {.fn_##type = get_default_##id}, flags | CFG_DEFAULT_RUN_TIME, since_version, {.fn_UNCONFIGURED = get_default_unconfigured_##id}, deprecated_since_version, deprecation_comment, comment},
+#define cfg_array(id, name, parent, flags, types, default_value, since_version, unconfigured_value, deprecated_since_version, deprecation_comment, comment) {id, parent, name, CFG_TYPE_ARRAY | types, {.v_CFG_TYPE_STRING = default_value}, flags, since_version, {.v_UNCONFIGURED = unconfigured_value}, deprecated_since_version, deprecation_comment, comment},
+#define cfg_array_runtime(id, name, parent, flags, types, since_version, deprecated_since_version, deprecation_comment, comment) {id, parent, name, CFG_TYPE_ARRAY | types, {.fn_CFG_TYPE_STRING = get_default_##id}, flags | CFG_DEFAULT_RUN_TIME, since_version, {.fn_UNCONFIGURED = get_default_unconfigured_##id}, deprecated_since_version, deprecation_comment, comment},
 #include "config_settings.h"
 #undef cfg_section
 #undef cfg
diff --git a/lib/config/config.h b/lib/config/config.h
index 892529d..c21a61b 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -128,6 +128,8 @@ typedef struct cfg_def_item {
 	uint16_t flags;							/* configuration item definition flags */
 	uint16_t since_version;						/* version this item appeared in */
 	cfg_def_unconfigured_value_t default_unconfigured_value;	/* default value in terms of @FOO@, pre-configured (only for settings) */
+	uint16_t deprecated_since_version;				/* version since this item is deprecated */
+	const char *deprecation_comment;				/* comment about reasons for deprecation and settings that supersede this one */
 	const char *comment;						/* comment */
 } cfg_def_item_t;
 
@@ -172,11 +174,11 @@ struct config_def_tree_spec {
  * Register ID for each possible item in the configuration tree.
  */
 enum {
-#define cfg_section(id, name, parent, flags, since_version, comment) id,
-#define cfg(id, name, parent, flags, type, default_value, since_version, unconfigured_value, comment) id,
-#define cfg_runtime(id, name, parent, flags, type, since_version, comment) id,
-#define cfg_array(id, name, parent, flags, types, default_value, since_version, unconfigured_value, comment) id,
-#define cfg_array_runtime(id, name, parent, flags, types, since_version, comment) id,
+#define cfg_section(id, name, parent, flags, since_version, deprecated_since_version, deprecation_comment, comment) id,
+#define cfg(id, name, parent, flags, type, default_value, since_version, unconfigured_value, deprecated_since_version, deprecation_comment, comment) id,
+#define cfg_runtime(id, name, parent, flags, type, since_version, deprecated_since_version, deprecation_comment, comment) id,
+#define cfg_array(id, name, parent, flags, types, default_value, since_version, unconfigured_value, deprecated_since_version, deprecation_comment, comment) id,
+#define cfg_array_runtime(id, name, parent, flags, types, since_version, deprecated_since_version, deprecation_comment, comment) id,
 #include "config_settings.h"
 #undef cfg_section
 #undef cfg
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index b496071..bece635 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -15,13 +15,13 @@
 /*
  * MACROS:
  * - define a configuration section:
- *   cfg_section(id, name, parent, flags, since_version, comment)
+ *   cfg_section(id, name, parent, flags, since_version, deprecated_since_version, deprecation_comment, comment)
  *
  * - define a configuration setting of simple type:
- *   cfg(id, name, parent, flags, type, default_value, since_version, unconfigured_default_value, comment)
+ *   cfg(id, name, parent, flags, type, default_value, since_version, unconfigured_default_value, deprecated_since_version, deprecation_comment, comment)
  *
  * - define a configuration array of one or more types:
- *   cfg_array(id, name, parent, flags, types, default_value, since_version, unconfigured_default_value, comment)
+ *   cfg_array(id, name, parent, flags, types, default_value, since_version, unconfigured_default_value, deprecated_since_version, deprecation_comment, comment)
  *
 *
  * If default value can't be assigned statically because it depends on some
@@ -83,55 +83,61 @@
  *                             while running configure.
  *                             (see also 'lvmconfig --type default --unconfigured')
  *
+ * deprecated_since_version:   The version since this configuration node is deprecated.
+ *
+ * deprecation_comment:        Comment about deprecation reason and related info (e.g. which
+ *                             configuration is used now instead).
+ *
  * comment:                    Comment used in configuration dumps. The very first line is the
  *                             summarizing comment.
  *                             (see also lvmconfig ... --withcomments and --withsummary)
  */
 #include "defaults.h"
 
-cfg_section(root_CFG_SECTION, "(root)", root_CFG_SECTION, 0, vsn(0, 0, 0), NULL)
+cfg_section(root_CFG_SECTION, "(root)", root_CFG_SECTION, 0, vsn(0, 0, 0), 0, NULL, NULL)
 
-cfg_section(config_CFG_SECTION, "config", root_CFG_SECTION, 0, vsn(2, 2, 99),
+cfg_section(config_CFG_SECTION, "config", root_CFG_SECTION, 0, vsn(2, 2, 99), 0, NULL,
 	"How LVM configuration settings are handled.\n")
 
-cfg_section(devices_CFG_SECTION, "devices", root_CFG_SECTION, 0, vsn(1, 0, 0),
+cfg_section(devices_CFG_SECTION, "devices", root_CFG_SECTION, 0, vsn(1, 0, 0), 0, NULL,
 	"How LVM uses block devices.\n")
 
-cfg_section(allocation_CFG_SECTION, "allocation", root_CFG_SECTION, CFG_PROFILABLE, vsn(2, 2, 77),
+cfg_section(allocation_CFG_SECTION, "allocation", root_CFG_SECTION, CFG_PROFILABLE, vsn(2, 2, 77), 0, NULL,
 	"How LVM selects free space for Logical Volumes.\n")
 
-cfg_section(log_CFG_SECTION, "log", root_CFG_SECTION, 0, vsn(1, 0, 0),
+cfg_section(log_CFG_SECTION, "log", root_CFG_SECTION, 0, vsn(1, 0, 0), 0, NULL,
 	"How LVM log information is reported.\n")
 
-cfg_section(backup_CFG_SECTION, "backup", root_CFG_SECTION, 0, vsn(1, 0, 0),
+cfg_section(backup_CFG_SECTION, "backup", root_CFG_SECTION, 0, vsn(1, 0, 0), 0, NULL,
 	"How LVM metadata is backed up and archived.\n"
 	"In LVM, a 'backup' is a copy of the metadata for the\n"
 	"current system, and an 'archive' contains old metadata\n"
 	"configurations. They are stored in a human readable\n"
 	"text format.\n")
 
-cfg_section(shell_CFG_SECTION, "shell", root_CFG_SECTION, 0, vsn(1, 0, 0),
+cfg_section(shell_CFG_SECTION, "shell", root_CFG_SECTION, 0, vsn(1, 0, 0), 0, NULL,
 	"Settings for running LVM in shell (readline) mode.\n")
 
-cfg_section(global_CFG_SECTION, "global", root_CFG_SECTION, CFG_PROFILABLE, vsn(1, 0, 0),
+cfg_section(global_CFG_SECTION, "global", root_CFG_SECTION, CFG_PROFILABLE, vsn(1, 0, 0), 0, NULL,
 	"Miscellaneous global LVM settings.\n")
 
-cfg_section(activation_CFG_SECTION, "activation", root_CFG_SECTION, CFG_PROFILABLE, vsn(1, 0, 0), NULL)
-cfg_section(metadata_CFG_SECTION, "metadata", root_CFG_SECTION, 0, vsn(1, 0, 0), NULL)
+cfg_section(activation_CFG_SECTION, "activation", root_CFG_SECTION, CFG_PROFILABLE, vsn(1, 0, 0), 0, NULL, NULL)
+
+cfg_section(metadata_CFG_SECTION, "metadata", root_CFG_SECTION, 0, vsn(1, 0, 0), 0, NULL, NULL)
 
-cfg_section(report_CFG_SECTION, "report", root_CFG_SECTION, CFG_PROFILABLE, vsn(1, 0, 0),
+cfg_section(report_CFG_SECTION, "report", root_CFG_SECTION, CFG_PROFILABLE, vsn(1, 0, 0), 0, NULL,
 	"LVM report command output formatting.\n")
 
-cfg_section(dmeventd_CFG_SECTION, "dmeventd", root_CFG_SECTION, 0, vsn(1, 2, 3),
+cfg_section(dmeventd_CFG_SECTION, "dmeventd", root_CFG_SECTION, 0, vsn(1, 2, 3), 0, NULL,
 	"Settings for the LVM event daemon.\n")
 
-cfg_section(tags_CFG_SECTION, "tags", root_CFG_SECTION, 0, vsn(1, 0, 18),
+cfg_section(tags_CFG_SECTION, "tags", root_CFG_SECTION, 0, vsn(1, 0, 18), 0, NULL,
 	"Host tag settings.\n")
 
-cfg_section(local_CFG_SECTION, "local", root_CFG_SECTION, 0, vsn(2, 2, 117),
+cfg_section(local_CFG_SECTION, "local", root_CFG_SECTION, 0, vsn(2, 2, 117), 0, NULL,
 	"LVM settings that are specific to the local host.\n")
 
-cfg(config_checks_CFG, "checks", config_CFG_SECTION, 0, CFG_TYPE_BOOL, 1, vsn(2, 2, 99), NULL,
+cfg(config_checks_CFG, "checks", config_CFG_SECTION, 0, CFG_TYPE_BOOL, 1, vsn(2, 2, 99), NULL, 0, NULL,
 	"If enabled, any LVM configuration mismatch is reported.\n"
 	"This implies checking that the configuration key is understood\n"
 	"by LVM and that the value of the key is the proper type.\n"
@@ -139,22 +145,22 @@ cfg(config_checks_CFG, "checks", config_CFG_SECTION, 0, CFG_TYPE_BOOL, 1, vsn(2,
 	"value is used without any warning (a message about the\n"
 	"configuration key not being found is issued in verbose mode only).\n")
 
-cfg(config_abort_on_errors_CFG, "abort_on_errors", config_CFG_SECTION, 0, CFG_TYPE_BOOL, 0, vsn(2,2,99), NULL,
+cfg(config_abort_on_errors_CFG, "abort_on_errors", config_CFG_SECTION, 0, CFG_TYPE_BOOL, 0, vsn(2,2,99), NULL, 0, NULL,
 	"Abort the LVM process if a configuration mismatch is found.\n")
 
-cfg_runtime(config_profile_dir_CFG, "profile_dir", config_CFG_SECTION, 0, CFG_TYPE_STRING, vsn(2, 2, 99),
+cfg_runtime(config_profile_dir_CFG, "profile_dir", config_CFG_SECTION, 0, CFG_TYPE_STRING, vsn(2, 2, 99), 0, NULL,
 	"Directory where LVM looks for configuration profiles.\n")
 
-cfg(devices_dir_CFG, "dir", devices_CFG_SECTION, CFG_ADVANCED, CFG_TYPE_STRING, DEFAULT_DEV_DIR, vsn(1, 0, 0), NULL,
+cfg(devices_dir_CFG, "dir", devices_CFG_SECTION, CFG_ADVANCED, CFG_TYPE_STRING, DEFAULT_DEV_DIR, vsn(1, 0, 0), NULL, 0, NULL,
 	"Directory in which to create volume group device nodes.\n"
 	"Commands also accept this as a prefix on volume group names.\n")
 
-cfg_array(devices_scan_CFG, "scan", devices_CFG_SECTION, CFG_ADVANCED, CFG_TYPE_STRING, "#S/dev", vsn(1, 0, 0), NULL,
+cfg_array(devices_scan_CFG, "scan", devices_CFG_SECTION, CFG_ADVANCED, CFG_TYPE_STRING, "#S/dev", vsn(1, 0, 0), NULL, 0, NULL,
 	"Directories containing device nodes to use with LVM.\n")
 
-cfg_array(devices_loopfiles_CFG, "loopfiles", devices_CFG_SECTION, CFG_DEFAULT_UNDEFINED | CFG_UNSUPPORTED, CFG_TYPE_STRING, NULL, vsn(1, 2, 0), NULL, NULL)
+cfg_array(devices_loopfiles_CFG, "loopfiles", devices_CFG_SECTION, CFG_DEFAULT_UNDEFINED | CFG_UNSUPPORTED, CFG_TYPE_STRING, NULL, vsn(1, 2, 0), NULL, 0, NULL, NULL)
 
-cfg(devices_obtain_device_list_from_udev_CFG, "obtain_device_list_from_udev", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_OBTAIN_DEVICE_LIST_FROM_UDEV, vsn(2, 2, 85), NULL,
+cfg(devices_obtain_device_list_from_udev_CFG, "obtain_device_list_from_udev", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_OBTAIN_DEVICE_LIST_FROM_UDEV, vsn(2, 2, 85), NULL, 0, NULL,
 	"Obtain the list of available devices from udev.\n"
 	"This avoids opening or using any inapplicable non-block\n"
 	"devices or subdirectories found in the udev directory.\n"
@@ -164,7 +170,7 @@ cfg(devices_obtain_device_list_from_udev_CFG, "obtain_device_list_from_udev", de
 	"scanned fully. LVM needs to be compiled with udev support\n"
 	"for this setting to apply.\n")
 
-cfg(devices_external_device_info_source_CFG, "external_device_info_source", devices_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_EXTERNAL_DEVICE_INFO_SOURCE, vsn(2, 2, 116), NULL,
+cfg(devices_external_device_info_source_CFG, "external_device_info_source", devices_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_EXTERNAL_DEVICE_INFO_SOURCE, vsn(2, 2, 116), NULL, 0, NULL,
 	"Select an external device information source.\n"
 	"Some information may already be available in the system and\n"
 	"LVM can use this information to determine the exact type\n"
@@ -179,7 +185,7 @@ cfg(devices_external_device_info_source_CFG, "external_device_info_source", devi
 	"udev - Reuse existing udev database records. Applicable\n"
 	"only if LVM is compiled with udev support.\n")
 
-cfg_array(devices_preferred_names_CFG, "preferred_names", devices_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 2, 19), NULL,
+cfg_array(devices_preferred_names_CFG, "preferred_names", devices_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 2, 19), NULL, 0, NULL,
 	"Select which path name to display for a block device.\n"
 	"If multiple path names exist for a block device,\n"
 	"and LVM needs to display a name for the device,\n"
@@ -196,7 +202,7 @@ cfg_array(devices_preferred_names_CFG, "preferred_names", devices_CFG_SECTION, C
 	"Example:\n"
 	"preferred_names = [ \"^/dev/mpath/\", \"^/dev/mapper/mpath\", \"^/dev/[hs]d\" ]\n")
 
-cfg_array(devices_filter_CFG, "filter", devices_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL,
+cfg_array(devices_filter_CFG, "filter", devices_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL, 0, NULL,
 	"Limit the block devices that are used by LVM commands.\n"
 	"This is a list of regular expressions used to accept or\n"
 	"reject block device path names.  Each regex is delimited\n"
@@ -231,7 +237,7 @@ cfg_array(devices_filter_CFG, "filter", devices_CFG_SECTION, CFG_DEFAULT_UNDEFIN
 	"Use anchors to be very specific.\n"
 	"filter = [ \"a|^/dev/hda8$|\", \"r|.*/|\" ]\n")
 
-cfg_array(devices_global_filter_CFG, "global_filter", devices_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 98), NULL,
+cfg_array(devices_global_filter_CFG, "global_filter", devices_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 98), NULL, 0, NULL,
 	"Limit the block devices that are used by LVM system components.\n"
 	"Because devices/filter may be overridden from the command line,\n"
 	"it is not suitable for system-wide device filtering, e.g. udev\n"
@@ -239,10 +245,10 @@ cfg_array(devices_global_filter_CFG, "global_filter", devices_CFG_SECTION, CFG_D
 	"system components. The syntax is the same as devices/filter.\n"
 	"Devices rejected by global_filter are not opened by LVM.\n")
 
-cfg_runtime(devices_cache_CFG, "cache", devices_CFG_SECTION, 0, CFG_TYPE_STRING, vsn(1, 0, 0),
+cfg_runtime(devices_cache_CFG, "cache", devices_CFG_SECTION, 0, CFG_TYPE_STRING, vsn(1, 0, 0), 0, NULL,
 	"The path can be set using the devices/cache_dir setting.\n")
 
-cfg_runtime(devices_cache_dir_CFG, "cache_dir", devices_CFG_SECTION, 0, CFG_TYPE_STRING, vsn(1, 2, 19),
+cfg_runtime(devices_cache_dir_CFG, "cache_dir", devices_CFG_SECTION, 0, CFG_TYPE_STRING, vsn(1, 2, 19), 0, NULL,
 	"Directory in which to store the device cache file.\n"
 	"The results of filtering are cached on disk to avoid\n"
 	"rescanning dud devices (which can take a very long time).\n"
@@ -251,46 +257,46 @@ cfg_runtime(devices_cache_dir_CFG, "cache_dir", devices_CFG_SECTION, 0, CFG_TYPE
 	"If obtain_device_list_from_udev is enabled, the list of devices\n"
 	"is obtained from udev and any existing .cache file is removed.\n")
 
-cfg(devices_cache_file_prefix_CFG, "cache_file_prefix", devices_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, DEFAULT_CACHE_FILE_PREFIX, vsn(1, 2, 19), NULL,
+cfg(devices_cache_file_prefix_CFG, "cache_file_prefix", devices_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, DEFAULT_CACHE_FILE_PREFIX, vsn(1, 2, 19), NULL, 0, NULL,
 	"A prefix used before the .cache file name. See devices/cache_dir.\n")
 
-cfg(devices_write_cache_state_CFG, "write_cache_state", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, 1, vsn(1, 0, 0), NULL,
+cfg(devices_write_cache_state_CFG, "write_cache_state", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, 1, vsn(1, 0, 0), NULL, 0, NULL,
 	"Enable/disable writing the cache file. See devices/cache_dir.\n")
 
-cfg_array(devices_types_CFG, "types", devices_CFG_SECTION, CFG_DEFAULT_UNDEFINED | CFG_ADVANCED, CFG_TYPE_INT | CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL,
+cfg_array(devices_types_CFG, "types", devices_CFG_SECTION, CFG_DEFAULT_UNDEFINED | CFG_ADVANCED, CFG_TYPE_INT | CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL, 0, NULL,
 	"List of additional acceptable block device types.\n"
 	"These are of device type names from /proc/devices,\n"
 	"followed by the maximum number of partitions.\n"
 	"Example:\n"
 	"types = [ \"fd\", 16 ]\n")
 
-cfg(devices_sysfs_scan_CFG, "sysfs_scan", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_SYSFS_SCAN, vsn(1, 0, 8), NULL,
+cfg(devices_sysfs_scan_CFG, "sysfs_scan", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_SYSFS_SCAN, vsn(1, 0, 8), NULL, 0, NULL,
 	"Restrict device scanning to block devices appearing in sysfs.\n"
 	"This is a quick way of filtering out block devices that are\n"
 	"not present on the system. sysfs must be part of the kernel\n"
 	"and mounted.)\n")
 
-cfg(devices_multipath_component_detection_CFG, "multipath_component_detection", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_MULTIPATH_COMPONENT_DETECTION, vsn(2, 2, 89), NULL,
+cfg(devices_multipath_component_detection_CFG, "multipath_component_detection", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_MULTIPATH_COMPONENT_DETECTION, vsn(2, 2, 89), NULL, 0, NULL,
 	"Ignore devices that are components of DM multipath devices.\n")
 
-cfg(devices_md_component_detection_CFG, "md_component_detection", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_MD_COMPONENT_DETECTION, vsn(1, 0, 18), NULL,
+cfg(devices_md_component_detection_CFG, "md_component_detection", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_MD_COMPONENT_DETECTION, vsn(1, 0, 18), NULL, 0, NULL,
 	"Ignore devices that are components of software RAID (md) devices.\n")
 
-cfg(devices_fw_raid_component_detection_CFG, "fw_raid_component_detection", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_FW_RAID_COMPONENT_DETECTION, vsn(2, 2, 112), NULL,
+cfg(devices_fw_raid_component_detection_CFG, "fw_raid_component_detection", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_FW_RAID_COMPONENT_DETECTION, vsn(2, 2, 112), NULL, 0, NULL,
 	"Ignore devices that are components of firmware RAID devices.\n"
 	"LVM must use an external_device_info_source other than none\n"
 	"for this detection to execute.\n")
 
-cfg(devices_md_chunk_alignment_CFG, "md_chunk_alignment", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_MD_CHUNK_ALIGNMENT, vsn(2, 2, 48), NULL,
+cfg(devices_md_chunk_alignment_CFG, "md_chunk_alignment", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_MD_CHUNK_ALIGNMENT, vsn(2, 2, 48), NULL, 0, NULL,
 	"Align PV data blocks with md device's stripe-width.\n"
 	"This applies if a PV is placed directly on an md device.\n")
 
-cfg(devices_default_data_alignment_CFG, "default_data_alignment", devices_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_DATA_ALIGNMENT, vsn(2, 2, 75), NULL,
+cfg(devices_default_data_alignment_CFG, "default_data_alignment", devices_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_DATA_ALIGNMENT, vsn(2, 2, 75), NULL, 0, NULL,
 	"Default alignment of the start of a PV data area in MB.\n"
 	"If set to 0, a value of 64KB will be used.\n"
 	"Set to 1 for 1MiB, 2 for 2MiB, etc.\n")
 
-cfg(devices_data_alignment_detection_CFG, "data_alignment_detection", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_DATA_ALIGNMENT_DETECTION, vsn(2, 2, 51), NULL,
+cfg(devices_data_alignment_detection_CFG, "data_alignment_detection", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_DATA_ALIGNMENT_DETECTION, vsn(2, 2, 51), NULL, 0, NULL,
 	"Detect PV data alignment based on sysfs device information.\n"
 	"The start of a PV data area will be a multiple of\n"
 	"minimum_io_size or optimal_io_size exposed in sysfs.\n"
@@ -302,7 +308,7 @@ cfg(devices_data_alignment_detection_CFG, "data_alignment_detection", devices_CF
 	"If md_chunk_alignment is enabled, that detects the optimal_io_size.\n"
 	"This setting takes precedence over md_chunk_alignment.\n")
 
-cfg(devices_data_alignment_CFG, "data_alignment", devices_CFG_SECTION, 0, CFG_TYPE_INT, 0, vsn(2, 2, 45), NULL,
+cfg(devices_data_alignment_CFG, "data_alignment", devices_CFG_SECTION, 0, CFG_TYPE_INT, 0, vsn(2, 2, 45), NULL, 0, NULL,
 	"Alignment of the start of a PV data area in KB.\n"
 	"If a PV is placed directly on an md device and\n"
 	"md_chunk_alignment or data_alignment_detection are enabled,\n"
@@ -310,7 +316,7 @@ cfg(devices_data_alignment_CFG, "data_alignment", devices_CFG_SECTION, 0, CFG_TY
 	"and data_alignment_detection are disabled if this is set.\n"
 	"Set to 0 to use the default alignment or the page size, if larger.\n")
 
-cfg(devices_data_alignment_offset_detection_CFG, "data_alignment_offset_detection", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_DATA_ALIGNMENT_OFFSET_DETECTION, vsn(2, 2, 50), NULL,
+cfg(devices_data_alignment_offset_detection_CFG, "data_alignment_offset_detection", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_DATA_ALIGNMENT_OFFSET_DETECTION, vsn(2, 2, 50), NULL, 0, NULL,
 	"Detect PV data alignment offset based on sysfs device information.\n"
 	"The start of a PV aligned data area will be shifted by the\n"
 	"alignment_offset exposed in sysfs.  This offset is often 0, but\n"
@@ -320,12 +326,12 @@ cfg(devices_data_alignment_offset_detection_CFG, "data_alignment_offset_detectio
 	"at LBA -1, and consequently sector 63 is aligned on a 4KB boundary).\n"
 	"pvcreate --dataalignmentoffset will skip this detection.\n")
 
-cfg(devices_ignore_suspended_devices_CFG, "ignore_suspended_devices", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_IGNORE_SUSPENDED_DEVICES, vsn(1, 2, 19), NULL,
+cfg(devices_ignore_suspended_devices_CFG, "ignore_suspended_devices", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_IGNORE_SUSPENDED_DEVICES, vsn(1, 2, 19), NULL, 0, NULL,
 	"Ignore DM devices that have I/O suspended while scanning devices.\n"
 	"Otherwise, LVM waits for a suspended device to become accessible.\n"
 	"This should only be needed in recovery situations.\n")
 
-cfg(devices_ignore_lvm_mirrors_CFG, "ignore_lvm_mirrors", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_IGNORE_LVM_MIRRORS, vsn(2, 2, 104), NULL,
+cfg(devices_ignore_lvm_mirrors_CFG, "ignore_lvm_mirrors", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_IGNORE_LVM_MIRRORS, vsn(2, 2, 104), NULL, 0, NULL,
 	"Do not scan 'mirror' LVs to avoid possible deadlocks.\n"
 	"This avoids possible deadlocks when using the 'mirror'\n"
 	"segment type.  This setting determines whether logical volumes\n"
@@ -345,7 +351,7 @@ cfg(devices_ignore_lvm_mirrors_CFG, "ignore_lvm_mirrors", devices_CFG_SECTION, 0
 	"'raid1' which handle failures in a different way, making them a\n"
 	"better choice for VG stacking.\n")
 
-cfg(devices_disable_after_error_count_CFG, "disable_after_error_count", devices_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_DISABLE_AFTER_ERROR_COUNT, vsn(2, 2, 75), NULL,
+cfg(devices_disable_after_error_count_CFG, "disable_after_error_count", devices_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_DISABLE_AFTER_ERROR_COUNT, vsn(2, 2, 75), NULL, 0, NULL,
 	"Number of I/O errors after which a device is skipped.\n"
 	"During each LVM operation, errors received from each device\n"
 	"are counted. If the counter of a device exceeds the limit set\n"
@@ -353,16 +359,16 @@ cfg(devices_disable_after_error_count_CFG, "disable_after_error_count", devices_
 	"of the operation.\n"
 	"Setting this to 0 disables the counters altogether.\n")
 
-cfg(devices_require_restorefile_with_uuid_CFG, "require_restorefile_with_uuid", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_REQUIRE_RESTOREFILE_WITH_UUID, vsn(2, 2, 73), NULL,
+cfg(devices_require_restorefile_with_uuid_CFG, "require_restorefile_with_uuid", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_REQUIRE_RESTOREFILE_WITH_UUID, vsn(2, 2, 73), NULL, 0, NULL,
 	"Allow use of pvcreate --uuid without requiring --restorefile.\n")
 
-cfg(devices_pv_min_size_CFG, "pv_min_size", devices_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_PV_MIN_SIZE_KB, vsn(2, 2, 85), NULL,
+cfg(devices_pv_min_size_CFG, "pv_min_size", devices_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_PV_MIN_SIZE_KB, vsn(2, 2, 85), NULL, 0, NULL,
 	"Minimum size (in KB) of block devices which can be used as PVs.\n"
 	"In a clustered environment all nodes must use the same value.\n"
 	"Any value smaller than 512KB is ignored.  The previous built-in\n"
 	"value was 512.\n")
 
-cfg(devices_issue_discards_CFG, "issue_discards", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_ISSUE_DISCARDS, vsn(2, 2, 85), NULL,
+cfg(devices_issue_discards_CFG, "issue_discards", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_ISSUE_DISCARDS, vsn(2, 2, 85), NULL, 0, NULL,
 	"Issue discards to PVs that are no longer used by an LV.\n"
 	"Discards are sent to an LV's underlying physical volumes when\n"
 	"the LV is no longer using the physical volumes' space, e.g.\n"
@@ -374,7 +380,7 @@ cfg(devices_issue_discards_CFG, "issue_discards", devices_CFG_SECTION, 0, CFG_TY
 	"and thinly provisioned LUNs generally do.  If enabled, discards\n"
 	"will only be issued if both the storage and kernel provide support.\n")
 
-cfg_array(allocation_cling_tag_list_CFG, "cling_tag_list", allocation_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 77), NULL,
+cfg_array(allocation_cling_tag_list_CFG, "cling_tag_list", allocation_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 77), NULL, 0, NULL,
 	"Advise LVM which PVs to use when searching for new space.\n"
 	"When searching for free space to extend an LV, the 'cling'\n"
 	"allocation policy will choose space on the same PVs as the last\n"
@@ -391,14 +397,14 @@ cfg_array(allocation_cling_tag_list_CFG, "cling_tag_list", allocation_CFG_SECTIO
 	"they are situated.\n"
 	"cling_tag_list = [ \"@site1\", \"@site2\" ]\n")
 
-cfg(allocation_maximise_cling_CFG, "maximise_cling", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_MAXIMISE_CLING, vsn(2, 2, 85), NULL,
+cfg(allocation_maximise_cling_CFG, "maximise_cling", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_MAXIMISE_CLING, vsn(2, 2, 85), NULL, 0, NULL,
 	"Use a previous allocation algorithm.\n"
 	"Changes made in version 2.02.85 extended the reach of the 'cling'\n"
 	"policies to detect more situations where data can be grouped onto\n"
 	"the same disks.  This setting can be used to disable the changes\n"
 	"and revert to the previous algorithm.\n")
 
-cfg(allocation_use_blkid_wiping_CFG, "use_blkid_wiping", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, 1, vsn(2, 2, 105), NULL,
+cfg(allocation_use_blkid_wiping_CFG, "use_blkid_wiping", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, 1, vsn(2, 2, 105), NULL, 0, NULL,
 	"Use blkid to detect existing signatures on new PVs and LVs.\n"
 	"The blkid library can detect more signatures than the\n"
 	"native LVM detection code, but may take longer.\n"
@@ -409,7 +415,7 @@ cfg(allocation_use_blkid_wiping_CFG, "use_blkid_wiping", allocation_CFG_SECTION,
 	"To see the list of signatures recognized by blkid, check the\n"
 	"output of the 'blkid -k' command.\n")
 
-cfg(allocation_wipe_signatures_when_zeroing_new_lvs_CFG, "wipe_signatures_when_zeroing_new_lvs", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, 1, vsn(2, 2, 105), NULL,
+cfg(allocation_wipe_signatures_when_zeroing_new_lvs_CFG, "wipe_signatures_when_zeroing_new_lvs", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, 1, vsn(2, 2, 105), NULL, 0, NULL,
 	"Look for and erase any signatures while zeroing a new LV.\n"
 	"Zeroing is controlled by the -Z/--zero option, and if not\n"
 	"specified, zeroing is used by default if possible.\n"
@@ -429,14 +435,14 @@ cfg(allocation_wipe_signatures_when_zeroing_new_lvs_CFG, "wipe_signatures_when_z
 	"not detected or erased unless the -W/--wipesignatures y\n"
 	"option is used directly.\n")
 
-cfg(allocation_mirror_logs_require_separate_pvs_CFG, "mirror_logs_require_separate_pvs", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_MIRROR_LOGS_REQUIRE_SEPARATE_PVS, vsn(2, 2, 85), NULL,
+cfg(allocation_mirror_logs_require_separate_pvs_CFG, "mirror_logs_require_separate_pvs", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_MIRROR_LOGS_REQUIRE_SEPARATE_PVS, vsn(2, 2, 85), NULL, 0, NULL,
 	"Mirror logs and images will always use different PVs.\n"
 	"The default setting changed in version 2.02.85.\n")
 
-cfg(allocation_cache_pool_metadata_require_separate_pvs_CFG, "cache_pool_metadata_require_separate_pvs", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_CACHE_POOL_METADATA_REQUIRE_SEPARATE_PVS, vsn(2, 2, 106), NULL,
+cfg(allocation_cache_pool_metadata_require_separate_pvs_CFG, "cache_pool_metadata_require_separate_pvs", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_CACHE_POOL_METADATA_REQUIRE_SEPARATE_PVS, vsn(2, 2, 106), NULL, 0, NULL,
 	"Cache pool metadata and data will always use different PVs.\n")
 
-cfg(allocation_cache_pool_cachemode_CFG, "cache_pool_cachemode", allocation_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_CACHE_POOL_CACHEMODE, vsn(2, 2, 113), NULL,
+cfg(allocation_cache_pool_cachemode_CFG, "cache_pool_cachemode", allocation_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_CACHE_POOL_CACHEMODE, vsn(2, 2, 113), NULL, 0, NULL,
 	"The default cache mode used for new cache pools.\n"
 	"Possible options are: writethrough, writeback.\n"
 	"writethrough - Data blocks are immediately written from\n"
@@ -444,7 +450,7 @@ cfg(allocation_cache_pool_cachemode_CFG, "cache_pool_cachemode", allocation_CFG_
 	"writeback - Data blocks are written from the cache back\n"
 	"to disk after some delay to improve performance.\n")
 
-cfg_runtime(allocation_cache_pool_chunk_size_CFG, "cache_pool_chunk_size", allocation_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_INT, vsn(2, 2, 106),
+cfg_runtime(allocation_cache_pool_chunk_size_CFG, "cache_pool_chunk_size", allocation_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_INT, vsn(2, 2, 106), 0, NULL,
 	"The minimal chunk size (in kiB) for cache pool volumes.\n"
 	"Using a chunk_size that is too large can result in wasteful\n"
 	"use of the cache, where small reads and writes can cause\n"
@@ -456,18 +462,18 @@ cfg_runtime(allocation_cache_pool_chunk_size_CFG, "cache_pool_chunk_size", alloc
 	"end of the spectrum.  Supported values range from 32(kiB) to\n"
 	"1048576 in multiples of 32.\n")
 
-cfg(allocation_thin_pool_metadata_require_separate_pvs_CFG, "thin_pool_metadata_require_separate_pvs", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_THIN_POOL_METADATA_REQUIRE_SEPARATE_PVS, vsn(2, 2, 89), NULL,
+cfg(allocation_thin_pool_metadata_require_separate_pvs_CFG, "thin_pool_metadata_require_separate_pvs", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_THIN_POOL_METADATA_REQUIRE_SEPARATE_PVS, vsn(2, 2, 89), NULL, 0, NULL,
 	"Thin pool metdata and data will always use different PVs.\n")
 
-cfg(allocation_thin_pool_zero_CFG, "thin_pool_zero", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA, CFG_TYPE_BOOL, DEFAULT_THIN_POOL_ZERO, vsn(2, 2, 99), NULL,
+cfg(allocation_thin_pool_zero_CFG, "thin_pool_zero", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA, CFG_TYPE_BOOL, DEFAULT_THIN_POOL_ZERO, vsn(2, 2, 99), NULL, 0, NULL,
 	"Thin pool data chunks are zeroed before they are first used.\n"
 	"Zeroing with a larger thin pool chunk size reduces performance.\n")
 
-cfg(allocation_thin_pool_discards_CFG, "thin_pool_discards", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA, CFG_TYPE_STRING, DEFAULT_THIN_POOL_DISCARDS, vsn(2, 2, 99), NULL,
+cfg(allocation_thin_pool_discards_CFG, "thin_pool_discards", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA, CFG_TYPE_STRING, DEFAULT_THIN_POOL_DISCARDS, vsn(2, 2, 99), NULL, 0, NULL,
 	"The discards behaviour of thin pool volumes.\n"
 	"Possible options are: ignore, nopassdown, passdown.\n")
 
-cfg(allocation_thin_pool_chunk_size_policy_CFG, "thin_pool_chunk_size_policy", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA, CFG_TYPE_STRING, DEFAULT_THIN_POOL_CHUNK_SIZE_POLICY, vsn(2, 2, 101), NULL,
+cfg(allocation_thin_pool_chunk_size_policy_CFG, "thin_pool_chunk_size_policy", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA, CFG_TYPE_STRING, DEFAULT_THIN_POOL_CHUNK_SIZE_POLICY, vsn(2, 2, 101), NULL, 0, NULL,
 	"The chunk size calculation policy for thin pool volumes.\n"
 	"Possible options are: generic, performance.\n"
 	"generic - If thin_pool_chunk_size is defined, use it.\n"
@@ -479,7 +485,7 @@ cfg(allocation_thin_pool_chunk_size_policy_CFG, "thin_pool_chunk_size_policy", a
 	"device hints exposed in sysfs - the optimal_io_size.\n"
 	"The chunk size is always at least 512KiB.\n")
 
-cfg_runtime(allocation_thin_pool_chunk_size_CFG, "thin_pool_chunk_size", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_UNDEFINED, CFG_TYPE_INT, vsn(2, 2, 99),
+cfg_runtime(allocation_thin_pool_chunk_size_CFG, "thin_pool_chunk_size", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_UNDEFINED, CFG_TYPE_INT, vsn(2, 2, 99), 0, NULL,
 	"The minimal chunk size (in KB) for thin pool volumes.\n"
 	"Larger chunk sizes may improve performance for plain\n"
 	"thin volumes, however using them for snapshot volumes\n"
@@ -488,13 +494,13 @@ cfg_runtime(allocation_thin_pool_chunk_size_CFG, "thin_pool_chunk_size", allocat
 	"chunk size starting from 64KB.  Supported values are in\n"
 	"the range 64 to 1048576.\n")
 
-cfg(allocation_physical_extent_size_CFG, "physical_extent_size", allocation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_EXTENT_SIZE, vsn(2, 2, 112), NULL,
+cfg(allocation_physical_extent_size_CFG, "physical_extent_size", allocation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_EXTENT_SIZE, vsn(2, 2, 112), NULL, 0, NULL,
 	"Default physical extent size to use for new VGs (in KB).\n")
 
-cfg(log_verbose_CFG, "verbose", log_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_VERBOSE, vsn(1, 0, 0), NULL,
+cfg(log_verbose_CFG, "verbose", log_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_VERBOSE, vsn(1, 0, 0), NULL, 0, NULL,
 	"Controls the messages sent to stdout or stderr.\n")
 
-cfg(log_silent_CFG, "silent", log_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_SILENT, vsn(2, 2, 98), NULL,
+cfg(log_silent_CFG, "silent", log_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_SILENT, vsn(2, 2, 98), NULL, 0, NULL,
 	"Suppress all non-essential messages from stdout.\n"
 	"This has the same effect as -qq.\n"
 	"When enabled, the following commands still produce output:\n"
@@ -505,40 +511,40 @@ cfg(log_silent_CFG, "silent", log_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_SILENT,
 	"Any 'yes' or 'no' questions not overridden by other arguments\n"
 	"are suppressed and default to 'no'.\n")
 
-cfg(log_syslog_CFG, "syslog", log_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_SYSLOG, vsn(1, 0, 0), NULL,
+cfg(log_syslog_CFG, "syslog", log_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_SYSLOG, vsn(1, 0, 0), NULL, 0, NULL,
 	"Send log messages through syslog.\n")
 
-cfg(log_file_CFG, "file", log_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL,
+cfg(log_file_CFG, "file", log_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL, 0, NULL,
 	"Write error and debug log messages to a file specified here.\n")
 
-cfg(log_overwrite_CFG, "overwrite", log_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_OVERWRITE, vsn(1, 0, 0), NULL,
+cfg(log_overwrite_CFG, "overwrite", log_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_OVERWRITE, vsn(1, 0, 0), NULL, 0, NULL,
 	"Overwrite the log file each time the program is run.\n")
 
-cfg(log_level_CFG, "level", log_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_LOGLEVEL, vsn(1, 0, 0), NULL,
+cfg(log_level_CFG, "level", log_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_LOGLEVEL, vsn(1, 0, 0), NULL, 0, NULL,
 	"The level of log messages that are sent to the log file or syslog.\n"
 	"There are 6 syslog-like log levels currently in use: 2 to 7 inclusive.\n"
 	"7 is the most verbose (LOG_DEBUG).\n")
 
-cfg(log_indent_CFG, "indent", log_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_INDENT, vsn(1, 0, 0), NULL,
+cfg(log_indent_CFG, "indent", log_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_INDENT, vsn(1, 0, 0), NULL, 0, NULL,
 	"Indent messages according to their severity.\n")
 
-cfg(log_command_names_CFG, "command_names", log_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_CMD_NAME, vsn(1, 0, 0), NULL,
+cfg(log_command_names_CFG, "command_names", log_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_CMD_NAME, vsn(1, 0, 0), NULL, 0, NULL,
 	"Display the command name on each line of output.\n")
 
-cfg(log_prefix_CFG, "prefix", log_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, DEFAULT_MSG_PREFIX, vsn(1, 0, 0), NULL,
+cfg(log_prefix_CFG, "prefix", log_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, DEFAULT_MSG_PREFIX, vsn(1, 0, 0), NULL, 0, NULL,
 	"A prefix to use before the log message text.\n"
 	"(After the command name, if selected).\n"
 	"Two spaces allows you to see/grep the severity of each message.\n"
 	"To make the messages look similar to the original LVM tools use:\n"
 	"indent = 0, command_names = 1, prefix = \" -- \"\n")
 
-cfg(log_activation_CFG, "activation", log_CFG_SECTION, 0, CFG_TYPE_BOOL, 0, vsn(1, 0, 0), NULL,
+cfg(log_activation_CFG, "activation", log_CFG_SECTION, 0, CFG_TYPE_BOOL, 0, vsn(1, 0, 0), NULL, 0, NULL,
 	"Log messages during activation.\n"
 	"Don't use this in low memory situations (can deadlock).\n")
 
-cfg(log_activate_file_CFG, "activate_file", log_CFG_SECTION, CFG_DEFAULT_UNDEFINED | CFG_UNSUPPORTED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL, NULL)
+cfg(log_activate_file_CFG, "activate_file", log_CFG_SECTION, CFG_DEFAULT_UNDEFINED | CFG_UNSUPPORTED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL, 0, NULL, NULL)
 
-cfg_array(log_debug_classes_CFG, "debug_classes", log_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, "#Smemory#Sdevices#Sactivation#Sallocation#Slvmetad#Smetadata#Scache#Slocking", vsn(2, 2, 99), NULL,
+cfg_array(log_debug_classes_CFG, "debug_classes", log_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, "#Smemory#Sdevices#Sactivation#Sallocation#Slvmetad#Smetadata#Scache#Slocking", vsn(2, 2, 99), NULL, 0, NULL,
 	"Select log messages by class.\n"
 	"Some debugging messages are assigned to a class\n"
 	"and only appear in debug output if the class is\n"
@@ -547,63 +553,63 @@ cfg_array(log_debug_classes_CFG, "debug_classes", log_CFG_SECTION, CFG_ALLOW_EMP
 	"lvmetad, metadata, cache, locking.\n"
 	"Use \"all\" to see everything.\n")
 
-cfg(backup_backup_CFG, "backup", backup_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_BACKUP_ENABLED, vsn(1, 0, 0), NULL,
+cfg(backup_backup_CFG, "backup", backup_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_BACKUP_ENABLED, vsn(1, 0, 0), NULL, 0, NULL,
 	"Maintain a backup of the current metadata configuration.\n"
 	"Think very hard before turning this off!\n")
 
-cfg_runtime(backup_backup_dir_CFG, "backup_dir", backup_CFG_SECTION, 0, CFG_TYPE_STRING, vsn(1, 0, 0),
+cfg_runtime(backup_backup_dir_CFG, "backup_dir", backup_CFG_SECTION, 0, CFG_TYPE_STRING, vsn(1, 0, 0), 0, NULL,
 	"Location of the metadata backup files.\n"
 	"Remember to back up this directory regularly!\n")
 
-cfg(backup_archive_CFG, "archive", backup_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_ARCHIVE_ENABLED, vsn(1, 0, 0), NULL,
+cfg(backup_archive_CFG, "archive", backup_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_ARCHIVE_ENABLED, vsn(1, 0, 0), NULL, 0, NULL,
 	"Maintain an archive of old metadata configurations.\n"
 	"Think very hard before turning this off.\n")
 
-cfg_runtime(backup_archive_dir_CFG, "archive_dir", backup_CFG_SECTION, 0, CFG_TYPE_STRING, vsn(1, 0, 0),
+cfg_runtime(backup_archive_dir_CFG, "archive_dir", backup_CFG_SECTION, 0, CFG_TYPE_STRING, vsn(1, 0, 0), 0, NULL,
 	"Location of the metdata archive files.\n"
 	"Remember to back up this directory regularly!\n")
 
-cfg(backup_retain_min_CFG, "retain_min", backup_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_ARCHIVE_NUMBER, vsn(1, 0, 0), NULL,
+cfg(backup_retain_min_CFG, "retain_min", backup_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_ARCHIVE_NUMBER, vsn(1, 0, 0), NULL, 0, NULL,
 	"Minimum number of archives to keep.\n")
 
-cfg(backup_retain_days_CFG, "retain_days", backup_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_ARCHIVE_DAYS, vsn(1, 0, 0), NULL,
+cfg(backup_retain_days_CFG, "retain_days", backup_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_ARCHIVE_DAYS, vsn(1, 0, 0), NULL, 0, NULL,
 	"Minimum number of days to keep archive files.\n")
 
-cfg(shell_history_size_CFG, "history_size", shell_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_MAX_HISTORY, vsn(1, 0, 0), NULL,
+cfg(shell_history_size_CFG, "history_size", shell_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_MAX_HISTORY, vsn(1, 0, 0), NULL, 0, NULL,
 	"Number of lines of history to store in ~/.lvm_history.\n")
 
-cfg(global_umask_CFG, "umask", global_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_UMASK, vsn(1, 0, 0), NULL,
+cfg(global_umask_CFG, "umask", global_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_UMASK, vsn(1, 0, 0), NULL, 0, NULL,
 	"The file creation mask for any files and directories created.\n"
 	"Interpreted as octal if the first digit is zero.\n")
 
-cfg(global_test_CFG, "test", global_CFG_SECTION, 0, CFG_TYPE_BOOL, 0, vsn(1, 0, 0), NULL,
+cfg(global_test_CFG, "test", global_CFG_SECTION, 0, CFG_TYPE_BOOL, 0, vsn(1, 0, 0), NULL, 0, NULL,
 	"No on-disk metadata changes will be made in test mode.\n"
 	"Equivalent to having the -t option on every command.\n")
 
-cfg(global_units_CFG, "units", global_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_UNITS, vsn(1, 0, 0), NULL,
+cfg(global_units_CFG, "units", global_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_UNITS, vsn(1, 0, 0), NULL, 0, NULL,
 	"Default value for --units argument.\n")
 
-cfg(global_si_unit_consistency_CFG, "si_unit_consistency", global_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_SI_UNIT_CONSISTENCY,  vsn(2, 2, 54), NULL,
+cfg(global_si_unit_consistency_CFG, "si_unit_consistency", global_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_SI_UNIT_CONSISTENCY,  vsn(2, 2, 54), NULL, 0, NULL,
 	"Distinguish between powers of 1024 and 1000 bytes.\n"
 	"The LVM commands distinguish between powers of 1024 bytes,\n"
 	"e.g. KiB, MiB, GiB, and powers of 1000 bytes, e.g. KB, MB, GB.\n"
 	"If scripts depend on the old behaviour, disable\n"
 	"this setting temporarily until they are updated.\n")
 
-cfg(global_suffix_CFG, "suffix", global_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_SUFFIX, vsn(1, 0, 0), NULL,
+cfg(global_suffix_CFG, "suffix", global_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_SUFFIX, vsn(1, 0, 0), NULL, 0, NULL,
 	"Display unit suffix for sizes.\n"
 	"This setting has no effect if the units are in human-readable\n"
 	"form (global/units=\"h\") in which case the suffix is always\n"
 	"displayed.\n")
 
-cfg(global_activation_CFG, "activation", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_ACTIVATION, vsn(1, 0, 0), NULL,
+cfg(global_activation_CFG, "activation", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_ACTIVATION, vsn(1, 0, 0), NULL, 0, NULL,
 	"Enable/disable communication with the kernel device-mapper.\n"
 	"Disable to use the tools to manipulate LVM metadata without\n"
 	"activating any logical volumes. If the device-mapper driver\n"
 	"is not present in the kernel, disabling this should suppress\n"
 	"the error messages.\n")
 
-cfg(global_fallback_to_lvm1_CFG, "fallback_to_lvm1", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_FALLBACK_TO_LVM1, vsn(1, 0, 18), NULL,
+cfg(global_fallback_to_lvm1_CFG, "fallback_to_lvm1", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_FALLBACK_TO_LVM1, vsn(1, 0, 18), NULL, 0, NULL,
 	"Try running LVM1 tools if LVM cannot communicate with DM.\n"
 	"This option only applies to 2.4 kernels and is provided to\n"
 	"help switch between device-mapper kernels and LVM1 kernels.\n"
@@ -611,25 +617,25 @@ cfg(global_fallback_to_lvm1_CFG, "fallback_to_lvm1", global_CFG_SECTION, 0, CFG_
 	"e.g. vgscan.lvm1. They will stop working once the lvm2\n"
 	"on-disk metadata format is used.\n")
 
-cfg(global_format_CFG, "format", global_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_FORMAT, vsn(1, 0, 0), NULL,
+cfg(global_format_CFG, "format", global_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_FORMAT, vsn(1, 0, 0), NULL, 0, NULL,
 	"The default metadata format that commands should use.\n"
 	"\"lvm1\" or \"lvm2\".\n"
 	"The command line override is -M1 or -M2.\n")
 
-cfg_array(global_format_libraries_CFG, "format_libraries", global_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL,
+cfg_array(global_format_libraries_CFG, "format_libraries", global_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL, 0, NULL,
 	"Shared libraries that process different metadata formats.\n"
 	"If support for LVM1 metadata was compiled as a shared library use\n"
 	"format_libraries = \"liblvm2format1.so\"\n")
 
-cfg_array(global_segment_libraries_CFG, "segment_libraries", global_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 18), NULL, NULL)
+cfg_array(global_segment_libraries_CFG, "segment_libraries", global_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 18), NULL, 0, NULL, NULL)
 
-cfg(global_proc_CFG, "proc", global_CFG_SECTION, CFG_ADVANCED, CFG_TYPE_STRING, DEFAULT_PROC_DIR, vsn(1, 0, 0), NULL,
+cfg(global_proc_CFG, "proc", global_CFG_SECTION, CFG_ADVANCED, CFG_TYPE_STRING, DEFAULT_PROC_DIR, vsn(1, 0, 0), NULL, 0, NULL,
 	"Location of proc filesystem.\n")
 
-cfg(global_etc_CFG, "etc", global_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_ETC_DIR, vsn(2, 2, 117), "@CONFDIR@",
+cfg(global_etc_CFG, "etc", global_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_ETC_DIR, vsn(2, 2, 117), "@CONFDIR@", 0, NULL,
 	"Location of /etc system configuration directory.\n")
 
-cfg(global_locking_type_CFG, "locking_type", global_CFG_SECTION, 0, CFG_TYPE_INT, 1, vsn(1, 0, 0), NULL,
+cfg(global_locking_type_CFG, "locking_type", global_CFG_SECTION, 0, CFG_TYPE_INT, 1, vsn(1, 0, 0), NULL, 0, NULL,
 	"Type of locking to use.\n"
 	"Type 0: turns off locking. Warning: this risks metadata\n"
 	"corruption if commands run concurrently.\n"
@@ -650,17 +656,17 @@ cfg(global_locking_type_CFG, "locking_type", global_CFG_SECTION, 0, CFG_TYPE_INT
 	"in use, for example a virtual machine image or a disk that is\n"
 	"shared by a clustered machine.\n")
 
-cfg(global_wait_for_locks_CFG, "wait_for_locks", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_WAIT_FOR_LOCKS, vsn(2, 2, 50), NULL,
+cfg(global_wait_for_locks_CFG, "wait_for_locks", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_WAIT_FOR_LOCKS, vsn(2, 2, 50), NULL, 0, NULL,
 	"When disabled, fail if a lock request would block.\n")
 
-cfg(global_fallback_to_clustered_locking_CFG, "fallback_to_clustered_locking", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_FALLBACK_TO_CLUSTERED_LOCKING, vsn(2, 2, 42), NULL,
+cfg(global_fallback_to_clustered_locking_CFG, "fallback_to_clustered_locking", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_FALLBACK_TO_CLUSTERED_LOCKING, vsn(2, 2, 42), NULL, 0, NULL,
 	"Attempt to use built-in cluster locking if locking_type 2 fails.\n"
 	"If using external locking (type 2) and initialisation fails,\n"
 	"with this enabled, an attempt will be made to use the built-in\n"
 	"clustered locking.\n"
 	"If you are using a customised locking_library you should disable this.\n")
 
-cfg(global_fallback_to_local_locking_CFG, "fallback_to_local_locking", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_FALLBACK_TO_LOCAL_LOCKING, vsn(2, 2, 42), NULL,
+cfg(global_fallback_to_local_locking_CFG, "fallback_to_local_locking", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_FALLBACK_TO_LOCAL_LOCKING, vsn(2, 2, 42), NULL, 0, NULL,
 	"Use locking_type 1 (local) if locking_type 2 or 3 fail.\n"
 	"If an attempt to initialise type 2 or type 3 locking failed,\n"
 	"perhaps because cluster components such as clvmd are not\n"
@@ -669,13 +675,13 @@ cfg(global_fallback_to_local_locking_CFG, "fallback_to_local_locking", global_CF
 	"commands against local volume groups will proceed.\n"
 	"Volume Groups marked as clustered will be ignored.\n")
 
-cfg(global_locking_dir_CFG, "locking_dir", global_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_LOCK_DIR, vsn(1, 0, 0), "@DEFAULT_LOCK_DIR@",
+cfg(global_locking_dir_CFG, "locking_dir", global_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_LOCK_DIR, vsn(1, 0, 0), "@DEFAULT_LOCK_DIR@", 0, NULL,
 	"Directory to use for LVM command file locks.\n"
 	"Local non-LV directory that holds file-based locks\n"
 	"while commands are in progress.  A directory like\n"
 	"/tmp that may get wiped on reboot is OK.\n")
 
-cfg(global_prioritise_write_locks_CFG, "prioritise_write_locks", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_PRIORITISE_WRITE_LOCKS, vsn(2, 2, 52), NULL,
+cfg(global_prioritise_write_locks_CFG, "prioritise_write_locks", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_PRIORITISE_WRITE_LOCKS, vsn(2, 2, 52), NULL, 0, NULL,
 	"Allow quicker VG write access during high volume read access.\n"
 	"When there are competing read-only and read-write access\n"
 	"requests for a volume group's metadata, instead of always\n"
@@ -686,26 +692,26 @@ cfg(global_prioritise_write_locks_CFG, "prioritise_write_locks", global_CFG_SECT
 	"This option only affects locking_type 1 viz.\n"
 	"local file-based locking.\n")
 
-cfg(global_library_dir_CFG, "library_dir", global_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL,
+cfg(global_library_dir_CFG, "library_dir", global_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL, 0, NULL,
 	"Search this directory first for shared libraries.\n")
 
-cfg(global_locking_library_CFG, "locking_library", global_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, DEFAULT_LOCKING_LIB, vsn(1, 0, 0), NULL,
+cfg(global_locking_library_CFG, "locking_library", global_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, DEFAULT_LOCKING_LIB, vsn(1, 0, 0), NULL, 0, NULL,
 	"The external locking library to use for locking_type 2.\n")
 
-cfg(global_abort_on_internal_errors_CFG, "abort_on_internal_errors", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_ABORT_ON_INTERNAL_ERRORS, vsn(2, 2, 57), NULL,
+cfg(global_abort_on_internal_errors_CFG, "abort_on_internal_errors", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_ABORT_ON_INTERNAL_ERRORS, vsn(2, 2, 57), NULL, 0, NULL,
 	"Abort a command that encounters an internal error.\n"
 	"Treat any internal errors as fatal errors, aborting\n"
 	"the process that encountered the internal error.\n"
 	"Please only enable for debugging.\n")
 
-cfg(global_detect_internal_vg_cache_corruption_CFG, "detect_internal_vg_cache_corruption", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_DETECT_INTERNAL_VG_CACHE_CORRUPTION, vsn(2, 2, 96), NULL,
+cfg(global_detect_internal_vg_cache_corruption_CFG, "detect_internal_vg_cache_corruption", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_DETECT_INTERNAL_VG_CACHE_CORRUPTION, vsn(2, 2, 96), NULL, 0, NULL,
 	"Internal verification of VG structures.\n"
 	"Check if CRC matches when a parsed VG is\n"
 	"used multiple times. This is useful to catch\n"
 	"unexpected changes to cached VG structures.\n"
 	"Please only enable for debugging.\n")
 
-cfg(global_metadata_read_only_CFG, "metadata_read_only", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_METADATA_READ_ONLY, vsn(2, 2, 75), NULL,
+cfg(global_metadata_read_only_CFG, "metadata_read_only", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_METADATA_READ_ONLY, vsn(2, 2, 75), NULL, 0, NULL,
 	"No operations that change on-disk metadata are permitted.\n"
 	"Additionally, read-only commands that encounter metadata\n"
 	"in need of repair will still be allowed to proceed exactly\n"
@@ -713,7 +719,7 @@ cfg(global_metadata_read_only_CFG, "metadata_read_only", global_CFG_SECTION, 0,
 	"vg_seqno). Inappropriate use could mess up your system,\n"
 	"so seek advice first!\n")
 
-cfg(global_mirror_segtype_default_CFG, "mirror_segtype_default", global_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_MIRROR_SEGTYPE, vsn(2, 2, 87), "@DEFAULT_MIRROR_SEGTYPE@",
+cfg(global_mirror_segtype_default_CFG, "mirror_segtype_default", global_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_MIRROR_SEGTYPE, vsn(2, 2, 87), "@DEFAULT_MIRROR_SEGTYPE@", 0, NULL,
 	"The segment type used by the short mirroring option -m.\n"
 	"Possible options are: mirror, raid1.\n"
 	"mirror - the original RAID1 implementation from LVM/DM.\n"
@@ -735,7 +741,7 @@ cfg(global_mirror_segtype_default_CFG, "mirror_segtype_default", global_CFG_SECT
 	"fashion in a cluster.\n"
 	"The '--type mirror|raid1' option overrides this setting.\n")
 
-cfg(global_raid10_segtype_default_CFG, "raid10_segtype_default", global_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_RAID10_SEGTYPE, vsn(2, 2, 99), "@DEFAULT_RAID10_SEGTYPE@",
+cfg(global_raid10_segtype_default_CFG, "raid10_segtype_default", global_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_RAID10_SEGTYPE, vsn(2, 2, 99), "@DEFAULT_RAID10_SEGTYPE@", 0, NULL,
 	"The segment type used by the -i -m combination.\n"
 	"The --stripes/-i and --mirrors/-m options can both\n"
 	"be specified during the creation of a logical volume\n"
@@ -750,7 +756,7 @@ cfg(global_raid10_segtype_default_CFG, "raid10_segtype_default", global_CFG_SECT
 	"and performance. The 'raid10' option is perferred.\n"
 	"The '--type raid10|mirror' option overrides this setting.\n")
 
-cfg(global_sparse_segtype_default_CFG, "sparse_segtype_default", global_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_SPARSE_SEGTYPE, vsn(2, 2, 112), "@DEFAULT_SPARSE_SEGTYPE@",
+cfg(global_sparse_segtype_default_CFG, "sparse_segtype_default", global_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_SPARSE_SEGTYPE, vsn(2, 2, 112), "@DEFAULT_SPARSE_SEGTYPE@", 0, NULL,
 	"The segment type used by the -V -L combination.\n"
 	"The combination of -V and -L options creates a\n"
 	"sparse LV. There are two different implementations.\n"
@@ -765,14 +771,14 @@ cfg(global_sparse_segtype_default_CFG, "sparse_segtype_default", global_CFG_SECT
 	"when more data is used.  It also supports full snapshots.\n"
 	"The '--type snapshot|thin' option overrides this setting.\n")
 
-cfg(global_lvdisplay_shows_full_device_path_CFG, "lvdisplay_shows_full_device_path", global_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_LVDISPLAY_SHOWS_FULL_DEVICE_PATH, vsn(2, 2, 89), NULL,
+cfg(global_lvdisplay_shows_full_device_path_CFG, "lvdisplay_shows_full_device_path", global_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_LVDISPLAY_SHOWS_FULL_DEVICE_PATH, vsn(2, 2, 89), NULL, 0, NULL,
 	"The default format for displaying LV names in lvdisplay was changed\n"
 	"in version 2.02.89 to show the LV name and path separately.\n"
 	"Previously this was always shown as /dev/vgname/lvname even when that\n"
 	"was never a valid path in the /dev filesystem.\n"
 	"Enable this option to reinstate the previous format.\n")
 
-cfg(global_use_lvmetad_CFG, "use_lvmetad", global_CFG_SECTION, 0, CFG_TYPE_BOOL, 0, vsn(2, 2, 93), NULL,
+cfg(global_use_lvmetad_CFG, "use_lvmetad", global_CFG_SECTION, 0, CFG_TYPE_BOOL, 0, vsn(2, 2, 93), NULL, 0, NULL,
 	"Use lvmetad to cache metadata and reduce disk scanning.\n"
 	"When enabled (and running), lvmetad provides LVM commands\n"
 	"with VG metadata and PV state.  LVM commands then avoid\n"
@@ -806,7 +812,7 @@ cfg(global_use_lvmetad_CFG, "use_lvmetad", global_CFG_SECTION, 0, CFG_TYPE_BOOL,
 	"LVM prints warnings and ignores lvmetad if this combination\n"
 	"is seen.\n")
 
-cfg(global_thin_check_executable_CFG, "thin_check_executable", global_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, THIN_CHECK_CMD, vsn(2, 2, 94), "@THIN_CHECK_CMD@",
+cfg(global_thin_check_executable_CFG, "thin_check_executable", global_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, THIN_CHECK_CMD, vsn(2, 2, 94), "@THIN_CHECK_CMD@", 0, NULL,
 	"The full path to the thin_check command.\n"
 	"LVM uses this command to check that a thin metadata\n"
 	"device is in a usable state.\n"
@@ -818,19 +824,19 @@ cfg(global_thin_check_executable_CFG, "thin_check_executable", global_CFG_SECTIO
 	"The thin tools are available from the package\n"
 	"device-mapper-persistent-data.\n")
 
-cfg(global_thin_dump_executable_CFG, "thin_dump_executable", global_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, THIN_DUMP_CMD, vsn(2, 2, 100), "@THIN_DUMP_CMD@",
+cfg(global_thin_dump_executable_CFG, "thin_dump_executable", global_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, THIN_DUMP_CMD, vsn(2, 2, 100), "@THIN_DUMP_CMD@", 0, NULL,
 	"The full path to the thin_dump command.\n"
 	"LVM uses this command to dump thin pool metadata.\n"
 	"(For thin tools, see thin_check_executable.)\n")
 
-cfg(global_thin_repair_executable_CFG, "thin_repair_executable", global_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, THIN_REPAIR_CMD, vsn(2, 2, 100), "@THIN_REPAIR_CMD@",
+cfg(global_thin_repair_executable_CFG, "thin_repair_executable", global_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, THIN_REPAIR_CMD, vsn(2, 2, 100), "@THIN_REPAIR_CMD@", 0, NULL,
 	"The full path to the thin_repair command.\n"
 	"LVM uses this command to repair a thin metadata device\n"
 	"if it is in an unusable state.\n"
 	"Also see thin_repair_options.\n"
 	"(For thin tools, see thin_check_executable.)\n")
 
-cfg_array(global_thin_check_options_CFG, "thin_check_options", global_CFG_SECTION, 0, CFG_TYPE_STRING, "#S" DEFAULT_THIN_CHECK_OPTION1 "#S" DEFAULT_THIN_CHECK_OPTION2, vsn(2, 2, 96), NULL,
+cfg_array(global_thin_check_options_CFG, "thin_check_options", global_CFG_SECTION, 0, CFG_TYPE_STRING, "#S" DEFAULT_THIN_CHECK_OPTION1 "#S" DEFAULT_THIN_CHECK_OPTION2, vsn(2, 2, 96), NULL, 0, NULL,
 	"List of options passed to the thin_check command.\n"
 	"With thin_check version 2.1 or newer you can add\n"
 	"--ignore-non-fatal-errors to let it pass through\n"
@@ -838,10 +844,10 @@ cfg_array(global_thin_check_options_CFG, "thin_check_options", global_CFG_SECTIO
 	"With thin_check version 3.2 or newer you should add\n"
 	"--clear-needs-check-flag.\n")
 
-cfg_array(global_thin_repair_options_CFG, "thin_repair_options", global_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, "#S" DEFAULT_THIN_REPAIR_OPTIONS, vsn(2, 2, 100), NULL,
+cfg_array(global_thin_repair_options_CFG, "thin_repair_options", global_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, "#S" DEFAULT_THIN_REPAIR_OPTIONS, vsn(2, 2, 100), NULL, 0, NULL,
 	"List of options passed to the thin_repair command.\n")
 
-cfg_array(global_thin_disabled_features_CFG, "thin_disabled_features", global_CFG_SECTION, CFG_DEFAULT_UNDEFINED | CFG_ALLOW_EMPTY, CFG_TYPE_STRING, NULL, vsn(2, 2, 99), NULL,
+cfg_array(global_thin_disabled_features_CFG, "thin_disabled_features", global_CFG_SECTION, CFG_DEFAULT_UNDEFINED | CFG_ALLOW_EMPTY, CFG_TYPE_STRING, NULL, vsn(2, 2, 99), NULL, 0, NULL,
 	"Features to not use in the thin driver.\n"
 	"This can be helpful for testing, or to avoid\n"
 	"using a feature that is causing problems.\n"
@@ -851,7 +857,7 @@ cfg_array(global_thin_disabled_features_CFG, "thin_disabled_features", global_CF
 	"Example:\n"
 	"thin_disabled_features = [ \"discards\", \"block_size\" ]\n")
 
-cfg(global_cache_check_executable_CFG, "cache_check_executable", global_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, CACHE_CHECK_CMD, vsn(2, 2, 108), "@CACHE_CHECK_CMD@",
+cfg(global_cache_check_executable_CFG, "cache_check_executable", global_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, CACHE_CHECK_CMD, vsn(2, 2, 108), "@CACHE_CHECK_CMD@", 0, NULL,
 	"The full path to the cache_check command.\n"
 	"LVM uses this command to check that a cache metadata\n"
 	"device is in a usable state.\n"
@@ -863,25 +869,25 @@ cfg(global_cache_check_executable_CFG, "cache_check_executable", global_CFG_SECT
 	"The cache tools are available from the package\n"
 	"device-mapper-persistent-data.\n")
 
-cfg(global_cache_dump_executable_CFG, "cache_dump_executable", global_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, CACHE_DUMP_CMD, vsn(2, 2, 108), "@CACHE_DUMP_CMD@",
+cfg(global_cache_dump_executable_CFG, "cache_dump_executable", global_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, CACHE_DUMP_CMD, vsn(2, 2, 108), "@CACHE_DUMP_CMD@", 0, NULL,
 	"The full path to the cache_dump command.\n"
 	"LVM uses this command to dump cache pool metadata.\n"
 	"(For cache tools, see cache_check_executable.)\n")
 
-cfg(global_cache_repair_executable_CFG, "cache_repair_executable", global_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, CACHE_REPAIR_CMD, vsn(2, 2, 108), "@CACHE_REPAIR_CMD@",
+cfg(global_cache_repair_executable_CFG, "cache_repair_executable", global_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, CACHE_REPAIR_CMD, vsn(2, 2, 108), "@CACHE_REPAIR_CMD@", 0, NULL,
 	"The full path to the cache_repair command.\n"
 	"LVM uses this command to repair a cache metadata device\n"
 	"if it is in an unusable state.\n"
 	"Also see cache_repair_options.\n"
 	"(For cache tools, see cache_check_executable.)\n")
 
-cfg_array(global_cache_check_options_CFG, "cache_check_options", global_CFG_SECTION, 0, CFG_TYPE_STRING, "#S" DEFAULT_CACHE_CHECK_OPTION1, vsn(2, 2, 108), NULL,
+cfg_array(global_cache_check_options_CFG, "cache_check_options", global_CFG_SECTION, 0, CFG_TYPE_STRING, "#S" DEFAULT_CACHE_CHECK_OPTION1, vsn(2, 2, 108), NULL, 0, NULL,
 	"List of options passed to the cache_check command.\n")
 
-cfg_array(global_cache_repair_options_CFG, "cache_repair_options", global_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, "#S" DEFAULT_CACHE_REPAIR_OPTIONS, vsn(2, 2, 108), NULL,
+cfg_array(global_cache_repair_options_CFG, "cache_repair_options", global_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, "#S" DEFAULT_CACHE_REPAIR_OPTIONS, vsn(2, 2, 108), NULL, 0, NULL,
 	"List of options passed to the cache_repair command.\n")
 
-cfg(global_system_id_source_CFG, "system_id_source", global_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_SYSTEM_ID_SOURCE, vsn(2, 2, 117), NULL,
+cfg(global_system_id_source_CFG, "system_id_source", global_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_SYSTEM_ID_SOURCE, vsn(2, 2, 117), NULL, 0, NULL,
 	"The method LVM uses to set the local system ID.\n"
 	"Volume Groups can also be given a system ID (by\n"
 	"vgcreate, vgchange, or vgimport.)\n"
@@ -901,18 +907,18 @@ cfg(global_system_id_source_CFG, "system_id_source", global_CFG_SECTION, 0, CFG_
 	"file - Use the contents of another file (system_id_file) to set\n"
 	"the system ID.\n")
 
-cfg(global_system_id_file_CFG, "system_id_file", global_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 117), NULL,
+cfg(global_system_id_file_CFG, "system_id_file", global_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 117), NULL, 0, NULL,
 	"The full path to the file containing a system ID.\n"
 	"This is used when system_id_source is set to 'file'.\n"
 	"Comments starting with the character # are ignored.\n")
 
-cfg(activation_checks_CFG, "checks", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_ACTIVATION_CHECKS, vsn(2, 2, 86), NULL,
+cfg(activation_checks_CFG, "checks", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_ACTIVATION_CHECKS, vsn(2, 2, 86), NULL, 0, NULL,
 	"Perform internal checks of libdevmapper operations.\n"
 	"Useful for debugging problems with activation.\n"
 	"Some of the checks may be expensive, so it's best to use\n"
 	"this only when there seems to be a problem.\n")
 
-cfg(activation_udev_sync_CFG, "udev_sync", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_UDEV_SYNC, vsn(2, 2, 51), NULL,
+cfg(activation_udev_sync_CFG, "udev_sync", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_UDEV_SYNC, vsn(2, 2, 51), NULL, 0, NULL,
 	"Use udev notifications to synchronize udev and LVM.\n"
 	"When disabled, LVM commands will not wait for notifications\n"
 	"from udev, but continue irrespective of any possible udev\n"
@@ -923,28 +929,28 @@ cfg(activation_udev_sync_CFG, "udev_sync", activation_CFG_SECTION, 0, CFG_TYPE_B
 	"wake them up.\n"
 	"The '--nodevsync' option overrides this setting.\n")
 
-cfg(activation_udev_rules_CFG, "udev_rules", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_UDEV_RULES, vsn(2, 2, 57), NULL,
+cfg(activation_udev_rules_CFG, "udev_rules", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_UDEV_RULES, vsn(2, 2, 57), NULL, 0, NULL,
 	"Use udev rules to manage LV device nodes and symlinks.\n"
 	"When disabled, LVM will manage the device nodes and\n"
 	"symlinks for active LVs itself.\n"
 	"Manual intervention may be required if this setting is\n"
 	"changed while LVs are active.\n")
 
-cfg(activation_verify_udev_operations_CFG, "verify_udev_operations", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_VERIFY_UDEV_OPERATIONS, vsn(2, 2, 86), NULL,
+cfg(activation_verify_udev_operations_CFG, "verify_udev_operations", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_VERIFY_UDEV_OPERATIONS, vsn(2, 2, 86), NULL, 0, NULL,
 	"Use extra checks in LVM to verify udev operations.\n"
 	"This enables additional checks (and if necessary,\n"
 	"repairs) on entries in the device directory after\n"
 	"udev has completed processing its events.\n"
 	"Useful for diagnosing problems with LVM/udev interactions.\n")
 
-cfg(activation_retry_deactivation_CFG, "retry_deactivation", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_RETRY_DEACTIVATION, vsn(2, 2, 89), NULL,
+cfg(activation_retry_deactivation_CFG, "retry_deactivation", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_RETRY_DEACTIVATION, vsn(2, 2, 89), NULL, 0, NULL,
 	"Retry failed LV deactivation.\n"
 	"If LV deactivation fails, LVM will retry for a few\n"
 	"seconds before failing. This may happen because a\n"
 	"process run from a quick udev rule temporarily opened\n"
 	"the device.\n")
 
-cfg(activation_missing_stripe_filler_CFG, "missing_stripe_filler", activation_CFG_SECTION, CFG_ADVANCED, CFG_TYPE_STRING, DEFAULT_STRIPE_FILLER, vsn(1, 0, 0), NULL,
+cfg(activation_missing_stripe_filler_CFG, "missing_stripe_filler", activation_CFG_SECTION, CFG_ADVANCED, CFG_TYPE_STRING, DEFAULT_STRIPE_FILLER, vsn(1, 0, 0), NULL, 0, NULL,
 	"Method to fill missing stripes when activating an incomplete LV.\n"
 	"Using 'error' will make inaccessible parts of the device return\n"
 	"I/O errors on access.  You can instead use a device path, in which\n"
@@ -952,26 +958,26 @@ cfg(activation_missing_stripe_filler_CFG, "missing_stripe_filler", activation_CF
 	"Using anything other than 'error' with mirrored or snapshotted\n"
 	"volumes is likely to result in data corruption.\n")
 
-cfg(activation_use_linear_target_CFG, "use_linear_target", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_USE_LINEAR_TARGET, vsn(2, 2, 89), NULL,
+cfg(activation_use_linear_target_CFG, "use_linear_target", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_USE_LINEAR_TARGET, vsn(2, 2, 89), NULL, 0, NULL,
 	"Use the linear target to optimize single stripe LVs.\n"
 	"When disabled, the striped target is used. The linear\n"
 	"target is an optimised version of the striped target\n"
 	"that only handles a single stripe.\n")
 
-cfg(activation_reserved_stack_CFG, "reserved_stack", activation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_RESERVED_STACK, vsn(1, 0, 0), NULL,
+cfg(activation_reserved_stack_CFG, "reserved_stack", activation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_RESERVED_STACK, vsn(1, 0, 0), NULL, 0, NULL,
 	"Stack size in KB to reserve for use while devices are suspended.\n"
 	"Insufficent reserve risks I/O deadlock during device suspension.\n")
 
-cfg(activation_reserved_memory_CFG, "reserved_memory", activation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_RESERVED_MEMORY, vsn(1, 0, 0), NULL,
+cfg(activation_reserved_memory_CFG, "reserved_memory", activation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_RESERVED_MEMORY, vsn(1, 0, 0), NULL, 0, NULL,
 	"Memory size in KB to reserve for use while devices are suspended.\n"
 	"Insufficent reserve risks I/O deadlock during device suspension.\n")
 
-cfg(activation_process_priority_CFG, "process_priority", activation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_PROCESS_PRIORITY, vsn(1, 0, 0), NULL,
+cfg(activation_process_priority_CFG, "process_priority", activation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_PROCESS_PRIORITY, vsn(1, 0, 0), NULL, 0, NULL,
 	"Nice value used while devices are suspended.\n"
 	"Use a high priority so that LVs are suspended\n"
 	"for the shortest possible time.\n")
 
-cfg_array(activation_volume_list_CFG, "volume_list", activation_CFG_SECTION, CFG_ALLOW_EMPTY|CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 18), NULL,
+cfg_array(activation_volume_list_CFG, "volume_list", activation_CFG_SECTION, CFG_ALLOW_EMPTY|CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 18), NULL, 0, NULL,
 	"Only LVs selected by this list are activated.\n"
 	"If this list is defined, an LV is only activated\n"
 	"if it matches an entry in this list.\n"
@@ -988,7 +994,7 @@ cfg_array(activation_volume_list_CFG, "volume_list", activation_CFG_SECTION, CFG
 	"Example:\n"
 	"volume_list = [ \"vg1\", \"vg2/lvol1\", \"@tag1\", \"@*\" ]\n")
 
-cfg_array(activation_auto_activation_volume_list_CFG, "auto_activation_volume_list", activation_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 97), NULL,
+cfg_array(activation_auto_activation_volume_list_CFG, "auto_activation_volume_list", activation_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 97), NULL, 0, NULL,
 	"Only LVs selected by this list are auto-activated.\n"
 	"This list works like volume_list, but it is used\n"
 	"only by auto-activation commands. It does not apply\n"
@@ -1018,7 +1024,7 @@ cfg_array(activation_auto_activation_volume_list_CFG, "auto_activation_volume_li
 	"Possible options are: vgname, vgname/lvname, @tag, @*\n"
 	"See volume_list for how these options are matched to LVs.\n")
 
-cfg_array(activation_read_only_volume_list_CFG, "read_only_volume_list", activation_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 89), NULL,
+cfg_array(activation_read_only_volume_list_CFG, "read_only_volume_list", activation_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 89), NULL, 0, NULL,
 	"LVs in this list are activated in read-only mode.\n"
 	"If this list is defined, each LV that is to be activated\n"
 	"is checked against this list, and if it matches, it is\n"
@@ -1028,16 +1034,16 @@ cfg_array(activation_read_only_volume_list_CFG, "read_only_volume_list", activat
 	"Possible options are: vgname, vgname/lvname, @tag, @*\n"
 	"See volume_list for how these options are matched to LVs.\n")
 
-cfg(activation_mirror_region_size_CFG, "mirror_region_size", activation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_RAID_REGION_SIZE, vsn(1, 0, 0), NULL,
+cfg(activation_mirror_region_size_CFG, "mirror_region_size", activation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_RAID_REGION_SIZE, vsn(1, 0, 0), NULL, 0, NULL,
 	"This has been replaced by the activation/raid_region_size setting.\n")
 
-cfg(activation_raid_region_size_CFG, "raid_region_size", activation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_RAID_REGION_SIZE, vsn(2, 2, 99), NULL,
+cfg(activation_raid_region_size_CFG, "raid_region_size", activation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_RAID_REGION_SIZE, vsn(2, 2, 99), NULL, 0, NULL,
 	"Size in KiB of each raid or mirror synchronization region.\n"
 	"For raid or mirror segment types, this is the amount of\n"
 	"data that is copied at once when initializing, or moved\n"
 	"at once by pvmove.\n")
 
-cfg(activation_error_when_full_CFG, "error_when_full", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_ERROR_WHEN_FULL, vsn(2, 2, 115), NULL,
+cfg(activation_error_when_full_CFG, "error_when_full", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_ERROR_WHEN_FULL, vsn(2, 2, 115), NULL, 0, NULL,
 	"Return errors if a thin pool runs out of space.\n"
 	"When enabled, writes to thin LVs immediately return\n"
 	"an error if the thin pool is out of data space.\n"
@@ -1047,13 +1053,13 @@ cfg(activation_error_when_full_CFG, "error_when_full", activation_CFG_SECTION, 0
 	"New thin pools are assigned the behavior defined here.\n"
 	"The '--errorwhenfull y|n' option overrides this setting.\n")
 
-cfg(activation_readahead_CFG, "readahead", activation_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_READ_AHEAD, vsn(1, 0, 23), NULL,
+cfg(activation_readahead_CFG, "readahead", activation_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_READ_AHEAD, vsn(1, 0, 23), NULL, 0, NULL,
 	"Setting to use when there is no readahead setting in metadata.\n"
 	"Possible options are: none, auto.\n"
 	"none - Disable readahead.\n"
 	"auto - Use default value chosen by kernel.\n")
 
-cfg(activation_raid_fault_policy_CFG, "raid_fault_policy", activation_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_RAID_FAULT_POLICY, vsn(2, 2, 89), NULL,
+cfg(activation_raid_fault_policy_CFG, "raid_fault_policy", activation_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_RAID_FAULT_POLICY, vsn(2, 2, 89), NULL, 0, NULL,
 	"Defines how a device failure in a RAID LV is handled.\n"
 	"This includes LVs that have the following segment types:\n"
 	"raid1, raid4, raid5*, and raid6*.\n"
@@ -1071,7 +1077,7 @@ cfg(activation_raid_fault_policy_CFG, "raid_fault_policy", activation_CFG_SECTIO
 	"allocate - Attempt to use any extra physical volumes in the\n"
 	"volume group as spares and replace faulty devices.\n")
 
-cfg_runtime(activation_mirror_image_fault_policy_CFG, "mirror_image_fault_policy", activation_CFG_SECTION, 0, CFG_TYPE_STRING, vsn(2, 2, 57),
+cfg_runtime(activation_mirror_image_fault_policy_CFG, "mirror_image_fault_policy", activation_CFG_SECTION, 0, CFG_TYPE_STRING, vsn(2, 2, 57), 0, NULL,
 	"Defines how a device failure in a 'mirror' LV is handled.\n"
 	"An LV with the 'mirror' segment type is composed of mirror\n"
 	"images (copies) and a mirror log.\n"
@@ -1106,15 +1112,15 @@ cfg_runtime(activation_mirror_image_fault_policy_CFG, "mirror_image_fault_policy
 	"of the mirror. This policy acts like 'remove' if no suitable\n"
 	"device and space can be allocated for the replacement.\n")
 
-cfg(activation_mirror_log_fault_policy_CFG, "mirror_log_fault_policy", activation_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_MIRROR_LOG_FAULT_POLICY, vsn(1, 2, 18), NULL,
+cfg(activation_mirror_log_fault_policy_CFG, "mirror_log_fault_policy", activation_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_MIRROR_LOG_FAULT_POLICY, vsn(1, 2, 18), NULL, 0, NULL,
 	"Defines how a device failure in a 'mirror' log LV is handled.\n"
 	"The mirror_image_fault_policy description for mirrored LVs\n"
 	"also applies to mirrored log LVs.\n")
 
-cfg(activation_mirror_device_fault_policy_CFG, "mirror_device_fault_policy", activation_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_MIRROR_DEVICE_FAULT_POLICY, vsn(1, 2, 10), NULL,
+cfg(activation_mirror_device_fault_policy_CFG, "mirror_device_fault_policy", activation_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_MIRROR_DEVICE_FAULT_POLICY, vsn(1, 2, 10), NULL, 0, NULL,
 	"This has been replaced by the mirror_image_fault_policy setting.\n")
 
-cfg(activation_snapshot_autoextend_threshold_CFG, "snapshot_autoextend_threshold", activation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_SNAPSHOT_AUTOEXTEND_THRESHOLD, vsn(2, 2, 75), NULL,
+cfg(activation_snapshot_autoextend_threshold_CFG, "snapshot_autoextend_threshold", activation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_SNAPSHOT_AUTOEXTEND_THRESHOLD, vsn(2, 2, 75), NULL, 0, NULL,
 	"Auto-extend a snapshot when its usage exceeds this percent.\n"
 	"Setting this to 100 disables automatic extension.\n"
 	"The minimum value is 50 (a smaller value is treated as 50.)\n"
@@ -1128,13 +1134,13 @@ cfg(activation_snapshot_autoextend_threshold_CFG, "snapshot_autoextend_threshold
 	"When the usage exceeds 840M, the snapshot will be extended\n"
 	"to 1.44G, and so on.\n")
 
-cfg(activation_snapshot_autoextend_percent_CFG, "snapshot_autoextend_percent", activation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_SNAPSHOT_AUTOEXTEND_PERCENT, vsn(2, 2, 75), NULL,
+cfg(activation_snapshot_autoextend_percent_CFG, "snapshot_autoextend_percent", activation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_SNAPSHOT_AUTOEXTEND_PERCENT, vsn(2, 2, 75), NULL, 0, NULL,
 	"Auto-extending a snapshot adds this percent extra space.\n"
 	"The amount of additional space added to a snapshot is this\n"
 	"percent of its current size.\n"
 	"Also see snapshot_autoextend_threshold.\n")
 
-cfg(activation_thin_pool_autoextend_threshold_CFG, "thin_pool_autoextend_threshold", activation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA, CFG_TYPE_INT, DEFAULT_THIN_POOL_AUTOEXTEND_THRESHOLD, vsn(2, 2, 89), NULL,
+cfg(activation_thin_pool_autoextend_threshold_CFG, "thin_pool_autoextend_threshold", activation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA, CFG_TYPE_INT, DEFAULT_THIN_POOL_AUTOEXTEND_THRESHOLD, vsn(2, 2, 89), NULL, 0, NULL,
 	"Auto-extend a thin pool when its usage exceeds this percent.\n"
 	"Setting this to 100 disables automatic extension.\n"
 	"The minimum value is 50 (a smaller value is treated as 50.)\n"
@@ -1148,12 +1154,12 @@ cfg(activation_thin_pool_autoextend_threshold_CFG, "thin_pool_autoextend_thresho
 	"When the usage exceeds 840M, the thin pool will be extended\n"
 	"to 1.44G, and so on.\n")
 
-cfg(activation_thin_pool_autoextend_percent_CFG, "thin_pool_autoextend_percent", activation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA, CFG_TYPE_INT, DEFAULT_THIN_POOL_AUTOEXTEND_PERCENT, vsn(2, 2, 89), NULL,
+cfg(activation_thin_pool_autoextend_percent_CFG, "thin_pool_autoextend_percent", activation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA, CFG_TYPE_INT, DEFAULT_THIN_POOL_AUTOEXTEND_PERCENT, vsn(2, 2, 89), NULL, 0, NULL,
 	"Auto-extending a thin pool adds this percent extra space.\n"
 	"The amount of additional space added to a thin pool is this\n"
 	"percent of its current size.\n")
 
-cfg_array(activation_mlock_filter_CFG, "mlock_filter", activation_CFG_SECTION, CFG_DEFAULT_UNDEFINED | CFG_ADVANCED, CFG_TYPE_STRING, NULL, vsn(2, 2, 62), NULL,
+cfg_array(activation_mlock_filter_CFG, "mlock_filter", activation_CFG_SECTION, CFG_DEFAULT_UNDEFINED | CFG_ADVANCED, CFG_TYPE_STRING, NULL, vsn(2, 2, 62), NULL, 0, NULL,
 	"Do not mlock these memory areas.\n"
 	"While activating devices, I/O to devices being\n"
 	"(re)configured is suspended. As a precaution against\n"
@@ -1169,18 +1175,18 @@ cfg_array(activation_mlock_filter_CFG, "mlock_filter", activation_CFG_SECTION, C
 	"Example:\n"
 	"mlock_filter = [ \"locale/locale-archive\", \"gconv/gconv-modules.cache\" ]\n")
 
-cfg(activation_use_mlockall_CFG, "use_mlockall", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_USE_MLOCKALL, vsn(2, 2, 62), NULL,
+cfg(activation_use_mlockall_CFG, "use_mlockall", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_USE_MLOCKALL, vsn(2, 2, 62), NULL, 0, NULL,
 	"Use the old behavior of mlockall to pin all memory.\n"
 	"Prior to version 2.02.62, LVM used mlockall() to pin\n"
 	"the whole process's memory while activating devices.\n")
 
-cfg(activation_monitoring_CFG, "monitoring", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_DMEVENTD_MONITOR, vsn(2, 2, 63), NULL,
+cfg(activation_monitoring_CFG, "monitoring", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_DMEVENTD_MONITOR, vsn(2, 2, 63), NULL, 0, NULL,
 	"Monitor LVs that are activated.\n"
 	"When enabled, LVM will ask dmeventd to monitor LVs\n"
 	"that are activated.\n"
 	"The '--ignoremonitoring' option overrides this setting.\n")
 
-cfg(activation_polling_interval_CFG, "polling_interval", activation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_INTERVAL, vsn(2, 2, 63), NULL,
+cfg(activation_polling_interval_CFG, "polling_interval", activation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_INTERVAL, vsn(2, 2, 63), NULL, 0, NULL,
 	"Check pvmove or lvconvert progress at this interval (seconds)\n"
 	"When pvmove or lvconvert must wait for the kernel to finish\n"
 	"synchronising or merging data, they check and report progress\n"
@@ -1189,7 +1195,7 @@ cfg(activation_polling_interval_CFG, "polling_interval", activation_CFG_SECTION,
 	"there are no progress reports, but the process is awoken\n"
 	"immediately once the operation is complete.\n")
 
-cfg(activation_auto_set_activation_skip_CFG, "auto_set_activation_skip", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_AUTO_SET_ACTIVATION_SKIP, vsn(2,2,99), NULL,
+cfg(activation_auto_set_activation_skip_CFG, "auto_set_activation_skip", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_AUTO_SET_ACTIVATION_SKIP, vsn(2,2,99), NULL, 0, NULL,
 	"Set the activation skip flag on new thin snapshot LVs.\n"
 	"An LV can have a persistent 'activation skip' flag.\n"
 	"The flag causes the LV to be skipped during normal activation.\n"
@@ -1199,7 +1205,7 @@ cfg(activation_auto_set_activation_skip_CFG, "auto_set_activation_skip", activat
 	"set on new thin snapshot LVs.\n"
 	"The '--setactivationskip y|n' option overrides this setting.\n")
 
-cfg(activation_mode_CFG, "activation_mode", activation_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_ACTIVATION_MODE, vsn(2,2,108), NULL,
+cfg(activation_mode_CFG, "activation_mode", activation_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_ACTIVATION_MODE, vsn(2,2,108), NULL, 0, NULL,
 	"How LVs with missing devices are activated.\n"
 	"Possible options are: complete, degraded, partial.\n"
 	"complete - Only allow activation of an LV if all of\n"
@@ -1217,7 +1223,7 @@ cfg(activation_mode_CFG, "activation_mode", activation_CFG_SECTION, 0, CFG_TYPE_
 	"sometimes assist with data recovery.\n"
 	"The '--activationmode' option overrides this setting.\n")
 
-cfg(metadata_pvmetadatacopies_CFG, "pvmetadatacopies", metadata_CFG_SECTION, CFG_ADVANCED, CFG_TYPE_INT, DEFAULT_PVMETADATACOPIES, vsn(1, 0, 0), NULL,
+cfg(metadata_pvmetadatacopies_CFG, "pvmetadatacopies", metadata_CFG_SECTION, CFG_ADVANCED, CFG_TYPE_INT, DEFAULT_PVMETADATACOPIES, vsn(1, 0, 0), NULL, 0, NULL,
 	"Number of copies of metadata to store on each PV.\n"
 	"Possible options are: 0, 1, 2.\n"
 	"If set to 2, two copies of the VG metadata are stored on\n"
@@ -1227,7 +1233,7 @@ cfg(metadata_pvmetadatacopies_CFG, "pvmetadatacopies", metadata_CFG_SECTION, CFG
 	"be useful with VGs containing large numbers of PVs.\n"
 	"The '--pvmetadatacopies' option overrides this setting.\n")
 
-cfg(metadata_vgmetadatacopies_CFG, "vgmetadatacopies", metadata_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_VGMETADATACOPIES, vsn(2, 2, 69), NULL,
+cfg(metadata_vgmetadatacopies_CFG, "vgmetadatacopies", metadata_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_VGMETADATACOPIES, vsn(2, 2, 69), NULL, 0, NULL,
 	"Number of copies of metadata to maintain for each VG.\n"
 	"If set to a non-zero value, LVM automatically chooses which of\n"
 	"the available metadata areas to use to achieve the requested\n"
@@ -1239,7 +1245,7 @@ cfg(metadata_vgmetadatacopies_CFG, "vgmetadatacopies", metadata_CFG_SECTION, 0,
 	"the individual PV level using 'pvchange --metadataignore y|n'.\n"
 	"The '--vgmetadatacopies' option overrides this setting.\n")
 
-cfg(metadata_pvmetadatasize_CFG, "pvmetadatasize", metadata_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_PVMETADATASIZE, vsn(1, 0, 0), NULL,
+cfg(metadata_pvmetadatasize_CFG, "pvmetadatasize", metadata_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_PVMETADATASIZE, vsn(1, 0, 0), NULL, 0, NULL,
 	"Approximate number of sectors to use for each metadata copy.\n"
 	"VGs with large numbers of PVs or LVs, or VGs containing\n"
 	"complex LV structures, may need additional space for VG\n"
@@ -1247,15 +1253,15 @@ cfg(metadata_pvmetadatasize_CFG, "pvmetadatasize", metadata_CFG_SECTION, 0, CFG_
 	"so unused space becomes filled with an archive of the most\n"
 	"recent previous versions of the metadata.\n")
 
-cfg(metadata_pvmetadataignore_CFG, "pvmetadataignore", metadata_CFG_SECTION, CFG_ADVANCED, CFG_TYPE_BOOL, DEFAULT_PVMETADATAIGNORE, vsn(2, 2, 69), NULL,
+cfg(metadata_pvmetadataignore_CFG, "pvmetadataignore", metadata_CFG_SECTION, CFG_ADVANCED, CFG_TYPE_BOOL, DEFAULT_PVMETADATAIGNORE, vsn(2, 2, 69), NULL, 0, NULL,
 	"Ignore metadata areas on a new PV.\n"
 	"If metadata areas on a PV are ignored, LVM will not store\n"
 	"metadata in them.\n"
 	"The '--metadataignore' option overrides this setting.\n")
 
-cfg(metadata_stripesize_CFG, "stripesize", metadata_CFG_SECTION, CFG_ADVANCED, CFG_TYPE_INT, DEFAULT_STRIPESIZE, vsn(1, 0, 0), NULL, NULL)
+cfg(metadata_stripesize_CFG, "stripesize", metadata_CFG_SECTION, CFG_ADVANCED, CFG_TYPE_INT, DEFAULT_STRIPESIZE, vsn(1, 0, 0), NULL, 0, NULL, NULL)
 
-cfg_array(metadata_dirs_CFG, "dirs", metadata_CFG_SECTION, CFG_ADVANCED | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL,
+cfg_array(metadata_dirs_CFG, "dirs", metadata_CFG_SECTION, CFG_ADVANCED | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL, 0, NULL,
 	"Directories holding live copies of text format metadata.\n"
 	"These directories must not be on logical volumes!\n"
 	"It's possible to use LVM with a couple of directories here,\n"
@@ -1270,22 +1276,22 @@ cfg_array(metadata_dirs_CFG, "dirs", metadata_CFG_SECTION, CFG_ADVANCED | CFG_DE
 	"Example:\n"
 	"dirs = [ \"/etc/lvm/metadata\", \"/mnt/disk2/lvm/metadata2\" ]\n")
 
-cfg_section(metadata_disk_areas_CFG_SUBSECTION, "disk_areas", metadata_CFG_SECTION, CFG_UNSUPPORTED | CFG_DEFAULT_UNDEFINED, vsn(1, 0, 0), NULL)
-cfg_section(disk_area_CFG_SUBSECTION, "disk_area", metadata_disk_areas_CFG_SUBSECTION, CFG_NAME_VARIABLE | CFG_UNSUPPORTED | CFG_DEFAULT_UNDEFINED, vsn(1, 0, 0), NULL)
-cfg(disk_area_start_sector_CFG, "start_sector", disk_area_CFG_SUBSECTION, CFG_UNSUPPORTED | CFG_DEFAULT_UNDEFINED, CFG_TYPE_INT, 0, vsn(1, 0, 0), NULL, NULL)
-cfg(disk_area_size_CFG, "size", disk_area_CFG_SUBSECTION, CFG_UNSUPPORTED | CFG_DEFAULT_UNDEFINED, CFG_TYPE_INT, 0, vsn(1, 0, 0), NULL, NULL)
-cfg(disk_area_id_CFG, "id", disk_area_CFG_SUBSECTION, CFG_UNSUPPORTED | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL, NULL)
+cfg_section(metadata_disk_areas_CFG_SUBSECTION, "disk_areas", metadata_CFG_SECTION, CFG_UNSUPPORTED | CFG_DEFAULT_UNDEFINED, vsn(1, 0, 0), 0, NULL, NULL)
+cfg_section(disk_area_CFG_SUBSECTION, "disk_area", metadata_disk_areas_CFG_SUBSECTION, CFG_NAME_VARIABLE | CFG_UNSUPPORTED | CFG_DEFAULT_UNDEFINED, vsn(1, 0, 0), 0, NULL, NULL)
+cfg(disk_area_start_sector_CFG, "start_sector", disk_area_CFG_SUBSECTION, CFG_UNSUPPORTED | CFG_DEFAULT_UNDEFINED, CFG_TYPE_INT, 0, vsn(1, 0, 0), NULL, 0, NULL, NULL)
+cfg(disk_area_size_CFG, "size", disk_area_CFG_SUBSECTION, CFG_UNSUPPORTED | CFG_DEFAULT_UNDEFINED, CFG_TYPE_INT, 0, vsn(1, 0, 0), NULL, 0, NULL, NULL)
+cfg(disk_area_id_CFG, "id", disk_area_CFG_SUBSECTION, CFG_UNSUPPORTED | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL, 0, NULL, NULL)
 
-cfg(report_compact_output_CFG, "compact_output", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_REP_COMPACT_OUTPUT, vsn(2, 2, 115), NULL,
+cfg(report_compact_output_CFG, "compact_output", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_REP_COMPACT_OUTPUT, vsn(2, 2, 115), NULL, 0, NULL,
 	"Do not print empty report fields.\n"
 	"Fields that don't have a value set for any of the rows\n"
 	"reported are skipped and not printed. Compact output is\n"
 	"applicable only if report/buffered is enabled.\n")
 
-cfg(report_aligned_CFG, "aligned", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_REP_ALIGNED, vsn(1, 0, 0), NULL,
+cfg(report_aligned_CFG, "aligned", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_REP_ALIGNED, vsn(1, 0, 0), NULL, 0, NULL,
 	"Align columns in report output.\n")
 
-cfg(report_buffered_CFG, "buffered", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_REP_BUFFERED, vsn(1, 0, 0), NULL,
+cfg(report_buffered_CFG, "buffered", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_REP_BUFFERED, vsn(1, 0, 0), NULL, 0, NULL,
 	"Buffer report output.\n"
 	"When buffered reporting is used, the report's content is appended\n"
 	"incrementally to include each object being reported until the report\n"
@@ -1293,134 +1299,134 @@ cfg(report_buffered_CFG, "buffered", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYP
 	"execution. Otherwise, if buffering is not used, each object is\n"
 	"reported as soon as its processing is finished.\n")
 
-cfg(report_headings_CFG, "headings", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_REP_HEADINGS, vsn(1, 0, 0), NULL,
+cfg(report_headings_CFG, "headings", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_REP_HEADINGS, vsn(1, 0, 0), NULL, 0, NULL,
 	"Show headings for columns on report.\n")
 
-cfg(report_separator_CFG, "separator", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_REP_SEPARATOR, vsn(1, 0, 0), NULL,
+cfg(report_separator_CFG, "separator", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_REP_SEPARATOR, vsn(1, 0, 0), NULL, 0, NULL,
 	"A separator to use on report after each field.\n")
 
-cfg(report_list_item_separator_CFG, "list_item_separator", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_REP_LIST_ITEM_SEPARATOR, vsn(2, 2, 108), NULL,
+cfg(report_list_item_separator_CFG, "list_item_separator", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_REP_LIST_ITEM_SEPARATOR, vsn(2, 2, 108), NULL, 0, NULL,
 	"A separator to use for list items when reported.\n")
 
-cfg(report_prefixes_CFG, "prefixes", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_REP_PREFIXES, vsn(2, 2, 36), NULL,
+cfg(report_prefixes_CFG, "prefixes", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_REP_PREFIXES, vsn(2, 2, 36), NULL, 0, NULL,
 	"Use a field name prefix for each field reported.\n")
 
-cfg(report_quoted_CFG, "quoted", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_REP_QUOTED, vsn(2, 2, 39), NULL,
+cfg(report_quoted_CFG, "quoted", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_REP_QUOTED, vsn(2, 2, 39), NULL, 0, NULL,
 	"Quote field values when using field name prefixes.\n")
 
-cfg(report_colums_as_rows_CFG, "colums_as_rows", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_REP_COLUMNS_AS_ROWS, vsn(1, 0, 0), NULL,
+cfg(report_colums_as_rows_CFG, "colums_as_rows", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_REP_COLUMNS_AS_ROWS, vsn(1, 0, 0), NULL, 0, NULL,
 	"Output each column as a row.\n"
 	"If set, this also implies report/prefixes=1.\n")
 
-cfg(report_binary_values_as_numeric_CFG, "binary_values_as_numeric", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, 0, vsn(2, 2, 108), NULL,
+cfg(report_binary_values_as_numeric_CFG, "binary_values_as_numeric", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, 0, vsn(2, 2, 108), NULL, 0, NULL,
 	"Use binary values 0 or 1 instead of descriptive literal values.\n"
 	"For columns that have exactly two valid values to report\n"
 	"(not counting the 'unknown' value which denotes that the\n"
 	"value could not be determined).\n")
 
-cfg(report_devtypes_sort_CFG, "devtypes_sort", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_DEVTYPES_SORT, vsn(2, 2, 101), NULL,
+cfg(report_devtypes_sort_CFG, "devtypes_sort", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_DEVTYPES_SORT, vsn(2, 2, 101), NULL, 0, NULL,
 	"List of columns to sort by when reporting 'lvm devtypes' command.\n"
 	"See 'lvm devtypes -o help' for the list of possible fields.\n")
 
-cfg(report_devtypes_cols_CFG, "devtypes_cols", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_DEVTYPES_COLS, vsn(2, 2, 101), NULL,
+cfg(report_devtypes_cols_CFG, "devtypes_cols", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_DEVTYPES_COLS, vsn(2, 2, 101), NULL, 0, NULL,
 	"List of columns to report for 'lvm devtypes' command.\n"
 	"See 'lvm devtypes -o help' for the list of possible fields.\n")
 
-cfg(report_devtypes_cols_verbose_CFG, "devtypes_cols_verbose", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_DEVTYPES_COLS_VERB, vsn(2, 2, 101), NULL,
+cfg(report_devtypes_cols_verbose_CFG, "devtypes_cols_verbose", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_DEVTYPES_COLS_VERB, vsn(2, 2, 101), NULL, 0, NULL,
 	"List of columns to report for 'lvm devtypes' command in verbose mode.\n"
 	"See 'lvm devtypes -o help' for the list of possible fields.\n")
 
-cfg(report_lvs_sort_CFG, "lvs_sort", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_LVS_SORT, vsn(1, 0, 0), NULL,
+cfg(report_lvs_sort_CFG, "lvs_sort", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_LVS_SORT, vsn(1, 0, 0), NULL, 0, NULL,
 	"List of columns to sort by when reporting 'lvs' command.\n"
 	"See 'lvs -o help' for the list of possible fields.\n")
 
-cfg(report_lvs_cols_CFG, "lvs_cols", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_LVS_COLS, vsn(1, 0, 0), NULL,
+cfg(report_lvs_cols_CFG, "lvs_cols", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_LVS_COLS, vsn(1, 0, 0), NULL, 0, NULL,
 	"List of columns to report for 'lvs' command.\n"
 	"See 'lvs -o help' for the list of possible fields.\n")
 
-cfg(report_lvs_cols_verbose_CFG, "lvs_cols_verbose", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_LVS_COLS_VERB, vsn(1, 0, 0), NULL,
+cfg(report_lvs_cols_verbose_CFG, "lvs_cols_verbose", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_LVS_COLS_VERB, vsn(1, 0, 0), NULL, 0, NULL,
 	"List of columns to report for 'lvs' command in verbose mode.\n"
 	"See 'lvs -o help' for the list of possible fields.\n")
 
-cfg(report_vgs_sort_CFG, "vgs_sort", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_VGS_SORT, vsn(1, 0, 0), NULL,
+cfg(report_vgs_sort_CFG, "vgs_sort", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_VGS_SORT, vsn(1, 0, 0), NULL, 0, NULL,
 	"List of columns to sort by when reporting 'vgs' command.\n"
 	"See 'vgs -o help' for the list of possible fields.\n")
 
-cfg(report_vgs_cols_CFG, "vgs_cols", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_VGS_COLS, vsn(1, 0, 0), NULL,
+cfg(report_vgs_cols_CFG, "vgs_cols", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_VGS_COLS, vsn(1, 0, 0), NULL, 0, NULL,
 	"List of columns to report for 'vgs' command.\n"
 	"See 'vgs -o help' for the list of possible fields.\n")
 
-cfg(report_vgs_cols_verbose_CFG, "vgs_cols_verbose", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_VGS_COLS_VERB, vsn(1, 0, 0), NULL,
+cfg(report_vgs_cols_verbose_CFG, "vgs_cols_verbose", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_VGS_COLS_VERB, vsn(1, 0, 0), NULL, 0, NULL,
 	"List of columns to report for 'vgs' command in verbose mode.\n"
 	"See 'vgs -o help' for the list of possible fields.\n")
 
-cfg(report_pvs_sort_CFG, "pvs_sort", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_PVS_SORT, vsn(1, 0, 0), NULL,
+cfg(report_pvs_sort_CFG, "pvs_sort", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_PVS_SORT, vsn(1, 0, 0), NULL, 0, NULL,
 	"List of columns to sort by when reporting 'pvs' command.\n"
 	"See 'pvs -o help' for the list of possible fields.\n")
 
-cfg(report_pvs_cols_CFG, "pvs_cols", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_PVS_COLS, vsn(1, 0, 0), NULL,
+cfg(report_pvs_cols_CFG, "pvs_cols", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_PVS_COLS, vsn(1, 0, 0), NULL, 0, NULL,
 	"List of columns to report for 'pvs' command.\n"
 	"See 'pvs -o help' for the list of possible fields.\n")
 
-cfg(report_pvs_cols_verbose_CFG, "pvs_cols_verbose", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_PVS_COLS_VERB, vsn(1, 0, 0), NULL,
+cfg(report_pvs_cols_verbose_CFG, "pvs_cols_verbose", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_PVS_COLS_VERB, vsn(1, 0, 0), NULL, 0, NULL,
 	"List of columns to report for 'pvs' command in verbose mode.\n"
 	"See 'pvs -o help' for the list of possible fields.\n")
 
-cfg(report_segs_sort_CFG, "segs_sort", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_SEGS_SORT, vsn(1, 0, 0), NULL,
+cfg(report_segs_sort_CFG, "segs_sort", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_SEGS_SORT, vsn(1, 0, 0), NULL, 0, NULL,
 	"List of columns to sort by when reporting 'lvs --segments' command.\n"
 	"See 'lvs --segments -o help' for the list of possible fields.\n")
 
-cfg(report_segs_cols_CFG, "segs_cols", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_SEGS_COLS, vsn(1, 0, 0), NULL,
+cfg(report_segs_cols_CFG, "segs_cols", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_SEGS_COLS, vsn(1, 0, 0), NULL, 0, NULL,
 	"List of columns to report for 'lvs --segments' command.\n"
 	"See 'lvs --segments  -o help' for the list of possible fields.\n")
 
-cfg(report_segs_cols_verbose_CFG, "segs_cols_verbose", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_SEGS_COLS_VERB, vsn(1, 0, 0), NULL,
+cfg(report_segs_cols_verbose_CFG, "segs_cols_verbose", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_SEGS_COLS_VERB, vsn(1, 0, 0), NULL, 0, NULL,
 	"List of columns to report for 'lvs --segments' command in verbose mode.\n"
 	"See 'lvs --segments -o help' for the list of possible fields.\n")
 
-cfg(report_pvsegs_sort_CFG, "pvsegs_sort", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_PVSEGS_SORT, vsn(1, 1, 3), NULL,
+cfg(report_pvsegs_sort_CFG, "pvsegs_sort", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_PVSEGS_SORT, vsn(1, 1, 3), NULL, 0, NULL,
 	"List of columns to sort by when reporting 'pvs --segments' command.\n"
 	"See 'pvs --segments -o help' for the list of possible fields.\n")
 
-cfg(report_pvsegs_cols_CFG, "pvsegs_cols", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_PVSEGS_COLS, vsn(1, 1, 3), NULL,
+cfg(report_pvsegs_cols_CFG, "pvsegs_cols", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_PVSEGS_COLS, vsn(1, 1, 3), NULL, 0, NULL,
 	"List of columns to sort by when reporting 'pvs --segments' command.\n"
 	"See 'pvs --segments -o help' for the list of possible fields.\n")
 
-cfg(report_pvsegs_cols_verbose_CFG, "pvsegs_cols_verbose", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_PVSEGS_COLS_VERB, vsn(1, 1, 3), NULL,
+cfg(report_pvsegs_cols_verbose_CFG, "pvsegs_cols_verbose", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_PVSEGS_COLS_VERB, vsn(1, 1, 3), NULL, 0, NULL,
 	"List of columns to sort by when reporting 'pvs --segments' command in verbose mode.\n"
 	"See 'pvs --segments -o help' for the list of possible fields.\n")
 
-cfg(dmeventd_mirror_library_CFG, "mirror_library", dmeventd_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_DMEVENTD_MIRROR_LIB, vsn(1, 2, 3), NULL,
+cfg(dmeventd_mirror_library_CFG, "mirror_library", dmeventd_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_DMEVENTD_MIRROR_LIB, vsn(1, 2, 3), NULL, 0, NULL,
 	"The library dmeventd uses when monitoring a mirror device.\n"
 	"libdevmapper-event-lvm2mirror.so attempts to recover from\n"
 	"failures.  It removes failed devices from a volume group and\n"
 	"reconfigures a mirror as necessary. If no mirror library is\n"
 	"provided, mirrors are not monitored through dmeventd.\n")
 
-cfg(dmeventd_raid_library_CFG, "raid_library", dmeventd_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_DMEVENTD_RAID_LIB, vsn(2, 2, 87), NULL, NULL)
+cfg(dmeventd_raid_library_CFG, "raid_library", dmeventd_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_DMEVENTD_RAID_LIB, vsn(2, 2, 87), NULL, 0, NULL, NULL)
 
-cfg(dmeventd_snapshot_library_CFG, "snapshot_library", dmeventd_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_DMEVENTD_SNAPSHOT_LIB, vsn(1, 2, 26), NULL,
+cfg(dmeventd_snapshot_library_CFG, "snapshot_library", dmeventd_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_DMEVENTD_SNAPSHOT_LIB, vsn(1, 2, 26), NULL, 0, NULL,
 	"The library dmeventd uses when monitoring a snapshot device.\n"
 	"libdevmapper-event-lvm2snapshot.so monitors the filling of\n"
 	"snapshots and emits a warning through syslog when the usage\n"
 	"exceeds 80%. The warning is repeated when 85%, 90% and\n"
 	"95% of the snapshot is filled.\n")
 
-cfg(dmeventd_thin_library_CFG, "thin_library", dmeventd_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_DMEVENTD_THIN_LIB, vsn(2, 2, 89), NULL,
+cfg(dmeventd_thin_library_CFG, "thin_library", dmeventd_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_DMEVENTD_THIN_LIB, vsn(2, 2, 89), NULL, 0, NULL,
 	"The library dmeventd uses when monitoring a thin device.\n"
 	"libdevmapper-event-lvm2thin.so monitors the filling of\n"
 	"a pool and emits a warning through syslog when the usage\n"
 	"exceeds 80%. The warning is repeated when 85%, 90% and\n"
 	"95% of the pool is filled.\n")
 
-cfg(dmeventd_executable_CFG, "executable", dmeventd_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_DMEVENTD_PATH, vsn(2, 2, 73), "@DMEVENTD_PATH@",
+cfg(dmeventd_executable_CFG, "executable", dmeventd_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_DMEVENTD_PATH, vsn(2, 2, 73), "@DMEVENTD_PATH@", 0, NULL,
 	"The full path to the dmeventd binary.\n")
 
-cfg(tags_hosttags_CFG, "hosttags", tags_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_HOSTTAGS, vsn(1, 0, 18), NULL,
+cfg(tags_hosttags_CFG, "hosttags", tags_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_HOSTTAGS, vsn(1, 0, 18), NULL, 0, NULL,
 	"Create a host tag using the machine name.\n"
 	"The machine name is nodename returned by uname(2).\n")
 
-cfg_section(tag_CFG_SUBSECTION, "tag", tags_CFG_SECTION, CFG_NAME_VARIABLE | CFG_DEFAULT_UNDEFINED, vsn(1, 0, 18),
+cfg_section(tag_CFG_SUBSECTION, "tag", tags_CFG_SECTION, CFG_NAME_VARIABLE | CFG_DEFAULT_UNDEFINED, vsn(1, 0, 18), 0, NULL,
 	"Replace this subsection name with a custom tag name.\n"
 	"Multiple subsections like this can be created.\n"
 	"The '@' prefix for tags is optional.\n"
@@ -1436,14 +1442,14 @@ cfg_section(tag_CFG_SUBSECTION, "tag", tags_CFG_SECTION, CFG_NAME_VARIABLE | CFG
 	"bar is given to the hosts named machine1 and machine2.\n"
 	"tags { foo { } bar { host_list = [ \"machine1\", \"machine2\" ] } }\n")
 
-cfg(tag_host_list_CFG, "host_list", tag_CFG_SUBSECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 18), NULL,
+cfg(tag_host_list_CFG, "host_list", tag_CFG_SUBSECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 18), NULL, 0, NULL,
 	"A list of machine names.\n"
 	"These machine names are compared to the nodename\n"
 	"returned by uname(2). If the local machine name\n"
 	"matches an entry in this list, the name of the\n"
 	"subsection is applied to the machine as a 'host tag'.\n")
 
-cfg(local_system_id_CFG, "system_id", local_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 117), NULL,
+cfg(local_system_id_CFG, "system_id", local_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 117), NULL, 0, NULL,
 	"Defines the local system ID for lvmlocal mode.\n"
 	"This is used when global/system_id_source is set\n"
 	"to 'lvmlocal' in the main configuration file,\n"
@@ -1458,7 +1464,7 @@ cfg(local_system_id_CFG, "system_id", local_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_D
 	"Set the system_id to the string 'host1'.\n"
 	"system_id = \"host1\"\n")
 
-cfg_array(local_extra_system_ids_CFG, "extra_system_ids", local_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 117), NULL,
+cfg_array(local_extra_system_ids_CFG, "extra_system_ids", local_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 117), NULL, 0, NULL,
 	"A list of extra VG system IDs the local host can access.\n"
 	"VGs with the system IDs listed here (in addition\n"
 	"to the host's own system ID) can be fully accessed\n"
@@ -1468,4 +1474,4 @@ cfg_array(local_extra_system_ids_CFG, "extra_system_ids", local_CFG_SECTION, CFG
 	"Use this only after consulting 'man lvmsystemid'\n"
 	"to be certain of correct usage and possible dangers.\n")
 
-cfg(CFG_COUNT, NULL, root_CFG_SECTION, 0, CFG_TYPE_INT, 0, vsn(0, 0, 0), NULL, NULL)
+cfg(CFG_COUNT, NULL, root_CFG_SECTION, 0, CFG_TYPE_INT, 0, vsn(0, 0, 0), NULL, 0, NULL, NULL)


