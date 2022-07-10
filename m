From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sun, 10 Jul 2022 23:22:18 +0000 (GMT)
Subject: main - vdo: report supported range in error path
Message-ID: <20220710232218.64A63385737B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9f3eff002cc229d3c22dfd7db6da69dadc0bd460
Commit:        9f3eff002cc229d3c22dfd7db6da69dadc0bd460
Parent:        b5c8e591ed9ee30b67e79d60705d3c0bb8509a2a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Jul 9 21:28:40 2022 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 11 01:18:24 2022 +0200

vdo: report supported range in error path

---
 device_mapper/vdo/vdo_target.c | 63 ++++++++++++++++++++++++++++++------------
 1 file changed, 45 insertions(+), 18 deletions(-)

diff --git a/device_mapper/vdo/vdo_target.c b/device_mapper/vdo/vdo_target.c
index 3ebe0592e..ab3fff26a 100644
--- a/device_mapper/vdo/vdo_target.c
+++ b/device_mapper/vdo/vdo_target.c
@@ -27,81 +27,108 @@ bool dm_vdo_validate_target_params(const struct dm_vdo_target_params *vtp,
 	/* 512 or 4096 bytes only ATM */
 	if ((vtp->minimum_io_size != (512 >> SECTOR_SHIFT)) &&
 	    (vtp->minimum_io_size != (4096 >> SECTOR_SHIFT))) {
-		log_error("VDO minimum io size %u is unsupported.",
+		log_error("VDO minimum io size %u is unsupported [512, 4096].",
 			  vtp->minimum_io_size);
 		valid = false;
 	}
 
 	if ((vtp->block_map_cache_size_mb < DM_VDO_BLOCK_MAP_CACHE_SIZE_MINIMUM_MB) ||
 	    (vtp->block_map_cache_size_mb > DM_VDO_BLOCK_MAP_CACHE_SIZE_MAXIMUM_MB)) {
-		log_error("VDO block map cache size %u out of range.",
-			  vtp->block_map_cache_size_mb);
+		log_error("VDO block map cache size %u MiB is out of range [%u..%u].",
+			  vtp->block_map_cache_size_mb,
+			  DM_VDO_BLOCK_MAP_CACHE_SIZE_MINIMUM_MB,
+			  DM_VDO_BLOCK_MAP_CACHE_SIZE_MAXIMUM_MB);
 		valid = false;
 	}
 
 	if ((vtp->block_map_era_length < DM_VDO_BLOCK_MAP_ERA_LENGTH_MINIMUM) ||
 	    (vtp->block_map_era_length > DM_VDO_BLOCK_MAP_ERA_LENGTH_MAXIMUM)) {
-		log_error("VDO block map era length %u out of range.",
-			  vtp->block_map_era_length);
+		log_error("VDO block map era length %u is out of range [%u..%u].",
+			  vtp->block_map_era_length,
+			  DM_VDO_BLOCK_MAP_ERA_LENGTH_MINIMUM,
+			  DM_VDO_BLOCK_MAP_ERA_LENGTH_MAXIMUM);
 		valid = false;
 	}
 
 	if ((vtp->index_memory_size_mb < DM_VDO_INDEX_MEMORY_SIZE_MINIMUM_MB) ||
 	    (vtp->index_memory_size_mb > DM_VDO_INDEX_MEMORY_SIZE_MAXIMUM_MB)) {
-		log_error("VDO index memory size %u out of range.",
-			  vtp->index_memory_size_mb);
+		log_error("VDO index memory size %u MiB is out of range [%u..%u].",
+			  vtp->index_memory_size_mb,
+			  DM_VDO_INDEX_MEMORY_SIZE_MINIMUM_MB,
+			  DM_VDO_INDEX_MEMORY_SIZE_MAXIMUM_MB);
 		valid = false;
 	}
 
 	if ((vtp->slab_size_mb < DM_VDO_SLAB_SIZE_MINIMUM_MB) ||
 	    (vtp->slab_size_mb > DM_VDO_SLAB_SIZE_MAXIMUM_MB)) {
-		log_error("VDO slab size %u out of range.",
-			  vtp->slab_size_mb);
+		log_error("VDO slab size %u MiB is out of range [%u..%u].",
+			  vtp->slab_size_mb,
+			  DM_VDO_SLAB_SIZE_MINIMUM_MB,
+			  DM_VDO_SLAB_SIZE_MAXIMUM_MB);
 		valid = false;
 	}
 
 	if ((vtp->max_discard < DM_VDO_MAX_DISCARD_MINIMUM) ||
 	    (vtp->max_discard > DM_VDO_MAX_DISCARD_MAXIMUM)) {
-		log_error("VDO max discard %u out of range.",
-			  vtp->max_discard);
+		log_error("VDO max discard %u is out of range [%u..%u].",
+			  vtp->max_discard,
+			  DM_VDO_MAX_DISCARD_MINIMUM,
+			  DM_VDO_MAX_DISCARD_MAXIMUM);
 		valid = false;
 	}
 
 	if (vtp->ack_threads > DM_VDO_ACK_THREADS_MAXIMUM) {
-		log_error("VDO ack threads %u out of range.", vtp->ack_threads);
+		log_error("VDO ack threads %u is out of range [0..%u].",
+			  vtp->ack_threads,
+			  DM_VDO_ACK_THREADS_MAXIMUM);
 		valid = false;
 	}
 
 	if ((vtp->bio_threads < DM_VDO_BIO_THREADS_MINIMUM) ||
 	    (vtp->bio_threads > DM_VDO_BIO_THREADS_MAXIMUM)) {
-		log_error("VDO bio threads %u out of range.", vtp->bio_threads);
+		log_error("VDO bio threads %u is out of range [%u..%u].",
+			  vtp->bio_threads,
+			  DM_VDO_BIO_THREADS_MINIMUM,
+			  DM_VDO_BIO_THREADS_MAXIMUM);
 		valid = false;
 	}
 
 	if ((vtp->bio_rotation < DM_VDO_BIO_ROTATION_MINIMUM) ||
 	    (vtp->bio_rotation > DM_VDO_BIO_ROTATION_MAXIMUM)) {
-		log_error("VDO bio rotation %u out of range.", vtp->bio_rotation);
+		log_error("VDO bio rotation %u is out of range [%u..%u].",
+			  vtp->bio_rotation,
+			  DM_VDO_BIO_ROTATION_MINIMUM,
+			  DM_VDO_BIO_ROTATION_MAXIMUM);
 		valid = false;
 	}
 
 	if ((vtp->cpu_threads < DM_VDO_CPU_THREADS_MINIMUM) ||
 	    (vtp->cpu_threads > DM_VDO_CPU_THREADS_MAXIMUM)) {
-		log_error("VDO cpu threads %u out of range.", vtp->cpu_threads);
+		log_error("VDO cpu threads %u is out of range [%u..%u].",
+			  vtp->cpu_threads,
+			  DM_VDO_CPU_THREADS_MINIMUM,
+			  DM_VDO_CPU_THREADS_MAXIMUM);
 		valid = false;
 	}
 
 	if (vtp->hash_zone_threads > DM_VDO_HASH_ZONE_THREADS_MAXIMUM) {
-		log_error("VDO hash zone threads %u out of range.", vtp->hash_zone_threads);
+		log_error("VDO hash zone threads %u is out of range [0..%u].",
+			  vtp->hash_zone_threads,
+			  DM_VDO_HASH_ZONE_THREADS_MAXIMUM);
 		valid = false;
 	}
 
 	if (vtp->logical_threads > DM_VDO_LOGICAL_THREADS_MAXIMUM) {
-		log_error("VDO logical threads %u out of range.", vtp->logical_threads);
+		log_error("VDO logical threads %u is out of range [0..%u].",
+			  vtp->logical_threads,
+			  DM_VDO_LOGICAL_THREADS_MAXIMUM);
 		valid = false;
 	}
 
 	if (vtp->physical_threads > DM_VDO_PHYSICAL_THREADS_MAXIMUM) {
-		log_error("VDO physical threads %u out of range.", vtp->physical_threads);
+		log_error("VDO physical threads %u is out of range [0..%u].",
+			  vtp->physical_threads,
+			  DM_VDO_PHYSICAL_THREADS_MAXIMUM);
 		valid = false;
 	}
 

