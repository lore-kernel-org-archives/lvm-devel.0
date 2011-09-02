From: agk@sourceware.org <agk@sourceware.org>
Date: 2 Sep 2011 01:32:11 -0000
Subject: LVM2 tools/lvmcmdline.c lib/commands/toolconte ...
Message-ID: <20110902013211.28181.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-09-02 01:32:09

Modified files:
	tools          : lvmcmdline.c 
	lib/commands   : toolcontext.c toolcontext.h 
	lib/config     : config.c config.h 
	libdm          : libdevmapper.h libdm-config.c 

Log message:
	Move cascade inside libdm etc.
	Makes dumpconfig whole-section output wrong in a different way from before,
	but we should be able to merge cft_cmdline properly into cmd->cft now and
	remove cascade.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.146&r2=1.147
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.132&r2=1.133
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.h.diff?cvsroot=lvm2&r1=1.45&r2=1.46
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.c.diff?cvsroot=lvm2&r1=1.104&r2=1.105
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/config.h.diff?cvsroot=lvm2&r1=1.36&r2=1.37
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.148&r2=1.149
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-config.c.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/tools/lvmcmdline.c	2011/08/04 14:54:48	1.146
+++ LVM2/tools/lvmcmdline.c	2011/09/02 01:32:08	1.147
@@ -996,6 +996,7 @@
 {
 	int ret = 0;
 	int locking_type;
+	struct dm_config_tree *old_cft;
 
 	init_error_message_produced(0);
 
@@ -1020,8 +1021,7 @@
 	set_cmd_name(cmd->command->name);
 
 	if (arg_count(cmd, config_ARG))
-		if (override_config_tree_from_string(cmd,
-		    arg_str_value(cmd, config_ARG, ""))) {
+		if (override_config_tree_from_string(cmd, arg_str_value(cmd, config_ARG, ""))) {
 			ret = EINVALID_CMD_LINE;
 			goto_out;
 		}
@@ -1029,10 +1029,9 @@
 	if (arg_count(cmd, config_ARG) || !cmd->config_valid || config_files_changed(cmd)) {
 		/* Reinitialise various settings inc. logging, filters */
 		if (!refresh_toolcontext(cmd)) {
-			if (cmd->cft_override) {
-				destroy_config_tree(cmd->cft_override);
-				cmd->cft_override = NULL;
-			}
+			old_cft = remove_overridden_config_tree(cmd);
+			if (old_cft)
+				dm_config_destroy(old_cft);
 			log_error("Updated config file invalid. Aborting.");
 			return ECMD_FAILED;
 		}
@@ -1081,9 +1080,8 @@
 		lvmcache_destroy(cmd, 1);
 	}
 
-	if (cmd->cft_override) {
-		destroy_config_tree(cmd->cft_override);
-		cmd->cft_override = NULL;
+	if ((old_cft = remove_overridden_config_tree(cmd))) {
+		dm_config_destroy(old_cft);
 		/* Move this? */
 		if (!refresh_toolcontext(cmd))
 			stack;
--- LVM2/lib/commands/toolcontext.c	2011/09/01 13:25:50	1.132
+++ LVM2/lib/commands/toolcontext.c	2011/09/02 01:32:09	1.133
@@ -558,13 +558,13 @@
 	return 1;
 }
 
-static int _merge_config_files(struct cmd_context *cmd)
+struct dm_config_tree *_merge_config_files(struct cmd_context *cmd, struct dm_config_tree *cft)
 {
 	struct config_tree_list *cfl;
 
 	/* Replace temporary duplicate copy of lvm.conf */
-	if (cmd->cft->root) {
-		if (!(cmd->cft = dm_config_create(NULL, 0))) {
+	if (cft->root) {
+		if (!(cft = dm_config_create(NULL, 0))) {
 			log_error("Failed to create config tree");
 			return 0;
 		}
@@ -572,11 +572,11 @@
 
 	dm_list_iterate_items(cfl, &cmd->config_files) {
 		/* Merge all config trees into cmd->cft using merge/tag rules */
-		if (!merge_config_tree(cmd, cmd->cft, cfl->cft))
+		if (!merge_config_tree(cmd, cft, cfl->cft))
 			return_0;
 	}
 
-	return 1;
+	return cft;
 }
 
 static void _destroy_tags(struct cmd_context *cmd)
@@ -600,9 +600,19 @@
 	return 0;
 }
 
-static void _destroy_tag_configs(struct cmd_context *cmd)
+/*
+ * Returns cmdline config_tree that overrides all others, if present.
+ */
+static struct dm_config_tree *_destroy_tag_configs(struct cmd_context *cmd)
 {
 	struct config_tree_list *cfl;
+	struct dm_config_tree *cft_cmdline = NULL, *cft;
+
+	cft = dm_config_remove_cascaded_tree(cmd->cft);
+	if (cft) {
+		cft_cmdline = cmd->cft;
+		cmd->cft = cft;
+	}
 
 	dm_list_iterate_items(cfl, &cmd->config_files) {
 		if (cfl->cft == cmd->cft)
@@ -616,6 +626,8 @@
 	}
 
 	dm_list_init(&cmd->config_files);
+
+	return cft_cmdline;
 }
 
 static int _init_dev_cache(struct cmd_context *cmd)
@@ -1285,7 +1297,7 @@
 	if (!_init_tag_configs(cmd))
 		goto_out;
 
-	if (!_merge_config_files(cmd))
+	if (!(cmd->cft = _merge_config_files(cmd, cmd->cft)))
 		goto_out;
 
 	if (!_process_config(cmd))
@@ -1397,6 +1409,8 @@
 
 int refresh_toolcontext(struct cmd_context *cmd)
 {
+	struct dm_config_tree *cft_cmdline, *cft_tmp;
+
 	log_verbose("Reloading config files");
 
 	/*
@@ -1415,7 +1429,7 @@
 	}
 	dev_cache_exit();
 	_destroy_tags(cmd);
-	_destroy_tag_configs(cmd);
+	cft_cmdline = _destroy_tag_configs(cmd);
 
 	cmd->config_valid = 0;
 
@@ -1424,17 +1438,31 @@
 	if (!_init_lvm_conf(cmd))
 		return 0;
 
+	/* Temporary duplicate cft pointer holding lvm.conf - replaced later */
+	cft_tmp = cmd->cft;
+	if (cft_cmdline)
+		cmd->cft = dm_config_insert_cascaded_tree(cft_cmdline, cft_tmp);
+
+	/* Uses cmd->cft i.e. cft_cmdline + lvm.conf */
 	_init_logging(cmd);
 
-	if (!_init_tags(cmd, cmd->cft))
+	/* Init tags from lvm.conf. */
+	if (!_init_tags(cmd, cft_tmp))
 		return 0;
 
+	/* Doesn't change cmd->cft */
 	if (!_init_tag_configs(cmd))
 		return 0;
 
-	if (!_merge_config_files(cmd))
+	/* Merge all the tag config files with lvm.conf, returning a
+	 * fresh cft pointer in place of cft_tmp. */
+	if (!(cmd->cft = _merge_config_files(cmd, cft_tmp)))
 		return 0;
 
+	/* Finally we can make the proper, fully-merged, cmd->cft */
+	if (cft_cmdline)
+		cmd->cft = dm_config_insert_cascaded_tree(cft_cmdline, cmd->cft);
+
 	if (!_process_config(cmd))
 		return 0;
 
@@ -1464,6 +1492,8 @@
 
 void destroy_toolcontext(struct cmd_context *cmd)
 {
+	struct dm_config_tree *cft_cmdline;
+
 	if (cmd->dump_filter)
 		persistent_filter_dump(cmd->filter, 1);
 
@@ -1479,7 +1509,8 @@
 		dm_pool_destroy(cmd->mem);
 	dev_cache_exit();
 	_destroy_tags(cmd);
-	_destroy_tag_configs(cmd);
+	if ((cft_cmdline = _destroy_tag_configs(cmd)))
+		dm_config_destroy(cft_cmdline);
 	if (cmd->libmem)
 		dm_pool_destroy(cmd->libmem);
 
--- LVM2/lib/commands/toolcontext.h	2011/08/30 14:55:16	1.45
+++ LVM2/lib/commands/toolcontext.h	2011/09/02 01:32:09	1.46
@@ -93,7 +93,6 @@
 	struct dm_list config_files;
 	int config_valid;
 	struct dm_config_tree *cft;
-	struct dm_config_tree *cft_override;
 	struct config_info default_settings;
 	struct config_info current_settings;
 
--- LVM2/lib/config/config.c	2011/09/01 21:04:14	1.104
+++ LVM2/lib/config/config.c	2011/09/02 01:32:09	1.105
@@ -40,14 +40,34 @@
 	dm_config_destroy(cft);
 }
 
+/*
+ * Returns config tree if it was removed.
+ */
+struct dm_config_tree *remove_overridden_config_tree(struct cmd_context *cmd)
+{
+	struct dm_config_tree *old_cft = cmd->cft;
+	struct dm_config_tree *cft = dm_config_remove_cascaded_tree(cmd->cft);
+
+	if (!cft)
+		return NULL;
+
+	cmd->cft = cft;
+
+	return old_cft;
+}
+
 int override_config_tree_from_string(struct cmd_context *cmd,
 				     const char *config_settings)
 {
-	if (!(cmd->cft_override = dm_config_from_string(config_settings))) {
+	struct dm_config_tree *cft_new;
+
+	if (!(cft_new = dm_config_from_string(config_settings))) {
 		log_error("Failed to set overridden configuration entries.");
 		return 1;
 	}
 
+	cmd->cft = dm_config_insert_cascaded_tree(cft_new, cmd->cft);
+
 	return 0;
 }
 
@@ -114,7 +134,7 @@
 
 int read_config_file(struct dm_config_tree *cft)
 {
-	const char *filename;
+	const char *filename = NULL;
 	struct device *dev = dm_config_get_custom(cft);
 	struct stat info;
 	int r;
@@ -122,6 +142,10 @@
 	if (!dm_config_check_file(cft, &filename, &info))
 		return_0;
 
+	/* Nothing to do.  E.g. empty file. */
+	if (!filename)
+		return 1;
+
 	if (!dev) {
 		if (!(dev = dev_create_file(filename, NULL, NULL, 1)))
 			return_0;
@@ -142,51 +166,38 @@
 	return r;
 }
 
-// FIXME AGK Move to override_config_tree_from_string before next release
-static struct dm_config_tree *_setup_context_tree(struct cmd_context *cmd)
-{
-	struct dm_config_tree *cft = cmd->cft_override;
-
-	if (cft)
-		cft->cascade = cmd->cft;
-	else
-		cft = cmd->cft;
-
-	return cft;
-}
-
 const struct dm_config_node *find_config_tree_node(struct cmd_context *cmd,
 						   const char *path)
 {
-	return dm_config_tree_find_node(_setup_context_tree(cmd), path);
+	return dm_config_tree_find_node(cmd->cft, path);
 }
 
 const char *find_config_tree_str(struct cmd_context *cmd,
 				 const char *path, const char *fail)
 {
-	return dm_config_tree_find_str(_setup_context_tree(cmd), path, fail);
+	return dm_config_tree_find_str(cmd->cft, path, fail);
 }
 
 int find_config_tree_int(struct cmd_context *cmd, const char *path,
 			 int fail)
 {
-	return dm_config_tree_find_int(_setup_context_tree(cmd), path, fail);
+	return dm_config_tree_find_int(cmd->cft, path, fail);
 }
 
 int64_t find_config_tree_int64(struct cmd_context *cmd, const char *path, int64_t fail)
 {
-	return dm_config_tree_find_int64(_setup_context_tree(cmd), path, fail);
+	return dm_config_tree_find_int64(cmd->cft, path, fail);
 }
 
 float find_config_tree_float(struct cmd_context *cmd, const char *path,
 			     float fail)
 {
-	return dm_config_tree_find_float(_setup_context_tree(cmd), path, fail);
+	return dm_config_tree_find_float(cmd->cft, path, fail);
 }
 
 int find_config_tree_bool(struct cmd_context *cmd, const char *path, int fail)
 {
-	return dm_config_tree_find_bool(_setup_context_tree(cmd), path, fail);
+	return dm_config_tree_find_bool(cmd->cft, path, fail);
 }
 
 /* Insert cn2 after cn1 */
--- LVM2/lib/config/config.h	2011/08/30 14:55:16	1.36
+++ LVM2/lib/config/config.h	2011/09/02 01:32:09	1.37
@@ -24,6 +24,7 @@
 int override_config_tree_from_string(struct cmd_context *cmd,
 				     const char *config_settings);
 void destroy_config_tree(struct dm_config_tree *cft);
+struct dm_config_tree *remove_overridden_config_tree(struct cmd_context *cmd);
 
 typedef uint32_t (*checksum_fn_t) (uint32_t initial, const uint8_t *buf, uint32_t size);
 
--- LVM2/libdm/libdevmapper.h	2011/09/01 21:04:14	1.148
+++ LVM2/libdm/libdevmapper.h	2011/09/02 01:32:09	1.149
@@ -1248,6 +1248,7 @@
 	struct dm_config_value *v;
 };
 
+/* FIXME Move cascade to dm_config_node and remove this struct */
 struct dm_config_tree {
 	struct dm_config_node *root;
 	struct dm_config_tree *cascade;
@@ -1263,6 +1264,17 @@
 
 void dm_config_set_custom(struct dm_config_tree *cft, void *custom);
 
+/*
+ * If there's a cascaded dm_config_tree, remove the top layer
+ * and return the layer below.  Otherwise return NULL.
+ */
+struct dm_config_tree *dm_config_remove_cascaded_tree(struct dm_config_tree *cft);
+
+/*
+ * When searching, first_cft is checked before second_cft.
+ */
+struct dm_config_tree *dm_config_insert_cascaded_tree(struct dm_config_tree *first_cft, struct dm_config_tree *second_cft);
+
 void dm_config_destroy(struct dm_config_tree *cft);
 
 int dm_config_write(struct dm_config_tree *cft, const char *file,
--- LVM2/libdm/libdm-config.c	2011/09/01 21:04:14	1.5
+++ LVM2/libdm/libdm-config.c	2011/09/02 01:32:09	1.6
@@ -159,6 +159,29 @@
 	dm_pool_destroy(c->mem);
 }
 
+/*
+ * If there's a cascaded dm_config_tree, remove and return it, otherwise
+ * return NULL.
+ */
+struct dm_config_tree *dm_config_remove_cascaded_tree(struct dm_config_tree *cft)
+{
+	struct dm_config_tree *second_cft = cft->cascade;
+
+	cft->cascade = NULL;
+
+	return second_cft;
+}
+
+/*
+ * When searching, first_cft is checked before second_cft.
+ */
+struct dm_config_tree *dm_config_insert_cascaded_tree(struct dm_config_tree *first_cft, struct dm_config_tree *second_cft)
+{
+	first_cft->cascade = second_cft;
+
+	return first_cft;
+}
+
 int dm_config_parse(struct dm_config_tree *cft, const char *start, const char *end)
 {
 	/* TODO? if (start == end) return 1; */
@@ -196,14 +219,16 @@
 	return cft;
 }
 
+/*
+ * Doesn't populate filename if the file is empty.
+ */
 int dm_config_check_file(struct dm_config_tree *cft, const char **filename, struct stat *info)
 {
 	struct cs *c = (struct cs *) cft;
 	struct stat _info;
+
 	if (!info)
 		info = &_info;
-	if (filename)
-		*filename = c->filename;
 
 	if (stat(c->filename, info)) {
 		log_sys_error("stat", c->filename);
@@ -218,12 +243,13 @@
 	}
 
 	c->exists = 1;
+	c->timestamp = info->st_ctime;
+	c->st_size = info->st_size;
 
 	if (info->st_size == 0)
 		log_verbose("%s is empty", c->filename);
-
-	c->timestamp = info->st_ctime;
-	c->st_size = info->st_size;
+	else if (filename)
+		*filename = c->filename;
 
 	return 1;
 }


