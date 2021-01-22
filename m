From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 22 Jan 2021 15:09:59 +0000 (GMT)
Subject: main - config: avoid printing spaces before end of line
Message-ID: <20210122150959.16CE238930FC@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9ae1935b74cc2336a19bcaee8703f6d22d1ee837
Commit:        9ae1935b74cc2336a19bcaee8703f6d22d1ee837
Parent:        74adbec77f77cd725bbac7ab3f3fb964d8b1e1f0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jan 21 21:51:20 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jan 22 15:30:37 2021 +0100

config: avoid printing spaces before end of line

Empty comments were generating unnecessary space char before new line.
---
 conf/example.conf.in  | 144 +++++++++++++++++++++++++-------------------------
 conf/lvmlocal.conf.in |   4 +-
 lib/config/config.c   |   2 +-
 3 files changed, 75 insertions(+), 75 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index fe17942d9..c32f4f5ad 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -78,14 +78,14 @@ devices {
 	# routines to acquire this information. For example, this information
 	# is used to drive LVM filtering like MD component detection, multipath
 	# component detection, partition detection and others.
-	# 
+	#
 	# Accepted values:
 	#   none
 	#     No external device information source is used.
 	#   udev
 	#     Reuse existing udev database records. Applicable only if LVM is
 	#     compiled with udev support.
-	# 
+	#
 	external_device_info_source = "none"
 
 	# Configuration option devices/hints.
@@ -94,13 +94,13 @@ devices {
 	# scanning, and will only scan the listed PVs. Removing the hint file
 	# will cause lvm to generate a new one. Disable hints if PVs will
 	# be copied onto devices using non-lvm commands, like dd.
-	# 
+	#
 	# Accepted values:
 	#   all
 	#     Use all hints.
 	#   none
 	#     Use no hints.
-	# 
+	#
 	# This configuration option has an automatic default value.
 	# hints = "all"
 
@@ -118,10 +118,10 @@ devices {
 	# Prefer the name with the least number of slashes.
 	# Prefer a name that is a symlink.
 	# Prefer the path with least value in lexicographical order.
-	# 
+	#
 	# Example
 	# preferred_names = [ "^/dev/mpath/", "^/dev/mapper/mpath", "^/dev/[hs]d" ]
-	# 
+	#
 	# This configuration option does not have a default value defined.
 
 	# Configuration option devices/filter.
@@ -139,7 +139,7 @@ devices {
 	# then the device is accepted. Be careful mixing 'a' and 'r' patterns,
 	# as the combination might produce unexpected results (test changes.)
 	# Run vgscan after changing the filter to regenerate the cache.
-	# 
+	#
 	# Example
 	# Accept every block device:
 	# filter = [ "a|.*|" ]
@@ -151,7 +151,7 @@ devices {
 	# filter = [ "a|loop|", "r|/dev/hdc|", "a|/dev/ide|", "r|.*|" ]
 	# Use anchors to be very specific:
 	# filter = [ "a|^/dev/hda8$|", "r|.*|" ]
-	# 
+	#
 	# This configuration option has an automatic default value.
 	# filter = [ "a|.*|" ]
 
@@ -169,10 +169,10 @@ devices {
 	# List of additional acceptable block device types.
 	# These are of device type names from /proc/devices, followed by the
 	# maximum number of partitions.
-	# 
+	#
 	# Example
 	# types = [ "fd", 16 ]
-	# 
+	#
 	# This configuration option is advanced.
 	# This configuration option does not have a default value defined.
 
@@ -214,7 +214,7 @@ devices {
 	# Configuration option devices/md_component_checks.
 	# The checks LVM should use to detect MD component devices.
 	# MD component devices are block devices used by MD software RAID.
-	# 
+	#
 	# Accepted values:
 	#   auto
 	#     LVM will skip scanning the end of devices when it has other
@@ -225,7 +225,7 @@ devices {
 	#   full
 	#     LVM will scan the start and end of devices for MD superblocks.
 	#     This requires an extra read at the end of devices.
-	# 
+	#
 	# This configuration option has an automatic default value.
 	# md_component_checks = "auto"
 
@@ -367,7 +367,7 @@ allocation {
 	# defined here, it will check whether any of them are attached to the
 	# PVs concerned and then seek to match those PV tags between existing
 	# extents and new extents.
-	# 
+	#
 	# Example
 	# Use the special tag "@*" as a wildcard to match any PV tag:
 	# cling_tag_list = [ "@*" ]
@@ -375,7 +375,7 @@ allocation {
 	# PVs are tagged with either @site1 or @site2 to indicate where
 	# they are situated:
 	# cling_tag_list = [ "@site1", "@site2" ]
-	# 
+	#
 	# This configuration option does not have a default value defined.
 
 	# Configuration option allocation/maximise_cling.
@@ -434,25 +434,25 @@ allocation {
 
 	# Configuration option allocation/cache_metadata_format.
 	# Sets default metadata format for new cache.
-	# 
+	#
 	# Accepted values:
 	#   0  Automatically detected best available format
 	#   1  Original format
 	#   2  Improved 2nd. generation format
-	# 
+	#
 	# This configuration option has an automatic default value.
 	# cache_metadata_format = 0
 
 	# Configuration option allocation/cache_mode.
 	# The default cache mode used for new cache.
-	# 
+	#
 	# Accepted values:
 	#   writethrough
 	#     Data blocks are immediately written from the cache to disk.
 	#   writeback
 	#     Data blocks are written from the cache back to disk after some
 	#     delay to improve performance.
-	# 
+	#
 	# This setting replaces allocation/cache_pool_cachemode.
 	# This configuration option has an automatic default value.
 	# cache_mode = "writethrough"
@@ -501,18 +501,18 @@ allocation {
 
 	# Configuration option allocation/thin_pool_discards.
 	# The discards behaviour of thin pool volumes.
-	# 
+	#
 	# Accepted values:
 	#   ignore
 	#   nopassdown
 	#   passdown
-	# 
+	#
 	# This configuration option has an automatic default value.
 	# thin_pool_discards = "passdown"
 
 	# Configuration option allocation/thin_pool_chunk_size_policy.
 	# The chunk size calculation policy for thin pool volumes.
-	# 
+	#
 	# Accepted values:
 	#   generic
 	#     If thin_pool_chunk_size is defined, use it. Otherwise, calculate
@@ -524,7 +524,7 @@ allocation {
 	#     the chunk size for performance based on device hints exposed in
 	#     sysfs - the optimal_io_size. The chunk size is always at least
 	#     512KiB.
-	# 
+	#
 	# This configuration option has an automatic default value.
 	# thin_pool_chunk_size_policy = "generic"
 
@@ -961,7 +961,7 @@ global {
 	# Configuration option global/mirror_segtype_default.
 	# The segment type used by the short mirroring option -m.
 	# The --type mirror|raid1 option overrides this setting.
-	# 
+	#
 	# Accepted values:
 	#   mirror
 	#     The original RAID1 implementation from LVM/DM. It is
@@ -981,16 +981,16 @@ global {
 	#     handling a failure. This mirror implementation is not
 	#     cluster-aware and cannot be used in a shared (active/active)
 	#     fashion in a cluster.
-	# 
+	#
 	mirror_segtype_default = "@DEFAULT_MIRROR_SEGTYPE@"
 
 	# Configuration option global/support_mirrored_mirror_log.
 	# Enable mirrored 'mirror' log type for testing.
-	# 
+	#
 	# This type is deprecated to create or convert to but can
 	# be enabled to test that activation of existing mirrored
 	# logs and conversion to disk/core works.
-	# 
+	#
 	# Not supported for regular operation!
 	# This configuration option has an automatic default value.
 	# support_mirrored_mirror_log = 0
@@ -1001,7 +1001,7 @@ global {
 	# The --stripes/-i and --mirrors/-m options can both be specified
 	# during the creation of a logical volume to use both striping and
 	# mirroring for the LV. There are two different implementations.
-	# 
+	#
 	# Accepted values:
 	#   raid10
 	#     LVM uses MD's RAID10 personality through DM. This is the
@@ -1011,7 +1011,7 @@ global {
 	#     is done by creating a mirror LV on top of striped sub-LVs,
 	#     effectively creating a RAID 0+1 array. The layering is suboptimal
 	#     in terms of providing redundancy and performance.
-	# 
+	#
 	raid10_segtype_default = "@DEFAULT_RAID10_SEGTYPE@"
 
 	# Configuration option global/sparse_segtype_default.
@@ -1019,7 +1019,7 @@ global {
 	# The --type snapshot|thin option overrides this setting.
 	# The combination of -V and -L options creates a sparse LV. There are
 	# two different implementations.
-	# 
+	#
 	# Accepted values:
 	#   snapshot
 	#     The original snapshot implementation from LVM/DM. It uses an old
@@ -1031,7 +1031,7 @@ global {
 	#     bigger minimal chunk size (64KiB) and uses a separate volume for
 	#     metadata. It has better performance, especially when more data
 	#     is used. It also supports full snapshots.
-	# 
+	#
 	sparse_segtype_default = "@DEFAULT_SPARSE_SEGTYPE@"
 
 	# Configuration option global/lvdisplay_shows_full_device_path.
@@ -1129,20 +1129,20 @@ global {
 	# causing problems. Features include: block_size, discards,
 	# discards_non_power_2, external_origin, metadata_resize,
 	# external_origin_extend, error_if_no_space.
-	# 
+	#
 	# Example
 	# thin_disabled_features = [ "discards", "block_size" ]
-	# 
+	#
 	# This configuration option does not have a default value defined.
 
 	# Configuration option global/cache_disabled_features.
 	# Features to not use in the cache driver.
 	# This can be helpful for testing, or to avoid using a feature that is
 	# causing problems. Features include: policy_mq, policy_smq, metadata2.
-	# 
+	#
 	# Example
 	# cache_disabled_features = [ "policy_smq" ]
-	# 
+	#
 	# This configuration option does not have a default value defined.
 
 	# Configuration option global/cache_check_executable.
@@ -1206,7 +1206,7 @@ global {
 	# or vgimport.) A VG on shared storage devices is accessible only to
 	# the host with a matching system ID. See 'man lvmsystemid' for
 	# information on limitations and correct usage.
-	# 
+	#
 	# Accepted values:
 	#   none
 	#     The host has no system ID.
@@ -1223,7 +1223,7 @@ global {
 	#   file
 	#     Use the contents of another file (system_id_file) to set the
 	#     system ID.
-	# 
+	#
 	system_id_source = "none"
 
 	# Configuration option global/system_id_file.
@@ -1349,7 +1349,7 @@ activation {
 	# If this list is defined, an LV is only activated if it matches an
 	# entry in this list. If this list is undefined, it imposes no limits
 	# on LV activation (all are allowed).
-	# 
+	#
 	# Accepted values:
 	#   vgname
 	#     The VG name is matched exactly and selects all LVs in the VG.
@@ -1363,10 +1363,10 @@ activation {
 	#     or VG. See tags/hosttags. If any host tags exist but volume_list
 	#     is not defined, a default single-entry list containing '@*'
 	#     is assumed.
-	# 
+	#
 	# Example
 	# volume_list = [ "vg1", "vg2/lvol1", "@tag1", "@*" ]
-	# 
+	#
 	# This configuration option does not have a default value defined.
 
 	# Configuration option activation/auto_activation_volume_list.
@@ -1386,7 +1386,7 @@ activation {
 	# commands run directly by a user. A user may also use the 'a' flag
 	# directly to perform auto-activation. Also see pvscan(8) for more
 	# information about auto-activation.
-	# 
+	#
 	# Accepted values:
 	#   vgname
 	#     The VG name is matched exactly and selects all LVs in the VG.
@@ -1400,10 +1400,10 @@ activation {
 	#     or VG. See tags/hosttags. If any host tags exist but volume_list
 	#     is not defined, a default single-entry list containing '@*'
 	#     is assumed.
-	# 
+	#
 	# Example
 	# auto_activation_volume_list = [ "vg1", "vg2/lvol1", "@tag1", "@*" ]
-	# 
+	#
 	# This configuration option does not have a default value defined.
 
 	# Configuration option activation/read_only_volume_list.
@@ -1412,7 +1412,7 @@ activation {
 	# against this list, and if it matches, it is activated in read-only
 	# mode. This overrides the permission setting stored in the metadata,
 	# e.g. from --permission rw.
-	# 
+	#
 	# Accepted values:
 	#   vgname
 	#     The VG name is matched exactly and selects all LVs in the VG.
@@ -1426,10 +1426,10 @@ activation {
 	#     or VG. See tags/hosttags. If any host tags exist but volume_list
 	#     is not defined, a default single-entry list containing '@*'
 	#     is assumed.
-	# 
+	#
 	# Example
 	# read_only_volume_list = [ "vg1", "vg2/lvol1", "@tag1", "@*" ]
-	# 
+	#
 	# This configuration option does not have a default value defined.
 
 	# Configuration option activation/raid_region_size.
@@ -1452,13 +1452,13 @@ activation {
 
 	# Configuration option activation/readahead.
 	# Setting to use when there is no readahead setting in metadata.
-	# 
+	#
 	# Accepted values:
 	#   none
 	#     Disable readahead.
 	#   auto
 	#     Use default value chosen by kernel.
-	# 
+	#
 	# This configuration option has an automatic default value.
 	# readahead = "auto"
 
@@ -1470,7 +1470,7 @@ activation {
 	# performed by dmeventd automatically, and the steps perfomed by the
 	# manual command lvconvert --repair --use-policies.
 	# Automatic handling requires dmeventd to be monitoring the LV.
-	# 
+	#
 	# Accepted values:
 	#   warn
 	#     Use the system log to warn the user that a device in the RAID LV
@@ -1481,7 +1481,7 @@ activation {
 	#   allocate
 	#     Attempt to use any extra physical volumes in the VG as spares and
 	#     replace faulty devices.
-	# 
+	#
 	raid_fault_policy = "warn"
 
 	# Configuration option activation/mirror_image_fault_policy.
@@ -1493,7 +1493,7 @@ activation {
 	# determines the steps perfomed by dmeventd automatically, and the steps
 	# performed by the manual command lvconvert --repair --use-policies.
 	# Automatic handling requires dmeventd to be monitoring the LV.
-	# 
+	#
 	# Accepted values:
 	#   remove
 	#     Simply remove the faulty device and run without it. If the log
@@ -1518,7 +1518,7 @@ activation {
 	#     the redundant nature of the mirror. This policy acts like
 	#     'remove' if no suitable device and space can be allocated for the
 	#     replacement.
-	# 
+	#
 	mirror_image_fault_policy = "remove"
 
 	# Configuration option activation/mirror_log_fault_policy.
@@ -1533,26 +1533,26 @@ activation {
 	# The minimum value is 50 (a smaller value is treated as 50.)
 	# Also see snapshot_autoextend_percent.
 	# Automatic extension requires dmeventd to be monitoring the LV.
-	# 
+	#
 	# Example
 	# Using 70% autoextend threshold and 20% autoextend size, when a 1G
 	# snapshot exceeds 700M, it is extended to 1.2G, and when it exceeds
 	# 840M, it is extended to 1.44G:
 	# snapshot_autoextend_threshold = 70
-	# 
+	#
 	snapshot_autoextend_threshold = 100
 
 	# Configuration option activation/snapshot_autoextend_percent.
 	# Auto-extending a snapshot adds this percent extra space.
 	# The amount of additional space added to a snapshot is this
 	# percent of its current size.
-	# 
+	#
 	# Example
 	# Using 70% autoextend threshold and 20% autoextend size, when a 1G
 	# snapshot exceeds 700M, it is extended to 1.2G, and when it exceeds
 	# 840M, it is extended to 1.44G:
 	# snapshot_autoextend_percent = 20
-	# 
+	#
 	snapshot_autoextend_percent = 20
 
 	# Configuration option activation/thin_pool_autoextend_threshold.
@@ -1561,26 +1561,26 @@ activation {
 	# The minimum value is 50 (a smaller value is treated as 50.)
 	# Also see thin_pool_autoextend_percent.
 	# Automatic extension requires dmeventd to be monitoring the LV.
-	# 
+	#
 	# Example
 	# Using 70% autoextend threshold and 20% autoextend size, when a 1G
 	# thin pool exceeds 700M, it is extended to 1.2G, and when it exceeds
 	# 840M, it is extended to 1.44G:
 	# thin_pool_autoextend_threshold = 70
-	# 
+	#
 	thin_pool_autoextend_threshold = 100
 
 	# Configuration option activation/thin_pool_autoextend_percent.
 	# Auto-extending a thin pool adds this percent extra space.
 	# The amount of additional space added to a thin pool is this
 	# percent of its current size.
-	# 
+	#
 	# Example
 	# Using 70% autoextend threshold and 20% autoextend size, when a 1G
 	# thin pool exceeds 700M, it is extended to 1.2G, and when it exceeds
 	# 840M, it is extended to 1.44G:
 	# thin_pool_autoextend_percent = 20
-	# 
+	#
 	thin_pool_autoextend_percent = 20
 
 	# Configuration option activation/vdo_pool_autoextend_threshold.
@@ -1589,13 +1589,13 @@ activation {
 	# The minimum value is 50 (a smaller value is treated as 50.)
 	# Also see vdo_pool_autoextend_percent.
 	# Automatic extension requires dmeventd to be monitoring the LV.
-	# 
+	#
 	# Example
 	# Using 70% autoextend threshold and 20% autoextend size, when a 10G
 	# VDO pool exceeds 7G, it is extended to 12G, and when it exceeds
 	# 8.4G, it is extended to 14.4G:
 	# vdo_pool_autoextend_threshold = 70
-	# 
+	#
 	# This configuration option has an automatic default value.
 	# vdo_pool_autoextend_threshold = 100
 
@@ -1603,7 +1603,7 @@ activation {
 	# Auto-extending a VDO pool adds this percent extra space.
 	# The amount of additional space added to a VDO pool is this
 	# percent of its current size.
-	# 
+	#
 	# Example
 	# Using 70% autoextend threshold and 20% autoextend size, when a 10G
 	# VDO pool exceeds 7G, it is extended to 12G, and when it exceeds
@@ -1622,10 +1622,10 @@ activation {
 	# pages corresponding to lines that match are not pinned. On some
 	# systems, locale-archive was found to make up over 80% of the memory
 	# used by the process.
-	# 
+	#
 	# Example
 	# mlock_filter = [ "locale/locale-archive", "gconv/gconv-modules.cache" ]
-	# 
+	#
 	# This configuration option is advanced.
 	# This configuration option does not have a default value defined.
 
@@ -1666,7 +1666,7 @@ activation {
 	# Configuration option activation/activation_mode.
 	# How LVs with missing devices are activated.
 	# The --activationmode option overrides this setting.
-	# 
+	#
 	# Accepted values:
 	#   complete
 	#     Only allow activation of an LV if all of the Physical Volumes it
@@ -1681,7 +1681,7 @@ activation {
 	#     could cause data loss with a portion of the LV inaccessible.
 	#     This setting should not normally be used, but may sometimes
 	#     assist with data recovery.
-	# 
+	#
 	activation_mode = "degraded"
 
 	# Configuration option activation/lock_start_list.
@@ -1729,7 +1729,7 @@ activation {
 	# Configuration option metadata/pvmetadatacopies.
 	# Number of copies of metadata to store on each PV.
 	# The --pvmetadatacopies option overrides this setting.
-	# 
+	#
 	# Accepted values:
 	#   2
 	#     Two copies of the VG metadata are stored on the PV, one at the
@@ -1739,7 +1739,7 @@ activation {
 	#   0
 	#     No copies of VG metadata are stored on the PV. This may be
 	#     useful for VGs containing large numbers of PVs.
-	# 
+	#
 	# This configuration option is advanced.
 	# This configuration option has an automatic default value.
 	# pvmetadatacopies = 1
@@ -1889,7 +1889,7 @@ activation {
 	# sequences are copied verbatim. Each special character sequence is
 	# introduced by the '%' character and such sequence is then
 	# substituted with a value as described below.
-	# 
+	#
 	# Accepted values:
 	#   %a
 	#     The abbreviated name of the day of the week according to the
@@ -2012,7 +2012,7 @@ activation {
 	#     The timezone name or abbreviation.
 	#   %%
 	#     A literal '%' character.
-	# 
+	#
 	# This configuration option has an automatic default value.
 	# time_format = "%Y-%m-%d %T %z"
 
@@ -2281,12 +2281,12 @@ dmeventd {
 	# applied to the local machine as a 'host tag'. If this subsection is
 	# empty (has no host_list), then the subsection name is always applied
 	# as a 'host tag'.
-	# 
+	#
 	# Example
 	# The host tag foo is given to all hosts, and the host tag
 	# bar is given to the hosts named machine1 and machine2.
 	# tags { foo { } bar { host_list = [ "machine1", "machine2" ] } }
-	# 
+	#
 	# This configuration section has variable name.
 	# This configuration section has an automatic default value.
 	# tag {
diff --git a/conf/lvmlocal.conf.in b/conf/lvmlocal.conf.in
index 04414bf4e..12214ea26 100644
--- a/conf/lvmlocal.conf.in
+++ b/conf/lvmlocal.conf.in
@@ -28,13 +28,13 @@ local {
 	# main configuration file, e.g. lvm.conf. When used, it must be set to
 	# a unique value among all hosts sharing access to the storage,
 	# e.g. a host name.
-	# 
+	#
 	# Example
 	# Set no system ID:
 	# system_id = ""
 	# Set the system_id to a specific name:
 	# system_id = "host1"
-	# 
+	#
 	# This configuration option has an automatic default value.
 	# system_id = ""
 
diff --git a/lib/config/config.c b/lib/config/config.c
index a25b7db6e..f9ca56677 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -1738,7 +1738,7 @@ static int _out_prefix_fn(const struct dm_config_node *cn, const char *line, voi
 						continue;
 					commentline[0] = '\0';
 				}
-				fprintf(out->fp, "%s# %s\n", line, commentline);
+				fprintf(out->fp, "%s#%s%s\n", line, commentline[0] ? " " : "", commentline);
 				/* withsummary prints only the first comment line. */
 				if (!out->tree_spec->withcomments)
 					break;


