From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 10 Mar 2017 13:37:21 -0500
Subject: master - cache: reporting cache metadata format
Message-ID: <201703101837.v2AIbLP6022195@int-mx13.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0a9b52f7a4f6dfbf23295ad694e4ff6b9a420cc3
Commit:        0a9b52f7a4f6dfbf23295ad694e4ff6b9a420cc3
Parent:        64d3f05aa1ee22cb337d5d8e9d650cb02040543a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 23 17:41:59 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 10 19:33:01 2017 +0100

cache: reporting cache metadata format

Report CMFmt column with cache metadata format version.

Report KMFmt column with 'kernel cache metadata format version' for device.
(a value reported from status).

(Update 'CacheMode' to name 'Cache' as primary segtype).
---
 lib/report/columns.h    |    6 ++++--
 lib/report/properties.c |    4 ++++
 lib/report/report.c     |   39 +++++++++++++++++++++++++++++++++++++++
 3 files changed, 47 insertions(+), 2 deletions(-)

diff --git a/lib/report/columns.h b/lib/report/columns.h
index 74078f5..be39ed9 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2013 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2017 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -140,6 +140,7 @@ FIELD(LVSSTATUS, lv, NUM, "CacheWriteHits", lvid, 16, cache_write_hits, cache_wr
 FIELD(LVSSTATUS, lv, NUM, "CacheWriteMisses", lvid, 0, cache_write_misses, cache_write_misses, "Cache write misses.", 0)
 FIELD(LVSSTATUS, lv, STR_LIST, "KCacheSettings", lvid, 18, kernel_cache_settings, kernel_cache_settings, "Cache settings/parameters as set in kernel, including default values (cached segments only).", 0)
 FIELD(LVSSTATUS, lv, STR, "KCachePolicy", lvid, 18, kernel_cache_policy, kernel_cache_policy, "Cache policy used in kernel.", 0)
+FIELD(LVSSTATUS, lv, NUM, "KMFmt", lvid, 0, kernelmetadataformat, kernel_metadata_format, "Cache metadata format used in kernel.", 0)
 FIELD(LVSSTATUS, lv, STR, "Health", lvid, 15, lvhealthstatus, lv_health_status, "LV health status.", 0)
 FIELD(LVSSTATUS, lv, STR, "KDiscards", lvid, 0, kdiscards, kernel_discards, "For thin pools, how discards are handled in kernel.", 0)
 FIELD(LVSSTATUS, lv, BIN, "CheckNeeded", lvid, 15, lvcheckneeded, lv_check_needed, "For thin pools and cache volumes, whether metadata check is needed.", 0)
@@ -254,7 +255,8 @@ FIELD(SEGS, seg, SIZ, "Region", region_size, 0, size32, region_size, "For mirror
 FIELD(SEGS, seg, SIZ, "Chunk", list, 0, chunksize, chunk_size, "For snapshots, the unit of data used when tracking changes.", 0)
 FIELD(SEGS, seg, NUM, "#Thins", list, 0, thincount, thin_count, "For thin pools, the number of thin volumes in this pool.", 0)
 FIELD(SEGS, seg, STR, "Discards", list, 0, discards, discards, "For thin pools, how discards are handled.", 0)
-FIELD(SEGS, seg, STR, "CacheMode", list, 0, cachemode, cache_mode, "For cache pools, how writes are cached.", 0)
+FIELD(SEGS, seg, NUM, "CMFmt", list, 0, cachemetadataformat, cache_metadata_format, "For cache, metadata format in use.", 0)
+FIELD(SEGS, seg, STR, "CacheMode", list, 0, cachemode, cache_mode, "For cache, how writes are cached.", 0)
 FIELD(SEGS, seg, BIN, "Zero", list, 0, thinzero, zero, "For thin pools and volumes, if zeroing is enabled.", 0)
 FIELD(SEGS, seg, NUM, "TransId", list, 0, transactionid, transaction_id, "For thin pools, the transaction id and creation transaction id for thins.", 0)
 FIELD(SEGS, seg, NUM, "ThId", list, 0, thinid, thin_id, "For thin volume, the thin device id.", 0)
diff --git a/lib/report/properties.c b/lib/report/properties.c
index c07fb2a..8e86b7a 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -482,6 +482,8 @@ GET_LVSEG_STR_PROPERTY_FN(kernel_discards, lvseg_kernel_discards_dup(lvseg->lv->
 #define _kernel_discards_set prop_not_implemented_set
 GET_LVSEG_STR_PROPERTY_FN(cache_mode, lvseg_cachemode_dup(lvseg->lv->vg->vgmem, lvseg))
 #define _cache_mode_set prop_not_implemented_set
+GET_LVSEG_NUM_PROPERTY_FN(cache_metadata_format, lvseg->cache_metadata_format)
+#define _cache_metadata_format_set prop_not_implemented_set
 GET_LVSEG_NUM_PROPERTY_FN(seg_start, (SECTOR_SIZE * lvseg_start(lvseg)))
 #define _seg_start_set prop_not_implemented_set
 GET_LVSEG_NUM_PROPERTY_FN(seg_start_pe, lvseg->le)
@@ -513,6 +515,8 @@ GET_LVSEG_STR_PROPERTY_FN(seg_monitor, lvseg_monitor_dup(lvseg->lv->vg->vgmem, l
 #define _kernel_cache_settings_set prop_not_implemented_set
 #define _kernel_cache_policy_get prop_not_implemented_get
 #define _kernel_cache_policy_set prop_not_implemented_set
+#define _kernel_metadata_format_get prop_not_implemented_get
+#define _kernel_metadata_format_set prop_not_implemented_set
 
 /* PVSEG */
 GET_PVSEG_NUM_PROPERTY_FN(pvseg_start, pvseg->pe)
diff --git a/lib/report/report.c b/lib/report/report.c
index 27269d4..afd922e 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -54,6 +54,7 @@ enum {
 
 static const uint64_t _zero64 = UINT64_C(0);
 static const uint64_t _one64 = UINT64_C(1);
+static const uint64_t _two64 = UINT64_C(2);
 static const char _str_zero[] = "0";
 static const char _str_one[] = "1";
 static const char _str_no[] = "no";
@@ -1537,6 +1538,21 @@ static int _kernel_cache_policy_disp(struct dm_report *rh, struct dm_pool *mem,
 				GET_FIELD_RESERVED_VALUE(cache_policy_undef));
 }
 
+static int _kernelmetadataformat_disp(struct dm_report *rh, struct dm_pool *mem,
+				      struct dm_report_field *field,
+				      const void *data, void *private)
+{
+	const struct lv_with_info_and_seg_status *lvdm = (const struct lv_with_info_and_seg_status *) data;
+	unsigned format;
+
+	if (lvdm->seg_status.type == SEG_STATUS_CACHE) {
+		format = (lvdm->seg_status.cache->feature_flags & DM_CACHE_FEATURE_METADATA2);
+		return dm_report_field_uint64(rh, field, format ? &_two64 : &_one64);
+	}
+
+	return _field_set_value(field, "", &GET_TYPE_RESERVED_VALUE(num_undef_64));
+}
+
 static int _cache_policy_disp(struct dm_report *rh, struct dm_pool *mem,
 			      struct dm_report_field *field,
 			      const void *data, void *private)
@@ -2718,6 +2734,29 @@ static int _cachemode_disp(struct dm_report *rh, struct dm_pool *mem,
 	return _field_string(rh, field, display_cache_mode(seg));
 }
 
+static int _cachemetadataformat_disp(struct dm_report *rh, struct dm_pool *mem,
+				     struct dm_report_field *field,
+				     const void *data, void *private)
+{
+	const struct lv_segment *seg = (const struct lv_segment *) data;
+	const uint64_t *fmt;
+
+	if (seg_is_cache(seg))
+		seg = first_seg(seg->pool_lv);
+
+	if (seg_is_cache_pool(seg)) {
+		switch (seg->cache_metadata_format) {
+		case CACHE_METADATA_FORMAT_1:
+		case CACHE_METADATA_FORMAT_2:
+			fmt = (seg->cache_metadata_format == CACHE_METADATA_FORMAT_2) ? &_two64 : &_one64;
+			return dm_report_field_uint64(rh, field, fmt);
+		default: /* unselected/undefined for all other cases */;
+		}
+	}
+
+	return _field_set_value(field, "", &GET_TYPE_RESERVED_VALUE(num_undef_64));
+}
+
 static int _originsize_disp(struct dm_report *rh, struct dm_pool *mem,
 			    struct dm_report_field *field,
 			    const void *data, void *private)


