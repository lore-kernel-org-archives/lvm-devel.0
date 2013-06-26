From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 26 Jun 2013 14:55:42 +0000 (UTC)
Subject: dev-peter-config-profiles - config: add config_source_t type to identify configuration source
Message-ID: <20130626145542.00B7960F23@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6c2bda4b433c55e0af05124f5157977621b93f50
Commit:        6c2bda4b433c55e0af05124f5157977621b93f50
Parent:        e09cffe14e6710ba3bb3598a6719ff3b2d70a440
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jun 25 12:25:43 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jun 26 16:53:49 2013 +0200

config: add config_source_t type to identify configuration source

A helper type that helps with identification of the configuration source
which make handling the configuration cascade a bit easier, mainly
removing and adding configuration trees to cascade dynamically.

Currently, the possible types are:

  CONFIG_UNDEFINED - configuration is not defined yet (not initialized)
  CONFIG_FILE - one file configuration
  CONFIG_MERGED_FILES - configuration that is a result of merging more files into one
  CONFIG_STRING - configuration string typed on cmd line directly
  CONFIG_PROFILE - profile configuration (the new type of configuration, patches will follow...)

Also, generalize existing "remove_overridden_config_tree" to work with
configuration type identification in a cascade. Before, it was just
the CONFIG_STRING one we used. Now, we need some more to add in a
cascade (like the CONFIG_PROFILE). So, we have:

  struct dm_config_tree *remove_config_tree_by_source(struct cmd_context *cmd, config_source_t source);
  config_source_t config_get_source_type(struct dm_config_tree *cft);

... for removing the tree by its source type from the cascade and
simply getting the source type.
---
 lib/commands/toolcontext.c      |   76 +++++++++--------
 lib/config/config.c             |  174 ++++++++++++++++++++++++++++++--------
 lib/config/config.h             |   18 +++-
 lib/filters/filter-persistent.c |    6 +-
 lib/format_text/import.c        |    8 +-
 tools/lvmcmdline.c              |    4 +-
 6 files changed, 200 insertions(+), 86 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index e0da663..4299d8c 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -37,6 +37,7 @@
 #include "lvmetad.h"
 #include "dev-cache.h"
 #include "archiver.h"
+#include "assert.h"
 
 #ifdef HAVE_LIBDL
 #include "sharedlib.h"
@@ -528,19 +529,21 @@ static int _init_tags(struct cmd_context *cmd, struct dm_config_tree *cft)
 	return 1;
 }
 
-static struct dm_config_tree *_open_and_read_config_file(const char *config_file)
+static struct dm_config_tree *_open_and_read_config_file(const char *config_file,
+							 config_source_t source)
 {
 	struct dm_config_tree *cft;
 	struct stat info;
 
-	if (!(cft = config_file_open(config_file, 0))) {
+	if (!(cft = config_open(source, config_file, 0))) {
 		log_error("config_tree allocation failed");
 		return NULL;
 	}
 
 	/* Is there a config file? */
 	if (stat(config_file, &info) == -1) {
-		if (errno == ENOENT)
+		/* Profile file must be present! */
+		if (errno == ENOENT && (source != CONFIG_PROFILE))
 			return cft;
 		log_sys_error("stat", config_file);
 		goto bad;
@@ -554,7 +557,7 @@ static struct dm_config_tree *_open_and_read_config_file(const char *config_file
 
 	return cft;
 bad:
-	config_file_destroy(cft);
+	config_destroy(cft);
 	return NULL;
 }
 
@@ -579,7 +582,7 @@ static int _load_config_file(struct cmd_context *cmd, const char *tag)
 		return 0;
 	}
 
-	if (!(cfl->cft = _open_and_read_config_file(config_file)))
+	if (!(cfl->cft = _open_and_read_config_file(config_file, CONFIG_FILE)))
 		return_0;
 
 	dm_list_add(&cmd->config_files, &cfl->list);
@@ -599,7 +602,7 @@ static int _init_lvm_conf(struct cmd_context *cmd)
 {
 	/* No config file if LVM_SYSTEM_DIR is empty */
 	if (!*cmd->system_dir) {
-		if (!(cmd->cft = config_file_open(NULL, 0))) {
+		if (!(cmd->cft = config_open(CONFIG_FILE, NULL, 0))) {
 			log_error("Failed to create config tree");
 			return 0;
 		}
@@ -632,7 +635,7 @@ static struct dm_config_tree *_merge_config_files(struct cmd_context *cmd, struc
 
 	/* Replace temporary duplicate copy of lvm.conf */
 	if (cft->root) {
-		if (!(cft = config_file_open(NULL, 0))) {
+		if (!(cft = config_open(CONFIG_MERGED_FILES, NULL, 0))) {
 			log_error("Failed to create config tree");
 			return 0;
 		}
@@ -668,34 +671,35 @@ int config_files_changed(struct cmd_context *cmd)
 	return 0;
 }
 
-/*
- * Returns cmdline config_tree that overrides all others, if present.
- */
-static struct dm_config_tree *_destroy_tag_configs(struct cmd_context *cmd)
+static void _destroy_config(struct cmd_context *cmd)
 {
 	struct config_tree_list *cfl;
-	struct dm_config_tree *cft_cmdline = NULL, *cft;
-
-	cft = dm_config_remove_cascaded_tree(cmd->cft);
-	if (cft) {
-		cft_cmdline = cmd->cft;
-		cmd->cft = cft;
-	}
+	struct dm_config_tree *cft;
 
-	dm_list_iterate_items(cfl, &cmd->config_files) {
-		if (cfl->cft == cmd->cft)
-			cmd->cft = NULL;
-		config_file_destroy(cfl->cft);
-	}
+	/*
+	 * Configuration cascade:
+	 * CONFIG_STRING -> CONFIG_FILE/CONFIG_MERGED_FILES
+	 *
+	 * CONFIG_STRING - the configuration string passed in command line via '--config'
+	 * CONFIG_MERGED_FILES - merged master lvm.conf and tag configurations
+	 * CONFIG_FILE - master lvm.conf only
+	 */
 
-	if (cmd->cft) {
-		config_file_destroy(cmd->cft);
-		cmd->cft = NULL;
-	}
+	/* CONFIG_FILE/CONFIG_MERGED_FILES */
+	if ((cft = remove_config_tree_by_source(cmd, CONFIG_MERGED_FILES)))
+		config_destroy(cft);
+	else
+		remove_config_tree_by_source(cmd, CONFIG_FILE);
 
+	dm_list_iterate_items(cfl, &cmd->config_files)
+		config_destroy(cfl->cft);
 	dm_list_init(&cmd->config_files);
 
-	return cft_cmdline;
+	/* CONFIG_STRING */
+	if ((cft = remove_config_tree_by_source(cmd, CONFIG_STRING)))
+		config_destroy(cft);
+
+	assert(!cmd->cft);
 }
 
 static int _init_dev_cache(struct cmd_context *cmd)
@@ -1608,7 +1612,8 @@ int refresh_toolcontext(struct cmd_context *cmd)
 	_destroy_dev_types(cmd);
 	_destroy_tags(cmd);
 
-	cft_cmdline = _destroy_tag_configs(cmd);
+	cft_cmdline = remove_config_tree_by_source(cmd, CONFIG_STRING);
+	_destroy_config(cmd);
 
 	cmd->config_valid = 0;
 
@@ -1696,8 +1701,13 @@ void destroy_toolcontext(struct cmd_context *cmd)
 	_destroy_dev_types(cmd);
 	_destroy_tags(cmd);
 
-	if ((cft_cmdline = _destroy_tag_configs(cmd)))
-		dm_config_destroy(cft_cmdline);
+	if ((cft_cmdline = remove_config_tree_by_source(cmd, CONFIG_STRING)))
+		config_destroy(cft_cmdline);
+	_destroy_config(cmd);
+
+	if (cmd->cft_def_hash)
+		dm_hash_destroy(cmd->cft_def_hash);
+
 	if (cmd->libmem)
 		dm_pool_destroy(cmd->libmem);
 
@@ -1723,10 +1733,6 @@ void destroy_toolcontext(struct cmd_context *cmd)
 		dm_free(cmd->linebuffer);
 	}
 #endif
-
-	if (cmd->cft_def_hash)
-		dm_hash_destroy(cmd->cft_def_hash);
-
 	dm_free(cmd);
 
 	lvmetad_release_token();
diff --git a/lib/config/config.c b/lib/config/config.c
index 7b6ac7b..177f373 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -30,8 +30,15 @@
 #include <assert.h>
 #include <ctype.h>
 
+static const char *_config_source_names[] = {
+	[CONFIG_UNDEFINED] = "undefined",
+	[CONFIG_FILE] = "file",
+	[CONFIG_MERGED_FILES] = "merged files",
+	[CONFIG_STRING] = "string",
+	[CONFIG_PROFILE] = "profile"
+};
+
 struct config_file {
-	time_t timestamp;
 	off_t st_size;
 	char *filename;
 	int exists;
@@ -39,6 +46,15 @@ struct config_file {
 	struct device *dev;
 };
 
+struct config_source {
+	config_source_t type;
+	time_t timestamp;
+	union {
+		struct config_file *file;
+		struct config_file *profile;
+	} source;
+};
+
 static char _cfg_path[CFG_PATH_MAX_LEN];
 
 /*
@@ -54,30 +70,49 @@ static struct cfg_def_item _cfg_def_items[CFG_COUNT + 1] = {
 #undef cfg_array
 };
 
+config_source_t config_get_source_type(struct dm_config_tree *cft)
+{
+	struct config_source *cs = dm_config_get_custom(cft);
+	return cs ? cs->type : CONFIG_UNDEFINED;
+}
+
 /*
  * public interface
  */
-struct dm_config_tree *config_file_open(const char *filename, int keep_open)
+struct dm_config_tree *config_open(config_source_t source,
+				   const char *filename,
+				   int keep_open)
 {
 	struct dm_config_tree *cft = dm_config_create();
+	struct config_source *cs;
 	struct config_file *cf;
+
 	if (!cft)
 		return NULL;
 
-	if (!(cf = dm_pool_zalloc(cft->mem, sizeof(struct config_file)))) {
-		log_error("Failed to allocate config tree.");
+	if (!(cs = dm_pool_zalloc(cft->mem, sizeof(struct config_source)))) {
+		log_error("Failed to allocate config source.");
 		goto fail;
 	}
 
-	cf->keep_open = keep_open;
-	dm_config_set_custom(cft, cf);
+	if ((source == CONFIG_FILE) || (source == CONFIG_PROFILE)) {
+		if (!(cf = dm_pool_zalloc(cft->mem, sizeof(struct config_file)))) {
+			log_error("Failed to allocate config file.");
+			goto fail;
+		}
 
-	if (filename &&
-	    !(cf->filename = dm_pool_strdup(cft->mem, filename))) {
-		log_error("Failed to duplicate filename.");
-		goto fail;
+		cf->keep_open = keep_open;
+		if (filename &&
+		    !(cf->filename = dm_pool_strdup(cft->mem, filename))) {
+			log_error("Failed to duplicate filename.");
+			goto fail;
+		}
+
+		cs->source.file = cf;
 	}
 
+	cs->type = source;
+	dm_config_set_custom(cft, cs);
 	return cft;
 fail:
 	dm_config_destroy(cft);
@@ -89,12 +124,21 @@ fail:
  */
 int config_file_check(struct dm_config_tree *cft, const char **filename, struct stat *info)
 {
-	struct config_file *cf = dm_config_get_custom(cft);
+	struct config_source *cs = dm_config_get_custom(cft);
+	struct config_file *cf;
 	struct stat _info;
 
+	if ((cs->type != CONFIG_FILE) && (cs->type != CONFIG_PROFILE)) {
+		log_error(INTERNAL_ERROR "config_file_check: expected file or profile config source, "
+					 "found %s config source.", _config_source_names[cs->type]);
+		return 0;
+	}
+
 	if (!info)
 		info = &_info;
 
+	cf = cs->source.file;
+
 	if (stat(cf->filename, info)) {
 		log_sys_error("stat", cf->filename);
 		cf->exists = 0;
@@ -107,8 +151,8 @@ int config_file_check(struct dm_config_tree *cft, const char **filename, struct
 		return 0;
 	}
 
+	cs->timestamp = info->st_ctime;
 	cf->exists = 1;
-	cf->timestamp = info->st_ctime;
 	cf->st_size = info->st_size;
 
 	if (info->st_size == 0)
@@ -124,9 +168,18 @@ int config_file_check(struct dm_config_tree *cft, const char **filename, struct
  */
 int config_file_changed(struct dm_config_tree *cft)
 {
-	struct config_file *cf = dm_config_get_custom(cft);
+	struct config_source *cs = dm_config_get_custom(cft);
+	struct config_file *cf;
 	struct stat info;
 
+	if (cs->type != CONFIG_FILE) {
+		log_error(INTERNAL_ERROR "config_file_changed: expected file config source, "
+					 "found %s config source.", _config_source_names[cs->type]);
+		return 0;
+	}
+
+	cf = cs->source.file;
+
 	if (!cf->filename)
 		return 0;
 
@@ -151,7 +204,7 @@ int config_file_changed(struct dm_config_tree *cft)
 	}
 
 	/* Unchanged? */
-	if (cf->timestamp == info.st_ctime && cf->st_size == info.st_size)
+	if (cs->timestamp == info.st_ctime && cf->st_size == info.st_size)
 		return 0;
 
       reload:
@@ -159,13 +212,17 @@ int config_file_changed(struct dm_config_tree *cft)
 	return 1;
 }
 
-void config_file_destroy(struct dm_config_tree *cft)
+void config_destroy(struct dm_config_tree *cft)
 {
-	struct config_file *cf = dm_config_get_custom(cft);
+	struct config_source *cs = dm_config_get_custom(cft);
+	struct config_file *cf;
 
-	if (cf && cf->dev)
-		if (!dev_close(cf->dev))
-			stack;
+	if ((cs->type == CONFIG_FILE) || (cs->type == CONFIG_PROFILE)) {
+		cf = cs->source.file;
+		if (cf && cf->dev)
+			if (!dev_close(cf->dev))
+				stack;
+	}
 
 	dm_config_destroy(cft);
 }
@@ -173,29 +230,62 @@ void config_file_destroy(struct dm_config_tree *cft)
 /*
  * Returns config tree if it was removed.
  */
-struct dm_config_tree *remove_overridden_config_tree(struct cmd_context *cmd)
+struct dm_config_tree *remove_config_tree_by_source(struct cmd_context *cmd,
+						    config_source_t source)
 {
-	struct dm_config_tree *old_cft = cmd->cft;
-	struct dm_config_tree *cft = dm_config_remove_cascaded_tree(cmd->cft);
-
-	if (!cft)
-		return NULL;
-
-	cmd->cft = cft;
+	struct dm_config_tree *previous_cft = NULL;
+	struct dm_config_tree *cft = cmd->cft;
+	struct config_source *cs;
+
+	while (cft) {
+		cs = dm_config_get_custom(cft);
+		if (cs && (cs->type == source)) {
+			if (previous_cft) {
+				previous_cft->cascade = cft->cascade;
+				cmd->cft = previous_cft;
+			} else
+				cmd->cft = cft->cascade;
+			cft->cascade = NULL;
+			break;
+		}
+		previous_cft = cft;
+		cft = cft->cascade;
+	}
 
-	return old_cft;
+	return cft;
 }
 
 int override_config_tree_from_string(struct cmd_context *cmd,
 				     const char *config_settings)
 {
 	struct dm_config_tree *cft_new;
+	struct config_source *cs = dm_config_get_custom(cmd->cft);
+
+	/*
+	 * Follow this sequence:
+	 * CONFIG_STRING -> CONFIG_FILE/CONFIG_MERGED_FILES
+	 */
+
+	if (cs->type == CONFIG_STRING) {
+		log_error(INTERNAL_ERROR "override_config_tree_from_string: "
+			  "config cascade already contains a string config.");
+		return 0;
+	}
 
 	if (!(cft_new = dm_config_from_string(config_settings))) {
 		log_error("Failed to set overridden configuration entries.");
 		return 0;
 	}
 
+	if (!(cs = dm_pool_zalloc(cft_new->mem, sizeof(struct config_source)))) {
+		log_error("Failed to allocate config source.");
+		dm_config_destroy(cft_new);
+		return 0;
+	}
+
+	cs->type = CONFIG_STRING;
+	dm_config_set_custom(cft_new, cs);
+
 	cmd->cft = dm_config_insert_cascaded_tree(cft_new, cmd->cft);
 
 	return 1;
@@ -210,6 +300,13 @@ int config_file_read_fd(struct dm_config_tree *cft, struct device *dev,
 	int use_mmap = 1;
 	off_t mmap_offset = 0;
 	char *buf = NULL;
+	struct config_source *cs = dm_config_get_custom(cft);
+
+	if ((cs->type != CONFIG_FILE) && (cs->type != CONFIG_PROFILE)) {
+		log_error(INTERNAL_ERROR "config_file_read_fd: expected file or profile config source, "
+					 "found %s config source.", _config_source_names[cs->type]);
+		return 0;
+	}
 
 	/* Only use mmap with regular files */
 	if (!(dev->flags & DEV_REGULAR) || size2)
@@ -267,7 +364,8 @@ int config_file_read_fd(struct dm_config_tree *cft, struct device *dev,
 int config_file_read(struct dm_config_tree *cft)
 {
 	const char *filename = NULL;
-	struct config_file *cf = dm_config_get_custom(cft);
+	struct config_source *cs = dm_config_get_custom(cft);
+	struct config_file *cf;
 	struct stat info;
 	int r;
 
@@ -278,6 +376,8 @@ int config_file_read(struct dm_config_tree *cft)
 	if (!filename)
 		return 1;
 
+	cf = cs->source.file;
+
 	if (!cf->dev) {
 		if (!(cf->dev = dev_create_file(filename, NULL, NULL, 1)))
 			return_0;
@@ -300,9 +400,8 @@ int config_file_read(struct dm_config_tree *cft)
 
 time_t config_file_timestamp(struct dm_config_tree *cft)
 {
-	struct config_file *cf = dm_config_get_custom(cft);
-	assert(cf);
-	return cf->timestamp;
+	struct config_source *cs = dm_config_get_custom(cft);
+	return cs->timestamp;
 }
 
 #define cfg_def_get_item_p(id) (&_cfg_def_items[id])
@@ -768,7 +867,7 @@ int merge_config_tree(struct cmd_context *cmd, struct dm_config_tree *cft,
 	struct dm_config_node *root = cft->root;
 	struct dm_config_node *cn, *nextn, *oldn, *cn2;
 	const struct dm_config_node *tn;
-	struct config_file *cf, *cfn;
+	struct config_source *cs, *csn;
 
 	for (cn = newdata->root; cn; cn = nextn) {
 		nextn = cn->sib;
@@ -803,10 +902,11 @@ int merge_config_tree(struct cmd_context *cmd, struct dm_config_tree *cft,
 	 * so we need to know the newest timestamp to make right decision
 	 * whether the .cache isn't older then any of configs
 	 */
-	if ((cf = dm_config_get_custom(cft)) &&
-	    (cfn = dm_config_get_custom(newdata)) &&
-	    cf->timestamp < cfn->timestamp)
-		cf->timestamp = cfn->timestamp;
+	cs = dm_config_get_custom(cft);
+	csn = dm_config_get_custom(cft);
+
+	if (cs && csn && (cs->timestamp < csn->timestamp))
+		cs->timestamp = csn->timestamp;
 
 	return 1;
 }
diff --git a/lib/config/config.h b/lib/config/config.h
index 155d69a..2f5cee6 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -26,6 +26,14 @@
 struct device;
 struct cmd_context;
 
+typedef enum {
+	CONFIG_UNDEFINED,
+	CONFIG_FILE,
+	CONFIG_MERGED_FILES,
+	CONFIG_STRING,
+	CONFIG_PROFILE
+} config_source_t;
+
 #define CFG_PATH_MAX_LEN 64
 
 /*
@@ -109,13 +117,13 @@ enum {
 int config_def_get_path(char *buf, size_t buf_size, int id);
 int config_def_check(struct cmd_context *cmd, int force, int skip, int suppress_messages);
 
-int override_config_tree_from_string(struct cmd_context *cmd,
-				     const char *config_settings);
-struct dm_config_tree *remove_overridden_config_tree(struct cmd_context *cmd);
+int override_config_tree_from_string(struct cmd_context *cmd, const char *config_settings);
+struct dm_config_tree *remove_config_tree_by_source(struct cmd_context *cmd, config_source_t source);
+config_source_t config_get_source_type(struct dm_config_tree *cft);
 
 typedef uint32_t (*checksum_fn_t) (uint32_t initial, const uint8_t *buf, uint32_t size);
 
-struct dm_config_tree *config_file_open(const char *filename, int keep_open);
+struct dm_config_tree *config_open(config_source_t source, const char *filename, int keep_open);
 int config_file_read_fd(struct dm_config_tree *cft, struct device *dev,
 			off_t offset, size_t size, off_t offset2, size_t size2,
 			checksum_fn_t checksum_fn, uint32_t checksum);
@@ -124,7 +132,7 @@ int config_write(struct dm_config_tree *cft,
 		 int withcomment, int withversion,
 		 const char *file, int argc, char **argv);
 struct dm_config_tree *config_def_create_tree(struct config_def_tree_spec *spec);
-void config_file_destroy(struct dm_config_tree *cft);
+void config_destroy(struct dm_config_tree *cft);
 
 time_t config_file_timestamp(struct dm_config_tree *cft);
 int config_file_changed(struct dm_config_tree *cft);
diff --git a/lib/filters/filter-persistent.c b/lib/filters/filter-persistent.c
index a59529d..2949b93 100644
--- a/lib/filters/filter-persistent.c
+++ b/lib/filters/filter-persistent.c
@@ -114,7 +114,7 @@ int persistent_filter_load(struct dev_filter *f, struct dm_config_tree **cft_out
 		return_0;
 	}
 
-	if (!(cft = config_file_open(pf->file, 1)))
+	if (!(cft = config_open(CONFIG_FILE, pf->file, 1)))
 		return_0;
 
 	if (!config_file_read(cft))
@@ -139,7 +139,7 @@ int persistent_filter_load(struct dev_filter *f, struct dm_config_tree **cft_out
 	if (r && cft_out)
 		*cft_out = cft;
 	else
-		config_file_destroy(cft);
+		config_destroy(cft);
 	return r;
 }
 
@@ -263,7 +263,7 @@ out:
 	fcntl_unlock_file(lockfd);
 
 	if (cft)
-		config_file_destroy(cft);
+		config_destroy(cft);
 
 	return r;
 }
diff --git a/lib/format_text/import.c b/lib/format_text/import.c
index 8a05ca9..6b7d589 100644
--- a/lib/format_text/import.c
+++ b/lib/format_text/import.c
@@ -46,7 +46,7 @@ const char *text_vgname_import(const struct format_type *fmt,
 
 	_init_text_import();
 
-	if (!(cft = config_file_open(NULL, 0)))
+	if (!(cft = config_open(CONFIG_FILE, NULL, 0)))
 		return_NULL;
 
 	if ((!dev && !config_file_read(cft)) ||
@@ -69,7 +69,7 @@ const char *text_vgname_import(const struct format_type *fmt,
 	}
 
       out:
-	config_file_destroy(cft);
+	config_destroy(cft);
 	return vgname;
 }
 
@@ -92,7 +92,7 @@ struct volume_group *text_vg_import_fd(struct format_instance *fid,
 	*desc = NULL;
 	*when = 0;
 
-	if (!(cft = config_file_open(file, 0)))
+	if (!(cft = config_open(CONFIG_FILE, file, 0)))
 		return_NULL;
 
 	if ((!dev && !config_file_read(cft)) ||
@@ -117,7 +117,7 @@ struct volume_group *text_vg_import_fd(struct format_instance *fid,
 	}
 
       out:
-	config_file_destroy(cft);
+	config_destroy(cft);
 	return vg;
 }
 
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 89ead2c..51bbcd2 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1083,7 +1083,7 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 	if (arg_count(cmd, config_ARG) || !cmd->config_valid || config_files_changed(cmd)) {
 		/* Reinitialise various settings inc. logging, filters */
 		if (!refresh_toolcontext(cmd)) {
-			old_cft = remove_overridden_config_tree(cmd);
+			old_cft = remove_config_tree_by_source(cmd, CONFIG_STRING);
 			if (old_cft)
 				dm_config_destroy(old_cft);
 			log_error("Updated config file invalid. Aborting.");
@@ -1138,7 +1138,7 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 		lvmcache_destroy(cmd, 1);
 	}
 
-	if ((old_cft = remove_overridden_config_tree(cmd))) {
+	if ((old_cft = remove_config_tree_by_source(cmd, CONFIG_STRING))) {
 		dm_config_destroy(old_cft);
 		/* Move this? */
 		if (!refresh_toolcontext(cmd))


