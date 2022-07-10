From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sun, 10 Jul 2022 23:22:17 +0000 (GMT)
Subject: main - vdo: use defines also for configuration defines
Message-ID: <20220710232217.44E03385734A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b5c8e591ed9ee30b67e79d60705d3c0bb8509a2a
Commit:        b5c8e591ed9ee30b67e79d60705d3c0bb8509a2a
Parent:        f445624c339a5c1436a47d2b51046869f183eb03
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 24 15:54:08 2022 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 11 01:18:24 2022 +0200

vdo: use defines also for configuration defines

Keep single source for most of values printed in lvm.conf
(still needs some conversion)

Correct max for logical threads to 60
(we may refuse some older configuration which might eventually
user higher numbers - but so far let's assume no user have ever set this
as it's been non-trivial and if would complicate code unnecessarily.)

Accept maximum of 4PiB for virtual size of VDO LV
(lvm2 will drop 'header borders to 0 for this case').
---
 conf/example.conf.in           |  9 +++----
 device_mapper/vdo/vdo_limits.h | 55 ++++++++++++++++++++++--------------------
 device_mapper/vdo/vdo_target.c | 11 +++++----
 lib/config/config_settings.h   | 32 +++++++++++++++---------
 4 files changed, 60 insertions(+), 47 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index 94f7a23fd..4e5482fee 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -625,13 +625,12 @@ allocation {
 	# Enables or disables whether VDO volume should tag its latency-critical
 	# writes with the REQ_SYNC flag. Some device mapper targets such as dm-raid5
 	# process writes with this flag at a higher priority.
-	# Default is enabled.
 	# This configuration option has an automatic default value.
 	# vdo_use_metadata_hints = 1
 
 	# Configuration option allocation/vdo_minimum_io_size.
 	# The minimum IO size for VDO volume to accept, in bytes.
-	# Valid values are 512 or 4096. The recommended and default value is 4096.
+	# Valid values are 512 or 4096. The recommended value is 4096.
 	# This configuration option has an automatic default value.
 	# vdo_minimum_io_size = 4096
 
@@ -684,7 +683,7 @@ allocation {
 	# Configuration option allocation/vdo_bio_threads.
 	# Specifies the number of threads to use for submitting I/O
 	# operations to the storage device of VDO volume.
-	# The value must be in range [1..100]
+	# The value must be in range [1..100].
 	# Each additional thread after the first will use an additional 18MiB of RAM,
 	# plus 1.12 MiB of RAM per megabyte of configured read cache size.
 	# This configuration option has an automatic default value.
@@ -698,7 +697,7 @@ allocation {
 
 	# Configuration option allocation/vdo_cpu_threads.
 	# Specifies the number of threads to use for CPU-intensive work such as
-	# hashing or compression for VDO volume. The value must be in range [1..100]
+	# hashing or compression for VDO volume. The value must be in range [1..100].
 	# This configuration option has an automatic default value.
 	# vdo_cpu_threads = 2
 
@@ -716,7 +715,7 @@ allocation {
 	# processing based on the hash value computed from the block data.
 	# A logical thread count of 9 or more will require explicitly specifying
 	# a sufficiently large block map cache size, as well.
-	# The value must be in range [0..100].
+	# The value must be in range [0..60].
 	# vdo_hash_zone_threads, vdo_logical_threads and vdo_physical_threads must be
 	# either all zero or all non-zero.
 	# This configuration option has an automatic default value.
diff --git a/device_mapper/vdo/vdo_limits.h b/device_mapper/vdo/vdo_limits.h
index e145100b1..db365ace2 100644
--- a/device_mapper/vdo/vdo_limits.h
+++ b/device_mapper/vdo/vdo_limits.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2018 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2018-2022 Red Hat, Inc. All rights reserved.
  *
  * This file is part of the device-mapper userspace tools.
  *
@@ -15,49 +15,52 @@
 #ifndef DEVICE_MAPPER_VDO_LIMITS_H
 #define DEVICE_MAPPER_VDO_LIMITS_H
 
+#ifndef SECTOR_SHIFT
+#define SECTOR_SHIFT 9L
+#endif
+
 #define DM_VDO_BLOCK_SIZE			UINT64_C(8)		// 4KiB in sectors
+#define DM_VDO_BLOCK_SIZE_KB			(DM_VDO_BLOCK_SIZE << SECTOR_SHIFT)
 
 #define DM_VDO_BLOCK_MAP_CACHE_SIZE_MINIMUM_MB	(128)			// 128MiB
 #define DM_VDO_BLOCK_MAP_CACHE_SIZE_MAXIMUM_MB	(16 * 1024 * 1024 - 1)	// 16TiB - 1
 #define DM_VDO_BLOCK_MAP_CACHE_SIZE_MINIMUM_PER_LOGICAL_THREAD  (4096 * DM_VDO_BLOCK_SIZE_KB)
 
-#define DM_VDO_BLOCK_MAP_ERA_LENGTH_MINIMUM	(1)
-#define DM_VDO_BLOCK_MAP_ERA_LENGTH_MAXIMUM	(16380)
+#define DM_VDO_BLOCK_MAP_ERA_LENGTH_MINIMUM	1
+#define DM_VDO_BLOCK_MAP_ERA_LENGTH_MAXIMUM	16380
 
-#define DM_VDO_INDEX_MEMORY_SIZE_MINIMUM_MB	(256)			// 0.25 GiB
+#define DM_VDO_INDEX_MEMORY_SIZE_MINIMUM_MB	256			// 0.25 GiB
 #define DM_VDO_INDEX_MEMORY_SIZE_MAXIMUM_MB	(1024 * 1024 * 1024)	// 1TiB
 
-//#define DM_VDO_READ_CACHE_SIZE_MINIMUM_MB	(0)
-#define DM_VDO_READ_CACHE_SIZE_MAXIMUM_MB	(16 * 1024 * 1024 - 1)	// 16TiB - 1
-
-#define DM_VDO_SLAB_SIZE_MINIMUM_MB		(128)			// 128MiB
+#define DM_VDO_SLAB_SIZE_MINIMUM_MB		128			// 128MiB
 #define DM_VDO_SLAB_SIZE_MAXIMUM_MB		(32 * 1024)		// 32GiB
+#define DM_VDO_SLABS_MAXIMUM			8192
 
-//#define DM_VDO_LOGICAL_SIZE_MINIMUM_MB	(0)
-#define DM_VDO_LOGICAL_SIZE_MAXIMUM_MB	(UINT64_C(4) * 1024 * 1024 * 1024) // 4PiB
+#define DM_VDO_LOGICAL_SIZE_MAXIMUM	(UINT64_C(4) * 1024 * 1024 * 1024 * 1024 * 1024 >> SECTOR_SHIFT) // 4PiB
+#define DM_VDO_PHYSICAL_SIZE_MAXIMUM	(UINT64_C(64) * DM_VDO_BLOCK_SIZE_KB * 1024 * 1024 * 1024 >> SECTOR_SHIFT) // 256TiB
 
-//#define DM_VDO_ACK_THREADS_MINIMUM		(0)
-#define DM_VDO_ACK_THREADS_MAXIMUM		(100)
+#define DM_VDO_ACK_THREADS_MINIMUM		0
+#define DM_VDO_ACK_THREADS_MAXIMUM		100
 
-#define DM_VDO_BIO_THREADS_MINIMUM		(1)
-#define DM_VDO_BIO_THREADS_MAXIMUM		(100)
+#define DM_VDO_BIO_THREADS_MINIMUM		1
+#define DM_VDO_BIO_THREADS_MAXIMUM		100
 
-#define DM_VDO_BIO_ROTATION_MINIMUM		(1)
-#define DM_VDO_BIO_ROTATION_MAXIMUM		(1024)
+#define DM_VDO_BIO_ROTATION_MINIMUM		1
+#define DM_VDO_BIO_ROTATION_MAXIMUM		1024
 
-#define DM_VDO_CPU_THREADS_MINIMUM		(1)
-#define DM_VDO_CPU_THREADS_MAXIMUM		(100)
+#define DM_VDO_CPU_THREADS_MINIMUM		1
+#define DM_VDO_CPU_THREADS_MAXIMUM		100
 
-//#define DM_VDO_HASH_ZONE_THREADS_MINIMUM	(0)
-#define DM_VDO_HASH_ZONE_THREADS_MAXIMUM	(100)
+#define DM_VDO_HASH_ZONE_THREADS_MINIMUM	0
+#define DM_VDO_HASH_ZONE_THREADS_MAXIMUM	100
 
-//#define DM_VDO_LOGICAL_THREADS_MINIMUM	(0)
-#define DM_VDO_LOGICAL_THREADS_MAXIMUM		(100)
+#define DM_VDO_LOGICAL_THREADS_MINIMUM		0
+#define DM_VDO_LOGICAL_THREADS_MAXIMUM		60
 
-//#define DM_VDO_PHYSICAL_THREADS_MINIMUM	(0)
-#define DM_VDO_PHYSICAL_THREADS_MAXIMUM		(16)
+#define DM_VDO_PHYSICAL_THREADS_MINIMUM		0
+#define DM_VDO_PHYSICAL_THREADS_MAXIMUM		16
 
-#define DM_VDO_MAX_DISCARD_MINIMUM		(1)
-#define DM_VDO_MAX_DISCARD_MAXIMUM		(UINT32_MAX / 4096)
+#define DM_VDO_MAX_DISCARD_MINIMUM		1
+#define DM_VDO_MAX_DISCARD_MAXIMUM		(UINT32_MAX / (uint32_t)(DM_VDO_BLOCK_SIZE_KB))
 
 #endif // DEVICE_MAPPER_VDO_LIMITS_H
diff --git a/device_mapper/vdo/vdo_target.c b/device_mapper/vdo/vdo_target.c
index 0e5abd162..3ebe0592e 100644
--- a/device_mapper/vdo/vdo_target.c
+++ b/device_mapper/vdo/vdo_target.c
@@ -18,14 +18,15 @@
 #include "vdo_limits.h"
 #include "target.h"
 
+/* validate vdo target parameters and  'vdo_size' in sectors */
 bool dm_vdo_validate_target_params(const struct dm_vdo_target_params *vtp,
 				   uint64_t vdo_size)
 {
 	bool valid = true;
 
 	/* 512 or 4096 bytes only ATM */
-	if ((vtp->minimum_io_size != 1) &&
-	    (vtp->minimum_io_size != 8)) {
+	if ((vtp->minimum_io_size != (512 >> SECTOR_SHIFT)) &&
+	    (vtp->minimum_io_size != (4096 >> SECTOR_SHIFT))) {
 		log_error("VDO minimum io size %u is unsupported.",
 			  vtp->minimum_io_size);
 		valid = false;
@@ -127,10 +128,10 @@ bool dm_vdo_validate_target_params(const struct dm_vdo_target_params *vtp,
 		valid = false;
 	}
 
-	if (vdo_size >= (DM_VDO_LOGICAL_SIZE_MAXIMUM_MB * UINT64_C(1024 * 2))) {
+	if (vdo_size > DM_VDO_LOGICAL_SIZE_MAXIMUM) {
 		log_error("VDO logical size is by " FMTu64 "KiB bigger then limit " FMTu64 "TiB.",
-			  (vdo_size - (DM_VDO_LOGICAL_SIZE_MAXIMUM_MB * UINT64_C(1024 * 2))) / 2,
-			  DM_VDO_LOGICAL_SIZE_MAXIMUM_MB / UINT64_C(1024) / UINT64_C(1024));
+			  (vdo_size - DM_VDO_LOGICAL_SIZE_MAXIMUM) / 2,
+			  DM_VDO_LOGICAL_SIZE_MAXIMUM / (UINT64_C(1024) * 1024 * 1024 * 1024 >> SECTOR_SHIFT));
 		valid = false;
 	}
 
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index bda6207d7..e97e12152 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -118,6 +118,7 @@
  * the previous default value was set (uncommented) in lvm.conf.
  */
 #include "lib/config/defaults.h"
+#include "device_mapper/vdo/vdo_limits.h"
 
 cfg_section(root_CFG_SECTION, "(root)", root_CFG_SECTION, 0, vsn(0, 0, 0), 0, NULL, NULL)
 
@@ -708,12 +709,11 @@ cfg(allocation_vdo_use_deduplication_CFG, "vdo_use_deduplication", allocation_CF
 cfg(allocation_vdo_use_metadata_hints_CFG, "vdo_use_metadata_hints", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_VDO_USE_METADATA_HINTS, VDO_1ST_VSN, NULL, 0, NULL,
 	"Enables or disables whether VDO volume should tag its latency-critical\n"
 	"writes with the REQ_SYNC flag. Some device mapper targets such as dm-raid5\n"
-	"process writes with this flag at a higher priority.\n"
-	"Default is enabled.\n")
+	"process writes with this flag at a higher priority.\n")
 
 cfg(allocation_vdo_minimum_io_size_CFG, "vdo_minimum_io_size", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_VDO_MINIMUM_IO_SIZE, VDO_1ST_VSN, NULL, 0, NULL,
 	"The minimum IO size for VDO volume to accept, in bytes.\n"
-	"Valid values are 512 or 4096. The recommended and default value is 4096.\n")
+	"Valid values are 512 or 4096. The recommended value is 4096.\n")
 
 cfg(allocation_vdo_block_map_cache_size_mb_CFG, "vdo_block_map_cache_size_mb", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_VDO_BLOCK_MAP_CACHE_SIZE_MB, VDO_1ST_VSN, NULL, 0, NULL,
 	"Specifies the amount of memory in MiB allocated for caching block map\n"
@@ -726,7 +726,8 @@ cfg(allocation_vdo_block_map_era_length_CFG, "vdo_block_map_period", allocation_
 	"The speed with which the block map cache writes out modified block map pages.\n"
 	"A smaller era length is likely to reduce the amount time spent rebuilding,\n"
 	"at the cost of increased block map writes during normal operation.\n"
-	"The maximum and recommended value is 16380; the minimum value is 1.\n")
+	"The maximum and recommended value is " DM_TO_STRING(DM_VDO_BLOCK_MAP_ERA_LENGTH_MAXIMUM)
+	"; the minimum value is " DM_TO_STRING(DM_VDO_BLOCK_MAP_ERA_LENGTH_MINIMUM) ".\n")
 
 cfg(allocation_vdo_check_point_frequency_CFG, "vdo_check_point_frequency", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_VDO_CHECK_POINT_FREQUENCY, VDO_1ST_VSN, NULL, 0, NULL,
 	"The default check point frequency for VDO volume.\n")
@@ -748,27 +749,34 @@ cfg(allocation_vdo_slab_size_mb_CFG, "vdo_slab_size_mb", allocation_CFG_SECTION,
 cfg(allocation_vdo_ack_threads_CFG, "vdo_ack_threads", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_VDO_ACK_THREADS, VDO_1ST_VSN, NULL, 0, NULL,
 	"Specifies the number of threads to use for acknowledging\n"
 	"completion of requested VDO I/O operations.\n"
-	"The value must be at in range [0..100].\n")
+	"The value must be at in range [" DM_TO_STRING(DM_VDO_ACK_THREADS_MINIMUM) ".."
+	DM_TO_STRING(DM_VDO_ACK_THREADS_MAXIMUM) "].\n")
 
 cfg(allocation_vdo_bio_threads_CFG, "vdo_bio_threads", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_VDO_BIO_THREADS, VDO_1ST_VSN, NULL, 0, NULL,
 	"Specifies the number of threads to use for submitting I/O\n"
 	"operations to the storage device of VDO volume.\n"
-	"The value must be in range [1..100]\n"
+	"The value must be in range [" DM_TO_STRING(DM_VDO_BIO_THREADS_MINIMUM) ".."
+	DM_TO_STRING(DM_VDO_BIO_THREADS_MAXIMUM) "].\n"
 	"Each additional thread after the first will use an additional 18MiB of RAM,\n"
 	"plus 1.12 MiB of RAM per megabyte of configured read cache size.\n")
 
 cfg(allocation_vdo_bio_rotation_CFG, "vdo_bio_rotation", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_VDO_BIO_ROTATION, VDO_1ST_VSN, NULL, 0, NULL,
 	"Specifies the number of I/O operations to enqueue for each bio-submission\n"
-	"thread before directing work to the next. The value must be in range [1..1024].\n")
+	"thread before directing work to the next. The value must be in range ["
+	DM_TO_STRING(DM_VDO_BIO_ROTATION_MINIMUM) ".."
+	DM_TO_STRING(DM_VDO_BIO_ROTATION_MAXIMUM) "].\n")
 
 cfg(allocation_vdo_cpu_threads_CFG, "vdo_cpu_threads", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_VDO_CPU_THREADS, VDO_1ST_VSN, NULL, 0, NULL,
 	"Specifies the number of threads to use for CPU-intensive work such as\n"
-	"hashing or compression for VDO volume. The value must be in range [1..100]\n")
+	"hashing or compression for VDO volume. The value must be in range ["
+	DM_TO_STRING(DM_VDO_CPU_THREADS_MINIMUM) ".."
+	DM_TO_STRING(DM_VDO_CPU_THREADS_MAXIMUM) "].\n")
 
 cfg(allocation_vdo_hash_zone_threads_CFG, "vdo_hash_zone_threads", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_VDO_HASH_ZONE_THREADS, VDO_1ST_VSN, NULL, 0, NULL,
 	"Specifies the number of threads across which to subdivide parts of the VDO\n"
 	"processing based on the hash value computed from the block data.\n"
-	"The value must be at in range [0..100].\n"
+	"The value must be at in range [" DM_TO_STRING(DM_VDO_HASH_ZONE_THREADS_MINIMUM) ".."
+	DM_TO_STRING(DM_VDO_HASH_ZONE_THREADS_MAXIMUM) "].\n"
 	"vdo_hash_zone_threads, vdo_logical_threads and vdo_physical_threads must be\n"
 	"either all zero or all non-zero.\n")
 
@@ -777,7 +785,8 @@ cfg(allocation_vdo_logical_threads_CFG, "vdo_logical_threads", allocation_CFG_SE
 	"processing based on the hash value computed from the block data.\n"
 	"A logical thread count of 9 or more will require explicitly specifying\n"
 	"a sufficiently large block map cache size, as well.\n"
-	"The value must be in range [0..100].\n"
+	"The value must be in range [" DM_TO_STRING(DM_VDO_LOGICAL_THREADS_MINIMUM) ".."
+	DM_TO_STRING(DM_VDO_LOGICAL_THREADS_MAXIMUM) "].\n"
 	"vdo_hash_zone_threads, vdo_logical_threads and vdo_physical_threads must be\n"
 	"either all zero or all non-zero.\n")
 
@@ -785,7 +794,8 @@ cfg(allocation_vdo_physical_threads_CFG, "vdo_physical_threads", allocation_CFG_
 	"Specifies the number of threads across which to subdivide parts of the VDO\n"
 	"processing based on physical block addresses.\n"
 	"Each additional thread after the first will use an additional 10MiB of RAM.\n"
-	"The value must be in range [0..16].\n"
+	"The value must be in range [" DM_TO_STRING(DM_VDO_PHYSICAL_THREADS_MINIMUM) ".."
+	DM_TO_STRING(DM_VDO_PHYSICAL_THREADS_MAXIMUM) "].\n"
 	"vdo_hash_zone_threads, vdo_logical_threads and vdo_physical_threads must be\n"
 	"either all zero or all non-zero.\n")
 

