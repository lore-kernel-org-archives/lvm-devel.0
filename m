From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 15 May 2015 15:13:30 +0000 (UTC)
Subject: master - config: add comments to match current example.conf
Message-ID: <20150515151330.8923E61277@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a98ceceb1d101f0b19a6115f406e23f13feab5ae
Commit:        a98ceceb1d101f0b19a6115f406e23f13feab5ae
Parent:        797c18d543947f4c2777b4dcf3ceff57cb55352b
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu May 14 16:08:50 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri May 15 10:13:17 2015 -0500

config: add comments to match current example.conf

Use CFG_DEFAULT_COMMENTED and CFG_DEFAULT_UNDEFINED to
replicate the existing comments in example.conf.

Fix host_list to be cfg_array.

UNDEFINED is only used if the value depends on other
system/kernel values outside of lvm.  The most common
case is when dm-thin or dm-cache have built-in default
settings in the kernel, and lvm will use those built-in
default values unless the corresponding lvm config setting
is set.

COMMENTED is used to comment out the default setting in
lvm.conf.  The effect is that if the LVM version is
upgraded, and the new version of LVM has new built-in
default values, the new defaults are used by LVM unless
the previous default value was set (uncommented) in lvm.conf.
---
 lib/config/config_settings.h |  198 +++++++++++++++++++++++-------------------
 1 files changed, 107 insertions(+), 91 deletions(-)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 4e3823e..e255392 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -23,7 +23,7 @@
  * - define a configuration array of one or more types:
  *   cfg_array(id, name, parent, flags, types, default_value, since_version, unconfigured_default_value, deprecated_since_version, deprecation_comment, comment)
  *
-*
+ *
  * If default value can't be assigned statically because it depends on some
  * run-time checks or if it depends on other settings already defined,
  * the configuration setting  or array can be defined with the
@@ -47,7 +47,7 @@
  *                                 CFG_UNSUPPORTED - this node is not officially supported and it's used primarily by developers
  *                                 CFG_PROFILABLE - this node is customizable by a profile
  *                                 CFG_PROFILABLE_METADATA - profilable and attachable to VG/LV metadata
- *                                 CFG_DEFAULT_UNDEFINED - node's default value is undefined
+ *                                 CFG_DEFAULT_UNDEFINED - node's default value is undefined (depends on other system/kernel values outside of lvm)
  *                                 CFG_DEFAULT_COMMENTED - node's default value is commented out on output
  *                                 CFG_DISABLED - configuration is disabled (defaults always used)
  *
@@ -92,6 +92,22 @@
  * comment:                    Comment used in configuration dumps. The very first line is the
  *                             summarizing comment.
  *                             (see also lvmconfig ... --withcomments and --withsummary)
+ *
+ *
+ * Difference between CFG_DEFAULT_COMMENTED and CFG_DEFAULT_UNDEFINED:
+ *
+ * UNDEFINED is only used if the value depends on other
+ * system/kernel values outside of lvm.  The most common
+ * case is when dm-thin or dm-cache have built-in default
+ * settings in the kernel, and lvm will use those built-in
+ * default values unless the corresponding lvm config setting
+ * is set.
+ *
+ * COMMENTED is used to comment out the default setting in
+ * lvm.conf.  The effect is that if the LVM version is
+ * upgraded, and the new version of LVM has new built-in
+ * default values, the new defaults are used by LVM unless
+ * the previous default value was set (uncommented) in lvm.conf.
  */
 #include "defaults.h"
 
@@ -124,15 +140,15 @@ cfg_section(global_CFG_SECTION, "global", root_CFG_SECTION, CFG_PROFILABLE, vsn(
 
 cfg_section(activation_CFG_SECTION, "activation", root_CFG_SECTION, CFG_PROFILABLE, vsn(1, 0, 0), 0, NULL, NULL)
 
-cfg_section(metadata_CFG_SECTION, "metadata", root_CFG_SECTION, 0, vsn(1, 0, 0), 0, NULL, NULL)
+cfg_section(metadata_CFG_SECTION, "metadata", root_CFG_SECTION, CFG_DEFAULT_COMMENTED, vsn(1, 0, 0), 0, NULL, NULL)
 
-cfg_section(report_CFG_SECTION, "report", root_CFG_SECTION, CFG_PROFILABLE, vsn(1, 0, 0), 0, NULL,
+cfg_section(report_CFG_SECTION, "report", root_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, vsn(1, 0, 0), 0, NULL,
 	"LVM report command output formatting.\n")
 
 cfg_section(dmeventd_CFG_SECTION, "dmeventd", root_CFG_SECTION, 0, vsn(1, 2, 3), 0, NULL,
 	"Settings for the LVM event daemon.\n")
 
-cfg_section(tags_CFG_SECTION, "tags", root_CFG_SECTION, 0, vsn(1, 0, 18), 0, NULL,
+cfg_section(tags_CFG_SECTION, "tags", root_CFG_SECTION, CFG_DEFAULT_COMMENTED, vsn(1, 0, 18), 0, NULL,
 	"Host tag settings.\n")
 
 cfg_section(local_CFG_SECTION, "local", root_CFG_SECTION, 0, vsn(2, 2, 117), 0, NULL,
@@ -159,7 +175,7 @@ cfg(devices_dir_CFG, "dir", devices_CFG_SECTION, CFG_ADVANCED, CFG_TYPE_STRING,
 cfg_array(devices_scan_CFG, "scan", devices_CFG_SECTION, CFG_ADVANCED, CFG_TYPE_STRING, "#S/dev", vsn(1, 0, 0), NULL, 0, NULL,
 	"Directories containing device nodes to use with LVM.\n")
 
-cfg_array(devices_loopfiles_CFG, "loopfiles", devices_CFG_SECTION, CFG_DEFAULT_UNDEFINED | CFG_UNSUPPORTED, CFG_TYPE_STRING, NULL, vsn(1, 2, 0), NULL, 0, NULL, NULL)
+cfg_array(devices_loopfiles_CFG, "loopfiles", devices_CFG_SECTION, CFG_DEFAULT_COMMENTED | CFG_UNSUPPORTED, CFG_TYPE_STRING, NULL, vsn(1, 2, 0), NULL, 0, NULL, NULL)
 
 cfg(devices_obtain_device_list_from_udev_CFG, "obtain_device_list_from_udev", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_OBTAIN_DEVICE_LIST_FROM_UDEV, vsn(2, 2, 85), NULL, 0, NULL,
 	"Obtain the list of available devices from udev.\n"
@@ -186,7 +202,7 @@ cfg(devices_external_device_info_source_CFG, "external_device_info_source", devi
 	"udev - Reuse existing udev database records. Applicable\n"
 	"only if LVM is compiled with udev support.\n")
 
-cfg_array(devices_preferred_names_CFG, "preferred_names", devices_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 2, 19), NULL, 0, NULL,
+cfg_array(devices_preferred_names_CFG, "preferred_names", devices_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_COMMENTED , CFG_TYPE_STRING, NULL, vsn(1, 2, 19), NULL, 0, NULL,
 	"Select which path name to display for a block device.\n"
 	"If multiple path names exist for a block device,\n"
 	"and LVM needs to display a name for the device,\n"
@@ -203,7 +219,7 @@ cfg_array(devices_preferred_names_CFG, "preferred_names", devices_CFG_SECTION, C
 	"Example:\n"
 	"preferred_names = [ \"^/dev/mpath/\", \"^/dev/mapper/mpath\", \"^/dev/[hs]d\" ]\n")
 
-cfg_array(devices_filter_CFG, "filter", devices_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL, 0, NULL,
+cfg_array(devices_filter_CFG, "filter", devices_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL, 0, NULL,
 	"Limit the block devices that are used by LVM commands.\n"
 	"This is a list of regular expressions used to accept or\n"
 	"reject block device path names.  Each regex is delimited\n"
@@ -238,7 +254,7 @@ cfg_array(devices_filter_CFG, "filter", devices_CFG_SECTION, CFG_DEFAULT_UNDEFIN
 	"Use anchors to be very specific.\n"
 	"filter = [ \"a|^/dev/hda8$|\", \"r|.*/|\" ]\n")
 
-cfg_array(devices_global_filter_CFG, "global_filter", devices_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 98), NULL, 0, NULL,
+cfg_array(devices_global_filter_CFG, "global_filter", devices_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, NULL, vsn(2, 2, 98), NULL, 0, NULL,
 	"Limit the block devices that are used by LVM system components.\n"
 	"Because devices/filter may be overridden from the command line,\n"
 	"it is not suitable for system-wide device filtering, e.g. udev\n"
@@ -265,7 +281,7 @@ cfg(devices_cache_file_prefix_CFG, "cache_file_prefix", devices_CFG_SECTION, CFG
 cfg(devices_write_cache_state_CFG, "write_cache_state", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, 1, vsn(1, 0, 0), NULL, 0, NULL,
 	"Enable/disable writing the cache file. See devices/cache_dir.\n")
 
-cfg_array(devices_types_CFG, "types", devices_CFG_SECTION, CFG_DEFAULT_UNDEFINED | CFG_ADVANCED, CFG_TYPE_INT | CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL, 0, NULL,
+cfg_array(devices_types_CFG, "types", devices_CFG_SECTION, CFG_DEFAULT_COMMENTED| CFG_ADVANCED, CFG_TYPE_INT | CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL, 0, NULL,
 	"List of additional acceptable block device types.\n"
 	"These are of device type names from /proc/devices,\n"
 	"followed by the maximum number of partitions.\n"
@@ -293,7 +309,7 @@ cfg(devices_md_chunk_alignment_CFG, "md_chunk_alignment", devices_CFG_SECTION, 0
 	"Align PV data blocks with md device's stripe-width.\n"
 	"This applies if a PV is placed directly on an md device.\n")
 
-cfg(devices_default_data_alignment_CFG, "default_data_alignment", devices_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_DATA_ALIGNMENT, vsn(2, 2, 75), NULL, 0, NULL,
+cfg(devices_default_data_alignment_CFG, "default_data_alignment", devices_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_DATA_ALIGNMENT, vsn(2, 2, 75), NULL, 0, NULL,
 	"Default alignment of the start of a PV data area in MB.\n"
 	"If set to 0, a value of 64KB will be used.\n"
 	"Set to 1 for 1MiB, 2 for 2MiB, etc.\n")
@@ -382,7 +398,7 @@ cfg(devices_issue_discards_CFG, "issue_discards", devices_CFG_SECTION, 0, CFG_TY
 	"and thinly provisioned LUNs generally do.  If enabled, discards\n"
 	"will only be issued if both the storage and kernel provide support.\n")
 
-cfg_array(allocation_cling_tag_list_CFG, "cling_tag_list", allocation_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 77), NULL, 0, NULL,
+cfg_array(allocation_cling_tag_list_CFG, "cling_tag_list", allocation_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, NULL, vsn(2, 2, 77), NULL, 0, NULL,
 	"Advise LVM which PVs to use when searching for new space.\n"
 	"When searching for free space to extend an LV, the 'cling'\n"
 	"allocation policy will choose space on the same PVs as the last\n"
@@ -444,7 +460,7 @@ cfg(allocation_mirror_logs_require_separate_pvs_CFG, "mirror_logs_require_separa
 cfg(allocation_cache_pool_metadata_require_separate_pvs_CFG, "cache_pool_metadata_require_separate_pvs", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_CACHE_POOL_METADATA_REQUIRE_SEPARATE_PVS, vsn(2, 2, 106), NULL, 0, NULL,
 	"Cache pool metadata and data will always use different PVs.\n")
 
-cfg(allocation_cache_pool_cachemode_CFG, "cache_pool_cachemode", allocation_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_CACHE_POOL_CACHEMODE, vsn(2, 2, 113), NULL, 0, NULL,
+cfg(allocation_cache_pool_cachemode_CFG, "cache_pool_cachemode", allocation_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, DEFAULT_CACHE_POOL_CACHEMODE, vsn(2, 2, 113), NULL, 0, NULL,
 	"The default cache mode used for new cache pools.\n"
 	"Possible options are: writethrough, writeback.\n"
 	"writethrough - Data blocks are immediately written from\n"
@@ -467,15 +483,15 @@ cfg_runtime(allocation_cache_pool_chunk_size_CFG, "cache_pool_chunk_size", alloc
 cfg(allocation_thin_pool_metadata_require_separate_pvs_CFG, "thin_pool_metadata_require_separate_pvs", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_THIN_POOL_METADATA_REQUIRE_SEPARATE_PVS, vsn(2, 2, 89), NULL, 0, NULL,
 	"Thin pool metdata and data will always use different PVs.\n")
 
-cfg(allocation_thin_pool_zero_CFG, "thin_pool_zero", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA, CFG_TYPE_BOOL, DEFAULT_THIN_POOL_ZERO, vsn(2, 2, 99), NULL, 0, NULL,
+cfg(allocation_thin_pool_zero_CFG, "thin_pool_zero", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_UNDEFINED, CFG_TYPE_BOOL, DEFAULT_THIN_POOL_ZERO, vsn(2, 2, 99), NULL, 0, NULL,
 	"Thin pool data chunks are zeroed before they are first used.\n"
 	"Zeroing with a larger thin pool chunk size reduces performance.\n")
 
-cfg(allocation_thin_pool_discards_CFG, "thin_pool_discards", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA, CFG_TYPE_STRING, DEFAULT_THIN_POOL_DISCARDS, vsn(2, 2, 99), NULL, 0, NULL,
+cfg(allocation_thin_pool_discards_CFG, "thin_pool_discards", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, DEFAULT_THIN_POOL_DISCARDS, vsn(2, 2, 99), NULL, 0, NULL,
 	"The discards behaviour of thin pool volumes.\n"
 	"Possible options are: ignore, nopassdown, passdown.\n")
 
-cfg(allocation_thin_pool_chunk_size_policy_CFG, "thin_pool_chunk_size_policy", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA, CFG_TYPE_STRING, DEFAULT_THIN_POOL_CHUNK_SIZE_POLICY, vsn(2, 2, 101), NULL, 0, NULL,
+cfg(allocation_thin_pool_chunk_size_policy_CFG, "thin_pool_chunk_size_policy", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, DEFAULT_THIN_POOL_CHUNK_SIZE_POLICY, vsn(2, 2, 101), NULL, 0, NULL,
 	"The chunk size calculation policy for thin pool volumes.\n"
 	"Possible options are: generic, performance.\n"
 	"generic - If thin_pool_chunk_size is defined, use it.\n"
@@ -496,7 +512,7 @@ cfg_runtime(allocation_thin_pool_chunk_size_CFG, "thin_pool_chunk_size", allocat
 	"chunk size starting from 64KB.  Supported values are in\n"
 	"the range 64 to 1048576.\n")
 
-cfg(allocation_physical_extent_size_CFG, "physical_extent_size", allocation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_EXTENT_SIZE, vsn(2, 2, 112), NULL, 0, NULL,
+cfg(allocation_physical_extent_size_CFG, "physical_extent_size", allocation_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_EXTENT_SIZE, vsn(2, 2, 112), NULL, 0, NULL,
 	"Default physical extent size to use for new VGs (in KB).\n")
 
 cfg(log_verbose_CFG, "verbose", log_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_VERBOSE, vsn(1, 0, 0), NULL, 0, NULL,
@@ -516,7 +532,7 @@ cfg(log_silent_CFG, "silent", log_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_SILENT,
 cfg(log_syslog_CFG, "syslog", log_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_SYSLOG, vsn(1, 0, 0), NULL, 0, NULL,
 	"Send log messages through syslog.\n")
 
-cfg(log_file_CFG, "file", log_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL, 0, NULL,
+cfg(log_file_CFG, "file", log_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL, 0, NULL,
 	"Write error and debug log messages to a file specified here.\n")
 
 cfg(log_overwrite_CFG, "overwrite", log_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_OVERWRITE, vsn(1, 0, 0), NULL, 0, NULL,
@@ -544,7 +560,7 @@ cfg(log_activation_CFG, "activation", log_CFG_SECTION, 0, CFG_TYPE_BOOL, 0, vsn(
 	"Log messages during activation.\n"
 	"Don't use this in low memory situations (can deadlock).\n")
 
-cfg(log_activate_file_CFG, "activate_file", log_CFG_SECTION, CFG_DEFAULT_UNDEFINED | CFG_UNSUPPORTED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL, 0, NULL, NULL)
+cfg(log_activate_file_CFG, "activate_file", log_CFG_SECTION, CFG_DEFAULT_COMMENTED | CFG_UNSUPPORTED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL, 0, NULL, NULL)
 
 cfg_array(log_debug_classes_CFG, "debug_classes", log_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, "#Smemory#Sdevices#Sactivation#Sallocation#Slvmetad#Smetadata#Scache#Slocking#Slvmpolld", vsn(2, 2, 99), NULL, 0, NULL,
 	"Select log messages by class.\n"
@@ -611,7 +627,7 @@ cfg(global_activation_CFG, "activation", global_CFG_SECTION, 0, CFG_TYPE_BOOL, D
 	"is not present in the kernel, disabling this should suppress\n"
 	"the error messages.\n")
 
-cfg(global_fallback_to_lvm1_CFG, "fallback_to_lvm1", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_FALLBACK_TO_LVM1, vsn(1, 0, 18), NULL, 0, NULL,
+cfg(global_fallback_to_lvm1_CFG, "fallback_to_lvm1", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_FALLBACK_TO_LVM1, vsn(1, 0, 18), NULL, 0, NULL,
 	"Try running LVM1 tools if LVM cannot communicate with DM.\n"
 	"This option only applies to 2.4 kernels and is provided to\n"
 	"help switch between device-mapper kernels and LVM1 kernels.\n"
@@ -619,17 +635,17 @@ cfg(global_fallback_to_lvm1_CFG, "fallback_to_lvm1", global_CFG_SECTION, 0, CFG_
 	"e.g. vgscan.lvm1. They will stop working once the lvm2\n"
 	"on-disk metadata format is used.\n")
 
-cfg(global_format_CFG, "format", global_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_FORMAT, vsn(1, 0, 0), NULL, 0, NULL,
+cfg(global_format_CFG, "format", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_FORMAT, vsn(1, 0, 0), NULL, 0, NULL,
 	"The default metadata format that commands should use.\n"
 	"\"lvm1\" or \"lvm2\".\n"
 	"The command line override is -M1 or -M2.\n")
 
-cfg_array(global_format_libraries_CFG, "format_libraries", global_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL, 0, NULL,
+cfg_array(global_format_libraries_CFG, "format_libraries", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL, 0, NULL,
 	"Shared libraries that process different metadata formats.\n"
 	"If support for LVM1 metadata was compiled as a shared library use\n"
 	"format_libraries = \"liblvm2format1.so\"\n")
 
-cfg_array(global_segment_libraries_CFG, "segment_libraries", global_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 18), NULL, 0, NULL, NULL)
+cfg_array(global_segment_libraries_CFG, "segment_libraries", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, NULL, vsn(1, 0, 18), NULL, 0, NULL, NULL)
 
 cfg(global_proc_CFG, "proc", global_CFG_SECTION, CFG_ADVANCED, CFG_TYPE_STRING, DEFAULT_PROC_DIR, vsn(1, 0, 0), NULL, 0, NULL,
 	"Location of proc filesystem.\n")
@@ -694,10 +710,10 @@ cfg(global_prioritise_write_locks_CFG, "prioritise_write_locks", global_CFG_SECT
 	"This option only affects locking_type 1 viz.\n"
 	"local file-based locking.\n")
 
-cfg(global_library_dir_CFG, "library_dir", global_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL, 0, NULL,
+cfg(global_library_dir_CFG, "library_dir", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL, 0, NULL,
 	"Search this directory first for shared libraries.\n")
 
-cfg(global_locking_library_CFG, "locking_library", global_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, DEFAULT_LOCKING_LIB, vsn(1, 0, 0), NULL, 0, NULL,
+cfg(global_locking_library_CFG, "locking_library", global_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_LOCKING_LIB, vsn(1, 0, 0), NULL, 0, NULL,
 	"The external locking library to use for locking_type 2.\n")
 
 cfg(global_abort_on_internal_errors_CFG, "abort_on_internal_errors", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_ABORT_ON_INTERNAL_ERRORS, vsn(2, 2, 57), NULL, 0, NULL,
@@ -773,7 +789,7 @@ cfg(global_sparse_segtype_default_CFG, "sparse_segtype_default", global_CFG_SECT
 	"when more data is used.  It also supports full snapshots.\n"
 	"The '--type snapshot|thin' option overrides this setting.\n")
 
-cfg(global_lvdisplay_shows_full_device_path_CFG, "lvdisplay_shows_full_device_path", global_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_LVDISPLAY_SHOWS_FULL_DEVICE_PATH, vsn(2, 2, 89), NULL, 0, NULL,
+cfg(global_lvdisplay_shows_full_device_path_CFG, "lvdisplay_shows_full_device_path", global_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_LVDISPLAY_SHOWS_FULL_DEVICE_PATH, vsn(2, 2, 89), NULL, 0, NULL,
 	"The default format for displaying LV names in lvdisplay was changed\n"
 	"in version 2.02.89 to show the LV name and path separately.\n"
 	"Previously this was always shown as /dev/vgname/lvname even when that\n"
@@ -814,7 +830,7 @@ cfg(global_use_lvmetad_CFG, "use_lvmetad", global_CFG_SECTION, 0, CFG_TYPE_BOOL,
 	"LVM prints warnings and ignores lvmetad if this combination\n"
 	"is seen.\n")
 
-cfg(global_thin_check_executable_CFG, "thin_check_executable", global_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, THIN_CHECK_CMD, vsn(2, 2, 94), "@THIN_CHECK_CMD@", 0, NULL,
+cfg(global_thin_check_executable_CFG, "thin_check_executable", global_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, THIN_CHECK_CMD, vsn(2, 2, 94), "@THIN_CHECK_CMD@", 0, NULL,
 	"The full path to the thin_check command.\n"
 	"LVM uses this command to check that a thin metadata\n"
 	"device is in a usable state.\n"
@@ -826,19 +842,19 @@ cfg(global_thin_check_executable_CFG, "thin_check_executable", global_CFG_SECTIO
 	"The thin tools are available from the package\n"
 	"device-mapper-persistent-data.\n")
 
-cfg(global_thin_dump_executable_CFG, "thin_dump_executable", global_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, THIN_DUMP_CMD, vsn(2, 2, 100), "@THIN_DUMP_CMD@", 0, NULL,
+cfg(global_thin_dump_executable_CFG, "thin_dump_executable", global_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, THIN_DUMP_CMD, vsn(2, 2, 100), "@THIN_DUMP_CMD@", 0, NULL,
 	"The full path to the thin_dump command.\n"
 	"LVM uses this command to dump thin pool metadata.\n"
 	"(For thin tools, see thin_check_executable.)\n")
 
-cfg(global_thin_repair_executable_CFG, "thin_repair_executable", global_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, THIN_REPAIR_CMD, vsn(2, 2, 100), "@THIN_REPAIR_CMD@", 0, NULL,
+cfg(global_thin_repair_executable_CFG, "thin_repair_executable", global_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, THIN_REPAIR_CMD, vsn(2, 2, 100), "@THIN_REPAIR_CMD@", 0, NULL,
 	"The full path to the thin_repair command.\n"
 	"LVM uses this command to repair a thin metadata device\n"
 	"if it is in an unusable state.\n"
 	"Also see thin_repair_options.\n"
 	"(For thin tools, see thin_check_executable.)\n")
 
-cfg_array(global_thin_check_options_CFG, "thin_check_options", global_CFG_SECTION, 0, CFG_TYPE_STRING, "#S" DEFAULT_THIN_CHECK_OPTION1 "#S" DEFAULT_THIN_CHECK_OPTION2, vsn(2, 2, 96), NULL, 0, NULL,
+cfg_array(global_thin_check_options_CFG, "thin_check_options", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, "#S" DEFAULT_THIN_CHECK_OPTION1 "#S" DEFAULT_THIN_CHECK_OPTION2, vsn(2, 2, 96), NULL, 0, NULL,
 	"List of options passed to the thin_check command.\n"
 	"With thin_check version 2.1 or newer you can add\n"
 	"--ignore-non-fatal-errors to let it pass through\n"
@@ -846,10 +862,10 @@ cfg_array(global_thin_check_options_CFG, "thin_check_options", global_CFG_SECTIO
 	"With thin_check version 3.2 or newer you should add\n"
 	"--clear-needs-check-flag.\n")
 
-cfg_array(global_thin_repair_options_CFG, "thin_repair_options", global_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, "#S" DEFAULT_THIN_REPAIR_OPTIONS, vsn(2, 2, 100), NULL, 0, NULL,
+cfg_array(global_thin_repair_options_CFG, "thin_repair_options", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, "#S" DEFAULT_THIN_REPAIR_OPTIONS, vsn(2, 2, 100), NULL, 0, NULL,
 	"List of options passed to the thin_repair command.\n")
 
-cfg_array(global_thin_disabled_features_CFG, "thin_disabled_features", global_CFG_SECTION, CFG_DEFAULT_UNDEFINED | CFG_ALLOW_EMPTY, CFG_TYPE_STRING, NULL, vsn(2, 2, 99), NULL, 0, NULL,
+cfg_array(global_thin_disabled_features_CFG, "thin_disabled_features", global_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, NULL, vsn(2, 2, 99), NULL, 0, NULL,
 	"Features to not use in the thin driver.\n"
 	"This can be helpful for testing, or to avoid\n"
 	"using a feature that is causing problems.\n"
@@ -859,7 +875,7 @@ cfg_array(global_thin_disabled_features_CFG, "thin_disabled_features", global_CF
 	"Example:\n"
 	"thin_disabled_features = [ \"discards\", \"block_size\" ]\n")
 
-cfg(global_cache_check_executable_CFG, "cache_check_executable", global_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, CACHE_CHECK_CMD, vsn(2, 2, 108), "@CACHE_CHECK_CMD@", 0, NULL,
+cfg(global_cache_check_executable_CFG, "cache_check_executable", global_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, CACHE_CHECK_CMD, vsn(2, 2, 108), "@CACHE_CHECK_CMD@", 0, NULL,
 	"The full path to the cache_check command.\n"
 	"LVM uses this command to check that a cache metadata\n"
 	"device is in a usable state.\n"
@@ -871,22 +887,22 @@ cfg(global_cache_check_executable_CFG, "cache_check_executable", global_CFG_SECT
 	"The cache tools are available from the package\n"
 	"device-mapper-persistent-data.\n")
 
-cfg(global_cache_dump_executable_CFG, "cache_dump_executable", global_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, CACHE_DUMP_CMD, vsn(2, 2, 108), "@CACHE_DUMP_CMD@", 0, NULL,
+cfg(global_cache_dump_executable_CFG, "cache_dump_executable", global_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, CACHE_DUMP_CMD, vsn(2, 2, 108), "@CACHE_DUMP_CMD@", 0, NULL,
 	"The full path to the cache_dump command.\n"
 	"LVM uses this command to dump cache pool metadata.\n"
 	"(For cache tools, see cache_check_executable.)\n")
 
-cfg(global_cache_repair_executable_CFG, "cache_repair_executable", global_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, CACHE_REPAIR_CMD, vsn(2, 2, 108), "@CACHE_REPAIR_CMD@", 0, NULL,
+cfg(global_cache_repair_executable_CFG, "cache_repair_executable", global_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, CACHE_REPAIR_CMD, vsn(2, 2, 108), "@CACHE_REPAIR_CMD@", 0, NULL,
 	"The full path to the cache_repair command.\n"
 	"LVM uses this command to repair a cache metadata device\n"
 	"if it is in an unusable state.\n"
 	"Also see cache_repair_options.\n"
 	"(For cache tools, see cache_check_executable.)\n")
 
-cfg_array(global_cache_check_options_CFG, "cache_check_options", global_CFG_SECTION, 0, CFG_TYPE_STRING, "#S" DEFAULT_CACHE_CHECK_OPTION1, vsn(2, 2, 108), NULL, 0, NULL,
+cfg_array(global_cache_check_options_CFG, "cache_check_options", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, "#S" DEFAULT_CACHE_CHECK_OPTION1, vsn(2, 2, 108), NULL, 0, NULL,
 	"List of options passed to the cache_check command.\n")
 
-cfg_array(global_cache_repair_options_CFG, "cache_repair_options", global_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, "#S" DEFAULT_CACHE_REPAIR_OPTIONS, vsn(2, 2, 108), NULL, 0, NULL,
+cfg_array(global_cache_repair_options_CFG, "cache_repair_options", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, "#S" DEFAULT_CACHE_REPAIR_OPTIONS, vsn(2, 2, 108), NULL, 0, NULL,
 	"List of options passed to the cache_repair command.\n")
 
 cfg(global_system_id_source_CFG, "system_id_source", global_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_SYSTEM_ID_SOURCE, vsn(2, 2, 117), NULL, 0, NULL,
@@ -909,7 +925,7 @@ cfg(global_system_id_source_CFG, "system_id_source", global_CFG_SECTION, 0, CFG_
 	"file - Use the contents of another file (system_id_file) to set\n"
 	"the system ID.\n")
 
-cfg(global_system_id_file_CFG, "system_id_file", global_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 117), NULL, 0, NULL,
+cfg(global_system_id_file_CFG, "system_id_file", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, NULL, vsn(2, 2, 117), NULL, 0, NULL,
 	"The full path to the file containing a system ID.\n"
 	"This is used when system_id_source is set to 'file'.\n"
 	"Comments starting with the character # are ignored.\n")
@@ -988,7 +1004,7 @@ cfg(activation_process_priority_CFG, "process_priority", activation_CFG_SECTION,
 	"Use a high priority so that LVs are suspended\n"
 	"for the shortest possible time.\n")
 
-cfg_array(activation_volume_list_CFG, "volume_list", activation_CFG_SECTION, CFG_ALLOW_EMPTY|CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 18), NULL, 0, NULL,
+cfg_array(activation_volume_list_CFG, "volume_list", activation_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, NULL, vsn(1, 0, 18), NULL, 0, NULL,
 	"Only LVs selected by this list are activated.\n"
 	"If this list is defined, an LV is only activated\n"
 	"if it matches an entry in this list.\n"
@@ -1005,7 +1021,7 @@ cfg_array(activation_volume_list_CFG, "volume_list", activation_CFG_SECTION, CFG
 	"Example:\n"
 	"volume_list = [ \"vg1\", \"vg2/lvol1\", \"@tag1\", \"@*\" ]\n")
 
-cfg_array(activation_auto_activation_volume_list_CFG, "auto_activation_volume_list", activation_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 97), NULL, 0, NULL,
+cfg_array(activation_auto_activation_volume_list_CFG, "auto_activation_volume_list", activation_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, NULL, vsn(2, 2, 97), NULL, 0, NULL,
 	"Only LVs selected by this list are auto-activated.\n"
 	"This list works like volume_list, but it is used\n"
 	"only by auto-activation commands. It does not apply\n"
@@ -1035,7 +1051,7 @@ cfg_array(activation_auto_activation_volume_list_CFG, "auto_activation_volume_li
 	"Possible options are: vgname, vgname/lvname, @tag, @*\n"
 	"See volume_list for how these options are matched to LVs.\n")
 
-cfg_array(activation_read_only_volume_list_CFG, "read_only_volume_list", activation_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 89), NULL, 0, NULL,
+cfg_array(activation_read_only_volume_list_CFG, "read_only_volume_list", activation_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, NULL, vsn(2, 2, 89), NULL, 0, NULL,
 	"LVs in this list are activated in read-only mode.\n"
 	"If this list is defined, each LV that is to be activated\n"
 	"is checked against this list, and if it matches, it is\n"
@@ -1055,7 +1071,7 @@ cfg(activation_raid_region_size_CFG, "raid_region_size", activation_CFG_SECTION,
 	"data that is copied at once when initializing, or moved\n"
 	"at once by pvmove.\n")
 
-cfg(activation_error_when_full_CFG, "error_when_full", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_ERROR_WHEN_FULL, vsn(2, 2, 115), NULL, 0, NULL,
+cfg(activation_error_when_full_CFG, "error_when_full", activation_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_ERROR_WHEN_FULL, vsn(2, 2, 115), NULL, 0, NULL,
 	"Return errors if a thin pool runs out of space.\n"
 	"When enabled, writes to thin LVs immediately return\n"
 	"an error if the thin pool is out of data space.\n"
@@ -1172,7 +1188,7 @@ cfg(activation_thin_pool_autoextend_percent_CFG, "thin_pool_autoextend_percent",
 	"The amount of additional space added to a thin pool is this\n"
 	"percent of its current size.\n")
 
-cfg_array(activation_mlock_filter_CFG, "mlock_filter", activation_CFG_SECTION, CFG_DEFAULT_UNDEFINED | CFG_ADVANCED, CFG_TYPE_STRING, NULL, vsn(2, 2, 62), NULL, 0, NULL,
+cfg_array(activation_mlock_filter_CFG, "mlock_filter", activation_CFG_SECTION, CFG_DEFAULT_COMMENTED | CFG_ADVANCED, CFG_TYPE_STRING, NULL, vsn(2, 2, 62), NULL, 0, NULL,
 	"Do not mlock these memory areas.\n"
 	"While activating devices, I/O to devices being\n"
 	"(re)configured is suspended. As a precaution against\n"
@@ -1186,7 +1202,7 @@ cfg_array(activation_mlock_filter_CFG, "mlock_filter", activation_CFG_SECTION, C
 	"locale-archive was found to make up over 80% of the memory\n"
 	"used by the process.\n"
 	"Example:\n"
-	"mlock_filter = [ \"locale/locale-archive\", \"gconv/gconv-modules.cache\" ]\n")
+	"mlock_filter=[ \"locale/locale-archive\", \"gconv/gconv-modules.cache\" ]\n")
 
 cfg(activation_use_mlockall_CFG, "use_mlockall", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_USE_MLOCKALL, vsn(2, 2, 62), NULL, 0, NULL,
 	"Use the old behavior of mlockall to pin all memory.\n"
@@ -1208,7 +1224,7 @@ cfg(activation_polling_interval_CFG, "polling_interval", activation_CFG_SECTION,
 	"there are no progress reports, but the process is awoken\n"
 	"immediately once the operation is complete.\n")
 
-cfg(activation_auto_set_activation_skip_CFG, "auto_set_activation_skip", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_AUTO_SET_ACTIVATION_SKIP, vsn(2,2,99), NULL, 0, NULL,
+cfg(activation_auto_set_activation_skip_CFG, "auto_set_activation_skip", activation_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_AUTO_SET_ACTIVATION_SKIP, vsn(2,2,99), NULL, 0, NULL,
 	"Set the activation skip flag on new thin snapshot LVs.\n"
 	"An LV can have a persistent 'activation skip' flag.\n"
 	"The flag causes the LV to be skipped during normal activation.\n"
@@ -1236,7 +1252,7 @@ cfg(activation_mode_CFG, "activation_mode", activation_CFG_SECTION, 0, CFG_TYPE_
 	"sometimes assist with data recovery.\n"
 	"The '--activationmode' option overrides this setting.\n")
 
-cfg(metadata_pvmetadatacopies_CFG, "pvmetadatacopies", metadata_CFG_SECTION, CFG_ADVANCED, CFG_TYPE_INT, DEFAULT_PVMETADATACOPIES, vsn(1, 0, 0), NULL, 0, NULL,
+cfg(metadata_pvmetadatacopies_CFG, "pvmetadatacopies", metadata_CFG_SECTION, CFG_ADVANCED | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_PVMETADATACOPIES, vsn(1, 0, 0), NULL, 0, NULL,
 	"Number of copies of metadata to store on each PV.\n"
 	"Possible options are: 0, 1, 2.\n"
 	"If set to 2, two copies of the VG metadata are stored on\n"
@@ -1246,7 +1262,7 @@ cfg(metadata_pvmetadatacopies_CFG, "pvmetadatacopies", metadata_CFG_SECTION, CFG
 	"be useful with VGs containing large numbers of PVs.\n"
 	"The '--pvmetadatacopies' option overrides this setting.\n")
 
-cfg(metadata_vgmetadatacopies_CFG, "vgmetadatacopies", metadata_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_VGMETADATACOPIES, vsn(2, 2, 69), NULL, 0, NULL,
+cfg(metadata_vgmetadatacopies_CFG, "vgmetadatacopies", metadata_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_VGMETADATACOPIES, vsn(2, 2, 69), NULL, 0, NULL,
 	"Number of copies of metadata to maintain for each VG.\n"
 	"If set to a non-zero value, LVM automatically chooses which of\n"
 	"the available metadata areas to use to achieve the requested\n"
@@ -1258,7 +1274,7 @@ cfg(metadata_vgmetadatacopies_CFG, "vgmetadatacopies", metadata_CFG_SECTION, 0,
 	"the individual PV level using 'pvchange --metadataignore y|n'.\n"
 	"The '--vgmetadatacopies' option overrides this setting.\n")
 
-cfg(metadata_pvmetadatasize_CFG, "pvmetadatasize", metadata_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_PVMETADATASIZE, vsn(1, 0, 0), NULL, 0, NULL,
+cfg(metadata_pvmetadatasize_CFG, "pvmetadatasize", metadata_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_PVMETADATASIZE, vsn(1, 0, 0), NULL, 0, NULL,
 	"Approximate number of sectors to use for each metadata copy.\n"
 	"VGs with large numbers of PVs or LVs, or VGs containing\n"
 	"complex LV structures, may need additional space for VG\n"
@@ -1266,15 +1282,15 @@ cfg(metadata_pvmetadatasize_CFG, "pvmetadatasize", metadata_CFG_SECTION, 0, CFG_
 	"so unused space becomes filled with an archive of the most\n"
 	"recent previous versions of the metadata.\n")
 
-cfg(metadata_pvmetadataignore_CFG, "pvmetadataignore", metadata_CFG_SECTION, CFG_ADVANCED, CFG_TYPE_BOOL, DEFAULT_PVMETADATAIGNORE, vsn(2, 2, 69), NULL, 0, NULL,
+cfg(metadata_pvmetadataignore_CFG, "pvmetadataignore", metadata_CFG_SECTION, CFG_ADVANCED | CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_PVMETADATAIGNORE, vsn(2, 2, 69), NULL, 0, NULL,
 	"Ignore metadata areas on a new PV.\n"
 	"If metadata areas on a PV are ignored, LVM will not store\n"
 	"metadata in them.\n"
 	"The '--metadataignore' option overrides this setting.\n")
 
-cfg(metadata_stripesize_CFG, "stripesize", metadata_CFG_SECTION, CFG_ADVANCED, CFG_TYPE_INT, DEFAULT_STRIPESIZE, vsn(1, 0, 0), NULL, 0, NULL, NULL)
+cfg(metadata_stripesize_CFG, "stripesize", metadata_CFG_SECTION, CFG_ADVANCED | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_STRIPESIZE, vsn(1, 0, 0), NULL, 0, NULL, NULL)
 
-cfg_array(metadata_dirs_CFG, "dirs", metadata_CFG_SECTION, CFG_ADVANCED | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL, 0, NULL,
+cfg_array(metadata_dirs_CFG, "dirs", metadata_CFG_SECTION, CFG_ADVANCED | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL, 0, NULL,
 	"Directories holding live copies of text format metadata.\n"
 	"These directories must not be on logical volumes!\n"
 	"It's possible to use LVM with a couple of directories here,\n"
@@ -1289,22 +1305,22 @@ cfg_array(metadata_dirs_CFG, "dirs", metadata_CFG_SECTION, CFG_ADVANCED | CFG_DE
 	"Example:\n"
 	"dirs = [ \"/etc/lvm/metadata\", \"/mnt/disk2/lvm/metadata2\" ]\n")
 
-cfg_section(metadata_disk_areas_CFG_SUBSECTION, "disk_areas", metadata_CFG_SECTION, CFG_UNSUPPORTED | CFG_DEFAULT_UNDEFINED, vsn(1, 0, 0), 0, NULL, NULL)
-cfg_section(disk_area_CFG_SUBSECTION, "disk_area", metadata_disk_areas_CFG_SUBSECTION, CFG_NAME_VARIABLE | CFG_UNSUPPORTED | CFG_DEFAULT_UNDEFINED, vsn(1, 0, 0), 0, NULL, NULL)
-cfg(disk_area_start_sector_CFG, "start_sector", disk_area_CFG_SUBSECTION, CFG_UNSUPPORTED | CFG_DEFAULT_UNDEFINED, CFG_TYPE_INT, 0, vsn(1, 0, 0), NULL, 0, NULL, NULL)
-cfg(disk_area_size_CFG, "size", disk_area_CFG_SUBSECTION, CFG_UNSUPPORTED | CFG_DEFAULT_UNDEFINED, CFG_TYPE_INT, 0, vsn(1, 0, 0), NULL, 0, NULL, NULL)
-cfg(disk_area_id_CFG, "id", disk_area_CFG_SUBSECTION, CFG_UNSUPPORTED | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL, 0, NULL, NULL)
+cfg_section(metadata_disk_areas_CFG_SUBSECTION, "disk_areas", metadata_CFG_SECTION, CFG_UNSUPPORTED | CFG_DEFAULT_COMMENTED, vsn(1, 0, 0), 0, NULL, NULL)
+cfg_section(disk_area_CFG_SUBSECTION, "disk_area", metadata_disk_areas_CFG_SUBSECTION, CFG_NAME_VARIABLE | CFG_UNSUPPORTED | CFG_DEFAULT_COMMENTED, vsn(1, 0, 0), 0, NULL, NULL)
+cfg(disk_area_start_sector_CFG, "start_sector", disk_area_CFG_SUBSECTION, CFG_UNSUPPORTED | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, 0, vsn(1, 0, 0), NULL, 0, NULL, NULL)
+cfg(disk_area_size_CFG, "size", disk_area_CFG_SUBSECTION, CFG_UNSUPPORTED | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, 0, vsn(1, 0, 0), NULL, 0, NULL, NULL)
+cfg(disk_area_id_CFG, "id", disk_area_CFG_SUBSECTION, CFG_UNSUPPORTED | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL, 0, NULL, NULL)
 
-cfg(report_compact_output_CFG, "compact_output", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_REP_COMPACT_OUTPUT, vsn(2, 2, 115), NULL, 0, NULL,
+cfg(report_compact_output_CFG, "compact_output", report_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_REP_COMPACT_OUTPUT, vsn(2, 2, 115), NULL, 0, NULL,
 	"Do not print empty report fields.\n"
 	"Fields that don't have a value set for any of the rows\n"
 	"reported are skipped and not printed. Compact output is\n"
 	"applicable only if report/buffered is enabled.\n")
 
-cfg(report_aligned_CFG, "aligned", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_REP_ALIGNED, vsn(1, 0, 0), NULL, 0, NULL,
+cfg(report_aligned_CFG, "aligned", report_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_REP_ALIGNED, vsn(1, 0, 0), NULL, 0, NULL,
 	"Align columns in report output.\n")
 
-cfg(report_buffered_CFG, "buffered", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_REP_BUFFERED, vsn(1, 0, 0), NULL, 0, NULL,
+cfg(report_buffered_CFG, "buffered", report_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_REP_BUFFERED, vsn(1, 0, 0), NULL, 0, NULL,
 	"Buffer report output.\n"
 	"When buffered reporting is used, the report's content is appended\n"
 	"incrementally to include each object being reported until the report\n"
@@ -1312,100 +1328,100 @@ cfg(report_buffered_CFG, "buffered", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYP
 	"execution. Otherwise, if buffering is not used, each object is\n"
 	"reported as soon as its processing is finished.\n")
 
-cfg(report_headings_CFG, "headings", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_REP_HEADINGS, vsn(1, 0, 0), NULL, 0, NULL,
+cfg(report_headings_CFG, "headings", report_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_REP_HEADINGS, vsn(1, 0, 0), NULL, 0, NULL,
 	"Show headings for columns on report.\n")
 
-cfg(report_separator_CFG, "separator", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_REP_SEPARATOR, vsn(1, 0, 0), NULL, 0, NULL,
+cfg(report_separator_CFG, "separator", report_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_REP_SEPARATOR, vsn(1, 0, 0), NULL, 0, NULL,
 	"A separator to use on report after each field.\n")
 
-cfg(report_list_item_separator_CFG, "list_item_separator", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_REP_LIST_ITEM_SEPARATOR, vsn(2, 2, 108), NULL, 0, NULL,
+cfg(report_list_item_separator_CFG, "list_item_separator", report_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_REP_LIST_ITEM_SEPARATOR, vsn(2, 2, 108), NULL, 0, NULL,
 	"A separator to use for list items when reported.\n")
 
-cfg(report_prefixes_CFG, "prefixes", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_REP_PREFIXES, vsn(2, 2, 36), NULL, 0, NULL,
+cfg(report_prefixes_CFG, "prefixes", report_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_REP_PREFIXES, vsn(2, 2, 36), NULL, 0, NULL,
 	"Use a field name prefix for each field reported.\n")
 
-cfg(report_quoted_CFG, "quoted", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_REP_QUOTED, vsn(2, 2, 39), NULL, 0, NULL,
+cfg(report_quoted_CFG, "quoted", report_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_REP_QUOTED, vsn(2, 2, 39), NULL, 0, NULL,
 	"Quote field values when using field name prefixes.\n")
 
-cfg(report_colums_as_rows_CFG, "colums_as_rows", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_REP_COLUMNS_AS_ROWS, vsn(1, 0, 0), NULL, 0, NULL,
+cfg(report_colums_as_rows_CFG, "colums_as_rows", report_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_REP_COLUMNS_AS_ROWS, vsn(1, 0, 0), NULL, 0, NULL,
 	"Output each column as a row.\n"
 	"If set, this also implies report/prefixes=1.\n")
 
-cfg(report_binary_values_as_numeric_CFG, "binary_values_as_numeric", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, 0, vsn(2, 2, 108), NULL, 0, NULL,
+cfg(report_binary_values_as_numeric_CFG, "binary_values_as_numeric", report_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, 0, vsn(2, 2, 108), NULL, 0, NULL,
 	"Use binary values 0 or 1 instead of descriptive literal values.\n"
 	"For columns that have exactly two valid values to report\n"
 	"(not counting the 'unknown' value which denotes that the\n"
 	"value could not be determined).\n")
 
-cfg(report_devtypes_sort_CFG, "devtypes_sort", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_DEVTYPES_SORT, vsn(2, 2, 101), NULL, 0, NULL,
+cfg(report_devtypes_sort_CFG, "devtypes_sort", report_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_DEVTYPES_SORT, vsn(2, 2, 101), NULL, 0, NULL,
 	"List of columns to sort by when reporting 'lvm devtypes' command.\n"
 	"See 'lvm devtypes -o help' for the list of possible fields.\n")
 
-cfg(report_devtypes_cols_CFG, "devtypes_cols", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_DEVTYPES_COLS, vsn(2, 2, 101), NULL, 0, NULL,
+cfg(report_devtypes_cols_CFG, "devtypes_cols", report_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_DEVTYPES_COLS, vsn(2, 2, 101), NULL, 0, NULL,
 	"List of columns to report for 'lvm devtypes' command.\n"
 	"See 'lvm devtypes -o help' for the list of possible fields.\n")
 
-cfg(report_devtypes_cols_verbose_CFG, "devtypes_cols_verbose", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_DEVTYPES_COLS_VERB, vsn(2, 2, 101), NULL, 0, NULL,
+cfg(report_devtypes_cols_verbose_CFG, "devtypes_cols_verbose", report_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_DEVTYPES_COLS_VERB, vsn(2, 2, 101), NULL, 0, NULL,
 	"List of columns to report for 'lvm devtypes' command in verbose mode.\n"
 	"See 'lvm devtypes -o help' for the list of possible fields.\n")
 
-cfg(report_lvs_sort_CFG, "lvs_sort", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_LVS_SORT, vsn(1, 0, 0), NULL, 0, NULL,
+cfg(report_lvs_sort_CFG, "lvs_sort", report_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_LVS_SORT, vsn(1, 0, 0), NULL, 0, NULL,
 	"List of columns to sort by when reporting 'lvs' command.\n"
 	"See 'lvs -o help' for the list of possible fields.\n")
 
-cfg(report_lvs_cols_CFG, "lvs_cols", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_LVS_COLS, vsn(1, 0, 0), NULL, 0, NULL,
+cfg(report_lvs_cols_CFG, "lvs_cols", report_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_LVS_COLS, vsn(1, 0, 0), NULL, 0, NULL,
 	"List of columns to report for 'lvs' command.\n"
 	"See 'lvs -o help' for the list of possible fields.\n")
 
-cfg(report_lvs_cols_verbose_CFG, "lvs_cols_verbose", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_LVS_COLS_VERB, vsn(1, 0, 0), NULL, 0, NULL,
+cfg(report_lvs_cols_verbose_CFG, "lvs_cols_verbose", report_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_LVS_COLS_VERB, vsn(1, 0, 0), NULL, 0, NULL,
 	"List of columns to report for 'lvs' command in verbose mode.\n"
 	"See 'lvs -o help' for the list of possible fields.\n")
 
-cfg(report_vgs_sort_CFG, "vgs_sort", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_VGS_SORT, vsn(1, 0, 0), NULL, 0, NULL,
+cfg(report_vgs_sort_CFG, "vgs_sort", report_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_VGS_SORT, vsn(1, 0, 0), NULL, 0, NULL,
 	"List of columns to sort by when reporting 'vgs' command.\n"
 	"See 'vgs -o help' for the list of possible fields.\n")
 
-cfg(report_vgs_cols_CFG, "vgs_cols", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_VGS_COLS, vsn(1, 0, 0), NULL, 0, NULL,
+cfg(report_vgs_cols_CFG, "vgs_cols", report_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_VGS_COLS, vsn(1, 0, 0), NULL, 0, NULL,
 	"List of columns to report for 'vgs' command.\n"
 	"See 'vgs -o help' for the list of possible fields.\n")
 
-cfg(report_vgs_cols_verbose_CFG, "vgs_cols_verbose", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_VGS_COLS_VERB, vsn(1, 0, 0), NULL, 0, NULL,
+cfg(report_vgs_cols_verbose_CFG, "vgs_cols_verbose", report_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_VGS_COLS_VERB, vsn(1, 0, 0), NULL, 0, NULL,
 	"List of columns to report for 'vgs' command in verbose mode.\n"
 	"See 'vgs -o help' for the list of possible fields.\n")
 
-cfg(report_pvs_sort_CFG, "pvs_sort", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_PVS_SORT, vsn(1, 0, 0), NULL, 0, NULL,
+cfg(report_pvs_sort_CFG, "pvs_sort", report_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_PVS_SORT, vsn(1, 0, 0), NULL, 0, NULL,
 	"List of columns to sort by when reporting 'pvs' command.\n"
 	"See 'pvs -o help' for the list of possible fields.\n")
 
-cfg(report_pvs_cols_CFG, "pvs_cols", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_PVS_COLS, vsn(1, 0, 0), NULL, 0, NULL,
+cfg(report_pvs_cols_CFG, "pvs_cols", report_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_PVS_COLS, vsn(1, 0, 0), NULL, 0, NULL,
 	"List of columns to report for 'pvs' command.\n"
 	"See 'pvs -o help' for the list of possible fields.\n")
 
-cfg(report_pvs_cols_verbose_CFG, "pvs_cols_verbose", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_PVS_COLS_VERB, vsn(1, 0, 0), NULL, 0, NULL,
+cfg(report_pvs_cols_verbose_CFG, "pvs_cols_verbose", report_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_PVS_COLS_VERB, vsn(1, 0, 0), NULL, 0, NULL,
 	"List of columns to report for 'pvs' command in verbose mode.\n"
 	"See 'pvs -o help' for the list of possible fields.\n")
 
-cfg(report_segs_sort_CFG, "segs_sort", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_SEGS_SORT, vsn(1, 0, 0), NULL, 0, NULL,
+cfg(report_segs_sort_CFG, "segs_sort", report_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_SEGS_SORT, vsn(1, 0, 0), NULL, 0, NULL,
 	"List of columns to sort by when reporting 'lvs --segments' command.\n"
 	"See 'lvs --segments -o help' for the list of possible fields.\n")
 
-cfg(report_segs_cols_CFG, "segs_cols", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_SEGS_COLS, vsn(1, 0, 0), NULL, 0, NULL,
+cfg(report_segs_cols_CFG, "segs_cols", report_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_SEGS_COLS, vsn(1, 0, 0), NULL, 0, NULL,
 	"List of columns to report for 'lvs --segments' command.\n"
 	"See 'lvs --segments  -o help' for the list of possible fields.\n")
 
-cfg(report_segs_cols_verbose_CFG, "segs_cols_verbose", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_SEGS_COLS_VERB, vsn(1, 0, 0), NULL, 0, NULL,
+cfg(report_segs_cols_verbose_CFG, "segs_cols_verbose", report_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_SEGS_COLS_VERB, vsn(1, 0, 0), NULL, 0, NULL,
 	"List of columns to report for 'lvs --segments' command in verbose mode.\n"
 	"See 'lvs --segments -o help' for the list of possible fields.\n")
 
-cfg(report_pvsegs_sort_CFG, "pvsegs_sort", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_PVSEGS_SORT, vsn(1, 1, 3), NULL, 0, NULL,
+cfg(report_pvsegs_sort_CFG, "pvsegs_sort", report_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_PVSEGS_SORT, vsn(1, 1, 3), NULL, 0, NULL,
 	"List of columns to sort by when reporting 'pvs --segments' command.\n"
 	"See 'pvs --segments -o help' for the list of possible fields.\n")
 
-cfg(report_pvsegs_cols_CFG, "pvsegs_cols", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_PVSEGS_COLS, vsn(1, 1, 3), NULL, 0, NULL,
+cfg(report_pvsegs_cols_CFG, "pvsegs_cols", report_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_PVSEGS_COLS, vsn(1, 1, 3), NULL, 0, NULL,
 	"List of columns to sort by when reporting 'pvs --segments' command.\n"
 	"See 'pvs --segments -o help' for the list of possible fields.\n")
 
-cfg(report_pvsegs_cols_verbose_CFG, "pvsegs_cols_verbose", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_PVSEGS_COLS_VERB, vsn(1, 1, 3), NULL, 0, NULL,
+cfg(report_pvsegs_cols_verbose_CFG, "pvsegs_cols_verbose", report_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_PVSEGS_COLS_VERB, vsn(1, 1, 3), NULL, 0, NULL,
 	"List of columns to sort by when reporting 'pvs --segments' command in verbose mode.\n"
 	"See 'pvs --segments -o help' for the list of possible fields.\n")
 
@@ -1416,7 +1432,7 @@ cfg(dmeventd_mirror_library_CFG, "mirror_library", dmeventd_CFG_SECTION, 0, CFG_
 	"reconfigures a mirror as necessary. If no mirror library is\n"
 	"provided, mirrors are not monitored through dmeventd.\n")
 
-cfg(dmeventd_raid_library_CFG, "raid_library", dmeventd_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_DMEVENTD_RAID_LIB, vsn(2, 2, 87), NULL, 0, NULL, NULL)
+cfg(dmeventd_raid_library_CFG, "raid_library", dmeventd_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_DMEVENTD_RAID_LIB, vsn(2, 2, 87), NULL, 0, NULL, NULL)
 
 cfg(dmeventd_snapshot_library_CFG, "snapshot_library", dmeventd_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_DMEVENTD_SNAPSHOT_LIB, vsn(1, 2, 26), NULL, 0, NULL,
 	"The library dmeventd uses when monitoring a snapshot device.\n"
@@ -1432,14 +1448,14 @@ cfg(dmeventd_thin_library_CFG, "thin_library", dmeventd_CFG_SECTION, 0, CFG_TYPE
 	"exceeds 80%. The warning is repeated when 85%, 90% and\n"
 	"95% of the pool is filled.\n")
 
-cfg(dmeventd_executable_CFG, "executable", dmeventd_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_DMEVENTD_PATH, vsn(2, 2, 73), "@DMEVENTD_PATH@", 0, NULL,
+cfg(dmeventd_executable_CFG, "executable", dmeventd_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_DMEVENTD_PATH, vsn(2, 2, 73), "@DMEVENTD_PATH@", 0, NULL,
 	"The full path to the dmeventd binary.\n")
 
-cfg(tags_hosttags_CFG, "hosttags", tags_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_HOSTTAGS, vsn(1, 0, 18), NULL, 0, NULL,
+cfg(tags_hosttags_CFG, "hosttags", tags_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_HOSTTAGS, vsn(1, 0, 18), NULL, 0, NULL,
 	"Create a host tag using the machine name.\n"
 	"The machine name is nodename returned by uname(2).\n")
 
-cfg_section(tag_CFG_SUBSECTION, "tag", tags_CFG_SECTION, CFG_NAME_VARIABLE | CFG_DEFAULT_UNDEFINED, vsn(1, 0, 18), 0, NULL,
+cfg_section(tag_CFG_SUBSECTION, "tag", tags_CFG_SECTION, CFG_NAME_VARIABLE | CFG_DEFAULT_COMMENTED, vsn(1, 0, 18), 0, NULL,
 	"Replace this subsection name with a custom tag name.\n"
 	"Multiple subsections like this can be created.\n"
 	"The '@' prefix for tags is optional.\n"
@@ -1455,14 +1471,14 @@ cfg_section(tag_CFG_SUBSECTION, "tag", tags_CFG_SECTION, CFG_NAME_VARIABLE | CFG
 	"bar is given to the hosts named machine1 and machine2.\n"
 	"tags { foo { } bar { host_list = [ \"machine1\", \"machine2\" ] } }\n")
 
-cfg(tag_host_list_CFG, "host_list", tag_CFG_SUBSECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 18), NULL, 0, NULL,
+cfg_array(tag_host_list_CFG, "host_list", tag_CFG_SUBSECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, NULL, vsn(1, 0, 18), NULL, 0, NULL,
 	"A list of machine names.\n"
 	"These machine names are compared to the nodename\n"
 	"returned by uname(2). If the local machine name\n"
 	"matches an entry in this list, the name of the\n"
 	"subsection is applied to the machine as a 'host tag'.\n")
 
-cfg(local_system_id_CFG, "system_id", local_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 117), NULL, 0, NULL,
+cfg(local_system_id_CFG, "system_id", local_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, NULL, vsn(2, 2, 117), NULL, 0, NULL,
 	"Defines the local system ID for lvmlocal mode.\n"
 	"This is used when global/system_id_source is set\n"
 	"to 'lvmlocal' in the main configuration file,\n"
@@ -1477,7 +1493,7 @@ cfg(local_system_id_CFG, "system_id", local_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_D
 	"Set the system_id to the string 'host1'.\n"
 	"system_id = \"host1\"\n")
 
-cfg_array(local_extra_system_ids_CFG, "extra_system_ids", local_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 117), NULL, 0, NULL,
+cfg_array(local_extra_system_ids_CFG, "extra_system_ids", local_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, NULL, vsn(2, 2, 117), NULL, 0, NULL,
 	"A list of extra VG system IDs the local host can access.\n"
 	"VGs with the system IDs listed here (in addition\n"
 	"to the host's own system ID) can be fully accessed\n"


