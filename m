From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  6 Mar 2014 11:20:55 +0000 (UTC)
Subject: master - config: use mempool for config paths used in find_config_tree_* functions
Message-ID: <20140306112055.5310A60DA7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e2870c94cf501f15ff9b1201bf468b40c1efd6d3
Commit:        e2870c94cf501f15ff9b1201bf468b40c1efd6d3
Parent:        c5a4e60c112893b5624cede0dac89bd5de7e14a4
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Mar 3 12:29:25 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Mar 6 10:50:47 2014 +0100

config: use mempool for config paths used in find_config_tree_* functions

Using mempool is much safer than using the global static variable.
The global variable would be rewritten on each find_config_tree_* call
and we need to be very careful not to get into this problem (we don't
do now, but we can with the patches for "runtime defaults" that will follow).
---
 lib/commands/toolcontext.c |   10 +++---
 lib/config/config.c        |   68 +++++++++++++++++++++++++++++--------------
 2 files changed, 51 insertions(+), 27 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index a709284..ce1f5af 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1479,6 +1479,11 @@ struct cmd_context *create_toolcontext(unsigned is_long_lived,
 		goto out;
 	}
 
+	if (!(cmd->mem = dm_pool_create("command", 4 * 1024))) {
+		log_error("Command memory pool creation failed");
+		goto out;
+	}
+
 	if (!_init_lvm_conf(cmd))
 		goto_out;
 
@@ -1512,11 +1517,6 @@ struct cmd_context *create_toolcontext(unsigned is_long_lived,
 	if (!_init_filters(cmd, 1))
 		goto_out;
 
-	if (!(cmd->mem = dm_pool_create("command", 4 * 1024))) {
-		log_error("Command memory pool creation failed");
-		goto out;
-	}
-
 	memlock_init(cmd);
 
 	if (!_init_formats(cmd))
diff --git a/lib/config/config.c b/lib/config/config.c
index e51c26f..cef00a0 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -56,8 +56,6 @@ struct config_source {
 	} source;
 };
 
-char _cfg_path[CFG_PATH_MAX_LEN];
-
 /*
  * Map each ID to respective definition of the configuration item.
  */
@@ -477,8 +475,6 @@ time_t config_file_timestamp(struct dm_config_tree *cft)
 
 #define cfg_def_get_item_p(id) (&_cfg_def_items[id])
 #define cfg_def_get_default_value(item,type) item->default_value.v_##type
-#define cfg_def_get_path(item) (_cfg_def_make_path(_cfg_path,CFG_PATH_MAX_LEN,item->id,item, 0),_cfg_path)
-#define cfg_def_get_path_xlated(item) (_cfg_def_make_path(_cfg_path,CFG_PATH_MAX_LEN,item->id,item, 1),_cfg_path)
 
 static int _cfg_def_make_path(char *buf, size_t buf_size, int id, cfg_def_item_t *item, int xlate)
 {
@@ -504,6 +500,21 @@ static int _cfg_def_make_path(char *buf, size_t buf_size, int id, cfg_def_item_t
 	return count + n;
 }
 
+static char *_cfg_def_get_path(struct dm_pool *mem, cfg_def_item_t *item, int xlate)
+{
+	char *path;
+
+	if (!(path = dm_pool_alloc(mem, CFG_PATH_MAX_LEN))) {
+		log_error("Failed to allocate buffer for configuration path.");
+		return NULL;
+	}
+
+	if (!_cfg_def_make_path(path, CFG_PATH_MAX_LEN, item->id, item, xlate))
+		return_0;
+
+	return path;
+}
+
 int config_def_get_path(char *buf, size_t buf_size, int id)
 {
 	return _cfg_def_make_path(buf, buf_size, id, cfg_def_get_item_p(id), 0);
@@ -702,7 +713,7 @@ int config_def_check(struct cmd_context *cmd, struct cft_check_handle *handle)
 {
 	cfg_def_item_t *def;
 	struct dm_config_node *cn;
-	char *vp = _cfg_path, rp[CFG_PATH_MAX_LEN];
+	char vp[CFG_PATH_MAX_LEN], rp[CFG_PATH_MAX_LEN];
 	size_t rplen;
 	int id, r = 1;
 
@@ -742,7 +753,7 @@ int config_def_check(struct cmd_context *cmd, struct cft_check_handle *handle)
 		}
 		for (id = 1; id < CFG_COUNT; id++) {
 			def = cfg_def_get_item_p(id);
-			if (!cfg_def_get_path(def)) {
+			if (!_cfg_def_make_path(vp, CFG_PATH_MAX_LEN, def->id, def, 0)) {
 				dm_hash_destroy(cmd->cft_def_hash);
 				cmd->cft_def_hash = NULL;
 				r = 0; goto out;
@@ -800,31 +811,35 @@ out:
 
 const struct dm_config_node *find_config_tree_node(struct cmd_context *cmd, int id, struct profile *profile)
 {
+	char *path;
 	int profile_applied = 0;
 	const struct dm_config_node *cn;
 
 	if (profile && !cmd->profile_params->global_profile)
 		profile_applied = override_config_tree_from_profile(cmd, profile);
 
-	cn = dm_config_tree_find_node(cmd->cft, cfg_def_get_path(cfg_def_get_item_p(id)));
+	path = _cfg_def_get_path(cmd->mem, cfg_def_get_item_p(id), 0);
+
+	cn = dm_config_tree_find_node(cmd->cft, path);
 
 	if (profile_applied)
 		remove_config_tree_by_source(cmd, CONFIG_PROFILE);
 
+	dm_pool_free(cmd->mem, path);
 	return cn;
 }
 
 const char *find_config_tree_str(struct cmd_context *cmd, int id, struct profile *profile)
 {
 	cfg_def_item_t *item = cfg_def_get_item_p(id);
-	const char *path;
+	char *path;
 	int profile_applied = 0;
 	const char *str;
 
 	if (profile && !cmd->profile_params->global_profile)
 		profile_applied = override_config_tree_from_profile(cmd, profile);
 
-	path = cfg_def_get_path(item);
+	path = _cfg_def_get_path(cmd->mem, item, 0);
 
 	if (item->type != CFG_TYPE_STRING)
 		log_error(INTERNAL_ERROR "%s cfg tree element not declared as string.", path);
@@ -834,20 +849,21 @@ const char *find_config_tree_str(struct cmd_context *cmd, int id, struct profile
 	if (profile_applied)
 		remove_config_tree_by_source(cmd, CONFIG_PROFILE);
 
+	dm_pool_free(cmd->mem, path);
 	return str;
 }
 
 const char *find_config_tree_str_allow_empty(struct cmd_context *cmd, int id, struct profile *profile)
 {
 	cfg_def_item_t *item = cfg_def_get_item_p(id);
-	const char *path;
+	char *path;
 	int profile_applied = 0;
 	const char *str;
 
 	if (profile && !cmd->profile_params->global_profile)
 		profile_applied = override_config_tree_from_profile(cmd, profile);
 
-	path = cfg_def_get_path(item);
+	path = _cfg_def_get_path(cmd->mem, item, 0);
 
 	if (item->type != CFG_TYPE_STRING)
 		log_error(INTERNAL_ERROR "%s cfg tree element not declared as string.", path);
@@ -859,20 +875,21 @@ const char *find_config_tree_str_allow_empty(struct cmd_context *cmd, int id, st
 	if (profile_applied)
 		remove_config_tree_by_source(cmd, CONFIG_PROFILE);
 
+	dm_pool_free(cmd->mem, path);
 	return str;
 }
 
 int find_config_tree_int(struct cmd_context *cmd, int id, struct profile *profile)
 {
 	cfg_def_item_t *item = cfg_def_get_item_p(id);
-	const char *path;
+	char *path;
 	int profile_applied = 0;
 	int i;
 
 	if (profile && !cmd->profile_params->global_profile)
 		profile_applied = override_config_tree_from_profile(cmd, profile);
 
-	path = cfg_def_get_path(item);
+	path = _cfg_def_get_path(cmd->mem, item, 0);
 
 	if (item->type != CFG_TYPE_INT)
 		log_error(INTERNAL_ERROR "%s cfg tree element not declared as integer.", path);
@@ -882,20 +899,21 @@ int find_config_tree_int(struct cmd_context *cmd, int id, struct profile *profil
 	if (profile_applied)
 		remove_config_tree_by_source(cmd, CONFIG_PROFILE);
 
+	dm_pool_free(cmd->mem, path);
 	return i;
 }
 
 int64_t find_config_tree_int64(struct cmd_context *cmd, int id, struct profile *profile)
 {
 	cfg_def_item_t *item = cfg_def_get_item_p(id);
-	const char *path;
+	char *path;
 	int profile_applied = 0;
 	int i64;
 
 	if (profile && !cmd->profile_params->global_profile)
 		profile_applied = override_config_tree_from_profile(cmd, profile);
 
-	path = cfg_def_get_path(item);
+	path = _cfg_def_get_path(cmd->mem, item, 0);
 
 	if (item->type != CFG_TYPE_INT)
 		log_error(INTERNAL_ERROR "%s cfg tree element not declared as integer.", path);
@@ -905,20 +923,21 @@ int64_t find_config_tree_int64(struct cmd_context *cmd, int id, struct profile *
 	if (profile_applied)
 		remove_config_tree_by_source(cmd, CONFIG_PROFILE);
 
+	dm_pool_free(cmd->mem, path);
 	return i64;
 }
 
 float find_config_tree_float(struct cmd_context *cmd, int id, struct profile *profile)
 {
 	cfg_def_item_t *item = cfg_def_get_item_p(id);
-	const char *path;
+	char *path;
 	int profile_applied = 0;
 	float f;
 
 	if (profile && !cmd->profile_params->global_profile)
 		profile_applied = override_config_tree_from_profile(cmd, profile);
 
-	path = cfg_def_get_path(item);
+	path = _cfg_def_get_path(cmd->mem, item, 0);
 
 	if (item->type != CFG_TYPE_FLOAT)
 		log_error(INTERNAL_ERROR "%s cfg tree element not declared as float.", path);
@@ -928,20 +947,21 @@ float find_config_tree_float(struct cmd_context *cmd, int id, struct profile *pr
 	if (profile_applied)
 		remove_config_tree_by_source(cmd, CONFIG_PROFILE);
 
+	dm_pool_free(cmd->mem, path);
 	return f;
 }
 
 int find_config_tree_bool(struct cmd_context *cmd, int id, struct profile *profile)
 {
 	cfg_def_item_t *item = cfg_def_get_item_p(id);
-	const char *path = cfg_def_get_path(item);
+	char *path;
 	int profile_applied = 0;
 	int b;
 
 	if (profile && !cmd->profile_params->global_profile)
 		profile_applied = override_config_tree_from_profile(cmd, profile);
 
-	path = cfg_def_get_path(item);
+	path = _cfg_def_get_path(cmd->mem, item, 0);
 
 	if (item->type != CFG_TYPE_BOOL)
 		log_error(INTERNAL_ERROR "%s cfg tree element not declared as boolean.", path);
@@ -951,6 +971,7 @@ int find_config_tree_bool(struct cmd_context *cmd, int id, struct profile *profi
 	if (profile_applied)
 		remove_config_tree_by_source(cmd, CONFIG_PROFILE);
 
+	dm_pool_free(cmd->mem, path);
 	return b;
 }
 
@@ -1091,6 +1112,7 @@ int merge_config_tree(struct cmd_context *cmd, struct dm_config_tree *cft,
 struct out_baton {
 	FILE *fp;
 	struct config_def_tree_spec *tree_spec;
+	struct dm_pool *mem;
 };
 
 static int _out_prefix_fn(const struct dm_config_node *cn, const char *line, void *baton)
@@ -1098,8 +1120,8 @@ static int _out_prefix_fn(const struct dm_config_node *cn, const char *line, voi
 	struct out_baton *out = baton;
 	struct cfg_def_item *cfg_def;
 	char version[9]; /* 8+1 chars for max version of 7.15.511 */
-	const char *path;
 	const char *node_type_name = cn->v ? "option" : "section";
+	char *path;
 
 	if (cn->id < 0)
 		return 1;
@@ -1112,8 +1134,9 @@ static int _out_prefix_fn(const struct dm_config_node *cn, const char *line, voi
 	cfg_def = cfg_def_get_item_p(cn->id);
 
 	if (out->tree_spec->withcomments) {
-		path = cfg_def_get_path_xlated(cfg_def);
+		path = _cfg_def_get_path(out->mem, cfg_def, 1);
 		fprintf(out->fp, "%s# Configuration %s %s.\n", line, node_type_name, path);
+		dm_pool_free(out->mem, path);
 
 		if (cfg_def->comment)
 			fprintf(out->fp, "%s# %s\n", line, cfg_def->comment);
@@ -1171,7 +1194,8 @@ int config_write(struct dm_config_tree *cft,
 	};
 	const struct dm_config_node *cn;
 	struct out_baton baton = {
-		.tree_spec = tree_spec
+		.tree_spec = tree_spec,
+		.mem = cft->mem
 	};
 	int r = 1;
 


