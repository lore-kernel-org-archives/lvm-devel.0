From: David Teigland <teigland@sourceware.org>
Date: Thu,  7 Oct 2021 17:43:21 +0000 (GMT)
Subject: main - config: comment all default settings
Message-ID: <20211007174321.8A2FF385840C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=02626cbd33b58144eff5e4582f07560e37f212b5
Commit:        02626cbd33b58144eff5e4582f07560e37f212b5
Parent:        3cf97a737bb5eb4cd456b894b1e675291f459129
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Mar 16 09:51:41 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Oct 7 12:06:49 2021 -0500

config: comment all default settings

---
 lib/config/config_settings.h | 174 +++++++++++++++++++++----------------------
 1 file changed, 87 insertions(+), 87 deletions(-)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index c0e491cad..b2270bee9 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -205,7 +205,7 @@ cfg_section(local_CFG_SECTION, "local", root_CFG_SECTION, 0, vsn(2, 2, 117), 0,
 	"# Please take care that each setting only appears once if uncommenting\n" \
 	"# example settings in this file and never copy this file between hosts.\n\n"
 
-cfg(config_checks_CFG, "checks", config_CFG_SECTION, 0, CFG_TYPE_BOOL, 1, vsn(2, 2, 99), NULL, 0, NULL,
+cfg(config_checks_CFG, "checks", config_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, 1, vsn(2, 2, 99), NULL, 0, NULL,
 	"If enabled, any LVM configuration mismatch is reported.\n"
 	"This implies checking that the configuration key is understood by\n"
 	"LVM and that the value of the key is the proper type. If disabled,\n"
@@ -213,22 +213,22 @@ cfg(config_checks_CFG, "checks", config_CFG_SECTION, 0, CFG_TYPE_BOOL, 1, vsn(2,
 	"without any warning (a message about the configuration key not being\n"
 	"found is issued in verbose mode only).\n")
 
-cfg(config_abort_on_errors_CFG, "abort_on_errors", config_CFG_SECTION, 0, CFG_TYPE_BOOL, 0, vsn(2,2,99), NULL, 0, NULL,
+cfg(config_abort_on_errors_CFG, "abort_on_errors", config_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, 0, vsn(2,2,99), NULL, 0, NULL,
 	"Abort the LVM process if a configuration mismatch is found.\n")
 
-cfg_runtime(config_profile_dir_CFG, "profile_dir", config_CFG_SECTION, CFG_DISALLOW_INTERACTIVE, CFG_TYPE_STRING, vsn(2, 2, 99), 0, NULL,
+cfg_runtime(config_profile_dir_CFG, "profile_dir", config_CFG_SECTION, CFG_DEFAULT_COMMENTED | CFG_DISALLOW_INTERACTIVE, CFG_TYPE_STRING, vsn(2, 2, 99), 0, NULL,
 	"Directory where LVM looks for configuration profiles.\n")
 
-cfg(devices_dir_CFG, "dir", devices_CFG_SECTION, CFG_ADVANCED, CFG_TYPE_STRING, DEFAULT_DEV_DIR, vsn(1, 0, 0), NULL, 0, NULL,
+cfg(devices_dir_CFG, "dir", devices_CFG_SECTION, CFG_DEFAULT_COMMENTED | CFG_ADVANCED, CFG_TYPE_STRING, DEFAULT_DEV_DIR, vsn(1, 0, 0), NULL, 0, NULL,
 	"Directory in which to create volume group device nodes.\n"
 	"Commands also accept this as a prefix on volume group names.\n")
 
-cfg_array(devices_scan_CFG, "scan", devices_CFG_SECTION, CFG_ADVANCED, CFG_TYPE_STRING, "#S/dev", vsn(1, 0, 0), NULL, 0, NULL,
+cfg_array(devices_scan_CFG, "scan", devices_CFG_SECTION, CFG_DEFAULT_COMMENTED | CFG_ADVANCED, CFG_TYPE_STRING, "#S/dev", vsn(1, 0, 0), NULL, 0, NULL,
 	"Directories containing device nodes to use with LVM.\n")
 
 cfg_array(devices_loopfiles_CFG, "loopfiles", devices_CFG_SECTION, CFG_DEFAULT_UNDEFINED | CFG_UNSUPPORTED, CFG_TYPE_STRING, NULL, vsn(1, 2, 0), NULL, vsn(2, 3, 0), NULL, NULL)
 
-cfg(devices_obtain_device_list_from_udev_CFG, "obtain_device_list_from_udev", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_OBTAIN_DEVICE_LIST_FROM_UDEV, vsn(2, 2, 85), NULL, 0, NULL,
+cfg(devices_obtain_device_list_from_udev_CFG, "obtain_device_list_from_udev", devices_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_OBTAIN_DEVICE_LIST_FROM_UDEV, vsn(2, 2, 85), NULL, 0, NULL,
 	"Obtain the list of available devices from udev.\n"
 	"This avoids opening or using any inapplicable non-block devices or\n"
 	"subdirectories found in the udev directory. Any device node or\n"
@@ -237,7 +237,7 @@ cfg(devices_obtain_device_list_from_udev_CFG, "obtain_device_list_from_udev", de
 	"directories will be scanned fully. LVM needs to be compiled with\n"
 	"udev support for this setting to apply.\n")
 
-cfg(devices_external_device_info_source_CFG, "external_device_info_source", devices_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_EXTERNAL_DEVICE_INFO_SOURCE, vsn(2, 2, 116), NULL, 0, NULL,
+cfg(devices_external_device_info_source_CFG, "external_device_info_source", devices_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_EXTERNAL_DEVICE_INFO_SOURCE, vsn(2, 2, 116), NULL, 0, NULL,
 	"Enable device information from udev.\n"
 	"If set to \"udev\", lvm will supplement its own native device information\n"
 	"with information from libudev. This can potentially improve the detection\n"
@@ -360,12 +360,12 @@ cfg_array(devices_types_CFG, "types", devices_CFG_SECTION, CFG_DEFAULT_UNDEFINED
 	"types = [ \"fd\", 16 ]\n"
 	"#\n")
 
-cfg(devices_sysfs_scan_CFG, "sysfs_scan", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_SYSFS_SCAN, vsn(1, 0, 8), NULL, 0, NULL,
+cfg(devices_sysfs_scan_CFG, "sysfs_scan", devices_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_SYSFS_SCAN, vsn(1, 0, 8), NULL, 0, NULL,
 	"Restrict device scanning to block devices appearing in sysfs.\n"
 	"This is a quick way of filtering out block devices that are not\n"
 	"present on the system. sysfs must be part of the kernel and mounted.)\n")
 
-cfg(devices_scan_lvs_CFG, "scan_lvs", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_SCAN_LVS, vsn(2, 2, 182), NULL, 0, NULL,
+cfg(devices_scan_lvs_CFG, "scan_lvs", devices_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_SCAN_LVS, vsn(2, 2, 182), NULL, 0, NULL,
 	"Scan LVM LVs for layered PVs, allowing LVs to be used as PVs.\n"
 	"When 1, LVM will detect PVs layered on LVs, and caution must be\n"
 	"taken to avoid a host accessing a layered VG that may not belong\n"
@@ -378,14 +378,14 @@ cfg(devices_scan_lvs_CFG, "scan_lvs", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEF
 	"an LV. The LVs are ignored using a built in device filter that\n"
 	"identifies and excludes LVs.\n")
 
-cfg(devices_multipath_component_detection_CFG, "multipath_component_detection", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_MULTIPATH_COMPONENT_DETECTION, vsn(2, 2, 89), NULL, 0, NULL,
+cfg(devices_multipath_component_detection_CFG, "multipath_component_detection", devices_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_MULTIPATH_COMPONENT_DETECTION, vsn(2, 2, 89), NULL, 0, NULL,
 	"Ignore devices that are components of DM multipath devices.\n")
 
 cfg(devices_multipath_wwids_file_CFG, "multipath_wwids_file", devices_CFG_SECTION, CFG_DEFAULT_COMMENTED | CFG_ALLOW_EMPTY, CFG_TYPE_STRING, DEFAULT_WWIDS_FILE, vsn(2, 3, 13), NULL, 0, NULL,
 	"The path to the multipath wwids file used for multipath component detection.\n"
 	"Set this to an empty string to disable the use of the multipath wwids file.\n")
 
-cfg(devices_md_component_detection_CFG, "md_component_detection", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_MD_COMPONENT_DETECTION, vsn(1, 0, 18), NULL, 0, NULL,
+cfg(devices_md_component_detection_CFG, "md_component_detection", devices_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_MD_COMPONENT_DETECTION, vsn(1, 0, 18), NULL, 0, NULL,
 	"Enable detection and exclusion of MD component devices.\n"
 	"An MD component device is a block device that MD uses as part\n"
 	"of a software RAID virtual device. When an LVM PV is created\n"
@@ -411,12 +411,12 @@ cfg(devices_md_component_checks_CFG, "md_component_checks", devices_CFG_SECTION,
 	"    This requires an extra read at the end of devices.\n"
 	"#\n")
 
-cfg(devices_fw_raid_component_detection_CFG, "fw_raid_component_detection", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_FW_RAID_COMPONENT_DETECTION, vsn(2, 2, 112), NULL, 0, NULL,
+cfg(devices_fw_raid_component_detection_CFG, "fw_raid_component_detection", devices_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_FW_RAID_COMPONENT_DETECTION, vsn(2, 2, 112), NULL, 0, NULL,
 	"Ignore devices that are components of firmware RAID devices.\n"
 	"LVM must use an external_device_info_source other than none for this\n"
 	"detection to execute.\n")
 
-cfg(devices_md_chunk_alignment_CFG, "md_chunk_alignment", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_MD_CHUNK_ALIGNMENT, vsn(2, 2, 48), NULL, 0, NULL,
+cfg(devices_md_chunk_alignment_CFG, "md_chunk_alignment", devices_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_MD_CHUNK_ALIGNMENT, vsn(2, 2, 48), NULL, 0, NULL,
 	"Align the start of a PV data area with md device's stripe-width.\n"
 	"This applies if a PV is placed directly on an md device.\n"
 	"default_data_alignment will be overridden if it is not aligned\n"
@@ -430,7 +430,7 @@ cfg(devices_default_data_alignment_CFG, "default_data_alignment", devices_CFG_SE
 	"This setting is overridden by data_alignment and the --dataalignment\n"
 	"option.\n")
 
-cfg(devices_data_alignment_detection_CFG, "data_alignment_detection", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_DATA_ALIGNMENT_DETECTION, vsn(2, 2, 51), NULL, 0, NULL,
+cfg(devices_data_alignment_detection_CFG, "data_alignment_detection", devices_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_DATA_ALIGNMENT_DETECTION, vsn(2, 2, 51), NULL, 0, NULL,
 	"Align the start of a PV data area with sysfs io properties.\n"
 	"The start of a PV data area will be a multiple of minimum_io_size or\n"
 	"optimal_io_size exposed in sysfs. minimum_io_size is the smallest\n"
@@ -444,14 +444,14 @@ cfg(devices_data_alignment_detection_CFG, "data_alignment_detection", devices_CF
 	"This setting is overridden by data_alignment and the --dataalignment\n"
 	"option.\n")
 
-cfg(devices_data_alignment_CFG, "data_alignment", devices_CFG_SECTION, 0, CFG_TYPE_INT, 0, vsn(2, 2, 45), NULL, 0, NULL,
+cfg(devices_data_alignment_CFG, "data_alignment", devices_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, 0, vsn(2, 2, 45), NULL, 0, NULL,
 	"Align the start of a PV data area with this number of KiB.\n"
 	"When non-zero, this setting overrides default_data_alignment.\n"
 	"Set to 0 to disable, in which case default_data_alignment\n"
 	"is used to align the first PE in units of MiB.\n"
 	"This setting is overridden by the --dataalignment option.\n")
 
-cfg(devices_data_alignment_offset_detection_CFG, "data_alignment_offset_detection", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_DATA_ALIGNMENT_OFFSET_DETECTION, vsn(2, 2, 50), NULL, 0, NULL,
+cfg(devices_data_alignment_offset_detection_CFG, "data_alignment_offset_detection", devices_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_DATA_ALIGNMENT_OFFSET_DETECTION, vsn(2, 2, 50), NULL, 0, NULL,
 	"Shift the start of an aligned PV data area based on sysfs information.\n"
 	"After a PV data area is aligned, it will be shifted by the\n"
 	"alignment_offset exposed in sysfs. This offset is often 0, but may\n"
@@ -461,12 +461,12 @@ cfg(devices_data_alignment_offset_detection_CFG, "data_alignment_offset_detectio
 	"LBA -1, and consequently sector 63 is aligned on a 4KiB boundary).\n"
 	"This setting is overridden by the --dataalignmentoffset option.\n")
 
-cfg(devices_ignore_suspended_devices_CFG, "ignore_suspended_devices", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_IGNORE_SUSPENDED_DEVICES, vsn(1, 2, 19), NULL, 0, NULL,
+cfg(devices_ignore_suspended_devices_CFG, "ignore_suspended_devices", devices_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_IGNORE_SUSPENDED_DEVICES, vsn(1, 2, 19), NULL, 0, NULL,
 	"Ignore DM devices that have I/O suspended while scanning devices.\n"
 	"Otherwise, LVM waits for a suspended device to become accessible.\n"
 	"This should only be needed in recovery situations.\n")
 
-cfg(devices_ignore_lvm_mirrors_CFG, "ignore_lvm_mirrors", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_IGNORE_LVM_MIRRORS, vsn(2, 2, 104), NULL, 0, NULL,
+cfg(devices_ignore_lvm_mirrors_CFG, "ignore_lvm_mirrors", devices_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_IGNORE_LVM_MIRRORS, vsn(2, 2, 104), NULL, 0, NULL,
 	"Do not scan 'mirror' LVs to avoid possible deadlocks.\n"
 	"This avoids possible deadlocks when using the 'mirror' segment type.\n"
 	"This setting determines whether LVs using the 'mirror' segment type\n"
@@ -484,19 +484,19 @@ cfg(devices_ignore_lvm_mirrors_CFG, "ignore_lvm_mirrors", devices_CFG_SECTION, 0
 	"apply to LVM RAID types like 'raid1' which handle failures in a\n"
 	"different way, making them a better choice for VG stacking.\n")
 
-cfg(devices_disable_after_error_count_CFG, "disable_after_error_count", devices_CFG_SECTION, 0, CFG_TYPE_INT, 0, vsn(2, 2, 75), NULL, vsn(2, 3, 0), NULL,
+cfg(devices_disable_after_error_count_CFG, "disable_after_error_count", devices_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, 0, vsn(2, 2, 75), NULL, vsn(2, 3, 0), NULL,
 	NULL)
 
-cfg(devices_require_restorefile_with_uuid_CFG, "require_restorefile_with_uuid", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_REQUIRE_RESTOREFILE_WITH_UUID, vsn(2, 2, 73), NULL, 0, NULL,
+cfg(devices_require_restorefile_with_uuid_CFG, "require_restorefile_with_uuid", devices_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_REQUIRE_RESTOREFILE_WITH_UUID, vsn(2, 2, 73), NULL, 0, NULL,
 	"Allow use of pvcreate --uuid without requiring --restorefile.\n")
 
-cfg(devices_pv_min_size_CFG, "pv_min_size", devices_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_PV_MIN_SIZE_KB, vsn(2, 2, 85), NULL, 0, NULL,
+cfg(devices_pv_min_size_CFG, "pv_min_size", devices_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_PV_MIN_SIZE_KB, vsn(2, 2, 85), NULL, 0, NULL,
 	"Minimum size in KiB of block devices which can be used as PVs.\n"
 	"In a clustered environment all nodes must use the same value.\n"
 	"Any value smaller than 512KiB is ignored. The previous built-in\n"
 	"value was 512.\n")
 
-cfg(devices_issue_discards_CFG, "issue_discards", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_ISSUE_DISCARDS, vsn(2, 2, 85), NULL, 0, NULL,
+cfg(devices_issue_discards_CFG, "issue_discards", devices_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_ISSUE_DISCARDS, vsn(2, 2, 85), NULL, 0, NULL,
 	"Issue discards to PVs that are no longer used by an LV.\n"
 	"Discards are sent to an LV's underlying physical volumes when the LV\n"
 	"is no longer using the physical volumes' space, e.g. lvremove,\n"
@@ -508,7 +508,7 @@ cfg(devices_issue_discards_CFG, "issue_discards", devices_CFG_SECTION, 0, CFG_TY
 	"generally do. If enabled, discards will only be issued if both the\n"
 	"storage and kernel provide support.\n")
 
-cfg(devices_allow_changes_with_duplicate_pvs_CFG, "allow_changes_with_duplicate_pvs", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_ALLOW_CHANGES_WITH_DUPLICATE_PVS, vsn(2, 2, 153), NULL, 0, NULL,
+cfg(devices_allow_changes_with_duplicate_pvs_CFG, "allow_changes_with_duplicate_pvs", devices_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_ALLOW_CHANGES_WITH_DUPLICATE_PVS, vsn(2, 2, 153), NULL, 0, NULL,
 	"Allow VG modification while a PV appears on multiple devices.\n"
 	"When a PV appears on multiple devices, LVM attempts to choose the\n"
 	"best device to use for the PV. If the devices represent the same\n"
@@ -520,7 +520,7 @@ cfg(devices_allow_changes_with_duplicate_pvs_CFG, "allow_changes_with_duplicate_
 	"Enabling this setting allows the VG to be used as usual even with\n"
 	"uncertain devices.\n")
 
-cfg(devices_allow_mixed_block_sizes_CFG, "allow_mixed_block_sizes", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, 0, vsn(2, 3, 6), NULL, 0, NULL,
+cfg(devices_allow_mixed_block_sizes_CFG, "allow_mixed_block_sizes", devices_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, 0, vsn(2, 3, 6), NULL, 0, NULL,
 	"Allow PVs in the same VG with different logical block sizes.\n"
 	"When allowed, the user is responsible to ensure that an LV is\n"
 	"using PVs with matching block sizes when necessary.\n")
@@ -543,14 +543,14 @@ cfg_array(allocation_cling_tag_list_CFG, "cling_tag_list", allocation_CFG_SECTIO
 	"cling_tag_list = [ \"@site1\", \"@site2\" ]\n"
 	"#\n")
 
-cfg(allocation_maximise_cling_CFG, "maximise_cling", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_MAXIMISE_CLING, vsn(2, 2, 85), NULL, 0, NULL,
+cfg(allocation_maximise_cling_CFG, "maximise_cling", allocation_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_MAXIMISE_CLING, vsn(2, 2, 85), NULL, 0, NULL,
 	"Use a previous allocation algorithm.\n"
 	"Changes made in version 2.02.85 extended the reach of the 'cling'\n"
 	"policies to detect more situations where data can be grouped onto\n"
 	"the same disks. This setting can be used to disable the changes\n"
 	"and revert to the previous algorithm.\n")
 
-cfg(allocation_use_blkid_wiping_CFG, "use_blkid_wiping", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_USE_BLKID_WIPING, vsn(2, 2, 105), "@DEFAULT_USE_BLKID_WIPING@", 0, NULL,
+cfg(allocation_use_blkid_wiping_CFG, "use_blkid_wiping", allocation_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_USE_BLKID_WIPING, vsn(2, 2, 105), "@DEFAULT_USE_BLKID_WIPING@", 0, NULL,
 	"Use blkid to detect and erase existing signatures on new PVs and LVs.\n"
 	"The blkid library can detect more signatures than the native LVM\n"
 	"detection code, but may take longer. LVM needs to be compiled with\n"
@@ -559,7 +559,7 @@ cfg(allocation_use_blkid_wiping_CFG, "use_blkid_wiping", allocation_CFG_SECTION,
 	"swap signature, and LUKS signatures. To see the list of signatures\n"
 	"recognized by blkid, check the output of the 'blkid -k' command.\n")
 
-cfg(allocation_wipe_signatures_when_zeroing_new_lvs_CFG, "wipe_signatures_when_zeroing_new_lvs", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, 1, vsn(2, 2, 105), NULL, 0, NULL,
+cfg(allocation_wipe_signatures_when_zeroing_new_lvs_CFG, "wipe_signatures_when_zeroing_new_lvs", allocation_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, 1, vsn(2, 2, 105), NULL, 0, NULL,
 	"Look for and erase any signatures while zeroing a new LV.\n"
 	"The --wipesignatures option overrides this setting.\n"
 	"Zeroing is controlled by the -Z/--zero option, and if not specified,\n"
@@ -575,7 +575,7 @@ cfg(allocation_wipe_signatures_when_zeroing_new_lvs_CFG, "wipe_signatures_when_z
 	"When this setting is disabled, signatures on new LVs are not detected\n"
 	"or erased unless the --wipesignatures option is used directly.\n")
 
-cfg(allocation_mirror_logs_require_separate_pvs_CFG, "mirror_logs_require_separate_pvs", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_MIRROR_LOGS_REQUIRE_SEPARATE_PVS, vsn(2, 2, 85), NULL, 0, NULL,
+cfg(allocation_mirror_logs_require_separate_pvs_CFG, "mirror_logs_require_separate_pvs", allocation_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_MIRROR_LOGS_REQUIRE_SEPARATE_PVS, vsn(2, 2, 85), NULL, 0, NULL,
 	"Mirror logs and images will always use different PVs.\n"
 	"The default setting changed in version 2.02.85.\n")
 
@@ -854,10 +854,10 @@ cfg(log_command_log_selection_CFG, "command_log_selection", log_CFG_SECTION, CFG
 	"For more information about selection criteria in general, see\n"
 	"lvm(8) man page.\n")
 
-cfg(log_verbose_CFG, "verbose", log_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_VERBOSE, vsn(1, 0, 0), NULL, 0, NULL,
+cfg(log_verbose_CFG, "verbose", log_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_VERBOSE, vsn(1, 0, 0), NULL, 0, NULL,
 	"Controls the messages sent to stdout or stderr.\n")
 
-cfg(log_silent_CFG, "silent", log_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_SILENT, vsn(2, 2, 98), NULL, 0, NULL,
+cfg(log_silent_CFG, "silent", log_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_SILENT, vsn(2, 2, 98), NULL, 0, NULL,
 	"Suppress all non-essential messages from stdout.\n"
 	"This has the same effect as -qq. When enabled, the following commands\n"
 	"still produce output: dumpconfig, lvdisplay, lvmdiskscan, lvs, pvck,\n"
@@ -867,16 +867,16 @@ cfg(log_silent_CFG, "silent", log_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_SILENT,
 	"Any 'yes' or 'no' questions not overridden by other arguments are\n"
 	"suppressed and default to 'no'.\n")
 
-cfg(log_syslog_CFG, "syslog", log_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_SYSLOG, vsn(1, 0, 0), NULL, 0, NULL,
+cfg(log_syslog_CFG, "syslog", log_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_SYSLOG, vsn(1, 0, 0), NULL, 0, NULL,
 	"Send log messages through syslog.\n")
 
 cfg(log_file_CFG, "file", log_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL, 0, NULL,
 	"Write error and debug log messages to a file specified here.\n")
 
-cfg(log_overwrite_CFG, "overwrite", log_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_OVERWRITE, vsn(1, 0, 0), NULL, 0, NULL,
+cfg(log_overwrite_CFG, "overwrite", log_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_OVERWRITE, vsn(1, 0, 0), NULL, 0, NULL,
 	"Overwrite the log file each time the program is run.\n")
 
-cfg(log_level_CFG, "level", log_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_LOGLEVEL, vsn(1, 0, 0), NULL, 0, NULL,
+cfg(log_level_CFG, "level", log_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_LOGLEVEL, vsn(1, 0, 0), NULL, 0, NULL,
 	"The level of log messages that are sent to the log file or syslog.\n"
 	"There are 6 syslog-like log levels currently in use: 2 to 7 inclusive.\n"
 	"7 is the most verbose (LOG_DEBUG).\n")
@@ -884,23 +884,23 @@ cfg(log_level_CFG, "level", log_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_LOGLEVEL,
 cfg(log_indent_CFG, "indent", log_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_INDENT, vsn(1, 0, 0), NULL, 0, NULL,
 	"Indent messages according to their severity.\n")
 
-cfg(log_command_names_CFG, "command_names", log_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_CMD_NAME, vsn(1, 0, 0), NULL, 0, NULL,
+cfg(log_command_names_CFG, "command_names", log_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_CMD_NAME, vsn(1, 0, 0), NULL, 0, NULL,
 	"Display the command name on each line of output.\n")
 
-cfg(log_prefix_CFG, "prefix", log_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, DEFAULT_MSG_PREFIX, vsn(1, 0, 0), NULL, 0, NULL,
+cfg(log_prefix_CFG, "prefix", log_CFG_SECTION, CFG_DEFAULT_COMMENTED | CFG_ALLOW_EMPTY, CFG_TYPE_STRING, DEFAULT_MSG_PREFIX, vsn(1, 0, 0), NULL, 0, NULL,
 	"A prefix to use before the log message text.\n"
 	"(After the command name, if selected).\n"
 	"Two spaces allows you to see/grep the severity of each message.\n"
 	"To make the messages look similar to the original LVM tools use:\n"
 	"indent = 0, command_names = 1, prefix = \" -- \"\n")
 
-cfg(log_activation_CFG, "activation", log_CFG_SECTION, 0, CFG_TYPE_BOOL, 0, vsn(1, 0, 0), NULL, 0, NULL,
+cfg(log_activation_CFG, "activation", log_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, 0, vsn(1, 0, 0), NULL, 0, NULL,
 	"Log messages during activation.\n"
 	"Don't use this in low memory situations (can deadlock).\n")
 
 cfg(log_activate_file_CFG, "activate_file", log_CFG_SECTION, CFG_DEFAULT_UNDEFINED | CFG_UNSUPPORTED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL, 0, NULL, NULL)
 
-cfg_array(log_debug_classes_CFG, "debug_classes", log_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, "#Smemory#Sdevices#Sio#Sactivation#Sallocation#Smetadata#Scache#Slocking#Slvmpolld#Sdbus", vsn(2, 2, 99), NULL, 0, NULL,
+cfg_array(log_debug_classes_CFG, "debug_classes", log_CFG_SECTION, CFG_DEFAULT_COMMENTED | CFG_ALLOW_EMPTY, CFG_TYPE_STRING, "#Smemory#Sdevices#Sio#Sactivation#Sallocation#Smetadata#Scache#Slocking#Slvmpolld#Sdbus", vsn(2, 2, 99), NULL, 0, NULL,
 	"Select log messages by class.\n"
 	"Some debugging messages are assigned to a class and only appear in\n"
 	"debug output if the class is listed here. Classes currently\n"
@@ -915,55 +915,55 @@ cfg_array(log_debug_output_fields_CFG, "debug_output_fields", log_CFG_SECTION, C
 	  "The fields included in debug output written to stderr.\n"
 	  "Use \"all\" to include everything (the default).\n")
 
-cfg(backup_backup_CFG, "backup", backup_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_BACKUP_ENABLED, vsn(1, 0, 0), NULL, 0, NULL,
+cfg(backup_backup_CFG, "backup", backup_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_BACKUP_ENABLED, vsn(1, 0, 0), NULL, 0, NULL,
 	"Maintain a backup of the current metadata configuration.\n"
 	"Think very hard before turning this off!\n")
 
-cfg_runtime(backup_backup_dir_CFG, "backup_dir", backup_CFG_SECTION, 0, CFG_TYPE_STRING, vsn(1, 0, 0), 0, NULL,
+cfg_runtime(backup_backup_dir_CFG, "backup_dir", backup_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, vsn(1, 0, 0), 0, NULL,
 	"Location of the metadata backup files.\n"
 	"Remember to back up this directory regularly!\n")
 
-cfg(backup_archive_CFG, "archive", backup_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_ARCHIVE_ENABLED, vsn(1, 0, 0), NULL, 0, NULL,
+cfg(backup_archive_CFG, "archive", backup_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_ARCHIVE_ENABLED, vsn(1, 0, 0), NULL, 0, NULL,
 	"Maintain an archive of old metadata configurations.\n"
 	"Think very hard before turning this off.\n")
 
-cfg_runtime(backup_archive_dir_CFG, "archive_dir", backup_CFG_SECTION, 0, CFG_TYPE_STRING, vsn(1, 0, 0), 0, NULL,
+cfg_runtime(backup_archive_dir_CFG, "archive_dir", backup_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, vsn(1, 0, 0), 0, NULL,
 	"Location of the metdata archive files.\n"
 	"Remember to back up this directory regularly!\n")
 
-cfg(backup_retain_min_CFG, "retain_min", backup_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_ARCHIVE_NUMBER, vsn(1, 0, 0), NULL, 0, NULL,
+cfg(backup_retain_min_CFG, "retain_min", backup_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_ARCHIVE_NUMBER, vsn(1, 0, 0), NULL, 0, NULL,
 	"Minimum number of archives to keep.\n")
 
-cfg(backup_retain_days_CFG, "retain_days", backup_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_ARCHIVE_DAYS, vsn(1, 0, 0), NULL, 0, NULL,
+cfg(backup_retain_days_CFG, "retain_days", backup_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_ARCHIVE_DAYS, vsn(1, 0, 0), NULL, 0, NULL,
 	"Minimum number of days to keep archive files.\n")
 
-cfg(shell_history_size_CFG, "history_size", shell_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_MAX_HISTORY, vsn(1, 0, 0), NULL, 0, NULL,
+cfg(shell_history_size_CFG, "history_size", shell_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_MAX_HISTORY, vsn(1, 0, 0), NULL, 0, NULL,
 	"Number of lines of history to store in ~/.lvm_history.\n")
 
-cfg(global_umask_CFG, "umask", global_CFG_SECTION, CFG_FORMAT_INT_OCTAL, CFG_TYPE_INT, DEFAULT_UMASK, vsn(1, 0, 0), NULL, 0, NULL,
+cfg(global_umask_CFG, "umask", global_CFG_SECTION, CFG_DEFAULT_COMMENTED | CFG_FORMAT_INT_OCTAL, CFG_TYPE_INT, DEFAULT_UMASK, vsn(1, 0, 0), NULL, 0, NULL,
 	"The file creation mask for any files and directories created.\n"
 	"Interpreted as octal if the first digit is zero.\n")
 
-cfg(global_test_CFG, "test", global_CFG_SECTION, 0, CFG_TYPE_BOOL, 0, vsn(1, 0, 0), NULL, 0, NULL,
+cfg(global_test_CFG, "test", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, 0, vsn(1, 0, 0), NULL, 0, NULL,
 	"No on-disk metadata changes will be made in test mode.\n"
 	"Equivalent to having the -t option on every command.\n")
 
-cfg(global_units_CFG, "units", global_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_UNITS, vsn(1, 0, 0), NULL, 0, NULL,
+cfg(global_units_CFG, "units", global_CFG_SECTION, CFG_DEFAULT_COMMENTED | CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_UNITS, vsn(1, 0, 0), NULL, 0, NULL,
 	"Default value for --units argument.\n")
 
-cfg(global_si_unit_consistency_CFG, "si_unit_consistency", global_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_SI_UNIT_CONSISTENCY,  vsn(2, 2, 54), NULL, 0, NULL,
+cfg(global_si_unit_consistency_CFG, "si_unit_consistency", global_CFG_SECTION, CFG_DEFAULT_COMMENTED | CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_SI_UNIT_CONSISTENCY,  vsn(2, 2, 54), NULL, 0, NULL,
 	"Distinguish between powers of 1024 and 1000 bytes.\n"
 	"The LVM commands distinguish between powers of 1024 bytes,\n"
 	"e.g. KiB, MiB, GiB, and powers of 1000 bytes, e.g. KB, MB, GB.\n"
 	"If scripts depend on the old behaviour, disable this setting\n"
 	"temporarily until they are updated.\n")
 
-cfg(global_suffix_CFG, "suffix", global_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_SUFFIX, vsn(1, 0, 0), NULL, 0, NULL,
+cfg(global_suffix_CFG, "suffix", global_CFG_SECTION, CFG_DEFAULT_COMMENTED | CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_SUFFIX, vsn(1, 0, 0), NULL, 0, NULL,
 	"Display unit suffix for sizes.\n"
 	"This setting has no effect if the units are in human-readable form\n"
 	"(global/units = \"h\") in which case the suffix is always displayed.\n")
 
-cfg(global_activation_CFG, "activation", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_ACTIVATION, vsn(1, 0, 0), NULL, 0, NULL,
+cfg(global_activation_CFG, "activation", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_ACTIVATION, vsn(1, 0, 0), NULL, 0, NULL,
 	"Enable/disable communication with the kernel device-mapper.\n"
 	"Disable to use the tools to manipulate LVM metadata without\n"
 	"activating any logical volumes. If the device-mapper driver\n"
@@ -981,30 +981,30 @@ cfg_array(global_format_libraries_CFG, "format_libraries", global_CFG_SECTION, C
 
 cfg_array(global_segment_libraries_CFG, "segment_libraries", global_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 18), NULL, vsn(2, 3, 3), NULL, NULL)
 
-cfg(global_proc_CFG, "proc", global_CFG_SECTION, CFG_ADVANCED, CFG_TYPE_STRING, DEFAULT_PROC_DIR, vsn(1, 0, 0), NULL, 0, NULL,
+cfg(global_proc_CFG, "proc", global_CFG_SECTION, CFG_DEFAULT_COMMENTED | CFG_ADVANCED, CFG_TYPE_STRING, DEFAULT_PROC_DIR, vsn(1, 0, 0), NULL, 0, NULL,
 	"Location of proc filesystem.\n")
 
-cfg(global_etc_CFG, "etc", global_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_ETC_DIR, vsn(2, 2, 117), "@CONFDIR@", 0, NULL,
+cfg(global_etc_CFG, "etc", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_ETC_DIR, vsn(2, 2, 117), "@CONFDIR@", 0, NULL,
 	"Location of /etc system configuration directory.\n")
 
-cfg(global_locking_type_CFG, "locking_type", global_CFG_SECTION, 0, CFG_TYPE_INT, 1, vsn(1, 0, 0), NULL, vsn(2, 3, 0), NULL,
+cfg(global_locking_type_CFG, "locking_type", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, 1, vsn(1, 0, 0), NULL, vsn(2, 3, 0), NULL,
     NULL)
 
-cfg(global_wait_for_locks_CFG, "wait_for_locks", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_WAIT_FOR_LOCKS, vsn(2, 2, 50), NULL, 0, NULL,
+cfg(global_wait_for_locks_CFG, "wait_for_locks", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_WAIT_FOR_LOCKS, vsn(2, 2, 50), NULL, 0, NULL,
 	"When disabled, fail if a lock request would block.\n")
 
-cfg(global_fallback_to_clustered_locking_CFG, "fallback_to_clustered_locking", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_FALLBACK_TO_CLUSTERED_LOCKING, vsn(2, 2, 42), NULL, vsn(2, 3, 0), NULL,
+cfg(global_fallback_to_clustered_locking_CFG, "fallback_to_clustered_locking", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_FALLBACK_TO_CLUSTERED_LOCKING, vsn(2, 2, 42), NULL, vsn(2, 3, 0), NULL,
 	NULL)
 
-cfg(global_fallback_to_local_locking_CFG, "fallback_to_local_locking", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_FALLBACK_TO_LOCAL_LOCKING, vsn(2, 2, 42), NULL, vsn(2, 3, 0), NULL,
+cfg(global_fallback_to_local_locking_CFG, "fallback_to_local_locking", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_FALLBACK_TO_LOCAL_LOCKING, vsn(2, 2, 42), NULL, vsn(2, 3, 0), NULL,
 	NULL)
 
-cfg(global_locking_dir_CFG, "locking_dir", global_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_LOCK_DIR, vsn(1, 0, 0), "@DEFAULT_LOCK_DIR@", 0, NULL,
+cfg(global_locking_dir_CFG, "locking_dir", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_LOCK_DIR, vsn(1, 0, 0), "@DEFAULT_LOCK_DIR@", 0, NULL,
 	"Directory to use for LVM command file locks.\n"
 	"Local non-LV directory that holds file-based locks while commands are\n"
 	"in progress. A directory like /tmp that may get wiped on reboot is OK.\n")
 
-cfg(global_prioritise_write_locks_CFG, "prioritise_write_locks", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_PRIORITISE_WRITE_LOCKS, vsn(2, 2, 52), NULL, 0, NULL,
+cfg(global_prioritise_write_locks_CFG, "prioritise_write_locks", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_PRIORITISE_WRITE_LOCKS, vsn(2, 2, 52), NULL, 0, NULL,
 	"Allow quicker VG write access during high volume read access.\n"
 	"When there are competing read-only and read-write access requests for\n"
 	"a volume group's metadata, instead of always granting the read-only\n"
@@ -1018,22 +1018,22 @@ cfg(global_library_dir_CFG, "library_dir", global_CFG_SECTION, CFG_DEFAULT_UNDEF
 cfg(global_locking_library_CFG, "locking_library", global_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_LOCKING_LIB, vsn(1, 0, 0), NULL, vsn(2, 3, 0), NULL,
 	NULL)
 
-cfg(global_abort_on_internal_errors_CFG, "abort_on_internal_errors", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_ABORT_ON_INTERNAL_ERRORS, vsn(2, 2, 57), NULL, 0, NULL,
+cfg(global_abort_on_internal_errors_CFG, "abort_on_internal_errors", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_ABORT_ON_INTERNAL_ERRORS, vsn(2, 2, 57), NULL, 0, NULL,
 	"Abort a command that encounters an internal error.\n"
 	"Treat any internal errors as fatal errors, aborting the process that\n"
 	"encountered the internal error. Please only enable for debugging.\n")
 
-cfg(global_detect_internal_vg_cache_corruption_CFG, "detect_internal_vg_cache_corruption", global_CFG_SECTION, 0, CFG_TYPE_BOOL, 0, vsn(2, 2, 96), NULL, vsn(2, 2, 174), NULL,
+cfg(global_detect_internal_vg_cache_corruption_CFG, "detect_internal_vg_cache_corruption", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, 0, vsn(2, 2, 96), NULL, vsn(2, 2, 174), NULL,
 	NULL)
 
-cfg(global_metadata_read_only_CFG, "metadata_read_only", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_METADATA_READ_ONLY, vsn(2, 2, 75), NULL, 0, NULL,
+cfg(global_metadata_read_only_CFG, "metadata_read_only", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_METADATA_READ_ONLY, vsn(2, 2, 75), NULL, 0, NULL,
 	"No operations that change on-disk metadata are permitted.\n"
 	"Additionally, read-only commands that encounter metadata in need of\n"
 	"repair will still be allowed to proceed exactly as if the repair had\n"
 	"been performed (except for the unchanged vg_seqno). Inappropriate\n"
 	"use could mess up your system, so seek advice first!\n")
 
-cfg(global_mirror_segtype_default_CFG, "mirror_segtype_default", global_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_MIRROR_SEGTYPE, vsn(2, 2, 87), "@DEFAULT_MIRROR_SEGTYPE@", 0, NULL,
+cfg(global_mirror_segtype_default_CFG, "mirror_segtype_default", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_MIRROR_SEGTYPE, vsn(2, 2, 87), "@DEFAULT_MIRROR_SEGTYPE@", 0, NULL,
 	"The segment type used by the short mirroring option -m.\n"
 	"The --type mirror|raid1 option overrides this setting.\n"
 	"#\n"
@@ -1068,7 +1068,7 @@ cfg(global_support_mirrored_mirror_log_CFG, "support_mirrored_mirror_log", globa
 	"Not supported for regular operation!\n"
 	"\n")
 
-cfg(global_raid10_segtype_default_CFG, "raid10_segtype_default", global_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_RAID10_SEGTYPE, vsn(2, 2, 99), "@DEFAULT_RAID10_SEGTYPE@", 0, NULL,
+cfg(global_raid10_segtype_default_CFG, "raid10_segtype_default", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_RAID10_SEGTYPE, vsn(2, 2, 99), "@DEFAULT_RAID10_SEGTYPE@", 0, NULL,
 	"The segment type used by the -i -m combination.\n"
 	"The --type raid10|mirror option overrides this setting.\n"
 	"The --stripes/-i and --mirrors/-m options can both be specified\n"
@@ -1086,7 +1086,7 @@ cfg(global_raid10_segtype_default_CFG, "raid10_segtype_default", global_CFG_SECT
 	"    in terms of providing redundancy and performance.\n"
 	"#\n")
 
-cfg(global_sparse_segtype_default_CFG, "sparse_segtype_default", global_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_SPARSE_SEGTYPE, vsn(2, 2, 112), "@DEFAULT_SPARSE_SEGTYPE@", 0, NULL,
+cfg(global_sparse_segtype_default_CFG, "sparse_segtype_default", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_SPARSE_SEGTYPE, vsn(2, 2, 112), "@DEFAULT_SPARSE_SEGTYPE@", 0, NULL,
 	"The segment type used by the -V -L combination.\n"
 	"The --type snapshot|thin option overrides this setting.\n"
 	"The combination of -V and -L options creates a sparse LV. There are\n"
@@ -1124,7 +1124,7 @@ cfg(global_event_activation_CFG, "event_activation", global_CFG_SECTION, CFG_DEF
 	"See the --setautoactivation option or the auto_activation_volume_list\n"
 	"setting to configure autoactivation for specific VGs or LVs.\n")
 
-cfg(global_use_lvmetad_CFG, "use_lvmetad", global_CFG_SECTION, 0, CFG_TYPE_BOOL, 0, vsn(2, 2, 93), 0, vsn(2, 3, 0), NULL,
+cfg(global_use_lvmetad_CFG, "use_lvmetad", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, 0, vsn(2, 2, 93), 0, vsn(2, 3, 0), NULL,
 	NULL)
 
 cfg(global_lvmetad_update_wait_time_CFG, "lvmetad_update_wait_time", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, 0, vsn(2, 2, 151), NULL, vsn(2, 3, 0), NULL,
@@ -1133,7 +1133,7 @@ cfg(global_lvmetad_update_wait_time_CFG, "lvmetad_update_wait_time", global_CFG_
 cfg(global_use_aio_CFG, "use_aio", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_USE_AIO, vsn(2, 2, 183), NULL, 0, NULL,
 	"Use async I/O when reading and writing devices.\n")
 
-cfg(global_use_lvmlockd_CFG, "use_lvmlockd", global_CFG_SECTION, 0, CFG_TYPE_BOOL, 0, vsn(2, 2, 124), NULL, 0, NULL,
+cfg(global_use_lvmlockd_CFG, "use_lvmlockd", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, 0, vsn(2, 2, 124), NULL, 0, NULL,
 	"Use lvmlockd for locking among hosts using LVM on shared storage.\n"
 	"Applicable only if LVM is compiled with lockd support in which\n"
 	"case there is also lvmlockd(8) man page available for more\n"
@@ -1259,7 +1259,7 @@ cfg(global_fsadm_executable_CFG, "fsadm_executable", global_CFG_SECTION, CFG_DEF
 	"The full path to the fsadm command.\n"
 	"LVM uses this command to help with lvresize -r operations.\n")
 
-cfg(global_system_id_source_CFG, "system_id_source", global_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_SYSTEM_ID_SOURCE, vsn(2, 2, 117), NULL, 0, NULL,
+cfg(global_system_id_source_CFG, "system_id_source", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_SYSTEM_ID_SOURCE, vsn(2, 2, 117), NULL, 0, NULL,
 	"The method LVM uses to set the local system ID.\n"
 	"Volume Groups can also be given a system ID (by vgcreate, vgchange,\n"
 	"or vgimport.) A VG on shared storage devices is accessible only to\n"
@@ -1289,13 +1289,13 @@ cfg(global_system_id_file_CFG, "system_id_file", global_CFG_SECTION, CFG_DEFAULT
 	"This is used when system_id_source is set to 'file'.\n"
 	"Comments starting with the character # are ignored.\n")
 
-cfg(activation_checks_CFG, "checks", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_ACTIVATION_CHECKS, vsn(2, 2, 86), NULL, 0, NULL,
+cfg(activation_checks_CFG, "checks", activation_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_ACTIVATION_CHECKS, vsn(2, 2, 86), NULL, 0, NULL,
 	"Perform internal checks of libdevmapper operations.\n"
 	"Useful for debugging problems with activation. Some of the checks may\n"
 	"be expensive, so it's best to use this only when there seems to be a\n"
 	"problem.\n")
 
-cfg(global_use_lvmpolld_CFG, "use_lvmpolld", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_USE_LVMPOLLD, vsn(2, 2, 120), "@DEFAULT_USE_LVMPOLLD@", 0, NULL,
+cfg(global_use_lvmpolld_CFG, "use_lvmpolld", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_USE_LVMPOLLD, vsn(2, 2, 120), "@DEFAULT_USE_LVMPOLLD@", 0, NULL,
 	"Use lvmpolld to supervise long running LVM commands.\n"
 	"When enabled, control of long running LVM commands is transferred\n"
 	"from the original LVM command to the lvmpolld daemon. This allows\n"
@@ -1308,7 +1308,7 @@ cfg(global_use_lvmpolld_CFG, "use_lvmpolld", global_CFG_SECTION, 0, CFG_TYPE_BOO
 	"commands will supervise long running operations by forking themselves.\n"
 	"Applicable only if LVM is compiled with lvmpolld support.\n")
 
-cfg(global_notify_dbus_CFG, "notify_dbus", global_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_NOTIFY_DBUS, vsn(2, 2, 145), NULL, 0, NULL,
+cfg(global_notify_dbus_CFG, "notify_dbus", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_NOTIFY_DBUS, vsn(2, 2, 145), NULL, 0, NULL,
 	"Enable D-Bus notification from LVM commands.\n"
 	"When enabled, an LVM command that changes PVs, changes VG metadata,\n"
 	"or changes the activation state of an LV will send a notification.\n")
@@ -1321,7 +1321,7 @@ cfg(global_io_memory_size_CFG, "io_memory_size", global_CFG_SECTION, CFG_DEFAULT
 	"This value should usually not be decreased from the default; setting\n"
 	"it too low can result in lvm failing to read VGs.\n")
 
-cfg(activation_udev_sync_CFG, "udev_sync", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_UDEV_SYNC, vsn(2, 2, 51), NULL, 0, NULL,
+cfg(activation_udev_sync_CFG, "udev_sync", activation_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_UDEV_SYNC, vsn(2, 2, 51), NULL, 0, NULL,
 	"Use udev notifications to synchronize udev and LVM.\n"
 	"The --noudevsync option overrides this setting.\n"
 	"When disabled, LVM commands will not wait for notifications from\n"
@@ -1331,7 +1331,7 @@ cfg(activation_udev_sync_CFG, "udev_sync", activation_CFG_SECTION, 0, CFG_TYPE_B
 	"running, and LVM processes are waiting for udev, run the command\n"
 	"'dmsetup udevcomplete_all' to wake them up.\n")
 
-cfg(activation_udev_rules_CFG, "udev_rules", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_UDEV_RULES, vsn(2, 2, 57), NULL, 0, NULL,
+cfg(activation_udev_rules_CFG, "udev_rules", activation_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_UDEV_RULES, vsn(2, 2, 57), NULL, 0, NULL,
 	"Use udev rules to manage LV device nodes and symlinks.\n"
 	"When disabled, LVM will manage the device nodes and symlinks for\n"
 	"active LVs itself. Manual intervention may be required if this\n"
@@ -1343,13 +1343,13 @@ cfg(activation_verify_udev_operations_CFG, "verify_udev_operations", activation_
 	"in the device directory after udev has completed processing its\n"
 	"events. Useful for diagnosing problems with LVM/udev interactions.\n")
 
-cfg(activation_retry_deactivation_CFG, "retry_deactivation", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_RETRY_DEACTIVATION, vsn(2, 2, 89), NULL, 0, NULL,
+cfg(activation_retry_deactivation_CFG, "retry_deactivation", activation_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_RETRY_DEACTIVATION, vsn(2, 2, 89), NULL, 0, NULL,
 	"Retry failed LV deactivation.\n"
 	"If LV deactivation fails, LVM will retry for a few seconds before\n"
 	"failing. This may happen because a process run from a quick udev rule\n"
 	"temporarily opened the device.\n")
 
-cfg(activation_missing_stripe_filler_CFG, "missing_stripe_filler", activation_CFG_SECTION, CFG_ADVANCED, CFG_TYPE_STRING, DEFAULT_STRIPE_FILLER, vsn(1, 0, 0), NULL, 0, NULL,
+cfg(activation_missing_stripe_filler_CFG, "missing_stripe_filler", activation_CFG_SECTION, CFG_DEFAULT_COMMENTED | CFG_ADVANCED, CFG_TYPE_STRING, DEFAULT_STRIPE_FILLER, vsn(1, 0, 0), NULL, 0, NULL,
 	"Method to fill missing stripes when activating an incomplete LV.\n"
 	"Using 'error' will make inaccessible parts of the device return I/O\n"
 	"errors on access. Using 'zero' will return success (and zero) on I/O\n"
@@ -1462,11 +1462,11 @@ cfg_array(activation_read_only_volume_list_CFG, "read_only_volume_list", activat
 	"read_only_volume_list = [ \"vg1\", \"vg2/lvol1\", \"@tag1\", \"@*\" ]\n"
 	"#\n")
 
- cfg(activation_mirror_region_size_CFG, "mirror_region_size", activation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_RAID_REGION_SIZE, vsn(1, 0, 0), NULL, vsn(2, 2, 99),
+ cfg(activation_mirror_region_size_CFG, "mirror_region_size", activation_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_RAID_REGION_SIZE, vsn(1, 0, 0), NULL, vsn(2, 2, 99),
 	"This has been replaced by the activation/raid_region_size setting.\n",
 	"Size in KiB of each raid or mirror synchronization region.\n")
 
-cfg(activation_raid_region_size_CFG, "raid_region_size", activation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_RAID_REGION_SIZE, vsn(2, 2, 99), NULL, 0, NULL,
+cfg(activation_raid_region_size_CFG, "raid_region_size", activation_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_RAID_REGION_SIZE, vsn(2, 2, 99), NULL, 0, NULL,
 	"Size in KiB of each raid or mirror synchronization region.\n"
 	"The clean/dirty state of data is tracked for each region.\n"
 	"The value is rounded down to a power of two if necessary, and\n"
@@ -1491,7 +1491,7 @@ cfg(activation_readahead_CFG, "readahead", activation_CFG_SECTION, CFG_DEFAULT_C
 	"    Use default value chosen by kernel.\n"
 	"#\n")
 
-cfg(activation_raid_fault_policy_CFG, "raid_fault_policy", activation_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_RAID_FAULT_POLICY, vsn(2, 2, 89), NULL, 0, NULL,
+cfg(activation_raid_fault_policy_CFG, "raid_fault_policy", activation_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_RAID_FAULT_POLICY, vsn(2, 2, 89), NULL, 0, NULL,
 	"Defines how a device failure in a RAID LV is handled.\n"
 	"This includes LVs that have the following segment types:\n"
 	"raid1, raid4, raid5*, and raid6*.\n"
@@ -1512,7 +1512,7 @@ cfg(activation_raid_fault_policy_CFG, "raid_fault_policy", activation_CFG_SECTIO
 	"    replace faulty devices.\n"
 	"#\n")
 
-cfg_runtime(activation_mirror_image_fault_policy_CFG, "mirror_image_fault_policy", activation_CFG_SECTION, 0, CFG_TYPE_STRING, vsn(2, 2, 57), 0, NULL,
+cfg_runtime(activation_mirror_image_fault_policy_CFG, "mirror_image_fault_policy", activation_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, vsn(2, 2, 57), 0, NULL,
 	"Defines how a device failure in a 'mirror' LV is handled.\n"
 	"An LV with the 'mirror' segment type is composed of mirror images\n"
 	"(copies) and a mirror log. A disk log ensures that a mirror LV does\n"
@@ -1548,16 +1548,16 @@ cfg_runtime(activation_mirror_image_fault_policy_CFG, "mirror_image_fault_policy
 	"    replacement.\n"
 	"#\n")
 
-cfg(activation_mirror_log_fault_policy_CFG, "mirror_log_fault_policy", activation_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_MIRROR_LOG_FAULT_POLICY, vsn(1, 2, 18), NULL, 0, NULL,
+cfg(activation_mirror_log_fault_policy_CFG, "mirror_log_fault_policy", activation_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_MIRROR_LOG_FAULT_POLICY, vsn(1, 2, 18), NULL, 0, NULL,
 	"Defines how a device failure in a 'mirror' log LV is handled.\n"
 	"The mirror_image_fault_policy description for mirrored LVs also\n"
 	"applies to mirrored log LVs.\n")
 
-cfg(activation_mirror_device_fault_policy_CFG, "mirror_device_fault_policy", activation_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_MIRROR_DEVICE_FAULT_POLICY, vsn(1, 2, 10), NULL, vsn(2, 2, 57),
+cfg(activation_mirror_device_fault_policy_CFG, "mirror_device_fault_policy", activation_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_MIRROR_DEVICE_FAULT_POLICY, vsn(1, 2, 10), NULL, vsn(2, 2, 57),
 	"This has been replaced by the activation/mirror_image_fault_policy setting.\n",
 	"Define how a device failure affecting a mirror is handled.\n")
 
-cfg(activation_snapshot_autoextend_threshold_CFG, "snapshot_autoextend_threshold", activation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_SNAPSHOT_AUTOEXTEND_THRESHOLD, vsn(2, 2, 75), NULL, 0, NULL,
+cfg(activation_snapshot_autoextend_threshold_CFG, "snapshot_autoextend_threshold", activation_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_SNAPSHOT_AUTOEXTEND_THRESHOLD, vsn(2, 2, 75), NULL, 0, NULL,
 	"Auto-extend a snapshot when its usage exceeds this percent.\n"
 	"Setting this to 100 disables automatic extension.\n"
 	"The minimum value is 50 (a smaller value is treated as 50.)\n"
@@ -1571,7 +1571,7 @@ cfg(activation_snapshot_autoextend_threshold_CFG, "snapshot_autoextend_threshold
 	"snapshot_autoextend_threshold = 70\n"
 	"#\n")
 
-cfg(activation_snapshot_autoextend_percent_CFG, "snapshot_autoextend_percent", activation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_SNAPSHOT_AUTOEXTEND_PERCENT, vsn(2, 2, 75), NULL, 0, NULL,
+cfg(activation_snapshot_autoextend_percent_CFG, "snapshot_autoextend_percent", activation_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_SNAPSHOT_AUTOEXTEND_PERCENT, vsn(2, 2, 75), NULL, 0, NULL,
 	"Auto-extending a snapshot adds this percent extra space.\n"
 	"The amount of additional space added to a snapshot is this\n"
 	"percent of its current size.\n"
@@ -1583,7 +1583,7 @@ cfg(activation_snapshot_autoextend_percent_CFG, "snapshot_autoextend_percent", a
 	"snapshot_autoextend_percent = 20\n"
 	"#\n")
 
-cfg(activation_thin_pool_autoextend_threshold_CFG, "thin_pool_autoextend_threshold", activation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA, CFG_TYPE_INT, DEFAULT_THIN_POOL_AUTOEXTEND_THRESHOLD, vsn(2, 2, 89), NULL, 0, NULL,
+cfg(activation_thin_pool_autoextend_threshold_CFG, "thin_pool_autoextend_threshold", activation_CFG_SECTION, CFG_DEFAULT_COMMENTED | CFG_PROFILABLE | CFG_PROFILABLE_METADATA, CFG_TYPE_INT, DEFAULT_THIN_POOL_AUTOEXTEND_THRESHOLD, vsn(2, 2, 89), NULL, 0, NULL,
 	"Auto-extend a thin pool when its usage exceeds this percent.\n"
 	"Setting this to 100 disables automatic extension.\n"
 	"The minimum value is 50 (a smaller value is treated as 50.)\n"
@@ -1597,7 +1597,7 @@ cfg(activation_thin_pool_autoextend_threshold_CFG, "thin_pool_autoextend_thresho
 	"thin_pool_autoextend_threshold = 70\n"
 	"#\n")
 
-cfg(activation_thin_pool_autoextend_percent_CFG, "thin_pool_autoextend_percent", activation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA, CFG_TYPE_INT, DEFAULT_THIN_POOL_AUTOEXTEND_PERCENT, vsn(2, 2, 89), NULL, 0, NULL,
+cfg(activation_thin_pool_autoextend_percent_CFG, "thin_pool_autoextend_percent", activation_CFG_SECTION, CFG_DEFAULT_COMMENTED | CFG_PROFILABLE | CFG_PROFILABLE_METADATA, CFG_TYPE_INT, DEFAULT_THIN_POOL_AUTOEXTEND_PERCENT, vsn(2, 2, 89), NULL, 0, NULL,
 	"Auto-extending a thin pool adds this percent extra space.\n"
 	"The amount of additional space added to a thin pool is this\n"
 	"percent of its current size.\n"
@@ -1654,7 +1654,7 @@ cfg(activation_use_mlockall_CFG, "use_mlockall", activation_CFG_SECTION, CFG_DEF
 	"Prior to version 2.02.62, LVM used mlockall() to pin the whole\n"
 	"process's memory while activating devices.\n")
 
-cfg(activation_monitoring_CFG, "monitoring", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_DMEVENTD_MONITOR, vsn(2, 2, 63), NULL, 0, NULL,
+cfg(activation_monitoring_CFG, "monitoring", activation_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_DMEVENTD_MONITOR, vsn(2, 2, 63), NULL, 0, NULL,
 	"Monitor LVs that are activated.\n"
 	"The --ignoremonitoring option overrides this setting.\n"
 	"When enabled, LVM will ask dmeventd to monitor activated LVs.\n")
@@ -1676,7 +1676,7 @@ cfg(activation_auto_set_activation_skip_CFG, "auto_set_activation_skip", activat
 	"flag set. When this setting is enabled, the activation skip flag is\n"
 	"set on new thin snapshot LVs.\n")
 
-cfg(activation_mode_CFG, "activation_mode", activation_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_ACTIVATION_MODE, vsn(2,2,108), NULL, 0, NULL,
+cfg(activation_mode_CFG, "activation_mode", activation_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_ACTIVATION_MODE, vsn(2,2,108), NULL, 0, NULL,
 	"How LVs with missing devices are activated.\n"
 	"The --activationmode option overrides this setting.\n"
 	"#\n"
@@ -2199,4 +2199,4 @@ cfg(local_host_id_CFG, "host_id", local_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_
 	"This must be unique among all hosts, and must be between 1 and 2000.\n"
 	"Applicable only if LVM is compiled with lockd support\n")
 
-cfg(CFG_COUNT, NULL, root_CFG_SECTION, 0, CFG_TYPE_INT, 0, vsn(0, 0, 0), NULL, 0, NULL, NULL)
+cfg(CFG_COUNT, NULL, root_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, 0, vsn(0, 0, 0), NULL, 0, NULL, NULL)


