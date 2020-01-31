From: David Teigland <teigland@sourceware.org>
Date: Fri, 31 Jan 2020 12:58:20 -0500
Subject: master - writecache: report status fields
Message-ID: <01363.120013112581501313@us-mta-235.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bddbbcb98ca135b91aa688c04c1c8be7d76a2bd1
Commit:        bddbbcb98ca135b91aa688c04c1c8be7d76a2bd1
Parent:        2444e830a90fe84721bd61f950946eedcbce0af7
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jan 31 11:52:49 2020 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jan 31 11:52:49 2020 -0600

writecache: report status fields

reporting fields (-o) directly from kernel:
writecache_total_blocks
writecache_free_blocks
writecache_writeback_blocks
writecache_error

The data_percent field shows used cache blocks / total cache blocks.
---
 device_mapper/all.h           |  2 +-
 device_mapper/libdm-targets.c |  4 ++--
 lib/metadata/lv.c             |  8 ++++++++
 lib/report/columns.h          |  4 ++++
 lib/report/properties.c       |  9 +++++++++
 lib/report/report.c           | 21 +++++++++++++++++++++
 6 files changed, 45 insertions(+), 3 deletions(-)

diff --git a/device_mapper/all.h b/device_mapper/all.h
index 57673b4..b23485f 100644
--- a/device_mapper/all.h
+++ b/device_mapper/all.h
@@ -383,7 +383,7 @@ int dm_get_status_cache(struct dm_pool *mem, const char *params,
 			struct dm_status_cache **status);
 
 struct dm_status_writecache {
-	uint32_t error;
+	uint64_t error;
 	uint64_t total_blocks;
 	uint64_t free_blocks;
 	uint64_t writeback_blocks;
diff --git a/device_mapper/libdm-targets.c b/device_mapper/libdm-targets.c
index d82e28b..86cb847 100644
--- a/device_mapper/libdm-targets.c
+++ b/device_mapper/libdm-targets.c
@@ -366,8 +366,8 @@ int dm_get_status_writecache(struct dm_pool *mem, const char *params,
 	if (!(s = dm_pool_zalloc(mem, sizeof(struct dm_status_writecache))))
 		return_0;
 
-	if (sscanf(params, "%u %llu %llu %llu",
-		   &s->error,
+	if (sscanf(params, "%llu %llu %llu %llu",
+		   (unsigned long long *)&s->error,
 		   (unsigned long long *)&s->total_blocks,
 		   (unsigned long long *)&s->free_blocks,
 		   (unsigned long long *)&s->writeback_blocks) != 4) {
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 4c2ab2b..ab26b8d 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -405,6 +405,14 @@ dm_percent_t lvseg_percent_with_info_and_seg_status(const struct lv_with_info_an
 			}
 		}
 		break;
+	case SEG_STATUS_WRITECACHE:
+		if (type != PERCENT_GET_DATA)
+			p = DM_PERCENT_INVALID;
+		else {
+			uint64_t used = s->writecache->total_blocks - s->writecache->free_blocks;
+			p = dm_make_percent(used, s->writecache->total_blocks);
+		}
+		break;
 	case SEG_STATUS_RAID:
 		switch (type) {
 		case PERCENT_GET_DIRTY:
diff --git a/lib/report/columns.h b/lib/report/columns.h
index 0a89451..31a1d17 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -151,6 +151,10 @@ FIELD(LVSSTATUS, lv, STR, "VDOCompressionState", lvid, 0, vdo_compression_state,
 FIELD(LVSSTATUS, lv, STR, "VDOIndexState", lvid, 0, vdo_index_state, vdo_index_state, "For vdo pools, state of index for deduplication.", 0)
 FIELD(LVSSTATUS, lv, NUM, "VDOUsedSize", lvid, 0, vdo_used_size, vdo_used_size, "For vdo pools, currently used space.", 0)
 FIELD(LVSSTATUS, lv, NUM, "VDOSaving%", lvid, 0, vdo_saving_percent, vdo_saving_percent, "For vdo pools, percentage of saved space.", 0)
+FIELD(LVSSTATUS, lv, NUM, "WCacheTotalBlocks", lvid, 0, writecache_total_blocks, writecache_total_blocks, "Total writecache blocks.", 0)
+FIELD(LVSSTATUS, lv, NUM, "WCacheFreeBlocks", lvid, 0, writecache_free_blocks, writecache_free_blocks, "Total writecache free blocks.", 0)
+FIELD(LVSSTATUS, lv, NUM, "WCacheWritebackBlocks", lvid, 0, writecache_writeback_blocks, writecache_writeback_blocks, "Total writecache writeback blocks.", 0)
+FIELD(LVSSTATUS, lv, NUM, "WCacheErrors", lvid, 0, writecache_error, writecache_error, "Total writecache errors.", 0)
 /*
  * End of LVSSTATUS type fields
  */
diff --git a/lib/report/properties.c b/lib/report/properties.c
index 25e263f..3257505 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -279,6 +279,15 @@ GET_PV_NUM_PROPERTY_FN(pv_ba_size, SECTOR_SIZE * pv->ba_size)
 #define _cache_write_misses_set prop_not_implemented_set
 #define _cache_write_misses_get prop_not_implemented_get
 
+#define _writecache_total_blocks_set prop_not_implemented_set
+#define _writecache_total_blocks_get prop_not_implemented_get
+#define _writecache_free_blocks_set prop_not_implemented_set
+#define _writecache_free_blocks_get prop_not_implemented_get
+#define _writecache_writeback_blocks_set prop_not_implemented_set
+#define _writecache_writeback_blocks_get prop_not_implemented_get
+#define _writecache_error_set prop_not_implemented_set
+#define _writecache_error_get prop_not_implemented_get
+
 #define _vdo_operating_mode_set prop_not_implemented_set
 #define _vdo_operating_mode_get prop_not_implemented_get
 #define _vdo_compression_state_set prop_not_implemented_set
diff --git a/lib/report/report.c b/lib/report/report.c
index 70ee514..d379e2a 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -3875,6 +3875,27 @@ GENERATE_CACHE_STATUS_DISP_FN(read_misses)
 GENERATE_CACHE_STATUS_DISP_FN(write_hits)
 GENERATE_CACHE_STATUS_DISP_FN(write_misses)
 
+/*
+ * Macro to generate '_writecache_<cache_status_field_name>_disp' reporting function.
+ * The 'writecache_status_field_name' is field name from struct dm_writecache_status.
+ */
+#define GENERATE_WRITECACHE_STATUS_DISP_FN(writecache_status_field_name) \
+static int _writecache_ ## writecache_status_field_name ## _disp (struct dm_report *rh, \
+							struct dm_pool *mem, \
+							struct dm_report_field *field, \
+							const void *data, \
+							void *private) \
+{ \
+	const struct lv_with_info_and_seg_status *lvdm = (const struct lv_with_info_and_seg_status *) data; \
+	if (lvdm->seg_status.type != SEG_STATUS_WRITECACHE) \
+		return _field_set_value(field, "", &GET_TYPE_RESERVED_VALUE(num_undef_64)); \
+	return dm_report_field_uint64(rh, field, &lvdm->seg_status.writecache->writecache_status_field_name); \
+}
+
+GENERATE_WRITECACHE_STATUS_DISP_FN(total_blocks)
+GENERATE_WRITECACHE_STATUS_DISP_FN(free_blocks)
+GENERATE_WRITECACHE_STATUS_DISP_FN(writeback_blocks)
+GENERATE_WRITECACHE_STATUS_DISP_FN(error)
 
 /*
  * Macro to generate '_vdo_<vdo_field_name>_disp' reporting function.



