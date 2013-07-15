From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 15 Jul 2013 11:37:13 +0000 (UTC)
Subject: master - fix: apply profile and then get the config path + auto_set_activation not profilable
Message-ID: <20130715113713.B539B61156@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a9dbe2c4fa5a9fa18fa1e0223a622708693be27a
Commit:        a9dbe2c4fa5a9fa18fa1e0223a622708693be27a
Parent:        eaa1f0eb15737e130a0a501905871400b66f68ff
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Jul 15 13:33:14 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jul 15 13:33:14 2013 +0200

fix: apply profile and then get the config path + auto_set_activation not profilable

cfg_def_get_path uses a global static var to store the result (for efficiency).
So we need to apply the profile first and then get the path for the config item
when calling find_config_tree_* fns.

Also activation/auto_set_activation is not profilable (at least not now,
maybe later if we need that).
---
 lib/config/config.c          |   58 +++++++++++++++++++++++++----------------
 lib/config/config_settings.h |    2 +-
 2 files changed, 36 insertions(+), 24 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index 7e79dd7..2c2d9a3 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -813,16 +813,18 @@ const struct dm_config_node *find_config_tree_node(struct cmd_context *cmd, int
 const char *find_config_tree_str(struct cmd_context *cmd, int id, struct profile *profile)
 {
 	cfg_def_item_t *item = cfg_def_get_item_p(id);
-	const char *path = cfg_def_get_path(item);
+	const char *path;
 	int profile_applied = 0;
 	const char *str;
 
-	if (item->type != CFG_TYPE_STRING)
-		log_error(INTERNAL_ERROR "%s cfg tree element not declared as string.", path);
-
 	if (profile && !cmd->profile_params->global_profile)
 		profile_applied = override_config_tree_from_profile(cmd, profile);
 
+	path = cfg_def_get_path(item);
+
+	if (item->type != CFG_TYPE_STRING)
+		log_error(INTERNAL_ERROR "%s cfg tree element not declared as string.", path);
+
 	str = dm_config_tree_find_str(cmd->cft, path, cfg_def_get_default_value(item, CFG_TYPE_STRING));
 
 	if (profile_applied)
@@ -834,18 +836,20 @@ const char *find_config_tree_str(struct cmd_context *cmd, int id, struct profile
 const char *find_config_tree_str_allow_empty(struct cmd_context *cmd, int id, struct profile *profile)
 {
 	cfg_def_item_t *item = cfg_def_get_item_p(id);
-	const char *path = cfg_def_get_path(item);
+	const char *path;
 	int profile_applied = 0;
 	const char *str;
 
+	if (profile && !cmd->profile_params->global_profile)
+		profile_applied = override_config_tree_from_profile(cmd, profile);
+
+	path = cfg_def_get_path(item);
+
 	if (item->type != CFG_TYPE_STRING)
 		log_error(INTERNAL_ERROR "%s cfg tree element not declared as string.", path);
 	if (!(item->flags & CFG_ALLOW_EMPTY))
 		log_error(INTERNAL_ERROR "%s cfg tree element not declared to allow empty values.", path);
 
-	if (profile && !cmd->profile_params->global_profile)
-		profile_applied = override_config_tree_from_profile(cmd, profile);
-
 	str = dm_config_tree_find_str_allow_empty(cmd->cft, path, cfg_def_get_default_value(item, CFG_TYPE_STRING));
 
 	if (profile_applied)
@@ -857,16 +861,18 @@ const char *find_config_tree_str_allow_empty(struct cmd_context *cmd, int id, st
 int find_config_tree_int(struct cmd_context *cmd, int id, struct profile *profile)
 {
 	cfg_def_item_t *item = cfg_def_get_item_p(id);
-	const char *path = cfg_def_get_path(item);
+	const char *path;
 	int profile_applied = 0;
 	int i;
 
-	if (item->type != CFG_TYPE_INT)
-		log_error(INTERNAL_ERROR "%s cfg tree element not declared as integer.", path);
-
 	if (profile && !cmd->profile_params->global_profile)
 		profile_applied = override_config_tree_from_profile(cmd, profile);
 
+	path = cfg_def_get_path(item);
+
+	if (item->type != CFG_TYPE_INT)
+		log_error(INTERNAL_ERROR "%s cfg tree element not declared as integer.", path);
+
 	i = dm_config_tree_find_int(cmd->cft, path, cfg_def_get_default_value(item, CFG_TYPE_INT));
 
 	if (profile_applied)
@@ -878,16 +884,18 @@ int find_config_tree_int(struct cmd_context *cmd, int id, struct profile *profil
 int64_t find_config_tree_int64(struct cmd_context *cmd, int id, struct profile *profile)
 {
 	cfg_def_item_t *item = cfg_def_get_item_p(id);
-	const char *path = cfg_def_get_path(item);
+	const char *path;
 	int profile_applied = 0;
 	int i64;
 
-	if (item->type != CFG_TYPE_INT)
-		log_error(INTERNAL_ERROR "%s cfg tree element not declared as integer.", path);
-
 	if (profile && !cmd->profile_params->global_profile)
 		profile_applied = override_config_tree_from_profile(cmd, profile);
 
+	path = cfg_def_get_path(item);
+
+	if (item->type != CFG_TYPE_INT)
+		log_error(INTERNAL_ERROR "%s cfg tree element not declared as integer.", path);
+
 	i64 = dm_config_tree_find_int64(cmd->cft, path, cfg_def_get_default_value(item, CFG_TYPE_INT));
 
 	if (profile_applied)
@@ -899,16 +907,18 @@ int64_t find_config_tree_int64(struct cmd_context *cmd, int id, struct profile *
 float find_config_tree_float(struct cmd_context *cmd, int id, struct profile *profile)
 {
 	cfg_def_item_t *item = cfg_def_get_item_p(id);
-	const char *path = cfg_def_get_path(item);
+	const char *path;
 	int profile_applied = 0;
 	float f;
 
-	if (item->type != CFG_TYPE_FLOAT)
-		log_error(INTERNAL_ERROR "%s cfg tree element not declared as float.", path);
-
 	if (profile && !cmd->profile_params->global_profile)
 		profile_applied = override_config_tree_from_profile(cmd, profile);
 
+	path = cfg_def_get_path(item);
+
+	if (item->type != CFG_TYPE_FLOAT)
+		log_error(INTERNAL_ERROR "%s cfg tree element not declared as float.", path);
+
 	f = dm_config_tree_find_float(cmd->cft, path, cfg_def_get_default_value(item, CFG_TYPE_FLOAT));
 
 	if (profile_applied)
@@ -924,12 +934,14 @@ int find_config_tree_bool(struct cmd_context *cmd, int id, struct profile *profi
 	int profile_applied = 0;
 	int b;
 
-	if (item->type != CFG_TYPE_BOOL)
-		log_error(INTERNAL_ERROR "%s cfg tree element not declared as boolean.", path);
-
 	if (profile && !cmd->profile_params->global_profile)
 		profile_applied = override_config_tree_from_profile(cmd, profile);
 
+	path = cfg_def_get_path(item);
+
+	if (item->type != CFG_TYPE_BOOL)
+		log_error(INTERNAL_ERROR "%s cfg tree element not declared as boolean.", path);
+
 	b = dm_config_tree_find_bool(cmd->cft, path, cfg_def_get_default_value(item, CFG_TYPE_BOOL));
 
 	if (profile_applied)
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index d2a6765..4d124c8 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -185,7 +185,7 @@ cfg_array(activation_mlock_filter_CFG, "mlock_filter", activation_CFG_SECTION, 0
 cfg(activation_use_mlockall_CFG, "use_mlockall", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_USE_MLOCKALL, vsn(2, 2, 62), NULL)
 cfg(activation_monitoring_CFG, "monitoring", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_DMEVENTD_MONITOR, vsn(2, 2, 63), NULL)
 cfg(activation_polling_interval_CFG, "polling_interval", activation_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_INTERVAL, vsn(2, 2, 63), NULL)
-cfg(activation_auto_set_activation_skip_CFG, "auto_set_activation_skip", activation_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_AUTO_SET_ACTIVATION_SKIP, vsn(2,2,99), NULL)
+cfg(activation_auto_set_activation_skip_CFG, "auto_set_activation_skip", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_AUTO_SET_ACTIVATION_SKIP, vsn(2,2,99), NULL)
 
 cfg(metadata_pvmetadatacopies_CFG, "pvmetadatacopies", metadata_CFG_SECTION, CFG_ADVANCED, CFG_TYPE_INT, DEFAULT_PVMETADATACOPIES, vsn(1, 0, 0), NULL)
 cfg(metadata_vgmetadatacopies_CFG, "vgmetadatacopies", metadata_CFG_SECTION, CFG_ADVANCED, CFG_TYPE_INT, DEFAULT_VGMETADATACOPIES, vsn(2, 2, 69), NULL)


