From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 18 Aug 2015 19:05:34 +0000 (UTC)
Subject: master - config: improve description text layout
Message-ID: <20150818190534.7C34D60F6E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d08427030dc68d827f7ad5be83b81063f613758c
Commit:        d08427030dc68d827f7ad5be83b81063f613758c
Parent:        7b570840cd5c503ff55a446e211ac30bb09ef3fd
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Aug 18 10:15:40 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Aug 18 14:02:32 2015 -0500

config: improve description text layout

This mainly makes the description text use 80 columns.
There are a few minor adjustments to wording to help
the text layout, and a couple minor improvements to
descriptions.
---
 lib/config/config_settings.h |  845 +++++++++++++++++++-----------------------
 1 files changed, 389 insertions(+), 456 deletions(-)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 1903e90..9017043 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -129,10 +129,9 @@ cfg_section(log_CFG_SECTION, "log", root_CFG_SECTION, 0, vsn(1, 0, 0), 0, NULL,
 
 cfg_section(backup_CFG_SECTION, "backup", root_CFG_SECTION, 0, vsn(1, 0, 0), 0, NULL,
 	"How LVM metadata is backed up and archived.\n"
-	"In LVM, a 'backup' is a copy of the metadata for the\n"
-	"current system, and an 'archive' contains old metadata\n"
-	"configurations. They are stored in a human readable\n"
-	"text format.\n")
+	"In LVM, a 'backup' is a copy of the metadata for the current system,\n"
+	"and an 'archive' contains old metadata configurations. They are\n"
+	"stored in a human readable text format.\n")
 
 cfg_section(shell_CFG_SECTION, "shell", root_CFG_SECTION, 0, vsn(1, 0, 0), 0, NULL,
 	"Settings for running LVM in shell (readline) mode.\n")
@@ -158,11 +157,11 @@ cfg_section(local_CFG_SECTION, "local", root_CFG_SECTION, 0, vsn(2, 2, 117), 0,
 
 cfg(config_checks_CFG, "checks", config_CFG_SECTION, 0, CFG_TYPE_BOOL, 1, vsn(2, 2, 99), NULL, 0, NULL,
 	"If enabled, any LVM configuration mismatch is reported.\n"
-	"This implies checking that the configuration key is understood\n"
-	"by LVM and that the value of the key is the proper type.\n"
-	"If disabled, any configuration mismatch is ignored and the default\n"
-	"value is used without any warning (a message about the\n"
-	"configuration key not being found is issued in verbose mode only).\n")
+	"This implies checking that the configuration key is understood by\n"
+	"LVM and that the value of the key is the proper type. If disabled,\n"
+	"any configuration mismatch is ignored and the default value is used\n"
+	"without any warning (a message about the configuration key not being\n"
+	"found is issued in verbose mode only).\n")
 
 cfg(config_abort_on_errors_CFG, "abort_on_errors", config_CFG_SECTION, 0, CFG_TYPE_BOOL, 0, vsn(2,2,99), NULL, 0, NULL,
 	"Abort the LVM process if a configuration mismatch is found.\n")
@@ -181,23 +180,21 @@ cfg_array(devices_loopfiles_CFG, "loopfiles", devices_CFG_SECTION, CFG_DEFAULT_U
 
 cfg(devices_obtain_device_list_from_udev_CFG, "obtain_device_list_from_udev", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_OBTAIN_DEVICE_LIST_FROM_UDEV, vsn(2, 2, 85), NULL, 0, NULL,
 	"Obtain the list of available devices from udev.\n"
-	"This avoids opening or using any inapplicable non-block\n"
-	"devices or subdirectories found in the udev directory.\n"
-	"Any device node or symlink not managed by udev in the udev\n"
-	"directory is ignored. This setting applies only to the\n"
-	"udev-managed device directory; other directories will be\n"
-	"scanned fully. LVM needs to be compiled with udev support\n"
-	"for this setting to apply.\n")
+	"This avoids opening or using any inapplicable non-block devices or\n"
+	"subdirectories found in the udev directory. Any device node or\n"
+	"symlink not managed by udev in the udev directory is ignored. This\n"
+	"setting applies only to the udev-managed device directory; other\n"
+	"directories will be scanned fully. LVM needs to be compiled with\n"
+	"udev support for this setting to apply.\n")
 
 cfg(devices_external_device_info_source_CFG, "external_device_info_source", devices_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_EXTERNAL_DEVICE_INFO_SOURCE, vsn(2, 2, 116), NULL, 0, NULL,
 	"Select an external device information source.\n"
-	"Some information may already be available in the system and\n"
-	"LVM can use this information to determine the exact type\n"
-	"or use of devices it processes. Using an existing external\n"
-	"device information source can speed up device processing\n"
-	"as LVM does not need to run its own native routines to acquire\n"
-	"this information. For example, this information is used to\n"
-	"drive LVM filtering like MD component detection, multipath\n"
+	"Some information may already be available in the system and LVM can\n"
+	"use this information to determine the exact type or use of devices it\n"
+	"processes. Using an existing external device information source can\n"
+	"speed up device processing as LVM does not need to run its own native\n"
+	"routines to acquire this information. For example, this information\n"
+	"is used to drive LVM filtering like MD component detection, multipath\n"
 	"component detection, partition detection and others.\n"
 	"#\n"
 	"Accepted values:\n"
@@ -210,18 +207,18 @@ cfg(devices_external_device_info_source_CFG, "external_device_info_source", devi
 
 cfg_array(devices_preferred_names_CFG, "preferred_names", devices_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED , CFG_TYPE_STRING, NULL, vsn(1, 2, 19), NULL, 0, NULL,
 	"Select which path name to display for a block device.\n"
-	"If multiple path names exist for a block device,\n"
-	"and LVM needs to display a name for the device,\n"
-	"the path names are matched against each item in\n"
-	"this list of regular expressions. The first match is used.\n"
-	"Try to avoid using undescriptive /dev/dm-N names, if present.\n"
-	"If no preferred name matches, or if preferred_names are not\n"
-	"defined, built-in rules are used until one produces a preference.\n"
-	"Rule 1 checks path prefixes and gives preference in this order:\n"
-	"/dev/mapper, /dev/disk, /dev/dm-*, /dev/block (/dev from devices/dev)\n"
-	"Rule 2 prefers the path with the least slashes.\n"
-	"Rule 3 prefers a symlink.\n"
-	"Rule 4 prefers the path with least value in lexicographical order.\n"
+	"If multiple path names exist for a block device, and LVM needs to\n"
+	"display a name for the device, the path names are matched against\n"
+	"each item in this list of regular expressions. The first match is\n"
+	"used. Try to avoid using undescriptive /dev/dm-N names, if present.\n"
+	"If no preferred name matches, or if preferred_names are not defined,\n"
+	"the following built-in preferences are applied in order until one\n"
+	"produces a preferred name:\n"
+	"Prefer names with path prefixes in the order of:\n"
+	"/dev/mapper, /dev/disk, /dev/dm-*, /dev/block.\n"
+	"Prefer the name with the least number of slashes.\n"
+	"Prefer a name that is a symlink.\n"
+	"Prefer the path with least value in lexicographical order.\n"
 	"#\n"
 	"Example\n"
 	"preferred_names = [ \"^/dev/mpath/\", \"^/dev/mapper/mpath\", \"^/dev/[hs]d\" ]\n"
@@ -229,21 +226,18 @@ cfg_array(devices_preferred_names_CFG, "preferred_names", devices_CFG_SECTION, C
 
 cfg_array(devices_filter_CFG, "filter", devices_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, "#Sa|.*/|", vsn(1, 0, 0), NULL, 0, NULL,
 	"Limit the block devices that are used by LVM commands.\n"
-	"This is a list of regular expressions used to accept or\n"
-	"reject block device path names.  Each regex is delimited\n"
-	"by a vertical bar '|' (or any character) and is preceded\n"
-	"by 'a' to accept the path, or by 'r' to reject the path.\n"
-	"The first regex in the list to match the path is used,\n"
-	"producing the 'a' or 'r' result for the device.\n"
-	"When multiple path names exist for a block device, if any\n"
-	"path name matches an 'a' pattern before an 'r' pattern,\n"
-	"then the device is accepted. If all the path names match\n"
-	"an 'r' pattern first, then the device is rejected.\n"
-	"Unmatching path names do not affect the accept or reject\n"
-	"decision. If no path names for a device match a pattern,\n"
-	"then the device is accepted.\n"
-	"Be careful mixing 'a' and 'r' patterns, as the combination\n"
-	"might produce unexpected results (test any changes.)\n"
+	"This is a list of regular expressions used to accept or reject block\n"
+	"device path names. Each regex is delimited by a vertical bar '|'\n"
+	"(or any character) and is preceded by 'a' to accept the path, or\n"
+	"by 'r' to reject the path. The first regex in the list to match the\n"
+	"path is used, producing the 'a' or 'r' result for the device.\n"
+	"When multiple path names exist for a block device, if any path name\n"
+	"matches an 'a' pattern before an 'r' pattern, then the device is\n"
+	"accepted. If all the path names match an 'r' pattern first, then the\n"
+	"device is rejected. Unmatching path names do not affect the accept\n"
+	"or reject decision. If no path names for a device match a pattern,\n"
+	"then the device is accepted. Be careful mixing 'a' and 'r' patterns,\n"
+	"as the combination might produce unexpected results (test changes.)\n"
 	"Run vgscan after changing the filter to regenerate the cache.\n"
 	"See the use_lvmetad comment for a special case regarding filters.\n"
 	"#\n"
@@ -262,11 +256,11 @@ cfg_array(devices_filter_CFG, "filter", devices_CFG_SECTION, CFG_DEFAULT_COMMENT
 
 cfg_array(devices_global_filter_CFG, "global_filter", devices_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, "#Sa|.*/|", vsn(2, 2, 98), NULL, 0, NULL,
 	"Limit the block devices that are used by LVM system components.\n"
-	"Because devices/filter may be overridden from the command line,\n"
-	"it is not suitable for system-wide device filtering, e.g. udev\n"
-	"and lvmetad. Use global_filter to hide devices from these LVM\n"
-	"system components. The syntax is the same as devices/filter.\n"
-	"Devices rejected by global_filter are not opened by LVM.\n")
+	"Because devices/filter may be overridden from the command line, it is\n"
+	"not suitable for system-wide device filtering, e.g. udev and lvmetad.\n"
+	"Use global_filter to hide devices from these LVM system components.\n"
+	"The syntax is the same as devices/filter. Devices rejected by\n"
+	"global_filter are not opened by LVM.\n")
 
 cfg_runtime(devices_cache_CFG, "cache", devices_CFG_SECTION, 0, CFG_TYPE_STRING, vsn(1, 0, 0), vsn(1, 2, 19),
 	"This has been replaced by the devices/cache_dir setting.\n",
@@ -274,12 +268,12 @@ cfg_runtime(devices_cache_CFG, "cache", devices_CFG_SECTION, 0, CFG_TYPE_STRING,
 
 cfg_runtime(devices_cache_dir_CFG, "cache_dir", devices_CFG_SECTION, 0, CFG_TYPE_STRING, vsn(1, 2, 19), 0, NULL,
 	"Directory in which to store the device cache file.\n"
-	"The results of filtering are cached on disk to avoid\n"
-	"rescanning dud devices (which can take a very long time).\n"
-	"By default this cache is stored in a file named .cache.\n"
-	"It is safe to delete this file; the tools regenerate it.\n"
-	"If obtain_device_list_from_udev is enabled, the list of devices\n"
-	"is obtained from udev and any existing .cache file is removed.\n")
+	"The results of filtering are cached on disk to avoid rescanning dud\n"
+	"devices (which can take a very long time). By default this cache is\n"
+	"stored in a file named .cache. It is safe to delete this file; the\n"
+	"tools regenerate it. If obtain_device_list_from_udev is enabled, the\n"
+	"list of devices is obtained from udev and any existing .cache file\n"
+	"is removed.\n")
 
 cfg(devices_cache_file_prefix_CFG, "cache_file_prefix", devices_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, DEFAULT_CACHE_FILE_PREFIX, vsn(1, 2, 19), NULL, 0, NULL,
 	"A prefix used before the .cache file name. See devices/cache_dir.\n")
@@ -289,8 +283,8 @@ cfg(devices_write_cache_state_CFG, "write_cache_state", devices_CFG_SECTION, 0,
 
 cfg_array(devices_types_CFG, "types", devices_CFG_SECTION, CFG_DEFAULT_UNDEFINED | CFG_ADVANCED, CFG_TYPE_INT | CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL, 0, NULL,
 	"List of additional acceptable block device types.\n"
-	"These are of device type names from /proc/devices,\n"
-	"followed by the maximum number of partitions.\n"
+	"These are of device type names from /proc/devices, followed by the\n"
+	"maximum number of partitions.\n"
 	"#\n"
 	"Example\n"
 	"types = [ \"fd\", 16 ]\n"
@@ -298,9 +292,8 @@ cfg_array(devices_types_CFG, "types", devices_CFG_SECTION, CFG_DEFAULT_UNDEFINED
 
 cfg(devices_sysfs_scan_CFG, "sysfs_scan", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_SYSFS_SCAN, vsn(1, 0, 8), NULL, 0, NULL,
 	"Restrict device scanning to block devices appearing in sysfs.\n"
-	"This is a quick way of filtering out block devices that are\n"
-	"not present on the system. sysfs must be part of the kernel\n"
-	"and mounted.)\n")
+	"This is a quick way of filtering out block devices that are not\n"
+	"present on the system. sysfs must be part of the kernel and mounted.)\n")
 
 cfg(devices_multipath_component_detection_CFG, "multipath_component_detection", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_MULTIPATH_COMPONENT_DETECTION, vsn(2, 2, 89), NULL, 0, NULL,
 	"Ignore devices that are components of DM multipath devices.\n")
@@ -310,8 +303,8 @@ cfg(devices_md_component_detection_CFG, "md_component_detection", devices_CFG_SE
 
 cfg(devices_fw_raid_component_detection_CFG, "fw_raid_component_detection", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_FW_RAID_COMPONENT_DETECTION, vsn(2, 2, 112), NULL, 0, NULL,
 	"Ignore devices that are components of firmware RAID devices.\n"
-	"LVM must use an external_device_info_source other than none\n"
-	"for this detection to execute.\n")
+	"LVM must use an external_device_info_source other than none for this\n"
+	"detection to execute.\n")
 
 cfg(devices_md_chunk_alignment_CFG, "md_chunk_alignment", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_MD_CHUNK_ALIGNMENT, vsn(2, 2, 48), NULL, 0, NULL,
 	"Align PV data blocks with md device's stripe-width.\n"
@@ -324,32 +317,31 @@ cfg(devices_default_data_alignment_CFG, "default_data_alignment", devices_CFG_SE
 
 cfg(devices_data_alignment_detection_CFG, "data_alignment_detection", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_DATA_ALIGNMENT_DETECTION, vsn(2, 2, 51), NULL, 0, NULL,
 	"Detect PV data alignment based on sysfs device information.\n"
-	"The start of a PV data area will be a multiple of\n"
-	"minimum_io_size or optimal_io_size exposed in sysfs.\n"
-	"minimum_io_size is the smallest request the device can perform\n"
-	"without incurring a read-modify-write penalty, e.g. MD chunk size.\n"
-	"optimal_io_size is the device's preferred unit of receiving I/O,\n"
-	"e.g. MD stripe width.\n"
+	"The start of a PV data area will be a multiple of minimum_io_size or\n"
+	"optimal_io_size exposed in sysfs. minimum_io_size is the smallest\n"
+	"request the device can perform without incurring a read-modify-write\n"
+	"penalty, e.g. MD chunk size. optimal_io_size is the device's\n"
+	"preferred unit of receiving I/O, e.g. MD stripe width.\n"
 	"minimum_io_size is used if optimal_io_size is undefined (0).\n"
 	"If md_chunk_alignment is enabled, that detects the optimal_io_size.\n"
 	"This setting takes precedence over md_chunk_alignment.\n")
 
 cfg(devices_data_alignment_CFG, "data_alignment", devices_CFG_SECTION, 0, CFG_TYPE_INT, 0, vsn(2, 2, 45), NULL, 0, NULL,
 	"Alignment of the start of a PV data area in KiB.\n"
-	"If a PV is placed directly on an md device and\n"
-	"md_chunk_alignment or data_alignment_detection are enabled,\n"
-	"then this setting is ignored.  Otherwise, md_chunk_alignment\n"
-	"and data_alignment_detection are disabled if this is set.\n"
-	"Set to 0 to use the default alignment or the page size, if larger.\n")
+	"If a PV is placed directly on an md device and md_chunk_alignment or\n"
+	"data_alignment_detection are enabled, then this setting is ignored.\n"
+	"Otherwise, md_chunk_alignment and data_alignment_detection are\n"
+	"disabled if this is set. Set to 0 to use the default alignment or the\n"
+	"page size, if larger.\n")
 
 cfg(devices_data_alignment_offset_detection_CFG, "data_alignment_offset_detection", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_DATA_ALIGNMENT_OFFSET_DETECTION, vsn(2, 2, 50), NULL, 0, NULL,
 	"Detect PV data alignment offset based on sysfs device information.\n"
 	"The start of a PV aligned data area will be shifted by the\n"
-	"alignment_offset exposed in sysfs.  This offset is often 0, but\n"
-	"may be non-zero.  Certain 4KiB sector drives that compensate for\n"
-	"windows partitioning will have an alignment_offset of 3584 bytes\n"
-	"(sector 7 is the lowest aligned logical block, the 4KiB sectors start\n"
-	"at LBA -1, and consequently sector 63 is aligned on a 4KiB boundary).\n"
+	"alignment_offset exposed in sysfs. This offset is often 0, but may\n"
+	"be non-zero. Certain 4KiB sector drives that compensate for windows\n"
+	"partitioning will have an alignment_offset of 3584 bytes (sector 7\n"
+	"is the lowest aligned logical block, the 4KiB sectors start at\n"
+	"LBA -1, and consequently sector 63 is aligned on a 4KiB boundary).\n"
 	"pvcreate --dataalignmentoffset will skip this detection.\n")
 
 cfg(devices_ignore_suspended_devices_CFG, "ignore_suspended_devices", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_IGNORE_SUSPENDED_DEVICES, vsn(1, 2, 19), NULL, 0, NULL,
@@ -359,31 +351,28 @@ cfg(devices_ignore_suspended_devices_CFG, "ignore_suspended_devices", devices_CF
 
 cfg(devices_ignore_lvm_mirrors_CFG, "ignore_lvm_mirrors", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_IGNORE_LVM_MIRRORS, vsn(2, 2, 104), NULL, 0, NULL,
 	"Do not scan 'mirror' LVs to avoid possible deadlocks.\n"
-	"This avoids possible deadlocks when using the 'mirror'\n"
-	"segment type.  This setting determines whether logical volumes\n"
-	"using the 'mirror' segment type are scanned for LVM labels.\n"
-	"This affects the ability of mirrors to be used as physical volumes.\n"
-	"If this setting is enabled, it becomes impossible to create VGs\n"
-	"on top of mirror LVs, i.e. to stack VGs on mirror LVs.\n"
-	"If this setting is disabled, allowing mirror LVs to be scanned,\n"
-	"it may cause LVM processes and I/O to the mirror to become blocked.\n"
-	"This is due to the way that the mirror segment type handles failures.\n"
-	"In order for the hang to occur, an LVM command must be run just after\n"
-	"a failure and before the automatic LVM repair process takes place,\n"
-	"or there must be failures in multiple mirrors in the same VG at the\n"
-	"same time with write failures occurring moments before a scan of the\n"
-	"mirror's labels.\n"
-	"The 'mirror' scanning problems do not apply to LVM RAID types like\n"
-	"'raid1' which handle failures in a different way, making them a\n"
-	"better choice for VG stacking.\n")
+	"This avoids possible deadlocks when using the 'mirror' segment type.\n"
+	"This setting determines whether LVs using the 'mirror' segment type\n"
+	"are scanned for LVM labels. This affects the ability of mirrors to\n"
+	"be used as physical volumes. If this setting is enabled, it is\n"
+	"impossible to create VGs on top of mirror LVs, i.e. to stack VGs on\n"
+	"mirror LVs. If this setting is disabled, allowing mirror LVs to be\n"
+	"scanned, it may cause LVM processes and I/O to the mirror to become\n"
+	"blocked. This is due to the way that the mirror segment type handles\n"
+	"failures. In order for the hang to occur, an LVM command must be run\n"
+	"just after a failure and before the automatic LVM repair process\n"
+	"takes place, or there must be failures in multiple mirrors in the\n"
+	"same VG at the same time with write failures occurring moments before\n"
+	"a scan of the mirror's labels. The 'mirror' scanning problems do not\n"
+	"apply to LVM RAID types like 'raid1' which handle failures in a\n"
+	"different way, making them a better choice for VG stacking.\n")
 
 cfg(devices_disable_after_error_count_CFG, "disable_after_error_count", devices_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_DISABLE_AFTER_ERROR_COUNT, vsn(2, 2, 75), NULL, 0, NULL,
 	"Number of I/O errors after which a device is skipped.\n"
-	"During each LVM operation, errors received from each device\n"
-	"are counted. If the counter of a device exceeds the limit set\n"
-	"here, no further I/O is sent to that device for the remainder\n"
-	"of the operation.\n"
-	"Setting this to 0 disables the counters altogether.\n")
+	"During each LVM operation, errors received from each device are\n"
+	"counted. If the counter of a device exceeds the limit set here,\n"
+	"no further I/O is sent to that device for the remainder of the\n"
+	"operation. Setting this to 0 disables the counters altogether.\n")
 
 cfg(devices_require_restorefile_with_uuid_CFG, "require_restorefile_with_uuid", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_REQUIRE_RESTOREFILE_WITH_UUID, vsn(2, 2, 73), NULL, 0, NULL,
 	"Allow use of pvcreate --uuid without requiring --restorefile.\n")
@@ -391,29 +380,29 @@ cfg(devices_require_restorefile_with_uuid_CFG, "require_restorefile_with_uuid",
 cfg(devices_pv_min_size_CFG, "pv_min_size", devices_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_PV_MIN_SIZE_KB, vsn(2, 2, 85), NULL, 0, NULL,
 	"Minimum size in KiB of block devices which can be used as PVs.\n"
 	"In a clustered environment all nodes must use the same value.\n"
-	"Any value smaller than 512KiB is ignored.  The previous built-in\n"
+	"Any value smaller than 512KiB is ignored. The previous built-in\n"
 	"value was 512.\n")
 
 cfg(devices_issue_discards_CFG, "issue_discards", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_ISSUE_DISCARDS, vsn(2, 2, 85), NULL, 0, NULL,
 	"Issue discards to PVs that are no longer used by an LV.\n"
-	"Discards are sent to an LV's underlying physical volumes when\n"
-	"the LV is no longer using the physical volumes' space, e.g.\n"
-	"lvremove, lvreduce.  Discards inform the storage that a region\n"
-	"is no longer used.  Storage that supports discards advertise\n"
-	"the protocol-specific way discards should be issued by the\n"
-	"kernel (TRIM, UNMAP, or WRITE SAME with UNMAP bit set).\n"
-	"Not all storage will support or benefit from discards, but SSDs\n"
-	"and thinly provisioned LUNs generally do.  If enabled, discards\n"
-	"will only be issued if both the storage and kernel provide support.\n")
+	"Discards are sent to an LV's underlying physical volumes when the LV\n"
+	"is no longer using the physical volumes' space, e.g. lvremove,\n"
+	"lvreduce. Discards inform the storage that a region is no longer\n"
+	"used. Storage that supports discards advertise the protocol-specific\n"
+	"way discards should be issued by the kernel (TRIM, UNMAP, or\n"
+	"WRITE SAME with UNMAP bit set). Not all storage will support or\n"
+	"benefit from discards, but SSDs and thinly provisioned LUNs\n"
+	"generally do. If enabled, discards will only be issued if both the\n"
+	"storage and kernel provide support.\n")
 
 cfg_array(allocation_cling_tag_list_CFG, "cling_tag_list", allocation_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 77), NULL, 0, NULL,
 	"Advise LVM which PVs to use when searching for new space.\n"
-	"When searching for free space to extend an LV, the 'cling'\n"
-	"allocation policy will choose space on the same PVs as the last\n"
-	"segment of the existing LV.  If there is insufficient space and a\n"
-	"list of tags is defined here, it will check whether any of them are\n"
-	"attached to the PVs concerned and then seek to match those PV tags\n"
-	"between existing extents and new extents.\n"
+	"When searching for free space to extend an LV, the 'cling' allocation\n"
+	"policy will choose space on the same PVs as the last segment of the\n"
+	"existing LV. If there is insufficient space and a list of tags is\n"
+	"defined here, it will check whether any of them are attached to the\n"
+	"PVs concerned and then seek to match those PV tags between existing\n"
+	"extents and new extents.\n"
 	"#\n"
 	"Example\n"
 	"Use the special tag \"@*\" as a wildcard to match any PV tag:\n"
@@ -428,39 +417,33 @@ cfg(allocation_maximise_cling_CFG, "maximise_cling", allocation_CFG_SECTION, 0,
 	"Use a previous allocation algorithm.\n"
 	"Changes made in version 2.02.85 extended the reach of the 'cling'\n"
 	"policies to detect more situations where data can be grouped onto\n"
-	"the same disks.  This setting can be used to disable the changes\n"
+	"the same disks. This setting can be used to disable the changes\n"
 	"and revert to the previous algorithm.\n")
 
 cfg(allocation_use_blkid_wiping_CFG, "use_blkid_wiping", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, 1, vsn(2, 2, 105), "@DEFAULT_USE_BLKID_WIPING@", 0, NULL,
 	"Use blkid to detect existing signatures on new PVs and LVs.\n"
-	"The blkid library can detect more signatures than the\n"
-	"native LVM detection code, but may take longer.\n"
-	"LVM needs to be compiled with blkid wiping support for\n"
-	"this setting to apply.\n"
-	"LVM native detection code is currently able to recognize:\n"
-	"MD device signatures, swap signature, and LUKS signatures.\n"
-	"To see the list of signatures recognized by blkid, check the\n"
-	"output of the 'blkid -k' command.\n")
+	"The blkid library can detect more signatures than the native LVM\n"
+	"detection code, but may take longer. LVM needs to be compiled with\n"
+	"blkid wiping support for this setting to apply. LVM native detection\n"
+	"code is currently able to recognize: MD device signatures,\n"
+	"swap signature, and LUKS signatures. To see the list of signatures\n"
+	"recognized by blkid, check the output of the 'blkid -k' command.\n")
 
 cfg(allocation_wipe_signatures_when_zeroing_new_lvs_CFG, "wipe_signatures_when_zeroing_new_lvs", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, 1, vsn(2, 2, 105), NULL, 0, NULL,
 	"Look for and erase any signatures while zeroing a new LV.\n"
-	"Zeroing is controlled by the -Z/--zero option, and if not\n"
-	"specified, zeroing is used by default if possible.\n"
-	"Zeroing simply overwrites the first 4KiB of a new LV\n"
-	"with zeroes and does no signature detection or wiping.\n"
-	"Signature wiping goes beyond zeroing and detects exact\n"
-	"types and positions of signatures within the whole LV.\n"
-	"It provides a cleaner LV after creation as all known\n"
-	"signatures are wiped.  The LV is not claimed incorrectly\n"
-	"by other tools because of old signatures from previous use.\n"
-	"The number of signatures that LVM can detect depends on the\n"
-	"detection code that is selected (see use_blkid_wiping.)\n"
-	"Wiping each detected signature must be confirmed.\n"
-	"The command line option -W/--wipesignatures takes precedence\n"
-	"over this setting.\n"
-	"When this setting is disabled, signatures on new LVs are\n"
-	"not detected or erased unless the -W/--wipesignatures y\n"
-	"option is used directly.\n")
+	"The --wipesignatures option overrides this setting.\n"
+	"Zeroing is controlled by the -Z/--zero option, and if not specified,\n"
+	"zeroing is used by default if possible. Zeroing simply overwrites the\n"
+	"first 4KiB of a new LV with zeroes and does no signature detection or\n"
+	"wiping. Signature wiping goes beyond zeroing and detects exact types\n"
+	"and positions of signatures within the whole LV. It provides a\n"
+	"cleaner LV after creation as all known signatures are wiped. The LV\n"
+	"is not claimed incorrectly by other tools because of old signatures\n"
+	"from previous use. The number of signatures that LVM can detect\n"
+	"depends on the detection code that is selected (see\n"
+	"use_blkid_wiping.) Wiping each detected signature must be confirmed.\n"
+	"When this setting is disabled, signatures on new LVs are not detected\n"
+	"or erased unless the --wipesignatures option is used directly.\n")
 
 cfg(allocation_mirror_logs_require_separate_pvs_CFG, "mirror_logs_require_separate_pvs", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_MIRROR_LOGS_REQUIRE_SEPARATE_PVS, vsn(2, 2, 85), NULL, 0, NULL,
 	"Mirror logs and images will always use different PVs.\n"
@@ -487,9 +470,8 @@ cfg(allocation_cache_mode_CFG, "cache_mode", allocation_CFG_SECTION, CFG_PROFILA
 
 cfg(allocation_cache_policy_CFG, "cache_policy", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, 0, vsn(2, 2, 128), NULL, 0, NULL,
 	"The default cache policy used for new cache volume.\n"
-	"For the kernel 4.2 and newer the default policy is smq\n"
-	"(Stochastic multique), otherwise the older mq (Multiqueue),\n"
-	"policy is selected.\n")
+	"Since kernel 4.2 the default policy is smq (Stochastic multique),\n"
+	"otherwise the older mq (Multiqueue) policy is selected.\n")
 
 cfg_section(allocation_cache_settings_CFG_SECTION, "cache_settings", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, vsn(2, 2, 128), 0, NULL,
 	"Individual settings for policies.\n"
@@ -501,15 +483,14 @@ cfg_section(policy_settings_CFG_SUBSECTION, "policy_settings", allocation_cache_
 
 cfg_runtime(allocation_cache_pool_chunk_size_CFG, "cache_pool_chunk_size", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_UNDEFINED, CFG_TYPE_INT, vsn(2, 2, 106), 0, NULL,
 	"The minimal chunk size in KiB for cache pool volumes.\n"
-	"Using a chunk_size that is too large can result in wasteful\n"
-	"use of the cache, where small reads and writes can cause\n"
-	"large sections of an LV to be mapped into the cache.  However,\n"
-	"choosing a chunk_size that is too small can result in more\n"
-	"overhead trying to manage the numerous chunks that become mapped\n"
-	"into the cache.  The former is more of a problem than the latter\n"
-	"in most cases, so we default to a value that is on the smaller\n"
-	"end of the spectrum.  Supported values range from 32KiB to\n"
-	"1GiB in multiples of 32.\n")
+	"Using a chunk_size that is too large can result in wasteful use of\n"
+	"the cache, where small reads and writes can cause large sections of\n"
+	"an LV to be mapped into the cache. However, choosing a chunk_size\n"
+	"that is too small can result in more overhead trying to manage the\n"
+	"numerous chunks that become mapped into the cache. The former is\n"
+	"more of a problem than the latter in most cases, so the default is\n"
+	"on the smaller end of the spectrum. Supported values range from\n"
+	"32KiB to 1GiB in multiples of 32.\n")
 
 cfg(allocation_thin_pool_metadata_require_separate_pvs_CFG, "thin_pool_metadata_require_separate_pvs", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_THIN_POOL_METADATA_REQUIRE_SEPARATE_PVS, vsn(2, 2, 89), NULL, 0, NULL,
 	"Thin pool metdata and data will always use different PVs.\n")
@@ -545,12 +526,11 @@ cfg(allocation_thin_pool_chunk_size_policy_CFG, "thin_pool_chunk_size_policy", a
 
 cfg_runtime(allocation_thin_pool_chunk_size_CFG, "thin_pool_chunk_size", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_UNDEFINED, CFG_TYPE_INT, vsn(2, 2, 99), 0, NULL,
 	"The minimal chunk size in KiB for thin pool volumes.\n"
-	"Larger chunk sizes may improve performance for plain\n"
-	"thin volumes, however using them for snapshot volumes\n"
-	"is less efficient, as it consumes more space and takes\n"
-	"extra time for copying.  When unset, lvm tries to estimate\n"
-	"chunk size starting from 64KiB.  Supported values are in\n"
-	"the range 64KiB to 1GiB.\n")
+	"Larger chunk sizes may improve performance for plain thin volumes,\n"
+	"however using them for snapshot volumes is less efficient, as it\n"
+	"consumes more space and takes extra time for copying. When unset,\n"
+	"lvm tries to estimate chunk size starting from 64KiB. Supported\n"
+	"values are in the range 64KiB to 1GiB.\n")
 
 cfg(allocation_physical_extent_size_CFG, "physical_extent_size", allocation_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_EXTENT_SIZE, vsn(2, 2, 112), NULL, 0, NULL,
 	"Default physical extent size in KiB to use for new VGs.\n")
@@ -560,14 +540,13 @@ cfg(log_verbose_CFG, "verbose", log_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_VERBO
 
 cfg(log_silent_CFG, "silent", log_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_SILENT, vsn(2, 2, 98), NULL, 0, NULL,
 	"Suppress all non-essential messages from stdout.\n"
-	"This has the same effect as -qq.\n"
-	"When enabled, the following commands still produce output:\n"
-	"dumpconfig, lvdisplay, lvmdiskscan, lvs, pvck, pvdisplay,\n"
-	"pvs, version, vgcfgrestore -l, vgdisplay, vgs.\n"
+	"This has the same effect as -qq. When enabled, the following commands\n"
+	"still produce output: dumpconfig, lvdisplay, lvmdiskscan, lvs, pvck,\n"
+	"pvdisplay, pvs, version, vgcfgrestore -l, vgdisplay, vgs.\n"
 	"Non-essential messages are shifted from log level 4 to log level 5\n"
 	"for syslog and lvm2_log_fn purposes.\n"
-	"Any 'yes' or 'no' questions not overridden by other arguments\n"
-	"are suppressed and default to 'no'.\n")
+	"Any 'yes' or 'no' questions not overridden by other arguments are\n"
+	"suppressed and default to 'no'.\n")
 
 cfg(log_syslog_CFG, "syslog", log_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_SYSLOG, vsn(1, 0, 0), NULL, 0, NULL,
 	"Send log messages through syslog.\n")
@@ -604,12 +583,10 @@ cfg(log_activate_file_CFG, "activate_file", log_CFG_SECTION, CFG_DEFAULT_UNDEFIN
 
 cfg_array(log_debug_classes_CFG, "debug_classes", log_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, "#Smemory#Sdevices#Sactivation#Sallocation#Slvmetad#Smetadata#Scache#Slocking#Slvmpolld", vsn(2, 2, 99), NULL, 0, NULL,
 	"Select log messages by class.\n"
-	"Some debugging messages are assigned to a class\n"
-	"and only appear in debug output if the class is\n"
-	"listed here.  Classes currently available:\n"
-	"memory, devices, activation, allocation,\n"
-	"lvmetad, metadata, cache, locking, lvmpolld.\n"
-	"Use \"all\" to see everything.\n")
+	"Some debugging messages are assigned to a class and only appear in\n"
+	"debug output if the class is listed here. Classes currently\n"
+	"available: memory, devices, activation, allocation, lvmetad,\n"
+	"metadata, cache, locking, lvmpolld. Use \"all\" to see everything.\n")
 
 cfg(backup_backup_CFG, "backup", backup_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_BACKUP_ENABLED, vsn(1, 0, 0), NULL, 0, NULL,
 	"Maintain a backup of the current metadata configuration.\n"
@@ -651,14 +628,13 @@ cfg(global_si_unit_consistency_CFG, "si_unit_consistency", global_CFG_SECTION, C
 	"Distinguish between powers of 1024 and 1000 bytes.\n"
 	"The LVM commands distinguish between powers of 1024 bytes,\n"
 	"e.g. KiB, MiB, GiB, and powers of 1000 bytes, e.g. KB, MB, GB.\n"
-	"If scripts depend on the old behaviour, disable\n"
-	"this setting temporarily until they are updated.\n")
+	"If scripts depend on the old behaviour, disable this setting\n"
+	"temporarily until they are updated.\n")
 
 cfg(global_suffix_CFG, "suffix", global_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_SUFFIX, vsn(1, 0, 0), NULL, 0, NULL,
 	"Display unit suffix for sizes.\n"
-	"This setting has no effect if the units are in human-readable\n"
-	"form (global/units = \"h\") in which case the suffix is always\n"
-	"displayed.\n")
+	"This setting has no effect if the units are in human-readable form\n"
+	"(global/units = \"h\") in which case the suffix is always displayed.\n")
 
 cfg(global_activation_CFG, "activation", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_ACTIVATION, vsn(1, 0, 0), NULL, 0, NULL,
 	"Enable/disable communication with the kernel device-mapper.\n"
@@ -669,16 +645,19 @@ cfg(global_activation_CFG, "activation", global_CFG_SECTION, 0, CFG_TYPE_BOOL, D
 
 cfg(global_fallback_to_lvm1_CFG, "fallback_to_lvm1", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_FALLBACK_TO_LVM1, vsn(1, 0, 18), "@DEFAULT_FALLBACK_TO_LVM1@", 0, NULL,
 	"Try running LVM1 tools if LVM cannot communicate with DM.\n"
-	"This option only applies to 2.4 kernels and is provided to\n"
-	"help switch between device-mapper kernels and LVM1 kernels.\n"
-	"The LVM1 tools need to be installed with .lvm1 suffices,\n"
-	"e.g. vgscan.lvm1. They will stop working once the lvm2\n"
-	"on-disk metadata format is used.\n")
+	"This option only applies to 2.4 kernels and is provided to help\n"
+	"switch between device-mapper kernels and LVM1 kernels. The LVM1\n"
+	"tools need to be installed with .lvm1 suffices, e.g. vgscan.lvm1.\n"
+	"They will stop working once the lvm2 on-disk metadata format is used.\n")
 
 cfg(global_format_CFG, "format", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_FORMAT, vsn(1, 0, 0), NULL, 0, NULL,
 	"The default metadata format that commands should use.\n"
-	"\"lvm1\" or \"lvm2\".\n"
-	"The command line override is -M1 or -M2.\n")
+	"The -M 1|2 option overrides this setting.\n"
+	"#\n"
+	"Accepted values:\n"
+	"  lvm1\n"
+	"  lvm2\n"
+	"#\n")
 
 cfg_array(global_format_libraries_CFG, "format_libraries", global_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL, 0, NULL,
 	"Shared libraries that process different metadata formats.\n"
@@ -728,36 +707,31 @@ cfg(global_wait_for_locks_CFG, "wait_for_locks", global_CFG_SECTION, 0, CFG_TYPE
 
 cfg(global_fallback_to_clustered_locking_CFG, "fallback_to_clustered_locking", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_FALLBACK_TO_CLUSTERED_LOCKING, vsn(2, 2, 42), NULL, 0, NULL,
 	"Attempt to use built-in cluster locking if locking_type 2 fails.\n"
-	"If using external locking (type 2) and initialisation fails,\n"
-	"with this enabled, an attempt will be made to use the built-in\n"
-	"clustered locking.\n"
-	"If you are using a customised locking_library you should disable this.\n")
+	"If using external locking (type 2) and initialisation fails, with\n"
+	"this enabled, an attempt will be made to use the built-in clustered\n"
+	"locking. Disable this if using a customised locking_library.\n")
 
 cfg(global_fallback_to_local_locking_CFG, "fallback_to_local_locking", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_FALLBACK_TO_LOCAL_LOCKING, vsn(2, 2, 42), NULL, 0, NULL,
 	"Use locking_type 1 (local) if locking_type 2 or 3 fail.\n"
-	"If an attempt to initialise type 2 or type 3 locking failed,\n"
-	"perhaps because cluster components such as clvmd are not\n"
-	"running, with this enabled, an attempt will be made to use\n"
-	"local file-based locking (type 1). If this succeeds, only\n"
-	"commands against local volume groups will proceed.\n"
-	"Volume Groups marked as clustered will be ignored.\n")
+	"If an attempt to initialise type 2 or type 3 locking failed, perhaps\n"
+	"because cluster components such as clvmd are not running, with this\n"
+	"enabled, an attempt will be made to use local file-based locking\n"
+	"(type 1). If this succeeds, only commands against local VGs will\n"
+	"proceed. VGs marked as clustered will be ignored.\n")
 
 cfg(global_locking_dir_CFG, "locking_dir", global_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_LOCK_DIR, vsn(1, 0, 0), "@DEFAULT_LOCK_DIR@", 0, NULL,
 	"Directory to use for LVM command file locks.\n"
-	"Local non-LV directory that holds file-based locks\n"
-	"while commands are in progress.  A directory like\n"
-	"/tmp that may get wiped on reboot is OK.\n")
+	"Local non-LV directory that holds file-based locks while commands are\n"
+	"in progress. A directory like /tmp that may get wiped on reboot is OK.\n")
 
 cfg(global_prioritise_write_locks_CFG, "prioritise_write_locks", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_PRIORITISE_WRITE_LOCKS, vsn(2, 2, 52), NULL, 0, NULL,
 	"Allow quicker VG write access during high volume read access.\n"
-	"When there are competing read-only and read-write access\n"
-	"requests for a volume group's metadata, instead of always\n"
-	"granting the read-only requests immediately, delay them to\n"
-	"allow the read-write requests to be serviced.  Without this\n"
-	"setting, write access may be stalled by a high volume of\n"
-	"read-only requests.\n"
-	"This option only affects locking_type 1 viz.\n"
-	"local file-based locking.\n")
+	"When there are competing read-only and read-write access requests for\n"
+	"a volume group's metadata, instead of always granting the read-only\n"
+	"requests immediately, delay them to allow the read-write requests to\n"
+	"be serviced. Without this setting, write access may be stalled by a\n"
+	"high volume of read-only requests. This option only affects\n"
+	"locking_type 1 viz. local file-based locking.\n")
 
 cfg(global_library_dir_CFG, "library_dir", global_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL, 0, NULL,
 	"Search this directory first for shared libraries.\n")
@@ -767,24 +741,21 @@ cfg(global_locking_library_CFG, "locking_library", global_CFG_SECTION, CFG_ALLOW
 
 cfg(global_abort_on_internal_errors_CFG, "abort_on_internal_errors", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_ABORT_ON_INTERNAL_ERRORS, vsn(2, 2, 57), NULL, 0, NULL,
 	"Abort a command that encounters an internal error.\n"
-	"Treat any internal errors as fatal errors, aborting\n"
-	"the process that encountered the internal error.\n"
-	"Please only enable for debugging.\n")
+	"Treat any internal errors as fatal errors, aborting the process that\n"
+	"encountered the internal error. Please only enable for debugging.\n")
 
 cfg(global_detect_internal_vg_cache_corruption_CFG, "detect_internal_vg_cache_corruption", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_DETECT_INTERNAL_VG_CACHE_CORRUPTION, vsn(2, 2, 96), NULL, 0, NULL,
 	"Internal verification of VG structures.\n"
-	"Check if CRC matches when a parsed VG is\n"
-	"used multiple times. This is useful to catch\n"
-	"unexpected changes to cached VG structures.\n"
+	"Check if CRC matches when a parsed VG is used multiple times. This\n"
+	"is useful to catch unexpected changes to cached VG structures.\n"
 	"Please only enable for debugging.\n")
 
 cfg(global_metadata_read_only_CFG, "metadata_read_only", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_METADATA_READ_ONLY, vsn(2, 2, 75), NULL, 0, NULL,
 	"No operations that change on-disk metadata are permitted.\n"
-	"Additionally, read-only commands that encounter metadata\n"
-	"in need of repair will still be allowed to proceed exactly\n"
-	"as if the repair had been performed (except for the unchanged\n"
-	"vg_seqno). Inappropriate use could mess up your system,\n"
-	"so seek advice first!\n")
+	"Additionally, read-only commands that encounter metadata in need of\n"
+	"repair will still be allowed to proceed exactly as if the repair had\n"
+	"been performed (except for the unchanged vg_seqno). Inappropriate\n"
+	"use could mess up your system, so seek advice first!\n")
 
 cfg(global_mirror_segtype_default_CFG, "mirror_segtype_default", global_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_MIRROR_SEGTYPE, vsn(2, 2, 87), "@DEFAULT_MIRROR_SEGTYPE@", 0, NULL,
 	"The segment type used by the short mirroring option -m.\n"
@@ -801,10 +772,10 @@ cfg(global_mirror_segtype_default_CFG, "mirror_segtype_default", global_CFG_SECT
 	"    devices/ignore_lvm_mirrors.)\n"
 	"  raid1\n"
 	"    This is a newer RAID1 implementation using the MD RAID1\n"
-	"    personality through device-mapper.  It is characterized by a\n"
+	"    personality through device-mapper. It is characterized by a\n"
 	"    lack of log options. (A log is always allocated for every\n"
 	"    device and they are placed on the same device as the image,\n"
-	"    so no separate devices are required.)  This mirror\n"
+	"    so no separate devices are required.) This mirror\n"
 	"    implementation does not require I/O to be blocked while\n"
 	"    handling a failure. This mirror implementation is not\n"
 	"    cluster-aware and cannot be used in a shared (active/active)\n"
@@ -813,10 +784,10 @@ cfg(global_mirror_segtype_default_CFG, "mirror_segtype_default", global_CFG_SECT
 
 cfg(global_raid10_segtype_default_CFG, "raid10_segtype_default", global_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_RAID10_SEGTYPE, vsn(2, 2, 99), "@DEFAULT_RAID10_SEGTYPE@", 0, NULL,
 	"The segment type used by the -i -m combination.\n"
+	"The --type raid10|mirror option overrides this setting.\n"
 	"The --stripes/-i and --mirrors/-m options can both be specified\n"
 	"during the creation of a logical volume to use both striping and\n"
 	"mirroring for the LV. There are two different implementations.\n"
-	"The --type raid10|mirror option overrides this setting.\n"
 	"#\n"
 	"Accepted values:\n"
 	"  raid10\n"
@@ -831,9 +802,9 @@ cfg(global_raid10_segtype_default_CFG, "raid10_segtype_default", global_CFG_SECT
 
 cfg(global_sparse_segtype_default_CFG, "sparse_segtype_default", global_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_SPARSE_SEGTYPE, vsn(2, 2, 112), "@DEFAULT_SPARSE_SEGTYPE@", 0, NULL,
 	"The segment type used by the -V -L combination.\n"
+	"The --type snapshot|thin option overrides this setting.\n"
 	"The combination of -V and -L options creates a sparse LV. There are\n"
 	"two different implementations.\n"
-	"The --type snapshot|thin option overrides this setting.\n"
 	"#\n"
 	"Accepted values:\n"
 	"  snapshot\n"
@@ -845,7 +816,7 @@ cfg(global_sparse_segtype_default_CFG, "sparse_segtype_default", global_CFG_SECT
 	"    A newer implementation that uses thin provisioning. It has a\n"
 	"    bigger minimal chunk size (64KiB) and uses a separate volume for\n"
 	"    metadata. It has better performance, especially when more data\n"
-	"    is used.  It also supports full snapshots.\n"
+	"    is used. It also supports full snapshots.\n"
 	"#\n")
 
 cfg(global_lvdisplay_shows_full_device_path_CFG, "lvdisplay_shows_full_device_path", global_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_LVDISPLAY_SHOWS_FULL_DEVICE_PATH, vsn(2, 2, 89), NULL, 0, NULL,
@@ -857,94 +828,83 @@ cfg(global_lvdisplay_shows_full_device_path_CFG, "lvdisplay_shows_full_device_pa
 
 cfg(global_use_lvmetad_CFG, "use_lvmetad", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_USE_LVMETAD, vsn(2, 2, 93), "@DEFAULT_USE_LVMETAD@", 0, NULL,
 	"Use lvmetad to cache metadata and reduce disk scanning.\n"
-	"When enabled (and running), lvmetad provides LVM commands\n"
-	"with VG metadata and PV state.  LVM commands then avoid\n"
-	"reading this information from disks which can be slow.\n"
-	"When disabled (or not running), LVM commands fall back to\n"
-	"scanning disks to obtain VG metadata.\n"
-	"lvmetad is kept updated via udev rules which must be set\n"
-	"up for LVM to work correctly. (The udev rules should be\n"
-	"installed by default.) Without a proper udev setup, changes\n"
-	"in the system's block device configuration will be unknown\n"
-	"to LVM, and ignored until a manual 'pvscan --cache' is run.\n"
-	"If lvmetad was running while use_lvmetad was disabled,\n"
-	"it must be stopped, use_lvmetad enabled, and then started.\n"
-	"When using lvmetad, LV activation is switched to an automatic,\n"
-	"event-based mode.  In this mode, LVs are activated based on\n"
-	"incoming udev events that inform lvmetad when PVs appear on\n"
-	"the system. When a VG is complete (all PVs present), it is\n"
-	"auto-activated. The auto_activation_volume_list setting\n"
+	"When enabled (and running), lvmetad provides LVM commands with VG\n"
+	"metadata and PV state. LVM commands then avoid reading this\n"
+	"information from disks which can be slow. When disabled (or not\n"
+	"running), LVM commands fall back to scanning disks to obtain VG\n"
+	"metadata. lvmetad is kept updated via udev rules which must be set\n"
+	"up for LVM to work correctly. (The udev rules should be installed\n"
+	"by default.) Without a proper udev setup, changes in the system's\n"
+	"block device configuration will be unknown to LVM, and ignored\n"
+	"until a manual 'pvscan --cache' is run. If lvmetad was running\n"
+	"while use_lvmetad was disabled, it must be stopped, use_lvmetad\n"
+	"enabled, and then started. When using lvmetad, LV activation is\n"
+	"switched to an automatic, event-based mode. In this mode, LVs are\n"
+	"activated based on incoming udev events that inform lvmetad when\n"
+	"PVs appear on the system. When a VG is complete (all PVs present),\n"
+	"it is auto-activated. The auto_activation_volume_list setting\n"
 	"controls which LVs are auto-activated (all by default.)\n"
-	"When lvmetad is updated (automatically by udev events, or\n"
-	"directly by pvscan --cache), devices/filter is ignored and\n"
-	"all devices are scanned by default. lvmetad always keeps\n"
-	"unfiltered information which is provided to LVM commands.\n"
-	"Each LVM command then filters based on devices/filter.\n"
-	"This does not apply to other, non-regexp, filtering settings:\n"
-	"component filters such as multipath and MD are checked\n"
-	"during pvscan --cache.\n"
-	"To filter a device and prevent scanning from the LVM system\n"
-	"entirely, including lvmetad, use devices/global_filter.\n"
-	"lvmetad is not compatible with locking_type 3 (clustering).\n"
-	"LVM prints warnings and ignores lvmetad if this combination\n"
-	"is seen.\n")
+	"When lvmetad is updated (automatically by udev events, or directly\n"
+	"by pvscan --cache), devices/filter is ignored and all devices are\n"
+	"scanned by default. lvmetad always keeps unfiltered information\n"
+	"which is provided to LVM commands. Each LVM command then filters\n"
+	"based on devices/filter. This does not apply to other, non-regexp,\n"
+	"filtering settings: component filters such as multipath and MD\n"
+	"are checked during pvscan --cache. To filter a device and prevent\n"
+	"scanning from the LVM system entirely, including lvmetad, use\n"
+	"devices/global_filter.\n")
 
 cfg(global_use_lvmlockd_CFG, "use_lvmlockd", global_CFG_SECTION, 0, CFG_TYPE_BOOL, 0, vsn(2, 2, 124), NULL, 0, NULL,
-	"Use lvmlockd for locking among hosts using LVM on shared storage.\n")
+	"Use lvmlockd for locking among hosts using LVM on shared storage.\n"
+	"See lvmlockd(8) for more information.\n")
 
 cfg(global_lvmlockd_lock_retries_CFG, "lvmlockd_lock_retries", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_LVMLOCKD_LOCK_RETRIES, vsn(2, 2, 125), NULL, 0, NULL,
 	"Retry lvmlockd lock requests this many times.\n")
 
 cfg(global_sanlock_lv_extend_CFG, "sanlock_lv_extend", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_SANLOCK_LV_EXTEND_MB, vsn(2, 2, 124), NULL, 0, NULL,
 	"Size in MiB to extend the internal LV holding sanlock locks.\n"
-	"The internal LV holds locks for each LV in the VG, and after\n"
-	"enough LVs have been created, the internal LV needs to be extended.\n"
-	"lvcreate will automatically extend the internal LV when needed by\n"
-	"the amount specified here.  Setting this to 0 disables the\n"
-	"automatic extension and can cause lvcreate to fail.\n")
+	"The internal LV holds locks for each LV in the VG, and after enough\n"
+	"LVs have been created, the internal LV needs to be extended. lvcreate\n"
+	"will automatically extend the internal LV when needed by the amount\n"
+	"specified here. Setting this to 0 disables the automatic extension\n"
+	"and can cause lvcreate to fail.\n")
 
 cfg(global_thin_check_executable_CFG, "thin_check_executable", global_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, THIN_CHECK_CMD, vsn(2, 2, 94), "@THIN_CHECK_CMD@", 0, NULL,
 	"The full path to the thin_check command.\n"
-	"LVM uses this command to check that a thin metadata\n"
-	"device is in a usable state.\n"
-	"When a thin pool is activated and after it is deactivated,\n"
-	"this command is run. Activation will only proceed if the\n"
-	"command has an exit status of 0.\n"
-	"Set to \"\" to skip this check.  (Not recommended.)\n"
-	"Also see thin_check_options.\n"
-	"The thin tools are available from the package\n"
-	"device-mapper-persistent-data.\n")
+	"LVM uses this command to check that a thin metadata device is in a\n"
+	"usable state. When a thin pool is activated and after it is\n"
+	"deactivated, this command is run. Activation will only proceed if\n"
+	"the command has an exit status of 0. Set to \"\" to skip this check.\n"
+	"(Not recommended.) Also see thin_check_options.\n"
+	"(See package device-mapper-persistent-data or thin-provisioning-tools)\n")
 
 cfg(global_thin_dump_executable_CFG, "thin_dump_executable", global_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, THIN_DUMP_CMD, vsn(2, 2, 100), "@THIN_DUMP_CMD@", 0, NULL,
 	"The full path to the thin_dump command.\n"
 	"LVM uses this command to dump thin pool metadata.\n"
-	"(For thin tools, see thin_check_executable.)\n")
+	"(See package device-mapper-persistent-data or thin-provisioning-tools)\n")
 
 cfg(global_thin_repair_executable_CFG, "thin_repair_executable", global_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, THIN_REPAIR_CMD, vsn(2, 2, 100), "@THIN_REPAIR_CMD@", 0, NULL,
 	"The full path to the thin_repair command.\n"
-	"LVM uses this command to repair a thin metadata device\n"
-	"if it is in an unusable state.\n"
-	"Also see thin_repair_options.\n"
-	"(For thin tools, see thin_check_executable.)\n")
+	"LVM uses this command to repair a thin metadata device if it is in\n"
+	"an unusable state. Also see thin_repair_options.\n"
+	"(See package device-mapper-persistent-data or thin-provisioning-tools)\n")
 
 cfg_array(global_thin_check_options_CFG, "thin_check_options", global_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_THIN_CHECK_OPTIONS_CONFIG, vsn(2, 2, 96), NULL, 0, NULL,
 	"List of options passed to the thin_check command.\n"
-	"With thin_check version 2.1 or newer you can add\n"
-	"--ignore-non-fatal-errors to let it pass through\n"
-	"ignorable errors and fix them later.\n"
-	"With thin_check version 3.2 or newer you should add\n"
-	"--clear-needs-check-flag.\n")
+	"With thin_check version 2.1 or newer you can add the option\n"
+	"--ignore-non-fatal-errors to let it pass through ignorable errors\n"
+	"and fix them later. With thin_check version 3.2 or newer you should\n"
+	"include the option --clear-needs-check-flag.\n")
 
 cfg_array(global_thin_repair_options_CFG, "thin_repair_options", global_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_THIN_REPAIR_OPTIONS_CONFIG, vsn(2, 2, 100), NULL, 0, NULL,
 	"List of options passed to the thin_repair command.\n")
 
 cfg_array(global_thin_disabled_features_CFG, "thin_disabled_features", global_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 99), NULL, 0, NULL,
 	"Features to not use in the thin driver.\n"
-	"This can be helpful for testing, or to avoid\n"
-	"using a feature that is causing problems.\n"
-	"Features: block_size, discards, discards_non_power_2,\n"
-	"external_origin, metadata_resize, external_origin_extend,\n"
-	"error_if_no_space.\n"
+	"This can be helpful for testing, or to avoid using a feature that is\n"
+	"causing problems. Features include: block_size, discards,\n"
+	"discards_non_power_2, external_origin, metadata_resize,\n"
+	"external_origin_extend, error_if_no_space.\n"
 	"#\n"
 	"Example\n"
 	"thin_disabled_features = [ \"discards\", \"block_size\" ]\n"
@@ -952,9 +912,8 @@ cfg_array(global_thin_disabled_features_CFG, "thin_disabled_features", global_CF
 
 cfg_array(global_cache_disabled_features_CFG, "cache_disabled_features", global_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 128), NULL, 0, NULL,
 	"Features to not use in the cache driver.\n"
-	"This can be helpful for testing, or to avoid\n"
-	"using a feature that is causing problems.\n"
-	"Features: policy_mq, policy_smq.\n"
+	"This can be helpful for testing, or to avoid using a feature that is\n"
+	"causing problems. Features include: policy_mq, policy_smq.\n"
 	"#\n"
 	"Example\n"
 	"cache_disabled_features = [ \"policy_smq\" ]\n"
@@ -962,32 +921,28 @@ cfg_array(global_cache_disabled_features_CFG, "cache_disabled_features", global_
 
 cfg(global_cache_check_executable_CFG, "cache_check_executable", global_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, CACHE_CHECK_CMD, vsn(2, 2, 108), "@CACHE_CHECK_CMD@", 0, NULL,
 	"The full path to the cache_check command.\n"
-	"LVM uses this command to check that a cache metadata\n"
-	"device is in a usable state.\n"
-	"When a cached LV is activated and after it is deactivated,\n"
-	"this command is run. Activation will only proceed if the\n"
-	"command has an exit status of 0.\n"
-	"Set to \"\" to skip this check.  (Not recommended.)\n"
-	"Also see cache_check_options.\n"
-	"The cache tools are available from the package\n"
-	"device-mapper-persistent-data.\n"
-	"With cache_check version 5.0 or newer you should add\n"
-	"--clear-needs-check-flag.\n")
+	"LVM uses this command to check that a cache metadata device is in a\n"
+	"usable state. When a cached LV is activated and after it is\n"
+	"deactivated, this command is run. Activation will only proceed if the\n"
+	"command has an exit status of 0. Set to \"\" to skip this check.\n"
+	"(Not recommended.) Also see cache_check_options.\n"
+	"(See package device-mapper-persistent-data or thin-provisioning-tools)\n")
 
 cfg(global_cache_dump_executable_CFG, "cache_dump_executable", global_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, CACHE_DUMP_CMD, vsn(2, 2, 108), "@CACHE_DUMP_CMD@", 0, NULL,
 	"The full path to the cache_dump command.\n"
 	"LVM uses this command to dump cache pool metadata.\n"
-	"(For cache tools, see cache_check_executable.)\n")
+	"(See package device-mapper-persistent-data or thin-provisioning-tools)\n")
 
 cfg(global_cache_repair_executable_CFG, "cache_repair_executable", global_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, CACHE_REPAIR_CMD, vsn(2, 2, 108), "@CACHE_REPAIR_CMD@", 0, NULL,
 	"The full path to the cache_repair command.\n"
-	"LVM uses this command to repair a cache metadata device\n"
-	"if it is in an unusable state.\n"
-	"Also see cache_repair_options.\n"
-	"(For cache tools, see cache_check_executable.)\n")
+	"LVM uses this command to repair a cache metadata device if it is in\n"
+	"an unusable state. Also see cache_repair_options.\n"
+	"(See package device-mapper-persistent-data or thin-provisioning-tools)\n")
 
 cfg_array(global_cache_check_options_CFG, "cache_check_options", global_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_CACHE_CHECK_OPTIONS_CONFIG, vsn(2, 2, 108), NULL, 0, NULL,
-	"List of options passed to the cache_check command.\n")
+	"List of options passed to the cache_check command.\n"
+	"With cache_check version 5.0 or newer you should include the option\n"
+	"--clear-needs-check-flag.\n")
 
 cfg_array(global_cache_repair_options_CFG, "cache_repair_options", global_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_CACHE_REPAIR_OPTIONS_CONFIG, vsn(2, 2, 108), NULL, 0, NULL,
 	"List of options passed to the cache_repair command.\n")
@@ -1024,67 +979,63 @@ cfg(global_system_id_file_CFG, "system_id_file", global_CFG_SECTION, CFG_DEFAULT
 
 cfg(activation_checks_CFG, "checks", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_ACTIVATION_CHECKS, vsn(2, 2, 86), NULL, 0, NULL,
 	"Perform internal checks of libdevmapper operations.\n"
-	"Useful for debugging problems with activation.\n"
-	"Some of the checks may be expensive, so it's best to use\n"
-	"this only when there seems to be a problem.\n")
+	"Useful for debugging problems with activation. Some of the checks may\n"
+	"be expensive, so it's best to use this only when there seems to be a\n"
+	"problem.\n")
 
 cfg(global_use_lvmpolld_CFG, "use_lvmpolld", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_USE_LVMPOLLD, vsn(2, 2, 120), "@DEFAULT_USE_LVMPOLLD@", 0, NULL,
 	"Use lvmpolld to supervise long running LVM commands.\n"
 	"When enabled, control of long running LVM commands is transferred\n"
-	"from the original LVM command to the lvmpolld daemon.  This allows\n"
+	"from the original LVM command to the lvmpolld daemon. This allows\n"
 	"the operation to continue independent of the original LVM command.\n"
 	"After lvmpolld takes over, the LVM command displays the progress\n"
-	"of the ongoing operation.  lvmpolld itself runs LVM commands to manage\n"
-	"the progress of ongoing operations.  lvmpolld can be used as a native\n"
-	"systemd service, which allows it to be started on demand, and to use\n"
-	"its own control group.  When this option is disabled, LVM commands will\n"
-	"supervise long running operations by forking themselves.\n")
+	"of the ongoing operation. lvmpolld itself runs LVM commands to\n"
+	"manage the progress of ongoing operations. lvmpolld can be used as\n"
+	"a native systemd service, which allows it to be started on demand,\n"
+	"and to use its own control group. When this option is disabled, LVM\n"
+	"commands will supervise long running operations by forking themselves.\n")
 
 cfg(activation_udev_sync_CFG, "udev_sync", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_UDEV_SYNC, vsn(2, 2, 51), NULL, 0, NULL,
 	"Use udev notifications to synchronize udev and LVM.\n"
-	"When disabled, LVM commands will not wait for notifications\n"
-	"from udev, but continue irrespective of any possible udev\n"
-	"processing in the background.  Only use this if udev is not\n"
-	"running or has rules that ignore the devices LVM creates.\n"
-	"If enabled when udev is not running, and LVM processes\n"
-	"are waiting for udev, run 'dmsetup udevcomplete_all' to\n"
-	"wake them up.\n"
-	"The '--nodevsync' option overrides this setting.\n")
+	"The --nodevsync option overrides this setting.\n"
+	"When disabled, LVM commands will not wait for notifications from\n"
+	"udev, but continue irrespective of any possible udev processing in\n"
+	"the background. Only use this if udev is not running or has rules\n"
+	"that ignore the devices LVM creates. If enabled when udev is not\n"
+	"running, and LVM processes are waiting for udev, run the command\n"
+	"'dmsetup udevcomplete_all' to wake them up.\n")
 
 cfg(activation_udev_rules_CFG, "udev_rules", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_UDEV_RULES, vsn(2, 2, 57), NULL, 0, NULL,
 	"Use udev rules to manage LV device nodes and symlinks.\n"
-	"When disabled, LVM will manage the device nodes and\n"
-	"symlinks for active LVs itself.\n"
-	"Manual intervention may be required if this setting is\n"
-	"changed while LVs are active.\n")
+	"When disabled, LVM will manage the device nodes and symlinks for\n"
+	"active LVs itself. Manual intervention may be required if this\n"
+	"setting is changed while LVs are active.\n")
 
 cfg(activation_verify_udev_operations_CFG, "verify_udev_operations", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_VERIFY_UDEV_OPERATIONS, vsn(2, 2, 86), NULL, 0, NULL,
 	"Use extra checks in LVM to verify udev operations.\n"
-	"This enables additional checks (and if necessary,\n"
-	"repairs) on entries in the device directory after\n"
-	"udev has completed processing its events.\n"
-	"Useful for diagnosing problems with LVM/udev interactions.\n")
+	"This enables additional checks (and if necessary, repairs) on entries\n"
+	"in the device directory after udev has completed processing its\n"
+	"events. Useful for diagnosing problems with LVM/udev interactions.\n")
 
 cfg(activation_retry_deactivation_CFG, "retry_deactivation", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_RETRY_DEACTIVATION, vsn(2, 2, 89), NULL, 0, NULL,
 	"Retry failed LV deactivation.\n"
-	"If LV deactivation fails, LVM will retry for a few\n"
-	"seconds before failing. This may happen because a\n"
-	"process run from a quick udev rule temporarily opened\n"
-	"the device.\n")
+	"If LV deactivation fails, LVM will retry for a few seconds before\n"
+	"failing. This may happen because a process run from a quick udev rule\n"
+	"temporarily opened the device.\n")
 
 cfg(activation_missing_stripe_filler_CFG, "missing_stripe_filler", activation_CFG_SECTION, CFG_ADVANCED, CFG_TYPE_STRING, DEFAULT_STRIPE_FILLER, vsn(1, 0, 0), NULL, 0, NULL,
 	"Method to fill missing stripes when activating an incomplete LV.\n"
-	"Using 'error' will make inaccessible parts of the device return\n"
-	"I/O errors on access.  You can instead use a device path, in which\n"
-	"case, that device will be used in place of missing stripes.\n"
-	"Using anything other than 'error' with mirrored or snapshotted\n"
-	"volumes is likely to result in data corruption.\n")
+	"Using 'error' will make inaccessible parts of the device return I/O\n"
+	"errors on access. You can instead use a device path, in which case,\n"
+	"that device will be used in place of missing stripes. Using anything\n"
+	"other than 'error' with mirrored or snapshotted volumes is likely to\n"
+	"result in data corruption.\n")
 
 cfg(activation_use_linear_target_CFG, "use_linear_target", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_USE_LINEAR_TARGET, vsn(2, 2, 89), NULL, 0, NULL,
 	"Use the linear target to optimize single stripe LVs.\n"
-	"When disabled, the striped target is used. The linear\n"
-	"target is an optimised version of the striped target\n"
-	"that only handles a single stripe.\n")
+	"When disabled, the striped target is used. The linear target is an\n"
+	"optimised version of the striped target that only handles a single\n"
+	"stripe.\n")
 
 cfg(activation_reserved_stack_CFG, "reserved_stack", activation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_RESERVED_STACK, vsn(1, 0, 0), NULL, 0, NULL,
 	"Stack size in KiB to reserve for use while devices are suspended.\n"
@@ -1190,19 +1141,17 @@ cfg(activation_mirror_region_size_CFG, "mirror_region_size", activation_CFG_SECT
 
 cfg(activation_raid_region_size_CFG, "raid_region_size", activation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_RAID_REGION_SIZE, vsn(2, 2, 99), NULL, 0, NULL,
 	"Size in KiB of each raid or mirror synchronization region.\n"
-	"For raid or mirror segment types, this is the amount of\n"
-	"data that is copied at once when initializing, or moved\n"
-	"at once by pvmove.\n")
+	"For raid or mirror segment types, this is the amount of data that is\n"
+	"copied at once when initializing, or moved at once by pvmove.\n")
 
 cfg(activation_error_when_full_CFG, "error_when_full", activation_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_ERROR_WHEN_FULL, vsn(2, 2, 115), NULL, 0, NULL,
 	"Return errors if a thin pool runs out of space.\n"
-	"When enabled, writes to thin LVs immediately return\n"
-	"an error if the thin pool is out of data space.\n"
-	"When disabled, writes to thin LVs are queued if the\n"
-	"thin pool is out of space, and processed when the\n"
-	"thin pool data space is extended.\n"
-	"New thin pools are assigned the behavior defined here.\n"
-	"The '--errorwhenfull y|n' option overrides this setting.\n")
+	"The --errorwhenfull option overrides this setting.\n"
+	"When enabled, writes to thin LVs immediately return an error if the\n"
+	"thin pool is out of data space. When disabled, writes to thin LVs\n"
+	"are queued if the thin pool is out of space, and processed when the\n"
+	"thin pool data space is extended. New thin pools are assigned the\n"
+	"behavior defined here.\n")
 
 cfg(activation_readahead_CFG, "readahead", activation_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_READ_AHEAD, vsn(1, 0, 23), NULL, 0, NULL,
 	"Setting to use when there is no readahead setting in metadata.\n"
@@ -1226,8 +1175,8 @@ cfg(activation_raid_fault_policy_CFG, "raid_fault_policy", activation_CFG_SECTIO
 	"Accepted values:\n"
 	"  warn\n"
 	"    Use the system log to warn the user that a device in the RAID LV\n"
-	"    has failed.  It is left to the user to run lvconvert --repair\n"
-	"    manually to remove or replace the failed device.  As long as the\n"
+	"    has failed. It is left to the user to run lvconvert --repair\n"
+	"    manually to remove or replace the failed device. As long as the\n"
 	"    number of failed devices does not exceed the redundancy of the LV\n"
 	"    (1 device for raid4/5, 2 for raid6), the LV will remain usable.\n"
 	"  allocate\n"
@@ -1273,12 +1222,12 @@ cfg_runtime(activation_mirror_image_fault_policy_CFG, "mirror_image_fault_policy
 
 cfg(activation_mirror_log_fault_policy_CFG, "mirror_log_fault_policy", activation_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_MIRROR_LOG_FAULT_POLICY, vsn(1, 2, 18), NULL, 0, NULL,
 	"Defines how a device failure in a 'mirror' log LV is handled.\n"
-	"The mirror_image_fault_policy description for mirrored LVs\n"
-	"also applies to mirrored log LVs.\n")
+	"The mirror_image_fault_policy description for mirrored LVs also\n"
+	"applies to mirrored log LVs.\n")
 
 cfg(activation_mirror_device_fault_policy_CFG, "mirror_device_fault_policy", activation_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_MIRROR_DEVICE_FAULT_POLICY, vsn(1, 2, 10), NULL, vsn(2, 2, 57),
 	"This has been replaced by the activation/mirror_image_fault_policy setting.\n",
-        "Define how a device failure affecting a mirror is handled.\n")
+	"Define how a device failure affecting a mirror is handled.\n")
 
 cfg(activation_snapshot_autoextend_threshold_CFG, "snapshot_autoextend_threshold", activation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_SNAPSHOT_AUTOEXTEND_THRESHOLD, vsn(2, 2, 75), NULL, 0, NULL,
 	"Auto-extend a snapshot when its usage exceeds this percent.\n"
@@ -1334,16 +1283,14 @@ cfg(activation_thin_pool_autoextend_percent_CFG, "thin_pool_autoextend_percent",
 
 cfg_array(activation_mlock_filter_CFG, "mlock_filter", activation_CFG_SECTION, CFG_DEFAULT_UNDEFINED | CFG_ADVANCED, CFG_TYPE_STRING, NULL, vsn(2, 2, 62), NULL, 0, NULL,
 	"Do not mlock these memory areas.\n"
-	"While activating devices, I/O to devices being\n"
-	"(re)configured is suspended. As a precaution against\n"
-	"deadlocks, LVM pins memory it is using so it is not\n"
-	"paged out, and will not require I/O to reread.\n"
-	"Groups of pages that are known not to be accessed during\n"
-	"activation do not need to be pinned into memory.\n"
-	"Each string listed in this setting is compared against\n"
-	"each line in /proc/self/maps, and the pages corresponding\n"
-	"to lines that match are not pinned.  On some systems,\n"
-	"locale-archive was found to make up over 80% of the memory\n"
+	"While activating devices, I/O to devices being (re)configured is\n"
+	"suspended. As a precaution against deadlocks, LVM pins memory it is\n"
+	"using so it is not paged out, and will not require I/O to reread.\n"
+	"Groups of pages that are known not to be accessed during activation\n"
+	"do not need to be pinned into memory. Each string listed in this\n"
+	"setting is compared against each line in /proc/self/maps, and the\n"
+	"pages corresponding to lines that match are not pinned. On some\n"
+	"systems, locale-archive was found to make up over 80% of the memory\n"
 	"used by the process.\n"
 	"#\n"
 	"Example\n"
@@ -1352,42 +1299,39 @@ cfg_array(activation_mlock_filter_CFG, "mlock_filter", activation_CFG_SECTION, C
 
 cfg(activation_use_mlockall_CFG, "use_mlockall", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_USE_MLOCKALL, vsn(2, 2, 62), NULL, 0, NULL,
 	"Use the old behavior of mlockall to pin all memory.\n"
-	"Prior to version 2.02.62, LVM used mlockall() to pin\n"
-	"the whole process's memory while activating devices.\n")
+	"Prior to version 2.02.62, LVM used mlockall() to pin the whole\n"
+	"process's memory while activating devices.\n")
 
 cfg(activation_monitoring_CFG, "monitoring", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_DMEVENTD_MONITOR, vsn(2, 2, 63), NULL, 0, NULL,
 	"Monitor LVs that are activated.\n"
-	"When enabled, LVM will ask dmeventd to monitor LVs\n"
-	"that are activated.\n"
-	"The '--ignoremonitoring' option overrides this setting.\n")
+	"The --ignoremonitoring option overrides this setting.\n"
+	"When enabled, LVM will ask dmeventd to monitor activated LVs.\n")
 
 cfg(activation_polling_interval_CFG, "polling_interval", activation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_INTERVAL, vsn(2, 2, 63), NULL, 0, NULL,
 	"Check pvmove or lvconvert progress at this interval (seconds).\n"
 	"When pvmove or lvconvert must wait for the kernel to finish\n"
-	"synchronising or merging data, they check and report progress\n"
-	"at intervals of this number of seconds.\n"
-	"If this is set to 0 and there is only one thing to wait for,\n"
-	"there are no progress reports, but the process is awoken\n"
-	"immediately once the operation is complete.\n")
+	"synchronising or merging data, they check and report progress at\n"
+	"intervals of this number of seconds. If this is set to 0 and there\n"
+	"is only one thing to wait for, there are no progress reports, but\n"
+	"the process is awoken immediately once the operation is complete.\n")
 
 cfg(activation_auto_set_activation_skip_CFG, "auto_set_activation_skip", activation_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_AUTO_SET_ACTIVATION_SKIP, vsn(2,2,99), NULL, 0, NULL,
 	"Set the activation skip flag on new thin snapshot LVs.\n"
-	"An LV can have a persistent 'activation skip' flag.\n"
-	"The flag causes the LV to be skipped during normal activation.\n"
-	"The lvchange/vgchange -K option is required to activate LVs\n"
-	"that have the activation skip flag set.\n"
-	"When this setting is enabled, the activation skip flag is\n"
-	"set on new thin snapshot LVs.\n"
-	"The '--setactivationskip y|n' option overrides this setting.\n")
+	"The --setactivationskip option overrides this setting.\n"
+	"An LV can have a persistent 'activation skip' flag. The flag causes\n"
+	"the LV to be skipped during normal activation. The lvchange/vgchange\n"
+	"-K option is required to activate LVs that have the activation skip\n"
+	"flag set. When this setting is enabled, the activation skip flag is\n"
+	"set on new thin snapshot LVs.\n")
 
 cfg(activation_mode_CFG, "activation_mode", activation_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_ACTIVATION_MODE, vsn(2,2,108), NULL, 0, NULL,
 	"How LVs with missing devices are activated.\n"
-	"The '--activationmode' option overrides this setting.\n"
+	"The --activationmode option overrides this setting.\n"
 	"#\n"
 	"Accepted values:\n"
 	"  complete\n"
 	"    Only allow activation of an LV if all of the Physical Volumes it\n"
-	"    uses are present.  Other PVs in the Volume Group may be missing.\n"
+	"    uses are present. Other PVs in the Volume Group may be missing.\n"
 	"  degraded\n"
 	"    Like complete, but additionally RAID LVs of segment type raid1,\n"
 	"    raid4, raid5, radid6 and raid10 will be activated if there is no\n"
@@ -1402,15 +1346,15 @@ cfg(activation_mode_CFG, "activation_mode", activation_CFG_SECTION, 0, CFG_TYPE_
 
 cfg_array(activation_lock_start_list_CFG, "lock_start_list", activation_CFG_SECTION, CFG_ALLOW_EMPTY|CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 124), NULL, 0, NULL,
 	"Locking is started only for VGs selected by this list.\n"
-	"The rules are the same as those for LVs in volume_list.\n")
+	"The rules are the same as those for volume_list.\n")
 
 cfg_array(activation_auto_lock_start_list_CFG, "auto_lock_start_list", activation_CFG_SECTION, CFG_ALLOW_EMPTY|CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 124), NULL, 0, NULL,
 	"Locking is auto-started only for VGs selected by this list.\n"
-	"The rules are the same as those for LVs in auto_activation_volume_list.\n")
+	"The rules are the same as those for auto_activation_volume_list.\n")
 
 cfg(metadata_pvmetadatacopies_CFG, "pvmetadatacopies", metadata_CFG_SECTION, CFG_ADVANCED | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_PVMETADATACOPIES, vsn(1, 0, 0), NULL, 0, NULL,
 	"Number of copies of metadata to store on each PV.\n"
-	"The '--pvmetadatacopies' option overrides this setting.\n"
+	"The --pvmetadatacopies option overrides this setting.\n"
 	"#\n"
 	"Accepted values:\n"
 	"  2\n"
@@ -1425,29 +1369,27 @@ cfg(metadata_pvmetadatacopies_CFG, "pvmetadatacopies", metadata_CFG_SECTION, CFG
 
 cfg(metadata_vgmetadatacopies_CFG, "vgmetadatacopies", metadata_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_VGMETADATACOPIES, vsn(2, 2, 69), NULL, 0, NULL,
 	"Number of copies of metadata to maintain for each VG.\n"
-	"If set to a non-zero value, LVM automatically chooses which of\n"
-	"the available metadata areas to use to achieve the requested\n"
-	"number of copies of the VG metadata.  If you set a value larger\n"
-	"than the the total number of metadata areas available, then\n"
-	"metadata is stored in them all.\n"
-	"The value 0 (unmanaged) disables this automatic management\n"
-	"and allows you to control which metadata areas are used at\n"
-	"the individual PV level using 'pvchange --metadataignore y|n'.\n"
-	"The '--vgmetadatacopies' option overrides this setting.\n")
+	"The --vgmetadatacopies option overrides this setting.\n"
+	"If set to a non-zero value, LVM automatically chooses which of the\n"
+	"available metadata areas to use to achieve the requested number of\n"
+	"copies of the VG metadata. If you set a value larger than the the\n"
+	"total number of metadata areas available, then metadata is stored in\n"
+	"them all. The value 0 (unmanaged) disables this automatic management\n"
+	"and allows you to control which metadata areas are used at the\n"
+	"individual PV level using pvchange --metadataignore y|n.\n")
 
 cfg(metadata_pvmetadatasize_CFG, "pvmetadatasize", metadata_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_PVMETADATASIZE, vsn(1, 0, 0), NULL, 0, NULL,
 	"Approximate number of sectors to use for each metadata copy.\n"
-	"VGs with large numbers of PVs or LVs, or VGs containing\n"
-	"complex LV structures, may need additional space for VG\n"
-	"metadata. The metadata areas are treated as circular buffers,\n"
-	"so unused space becomes filled with an archive of the most\n"
-	"recent previous versions of the metadata.\n")
+	"VGs with large numbers of PVs or LVs, or VGs containing complex LV\n"
+	"structures, may need additional space for VG metadata. The metadata\n"
+	"areas are treated as circular buffers, so unused space becomes filled\n"
+	"with an archive of the most recent previous versions of the metadata.\n")
 
 cfg(metadata_pvmetadataignore_CFG, "pvmetadataignore", metadata_CFG_SECTION, CFG_ADVANCED | CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_PVMETADATAIGNORE, vsn(2, 2, 69), NULL, 0, NULL,
 	"Ignore metadata areas on a new PV.\n"
-	"If metadata areas on a PV are ignored, LVM will not store\n"
-	"metadata in them.\n"
-	"The '--metadataignore' option overrides this setting.\n")
+	"The --metadataignore option overrides this setting.\n"
+	"If metadata areas on a PV are ignored, LVM will not store metadata\n"
+	"in them.\n")
 
 cfg(metadata_stripesize_CFG, "stripesize", metadata_CFG_SECTION, CFG_ADVANCED | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_STRIPESIZE, vsn(1, 0, 0), NULL, 0, NULL, NULL)
 
@@ -1456,13 +1398,12 @@ cfg_array(metadata_dirs_CFG, "dirs", metadata_CFG_SECTION, CFG_ADVANCED | CFG_DE
 	"These directories must not be on logical volumes!\n"
 	"It's possible to use LVM with a couple of directories here,\n"
 	"preferably on different (non-LV) filesystems, and with no other\n"
-	"on-disk metadata (pvmetadatacopies = 0). Or this can be in\n"
-	"addition to on-disk metadata areas.\n"
-	"The feature was originally added to simplify testing and is not\n"
-	"supported under low memory situations - the machine could lock up.\n"
-	"Never edit any files in these directories by hand unless you\n"
-	"you are absolutely sure you know what you are doing! Use\n"
-	"the supplied toolset to make changes (e.g. vgcfgrestore).\n"
+	"on-disk metadata (pvmetadatacopies = 0). Or this can be in addition\n"
+	"to on-disk metadata areas. The feature was originally added to\n"
+	"simplify testing and is not supported under low memory situations -\n"
+	"the machine could lock up. Never edit any files in these directories\n"
+	"by hand unless you are absolutely sure you know what you are doing!\n"
+	"Use the supplied toolset to make changes (e.g. vgcfgrestore).\n"
 	"#\n"
 	"Example\n"
 	"dirs = [ \"/etc/lvm/metadata\", \"/mnt/disk2/lvm/metadata2\" ]\n"
@@ -1476,9 +1417,9 @@ cfg(disk_area_id_CFG, "id", disk_area_CFG_SUBSECTION, CFG_UNSUPPORTED | CFG_DEFA
 
 cfg(report_compact_output_CFG, "compact_output", report_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_REP_COMPACT_OUTPUT, vsn(2, 2, 115), NULL, 0, NULL,
 	"Do not print empty report fields.\n"
-	"Fields that don't have a value set for any of the rows\n"
-	"reported are skipped and not printed. Compact output is\n"
-	"applicable only if report/buffered is enabled.\n")
+	"Fields that don't have a value set for any of the rows reported are\n"
+	"skipped and not printed. Compact output is applicable only if\n"
+	"report/buffered is enabled.\n")
 
 cfg(report_aligned_CFG, "aligned", report_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_REP_ALIGNED, vsn(1, 0, 0), NULL, 0, NULL,
 	"Align columns in report output.\n")
@@ -1544,7 +1485,7 @@ cfg(report_time_format_CFG, "time_format", report_CFG_SECTION, CFG_PROFILABLE |
 	"    The day of the month as a decimal number (range 01 to 31).\n"
 	"    (alt O)\n"
 	"  %D\n"
-	"    Equivalent to %m/%d/%y.  (For Americans only. Americans should\n"
+	"    Equivalent to %m/%d/%y. (For Americans only. Americans should\n"
 	"    note that in other countries%d/%m/%y is rather common. This\n"
 	"    means that in international context this format is ambiguous and\n"
 	"    should not be used.\n"
@@ -1702,7 +1643,7 @@ cfg(report_segs_sort_CFG, "segs_sort", report_CFG_SECTION, CFG_PROFILABLE | CFG_
 
 cfg(report_segs_cols_CFG, "segs_cols", report_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_SEGS_COLS, vsn(1, 0, 0), NULL, 0, NULL,
 	"List of columns to report for 'lvs --segments' command.\n"
-	"See 'lvs --segments  -o help' for the list of possible fields.\n")
+	"See 'lvs --segments -o help' for the list of possible fields.\n")
 
 cfg(report_segs_cols_verbose_CFG, "segs_cols_verbose", report_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_SEGS_COLS_VERB, vsn(1, 0, 0), NULL, 0, NULL,
 	"List of columns to report for 'lvs --segments' command in verbose mode.\n"
@@ -1723,7 +1664,7 @@ cfg(report_pvsegs_cols_verbose_CFG, "pvsegs_cols_verbose", report_CFG_SECTION, C
 cfg(dmeventd_mirror_library_CFG, "mirror_library", dmeventd_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_DMEVENTD_MIRROR_LIB, vsn(1, 2, 3), NULL, 0, NULL,
 	"The library dmeventd uses when monitoring a mirror device.\n"
 	"libdevmapper-event-lvm2mirror.so attempts to recover from\n"
-	"failures.  It removes failed devices from a volume group and\n"
+	"failures. It removes failed devices from a volume group and\n"
 	"reconfigures a mirror as necessary. If no mirror library is\n"
 	"provided, mirrors are not monitored through dmeventd.\n")
 
@@ -1731,17 +1672,15 @@ cfg(dmeventd_raid_library_CFG, "raid_library", dmeventd_CFG_SECTION, CFG_DEFAULT
 
 cfg(dmeventd_snapshot_library_CFG, "snapshot_library", dmeventd_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_DMEVENTD_SNAPSHOT_LIB, vsn(1, 2, 26), NULL, 0, NULL,
 	"The library dmeventd uses when monitoring a snapshot device.\n"
-	"libdevmapper-event-lvm2snapshot.so monitors the filling of\n"
-	"snapshots and emits a warning through syslog when the usage\n"
-	"exceeds 80%. The warning is repeated when 85%, 90% and\n"
-	"95% of the snapshot is filled.\n")
+	"libdevmapper-event-lvm2snapshot.so monitors the filling of snapshots\n"
+	"and emits a warning through syslog when the usage exceeds 80%. The\n"
+	"warning is repeated when 85%, 90% and 95% of the snapshot is filled.\n")
 
 cfg(dmeventd_thin_library_CFG, "thin_library", dmeventd_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_DMEVENTD_THIN_LIB, vsn(2, 2, 89), NULL, 0, NULL,
 	"The library dmeventd uses when monitoring a thin device.\n"
-	"libdevmapper-event-lvm2thin.so monitors the filling of\n"
-	"a pool and emits a warning through syslog when the usage\n"
-	"exceeds 80%. The warning is repeated when 85%, 90% and\n"
-	"95% of the pool is filled.\n")
+	"libdevmapper-event-lvm2thin.so monitors the filling of a pool\n"
+	"and emits a warning through syslog when the usage exceeds 80%. The\n"
+	"warning is repeated when 85%, 90% and 95% of the pool is filled.\n")
 
 cfg(dmeventd_executable_CFG, "executable", dmeventd_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_DMEVENTD_PATH, vsn(2, 2, 73), "@DMEVENTD_PATH@", 0, NULL,
 	"The full path to the dmeventd binary.\n")
@@ -1752,15 +1691,13 @@ cfg(tags_hosttags_CFG, "hosttags", tags_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_
 
 cfg_section(tag_CFG_SUBSECTION, "tag", tags_CFG_SECTION, CFG_NAME_VARIABLE | CFG_DEFAULT_COMMENTED, vsn(1, 0, 18), 0, NULL,
 	"Replace this subsection name with a custom tag name.\n"
-	"Multiple subsections like this can be created.\n"
-	"The '@' prefix for tags is optional.\n"
-	"This subsection can contain host_list, which is a\n"
-	"list of machine names. If the name of the local\n"
-	"machine is found in host_list, then the name of\n"
-	"this subsection is used as a tag and is applied\n"
-	"to the local machine as a 'host tag'.\n"
-	"If this subsection is empty (has no host_list), then\n"
-	"the subsection name is always applied as a 'host tag'.\n"
+	"Multiple subsections like this can be created. The '@' prefix for\n"
+	"tags is optional. This subsection can contain host_list, which is a\n"
+	"list of machine names. If the name of the local machine is found in\n"
+	"host_list, then the name of this subsection is used as a tag and is\n"
+	"applied to the local machine as a 'host tag'. If this subsection is\n"
+	"empty (has no host_list), then the subsection name is always applied\n"
+	"as a 'host tag'.\n"
 	"#\n"
 	"Example\n"
 	"The host tag foo is given to all hosts, and the host tag\n"
@@ -1770,18 +1707,16 @@ cfg_section(tag_CFG_SUBSECTION, "tag", tags_CFG_SECTION, CFG_NAME_VARIABLE | CFG
 
 cfg_array(tag_host_list_CFG, "host_list", tag_CFG_SUBSECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 18), NULL, 0, NULL,
 	"A list of machine names.\n"
-	"These machine names are compared to the nodename\n"
-	"returned by uname(2). If the local machine name\n"
-	"matches an entry in this list, the name of the\n"
-	"subsection is applied to the machine as a 'host tag'.\n")
+	"These machine names are compared to the nodename returned\n"
+	"by uname(2). If the local machine name matches an entry in\n"
+	"this list, the name of the subsection is applied to the\n"
+	"machine as a 'host tag'.\n")
 
 cfg(local_system_id_CFG, "system_id", local_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, NULL, vsn(2, 2, 117), NULL, 0, NULL,
 	"Defines the local system ID for lvmlocal mode.\n"
-	"This is used when global/system_id_source is set\n"
-	"to 'lvmlocal' in the main configuration file,\n"
-	"e.g. lvm.conf.\n"
-	"When used, it must be set to a unique value\n"
-	"among all hosts sharing access to the storage,\n"
+	"This is used when global/system_id_source is set to 'lvmlocal' in the\n"
+	"main configuration file, e.g. lvm.conf. When used, it must be set to\n"
+	"a unique value among all hosts sharing access to the storage,\n"
 	"e.g. a host name.\n"
 	"#\n"
 	"Example\n"
@@ -1793,17 +1728,15 @@ cfg(local_system_id_CFG, "system_id", local_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_D
 
 cfg_array(local_extra_system_ids_CFG, "extra_system_ids", local_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 117), NULL, 0, NULL,
 	"A list of extra VG system IDs the local host can access.\n"
-	"VGs with the system IDs listed here (in addition\n"
-	"to the host's own system ID) can be fully accessed\n"
-	"by the local host.  (These are system IDs that the\n"
-	"host sees in VGs, not system IDs that identify the\n"
-	"local host, which is determined by system_id_source.)\n"
-	"Use this only after consulting 'man lvmsystemid'\n"
-	"to be certain of correct usage and possible dangers.\n")
+	"VGs with the system IDs listed here (in addition to the host's own\n"
+	"system ID) can be fully accessed by the local host. (These are\n"
+	"system IDs that the host sees in VGs, not system IDs that identify\n"
+	"the local host, which is determined by system_id_source.)\n"
+	"Use this only after consulting 'man lvmsystemid' to be certain of\n"
+	"correct usage and possible dangers.\n")
 
 cfg(local_host_id_CFG, "host_id", local_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, 0, vsn(2, 2, 124), NULL, 0, NULL,
 	"The lvmlockd sanlock host_id.\n"
-	"This must be a unique among all hosts,\n"
-	"and must be between 1 and 2000.\n")
+	"This must be unique among all hosts, and must be between 1 and 2000.\n")
 
 cfg(CFG_COUNT, NULL, root_CFG_SECTION, 0, CFG_TYPE_INT, 0, vsn(0, 0, 0), NULL, 0, NULL, NULL)


