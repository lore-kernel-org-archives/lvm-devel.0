From: David Teigland <teigland@sourceware.org>
Date: Tue, 6 Nov 2018 16:43:54 -0500
Subject: master - Add dm-writecache support
Message-ID: <201811062143.wA6Lhs3K004837@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3ae55695708b5d702f21daf776607d30cebe69c3
Commit:        3ae55695708b5d702f21daf776607d30cebe69c3
Parent:        cac4a9743acb826d785c0e51e9a752d8959ced80
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Aug 27 14:53:09 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Nov 6 14:18:41 2018 -0600

Add dm-writecache support

dm-writecache is used like dm-cache with a standard LV
as the cache.

$ lvcreate -n main -L 128M -an foo /dev/loop0

$ lvcreate -n fast -L 32M -an foo /dev/pmem0

$ lvconvert --type writecache --cachepool fast foo/main

$ lvs -a foo -o+devices
  LV            VG  Attr       LSize   Origin        Devices
  [fast]        foo -wi-------  32.00m               /dev/pmem0(0)
  main          foo Cwi------- 128.00m [main_wcorig] main_wcorig(0)
  [main_wcorig] foo -wi------- 128.00m               /dev/loop0(0)

$ lvchange -ay foo/main

$ dmsetup table
foo-main_wcorig: 0 262144 linear 7:0 2048
foo-main: 0 262144 writecache p 253:4 253:3 4096 0
foo-fast: 0 65536 linear 259:0 2048

$ lvchange -an foo/main

$ lvconvert --splitcache foo/main

$ lvs -a foo -o+devices
  LV   VG  Attr       LSize   Devices
  fast foo -wi-------  32.00m /dev/pmem0(0)
  main foo -wi------- 128.00m /dev/loop0(0)
---
 configure.ac                     |   18 ++
 device_mapper/all.h              |   48 +++
 device_mapper/libdm-deptree.c    |  134 ++++++++
 device_mapper/libdm-targets.c    |   32 ++
 lib/Makefile.in                  |    1 +
 lib/activate/activate.c          |   20 ++
 lib/activate/activate.h          |    5 +
 lib/activate/dev_manager.c       |   47 +++
 lib/activate/dev_manager.h       |    3 +
 lib/commands/toolcontext.c       |    5 +
 lib/device/dev-type.c            |   42 +++
 lib/device/dev-type.h            |    2 +
 lib/format_text/flags.c          |    1 +
 lib/metadata/lv.c                |    4 +-
 lib/metadata/lv_manip.c          |   10 +
 lib/metadata/merge.c             |    2 +-
 lib/metadata/metadata-exported.h |    8 +
 lib/metadata/metadata.c          |   35 +++
 lib/metadata/segtype.h           |    6 +
 lib/writecache/writecache.c      |  314 +++++++++++++++++++
 test/shell/writecache.sh         |  129 ++++++++
 tools/args.h                     |    3 +
 tools/command-lines.in           |   24 +-
 tools/lv_types.h                 |    1 +
 tools/lvconvert.c                |  621 +++++++++++++++++++++++++++++++++++---
 tools/lvmcmdline.c               |    7 +-
 tools/toollib.c                  |   13 +-
 tools/tools.h                    |    3 +-
 28 files changed, 1481 insertions(+), 57 deletions(-)

diff --git a/configure.ac b/configure.ac
index 70fd674..8549a80 100644
--- a/configure.ac
+++ b/configure.ac
@@ -643,6 +643,24 @@ AC_DEFINE_UNQUOTED([VDO_FORMAT_CMD], ["$VDO_FORMAT_CMD"],
 #AC_MSG_RESULT($VDO_LIB)
 
 ################################################################################
+dnl -- writecache inclusion type
+AC_MSG_CHECKING(whether to include writecache)
+AC_ARG_WITH(writecache,
+	    AC_HELP_STRING([--with-writecache=TYPE],
+			   [writecache support: internal/none [internal]]),
+			   WRITECACHE=$withval, WRITECACHE="none")
+
+AC_MSG_RESULT($WRITECACHE)
+
+case "$WRITECACHE" in
+ none) ;;
+ internal) 
+	AC_DEFINE([WRITECACHE_INTERNAL], 1, [Define to 1 to include built-in support for writecache.])
+	;;
+ *) AC_MSG_ERROR([--with-writecache parameter invalid]) ;;
+esac
+
+################################################################################
 dnl -- Disable readline
 AC_ARG_ENABLE([readline],
 	      AC_HELP_STRING([--disable-readline], [disable readline support]),
diff --git a/device_mapper/all.h b/device_mapper/all.h
index 0f01075..6fe80f8 100644
--- a/device_mapper/all.h
+++ b/device_mapper/all.h
@@ -378,6 +378,16 @@ struct dm_status_cache {
 int dm_get_status_cache(struct dm_pool *mem, const char *params,
 			struct dm_status_cache **status);
 
+struct dm_status_writecache {
+	uint32_t error;
+	uint64_t total_blocks;
+	uint64_t free_blocks;
+	uint64_t writeback_blocks;
+};
+
+int dm_get_status_writecache(struct dm_pool *mem, const char *params,
+                             struct dm_status_writecache **status);
+
 /*
  * Parse params from STATUS call for snapshot target
  *
@@ -918,6 +928,44 @@ int dm_tree_node_add_cache_target(struct dm_tree_node *node,
 				  uint64_t data_len,
 				  uint32_t data_block_size);
 
+struct writecache_settings {
+	uint64_t high_watermark;
+	uint64_t low_watermark;
+	uint64_t writeback_jobs;
+	uint64_t autocommit_blocks;
+	uint64_t autocommit_time; /* in milliseconds */
+	uint32_t fua;
+	uint32_t nofua;
+
+	/*
+	 * Allow an unrecognized key and its val to be passed to the kernel for
+	 * cases where a new kernel setting is added but lvm doesn't know about
+	 * it yet.
+	 */
+	char *new_key;
+	char *new_val;
+
+	/*
+	 * Flag is 1 if a value has been set.
+	 */
+	unsigned high_watermark_set:1;
+	unsigned low_watermark_set:1;
+	unsigned writeback_jobs_set:1;
+	unsigned autocommit_blocks_set:1;
+	unsigned autocommit_time_set:1;
+	unsigned fua_set:1;
+	unsigned nofua_set:1;
+};
+
+int dm_tree_node_add_writecache_target(struct dm_tree_node *node,
+				uint64_t size,
+				const char *origin_uuid,
+				const char *cache_uuid,
+				int pmem,
+				uint32_t writecache_block_size,
+				struct writecache_settings *settings);
+
+
 /*
  * VDO target
  */
diff --git a/device_mapper/libdm-deptree.c b/device_mapper/libdm-deptree.c
index 13239c7..89a0a48 100644
--- a/device_mapper/libdm-deptree.c
+++ b/device_mapper/libdm-deptree.c
@@ -37,6 +37,7 @@ enum {
 	SEG_SNAPSHOT_MERGE,
 	SEG_STRIPED,
 	SEG_ZERO,
+	SEG_WRITECACHE,
 	SEG_THIN_POOL,
 	SEG_THIN,
 	SEG_VDO,
@@ -76,6 +77,7 @@ static const struct {
 	{ SEG_SNAPSHOT_MERGE, "snapshot-merge" },
 	{ SEG_STRIPED, "striped" },
 	{ SEG_ZERO, "zero"},
+	{ SEG_WRITECACHE, "writecache"},
 	{ SEG_THIN_POOL, "thin-pool"},
 	{ SEG_THIN, "thin"},
 	{ SEG_VDO, "vdo" },
@@ -212,6 +214,11 @@ struct load_segment {
 	struct dm_tree_node *vdo_data;  /* VDO */
 	struct dm_vdo_target_params vdo_params; /* VDO */
 	const char *vdo_name;           /* VDO - device name is ALSO passed as table arg */
+
+	struct dm_tree_node *writecache_node;		/* writecache */
+	int writecache_pmem;				/* writecache, 1 if pmem, 0 if ssd */
+	uint32_t writecache_block_size;			/* writecache, in bytes */
+	struct writecache_settings writecache_settings;	/* writecache */
 };
 
 /* Per-device properties */
@@ -2605,6 +2612,88 @@ static int _cache_emit_segment_line(struct dm_task *dmt,
 	return 1;
 }
 
+static int _writecache_emit_segment_line(struct dm_task *dmt,
+				    struct load_segment *seg,
+				    char *params, size_t paramsize)
+{
+	int pos = 0;
+	int count = 0;
+	uint32_t block_size;
+	char origin_dev[DM_FORMAT_DEV_BUFSIZE];
+	char cache_dev[DM_FORMAT_DEV_BUFSIZE];
+
+	if (!_build_dev_string(origin_dev, sizeof(origin_dev), seg->origin))
+		return_0;
+
+	if (!_build_dev_string(cache_dev, sizeof(cache_dev), seg->writecache_node))
+		return_0;
+
+	if (seg->writecache_settings.high_watermark_set)
+		count += 2;
+	if (seg->writecache_settings.low_watermark_set)
+		count += 2;
+	if (seg->writecache_settings.writeback_jobs_set)
+		count += 2;
+	if (seg->writecache_settings.autocommit_blocks_set)
+		count += 2;
+	if (seg->writecache_settings.autocommit_time_set)
+		count += 2;
+	if (seg->writecache_settings.fua_set)
+		count += 1;
+	if (seg->writecache_settings.nofua_set)
+		count += 1;
+	if (seg->writecache_settings.new_key)
+		count += 2;
+
+	if (!(block_size = seg->writecache_block_size))
+		block_size = 4096;
+
+	EMIT_PARAMS(pos, "%s %s %s %u %d",
+		    seg->writecache_pmem ? "p" : "s",
+		    origin_dev, cache_dev, block_size, count);
+
+	if (seg->writecache_settings.high_watermark_set) {
+		EMIT_PARAMS(pos, " high_watermark %llu",
+			(unsigned long long)seg->writecache_settings.high_watermark);
+	}
+
+	if (seg->writecache_settings.low_watermark_set) {
+		EMIT_PARAMS(pos, " low_watermark %llu",
+			(unsigned long long)seg->writecache_settings.low_watermark);
+	}
+
+	if (seg->writecache_settings.writeback_jobs_set) {
+		EMIT_PARAMS(pos, " writeback_jobs %llu",
+			(unsigned long long)seg->writecache_settings.writeback_jobs);
+	}
+
+	if (seg->writecache_settings.autocommit_blocks_set) {
+		EMIT_PARAMS(pos, " autocommit_blocks %llu",
+			(unsigned long long)seg->writecache_settings.autocommit_blocks);
+	}
+
+	if (seg->writecache_settings.autocommit_time_set) {
+		EMIT_PARAMS(pos, " autocommit_time %llu",
+			(unsigned long long)seg->writecache_settings.autocommit_time);
+	}
+
+	if (seg->writecache_settings.fua_set) {
+		EMIT_PARAMS(pos, " fua");
+	}
+
+	if (seg->writecache_settings.nofua_set) {
+		EMIT_PARAMS(pos, " nofua");
+	}
+
+	if (seg->writecache_settings.new_key) {
+		EMIT_PARAMS(pos, " %s %s",
+			seg->writecache_settings.new_key,
+			seg->writecache_settings.new_val);
+	}
+
+	return 1;
+}
+
 static int _thin_pool_emit_segment_line(struct dm_task *dmt,
 					struct load_segment *seg,
 					char *params, size_t paramsize)
@@ -2784,6 +2873,10 @@ static int _emit_segment_line(struct dm_task *dmt, uint32_t major,
 		if (!_cache_emit_segment_line(dmt, seg, params, paramsize))
 			return_0;
 		break;
+	case SEG_WRITECACHE:
+		if (!_writecache_emit_segment_line(dmt, seg, params, paramsize))
+			return_0;
+		break;
 	}
 
 	switch(seg->type) {
@@ -2795,6 +2888,7 @@ static int _emit_segment_line(struct dm_task *dmt, uint32_t major,
 	case SEG_THIN_POOL:
 	case SEG_THIN:
 	case SEG_CACHE:
+	case SEG_WRITECACHE:
 		break;
 	case SEG_CRYPT:
 	case SEG_LINEAR:
@@ -3583,6 +3677,46 @@ int dm_tree_node_add_cache_target(struct dm_tree_node *node,
 	return 1;
 }
 
+int dm_tree_node_add_writecache_target(struct dm_tree_node *node,
+				  uint64_t size,
+				  const char *origin_uuid,
+				  const char *cache_uuid,
+				  int pmem,
+				  uint32_t writecache_block_size,
+				  struct writecache_settings *settings)
+{
+	struct load_segment *seg;
+
+	if (!(seg = _add_segment(node, SEG_WRITECACHE, size)))
+		return_0;
+
+	seg->writecache_pmem = pmem;
+	seg->writecache_block_size = writecache_block_size;
+
+	if (!(seg->writecache_node = dm_tree_find_node_by_uuid(node->dtree, cache_uuid))) {
+		log_error("Missing writecache's cache uuid %s.", cache_uuid);
+		return 0;
+	}
+	if (!_link_tree_nodes(node, seg->writecache_node))
+		return_0;
+
+	if (!(seg->origin = dm_tree_find_node_by_uuid(node->dtree, origin_uuid))) {
+		log_error("Missing writecache's origin uuid %s.", origin_uuid);
+		return 0;
+	}
+	if (!_link_tree_nodes(node, seg->origin))
+		return_0;
+
+	memcpy(&seg->writecache_settings, settings, sizeof(struct writecache_settings));
+
+	if (settings->new_key && settings->new_val) {
+		seg->writecache_settings.new_key = dm_pool_strdup(node->dtree->mem, settings->new_key);
+		seg->writecache_settings.new_val = dm_pool_strdup(node->dtree->mem, settings->new_val);
+	}
+
+	return 1;
+}
+
 int dm_tree_node_add_replicator_target(struct dm_tree_node *node,
 				       uint64_t size,
 				       const char *rlog_uuid,
diff --git a/device_mapper/libdm-targets.c b/device_mapper/libdm-targets.c
index 5ab4701..607f429 100644
--- a/device_mapper/libdm-targets.c
+++ b/device_mapper/libdm-targets.c
@@ -346,6 +346,38 @@ bad:
 	return 0;
 }
 
+/*
+ * From linux/Documentation/device-mapper/writecache.txt
+ *
+ * Status:
+ * 1. error indicator - 0 if there was no error, otherwise error number
+ * 2. the number of blocks
+ * 3. the number of free blocks
+ * 4. the number of blocks under writeback
+ */
+
+int dm_get_status_writecache(struct dm_pool *mem, const char *params,
+			     struct dm_status_writecache **status)
+{
+	struct dm_status_writecache *s;
+
+	if (!(s = dm_pool_zalloc(mem, sizeof(struct dm_status_writecache))))
+		return_0;
+
+	if (sscanf(params, "%u %llu %llu %llu",
+		   &s->error,
+		   (unsigned long long *)&s->total_blocks,
+		   (unsigned long long *)&s->free_blocks,
+		   (unsigned long long *)&s->writeback_blocks) != 4) {
+		log_error("Failed to parse writecache params: %s.", params);
+		dm_pool_free(mem, s);
+		return 0;
+	}
+
+	*status = s;
+	return 1;
+}
+
 int parse_thin_pool_status(const char *params, struct dm_status_thin_pool *s)
 {
 	int pos;
diff --git a/lib/Makefile.in b/lib/Makefile.in
index 1b170ee..722e954 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -19,6 +19,7 @@ top_builddir = @top_builddir@
 SOURCES =\
 	activate/activate.c \
 	cache/lvmcache.c \
+	writecache/writecache.c \
 	cache_segtype/cache.c \
 	commands/toolcontext.c \
 	config/config.c \
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 1e195b6..b1f7391 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1173,6 +1173,26 @@ out:
 	return r;
 }
 
+int lv_writecache_message(const struct logical_volume *lv, const char *msg)
+{
+	int r = 0;
+	struct dev_manager *dm;
+
+	if (!lv_info(lv->vg->cmd, lv, 0, NULL, 0, 0)) {
+		log_error("Unable to send message to an inactive logical volume.");
+		return 0;
+	}
+
+	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, 1)))
+		return_0;
+
+	r = dev_manager_writecache_message(dm, lv, msg);
+
+	dev_manager_destroy(dm);
+
+	return r;
+}
+
 /*
  * Return dm_status_cache for cache volume, accept also cache pool
  *
diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index 9530c36..8f9c918 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -38,6 +38,7 @@ typedef enum {
 	SEG_STATUS_THIN,
 	SEG_STATUS_THIN_POOL,
 	SEG_STATUS_VDO_POOL,
+	SEG_STATUS_WRITECACHE,
 	SEG_STATUS_UNKNOWN
 } lv_seg_status_type_t;
 
@@ -51,6 +52,7 @@ struct lv_seg_status {
 		struct dm_status_snapshot *snapshot;
 		struct dm_status_thin *thin;
 		struct dm_status_thin_pool *thin_pool;
+		struct dm_status_writecache *writecache;
 		struct lv_status_vdo vdo_pool;
 	};
 };
@@ -184,6 +186,7 @@ int lv_raid_dev_health(const struct logical_volume *lv, char **dev_health);
 int lv_raid_mismatch_count(const struct logical_volume *lv, uint64_t *cnt);
 int lv_raid_sync_action(const struct logical_volume *lv, char **sync_action);
 int lv_raid_message(const struct logical_volume *lv, const char *msg);
+int lv_writecache_message(const struct logical_volume *lv, const char *msg);
 int lv_cache_status(const struct logical_volume *cache_lv,
 		    struct lv_status_cache **status);
 int lv_thin_pool_percent(const struct logical_volume *lv, int metadata,
@@ -255,6 +258,7 @@ int device_is_usable(struct device *dev, struct dev_usable_check_params check);
 void fs_unlock(void);
 
 #define TARGET_NAME_CACHE "cache"
+#define TARGET_NAME_WRITECACHE "writecache"
 #define TARGET_NAME_ERROR "error"
 #define TARGET_NAME_ERROR_OLD "erro"	/* Truncated in older kernels */
 #define TARGET_NAME_LINEAR "linear"
@@ -271,6 +275,7 @@ void fs_unlock(void);
 
 #define MODULE_NAME_CLUSTERED_MIRROR "clog"
 #define MODULE_NAME_CACHE TARGET_NAME_CACHE
+#define MODULE_NAME_WRITECACHE TARGET_NAME_WRITECACHE
 #define MODULE_NAME_ERROR TARGET_NAME_ERROR
 #define MODULE_NAME_LOG_CLUSTERED "log-clustered"
 #define MODULE_NAME_LOG_USERSPACE "log-userspace"
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 1249581..49f425b 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -213,6 +213,10 @@ static int _get_segment_status_from_target_params(const char *target_name,
 		if (!parse_vdo_pool_status(seg_status->mem, seg->lv, params, &seg_status->vdo_pool))
 			return_0;
 		seg_status->type = SEG_STATUS_VDO_POOL;
+	} else if (segtype_is_writecache(segtype)) {
+		if (!dm_get_status_writecache(seg_status->mem, params, &(seg_status->writecache)))
+			return_0;
+		seg_status->type = SEG_STATUS_WRITECACHE;
 	} else
 		/*
 		 * TODO: Add support for other segment types too!
@@ -1557,6 +1561,40 @@ out:
 	return r;
 }
 
+int dev_manager_writecache_message(struct dev_manager *dm,
+				   const struct logical_volume *lv,
+				   const char *msg)
+{
+	int r = 0;
+	const char *dlid;
+	struct dm_task *dmt;
+	const char *layer = lv_layer(lv);
+
+	if (!lv_is_writecache(lv)) {
+		log_error(INTERNAL_ERROR "%s is not a writecache logical volume.",
+			  display_lvname(lv));
+		return 0;
+	}
+
+	if (!(dlid = build_dm_uuid(dm->mem, lv, layer)))
+		return_0;
+
+	if (!(dmt = _setup_task_run(DM_DEVICE_TARGET_MSG, NULL, NULL, dlid, 0, 0, 0, 0, 1, 0)))
+		return_0;
+
+	if (!dm_task_set_message(dmt, msg))
+		goto_out;
+
+	if (!dm_task_run(dmt))
+		goto_out;
+
+	r = 1;
+out:
+	dm_task_destroy(dmt);
+
+	return r;
+}
+
 int dev_manager_cache_status(struct dev_manager *dm,
 			     const struct logical_volume *lv,
 			     struct lv_status_cache **status)
@@ -2601,6 +2639,10 @@ static int _add_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		if (seg->metadata_lv &&
 		    !_add_lv_to_dtree(dm, dtree, seg->metadata_lv, 0))
 			return_0;
+		if (seg->writecache && seg_is_writecache(seg)) {
+			if (!_add_lv_to_dtree(dm, dtree, seg->writecache, dm->activation ? origin_only : 1))
+				return_0;
+		}
 		if (seg->pool_lv &&
 		    (lv_is_cache_pool(seg->pool_lv) || lv_is_cache_single(seg->pool_lv) || dm->track_external_lv_deps) &&
 		    /* When activating and not origin_only detect linear 'overlay' over pool */
@@ -3053,6 +3095,11 @@ static int _add_segment_to_dtree(struct dev_manager *dm,
 				  lv_layer(seg->pool_lv)))
 		return_0;
 
+	if (seg->writecache && !laopts->origin_only &&
+	    !_add_new_lv_to_dtree(dm, dtree, seg->writecache, laopts,
+				  lv_layer(seg->writecache)))
+		return_0;
+
 	/* Add any LVs used by this segment */
 	for (s = 0; s < seg->area_count; ++s) {
 		if ((seg_type(seg, s) == AREA_LV) &&
diff --git a/lib/activate/dev_manager.h b/lib/activate/dev_manager.h
index b669bd2..ca8c0d3 100644
--- a/lib/activate/dev_manager.h
+++ b/lib/activate/dev_manager.h
@@ -63,6 +63,9 @@ int dev_manager_raid_status(struct dev_manager *dm,
 int dev_manager_raid_message(struct dev_manager *dm,
 			     const struct logical_volume *lv,
 			     const char *msg);
+int dev_manager_writecache_message(struct dev_manager *dm,
+                                   const struct logical_volume *lv,
+                                   const char *msg);
 int dev_manager_cache_status(struct dev_manager *dm,
 			     const struct logical_volume *lv,
 			     struct lv_status_cache **status);
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 9f00593..58d46ac 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1367,6 +1367,11 @@ static int _init_segtypes(struct cmd_context *cmd)
 		return_0;
 #endif
 
+#ifdef WRITECACHE_INTERNAL
+	if (!init_writecache_segtypes(cmd, &seglib))
+		return 0;
+#endif
+
 #ifdef HAVE_LIBDL
 	/* Load any formats in shared libs unless static */
 	if (!is_static() &&
diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index f2d193b..1f74fdc 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -35,6 +35,48 @@
 
 #include "lib/device/device-types.h"
 
+/*
+ * dev is pmem if /sys/dev/block/<major>:<minor>/queue/dax is 1
+ */
+
+int dev_is_pmem(struct device *dev)
+{
+	FILE *fp;
+	char path[PATH_MAX];
+	char buffer[64];
+	int is_pmem = 0;
+
+	if (dm_snprintf(path, sizeof(path), "%sdev/block/%d:%d/queue/dax",
+			dm_sysfs_dir(),
+			(int) MAJOR(dev->dev),
+			(int) MINOR(dev->dev)) < 0) {
+		log_warn("Sysfs path for %s dax is too long.", dev_name(dev));
+		return 0;
+	}
+
+	if (!(fp = fopen(path, "r")))
+		return 0;
+
+	if (!fgets(buffer, sizeof(buffer), fp)) {
+		log_warn("Failed to read %s.", path);
+		fclose(fp);
+		return 0;
+	} else if (sscanf(buffer, "%d", &is_pmem) != 1) {
+		log_warn("Failed to parse %s '%s'.", path, buffer);
+		fclose(fp);
+		return 0;
+	}
+
+	fclose(fp);
+
+	if (is_pmem) {
+		log_debug("%s is pmem", dev_name(dev));
+		return 1;
+	}
+
+	return 0;
+}
+
 struct dev_types *create_dev_types(const char *proc_dir,
 				   const struct dm_config_node *cn)
 {
diff --git a/lib/device/dev-type.h b/lib/device/dev-type.h
index 0e418d6..e8f0fcb 100644
--- a/lib/device/dev-type.h
+++ b/lib/device/dev-type.h
@@ -92,4 +92,6 @@ unsigned long dev_discard_granularity(struct dev_types *dt, struct device *dev);
 
 int dev_is_rotational(struct dev_types *dt, struct device *dev);
 
+int dev_is_pmem(struct device *dev);
+
 #endif
diff --git a/lib/format_text/flags.c b/lib/format_text/flags.c
index d7c4318..cf5be00 100644
--- a/lib/format_text/flags.c
+++ b/lib/format_text/flags.c
@@ -102,6 +102,7 @@ static const struct flag _lv_flags[] = {
 	{LV_VDO, NULL, 0},
 	{LV_VDO_POOL, NULL, 0},
 	{LV_VDO_POOL_DATA, NULL, 0},
+	{WRITECACHE, NULL, 0},
 	{LV_PENDING_DELETE, NULL, 0}, /* FIXME Display like COMPATIBLE_FLAG */
 	{LV_REMOVED, NULL, 0},
 	{0, NULL, 0}
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index cb064d8..0e54323 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -578,6 +578,8 @@ struct logical_volume *lv_origin_lv(const struct logical_volume *lv)
 		origin = first_seg(lv)->origin;
 	else if (lv_is_thin_volume(lv) && first_seg(lv)->external_lv)
 		origin = first_seg(lv)->external_lv;
+	else if (lv_is_writecache(lv) && first_seg(lv)->origin)
+		origin = first_seg(lv)->origin;
 
 	return origin;
 }
@@ -1192,7 +1194,7 @@ char *lv_attr_dup_with_info_and_seg_status(struct dm_pool *mem, const struct lv_
 		 lv_is_pool_metadata_spare(lv) ||
 		 lv_is_raid_metadata(lv))
 		repstr[0] = 'e';
-	else if (lv_is_cache_type(lv))
+	else if (lv_is_cache_type(lv) || lv_is_writecache(lv))
 		repstr[0] = 'C';
 	else if (lv_is_raid(lv))
 		repstr[0] = (lv_is_not_synced(lv)) ? 'R' : 'r';
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 8e64dac..d5603c7 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1572,6 +1572,11 @@ int lv_reduce(struct logical_volume *lv, uint32_t extents)
 {
 	struct lv_segment *seg = first_seg(lv);
 
+	if (lv_is_writecache(lv)) {
+		log_error("Remove not yet allowed on LVs with writecache attached.");
+		return 0;
+	}
+
 	/* Ensure stripe boundary extents on RAID LVs */
 	if (lv_is_raid(lv) && extents != lv->le_count)
 		extents =_round_to_stripe_boundary(lv->vg, extents,
@@ -5562,6 +5567,11 @@ int lv_resize(struct logical_volume *lv,
 	int ret = 0;
 	int status;
 
+	if (lv_is_writecache(lv)) {
+		log_error("Resize not yet allowed on LVs with writecache attached.");
+		return 0;
+	}
+
 	if (!_lvresize_check(lv, lp))
 		return_0;
 
diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index d95da1f..bdd9c67 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -710,7 +710,7 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 		}
 		if (seg->log_lv == lv)
 			seg_found++;
-		if (seg->metadata_lv == lv || seg->pool_lv == lv)
+		if (seg->metadata_lv == lv || seg->pool_lv == lv || seg->writecache == lv)
 			seg_found++;
 		if (seg_is_thin_volume(seg) && (seg->origin == lv || seg->external_lv == lv))
 			seg_found++;
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 30ab356..7f673cd 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -95,6 +95,7 @@
 #define MERGING			UINT64_C(0x0000000010000000)	/* LV SEG */
 
 #define UNLABELLED_PV		UINT64_C(0x0000000080000000)	/* PV -this PV had no label written yet */
+#define WRITECACHE		UINT64_C(0x0000000080000000)	/* LV - shared with UNLABELLED_PV */
 
 #define RAID			UINT64_C(0x0000000100000000)	/* LV - Internal use only */
 #define RAID_META		UINT64_C(0x0000000200000000)	/* LV - Internal use only */
@@ -258,6 +259,7 @@
 #define lv_is_pool_metadata(lv)		(((lv)->status & (CACHE_POOL_METADATA | THIN_POOL_METADATA)) ? 1 : 0)
 #define lv_is_pool_metadata_spare(lv)	(((lv)->status & POOL_METADATA_SPARE) ? 1 : 0)
 #define lv_is_lockd_sanlock_lv(lv)	(((lv)->status & LOCKD_SANLOCK_LV) ? 1 : 0)
+#define lv_is_writecache(lv)   (((lv)->status & WRITECACHE) ? 1 : 0)
 
 #define lv_is_vdo(lv)		(((lv)->status & LV_VDO) ? 1 : 0)
 #define lv_is_vdo_pool(lv)	(((lv)->status & LV_VDO_POOL) ? 1 : 0)
@@ -509,6 +511,10 @@ struct lv_segment {
 	struct dm_config_node *policy_settings;	/* For cache_pool */
 	unsigned cleaner_policy;		/* For cache */
 
+	struct logical_volume *writecache;	/* For writecache */
+	uint32_t writecache_block_size;		/* For writecache */
+	struct writecache_settings writecache_settings; /* For writecache */
+
 	struct dm_vdo_target_params vdo_params;	/* For VDO-pool */
 	uint32_t vdo_pool_header_size;		/* For VDO-pool */
 	uint32_t vdo_pool_virtual_extents;	/* For VDO-pool */
@@ -1360,4 +1366,6 @@ int is_system_id_allowed(struct cmd_context *cmd, const char *system_id);
 
 int vg_strip_outdated_historical_lvs(struct volume_group *vg);
 
+int lv_on_pmem(struct logical_volume *lv);
+
 #endif
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 57e1842..6c71c74 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -5545,3 +5545,38 @@ int vg_strip_outdated_historical_lvs(struct volume_group *vg) {
 
 	return 1;
 }
+
+int lv_on_pmem(struct logical_volume *lv)
+{
+	struct lv_segment *seg;
+	struct physical_volume *pv;
+	uint32_t s;
+	int pmem_devs = 0, other_devs = 0;
+
+	dm_list_iterate_items(seg, &lv->segments) {
+		for (s = 0; s < seg->area_count; s++) {
+			pv = seg_pv(seg, s);
+
+			if (dev_is_pmem(pv->dev)) {
+				log_debug("LV %s dev %s is pmem.", lv->name, dev_name(pv->dev));
+				pmem_devs++;
+			} else {
+				log_debug("LV %s dev %s not pmem.", lv->name, dev_name(pv->dev));
+				other_devs++;
+			}
+		}
+	}
+
+	if (pmem_devs && other_devs) {
+		log_error("Invalid mix of cache device types in %s.", display_lvname(lv));
+		return -1;
+	}
+
+	if (pmem_devs) {
+		log_debug("LV %s on pmem", lv->name);
+		return 1;
+	}
+
+	return 0;
+}
+
diff --git a/lib/metadata/segtype.h b/lib/metadata/segtype.h
index 6fdf075..22a511e 100644
--- a/lib/metadata/segtype.h
+++ b/lib/metadata/segtype.h
@@ -66,6 +66,7 @@ struct dev_manager;
 #define SEG_RAID6_RS_6		(1ULL << 34)
 #define SEG_RAID6_N_6		(1ULL << 35)
 #define SEG_RAID6		SEG_RAID6_ZR
+#define SEG_WRITECACHE		(1ULL << 36)
 
 #define SEG_STRIPED_TARGET	(1ULL << 39)
 #define SEG_LINEAR_TARGET	(1ULL << 40)
@@ -82,6 +83,7 @@ struct dev_manager;
 #define SEG_TYPE_NAME_THIN_POOL		"thin-pool"
 #define SEG_TYPE_NAME_CACHE		"cache"
 #define SEG_TYPE_NAME_CACHE_POOL	"cache-pool"
+#define SEG_TYPE_NAME_WRITECACHE	"writecache"
 #define SEG_TYPE_NAME_ERROR		"error"
 #define SEG_TYPE_NAME_FREE		"free"
 #define SEG_TYPE_NAME_ZERO		"zero"
@@ -114,6 +116,7 @@ struct dev_manager;
 #define segtype_is_striped_target(segtype)	((segtype)->flags & SEG_STRIPED_TARGET ? 1 : 0)
 #define segtype_is_cache(segtype)	((segtype)->flags & SEG_CACHE ? 1 : 0)
 #define segtype_is_cache_pool(segtype)	((segtype)->flags & SEG_CACHE_POOL ? 1 : 0)
+#define segtype_is_writecache(segtype)	((segtype)->flags & SEG_WRITECACHE ? 1 : 0)
 #define segtype_is_mirrored(segtype)	((segtype)->flags & SEG_AREAS_MIRRORED ? 1 : 0)
 #define segtype_is_mirror(segtype)	((segtype)->flags & SEG_MIRROR ? 1 : 0)
 #define segtype_is_pool(segtype)	((segtype)->flags & (SEG_CACHE_POOL | SEG_THIN_POOL)  ? 1 : 0)
@@ -175,6 +178,7 @@ struct dev_manager;
 #define seg_is_striped_target(seg)	segtype_is_striped_target((seg)->segtype)
 #define seg_is_cache(seg)	segtype_is_cache((seg)->segtype)
 #define seg_is_cache_pool(seg)	segtype_is_cache_pool((seg)->segtype)
+#define seg_is_writecache(seg)	segtype_is_writecache((seg)->segtype)
 #define seg_is_used_cache_pool(seg) (seg_is_cache_pool(seg) && (!dm_list_empty(&(seg->lv)->segs_using_this_lv)))
 #define seg_is_linear(seg)	(seg_is_striped(seg) && ((seg)->area_count == 1))
 #define seg_is_mirror(seg)	segtype_is_mirror((seg)->segtype)
@@ -341,6 +345,8 @@ int init_cache_segtypes(struct cmd_context *cmd, struct segtype_library *seglib)
 int init_vdo_segtypes(struct cmd_context *cmd, struct segtype_library *seglib);
 #endif
 
+int init_writecache_segtypes(struct cmd_context *cmd, struct segtype_library *seglib);
+
 #define CACHE_FEATURE_POLICY_MQ			(1U << 0)
 #define CACHE_FEATURE_POLICY_SMQ		(1U << 1)
 #define CACHE_FEATURE_METADATA2			(1U << 2)
diff --git a/lib/writecache/writecache.c b/lib/writecache/writecache.c
new file mode 100644
index 0000000..e9d337b
--- /dev/null
+++ b/lib/writecache/writecache.c
@@ -0,0 +1,314 @@
+/*
+ * Copyright (C) 2013-2016 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+ */
+
+#include "base/memory/zalloc.h"
+#include "lib/misc/lib.h"
+#include "lib/commands/toolcontext.h"
+#include "lib/metadata/segtype.h"
+#include "lib/display/display.h"
+#include "lib/format_text/text_export.h"
+#include "lib/config/config.h"
+#include "lib/datastruct/str_list.h"
+#include "lib/misc/lvm-string.h"
+#include "lib/activate/activate.h"
+#include "lib/metadata/metadata.h"
+#include "lib/metadata/lv_alloc.h"
+#include "lib/config/defaults.h"
+
+static const char _writecache_module[] = "writecache";
+
+#define SEG_LOG_ERROR(t, p...) \
+        log_error(t " segment %s of logical volume %s.", ## p,	\
+                  dm_config_parent_name(sn), seg->lv->name), 0;
+
+static void _writecache_display(const struct lv_segment *seg)
+{
+	/* TODO: lvdisplay segments */
+}
+
+static int _writecache_text_import(struct lv_segment *seg,
+				   const struct dm_config_node *sn,
+				   struct dm_hash_table *pv_hash __attribute__((unused)))
+{
+	struct logical_volume *origin_lv = NULL;
+	struct logical_volume *fast_lv;
+	const char *origin_name = NULL;
+	const char *fast_name = NULL;
+
+	if (!dm_config_has_node(sn, "origin"))
+		return SEG_LOG_ERROR("origin not specified in");
+
+	if (!dm_config_get_str(sn, "origin", &origin_name))
+		return SEG_LOG_ERROR("origin must be a string in");
+
+	if (!(origin_lv = find_lv(seg->lv->vg, origin_name)))
+		return SEG_LOG_ERROR("Unknown LV specified for writecache origin %s in", origin_name);
+
+	if (!set_lv_segment_area_lv(seg, 0, origin_lv, 0, 0))
+		return_0;
+
+	if (!dm_config_has_node(sn, "writecache"))
+		return SEG_LOG_ERROR("writecache not specified in");
+
+	if (!dm_config_get_str(sn, "writecache", &fast_name))
+		return SEG_LOG_ERROR("writecache must be a string in");
+
+	if (!(fast_lv = find_lv(seg->lv->vg, fast_name)))
+		return SEG_LOG_ERROR("Unknown logical volume %s specified for writecache in",
+				     fast_name);
+
+	if (!dm_config_get_uint32(sn, "writecache_block_size", &seg->writecache_block_size))
+		return SEG_LOG_ERROR("writecache block_size must be set in");
+
+	seg->origin = origin_lv;
+	seg->writecache = fast_lv;
+	seg->lv->status |= WRITECACHE;
+
+	if (!add_seg_to_segs_using_this_lv(fast_lv, seg))
+		return_0;
+
+	memset(&seg->writecache_settings, 0, sizeof(struct writecache_settings));
+
+	if (dm_config_has_node(sn, "high_watermark")) {
+		if (!dm_config_get_uint64(sn, "high_watermark", &seg->writecache_settings.high_watermark))
+			return SEG_LOG_ERROR("Unknown writecache_setting in");
+		seg->writecache_settings.high_watermark_set = 1;
+	}
+
+	if (dm_config_has_node(sn, "low_watermark")) {
+		if (!dm_config_get_uint64(sn, "low_watermark", &seg->writecache_settings.low_watermark))
+			return SEG_LOG_ERROR("Unknown writecache_setting in");
+		seg->writecache_settings.low_watermark_set = 1;
+	}
+
+	if (dm_config_has_node(sn, "writeback_jobs")) {
+		if (!dm_config_get_uint64(sn, "writeback_jobs", &seg->writecache_settings.writeback_jobs))
+			return SEG_LOG_ERROR("Unknown writecache_setting in");
+		seg->writecache_settings.writeback_jobs_set = 1;
+	}
+
+	if (dm_config_has_node(sn, "autocommit_blocks")) {
+		if (!dm_config_get_uint64(sn, "autocommit_blocks", &seg->writecache_settings.autocommit_blocks))
+			return SEG_LOG_ERROR("Unknown writecache_setting in");
+		seg->writecache_settings.autocommit_blocks_set = 1;
+	}
+
+	if (dm_config_has_node(sn, "autocommit_time")) {
+		if (!dm_config_get_uint64(sn, "autocommit_time", &seg->writecache_settings.autocommit_time))
+			return SEG_LOG_ERROR("Unknown writecache_setting in");
+		seg->writecache_settings.autocommit_time_set = 1;
+	}
+
+	if (dm_config_has_node(sn, "fua")) {
+		if (!dm_config_get_uint32(sn, "fua", &seg->writecache_settings.fua))
+			return SEG_LOG_ERROR("Unknown writecache_setting in");
+		seg->writecache_settings.fua_set = 1;
+	}
+
+	if (dm_config_has_node(sn, "nofua")) {
+		if (!dm_config_get_uint32(sn, "nofua", &seg->writecache_settings.nofua))
+			return SEG_LOG_ERROR("Unknown writecache_setting in");
+		seg->writecache_settings.nofua_set = 1;
+	}
+
+	if (dm_config_has_node(sn, "writecache_setting_key")) {
+		const char *key;
+		const char *val;
+
+		if (!dm_config_get_str(sn, "writecache_setting_key", &key))
+			return SEG_LOG_ERROR("Unknown writecache_setting in");
+		if (!dm_config_get_str(sn, "writecache_setting_val", &val))
+			return SEG_LOG_ERROR("Unknown writecache_setting in");
+
+		seg->writecache_settings.new_key = dm_pool_strdup(seg->lv->vg->vgmem, key);
+		seg->writecache_settings.new_val = dm_pool_strdup(seg->lv->vg->vgmem, val);
+	}
+
+	return 1;
+}
+
+static int _writecache_text_import_area_count(const struct dm_config_node *sn,
+					      uint32_t *area_count)
+{
+	*area_count = 1;
+
+	return 1;
+}
+
+static int _writecache_text_export(const struct lv_segment *seg,
+				   struct formatter *f)
+{
+	outf(f, "writecache = \"%s\"", seg->writecache->name);
+	outf(f, "origin = \"%s\"", seg_lv(seg, 0)->name);
+	outf(f, "writecache_block_size = %u", seg->writecache_block_size);
+
+	if (seg->writecache_settings.high_watermark_set) {
+	        outf(f, "high_watermark = %llu",
+	                (unsigned long long)seg->writecache_settings.high_watermark);
+	}
+
+	if (seg->writecache_settings.low_watermark_set) {
+	        outf(f, "low_watermark = %llu",
+	                (unsigned long long)seg->writecache_settings.low_watermark);
+	}
+
+	if (seg->writecache_settings.writeback_jobs_set) {
+	        outf(f, "writeback_jobs = %llu",
+	                (unsigned long long)seg->writecache_settings.writeback_jobs);
+	}
+
+	if (seg->writecache_settings.autocommit_blocks_set) {
+	        outf(f, "autocommit_blocks = %llu",
+	                (unsigned long long)seg->writecache_settings.autocommit_blocks);
+	}
+
+	if (seg->writecache_settings.autocommit_time_set) {
+	        outf(f, "autocommit_time = %llu",
+	                (unsigned long long)seg->writecache_settings.autocommit_time);
+	}
+
+	if (seg->writecache_settings.fua_set) {
+	        outf(f, "fua = %u", seg->writecache_settings.fua);
+	}
+
+	if (seg->writecache_settings.nofua_set) {
+	        outf(f, "nofua = %u", seg->writecache_settings.nofua);
+	}
+
+	if (seg->writecache_settings.new_key && seg->writecache_settings.new_val) {
+	        outf(f, "writecache_setting_key = \"%s\"",
+	                seg->writecache_settings.new_key);
+
+	        outf(f, "writecache_setting_val = \"%s\"",
+	                seg->writecache_settings.new_val);
+	}
+
+	return 1;
+}
+
+static void _destroy(struct segment_type *segtype)
+{
+	free((void *) segtype);
+}
+
+#ifdef DEVMAPPER_SUPPORT
+
+static int _target_present(struct cmd_context *cmd,
+			   const struct lv_segment *seg __attribute__((unused)),
+			   unsigned *attributes __attribute__((unused)))
+{
+	static int _writecache_checked = 0;
+	static int _writecache_present = 0;
+
+	if (!activation())
+		return 0;
+
+	if (!_writecache_checked) {
+		_writecache_checked = 1;
+		_writecache_present =  target_present(cmd, TARGET_NAME_WRITECACHE, 0);
+	}
+
+	return _writecache_present;
+}
+
+static int _modules_needed(struct dm_pool *mem,
+			   const struct lv_segment *seg __attribute__((unused)),
+			   struct dm_list *modules)
+{
+	if (!str_list_add(mem, modules, MODULE_NAME_WRITECACHE)) {
+		log_error("String list allocation failed for writecache module.");
+		return 0;
+	}
+
+	return 1;
+}
+#endif /* DEVMAPPER_SUPPORT */
+
+#ifdef DEVMAPPER_SUPPORT
+static int _writecache_add_target_line(struct dev_manager *dm,
+				 struct dm_pool *mem,
+				 struct cmd_context *cmd __attribute__((unused)),
+				 void **target_state __attribute__((unused)),
+				 struct lv_segment *seg,
+				 const struct lv_activate_opts *laopts __attribute__((unused)),
+				 struct dm_tree_node *node, uint64_t len,
+				 uint32_t *pvmove_mirror_count __attribute__((unused)))
+{
+	char *origin_uuid;
+	char *fast_uuid;
+	int pmem;
+
+	if (!seg_is_writecache(seg)) {
+		log_error(INTERNAL_ERROR "Passed segment is not writecache.");
+		return 0;
+	}
+
+	if (!seg->writecache) {
+		log_error(INTERNAL_ERROR "Passed segment has no writecache.");
+		return 0;
+	}
+
+	if ((pmem = lv_on_pmem(seg->writecache)) < 0)
+		return_0;
+
+	if (!(origin_uuid = build_dm_uuid(mem, seg_lv(seg, 0), NULL)))
+		return_0;
+
+	if (!(fast_uuid = build_dm_uuid(mem, seg->writecache, NULL)))
+		return_0;
+
+	if (!dm_tree_node_add_writecache_target(node, len,
+						origin_uuid, fast_uuid,
+						pmem,
+						seg->writecache_block_size,
+						&seg->writecache_settings))
+		return_0;
+
+	return 1;
+}
+#endif /* DEVMAPPER_SUPPORT */
+
+static struct segtype_handler _writecache_ops = {
+	.display = _writecache_display,
+	.text_import = _writecache_text_import,
+	.text_import_area_count = _writecache_text_import_area_count,
+	.text_export = _writecache_text_export,
+#ifdef DEVMAPPER_SUPPORT
+	.add_target_line = _writecache_add_target_line,
+	.target_present = _target_present,
+	.modules_needed = _modules_needed,
+#endif
+	.destroy = _destroy,
+};
+
+int init_writecache_segtypes(struct cmd_context *cmd,
+			struct segtype_library *seglib)
+{
+	struct segment_type *segtype = zalloc(sizeof(*segtype));
+
+	if (!segtype) {
+		log_error("Failed to allocate memory for writecache segtype");
+		return 0;
+	}
+
+	segtype->name = SEG_TYPE_NAME_WRITECACHE;
+	segtype->flags = SEG_WRITECACHE;
+	segtype->ops = &_writecache_ops;
+
+	if (!lvm_register_segtype(seglib, segtype))
+		return_0;
+	log_very_verbose("Initialised segtype: %s", segtype->name);
+
+	return 1;
+}
diff --git a/test/shell/writecache.sh b/test/shell/writecache.sh
new file mode 100644
index 0000000..19cc93b
--- /dev/null
+++ b/test/shell/writecache.sh
@@ -0,0 +1,129 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2017 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+# Test writecache usage
+
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+mount_dir="mnt"
+mkdir -p $mount_dir
+
+# generate random data
+dmesg > pattern1
+ps aux >> pattern1
+
+aux prepare_devs 2 64
+
+vgcreate $SHARED $vg "$dev1"
+
+vgextend $vg "$dev2"
+
+lvcreate -n $lv1 -l 8 -an $vg "$dev1"
+
+lvcreate -n $lv2 -l 4 -an $vg "$dev2"
+
+# test1: create fs on LV before writecache is attached
+
+lvchange -ay $vg/$lv1
+
+mkfs.xfs -f -s size=4096 "$DM_DEV_DIR/$vg/$lv1"
+
+mount "$DM_DEV_DIR/$vg/$lv1" $mount_dir
+
+cp pattern1 $mount_dir/pattern1
+
+umount $mount_dir
+lvchange -an $vg/$lv1
+
+lvconvert --type writecache --cachepool $lv2 $vg/$lv1
+
+check lv_field $vg/$lv1 segtype writecache
+
+lvs -a $vg/$lv2 --noheadings -o segtype >out
+grep linear out
+
+lvchange -ay $vg/$lv1
+
+mount "$DM_DEV_DIR/$vg/$lv1" $mount_dir
+
+diff pattern1 $mount_dir/pattern1
+
+cp pattern1 $mount_dir/pattern1b
+
+ls -l $mount_dir
+
+umount $mount_dir
+
+lvchange -an $vg/$lv1
+
+lvconvert --splitcache $vg/$lv1
+
+check lv_field $vg/$lv1 segtype linear
+check lv_field $vg/$lv2 segtype linear
+
+lvchange -ay $vg/$lv1
+lvchange -ay $vg/$lv2
+
+mount "$DM_DEV_DIR/$vg/$lv1" $mount_dir
+
+ls -l $mount_dir
+
+diff pattern1 $mount_dir/pattern1
+diff pattern1 $mount_dir/pattern1b
+
+umount $mount_dir
+lvchange -an $vg/$lv1
+lvchange -an $vg/$lv2
+
+# test2: create fs on LV after writecache is attached
+
+lvconvert --type writecache --cachepool $lv2 $vg/$lv1
+
+check lv_field $vg/$lv1 segtype writecache
+
+lvs -a $vg/$lv2 --noheadings -o segtype >out
+grep linear out
+
+lvchange -ay $vg/$lv1
+
+mkfs.xfs -f -s size=4096 "$DM_DEV_DIR/$vg/$lv1"
+
+mount "$DM_DEV_DIR/$vg/$lv1" $mount_dir
+
+cp pattern1 $mount_dir/pattern1
+ls -l $mount_dir
+
+umount $mount_dir
+lvchange -an $vg/$lv1
+
+lvconvert --splitcache $vg/$lv1
+
+check lv_field $vg/$lv1 segtype linear
+check lv_field $vg/$lv2 segtype linear
+
+lvchange -ay $vg/$lv1
+lvchange -ay $vg/$lv2
+
+mount "$DM_DEV_DIR/$vg/$lv1" $mount_dir
+
+ls -l $mount_dir
+
+diff pattern1 $mount_dir/pattern1
+
+umount $mount_dir
+lvchange -an $vg/$lv1
+lvchange -an $vg/$lv2
+
+vgremove -ff $vg
+
diff --git a/tools/args.h b/tools/args.h
index adca84b..cc65be5 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -816,6 +816,9 @@ arg(withversions_ARG, '\0', "withversions", 0, 0, 0,
     "each configuration node. If the setting is deprecated, also display\n"
     "the version since which it is deprecated.\n")
 
+arg(writecacheblocksize_ARG, '\0', "writecacheblocksize", sizekb_VAL, 0, 0,
+    "The block size to use for cache blocks in writecache.\n")
+
 arg(writebehind_ARG, '\0', "writebehind", number_VAL, 0, 0,
     "The maximum number of outstanding writes that are allowed to\n"
     "devices in a RAID1 LV that is marked write-mostly.\n"
diff --git a/tools/command-lines.in b/tools/command-lines.in
index 840d771..a8e7272 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -454,7 +454,7 @@ RULE: --poolmetadata not --readahead --stripesize --stripes_long
 lvconvert --type cache --cachepool LV LV_linear_striped_raid_thinpool
 OO: --cache, OO_LVCONVERT_CACHE, OO_LVCONVERT_POOL, OO_LVCONVERT
 ID: lvconvert_to_cache_vol
-DESC: Convert LV to type cache.
+DESC: Attach a cache to an LV, converts the LV to type cache.
 RULE: all and lv_is_visible
 RULE: --poolmetadata not --readahead --stripesize --stripes_long
 
@@ -462,13 +462,21 @@ RULE: --poolmetadata not --readahead --stripesize --stripes_long
 lvconvert --cache --cachepool LV LV_linear_striped_raid_thinpool
 OO: --type cache, OO_LVCONVERT_CACHE, OO_LVCONVERT_POOL, OO_LVCONVERT
 ID: lvconvert_to_cache_vol
-DESC: Convert LV to type cache (infers --type cache).
+DESC: Attach a cache to an LV (infers --type cache).
 RULE: all and lv_is_visible
 RULE: --poolmetadata not --readahead --stripesize --stripes_long
 FLAGS: SECONDARY_SYNTAX
 
 ---
 
+lvconvert --type writecache --cachepool LV LV_linear_striped_raid
+OO: OO_LVCONVERT, --cachesettings String, --writecacheblocksize SizeKB
+ID: lvconvert_to_writecache_vol
+DESC: Attach a writecache to an LV, converts the LV to type writecache.
+RULE: all and lv_is_visible
+
+---
+
 lvconvert --type thin-pool LV_linear_striped_raid_cache
 OO: --stripes_long Number, --stripesize SizeKB,
 --discards Discards, OO_LVCONVERT_POOL, OO_LVCONVERT
@@ -573,17 +581,17 @@ FLAGS: SECONDARY_SYNTAX
 
 ---
 
-lvconvert --splitcache LV_cachepool_cache_thinpool
+lvconvert --splitcache LV_cachepool_cache_thinpool_writecache
 OO: OO_LVCONVERT
-ID: lvconvert_split_and_keep_cachepool
-DESC: Separate and keep the cache pool from a cache LV.
+ID: lvconvert_split_and_keep_cache
+DESC: Detach a cache from an LV.
 
 ---
 
-lvconvert --uncache LV_cache_thinpool
+lvconvert --uncache LV_cache_thinpool_writecache
 OO: OO_LVCONVERT
-ID: lvconvert_split_and_remove_cachepool
-DESC: Separate and delete the cache pool from a cache LV.
+ID: lvconvert_split_and_remove_cache
+DESC: Detach and delete a cache from an LV.
 FLAGS: SECONDARY_SYNTAX
 
 ---
diff --git a/tools/lv_types.h b/tools/lv_types.h
index 494776b..778cd54 100644
--- a/tools/lv_types.h
+++ b/tools/lv_types.h
@@ -33,5 +33,6 @@ lvt(raid6_LVT, "raid6", NULL)
 lvt(raid10_LVT, "raid10", NULL)
 lvt(error_LVT, "error", NULL)
 lvt(zero_LVT, "zero", NULL)
+lvt(writecache_LVT, "writecache", NULL)
 lvt(LVT_COUNT, "", NULL)
 
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 7382ce0..a207bd9 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -16,6 +16,7 @@
 
 #include "lib/lvmpolld/polldaemon.h"
 #include "lib/metadata/lv_alloc.h"
+#include "lib/metadata/metadata.h"
 #include "lvconvert_poll.h"
 
 #define MAX_PDATA_ARGS	10	/* Max number of accepted args for d-m-p-d tools */
@@ -1840,13 +1841,13 @@ static int _lvconvert_splitsnapshot(struct cmd_context *cmd, struct logical_volu
 	return 1;
 }
 
-static int _lvconvert_split_and_keep_cachepool(struct cmd_context *cmd,
+static int _lvconvert_split_and_keep_cache(struct cmd_context *cmd,
 				   struct logical_volume *lv,
-				   struct logical_volume *cachepool_lv)
+				   struct logical_volume *lv_fast)
 {
 	struct lv_segment *cache_seg = first_seg(lv);
 
-	log_debug("Detaching cache %s from LV %s.", display_lvname(cachepool_lv), display_lvname(lv));
+	log_debug("Detaching cache %s from LV %s.", display_lvname(lv_fast), display_lvname(lv));
 
 	if (!archive(lv->vg))
 		return_0;
@@ -1865,12 +1866,12 @@ static int _lvconvert_split_and_keep_cachepool(struct cmd_context *cmd,
 	backup(lv->vg);
 
 	log_print_unless_silent("Logical volume %s is not cached and cache pool %s is unused.",
-				display_lvname(lv), display_lvname(cachepool_lv));
+				display_lvname(lv), display_lvname(lv_fast));
 
 	return 1;
 }
 
-static int _lvconvert_split_and_remove_cachepool(struct cmd_context *cmd,
+static int _lvconvert_split_and_remove_cache(struct cmd_context *cmd,
 				   struct logical_volume *lv,
 				   struct logical_volume *cachepool_lv)
 {
@@ -4504,63 +4505,83 @@ int lvconvert_merge_thin_cmd(struct cmd_context *cmd, int argc, char **argv)
 			       NULL, NULL, &_lvconvert_merge_thin_single);
 }
 
-static int _lvconvert_split_cachepool_single(struct cmd_context *cmd,
+static int _lvconvert_detach_writecache(struct cmd_context *cmd,
+					struct logical_volume *lv,
+					struct logical_volume *lv_fast);
+
+static int _lvconvert_split_cache_single(struct cmd_context *cmd,
 					 struct logical_volume *lv,
 					 struct processing_handle *handle)
 {
-	struct logical_volume *cache_lv = NULL;
-	struct logical_volume *cachepool_lv = NULL;
+	struct logical_volume *lv_main = NULL;
+	struct logical_volume *lv_fast = NULL;
 	struct lv_segment *seg;
 	int ret;
 
-	if (lv_is_cache(lv)) {
-		cache_lv = lv;
-		cachepool_lv = first_seg(cache_lv)->pool_lv;
+	if (lv_is_writecache(lv)) {
+		lv_main = lv;
+		lv_fast = first_seg(lv_main)->writecache;
+
+	} else if (lv_is_cache(lv)) {
+		lv_main = lv;
+		lv_fast = first_seg(lv_main)->pool_lv;
 
 	} else if (lv_is_cache_pool(lv)) {
-		cachepool_lv = lv;
+		lv_fast = lv;
 
-		if ((dm_list_size(&cachepool_lv->segs_using_this_lv) == 1) &&
-		    (seg = get_only_segment_using_this_lv(cachepool_lv)) &&
+		if ((dm_list_size(&lv_fast->segs_using_this_lv) == 1) &&
+		    (seg = get_only_segment_using_this_lv(lv_fast)) &&
 		    seg_is_cache(seg))
-			cache_lv = seg->lv;
+			lv_main = seg->lv;
 
 	} else if (lv_is_thin_pool(lv)) {
-		cache_lv = seg_lv(first_seg(lv), 0); /* cached _tdata */
-		cachepool_lv = first_seg(cache_lv)->pool_lv;
+		lv_main = seg_lv(first_seg(lv), 0); /* cached _tdata */
+		lv_fast = first_seg(lv_main)->pool_lv;
 	}
 
-	if (!cache_lv) {
-		log_error("Cannot find cache LV from %s.", display_lvname(lv));
+	if (!lv_main) {
+		log_error("Cannot find LV with cache from %s.", display_lvname(lv));
 		return ECMD_FAILED;
 	}
 
-	if (!cachepool_lv) {
-		log_error("Cannot find cache pool LV from %s.", display_lvname(lv));
+	if (!lv_fast) {
+		log_error("Cannot find cache %s.", display_lvname(lv));
 		return ECMD_FAILED;
 	}
 
-	if ((cmd->command->command_enum == lvconvert_split_and_remove_cachepool_CMD) &&
-	    lv_is_cache_single(cachepool_lv)) {
-		log_error("Detach cache from %s with --splitcache.", display_lvname(lv));
-		log_error("The cache %s may then be removed with lvremove.", display_lvname(cachepool_lv));
-		return 0;
-	}
-
 	/* If LV is inactive here, ensure it's not active elsewhere. */
-	if (!lockd_lv(cmd, cache_lv, "ex", 0))
+	if (!lockd_lv(cmd, lv_main, "ex", 0))
 		return_0;
 
-	switch (cmd->command->command_enum) {
-	case lvconvert_split_and_keep_cachepool_CMD:
-		ret = _lvconvert_split_and_keep_cachepool(cmd, cache_lv, cachepool_lv);
-		break;
+	if (lv_is_writecache(lv_main)) {
+		if (cmd->command->command_enum == lvconvert_split_and_remove_cache_CMD) {
+			log_error("Detach cache from %s with --splitcache.", display_lvname(lv));
+			log_error("The writecache %s may then be removed with lvremove.", display_lvname(lv_fast));
+			return 0;
+		}
 
-	case lvconvert_split_and_remove_cachepool_CMD:
-		ret = _lvconvert_split_and_remove_cachepool(cmd, cache_lv, cachepool_lv);
-		break;
-	default:
-		log_error(INTERNAL_ERROR "Unknown cache pool split.");
+		ret = _lvconvert_detach_writecache(cmd, lv_main, lv_fast);
+
+	} else if (lv_is_cache(lv_main)) {
+		if ((cmd->command->command_enum == lvconvert_split_and_remove_cache_CMD) &&
+		    lv_is_cache_single(lv_fast)) {
+			log_error("Detach cache from %s with --splitcache.", display_lvname(lv));
+			log_error("The cache %s may then be removed with lvremove.", display_lvname(lv_fast));
+			return 0;
+		}
+
+		if (cmd->command->command_enum == lvconvert_split_and_remove_cache_CMD)
+			ret = _lvconvert_split_and_remove_cache(cmd, lv_main, lv_fast);
+
+		else if (cmd->command->command_enum == lvconvert_split_and_keep_cache_CMD)
+			ret = _lvconvert_split_and_keep_cache(cmd, lv_main, lv_fast);
+
+		else  {
+			log_error(INTERNAL_ERROR "Unknown cache split command.");
+			ret = 0;
+		}
+	} else {
+		log_error(INTERNAL_ERROR "Unknown cache split command.");
 		ret = 0;
 	}
 
@@ -4570,15 +4591,15 @@ static int _lvconvert_split_cachepool_single(struct cmd_context *cmd,
 	return ECMD_PROCESSED;
 }
 
-int lvconvert_split_cachepool_cmd(struct cmd_context *cmd, int argc, char **argv)
+int lvconvert_split_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 {
-	if (cmd->command->command_enum == lvconvert_split_and_remove_cachepool_CMD) {
+	if (cmd->command->command_enum == lvconvert_split_and_remove_cache_CMD) {
 		cmd->handles_missing_pvs = 1;
 		cmd->partial_activation = 1;
 	}
 
 	return process_each_lv(cmd, 1, cmd->position_argv, NULL, NULL, READ_FOR_UPDATE,
-			       NULL, NULL, &_lvconvert_split_cachepool_single);
+			       NULL, NULL, &_lvconvert_split_cache_single);
 }
 
 static int _lvconvert_raid_types_single(struct cmd_context *cmd, struct logical_volume *lv,
@@ -5041,6 +5062,524 @@ int lvconvert_to_vdopool_param_cmd(struct cmd_context *cmd, int argc, char **arg
 			       NULL, NULL, &_lvconvert_to_vdopool_single);
 }
 
+static int _lv_writecache_detach(struct cmd_context *cmd, struct logical_volume *lv,
+				 struct logical_volume *lv_fast)
+{
+	struct lv_segment *seg = first_seg(lv);
+	struct logical_volume *origin;
+
+	if (!seg_is_writecache(seg)) {
+		log_error("LV %s segment is not writecache.", display_lvname(lv));
+		return 0;
+	}
+
+	if (!seg->writecache) {
+		log_error("LV %s writecache segment has no writecache.", display_lvname(lv));
+		return 0;
+	}
+
+	if (!(origin = seg_lv(seg, 0))) {
+		log_error("LV %s writecache segment has no origin", display_lvname(lv));
+		return 0;
+	}
+
+	if (!remove_seg_from_segs_using_this_lv(seg->writecache, seg))
+		return_0;
+
+	lv_set_visible(seg->writecache);
+
+	lv->status &= ~WRITECACHE;
+	seg->writecache = NULL;
+
+	if (!remove_layer_from_lv(lv, origin))
+		return_0;
+
+	if (!lv_remove(origin))
+		return_0;
+
+	return 1;
+}
+
+static int _get_writecache_kernel_error(struct cmd_context *cmd,
+					struct logical_volume *lv,
+					uint32_t *kernel_error)
+{
+	struct lv_with_info_and_seg_status status;
+
+	memset(&status, 0, sizeof(status));
+	status.seg_status.type = SEG_STATUS_NONE;
+
+	status.seg_status.seg = first_seg(lv);
+
+	/* FIXME: why reporter_pool? */
+	if (!(status.seg_status.mem = dm_pool_create("reporter_pool", 1024))) {
+		log_error("Failed to get mem for LV status.");
+		return 0;
+	}
+
+	if (!lv_info_with_seg_status(cmd, first_seg(lv), &status, 1, 1)) {
+		log_error("Failed to get device mapper status for %s", display_lvname(lv));
+		goto fail;
+	}
+
+	if (!status.info.exists) {
+		log_error("No device mapper info exists for %s", display_lvname(lv));
+		goto fail;
+	}
+
+	if (status.seg_status.type != SEG_STATUS_WRITECACHE) {
+		log_error("Invalid device mapper status type (%d) for %s",
+			  (uint32_t)status.seg_status.type, display_lvname(lv));
+		goto fail;
+	}
+
+	*kernel_error = status.seg_status.writecache->error;
+
+	dm_pool_destroy(status.seg_status.mem);
+	return 1;
+
+fail:
+	dm_pool_destroy(status.seg_status.mem);
+	return 0;
+}
+
+/*
+ * TODO: add a new option that will skip activating and flushing the
+ * writecache and move directly to detaching.
+ */
+
+static int _lvconvert_detach_writecache(struct cmd_context *cmd,
+					struct logical_volume *lv,
+					struct logical_volume *lv_fast)
+{
+	uint32_t kernel_error = 0;
+
+	/*
+	 * LV must be inactive externally before detaching cache.
+	 */
+
+	if (lv_info(cmd, lv, 1, NULL, 0, 0)) {
+		log_error("LV %s must be inactive to detach writecache.", display_lvname(lv));
+		return 0;
+	}
+
+	if (!archive(lv->vg))
+		goto_bad;
+
+	/*
+	 * Activate LV internally since the LV needs to be active to flush.
+	 * LV_TEMPORARY should keep the LV from being exposed to the user
+	 * and being accessed.
+	 */
+
+	lv->status |= LV_TEMPORARY;
+
+	if (!activate_lv(cmd, lv)) {
+		log_error("Failed to activate LV %s for flushing.", display_lvname(lv));
+		return 0;
+	}
+
+	sync_local_dev_names(cmd);
+
+	if (!lv_writecache_message(lv, "flush")) {
+		log_error("Failed to flush writecache for %s.", display_lvname(lv));
+		deactivate_lv(cmd, lv);
+		return 0;
+	}
+
+	if (!_get_writecache_kernel_error(cmd, lv, &kernel_error)) {
+		log_error("Failed to get writecache error status for %s.", display_lvname(lv));
+		deactivate_lv(cmd, lv);
+		return 0;
+	}
+
+	if (kernel_error) {
+		log_error("Failed to flush writecache (error %u) for %s.", kernel_error, display_lvname(lv));
+		deactivate_lv(cmd, lv);
+		return 0;
+	}
+
+	if (!deactivate_lv(cmd, lv)) {
+		log_error("Failed to deactivate LV %s for detaching writecache.", display_lvname(lv));
+		return 0;
+	}
+
+	lv->status &= ~LV_TEMPORARY;
+
+	if (!_lv_writecache_detach(cmd, lv, lv_fast)) {
+		log_error("Failed to detach writecache from %s", display_lvname(lv));
+		return 0;
+	}
+
+	if (!vg_write(lv->vg) || !vg_commit(lv->vg))
+		return_0;
+
+	backup(lv->vg);
+
+	log_print_unless_silent("Logical volume %s write cache has been detached.",
+				display_lvname(lv));
+	return ECMD_PROCESSED;
+bad:
+	return ECMD_FAILED;
+
+}
+
+static int _writecache_zero(struct cmd_context *cmd, struct logical_volume *lv)
+{
+	struct device *dev;
+	char name[PATH_MAX];
+	int ret = 0;
+
+	if (!activate_lv(cmd, lv)) {
+		log_error("Failed to activate LV %s for zeroing.", lv->name);
+		return 0;
+	}
+
+	sync_local_dev_names(cmd);
+
+	if (dm_snprintf(name, sizeof(name), "%s%s/%s",
+			cmd->dev_dir, lv->vg->name, lv->name) < 0) {
+		log_error("Name too long - device not cleared (%s)", lv->name);
+		goto out;
+	}
+
+	if (!(dev = dev_cache_get(cmd, name, NULL))) {
+		log_error("%s: not found: device not zeroed", name);
+		goto out;
+	}
+
+	if (!label_scan_open(dev)) {
+		log_error("Failed to open %s/%s for zeroing.", lv->vg->name, lv->name);
+		goto out;
+	}
+
+	if (!dev_write_zeros(dev, UINT64_C(0), (size_t) 1 << SECTOR_SHIFT))
+		goto_out;
+
+	log_debug("Zeroed the first sector of %s", lv->name);
+
+	label_scan_invalidate(dev);
+
+	ret = 1;
+out:
+	if (!deactivate_lv(cmd, lv)) {
+		log_error("Failed to deactivate LV %s for zeroing.", lv->name);
+		ret = 0;
+	}
+
+	return ret;
+}
+
+static int _get_one_writecache_setting(struct cmd_context *cmd, struct writecache_settings *settings,
+				       char *key, char *val)
+{
+	if (!strncmp(key, "high_watermark", strlen("high_watermark"))) {
+		if (sscanf(val, "%llu", (unsigned long long *)&settings->high_watermark) != 1)
+			goto_bad;
+		settings->high_watermark_set = 1;
+		return 1;
+	}
+
+	if (!strncmp(key, "low_watermark", strlen("low_watermark"))) {
+		if (sscanf(val, "%llu", (unsigned long long *)&settings->low_watermark) != 1)
+			goto_bad;
+		settings->low_watermark_set = 1;
+		return 1;
+	}
+
+	if (!strncmp(key, "writeback_jobs", strlen("writeback_jobs"))) {
+		if (sscanf(val, "%llu", (unsigned long long *)&settings->writeback_jobs) != 1)
+			goto_bad;
+		settings->writeback_jobs_set = 1;
+		return 1;
+	}
+
+	if (!strncmp(key, "autocommit_blocks", strlen("autocommit_blocks"))) {
+		if (sscanf(val, "%llu", (unsigned long long *)&settings->autocommit_blocks) != 1)
+			goto_bad;
+		settings->autocommit_blocks_set = 1;
+		return 1;
+	}
+
+	if (!strncmp(key, "autocommit_time", strlen("autocommit_time"))) {
+		if (sscanf(val, "%llu", (unsigned long long *)&settings->autocommit_time) != 1)
+			goto_bad;
+		settings->autocommit_time_set = 1;
+		return 1;
+	}
+
+	if (!strncmp(key, "fua", strlen("fua"))) {
+		if (settings->nofua_set) {
+			log_error("Setting fua and nofua cannot both be set.");
+			return_0;
+		}
+		if (sscanf(val, "%u", &settings->fua) != 1)
+			goto_bad;
+		settings->fua_set = 1;
+		return 1;
+	}
+
+	if (!strncmp(key, "nofua", strlen("nofua"))) {
+		if (settings->nofua_set) {
+			log_error("Setting fua and nofua cannot both be set.");
+			return_0;
+		}
+		if (sscanf(val, "%u", &settings->nofua) != 1)
+			goto_bad;
+		settings->nofua_set = 1;
+		return 1;
+	}
+
+	if (settings->new_key) {
+		log_error("Setting %s is not recognized. Only one unrecognized setting is allowed.", key);
+		return 0;
+	}
+
+	log_warn("Unrecognized writecache setting \"%s\" may cause activation failure.", key);
+	if (yes_no_prompt("Use unrecognized writecache setting? [y/n]: ") == 'n') {
+		log_error("Aborting writecache conversion.");
+		return_0;
+	}
+
+	log_warn("Using unrecognized writecache setting: %s = %s.", key, val);
+
+	settings->new_key = dm_pool_strdup(cmd->mem, key);
+	settings->new_val = dm_pool_strdup(cmd->mem, val);
+	return 1;
+
+ bad:
+	log_error("Invalid setting: %s", key);
+	return 0;
+}
+
+static int _get_writecache_settings(struct cmd_context *cmd, struct writecache_settings *settings)
+{
+	struct arg_value_group_list *group;
+	const char *str;
+	char key[64];
+	char val[64];
+	int num;
+	int pos;
+
+	/*
+	 * "grouped" means that multiple --cachesettings options can be used.
+	 * Each option is also allowed to contain multiple key = val pairs.
+	 */
+
+	dm_list_iterate_items(group, &cmd->arg_value_groups) {
+		if (!grouped_arg_is_set(group->arg_values, cachesettings_ARG))
+			continue;
+
+		if (!(str = grouped_arg_str_value(group->arg_values, cachesettings_ARG, NULL)))
+			break;
+
+		pos = 0;
+
+		while (pos < strlen(str)) {
+			/* scan for "key1=val1 key2 = val2  key3= val3" */
+
+			memset(key, 0, sizeof(key));
+			memset(val, 0, sizeof(val));
+
+			if (sscanf(str + pos, " %63[^=]=%63s %n", key, val, &num) != 2) {
+				log_error("Invalid setting at: %s", str+pos);
+				return_0;
+			}
+
+			pos += num;
+
+			if (!_get_one_writecache_setting(cmd, settings, key, val))
+				return_0;
+		}
+	}
+
+	return 1;
+}
+
+static struct logical_volume *_lv_writecache_create(struct cmd_context *cmd,
+					    struct logical_volume *lv,
+					    struct logical_volume *lv_fast,
+					    uint32_t block_size_sectors,
+					    struct writecache_settings *settings)
+{
+	struct logical_volume *lv_wcorig;
+	const struct segment_type *segtype;
+	struct lv_segment *seg;
+
+	/* should lv_fast get a new status flag indicating it's the cache in a writecache LV? */
+
+	if (!(segtype = get_segtype_from_string(cmd, SEG_TYPE_NAME_WRITECACHE)))
+		return_NULL;
+
+	/*
+	 * "lv_wcorig" is a new LV with new id, but with the segments from "lv".
+	 * "lv" keeps the existing name and id, but gets a new writecache segment,
+	 * in place of the segments that were moved to lv_wcorig.
+	 */
+
+	if (!(lv_wcorig = insert_layer_for_lv(cmd, lv, WRITECACHE, "_wcorig")))
+		return_NULL;
+
+	lv_set_hidden(lv_fast);
+
+	seg = first_seg(lv);
+	seg->segtype = segtype;
+
+	seg->writecache = lv_fast;
+
+	/* writecache_block_size is in bytes */
+	seg->writecache_block_size = block_size_sectors * 512;
+
+	memcpy(&seg->writecache_settings, settings, sizeof(struct writecache_settings));
+
+	add_seg_to_segs_using_this_lv(lv_fast, seg);
+
+	return lv_wcorig;
+}
+
+static int _lvconvert_writecache_attach_single(struct cmd_context *cmd,
+					struct logical_volume *lv,
+					struct processing_handle *handle)
+{
+	struct volume_group *vg = lv->vg;
+	struct logical_volume *lv_wcorig;
+	struct logical_volume *lv_fast;
+	struct writecache_settings settings;
+	const char *fast_name;
+	uint32_t block_size_sectors;
+	char *lockd_fast_args = NULL;
+	char *lockd_fast_name = NULL;
+	struct id lockd_fast_id;
+
+	fast_name = arg_str_value(cmd, cachepool_ARG, "");
+
+	if (!(lv_fast = find_lv(vg, fast_name))) {
+		log_error("LV %s not found.", fast_name);
+		goto bad;
+	}
+
+	if (!seg_is_linear(first_seg(lv_fast))) {
+		log_error("LV %s must be linear to use as a writecache.", display_lvname(lv_fast));
+		return 0;
+	}
+
+	/* fast LV shouldn't generally be active by itself, but just in case. */
+	if (lv_info(cmd, lv_fast, 1, NULL, 0, 0)) {
+		log_error("LV %s must be inactive to attach.", display_lvname(lv_fast));
+		return 0;
+	}
+
+	/* default block size is 4096 bytes (8 sectors) */
+	block_size_sectors = arg_int_value(cmd, writecacheblocksize_ARG, 8);
+	if (block_size_sectors > 8) {
+		log_error("Max writecache block size is 4096 bytes.");
+		return 0;
+	}
+
+	memset(&settings, 0, sizeof(settings));
+
+	if (!_get_writecache_settings(cmd, &settings)) {
+		log_error("Invalid writecache settings.");
+		return 0;
+	}
+
+	/* Ensure the two LVs are not active elsewhere. */
+	if (!lockd_lv(cmd, lv, "ex", 0))
+		goto_bad;
+	if (!lockd_lv(cmd, lv_fast, "ex", 0))
+		goto_bad;
+
+	if (!archive(vg))
+		goto_bad;
+
+	/*
+	 * TODO: use libblkid to get the sector size of lv.  If it doesn't
+	 * match the block_size we are using for the writecache, then warn that
+	 * an existing file system on lv may become unmountable with the
+	 * writecache attached because of the changing sector size.  If this
+	 * happens, then use --splitcache, and reattach the writecache using a
+	 * --writecacheblocksize value matching the sector size of lv.
+	 */
+
+	if (!_writecache_zero(cmd, lv_fast)) {
+		log_error("LV %s could not be zeroed.", display_lvname(lv_fast));
+		return 0;
+	}
+
+	/*
+	 * Changes the vg struct to match the desired state.
+	 *
+	 * - lv keeps existing lv name and id, gets new segment with segtype
+	 *   "writecache".
+	 *
+	 * - lv_fast keeps its existing name and id, becomes hidden.
+	 *
+	 * - lv_wcorig gets new name (existing name + _wcorig suffix),
+	 *   gets new id, becomes hidden, gets segments from lv.
+	 */
+
+	if (!(lv_wcorig = _lv_writecache_create(cmd, lv, lv_fast, block_size_sectors, &settings)))
+		goto_bad;
+
+	/*
+	 * lv keeps the same lockd lock it had before, the lock for
+	 * lv_fast is freed, and lv_wcorig gets no lock.
+	 */
+	if (vg_is_shared(vg) && lv_fast->lock_args) {
+		lockd_fast_args = dm_pool_strdup(cmd->mem, lv_fast->lock_args);
+		lockd_fast_name = dm_pool_strdup(cmd->mem, lv_fast->name);
+		memcpy(&lockd_fast_id, &lv_fast->lvid.id[1], sizeof(struct id));
+		lv_fast->lock_args = NULL;
+	}
+
+	/*
+	 * vg_write(), suspend_lv(), vg_commit(), resume_lv(),
+	 * where the old LV is suspended and the new LV is resumed.
+	 */
+
+	if (!lv_update_and_reload(lv))
+		goto_bad;
+
+	lockd_lv(cmd, lv, "un", 0);
+
+	if (lockd_fast_name) {
+		/* unlock and free lockd lock for lv_fast */
+		if (!lockd_lv_name(cmd, vg, lockd_fast_name, &lockd_fast_id, lockd_fast_args, "un", 0))
+			log_error("Failed to unlock fast LV %s/%s", vg->name, lockd_fast_name);
+		lockd_free_lv(cmd, vg, lockd_fast_name, &lockd_fast_id, lockd_fast_args);
+	}
+
+	log_print_unless_silent("Logical volume %s now has write cache.",
+				display_lvname(lv));
+	return ECMD_PROCESSED;
+bad:
+	return ECMD_FAILED;
+
+}
+
+int lvconvert_to_writecache_vol_cmd(struct cmd_context *cmd, int argc, char **argv)
+{
+	struct processing_handle *handle;
+	struct lvconvert_result lr = { 0 };
+	int ret;
+
+	if (!(handle = init_processing_handle(cmd, NULL))) {
+		log_error("Failed to initialize processing handle.");
+		return ECMD_FAILED;
+	}
+
+	handle->custom_handle = &lr;
+
+	cmd->cname->flags &= ~GET_VGNAME_FROM_OPTIONS;
+
+	ret = process_each_lv(cmd, cmd->position_argc, cmd->position_argv, NULL, NULL, READ_FOR_UPDATE, handle, NULL,
+			      &_lvconvert_writecache_attach_single);
+
+	destroy_processing_handle(cmd, handle);
+
+	return ret;
+}
+
 /*
  * All lvconvert command defs have their own function,
  * so the generic function name is unused.
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index b1d0723..f49843d 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -124,12 +124,13 @@ static const struct command_function _command_functions[CMD_COUNT] = {
 	{ lvconvert_to_cachepool_CMD,			lvconvert_to_pool_cmd },
 	{ lvconvert_to_thin_with_external_CMD,		lvconvert_to_thin_with_external_cmd },
 	{ lvconvert_to_cache_vol_CMD,			lvconvert_to_cache_vol_cmd },
+	{ lvconvert_to_writecache_vol_CMD,		lvconvert_to_writecache_vol_cmd },
 	{ lvconvert_swap_pool_metadata_CMD,		lvconvert_swap_pool_metadata_cmd },
 	{ lvconvert_to_thinpool_or_swap_metadata_CMD,   lvconvert_to_pool_or_swap_metadata_cmd },
 	{ lvconvert_to_cachepool_or_swap_metadata_CMD,  lvconvert_to_pool_or_swap_metadata_cmd },
 	{ lvconvert_merge_thin_CMD,			lvconvert_merge_thin_cmd },
-	{ lvconvert_split_and_keep_cachepool_CMD,	lvconvert_split_cachepool_cmd },
-	{ lvconvert_split_and_remove_cachepool_CMD,	lvconvert_split_cachepool_cmd },
+	{ lvconvert_split_and_keep_cache_CMD,		lvconvert_split_cache_cmd },
+	{ lvconvert_split_and_remove_cache_CMD,		lvconvert_split_cache_cmd },
 
 	/* lvconvert raid-related type conversions */
 	{ lvconvert_raid_types_CMD,			lvconvert_raid_types_cmd },
@@ -2120,7 +2121,7 @@ static int _process_command_line(struct cmd_context *cmd, int *argc, char ***arg
 		 * value (e.g. foo_ARG) from the args array.
 		 */
 		if ((arg_enum = _find_arg(cmd->name, goval)) < 0) {
-			log_fatal("Unrecognised option.");
+			log_fatal("Unrecognised option %d (%c).", goval, goval);
 			return 0;
 		}
 
diff --git a/tools/toollib.c b/tools/toollib.c
index c2ffa42..2ab4b62 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -2562,6 +2562,8 @@ static int _lv_is_type(struct cmd_context *cmd, struct logical_volume *lv, int l
 		return seg_is_any_raid6(seg);
 	case raid10_LVT:
 		return seg_is_raid10(seg);
+	case writecache_LVT:
+		return seg_is_writecache(seg);
 	case error_LVT:
 		return !strcmp(seg->segtype->name, SEG_TYPE_NAME_ERROR);
 	case zero_LVT:
@@ -2618,6 +2620,8 @@ int get_lvt_enum(struct logical_volume *lv)
 		return raid6_LVT;
 	if (seg_is_raid10(seg))
 		return raid10_LVT;
+	if (seg_is_writecache(seg))
+		return writecache_LVT;
 
 	if (!strcmp(seg->segtype->name, SEG_TYPE_NAME_ERROR))
 		return error_LVT;
@@ -2740,8 +2744,13 @@ static int _check_lv_types(struct cmd_context *cmd, struct logical_volume *lv, i
 	if (!ret) {
 		int lvt_enum = get_lvt_enum(lv);
 		struct lv_type *type = get_lv_type(lvt_enum);
-		log_warn("Command on LV %s does not accept LV type %s.",
-			 display_lvname(lv), type ? type->name : "unknown");
+		if (!type) {
+			log_warn("Command on LV %s does not accept LV type unknown (%d).",
+				 display_lvname(lv), lvt_enum);
+		} else {
+			log_warn("Command on LV %s does not accept LV type %s.",
+				 display_lvname(lv), type->name);
+		}
 	}
 
 	return ret;
diff --git a/tools/tools.h b/tools/tools.h
index 55d486b..5e0cd30 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -248,11 +248,12 @@ int lvconvert_start_poll_cmd(struct cmd_context *cmd, int argc, char **argv);
 
 int lvconvert_to_pool_cmd(struct cmd_context *cmd, int argc, char **argv);
 int lvconvert_to_cache_vol_cmd(struct cmd_context *cmd, int argc, char **argv);
+int lvconvert_to_writecache_vol_cmd(struct cmd_context *cmd, int argc, char **argv);
 int lvconvert_to_thin_with_external_cmd(struct cmd_context *cmd, int argc, char **argv);
 int lvconvert_swap_pool_metadata_cmd(struct cmd_context *cmd, int argc, char **argv);
 int lvconvert_to_pool_or_swap_metadata_cmd(struct cmd_context *cmd, int argc, char **argv);
 int lvconvert_merge_thin_cmd(struct cmd_context *cmd, int argc, char **argv);
-int lvconvert_split_cachepool_cmd(struct cmd_context *cmd, int argc, char **argv);
+int lvconvert_split_cache_cmd(struct cmd_context *cmd, int argc, char **argv);
 
 int lvconvert_raid_types_cmd(struct cmd_context * cmd, int argc, char **argv);
 int lvconvert_split_mirror_images_cmd(struct cmd_context * cmd, int argc, char **argv);


