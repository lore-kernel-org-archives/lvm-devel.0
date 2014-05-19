From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 19 May 2014 13:43:53 +0000 (UTC)
Subject: master - config: attach cft_check_handle to each config tree instead of global cmd_context
Message-ID: <20140519134353.34BC060CFE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c42f72867a653974f07e6e1db52f41691356e5b7
Commit:        c42f72867a653974f07e6e1db52f41691356e5b7
Parent:        ff9d27a1c71785abd6aa71eddc7018dd56807517
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon May 19 13:23:12 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon May 19 15:38:04 2014 +0200

config: attach cft_check_handle to each config tree instead of global cmd_context

Before, the cft_check_handle used to direct configuration checking
was part of cmd_context. It's better to attach this as part of the
exact config tree against which the check is done. This patch moves
the cft_check_handle out of cmd_context and it attaches it to the
config tree directly as dm_config_tree->custom->config_source->check_handle.

This change makes it easier to track the config tree check results
and provides less space for bugs as the results are directly attached
to the tree and we don't need to be cautious whether the global value
is correct or not (and whether it needs reinitialization) as it was
in the case when the cft_check_handle was part of cmd_context.
---
 lib/commands/toolcontext.c |   34 +++++++++++++++++-----------
 lib/commands/toolcontext.h |    1 -
 lib/config/config.c        |   51 +++++++++++++++++++++++++++++++++++++++++-
 lib/config/config.h        |    5 +++-
 tools/dumpconfig.c         |   52 +++++++++++++------------------------------
 5 files changed, 90 insertions(+), 53 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index b2f8293..03b06d2 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -256,24 +256,32 @@ static int _check_disable_udev(const char *msg) {
 	return 0;
 }
 
+static int _check_config_by_source(struct cmd_context *cmd, config_source_t source)
+{
+	struct dm_config_tree *cft;
+	struct cft_check_handle *handle;
+
+	if (!(cft = get_config_tree_by_source(cmd, source)) ||
+	    !(handle = get_config_tree_check_handle(cmd, cft)))
+		return 1;
+
+	return config_def_check(handle);
+}
+
 static int _check_config(struct cmd_context *cmd)
 {
+	int abort_on_error;
+
 	if (!find_config_tree_bool(cmd, config_checks_CFG, NULL))
 		return 1;
 
-	if (!cmd->cft_check_handle) {
-		if (!(cmd->cft_check_handle = dm_pool_zalloc(cmd->libmem, sizeof(*cmd->cft_check_handle)))) {
-			log_error("Configuration check handle allocation failed.");
-			return 0;
-		}
-	}
-
-	cmd->cft_check_handle->cft = cmd->cft;
-	cmd->cft_check_handle->cmd = cmd;
+	abort_on_error = find_config_tree_bool(cmd, config_abort_on_errors_CFG, NULL);
 
-	if (!config_def_check(cmd->cft_check_handle) &&
-	    find_config_tree_bool(cmd, config_abort_on_errors_CFG, NULL)) {
-		log_error("LVM configuration invalid.");
+	if ((!_check_config_by_source(cmd, CONFIG_STRING) ||
+	    !_check_config_by_source(cmd, CONFIG_MERGED_FILES) ||
+	    !_check_config_by_source(cmd, CONFIG_FILE)) &&
+	    abort_on_error) {
+		log_error("LVM_ configuration invalid.");
 		return 0;
 	}
 
@@ -571,7 +579,7 @@ static int _load_config_file(struct cmd_context *cmd, const char *tag)
 		return 0;
 	}
 
-	if (!(cfl->cft = config_file_open_and_read(config_file, CONFIG_FILE)))
+	if (!(cfl->cft = config_file_open_and_read(config_file, CONFIG_FILE, cmd)))
 		return_0;
 
 	dm_list_add(&cmd->config_files, &cfl->list);
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 7694ee2..9023a6c 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -105,7 +105,6 @@ struct cmd_context {
 	int config_initialized; /* used to reinitialize config if previous init was not successful */
 
 	struct dm_hash_table *cft_def_hash; /* config definition hash used for validity check (item type + item recognized) */
-	struct cft_check_handle *cft_check_handle;
 
 	/* selected settings with original default/configured value which can be changed during cmd processing */
 	struct config_info default_settings;
diff --git a/lib/config/config.c b/lib/config/config.c
index b0880a6..4b5c18c 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -57,6 +57,7 @@ struct config_source {
 		struct config_file *file;
 		struct config_file *profile;
 	} source;
+	struct cft_check_handle *check_handle;
 };
 
 /*
@@ -246,7 +247,8 @@ void config_destroy(struct dm_config_tree *cft)
 }
 
 struct dm_config_tree *config_file_open_and_read(const char *config_file,
-						 config_source_t source)
+						 config_source_t source,
+						 struct cmd_context *cmd)
 {
 	struct dm_config_tree *cft;
 	struct stat info;
@@ -277,6 +279,22 @@ bad:
 	return NULL;
 }
 
+struct dm_config_tree *get_config_tree_by_source(struct cmd_context *cmd,
+						 config_source_t source)
+{
+	struct dm_config_tree *cft = cmd->cft;
+	struct config_source *cs;
+
+	while (cft) {
+		cs = dm_config_get_custom(cft);
+		if (cs && cs->type == source)
+			return cft;
+		cft = cft->cascade;
+	}
+
+	return NULL;
+}
+
 /*
  * Returns config tree if it was removed.
  */
@@ -305,6 +323,35 @@ struct dm_config_tree *remove_config_tree_by_source(struct cmd_context *cmd,
 	return cft;
 }
 
+struct cft_check_handle *get_config_tree_check_handle(struct cmd_context *cmd,
+						      struct dm_config_tree *cft)
+{
+	struct config_source *cs = dm_config_get_custom(cft);
+
+	if (!(cs = dm_config_get_custom(cft)))
+		return NULL;
+
+	if (cs->check_handle)
+		goto out;
+
+	/*
+	 * Attach config check handle to all config types but
+	 * CONFIG_FILE_SPECIAL - this one uses its own check
+	 * methods and the cft_check_handle is not applicable here.
+	 */
+	if (cs->type != CONFIG_FILE_SPECIAL) {
+		if (!(cs->check_handle = dm_pool_zalloc(cft->mem, sizeof(*cs->check_handle)))) {
+			log_error("Failed to allocate configuration check handle.");
+			return NULL;
+		}
+		cs->check_handle->cft = cft;
+		cs->check_handle->cmd = cmd;
+	}
+out:
+	return cs->check_handle;
+}
+
+
 int override_config_tree_from_string(struct cmd_context *cmd,
 				     const char *config_settings)
 {
@@ -1646,7 +1693,7 @@ int load_profile(struct cmd_context *cmd, struct profile *profile) {
 		return 0;
 	}
 
-	if (!(profile->cft = config_file_open_and_read(profile_path, CONFIG_PROFILE)))
+	if (!(profile->cft = config_file_open_and_read(profile_path, CONFIG_PROFILE, cmd)))
 		return 0;
 
 	dm_list_move(&cmd->profile_params->profiles, &profile->list);
diff --git a/lib/config/config.h b/lib/config/config.h
index d78ea43..4967b27 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -183,7 +183,9 @@ int config_def_check(struct cft_check_handle *handle);
 
 int override_config_tree_from_string(struct cmd_context *cmd, const char *config_settings);
 int override_config_tree_from_profile(struct cmd_context *cmd, struct profile *profile);
+struct dm_config_tree *get_config_tree_by_source(struct cmd_context *, config_source_t source);
 struct dm_config_tree *remove_config_tree_by_source(struct cmd_context *cmd, config_source_t source);
+struct cft_check_handle *get_config_tree_check_handle(struct cmd_context *cmd, struct dm_config_tree *cft);
 config_source_t config_get_source_type(struct dm_config_tree *cft);
 
 typedef uint32_t (*checksum_fn_t) (uint32_t initial, const uint8_t *buf, uint32_t size);
@@ -193,7 +195,8 @@ int config_file_read_fd(struct dm_config_tree *cft, struct device *dev,
 			off_t offset, size_t size, off_t offset2, size_t size2,
 			checksum_fn_t checksum_fn, uint32_t checksum);
 int config_file_read(struct dm_config_tree *cft);
-struct dm_config_tree *config_file_open_and_read(const char *config_file, config_source_t source);
+struct dm_config_tree *config_file_open_and_read(const char *config_file, config_source_t source,
+						 struct cmd_context *cmd);
 int config_write(struct dm_config_tree *cft, struct config_def_tree_spec *tree_spec,
 		 const char *file, int argc, char **argv);
 struct dm_config_tree *config_def_create_tree(struct config_def_tree_spec *spec);
diff --git a/tools/dumpconfig.c b/tools/dumpconfig.c
index 97863be..49a6a68 100644
--- a/tools/dumpconfig.c
+++ b/tools/dumpconfig.c
@@ -29,40 +29,13 @@ static int _get_vsn(struct cmd_context *cmd, uint16_t *version_int)
 	return 1;
 }
 
-static struct cft_check_handle *_get_cft_check_handle(struct cmd_context *cmd, struct dm_config_tree *cft)
-{
-	struct cft_check_handle *handle;
-	struct dm_pool *mem;
-
-	if (cft == cmd->cft) {
-		mem = cmd->libmem;
-		handle = cmd->cft_check_handle;
-	} else {
-		mem = cft->mem;
-		handle = NULL;
-	}
-
-	if (!handle) {
-		if (!(handle = dm_pool_zalloc(mem, sizeof(struct cft_check_handle)))) {
-			log_error("Configuration check handle allocation failed.");
-			return NULL;
-		}
-		handle->cmd = cmd;
-		handle->cft = cft;
-		if (cft == cmd->cft)
-			cmd->cft_check_handle = handle;
-	}
-
-	return handle;
-}
-
 static int _do_def_check(struct config_def_tree_spec *spec,
 			 struct dm_config_tree *cft,
 			 struct cft_check_handle **cft_check_handle)
 {
 	struct cft_check_handle *handle;
 
-	if (!(handle = _get_cft_check_handle(spec->cmd, cft)))
+	if (!(handle = get_config_tree_check_handle(spec->cmd, cft)))
 		return 0;
 
 	handle->force_check = 1;
@@ -94,6 +67,20 @@ static int _merge_config_cascade(struct cmd_context *cmd, struct dm_config_tree
 	return merge_config_tree(cmd, *cft_merged, cft_cascaded, CONFIG_MERGE_TYPE_RAW);
 }
 
+static int _config_validate(struct cmd_context *cmd, struct dm_config_tree *cft)
+{
+	struct cft_check_handle *handle;
+
+	if (!(handle = get_config_tree_check_handle(cmd, cft)))
+		return 1;
+
+	handle->force_check = 1;
+	handle->skip_if_checked = 1;
+	handle->suppress_messages = 0;
+
+	return config_def_check(handle);
+}
+
 int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 {
 	const char *file = arg_str_value(cmd, file_ARG, NULL);
@@ -154,14 +141,7 @@ int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 		cft = cmd->cft;
 
 	if (arg_count(cmd, validate_ARG)) {
-		if (!(cft_check_handle = _get_cft_check_handle(cmd, cft)))
-			return ECMD_FAILED;
-
-		cft_check_handle->force_check = 1;
-		cft_check_handle->skip_if_checked = 1;
-		cft_check_handle->suppress_messages = 0;
-
-		if (config_def_check(cft_check_handle)) {
+		if (_config_validate(cmd, cft)) {
 			log_print("LVM configuration valid.");
 			goto out;
 		} else {


