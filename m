From: David Teigland <teigland@redhat.com>
Date: Thu, 25 Sep 2014 16:54:43 -0500
Subject: [PATCH] report: display cache mode of a cache pool
Message-ID: <20140925215443.GB4763@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

V2: avoid duplicating the feature flag test, and
writethrough may be implied by the lack of the WRITEBACK
flag, without the WRITETHROUGH flag set.

---
 lib/metadata/cache_manip.c       |  8 ++++++++
 lib/metadata/lv.c                |  5 +++++
 lib/metadata/lv.h                |  1 +
 lib/metadata/metadata-exported.h |  1 +
 lib/report/columns.h             |  1 +
 lib/report/properties.c          |  2 ++
 lib/report/report.c              | 18 ++++++++++++++++++
 7 files changed, 36 insertions(+)

diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 7f5ea65c35fe..902bfb43a77b 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -22,6 +22,14 @@
 #include "activate.h"
 #include "defaults.h"
 
+const char *get_cachepool_cachemode_name(uint32_t feature_flags)
+{
+	if (feature_flags & DM_CACHE_FEATURE_WRITEBACK)
+		return "writeback";
+	else
+		return "writethrough";
+}
+
 int update_cache_pool_params(struct volume_group *vg, unsigned attr,
 			     int passed_args, uint32_t data_extents,
 			     uint64_t *pool_metadata_size,
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index d29e787aae0a..42501ab86e85 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -128,6 +128,11 @@ char *lvseg_discards_dup(struct dm_pool *mem, const struct lv_segment *seg)
 	return  dm_pool_strdup(mem, get_pool_discards_name(seg->discards));
 }
 
+char *lvseg_cachemode_dup(struct dm_pool *mem, const struct lv_segment *seg)
+{
+	return  dm_pool_strdup(mem, get_cachepool_cachemode_name(seg->feature_flags));
+}
+
 #ifdef DMEVENTD
 #  include "libdevmapper-event.h"
 #endif
diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index 3a21f94c0a7d..ace87ad7cf94 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -82,6 +82,7 @@ uint64_t lvseg_size(const struct lv_segment *seg);
 uint64_t lvseg_chunksize(const struct lv_segment *seg);
 char *lvseg_segtype_dup(struct dm_pool *mem, const struct lv_segment *seg);
 char *lvseg_discards_dup(struct dm_pool *mem, const struct lv_segment *seg);
+char *lvseg_cachemode_dup(struct dm_pool *mem, const struct lv_segment *seg);
 char *lvseg_monitor_dup(struct dm_pool *mem, const struct lv_segment *seg);
 char *lvseg_tags_dup(const struct lv_segment *seg);
 char *lvseg_devices(struct dm_pool *mem, const struct lv_segment *seg);
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index a69979952d4f..3d4d6e32a492 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1074,6 +1074,7 @@ int partial_raid_lv_supports_degraded_activation(struct logical_volume *lv);
 /* --  metadata/raid_manip.c */
 
 /* ++  metadata/cache_manip.c */
+const char *get_cachepool_cachemode_name(uint32_t feature_flags);
 int update_cache_pool_params(struct volume_group *vg, unsigned attr,
 			     int passed_args, uint32_t data_extents,
 			     uint64_t *pool_metadata_size,
diff --git a/lib/report/columns.h b/lib/report/columns.h
index 403575811832..6f988e418965 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -158,6 +158,7 @@ FIELD(SEGS, seg, SIZ, "Chunk", list, 5, chunksize, chunksize, "For snapshots, th
 FIELD(SEGS, seg, SIZ, "Chunk", list, 5, chunksize, chunk_size, "For snapshots, the unit of data used when tracking changes.", 0)
 FIELD(SEGS, seg, NUM, "#Thins", list, 4, thincount, thin_count, "For thin pools, the number of thin volumes in this pool.", 0)
 FIELD(SEGS, seg, STR, "Discards", list, 8, discards, discards, "For thin pools, how discards are handled.", 0)
+FIELD(SEGS, seg, STR, "Cachemode", list, 9, cachemode, cachemode, "For cache pools, how writes are cached.", 0)
 FIELD(SEGS, seg, BIN, "Zero", list, 4, thinzero, zero, "For thin pools, if zeroing is enabled.", 0)
 FIELD(SEGS, seg, NUM, "TransId", list, 4, transactionid, transaction_id, "For thin pools, the transaction id.", 0)
 FIELD(SEGS, seg, NUM, "ThId", list, 4, thinid, thin_id, "For thin volume, the thin device id.", 0)
diff --git a/lib/report/properties.c b/lib/report/properties.c
index e0092dbfc96a..8f4f472507a0 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -380,6 +380,8 @@ GET_LVSEG_NUM_PROPERTY_FN(thin_id, lvseg->device_id)
 #define _thin_id_set prop_not_implemented_set
 GET_LVSEG_STR_PROPERTY_FN(discards, lvseg_discards_dup(lvseg->lv->vg->vgmem, lvseg))
 #define _discards_set prop_not_implemented_set
+GET_LVSEG_STR_PROPERTY_FN(cachemode, lvseg_cachemode_dup(lvseg->lv->vg->vgmem, lvseg))
+#define _cachemode_set prop_not_implemented_set
 GET_LVSEG_NUM_PROPERTY_FN(seg_start, (SECTOR_SIZE * lvseg_start(lvseg)))
 #define _seg_start_set prop_not_implemented_set
 GET_LVSEG_NUM_PROPERTY_FN(seg_start_pe, lvseg->le)
diff --git a/lib/report/report.c b/lib/report/report.c
index c0e0b47cc4a5..56d0be47c2cd 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -803,6 +803,24 @@ static int _discards_disp(struct dm_report *rh, struct dm_pool *mem,
 	return _field_set_value(field, "", NULL);
 }
 
+static int _cachemode_disp(struct dm_report *rh, struct dm_pool *mem,
+			   struct dm_report_field *field,
+			   const void *data, void *private)
+{
+	const struct lv_segment *seg = (const struct lv_segment *) data;
+	const char *cachemode_str;
+
+	if (seg_is_cache(seg))
+		seg = first_seg(seg->pool_lv);
+
+	if (seg_is_cache_pool(seg)) {
+		cachemode_str = get_cachepool_cachemode_name(seg->feature_flags);
+		return dm_report_field_string(rh, field, &cachemode_str);
+	}
+
+	return _field_set_value(field, "", NULL);
+}
+
 static int _originsize_disp(struct dm_report *rh, struct dm_pool *mem,
 			    struct dm_report_field *field,
 			    const void *data, void *private)
-- 
1.8.3.1


