From: David Teigland <teigland@redhat.com>
Date: Wed, 1 Oct 2014 16:09:45 -0500
Subject: [PATCH] cache: include cache mode in vg metadata and display
Message-ID: <20141001210945.GB10150@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The cache mode of a new cache pool is always explicitly
included in the vg metadata.  If a cache mode is not
specified on the command line, the cache mode is taken
from lvm.conf allocation/cache_pool_cachemode, which
defaults to "writethrough".

The cache mode can be displayed with lvs -o+cachemode.
---
 conf/example.conf.in             |  9 +++++++++
 lib/config/config_settings.h     |  1 +
 lib/config/defaults.h            |  1 +
 lib/metadata/cache_manip.c       | 11 +++++++++++
 lib/metadata/lv.c                |  5 +++++
 lib/metadata/lv.h                |  1 +
 lib/metadata/metadata-exported.h |  1 +
 lib/report/columns.h             |  1 +
 lib/report/properties.c          |  2 ++
 lib/report/report.c              | 18 ++++++++++++++++++
 man/lvm.conf.5.in                |  9 +++++++++
 tools/lvconvert.c                |  8 +++++---
 tools/lvcreate.c                 |  9 ++++++---
 13 files changed, 70 insertions(+), 6 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index dd1d066eb751..d1da23f81fcd 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -335,6 +335,15 @@ allocation {
     # range from 32(kiB) to 1048576 in multiples of 32.
     # cache_pool_chunk_size = 64
 
+    # Specify the default cache mode used for new cache pools.
+    # Possible options are:
+    # "writethrough"    - Data blocks are immediately written from
+    #                     the cache to disk.
+    # "writeback"       - Data blocks are written from the cache
+    #                     back to disk after some delay to improve
+    #                     performance.
+    # cache_pool_cachemode = "writethrough"
+
     # Set to 1 to guarantee that thin pool metadata will always
     # be placed on different PVs from the pool data.
     thin_pool_metadata_require_separate_pvs = 0
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 7724c5725437..a6c1d1b049df 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -120,6 +120,7 @@ cfg(allocation_use_blkid_wiping_CFG, "use_blkid_wiping", allocation_CFG_SECTION,
 cfg(allocation_wipe_signatures_when_zeroing_new_lvs_CFG, "wipe_signatures_when_zeroing_new_lvs", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, 1, vsn(2, 2, 105), NULL)
 cfg(allocation_mirror_logs_require_separate_pvs_CFG, "mirror_logs_require_separate_pvs", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_MIRROR_LOGS_REQUIRE_SEPARATE_PVS, vsn(2, 2, 85), NULL)
 cfg(allocation_cache_pool_metadata_require_separate_pvs_CFG, "cache_pool_metadata_require_separate_pvs", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_CACHE_POOL_METADATA_REQUIRE_SEPARATE_PVS, vsn(2, 2, 106), NULL)
+cfg(allocation_cache_pool_cachemode_CFG, "cache_pool_cachemode", allocation_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_CACHE_POOL_CACHEMODE, vsn(2, 2, 113), NULL)
 cfg_runtime(allocation_cache_pool_chunk_size_CFG, "cache_pool_chunk_size", allocation_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_INT, vsn(2, 2, 106), NULL)
 cfg(allocation_thin_pool_metadata_require_separate_pvs_CFG, "thin_pool_metadata_require_separate_pvs", allocation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_THIN_POOL_METADATA_REQUIRE_SEPARATE_PVS, vsn(2, 2, 89), NULL)
 cfg(allocation_thin_pool_zero_CFG, "thin_pool_zero", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA, CFG_TYPE_BOOL, DEFAULT_THIN_POOL_ZERO, vsn(2, 2, 99), NULL)
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 05187b08c120..2cb1e5aa9071 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -96,6 +96,7 @@
 #define DEFAULT_CACHE_POOL_CHUNK_SIZE 64 /* KB */
 #define DEFAULT_CACHE_POOL_MIN_METADATA_SIZE 2048  /* KB */
 #define DEFAULT_CACHE_POOL_MAX_METADATA_SIZE (16 * 1024 * 1024)  /* KB */
+#define DEFAULT_CACHE_POOL_CACHEMODE "writethrough"
 
 #define DEFAULT_UMASK 0077
 
diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 7f5ea65c35fe..a44bba89723a 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -22,6 +22,17 @@
 #include "activate.h"
 #include "defaults.h"
 
+const char *get_cachepool_cachemode_name(const struct lv_segment *seg)
+{
+	if (seg->feature_flags & DM_CACHE_FEATURE_WRITEBACK)
+		return "writeback";
+
+	if (seg->feature_flags & DM_CACHE_FEATURE_WRITETHROUGH)
+		return "writethrough";
+
+	return "unknown";
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
index d43bc01adea8..bcd702880ac6 100644
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
index 5787f5a1368d..b392bde990ac 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1069,6 +1069,7 @@ int partial_raid_lv_supports_degraded_activation(const struct logical_volume *lv
 /* --  metadata/raid_manip.c */
 
 /* ++  metadata/cache_manip.c */
+const char *get_cachepool_cachemode_name(const struct lv_segment *seg);
 int update_cache_pool_params(struct volume_group *vg, unsigned attr,
 			     int passed_args, uint32_t data_extents,
 			     uint64_t *pool_metadata_size,
diff --git a/lib/report/columns.h b/lib/report/columns.h
index 796ac4ec1632..a2f34f928122 100644
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
index c34aa5e6f030..69f75ed91e06 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -773,6 +773,24 @@ static int _discards_disp(struct dm_report *rh, struct dm_pool *mem,
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
diff --git a/man/lvm.conf.5.in b/man/lvm.conf.5.in
index c4345270a01e..5bc20815680b 100644
--- a/man/lvm.conf.5.in
+++ b/man/lvm.conf.5.in
@@ -299,6 +299,15 @@ they are situated and these two PV tags are selected for use with this
 allocation policy:
 .IP
 cling_tag_list = [ "@site1", "@site2" ]
+.IP
+\fBcache_pool_cachemode\fP \(em Cache mode for new cache pools.
+.IP
+This is the default cache mode a new cache pool will be given.
+Valid cache modes are:
+\fBwritethrough\fP - Data blocks are immediately written from the
+cache to disk.
+\fBwriteback\fP - Data blocks are written from the cache
+back to disk after some delay to improve performance.
 .TP
 \fBlog\fP \(em Default log settings
 .IP
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index c05ea1b822fc..09257e333832 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -204,7 +204,6 @@ static int _mirror_or_raid_type_requested(struct cmd_context *cmd, const char *t
 static int _read_pool_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 			     const char *type_str, int *pargc, char ***pargv)
 {
-	const char *tmp_str;
 	int cachepool = 0;
 	int thinpool = 0;
 
@@ -234,8 +233,11 @@ static int _read_pool_params(struct lvconvert_params *lp, struct cmd_context *cm
 		thinpool = 1;
 
 	if (cachepool) {
-		if ((tmp_str = arg_str_value(cmd, cachemode_ARG, NULL)) &&
-		    !get_cache_mode(tmp_str, &lp->feature_flags))
+		const char *cachemode = arg_str_value(cmd, cachemode_ARG, NULL);
+		if (!cachemode)
+			cachemode = find_config_tree_str(cmd, allocation_cache_pool_cachemode_CFG, NULL);
+
+		if (!get_cache_mode(cachemode, &lp->feature_flags))
 			return_0;
 	} else {
 		if (arg_from_list_is_set(cmd, "is valid only with cache pools",
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 17fcd46d618d..bb3892db1792 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -693,13 +693,16 @@ static int _read_raid_params(struct lvcreate_params *lp,
 static int _read_cache_pool_params(struct lvcreate_params *lp,
 				  struct cmd_context *cmd)
 {
-	const char *str_arg;
+	const char *cachemode;
 
 	if (!segtype_is_cache_pool(lp->segtype))
 		return 1;
 
-	if ((str_arg = arg_str_value(cmd, cachemode_ARG, NULL)) &&
-	    !get_cache_mode(str_arg, &lp->feature_flags))
+	cachemode = arg_str_value(cmd, cachemode_ARG, NULL);
+	if (!cachemode)
+		cachemode = find_config_tree_str(cmd, allocation_cache_pool_cachemode_CFG, NULL);
+
+	if (!get_cache_mode(cachemode, &lp->feature_flags))
 		return_0;
 
 	return 1;
-- 
1.8.3.1


