From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 19 Aug 2020 13:09:39 +0000 (GMT)
Subject: master - config: move some config setting into commented part
Message-ID: <20200819130939.CF43A3857C4D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7b41ea61b2e33dbfad754fd4c6e7851faf7ca5ef
Commit:        7b41ea61b2e33dbfad754fd4c6e7851faf7ca5ef
Parent:        135d16fbb808da1d37d33258812f2eca4466c5bc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jul 9 23:22:52 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Aug 19 15:07:09 2020 +0200

config: move some config setting into commented part

It's better to set most of option as 'commented' with some
documented defaults instead of providing strict values.

This has the advantage we can eventually 'change' defualts
and get them working in future. Otherwise once the setting
is stored in lvm.conf in /etc, such setting has strictly
defined value and that can be only change with file update.
---
 conf/example.conf.in         | 51 +++++++++++++++++++++++++++++---------------
 lib/config/config_settings.h | 34 ++++++++++++++---------------
 2 files changed, 51 insertions(+), 34 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index a3d8ca380..6b0622ab9 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -429,7 +429,8 @@ allocation {
 
 	# Configuration option allocation/cache_pool_metadata_require_separate_pvs.
 	# Cache pool metadata and data will always use different PVs.
-	cache_pool_metadata_require_separate_pvs = 0
+	# This configuration option has an automatic default value.
+	# cache_pool_metadata_require_separate_pvs = 0
 
 	# Configuration option allocation/cache_metadata_format.
 	# Sets default metadata format for new cache.
@@ -489,7 +490,8 @@ allocation {
 
 	# Configuration option allocation/thin_pool_metadata_require_separate_pvs.
 	# Thin pool metadata and data will always use different PVs.
-	thin_pool_metadata_require_separate_pvs = 0
+	# This configuration option has an automatic default value.
+	# thin_pool_metadata_require_separate_pvs = 0
 
 	# Configuration option allocation/thin_pool_zero.
 	# Thin pool data chunks are zeroed before they are first used.
@@ -528,7 +530,8 @@ allocation {
 
 	# Configuration option allocation/zero_metadata.
 	# Zero whole metadata area before use with thin or cache pool.
-	zero_metadata = 1
+	# This configuration option has an automatic default value.
+	# zero_metadata = 1
 
 	# Configuration option allocation/thin_pool_chunk_size.
 	# The minimal chunk size in KiB for thin pool volumes.
@@ -990,7 +993,8 @@ global {
 	# logs and conversion to disk/core works.
 	# 
 	# Not supported for regular operation!
-	support_mirrored_mirror_log = 0
+	# This configuration option has an automatic default value.
+	# support_mirrored_mirror_log = 0
 
 	# Configuration option global/raid10_segtype_default.
 	# The segment type used by the -i -m combination.
@@ -1048,7 +1052,8 @@ global {
 	# activated from these events (the default is all.)
 	# When event_activation is disabled, the system will generally run
 	# a direct activation command to activate LVs in complete VGs.
-	event_activation = 1
+	# This configuration option has an automatic default value.
+	# event_activation = 1
 
 	# Configuration option global/use_aio.
 	# Use async I/O when reading and writing devices.
@@ -1292,7 +1297,8 @@ activation {
 	# This enables additional checks (and if necessary, repairs) on entries
 	# in the device directory after udev has completed processing its
 	# events. Useful for diagnosing problems with LVM/udev interactions.
-	verify_udev_operations = 0
+	# This configuration option has an automatic default value.
+	# verify_udev_operations = 0
 
 	# Configuration option activation/retry_deactivation.
 	# Retry failed LV deactivation.
@@ -1317,23 +1323,27 @@ activation {
 	# When disabled, the striped target is used. The linear target is an
 	# optimised version of the striped target that only handles a single
 	# stripe.
-	use_linear_target = 1
+	# This configuration option has an automatic default value.
+	# use_linear_target = 1
 
 	# Configuration option activation/reserved_stack.
 	# Stack size in KiB to reserve for use while devices are suspended.
 	# Insufficent reserve risks I/O deadlock during device suspension.
-	reserved_stack = 64
+	# This configuration option has an automatic default value.
+	# reserved_stack = 64
 
 	# Configuration option activation/reserved_memory.
 	# Memory size in KiB to reserve for use while devices are suspended.
 	# Insufficent reserve risks I/O deadlock during device suspension.
-	reserved_memory = 8192
+	# This configuration option has an automatic default value.
+	# reserved_memory = 8192
 
 	# Configuration option activation/process_priority.
 	# Nice value used while devices are suspended.
 	# Use a high priority so that LVs are suspended
 	# for the shortest possible time.
-	process_priority = -18
+	# This configuration option has an automatic default value.
+	# process_priority = -18
 
 	# Configuration option activation/volume_list.
 	# Only LVs selected by this list are activated.
@@ -1450,7 +1460,8 @@ activation {
 	#   auto
 	#     Use default value chosen by kernel.
 	# 
-	readahead = "auto"
+	# This configuration option has an automatic default value.
+	# readahead = "auto"
 
 	# Configuration option activation/raid_fault_policy.
 	# Defines how a device failure in a RAID LV is handled.
@@ -1586,7 +1597,8 @@ activation {
 	# 8.4G, it is extended to 14.4G:
 	# vdo_pool_autoextend_threshold = 70
 	# 
-	vdo_pool_autoextend_threshold = 100
+	# This configuration option has an automatic default value.
+	# vdo_pool_autoextend_threshold = 100
 
 	# Configuration option activation/vdo_pool_autoextend_percent.
 	# Auto-extending a VDO pool adds this percent extra space.
@@ -1622,7 +1634,8 @@ activation {
 	# Use the old behavior of mlockall to pin all memory.
 	# Prior to version 2.02.62, LVM used mlockall() to pin the whole
 	# process's memory while activating devices.
-	use_mlockall = 0
+	# This configuration option has an automatic default value.
+	# use_mlockall = 0
 
 	# Configuration option activation/monitoring.
 	# Monitor LVs that are activated.
@@ -1637,7 +1650,8 @@ activation {
 	# intervals of this number of seconds. If this is set to 0 and there
 	# is only one thing to wait for, there are no progress reports, but
 	# the process is awoken immediately once the operation is complete.
-	polling_interval = 15
+	# This configuration option has an automatic default value.
+	# polling_interval = 15
 
 	# Configuration option activation/auto_set_activation_skip.
 	# Set the activation skip flag on new thin snapshot LVs.
@@ -2193,7 +2207,8 @@ dmeventd {
 	# failures. It removes failed devices from a volume group and
 	# reconfigures a mirror as necessary. If no mirror library is
 	# provided, mirrors are not monitored through dmeventd.
-	mirror_library = "libdevmapper-event-lvm2mirror.so"
+	# This configuration option has an automatic default value.
+	# mirror_library = "libdevmapper-event-lvm2mirror.so"
 
 	# Configuration option dmeventd/raid_library.
 	# This configuration option has an automatic default value.
@@ -2204,14 +2219,16 @@ dmeventd {
 	# libdevmapper-event-lvm2snapshot.so monitors the filling of snapshots
 	# and emits a warning through syslog when the usage exceeds 80%. The
 	# warning is repeated when 85%, 90% and 95% of the snapshot is filled.
-	snapshot_library = "libdevmapper-event-lvm2snapshot.so"
+	# This configuration option has an automatic default value.
+	# snapshot_library = "libdevmapper-event-lvm2snapshot.so"
 
 	# Configuration option dmeventd/thin_library.
 	# The library dmeventd uses when monitoring a thin device.
 	# libdevmapper-event-lvm2thin.so monitors the filling of a pool
 	# and emits a warning through syslog when the usage exceeds 80%. The
 	# warning is repeated when 85%, 90% and 95% of the pool is filled.
-	thin_library = "libdevmapper-event-lvm2thin.so"
+	# This configuration option has an automatic default value.
+	# thin_library = "libdevmapper-event-lvm2thin.so"
 
 	# Configuration option dmeventd/thin_command.
 	# The plugin runs command with each 5% increment when thin-pool data volume
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 531fb139d..e4e3dcdde 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -568,7 +568,7 @@ cfg(allocation_raid_stripe_all_devices_CFG, "raid_stripe_all_devices", allocatio
 	"stripes to use.\n"
 	"This was the default behaviour until release 2.02.162.\n")
 
-cfg(allocation_cache_pool_metadata_require_separate_pvs_CFG, "cache_pool_metadata_require_separate_pvs", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA, CFG_TYPE_BOOL, DEFAULT_CACHE_POOL_METADATA_REQUIRE_SEPARATE_PVS, vsn(2, 2, 106), NULL, 0, NULL,
+cfg(allocation_cache_pool_metadata_require_separate_pvs_CFG, "cache_pool_metadata_require_separate_pvs", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_CACHE_POOL_METADATA_REQUIRE_SEPARATE_PVS, vsn(2, 2, 106), NULL, 0, NULL,
 	"Cache pool metadata and data will always use different PVs.\n")
 
 cfg(allocation_cache_pool_cachemode_CFG, "cache_pool_cachemode", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_CACHE_MODE, vsn(2, 2, 113), NULL, vsn(2, 2, 128),
@@ -625,7 +625,7 @@ cfg(allocation_cache_pool_max_chunks_CFG, "cache_pool_max_chunks", allocation_CF
 	"For cache target v1.9 the recommended maximumm is 1000000 chunks.\n"
 	"Using cache pool with more chunks may degrade cache performance.\n")
 
-cfg(allocation_thin_pool_metadata_require_separate_pvs_CFG, "thin_pool_metadata_require_separate_pvs", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_THIN_POOL_METADATA_REQUIRE_SEPARATE_PVS, vsn(2, 2, 89), NULL, 0, NULL,
+cfg(allocation_thin_pool_metadata_require_separate_pvs_CFG, "thin_pool_metadata_require_separate_pvs", allocation_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_THIN_POOL_METADATA_REQUIRE_SEPARATE_PVS, vsn(2, 2, 89), NULL, 0, NULL,
 	"Thin pool metadata and data will always use different PVs.\n")
 
 cfg(allocation_thin_pool_zero_CFG, "thin_pool_zero", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_THIN_POOL_ZERO, vsn(2, 2, 99), NULL, 0, NULL,
@@ -657,7 +657,7 @@ cfg(allocation_thin_pool_chunk_size_policy_CFG, "thin_pool_chunk_size_policy", a
 	"    512KiB.\n"
 	"#\n")
 
-cfg(allocation_zero_metadata_CFG, "zero_metadata", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_ZERO_METADATA, vsn(2, 3, 10), NULL, 0, NULL,
+cfg(allocation_zero_metadata_CFG, "zero_metadata", allocation_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_ZERO_METADATA, vsn(2, 3, 10), NULL, 0, NULL,
 	"Zero whole metadata area before use with thin or cache pool.\n")
 
 cfg_runtime(allocation_thin_pool_chunk_size_CFG, "thin_pool_chunk_size", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_UNDEFINED, CFG_TYPE_INT, vsn(2, 2, 99), 0, NULL,
@@ -1031,7 +1031,7 @@ cfg(global_mirror_segtype_default_CFG, "mirror_segtype_default", global_CFG_SECT
 	"    fashion in a cluster.\n"
 	"#\n")
 
-cfg(global_support_mirrored_mirror_log_CFG, "support_mirrored_mirror_log", global_CFG_SECTION, 0, CFG_TYPE_BOOL, 0, vsn(2, 3, 2), NULL, 0, NULL,
+cfg(global_support_mirrored_mirror_log_CFG, "support_mirrored_mirror_log", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, 0, vsn(2, 3, 2), NULL, 0, NULL,
 	"Enable mirrored 'mirror' log type for testing.\n"
 	"#\n"
 	"This type is deprecated to create or convert to but can\n"
@@ -1085,7 +1085,7 @@ cfg(global_lvdisplay_shows_full_device_path_CFG, "lvdisplay_shows_full_device_pa
 	"Previously this was always shown as /dev/vgname/lvname even when that\n"
 	"was never a valid path in the /dev filesystem.\n")
 
-cfg(global_event_activation_CFG, "event_activation", global_CFG_SECTION, 0, CFG_TYPE_BOOL, 1, vsn(2, 3, 1), 0, 0, NULL,
+cfg(global_event_activation_CFG, "event_activation", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, 1, vsn(2, 3, 1), 0, 0, NULL,
 	"Activate LVs based on system-generated device events.\n"
 	"When a device appears on the system, a system-generated event runs\n"
 	"the pvscan command to activate LVs if the new PV completes the VG.\n"
@@ -1289,7 +1289,7 @@ cfg(activation_udev_rules_CFG, "udev_rules", activation_CFG_SECTION, 0, CFG_TYPE
 	"active LVs itself. Manual intervention may be required if this\n"
 	"setting is changed while LVs are active.\n")
 
-cfg(activation_verify_udev_operations_CFG, "verify_udev_operations", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_VERIFY_UDEV_OPERATIONS, vsn(2, 2, 86), NULL, 0, NULL,
+cfg(activation_verify_udev_operations_CFG, "verify_udev_operations", activation_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_VERIFY_UDEV_OPERATIONS, vsn(2, 2, 86), NULL, 0, NULL,
 	"Use extra checks in LVM to verify udev operations.\n"
 	"This enables additional checks (and if necessary, repairs) on entries\n"
 	"in the device directory after udev has completed processing its\n"
@@ -1310,21 +1310,21 @@ cfg(activation_missing_stripe_filler_CFG, "missing_stripe_filler", activation_CF
 	"other than 'error' with mirrored or snapshotted volumes is likely to\n"
 	"result in data corruption.\n")
 
-cfg(activation_use_linear_target_CFG, "use_linear_target", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_USE_LINEAR_TARGET, vsn(2, 2, 89), NULL, 0, NULL,
+cfg(activation_use_linear_target_CFG, "use_linear_target", activation_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_USE_LINEAR_TARGET, vsn(2, 2, 89), NULL, 0, NULL,
 	"Use the linear target to optimize single stripe LVs.\n"
 	"When disabled, the striped target is used. The linear target is an\n"
 	"optimised version of the striped target that only handles a single\n"
 	"stripe.\n")
 
-cfg(activation_reserved_stack_CFG, "reserved_stack", activation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_RESERVED_STACK, vsn(1, 0, 0), NULL, 0, NULL,
+cfg(activation_reserved_stack_CFG, "reserved_stack", activation_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_RESERVED_STACK, vsn(1, 0, 0), NULL, 0, NULL,
 	"Stack size in KiB to reserve for use while devices are suspended.\n"
 	"Insufficent reserve risks I/O deadlock during device suspension.\n")
 
-cfg(activation_reserved_memory_CFG, "reserved_memory", activation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_RESERVED_MEMORY, vsn(1, 0, 0), NULL, 0, NULL,
+cfg(activation_reserved_memory_CFG, "reserved_memory", activation_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_RESERVED_MEMORY, vsn(1, 0, 0), NULL, 0, NULL,
 	"Memory size in KiB to reserve for use while devices are suspended.\n"
 	"Insufficent reserve risks I/O deadlock during device suspension.\n")
 
-cfg(activation_process_priority_CFG, "process_priority", activation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_PROCESS_PRIORITY, vsn(1, 0, 0), NULL, 0, NULL,
+cfg(activation_process_priority_CFG, "process_priority", activation_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_PROCESS_PRIORITY, vsn(1, 0, 0), NULL, 0, NULL,
 	"Nice value used while devices are suspended.\n"
 	"Use a high priority so that LVs are suspended\n"
 	"for the shortest possible time.\n")
@@ -1433,7 +1433,7 @@ cfg(activation_error_when_full_CFG, "error_when_full", activation_CFG_SECTION, C
 	"thin pool data space is extended. New thin pools are assigned the\n"
 	"behavior defined here.\n")
 
-cfg(activation_readahead_CFG, "readahead", activation_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_READ_AHEAD, vsn(1, 0, 23), NULL, 0, NULL,
+cfg(activation_readahead_CFG, "readahead", activation_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_READ_AHEAD, vsn(1, 0, 23), NULL, 0, NULL,
 	"Setting to use when there is no readahead setting in metadata.\n"
 	"#\n"
 	"Accepted values:\n"
@@ -1561,7 +1561,7 @@ cfg(activation_thin_pool_autoextend_percent_CFG, "thin_pool_autoextend_percent",
 	"thin_pool_autoextend_percent = 20\n"
 	"#\n")
 
-cfg(activation_vdo_pool_autoextend_threshold_CFG, "vdo_pool_autoextend_threshold", activation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA, CFG_TYPE_INT, DEFAULT_VDO_POOL_AUTOEXTEND_THRESHOLD, VDO_1ST_VSN, NULL, 0, NULL,
+cfg(activation_vdo_pool_autoextend_threshold_CFG, "vdo_pool_autoextend_threshold", activation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_VDO_POOL_AUTOEXTEND_THRESHOLD, VDO_1ST_VSN, NULL, 0, NULL,
 	"Auto-extend a VDO pool when its usage exceeds this percent.\n"
 	"Setting this to 100 disables automatic extension.\n"
 	"The minimum value is 50 (a smaller value is treated as 50.)\n"
@@ -1601,7 +1601,7 @@ cfg_array(activation_mlock_filter_CFG, "mlock_filter", activation_CFG_SECTION, C
 	"mlock_filter = [ \"locale/locale-archive\", \"gconv/gconv-modules.cache\" ]\n"
 	"#\n")
 
-cfg(activation_use_mlockall_CFG, "use_mlockall", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_USE_MLOCKALL, vsn(2, 2, 62), NULL, 0, NULL,
+cfg(activation_use_mlockall_CFG, "use_mlockall", activation_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_USE_MLOCKALL, vsn(2, 2, 62), NULL, 0, NULL,
 	"Use the old behavior of mlockall to pin all memory.\n"
 	"Prior to version 2.02.62, LVM used mlockall() to pin the whole\n"
 	"process's memory while activating devices.\n")
@@ -1611,7 +1611,7 @@ cfg(activation_monitoring_CFG, "monitoring", activation_CFG_SECTION, 0, CFG_TYPE
 	"The --ignoremonitoring option overrides this setting.\n"
 	"When enabled, LVM will ask dmeventd to monitor activated LVs.\n")
 
-cfg(activation_polling_interval_CFG, "polling_interval", activation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_INTERVAL, vsn(2, 2, 63), NULL, 0, NULL,
+cfg(activation_polling_interval_CFG, "polling_interval", activation_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_INTERVAL, vsn(2, 2, 63), NULL, 0, NULL,
 	"Check pvmove or lvconvert progress at this interval (seconds).\n"
 	"When pvmove or lvconvert must wait for the kernel to finish\n"
 	"synchronising or merging data, they check and report progress at\n"
@@ -2050,7 +2050,7 @@ cfg(report_two_word_unknown_device_CFG, "two_word_unknown_device", report_CFG_SE
 	"Use the two words 'unknown device' in place of '[unknown]'.\n"
 	"This is displayed when the device for a PV is not known.\n")
 
-cfg(dmeventd_mirror_library_CFG, "mirror_library", dmeventd_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_DMEVENTD_MIRROR_LIB, vsn(1, 2, 3), NULL, 0, NULL,
+cfg(dmeventd_mirror_library_CFG, "mirror_library", dmeventd_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_DMEVENTD_MIRROR_LIB, vsn(1, 2, 3), NULL, 0, NULL,
 	"The library dmeventd uses when monitoring a mirror device.\n"
 	"libdevmapper-event-lvm2mirror.so attempts to recover from\n"
 	"failures. It removes failed devices from a volume group and\n"
@@ -2059,13 +2059,13 @@ cfg(dmeventd_mirror_library_CFG, "mirror_library", dmeventd_CFG_SECTION, 0, CFG_
 
 cfg(dmeventd_raid_library_CFG, "raid_library", dmeventd_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_DMEVENTD_RAID_LIB, vsn(2, 2, 87), NULL, 0, NULL, NULL)
 
-cfg(dmeventd_snapshot_library_CFG, "snapshot_library", dmeventd_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_DMEVENTD_SNAPSHOT_LIB, vsn(1, 2, 26), NULL, 0, NULL,
+cfg(dmeventd_snapshot_library_CFG, "snapshot_library", dmeventd_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_DMEVENTD_SNAPSHOT_LIB, vsn(1, 2, 26), NULL, 0, NULL,
 	"The library dmeventd uses when monitoring a snapshot device.\n"
 	"libdevmapper-event-lvm2snapshot.so monitors the filling of snapshots\n"
 	"and emits a warning through syslog when the usage exceeds 80%. The\n"
 	"warning is repeated when 85%, 90% and 95% of the snapshot is filled.\n")
 
-cfg(dmeventd_thin_library_CFG, "thin_library", dmeventd_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_DMEVENTD_THIN_LIB, vsn(2, 2, 89), NULL, 0, NULL,
+cfg(dmeventd_thin_library_CFG, "thin_library", dmeventd_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_DMEVENTD_THIN_LIB, vsn(2, 2, 89), NULL, 0, NULL,
 	"The library dmeventd uses when monitoring a thin device.\n"
 	"libdevmapper-event-lvm2thin.so monitors the filling of a pool\n"
 	"and emits a warning through syslog when the usage exceeds 80%. The\n"


