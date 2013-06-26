From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 26 Jun 2013 14:55:56 +0000 (UTC)
Subject: dev-peter-config-profiles - config: add profile arg to find_config_tree_str_allow_empty
Message-ID: <20130626145556.C52E960F23@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=dfb16979f9b41bad89f364873a849fc75e907fa7
Commit:        dfb16979f9b41bad89f364873a849fc75e907fa7
Parent:        c7735b82bacd3263ac8a1bf42e81238458383b51
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jun 25 12:30:08 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jun 26 16:53:50 2013 +0200

config: add profile arg to find_config_tree_str_allow_empty

---
 lib/activate/dev_manager.c |    2 +-
 lib/commands/toolcontext.c |    2 +-
 lib/config/config.c        |   14 ++++++++++++--
 lib/config/config.h        |    2 +-
 4 files changed, 15 insertions(+), 5 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 7054656..d07e04a 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1560,7 +1560,7 @@ static int _thin_pool_callback(struct dm_tree_node *node,
 	const struct dm_config_node *cn;
 	const struct dm_config_value *cv;
 	const char *thin_check =
-		find_config_tree_str_allow_empty(data->pool_lv->vg->cmd, global_thin_check_executable_CFG);
+		find_config_tree_str_allow_empty(data->pool_lv->vg->cmd, global_thin_check_executable_CFG, NULL);
 	const struct logical_volume *mlv = first_seg(data->pool_lv)->metadata_lv;
 	size_t len = strlen(dmdir) + 2 * (strlen(mlv->vg->name) + strlen(mlv->name)) + 3;
 	char meta_path[len];
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index fda150e..b4434f7 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -203,7 +203,7 @@ static void _init_logging(struct cmd_context *cmd)
 	init_indent(find_config_tree_bool(cmd, log_indent_CFG));
 	init_abort_on_internal_errors(find_config_tree_bool(cmd, global_abort_on_internal_errors_CFG));
 
-	cmd->default_settings.msg_prefix = find_config_tree_str_allow_empty(cmd, log_prefix_CFG);
+	cmd->default_settings.msg_prefix = find_config_tree_str_allow_empty(cmd, log_prefix_CFG, NULL);
 	init_msg_prefix(cmd->default_settings.msg_prefix);
 
 	cmd->default_settings.cmd_name = find_config_tree_bool(cmd, log_command_names_CFG);
diff --git a/lib/config/config.c b/lib/config/config.c
index 0a08ac1..743d6f1 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -780,17 +780,27 @@ const char *find_config_tree_str(struct cmd_context *cmd, int id, struct profile
 	return str;
 }
 
-const char *find_config_tree_str_allow_empty(struct cmd_context *cmd, int id)
+const char *find_config_tree_str_allow_empty(struct cmd_context *cmd, int id, struct profile *profile)
 {
 	cfg_def_item_t *item = cfg_def_get_item_p(id);
 	const char *path = cfg_def_get_path(item);
+	int profile_applied = 0;
+	const char *str;
 
 	if (item->type != CFG_TYPE_STRING)
 		log_error(INTERNAL_ERROR "%s cfg tree element not declared as string.", path);
 	if (!(item->flags & CFG_ALLOW_EMPTY))
 		log_error(INTERNAL_ERROR "%s cfg tree element not declared to allow empty values.", path);
 
-	return dm_config_tree_find_str_allow_empty(cmd->cft, path, cfg_def_get_default_value(item, CFG_TYPE_STRING));
+	if (profile && !cmd->profile_params->global_profile)
+		profile_applied = override_config_tree_from_profile(cmd, profile);
+
+	str = dm_config_tree_find_str_allow_empty(cmd->cft, path, cfg_def_get_default_value(item, CFG_TYPE_STRING));
+
+	if (profile_applied)
+		remove_config_tree_by_source(cmd, CONFIG_PROFILE);
+
+	return str;
 }
 
 int find_config_tree_int(struct cmd_context *cmd, int id)
diff --git a/lib/config/config.h b/lib/config/config.h
index 039738f..d365df7 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -162,7 +162,7 @@ int merge_config_tree(struct cmd_context *cmd, struct dm_config_tree *cft,
  */
 const struct dm_config_node *find_config_tree_node(struct cmd_context *cmd, int id, struct profile *profile);
 const char *find_config_tree_str(struct cmd_context *cmd, int id, struct profile *profile);
-const char *find_config_tree_str_allow_empty(struct cmd_context *cmd, int id);
+const char *find_config_tree_str_allow_empty(struct cmd_context *cmd, int id, struct profile *profile);
 int find_config_tree_int(struct cmd_context *cmd, int id);
 int64_t find_config_tree_int64(struct cmd_context *cmd, int id);
 float find_config_tree_float(struct cmd_context *cmd, int id);


