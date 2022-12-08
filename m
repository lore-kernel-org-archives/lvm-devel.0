From: Marian Csontos <mcsontos@sourceware.org>
Date: Thu,  8 Dec 2022 14:40:08 +0000 (GMT)
Subject: rhel-8.8.0 - vdo: use single validator
Message-ID: <20221208144008.1CA103968921@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d0b5614d43ac41ee24a480a6272f256b1a242873
Commit:        d0b5614d43ac41ee24a480a6272f256b1a242873
Parent:        71354c39350b482ca8cf0fd9dcaf025b1d55b7d1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 4 16:08:30 2022 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu Dec 8 15:25:12 2022 +0100

vdo: use single validator

Add era lenght validation into dm_vdo_validate_target_params()
and reuse this validator also for _check_lv_segment().

(cherry picked from commit 8ca2b1bc213188037ecedfbf76de53de871c7f5b)
---
 device_mapper/vdo/vdo_target.c |  9 ++++++++-
 lib/metadata/merge.c           | 37 ++-----------------------------------
 2 files changed, 10 insertions(+), 36 deletions(-)

diff --git a/device_mapper/vdo/vdo_target.c b/device_mapper/vdo/vdo_target.c
index 2ffd29145..0e5abd162 100644
--- a/device_mapper/vdo/vdo_target.c
+++ b/device_mapper/vdo/vdo_target.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2018 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2018-2022 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -38,6 +38,13 @@ bool dm_vdo_validate_target_params(const struct dm_vdo_target_params *vtp,
 		valid = false;
 	}
 
+	if ((vtp->block_map_era_length < DM_VDO_BLOCK_MAP_ERA_LENGTH_MINIMUM) ||
+	    (vtp->block_map_era_length > DM_VDO_BLOCK_MAP_ERA_LENGTH_MAXIMUM)) {
+		log_error("VDO block map era length %u out of range.",
+			  vtp->block_map_era_length);
+		valid = false;
+	}
+
 	if ((vtp->index_memory_size_mb < DM_VDO_INDEX_MEMORY_SIZE_MINIMUM_MB) ||
 	    (vtp->index_memory_size_mb > DM_VDO_INDEX_MEMORY_SIZE_MAXIMUM_MB)) {
 		log_error("VDO index memory size %u out of range.",
diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index 8eff74297..5209f51b5 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -545,41 +545,8 @@ static void _check_lv_segment(struct logical_volume *lv, struct lv_segment *seg,
 			seg_error("is missing a VDO pool data LV");
 		} else if (!lv_is_vdo_pool_data(seg_lv(seg, 0)))
 			seg_error("is not VDO pool data LV");
-		if ((seg->vdo_params.minimum_io_size != (512 >> SECTOR_SHIFT)) &&
-		    (seg->vdo_params.minimum_io_size != (4096 >> SECTOR_SHIFT)))
-			seg_error("sets unsupported VDO minimum io size");
-		if ((seg->vdo_params.block_map_cache_size_mb < DM_VDO_BLOCK_MAP_CACHE_SIZE_MINIMUM_MB) ||
-		    (seg->vdo_params.block_map_cache_size_mb > DM_VDO_BLOCK_MAP_CACHE_SIZE_MAXIMUM_MB))
-			seg_error("sets unsupported VDO block map cache size");
-		if ((seg->vdo_params.block_map_era_length < DM_VDO_BLOCK_MAP_ERA_LENGTH_MINIMUM) ||
-		    (seg->vdo_params.block_map_era_length > DM_VDO_BLOCK_MAP_ERA_LENGTH_MAXIMUM))
-			seg_error("sets unsupported VDO block map era length");
-		if ((seg->vdo_params.index_memory_size_mb < DM_VDO_INDEX_MEMORY_SIZE_MINIMUM_MB) ||
-		    (seg->vdo_params.index_memory_size_mb > DM_VDO_INDEX_MEMORY_SIZE_MAXIMUM_MB))
-			seg_error("sets unsupported VDO index memory size");
-		if ((seg->vdo_params.slab_size_mb < DM_VDO_SLAB_SIZE_MINIMUM_MB) ||
-		    (seg->vdo_params.slab_size_mb > DM_VDO_SLAB_SIZE_MAXIMUM_MB))
-			seg_error("sets unsupported VDO slab size");
-		if ((seg->vdo_params.max_discard < DM_VDO_MAX_DISCARD_MINIMUM) ||
-		    (seg->vdo_params.max_discard > DM_VDO_MAX_DISCARD_MAXIMUM))
-			seg_error("sets unsupported VDO max discard");
-		if (seg->vdo_params.ack_threads > DM_VDO_ACK_THREADS_MAXIMUM)
-			seg_error("sets unsupported VDO ack threads");
-		if ((seg->vdo_params.bio_threads < DM_VDO_BIO_THREADS_MINIMUM) ||
-		    (seg->vdo_params.bio_threads > DM_VDO_BIO_THREADS_MAXIMUM))
-			seg_error("sets unsupported VDO bio threads");
-		if ((seg->vdo_params.bio_rotation < DM_VDO_BIO_ROTATION_MINIMUM) ||
-		    (seg->vdo_params.bio_rotation > DM_VDO_BIO_ROTATION_MAXIMUM))
-			seg_error("sets unsupported VDO bio rotation");
-		if ((seg->vdo_params.cpu_threads < DM_VDO_CPU_THREADS_MINIMUM) ||
-		    (seg->vdo_params.cpu_threads > DM_VDO_CPU_THREADS_MAXIMUM))
-			seg_error("sets unsupported VDO cpu threads");
-		if (seg->vdo_params.hash_zone_threads > DM_VDO_HASH_ZONE_THREADS_MAXIMUM)
-			seg_error("sets unsupported VDO hash zone threads");
-		if (seg->vdo_params.logical_threads > DM_VDO_LOGICAL_THREADS_MAXIMUM)
-			seg_error("sets unsupported VDO logical threads");
-		if (seg->vdo_params.physical_threads > DM_VDO_PHYSICAL_THREADS_MAXIMUM)
-			seg_error("sets unsupported VDO physical threads");
+		if (!dm_vdo_validate_target_params(&seg->vdo_params, 0))
+			seg_error("sets invalid VDO parameter(s)");
 	} else { /* !VDO pool */
 		if (seg->vdo_pool_header_size)
 			seg_error("sets vdo_pool_header_size");

