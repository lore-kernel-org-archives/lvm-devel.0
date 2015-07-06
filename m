From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon,  6 Jul 2015 14:09:36 +0000 (UTC)
Subject: master - macros: Wrap PRI with FMT.
Message-ID: <20150706140936.2D8576007A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=810ab095e6709364d9f7c86d3754762aab3d976d
Commit:        810ab095e6709364d9f7c86d3754762aab3d976d
Parent:        5fb71bd53062011dd962d77b233552ffad128238
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Jul 6 15:09:17 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Jul 6 15:09:17 2015 +0100

macros: Wrap PRI with FMT.

Create a set of wrappers with embedded % such as
  #define FMTu64 "%" PRIu64
---
 WHATS_NEW_DM                    |    1 +
 daemons/clvmd/clvmd-openais.c   |    2 +-
 lib/format_text/format-text.c   |    2 +-
 lib/metadata/cache_manip.c      |    2 +-
 lib/metadata/lv.c               |    2 +-
 lib/metadata/lv_manip.c         |    4 ++--
 lib/metadata/mirror.c           |    2 +-
 lib/metadata/replicator_manip.c |    2 +-
 lib/metadata/thin_manip.c       |    2 +-
 lib/mirror/mirrored.c           |    2 +-
 lib/misc/lib.h                  |    5 -----
 lib/misc/util.h                 |   37 +++++++++++++++++++++++++++++++++++++
 lib/raid/raid.c                 |    2 +-
 lib/replicator/replicator.c     |    2 +-
 lib/uuid/uuid.h                 |    1 -
 libdaemon/client/config-util.c  |    5 +++--
 libdm/libdm-common.c            |    2 +-
 libdm/libdm-config.c            |    2 +-
 libdm/libdm-deptree.c           |    8 ++++----
 libdm/libdm-report.c            |    2 +-
 tools/dmsetup.c                 |   10 ++++------
 tools/lvconvert.c               |    6 +++---
 tools/pvscan.c                  |    2 +-
 23 files changed, 68 insertions(+), 37 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 8b4faff..fe3b5de 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.102 -
 ================================
+  Introduce format macros with embedded % such as FMTu64.
 
 Version 1.02.101 - 3rd July 2015
 ================================
diff --git a/daemons/clvmd/clvmd-openais.c b/daemons/clvmd/clvmd-openais.c
index 29a323a..bd76214 100644
--- a/daemons/clvmd/clvmd-openais.c
+++ b/daemons/clvmd/clvmd-openais.c
@@ -243,7 +243,7 @@ static void openais_cpg_confchg_callback(cpg_handle_t handle,
 	struct node_info *ninfo;
 
 	DEBUGLOG("confchg callback. %" PRIsize_t " joined, "
-		 "%" PRIsize_t " left, %" PRIsize_t " members\n",
+		 FMTsize_t " left, %" PRIsize_t " members\n",
 		 joined_list_entries, left_list_entries, member_list_entries);
 
 	for (i=0; i<joined_list_entries; i++) {
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index f38628c..fc759fb 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -2237,7 +2237,7 @@ static int _text_pv_add_metadata_area(const struct format_type *fmt,
 	if (limit_applied)
 		log_very_verbose("Using limited metadata area size on %s "
 				 "with value %" PRIu64 " (limited by %s of "
-				 "%" PRIu64 ").", pv_dev_name(pv),
+				 FMTu64 ").", pv_dev_name(pv),
 				  mda_size, limit_name, limit);
 
 	if (mda_size) {
diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 41de440..5a93031 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -322,7 +322,7 @@ int lv_cache_remove(struct logical_volume *cache_lv)
 		dirty_blocks = status->cache->dirty_blocks;
 		dm_pool_destroy(status->mem);
 		if (dirty_blocks) {
-			log_print_unless_silent("%" PRIu64 " blocks must still be flushed.",
+			log_print_unless_silent(FMTu64 " blocks must still be flushed.",
 						dirty_blocks);
 			sleep(1);
 		}
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 49d4a09..df784c1 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -79,7 +79,7 @@ static char *_format_pvsegs(struct dm_pool *mem, const struct lv_segment *seg,
 
 		if (range_format) {
 			if (dm_snprintf(extent_str, sizeof(extent_str),
-					"%" PRIu32, extent + seg->area_len - 1) < 0) {
+					FMTu32, extent + seg->area_len - 1) < 0) {
 				log_error("Extent number dm_snprintf failed");
 				return NULL;
 			}
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 1891491..a447f08 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4356,7 +4356,7 @@ static int _fsadm_cmd(struct cmd_context *cmd,
 	argv[i++] = lv_path;
 
 	if (fcmd == FSADM_CMD_RESIZE) {
-		if (dm_snprintf(size_buf, sizeof(size_buf), "%" PRIu64 "K",
+		if (dm_snprintf(size_buf, sizeof(size_buf), FMTu64 "K",
 				(uint64_t) lp->extents * (vg->extent_size / 2)) < 0) {
 			log_error("Couldn't generate new LV size string");
 			return 0;
@@ -6161,7 +6161,7 @@ int remove_layers_for_segments(struct cmd_context *cmd,
 				log_error("Layer boundary mismatch: "
 					  "%s:%" PRIu32 "-%" PRIu32 " on "
 					  "%s:%" PRIu32 " / "
-					  "%" PRIu32 "-%" PRIu32 " / ",
+					  FMTu32 "-" FMTu32 " / ",
 					  lv->name, seg->le, seg->area_len,
 					  layer_lv->name, seg_le(seg, s),
 					  lseg->le, lseg->area_len);
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 4857ad0..f0d8f00 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -1171,7 +1171,7 @@ static int _remove_mirror_images(struct logical_volume *lv,
 	if (removed)
 		*removed = old_area_count - new_area_count;
 
-	log_very_verbose("%" PRIu32 " image(s) removed from %s",
+	log_very_verbose(FMTu32 " image(s) removed from %s",
 			 old_area_count - new_area_count, lv->name);
 
 	return 1;
diff --git a/lib/metadata/replicator_manip.c b/lib/metadata/replicator_manip.c
index fc4bf5f..ed34cca 100644
--- a/lib/metadata/replicator_manip.c
+++ b/lib/metadata/replicator_manip.c
@@ -298,7 +298,7 @@ int check_replicator_segment(const struct lv_segment *rseg)
 			}
 			if (rsite->fall_behind_data) {
 				log_error("Defined fall_behind_data="
-					  "%" PRIu64 " for sync replicator %s/%s.",
+					  FMTu64 " for sync replicator %s/%s.",
 					  rsite->fall_behind_data, lv->name, rsite->name);
 				r = 0;
 			}
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 6ae0795..dd4e514 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -720,7 +720,7 @@ int check_new_thin_pool(const struct logical_volume *pool_lv)
 	/* Require pool to have same transaction_id as new  */
 	if (first_seg(pool_lv)->transaction_id != transaction_id) {
 		log_error("Cannot use thin pool %s with transaction id "
-			  "%" PRIu64 " for thin volumes. "
+			  FMTu64 " for thin volumes. "
 			  "Expected transaction id %" PRIu64 ".",
 			  display_lvname(pool_lv), transaction_id,
 			  first_seg(pool_lv)->transaction_id);
diff --git a/lib/mirror/mirrored.c b/lib/mirror/mirrored.c
index e57e9bb..2156165 100644
--- a/lib/mirror/mirrored.c
+++ b/lib/mirror/mirrored.c
@@ -195,7 +195,7 @@ static int _mirrored_target_percent(void **target_state,
 		pos += used;
 	}
 
-	if (sscanf(pos, "%" PRIu64 "/%" PRIu64 "%n", &numerator, &denominator,
+	if (sscanf(pos, FMTu64 "/" FMTu64 "%n", &numerator, &denominator,
 		   &used) != 2) {
 		log_error("Failure parsing mirror status fraction: %s", params);
 		return 0;
diff --git a/lib/misc/lib.h b/lib/misc/lib.h
index 63e58d0..63f60a2 100644
--- a/lib/misc/lib.h
+++ b/lib/misc/lib.h
@@ -25,11 +25,6 @@
 #define _GNU_SOURCE
 #define _FILE_OFFSET_BITS 64
 
-/* Define some portable printing types */
-#define PRIsize_t "zu"
-#define PRIptrdiff_t "td"
-#define PRIpid_t PRId32
-
 #if defined(__GNUC__)
 #define DM_EXPORTED_SYMBOL(func, ver) \
 	__asm__(".symver " #func "_v" #ver ", " #func "@@DM_" #ver )
diff --git a/lib/misc/util.h b/lib/misc/util.h
index a453469..113ca69 100644
--- a/lib/misc/util.h
+++ b/lib/misc/util.h
@@ -15,6 +15,8 @@
 #ifndef _LVM_UTIL_H
 #define _LVM_UTIL_H
 
+#include <inttypes.h>
+
 #define min(a, b) ({ typeof(a) _a = (a); \
 		     typeof(b) _b = (b); \
 		     (void) (&_a == &_b); \
@@ -33,4 +35,39 @@
 
 #define KERNEL_VERSION(major, minor, release) (((major) << 16) + ((minor) << 8) + (release))
 
+/* Define some portable printing types */
+#define PRIsize_t "zu"
+#define PRIptrdiff_t "td"
+#define PRIpid_t PRId32
+
+/* For convenience */
+#define FMTsize_t "%" PRIsize_t
+#define FMTptrdiff_t "%" PRIptrdiff_t
+#define FMTpid_t "%" PRIpid_t
+
+#define FMTd8  "%" PRId8
+#define FMTd16 "%" PRId16
+#define FMTd32 "%" PRId32
+#define FMTd64 "%" PRId64
+
+#define FMTi8  "%" PRIi8
+#define FMTi16 "%" PRIi16
+#define FMTi32 "%" PRIi32
+#define FMTi64 "%" PRIi64
+
+#define FMTo8  "%" PRIo8
+#define FMTo16 "%" PRIo16
+#define FMTo32 "%" PRIo32
+#define FMTo64 "%" PRIo64
+
+#define FMTu8  "%" PRIu8
+#define FMTu16 "%" PRIu16
+#define FMTu32 "%" PRIu32
+#define FMTu64 "%" PRIu64
+
+#define FMTx8  "%" PRIx8
+#define FMTx16 "%" PRIx16
+#define FMTx32 "%" PRIx32
+#define FMTx64 "%" PRIx64
+
 #endif
diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index 39e3a06..e9dfbd4 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -302,7 +302,7 @@ static int _raid_target_percent(void **target_state,
 		else
 			break;
 	}
-	if (!pos || (sscanf(pos, "%" PRIu64 "/%" PRIu64 "%n",
+	if (!pos || (sscanf(pos, FMTu64 "/" FMTu64 "%n",
 			    &numerator, &denominator, &i) != 2)) {
 		log_error("Failed to parse %s status fraction: %s",
 			  (seg) ? seg->segtype->name : "segment", params);
diff --git a/lib/replicator/replicator.c b/lib/replicator/replicator.c
index ae87d7f..7a8c3a8 100644
--- a/lib/replicator/replicator.c
+++ b/lib/replicator/replicator.c
@@ -672,7 +672,7 @@ static int _replicator_dev_add_target_line(struct dev_manager *dm,
 			if (!(slog_dlid = build_dm_uuid(mem, rdev->slog, NULL)))
 				return_0;
 		} else if (rdev->slog_name &&
-			   sscanf(rdev->slog_name, "%" PRIu32, &slog_size) == 1) {
+			   sscanf(rdev->slog_name, FMTu32, &slog_size) == 1) {
 			slog_flags = DM_CORELOG | DM_FORCESYNC;
 			if (slog_size == 0) {
 				log_error("Failed to use empty corelog size "
diff --git a/lib/uuid/uuid.h b/lib/uuid/uuid.h
index d39ad88..d87de73 100644
--- a/lib/uuid/uuid.h
+++ b/lib/uuid/uuid.h
@@ -18,7 +18,6 @@
 
 #define ID_LEN 32
 
-#include <inttypes.h>
 #include <sys/types.h>
 
 struct dm_pool;
diff --git a/libdaemon/client/config-util.c b/libdaemon/client/config-util.c
index 067c912..c417def 100644
--- a/libdaemon/client/config-util.c
+++ b/libdaemon/client/config-util.c
@@ -14,6 +14,7 @@
 
 #include "daemon-io.h"
 #include "dm-logging.h"
+#include "util.h"
 
 #include <errno.h>
 #include <stdio.h>
@@ -39,7 +40,7 @@ int buffer_append_vf(struct buffer *buf, va_list ap)
 			goto fail;
 		}
 		keylen = strchr(next, '=') - next;
-		if (strstr(next, "%d") || strstr(next, "%" PRId64)) {
+		if (strstr(next, "%d") || strstr(next, FMTd64)) {
 			value = va_arg(ap, int64_t);
 			if (dm_asprintf(&append, "%.*s= %" PRId64 "\n", keylen, next, value) < 0)
 				goto fail;
@@ -237,7 +238,7 @@ struct dm_config_node *config_make_nodes_v(struct dm_config_tree *cft,
 		key[fmt - next] = '\0';
 		fmt += 2;
 
-		if (!strcmp(fmt, "%d") || !strcmp(fmt, "%" PRId64)) {
+		if (!strcmp(fmt, "%d") || !strcmp(fmt, FMTd64)) {
 			int64_t value = va_arg(ap, int64_t);
 			if (!(cn = make_int_node(cft, key, value, parent, pre_sib)))
 				return 0;
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index 6f56c60..b56643f 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -1219,7 +1219,7 @@ static int _set_read_ahead(const char *dev_name, uint32_t major, uint32_t minor,
 		}
 
 		/* Sysfs is kB based, round up to kB */
-		if ((len = dm_snprintf(buf, sizeof(buf), "%" PRIu32,
+		if ((len = dm_snprintf(buf, sizeof(buf), FMTu32,
 				       (read_ahead + 1) / 2)) < 0) {
 			log_error("Failed to build size in kB.");
 			return 0;
diff --git a/libdm/libdm-config.c b/libdm/libdm-config.c
index f163677..b2082c8 100644
--- a/libdm/libdm-config.c
+++ b/libdm/libdm-config.c
@@ -290,7 +290,7 @@ static int _write_value(struct config_output *out, const struct dm_config_value
 		if (v->format_flags & DM_CONFIG_VALUE_FMT_INT_OCTAL)
 			line_append("0%" PRIo64, v->v.i);
 		else
-			line_append("%" PRId64, v->v.i);
+			line_append(FMTd64, v->v.i);
 		break;
 
 	case DM_CFG_EMPTY_ARRAY:
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 5baac6d..36befff 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -1458,7 +1458,7 @@ static int _thin_pool_status_transaction_id(struct dm_tree_node *dnode, uint64_t
 		goto out;
 	}
 
-	if (!params || (sscanf(params, "%" PRIu64, transaction_id) != 1)) {
+	if (!params || (sscanf(params, FMTu64, transaction_id) != 1)) {
 		log_error("Failed to parse transaction_id from %s.", params);
 		goto out;
 	}
@@ -3075,7 +3075,7 @@ int dm_get_status_snapshot(struct dm_pool *mem, const char *params,
 		return 0;
 	}
 
-	r = sscanf(params, "%" PRIu64 "/%" PRIu64 " %" PRIu64,
+	r = sscanf(params, FMTu64 "/" FMTu64 " " FMTu64,
 		   &s->used_sectors, &s->total_sectors,
 		   &s->metadata_sectors);
 
@@ -3992,7 +3992,7 @@ int dm_get_status_thin_pool(struct dm_pool *mem, const char *params,
 	}
 
 	/* FIXME: add support for held metadata root */
-	if (sscanf(params, "%" PRIu64 " %" PRIu64 "/%" PRIu64 " %" PRIu64 "/%" PRIu64 "%n",
+	if (sscanf(params, FMTu64 " " FMTu64 "/" FMTu64 " " FMTu64 "/" FMTu64 "%n",
 		   &s->transaction_id,
 		   &s->used_metadata_blocks,
 		   &s->total_metadata_blocks,
@@ -4044,7 +4044,7 @@ int dm_get_status_thin(struct dm_pool *mem, const char *params,
 	if (strchr(params, '-')) {
 		s->mapped_sectors = 0;
 		s->highest_mapped_sector = 0;
-	} else if (sscanf(params, "%" PRIu64 " %" PRIu64,
+	} else if (sscanf(params, FMTu64 " " FMTu64,
 		   &s->mapped_sectors,
 		   &s->highest_mapped_sector) != 2) {
 		dm_pool_free(mem, s);
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 7afbb8d..455123f 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -639,7 +639,7 @@ int dm_report_field_uint64(struct dm_report *rh,
 		return 0;
 	}
 
-	if (dm_snprintf(repstr, 21, "%" PRIu64 , value) < 0) {
+	if (dm_snprintf(repstr, 21, FMTu64 , value) < 0) {
 		log_error("dm_report_field_uint64: uint64 too big: %" PRIu64, value);
 		return 0;
 	}
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index f200e94..067a677 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -20,7 +20,7 @@
 #define _FILE_OFFSET_BITS 64
 
 #include "configure.h"
-
+#include "util.h"
 #include "dm-logging.h"
 
 #include <stdio.h>
@@ -29,9 +29,7 @@
 #include <ctype.h>
 #include <dirent.h>
 #include <errno.h>
-#include <unistd.h>
 #include <sys/wait.h>
-#include <unistd.h>
 #include <sys/param.h>
 #include <locale.h>
 #include <langinfo.h>
@@ -1186,7 +1184,7 @@ static int _udevcomplete_all(CMD_ARGS)
 			if (semctl(sid, 0, IPC_RMID, 0) < 0) {
 				log_error("Could not cleanup notification semaphore "
 					  "with semid %d and cookie value "
-					  "%" PRIu32 " (0x%" PRIx32 ")", sid,
+					  FMTu32 " (0x" FMTx32 ")", sid,
 					  sdata.sem_perm.__key, sdata.sem_perm.__key);
 				continue;
 			}
@@ -1196,7 +1194,7 @@ static int _udevcomplete_all(CMD_ARGS)
 	}
 
 	log_print("%d semaphores with keys prefixed by "
-		  "%" PRIu16 " (0x%" PRIx16 ") destroyed. %d skipped.",
+		  FMTu16 " (0x" FMTx16 ") destroyed. %d skipped.",
 		  counter, DM_COOKIE_MAGIC, DM_COOKIE_MAGIC, skipped);
 
 	return 1;
@@ -1713,7 +1711,7 @@ static int _status(CMD_ARGS)
 					while (*c && *c != ' ')
 						*c++ = '0';
 				}
-				printf("%" PRIu64 " %" PRIu64 " %s %s",
+				printf(FMTu64 " " FMTu64 " %s %s",
 				       start, length, target_type, params);
 			}
 			printf("\n");
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 00bab36..f967ae4 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2406,12 +2406,12 @@ static int _lvconvert_pool_repair(struct cmd_context *cmd,
 			 */
 			if ((fgets(meta_path, sizeof(meta_path), f) > 0) &&
 			    (trans_id_str = strstr(meta_path, "transaction=\"")) &&
-			    (sscanf(trans_id_str + 13, "%" PRIu64, &trans_id) == 1) &&
+			    (sscanf(trans_id_str + 13, FMTu64, &trans_id) == 1) &&
 			    (trans_id != first_seg(pool_lv)->transaction_id) &&
 			    ((trans_id - 1) != first_seg(pool_lv)->transaction_id))
-				log_error("Transaction id %" PRIu64 " from pool \"%s/%s\" "
+				log_error("Transaction id " FMTu64 " from pool \"%s/%s\" "
 					  "does not match repaired transaction id "
-					  "%" PRIu64 " from %s.",
+					  FMTu64 " from %s.",
 					  first_seg(pool_lv)->transaction_id,
 					  pool_lv->vg->name, pool_lv->name, trans_id,
 					  pms_path);
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 844aabd..3adb91c 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -166,7 +166,7 @@ static int _clear_dev_from_lvmetad_cache(dev_t devno, int32_t major, int32_t min
 {
 	char buf[24];
 
-	(void) dm_snprintf(buf, sizeof(buf), "%" PRIi32 ":%" PRIi32, major, minor);
+	(void) dm_snprintf(buf, sizeof(buf), FMTi32 ":" FMTi32, major, minor);
 
 	if (!lvmetad_pv_gone(devno, buf, handler))
 		return_0;


