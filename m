From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 10 Apr 2015 21:44:25 +0000 (UTC)
Subject: master - config: editing descriptions
Message-ID: <20150410214425.0833D610A7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b851b74cba6dd8d1c2c831d5e3d2662734f987e8
Commit:        b851b74cba6dd8d1c2c831d5e3d2662734f987e8
Parent:        2872e8c289a04e60e59494b41336ae9e9eb6021e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Apr 10 16:41:54 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 10 16:43:38 2015 -0500

config: editing descriptions

Update wording and formatting.
---
 lib/config/config_settings.h |  482 ++++++++++++++++++++++--------------------
 1 files changed, 248 insertions(+), 234 deletions(-)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 63332d4..ecdf368 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -123,7 +123,8 @@ cfg_runtime(config_profile_dir_CFG, "profile_dir", config_CFG_SECTION, 0, CFG_TY
 	"Directory where LVM looks for configuration profiles.\n")
 
 cfg(devices_dir_CFG, "dir", devices_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_DEV_DIR, vsn(1, 0, 0),
-	"Where do you want your volume groups to appear ?")
+	"Directory in which to create volume group device nodes.\n"
+	"Commands also accept this as a prefix on volume group names.\n")
 
 cfg_array(devices_scan_CFG, "scan", devices_CFG_SECTION, 0, CFG_TYPE_STRING, "#S/dev", vsn(1, 0, 0),
 	"An array of directories that contain the device nodes you wish\n"
@@ -138,18 +139,20 @@ cfg(devices_obtain_device_list_from_udev_CFG, "obtain_device_list_from_udev", de
 	"subdirectories found in the device directory. This setting is applied\n"
 	"to udev-managed device directory only, other directories will be scanned\n"
 	"fully. LVM needs to be compiled with udev support for this setting to\n"
-	"take effect. N.B. Any device node or symlink not managed by udev in\n"
-	"udev directory will be ignored with this setting on.\n")
+	"take effect. Any device node or symlink not managed by udev in udev\n"
+	"directory will be ignored with this setting on.\n")
 
 cfg(devices_external_device_info_source_CFG, "external_device_info_source", devices_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_EXTERNAL_DEVICE_INFO_SOURCE, vsn(2, 2, 116),
-	"Select external device information source to use for further and more\n"
-	"detailed device determination. Some information may already be available\n"
-	"in the system and LVM can use this information to determine the exact\n"
-	"type or use of the device it processes. Using existing external device\n"
-	"information source can speed up device processing as LVM does not need\n"
-	"to run its own native routines to acquire this information. For example,\n"
-	"such information is used to drive LVM filtering like MD component\n"
-	"detection, multipath component detection, partition detection and others.\n"
+	"Select external device information source to use for\n"
+	"further and more detailed device determination. Some\n"
+	"information may already be available in the system and\n"
+	"LVM can use this information to determine the exact type\n"
+	"or use of the device it processes. Using existing external\n"
+	"device information source can speed up device processing\n"
+	"as LVM does not need to run its own native routines to acquire\n"
+	"this information. For example, such information is used to\n"
+	"drive LVM filtering like MD component detection, multipath\n"
+	"component detection, partition detection and others.\n"
 	"Possible options are: none, udev.\n"
 	"none - No external device information source is used.\n"
 	"udev - Reuse existing udev database records. Applicable\n"
@@ -157,84 +160,74 @@ cfg(devices_external_device_info_source_CFG, "external_device_info_source", devi
 
 cfg_array(devices_preferred_names_CFG, "preferred_names", devices_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 2, 19),
 	"If several entries in the scanned directories correspond to the\n"
-	"same block device and the tools need to display a name for device,\n"
-	"all the pathnames are matched against each item in the following\n"
-	"list of regular expressions in turn and the first match is used.\n"
+	"same block device and the tools need to display a name for the device,\n"
+	"all the path names are matched against each item in this list of\n"
+	"regular expressions. The first match is used.\n"
 	"Try to avoid using undescriptive /dev/dm-N names, if present.\n"
-	"In case no prefererred name matches or if preferred_names are not\n"
-	"defined at all, builtin rules are used to determine the preference.\n"
-	"The first builtin rule checks path prefixes and it gives preference\n"
-	"based on this ordering (where /dev depends on devices/dev setting):\n"
-	"/dev/mapper > /dev/disk > /dev/dm-* > /dev/block\n"
-	"If the ordering above cannot be applied, the path with fewer slashes\n"
-	"gets preference then.\n"
-	"If the number of slashes is the same, a symlink gets preference.\n"
-	"Finally, if all the rules mentioned above are not applicable,\n"
-	"lexicographical order is used over paths and the smallest one\n"
-	"of all gets preference.\n"
+	"If no preferred name matches, or if preferred_names are not\n"
+	"defined, built-in rules are used until one produces a preference.\n"
+	"Rule 1 checks path prefixes and gives preference in this order:\n"
+	"/dev/mapper, /dev/disk, /dev/dm-*, /dev/block (/dev from devices/dev)\n"
+	"Rule 2 prefers the path with the least slashes.\n"
+	"Rule 3 prefers a symlink.\n"
+	"Rule 4 prefers the path with least value in lexicographical order.\n"
 	"Example:\n"
 	"preferred_names = [ \"^/dev/mpath/\", \"^/dev/mapper/mpath\", \"^/dev/[hs]d\" ]\n")
 
 cfg_array(devices_filter_CFG, "filter", devices_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0),
-	"A filter that tells LVM to only use a restricted set of devices.\n"
-	"The filter consists of an array of regular expressions.  These\n"
-	"expressions can be delimited by a character of your choice, and\n"
-	"prefixed with either an 'a' (for accept) or 'r' (for reject).\n"
-	"The first expression found to match a device name determines if\n"
-	"the device will be accepted or rejected (ignored).  Devices that\n"
-	"don't match any patterns are accepted.\n"
-	"Be careful if there there are symbolic links or multiple filesystem\n"
-	"entries for the same device as each name is checked separately against\n"
-	"the list of patterns.  The effect is that if the first pattern in the\n"
-	"list to match a name is an 'a' pattern for any of the names, the device\n"
-	"is accepted; otherwise if the first pattern in the list to match a name\n"
-	"is an 'r' pattern for any of the names it is rejected; otherwise it is\n"
-	"accepted.\n"
-	"Don't have more than one filter line active at once: only one gets used.\n"
-	"Run vgscan after you change this parameter to ensure that\n"
-	"the cache file gets regenerated (see below).\n"
-	"If it doesn't do what you expect, check the output of 'vgscan -vvvv'.\n"
-	"If lvmetad is used, then see \"A note about device filtering while\n"
-	"lvmetad is used\" comment that is attached to global/use_lvmetad setting.\n"
-	"Examples:\n"
-	"By default we accept every block device:\n"
+	"Patterns used to accept or reject devices found by a scan.\n"
+	"Patterns are regular expressions delimited by any character\n"
+	"and preceded by 'a' for accept or 'r' for reject.\n"
+	"The list is traversed in order, and the first regex that matches\n"
+	"determines if the device is accepted or rejected (ignored).\n"
+	"Devices that don't match any patterns are accepted.\n"
+	"If there are several names for the same device, e.g. from symlinks,\n"
+	"the first pattern matching any of the names determines if the\n"
+	"device is accepted or rejected (depending on whether the first\n"
+	"matching pattern is 'a' or 'r'.)\n"
+	"Run vgscan after changing the filter to regenerate the cache.\n"
+	"See the use_lvmetad comment for a special case regarding filters.\n"
+	"Example:\n"
+	"Accept every block device.\n"
 	"filter = [ \"a/.*/\" ]\n"
-	"Exclude the cdrom drive:\n"
+	"Example:\n"
+	"Reject the cdrom drive.\n"
 	"filter = [ \"r|/dev/cdrom|\" ]\n"
-	"When testing I like to work with just loopback devices:\n"
+	"Example:\n"
+	"Work with just loopback devices, e.g. for testing.\n"
 	"filter = [ \"a/loop/\", \"r/.*/\" ]\n"
-	"Or maybe all loops and ide drives except hdc:\n"
+	"Example:\n"
+	"Accept all loop devices and ide drives except hdc.\n"
 	"filter =[ \"a|loop|\", \"r|/dev/hdc|\", \"a|/dev/ide|\", \"r|.*|\" ]\n"
-	"Use anchors if you want to be really specific:\n"
+	"Example:\n"
+	"Use anchors to be very specific.\n"
 	"filter = [ \"a|^/dev/hda8$|\", \"r/.*/\" ]\n")
 
 cfg_array(devices_global_filter_CFG, "global_filter", devices_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 98),
-	"Since filter is often overridden from command line, it is not suitable\n"
-	"for system-wide device filtering (udev rules, lvmetad). To hide devices\n"
-	"from LVM-specific udev processing and/or from lvmetad, you need to set\n"
-	"global_filter. The syntax is the same as for normal filter\n"
-	"above. Devices that fail the global_filter are not even opened by LVM.\n")
+	"Since filter is often overridden from the command line,\n"
+	"it is not suitable for system-wide device filtering,\n"
+	"e.g. udev rules and lvmetad. To hide devices from LVM-specific\n"
+	"udev processing and lvmetad, use global_filter.\n"
+	"The syntax is the same as devices/filter above.\n"
+	"Devices rejected by global_filter are not opened by LVM.\n")
 
 cfg_runtime(devices_cache_CFG, "cache", devices_CFG_SECTION, 0, CFG_TYPE_STRING, vsn(1, 0, 0),
-	"This setting has been replaced by the cache_dir setting.\n")
+	"This setting has been replaced by the devices/cache_dir setting.\n")
 
 cfg_runtime(devices_cache_dir_CFG, "cache_dir", devices_CFG_SECTION, 0, CFG_TYPE_STRING, vsn(1, 2, 19),
-	"The results of the filtering are cached on disk to avoid\n"
+	"The results of filtering are cached on disk to avoid\n"
 	"rescanning dud devices (which can take a very long time).\n"
 	"By default this cache is stored in a file named .cache\n"
 	"in the directory specified by this setting.\n"
-	"It is safe to delete the contents: the tools regenerate it.\n"
-	"(The old setting 'cache' is still respected if neither of\n"
-	"these new ones is present.)\n"
-	"N.B. If obtain_device_list_from_udev is set to 1 the list of\n"
-	"devices is instead obtained from udev and any existing .cache\n"
-	"file is removed.\n")
+	"It is safe to delete this file; the tools regenerate it.\n"
+	"If obtain_device_list_from_udev is enabled, the list of devices\n"
+	"is obtained from udev and any existing .cache file is removed.\n")
 
 cfg(devices_cache_file_prefix_CFG, "cache_file_prefix", devices_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, DEFAULT_CACHE_FILE_PREFIX, vsn(1, 2, 19),
-	"A prefix used before the .cache file name.\n")
+	"A prefix used before the .cache file name. See devices/cache_dir.\n")
 
 cfg(devices_write_cache_state_CFG, "write_cache_state", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, 1, vsn(1, 0, 0),
-	"Enable/disable writing the cache file.\n")
+	"Enable/disable writing the cache file. See devices/cache_dir.\n")
 
 cfg_array(devices_types_CFG, "types", devices_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_INT | CFG_TYPE_STRING, NULL, vsn(1, 0, 0),
 	"List of pairs of additional acceptable block device types found\n"
@@ -243,15 +236,18 @@ cfg_array(devices_types_CFG, "types", devices_CFG_SECTION, CFG_DEFAULT_UNDEFINED
 	"types = [ \"fd\", 16 ]\n")
 
 cfg(devices_sysfs_scan_CFG, "sysfs_scan", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_SYSFS_SCAN, vsn(1, 0, 8),
-	"If sysfs is mounted (2.6 kernels) restrict device scanning to\n"
-	"the block devices it believes are valid.\n")
+	"Restrict device scanning to block devices that sysfs believes\n"
+	"are valid. (sysfs must be part of the kernel and mounted.)\n"
+	"This is a quick way of filtering out block devices that are\n"
+	"not present.\n")
 
 cfg(devices_multipath_component_detection_CFG, "multipath_component_detection", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_MULTIPATH_COMPONENT_DETECTION, vsn(2, 2, 89),
-	"Ignore devices used as component paths of device-mapper multipath devices.\n")
+	"Ignore devices used as component paths of device-mapper\n"
+	"multipath devices.\n")
 
 cfg(devices_md_component_detection_CFG, "md_component_detection", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_MD_COMPONENT_DETECTION, vsn(1, 0, 18),
-	"Ignore devices used as components of software RAID (md) devices by looking\n"
-	"for md superblocks.\n")
+	"Ignore devices used as components of software RAID (md) devices\n"
+	"by looking for md superblocks.\n")
 
 cfg(devices_fw_raid_component_detection_CFG, "fw_raid_component_detection", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_FW_RAID_COMPONENT_DETECTION, vsn(2, 2, 112),
 	"Ignore devices used as components of firmware RAID devices.\n"
@@ -260,73 +256,73 @@ cfg(devices_fw_raid_component_detection_CFG, "fw_raid_component_detection", devi
 	"this detection to execute.\n")
 
 cfg(devices_md_chunk_alignment_CFG, "md_chunk_alignment", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_MD_CHUNK_ALIGNMENT, vsn(2, 2, 48),
-	"If a PV is placed directly upon an md device, align its data blocks\n"
-	"with the md device's stripe-width.\n")
+	"If a PV is placed directly upon an md device, align its data\n"
+	"blocks with the md device's stripe-width.\n")
 
 cfg(devices_default_data_alignment_CFG, "default_data_alignment", devices_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_DATA_ALIGNMENT, vsn(2, 2, 75),
-	"Default alignment of the start of a data area in MB. If set to 0,\n"
-	"a value of 64KB will be used.  Set to 1 for 1MiB, 2 for 2MiB, etc.\n")
+	"Default alignment of the start of a data area in MB.\n"
+	"If set to 0, a value of 64KB will be used.\n"
+	"Set to 1 for 1MiB, 2 for 2MiB, etc.\n")
 
 cfg(devices_data_alignment_detection_CFG, "data_alignment_detection", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_DATA_ALIGNMENT_DETECTION, vsn(2, 2, 51),
-	"The start of a PV's data area will be a multiple of the minimum_io_size\n"
-	"or optimal_io_size exposed in sysfs.\n"
-	"minimum_io_size - the smallest request the device can perform\n"
-	"without incurring a read-modify-write penalty (e.g. MD's chunk size)\n"
-	"optimal_io_size - the device's preferred unit of receiving I/O\n"
-	"(e.g. MD's stripe width)\n"
+	"The start of a PV data area will be a multiple of\n"
+	"minimum_io_size or optimal_io_size exposed in sysfs.\n"
+	"minimum_io_size is the smallest request the device can perform\n"
+	"without incurring a read-modify-write penalty, e.g. MD chunk size.\n"
+	"optimal_io_size is the device's preferred unit of receiving I/O,\n"
+	"e.g. MD stripe width.\n"
 	"minimum_io_size is used if optimal_io_size is undefined (0).\n"
 	"If md_chunk_alignment is enabled, that detects the optimal_io_size.\n"
 	"This setting takes precedence over md_chunk_alignment.\n")
 
 cfg(devices_data_alignment_CFG, "data_alignment", devices_CFG_SECTION, 0, CFG_TYPE_INT, 0, vsn(2, 2, 45),
 	"Alignment (in KB) of start of data area when creating a new PV.\n"
-	"md_chunk_alignment and data_alignment_detection are disabled if set.\n"
-	"Set to 0 for the default alignment (see: data_alignment_default)\n"
-	"or page size, if larger.\n")
+	"If a PV is placed directly upon an md device and\n"
+	"md_chunk_alignment or data_alignment_detection are enabled,\n"
+	"then this setting is ignored.  Otherwise, md_chunk_alignment\n"
+	"and data_alignment_detection are disabled if this is set.\n"
+	"Set to 0 to use the default alignment or the page size, if larger.\n")
 
 cfg(devices_data_alignment_offset_detection_CFG, "data_alignment_offset_detection", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_DATA_ALIGNMENT_OFFSET_DETECTION, vsn(2, 2, 50),
-	"The start of the PV's aligned data area will be shifted by\n"
-	"the alignment_offset exposed in sysfs.  This offset is often 0 but\n"
-	"may be non-zero; e.g.: certain 4KB sector drives that compensate for\n"
+	"The start of a PV aligned data area will be shifted by\n"
+	"the alignment_offset exposed in sysfs.  This offset is often 0, but\n"
+	"may be non-zero.  Certain 4KB sector drives that compensate for\n"
 	"windows partitioning will have an alignment_offset of 3584 bytes\n"
 	"(sector 7 is the lowest aligned logical block, the 4KB sectors start\n"
 	"at LBA -1, and consequently sector 63 is aligned on a 4KB boundary).\n"
-	"But note that pvcreate --dataalignmentoffset will skip this detection.\n")
+	"pvcreate --dataalignmentoffset will skip this detection.\n")
 
 cfg(devices_ignore_suspended_devices_CFG, "ignore_suspended_devices", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_IGNORE_SUSPENDED_DEVICES, vsn(1, 2, 19),
-	"While scanning the system for PVs, skip a device-mapper device\n"
-	"that has its I/O suspended. Otherwise, LVM waits for the device\n"
-	"to become accessible. This should only be needed in recovery situations.\n")
+	"While scanning the system for PVs, skip a device-mapper\n"
+	"device that has its I/O suspended. Otherwise, LVM waits\n"
+	"for the device to become accessible. This should only be\n"
+	"needed in recovery situations.\n")
 
 cfg(devices_ignore_lvm_mirrors_CFG, "ignore_lvm_mirrors", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_IGNORE_LVM_MIRRORS, vsn(2, 2, 104),
-	"This setting determines whether logical volumes of 'mirror' segment\n"
-	"type are scanned for LVM labels.  This affects the ability of\n"
-	"mirrors to be used as physical volumes.  If ignore_lvm_mirrors\n"
-	"is enabled, it becomes impossible to create volume groups on top\n"
-	"of mirror logical volumes - i.e. to stack volume groups on mirrors.\n"
-	"Allowing mirror logical volumes to be scanned (ignore_lvm_mirrors is\n"
-	"disabled) can potentially cause LVM processes and I/O to the mirror to\n"
-	"become blocked.  This is due to the way that the 'mirror' segment type\n"
-	"handles failures.  In order for the hang to manifest itself, an LVM\n"
-	"command must be run just after a failure and before the automatic LVM\n"
-	"repair process takes place OR there must be failures in multiple mirrors\n"
-	"in the same volume group at the same time with write failures occurring\n"
-	"moments before a scan of the mirror's labels.\n"
-	"Note that these scanning limitations do not apply to the LVM RAID\n"
-	"types, like 'raid1'.  The RAID segment types handle failures in a\n"
-	"different way and are not subject to possible process or I/O blocking.\n"
-	"It is encouraged that users enable ignore_lvm_mirrors if they are using\n"
-	"the 'mirror' segment type.  Users that require volume group stacking on\n"
-	"mirrored logical volumes should consider using the 'raid1' segment type.\n"
-	"The 'raid1' segment type is not available for active/active clustered\n"
-	"volume groups.  Enable ignore_lvm_mirrors to disallow stacking and\n"
-	"thereby avoid a possible deadlock.\n")
+	"Enable this to avoid possible deadlocks when using the 'mirror'\n"
+	"segment type.  This setting determines whether logical volumes\n"
+	"using the 'mirror' segment type are scanned for LVM labels.\n"
+	"This affects the ability of mirrors to be used as physical volumes.\n"
+	"If this setting is enabled, it becomes impossible to create VGs\n"
+	"on top of mirror LVs, i.e. to stack VGs on mirror LVs.\n"
+	"If this setting is disabled, allowing mirror LVs to be scanned,\n"
+	"it may cause LVM processes and I/O to the mirror to become blocked.\n"
+	"This is due to the way that the mirror segment type handles failures.\n"
+	"In order for the hang to occur, an LVM command must be run just after\n"
+	"a failure and before the automatic LVM repair process takes place,\n"
+	"or there must be failures in multiple mirrors in the same VG at the\n"
+	"same time with write failures occurring moments before a scan of the\n"
+	"mirror's labels.\n"
+	"The 'mirror' scanning problems do not apply to LVM RAID types like\n"
+	"'raid1' which handle failures in a different way, making them a\n"
+	"better choice for VG stacking.\n")
 
 cfg(devices_disable_after_error_count_CFG, "disable_after_error_count", devices_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_DISABLE_AFTER_ERROR_COUNT, vsn(2, 2, 75),
-	"During each LVM operation errors received from each device are counted.\n"
-	"If the counter of a particular device exceeds the limit set here, no\n"
-	"further I/O is sent to that device for the remainder of the respective\n"
-	"operation. Setting the parameter to 0 disables the counters altogether.\n")
+	"During each LVM operation, errors received from each device\n"
+	"are counted. If the counter of a device exceeds the limit set\n"
+	"here, no further I/O is sent to that device for the remainder\n"
+	"of the operation.\n"
+	"Setting this to 0 disables the counters altogether.\n")
 
 cfg(devices_require_restorefile_with_uuid_CFG, "require_restorefile_with_uuid", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_REQUIRE_RESTOREFILE_WITH_UUID, vsn(2, 2, 73),
 	"Allow use of pvcreate --uuid without requiring --restorefile.\n")
@@ -334,18 +330,19 @@ cfg(devices_require_restorefile_with_uuid_CFG, "require_restorefile_with_uuid",
 cfg(devices_pv_min_size_CFG, "pv_min_size", devices_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_PV_MIN_SIZE_KB, vsn(2, 2, 85),
 	"Minimum size (in KB) of block devices which can be used as PVs.\n"
 	"In a clustered environment all nodes must use the same value.\n"
-	"Any value smaller than 512KB is ignored.\n"
-	"The original built-in setting was 512 up to and including version 2.02.84.\n")
+	"Any value smaller than 512KB is ignored.  The previous built-in\n"
+	"value was 512.\n")
 
 cfg(devices_issue_discards_CFG, "issue_discards", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_ISSUE_DISCARDS, vsn(2, 2, 85),
-	"Issue discards to a logical volumes's underlying physical volume(s) when\n"
-	"the logical volume is no longer using the physical volumes' space (e.g.\n"
-	"lvremove, lvreduce, etc).  Discards inform the storage that a region is\n"
-	"no longer in use.  Storage that supports discards advertise the protocol\n"
-	"specific way discards should be issued by the kernel (TRIM, UNMAP, or\n"
-	"WRITE SAME with UNMAP bit set).  Not all storage will support or benefit\n"
-	"from discards but SSDs and thinly provisioned LUNs generally do.  If enabled,\n"
-	"discards will only be issued if both the storage and kernel provide support.\n")
+	"Issue discards to a logical volume's underlying physical volumes\n"
+	"when the logical volume is no longer using the physical volumes'\n"
+	"space, e.g. lvremove, lvreduce.  Discards inform the storage that\n"
+	"a region is no longer in use.  Storage that supports discards\n"
+	"advertise the protocol specific way discards should be issued by\n"
+	"the kernel (TRIM, UNMAP, or WRITE SAME with UNMAP bit set).\n"
+	"Not all storage will support or benefit from discards, but SSDs\n"
+	"and thinly provisioned LUNs generally do.  If enabled, discards\n"
+	"will only be issued if both the storage and kernel provide support.\n")
 
 cfg_array(allocation_cling_tag_list_CFG, "cling_tag_list", allocation_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 77),
 	"When searching for free space to extend an LV, the 'cling'\n"
@@ -370,36 +367,37 @@ cfg(allocation_maximise_cling_CFG, "maximise_cling", allocation_CFG_SECTION, 0,
 	"and revert to the previous algorithm.\n")
 
 cfg(allocation_use_blkid_wiping_CFG, "use_blkid_wiping", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, 1, vsn(2, 2, 105),
-	"Enable use of the blkid library instead of native LVM code to detect\n"
-	"any existing signatures while creating new Physical Volumes and\n"
-	"Logical Volumes. LVM needs to be compiled with blkid wiping support\n"
-	"for this setting to take effect.\n"
+	"Use the blkid library instead of native LVM code to detect\n"
+	"any existing signatures while creating new PVs and LVs.\n"
+	"LVM needs to be compiled with blkid wiping support for this\n"
+	"setting to take effect.\n"
 	"LVM native detection code is currently able to recognize:\n"
 	"MD device signatures, swap signature, and LUKS signatures.\n"
-	"To see the list of signatures recognized by blkid, check the output\n"
-	"of 'blkid -k' command. The blkid can recognize more signatures than\n"
-	"LVM native detection code, but due to this higher number of signatures\n"
-	"to be recognized, it can take more time to complete the signature scan.\n")
+	"To see the list of signatures recognized by blkid, check the\n"
+	"output of the 'blkid -k' command.  blkid can recognize more\n"
+	"signatures than LVM native detection code, but due to this\n"
+	"higher number of signatures to be recognized, it can take more\n"
+	"time to complete the signature scan.\n")
 
 cfg(allocation_wipe_signatures_when_zeroing_new_lvs_CFG, "wipe_signatures_when_zeroing_new_lvs", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, 1, vsn(2, 2, 105),
-	"Look for any signatures on a newly-created Logical Volume\n"
-	"whenever zeroing of the LV is done (zeroing is controlled by -Z/--zero\n"
-	"option and if not specified, zeroing is used by default if possible).\n"
-	"While zeroing simply overwrites first 4 KiB of the LV with zeroes without\n"
-	"doing any signature detection, signature wiping goes beyond that and it\n"
-	"can detect exact type and position of signature within the whole LV.\n"
-	"As such, it provides cleaner LV for use after creation as all known\n"
-	"signatures are wiped so that the LV is not claimed by other tools\n"
-	"incorrectly by the existence of old signature from any previous use.\n"
-	"The number of signatures that LVM can detect depends on detection\n"
-	"code that is selected - see also use_blkid_wiping option.\n"
-	"Wiping of each detected signature must be confirmed.\n"
+	"Look for and erase any signatures while zeroing a new LV.\n"
+	"Zeroing is controlled by the -Z/--zero option, and if not\n"
+	"specified, zeroing is used by default if possible.\n"
+	"Zeroing simply overwrites the first 4 KiB of a new LV\n"
+	"with zeroes and does no signature detection or wiping.\n"
+	"Signature wiping goes beyond zeroing and detects exact\n"
+	"types and positions of signatures within the whole LV.\n"
+	"It provides a cleaner LV after creation as all known\n"
+	"signatures are wiped.  The LV is not claimed incorrectly\n"
+	"by other tools because of old signatures from previous use.\n"
+	"The number of signatures that LVM can detect depends on the\n"
+	"detection code that is selected (see use_blkid_wiping.)\n"
+	"Wiping each detected signature must be confirmed.\n"
 	"The command line option -W/--wipesignatures takes precedence\n"
 	"over this setting.\n"
-	"When disabled, signatures on newly-created Logical Volumes\n"
-	"are never detected and wiped and you always need to use\n"
-	"-W/--wipesignatures y option directly to enable this feature\n"
-	"no matter whether zeroing is used or not.\n")
+	"When this setting is disabled, signatures on new LVs are\n"
+	"not detected or erased unless the -W/--wipesignatures y\n"
+	"option is used directly.\n")
 
 cfg(allocation_mirror_logs_require_separate_pvs_CFG, "mirror_logs_require_separate_pvs", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_MIRROR_LOGS_REQUIRE_SEPARATE_PVS, vsn(2, 2, 85),
 	"Guarantees that mirror logs will always be placed on\n"
@@ -413,28 +411,31 @@ cfg(allocation_cache_pool_metadata_require_separate_pvs_CFG, "cache_pool_metadat
 cfg(allocation_cache_pool_cachemode_CFG, "cache_pool_cachemode", allocation_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_CACHE_POOL_CACHEMODE, vsn(2, 2, 113),
 	"The default cache mode used for new cache pools.\n"
 	"Possible options are: writethrough, writeback.\n"
-	"writethrough - Data blocks are immediately written from the cache to disk.\n"
-	"writeback - Data blocks are written from the cache back to disk after\n"
-	"some delay to improve performance.\n")
+	"writethrough - Data blocks are immediately written from\n"
+	"the cache to disk.\n"
+	"writeback - Data blocks are written from the cache back\n"
+	"to disk after some delay to improve performance.\n")
 
 cfg_runtime(allocation_cache_pool_chunk_size_CFG, "cache_pool_chunk_size", allocation_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_INT, vsn(2, 2, 106),
 	"The minimal chunk size (in kiB) for cache pool volumes.\n"
-	"Using a chunk_size that is too large can result in wasteful use of\n"
-	"the cache, where small reads and writes can cause large sections of\n"
-	"an LV to be mapped into the cache.  However, choosing a chunk_size\n"
-	"that is too small can result in more overhead trying to manage the\n"
-	"numerous chunks that become mapped into the cache.  The former is\n"
-	"more of a problem than the latter in most cases, so we default to\n"
-	"a value that is on the smaller end of the spectrum.  Supported values\n"
-	"range from 32(kiB) to 1048576 in multiples of 32.\n")
+	"Using a chunk_size that is too large can result in wasteful\n"
+	"use of the cache, where small reads and writes can cause\n"
+	"large sections of an LV to be mapped into the cache.  However,\n"
+	"choosing a chunk_size that is too small can result in more\n"
+	"overhead trying to manage the numerous chunks that become mapped\n"
+	"into the cache.  The former is more of a problem than the latter\n"
+	"in most cases, so we default to a value that is on the smaller\n"
+	"end of the spectrum.  Supported values range from 32(kiB) to\n"
+	"1048576 in multiples of 32.\n")
 
 cfg(allocation_thin_pool_metadata_require_separate_pvs_CFG, "thin_pool_metadata_require_separate_pvs", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_THIN_POOL_METADATA_REQUIRE_SEPARATE_PVS, vsn(2, 2, 89),
 	"Guarantees that thin pool metadata will always\n"
 	"be placed on different PVs from the pool data.\n")
 
 cfg(allocation_thin_pool_zero_CFG, "thin_pool_zero", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA, CFG_TYPE_BOOL, DEFAULT_THIN_POOL_ZERO, vsn(2, 2, 99),
-	"Enable/disable zeroing of thin pool data chunks before their first use.\n"
-	"N.B. zeroing larger thin pool chunk size degrades performance.\n")
+	"Enable/disable zeroing of thin pool data chunks before\n"
+	"their first use.  Zeroing larger thin pool chunk size\n"
+	"reduces performance.\n")
 
 cfg(allocation_thin_pool_discards_CFG, "thin_pool_discards", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA, CFG_TYPE_STRING, DEFAULT_THIN_POOL_DISCARDS, vsn(2, 2, 99),
 	"The discards behaviour of thin pool volumes.\n"
@@ -443,25 +444,26 @@ cfg(allocation_thin_pool_discards_CFG, "thin_pool_discards", allocation_CFG_SECT
 cfg(allocation_thin_pool_chunk_size_policy_CFG, "thin_pool_chunk_size_policy", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA, CFG_TYPE_STRING, DEFAULT_THIN_POOL_CHUNK_SIZE_POLICY, vsn(2, 2, 101),
 	"The chunk size calculation policy for thin pool volumes.\n"
 	"Possible options are: generic, performance.\n"
-	"generic - if thin_pool_chunk_size is defined, use it.\n"
+	"generic - If thin_pool_chunk_size is defined, use it.\n"
 	"Otherwise, calculate the chunk size based on estimation and\n"
 	"device hints exposed in sysfs - the minimum_io_size.\n"
 	"The chunk size is always at least 64KiB.\n"
-	"performance - if thin_pool_chunk_size is defined, use it.\n"
+	"performance - If thin_pool_chunk_size is defined, use it.\n"
 	"Otherwise, calculate the chunk size for performance based on\n"
 	"device hints exposed in sysfs - the optimal_io_size.\n"
 	"The chunk size is always at least 512KiB.\n")
 
 cfg_runtime(allocation_thin_pool_chunk_size_CFG, "thin_pool_chunk_size", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_UNDEFINED, CFG_TYPE_INT, vsn(2, 2, 99),
 	"The minimal chunk size (in KB) for thin pool volumes.\n"
-	"Use of the larger chunk size may improve performance for plain\n"
-	"thin volumes, however using them for snapshot volumes is less efficient,\n"
-	"as it consumes more space and takes extra time for copying.\n"
-	"When unset, lvm tries to estimate chunk size starting from 64KB\n"
-	"Supported values are in range from 64 to 1048576.\n")
+	"Larger chunk sizes may improve performance for plain\n"
+	"thin volumes, however using them for snapshot volumes\n"
+	"is less efficient, as it consumes more space and takes\n"
+	"extra time for copying.  When unset, lvm tries to estimate\n"
+	"chunk size starting from 64KB.  Supported values are in\n"
+	"the range 64 to 1048576.\n")
 
 cfg(allocation_physical_extent_size_CFG, "physical_extent_size", allocation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_EXTENT_SIZE, vsn(2, 2, 112),
-	"Default physical extent size to use for newly created VGs (in KB).\n")
+	"Default physical extent size to use for new VGs (in KB).\n")
 
 cfg(log_verbose_CFG, "verbose", log_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_VERBOSE, vsn(1, 0, 0),
 	"Controls the messages sent to stdout or stderr.\n")
@@ -487,18 +489,22 @@ cfg(log_overwrite_CFG, "overwrite", log_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_O
 	"Overwrite the log file each time the program is run.\n")
 
 cfg(log_level_CFG, "level", log_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_LOGLEVEL, vsn(1, 0, 0),
-	"The level of log messages that are sent to the log file and/or syslog.\n"
-	"There are 6 syslog-like log levels currently in use - 2 to 7 inclusive.\n"
+	"The level of log messages that are sent to the\n"
+	"log file and/or syslog.  There are 6 syslog-like\n"
+	"log levels currently in use: 2 to 7 inclusive.\n"
 	"7 is the most verbose (LOG_DEBUG).\n")
 
 cfg(log_indent_CFG, "indent", log_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_INDENT, vsn(1, 0, 0),
-	"Format of output messages: indent messages according to their severity.\n")
+	"Format of output messages:\n"
+	"indent messages according to their severity.\n")
 
 cfg(log_command_names_CFG, "command_names", log_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_CMD_NAME, vsn(1, 0, 0),
-	"Format of output messages: display the command name on each line output.\n")
+	"Format of output messages:\n"
+	"display the command name on each line output.\n")
 
 cfg(log_prefix_CFG, "prefix", log_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, DEFAULT_MSG_PREFIX, vsn(1, 0, 0),
-	"Format of output messages: a prefix to use before the message text.\n"
+	"Format of output messages:\n"
+	"a prefix to use before the message text.\n"
 	"(After the command name, if selected).\n"
 	"Two spaces allows you to see/grep the severity of each message.\n"
 	"To make the messages look similar to the original LVM tools use:\n"
@@ -511,10 +517,11 @@ cfg(log_activation_CFG, "activation", log_CFG_SECTION, 0, CFG_TYPE_BOOL, 0, vsn(
 cfg(log_activate_file_CFG, "activate_file", log_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL)
 
 cfg_array(log_debug_classes_CFG, "debug_classes", log_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, "#Smemory#Sdevices#Sactivation#Sallocation#Slvmetad#Smetadata#Scache#Slocking", vsn(2, 2, 99),
-	"Some debugging messages are assigned to a class and only appear\n"
-	"in debug output if the class is listed here.\n"
-	"Classes currently available:\n"
-	"memory, devices, activation, allocation, lvmetad, metadata, cache, locking.\n"
+	"Some debugging messages are assigned to a class\n"
+	"and only appear in debug output if the class is\n"
+	"listed here.  Classes currently available:\n"
+	"memory, devices, activation, allocation,\n"
+	"lvmetad, metadata, cache, locking.\n"
 	"Use \"all\" to see everything.\n")
 
 cfg(backup_backup_CFG, "backup", backup_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_BACKUP_ENABLED, vsn(1, 0, 0),
@@ -547,17 +554,18 @@ cfg(global_umask_CFG, "umask", global_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_UMAS
 	"Interpreted as octal if the first digit is zero.\n")
 
 cfg(global_test_CFG, "test", global_CFG_SECTION, 0, CFG_TYPE_BOOL, 0, vsn(1, 0, 0),
-	"Enabling test mode means that no changes to the on disk metadata\n"
-	"will be made.  Equivalent to having the -t option on every command.\n")
+	"Enabling test mode means that no changes to the\n"
+	"on-disk metadata will be made.  Equivalent to having\n"
+	"the -t option on every command.\n")
 
 cfg(global_units_CFG, "units", global_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_UNITS, vsn(1, 0, 0),
 	"Default value for --units argument.\n")
 
 cfg(global_si_unit_consistency_CFG, "si_unit_consistency", global_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_SI_UNIT_CONSISTENCY,  vsn(2, 2, 54),
-	"The tools distinguish between powers of 1024 bytes\n"
-	"(e.g. KiB, MiB, GiB) and powers of 1000 bytes (e.g. KB, MB, GB).\n"
-	"If you have scripts that depend on the old behaviour, disable\n"
-	"this setting temporarily until you update them.\n")
+	"The tools distinguish between powers of 1024 bytes,\n"
+	"e.g. KiB, MiB, GiB, and powers of 1000 bytes, e.g. KB, MB, GB.\n"
+	"If scripts depend on the old behaviour, disable\n"
+	"this setting temporarily until they are updated.\n")
 
 cfg(global_suffix_CFG, "suffix", global_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_SUFFIX, vsn(1, 0, 0),
 	"Display unit suffix for sizes. This setting has no effect if the\n"
@@ -566,24 +574,28 @@ cfg(global_suffix_CFG, "suffix", global_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BO
 
 cfg(global_activation_CFG, "activation", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_ACTIVATION, vsn(1, 0, 0),
 	"Enable/disable communication with the kernel device-mapper.\n"
-	"Disable if you want to use the tools to manipulate LVM metadata\n"
-	"without activating any logical volumes.\n"
-	"If the device-mapper kernel driver is not present in your kernel,\n"
-	"disabling this should suppress the error messages.\n")
+	"Disable to use the tools to manipulate LVM metadata without\n"
+	"activating any logical volumes. If the device-mapper driver\n"
+	"is not present in the kernel, disabling this should suppress\n"
+	"the error messages.\n")
 
 cfg(global_fallback_to_lvm1_CFG, "fallback_to_lvm1", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_FALLBACK_TO_LVM1, vsn(1, 0, 18),
-	"If we cannot communicate with device-mapper, try running the LVM1 tools.\n"
-	"This option only applies to 2.4 kernels and is provided to help you\n"
-	"switch between device-mapper kernels and LVM1 kernels.\n"
-	"The LVM1 tools need to be installed with .lvm1 suffices\n"
-	"e.g. vgscan.lvm1 and they will stop working after you start using\n"
-	"the new lvm2 on-disk metadata format.\n")
+	"Try running the LVM1 tools if LVM cannot communicate with\n"
+	"device-mapper. This option only applies to 2.4 kernels and\n"
+	"is provided to help switch between device-mapper kernels and\n"
+	"LVM1 kernels.\n"
+	"The LVM1 tools need to be installed with .lvm1 suffices,\n"
+	"e.g. vgscan.lvm1. They will stop working once the lvm2\n"
+	"on-disk metadata format is used.\n")
 
 cfg(global_format_CFG, "format", global_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_FORMAT, vsn(1, 0, 0),
-	"The default metadata format that commands should use - \"lvm1\" or \"lvm2\".\n"
+	"The default metadata format that commands should use:\n"
+	"\"lvm1\" or \"lvm2\".\n"
 	"The command line override is -M1 or -M2.\n")
 
 cfg_array(global_format_libraries_CFG, "format_libraries", global_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0),
+	"A list of shared libraries to load that contain\n"
+	"code to process different formats of metadata.\n"
 	"If support for LVM1 metadata was compiled as a shared library use\n"
 	"format_libraries = \"liblvm2format1.so\"\n")
 
@@ -596,25 +608,25 @@ cfg(global_etc_CFG, "etc", global_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_ETC_D
 	"Location of /etc system configuration directory.\n")
 
 cfg(global_locking_type_CFG, "locking_type", global_CFG_SECTION, 0, CFG_TYPE_INT, 1, vsn(1, 0, 0),
-	"Type of locking to use. Defaults to local file-based locking (1).\n"
-	"Turn locking off by setting to 0 (dangerous: risks metadata corruption\n"
-	"if LVM commands get run concurrently).\n"
-	"Type 2 uses the external shared library locking_library.\n"
-	"Type 3 uses built-in clustered locking.\n"
-	"Type 4 uses read-only locking which forbids any operations that might\n"
-	"change metadata.\n"
-	"Type 5 offers dummy locking for tools that do not need any locks.\n"
-	"You should not need to set this directly: the tools will select when\n"
-	"to use it instead of the configured locking_type.  Do not use lvmetad or\n"
-	"the kernel device-mapper driver with this locking type.\n"
-	"It is used by the --readonly option that offers read-only access to\n"
-	"Volume Group metadata that cannot be locked safely because it belongs to\n"
-	"an inaccessible domain and might be in use, for example a virtual machine\n"
-	"image or a disk that is shared by a clustered machine.\n"
-	"N.B. Don't use lvmetad with locking type 3 as lvmetad is not yet\n"
-	"supported in clustered environment. If use_lvmetad=1 and locking_type=3\n"
-	"is set at the same time, LVM always issues a warning message about this\n"
-	"and then it automatically disables lvmetad use.\n")
+	"Type of locking to use.\n"
+	"Type 0: turns off locking. Warning: this risks metadata\n"
+	"corruption if commands run concurrently.\n"
+	"Type 1: uses local file-based locking, the standard mode.\n"
+	"Type 2: uses the external shared library locking_library.\n"
+	"Type 3: uses built-in clustered locking with clvmd.\n"
+	"This is incompatible with lvmetad. If use_lvmetad is enabled,\n"
+	"lvm prints a warning and disables lvmetad use.\n"
+	"Type 4: uses read-only locking which forbids any operations\n"
+	"that might change metadata.\n"
+	"Type 5: offers dummy locking for tools that do not need any locks.\n"
+	"You should not need to set this directly; the tools will select\n"
+	"when to use it instead of the configured locking_type.\n"
+	"Do not use lvmetad or the kernel device-mapper driver with this\n"
+	"locking type. It is used by the --readonly option that offers\n"
+	"read-only access to Volume Group metadata that cannot be locked\n"
+	"safely because it belongs to an inaccessible domain and might be\n"
+	"in use, for example a virtual machine image or a disk that is\n"
+	"shared by a clustered machine.\n")
 
 cfg(global_wait_for_locks_CFG, "wait_for_locks", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_WAIT_FOR_LOCKS, vsn(2, 2, 50),
 	"When disabled, fail if a lock request cannot be satisfied immediately.\n")
@@ -667,25 +679,27 @@ cfg(global_metadata_read_only_CFG, "metadata_read_only", global_CFG_SECTION, 0,
 	"Inappropriate use could mess up your system, so seek advice first!\n")
 
 cfg(global_mirror_segtype_default_CFG, "mirror_segtype_default", global_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_MIRROR_SEGTYPE, vsn(2, 2, 87),
-	"Defines which segtype will be used when the shorthand -m option\n"
+	"Defines which segtype is used when the short option -m\n"
 	"is used for mirroring.\n"
 	"Possible options are: mirror, raid1.\n"
-	"mirror - The original RAID1 implementation provided by LVM/DM.\n"
-	"It is characterized by a flexible log solution (core, disk, mirrored)\n"
-	"and by the necessity to block I/O while reconfiguring in the\n"
-	"event of a failure.\n"
-	"There is an inherent race in the dmeventd failure handling\n"
-	"logic with snapshots of devices using this type of RAID1 that\n"
-	"in the worst case could cause a deadlock.\n"
-	"raid1 - This implementation leverages MD's RAID1 personality through\n"
-	"device-mapper.  It is characterized by a lack of log options.\n"
-	"(A log is always allocated for every device and they are placed\n"
-	"on the same device as the image - no separate devices are\n"
-	"required.)  This mirror implementation does not require I/O\n"
-	"to be blocked in the kernel in the event of a failure.\n"
-	"This mirror implementation is not cluster-aware and cannot be\n"
-	"used in a shared (active/active) fashion in a cluster.\n"
-	"Use '--type <mirror|raid1>' to override this default setting.\n")
+	"mirror - the original RAID1 implementation from LVM/DM.\n"
+	"It is characterized by a flexible log solution (core,\n"
+	"disk, mirrored), and by the necessity to block I/O while\n"
+	"handling a failure.\n"
+	"There is an inherent race in the dmeventd failure\n"
+	"handling logic with snapshots of devices using this\n"
+	"type of RAID1 that in the worst case could cause a\n"
+	"deadlock. (Also see devices/ignore_lvm_mirrors.)\n"
+	"raid1 - a newer RAID1 implementation using the MD RAID1\n"
+	"personality through device-mapper.  It is characterized\n"
+	"by a lack of log options. (A log is always allocated for\n"
+	"every device and they are placed on the same device as the\n"
+	"image - no separate devices are required.)  This mirror\n"
+	"implementation does not require I/O to be blocked while\n"
+	"handling a failure. This mirror implementation is not\n"
+	"cluster-aware and cannot be used in a shared (active/active)\n"
+	"fashion in a cluster.\n"
+	"Use '--type mirror|raid1' to override this default setting.\n")
 
 cfg(global_raid10_segtype_default_CFG, "raid10_segtype_default", global_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_RAID10_SEGTYPE, vsn(2, 2, 99),
 	"Determines the segment types used by default when\n"


