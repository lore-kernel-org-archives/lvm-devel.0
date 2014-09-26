From: David Teigland <teigland@redhat.com>
Date: Fri, 26 Sep 2014 11:08:24 -0500
Subject: [PATCH] report: display cache mode of a cache pool
Message-ID: <20140926160824.GA20360@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Jon explained that we want to check the cache mode from dm first,
and report that if it's available, before reporting what's set in
the metadata.  That's what this tries to do, but it doesn't work.
Neither lv_info() or dev_manager_cache_status() return anything.

So, this always falls back to reporting the cache mode set in
the metadata ("default" means there's no mode set in the metadata
and the mode will be whatever dm defaults to.)

---
 lib/activate/activate.c          | 29 +++++++++++++++++++++++++++++
 lib/activate/activate.h          |  1 +
 lib/metadata/cache_manip.c       | 16 ++++++++++++++++
 lib/metadata/lv.c                |  5 +++++
 lib/metadata/lv.h                |  1 +
 lib/metadata/metadata-exported.h |  1 +
 lib/report/columns.h             |  1 +
 lib/report/properties.c          |  2 ++
 lib/report/report.c              | 18 ++++++++++++++++++
 9 files changed, 74 insertions(+)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 2091fa12d2db..4c08d2c846bd 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1140,6 +1140,35 @@ int lv_cache_policy_info(struct logical_volume *lv,
 	return 1;
 }
 
+const char *lv_cache_pool_cachemode(const struct logical_volume *lv)
+{
+	struct dev_manager *dm;
+	struct dm_status_cache *status;
+	const char *cachemode;
+
+	if (!lv_info(lv->vg->cmd, lv, 0, NULL, 0, 0))
+		return NULL;
+
+	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, 1)))
+		return NULL;
+
+	if (!dev_manager_cache_status(dm, lv, &status)) {
+		dev_manager_destroy(dm);
+		return NULL;
+	}
+
+	if (status->feature_flags & DM_CACHE_FEATURE_WRITEBACK)
+		cachemode = "writeback";
+	else if (status->feature_flags & DM_CACHE_FEATURE_WRITETHROUGH)
+		cachemode = "writethrough";
+	else
+		cachemode = "not_found";
+
+	dev_manager_destroy(dm);
+
+	return cachemode;
+}
+
 /*
  * Returns data or metadata percent usage, depends on metadata 0/1.
  * Returns 1 if percent set, else 0 on failure.
diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index b6cf4744ac1f..b5a43c8a00b1 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -126,6 +126,7 @@ int lv_cache_block_info(struct logical_volume *lv,
 int lv_cache_policy_info(struct logical_volume *lv,
 			 const char **policy_name, int *policy_argc,
 			 const char ***policy_argv);
+const char *lv_cache_pool_cachemode(const struct logical_volume *lv);
 int lv_thin_pool_percent(const struct logical_volume *lv, int metadata,
 			 dm_percent_t *percent);
 int lv_thin_percent(const struct logical_volume *lv, int mapped,
diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 7f5ea65c35fe..6d19ed526f8d 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -22,6 +22,22 @@
 #include "activate.h"
 #include "defaults.h"
 
+const char *get_cachepool_cachemode_name(const struct lv_segment *seg)
+{
+	const char *cachemode;
+
+	cachemode = lv_cache_pool_cachemode(seg->lv);
+	if (!cachemode) {
+		if (seg->feature_flags & DM_CACHE_FEATURE_WRITEBACK)
+			cachemode = "writeback";
+		else if (seg->feature_flags & DM_CACHE_FEATURE_WRITETHROUGH)
+			cachemode = "writethrough";
+		else
+			cachemode = "default";
+	}
+	return cachemode;
+}
+
 int update_cache_pool_params(struct volume_group *vg, unsigned attr,
 			     int passed_args, uint32_t data_extents,
 			     uint64_t *pool_metadata_size,
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index d29e787aae0a..23f0991dcb67 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -128,6 +128,11 @@ char *lvseg_discards_dup(struct dm_pool *mem, const struct lv_segment *seg)
 	return  dm_pool_strdup(mem, get_pool_discards_name(seg->discards));
 }
 
+char *lvseg_cachemode_dup(struct dm_pool *mem, const struct lv_segment *seg)
+{
+	return dm_pool_strdup(mem, get_cachepool_cachemode_name(seg));
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
index a69979952d4f..d1e0833ea3c1 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1074,6 +1074,7 @@ int partial_raid_lv_supports_degraded_activation(struct logical_volume *lv);
 /* --  metadata/raid_manip.c */
 
 /* ++  metadata/cache_manip.c */
+const char *get_cachepool_cachemode_name(const struct lv_segment *seg);
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
index c0e0b47cc4a5..112ea95f8e54 100644
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
+		cachemode_str = get_cachepool_cachemode_name(seg);
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


