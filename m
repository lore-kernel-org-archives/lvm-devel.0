From: Marian Csontos <mcsontos@sourceware.org>
Date: Fri,  6 Aug 2021 12:03:23 +0000 (GMT)
Subject: dev-next - make: generate
Message-ID: <20210806120323.90CD4383D80F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d99be296539e8c6ea38ab80677d267df6d4f9c65
Commit:        d99be296539e8c6ea38ab80677d267df6d4f9c65
Parent:        7b87ffce2a5d635fb10bde3477847339b0ebb776
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Fri Aug 6 13:23:11 2021 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Fri Aug 6 13:23:11 2021 +0200

make: generate

---
 conf/example.conf.in         | 278 ++++++++++++++++++++++++++++---------------
 man/lvchange.8_pregen        |  14 +++
 man/lvconvert.8_pregen       |  14 +++
 man/lvcreate.8_pregen        |  14 +++
 man/lvdisplay.8_pregen       |  12 ++
 man/lvextend.8_pregen        |  14 +++
 man/lvm-fullreport.8_pregen  |  12 ++
 man/lvm-lvpoll.8_pregen      |  12 ++
 man/lvmconfig.8_pregen       |  12 ++
 man/lvmdevices.8_pregen      |  14 +++
 man/lvmdiskscan.8_pregen     |  12 ++
 man/lvreduce.8_pregen        |  12 ++
 man/lvremove.8_pregen        |  12 ++
 man/lvrename.8_pregen        |  12 ++
 man/lvresize.8_pregen        |  14 +++
 man/lvs.8_pregen             |  12 ++
 man/lvscan.8_pregen          |  12 ++
 man/pvchange.8_pregen        |  12 ++
 man/pvck.8_pregen            |  14 +++
 man/pvcreate.8_pregen        |  12 ++
 man/pvdisplay.8_pregen       |  12 ++
 man/pvmove.8_pregen          |  12 ++
 man/pvremove.8_pregen        |  12 ++
 man/pvresize.8_pregen        |  12 ++
 man/pvs.8_pregen             |  12 ++
 man/pvscan.8_pregen          | 214 ++++++++++++++++++++++++++++++++-
 man/vgcfgbackup.8_pregen     |  12 ++
 man/vgcfgrestore.8_pregen    |  14 +++
 man/vgchange.8_pregen        |  14 +++
 man/vgck.8_pregen            |  12 ++
 man/vgconvert.8_pregen       |  12 ++
 man/vgcreate.8_pregen        |  12 ++
 man/vgdisplay.8_pregen       |  12 ++
 man/vgexport.8_pregen        |  12 ++
 man/vgextend.8_pregen        |  12 ++
 man/vgimport.8_pregen        |  12 ++
 man/vgimportclone.8_pregen   |  12 ++
 man/vgimportdevices.8_pregen |  12 ++
 man/vgmerge.8_pregen         |  12 ++
 man/vgmknodes.8_pregen       |  12 ++
 man/vgreduce.8_pregen        |  14 +++
 man/vgremove.8_pregen        |  12 ++
 man/vgrename.8_pregen        |  12 ++
 man/vgs.8_pregen             |  12 ++
 man/vgscan.8_pregen          |  12 ++
 man/vgsplit.8_pregen         |  12 ++
 46 files changed, 936 insertions(+), 104 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index 50cf6f42b..df6174bb6 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -33,15 +33,18 @@ config {
 	# any configuration mismatch is ignored and the default value is used
 	# without any warning (a message about the configuration key not being
 	# found is issued in verbose mode only).
-	checks = 1
+	# This configuration option has an automatic default value.
+	# checks = 1
 
 	# Configuration option config/abort_on_errors.
 	# Abort the LVM process if a configuration mismatch is found.
-	abort_on_errors = 0
+	# This configuration option has an automatic default value.
+	# abort_on_errors = 0
 
 	# Configuration option config/profile_dir.
 	# Directory where LVM looks for configuration profiles.
-	profile_dir = "@DEFAULT_SYS_DIR@/@DEFAULT_PROFILE_SUBDIR@"
+	# This configuration option has an automatic default value.
+	# profile_dir = "@DEFAULT_SYS_DIR@/@DEFAULT_PROFILE_SUBDIR@"
 }
 
 # Configuration section devices.
@@ -52,12 +55,14 @@ devices {
 	# Directory in which to create volume group device nodes.
 	# Commands also accept this as a prefix on volume group names.
 	# This configuration option is advanced.
-	dir = "/dev"
+	# This configuration option has an automatic default value.
+	# dir = "/dev"
 
 	# Configuration option devices/scan.
 	# Directories containing device nodes to use with LVM.
 	# This configuration option is advanced.
-	scan = [ "/dev" ]
+	# This configuration option has an automatic default value.
+	# scan = [ "/dev" ]
 
 	# Configuration option devices/obtain_device_list_from_udev.
 	# Obtain the list of available devices from udev.
@@ -67,26 +72,16 @@ devices {
 	# setting applies only to the udev-managed device directory; other
 	# directories will be scanned fully. LVM needs to be compiled with
 	# udev support for this setting to apply.
-	obtain_device_list_from_udev = 1
+	# This configuration option has an automatic default value.
+	# obtain_device_list_from_udev = 0
 
 	# Configuration option devices/external_device_info_source.
-	# Select an external device information source.
-	# Some information may already be available in the system and LVM can
-	# use this information to determine the exact type or use of devices it
-	# processes. Using an existing external device information source can
-	# speed up device processing as LVM does not need to run its own native
-	# routines to acquire this information. For example, this information
-	# is used to drive LVM filtering like MD component detection, multipath
-	# component detection, partition detection and others.
-	#
-	# Accepted values:
-	#   none
-	#     No external device information source is used.
-	#   udev
-	#     Reuse existing udev database records. Applicable only if LVM is
-	#     compiled with udev support.
-	#
-	external_device_info_source = "none"
+	# Enable device information from udev.
+	# If set to "udev", lvm will supplement its own native device information
+	# with information from libudev. This can potentially improve the detection
+	# of MD component devices and multipath component devices.
+	# This configuration option has an automatic default value.
+	# external_device_info_source = "none"
 
 	# Configuration option devices/hints.
 	# Use a local file to remember which devices have PVs on them.
@@ -131,7 +126,7 @@ devices {
 	# be used, regardless of this setting, when the --devicesfile
 	# option is set to a specific file name.
 	# This configuration option has an automatic default value.
-	# use_devicesfile = 0
+	# use_devicesfile = 1
 
 	# Configuration option devices/devicesfile.
 	# The name of the system devices file, listing devices that LVM should use.
@@ -212,7 +207,8 @@ devices {
 	# Restrict device scanning to block devices appearing in sysfs.
 	# This is a quick way of filtering out block devices that are not
 	# present on the system. sysfs must be part of the kernel and mounted.)
-	sysfs_scan = 1
+	# This configuration option has an automatic default value.
+	# sysfs_scan = 1
 
 	# Configuration option devices/scan_lvs.
 	# Scan LVM LVs for layered PVs, allowing LVs to be used as PVs.
@@ -226,11 +222,19 @@ devices {
 	# use PVs that exist on LVs, and will not allow a PV to be created on
 	# an LV. The LVs are ignored using a built in device filter that
 	# identifies and excludes LVs.
-	scan_lvs = 0
+	# This configuration option has an automatic default value.
+	# scan_lvs = 0
 
 	# Configuration option devices/multipath_component_detection.
 	# Ignore devices that are components of DM multipath devices.
-	multipath_component_detection = 1
+	# This configuration option has an automatic default value.
+	# multipath_component_detection = 1
+
+	# Configuration option devices/multipath_wwids_file.
+	# The path to the multipath wwids file used for multipath component detection.
+	# Set this to an empty string to disable the use of the multipath wwids file.
+	# This configuration option has an automatic default value.
+	# multipath_wwids_file = "/etc/multipath/wwids"
 
 	# Configuration option devices/md_component_detection.
 	# Enable detection and exclusion of MD component devices.
@@ -241,7 +245,8 @@ devices {
 	# In cases where the MD superblock is located at the end of the
 	# component devices, it is more difficult for LVM to consistently
 	# identify an MD component, see the md_component_checks setting.
-	md_component_detection = 1
+	# This configuration option has an automatic default value.
+	# md_component_detection = 1
 
 	# Configuration option devices/md_component_checks.
 	# The checks LVM should use to detect MD component devices.
@@ -265,7 +270,8 @@ devices {
 	# Ignore devices that are components of firmware RAID devices.
 	# LVM must use an external_device_info_source other than none for this
 	# detection to execute.
-	fw_raid_component_detection = 0
+	# This configuration option has an automatic default value.
+	# fw_raid_component_detection = 0
 
 	# Configuration option devices/md_chunk_alignment.
 	# Align the start of a PV data area with md device's stripe-width.
@@ -274,7 +280,8 @@ devices {
 	# with the value detected for this setting.
 	# This setting is overridden by data_alignment_detection,
 	# data_alignment, and the --dataalignment option.
-	md_chunk_alignment = 1
+	# This configuration option has an automatic default value.
+	# md_chunk_alignment = 1
 
 	# Configuration option devices/default_data_alignment.
 	# Align the start of a PV data area with this number of MiB.
@@ -297,7 +304,8 @@ devices {
 	# if they are not aligned with the value detected for this setting.
 	# This setting is overridden by data_alignment and the --dataalignment
 	# option.
-	data_alignment_detection = 1
+	# This configuration option has an automatic default value.
+	# data_alignment_detection = 1
 
 	# Configuration option devices/data_alignment.
 	# Align the start of a PV data area with this number of KiB.
@@ -305,7 +313,8 @@ devices {
 	# Set to 0 to disable, in which case default_data_alignment
 	# is used to align the first PE in units of MiB.
 	# This setting is overridden by the --dataalignment option.
-	data_alignment = 0
+	# This configuration option has an automatic default value.
+	# data_alignment = 0
 
 	# Configuration option devices/data_alignment_offset_detection.
 	# Shift the start of an aligned PV data area based on sysfs information.
@@ -316,13 +325,15 @@ devices {
 	# is the lowest aligned logical block, the 4KiB sectors start at
 	# LBA -1, and consequently sector 63 is aligned on a 4KiB boundary).
 	# This setting is overridden by the --dataalignmentoffset option.
-	data_alignment_offset_detection = 1
+	# This configuration option has an automatic default value.
+	# data_alignment_offset_detection = 1
 
 	# Configuration option devices/ignore_suspended_devices.
 	# Ignore DM devices that have I/O suspended while scanning devices.
 	# Otherwise, LVM waits for a suspended device to become accessible.
 	# This should only be needed in recovery situations.
-	ignore_suspended_devices = 0
+	# This configuration option has an automatic default value.
+	# ignore_suspended_devices = 0
 
 	# Configuration option devices/ignore_lvm_mirrors.
 	# Do not scan 'mirror' LVs to avoid possible deadlocks.
@@ -341,18 +352,21 @@ devices {
 	# a scan of the mirror's labels. The 'mirror' scanning problems do not
 	# apply to LVM RAID types like 'raid1' which handle failures in a
 	# different way, making them a better choice for VG stacking.
-	ignore_lvm_mirrors = 1
+	# This configuration option has an automatic default value.
+	# ignore_lvm_mirrors = 1
 
 	# Configuration option devices/require_restorefile_with_uuid.
 	# Allow use of pvcreate --uuid without requiring --restorefile.
-	require_restorefile_with_uuid = 1
+	# This configuration option has an automatic default value.
+	# require_restorefile_with_uuid = 1
 
 	# Configuration option devices/pv_min_size.
 	# Minimum size in KiB of block devices which can be used as PVs.
 	# In a clustered environment all nodes must use the same value.
 	# Any value smaller than 512KiB is ignored. The previous built-in
 	# value was 512.
-	pv_min_size = 2048
+	# This configuration option has an automatic default value.
+	# pv_min_size = 2048
 
 	# Configuration option devices/issue_discards.
 	# Issue discards to PVs that are no longer used by an LV.
@@ -365,7 +379,8 @@ devices {
 	# benefit from discards, but SSDs and thinly provisioned LUNs
 	# generally do. If enabled, discards will only be issued if both the
 	# storage and kernel provide support.
-	issue_discards = 0
+	# This configuration option has an automatic default value.
+	# issue_discards = 0
 
 	# Configuration option devices/allow_changes_with_duplicate_pvs.
 	# Allow VG modification while a PV appears on multiple devices.
@@ -378,13 +393,15 @@ devices {
 	# or activating LVs in it while a PV appears on multiple devices.
 	# Enabling this setting allows the VG to be used as usual even with
 	# uncertain devices.
-	allow_changes_with_duplicate_pvs = 0
+	# This configuration option has an automatic default value.
+	# allow_changes_with_duplicate_pvs = 0
 
 	# Configuration option devices/allow_mixed_block_sizes.
 	# Allow PVs in the same VG with different logical block sizes.
 	# When allowed, the user is responsible to ensure that an LV is
 	# using PVs with matching block sizes when necessary.
-	allow_mixed_block_sizes = 0
+	# This configuration option has an automatic default value.
+	# allow_mixed_block_sizes = 0
 }
 
 # Configuration section allocation.
@@ -416,7 +433,8 @@ allocation {
 	# policies to detect more situations where data can be grouped onto
 	# the same disks. This setting can be used to disable the changes
 	# and revert to the previous algorithm.
-	maximise_cling = 1
+	# This configuration option has an automatic default value.
+	# maximise_cling = 1
 
 	# Configuration option allocation/use_blkid_wiping.
 	# Use blkid to detect and erase existing signatures on new PVs and LVs.
@@ -426,7 +444,8 @@ allocation {
 	# code is currently able to recognize: MD device signatures,
 	# swap signature, and LUKS signatures. To see the list of signatures
 	# recognized by blkid, check the output of the 'blkid -k' command.
-	use_blkid_wiping = @DEFAULT_USE_BLKID_WIPING@
+	# This configuration option has an automatic default value.
+	# use_blkid_wiping = @DEFAULT_USE_BLKID_WIPING@
 
 	# Configuration option allocation/wipe_signatures_when_zeroing_new_lvs.
 	# Look for and erase any signatures while zeroing a new LV.
@@ -443,12 +462,14 @@ allocation {
 	# use_blkid_wiping.) Wiping each detected signature must be confirmed.
 	# When this setting is disabled, signatures on new LVs are not detected
 	# or erased unless the --wipesignatures option is used directly.
-	wipe_signatures_when_zeroing_new_lvs = 1
+	# This configuration option has an automatic default value.
+	# wipe_signatures_when_zeroing_new_lvs = 1
 
 	# Configuration option allocation/mirror_logs_require_separate_pvs.
 	# Mirror logs and images will always use different PVs.
 	# The default setting changed in version 2.02.85.
-	mirror_logs_require_separate_pvs = 0
+	# This configuration option has an automatic default value.
+	# mirror_logs_require_separate_pvs = 0
 
 	# Configuration option allocation/raid_stripe_all_devices.
 	# Stripe across all PVs when RAID stripes are not specified.
@@ -795,7 +816,8 @@ log {
 
 	# Configuration option log/verbose.
 	# Controls the messages sent to stdout or stderr.
-	verbose = 0
+	# This configuration option has an automatic default value.
+	# verbose = 0
 
 	# Configuration option log/silent.
 	# Suppress all non-essential messages from stdout.
@@ -806,25 +828,37 @@ log {
 	# for syslog and lvm2_log_fn purposes.
 	# Any 'yes' or 'no' questions not overridden by other arguments are
 	# suppressed and default to 'no'.
-	silent = 0
+	# This configuration option has an automatic default value.
+	# silent = 0
 
 	# Configuration option log/syslog.
 	# Send log messages through syslog.
-	syslog = 1
+	# This configuration option has an automatic default value.
+	# syslog = 1
 
 	# Configuration option log/file.
 	# Write error and debug log messages to a file specified here.
 	# This configuration option does not have a default value defined.
 
+	# Configuration option log/journal.
+	# Record lvm information in the systemd journal.
+	# command: record commands that are run.
+	# output: record default output from commands.
+	# debug: record debug messages from commands.
+	# This configuration option has an automatic default value.
+	# journal = [ ]
+
 	# Configuration option log/overwrite.
 	# Overwrite the log file each time the program is run.
-	overwrite = 0
+	# This configuration option has an automatic default value.
+	# overwrite = 0
 
 	# Configuration option log/level.
 	# The level of log messages that are sent to the log file or syslog.
 	# There are 6 syslog-like log levels currently in use: 2 to 7 inclusive.
 	# 7 is the most verbose (LOG_DEBUG).
-	level = 0
+	# This configuration option has an automatic default value.
+	# level = 0
 
 	# Configuration option log/indent.
 	# Indent messages according to their severity.
@@ -833,7 +867,8 @@ log {
 
 	# Configuration option log/command_names.
 	# Display the command name on each line of output.
-	command_names = 0
+	# This configuration option has an automatic default value.
+	# command_names = 0
 
 	# Configuration option log/prefix.
 	# A prefix to use before the log message text.
@@ -841,12 +876,14 @@ log {
 	# Two spaces allows you to see/grep the severity of each message.
 	# To make the messages look similar to the original LVM tools use:
 	# indent = 0, command_names = 1, prefix = " -- "
-	prefix = "  "
+	# This configuration option has an automatic default value.
+	# prefix = "  "
 
 	# Configuration option log/activation.
 	# Log messages during activation.
 	# Don't use this in low memory situations (can deadlock).
-	activation = 0
+	# This configuration option has an automatic default value.
+	# activation = 0
 
 	# Configuration option log/debug_classes.
 	# Select log messages by class.
@@ -854,7 +891,8 @@ log {
 	# debug output if the class is listed here. Classes currently
 	# available: memory, devices, io, activation, allocation,
 	# metadata, cache, locking, lvmpolld. Use "all" to see everything.
-	debug_classes = [ "memory", "devices", "io", "activation", "allocation", "metadata", "cache", "locking", "lvmpolld", "dbus" ]
+	# This configuration option has an automatic default value.
+	# debug_classes = [ "memory", "devices", "io", "activation", "allocation", "metadata", "cache", "locking", "lvmpolld", "dbus" ]
 
 	# Configuration option log/debug_file_fields.
 	# The fields included in debug output written to log file.
@@ -881,30 +919,36 @@ backup {
 	# Configuration option backup/backup.
 	# Maintain a backup of the current metadata configuration.
 	# Think very hard before turning this off!
-	backup = 1
+	# This configuration option has an automatic default value.
+	# backup = 1
 
 	# Configuration option backup/backup_dir.
 	# Location of the metadata backup files.
 	# Remember to back up this directory regularly!
-	backup_dir = "@DEFAULT_SYS_DIR@/@DEFAULT_BACKUP_SUBDIR@"
+	# This configuration option has an automatic default value.
+	# backup_dir = "@DEFAULT_SYS_DIR@/@DEFAULT_BACKUP_SUBDIR@"
 
 	# Configuration option backup/archive.
 	# Maintain an archive of old metadata configurations.
 	# Think very hard before turning this off.
-	archive = 1
+	# This configuration option has an automatic default value.
+	# archive = 1
 
 	# Configuration option backup/archive_dir.
 	# Location of the metdata archive files.
 	# Remember to back up this directory regularly!
-	archive_dir = "@DEFAULT_SYS_DIR@/@DEFAULT_ARCHIVE_SUBDIR@"
+	# This configuration option has an automatic default value.
+	# archive_dir = "@DEFAULT_SYS_DIR@/@DEFAULT_ARCHIVE_SUBDIR@"
 
 	# Configuration option backup/retain_min.
 	# Minimum number of archives to keep.
-	retain_min = 10
+	# This configuration option has an automatic default value.
+	# retain_min = 10
 
 	# Configuration option backup/retain_days.
 	# Minimum number of days to keep archive files.
-	retain_days = 30
+	# This configuration option has an automatic default value.
+	# retain_days = 30
 }
 
 # Configuration section shell.
@@ -913,7 +957,8 @@ shell {
 
 	# Configuration option shell/history_size.
 	# Number of lines of history to store in ~/.lvm_history.
-	history_size = 100
+	# This configuration option has an automatic default value.
+	# history_size = 100
 }
 
 # Configuration section global.
@@ -923,16 +968,19 @@ global {
 	# Configuration option global/umask.
 	# The file creation mask for any files and directories created.
 	# Interpreted as octal if the first digit is zero.
-	umask = 077
+	# This configuration option has an automatic default value.
+	# umask = 077
 
 	# Configuration option global/test.
 	# No on-disk metadata changes will be made in test mode.
 	# Equivalent to having the -t option on every command.
-	test = 0
+	# This configuration option has an automatic default value.
+	# test = 0
 
 	# Configuration option global/units.
 	# Default value for --units argument.
-	units = "r"
+	# This configuration option has an automatic default value.
+	# units = "r"
 
 	# Configuration option global/si_unit_consistency.
 	# Distinguish between powers of 1024 and 1000 bytes.
@@ -940,13 +988,15 @@ global {
 	# e.g. KiB, MiB, GiB, and powers of 1000 bytes, e.g. KB, MB, GB.
 	# If scripts depend on the old behaviour, disable this setting
 	# temporarily until they are updated.
-	si_unit_consistency = 1
+	# This configuration option has an automatic default value.
+	# si_unit_consistency = 1
 
 	# Configuration option global/suffix.
 	# Display unit suffix for sizes.
 	# This setting has no effect if the units are in human-readable form
 	# (global/units = "h") in which case the suffix is always displayed.
-	suffix = 1
+	# This configuration option has an automatic default value.
+	# suffix = 1
 
 	# Configuration option global/activation.
 	# Enable/disable communication with the kernel device-mapper.
@@ -954,26 +1004,31 @@ global {
 	# activating any logical volumes. If the device-mapper driver
 	# is not present in the kernel, disabling this should suppress
 	# the error messages.
-	activation = 1
+	# This configuration option has an automatic default value.
+	# activation = 1
 
 	# Configuration option global/proc.
 	# Location of proc filesystem.
 	# This configuration option is advanced.
-	proc = "/proc"
+	# This configuration option has an automatic default value.
+	# proc = "/proc"
 
 	# Configuration option global/etc.
 	# Location of /etc system configuration directory.
-	etc = "@CONFDIR@"
+	# This configuration option has an automatic default value.
+	# etc = "@CONFDIR@"
 
 	# Configuration option global/wait_for_locks.
 	# When disabled, fail if a lock request would block.
-	wait_for_locks = 1
+	# This configuration option has an automatic default value.
+	# wait_for_locks = 1
 
 	# Configuration option global/locking_dir.
 	# Directory to use for LVM command file locks.
 	# Local non-LV directory that holds file-based locks while commands are
 	# in progress. A directory like /tmp that may get wiped on reboot is OK.
-	locking_dir = "@DEFAULT_LOCK_DIR@"
+	# This configuration option has an automatic default value.
+	# locking_dir = "@DEFAULT_LOCK_DIR@"
 
 	# Configuration option global/prioritise_write_locks.
 	# Allow quicker VG write access during high volume read access.
@@ -982,7 +1037,8 @@ global {
 	# requests immediately, delay them to allow the read-write requests to
 	# be serviced. Without this setting, write access may be stalled by a
 	# high volume of read-only requests. This option only affects file locks.
-	prioritise_write_locks = 1
+	# This configuration option has an automatic default value.
+	# prioritise_write_locks = 1
 
 	# Configuration option global/library_dir.
 	# Search this directory first for shared libraries.
@@ -992,7 +1048,8 @@ global {
 	# Abort a command that encounters an internal error.
 	# Treat any internal errors as fatal errors, aborting the process that
 	# encountered the internal error. Please only enable for debugging.
-	abort_on_internal_errors = 0
+	# This configuration option has an automatic default value.
+	# abort_on_internal_errors = 0
 
 	# Configuration option global/metadata_read_only.
 	# No operations that change on-disk metadata are permitted.
@@ -1000,7 +1057,8 @@ global {
 	# repair will still be allowed to proceed exactly as if the repair had
 	# been performed (except for the unchanged vg_seqno). Inappropriate
 	# use could mess up your system, so seek advice first!
-	metadata_read_only = 0
+	# This configuration option has an automatic default value.
+	# metadata_read_only = 0
 
 	# Configuration option global/mirror_segtype_default.
 	# The segment type used by the short mirroring option -m.
@@ -1026,7 +1084,8 @@ global {
 	#     cluster-aware and cannot be used in a shared (active/active)
 	#     fashion in a cluster.
 	#
-	mirror_segtype_default = "@DEFAULT_MIRROR_SEGTYPE@"
+	# This configuration option has an automatic default value.
+	# mirror_segtype_default = "@DEFAULT_MIRROR_SEGTYPE@"
 
 	# Configuration option global/support_mirrored_mirror_log.
 	# Enable mirrored 'mirror' log type for testing.
@@ -1056,7 +1115,8 @@ global {
 	#     effectively creating a RAID 0+1 array. The layering is suboptimal
 	#     in terms of providing redundancy and performance.
 	#
-	raid10_segtype_default = "@DEFAULT_RAID10_SEGTYPE@"
+	# This configuration option has an automatic default value.
+	# raid10_segtype_default = "@DEFAULT_RAID10_SEGTYPE@"
 
 	# Configuration option global/sparse_segtype_default.
 	# The segment type used by the -V -L combination.
@@ -1076,7 +1136,8 @@ global {
 	#     metadata. It has better performance, especially when more data
 	#     is used. It also supports full snapshots.
 	#
-	sparse_segtype_default = "@DEFAULT_SPARSE_SEGTYPE@"
+	# This configuration option has an automatic default value.
+	# sparse_segtype_default = "@DEFAULT_SPARSE_SEGTYPE@"
 
 	# Configuration option global/lvdisplay_shows_full_device_path.
 	# Enable this to reinstate the previous lvdisplay name format.
@@ -1111,7 +1172,8 @@ global {
 	# Applicable only if LVM is compiled with lockd support in which
 	# case there is also lvmlockd(8) man page available for more
 	# information.
-	use_lvmlockd = 0
+	# This configuration option has an automatic default value.
+	# use_lvmlockd = 0
 
 	# Configuration option global/lvmlockd_lock_retries.
 	# Retry lvmlockd lock requests this many times.
@@ -1284,15 +1346,18 @@ global {
 	#   uname
 	#     Set the system ID from the hostname (uname) of the system.
 	#     System IDs beginning localhost are not permitted.
+	#   appmachineid
+	#     Use an LVM-specific derivation of the local machine-id as the
+	#     system ID. See 'man machine-id'.
 	#   machineid
-	#     Use the contents of the machine-id file to set the system ID.
-	#     Some systems create this file at installation time.
-	#     See 'man machine-id' and global/etc.
+	#     Use the contents of the machine-id file to set the system ID
+	#     (appmachineid is recommended.)
 	#   file
 	#     Use the contents of another file (system_id_file) to set the
 	#     system ID.
 	#
-	system_id_source = "none"
+	# This configuration option has an automatic default value.
+	# system_id_source = "none"
 
 	# Configuration option global/system_id_file.
 	# The full path to the file containing a system ID.
@@ -1312,13 +1377,15 @@ global {
 	# and to use its own control group. When this option is disabled, LVM
 	# commands will supervise long running operations by forking themselves.
 	# Applicable only if LVM is compiled with lvmpolld support.
-	use_lvmpolld = @DEFAULT_USE_LVMPOLLD@
+	# This configuration option has an automatic default value.
+	# use_lvmpolld = @DEFAULT_USE_LVMPOLLD@
 
 	# Configuration option global/notify_dbus.
 	# Enable D-Bus notification from LVM commands.
 	# When enabled, an LVM command that changes PVs, changes VG metadata,
 	# or changes the activation state of an LV will send a notification.
-	notify_dbus = 1
+	# This configuration option has an automatic default value.
+	# notify_dbus = 1
 
 	# Configuration option global/io_memory_size.
 	# The amount of memory in KiB that LVM allocates to perform disk io.
@@ -1339,7 +1406,8 @@ activation {
 	# Useful for debugging problems with activation. Some of the checks may
 	# be expensive, so it's best to use this only when there seems to be a
 	# problem.
-	checks = 0
+	# This configuration option has an automatic default value.
+	# checks = 0
 
 	# Configuration option activation/udev_sync.
 	# Use udev notifications to synchronize udev and LVM.
@@ -1350,14 +1418,16 @@ activation {
 	# that ignore the devices LVM creates. If enabled when udev is not
 	# running, and LVM processes are waiting for udev, run the command
 	# 'dmsetup udevcomplete_all' to wake them up.
-	udev_sync = 1
+	# This configuration option has an automatic default value.
+	# udev_sync = 1
 
 	# Configuration option activation/udev_rules.
 	# Use udev rules to manage LV device nodes and symlinks.
 	# When disabled, LVM will manage the device nodes and symlinks for
 	# active LVs itself. Manual intervention may be required if this
 	# setting is changed while LVs are active.
-	udev_rules = 1
+	# This configuration option has an automatic default value.
+	# udev_rules = 1
 
 	# Configuration option activation/verify_udev_operations.
 	# Use extra checks in LVM to verify udev operations.
@@ -1372,7 +1442,8 @@ activation {
 	# If LV deactivation fails, LVM will retry for a few seconds before
 	# failing. This may happen because a process run from a quick udev rule
 	# temporarily opened the device.
-	retry_deactivation = 1
+	# This configuration option has an automatic default value.
+	# retry_deactivation = 1
 
 	# Configuration option activation/missing_stripe_filler.
 	# Method to fill missing stripes when activating an incomplete LV.
@@ -1383,7 +1454,8 @@ activation {
 	# other than 'error' with mirrored or snapshotted volumes is likely to
 	# result in data corruption.
 	# This configuration option is advanced.
-	missing_stripe_filler = "error"
+	# This configuration option has an automatic default value.
+	# missing_stripe_filler = "error"
 
 	# Configuration option activation/use_linear_target.
 	# Use the linear target to optimize single stripe LVs.
@@ -1505,7 +1577,8 @@ activation {
 	# The clean/dirty state of data is tracked for each region.
 	# The value is rounded down to a power of two if necessary, and
 	# is ignored if it is not a multiple of the machine memory page size.
-	raid_region_size = 2048
+	# This configuration option has an automatic default value.
+	# raid_region_size = 2048
 
 	# Configuration option activation/error_when_full.
 	# Return errors if a thin pool runs out of space.
@@ -1550,7 +1623,8 @@ activation {
 	#     Attempt to use any extra physical volumes in the VG as spares and
 	#     replace faulty devices.
 	#
-	raid_fault_policy = "warn"
+	# This configuration option has an automatic default value.
+	# raid_fault_policy = "warn"
 
 	# Configuration option activation/mirror_image_fault_policy.
 	# Defines how a device failure in a 'mirror' LV is handled.
@@ -1587,13 +1661,15 @@ activation {
 	#     'remove' if no suitable device and space can be allocated for the
 	#     replacement.
 	#
-	mirror_image_fault_policy = "remove"
+	# This configuration option has an automatic default value.
+	# mirror_image_fault_policy = "remove"
 
 	# Configuration option activation/mirror_log_fault_policy.
 	# Defines how a device failure in a 'mirror' log LV is handled.
 	# The mirror_image_fault_policy description for mirrored LVs also
 	# applies to mirrored log LVs.
-	mirror_log_fault_policy = "allocate"
+	# This configuration option has an automatic default value.
+	# mirror_log_fault_policy = "allocate"
 
 	# Configuration option activation/snapshot_autoextend_threshold.
 	# Auto-extend a snapshot when its usage exceeds this percent.
@@ -1608,7 +1684,8 @@ activation {
 	# 840M, it is extended to 1.44G:
 	# snapshot_autoextend_threshold = 70
 	#
-	snapshot_autoextend_threshold = 100
+	# This configuration option has an automatic default value.
+	# snapshot_autoextend_threshold = 100
 
 	# Configuration option activation/snapshot_autoextend_percent.
 	# Auto-extending a snapshot adds this percent extra space.
@@ -1621,7 +1698,8 @@ activation {
 	# 840M, it is extended to 1.44G:
 	# snapshot_autoextend_percent = 20
 	#
-	snapshot_autoextend_percent = 20
+	# This configuration option has an automatic default value.
+	# snapshot_autoextend_percent = 20
 
 	# Configuration option activation/thin_pool_autoextend_threshold.
 	# Auto-extend a thin pool when its usage exceeds this percent.
@@ -1636,7 +1714,8 @@ activation {
 	# 840M, it is extended to 1.44G:
 	# thin_pool_autoextend_threshold = 70
 	#
-	thin_pool_autoextend_threshold = 100
+	# This configuration option has an automatic default value.
+	# thin_pool_autoextend_threshold = 100
 
 	# Configuration option activation/thin_pool_autoextend_percent.
 	# Auto-extending a thin pool adds this percent extra space.
@@ -1649,7 +1728,8 @@ activation {
 	# 840M, it is extended to 1.44G:
 	# thin_pool_autoextend_percent = 20
 	#
-	thin_pool_autoextend_percent = 20
+	# This configuration option has an automatic default value.
+	# thin_pool_autoextend_percent = 20
 
 	# Configuration option activation/vdo_pool_autoextend_threshold.
 	# Auto-extend a VDO pool when its usage exceeds this percent.
@@ -1708,7 +1788,8 @@ activation {
 	# Monitor LVs that are activated.
 	# The --ignoremonitoring option overrides this setting.
 	# When enabled, LVM will ask dmeventd to monitor activated LVs.
-	monitoring = 1
+	# This configuration option has an automatic default value.
+	# monitoring = 1
 
 	# Configuration option activation/polling_interval.
 	# Check pvmove or lvconvert progress at this interval (seconds).
@@ -1750,7 +1831,8 @@ activation {
 	#     This setting should not normally be used, but may sometimes
 	#     assist with data recovery.
 	#
-	activation_mode = "degraded"
+	# This configuration option has an automatic default value.
+	# activation_mode = "degraded"
 
 	# Configuration option activation/lock_start_list.
 	# Locking is started only for VGs selected by this list.
diff --git a/man/lvchange.8_pregen b/man/lvchange.8_pregen
index 3cfa7330d..242246570 100644
--- a/man/lvchange.8_pregen
+++ b/man/lvchange.8_pregen
@@ -66,6 +66,8 @@ lvchange \(em Change the attributes of logical volume(s)
     \fB--ignorelockingfailure\fP
 .br
     \fB--ignoremonitoring\fP
+.br
+    \fB--journal\fP \fIString\fP
 .br
     \fB--lockopt\fP \fIString\fP
 .br
@@ -419,6 +421,8 @@ Common options for lvm:
 .br
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .br
+[    \fB--journal\fP \fIString\fP ]
+.br
 [    \fB--lockopt\fP \fIString\fP ]
 .br
 [    \fB--longhelp\fP ]
@@ -674,6 +678,16 @@ Do not interact with dmeventd unless --monitor is specified.
 Do not use this if dmeventd is already monitoring a device.
 .
 .HP
+\fB--journal\fP \fIString\fP
+.br
+Record information in the systemd journal.
+This information is in addition to information
+enabled by the lvm.conf log/journal setting.
+command: record information about the command.
+output: record the default command output.
+debug: record full command debugging.
+.
+.HP
 \fB--lockopt\fP \fIString\fP
 .br
 Used to pass options for special cases to lvmlockd.
diff --git a/man/lvconvert.8_pregen b/man/lvconvert.8_pregen
index 4fafe5d29..f5f2bfd2d 100644
--- a/man/lvconvert.8_pregen
+++ b/man/lvconvert.8_pregen
@@ -66,6 +66,8 @@ lvconvert \(em Change logical volume layout
  \fB-h\fP|\fB--help\fP
 .br
  \fB-i\fP|\fB--interval\fP \fINumber\fP
+.br
+    \fB--journal\fP \fIString\fP
 .br
     \fB--lockopt\fP \fIString\fP
 .br
@@ -963,6 +965,8 @@ Common options for lvm:
 .br
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .br
+[    \fB--journal\fP \fIString\fP ]
+.br
 [    \fB--lockopt\fP \fIString\fP ]
 .br
 [    \fB--longhelp\fP ]
@@ -1183,6 +1187,16 @@ Display help text.
 Report progress at regular intervals.
 .
 .HP
+\fB--journal\fP \fIString\fP
+.br
+Record information in the systemd journal.
+This information is in addition to information
+enabled by the lvm.conf log/journal setting.
+command: record information about the command.
+output: record the default command output.
+debug: record full command debugging.
+.
+.HP
 \fB--lockopt\fP \fIString\fP
 .br
 Used to pass options for special cases to lvmlockd.
diff --git a/man/lvcreate.8_pregen b/man/lvcreate.8_pregen
index b642ad0c2..513ef0539 100644
--- a/man/lvcreate.8_pregen
+++ b/man/lvcreate.8_pregen
@@ -74,6 +74,8 @@ lvcreate \(em Create a logical volume
  \fB-K\fP|\fB--ignoreactivationskip\fP
 .br
     \fB--ignoremonitoring\fP
+.br
+    \fB--journal\fP \fIString\fP
 .br
     \fB--lockopt\fP \fIString\fP
 .br
@@ -805,6 +807,8 @@ Common options for lvm:
 .br
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .br
+[    \fB--journal\fP \fIString\fP ]
+.br
 [    \fB--lockopt\fP \fIString\fP ]
 .br
 [    \fB--longhelp\fP ]
@@ -1075,6 +1079,16 @@ Do not interact with dmeventd unless --monitor is specified.
 Do not use this if dmeventd is already monitoring a device.
 .
 .HP
+\fB--journal\fP \fIString\fP
+.br
+Record information in the systemd journal.
+This information is in addition to information
+enabled by the lvm.conf log/journal setting.
+command: record information about the command.
+output: record the default command output.
+debug: record full command debugging.
+.
+.HP
 \fB--lockopt\fP \fIString\fP
 .br
 Used to pass options for special cases to lvmlockd.
diff --git a/man/lvdisplay.8_pregen b/man/lvdisplay.8_pregen
index 8ff34bc08..011857c81 100644
--- a/man/lvdisplay.8_pregen
+++ b/man/lvdisplay.8_pregen
@@ -110,6 +110,8 @@ Common options for lvm:
 .br
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .br
+[    \fB--journal\fP \fIString\fP ]
+.br
 [    \fB--lockopt\fP \fIString\fP ]
 .br
 [    \fB--longhelp\fP ]
@@ -228,6 +230,16 @@ Allows a command to continue with read-only metadata
 operations after locking failures.
 .
 .HP
+\fB--journal\fP \fIString\fP
+.br
+Record information in the systemd journal.
+This information is in addition to information
+enabled by the lvm.conf log/journal setting.
+command: record information about the command.
+output: record the default command output.
+debug: record full command debugging.
+.
+.HP
 \fB--lockopt\fP \fIString\fP
 .br
 Used to pass options for special cases to lvmlockd.
diff --git a/man/lvextend.8_pregen b/man/lvextend.8_pregen
index fa0aec63a..1409adadf 100644
--- a/man/lvextend.8_pregen
+++ b/man/lvextend.8_pregen
@@ -38,6 +38,8 @@ lvextend \(em Add space to a logical volume
  \fB-f\fP|\fB--force\fP
 .br
  \fB-h\fP|\fB--help\fP
+.br
+    \fB--journal\fP \fIString\fP
 .br
     \fB--lockopt\fP \fIString\fP
 .br
@@ -251,6 +253,8 @@ Common options for lvm:
 .br
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .br
+[    \fB--journal\fP \fIString\fP ]
+.br
 [    \fB--lockopt\fP \fIString\fP ]
 .br
 [    \fB--longhelp\fP ]
@@ -373,6 +377,16 @@ Use with extreme caution.
 Display help text.
 .
 .HP
+\fB--journal\fP \fIString\fP
+.br
+Record information in the systemd journal.
+This information is in addition to information
+enabled by the lvm.conf log/journal setting.
+command: record information about the command.
+output: record the default command output.
+debug: record full command debugging.
+.
+.HP
 \fB--lockopt\fP \fIString\fP
 .br
 Used to pass options for special cases to lvmlockd.
diff --git a/man/lvm-fullreport.8_pregen b/man/lvm-fullreport.8_pregen
index 399d4ff9a..a93e9cf1c 100644
--- a/man/lvm-fullreport.8_pregen
+++ b/man/lvm-fullreport.8_pregen
@@ -106,6 +106,8 @@ Common options for lvm:
 .br
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .br
+[    \fB--journal\fP \fIString\fP ]
+.br
 [    \fB--lockopt\fP \fIString\fP ]
 .br
 [    \fB--longhelp\fP ]
@@ -202,6 +204,16 @@ Allows a command to continue with read-only metadata
 operations after locking failures.
 .
 .HP
+\fB--journal\fP \fIString\fP
+.br
+Record information in the systemd journal.
+This information is in addition to information
+enabled by the lvm.conf log/journal setting.
+command: record information about the command.
+output: record the default command output.
+debug: record full command debugging.
+.
+.HP
 \fB--lockopt\fP \fIString\fP
 .br
 Used to pass options for special cases to lvmlockd.
diff --git a/man/lvm-lvpoll.8_pregen b/man/lvm-lvpoll.8_pregen
index cf18ebeec..4c6cd3075 100644
--- a/man/lvm-lvpoll.8_pregen
+++ b/man/lvm-lvpoll.8_pregen
@@ -62,6 +62,8 @@ Common options for lvm:
 .br
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .br
+[    \fB--journal\fP \fIString\fP ]
+.br
 [    \fB--lockopt\fP \fIString\fP ]
 .br
 [    \fB--longhelp\fP ]
@@ -147,6 +149,16 @@ Display help text.
 Report progress at regular intervals.
 .
 .HP
+\fB--journal\fP \fIString\fP
+.br
+Record information in the systemd journal.
+This information is in addition to information
+enabled by the lvm.conf log/journal setting.
+command: record information about the command.
+output: record the default command output.
+debug: record full command debugging.
+.
+.HP
 \fB--lockopt\fP \fIString\fP
 .br
 Used to pass options for special cases to lvmlockd.
diff --git a/man/lvmconfig.8_pregen b/man/lvmconfig.8_pregen
index 6cdb577c1..bcbe3e63d 100644
--- a/man/lvmconfig.8_pregen
+++ b/man/lvmconfig.8_pregen
@@ -103,6 +103,8 @@ Common options for lvm:
 .br
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .br
+[    \fB--journal\fP \fIString\fP ]
+.br
 [    \fB--lockopt\fP \fIString\fP ]
 .br
 [    \fB--longhelp\fP ]
@@ -204,6 +206,16 @@ and \fBdiff\fP types include unsupported settings in their output by default,
 all the other types ignore unsupported settings.
 .
 .HP
+\fB--journal\fP \fIString\fP
+.br
+Record information in the systemd journal.
+This information is in addition to information
+enabled by the lvm.conf log/journal setting.
+command: record information about the command.
+output: record the default command output.
+debug: record full command debugging.
+.
+.HP
 \fB-l\fP|\fB--list\fP
 .br
 List config settings with summarizing comment. This is the same as using
diff --git a/man/lvmdevices.8_pregen b/man/lvmdevices.8_pregen
index e581a8d01..0506991a1 100644
--- a/man/lvmdevices.8_pregen
+++ b/man/lvmdevices.8_pregen
@@ -37,6 +37,8 @@ lvmdevices \(em Manage the devices file
     \fB--driverloaded\fP \fBy\fP|\fBn\fP
 .br
  \fB-h\fP|\fB--help\fP
+.br
+    \fB--journal\fP \fIString\fP
 .br
     \fB--lockopt\fP \fIString\fP
 .br
@@ -284,6 +286,8 @@ Common options for lvm:
 .br
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .br
+[    \fB--journal\fP \fIString\fP ]
+.br
 [    \fB--lockopt\fP \fIString\fP ]
 .br
 [    \fB--longhelp\fP ]
@@ -379,6 +383,16 @@ For testing and debugging.
 Display help text.
 .
 .HP
+\fB--journal\fP \fIString\fP
+.br
+Record information in the systemd journal.
+This information is in addition to information
+enabled by the lvm.conf log/journal setting.
+command: record information about the command.
+output: record the default command output.
+debug: record full command debugging.
+.
+.HP
 \fB--lockopt\fP \fIString\fP
 .br
 Used to pass options for special cases to lvmlockd.
diff --git a/man/lvmdiskscan.8_pregen b/man/lvmdiskscan.8_pregen
index 5f31e8115..0f1f0f58c 100644
--- a/man/lvmdiskscan.8_pregen
+++ b/man/lvmdiskscan.8_pregen
@@ -60,6 +60,8 @@ Common options for lvm:
 .br
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .br
+[    \fB--journal\fP \fIString\fP ]
+.br
 [    \fB--lockopt\fP \fIString\fP ]
 .br
 [    \fB--longhelp\fP ]
@@ -123,6 +125,16 @@ For testing and debugging.
 Display help text.
 .
 .HP
+\fB--journal\fP \fIString\fP
+.br
+Record information in the systemd journal.
+This information is in addition to information
+enabled by the lvm.conf log/journal setting.
+command: record information about the command.
+output: record the default command output.
+debug: record full command debugging.
+.
+.HP
 \fB--lockopt\fP \fIString\fP
 .br
 Used to pass options for special cases to lvmlockd.
diff --git a/man/lvreduce.8_pregen b/man/lvreduce.8_pregen
index 0a659e1c8..a5a9e8b69 100644
--- a/man/lvreduce.8_pregen
+++ b/man/lvreduce.8_pregen
@@ -82,6 +82,8 @@ Common options for lvm:
 .br
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .br
+[    \fB--journal\fP \fIString\fP ]
+.br
 [    \fB--lockopt\fP \fIString\fP ]
 .br
 [    \fB--longhelp\fP ]
@@ -179,6 +181,16 @@ Use with extreme caution.
 Display help text.
 .
 .HP
+\fB--journal\fP \fIString\fP
+.br
+Record information in the systemd journal.
+This information is in addition to information
+enabled by the lvm.conf log/journal setting.
+command: record information about the command.
+output: record the default command output.
+debug: record full command debugging.
+.
+.HP
 \fB--lockopt\fP \fIString\fP
 .br
 Used to pass options for special cases to lvmlockd.
diff --git a/man/lvremove.8_pregen b/man/lvremove.8_pregen
index a5ed82666..aa3dd78bb 100644
--- a/man/lvremove.8_pregen
+++ b/man/lvremove.8_pregen
@@ -88,6 +88,8 @@ Common options for lvm:
 .br
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .br
+[    \fB--journal\fP \fIString\fP ]
+.br
 [    \fB--lockopt\fP \fIString\fP ]
 .br
 [    \fB--longhelp\fP ]
@@ -163,6 +165,16 @@ Use with extreme caution.
 Display help text.
 .
 .HP
+\fB--journal\fP \fIString\fP
+.br
+Record information in the systemd journal.
+This information is in addition to information
+enabled by the lvm.conf log/journal setting.
+command: record information about the command.
+output: record the default command output.
+debug: record full command debugging.
+.
+.HP
 \fB--lockopt\fP \fIString\fP
 .br
 Used to pass options for special cases to lvmlockd.
diff --git a/man/lvrename.8_pregen b/man/lvrename.8_pregen
index 5b5975fa3..76702e871 100644
--- a/man/lvrename.8_pregen
+++ b/man/lvrename.8_pregen
@@ -72,6 +72,8 @@ Common options for lvm:
 .br
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .br
+[    \fB--journal\fP \fIString\fP ]
+.br
 [    \fB--lockopt\fP \fIString\fP ]
 .br
 [    \fB--longhelp\fP ]
@@ -141,6 +143,16 @@ For testing and debugging.
 Display help text.
 .
 .HP
+\fB--journal\fP \fIString\fP
+.br
+Record information in the systemd journal.
+This information is in addition to information
+enabled by the lvm.conf log/journal setting.
+command: record information about the command.
+output: record the default command output.
+debug: record full command debugging.
+.
+.HP
 \fB--lockopt\fP \fIString\fP
 .br
 Used to pass options for special cases to lvmlockd.
diff --git a/man/lvresize.8_pregen b/man/lvresize.8_pregen
index 36c1760fc..a9dea81f5 100644
--- a/man/lvresize.8_pregen
+++ b/man/lvresize.8_pregen
@@ -38,6 +38,8 @@ lvresize \(em Resize a logical volume
  \fB-f\fP|\fB--force\fP
 .br
  \fB-h\fP|\fB--help\fP
+.br
+    \fB--journal\fP \fIString\fP
 .br
     \fB--lockopt\fP \fIString\fP
 .br
@@ -209,6 +211,8 @@ Common options for lvm:
 .br
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .br
+[    \fB--journal\fP \fIString\fP ]
+.br
 [    \fB--lockopt\fP \fIString\fP ]
 .br
 [    \fB--longhelp\fP ]
@@ -331,6 +335,16 @@ Use with extreme caution.
 Display help text.
 .
 .HP
+\fB--journal\fP \fIString\fP
+.br
+Record information in the systemd journal.
+This information is in addition to information
+enabled by the lvm.conf log/journal setting.
+command: record information about the command.
+output: record the default command output.
+debug: record full command debugging.
+.
+.HP
 \fB--lockopt\fP \fIString\fP
 .br
 Used to pass options for special cases to lvmlockd.
diff --git a/man/lvs.8_pregen b/man/lvs.8_pregen
index d822347a1..5207a32ad 100644
--- a/man/lvs.8_pregen
+++ b/man/lvs.8_pregen
@@ -106,6 +106,8 @@ Common options for lvm:
 .br
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .br
+[    \fB--journal\fP \fIString\fP ]
+.br
 [    \fB--lockopt\fP \fIString\fP ]
 .br
 [    \fB--longhelp\fP ]
@@ -212,6 +214,16 @@ Allows a command to continue with read-only metadata
 operations after locking failures.
 .
 .HP
+\fB--journal\fP \fIString\fP
+.br
+Record information in the systemd journal.
+This information is in addition to information
+enabled by the lvm.conf log/journal setting.
+command: record information about the command.
+output: record the default command output.
+debug: record full command debugging.
+.
+.HP
 \fB--lockopt\fP \fIString\fP
 .br
 Used to pass options for special cases to lvmlockd.
diff --git a/man/lvscan.8_pregen b/man/lvscan.8_pregen
index 40438a7d2..fa318efa1 100644
--- a/man/lvscan.8_pregen
+++ b/man/lvscan.8_pregen
@@ -65,6 +65,8 @@ Common options for lvm:
 .br
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .br
+[    \fB--journal\fP \fIString\fP ]
+.br
 [    \fB--lockopt\fP \fIString\fP ]
 .br
 [    \fB--longhelp\fP ]
@@ -146,6 +148,16 @@ Allows a command to continue with read-only metadata
 operations after locking failures.
 .
 .HP
+\fB--journal\fP \fIString\fP
+.br
+Record information in the systemd journal.
+This information is in addition to information
+enabled by the lvm.conf log/journal setting.
+command: record information about the command.
+output: record the default command output.
+debug: record full command debugging.
+.
+.HP
 \fB--lockopt\fP \fIString\fP
 .br
 Used to pass options for special cases to lvmlockd.
diff --git a/man/pvchange.8_pregen b/man/pvchange.8_pregen
index 577352d2a..ca3c0f3dd 100644
--- a/man/pvchange.8_pregen
+++ b/man/pvchange.8_pregen
@@ -109,6 +109,8 @@ Common options for lvm:
 .br
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .br
+[    \fB--journal\fP \fIString\fP ]
+.br
 [    \fB--lockopt\fP \fIString\fP ]
 .br
 [    \fB--longhelp\fP ]
@@ -206,6 +208,16 @@ Use with extreme caution.
 Display help text.
 .
 .HP
+\fB--journal\fP \fIString\fP
+.br
+Record information in the systemd journal.
+This information is in addition to information
+enabled by the lvm.conf log/journal setting.
+command: record information about the command.
+output: record the default command output.
+debug: record full command debugging.
+.
+.HP
 \fB--lockopt\fP \fIString\fP
 .br
 Used to pass options for special cases to lvmlockd.
diff --git a/man/pvck.8_pregen b/man/pvck.8_pregen
index 6e55916a3..76f4144a8 100644
--- a/man/pvck.8_pregen
+++ b/man/pvck.8_pregen
@@ -32,6 +32,8 @@ pvck \(em Check metadata on physical volumes
  \fB-f\fP|\fB--file\fP \fIString\fP
 .br
  \fB-h\fP|\fB--help\fP
+.br
+    \fB--journal\fP \fIString\fP
 .br
     \fB--labelsector\fP \fINumber\fP
 .br
@@ -305,6 +307,8 @@ Common options for lvm:
 .br
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .br
+[    \fB--journal\fP \fIString\fP ]
+.br
 [    \fB--lockopt\fP \fIString\fP ]
 .br
 [    \fB--longhelp\fP ]
@@ -389,6 +393,16 @@ Metadata file to read or write.
 Display help text.
 .
 .HP
+\fB--journal\fP \fIString\fP
+.br
+Record information in the systemd journal.
+This information is in addition to information
+enabled by the lvm.conf log/journal setting.
+command: record information about the command.
+output: record the default command output.
+debug: record full command debugging.
+.
+.HP
 \fB--labelsector\fP \fINumber\fP
 .br
 By default the PV is labelled with an LVM2 identifier in its second
diff --git a/man/pvcreate.8_pregen b/man/pvcreate.8_pregen
index 26e5141fe..9fb110678 100644
--- a/man/pvcreate.8_pregen
+++ b/man/pvcreate.8_pregen
@@ -158,6 +158,8 @@ Common options for lvm:
 .br
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .br
+[    \fB--journal\fP \fIString\fP ]
+.br
 [    \fB--lockopt\fP \fIString\fP ]
 .br
 [    \fB--longhelp\fP ]
@@ -256,6 +258,16 @@ Use with extreme caution.
 Display help text.
 .
 .HP
+\fB--journal\fP \fIString\fP
+.br
+Record information in the systemd journal.
+This information is in addition to information
+enabled by the lvm.conf log/journal setting.
+command: record information about the command.
+output: record the default command output.
+debug: record full command debugging.
+.
+.HP
 \fB--labelsector\fP \fINumber\fP
 .br
 By default the PV is labelled with an LVM2 identifier in its second
diff --git a/man/pvdisplay.8_pregen b/man/pvdisplay.8_pregen
index ff5d9f50a..346b97d4a 100644
--- a/man/pvdisplay.8_pregen
+++ b/man/pvdisplay.8_pregen
@@ -108,6 +108,8 @@ Common options for lvm:
 .br
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .br
+[    \fB--journal\fP \fIString\fP ]
+.br
 [    \fB--lockopt\fP \fIString\fP ]
 .br
 [    \fB--longhelp\fP ]
@@ -218,6 +220,16 @@ Allows a command to continue with read-only metadata
 operations after locking failures.
 .
 .HP
+\fB--journal\fP \fIString\fP
+.br
+Record information in the systemd journal.
+This information is in addition to information
+enabled by the lvm.conf log/journal setting.
+command: record information about the command.
+output: record the default command output.
+debug: record full command debugging.
+.
+.HP
 \fB--lockopt\fP \fIString\fP
 .br
 Used to pass options for special cases to lvmlockd.
diff --git a/man/pvmove.8_pregen b/man/pvmove.8_pregen
index a764ed9ca..2ec1b593d 100644
--- a/man/pvmove.8_pregen
+++ b/man/pvmove.8_pregen
@@ -112,6 +112,8 @@ Common options for lvm:
 .br
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .br
+[    \fB--journal\fP \fIString\fP ]
+.br
 [    \fB--lockopt\fP \fIString\fP ]
 .br
 [    \fB--longhelp\fP ]
@@ -232,6 +234,16 @@ Display help text.
 Report progress at regular intervals.
 .
 .HP
+\fB--journal\fP \fIString\fP
+.br
+Record information in the systemd journal.
+This information is in addition to information
+enabled by the lvm.conf log/journal setting.
+command: record information about the command.
+output: record the default command output.
+debug: record full command debugging.
+.
+.HP
 \fB--lockopt\fP \fIString\fP
 .br
 Used to pass options for special cases to lvmlockd.
diff --git a/man/pvremove.8_pregen b/man/pvremove.8_pregen
index b34f2a042..6ca29f55c 100644
--- a/man/pvremove.8_pregen
+++ b/man/pvremove.8_pregen
@@ -61,6 +61,8 @@ Common options for lvm:
 .br
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .br
+[    \fB--journal\fP \fIString\fP ]
+.br
 [    \fB--lockopt\fP \fIString\fP ]
 .br
 [    \fB--longhelp\fP ]
@@ -130,6 +132,16 @@ Use with extreme caution.
 Display help text.
 .
 .HP
+\fB--journal\fP \fIString\fP
+.br
+Record information in the systemd journal.
+This information is in addition to information
+enabled by the lvm.conf log/journal setting.
+command: record information about the command.
+output: record the default command output.
+debug: record full command debugging.
+.
+.HP
 \fB--lockopt\fP \fIString\fP
 .br
 Used to pass options for special cases to lvmlockd.
diff --git a/man/pvresize.8_pregen b/man/pvresize.8_pregen
index ea309b311..a94e0e5a5 100644
--- a/man/pvresize.8_pregen
+++ b/man/pvresize.8_pregen
@@ -56,6 +56,8 @@ Common options for lvm:
 .br
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .br
+[    \fB--journal\fP \fIString\fP ]
+.br
 [    \fB--lockopt\fP \fIString\fP ]
 .br
 [    \fB--longhelp\fP ]
@@ -119,6 +121,16 @@ For testing and debugging.
 Display help text.
 .
 .HP
+\fB--journal\fP \fIString\fP
+.br
+Record information in the systemd journal.
+This information is in addition to information
+enabled by the lvm.conf log/journal setting.
+command: record information about the command.
+output: record the default command output.
+debug: record full command debugging.
+.
+.HP
 \fB--lockopt\fP \fIString\fP
 .br
 Used to pass options for special cases to lvmlockd.
diff --git a/man/pvs.8_pregen b/man/pvs.8_pregen
index 08b5600f5..00c501cfe 100644
--- a/man/pvs.8_pregen
+++ b/man/pvs.8_pregen
@@ -104,6 +104,8 @@ Common options for lvm:
 .br
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .br
+[    \fB--journal\fP \fIString\fP ]
+.br
 [    \fB--lockopt\fP \fIString\fP ]
 .br
 [    \fB--longhelp\fP ]
@@ -202,6 +204,16 @@ Allows a command to continue with read-only metadata
 operations after locking failures.
 .
 .HP
+\fB--journal\fP \fIString\fP
+.br
+Record information in the systemd journal.
+This information is in addition to information
+enabled by the lvm.conf log/journal setting.
+command: record information about the command.
+output: record the default command output.
+debug: record full command debugging.
+.
+.HP
 \fB--lockopt\fP \fIString\fP
 .br
 Used to pass options for special cases to lvmlockd.
diff --git a/man/pvscan.8_pregen b/man/pvscan.8_pregen
index 8025d6c34..ec4189e10 100644
--- a/man/pvscan.8_pregen
+++ b/man/pvscan.8_pregen
@@ -6,12 +6,80 @@ pvscan \(em List all physical volumes
 .
 .SH SYNOPSIS
 .
-\fBpvscan\fP \fIoption_args\fP
+\fBpvscan\fP \fIoption_args\fP \fIposition_args\fP
 .br
     [ \fIoption_args\fP ]
 .br
     [ \fIposition_args\fP ]
 .br
+.P
+.ad l
+ \fB-a\fP|\fB--activate\fP \fBy\fP|\fBn\fP|\fBay\fP
+.br
+    \fB--cache\fP
+.br
+    \fB--checkcomplete\fP
+.br
+    \fB--commandprofile\fP \fIString\fP
+.br
+    \fB--config\fP \fIString\fP
+.br
+ \fB-d\fP|\fB--debug\fP
+.br
+    \fB--devices\fP \fIPV\fP
+.br
+    \fB--devicesfile\fP \fIString\fP
+.br
+    \fB--driverloaded\fP \fBy\fP|\fBn\fP
+.br
+ \fB-e\fP|\fB--exported\fP
+.br
+ \fB-h\fP|\fB--help\fP
+.br
+    \fB--ignorelockingfailure\fP
+.br
+    \fB--journal\fP \fIString\fP
+.br
+    \fB--listlvs\fP
+.br
+    \fB--listvg\fP
+.br
+    \fB--lockopt\fP \fIString\fP
+.br
+    \fB--longhelp\fP
+.br
+ \fB-j\fP|\fB--major\fP \fINumber\fP
+.br
+    \fB--minor\fP \fINumber\fP
+.br
+    \fB--nolocking\fP
+.br
+    \fB--noudevsync\fP
+.br
+ \fB-n\fP|\fB--novolumegroup\fP
+.br
+    \fB--profile\fP \fIString\fP
+.br
+ \fB-q\fP|\fB--quiet\fP
+.br
+    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP
+.br
+ \fB-s\fP|\fB--short\fP
+.br
+ \fB-t\fP|\fB--test\fP
+.br
+    \fB--udevoutput\fP
+.br
+ \fB-u\fP|\fB--uuid\fP
+.br
+ \fB-v\fP|\fB--verbose\fP
+.br
+    \fB--version\fP
+.br
+    \fB--vgonline\fP
+.br
+ \fB-y\fP|\fB--yes\fP
+.ad b
 .
 .SH DESCRIPTION
 .
@@ -92,21 +160,29 @@ Display PV information.
 .br
 [ \fB-u\fP|\fB--uuid\fP ]
 .br
+[    \fB--ignorelockingfailure\fP ]
+.br
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+.br
 [ COMMON_OPTIONS ]
 .ad b
 .RE
 .P
-Autoactivate a VG when all PVs are online.
+\(em
+.P
+Record that a PV is online or offline.
 .br
 .P
 \fBpvscan\fP \fB--cache\fP
 .br
 .RS 4
 .ad l
-[ \fB-a\fP|\fB--activate\fP \fBay\fP ]
-.br
 [ \fB-j\fP|\fB--major\fP \fINumber\fP ]
 .br
+[    \fB--ignorelockingfailure\fP ]
+.br
+[    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+.br
 [    \fB--minor\fP \fINumber\fP ]
 .br
 [    \fB--noudevsync\fP ]
@@ -118,16 +194,100 @@ Autoactivate a VG when all PVs are online.
 [ \fIString\fP|\fIPV\fP ... ]
 .RE
 .P
-Common options for command:
-.
+\(em
+.P
+Record that a PV is online and autoactivate the VG if complete.
+.br
+.P
+\fBpvscan\fP \fB--cache\fP \fB-a\fP|\fB--activate\fP \fBay\fP
+.br
 .RS 4
 .ad l
+[ \fB-j\fP|\fB--major\fP \fINumber\fP ]
+.br
 [    \fB--ignorelockingfailure\fP ]
 .br
 [    \fB--reportformat\fP \fBbasic\fP|\fBjson\fP ]
+.br
+[    \fB--minor\fP \fINumber\fP ]
+.br
+[    \fB--noudevsync\fP ]
+.br
+[ COMMON_OPTIONS ]
+.ad b
+.RE
+.RS 4
+[ \fIString\fP|\fIPV\fP ... ]
+.RE
+.P
+\(em
+.P
+Record that a PV is online and list the VG using the PV.
+.br
+.P
+\fBpvscan\fP \fB--cache\fP \fB--listvg\fP \fIPV\fP
+.br
+.RS 4
+.ad l
+[    \fB--ignorelockingfailure\fP ]
+.br
+[    \fB--checkcomplete\fP ]
+.br
+[    \fB--vgonline\fP ]
+.br
+[    \fB--udevoutput\fP ]
+.br
+[ COMMON_OPTIONS ]
 .ad b
 .RE
 .P
+\(em
+.P
+Record that a PV is online and list LVs using the PV.
+.br
+.P
+\fBpvscan\fP \fB--cache\fP \fB--listlvs\fP \fIPV\fP
+.br
+.RS 4
+.ad l
+[    \fB--ignorelockingfailure\fP ]
+.br
+[    \fB--checkcomplete\fP ]
+.br
+[    \fB--vgonline\fP ]
+.br
+[ COMMON_OPTIONS ]
+.ad b
+.RE
+.P
+\(em
+.P
+List LVs using the PV.
+.br
+.P
+\fBpvscan\fP \fB--listlvs\fP \fIPV\fP
+.br
+.RS 4
+.ad l
+[ COMMON_OPTIONS ]
+.ad b
+.RE
+.P
+\(em
+.P
+List the VG using the PV.
+.br
+.P
+\fBpvscan\fP \fB--listvg\fP \fIPV\fP
+.br
+.RS 4
+.ad l
+[ COMMON_OPTIONS ]
+.ad b
+.RE
+.P
+\(em
+.P
 Common options for lvm:
 .
 .RS 4
@@ -154,6 +314,8 @@ Common options for lvm:
 .br
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .br
+[    \fB--journal\fP \fIString\fP ]
+.br
 [    \fB--lockopt\fP \fIString\fP ]
 .br
 [    \fB--longhelp\fP ]
@@ -181,6 +343,15 @@ Auto-activate LVs in a VG when the PVs scanned have completed the VG.
 Scan one or more devices and record that they are online.
 .
 .HP
+\fB--checkcomplete\fP
+.br
+Check if all the devices used by a VG or LV are present,
+and print "complete" or "incomplete" for each listed
+VG or LV.  This option is used as a part of event-based
+autoactivation, so pvscan will do nothing if this option
+is set and event_activation=0 in the config settings.
+.
+.HP
 \fB--commandprofile\fP \fIString\fP
 .br
 The command profile to use for command configuration.
@@ -239,6 +410,26 @@ Allows a command to continue with read-only metadata
 operations after locking failures.
 .
 .HP
+\fB--journal\fP \fIString\fP
+.br
+Record information in the systemd journal.
+This information is in addition to information
+enabled by the lvm.conf log/journal setting.
+command: record information about the command.
+output: record the default command output.
+debug: record full command debugging.
+.
+.HP
+\fB--listlvs\fP
+.br
+Print a list of LVs that use the device.
+.
+.HP
+\fB--listvg\fP
+.br
+Print the VG that uses the device.
+.
+.HP
 \fB--lockopt\fP \fIString\fP
 .br
 Used to pass options for special cases to lvmlockd.
@@ -314,6 +505,11 @@ error messages in multi-stage operations if a tool relies on reading
 back metadata it believes has changed but hasn't.
 .
 .HP
+\fB--udevoutput\fP
+.br
+Command output is modified to be imported from a udev rule.
+.
+.HP
 \fB-u\fP|\fB--uuid\fP
 .br
 Show UUIDs in addition to device names.
@@ -330,6 +526,12 @@ of messages sent to stdout and stderr.
 Display version information.
 .
 .HP
+\fB--vgonline\fP
+.br
+The first command to see a complete VG will report it uniquely.
+Other commands to see the complete VG will report it differently.
+.
+.HP
 \fB-y\fP|\fB--yes\fP
 .br
 Do not prompt for confirmation interactively but always assume the
diff --git a/man/vgcfgbackup.8_pregen b/man/vgcfgbackup.8_pregen
index ce7102595..34690efba 100644
--- a/man/vgcfgbackup.8_pregen
+++ b/man/vgcfgbackup.8_pregen
@@ -81,6 +81,8 @@ Common options for lvm:
 .br
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .br
+[    \fB--journal\fP \fIString\fP ]
+.br
 [    \fB--lockopt\fP \fIString\fP ]
 .br
 [    \fB--longhelp\fP ]
@@ -163,6 +165,16 @@ Allows a command to continue with read-only metadata
 operations after locking failures.
 .
 .HP
+\fB--journal\fP \fIString\fP
+.br
+Record information in the systemd journal.
+This information is in addition to information
+enabled by the lvm.conf log/journal setting.
+command: record information about the command.
+output: record the default command output.
+debug: record full command debugging.
+.
+.HP
 \fB--lockopt\fP \fIString\fP
 .br
 Used to pass options for special cases to lvmlockd.
diff --git a/man/vgcfgrestore.8_pregen b/man/vgcfgrestore.8_pregen
index 841626728..54f1d45dd 100644
--- a/man/vgcfgrestore.8_pregen
+++ b/man/vgcfgrestore.8_pregen
@@ -31,6 +31,8 @@ vgcfgrestore \(em Restore volume group configuration
     \fB--force\fP
 .br
  \fB-h\fP|\fB--help\fP
+.br
+    \fB--journal\fP \fIString\fP
 .br
  \fB-l\fP|\fB--list\fP
 .br
@@ -162,6 +164,8 @@ Common options for lvm:
 .br
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .br
+[    \fB--journal\fP \fIString\fP ]
+.br
 [    \fB--lockopt\fP \fIString\fP ]
 .br
 [    \fB--longhelp\fP ]
@@ -240,6 +244,16 @@ thin pool kernel metadata precisely.
 Display help text.
 .
 .HP
+\fB--journal\fP \fIString\fP
+.br
+Record information in the systemd journal.
+This information is in addition to information
+enabled by the lvm.conf log/journal setting.
+command: record information about the command.
+output: record the default command output.
+debug: record full command debugging.
+.
+.HP
 \fB-l\fP|\fB--list\fP
 .br
 List metadata backup and archive files pertaining to the VG.
diff --git a/man/vgchange.8_pregen b/man/vgchange.8_pregen
index 31fc458da..c2324d337 100644
--- a/man/vgchange.8_pregen
+++ b/man/vgchange.8_pregen
@@ -52,6 +52,8 @@ vgchange \(em Change volume group attributes
     \fB--ignorelockingfailure\fP
 .br
     \fB--ignoremonitoring\fP
+.br
+    \fB--journal\fP \fIString\fP
 .br
     \fB--lockopt\fP \fIString\fP
 .br
@@ -419,6 +421,8 @@ Common options for lvm:
 .br
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .br
+[    \fB--journal\fP \fIString\fP ]
+.br
 [    \fB--lockopt\fP \fIString\fP ]
 .br
 [    \fB--longhelp\fP ]
@@ -597,6 +601,16 @@ Do not interact with dmeventd unless --monitor is specified.
 Do not use this if dmeventd is already monitoring a device.
 .
 .HP
+\fB--journal\fP \fIString\fP
+.br
+Record information in the systemd journal.
+This information is in addition to information
+enabled by the lvm.conf log/journal setting.
+command: record information about the command.
+output: record the default command output.
+debug: record full command debugging.
+.
+.HP
 \fB--lockopt\fP \fIString\fP
 .br
 Used to pass options for special cases to lvmlockd.
diff --git a/man/vgck.8_pregen b/man/vgck.8_pregen
index ae312424a..6295e4451 100644
--- a/man/vgck.8_pregen
+++ b/man/vgck.8_pregen
@@ -72,6 +72,8 @@ Common options for lvm:
 .br
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .br
+[    \fB--journal\fP \fIString\fP ]
+.br
 [    \fB--lockopt\fP \fIString\fP ]
 .br
 [    \fB--longhelp\fP ]
@@ -135,6 +137,16 @@ For testing and debugging.
 Display help text.
 .
 .HP
+\fB--journal\fP \fIString\fP
+.br
+Record information in the systemd journal.
+This information is in addition to information
+enabled by the lvm.conf log/journal setting.
+command: record information about the command.
+output: record the default command output.
+debug: record full command debugging.
+.
+.HP
 \fB--lockopt\fP \fIString\fP
 .br
 Used to pass options for special cases to lvmlockd.
diff --git a/man/vgconvert.8_pregen b/man/vgconvert.8_pregen
index d18e7af08..2665fe6e0 100644
--- a/man/vgconvert.8_pregen
+++ b/man/vgconvert.8_pregen
@@ -67,6 +67,8 @@ Common options for lvm:
 .br
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .br
+[    \fB--journal\fP \fIString\fP ]
+.br
 [    \fB--lockopt\fP \fIString\fP ]
 .br
 [    \fB--longhelp\fP ]
@@ -151,6 +153,16 @@ Use with extreme caution.
 Display help text.
 .
 .HP
+\fB--journal\fP \fIString\fP
+.br
+Record information in the systemd journal.
+This information is in addition to information
+enabled by the lvm.conf log/journal setting.
+command: record information about the command.
+output: record the default command output.
+debug: record full command debugging.
+.
+.HP
 \fB--labelsector\fP \fINumber\fP
 .br
 By default the PV is labelled with an LVM2 identifier in its second
diff --git a/man/vgcreate.8_pregen b/man/vgcreate.8_pregen
index 7e357a548..a77457594 100644
--- a/man/vgcreate.8_pregen
+++ b/man/vgcreate.8_pregen
@@ -107,6 +107,8 @@ Common options for lvm:
 .br
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .br
+[    \fB--journal\fP \fIString\fP ]
+.br
 [    \fB--lockopt\fP \fIString\fP ]
 .br
 [    \fB--longhelp\fP ]
@@ -233,6 +235,16 @@ Use with extreme caution.
 Display help text.
 .
 .HP
+\fB--journal\fP \fIString\fP
+.br
+Record information in the systemd journal.
+This information is in addition to information
+enabled by the lvm.conf log/journal setting.
+command: record information about the command.
+output: record the default command output.
+debug: record full command debugging.
+.
+.HP
 \fB--labelsector\fP \fINumber\fP
 .br
 By default the PV is labelled with an LVM2 identifier in its second
diff --git a/man/vgdisplay.8_pregen b/man/vgdisplay.8_pregen
index 467f74506..4f7ddf517 100644
--- a/man/vgdisplay.8_pregen
+++ b/man/vgdisplay.8_pregen
@@ -105,6 +105,8 @@ Common options for lvm:
 .br
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .br
+[    \fB--journal\fP \fIString\fP ]
+.br
 [    \fB--lockopt\fP \fIString\fP ]
 .br
 [    \fB--longhelp\fP ]
@@ -215,6 +217,16 @@ Allows a command to continue with read-only metadata
 operations after locking failures.
 .
 .HP
+\fB--journal\fP \fIString\fP
+.br
+Record information in the systemd journal.
+This information is in addition to information
+enabled by the lvm.conf log/journal setting.
+command: record information about the command.
+output: record the default command output.
+debug: record full command debugging.
+.
+.HP
 \fB--lockopt\fP \fIString\fP
 .br
 Used to pass options for special cases to lvmlockd.
diff --git a/man/vgexport.8_pregen b/man/vgexport.8_pregen
index 0e6e0b164..5c39c8d53 100644
--- a/man/vgexport.8_pregen
+++ b/man/vgexport.8_pregen
@@ -93,6 +93,8 @@ Common options for lvm:
 .br
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .br
+[    \fB--journal\fP \fIString\fP ]
+.br
 [    \fB--lockopt\fP \fIString\fP ]
 .br
 [    \fB--longhelp\fP ]
@@ -160,6 +162,16 @@ For testing and debugging.
 Display help text.
 .
 .HP
+\fB--journal\fP \fIString\fP
+.br
+Record information in the systemd journal.
+This information is in addition to information
+enabled by the lvm.conf log/journal setting.
+command: record information about the command.
+output: record the default command output.
+debug: record full command debugging.
+.
+.HP
 \fB--lockopt\fP \fIString\fP
 .br
 Used to pass options for special cases to lvmlockd.
diff --git a/man/vgextend.8_pregen b/man/vgextend.8_pregen
index e5e01c4c5..b0d20f6eb 100644
--- a/man/vgextend.8_pregen
+++ b/man/vgextend.8_pregen
@@ -85,6 +85,8 @@ Common options for lvm:
 .br
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .br
+[    \fB--journal\fP \fIString\fP ]
+.br
 [    \fB--lockopt\fP \fIString\fP ]
 .br
 [    \fB--longhelp\fP ]
@@ -174,6 +176,16 @@ Use with extreme caution.
 Display help text.
 .
 .HP
+\fB--journal\fP \fIString\fP
+.br
+Record information in the systemd journal.
+This information is in addition to information
+enabled by the lvm.conf log/journal setting.
+command: record information about the command.
+output: record the default command output.
+debug: record full command debugging.
+.
+.HP
 \fB--labelsector\fP \fINumber\fP
 .br
 By default the PV is labelled with an LVM2 identifier in its second
diff --git a/man/vgimport.8_pregen b/man/vgimport.8_pregen
index c0b815b65..ff242cf96 100644
--- a/man/vgimport.8_pregen
+++ b/man/vgimport.8_pregen
@@ -81,6 +81,8 @@ Common options for lvm:
 .br
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .br
+[    \fB--journal\fP \fIString\fP ]
+.br
 [    \fB--lockopt\fP \fIString\fP ]
 .br
 [    \fB--longhelp\fP ]
@@ -155,6 +157,16 @@ Use with extreme caution.
 Display help text.
 .
 .HP
+\fB--journal\fP \fIString\fP
+.br
+Record information in the systemd journal.
+This information is in addition to information
+enabled by the lvm.conf log/journal setting.
+command: record information about the command.
+output: record the default command output.
+debug: record full command debugging.
+.
+.HP
 \fB--lockopt\fP \fIString\fP
 .br
 Used to pass options for special cases to lvmlockd.
diff --git a/man/vgimportclone.8_pregen b/man/vgimportclone.8_pregen
index ee9bbe66c..e78d1b2c9 100644
--- a/man/vgimportclone.8_pregen
+++ b/man/vgimportclone.8_pregen
@@ -62,6 +62,8 @@ Common options for lvm:
 .br
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .br
+[    \fB--journal\fP \fIString\fP ]
+.br
 [    \fB--lockopt\fP \fIString\fP ]
 .br
 [    \fB--longhelp\fP ]
@@ -145,6 +147,16 @@ will not be changed (nor will their associated PVs).
 Add devices to the devices file.
 .
 .HP
+\fB--journal\fP \fIString\fP
+.br
+Record information in the systemd journal.
+This information is in addition to information
+enabled by the lvm.conf log/journal setting.
+command: record information about the command.
+output: record the default command output.
+debug: record full command debugging.
+.
+.HP
 \fB--lockopt\fP \fIString\fP
 .br
 Used to pass options for special cases to lvmlockd.
diff --git a/man/vgimportdevices.8_pregen b/man/vgimportdevices.8_pregen
index 364ef52a4..db6b597db 100644
--- a/man/vgimportdevices.8_pregen
+++ b/man/vgimportdevices.8_pregen
@@ -86,6 +86,8 @@ Common options for lvm:
 .br
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .br
+[    \fB--journal\fP \fIString\fP ]
+.br
 [    \fB--lockopt\fP \fIString\fP ]
 .br
 [    \fB--longhelp\fP ]
@@ -159,6 +161,16 @@ See \fBlvmsystemid\fP(7) for more information about foreign VGs.
 Display help text.
 .
 .HP
+\fB--journal\fP \fIString\fP
+.br
+Record information in the systemd journal.
+This information is in addition to information
+enabled by the lvm.conf log/journal setting.
+command: record information about the command.
+output: record the default command output.
+debug: record full command debugging.
+.
+.HP
 \fB--lockopt\fP \fIString\fP
 .br
 Used to pass options for special cases to lvmlockd.
diff --git a/man/vgmerge.8_pregen b/man/vgmerge.8_pregen
index e2292182a..588d2ec5d 100644
--- a/man/vgmerge.8_pregen
+++ b/man/vgmerge.8_pregen
@@ -59,6 +59,8 @@ Common options for lvm:
 .br
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .br
+[    \fB--journal\fP \fIString\fP ]
+.br
 [    \fB--lockopt\fP \fIString\fP ]
 .br
 [    \fB--longhelp\fP ]
@@ -128,6 +130,16 @@ For testing and debugging.
 Display help text.
 .
 .HP
+\fB--journal\fP \fIString\fP
+.br
+Record information in the systemd journal.
+This information is in addition to information
+enabled by the lvm.conf log/journal setting.
+command: record information about the command.
+output: record the default command output.
+debug: record full command debugging.
+.
+.HP
 \fB-l\fP|\fB--list\fP
 .br
 Display merged destination VG like vgdisplay -v.
diff --git a/man/vgmknodes.8_pregen b/man/vgmknodes.8_pregen
index 10f235949..df405289d 100644
--- a/man/vgmknodes.8_pregen
+++ b/man/vgmknodes.8_pregen
@@ -66,6 +66,8 @@ Common options for lvm:
 .br
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .br
+[    \fB--journal\fP \fIString\fP ]
+.br
 [    \fB--lockopt\fP \fIString\fP ]
 .br
 [    \fB--longhelp\fP ]
@@ -135,6 +137,16 @@ Allows a command to continue with read-only metadata
 operations after locking failures.
 .
 .HP
+\fB--journal\fP \fIString\fP
+.br
+Record information in the systemd journal.
+This information is in addition to information
+enabled by the lvm.conf log/journal setting.
+command: record information about the command.
+output: record the default command output.
+debug: record full command debugging.
+.
+.HP
 \fB--lockopt\fP \fIString\fP
 .br
 Used to pass options for special cases to lvmlockd.
diff --git a/man/vgreduce.8_pregen b/man/vgreduce.8_pregen
index 1509e4bd0..0fd4c5e73 100644
--- a/man/vgreduce.8_pregen
+++ b/man/vgreduce.8_pregen
@@ -31,6 +31,8 @@ vgreduce \(em Remove physical volume(s) from a volume group
  \fB-f\fP|\fB--force\fP
 .br
  \fB-h\fP|\fB--help\fP
+.br
+    \fB--journal\fP \fIString\fP
 .br
     \fB--lockopt\fP \fIString\fP
 .br
@@ -142,6 +144,8 @@ Common options for lvm:
 .br
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .br
+[    \fB--journal\fP \fIString\fP ]
+.br
 [    \fB--lockopt\fP \fIString\fP ]
 .br
 [    \fB--longhelp\fP ]
@@ -222,6 +226,16 @@ Use with extreme caution.
 Display help text.
 .
 .HP
+\fB--journal\fP \fIString\fP
+.br
+Record information in the systemd journal.
+This information is in addition to information
+enabled by the lvm.conf log/journal setting.
+command: record information about the command.
+output: record the default command output.
+debug: record full command debugging.
+.
+.HP
 \fB--lockopt\fP \fIString\fP
 .br
 Used to pass options for special cases to lvmlockd.
diff --git a/man/vgremove.8_pregen b/man/vgremove.8_pregen
index cf5c48ce4..e4b5a0268 100644
--- a/man/vgremove.8_pregen
+++ b/man/vgremove.8_pregen
@@ -67,6 +67,8 @@ Common options for lvm:
 .br
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .br
+[    \fB--journal\fP \fIString\fP ]
+.br
 [    \fB--lockopt\fP \fIString\fP ]
 .br
 [    \fB--longhelp\fP ]
@@ -136,6 +138,16 @@ Use with extreme caution.
 Display help text.
 .
 .HP
+\fB--journal\fP \fIString\fP
+.br
+Record information in the systemd journal.
+This information is in addition to information
+enabled by the lvm.conf log/journal setting.
+command: record information about the command.
+output: record the default command output.
+debug: record full command debugging.
+.
+.HP
 \fB--lockopt\fP \fIString\fP
 .br
 Used to pass options for special cases to lvmlockd.
diff --git a/man/vgrename.8_pregen b/man/vgrename.8_pregen
index 24ff24744..f09bfd507 100644
--- a/man/vgrename.8_pregen
+++ b/man/vgrename.8_pregen
@@ -85,6 +85,8 @@ Common options for lvm:
 .br
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .br
+[    \fB--journal\fP \fIString\fP ]
+.br
 [    \fB--lockopt\fP \fIString\fP ]
 .br
 [    \fB--longhelp\fP ]
@@ -160,6 +162,16 @@ Use with extreme caution.
 Display help text.
 .
 .HP
+\fB--journal\fP \fIString\fP
+.br
+Record information in the systemd journal.
+This information is in addition to information
+enabled by the lvm.conf log/journal setting.
+command: record information about the command.
+output: record the default command output.
+debug: record full command debugging.
+.
+.HP
 \fB--lockopt\fP \fIString\fP
 .br
 Used to pass options for special cases to lvmlockd.
diff --git a/man/vgs.8_pregen b/man/vgs.8_pregen
index ffb4ddc41..817bea5c1 100644
--- a/man/vgs.8_pregen
+++ b/man/vgs.8_pregen
@@ -102,6 +102,8 @@ Common options for lvm:
 .br
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .br
+[    \fB--journal\fP \fIString\fP ]
+.br
 [    \fB--lockopt\fP \fIString\fP ]
 .br
 [    \fB--longhelp\fP ]
@@ -199,6 +201,16 @@ Allows a command to continue with read-only metadata
 operations after locking failures.
 .
 .HP
+\fB--journal\fP \fIString\fP
+.br
+Record information in the systemd journal.
+This information is in addition to information
+enabled by the lvm.conf log/journal setting.
+command: record information about the command.
+output: record the default command output.
+debug: record full command debugging.
+.
+.HP
 \fB--lockopt\fP \fIString\fP
 .br
 Used to pass options for special cases to lvmlockd.
diff --git a/man/vgscan.8_pregen b/man/vgscan.8_pregen
index 959e16190..86b7bc6ef 100644
--- a/man/vgscan.8_pregen
+++ b/man/vgscan.8_pregen
@@ -59,6 +59,8 @@ Common options for lvm:
 .br
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .br
+[    \fB--journal\fP \fIString\fP ]
+.br
 [    \fB--lockopt\fP \fIString\fP ]
 .br
 [    \fB--longhelp\fP ]
@@ -128,6 +130,16 @@ Allows a command to continue with read-only metadata
 operations after locking failures.
 .
 .HP
+\fB--journal\fP \fIString\fP
+.br
+Record information in the systemd journal.
+This information is in addition to information
+enabled by the lvm.conf log/journal setting.
+command: record information about the command.
+output: record the default command output.
+debug: record full command debugging.
+.
+.HP
 \fB--lockopt\fP \fIString\fP
 .br
 Used to pass options for special cases to lvmlockd.
diff --git a/man/vgsplit.8_pregen b/man/vgsplit.8_pregen
index 8a0ae597e..c32fc57bf 100644
--- a/man/vgsplit.8_pregen
+++ b/man/vgsplit.8_pregen
@@ -102,6 +102,8 @@ Common options for lvm:
 .br
 [    \fB--driverloaded\fP \fBy\fP|\fBn\fP ]
 .br
+[    \fB--journal\fP \fIString\fP ]
+.br
 [    \fB--lockopt\fP \fIString\fP ]
 .br
 [    \fB--longhelp\fP ]
@@ -196,6 +198,16 @@ For testing and debugging.
 Display help text.
 .
 .HP
+\fB--journal\fP \fIString\fP
+.br
+Record information in the systemd journal.
+This information is in addition to information
+enabled by the lvm.conf log/journal setting.
+command: record information about the command.
+output: record the default command output.
+debug: record full command debugging.
+.
+.HP
 \fB--lockopt\fP \fIString\fP
 .br
 Used to pass options for special cases to lvmlockd.


