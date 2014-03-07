From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  7 Mar 2014 16:50:41 +0000 (UTC)
Subject: master - config: use small local static buffer instead of mempool for temporary config path
Message-ID: <20140307165041.2F5E36025E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=eeff7729d9a48b07bc650c552ec7a03b064c3bc9
Commit:        eeff7729d9a48b07bc650c552ec7a03b064c3bc9
Parent:        7409009a20d7c24ddb02f8f792fe4bbd6f2b3e97
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Mar 7 17:44:36 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Mar 7 17:50:01 2014 +0100

config: use small local static buffer instead of mempool for temporary config path

We can't use mempool for temporary variable for configuration path inside
find_config_tree_* functions since these functions can use the mempool
themselves deeper in the code and we can free mempool chunks only from
top to bottom which is not the case here (some default string
configuration values can be allocated from the mempool).
---
 lib/config/config.c |   58 +++++++++++++++-----------------------------------
 1 files changed, 18 insertions(+), 40 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index b6158bc..3c28321 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -505,21 +505,6 @@ static int _cfg_def_make_path(char *buf, size_t buf_size, int id, cfg_def_item_t
 	return count + n;
 }
 
-static char *_cfg_def_get_path(struct dm_pool *mem, cfg_def_item_t *item, int xlate)
-{
-	char *path;
-
-	if (!(path = dm_pool_alloc(mem, CFG_PATH_MAX_LEN))) {
-		log_error("Failed to allocate buffer for configuration path.");
-		return NULL;
-	}
-
-	if (!_cfg_def_make_path(path, CFG_PATH_MAX_LEN, item->id, item, xlate))
-		return_0;
-
-	return path;
-}
-
 int config_def_get_path(char *buf, size_t buf_size, int id)
 {
 	return _cfg_def_make_path(buf, buf_size, id, cfg_def_get_item_p(id), 0);
@@ -816,35 +801,34 @@ out:
 
 const struct dm_config_node *find_config_tree_node(struct cmd_context *cmd, int id, struct profile *profile)
 {
-	char *path;
+	cfg_def_item_t *item = cfg_def_get_item_p(id);
+	char path[CFG_PATH_MAX_LEN];
 	int profile_applied = 0;
 	const struct dm_config_node *cn;
 
 	if (profile && !cmd->profile_params->global_profile)
 		profile_applied = override_config_tree_from_profile(cmd, profile);
 
-	path = _cfg_def_get_path(cmd->mem, cfg_def_get_item_p(id), 0);
-
+	_cfg_def_make_path(path, sizeof(path), item->id, item, 0);
 	cn = dm_config_tree_find_node(cmd->cft, path);
 
 	if (profile_applied)
 		remove_config_tree_by_source(cmd, CONFIG_PROFILE);
 
-	dm_pool_free(cmd->mem, path);
 	return cn;
 }
 
 const char *find_config_tree_str(struct cmd_context *cmd, int id, struct profile *profile)
 {
 	cfg_def_item_t *item = cfg_def_get_item_p(id);
-	char *path;
+	char path[CFG_PATH_MAX_LEN];
 	int profile_applied = 0;
 	const char *str;
 
 	if (profile && !cmd->profile_params->global_profile)
 		profile_applied = override_config_tree_from_profile(cmd, profile);
 
-	path = _cfg_def_get_path(cmd->mem, item, 0);
+	_cfg_def_make_path(path, sizeof(path), item->id, item, 0);
 
 	if (item->type != CFG_TYPE_STRING)
 		log_error(INTERNAL_ERROR "%s cfg tree element not declared as string.", path);
@@ -854,21 +838,20 @@ const char *find_config_tree_str(struct cmd_context *cmd, int id, struct profile
 	if (profile_applied)
 		remove_config_tree_by_source(cmd, CONFIG_PROFILE);
 
-	dm_pool_free(cmd->mem, path);
 	return str;
 }
 
 const char *find_config_tree_str_allow_empty(struct cmd_context *cmd, int id, struct profile *profile)
 {
 	cfg_def_item_t *item = cfg_def_get_item_p(id);
-	char *path;
+	char path[CFG_PATH_MAX_LEN];
 	int profile_applied = 0;
 	const char *str;
 
 	if (profile && !cmd->profile_params->global_profile)
 		profile_applied = override_config_tree_from_profile(cmd, profile);
 
-	path = _cfg_def_get_path(cmd->mem, item, 0);
+	_cfg_def_make_path(path, sizeof(path), item->id, item, 0);
 
 	if (item->type != CFG_TYPE_STRING)
 		log_error(INTERNAL_ERROR "%s cfg tree element not declared as string.", path);
@@ -880,21 +863,20 @@ const char *find_config_tree_str_allow_empty(struct cmd_context *cmd, int id, st
 	if (profile_applied)
 		remove_config_tree_by_source(cmd, CONFIG_PROFILE);
 
-	dm_pool_free(cmd->mem, path);
 	return str;
 }
 
 int find_config_tree_int(struct cmd_context *cmd, int id, struct profile *profile)
 {
 	cfg_def_item_t *item = cfg_def_get_item_p(id);
-	char *path;
+	char path[CFG_PATH_MAX_LEN];
 	int profile_applied = 0;
 	int i;
 
 	if (profile && !cmd->profile_params->global_profile)
 		profile_applied = override_config_tree_from_profile(cmd, profile);
 
-	path = _cfg_def_get_path(cmd->mem, item, 0);
+	_cfg_def_make_path(path, sizeof(path), item->id, item, 0);
 
 	if (item->type != CFG_TYPE_INT)
 		log_error(INTERNAL_ERROR "%s cfg tree element not declared as integer.", path);
@@ -904,21 +886,20 @@ int find_config_tree_int(struct cmd_context *cmd, int id, struct profile *profil
 	if (profile_applied)
 		remove_config_tree_by_source(cmd, CONFIG_PROFILE);
 
-	dm_pool_free(cmd->mem, path);
 	return i;
 }
 
 int64_t find_config_tree_int64(struct cmd_context *cmd, int id, struct profile *profile)
 {
 	cfg_def_item_t *item = cfg_def_get_item_p(id);
-	char *path;
+	char path[CFG_PATH_MAX_LEN];
 	int profile_applied = 0;
 	int i64;
 
 	if (profile && !cmd->profile_params->global_profile)
 		profile_applied = override_config_tree_from_profile(cmd, profile);
 
-	path = _cfg_def_get_path(cmd->mem, item, 0);
+	_cfg_def_make_path(path, sizeof(path), item->id, item, 0);
 
 	if (item->type != CFG_TYPE_INT)
 		log_error(INTERNAL_ERROR "%s cfg tree element not declared as integer.", path);
@@ -928,21 +909,20 @@ int64_t find_config_tree_int64(struct cmd_context *cmd, int id, struct profile *
 	if (profile_applied)
 		remove_config_tree_by_source(cmd, CONFIG_PROFILE);
 
-	dm_pool_free(cmd->mem, path);
 	return i64;
 }
 
 float find_config_tree_float(struct cmd_context *cmd, int id, struct profile *profile)
 {
 	cfg_def_item_t *item = cfg_def_get_item_p(id);
-	char *path;
+	char path[CFG_PATH_MAX_LEN];
 	int profile_applied = 0;
 	float f;
 
 	if (profile && !cmd->profile_params->global_profile)
 		profile_applied = override_config_tree_from_profile(cmd, profile);
 
-	path = _cfg_def_get_path(cmd->mem, item, 0);
+	_cfg_def_make_path(path, sizeof(path), item->id, item, 0);
 
 	if (item->type != CFG_TYPE_FLOAT)
 		log_error(INTERNAL_ERROR "%s cfg tree element not declared as float.", path);
@@ -952,21 +932,20 @@ float find_config_tree_float(struct cmd_context *cmd, int id, struct profile *pr
 	if (profile_applied)
 		remove_config_tree_by_source(cmd, CONFIG_PROFILE);
 
-	dm_pool_free(cmd->mem, path);
 	return f;
 }
 
 int find_config_tree_bool(struct cmd_context *cmd, int id, struct profile *profile)
 {
 	cfg_def_item_t *item = cfg_def_get_item_p(id);
-	char *path;
+	char path[CFG_PATH_MAX_LEN];
 	int profile_applied = 0;
 	int b;
 
 	if (profile && !cmd->profile_params->global_profile)
 		profile_applied = override_config_tree_from_profile(cmd, profile);
 
-	path = _cfg_def_get_path(cmd->mem, item, 0);
+	_cfg_def_make_path(path, sizeof(path), item->id, item, 0);
 
 	if (item->type != CFG_TYPE_BOOL)
 		log_error(INTERNAL_ERROR "%s cfg tree element not declared as boolean.", path);
@@ -976,7 +955,6 @@ int find_config_tree_bool(struct cmd_context *cmd, int id, struct profile *profi
 	if (profile_applied)
 		remove_config_tree_by_source(cmd, CONFIG_PROFILE);
 
-	dm_pool_free(cmd->mem, path);
 	return b;
 }
 
@@ -1126,7 +1104,8 @@ static int _out_prefix_fn(const struct dm_config_node *cn, const char *line, voi
 	struct cfg_def_item *cfg_def;
 	char version[9]; /* 8+1 chars for max version of 7.15.511 */
 	const char *node_type_name = cn->v ? "option" : "section";
-	char *path;
+	char path[CFG_PATH_MAX_LEN];
+
 
 	if (cn->id < 0)
 		return 1;
@@ -1139,9 +1118,8 @@ static int _out_prefix_fn(const struct dm_config_node *cn, const char *line, voi
 	cfg_def = cfg_def_get_item_p(cn->id);
 
 	if (out->tree_spec->withcomments) {
-		path = _cfg_def_get_path(out->mem, cfg_def, 1);
+		_cfg_def_make_path(path, sizeof(path), cfg_def->id, cfg_def, 0);
 		fprintf(out->fp, "%s# Configuration %s %s.\n", line, node_type_name, path);
-		dm_pool_free(out->mem, path);
 
 		if (cfg_def->comment)
 			fprintf(out->fp, "%s# %s\n", line, cfg_def->comment);


