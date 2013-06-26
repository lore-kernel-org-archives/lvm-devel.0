From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 26 Jun 2013 14:56:13 +0000 (UTC)
Subject: dev-peter-config-profiles - config: make it possible to run several instances of configuration check at once
Message-ID: <20130626145613.8D963615EB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=28e644fa11ff2101ea20e0842055d0c26bb8ede6
Commit:        28e644fa11ff2101ea20e0842055d0c26bb8ede6
Parent:        6fb82a545af104e2e2db0fffdc06f1f3e6df1f41
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jun 26 14:53:57 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jun 26 16:53:51 2013 +0200

config: make it possible to run several instances of configuration check at once

Before, the status of the configuration check (config_def_check fn call)
was saved directly in global configuration definitinion array (as part
of the cfg_def_item_t/flags)

This patch introduces the "struct cft_check_handle" that defines
configuration check parameters as well as separate place to store
the status (status here means CFG_USED and CFG_VALID flags, formerly
saved in cfg_def_item_t/flags). This struct can hold config check
parameters as well as the status for each config tree separately,
thus making it possible to run several instances of config_def_check
without interference.
---
 lib/commands/toolcontext.c |   28 ++++++++++--
 lib/commands/toolcontext.h |    2 +
 lib/config/config.c        |  103 +++++++++++++++++++++----------------------
 lib/config/config.h        |   21 +++++++--
 tools/dumpconfig.c         |   36 ++++++++++++++-
 5 files changed, 126 insertions(+), 64 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 50c96d4..cee5ed9 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -264,6 +264,28 @@ static int _check_disable_udev(const char *msg) {
 	return 0;
 }
 
+static int _check_config(struct cmd_context *cmd)
+{
+	if (!find_config_tree_bool(cmd, config_checks_CFG, NULL))
+		return 1;
+
+	if (!cmd->cft_check_handle) {
+		if (!(cmd->cft_check_handle = dm_pool_zalloc(cmd->libmem, sizeof(*cmd->cft_check_handle)))) {
+			log_error("Configuration check handle allocation failed.");
+			return 0;
+		}
+		cmd->cft_check_handle->cft = cmd->cft;
+	}
+
+	if (!config_def_check(cmd, cmd->cft_check_handle) &&
+	    find_config_tree_bool(cmd, config_abort_on_errors_CFG, NULL)) {
+		log_error("LVM configuration invalid.");
+		return 0;
+	}
+
+	return 1;
+}
+
 static int _process_config(struct cmd_context *cmd)
 {
 	mode_t old_umask;
@@ -276,10 +298,8 @@ static int _process_config(struct cmd_context *cmd)
 	int udev_disabled = 0;
 	char sysfs_dir[PATH_MAX];
 
-	if (!config_def_check(cmd, 0, 0, 0) && find_config_tree_bool(cmd, config_abort_on_errors_CFG, NULL)) {
-		log_error("LVM configuration invalid.");
-		return 0;
-	}
+	if (!_check_config(cmd))
+		return_0;
 
 	/* umask */
 	cmd->default_settings.umask = find_config_tree_int(cmd, global_umask_CFG, NULL);
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 42a4e54..2d90138 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -102,7 +102,9 @@ struct cmd_context {
 	struct profile_params *profile_params; /* profile handling params including loaded profile configs */
 	struct dm_config_tree *cft; /* the whole cascade: CONFIG_STRING -> CONFIG_PROFILE -> CONFIG_FILE/CONFIG_MERGED_FILES */
 	int config_initialized; /* used to reinitialize config if previous init was not successful */
+
 	struct dm_hash_table *cft_def_hash; /* config definition hash used for validity check (item type + item recognized) */
+	struct cft_check_handle *cft_check_handle;
 
 	/* selected settings with original default/configured value which can be changed during cmd processing */
 	struct config_info default_settings;
diff --git a/lib/config/config.c b/lib/config/config.c
index b6ddcb7..c66dd9b 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -543,12 +543,13 @@ static int _config_def_check_node_single_value(const char *rp, const struct dm_c
 	return 1;
 }
 
-static int _config_def_check_node_value(const char *rp, const struct dm_config_value *v,
-					const cfg_def_item_t *def, int suppress_messages)
+static int _config_def_check_node_value(struct cft_check_handle *handle,
+					const char *rp, const struct dm_config_value *v,
+					const cfg_def_item_t *def)
 {
 	if (!v) {
 		if (def->type != CFG_TYPE_SECTION) {
-			_log_type_error(rp, CFG_TYPE_SECTION, def->type, suppress_messages);
+			_log_type_error(rp, CFG_TYPE_SECTION, def->type, handle->suppress_messages);
 			return 0;
 		}
 		return 1;
@@ -556,13 +557,13 @@ static int _config_def_check_node_value(const char *rp, const struct dm_config_v
 
 	if (v->next) {
 		if (!(def->type & CFG_TYPE_ARRAY)) {
-			_log_type_error(rp, CFG_TYPE_ARRAY, def->type, suppress_messages);
+			_log_type_error(rp, CFG_TYPE_ARRAY, def->type, handle->suppress_messages);
 			return 0;
 		}
 	}
 
 	do {
-		if (!_config_def_check_node_single_value(rp, v, def, suppress_messages))
+		if (!_config_def_check_node_single_value(rp, v, def, handle->suppress_messages))
 			return 0;
 		v = v->next;
 	} while (v);
@@ -570,9 +571,10 @@ static int _config_def_check_node_value(const char *rp, const struct dm_config_v
 	return 1;
 }
 
-static int _config_def_check_node(const char *vp, char *pvp, char *rp, char *prp,
+static int _config_def_check_node(struct cft_check_handle *handle,
+				  const char *vp, char *pvp, char *rp, char *prp,
 				  size_t buf_size, struct dm_config_node *cn,
-				  struct dm_hash_table *ht, int suppress_messages)
+				  struct dm_hash_table *ht)
 {
 	cfg_def_item_t *def;
 	int sep = vp != pvp; /* don't use '/' separator for top-level node */
@@ -587,7 +589,7 @@ static int _config_def_check_node(const char *vp, char *pvp, char *rp, char *prp
 	if (!(def = (cfg_def_item_t *) dm_hash_lookup(ht, vp))) {
 		/* If the node is not a section but a setting, fail now. */
 		if (cn->v) {
-			log_warn_suppress(suppress_messages,
+			log_warn_suppress(handle->suppress_messages,
 				"Configuration setting \"%s\" unknown.", rp);
 			cn->id = -1;
 			return 0;
@@ -598,38 +600,38 @@ static int _config_def_check_node(const char *vp, char *pvp, char *rp, char *prp
 		/* The real path without '#' is still stored in rp variable. */
 		pvp[sep] = '#', pvp[sep + 1] = '\0';
 		if (!(def = (cfg_def_item_t *) dm_hash_lookup(ht, vp))) {
-			log_warn_suppress(suppress_messages,
+			log_warn_suppress(handle->suppress_messages,
 				"Configuration section \"%s\" unknown.", rp);
 			cn->id = -1;
 			return 0;
 		}
 	}
 
-	def->flags |= CFG_USED;
+	handle->status[def->id] |= CFG_USED;
 	cn->id = def->id;
 
-	if (!_config_def_check_node_value(rp, cn->v, def, suppress_messages))
-	return 0;
+	if (!_config_def_check_node_value(handle, rp, cn->v, def))
+		return 0;
 
-	def->flags |= CFG_VALID;
+	handle->status[def->id] |= CFG_VALID;
 	return 1;
 }
 
-static int _config_def_check_tree(const char *vp, char *pvp, char *rp, char *prp,
+static int _config_def_check_tree(struct cft_check_handle *handle,
+				  const char *vp, char *pvp, char *rp, char *prp,
 				  size_t buf_size, struct dm_config_node *root,
-				  struct dm_hash_table *ht, int suppress_messages)
+				  struct dm_hash_table *ht)
 {
 	struct dm_config_node *cn;
 	int valid, r = 1;
 	size_t len;
 
 	for (cn = root->child; cn; cn = cn->sib) {
-		if ((valid = _config_def_check_node(vp, pvp, rp, prp, buf_size,
-					cn, ht, suppress_messages)) && !cn->v) {
+		if ((valid = _config_def_check_node(handle, vp, pvp, rp, prp,
+					buf_size, cn, ht)) && !cn->v) {
 			len = strlen(rp);
-			valid = _config_def_check_tree(vp, pvp + strlen(pvp),
-					rp, prp + len, buf_size - len, cn, ht,
-					suppress_messages);
+			valid = _config_def_check_tree(handle, vp, pvp + strlen(pvp),
+					rp, prp + len, buf_size - len, cn, ht);
 		}
 		if (!valid)
 			r = 0;
@@ -638,7 +640,7 @@ static int _config_def_check_tree(const char *vp, char *pvp, char *rp, char *prp
 	return r;
 }
 
-int config_def_check(struct cmd_context *cmd, int force, int skip, int suppress_messages)
+int config_def_check(struct cmd_context *cmd, struct cft_check_handle *handle)
 {
 	cfg_def_item_t *def;
 	struct dm_config_node *cn;
@@ -654,28 +656,21 @@ int config_def_check(struct cmd_context *cmd, int force, int skip, int suppress_
 	 */
 
 	/*
-	 * If the check has already been done and 'skip' is set,
+	 * If the check has already been done and 'skip_if_checked' is set,
 	 * skip the actual check and use last result if available.
 	 * If not available, we must do the check. The global status
 	 * is stored in root node.
 	 */
-	def = cfg_def_get_item_p(root_CFG_SECTION);
-	if (skip && (def->flags & CFG_USED))
-		return def->flags & CFG_VALID;
-
-	/* Clear 'used' and 'valid' status flags. */
-	for (id = 0; id < CFG_COUNT; id++) {
-		def = cfg_def_get_item_p(id);
-		def->flags &= ~(CFG_USED | CFG_VALID);
-	}
+	if (handle->skip_if_checked && (handle->status[root_CFG_SECTION] & CFG_USED))
+		return handle->status[root_CFG_SECTION] & CFG_VALID;
 
-	if (!force && !find_config_tree_bool(cmd, config_checks_CFG, NULL)) {
-		if (cmd->cft_def_hash) {
-			dm_hash_destroy(cmd->cft_def_hash);
-			cmd->cft_def_hash = NULL;
-		}
+	/* Nothing to do if checks are disabled and also not forced. */
+	if (!handle->force_check && !find_config_tree_bool(cmd, config_checks_CFG, NULL))
 		return 1;
-	}
+
+	/* Clear 'used' and 'valid' status flags. */
+	for (id = 0; id < CFG_COUNT; id++)
+		handle->status[id] &= ~(CFG_USED | CFG_VALID);
 
 	/*
 	 * Create a hash of all possible configuration
@@ -702,44 +697,46 @@ int config_def_check(struct cmd_context *cmd, int force, int skip, int suppress_
 		}
 	}
 
-	cfg_def_get_item_p(root_CFG_SECTION)->flags |= CFG_USED;
+	/*
+	 * Mark this handle as used so next time we know that the check
+	 * has already been done and so we can just reuse the previous
+	 * status instead of running this whole check again.
+	 */
+	handle->status[root_CFG_SECTION] |= CFG_USED;
 
 	/*
 	 * Allow only sections as top-level elements.
 	 * Iterate top-level sections and dive deeper.
 	 * If any of subsequent checks fails, the whole check fails.
 	 */
-	for (cn = cmd->cft->root; cn; cn = cn->sib) {
+	for (cn = handle->cft->root; cn; cn = cn->sib) {
 		if (!cn->v) {
 			/* top level node: vp=vp, rp=rp */
-			if (!_config_def_check_node(vp, vp, rp, rp,
+			if (!_config_def_check_node(handle, vp, vp, rp, rp,
 						    CFG_PATH_MAX_LEN,
-						    cn, cmd->cft_def_hash,
-						    suppress_messages)) {
+						    cn, cmd->cft_def_hash)) {
 				r = 0; continue;
 			}
 			rplen = strlen(rp);
-			if (!_config_def_check_tree(vp, vp + strlen(vp),
+			if (!_config_def_check_tree(handle,
+						    vp, vp + strlen(vp),
 						    rp, rp + rplen,
 						    CFG_PATH_MAX_LEN - rplen,
-						    cn, cmd->cft_def_hash,
-						    suppress_messages))
+						    cn, cmd->cft_def_hash))
 				r = 0;
 		} else {
-			log_error_suppress(suppress_messages,
+			log_error_suppress(handle->suppress_messages,
 				"Configuration setting \"%s\" invalid. "
 				"It's not part of any section.", cn->key);
 			r = 0;
 		}
 	}
 out:
-	if (r) {
-		cfg_def_get_item_p(root_CFG_SECTION)->flags |= CFG_VALID;
-		def->flags |= CFG_VALID;
-	} else {
-		cfg_def_get_item_p(root_CFG_SECTION)->flags &= ~CFG_VALID;
-		def->flags &= ~CFG_VALID;
-	}
+	if (r)
+		handle->status[root_CFG_SECTION] |= CFG_VALID;
+	else
+		handle->status[root_CFG_SECTION] &= ~CFG_VALID;
+
 	return r;
 }
 
diff --git a/lib/config/config.h b/lib/config/config.h
index 483d8a5..5b402d7 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -79,10 +79,6 @@ typedef union {
 #define CFG_ADVANCED		0x04
 /* whether the configuraton item is not officially supported */
 #define CFG_UNSUPPORTED		0x08
-/* helper flag to mark the item as used in a config tree instance */
-#define CFG_USED		0x10
-/* helper flag to mark the item as valid in a config tree instance */
-#define CFG_VALID		0x20
 
 /* configuration definition item structure */
 typedef struct cfg_def_item {
@@ -113,6 +109,12 @@ struct config_def_tree_spec {
 	int ignoreunsupported;		/* do not include unsupported configs */
 };
 
+
+/* flag to mark the item as used in a config tree instance during validation */
+#define CFG_USED		0x01
+/* flag to mark the item as valid in a config tree instance during validation */
+#define CFG_VALID		0x02
+
 /*
  * Register ID for each possible item in the configuration tree.
  */
@@ -126,10 +128,19 @@ enum {
 #undef cfg_array
 };
 
+/* configuration check handle for each instance of the validation check */
+struct cft_check_handle {
+	struct dm_config_tree *cft;	/* the tree for which the check is done */
+	unsigned force_check:1;		/* force check even if disabled by config/checks setting */
+	unsigned skip_if_checked:1;	/* skip the check if already done before - return last state */
+	unsigned suppress_messages:1;	/* suppress messages during the check if config item is found invalid */
+	uint8_t status[CFG_COUNT];	/* flags for each configuration item - the result of the check */
+};
+
 struct profile *load_profile(struct cmd_context *cmd, const char *profile_name);
 
 int config_def_get_path(char *buf, size_t buf_size, int id);
-int config_def_check(struct cmd_context *cmd, int force, int skip, int suppress_messages);
+int config_def_check(struct cmd_context *cmd, struct cft_check_handle *handle);
 
 int override_config_tree_from_string(struct cmd_context *cmd, const char *config_settings);
 int override_config_tree_from_profile(struct cmd_context *cmd, struct profile *profile);
diff --git a/tools/dumpconfig.c b/tools/dumpconfig.c
index 9ba451e..2d6cbe3 100644
--- a/tools/dumpconfig.c
+++ b/tools/dumpconfig.c
@@ -31,6 +31,22 @@ static int _get_vsn(struct cmd_context *cmd, unsigned int *major,
 	return 1;
 }
 
+static struct cft_check_handle *_get_cft_check_handle(struct cmd_context *cmd)
+{
+	struct cft_check_handle *handle = cmd->cft_check_handle;
+
+	if (!handle) {
+		if (!(handle = dm_pool_zalloc(cmd->libmem, sizeof(*cmd->cft_check_handle)))) {
+			log_error("Configuration check handle allocation failed.");
+			return NULL;
+		}
+		handle->cft = cmd->cft;
+		cmd->cft_check_handle = handle;
+	}
+
+	return handle;
+}
+
 int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 {
 	const char *file = arg_str_value(cmd, file_ARG, NULL);
@@ -38,6 +54,7 @@ int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 	unsigned int major, minor, patchlevel;
 	struct config_def_tree_spec tree_spec = {0};
 	struct dm_config_tree *cft = cmd->cft;
+	struct cft_check_handle *cft_check_handle;
 	int r = ECMD_PROCESSED;
 
 	if (arg_count(cmd, configtype_ARG) && arg_count(cmd, validate_ARG)) {
@@ -57,7 +74,14 @@ int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 		tree_spec.ignoreunsupported = 1;
 
 	if (arg_count(cmd, validate_ARG)) {
-		if (config_def_check(cmd, 1, 1, 0)) {
+		if (!(cft_check_handle = _get_cft_check_handle(cmd)))
+			return ECMD_FAILED;
+
+		cft_check_handle->force_check = 1;
+		cft_check_handle->skip_if_checked = 1;
+		cft_check_handle->suppress_messages = 0;
+
+		if (config_def_check(cmd, cft_check_handle)) {
 			log_print("LVM configuration valid.");
 			return ECMD_PROCESSED;
 		} else {
@@ -72,7 +96,15 @@ int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 			return EINVALID_CMD_LINE;
 		}
 		tree_spec.type = CFG_DEF_TREE_CURRENT;
-		config_def_check(cmd, 1, 1, 1);
+
+		if (!(cft_check_handle = _get_cft_check_handle(cmd)))
+			return ECMD_FAILED;
+
+		cft_check_handle->force_check = 1;
+		cft_check_handle->skip_if_checked = 1;
+		cft_check_handle->suppress_messages = 1;
+
+		config_def_check(cmd, cft_check_handle);
 	}
 
 	else if (!strcmp(type, "default"))


