From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 17 Aug 2015 15:53:03 +0000 (UTC)
Subject: master - conf: Regenerate example.conf.
Message-ID: <20150817155303.9C33860E6A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=15e20bb5c01190217969c4b2e42926af3709223c
Commit:        15e20bb5c01190217969c4b2e42926af3709223c
Parent:        80bc87e377cbcc10225e1d2b58d6e84b65b449de
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Aug 17 16:51:43 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Aug 17 16:51:43 2015 +0100

conf: Regenerate example.conf.

---
 conf/example.conf.in |   69 +++++++++++++++++++++++++++++++++----------------
 1 files changed, 46 insertions(+), 23 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index 3900ad4..014aa1a 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -204,7 +204,7 @@ devices {
 
 	# Configuration option devices/default_data_alignment.
 	# Default alignment of the start of a PV data area in MB.
-	# If set to 0, a value of 64KB will be used.
+	# If set to 0, a value of 64KiB will be used.
 	# Set to 1 for 1MiB, 2 for 2MiB, etc.
 	# default_data_alignment = 1
 
@@ -222,7 +222,7 @@ devices {
 	data_alignment_detection = 1
 
 	# Configuration option devices/data_alignment.
-	# Alignment of the start of a PV data area in KB.
+	# Alignment of the start of a PV data area in KiB.
 	# If a PV is placed directly on an md device and
 	# md_chunk_alignment or data_alignment_detection are enabled,
 	# then this setting is ignored.  Otherwise, md_chunk_alignment
@@ -234,10 +234,10 @@ devices {
 	# Detect PV data alignment offset based on sysfs device information.
 	# The start of a PV aligned data area will be shifted by the
 	# alignment_offset exposed in sysfs.  This offset is often 0, but
-	# may be non-zero.  Certain 4KB sector drives that compensate for
+	# may be non-zero.  Certain 4KiB sector drives that compensate for
 	# windows partitioning will have an alignment_offset of 3584 bytes
-	# (sector 7 is the lowest aligned logical block, the 4KB sectors start
-	# at LBA -1, and consequently sector 63 is aligned on a 4KB boundary).
+	# (sector 7 is the lowest aligned logical block, the 4KiB sectors start
+	# at LBA -1, and consequently sector 63 is aligned on a 4KiB boundary).
 	# pvcreate --dataalignmentoffset will skip this detection.
 	data_alignment_offset_detection = 1
 
@@ -282,9 +282,9 @@ devices {
 	require_restorefile_with_uuid = 1
 
 	# Configuration option devices/pv_min_size.
-	# Minimum size (in KB) of block devices which can be used as PVs.
+	# Minimum size in KiB of block devices which can be used as PVs.
 	# In a clustered environment all nodes must use the same value.
-	# Any value smaller than 512KB is ignored.  The previous built-in
+	# Any value smaller than 512KiB is ignored.  The previous built-in
 	# value was 512.
 	pv_min_size = 2048
 
@@ -303,7 +303,7 @@ devices {
 }
 
 # Configuration section allocation.
-# How LVM selects free space for Logical Volumes.
+# How LVM selects space and applies properties to LVs.
 allocation {
 
 	# Configuration option allocation/cling_tag_list.
@@ -348,7 +348,7 @@ allocation {
 	# Look for and erase any signatures while zeroing a new LV.
 	# Zeroing is controlled by the -Z/--zero option, and if not
 	# specified, zeroing is used by default if possible.
-	# Zeroing simply overwrites the first 4 KiB of a new LV
+	# Zeroing simply overwrites the first 4KiB of a new LV
 	# with zeroes and does no signature detection or wiping.
 	# Signature wiping goes beyond zeroing and detects exact
 	# types and positions of signatures within the whole LV.
@@ -374,17 +374,31 @@ allocation {
 	# Cache pool metadata and data will always use different PVs.
 	cache_pool_metadata_require_separate_pvs = 0
 
-	# Configuration option allocation/cache_pool_cachemode.
-	# The default cache mode used for new cache pools.
+	# Configuration option allocation/cache_mode.
+	# The default cache mode used for new cache.
 	# Possible options are: writethrough, writeback.
 	# writethrough - Data blocks are immediately written from
 	# the cache to disk.
 	# writeback - Data blocks are written from the cache back
 	# to disk after some delay to improve performance.
-	# cache_pool_cachemode = "writethrough"
+	# This setting replaces allocation/cache_pool_cachemode.
+	# cache_mode = "writethrough"
+
+	# Configuration option allocation/cache_policy.
+	# The default cache policy used for new cache volume.
+	# For the kernel 4.2 and newer the default policy is smq
+	# (Stochastic multique), otherwise the older mq (Multiqueue),
+	# policy is selected.
+	# This configuration option does not have a default value defined.
+
+	# Configuration section allocation/cache_settings.
+	# Individual settings for policies.
+	# See the help for individual policies for more info.
+	# cache_settings {
+	# }
 
 	# Configuration option allocation/cache_pool_chunk_size.
-	# The minimal chunk size (in kiB) for cache pool volumes.
+	# The minimal chunk size in KiB for cache pool volumes.
 	# Using a chunk_size that is too large can result in wasteful
 	# use of the cache, where small reads and writes can cause
 	# large sections of an LV to be mapped into the cache.  However,
@@ -392,8 +406,8 @@ allocation {
 	# overhead trying to manage the numerous chunks that become mapped
 	# into the cache.  The former is more of a problem than the latter
 	# in most cases, so we default to a value that is on the smaller
-	# end of the spectrum.  Supported values range from 32(kiB) to
-	# 1048576 in multiples of 32.
+	# end of the spectrum.  Supported values range from 32KiB to
+	# 1GiB in multiples of 32.
 	# This configuration option does not have a default value defined.
 
 	# Configuration option allocation/thin_pool_metadata_require_separate_pvs.
@@ -424,17 +438,17 @@ allocation {
 	# thin_pool_chunk_size_policy = "generic"
 
 	# Configuration option allocation/thin_pool_chunk_size.
-	# The minimal chunk size (in KB) for thin pool volumes.
+	# The minimal chunk size in KiB for thin pool volumes.
 	# Larger chunk sizes may improve performance for plain
 	# thin volumes, however using them for snapshot volumes
 	# is less efficient, as it consumes more space and takes
 	# extra time for copying.  When unset, lvm tries to estimate
-	# chunk size starting from 64KB.  Supported values are in
-	# the range 64 to 1048576.
+	# chunk size starting from 64KiB.  Supported values are in
+	# the range 64KiB to 1GiB.
 	# This configuration option does not have a default value defined.
 
 	# Configuration option allocation/physical_extent_size.
-	# Default physical extent size to use for new VGs (in KB).
+	# Default physical extent size in KiB to use for new VGs.
 	# physical_extent_size = 4096
 }
 
@@ -779,11 +793,11 @@ global {
 	sparse_segtype_default = "@DEFAULT_SPARSE_SEGTYPE@"
 
 	# Configuration option global/lvdisplay_shows_full_device_path.
+	# Enable this to reinstate the previous lvdisplay name format.
 	# The default format for displaying LV names in lvdisplay was changed
 	# in version 2.02.89 to show the LV name and path separately.
 	# Previously this was always shown as /dev/vgname/lvname even when that
 	# was never a valid path in the /dev filesystem.
-	# Enable this option to reinstate the previous format.
 	# lvdisplay_shows_full_device_path = 0
 
 	# Configuration option global/use_lvmetad.
@@ -889,6 +903,15 @@ global {
 	# thin_disabled_features = [ "discards", "block_size" ]
 	# This configuration option does not have a default value defined.
 
+	# Configuration option global/cache_disabled_features.
+	# Features to not use in the cache driver.
+	# This can be helpful for testing, or to avoid
+	# using a feature that is causing problems.
+	# Features: policy_mq, policy_smq.
+	# Example:
+	# cache_disabled_features = [ "policy_smq" ]
+	# This configuration option does not have a default value defined.
+
 	# Configuration option global/cache_check_executable.
 	# The full path to the cache_check command.
 	# LVM uses this command to check that a cache metadata
@@ -1031,12 +1054,12 @@ activation {
 	use_linear_target = 1
 
 	# Configuration option activation/reserved_stack.
-	# Stack size in KB to reserve for use while devices are suspended.
+	# Stack size in KiB to reserve for use while devices are suspended.
 	# Insufficent reserve risks I/O deadlock during device suspension.
 	reserved_stack = 64
 
 	# Configuration option activation/reserved_memory.
-	# Memory size in KB to reserve for use while devices are suspended.
+	# Memory size in KiB to reserve for use while devices are suspended.
 	# Insufficent reserve risks I/O deadlock during device suspension.
 	reserved_memory = 8192
 
@@ -1267,7 +1290,7 @@ activation {
 	monitoring = 1
 
 	# Configuration option activation/polling_interval.
-	# Check pvmove or lvconvert progress at this interval (seconds)
+	# Check pvmove or lvconvert progress at this interval (seconds).
 	# When pvmove or lvconvert must wait for the kernel to finish
 	# synchronising or merging data, they check and report progress
 	# at intervals of this number of seconds.


