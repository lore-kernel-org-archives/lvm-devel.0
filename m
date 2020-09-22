From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 22 Sep 2020 21:46:48 +0000 (GMT)
Subject: master - vdo: extend vdo segment validation
Message-ID: <20200922214648.35EE639450F9@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f38b7afd62533041ec68b10349169efb70c37d82
Commit:        f38b7afd62533041ec68b10349169efb70c37d82
Parent:        642ef5439962c721da37343a51468872027407c1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 22 23:17:54 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 22 23:25:16 2020 +0200

vdo: extend vdo segment validation

Try to catch all suspicious VDO segments in metadata early.
---
 lib/metadata/merge.c | 50 ++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 50 insertions(+)

diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index 1d47449db..0aa2293eb 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -541,11 +541,61 @@ static void _check_lv_segment(struct logical_volume *lv, struct lv_segment *seg,
 			seg_error("is missing a VDO pool data LV");
 		} else if (!lv_is_vdo_pool_data(seg_lv(seg, 0)))
 			seg_error("is not VDO pool data LV");
+		if ((seg->vdo_params.minimum_io_size != (512 >> SECTOR_SHIFT)) &&
+		    (seg->vdo_params.minimum_io_size != (4096 >> SECTOR_SHIFT)))
+			seg_error("sets unsupported VDO minimum io size");
+		if ((seg->vdo_params.block_map_cache_size_mb < DM_VDO_BLOCK_MAP_CACHE_SIZE_MINIMUM_MB) ||
+		    (seg->vdo_params.block_map_cache_size_mb > DM_VDO_BLOCK_MAP_CACHE_SIZE_MAXIMUM_MB))
+			seg_error("sets unsupported VDO block map cache size");
+		if ((seg->vdo_params.block_map_era_length < DM_VDO_BLOCK_MAP_ERA_LENGTH_MINIMUM) ||
+		    (seg->vdo_params.block_map_era_length > DM_VDO_BLOCK_MAP_ERA_LENGTH_MAXIMUM))
+			seg_error("sets unsupported VDO block map era length");
+		if ((seg->vdo_params.index_memory_size_mb < DM_VDO_INDEX_MEMORY_SIZE_MINIMUM_MB) ||
+		    (seg->vdo_params.index_memory_size_mb > DM_VDO_INDEX_MEMORY_SIZE_MAXIMUM_MB))
+			seg_error("sets unsupported VDO index memory size");
+		if ((seg->vdo_params.slab_size_mb < DM_VDO_SLAB_SIZE_MINIMUM_MB) ||
+		    (seg->vdo_params.slab_size_mb > DM_VDO_SLAB_SIZE_MAXIMUM_MB))
+			seg_error("sets unsupported VDO slab size");
+		if ((seg->vdo_params.max_discard < DM_VDO_MAX_DISCARD_MINIMUM) ||
+		    (seg->vdo_params.max_discard > DM_VDO_MAX_DISCARD_MAXIMUM))
+			seg_error("sets unsupported VDO max discard");
+		if (seg->vdo_params.ack_threads > DM_VDO_ACK_THREADS_MAXIMUM)
+			seg_error("sets unsupported VDO ack threads");
+		if ((seg->vdo_params.bio_threads < DM_VDO_BIO_THREADS_MINIMUM) ||
+		    (seg->vdo_params.bio_threads > DM_VDO_BIO_THREADS_MAXIMUM))
+			seg_error("sets unsupported VDO bio threads");
+		if ((seg->vdo_params.bio_rotation < DM_VDO_BIO_ROTATION_MINIMUM) ||
+		    (seg->vdo_params.bio_rotation > DM_VDO_BIO_ROTATION_MAXIMUM))
+			seg_error("sets unsupported VDO bio rotation");
+		if ((seg->vdo_params.cpu_threads < DM_VDO_CPU_THREADS_MINIMUM) ||
+		    (seg->vdo_params.cpu_threads > DM_VDO_CPU_THREADS_MAXIMUM))
+			seg_error("sets unsupported VDO cpu threads");
+		if (seg->vdo_params.hash_zone_threads > DM_VDO_HASH_ZONE_THREADS_MAXIMUM)
+			seg_error("sets unsupported VDO hash zone threads");
+		if (seg->vdo_params.logical_threads > DM_VDO_LOGICAL_THREADS_MAXIMUM)
+			seg_error("sets unsupported VDO logical threads");
+		if (seg->vdo_params.physical_threads > DM_VDO_PHYSICAL_THREADS_MAXIMUM)
+			seg_error("sets unsupported VDO physical threads");
 	} else { /* !VDO pool */
 		if (seg->vdo_pool_header_size)
 			seg_error("sets vdo_pool_header_size");
 		if (seg->vdo_pool_virtual_extents)
 			seg_error("sets vdo_pool_virtual_extents");
+		if (seg->vdo_params.minimum_io_size |
+		    seg->vdo_params.block_map_cache_size_mb |
+		    seg->vdo_params.block_map_era_length |
+		    seg->vdo_params.check_point_frequency |
+		    seg->vdo_params.index_memory_size_mb |
+		    seg->vdo_params.slab_size_mb |
+		    seg->vdo_params.max_discard |
+		    seg->vdo_params.ack_threads |
+		    seg->vdo_params.bio_threads |
+		    seg->vdo_params.bio_rotation |
+		    seg->vdo_params.cpu_threads |
+		    seg->vdo_params.hash_zone_threads |
+		    seg->vdo_params.logical_threads |
+		    seg->vdo_params.physical_threads)
+			seg_error("sets vdo_params");
 	}
 
 	if (seg_is_vdo(seg)) {


