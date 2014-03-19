From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 19 Mar 2014 07:47:47 +0000 (UTC)
Subject: master - cleanup: add cmd_context reference to struct cft_check_handle
Message-ID: <20140319074747.1410260370@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=000e81a999a456a6db2de1aef70a147b00fb7491
Commit:        000e81a999a456a6db2de1aef70a147b00fb7491
Parent:        b6eb2ac10ab509a74f83b9333ff195b63d64d8ef
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Mar 19 08:45:05 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Mar 19 08:45:05 2014 +0100

cleanup: add cmd_context reference to struct cft_check_handle

So we have all things needed to do a configuration check packaged
in one handle. It makes function calls inside a bit more readable.
---
 lib/commands/toolcontext.c |    3 +-
 lib/config/config.c        |   56 +++++++++++++++++++++----------------------
 lib/config/config.h        |    3 +-
 tools/dumpconfig.c         |    5 ++-
 4 files changed, 34 insertions(+), 33 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index e620884..899666c 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -269,8 +269,9 @@ static int _check_config(struct cmd_context *cmd)
 	}
 
 	cmd->cft_check_handle->cft = cmd->cft;
+	cmd->cft_check_handle->cmd = cmd;
 
-	if (!config_def_check(cmd, cmd->cft_check_handle) &&
+	if (!config_def_check(cmd->cft_check_handle) &&
 	    find_config_tree_bool(cmd, config_abort_on_errors_CFG, NULL)) {
 		log_error("LVM configuration invalid.");
 		return 0;
diff --git a/lib/config/config.c b/lib/config/config.c
index 38d3f0b..ba1e280 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -537,17 +537,18 @@ static void _log_type_error(const char *path, cfg_def_type_t actual,
 					     actual_type_name, expected_type_name);
 }
 
-static int _config_def_check_node_single_value(const char *rp, const struct dm_config_value *v,
-					       const cfg_def_item_t *def, int suppress_messages)
+static int _config_def_check_node_single_value(struct cft_check_handle *handle,
+					       const char *rp, const struct dm_config_value *v,
+					       const cfg_def_item_t *def)
 {
 	/* Check empty array first if present. */
 	if (v->type == DM_CFG_EMPTY_ARRAY) {
 		if (!(def->type & CFG_TYPE_ARRAY)) {
-			_log_type_error(rp, CFG_TYPE_ARRAY, def->type, suppress_messages);
+			_log_type_error(rp, CFG_TYPE_ARRAY, def->type, handle->suppress_messages);
 			return 0;
 		}
 		if (!(def->flags & CFG_ALLOW_EMPTY)) {
-			log_warn_suppress(suppress_messages,
+			log_warn_suppress(handle->suppress_messages,
 				"Configuration setting \"%s\" invalid. Empty value not allowed.", rp);
 			return 0;
 		}
@@ -557,20 +558,20 @@ static int _config_def_check_node_single_value(const char *rp, const struct dm_c
 	switch (v->type) {
 		case DM_CFG_INT:
 			if (!(def->type & CFG_TYPE_INT) && !(def->type & CFG_TYPE_BOOL)) {
-				_log_type_error(rp, CFG_TYPE_INT, def->type, suppress_messages);
+				_log_type_error(rp, CFG_TYPE_INT, def->type, handle->suppress_messages);
 				return 0;
 			}
 			break;
 		case DM_CFG_FLOAT:
 			if (!(def->type & CFG_TYPE_FLOAT)) {
-				_log_type_error(rp, CFG_TYPE_FLOAT, def->type, suppress_messages);
+				_log_type_error(rp, CFG_TYPE_FLOAT, def->type, handle-> suppress_messages);
 				return 0;
 			}
 			break;
 		case DM_CFG_STRING:
 			if (def->type & CFG_TYPE_BOOL) {
 				if (!dm_config_value_is_bool(v)) {
-					log_warn_suppress(suppress_messages,
+					log_warn_suppress(handle->suppress_messages,
 						"Configuration setting \"%s\" invalid. "
 						"Found string value \"%s\", "
 						"expected boolean value: 0/1, \"y/n\", "
@@ -579,7 +580,7 @@ static int _config_def_check_node_single_value(const char *rp, const struct dm_c
 					return 0;
 				}
 			} else if  (!(def->type & CFG_TYPE_STRING)) {
-				_log_type_error(rp, CFG_TYPE_STRING, def->type, suppress_messages);
+				_log_type_error(rp, CFG_TYPE_STRING, def->type, handle->suppress_messages);
 				return 0;
 			}
 			break;
@@ -609,7 +610,7 @@ static int _config_def_check_node_value(struct cft_check_handle *handle,
 	}
 
 	do {
-		if (!_config_def_check_node_single_value(rp, v, def, handle->suppress_messages))
+		if (!_config_def_check_node_single_value(handle, rp, v, def))
 			return 0;
 		v = v->next;
 	} while (v);
@@ -619,8 +620,7 @@ static int _config_def_check_node_value(struct cft_check_handle *handle,
 
 static int _config_def_check_node(struct cft_check_handle *handle,
 				  const char *vp, char *pvp, char *rp, char *prp,
-				  size_t buf_size, struct dm_config_node *cn,
-				  struct dm_hash_table *ht)
+				  size_t buf_size, struct dm_config_node *cn)
 {
 	cfg_def_item_t *def;
 	int sep = vp != pvp; /* don't use '/' separator for top-level node */
@@ -632,7 +632,7 @@ static int _config_def_check_node(struct cft_check_handle *handle,
 	}
 
 
-	if (!(def = (cfg_def_item_t *) dm_hash_lookup(ht, vp))) {
+	if (!(def = (cfg_def_item_t *) dm_hash_lookup(handle->cmd->cft_def_hash, vp))) {
 		/* If the node is not a section but a setting, fail now. */
 		if (cn->v) {
 			log_warn_suppress(handle->suppress_messages,
@@ -645,7 +645,7 @@ static int _config_def_check_node(struct cft_check_handle *handle,
 		/* Modify virtual path vp in situ and replace the key name with a '#'. */
 		/* The real path without '#' is still stored in rp variable. */
 		pvp[sep] = '#', pvp[sep + 1] = '\0';
-		if (!(def = (cfg_def_item_t *) dm_hash_lookup(ht, vp))) {
+		if (!(def = (cfg_def_item_t *) dm_hash_lookup(handle->cmd->cft_def_hash, vp))) {
 			log_warn_suppress(handle->suppress_messages,
 				"Configuration section \"%s\" unknown.", rp);
 			cn->id = -1;
@@ -678,8 +678,7 @@ static int _config_def_check_node(struct cft_check_handle *handle,
 
 static int _config_def_check_tree(struct cft_check_handle *handle,
 				  const char *vp, char *pvp, char *rp, char *prp,
-				  size_t buf_size, struct dm_config_node *root,
-				  struct dm_hash_table *ht)
+				  size_t buf_size, struct dm_config_node *root)
 {
 	struct dm_config_node *cn;
 	int valid, r = 1;
@@ -687,10 +686,10 @@ static int _config_def_check_tree(struct cft_check_handle *handle,
 
 	for (cn = root->child; cn; cn = cn->sib) {
 		if ((valid = _config_def_check_node(handle, vp, pvp, rp, prp,
-					buf_size, cn, ht)) && !cn->v) {
+						    buf_size, cn)) && !cn->v) {
 			len = strlen(rp);
 			valid = _config_def_check_tree(handle, vp, pvp + strlen(pvp),
-					rp, prp + len, buf_size - len, cn, ht);
+						       rp, prp + len, buf_size - len, cn);
 		}
 		if (!valid)
 			r = 0;
@@ -699,7 +698,7 @@ static int _config_def_check_tree(struct cft_check_handle *handle,
 	return r;
 }
 
-int config_def_check(struct cmd_context *cmd, struct cft_check_handle *handle)
+int config_def_check(struct cft_check_handle *handle)
 {
 	cfg_def_item_t *def;
 	struct dm_config_node *cn;
@@ -724,7 +723,7 @@ int config_def_check(struct cmd_context *cmd, struct cft_check_handle *handle)
 		return handle->status[root_CFG_SECTION] & CFG_VALID;
 
 	/* Nothing to do if checks are disabled and also not forced. */
-	if (!handle->force_check && !find_config_tree_bool(cmd, config_checks_CFG, NULL))
+	if (!handle->force_check && !find_config_tree_bool(handle->cmd, config_checks_CFG, NULL))
 		return 1;
 
 	/* Clear 'used' and 'valid' status flags. */
@@ -736,19 +735,19 @@ int config_def_check(struct cmd_context *cmd, struct cft_check_handle *handle)
 	 * sections and settings with full path as a key.
 	 * If section name is variable, use '#' as a substitute.
 	 */
-	if (!cmd->cft_def_hash) {
-		if (!(cmd->cft_def_hash = dm_hash_create(64))) {
+	if (!handle->cmd->cft_def_hash) {
+		if (!(handle->cmd->cft_def_hash = dm_hash_create(64))) {
 			log_error("Failed to create configuration definition hash.");
 			r = 0; goto out;
 		}
 		for (id = 1; id < CFG_COUNT; id++) {
 			def = cfg_def_get_item_p(id);
 			if (!_cfg_def_make_path(vp, CFG_PATH_MAX_LEN, def->id, def, 0)) {
-				dm_hash_destroy(cmd->cft_def_hash);
-				cmd->cft_def_hash = NULL;
+				dm_hash_destroy(handle->cmd->cft_def_hash);
+				handle->cmd->cft_def_hash = NULL;
 				r = 0; goto out;
 			}
-			if (!dm_hash_insert(cmd->cft_def_hash, vp, def)) {
+			if (!dm_hash_insert(handle->cmd->cft_def_hash, vp, def)) {
 				log_error("Failed to insert configuration to hash.");
 				r = 0;
 				goto out;
@@ -772,16 +771,14 @@ int config_def_check(struct cmd_context *cmd, struct cft_check_handle *handle)
 		if (!cn->v) {
 			/* top level node: vp=vp, rp=rp */
 			if (!_config_def_check_node(handle, vp, vp, rp, rp,
-						    CFG_PATH_MAX_LEN,
-						    cn, cmd->cft_def_hash)) {
+						    CFG_PATH_MAX_LEN, cn)) {
 				r = 0; continue;
 			}
 			rplen = strlen(rp);
 			if (!_config_def_check_tree(handle,
 						    vp, vp + strlen(vp),
 						    rp, rp + rplen,
-						    CFG_PATH_MAX_LEN - rplen,
-						    cn, cmd->cft_def_hash))
+						    CFG_PATH_MAX_LEN - rplen, cn))
 				r = 0;
 		} else {
 			log_error_suppress(handle->suppress_messages,
@@ -1478,6 +1475,7 @@ static int _check_profile(struct cmd_context *cmd, struct profile *profile)
 		return 0;
 	}
 
+	handle->cmd = cmd;
 	handle->cft = profile->cft;
 	handle->source = CONFIG_PROFILE;
 	/* the check is compulsory - allow only profilable items in a profile config! */
@@ -1485,7 +1483,7 @@ static int _check_profile(struct cmd_context *cmd, struct profile *profile)
 	/* provide warning messages only if config/checks=1 */
 	handle->suppress_messages = !find_config_tree_bool(cmd, config_checks_CFG, NULL);
 
-	r = config_def_check(cmd, handle);
+	r = config_def_check(handle);
 
 	dm_pool_free(cmd->libmem, handle);
 	return r;
diff --git a/lib/config/config.h b/lib/config/config.h
index 5bfa345..e5bcab8 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -165,6 +165,7 @@ int load_pending_profiles(struct cmd_context *cmd);
 
 /* configuration check handle for each instance of the validation check */
 struct cft_check_handle {
+	struct cmd_context *cmd;	/* command context */
 	struct dm_config_tree *cft;	/* the tree for which the check is done */
 	config_source_t source;		/* configuration source */
 	unsigned force_check:1;		/* force check even if disabled by config/checks setting */
@@ -174,7 +175,7 @@ struct cft_check_handle {
 };
 
 int config_def_get_path(char *buf, size_t buf_size, int id);
-int config_def_check(struct cmd_context *cmd, struct cft_check_handle *handle);
+int config_def_check(struct cft_check_handle *handle);
 
 int override_config_tree_from_string(struct cmd_context *cmd, const char *config_settings);
 int override_config_tree_from_profile(struct cmd_context *cmd, struct profile *profile);
diff --git a/tools/dumpconfig.c b/tools/dumpconfig.c
index d9aebd9..7404462 100644
--- a/tools/dumpconfig.c
+++ b/tools/dumpconfig.c
@@ -47,6 +47,7 @@ static struct cft_check_handle *_get_cft_check_handle(struct cmd_context *cmd, s
 			log_error("Configuration check handle allocation failed.");
 			return NULL;
 		}
+		handle->cmd = cmd;
 		handle->cft = cft;
 		if (cft == cmd->cft)
 			cmd->cft_check_handle = handle;
@@ -67,7 +68,7 @@ static int _do_def_check(struct cmd_context *cmd, struct dm_config_tree *cft,
 	handle->skip_if_checked = 1;
 	handle->suppress_messages = 1;
 
-	config_def_check(cmd, handle);
+	config_def_check(handle);
 	*cft_check_handle = handle;
 
 	return 1;
@@ -155,7 +156,7 @@ int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 		cft_check_handle->skip_if_checked = 1;
 		cft_check_handle->suppress_messages = 0;
 
-		if (config_def_check(cmd, cft_check_handle)) {
+		if (config_def_check(cft_check_handle)) {
 			log_print("LVM configuration valid.");
 			goto out;
 		} else {


