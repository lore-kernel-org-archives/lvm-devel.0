From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri,  1 May 2015 23:16:21 +0000 (UTC)
Subject: master - config: Remove newly-exposed default settings.
Message-ID: <20150501231621.F1E2160789@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=796dc9c91c2da05a65054e4892eda41415c9898e
Commit:        796dc9c91c2da05a65054e4892eda41415c9898e
Parent:        3542fce0fba91b71792d5dabcbe96637f19de3fc
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Sat May 2 00:07:12 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Sat May 2 00:07:12 2015 +0100

config: Remove newly-exposed default settings.

Reinstate config settings matching the last release until every
case where the generator produces different output has been reviewed
and fresh decisions made about which defaults to expose as protection
against changes in newer releases. We should be trying to reduce, not
increase, this number.
---
 WHATS_NEW             |    7 +-
 conf/example.conf.in  |  436 ++++++++++++++++++++++---------------------------
 conf/lvmlocal.conf.in |    4 +-
 3 files changed, 199 insertions(+), 248 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 79ef842..9d30df4 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,12 +1,13 @@
 Version 2.02.119 - 
 ==================================
-  Also display deprecation info for deprecated config in lvmconfig --withcomments.
+  Generate complete config files with lvmconfig or 'make generate'.
+  Also display info on deprecated config with lvmconfig --withcomments.
   Display version since which config is deprecated in lvmconfig --withversions.
   Add --showdeprecated to lvmconfig to also display deprecated settings.
-  Hide deprecated settings in lvmconfig output for all types except current,diff.
+  Hide deprecated settings in lvmconfig output for all types but current,diff.
   Introduce support for exit on idle feature in libdaemon
   Add --showunsupported to lvmconfig to also display unsupported settings.
-  Display unsupported settings for lvmconfig --type current,diff only by default.
+  Display unsupported settings for lvmconfig --type current,diff only by default
   Honour lvmconfig --ignoreunsupported and --ignoreadvanced for all --type.
   Make python bindings usable with python3 (and compatible with 2.6 & 2.7).
   Add lvmconfig -l|--list as shortcut for lvmconfig --type list --withsummary.
diff --git a/conf/example.conf.in b/conf/example.conf.in
index 5354779..c1a8f03 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -22,15 +22,15 @@ config {
 	# If disabled, any configuration mismatch is ignored and the default
 	# value is used without any warning (a message about the
 	# configuration key not being found is issued in verbose mode only).
-	checks=1
+	checks = 1
 
 	# Configuration option config/abort_on_errors.
 	# Abort the LVM process if a configuration mismatch is found.
-	abort_on_errors=0
+	abort_on_errors = 0
 
 	# Configuration option config/profile_dir.
 	# Directory where LVM looks for configuration profiles.
-	profile_dir="@DEFAULT_SYS_DIR@/@DEFAULT_PROFILE_SUBDIR@"
+	profile_dir = "@DEFAULT_SYS_DIR@/@DEFAULT_PROFILE_SUBDIR@"
 }
 
 # Configuration section devices.
@@ -40,15 +40,13 @@ devices {
 	# Configuration option devices/dir.
 	# Directory in which to create volume group device nodes.
 	# Commands also accept this as a prefix on volume group names.
-	dir="/dev"
+	# This configuration option is advanced.
+	dir = "/dev"
 
 	# Configuration option devices/scan.
 	# Directories containing device nodes to use with LVM.
-	scan="/dev"
-
-	# Configuration option devices/loopfiles.
-	# This configuration option does not have a default value defined.
-#	loopfiles=[]
+	# This configuration option is advanced.
+	scan = [ "/dev" ]
 
 	# Configuration option devices/obtain_device_list_from_udev.
 	# Obtain the list of available devices from udev.
@@ -59,7 +57,7 @@ devices {
 	# udev-managed device directory; other directories will be
 	# scanned fully. LVM needs to be compiled with udev support
 	# for this setting to apply.
-	obtain_device_list_from_udev=1
+	obtain_device_list_from_udev = 1
 
 	# Configuration option devices/external_device_info_source.
 	# Select an external device information source.
@@ -75,7 +73,7 @@ devices {
 	# none - No external device information source is used.
 	# udev - Reuse existing udev database records. Applicable
 	# only if LVM is compiled with udev support.
-	external_device_info_source="none"
+	external_device_info_source = "none"
 
 	# Configuration option devices/preferred_names.
 	# Select which path name to display for a block device.
@@ -94,7 +92,7 @@ devices {
 	# Example:
 	# preferred_names = [ "^/dev/mpath/", "^/dev/mapper/mpath", "^/dev/[hs]d" ]
 	# This configuration option does not have a default value defined.
-#	preferred_names=[]
+	# preferred_names=[]
 
 	# Configuration option devices/filter.
 	# Limit the block devices that are used by LVM commands.
@@ -126,12 +124,12 @@ devices {
 	# filter = [ "a|loop|", "r|.*|" ]
 	# Example:
 	# Accept all loop devices and ide drives except hdc.
-	# filter =[ "a|loop|", "r|/dev/hdc|", "a|/dev/ide|", "r|.*|" ]
+	# filter = [ "a|loop|", "r|/dev/hdc|", "a|/dev/ide|", "r|.*|" ]
 	# Example:
 	# Use anchors to be very specific.
 	# filter = [ "a|^/dev/hda8$|", "r|.*/|" ]
 	# This configuration option does not have a default value defined.
-#	filter=[]
+	# filter = []
 
 	# Configuration option devices/global_filter.
 	# Limit the block devices that are used by LVM system components.
@@ -141,11 +139,7 @@ devices {
 	# system components. The syntax is the same as devices/filter.
 	# Devices rejected by global_filter are not opened by LVM.
 	# This configuration option does not have a default value defined.
-#	global_filter=[]
-
-	# Configuration option devices/cache.
-	# The path can be set using the devices/cache_dir setting.
-	cache="/etc/lvm/cache/.cache"
+	# global_filter = []
 
 	# Configuration option devices/cache_dir.
 	# Directory in which to store the device cache file.
@@ -155,15 +149,15 @@ devices {
 	# It is safe to delete this file; the tools regenerate it.
 	# If obtain_device_list_from_udev is enabled, the list of devices
 	# is obtained from udev and any existing .cache file is removed.
-	cache_dir="@DEFAULT_SYS_DIR@/@DEFAULT_CACHE_SUBDIR@"
+	cache_dir = "@DEFAULT_SYS_DIR@/@DEFAULT_CACHE_SUBDIR@"
 
 	# Configuration option devices/cache_file_prefix.
 	# A prefix used before the .cache file name. See devices/cache_dir.
-	cache_file_prefix=""
+	cache_file_prefix = ""
 
 	# Configuration option devices/write_cache_state.
 	# Enable/disable writing the cache file. See devices/cache_dir.
-	write_cache_state=1
+	write_cache_state = 1
 
 	# Configuration option devices/types.
 	# List of additional acceptable block device types.
@@ -171,40 +165,41 @@ devices {
 	# followed by the maximum number of partitions.
 	# Example:
 	# types = [ "fd", 16 ]
+	# This configuration option is advanced.
 	# This configuration option does not have a default value defined.
-#	types=[]
+	# types = []
 
 	# Configuration option devices/sysfs_scan.
 	# Restrict device scanning to block devices appearing in sysfs.
 	# This is a quick way of filtering out block devices that are
 	# not present on the system. sysfs must be part of the kernel
 	# and mounted.)
-	sysfs_scan=1
+	sysfs_scan = 1
 
 	# Configuration option devices/multipath_component_detection.
 	# Ignore devices that are components of DM multipath devices.
-	multipath_component_detection=1
+	multipath_component_detection = 1
 
 	# Configuration option devices/md_component_detection.
 	# Ignore devices that are components of software RAID (md) devices.
-	md_component_detection=1
+	md_component_detection = 1
 
 	# Configuration option devices/fw_raid_component_detection.
 	# Ignore devices that are components of firmware RAID devices.
 	# LVM must use an external_device_info_source other than none
 	# for this detection to execute.
-	fw_raid_component_detection=0
+	fw_raid_component_detection = 0
 
 	# Configuration option devices/md_chunk_alignment.
 	# Align PV data blocks with md device's stripe-width.
 	# This applies if a PV is placed directly on an md device.
-	md_chunk_alignment=1
+	md_chunk_alignment = 1
 
 	# Configuration option devices/default_data_alignment.
 	# Default alignment of the start of a PV data area in MB.
 	# If set to 0, a value of 64KB will be used.
 	# Set to 1 for 1MiB, 2 for 2MiB, etc.
-	default_data_alignment=1
+	# default_data_alignment = 1
 
 	# Configuration option devices/data_alignment_detection.
 	# Detect PV data alignment based on sysfs device information.
@@ -217,7 +212,7 @@ devices {
 	# minimum_io_size is used if optimal_io_size is undefined (0).
 	# If md_chunk_alignment is enabled, that detects the optimal_io_size.
 	# This setting takes precedence over md_chunk_alignment.
-	data_alignment_detection=1
+	data_alignment_detection = 1
 
 	# Configuration option devices/data_alignment.
 	# Alignment of the start of a PV data area in KB.
@@ -226,7 +221,7 @@ devices {
 	# then this setting is ignored.  Otherwise, md_chunk_alignment
 	# and data_alignment_detection are disabled if this is set.
 	# Set to 0 to use the default alignment or the page size, if larger.
-	data_alignment=0
+	data_alignment = 0
 
 	# Configuration option devices/data_alignment_offset_detection.
 	# Detect PV data alignment offset based on sysfs device information.
@@ -237,13 +232,13 @@ devices {
 	# (sector 7 is the lowest aligned logical block, the 4KB sectors start
 	# at LBA -1, and consequently sector 63 is aligned on a 4KB boundary).
 	# pvcreate --dataalignmentoffset will skip this detection.
-	data_alignment_offset_detection=1
+	data_alignment_offset_detection = 1
 
 	# Configuration option devices/ignore_suspended_devices.
 	# Ignore DM devices that have I/O suspended while scanning devices.
 	# Otherwise, LVM waits for a suspended device to become accessible.
 	# This should only be needed in recovery situations.
-	ignore_suspended_devices=0
+	ignore_suspended_devices = 0
 
 	# Configuration option devices/ignore_lvm_mirrors.
 	# Do not scan 'mirror' LVs to avoid possible deadlocks.
@@ -264,7 +259,7 @@ devices {
 	# The 'mirror' scanning problems do not apply to LVM RAID types like
 	# 'raid1' which handle failures in a different way, making them a
 	# better choice for VG stacking.
-	ignore_lvm_mirrors=1
+	ignore_lvm_mirrors = 1
 
 	# Configuration option devices/disable_after_error_count.
 	# Number of I/O errors after which a device is skipped.
@@ -273,18 +268,18 @@ devices {
 	# here, no further I/O is sent to that device for the remainder
 	# of the operation.
 	# Setting this to 0 disables the counters altogether.
-	disable_after_error_count=0
+	disable_after_error_count = 0
 
 	# Configuration option devices/require_restorefile_with_uuid.
 	# Allow use of pvcreate --uuid without requiring --restorefile.
-	require_restorefile_with_uuid=1
+	require_restorefile_with_uuid = 1
 
 	# Configuration option devices/pv_min_size.
 	# Minimum size (in KB) of block devices which can be used as PVs.
 	# In a clustered environment all nodes must use the same value.
 	# Any value smaller than 512KB is ignored.  The previous built-in
 	# value was 512.
-	pv_min_size=2048
+	pv_min_size = 2048
 
 	# Configuration option devices/issue_discards.
 	# Issue discards to PVs that are no longer used by an LV.
@@ -297,7 +292,7 @@ devices {
 	# Not all storage will support or benefit from discards, but SSDs
 	# and thinly provisioned LUNs generally do.  If enabled, discards
 	# will only be issued if both the storage and kernel provide support.
-	issue_discards=0
+	issue_discards = 0
 }
 
 # Configuration section allocation.
@@ -321,7 +316,7 @@ allocation {
 	# they are situated.
 	# cling_tag_list = [ "@site1", "@site2" ]
 	# This configuration option does not have a default value defined.
-#	cling_tag_list=[]
+	# cling_tag_list = []
 
 	# Configuration option allocation/maximise_cling.
 	# Use a previous allocation algorithm.
@@ -329,7 +324,7 @@ allocation {
 	# policies to detect more situations where data can be grouped onto
 	# the same disks.  This setting can be used to disable the changes
 	# and revert to the previous algorithm.
-	maximise_cling=1
+	maximise_cling = 1
 
 	# Configuration option allocation/use_blkid_wiping.
 	# Use blkid to detect existing signatures on new PVs and LVs.
@@ -341,7 +336,7 @@ allocation {
 	# MD device signatures, swap signature, and LUKS signatures.
 	# To see the list of signatures recognized by blkid, check the
 	# output of the 'blkid -k' command.
-	use_blkid_wiping=1
+	use_blkid_wiping = 1
 
 	# Configuration option allocation/wipe_signatures_when_zeroing_new_lvs.
 	# Look for and erase any signatures while zeroing a new LV.
@@ -362,16 +357,16 @@ allocation {
 	# When this setting is disabled, signatures on new LVs are
 	# not detected or erased unless the -W/--wipesignatures y
 	# option is used directly.
-	wipe_signatures_when_zeroing_new_lvs=1
+	wipe_signatures_when_zeroing_new_lvs = 1
 
 	# Configuration option allocation/mirror_logs_require_separate_pvs.
 	# Mirror logs and images will always use different PVs.
 	# The default setting changed in version 2.02.85.
-	mirror_logs_require_separate_pvs=0
+	mirror_logs_require_separate_pvs = 0
 
 	# Configuration option allocation/cache_pool_metadata_require_separate_pvs.
 	# Cache pool metadata and data will always use different PVs.
-	cache_pool_metadata_require_separate_pvs=0
+	cache_pool_metadata_require_separate_pvs = 0
 
 	# Configuration option allocation/cache_pool_cachemode.
 	# The default cache mode used for new cache pools.
@@ -380,7 +375,7 @@ allocation {
 	# the cache to disk.
 	# writeback - Data blocks are written from the cache back
 	# to disk after some delay to improve performance.
-	cache_pool_cachemode="writethrough"
+	# cache_pool_cachemode = "writethrough"
 
 	# Configuration option allocation/cache_pool_chunk_size.
 	# The minimal chunk size (in kiB) for cache pool volumes.
@@ -394,21 +389,21 @@ allocation {
 	# end of the spectrum.  Supported values range from 32(kiB) to
 	# 1048576 in multiples of 32.
 	# This configuration option does not have a default value defined.
-#	cache_pool_chunk_size=128
+	# cache_pool_chunk_size = 128
 
 	# Configuration option allocation/thin_pool_metadata_require_separate_pvs.
 	# Thin pool metdata and data will always use different PVs.
-	thin_pool_metadata_require_separate_pvs=0
+	thin_pool_metadata_require_separate_pvs = 0
 
 	# Configuration option allocation/thin_pool_zero.
 	# Thin pool data chunks are zeroed before they are first used.
 	# Zeroing with a larger thin pool chunk size reduces performance.
-	thin_pool_zero=1
+	# thin_pool_zero = 1
 
 	# Configuration option allocation/thin_pool_discards.
 	# The discards behaviour of thin pool volumes.
 	# Possible options are: ignore, nopassdown, passdown.
-	thin_pool_discards="passdown"
+	# thin_pool_discards = "passdown"
 
 	# Configuration option allocation/thin_pool_chunk_size_policy.
 	# The chunk size calculation policy for thin pool volumes.
@@ -421,7 +416,7 @@ allocation {
 	# Otherwise, calculate the chunk size for performance based on
 	# device hints exposed in sysfs - the optimal_io_size.
 	# The chunk size is always at least 512KiB.
-	thin_pool_chunk_size_policy="generic"
+	# thin_pool_chunk_size_policy = "generic"
 
 	# Configuration option allocation/thin_pool_chunk_size.
 	# The minimal chunk size (in KB) for thin pool volumes.
@@ -432,11 +427,11 @@ allocation {
 	# chunk size starting from 64KB.  Supported values are in
 	# the range 64 to 1048576.
 	# This configuration option does not have a default value defined.
-#	thin_pool_chunk_size=128
+	# thin_pool_chunk_size = 128
 
 	# Configuration option allocation/physical_extent_size.
 	# Default physical extent size to use for new VGs (in KB).
-	physical_extent_size=4096
+	# physical_extent_size = 4096
 }
 
 # Configuration section log.
@@ -445,7 +440,7 @@ log {
 
 	# Configuration option log/verbose.
 	# Controls the messages sent to stdout or stderr.
-	verbose=0
+	verbose = 0
 
 	# Configuration option log/silent.
 	# Suppress all non-essential messages from stdout.
@@ -457,34 +452,34 @@ log {
 	# for syslog and lvm2_log_fn purposes.
 	# Any 'yes' or 'no' questions not overridden by other arguments
 	# are suppressed and default to 'no'.
-	silent=0
+	silent = 0
 
 	# Configuration option log/syslog.
 	# Send log messages through syslog.
-	syslog=1
+	syslog = 1
 
 	# Configuration option log/file.
 	# Write error and debug log messages to a file specified here.
 	# This configuration option does not have a default value defined.
-#	file=""
+	# file = ""
 
 	# Configuration option log/overwrite.
 	# Overwrite the log file each time the program is run.
-	overwrite=0
+	overwrite = 0
 
 	# Configuration option log/level.
 	# The level of log messages that are sent to the log file or syslog.
 	# There are 6 syslog-like log levels currently in use: 2 to 7 inclusive.
 	# 7 is the most verbose (LOG_DEBUG).
-	level=0
+	level = 0
 
 	# Configuration option log/indent.
 	# Indent messages according to their severity.
-	indent=1
+	indent = 1
 
 	# Configuration option log/command_names.
 	# Display the command name on each line of output.
-	command_names=0
+	command_names = 0
 
 	# Configuration option log/prefix.
 	# A prefix to use before the log message text.
@@ -492,16 +487,12 @@ log {
 	# Two spaces allows you to see/grep the severity of each message.
 	# To make the messages look similar to the original LVM tools use:
 	# indent = 0, command_names = 1, prefix = " -- "
-	prefix="  "
+	prefix = "  "
 
 	# Configuration option log/activation.
 	# Log messages during activation.
 	# Don't use this in low memory situations (can deadlock).
-	activation=0
-
-	# Configuration option log/activate_file.
-	# This configuration option does not have a default value defined.
-#	activate_file=""
+	# activation = 0
 
 	# Configuration option log/debug_classes.
 	# Select log messages by class.
@@ -511,7 +502,8 @@ log {
 	# memory, devices, activation, allocation,
 	# lvmetad, metadata, cache, locking.
 	# Use "all" to see everything.
-	debug_classes=["memory", "devices", "activation", "allocation", "lvmetad", "metadata", "cache", "locking"]
+	debug_classes = ["memory", "devices", "activation", "allocation",
+			 "lvmetad", "metadata", "cache", "locking"]
 }
 
 # Configuration section backup.
@@ -525,30 +517,30 @@ backup {
 	# Configuration option backup/backup.
 	# Maintain a backup of the current metadata configuration.
 	# Think very hard before turning this off!
-	backup=1
+	backup = 1
 
 	# Configuration option backup/backup_dir.
 	# Location of the metadata backup files.
 	# Remember to back up this directory regularly!
-	backup_dir="@DEFAULT_SYS_DIR@/@DEFAULT_BACKUP_SUBDIR@"
+	backup_dir = "@DEFAULT_SYS_DIR@/@DEFAULT_BACKUP_SUBDIR@"
 
 	# Configuration option backup/archive.
 	# Maintain an archive of old metadata configurations.
 	# Think very hard before turning this off.
-	archive=1
+	archive = 1
 
 	# Configuration option backup/archive_dir.
 	# Location of the metdata archive files.
 	# Remember to back up this directory regularly!
-	archive_dir="@DEFAULT_SYS_DIR@/@DEFAULT_ARCHIVE_SUBDIR@"
+	archive_dir = "@DEFAULT_SYS_DIR@/@DEFAULT_ARCHIVE_SUBDIR@"
 
 	# Configuration option backup/retain_min.
 	# Minimum number of archives to keep.
-	retain_min=10
+	retain_min = 10
 
 	# Configuration option backup/retain_days.
 	# Minimum number of days to keep archive files.
-	retain_days=30
+	retain_days = 30
 }
 
 # Configuration section shell.
@@ -557,7 +549,7 @@ shell {
 
 	# Configuration option shell/history_size.
 	# Number of lines of history to store in ~/.lvm_history.
-	history_size=100
+	history_size = 100
 }
 
 # Configuration section global.
@@ -567,16 +559,16 @@ global {
 	# Configuration option global/umask.
 	# The file creation mask for any files and directories created.
 	# Interpreted as octal if the first digit is zero.
-	umask=63
+	umask = 077
 
 	# Configuration option global/test.
 	# No on-disk metadata changes will be made in test mode.
 	# Equivalent to having the -t option on every command.
-	test=0
+	test = 0
 
 	# Configuration option global/units.
 	# Default value for --units argument.
-	units="h"
+	units = "h"
 
 	# Configuration option global/si_unit_consistency.
 	# Distinguish between powers of 1024 and 1000 bytes.
@@ -584,14 +576,14 @@ global {
 	# e.g. KiB, MiB, GiB, and powers of 1000 bytes, e.g. KB, MB, GB.
 	# If scripts depend on the old behaviour, disable
 	# this setting temporarily until they are updated.
-	si_unit_consistency=1
+	si_unit_consistency = 1
 
 	# Configuration option global/suffix.
 	# Display unit suffix for sizes.
 	# This setting has no effect if the units are in human-readable
-	# form (global/units="h") in which case the suffix is always
+	# form (global/units = "h") in which case the suffix is always
 	# displayed.
-	suffix=1
+	suffix = 1
 
 	# Configuration option global/activation.
 	# Enable/disable communication with the kernel device-mapper.
@@ -599,7 +591,7 @@ global {
 	# activating any logical volumes. If the device-mapper driver
 	# is not present in the kernel, disabling this should suppress
 	# the error messages.
-	activation=1
+	activation = 1
 
 	# Configuration option global/fallback_to_lvm1.
 	# Try running LVM1 tools if LVM cannot communicate with DM.
@@ -608,32 +600,33 @@ global {
 	# The LVM1 tools need to be installed with .lvm1 suffices,
 	# e.g. vgscan.lvm1. They will stop working once the lvm2
 	# on-disk metadata format is used.
-	fallback_to_lvm1=1
+	# fallback_to_lvm1 = 0
 
 	# Configuration option global/format.
 	# The default metadata format that commands should use.
 	# "lvm1" or "lvm2".
 	# The command line override is -M1 or -M2.
-	format="lvm2"
+	# format = "lvm2"
 
 	# Configuration option global/format_libraries.
 	# Shared libraries that process different metadata formats.
 	# If support for LVM1 metadata was compiled as a shared library use
 	# format_libraries = "liblvm2format1.so"
 	# This configuration option does not have a default value defined.
-#	format_libraries=[]
+	# format_libraries = []
 
 	# Configuration option global/segment_libraries.
 	# This configuration option does not have a default value defined.
-#	segment_libraries=[]
+	# segment_libraries = []
 
 	# Configuration option global/proc.
 	# Location of proc filesystem.
-	proc="/proc"
+	# This configuration option is advanced.
+	proc = "/proc"
 
 	# Configuration option global/etc.
 	# Location of /etc system configuration directory.
-	etc="@CONFDIR@"
+	etc = "@CONFDIR@"
 
 	# Configuration option global/locking_type.
 	# Type of locking to use.
@@ -655,11 +648,11 @@ global {
 	# safely because it belongs to an inaccessible domain and might be
 	# in use, for example a virtual machine image or a disk that is
 	# shared by a clustered machine.
-	locking_type=1
+	locking_type = 1
 
 	# Configuration option global/wait_for_locks.
 	# When disabled, fail if a lock request would block.
-	wait_for_locks=1
+	wait_for_locks = 1
 
 	# Configuration option global/fallback_to_clustered_locking.
 	# Attempt to use built-in cluster locking if locking_type 2 fails.
@@ -667,7 +660,7 @@ global {
 	# with this enabled, an attempt will be made to use the built-in
 	# clustered locking.
 	# If you are using a customised locking_library you should disable this.
-	fallback_to_clustered_locking=1
+	fallback_to_clustered_locking = 1
 
 	# Configuration option global/fallback_to_local_locking.
 	# Use locking_type 1 (local) if locking_type 2 or 3 fail.
@@ -677,14 +670,14 @@ global {
 	# local file-based locking (type 1). If this succeeds, only
 	# commands against local volume groups will proceed.
 	# Volume Groups marked as clustered will be ignored.
-	fallback_to_local_locking=1
+	fallback_to_local_locking = 1
 
 	# Configuration option global/locking_dir.
 	# Directory to use for LVM command file locks.
 	# Local non-LV directory that holds file-based locks
 	# while commands are in progress.  A directory like
 	# /tmp that may get wiped on reboot is OK.
-	locking_dir="@DEFAULT_LOCK_DIR@"
+	locking_dir = "@DEFAULT_LOCK_DIR@"
 
 	# Configuration option global/prioritise_write_locks.
 	# Allow quicker VG write access during high volume read access.
@@ -696,23 +689,23 @@ global {
 	# read-only requests.
 	# This option only affects locking_type 1 viz.
 	# local file-based locking.
-	prioritise_write_locks=1
+	prioritise_write_locks = 1
 
 	# Configuration option global/library_dir.
 	# Search this directory first for shared libraries.
 	# This configuration option does not have a default value defined.
-#	library_dir=""
+	# library_dir = ""
 
 	# Configuration option global/locking_library.
 	# The external locking library to use for locking_type 2.
-	locking_library="liblvm2clusterlock.so"
+	# locking_library = "liblvm2clusterlock.so"
 
 	# Configuration option global/abort_on_internal_errors.
 	# Abort a command that encounters an internal error.
 	# Treat any internal errors as fatal errors, aborting
 	# the process that encountered the internal error.
 	# Please only enable for debugging.
-	abort_on_internal_errors=0
+	abort_on_internal_errors = 0
 
 	# Configuration option global/detect_internal_vg_cache_corruption.
 	# Internal verification of VG structures.
@@ -720,7 +713,7 @@ global {
 	# used multiple times. This is useful to catch
 	# unexpected changes to cached VG structures.
 	# Please only enable for debugging.
-	detect_internal_vg_cache_corruption=0
+	detect_internal_vg_cache_corruption = 0
 
 	# Configuration option global/metadata_read_only.
 	# No operations that change on-disk metadata are permitted.
@@ -729,7 +722,7 @@ global {
 	# as if the repair had been performed (except for the unchanged
 	# vg_seqno). Inappropriate use could mess up your system,
 	# so seek advice first!
-	metadata_read_only=0
+	metadata_read_only = 0
 
 	# Configuration option global/mirror_segtype_default.
 	# The segment type used by the short mirroring option -m.
@@ -752,7 +745,7 @@ global {
 	# cluster-aware and cannot be used in a shared (active/active)
 	# fashion in a cluster.
 	# The '--type mirror|raid1' option overrides this setting.
-	mirror_segtype_default="@DEFAULT_MIRROR_SEGTYPE@"
+	mirror_segtype_default = "@DEFAULT_MIRROR_SEGTYPE@"
 
 	# Configuration option global/raid10_segtype_default.
 	# The segment type used by the -i -m combination.
@@ -768,7 +761,7 @@ global {
 	# The layering is suboptimal in terms of providing redundancy
 	# and performance. The 'raid10' option is perferred.
 	# The '--type raid10|mirror' option overrides this setting.
-	raid10_segtype_default="@DEFAULT_RAID10_SEGTYPE@"
+	raid10_segtype_default = "@DEFAULT_RAID10_SEGTYPE@"
 
 	# Configuration option global/sparse_segtype_default.
 	# The segment type used by the -V -L combination.
@@ -784,7 +777,7 @@ global {
 	# volume for metadata. It has better performance, especially
 	# when more data is used.  It also supports full snapshots.
 	# The '--type snapshot|thin' option overrides this setting.
-	sparse_segtype_default="@DEFAULT_SPARSE_SEGTYPE@"
+	sparse_segtype_default = "@DEFAULT_SPARSE_SEGTYPE@"
 
 	# Configuration option global/lvdisplay_shows_full_device_path.
 	# The default format for displaying LV names in lvdisplay was changed
@@ -792,7 +785,7 @@ global {
 	# Previously this was always shown as /dev/vgname/lvname even when that
 	# was never a valid path in the /dev filesystem.
 	# Enable this option to reinstate the previous format.
-	lvdisplay_shows_full_device_path=0
+	# lvdisplay_shows_full_device_path = 0
 
 	# Configuration option global/use_lvmetad.
 	# Use lvmetad to cache metadata and reduce disk scanning.
@@ -827,7 +820,7 @@ global {
 	# lvmetad is not compatible with locking_type 3 (clustering).
 	# LVM prints warnings and ignores lvmetad if this combination
 	# is seen.
-	use_lvmetad=0
+	use_lvmetad = 0
 
 	# Configuration option global/thin_check_executable.
 	# The full path to the thin_check command.
@@ -840,13 +833,13 @@ global {
 	# Also see thin_check_options.
 	# The thin tools are available from the package
 	# device-mapper-persistent-data.
-	thin_check_executable="@THIN_CHECK_CMD@"
+	# thin_check_executable = "@THIN_CHECK_CMD@"
 
 	# Configuration option global/thin_dump_executable.
 	# The full path to the thin_dump command.
 	# LVM uses this command to dump thin pool metadata.
 	# (For thin tools, see thin_check_executable.)
-	thin_dump_executable="@THIN_DUMP_CMD@"
+	# thin_dump_executable = "@THIN_DUMP_CMD@"
 
 	# Configuration option global/thin_repair_executable.
 	# The full path to the thin_repair command.
@@ -854,21 +847,21 @@ global {
 	# if it is in an unusable state.
 	# Also see thin_repair_options.
 	# (For thin tools, see thin_check_executable.)
-	thin_repair_executable="@THIN_REPAIR_CMD@"
+	# thin_repair_executable = "@THIN_REPAIR_CMD@"
 
 	# Configuration option global/thin_check_options.
-	# String of options passed to the thin_check command.
+	# List of options passed to the thin_check command.
 	# With thin_check version 2.1 or newer you can add
 	# --ignore-non-fatal-errors to let it pass through
 	# ignorable errors and fix them later.
 	# With thin_check version 3.2 or newer you should add
 	# --clear-needs-check-flag.
-	thin_check_options=["-q", "--clear-needs-check-flag"]
+	# thin_check_options = ["-q", "--clear-needs-check-flag"]
 
 	# Configuration option global/thin_repair_options.
-	# String of options passed to the thin_repair command.
+	# List of options passed to the thin_repair command.
 	# This configuration option does not have a default value defined.
-#	thin_repair_options=""
+	# thin_repair_options = ""
 
 	# Configuration option global/thin_disabled_features.
 	# Features to not use in the thin driver.
@@ -880,7 +873,7 @@ global {
 	# Example:
 	# thin_disabled_features = [ "discards", "block_size" ]
 	# This configuration option does not have a default value defined.
-#	thin_disabled_features=[]
+	# thin_disabled_features = []
 
 	# Configuration option global/cache_check_executable.
 	# The full path to the cache_check command.
@@ -893,13 +886,13 @@ global {
 	# Also see cache_check_options.
 	# The cache tools are available from the package
 	# device-mapper-persistent-data.
-	cache_check_executable="@CACHE_CHECK_CMD@"
+	# cache_check_executable = "@CACHE_CHECK_CMD@"
 
 	# Configuration option global/cache_dump_executable.
 	# The full path to the cache_dump command.
 	# LVM uses this command to dump cache pool metadata.
 	# (For cache tools, see cache_check_executable.)
-	cache_dump_executable="@CACHE_DUMP_CMD@"
+	# cache_dump_executable = "@CACHE_DUMP_CMD@"
 
 	# Configuration option global/cache_repair_executable.
 	# The full path to the cache_repair command.
@@ -907,16 +900,16 @@ global {
 	# if it is in an unusable state.
 	# Also see cache_repair_options.
 	# (For cache tools, see cache_check_executable.)
-	cache_repair_executable="@CACHE_REPAIR_CMD@"
+	# cache_repair_executable = "@CACHE_REPAIR_CMD@"
 
 	# Configuration option global/cache_check_options.
-	# String of options passed to the cache_check command.
-	cache_check_options="-q"
+	# List of options passed to the cache_check command.
+	# cache_check_options = "-q"
 
 	# Configuration option global/cache_repair_options.
-	# String of options passed to the cache_repair command.
+	# List of options passed to the cache_repair command.
 	# This configuration option does not have a default value defined.
-#	cache_repair_options=""
+	# cache_repair_options = ""
 
 	# Configuration option global/system_id_source.
 	# The method LVM uses to set the local system ID.
@@ -937,14 +930,14 @@ global {
 	# See 'man machine-id'.
 	# file - Use the contents of another file (system_id_file) to set
 	# the system ID.
-	system_id_source="none"
+	# system_id_source = "none"
 
 	# Configuration option global/system_id_file.
 	# The full path to the file containing a system ID.
 	# This is used when system_id_source is set to 'file'.
 	# Comments starting with the character # are ignored.
 	# This configuration option does not have a default value defined.
-#	system_id_file=""
+	# system_id_file = ""
 }
 
 # Configuration section activation.
@@ -955,7 +948,7 @@ activation {
 	# Useful for debugging problems with activation.
 	# Some of the checks may be expensive, so it's best to use
 	# this only when there seems to be a problem.
-	checks=0
+	checks = 0
 
 	# Configuration option activation/udev_sync.
 	# Use udev notifications to synchronize udev and LVM.
@@ -967,7 +960,7 @@ activation {
 	# are waiting for udev, run 'dmsetup udevcomplete_all' to
 	# wake them up.
 	# The '--nodevsync' option overrides this setting.
-	udev_sync=1
+	udev_sync = 1
 
 	# Configuration option activation/udev_rules.
 	# Use udev rules to manage LV device nodes and symlinks.
@@ -975,7 +968,7 @@ activation {
 	# symlinks for active LVs itself.
 	# Manual intervention may be required if this setting is
 	# changed while LVs are active.
-	udev_rules=1
+	udev_rules = 1
 
 	# Configuration option activation/verify_udev_operations.
 	# Use extra checks in LVM to verify udev operations.
@@ -983,7 +976,7 @@ activation {
 	# repairs) on entries in the device directory after
 	# udev has completed processing its events.
 	# Useful for diagnosing problems with LVM/udev interactions.
-	verify_udev_operations=0
+	verify_udev_operations = 0
 
 	# Configuration option activation/retry_deactivation.
 	# Retry failed LV deactivation.
@@ -991,7 +984,7 @@ activation {
 	# seconds before failing. This may happen because a
 	# process run from a quick udev rule temporarily opened
 	# the device.
-	retry_deactivation=1
+	retry_deactivation = 1
 
 	# Configuration option activation/missing_stripe_filler.
 	# Method to fill missing stripes when activating an incomplete LV.
@@ -1000,30 +993,31 @@ activation {
 	# case, that device will be used in place of missing stripes.
 	# Using anything other than 'error' with mirrored or snapshotted
 	# volumes is likely to result in data corruption.
-	missing_stripe_filler="error"
+	# This configuration option is advanced.
+	missing_stripe_filler = "error"
 
 	# Configuration option activation/use_linear_target.
 	# Use the linear target to optimize single stripe LVs.
 	# When disabled, the striped target is used. The linear
 	# target is an optimised version of the striped target
 	# that only handles a single stripe.
-	use_linear_target=1
+	use_linear_target = 1
 
 	# Configuration option activation/reserved_stack.
 	# Stack size in KB to reserve for use while devices are suspended.
 	# Insufficent reserve risks I/O deadlock during device suspension.
-	reserved_stack=64
+	reserved_stack = 64
 
 	# Configuration option activation/reserved_memory.
 	# Memory size in KB to reserve for use while devices are suspended.
 	# Insufficent reserve risks I/O deadlock during device suspension.
-	reserved_memory=8192
+	reserved_memory = 8192
 
 	# Configuration option activation/process_priority.
 	# Nice value used while devices are suspended.
 	# Use a high priority so that LVs are suspended
 	# for the shortest possible time.
-	process_priority=-18
+	process_priority = -18
 
 	# Configuration option activation/volume_list.
 	# Only LVs selected by this list are activated.
@@ -1042,7 +1036,7 @@ activation {
 	# Example:
 	# volume_list = [ "vg1", "vg2/lvol1", "@tag1", "@*" ]
 	# This configuration option does not have a default value defined.
-#	volume_list=[]
+	# volume_list = []
 
 	# Configuration option activation/auto_activation_volume_list.
 	# Only LVs selected by this list are auto-activated.
@@ -1074,7 +1068,7 @@ activation {
 	# Possible options are: vgname, vgname/lvname, @tag, @*
 	# See volume_list for how these options are matched to LVs.
 	# This configuration option does not have a default value defined.
-#	auto_activation_volume_list=[]
+	# auto_activation_volume_list = []
 
 	# Configuration option activation/read_only_volume_list.
 	# LVs in this list are activated in read-only mode.
@@ -1086,18 +1080,14 @@ activation {
 	# Possible options are: vgname, vgname/lvname, @tag, @*
 	# See volume_list for how these options are matched to LVs.
 	# This configuration option does not have a default value defined.
-#	read_only_volume_list=[]
-
-	# Configuration option activation/mirror_region_size.
-	# This has been replaced by the activation/raid_region_size setting.
-	mirror_region_size=512
+	# read_only_volume_list = []
 
 	# Configuration option activation/raid_region_size.
 	# Size in KiB of each raid or mirror synchronization region.
 	# For raid or mirror segment types, this is the amount of
 	# data that is copied at once when initializing, or moved
 	# at once by pvmove.
-	raid_region_size=512
+	raid_region_size = 512
 
 	# Configuration option activation/error_when_full.
 	# Return errors if a thin pool runs out of space.
@@ -1108,14 +1098,14 @@ activation {
 	# thin pool data space is extended.
 	# New thin pools are assigned the behavior defined here.
 	# The '--errorwhenfull y|n' option overrides this setting.
-	error_when_full=0
+	# error_when_full = 0
 
 	# Configuration option activation/readahead.
 	# Setting to use when there is no readahead setting in metadata.
 	# Possible options are: none, auto.
 	# none - Disable readahead.
 	# auto - Use default value chosen by kernel.
-	readahead="auto"
+	readahead = "auto"
 
 	# Configuration option activation/raid_fault_policy.
 	# Defines how a device failure in a RAID LV is handled.
@@ -1134,7 +1124,7 @@ activation {
 	# raid4/5, 2 for raid6, etc) the LV will remain usable.
 	# allocate - Attempt to use any extra physical volumes in the
 	# volume group as spares and replace faulty devices.
-	raid_fault_policy="warn"
+	raid_fault_policy = "warn"
 
 	# Configuration option activation/mirror_image_fault_policy.
 	# Defines how a device failure in a 'mirror' LV is handled.
@@ -1170,17 +1160,13 @@ activation {
 	# for mirror devices since it would break the redundant nature
 	# of the mirror. This policy acts like 'remove' if no suitable
 	# device and space can be allocated for the replacement.
-	mirror_image_fault_policy="remove"
+	mirror_image_fault_policy = "remove"
 
 	# Configuration option activation/mirror_log_fault_policy.
 	# Defines how a device failure in a 'mirror' log LV is handled.
 	# The mirror_image_fault_policy description for mirrored LVs
 	# also applies to mirrored log LVs.
-	mirror_log_fault_policy="allocate"
-
-	# Configuration option activation/mirror_device_fault_policy.
-	# This has been replaced by the mirror_image_fault_policy setting.
-	mirror_device_fault_policy="remove"
+	mirror_log_fault_policy = "allocate"
 
 	# Configuration option activation/snapshot_autoextend_threshold.
 	# Auto-extend a snapshot when its usage exceeds this percent.
@@ -1195,14 +1181,14 @@ activation {
 	# For a 1G snapshot, using 700M will trigger a resize to 1.2G.
 	# When the usage exceeds 840M, the snapshot will be extended
 	# to 1.44G, and so on.
-	snapshot_autoextend_threshold=100
+	snapshot_autoextend_threshold = 100
 
 	# Configuration option activation/snapshot_autoextend_percent.
 	# Auto-extending a snapshot adds this percent extra space.
 	# The amount of additional space added to a snapshot is this
 	# percent of its current size.
 	# Also see snapshot_autoextend_threshold.
-	snapshot_autoextend_percent=20
+	snapshot_autoextend_percent = 20
 
 	# Configuration option activation/thin_pool_autoextend_threshold.
 	# Auto-extend a thin pool when its usage exceeds this percent.
@@ -1217,7 +1203,7 @@ activation {
 	# For a 1G thin pool, using up 700M will trigger a resize to 1.2G.
 	# When the usage exceeds 840M, the thin pool will be extended
 	# to 1.44G, and so on.
-	thin_pool_autoextend_threshold=100
+	thin_pool_autoextend_threshold = 100
 
 	# Configuration option activation/thin_pool_autoextend_percent.
 	# Auto-extending a thin pool adds this percent extra space.
@@ -1240,21 +1226,22 @@ activation {
 	# used by the process.
 	# Example:
 	# mlock_filter = [ "locale/locale-archive", "gconv/gconv-modules.cache" ]
+	# This configuration option is advanced.
 	# This configuration option does not have a default value defined.
-#	mlock_filter=[]
+	# mlock_filter = []
 
 	# Configuration option activation/use_mlockall.
 	# Use the old behavior of mlockall to pin all memory.
 	# Prior to version 2.02.62, LVM used mlockall() to pin
 	# the whole process's memory while activating devices.
-	use_mlockall=0
+	use_mlockall = 0
 
 	# Configuration option activation/monitoring.
 	# Monitor LVs that are activated.
 	# When enabled, LVM will ask dmeventd to monitor LVs
 	# that are activated.
 	# The '--ignoremonitoring' option overrides this setting.
-	monitoring=1
+	monitoring = 1
 
 	# Configuration option activation/polling_interval.
 	# Check pvmove or lvconvert progress at this interval (seconds)
@@ -1264,7 +1251,7 @@ activation {
 	# If this is set to 0 and there is only one thing to wait for,
 	# there are no progress reports, but the process is awoken
 	# immediately once the operation is complete.
-	polling_interval=15
+	polling_interval = 15
 
 	# Configuration option activation/auto_set_activation_skip.
 	# Set the activation skip flag on new thin snapshot LVs.
@@ -1275,7 +1262,7 @@ activation {
 	# When this setting is enabled, the activation skip flag is
 	# set on new thin snapshot LVs.
 	# The '--setactivationskip y|n' option overrides this setting.
-	auto_set_activation_skip=1
+	# auto_set_activation_skip = 1
 
 	# Configuration option activation/activation_mode.
 	# How LVs with missing devices are activated.
@@ -1294,12 +1281,11 @@ activation {
 	# This setting should not normally be used, but may
 	# sometimes assist with data recovery.
 	# The '--activationmode' option overrides this setting.
-	activation_mode="degraded"
+	activation_mode = "degraded"
 }
 
 # Configuration section metadata.
-# This configuration section is advanced.
-metadata {
+# metadata {
 
 	# Configuration option metadata/pvmetadatacopies.
 	# Number of copies of metadata to store on each PV.
@@ -1311,7 +1297,7 @@ metadata {
 	# be useful with VGs containing large numbers of PVs.
 	# The '--pvmetadatacopies' option overrides this setting.
 	# This configuration option is advanced.
-	pvmetadatacopies=1
+	# pvmetadatacopies = 1
 
 	# Configuration option metadata/vgmetadatacopies.
 	# Number of copies of metadata to maintain for each VG.
@@ -1324,8 +1310,7 @@ metadata {
 	# and allows you to control which metadata areas are used at
 	# the individual PV level using 'pvchange --metadataignore y|n'.
 	# The '--vgmetadatacopies' option overrides this setting.
-	# This configuration option is advanced.
-	vgmetadatacopies=0
+	# vgmetadatacopies = 0
 
 	# Configuration option metadata/pvmetadatasize.
 	# Approximate number of sectors to use for each metadata copy.
@@ -1334,8 +1319,7 @@ metadata {
 	# metadata. The metadata areas are treated as circular buffers,
 	# so unused space becomes filled with an archive of the most
 	# recent previous versions of the metadata.
-	# This configuration option is advanced.
-	pvmetadatasize=255
+	# pvmetadatasize = 255
 
 	# Configuration option metadata/pvmetadataignore.
 	# Ignore metadata areas on a new PV.
@@ -1343,11 +1327,11 @@ metadata {
 	# metadata in them.
 	# The '--metadataignore' option overrides this setting.
 	# This configuration option is advanced.
-	pvmetadataignore=0
+	# pvmetadataignore = 0
 
 	# Configuration option metadata/stripesize.
 	# This configuration option is advanced.
-	stripesize=64
+	# stripesize = 64
 
 	# Configuration option metadata/dirs.
 	# Directories holding live copies of text format metadata.
@@ -1365,57 +1349,23 @@ metadata {
 	# dirs = [ "/etc/lvm/metadata", "/mnt/disk2/lvm/metadata2" ]
 	# This configuration option is advanced.
 	# This configuration option does not have a default value defined.
-#	dirs=[]
-
-	# Configuration section metadata/disk_areas.
-	# This configuration section is advanced.
-	# This configuration section is not officially supported.
-	# This configuration section does not have a default value defined.
-#	disk_areas {
-
-		# Configuration section metadata/disk_areas/<disk_area>.
-		# This configuration section is advanced.
-		# This configuration section is not officially supported.
-		# This configuration section has variable name.
-		# This configuration section does not have a default value defined.
-#		disk_area {
-
-			# Configuration option metadata/disk_areas/<disk_area>/start_sector.
-			# This configuration option is advanced.
-			# This configuration option is not officially supported.
-			# This configuration option does not have a default value defined.
-#			start_sector=0
-
-			# Configuration option metadata/disk_areas/<disk_area>/size.
-			# This configuration option is advanced.
-			# This configuration option is not officially supported.
-			# This configuration option does not have a default value defined.
-#			size=0
-
-			# Configuration option metadata/disk_areas/<disk_area>/id.
-			# This configuration option is advanced.
-			# This configuration option is not officially supported.
-			# This configuration option does not have a default value defined.
-#			id=""
-#		}
-#	}
-}
+	# dirs = []
+# }
 
 # Configuration section report.
 # LVM report command output formatting.
-# This configuration section is advanced.
-report {
+# report {
 
 	# Configuration option report/compact_output.
 	# Do not print empty report fields.
 	# Fields that don't have a value set for any of the rows
 	# reported are skipped and not printed. Compact output is
 	# applicable only if report/buffered is enabled.
-	compact_output=0
+	# compact_output = 0
 
 	# Configuration option report/aligned.
 	# Align columns in report output.
-	aligned=1
+	# aligned = 1
 
 	# Configuration option report/buffered.
 	# Buffer report output.
@@ -1424,130 +1374,130 @@ report {
 	# is flushed to output which normally happens at the end of command
 	# execution. Otherwise, if buffering is not used, each object is
 	# reported as soon as its processing is finished.
-	buffered=1
+	# buffered = 1
 
 	# Configuration option report/headings.
 	# Show headings for columns on report.
-	headings=1
+	# headings = 1
 
 	# Configuration option report/separator.
 	# A separator to use on report after each field.
-	separator=" "
+	# separator = " "
 
 	# Configuration option report/list_item_separator.
 	# A separator to use for list items when reported.
-	list_item_separator=","
+	# list_item_separator = ","
 
 	# Configuration option report/prefixes.
 	# Use a field name prefix for each field reported.
-	prefixes=0
+	# prefixes = 0
 
 	# Configuration option report/quoted.
 	# Quote field values when using field name prefixes.
-	quoted=1
+	# quoted = 1
 
 	# Configuration option report/colums_as_rows.
 	# Output each column as a row.
-	# If set, this also implies report/prefixes=1.
-	colums_as_rows=0
+	# If set, this also implies report/prefixes = 1.
+	# colums_as_rows = 0
 
 	# Configuration option report/binary_values_as_numeric.
 	# Use binary values 0 or 1 instead of descriptive literal values.
 	# For columns that have exactly two valid values to report
 	# (not counting the 'unknown' value which denotes that the
 	# value could not be determined).
-	binary_values_as_numeric=0
+	# binary_values_as_numeric = 0
 
 	# Configuration option report/devtypes_sort.
 	# List of columns to sort by when reporting 'lvm devtypes' command.
 	# See 'lvm devtypes -o help' for the list of possible fields.
-	devtypes_sort="devtype_name"
+	# devtypes_sort = "devtype_name"
 
 	# Configuration option report/devtypes_cols.
 	# List of columns to report for 'lvm devtypes' command.
 	# See 'lvm devtypes -o help' for the list of possible fields.
-	devtypes_cols="devtype_name,devtype_max_partitions,devtype_description"
+	# devtypes_cols = "devtype_name,devtype_max_partitions,devtype_description"
 
 	# Configuration option report/devtypes_cols_verbose.
 	# List of columns to report for 'lvm devtypes' command in verbose mode.
 	# See 'lvm devtypes -o help' for the list of possible fields.
-	devtypes_cols_verbose="devtype_name,devtype_max_partitions,devtype_description"
+	# devtypes_cols_verbose = "devtype_name,devtype_max_partitions,devtype_description"
 
 	# Configuration option report/lvs_sort.
 	# List of columns to sort by when reporting 'lvs' command.
 	# See 'lvs -o help' for the list of possible fields.
-	lvs_sort="vg_name,lv_name"
+	# lvs_sort = "vg_name,lv_name"
 
 	# Configuration option report/lvs_cols.
 	# List of columns to report for 'lvs' command.
 	# See 'lvs -o help' for the list of possible fields.
-	lvs_cols="lv_name,vg_name,lv_attr,lv_size,pool_lv,origin,data_percent,metadata_percent,move_pv,mirror_log,copy_percent,convert_lv"
+	# lvs_cols = "lv_name,vg_name,lv_attr,lv_size,pool_lv,origin,data_percent,metadata_percent,move_pv,mirror_log,copy_percent,convert_lv"
 
 	# Configuration option report/lvs_cols_verbose.
 	# List of columns to report for 'lvs' command in verbose mode.
 	# See 'lvs -o help' for the list of possible fields.
-	lvs_cols_verbose="lv_name,vg_name,seg_count,lv_attr,lv_size,lv_major,lv_minor,lv_kernel_major,lv_kernel_minor,pool_lv,origin,data_percent,metadata_percent,move_pv,copy_percent,mirror_log,convert_lv,lv_uuid,lv_profile"
+	# lvs_cols_verbose = "lv_name,vg_name,seg_count,lv_attr,lv_size,lv_major,lv_minor,lv_kernel_major,lv_kernel_minor,pool_lv,origin,data_percent,metadata_percent,move_pv,copy_percent,mirror_log,convert_lv,lv_uuid,lv_profile"
 
 	# Configuration option report/vgs_sort.
 	# List of columns to sort by when reporting 'vgs' command.
 	# See 'vgs -o help' for the list of possible fields.
-	vgs_sort="vg_name"
+	# vgs_sort = "vg_name"
 
 	# Configuration option report/vgs_cols.
 	# List of columns to report for 'vgs' command.
 	# See 'vgs -o help' for the list of possible fields.
-	vgs_cols="vg_name,pv_count,lv_count,snap_count,vg_attr,vg_size,vg_free"
+	# vgs_cols = "vg_name,pv_count,lv_count,snap_count,vg_attr,vg_size,vg_free"
 
 	# Configuration option report/vgs_cols_verbose.
 	# List of columns to report for 'vgs' command in verbose mode.
 	# See 'vgs -o help' for the list of possible fields.
-	vgs_cols_verbose="vg_name,vg_attr,vg_extent_size,pv_count,lv_count,snap_count,vg_size,vg_free,vg_uuid,vg_profile"
+	# vgs_cols_verbose = "vg_name,vg_attr,vg_extent_size,pv_count,lv_count,snap_count,vg_size,vg_free,vg_uuid,vg_profile"
 
 	# Configuration option report/pvs_sort.
 	# List of columns to sort by when reporting 'pvs' command.
 	# See 'pvs -o help' for the list of possible fields.
-	pvs_sort="pv_name"
+	# pvs_sort = "pv_name"
 
 	# Configuration option report/pvs_cols.
 	# List of columns to report for 'pvs' command.
 	# See 'pvs -o help' for the list of possible fields.
-	pvs_cols="pv_name,vg_name,pv_fmt,pv_attr,pv_size,pv_free"
+	# pvs_cols = "pv_name,vg_name,pv_fmt,pv_attr,pv_size,pv_free"
 
 	# Configuration option report/pvs_cols_verbose.
 	# List of columns to report for 'pvs' command in verbose mode.
 	# See 'pvs -o help' for the list of possible fields.
-	pvs_cols_verbose="pv_name,vg_name,pv_fmt,pv_attr,pv_size,pv_free,dev_size,pv_uuid"
+	# pvs_cols_verbose = "pv_name,vg_name,pv_fmt,pv_attr,pv_size,pv_free,dev_size,pv_uuid"
 
 	# Configuration option report/segs_sort.
 	# List of columns to sort by when reporting 'lvs --segments' command.
 	# See 'lvs --segments -o help' for the list of possible fields.
-	segs_sort="vg_name,lv_name,seg_start"
+	# segs_sort = "vg_name,lv_name,seg_start"
 
 	# Configuration option report/segs_cols.
 	# List of columns to report for 'lvs --segments' command.
 	# See 'lvs --segments  -o help' for the list of possible fields.
-	segs_cols="lv_name,vg_name,lv_attr,stripes,segtype,seg_size"
+	# segs_cols = "lv_name,vg_name,lv_attr,stripes,segtype,seg_size"
 
 	# Configuration option report/segs_cols_verbose.
 	# List of columns to report for 'lvs --segments' command in verbose mode.
 	# See 'lvs --segments -o help' for the list of possible fields.
-	segs_cols_verbose="lv_name,vg_name,lv_attr,seg_start,seg_size,stripes,segtype,stripesize,chunksize"
+	# segs_cols_verbose = "lv_name,vg_name,lv_attr,seg_start,seg_size,stripes,segtype,stripesize,chunksize"
 
 	# Configuration option report/pvsegs_sort.
 	# List of columns to sort by when reporting 'pvs --segments' command.
 	# See 'pvs --segments -o help' for the list of possible fields.
-	pvsegs_sort="pv_name,pvseg_start"
+	# pvsegs_sort = "pv_name,pvseg_start"
 
 	# Configuration option report/pvsegs_cols.
 	# List of columns to sort by when reporting 'pvs --segments' command.
 	# See 'pvs --segments -o help' for the list of possible fields.
-	pvsegs_cols="pv_name,vg_name,pv_fmt,pv_attr,pv_size,pv_free,pvseg_start,pvseg_size"
+	# pvsegs_cols = "pv_name,vg_name,pv_fmt,pv_attr,pv_size,pv_free,pvseg_start,pvseg_size"
 
 	# Configuration option report/pvsegs_cols_verbose.
 	# List of columns to sort by when reporting 'pvs --segments' command in verbose mode.
 	# See 'pvs --segments -o help' for the list of possible fields.
-	pvsegs_cols_verbose="pv_name,vg_name,pv_fmt,pv_attr,pv_size,pv_free,pvseg_start,pvseg_size,lv_name,seg_start_pe,segtype,seg_pe_ranges"
-}
+	# pvsegs_cols_verbose = "pv_name,vg_name,pv_fmt,pv_attr,pv_size,pv_free,pvseg_start,pvseg_size,lv_name,seg_start_pe,segtype,seg_pe_ranges"
+# }
 
 # Configuration section dmeventd.
 # Settings for the LVM event daemon.
@@ -1559,10 +1509,10 @@ dmeventd {
 	# failures.  It removes failed devices from a volume group and
 	# reconfigures a mirror as necessary. If no mirror library is
 	# provided, mirrors are not monitored through dmeventd.
-	mirror_library="libdevmapper-event-lvm2mirror.so"
+	mirror_library = "libdevmapper-event-lvm2mirror.so"
 
 	# Configuration option dmeventd/raid_library.
-	raid_library="libdevmapper-event-lvm2raid.so"
+	# raid_library = "libdevmapper-event-lvm2raid.so"
 
 	# Configuration option dmeventd/snapshot_library.
 	# The library dmeventd uses when monitoring a snapshot device.
@@ -1570,7 +1520,7 @@ dmeventd {
 	# snapshots and emits a warning through syslog when the usage
 	# exceeds 80%. The warning is repeated when 85%, 90% and
 	# 95% of the snapshot is filled.
-	snapshot_library="libdevmapper-event-lvm2snapshot.so"
+	snapshot_library = "libdevmapper-event-lvm2snapshot.so"
 
 	# Configuration option dmeventd/thin_library.
 	# The library dmeventd uses when monitoring a thin device.
@@ -1578,21 +1528,21 @@ dmeventd {
 	# a pool and emits a warning through syslog when the usage
 	# exceeds 80%. The warning is repeated when 85%, 90% and
 	# 95% of the pool is filled.
-	thin_library="libdevmapper-event-lvm2thin.so"
+	thin_library = "libdevmapper-event-lvm2thin.so"
 
 	# Configuration option dmeventd/executable.
 	# The full path to the dmeventd binary.
-	executable="@DMEVENTD_PATH@"
+	# executable = "@DMEVENTD_PATH@"
 }
 
 # Configuration section tags.
 # Host tag settings.
-tags {
+# tags {
 
 	# Configuration option tags/hosttags.
 	# Create a host tag using the machine name.
 	# The machine name is nodename returned by uname(2).
-	hosttags=0
+	# hosttags = 0
 
 	# Configuration section tags/<tag>.
 	# Replace this subsection name with a custom tag name.
@@ -1611,7 +1561,7 @@ tags {
 	# tags { foo { } bar { host_list = [ "machine1", "machine2" ] } }
 	# This configuration section has variable name.
 	# This configuration section does not have a default value defined.
-#	tag {
+	# tag {
 
 		# Configuration option tags/<tag>/host_list.
 		# A list of machine names.
@@ -1620,6 +1570,6 @@ tags {
 		# matches an entry in this list, the name of the
 		# subsection is applied to the machine as a 'host tag'.
 		# This configuration option does not have a default value defined.
-#		host_list=""
-#	}
-}
+		# host_list = ""
+	# }
+# }
diff --git a/conf/lvmlocal.conf.in b/conf/lvmlocal.conf.in
index 23689e8..e151b50 100644
--- a/conf/lvmlocal.conf.in
+++ b/conf/lvmlocal.conf.in
@@ -37,7 +37,7 @@ local {
 	# Set the system_id to the string 'host1'.
 	# system_id = "host1"
 	# This configuration option does not have a default value defined.
-#	system_id=""
+	# system_id=""
 
 	# Configuration option local/extra_system_ids.
 	# A list of extra VG system IDs the local host can access.
@@ -49,5 +49,5 @@ local {
 	# Use this only after consulting 'man lvmsystemid'
 	# to be certain of correct usage and possible dangers.
 	# This configuration option does not have a default value defined.
-#	extra_system_ids=[]
+	# extra_system_ids=[]
 }


