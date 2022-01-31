From: David Teigland <teigland@sourceware.org>
Date: Mon, 31 Jan 2022 23:02:53 +0000 (GMT)
Subject: main - Revert "writecache: handle options from lvm.conf"
Message-ID: <20220131230253.97B833858D39@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ffa07c8e398232150794767e05b95893c7b737b6
Commit:        ffa07c8e398232150794767e05b95893c7b737b6
Parent:        208af8db2afbf6941a7c71d8537e9ec3f60f4e79
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Jan 31 15:18:46 2022 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Jan 31 16:54:40 2022 -0600

Revert "writecache: handle options from lvm.conf"

This reverts commit c6639056e0bb2fc5f072b2c0d6bb629ad17eee6e.

Next commit restores this feature.
---
 WHATS_NEW       |   1 -
 tools/toollib.c | 276 +++++++++++++++++++++++++-------------------------------
 2 files changed, 121 insertions(+), 156 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 16235514e..e2f6e166b 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,6 +1,5 @@
 Version 2.03.15 - 
 ===================================
-  Improve support for metadata profiles for --type writecache.
   Use cache or active DM device when available with new kernels.
   Introduce function to utilize UUIDs from DM_DEVICE_LIST.
   Increase some hash table size to better support large device sets.
diff --git a/tools/toollib.c b/tools/toollib.c
index 4a131aea8..c23f55c07 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1200,136 +1200,117 @@ out:
 	return ok;
 }
 
-static int _get_writecache_setting(struct cmd_context *cmd,
-				   struct dm_config_node *cn,
-				   struct writecache_settings *settings,
-				   uint32_t *block_size_sectors)
+static int _get_one_writecache_setting(struct cmd_context *cmd, struct writecache_settings *settings,
+				       char *key, char *val, uint32_t *block_size_sectors)
 {
-	char val[32];
-
-	/* Try to find our section for given policy */
-	for (; cn; cn = cn->sib) {
-		/* special case: block_size is not a setting but is set with the --cachesettings option */
-		if (!strcmp(cn->key, "block_size")) {
-			if (cn->v->type != DM_CFG_INT)
-				goto_bad;
-			if (cn->v->v.i == 512)
-				*block_size_sectors = 1;
-			else if (cn->v->v.i == 4096)
-				*block_size_sectors = 8;
-			else
-				goto_bad;
-
-		} else if (!strcmp(cn->key, "high_watermark")) {
-			if (cn->v->type != DM_CFG_INT)
-				goto_bad;
-			settings->high_watermark = (uint64_t)cn->v->v.i;
-			if (settings->high_watermark > 100)
-				goto_bad;
-			settings->high_watermark_set = 1;
-
-		} else if (!strcmp(cn->key, "low_watermark")) {
-			if (cn->v->type != DM_CFG_INT)
-				goto_bad;
-			settings->low_watermark = (uint64_t)cn->v->v.i;
-			if (settings->low_watermark > 100)
-				goto_bad;
-			settings->low_watermark_set = 1;
-
-		} else if (!strcmp(cn->key, "writeback_jobs")) {
-			if (cn->v->type != DM_CFG_INT)
-				goto_bad;
-			settings->writeback_jobs = (uint64_t)cn->v->v.i;
-			settings->writeback_jobs_set = 1;
-
-		} else if (!strcmp(cn->key, "autocommit_blocks")) {
-			if (cn->v->type != DM_CFG_INT)
-				goto_bad;
-			settings->autocommit_blocks = (uint64_t)cn->v->v.i;
-			settings->autocommit_blocks_set = 1;
-
-		} else if (!strcmp(cn->key, "autocommit_time")) {
-			if (cn->v->type != DM_CFG_INT)
-				goto_bad;
-			settings->autocommit_time = (uint64_t)cn->v->v.i;
-			settings->autocommit_time_set = 1;
-
-		} else if (!strcmp(cn->key, "fua")) {
-			if (settings->nofua_set) {
-				log_error("Setting fua and nofua cannot both be set.");
-				return 0;
-			}
-			if (cn->v->type != DM_CFG_INT)
-				goto_bad;
-			settings->fua = (unsigned)cn->v->v.i;
-			settings->fua_set = 1;
-
-		} else if (!strcmp(cn->key, "nofua")) {
-			if (settings->fua_set) {
-				log_error("Setting fua and nofua cannot both be set.");
-				return 0;
-			}
-			if (cn->v->type != DM_CFG_INT)
-				goto_bad;
-			settings->nofua = (unsigned)cn->v->v.i;
-			settings->nofua_set = 1;
-
-		} else if (!strcmp(cn->key, "cleaner")) {
-			if (cn->v->type != DM_CFG_INT)
-				goto_bad;
-			settings->cleaner = (unsigned) cn->v->v.i;
-			settings->cleaner_set = 1;
-
-		} else if (!strcmp(cn->key, "max_age")) {
-			if (cn->v->type != DM_CFG_INT)
-				goto_bad;
-			settings->max_age = (unsigned) cn->v->v.i;
-			settings->max_age_set = 1;
-
-		} else if (settings->new_key) {
-			log_error("Setting %s is not recognized. Only one unrecognized setting is allowed.", cn->key);
-			return 0;
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
 
-		} else {
-			log_warn("Unrecognized writecache setting \"%s\" may cause activation failure.", cn->key);
-			if (yes_no_prompt("Use unrecognized writecache setting? [y/n]: ") == 'n') {
-				log_error("Aborting writecache conversion.");
-				return 0;
-			}
+	if (!strncmp(key, "high_watermark", strlen("high_watermark"))) {
+		if (sscanf(val, "%llu", (unsigned long long *)&settings->high_watermark) != 1)
+			goto_bad;
+		if (settings->high_watermark > 100)
+			goto_bad;
+		settings->high_watermark_set = 1;
+		return 1;
+	}
 
-			settings->new_key = dm_pool_strdup(cmd->mem, cn->key);
-			switch (cn->v->type) {
-			case DM_CFG_INT:
-				snprintf(val, sizeof(val), FMTd64, cn->v->v.i);
-				settings->new_val = dm_pool_strdup(cmd->mem, val);
-				break;
-			case DM_CFG_STRING:
-				settings->new_val = dm_pool_strdup(cmd->mem, cn->v->v.str);
-				break;
-			default:
-				log_error("Unsupported unrecognized setting %s value.", cn->key);
-				return 0;
-			}
-			if (!settings->new_key || !settings->new_val) {
-				log_error("Failed to copy unrecognized setting %s.", cn->key);
-				return 0;
-			}
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
 
-			log_warn("Using unrecognized writecache setting: %s = %s.",
-				 settings->new_key, settings->new_val);
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
 		}
+		if (sscanf(val, "%u", &settings->fua) != 1)
+			goto_bad;
+		settings->fua_set = 1;
+		return 1;
 	}
 
-	if (settings->high_watermark_set && settings->low_watermark_set &&
-	    (settings->high_watermark <= settings->low_watermark)) {
-		log_error("High watermark must be greater than low watermark.");
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
+	if (!strncmp(key, "cleaner", strlen("cleaner"))) {
+		if (sscanf(val, "%u", &settings->cleaner) != 1)
+			goto_bad;
+		settings->cleaner_set = 1;
+		return 1;
+	}
+
+	if (!strncmp(key, "max_age", strlen("max_age"))) {
+		if (sscanf(val, "%u", &settings->max_age) != 1)
+			goto_bad;
+		settings->max_age_set = 1;
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
 		return 0;
 	}
 
+	log_warn("Using unrecognized writecache setting: %s = %s.", key, val);
+
+	settings->new_key = dm_pool_strdup(cmd->mem, key);
+	settings->new_val = dm_pool_strdup(cmd->mem, val);
 	return 1;
 
-bad:
-	log_error("Invalid setting: %s", cn->key);
+ bad:
+	log_error("Invalid setting: %s", key);
 	return 0;
 }
 
@@ -1337,10 +1318,11 @@ int get_writecache_settings(struct cmd_context *cmd, struct writecache_settings
 			    uint32_t *block_size_sectors)
 {
 	struct arg_value_group_list *group;
-	struct dm_config_tree *result = NULL, *prev = NULL, *current = NULL;
-	const struct dm_config_node *cns, *cn;
-	int ok = 0;
 	const char *str;
+	char key[64];
+	char val[64];
+	int num;
+	int pos;
 
 	/*
 	 * "grouped" means that multiple --cachesettings options can be used.
@@ -1351,52 +1333,36 @@ int get_writecache_settings(struct cmd_context *cmd, struct writecache_settings
 		if (!grouped_arg_is_set(group->arg_values, cachesettings_ARG))
 			continue;
 
-		if (!(current = dm_config_create()))
-			goto_out;
-		if (prev)
-			current->cascade = prev;
-		prev = current;
-
 		if (!(str = grouped_arg_str_value(group->arg_values, cachesettings_ARG, NULL)))
 			break;
 
-		if (!dm_config_parse_without_dup_node_check(current, str, str + strlen(str)))
-			goto_out;
-	}
+		pos = 0;
 
-	if (current) {
-		if (!(result = dm_config_flatten(current)))
-			goto_out;
-		if (!_get_writecache_setting(cmd, result->root, settings, block_size_sectors))
-			goto_out;
+		while (pos < strlen(str)) {
+			/* scan for "key1=val1 key2 = val2  key3= val3" */
+
+			memset(key, 0, sizeof(key));
+			memset(val, 0, sizeof(val));
 
-	} else if ((cns = find_config_tree_node(cmd, allocation_cache_settings_CFG_SECTION, NULL))) {
-		/* Fallback to lvm.conf cache settings for 'writecache{}' */
-		/* TODO: support profiles */
-		for (cn = cns->child; cn; cn = cn->sib) {
-			if (!cn->child)
-				continue; /* Ignore section without settings */
+			if (sscanf(str + pos, " %63[^=]=%63s %n", key, val, &num) != 2) {
+				log_error("Invalid setting at: %s", str+pos);
+				return 0;
+			}
 
-			if (cn->v || strcmp(cn->key, "writecache") != 0)
-				continue; /* Ignore non-matching settings */
+			pos += num;
 
-			if (!_get_writecache_setting(cmd, cn->child, settings, block_size_sectors))
-				goto_out;
+			if (!_get_one_writecache_setting(cmd, settings, key, val, block_size_sectors))
+				return_0;
 		}
 	}
 
-	ok = 1;
-out:
-	if (result)
-		dm_config_destroy(result);
-
-	while (prev) {
-		current = prev->cascade;
-		dm_config_destroy(prev);
-		prev = current;
+	if (settings->high_watermark_set && settings->low_watermark_set &&
+	    (settings->high_watermark <= settings->low_watermark)) {
+		log_error("High watermark must be greater than low watermark.");
+		return 0;
 	}
 
-	return ok;
+	return 1;
 }
 
 /* FIXME move to lib */


