From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 8 Jan 2019 07:16:42 -0500
Subject: master - vdo: regenerate config
Message-ID: <201901081216.x08CGgjO031891@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=54a569be4068d7e08ad7d6d2f6e0ee64dad0797e
Commit:        54a569be4068d7e08ad7d6d2f6e0ee64dad0797e
Parent:        61e378c4e72096be64cb5ee0a26cf976ad3a75e9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jan 8 13:04:42 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jan 8 13:13:57 2019 +0100

vdo: regenerate config

---
 conf/example.conf.in         |   51 +++++++++++++++++++++++-------------------
 lib/config/config_settings.h |    6 ++--
 2 files changed, 31 insertions(+), 26 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index 85465f5..39584b3 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -497,10 +497,19 @@ allocation {
 	# This configuration option has an automatic default value.
 	# vdo_use_deduplication = 1
 
-	# Configuration option allocation/vdo_emulate_512_sectors.
-	# Specifies that the VDO volume is to emulate a 512 byte block device.
+	# Configuration option allocation/vdo_use_metadata_hints.
+	# Enables or disables whether VDO volume should tag its latency-critical
+	# writes with the REQ_SYNC flag. Some device mapper targets such as dm-raid5
+	# process writes with this flag at a higher priority.
+	# Default is enabled.
 	# This configuration option has an automatic default value.
-	# vdo_emulate_512_sectors = 0
+	# vdo_use_metadata_hints = 1
+
+	# Configuration option allocation/vdo_minimum_io_size.
+	# The minimum IO size for VDO volume to accept, in bytes.
+	# Valid values are 512 or 4096. The recommended and default value is 4096.
+	# This configuration option has an automatic default value.
+	# vdo_minimum_io_size = 4096
 
 	# Configuration option allocation/vdo_block_map_cache_size_mb.
 	# Specifies the amount of memory in MiB allocated for caching block map
@@ -511,10 +520,10 @@ allocation {
 	# vdo_block_map_cache_size_mb = 128
 
 	# Configuration option allocation/vdo_block_map_period.
-	# Tunes the quantity of block map updates that can accumulate
-	# before cache pages are flushed to disk. The value must be
-	# at least 1 and less then 16380.
-	# A lower value means shorter recovery time but lower performance.
+	# The speed with which the block map cache writes out modified block map pages.
+	# A smaller era length is likely to reduce the amount time spent rebuilding,
+	# at the cost of increased block map writes during normal operation.
+	# The maximum and recommended value is 16380; the minimum value is 1.
 	# This configuration option has an automatic default value.
 	# vdo_block_map_period = 16380
 
@@ -534,22 +543,6 @@ allocation {
 	# This configuration option has an automatic default value.
 	# vdo_index_memory_size_mb = 256
 
-	# Configuration option allocation/vdo_use_read_cache.
-	# Enables or disables the read cache within the VDO volume.
-	# The cache should be enabled if write workloads are expected
-	# to have high levels of deduplication, or for read intensive
-	# workloads of highly compressible data.
-	# This configuration option has an automatic default value.
-	# vdo_use_read_cache = 0
-
-	# Configuration option allocation/vdo_read_cache_size_mb.
-	# Specifies the extra VDO volume read cache size in MiB.
-	# This space is in addition to a system-defined minimum.
-	# The value must be less then 16TiB and 1.12 MiB of memory
-	# will be used per MiB of read cache specified, per bio thread.
-	# This configuration option has an automatic default value.
-	# vdo_read_cache_size_mb = 0
-
 	# Configuration option allocation/vdo_slab_size_mb.
 	# Specifies the size in MiB of the increment by which a VDO is grown.
 	# Using a smaller size constrains the total maximum physical size
@@ -625,6 +618,18 @@ allocation {
 	#         Data which has not been flushed is not guaranteed to persist in this mode.
 	# This configuration option has an automatic default value.
 	# vdo_write_policy = "auto"
+
+	# Configuration option allocation/vdo_max_discard.
+	# Specified te maximum size of discard bio accepted, in 4096 byte blocks.
+	# I/O requests to a VDO volume are normally split into 4096-byte blocks,
+	# and processed up to 2048 at a time. However, discard requests to a VDO volume
+	# can be automatically split to a larger size, up to <max discard> 4096-byte blocks
+	# in a single bio, and are limited to 1500 at a time.
+	# Increasing this value may provide better overall performance, at the cost of
+	# increased latency for the individual discard requests.
+	# The default and minimum is 1. The maximum is UINT_MAX / 4096.
+	# This configuration option has an automatic default value.
+	# vdo_max_discard = 1
 }
 
 # Configuration section log.
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index eedb7cd..248d204 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -660,12 +660,12 @@ cfg(allocation_vdo_use_sparse_index_CFG, "vdo_use_sparse_index", allocation_CFG_
 // vdo format
 cfg(allocation_vdo_index_memory_size_mb_CFG, "vdo_index_memory_size_mb", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_VDO_INDEX_MEMORY_SIZE_MB, VDO_1ST_VSN, NULL, 0, NULL,
 	"Specifies the amount of index memory in MiB for VDO volume.\n"
-	"The value must be at least 256MiB and at most 1TiB.")
+	"The value must be at least 256MiB and at most 1TiB.\n")
 
 cfg(allocation_vdo_slab_size_mb_CFG, "vdo_slab_size_mb", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_VDO_SLAB_SIZE_MB, VDO_1ST_VSN, NULL, 0, NULL,
 	"Specifies the size in MiB of the increment by which a VDO is grown.\n"
 	"Using a smaller size constrains the total maximum physical size\n"
-	"that can be accommodated. Must be a power of two between 128MiB and 32GiB.")
+	"that can be accommodated. Must be a power of two between 128MiB and 32GiB.\n")
 
 cfg(allocation_vdo_ack_threads_CFG, "vdo_ack_threads", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_VDO_ACK_THREADS, VDO_1ST_VSN, NULL, 0, NULL,
 	"Specifies the number of threads to use for acknowledging\n"
@@ -692,7 +692,7 @@ cfg(allocation_vdo_hash_zone_threads_CFG, "vdo_hash_zone_threads", allocation_CF
 	"processing based on the hash value computed from the block data.\n"
 	"The value must be at in range [0..100].\n"
 	"vdo_hash_zone_threads, vdo_logical_threads and vdo_physical_threads must be\n"
-	"either all zero or all non-zero.")
+	"either all zero or all non-zero.\n")
 
 cfg(allocation_vdo_logical_threads_CFG, "vdo_logical_threads", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_VDO_LOGICAL_THREADS, VDO_1ST_VSN, NULL, 0, NULL,
 	"Specifies the number of threads across which to subdivide parts of the VDO\n"


