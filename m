From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 11 Nov 2014 12:12:39 +0000 (UTC)
Subject: master - report: add cache device status fields
Message-ID: <20141111121239.DDD3261079@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2dde6c6531f9a06896ae61f0878745542b4001b6
Commit:        2dde6c6531f9a06896ae61f0878745542b4001b6
Parent:        a2c1024f6ac7e22ac5c010a267d0c1df331ee416
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Oct 24 13:39:56 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Nov 11 13:07:30 2014 +0100

report: add cache device status fields

New reporting fields related to cache device status:
  - cache_total_blocks
  - cache_used_blocks
  - cache_dirty_blocks
  - cache_read_hits
  - cache_read_misses
  - cache_write_hits
  - cache_write_misses
---
 WHATS_NEW               |    2 ++
 lib/report/columns.h    |    8 ++++++++
 lib/report/properties.c |   15 +++++++++++++++
 lib/report/report.c     |   25 +++++++++++++++++++++++++
 4 files changed, 50 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 0b5d892..3a3f7d5 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
 Version 2.02.112 - 
 =====================================
+  Add cache_{read_write}_{hits,misses} reporting fields.
+  Add cache_{total,used,dirty}_blocks reporting fields.
   Add _corig as reserved suffix.
   Reduce vg write and vg commits when creating spare volumes.
   When remove_layer_from_lv() removes layer, restore subLV names.
diff --git a/lib/report/columns.h b/lib/report/columns.h
index a2f34f9..db43e13 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -95,6 +95,14 @@ FIELD(LVSINFO, lv, BIN, "LiveTable", lvid, 20, lvlivetable, lv_live_table, "Set
 FIELD(LVSINFO, lv, BIN, "InactiveTable", lvid, 20, lvinactivetable, lv_inactive_table, "Set if LV has inactive table present.", 0)
 FIELD(LVSINFO, lv, BIN, "DevOpen", lvid, 10, lvdeviceopen, lv_device_open, "Set if LV device is open.", 0)
 
+FIELD(LVSSTATUS, lv, NUM, "CacheTotalBlocks", lvid, 16, cache_total_blocks, cache_total_blocks, "Total cache blocks.", 0)
+FIELD(LVSSTATUS, lv, NUM, "CacheUsedBlocks", lvid, 16, cache_used_blocks, cache_used_blocks, "Used cache blocks.", 0)
+FIELD(LVSSTATUS, lv, NUM, "CacheDirtyBlocks", lvid, 16, cache_dirty_blocks, cache_dirty_blocks, "Dirty cache blocks.", 0)
+FIELD(LVSSTATUS, lv, NUM, "CacheReadHits", lvid, 16, cache_read_hits, cache_read_hits, "Cache read hits.", 0)
+FIELD(LVSSTATUS, lv, NUM, "CacheReadMisses", lvid, 16, cache_read_misses, cache_read_misses, "Cache read misses.", 0)
+FIELD(LVSSTATUS, lv, NUM, "CacheWriteHits", lvid, 16, cache_write_hits, cache_write_hits, "Cache write hits.", 0)
+FIELD(LVSSTATUS, lv, NUM, "CacheWriteMisses", lvid, 16, cache_write_misses, cache_write_misses, "Cache write misses.", 0)
+
 FIELD(LABEL, label, STR, "Fmt", type, 3, pvfmt, pv_fmt, "Type of metadata.", 0)
 FIELD(LABEL, label, STR, "PV UUID", type, 38, pvuuid, pv_uuid, "Unique identifier.", 0)
 FIELD(LABEL, label, SIZ, "DevSize", dev, 7, devsize, dev_size, "Size of underlying device in current units.", 0)
diff --git a/lib/report/properties.c b/lib/report/properties.c
index 3389087..2308c36 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -248,6 +248,21 @@ GET_PV_NUM_PROPERTY_FN(pv_ba_size, SECTOR_SIZE * pv->ba_size)
 #define _lv_skip_activation_set prop_not_implemented_set
 #define _lv_skip_activation_get prop_not_implemented_get
 
+#define _cache_total_blocks_set prop_not_implemented_set
+#define _cache_total_blocks_get prop_not_implemented_get
+#define _cache_used_blocks_set prop_not_implemented_set
+#define _cache_used_blocks_get prop_not_implemented_get
+#define _cache_dirty_blocks_set prop_not_implemented_set
+#define _cache_dirty_blocks_get prop_not_implemented_get
+#define _cache_read_hits_set prop_not_implemented_set
+#define _cache_read_hits_get prop_not_implemented_get
+#define _cache_read_misses_set prop_not_implemented_set
+#define _cache_read_misses_get prop_not_implemented_get
+#define _cache_write_hits_set prop_not_implemented_set
+#define _cache_write_hits_get prop_not_implemented_get
+#define _cache_write_misses_set prop_not_implemented_set
+#define _cache_write_misses_get prop_not_implemented_get
+
 /* LV */
 GET_LV_STR_PROPERTY_FN(lv_uuid, lv_uuid_dup(lv))
 #define _lv_uuid_set prop_not_implemented_set
diff --git a/lib/report/report.c b/lib/report/report.c
index 74ba4bc..42355e2 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1686,6 +1686,31 @@ static int _lvskipactivation_disp(struct dm_report *rh, struct dm_pool *mem,
 	return _binary_disp(rh, mem, field, skip_activation, "skip activation", private);
 }
 
+/*
+ * Macro to generate '_cache_<cache_status_field_name>_disp' reporting function.
+ * The 'cache_status_field_name' is field name from struct dm_cache_status.
+ */
+#define GENERATE_CACHE_STATUS_DISP_FN(cache_status_field_name) \
+static int _cache_ ## cache_status_field_name ## _disp (struct dm_report *rh, \
+							struct dm_pool *mem, \
+							struct dm_report_field *field, \
+							const void *data, \
+							void *private) \
+{ \
+	const struct lv_with_info_and_seg_status *lvdm = (const struct lv_with_info_and_seg_status *) data; \
+	if (lvdm->seg_status->type != SEG_STATUS_CACHE) \
+		return _field_set_value(field, "", &RESERVED(number_undef_64)); \
+	return dm_report_field_uint64(rh, field, (void *) ((char *) lvdm->seg_status->status + offsetof(struct dm_status_cache, cache_status_field_name))); \
+}
+
+GENERATE_CACHE_STATUS_DISP_FN(total_blocks)
+GENERATE_CACHE_STATUS_DISP_FN(used_blocks)
+GENERATE_CACHE_STATUS_DISP_FN(dirty_blocks)
+GENERATE_CACHE_STATUS_DISP_FN(read_hits)
+GENERATE_CACHE_STATUS_DISP_FN(read_misses)
+GENERATE_CACHE_STATUS_DISP_FN(write_hits)
+GENERATE_CACHE_STATUS_DISP_FN(write_misses)
+
 /* Report object types */
 
 /* necessary for displaying something for PVs not belonging to VG */


