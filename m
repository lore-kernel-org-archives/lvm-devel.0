From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 4 Oct 2019 11:33:37 -0400
Subject: master - vdo: add lvs fields to query vdo volume properties
Message-ID: <201910041533.x94FXb89031082@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ca70dc4540571bde2d10f4506f865e1caf398f00
Commit:        ca70dc4540571bde2d10f4506f865e1caf398f00
Parent:        862aa06e5eb28c0a9a163f109bdaeba9729243bc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 4 17:02:20 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 4 17:31:55 2019 +0200

vdo: add lvs fields to query vdo volume properties

Add lots of vdo fields:

    vdo_operating_mode       - For vdo pools, its current operating mode.
    vdo_compression_state    - For vdo pools, whether compression is running.
    vdo_index_state          - For vdo pools, state of index for deduplication.
    vdo_used_size            - For vdo pools, currently used space.
    vdo_saving_percent       - For vdo pools, percentage of saved space.
    vdo_compression          - Set for compressed LV (vdopool).
    vdo_deduplication        - Set for deduplicated LV (vdopool).
    vdo_use_metadata_hints   - Use REQ_SYNC for writes (vdopool).
    vdo_minimum_io_size      - Minimum acceptable IO size (vdopool).
    vdo_block_map_cache_size - Allocated caching size (vdopool).
    vdo_block_map_era_length - Speed of cache writes (vdopool).
    vdo_use_sparse_index     - Sparse indexing (vdopool).
    vdo_index_memory_size    - Allocated indexing memory (vdopool).
    vdo_slab_size            - Increment size for growing (vdopool).
    vdo_ack_threads          - Acknowledging threads (vdopool).
    vdo_bio_threads          - IO submitting threads (vdopool).
    vdo_bio_rotation         - IO enqueue (vdopool).
    vdo_cpu_threads          - CPU threads for compression and hashing (vdopool).
    vdo_hash_zone_threads    - Threads for subdivide parts (vdopool).
    vdo_logical_threads      - Logical threads for subdivide parts (vdopool).
    vdo_physical_threads     - Physical threads for subdivide parts (vdopool).
    vdo_max_discard          - Maximum discard size volume can recieve (vdopool).
    vdo_write_policy         - Specified write policy (vdopool).
    vdo_header_size          - Header size at front of vdopool.

Previously only 'lvdisplay -m' was exposing them.
---
 lib/report/columns.h    |   28 +++++-
 lib/report/properties.c |   49 ++++++++++
 lib/report/report.c     |  244 ++++++++++++++++++++++++++++++++++++++++++++++-
 lib/report/values.h     |    5 +
 4 files changed, 324 insertions(+), 2 deletions(-)

diff --git a/lib/report/columns.h b/lib/report/columns.h
index 6f0f638..0a89451 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2017 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2019 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -146,6 +146,11 @@ FIELD(LVSSTATUS, lv, STR, "KDiscards", lvid, 0, kdiscards, kernel_discards, "For
 FIELD(LVSSTATUS, lv, BIN, "CheckNeeded", lvid, 15, lvcheckneeded, lv_check_needed, "For thin pools and cache volumes, whether metadata check is needed.", 0)
 FIELD(LVSSTATUS, lv, BIN, "MergeFailed", lvid, 15, lvmergefailed, lv_merge_failed, "Set if snapshot merge failed.", 0)
 FIELD(LVSSTATUS, lv, BIN, "SnapInvalid", lvid, 15, lvsnapshotinvalid, lv_snapshot_invalid, "Set if snapshot LV is invalid.", 0)
+FIELD(LVSSTATUS, lv, STR, "VDOOperatingMode", lvid, 0, vdo_operating_mode, vdo_operating_mode, "For vdo pools, its current operating mode.", 0)
+FIELD(LVSSTATUS, lv, STR, "VDOCompressionState", lvid, 0, vdo_compression_state, vdo_compression_state, "For vdo pools, whether compression is running.", 0)
+FIELD(LVSSTATUS, lv, STR, "VDOIndexState", lvid, 0, vdo_index_state, vdo_index_state, "For vdo pools, state of index for deduplication.", 0)
+FIELD(LVSSTATUS, lv, NUM, "VDOUsedSize", lvid, 0, vdo_used_size, vdo_used_size, "For vdo pools, currently used space.", 0)
+FIELD(LVSSTATUS, lv, NUM, "VDOSaving%", lvid, 0, vdo_saving_percent, vdo_saving_percent, "For vdo pools, percentage of saved space.", 0)
 /*
  * End of LVSSTATUS type fields
  */
@@ -274,6 +279,27 @@ FIELD(SEGS, seg, STR_LIST, "Metadata Devs", list, 0, metadatadevices, metadata_d
 FIELD(SEGS, seg, STR, "Monitor", list, 0, segmonitor, seg_monitor, "Dmeventd monitoring status of the segment.", 0)
 FIELD(SEGS, seg, STR, "CachePolicy", list, 0, cache_policy, cache_policy, "The cache policy (cached segments only).", 0)
 FIELD(SEGS, seg, STR_LIST, "CacheSettings", list, 0, cache_settings, cache_settings, "Cache settings/parameters (cached segments only).", 0)
+
+FIELD(SEGS, seg, BIN, "VDOCompression", list, 0, vdo_compression, vdo_compression, "Set for compressed LV (vdopool).", 0)
+FIELD(SEGS, seg, BIN, "VDODeduplication", list, 0, vdo_deduplication, vdo_deduplication, "Set for deduplicated LV (vdopool).", 0)
+FIELD(SEGS, seg, BIN, "VDOMetadataHints", list, 0, vdo_use_metadata_hints, vdo_use_metadata_hints, "Use REQ_SYNC for writes (vdopool).", 0)
+FIELD(SEGS, seg, NUM, "VDOMinimumIOSize", list, 0, vdo_minimum_io_size, vdo_minimum_io_size, "Minimum acceptable IO size (vdopool).", 0)
+FIELD(SEGS, seg, SIZ, "VDOBlockMapCacheSize", list, 0, vdo_block_map_cache_size, vdo_block_map_cache_size, "Allocated caching size (vdopool).", 0)
+FIELD(SEGS, seg, NUM, "VDOBlockMapEraLength", list, 0, vdo_block_map_era_length, vdo_block_map_era_length, "Speed of cache writes (vdopool).", 0)
+FIELD(SEGS, seg, BIN, "VDOSparseIndex", list, 0, vdo_use_sparse_index, vdo_use_sparse_index, "Sparse indexing (vdopool).", 0)
+FIELD(SEGS, seg, SIZ, "VDOIndexMemorySize", list, 0, vdo_index_memory_size, vdo_index_memory_size, "Allocated indexing memory (vdopool).", 0)
+FIELD(SEGS, seg, SIZ, "VDOSlabSize", list, 0, vdo_slab_size, vdo_slab_size, "Increment size for growing (vdopool).", 0)
+FIELD(SEGS, seg, NUM, "VDOAckThreads", list, 0, vdo_ack_threads, vdo_ack_threads, "Acknowledging threads (vdopool).", 0)
+FIELD(SEGS, seg, NUM, "VDOBioThreads", list, 0, vdo_bio_threads, vdo_bio_threads, "IO submitting threads (vdopool).", 0)
+FIELD(SEGS, seg, NUM, "VDOBioRotation", list, 0, vdo_bio_rotation, vdo_bio_rotation, "IO enqueue (vdopool).", 0)
+FIELD(SEGS, seg, NUM, "VDOCPUThreads", list, 0, vdo_cpu_threads, vdo_cpu_threads, "CPU threads for compression and hashing (vdopool).", 0)
+FIELD(SEGS, seg, NUM, "VDOHashZoneThreads", list, 0, vdo_hash_zone_threads, vdo_hash_zone_threads, "Threads for subdivide parts (vdopool).", 0)
+FIELD(SEGS, seg, NUM, "VDOLogicalThreads", list, 0, vdo_logical_threads, vdo_logical_threads, "Logical threads for subdivide parts (vdopool).", 0)
+FIELD(SEGS, seg, NUM, "VDOPhysicalThreads", list, 0, vdo_physical_threads, vdo_physical_threads, "Physical threads for subdivide parts (vdopool).", 0)
+FIELD(SEGS, seg, NUM, "VDOMaxDiscard", list, 0, vdo_max_discard, vdo_max_discard, "Maximum discard size volume can recieve (vdopool).", 0)
+FIELD(SEGS, seg, STR, "VDOWritePolicy", list, 0, vdo_write_policy, vdo_write_policy, "Specified write policy (vdopool).", 0)
+FIELD(SEGS, seg, SIZ, "VDOHeaderSize", list, 0, vdo_header_size, vdo_header_size, "Header size at front of vdopool.", 0)
+
 /*
  * End of SEGS type fields
  */
diff --git a/lib/report/properties.c b/lib/report/properties.c
index 74f13c8..25e263f 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -279,6 +279,55 @@ GET_PV_NUM_PROPERTY_FN(pv_ba_size, SECTOR_SIZE * pv->ba_size)
 #define _cache_write_misses_set prop_not_implemented_set
 #define _cache_write_misses_get prop_not_implemented_get
 
+#define _vdo_operating_mode_set prop_not_implemented_set
+#define _vdo_operating_mode_get prop_not_implemented_get
+#define _vdo_compression_state_set prop_not_implemented_set
+#define _vdo_compression_state_get prop_not_implemented_get
+#define _vdo_index_state_set prop_not_implemented_set
+#define _vdo_index_state_get prop_not_implemented_get
+#define _vdo_used_size_set prop_not_implemented_set
+#define _vdo_used_size_get prop_not_implemented_get
+#define _vdo_saving_percent_set prop_not_implemented_set
+#define _vdo_saving_percent_get prop_not_implemented_get
+#define _vdo_compression_set prop_not_implemented_set
+#define _vdo_compression_get prop_not_implemented_get
+#define _vdo_deduplication_set prop_not_implemented_set
+#define _vdo_deduplication_get prop_not_implemented_get
+#define _vdo_use_metadata_hints_set prop_not_implemented_set
+#define _vdo_use_metadata_hints_get prop_not_implemented_get
+#define _vdo_minimum_io_size_set prop_not_implemented_set
+#define _vdo_minimum_io_size_get prop_not_implemented_get
+#define _vdo_block_map_cache_size_set prop_not_implemented_set
+#define _vdo_block_map_cache_size_get prop_not_implemented_get
+#define _vdo_block_map_era_length_set prop_not_implemented_set
+#define _vdo_block_map_era_length_get prop_not_implemented_get
+#define _vdo_use_sparse_index_set prop_not_implemented_set
+#define _vdo_use_sparse_index_get prop_not_implemented_get
+#define _vdo_index_memory_size_set prop_not_implemented_set
+#define _vdo_index_memory_size_get prop_not_implemented_get
+#define _vdo_slab_size_set prop_not_implemented_set
+#define _vdo_slab_size_get prop_not_implemented_get
+#define _vdo_ack_threads_set prop_not_implemented_set
+#define _vdo_ack_threads_get prop_not_implemented_get
+#define _vdo_bio_threads_set prop_not_implemented_set
+#define _vdo_bio_threads_get prop_not_implemented_get
+#define _vdo_bio_rotation_set prop_not_implemented_set
+#define _vdo_bio_rotation_get prop_not_implemented_get
+#define _vdo_cpu_threads_set prop_not_implemented_set
+#define _vdo_cpu_threads_get prop_not_implemented_get
+#define _vdo_hash_zone_threads_set prop_not_implemented_set
+#define _vdo_hash_zone_threads_get prop_not_implemented_get
+#define _vdo_logical_threads_set prop_not_implemented_set
+#define _vdo_logical_threads_get prop_not_implemented_get
+#define _vdo_physical_threads_set prop_not_implemented_set
+#define _vdo_physical_threads_get prop_not_implemented_get
+#define _vdo_max_discard_set prop_not_implemented_set
+#define _vdo_max_discard_get prop_not_implemented_get
+#define _vdo_write_policy_set prop_not_implemented_set
+#define _vdo_write_policy_get prop_not_implemented_get
+#define _vdo_header_size_set prop_not_implemented_set
+#define _vdo_header_size_get prop_not_implemented_get
+
 /* LV */
 GET_LV_STR_PROPERTY_FN(lv_uuid, lv_uuid_dup(lv->vg->vgmem, lv))
 #define _lv_uuid_set prop_not_implemented_set
diff --git a/lib/report/report.c b/lib/report/report.c
index 730b0af..70ee514 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2014 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2019 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -2407,6 +2407,74 @@ static int _lvkreadahead_disp(struct dm_report *rh, struct dm_pool *mem,
 	return _size32_disp(rh, mem, field, &lvdm->info.read_ahead, private);
 }
 
+static int _vdo_operating_mode_disp(struct dm_report *rh, struct dm_pool *mem,
+				    struct dm_report_field *field,
+				    const void *data, void *private)
+{
+	const struct lv_with_info_and_seg_status *lvdm = (const struct lv_with_info_and_seg_status *) data;
+
+	if ((lv_is_vdo_pool(lvdm->lv) || lv_is_vdo(lvdm->lv)) &&
+	    (lvdm->seg_status.type == SEG_STATUS_VDO_POOL))
+		return _field_string(rh, field, get_vdo_operating_mode_name(lvdm->seg_status.vdo_pool.vdo->operating_mode));
+
+	return _field_set_value(field, "", &GET_TYPE_RESERVED_VALUE(num_undef_64));
+}
+
+static int _vdo_compression_state_disp(struct dm_report *rh, struct dm_pool *mem,
+				       struct dm_report_field *field,
+				       const void *data, void *private)
+{
+	const struct lv_with_info_and_seg_status *lvdm = (const struct lv_with_info_and_seg_status *) data;
+
+	if ((lv_is_vdo_pool(lvdm->lv) || lv_is_vdo(lvdm->lv)) &&
+	    (lvdm->seg_status.type == SEG_STATUS_VDO_POOL))
+		return _field_string(rh, field, get_vdo_compression_state_name(lvdm->seg_status.vdo_pool.vdo->compression_state));
+
+	return _field_set_value(field, "", &GET_TYPE_RESERVED_VALUE(num_undef_64));
+}
+
+static int _vdo_index_state_disp(struct dm_report *rh, struct dm_pool *mem,
+				 struct dm_report_field *field,
+				 const void *data, void *private)
+{
+	const struct lv_with_info_and_seg_status *lvdm = (const struct lv_with_info_and_seg_status *) data;
+
+	if ((lv_is_vdo_pool(lvdm->lv) || lv_is_vdo(lvdm->lv)) &&
+	    (lvdm->seg_status.type == SEG_STATUS_VDO_POOL))
+		return _field_string(rh, field, get_vdo_index_state_name(lvdm->seg_status.vdo_pool.vdo->index_state));
+
+	return _field_set_value(field, "", &GET_TYPE_RESERVED_VALUE(num_undef_64));
+}
+
+static int _vdo_used_size_disp(struct dm_report *rh, struct dm_pool *mem,
+			       struct dm_report_field *field,
+			       const void *data, void *private)
+{
+	uint64_t size;
+	const struct lv_with_info_and_seg_status *lvdm = (const struct lv_with_info_and_seg_status *) data;
+
+	if ((lv_is_vdo_pool(lvdm->lv) || lv_is_vdo(lvdm->lv)) &&
+	    (lvdm->seg_status.type == SEG_STATUS_VDO_POOL)) {
+		size = lvdm->seg_status.vdo_pool.vdo->used_blocks * DM_VDO_BLOCK_SIZE;
+		return _size64_disp(rh, mem, field, &size, private);
+	}
+
+	return _field_set_value(field, "", &GET_TYPE_RESERVED_VALUE(num_undef_64));
+}
+
+static int _vdo_saving_percent_disp(struct dm_report *rh, struct dm_pool *mem,
+				    struct dm_report_field *field,
+				    const void *data, void *private)
+{
+	const struct lv_with_info_and_seg_status *lvdm = (const struct lv_with_info_and_seg_status *) data;
+
+	if ((lv_is_vdo_pool(lvdm->lv) || lv_is_vdo(lvdm->lv)) &&
+	    (lvdm->seg_status.type == SEG_STATUS_VDO_POOL))
+		return dm_report_field_percent(rh, field, &lvdm->seg_status.vdo_pool.saving);
+
+	return _field_set_value(field, "", &GET_TYPE_RESERVED_VALUE(num_undef_64));
+}
+
 static int _vgsize_disp(struct dm_report *rh, struct dm_pool *mem,
 			struct dm_report_field *field,
 			const void *data, void *private)
@@ -3807,6 +3875,180 @@ GENERATE_CACHE_STATUS_DISP_FN(read_misses)
 GENERATE_CACHE_STATUS_DISP_FN(write_hits)
 GENERATE_CACHE_STATUS_DISP_FN(write_misses)
 
+
+/*
+ * Macro to generate '_vdo_<vdo_field_name>_disp' reporting function.
+ * The 'vdo_field_name' is field name from struct lv_vdo_status.
+ */
+#define GENERATE_VDO_FIELD_DISP_FN(vdo_field_name) \
+static int _vdo_ ## vdo_field_name ## _disp (struct dm_report *rh, struct dm_pool *mem, \
+					     struct dm_report_field *field, \
+					     const void *data, void *private) \
+{ \
+	const struct lv_segment *seg = (const struct lv_segment *) data; \
+\
+	if (seg_is_vdo(seg)) \
+		seg = first_seg(seg_lv(seg, 0)); \
+\
+	if (!seg_is_vdo_pool(seg)) \
+		return _field_set_value(field, "", &GET_TYPE_RESERVED_VALUE(num_undef_64)); \
+\
+	return dm_report_field_uint32(rh, field, &seg->vdo_params.vdo_field_name); \
+}
+
+GENERATE_VDO_FIELD_DISP_FN(block_map_era_length)
+GENERATE_VDO_FIELD_DISP_FN(ack_threads)
+GENERATE_VDO_FIELD_DISP_FN(bio_threads)
+GENERATE_VDO_FIELD_DISP_FN(bio_rotation)
+GENERATE_VDO_FIELD_DISP_FN(cpu_threads)
+GENERATE_VDO_FIELD_DISP_FN(hash_zone_threads)
+GENERATE_VDO_FIELD_DISP_FN(logical_threads)
+GENERATE_VDO_FIELD_DISP_FN(physical_threads)
+GENERATE_VDO_FIELD_DISP_FN(max_discard)
+
+/*
+ * Macro to generate '_vdo_<vdo_field_name>_disp' reporting function.
+ * The 'vdo_field_name' is field name from struct lv_vdo_status.
+ */
+#define GENERATE_VDO_FIELDSZMB_DISP_FN(vdo_field_name) \
+static int _vdo_ ## vdo_field_name ## _disp (struct dm_report *rh, struct dm_pool *mem, \
+					     struct dm_report_field *field, \
+					     const void *data, void *private) \
+{ \
+	uint64_t size; \
+	const struct lv_segment *seg = (const struct lv_segment *) data; \
+\
+	if (seg_is_vdo(seg)) \
+		seg = first_seg(seg_lv(seg, 0)); \
+\
+	if (!seg_is_vdo_pool(seg)) \
+		return _field_set_value(field, "", &GET_TYPE_RESERVED_VALUE(num_undef_64)); \
+\
+	size = seg->vdo_params.vdo_field_name ## _mb * (1024 * 1024 >> SECTOR_SHIFT); \
+\
+	return _size64_disp(rh, mem, field, &size, private);\
+}
+
+GENERATE_VDO_FIELDSZMB_DISP_FN(block_map_cache_size)
+GENERATE_VDO_FIELDSZMB_DISP_FN(index_memory_size)
+GENERATE_VDO_FIELDSZMB_DISP_FN(slab_size)
+
+static int _vdo_compression_disp(struct dm_report *rh, struct dm_pool *mem,
+				 struct dm_report_field *field,
+				 const void *data, void *private)
+{
+	const struct lv_segment *seg = (const struct lv_segment *) data; \
+
+	if (seg_is_vdo(seg))
+		seg = first_seg(seg_lv(seg, 0));
+
+	if (seg_is_vdo_pool(seg))
+		return _binary_disp(rh, mem, field, seg->vdo_params.use_compression,
+				    GET_FIRST_RESERVED_NAME(vdo_compression_y), private);
+
+	return _field_set_value(field, "", &GET_TYPE_RESERVED_VALUE(num_undef_64)); \
+}
+
+static int _vdo_deduplication_disp(struct dm_report *rh, struct dm_pool *mem,
+				   struct dm_report_field *field,
+				   const void *data, void *private)
+{
+	const struct lv_segment *seg = (const struct lv_segment *) data; \
+
+	if (seg_is_vdo(seg))
+		seg = first_seg(seg_lv(seg, 0));
+
+	if (seg_is_vdo_pool(seg))
+		return _binary_disp(rh, mem, field, seg->vdo_params.use_deduplication,
+				    GET_FIRST_RESERVED_NAME(vdo_deduplication_y), private);
+
+	return _field_set_value(field, "", &GET_TYPE_RESERVED_VALUE(num_undef_64)); \
+}
+
+static int _vdo_use_metadata_hints_disp(struct dm_report *rh, struct dm_pool *mem,
+					struct dm_report_field *field,
+					const void *data, void *private)
+{
+	const struct lv_segment *seg = (const struct lv_segment *) data;
+
+	if (seg_is_vdo(seg))
+		seg = first_seg(seg_lv(seg, 0));
+
+	if (seg_is_vdo_pool(seg))
+		return _binary_disp(rh, mem, field, seg->vdo_params.use_metadata_hints,
+				    GET_FIRST_RESERVED_NAME(vdo_use_metadata_hints_y),
+				    private);
+
+	return _field_set_value(field, "", &GET_TYPE_RESERVED_VALUE(num_undef_64));
+}
+
+static int _vdo_use_sparse_index_disp(struct dm_report *rh, struct dm_pool *mem,
+				      struct dm_report_field *field,
+				      const void *data, void *private)
+{
+	const struct lv_segment *seg = (const struct lv_segment *) data;
+
+	if (seg_is_vdo(seg))
+		seg = first_seg(seg_lv(seg, 0));
+
+	if (seg_is_vdo_pool(seg))
+		return _binary_disp(rh, mem, field, seg->vdo_params.use_sparse_index,
+				    GET_FIRST_RESERVED_NAME(vdo_use_sparse_index_y),
+				    private);
+
+	return _field_set_value(field, "", &GET_TYPE_RESERVED_VALUE(num_undef_64));
+}
+
+static int _vdo_minimum_io_size_disp(struct dm_report *rh, struct dm_pool *mem,
+				     struct dm_report_field *field,
+				     const void *data, void *private)
+{
+	const struct lv_segment *seg = (const struct lv_segment *) data;
+
+	if (seg_is_vdo(seg))
+		seg = first_seg(seg_lv(seg, 0));
+
+	if (seg_is_vdo_pool(seg))
+		return _size32_disp(rh, mem, field, &seg->vdo_params.minimum_io_size, private);
+
+	return _field_set_value(field, "", &GET_TYPE_RESERVED_VALUE(num_undef_64));
+}
+
+static int _vdo_header_size_disp(struct dm_report *rh,
+				 struct dm_pool *mem,
+				 struct dm_report_field *field,
+				 const void *data,
+				 void *private)
+{
+	const struct lv_segment *seg = (const struct lv_segment *) data;
+
+	if (seg_is_vdo(seg))
+		seg = first_seg(seg_lv(seg, 0));
+
+	if (seg_is_vdo_pool(seg))
+		return _size32_disp(rh, mem, field, &seg->vdo_pool_header_size, private);
+
+	return _field_set_value(field, "", &GET_TYPE_RESERVED_VALUE(num_undef_64));
+}
+
+static int _vdo_write_policy_disp(struct dm_report *rh,
+				     struct dm_pool *mem,
+				     struct dm_report_field *field,
+				     const void *data,
+				     void *private)
+{
+	const struct lv_segment *seg = (const struct lv_segment *) data;
+
+	if (seg_is_vdo(seg))
+		seg = first_seg(seg_lv(seg, 0));
+
+	if (seg_is_vdo_pool(seg))
+		return _field_string(rh, field, get_vdo_write_policy_name(seg->vdo_params.write_policy));
+
+	return  _field_set_value(field, GET_FIRST_RESERVED_NAME(vdo_write_policy_undef),
+				 GET_FIELD_RESERVED_VALUE(vdo_write_policy_undef));
+}
+
 /* Report object types */
 
 /* necessary for displaying something for PVs not belonging to VG */
diff --git a/lib/report/values.h b/lib/report/values.h
index 96729ef..9b98c22 100644
--- a/lib/report/values.h
+++ b/lib/report/values.h
@@ -84,6 +84,10 @@ FIELD_RESERVED_BINARY_VALUE(lv_device_open, lv_device_open, "", "open")
 FIELD_RESERVED_BINARY_VALUE(lv_skip_activation, lv_skip_activation, "", "skip activation", "skip")
 FIELD_RESERVED_BINARY_VALUE(zero, zero, "", "zero")
 FIELD_RESERVED_BINARY_VALUE(lv_check_needed, lv_check_needed, "", "check needed", "needed")
+FIELD_RESERVED_BINARY_VALUE(vdo_compression, vdo_compression, "", "enabled" )
+FIELD_RESERVED_BINARY_VALUE(vdo_deduplication, vdo_deduplication, "", "enabled" )
+FIELD_RESERVED_BINARY_VALUE(vdo_use_metadata_hints, vdo_use_metadata_hints, "", "enabled" )
+FIELD_RESERVED_BINARY_VALUE(vdo_use_sparse_index, vdo_use_sparse_index, "", "enabled" )
 FIELD_RESERVED_VALUE(NAMED, lv_permissions, lv_permissions_rw, "", "writeable", "writeable", "rw", "read-write")
 FIELD_RESERVED_VALUE(NAMED, lv_permissions, lv_permissions_r, "", "read-only", "read-only", "r", "ro")
 FIELD_RESERVED_VALUE(NAMED, lv_permissions, lv_permissions_r_override, "", "read-only-override", "read-only-override", "ro-override", "r-override", "R")
@@ -99,6 +103,7 @@ FIELD_RESERVED_VALUE(NOFLAG, cache_policy, cache_policy_undef, "", "", "", "unde
 FIELD_RESERVED_VALUE(NOFLAG, seg_monitor, seg_monitor_undef, "", "", "", "undefined")
 FIELD_RESERVED_VALUE(NOFLAG, lv_health_status, health_undef, "", "", "", "undefined")
 FIELD_RESERVED_VALUE(NOFLAG, kernel_discards, seg_kernel_discards_undef, "", "", "", "undefined")
+FIELD_RESERVED_VALUE(NOFLAG, vdo_write_policy, vdo_write_policy_undef, "", "", "", "undefined")
 /* TODO the following 2 need STR_LIST support for reserved values
 FIELD_RESERVED_VALUE(cache_settings, cache_settings_default, "", "default", "default")
 FIELD_RESERVED_VALUE(cache_settings, cache_settings_undef, "", "undefined", "undefined") */


