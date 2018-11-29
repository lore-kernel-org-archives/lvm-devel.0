From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Nov 2018 17:12:49 -0500
Subject: master - make: generate config update
Message-ID: <201811292212.wATMCnQ8016631@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fc482406ec4e0607a9d7335ac927c64b361cad1c
Commit:        fc482406ec4e0607a9d7335ac927c64b361cad1c
Parent:        4ddd756d6f0729d5f339b0165745cbf61d4ca931
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 29 23:08:05 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 29 23:10:08 2018 +0100

make: generate config update

---
 conf/example.conf.in |  126 +++++++++++++++++++-------------------------------
 1 files changed, 47 insertions(+), 79 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index 2690006..0204f4b 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -149,18 +149,6 @@ devices {
 	# This configuration option has an automatic default value.
 	# global_filter = [ "a|.*/|" ]
 
-	# Configuration option devices/cache_dir.
-	# This setting is no longer used.
-	cache_dir = "@DEFAULT_SYS_DIR@/@DEFAULT_CACHE_SUBDIR@"
-
-	# Configuration option devices/cache_file_prefix.
-	# This setting is no longer used.
-	cache_file_prefix = ""
-
-	# Configuration option devices/write_cache_state.
-	# This setting is no longer used.
-	write_cache_state = 1
-
 	# Configuration option devices/types.
 	# List of additional acceptable block device types.
 	# These are of device type names from /proc/devices, followed by the
@@ -197,19 +185,24 @@ devices {
 	fw_raid_component_detection = 0
 
 	# Configuration option devices/md_chunk_alignment.
-	# Align PV data blocks with md device's stripe-width.
+	# Align the start of a PV data area with md device's stripe-width.
 	# This applies if a PV is placed directly on an md device.
+	# default_data_alignment will be overriden if it is not aligned
+	# with the value detected for this setting.
+	# This setting is overriden by data_alignment_detection,
+	# data_alignment, and the --dataalignment option.
 	md_chunk_alignment = 1
 
 	# Configuration option devices/default_data_alignment.
-	# Default alignment of the start of a PV data area in MB.
-	# If set to 0, a value of 64KiB will be used.
-	# Set to 1 for 1MiB, 2 for 2MiB, etc.
+	# Align the start of a PV data area with this number of MiB.
+	# Set to 1 for 1MiB, 2 for 2MiB, etc. Set to 0 to disable.
+	# This setting is overriden by data_alignment and the --dataalignment
+	# option.
 	# This configuration option has an automatic default value.
 	# default_data_alignment = 1
 
 	# Configuration option devices/data_alignment_detection.
-	# Detect PV data alignment based on sysfs device information.
+	# Align the start of a PV data area with sysfs io properties.
 	# The start of a PV data area will be a multiple of minimum_io_size or
 	# optimal_io_size exposed in sysfs. minimum_io_size is the smallest
 	# request the device can perform without incurring a read-modify-write
@@ -217,27 +210,29 @@ devices {
 	# preferred unit of receiving I/O, e.g. MD stripe width.
 	# minimum_io_size is used if optimal_io_size is undefined (0).
 	# If md_chunk_alignment is enabled, that detects the optimal_io_size.
-	# This setting takes precedence over md_chunk_alignment.
+	# default_data_alignment and md_chunk_alignment will be overriden
+	# if they are not aligned with the value detected for this setting.
+	# This setting is overriden by data_alignment and the --dataalignment
+	# option.
 	data_alignment_detection = 1
 
 	# Configuration option devices/data_alignment.
-	# Alignment of the start of a PV data area in KiB.
-	# If a PV is placed directly on an md device and md_chunk_alignment or
-	# data_alignment_detection are enabled, then this setting is ignored.
-	# Otherwise, md_chunk_alignment and data_alignment_detection are
-	# disabled if this is set. Set to 0 to use the default alignment or the
-	# page size, if larger.
+	# Align the start of a PV data area with this number of KiB.
+	# When non-zero, this setting overrides default_data_alignment.
+	# Set to 0 to disable, in which case default_data_alignment
+	# is used to align the first PE in units of MiB.
+	# This setting is overriden by the --dataalignment option.
 	data_alignment = 0
 
 	# Configuration option devices/data_alignment_offset_detection.
-	# Detect PV data alignment offset based on sysfs device information.
-	# The start of a PV aligned data area will be shifted by the
+	# Shift the start of an aligned PV data area based on sysfs information.
+	# After a PV data area is aligned, it will be shifted by the
 	# alignment_offset exposed in sysfs. This offset is often 0, but may
 	# be non-zero. Certain 4KiB sector drives that compensate for windows
 	# partitioning will have an alignment_offset of 3584 bytes (sector 7
 	# is the lowest aligned logical block, the 4KiB sectors start at
 	# LBA -1, and consequently sector 63 is aligned on a 4KiB boundary).
-	# pvcreate --dataalignmentoffset will skip this detection.
+	# This setting is overriden by the --dataalignmentoffset option.
 	data_alignment_offset_detection = 1
 
 	# Configuration option devices/ignore_suspended_devices.
@@ -265,10 +260,6 @@ devices {
 	# different way, making them a better choice for VG stacking.
 	ignore_lvm_mirrors = 1
 
-	# Configuration option devices/disable_after_error_count.
-	# This setting is no longer used.
-	disable_after_error_count = 0
-
 	# Configuration option devices/require_restorefile_with_uuid.
 	# Allow use of pvcreate --uuid without requiring --restorefile.
 	require_restorefile_with_uuid = 1
@@ -837,20 +828,6 @@ global {
 	# the error messages.
 	activation = 1
 
-	# Configuration option global/fallback_to_lvm1.
-	# This setting is no longer used.
-	# This configuration option has an automatic default value.
-	# fallback_to_lvm1 = 0
-
-	# Configuration option global/format.
-	# This setting is no longer used.
-	# This configuration option has an automatic default value.
-	# format = "lvm2"
-
-	# Configuration option global/format_libraries.
-	# This setting is no longer used.
-	# This configuration option does not have a default value defined.
-
 	# Configuration option global/segment_libraries.
 	# This configuration option does not have a default value defined.
 
@@ -863,22 +840,10 @@ global {
 	# Location of /etc system configuration directory.
 	etc = "@CONFDIR@"
 
-	# Configuration option global/locking_type.
-	# This setting is no longer used.
-	locking_type = 1
-
 	# Configuration option global/wait_for_locks.
 	# When disabled, fail if a lock request would block.
 	wait_for_locks = 1
 
-	# Configuration option global/fallback_to_clustered_locking.
-	# This setting is no longer used.
-	fallback_to_clustered_locking = 1
-
-	# Configuration option global/fallback_to_local_locking.
-	# This setting is no longer used.
-	fallback_to_local_locking = 1
-
 	# Configuration option global/locking_dir.
 	# Directory to use for LVM command file locks.
 	# Local non-LV directory that holds file-based locks while commands are
@@ -899,11 +864,6 @@ global {
 	# Search this directory first for shared libraries.
 	# This configuration option does not have a default value defined.
 
-	# Configuration option global/locking_library.
-	# This setting is no longer used.
-	# This configuration option has an automatic default value.
-	# locking_library = "liblvm2clusterlock.so"
-
 	# Configuration option global/abort_on_internal_errors.
 	# Abort a command that encounters an internal error.
 	# Treat any internal errors as fatal errors, aborting the process that
@@ -992,14 +952,20 @@ global {
 	# This configuration option has an automatic default value.
 	# lvdisplay_shows_full_device_path = 0
 
-	# Configuration option global/use_lvmetad.
-	# This setting is no longer used.
-	use_lvmetad = 0
+	# Configuration option global/event_activation.
+	# Activate LVs based on system-generated device events.
+	# When a device appears on the system, a system-generated event runs
+	# the pvscan command to activate LVs if the new PV completes the VG.
+	# Use auto_activation_volume_list to select which LVs should be
+	# activated from these events (the default is all.)
+	# When event_activation is disabled, the system will generally run
+	# a direct activation command to activate LVs in complete VGs.
+	event_activation = 1
 
-	# Configuration option global/lvmetad_update_wait_time.
-	# This setting is no longer used.
+	# Configuration option global/use_aio.
+	# Use async I/O when reading and writing devices.
 	# This configuration option has an automatic default value.
-	# lvmetad_update_wait_time = 0
+	# use_aio = 1
 
 	# Configuration option global/use_lvmlockd.
 	# Use lvmlockd for locking among hosts using LVM on shared storage.
@@ -1681,13 +1647,20 @@ activation {
 	# vgmetadatacopies = 0
 
 	# Configuration option metadata/pvmetadatasize.
-	# Approximate number of sectors to use for each metadata copy.
-	# VGs with large numbers of PVs or LVs, or VGs containing complex LV
-	# structures, may need additional space for VG metadata. The metadata
-	# areas are treated as circular buffers, so unused space becomes filled
-	# with an archive of the most recent previous versions of the metadata.
+	# The default size of the metadata area in units of 512 byte sectors.
+	# The metadata area begins at an offset of the page size from the start
+	# of the device. The first PE is by default at 1 MiB from the start of
+	# the device. The space between these is the default metadata area size.
+	# The actual size of the metadata area may be larger than what is set
+	# here due to default_data_alignment making the first PE a MiB multiple.
+	# The metadata area begins with a 512 byte header and is followed by a
+	# circular buffer used for VG metadata text. The maximum size of the VG
+	# metadata is about half the size of the metadata buffer. VGs with large
+	# numbers of PVs or LVs, or VGs containing complex LV structures, may need
+	# additional space for VG metadata. The --metadatasize option overrides
+	# this setting.
+	# This configuration option does not have a default value defined.
 	# This configuration option has an automatic default value.
-	# pvmetadatasize = 255
 
 	# Configuration option metadata/pvmetadataignore.
 	# Ignore metadata areas on a new PV.
@@ -1702,11 +1675,6 @@ activation {
 	# This configuration option is advanced.
 	# This configuration option has an automatic default value.
 	# stripesize = 64
-
-	# Configuration option metadata/dirs.
-	# This setting is no longer used.
-	# This configuration option is advanced.
-	# This configuration option does not have a default value defined.
 # }
 
 # Configuration section report.


