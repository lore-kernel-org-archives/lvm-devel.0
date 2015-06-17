From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 17 Jun 2015 11:35:50 +0000 (UTC)
Subject: master - config: fix some settings incorrectly marked as CFG_DEFAULT_COMMENTED instead of CFG_DEFAULT_UNDEFINED and causing segfault
Message-ID: <20150617113550.2ABBA60D1B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a9bc53d5f33afd5c4c3ad36450146f753c568a7c
Commit:        a9bc53d5f33afd5c4c3ad36450146f753c568a7c
Parent:        da1f88706060baf03bceb9e4d788c65646b831b7
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jun 17 13:26:11 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jun 17 13:34:31 2015 +0200

config: fix some settings incorrectly marked as CFG_DEFAULT_COMMENTED instead of CFG_DEFAULT_UNDEFINED and causing segfault

This patch fixes segfault which was caused by incorrectly marking some
settings CFG_DEFAULT_COMMENTED instead of CFG_DEFAULT_UNDEFINED - the
ones which have NULL default value, hence they're really undefined.
A regression caused by a98ceceb1d101f0b19a6115f406e23f13feab5ae.

For example:

$ lvmconfig log/file
file="/a"

Before this patch:

$ lvmconfig --type diff
Segmentation fault (core dumped)

With this patch applied:

$ lvmconfig --type diff
log {
	file="/a"
}

The same applies for these settings:

  log/activate_file
  global/library_dir
  global/system_id_file
  <disk_area>/disk_area_id

There were also other settings with NULL default value and marked as
CFG_DEFAULT_COMMENTED instead of CFG_DEFAULT_UNDEFINED, but they were
cfg_array config settings where the NULL value was not causing segfault
(NULL == empty array).
---
 WHATS_NEW                    |    1 +
 lib/config/config_settings.h |   52 +++++++++++++++++++++---------------------
 2 files changed, 27 insertions(+), 26 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 007ee0a..e5a8af7 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.122 - 
 =================================
+  Fix lvmconfig segfault on settings with undefined default value (2.02.120).
 
 Version 2.02.121 - 12th June 2015
 =================================
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 885a2fa..5c7b132 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -96,12 +96,12 @@
  *
  * Difference between CFG_DEFAULT_COMMENTED and CFG_DEFAULT_UNDEFINED:
  *
- * UNDEFINED is only used if the value depends on other
- * system/kernel values outside of lvm.  The most common
- * case is when dm-thin or dm-cache have built-in default
- * settings in the kernel, and lvm will use those built-in
- * default values unless the corresponding lvm config setting
- * is set.
+ * UNDEFINED is used if default value is NULL or the value
+ * depends on other system/kernel values outside of lvm.
+ * The most common case is when dm-thin or dm-cache have
+ * built-in default settings in the kernel, and lvm will use
+ * those built-in default values unless the corresponding lvm
+ * config setting is set.
  *
  * COMMENTED is used to comment out the default setting in
  * lvm.conf.  The effect is that if the LVM version is
@@ -202,7 +202,7 @@ cfg(devices_external_device_info_source_CFG, "external_device_info_source", devi
 	"udev - Reuse existing udev database records. Applicable\n"
 	"only if LVM is compiled with udev support.\n")
 
-cfg_array(devices_preferred_names_CFG, "preferred_names", devices_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_COMMENTED , CFG_TYPE_STRING, NULL, vsn(1, 2, 19), NULL, 0, NULL,
+cfg_array(devices_preferred_names_CFG, "preferred_names", devices_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_COMMENTED , CFG_TYPE_STRING, "#S", vsn(1, 2, 19), NULL, 0, NULL,
 	"Select which path name to display for a block device.\n"
 	"If multiple path names exist for a block device,\n"
 	"and LVM needs to display a name for the device,\n"
@@ -219,7 +219,7 @@ cfg_array(devices_preferred_names_CFG, "preferred_names", devices_CFG_SECTION, C
 	"Example:\n"
 	"preferred_names = [ \"^/dev/mpath/\", \"^/dev/mapper/mpath\", \"^/dev/[hs]d\" ]\n")
 
-cfg_array(devices_filter_CFG, "filter", devices_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL, 0, NULL,
+cfg_array(devices_filter_CFG, "filter", devices_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL, 0, NULL,
 	"Limit the block devices that are used by LVM commands.\n"
 	"This is a list of regular expressions used to accept or\n"
 	"reject block device path names.  Each regex is delimited\n"
@@ -254,7 +254,7 @@ cfg_array(devices_filter_CFG, "filter", devices_CFG_SECTION, CFG_DEFAULT_COMMENT
 	"Use anchors to be very specific.\n"
 	"filter = [ \"a|^/dev/hda8$|\", \"r|.*/|\" ]\n")
 
-cfg_array(devices_global_filter_CFG, "global_filter", devices_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, NULL, vsn(2, 2, 98), NULL, 0, NULL,
+cfg_array(devices_global_filter_CFG, "global_filter", devices_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 98), NULL, 0, NULL,
 	"Limit the block devices that are used by LVM system components.\n"
 	"Because devices/filter may be overridden from the command line,\n"
 	"it is not suitable for system-wide device filtering, e.g. udev\n"
@@ -281,7 +281,7 @@ cfg(devices_cache_file_prefix_CFG, "cache_file_prefix", devices_CFG_SECTION, CFG
 cfg(devices_write_cache_state_CFG, "write_cache_state", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, 1, vsn(1, 0, 0), NULL, 0, NULL,
 	"Enable/disable writing the cache file. See devices/cache_dir.\n")
 
-cfg_array(devices_types_CFG, "types", devices_CFG_SECTION, CFG_DEFAULT_COMMENTED| CFG_ADVANCED, CFG_TYPE_INT | CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL, 0, NULL,
+cfg_array(devices_types_CFG, "types", devices_CFG_SECTION, CFG_DEFAULT_UNDEFINED | CFG_ADVANCED, CFG_TYPE_INT | CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL, 0, NULL,
 	"List of additional acceptable block device types.\n"
 	"These are of device type names from /proc/devices,\n"
 	"followed by the maximum number of partitions.\n"
@@ -398,7 +398,7 @@ cfg(devices_issue_discards_CFG, "issue_discards", devices_CFG_SECTION, 0, CFG_TY
 	"and thinly provisioned LUNs generally do.  If enabled, discards\n"
 	"will only be issued if both the storage and kernel provide support.\n")
 
-cfg_array(allocation_cling_tag_list_CFG, "cling_tag_list", allocation_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, NULL, vsn(2, 2, 77), NULL, 0, NULL,
+cfg_array(allocation_cling_tag_list_CFG, "cling_tag_list", allocation_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 77), NULL, 0, NULL,
 	"Advise LVM which PVs to use when searching for new space.\n"
 	"When searching for free space to extend an LV, the 'cling'\n"
 	"allocation policy will choose space on the same PVs as the last\n"
@@ -532,7 +532,7 @@ cfg(log_silent_CFG, "silent", log_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_SILENT,
 cfg(log_syslog_CFG, "syslog", log_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_SYSLOG, vsn(1, 0, 0), NULL, 0, NULL,
 	"Send log messages through syslog.\n")
 
-cfg(log_file_CFG, "file", log_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL, 0, NULL,
+cfg(log_file_CFG, "file", log_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL, 0, NULL,
 	"Write error and debug log messages to a file specified here.\n")
 
 cfg(log_overwrite_CFG, "overwrite", log_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_OVERWRITE, vsn(1, 0, 0), NULL, 0, NULL,
@@ -560,7 +560,7 @@ cfg(log_activation_CFG, "activation", log_CFG_SECTION, 0, CFG_TYPE_BOOL, 0, vsn(
 	"Log messages during activation.\n"
 	"Don't use this in low memory situations (can deadlock).\n")
 
-cfg(log_activate_file_CFG, "activate_file", log_CFG_SECTION, CFG_DEFAULT_COMMENTED | CFG_UNSUPPORTED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL, 0, NULL, NULL)
+cfg(log_activate_file_CFG, "activate_file", log_CFG_SECTION, CFG_DEFAULT_UNDEFINED | CFG_UNSUPPORTED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL, 0, NULL, NULL)
 
 cfg_array(log_debug_classes_CFG, "debug_classes", log_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, "#Smemory#Sdevices#Sactivation#Sallocation#Slvmetad#Smetadata#Scache#Slocking#Slvmpolld", vsn(2, 2, 99), NULL, 0, NULL,
 	"Select log messages by class.\n"
@@ -640,12 +640,12 @@ cfg(global_format_CFG, "format", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_
 	"\"lvm1\" or \"lvm2\".\n"
 	"The command line override is -M1 or -M2.\n")
 
-cfg_array(global_format_libraries_CFG, "format_libraries", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL, 0, NULL,
+cfg_array(global_format_libraries_CFG, "format_libraries", global_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL, 0, NULL,
 	"Shared libraries that process different metadata formats.\n"
 	"If support for LVM1 metadata was compiled as a shared library use\n"
 	"format_libraries = \"liblvm2format1.so\"\n")
 
-cfg_array(global_segment_libraries_CFG, "segment_libraries", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, NULL, vsn(1, 0, 18), NULL, 0, NULL, NULL)
+cfg_array(global_segment_libraries_CFG, "segment_libraries", global_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 18), NULL, 0, NULL, NULL)
 
 cfg(global_proc_CFG, "proc", global_CFG_SECTION, CFG_ADVANCED, CFG_TYPE_STRING, DEFAULT_PROC_DIR, vsn(1, 0, 0), NULL, 0, NULL,
 	"Location of proc filesystem.\n")
@@ -710,7 +710,7 @@ cfg(global_prioritise_write_locks_CFG, "prioritise_write_locks", global_CFG_SECT
 	"This option only affects locking_type 1 viz.\n"
 	"local file-based locking.\n")
 
-cfg(global_library_dir_CFG, "library_dir", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL, 0, NULL,
+cfg(global_library_dir_CFG, "library_dir", global_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL, 0, NULL,
 	"Search this directory first for shared libraries.\n")
 
 cfg(global_locking_library_CFG, "locking_library", global_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_LOCKING_LIB, vsn(1, 0, 0), NULL, 0, NULL,
@@ -865,7 +865,7 @@ cfg_array(global_thin_check_options_CFG, "thin_check_options", global_CFG_SECTIO
 cfg_array(global_thin_repair_options_CFG, "thin_repair_options", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, "#S" DEFAULT_THIN_REPAIR_OPTIONS, vsn(2, 2, 100), NULL, 0, NULL,
 	"List of options passed to the thin_repair command.\n")
 
-cfg_array(global_thin_disabled_features_CFG, "thin_disabled_features", global_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, NULL, vsn(2, 2, 99), NULL, 0, NULL,
+cfg_array(global_thin_disabled_features_CFG, "thin_disabled_features", global_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, "#S", vsn(2, 2, 99), NULL, 0, NULL,
 	"Features to not use in the thin driver.\n"
 	"This can be helpful for testing, or to avoid\n"
 	"using a feature that is causing problems.\n"
@@ -925,7 +925,7 @@ cfg(global_system_id_source_CFG, "system_id_source", global_CFG_SECTION, 0, CFG_
 	"file - Use the contents of another file (system_id_file) to set\n"
 	"the system ID.\n")
 
-cfg(global_system_id_file_CFG, "system_id_file", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, NULL, vsn(2, 2, 117), NULL, 0, NULL,
+cfg(global_system_id_file_CFG, "system_id_file", global_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 117), NULL, 0, NULL,
 	"The full path to the file containing a system ID.\n"
 	"This is used when system_id_source is set to 'file'.\n"
 	"Comments starting with the character # are ignored.\n")
@@ -1007,7 +1007,7 @@ cfg(activation_process_priority_CFG, "process_priority", activation_CFG_SECTION,
 	"Use a high priority so that LVs are suspended\n"
 	"for the shortest possible time.\n")
 
-cfg_array(activation_volume_list_CFG, "volume_list", activation_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, NULL, vsn(1, 0, 18), NULL, 0, NULL,
+cfg_array(activation_volume_list_CFG, "volume_list", activation_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 18), NULL, 0, NULL,
 	"Only LVs selected by this list are activated.\n"
 	"If this list is defined, an LV is only activated\n"
 	"if it matches an entry in this list.\n"
@@ -1024,7 +1024,7 @@ cfg_array(activation_volume_list_CFG, "volume_list", activation_CFG_SECTION, CFG
 	"Example:\n"
 	"volume_list = [ \"vg1\", \"vg2/lvol1\", \"@tag1\", \"@*\" ]\n")
 
-cfg_array(activation_auto_activation_volume_list_CFG, "auto_activation_volume_list", activation_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, NULL, vsn(2, 2, 97), NULL, 0, NULL,
+cfg_array(activation_auto_activation_volume_list_CFG, "auto_activation_volume_list", activation_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 97), NULL, 0, NULL,
 	"Only LVs selected by this list are auto-activated.\n"
 	"This list works like volume_list, but it is used\n"
 	"only by auto-activation commands. It does not apply\n"
@@ -1054,7 +1054,7 @@ cfg_array(activation_auto_activation_volume_list_CFG, "auto_activation_volume_li
 	"Possible options are: vgname, vgname/lvname, @tag, @*\n"
 	"See volume_list for how these options are matched to LVs.\n")
 
-cfg_array(activation_read_only_volume_list_CFG, "read_only_volume_list", activation_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, NULL, vsn(2, 2, 89), NULL, 0, NULL,
+cfg_array(activation_read_only_volume_list_CFG, "read_only_volume_list", activation_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 89), NULL, 0, NULL,
 	"LVs in this list are activated in read-only mode.\n"
 	"If this list is defined, each LV that is to be activated\n"
 	"is checked against this list, and if it matches, it is\n"
@@ -1191,7 +1191,7 @@ cfg(activation_thin_pool_autoextend_percent_CFG, "thin_pool_autoextend_percent",
 	"The amount of additional space added to a thin pool is this\n"
 	"percent of its current size.\n")
 
-cfg_array(activation_mlock_filter_CFG, "mlock_filter", activation_CFG_SECTION, CFG_DEFAULT_COMMENTED | CFG_ADVANCED, CFG_TYPE_STRING, NULL, vsn(2, 2, 62), NULL, 0, NULL,
+cfg_array(activation_mlock_filter_CFG, "mlock_filter", activation_CFG_SECTION, CFG_DEFAULT_UNDEFINED | CFG_ADVANCED, CFG_TYPE_STRING, NULL, vsn(2, 2, 62), NULL, 0, NULL,
 	"Do not mlock these memory areas.\n"
 	"While activating devices, I/O to devices being\n"
 	"(re)configured is suspended. As a precaution against\n"
@@ -1293,7 +1293,7 @@ cfg(metadata_pvmetadataignore_CFG, "pvmetadataignore", metadata_CFG_SECTION, CFG
 
 cfg(metadata_stripesize_CFG, "stripesize", metadata_CFG_SECTION, CFG_ADVANCED | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_STRIPESIZE, vsn(1, 0, 0), NULL, 0, NULL, NULL)
 
-cfg_array(metadata_dirs_CFG, "dirs", metadata_CFG_SECTION, CFG_ADVANCED | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL, 0, NULL,
+cfg_array(metadata_dirs_CFG, "dirs", metadata_CFG_SECTION, CFG_ADVANCED | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL, 0, NULL,
 	"Directories holding live copies of text format metadata.\n"
 	"These directories must not be on logical volumes!\n"
 	"It's possible to use LVM with a couple of directories here,\n"
@@ -1312,7 +1312,7 @@ cfg_section(metadata_disk_areas_CFG_SUBSECTION, "disk_areas", metadata_CFG_SECTI
 cfg_section(disk_area_CFG_SUBSECTION, "disk_area", metadata_disk_areas_CFG_SUBSECTION, CFG_NAME_VARIABLE | CFG_UNSUPPORTED | CFG_DEFAULT_COMMENTED, vsn(1, 0, 0), 0, NULL, NULL)
 cfg(disk_area_start_sector_CFG, "start_sector", disk_area_CFG_SUBSECTION, CFG_UNSUPPORTED | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, 0, vsn(1, 0, 0), NULL, 0, NULL, NULL)
 cfg(disk_area_size_CFG, "size", disk_area_CFG_SUBSECTION, CFG_UNSUPPORTED | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, 0, vsn(1, 0, 0), NULL, 0, NULL, NULL)
-cfg(disk_area_id_CFG, "id", disk_area_CFG_SUBSECTION, CFG_UNSUPPORTED | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL, 0, NULL, NULL)
+cfg(disk_area_id_CFG, "id", disk_area_CFG_SUBSECTION, CFG_UNSUPPORTED | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL, 0, NULL, NULL)
 
 cfg(report_compact_output_CFG, "compact_output", report_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_REP_COMPACT_OUTPUT, vsn(2, 2, 115), NULL, 0, NULL,
 	"Do not print empty report fields.\n"
@@ -1474,7 +1474,7 @@ cfg_section(tag_CFG_SUBSECTION, "tag", tags_CFG_SECTION, CFG_NAME_VARIABLE | CFG
 	"bar is given to the hosts named machine1 and machine2.\n"
 	"tags { foo { } bar { host_list = [ \"machine1\", \"machine2\" ] } }\n")
 
-cfg_array(tag_host_list_CFG, "host_list", tag_CFG_SUBSECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, NULL, vsn(1, 0, 18), NULL, 0, NULL,
+cfg_array(tag_host_list_CFG, "host_list", tag_CFG_SUBSECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 18), NULL, 0, NULL,
 	"A list of machine names.\n"
 	"These machine names are compared to the nodename\n"
 	"returned by uname(2). If the local machine name\n"
@@ -1496,7 +1496,7 @@ cfg(local_system_id_CFG, "system_id", local_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_D
 	"Set the system_id to the string 'host1'.\n"
 	"system_id = \"host1\"\n")
 
-cfg_array(local_extra_system_ids_CFG, "extra_system_ids", local_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, NULL, vsn(2, 2, 117), NULL, 0, NULL,
+cfg_array(local_extra_system_ids_CFG, "extra_system_ids", local_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, "#S", vsn(2, 2, 117), NULL, 0, NULL,
 	"A list of extra VG system IDs the local host can access.\n"
 	"VGs with the system IDs listed here (in addition\n"
 	"to the host's own system ID) can be fully accessed\n"


