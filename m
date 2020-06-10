From: David Teigland <teigland@sourceware.org>
Date: Wed, 10 Jun 2020 17:31:40 +0000 (GMT)
Subject: master - writecache: cachesettings in lvchange and lvs
Message-ID: <20200610173140.7471C388C030@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1ee42f13915d852008b1e7b777edee766413ef89
Commit:        1ee42f13915d852008b1e7b777edee766413ef89
Parent:        ce772bfab976d89f6a35a442434d1a49ceb634c7
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Feb 26 14:47:29 2020 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jun 10 12:14:00 2020 -0500

writecache: cachesettings in lvchange and lvs

lvchange --cachesettings
lvs -o+cache_settings
---
 lib/metadata/metadata-exported.h |   1 +
 lib/metadata/writecache_manip.c  |  70 ++++++++++++++++++
 lib/report/report.c              |  10 +++
 tools/command-lines.in           |   2 +-
 tools/lvchange.c                 |  75 +++++++++++++++++++
 tools/lvconvert.c                | 153 +--------------------------------------
 tools/toollib.c                  | 150 ++++++++++++++++++++++++++++++++++++++
 tools/toollib.h                  |   3 +
 8 files changed, 311 insertions(+), 153 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 9de088437..0d6be136b 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1096,6 +1096,7 @@ int lv_is_cow(const struct logical_volume *lv);
 int lv_is_cache_origin(const struct logical_volume *lv);
 int lv_is_writecache_origin(const struct logical_volume *lv);
 int lv_is_writecache_cachevol(const struct logical_volume *lv);
+int writecache_settings_to_str_list(struct writecache_settings *settings, struct dm_list *result, struct dm_pool *mem);
 
 int lv_is_integrity_origin(const struct logical_volume *lv);
 
diff --git a/lib/metadata/writecache_manip.c b/lib/metadata/writecache_manip.c
index 4f09e69cf..e24bcb76b 100644
--- a/lib/metadata/writecache_manip.c
+++ b/lib/metadata/writecache_manip.c
@@ -22,6 +22,7 @@
 #include "lib/metadata/lv_alloc.h"
 #include "lib/activate/activate.h"
 #include "lib/config/defaults.h"
+#include "lib/datastruct/str_list.h"
 
 int lv_is_writecache_origin(const struct logical_volume *lv)
 {
@@ -394,3 +395,72 @@ int lv_detach_writecache_cachevol(struct logical_volume *lv, int noflush)
 		return _lv_detach_writecache_cachevol_inactive(lv, noflush);
 }
 
+static int _writecache_setting_str_list_add(const char *field, uint64_t val, char *val_str, struct dm_list *result, struct dm_pool *mem)
+{
+	char buf[128];
+	char *list_item;
+	int len;
+
+	if (val_str) {
+		if (dm_snprintf(buf, sizeof(buf), "%s=%s", field, val_str) < 0)
+			return_0;
+	} else {
+		if (dm_snprintf(buf, sizeof(buf), "%s=%llu", field, (unsigned long long)val) < 0)
+			return_0;
+	}
+
+	len = strlen(buf) + 1;
+
+	if (!(list_item = dm_pool_zalloc(mem, len)))
+		return_0;
+
+	memcpy(list_item, buf, len);
+
+	if (!str_list_add_no_dup_check(mem, result, list_item))
+		return_0;
+
+	return 1;
+}
+
+int writecache_settings_to_str_list(struct writecache_settings *settings, struct dm_list *result, struct dm_pool *mem)
+{
+	int errors = 0;
+
+	if (settings->high_watermark_set)
+		if (!_writecache_setting_str_list_add("high_watermark", settings->high_watermark, NULL, result, mem))
+			errors++;
+
+	if (settings->low_watermark_set)
+		if (!_writecache_setting_str_list_add("low_watermark", settings->low_watermark, NULL, result, mem))
+			errors++;
+
+	if (settings->writeback_jobs_set)
+		if (!_writecache_setting_str_list_add("writeback_jobs", settings->writeback_jobs, NULL, result, mem))
+			errors++;
+
+	if (settings->autocommit_blocks_set)
+		if (!_writecache_setting_str_list_add("autocommit_blocks", settings->autocommit_blocks, NULL, result, mem))
+			errors++;
+
+	if (settings->autocommit_time_set)
+		if (!_writecache_setting_str_list_add("autocommit_time", settings->autocommit_time, NULL, result, mem))
+			errors++;
+
+	if (settings->fua_set)
+		if (!_writecache_setting_str_list_add("fua", (uint64_t)settings->fua, NULL, result, mem))
+			errors++;
+
+	if (settings->nofua_set)
+		if (!_writecache_setting_str_list_add("nofua", (uint64_t)settings->nofua, NULL, result, mem))
+			errors++;
+
+	if (settings->new_key && settings->new_val)
+		if (!_writecache_setting_str_list_add(settings->new_key, 0, settings->new_val, result, mem))
+			errors++;
+
+	if (errors)
+		log_warn("Failed to create list of writecache settings.");
+
+	return 1;
+}
+
diff --git a/lib/report/report.c b/lib/report/report.c
index e1c630576..268bed61b 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1430,6 +1430,16 @@ static int _cache_settings_disp(struct dm_report *rh, struct dm_pool *mem,
 	struct _str_list_append_baton baton;
 	struct dm_list dummy_list; /* dummy list to display "nothing" */
 
+	if (seg_is_writecache(seg)) {
+		if (!(result = str_list_create(mem)))
+			return_0;
+
+		if (!writecache_settings_to_str_list(&seg->writecache_settings, result, mem))
+			return_0;
+
+		return _field_set_string_list(rh, field, result, private, 0, NULL);
+	}
+
 	if (seg_is_cache(seg) && lv_is_cache_vol(seg->pool_lv))
 		setting_seg = seg;
 
diff --git a/tools/command-lines.in b/tools/command-lines.in
index ed3d0413a..98044a918 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -247,7 +247,7 @@ RULE: --profile not --detachprofile
 RULE: --metadataprofile not --detachprofile
 RULE: --minrecoveryrate --maxrecoveryrate and LV_raid
 RULE: --writebehind --writemostly and LV_raid1
-RULE: --cachemode --cachepolicy --cachesettings and LV_cache LV_cachepool
+RULE: --cachemode --cachepolicy --cachesettings and LV_cache LV_cachepool LV_writecache
 RULE: --errorwhenfull --discards --zero and LV_thinpool
 RULE: --permission not lv_is_external_origin lv_is_raid_metadata lv_is_raid_image LV_thinpool
 RULE: --alloc --contiguous --metadataprofile --permission --persistent --profile --readahead not lv_is_thick_origin
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 2d5bb32be..ba24e8239 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -606,6 +606,78 @@ static int _lvchange_persistent(struct cmd_context *cmd,
 	return 1;
 }
 
+static int _lvchange_writecache(struct cmd_context *cmd,
+			   struct logical_volume *lv,
+			   uint32_t *mr)
+{
+	struct writecache_settings settings = { 0 };
+	uint32_t block_size_sectors = 0;
+	struct lv_segment *seg = first_seg(lv);
+	int set_count = 0;
+
+	if (!get_writecache_settings(cmd, &settings, &block_size_sectors))
+		return_0;
+
+	if (block_size_sectors && (seg->writecache_block_size != (block_size_sectors * 512))) {
+		log_error("Cannot change existing block size %u bytes.", seg->writecache_block_size);
+		return 0;
+	}
+
+	if (settings.high_watermark_set) {
+		seg->writecache_settings.high_watermark_set = settings.high_watermark_set;
+		seg->writecache_settings.high_watermark = settings.high_watermark;
+		set_count++;
+	}
+	if (settings.low_watermark_set) {
+		seg->writecache_settings.low_watermark_set = settings.low_watermark_set;
+		seg->writecache_settings.low_watermark = settings.low_watermark;
+		set_count++;
+	}
+	if (settings.writeback_jobs_set) {
+		seg->writecache_settings.writeback_jobs_set = settings.writeback_jobs_set;
+		seg->writecache_settings.writeback_jobs = settings.writeback_jobs;
+		set_count++;
+	}
+	if (settings.autocommit_blocks_set) {
+		seg->writecache_settings.autocommit_blocks_set = settings.autocommit_blocks_set;
+		seg->writecache_settings.autocommit_blocks = settings.autocommit_blocks;
+		set_count++;
+	}
+	if (settings.autocommit_time_set) {
+		seg->writecache_settings.autocommit_time_set = settings.autocommit_time_set;
+		seg->writecache_settings.autocommit_time = settings.autocommit_time;
+		set_count++;
+	}
+	if (settings.fua_set) {
+		seg->writecache_settings.fua_set = settings.fua_set;
+		seg->writecache_settings.fua = settings.fua;
+		set_count++;
+	}
+	if (settings.nofua_set) {
+		seg->writecache_settings.nofua_set = settings.nofua_set;
+		seg->writecache_settings.nofua = settings.nofua;
+		set_count++;
+	}
+
+	if (!set_count) {
+		/*
+		 * Empty settings can be used to clear all current settings,
+		 * lvchange --cachesettings "" vg/lv
+		 */
+		if (!arg_count(cmd, yes_ARG) &&
+		    yes_no_prompt("Clear all writecache settings? ") == 'n') {
+			log_print("No settings changed.");
+			return 1;
+		}
+		memset(&seg->writecache_settings, 0, sizeof(struct writecache_settings));
+	}
+
+	/* Request caller to commit and reload metadata */
+	*mr |= MR_RELOAD;
+
+	return 1;
+}
+
 static int _lvchange_cache(struct cmd_context *cmd,
 			   struct logical_volume *lv,
 			   uint32_t *mr)
@@ -619,6 +691,9 @@ static int _lvchange_cache(struct cmd_context *cmd,
 	int r = 0, is_clean;
 	uint32_t chunk_size = 0; /* FYI: lvchange does NOT support its change */
 
+	if (lv_is_writecache(lv))
+		return _lvchange_writecache(cmd, lv, mr);
+
 	seg = first_seg(lv);
 
 	if (seg_is_cache(seg) && lv_is_cache_vol(seg->pool_lv))
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 7935eb74e..757e708ff 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -5389,157 +5389,6 @@ static int _writecache_zero(struct cmd_context *cmd, struct logical_volume *lv)
 	return ret;
 }
 
-static int _get_one_writecache_setting(struct cmd_context *cmd, struct writecache_settings *settings,
-				       char *key, char *val, uint32_t *block_size_sectors)
-{
-	/* special case: block_size is not a setting but is set with the --cachesettings option */
-	if (!strncmp(key, "block_size", strlen("block_size"))) {
-		uint32_t block_size = 0;
-		if (sscanf(val, "%u", &block_size) != 1)
-			goto_bad;
-		if (block_size == 512)
-			*block_size_sectors = 1;
-		else if (block_size == 4096)
-			*block_size_sectors = 8;
-		else
-			goto_bad;
-		return 1;
-	}
-
-	if (!strncmp(key, "high_watermark", strlen("high_watermark"))) {
-		if (sscanf(val, "%llu", (unsigned long long *)&settings->high_watermark) != 1)
-			goto_bad;
-		if (settings->high_watermark > 100)
-			goto_bad;
-		settings->high_watermark_set = 1;
-		return 1;
-	}
-
-	if (!strncmp(key, "low_watermark", strlen("low_watermark"))) {
-		if (sscanf(val, "%llu", (unsigned long long *)&settings->low_watermark) != 1)
-			goto_bad;
-		if (settings->low_watermark > 100)
-			goto_bad;
-		settings->low_watermark_set = 1;
-		return 1;
-	}
-
-	if (!strncmp(key, "writeback_jobs", strlen("writeback_jobs"))) {
-		if (sscanf(val, "%llu", (unsigned long long *)&settings->writeback_jobs) != 1)
-			goto_bad;
-		settings->writeback_jobs_set = 1;
-		return 1;
-	}
-
-	if (!strncmp(key, "autocommit_blocks", strlen("autocommit_blocks"))) {
-		if (sscanf(val, "%llu", (unsigned long long *)&settings->autocommit_blocks) != 1)
-			goto_bad;
-		settings->autocommit_blocks_set = 1;
-		return 1;
-	}
-
-	if (!strncmp(key, "autocommit_time", strlen("autocommit_time"))) {
-		if (sscanf(val, "%llu", (unsigned long long *)&settings->autocommit_time) != 1)
-			goto_bad;
-		settings->autocommit_time_set = 1;
-		return 1;
-	}
-
-	if (!strncmp(key, "fua", strlen("fua"))) {
-		if (settings->nofua_set) {
-			log_error("Setting fua and nofua cannot both be set.");
-			return 0;
-		}
-		if (sscanf(val, "%u", &settings->fua) != 1)
-			goto_bad;
-		settings->fua_set = 1;
-		return 1;
-	}
-
-	if (!strncmp(key, "nofua", strlen("nofua"))) {
-		if (settings->fua_set) {
-			log_error("Setting fua and nofua cannot both be set.");
-			return 0;
-		}
-		if (sscanf(val, "%u", &settings->nofua) != 1)
-			goto_bad;
-		settings->nofua_set = 1;
-		return 1;
-	}
-
-	if (settings->new_key) {
-		log_error("Setting %s is not recognized. Only one unrecognized setting is allowed.", key);
-		return 0;
-	}
-
-	log_warn("Unrecognized writecache setting \"%s\" may cause activation failure.", key);
-	if (yes_no_prompt("Use unrecognized writecache setting? [y/n]: ") == 'n') {
-		log_error("Aborting writecache conversion.");
-		return 0;
-	}
-
-	log_warn("Using unrecognized writecache setting: %s = %s.", key, val);
-
-	settings->new_key = dm_pool_strdup(cmd->mem, key);
-	settings->new_val = dm_pool_strdup(cmd->mem, val);
-	return 1;
-
- bad:
-	log_error("Invalid setting: %s", key);
-	return 0;
-}
-
-static int _get_writecache_settings(struct cmd_context *cmd, struct writecache_settings *settings,
-				    uint32_t *block_size_sectors)
-{
-	struct arg_value_group_list *group;
-	const char *str;
-	char key[64];
-	char val[64];
-	int num;
-	int pos;
-
-	/*
-	 * "grouped" means that multiple --cachesettings options can be used.
-	 * Each option is also allowed to contain multiple key = val pairs.
-	 */
-
-	dm_list_iterate_items(group, &cmd->arg_value_groups) {
-		if (!grouped_arg_is_set(group->arg_values, cachesettings_ARG))
-			continue;
-
-		if (!(str = grouped_arg_str_value(group->arg_values, cachesettings_ARG, NULL)))
-			break;
-
-		pos = 0;
-
-		while (pos < strlen(str)) {
-			/* scan for "key1=val1 key2 = val2  key3= val3" */
-
-			memset(key, 0, sizeof(key));
-			memset(val, 0, sizeof(val));
-
-			if (sscanf(str + pos, " %63[^=]=%63s %n", key, val, &num) != 2) {
-				log_error("Invalid setting at: %s", str+pos);
-				return 0;
-			}
-
-			pos += num;
-
-			if (!_get_one_writecache_setting(cmd, settings, key, val, block_size_sectors))
-				return_0;
-		}
-	}
-
-	if (settings->high_watermark_set && settings->low_watermark_set &&
-	    (settings->high_watermark <= settings->low_watermark)) {
-		log_error("High watermark must be greater than low watermark.");
-		return 0;
-	}
-
-	return 1;
-}
-
 static struct logical_volume *_lv_writecache_create(struct cmd_context *cmd,
 					    struct logical_volume *lv,
 					    struct logical_volume *lv_fast,
@@ -5642,7 +5491,7 @@ static int _lvconvert_writecache_attach_single(struct cmd_context *cmd,
 	memset(&settings, 0, sizeof(settings));
 	block_size_sectors = DEFAULT_WRITECACHE_BLOCK_SIZE_SECTORS;
 
-	if (!_get_writecache_settings(cmd, &settings, &block_size_sectors)) {
+	if (!get_writecache_settings(cmd, &settings, &block_size_sectors)) {
 		log_error("Invalid writecache settings.");
 		goto bad;
 	}
diff --git a/tools/toollib.c b/tools/toollib.c
index 89b637407..94e6e6c44 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1184,6 +1184,156 @@ out:
 	return ok;
 }
 
+static int _get_one_writecache_setting(struct cmd_context *cmd, struct writecache_settings *settings,
+				       char *key, char *val, uint32_t *block_size_sectors)
+{
+	/* special case: block_size is not a setting but is set with the --cachesettings option */
+	if (!strncmp(key, "block_size", strlen("block_size"))) {
+		uint32_t block_size = 0;
+		if (sscanf(val, "%u", &block_size) != 1)
+			goto_bad;
+		if (block_size == 512)
+			*block_size_sectors = 1;
+		else if (block_size == 4096)
+			*block_size_sectors = 8;
+		else
+			goto_bad;
+		return 1;
+	}
+
+	if (!strncmp(key, "high_watermark", strlen("high_watermark"))) {
+		if (sscanf(val, "%llu", (unsigned long long *)&settings->high_watermark) != 1)
+			goto_bad;
+		if (settings->high_watermark > 100)
+			goto_bad;
+		settings->high_watermark_set = 1;
+		return 1;
+	}
+
+	if (!strncmp(key, "low_watermark", strlen("low_watermark"))) {
+		if (sscanf(val, "%llu", (unsigned long long *)&settings->low_watermark) != 1)
+			goto_bad;
+		if (settings->low_watermark > 100)
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
+			return 0;
+		}
+		if (sscanf(val, "%u", &settings->fua) != 1)
+			goto_bad;
+		settings->fua_set = 1;
+		return 1;
+	}
+
+	if (!strncmp(key, "nofua", strlen("nofua"))) {
+		if (settings->fua_set) {
+			log_error("Setting fua and nofua cannot both be set.");
+			return 0;
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
+		return 0;
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
+int get_writecache_settings(struct cmd_context *cmd, struct writecache_settings *settings,
+			    uint32_t *block_size_sectors)
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
+				return 0;
+			}
+
+			pos += num;
+
+			if (!_get_one_writecache_setting(cmd, settings, key, val, block_size_sectors))
+				return_0;
+		}
+	}
+
+	if (settings->high_watermark_set && settings->low_watermark_set &&
+	    (settings->high_watermark <= settings->low_watermark)) {
+		log_error("High watermark must be greater than low watermark.");
+		return 0;
+	}
+
+	return 1;
+}
 
 /* FIXME move to lib */
 static int _pv_change_tag(struct physical_volume *pv, const char *tag, int addtag)
diff --git a/tools/toollib.h b/tools/toollib.h
index 53a5e5b4f..f3a60fbc4 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -217,6 +217,9 @@ int get_cache_params(struct cmd_context *cmd,
 		     const char **name,
 		     struct dm_config_tree **settings);
 
+int get_writecache_settings(struct cmd_context *cmd, struct writecache_settings *settings,
+                            uint32_t *block_size_sectors);
+
 int change_tag(struct cmd_context *cmd, struct volume_group *vg,
 	       struct logical_volume *lv, struct physical_volume *pv, int arg);
 


