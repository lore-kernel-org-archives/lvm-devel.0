From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed,  4 Mar 2015 13:10:37 +0000 (UTC)
Subject: master - config: add CFG_DISABLED flag and mark system_id settings with that flag
Message-ID: <20150304131037.D3AC9606D8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=67c52a4453a941244b07044ee1b80284e8f181c6
Commit:        67c52a4453a941244b07044ee1b80284e8f181c6
Parent:        e73dad787439c1376dfa00fef6d1ee0f18f42c9b
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Mar 4 14:08:47 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Mar 4 14:08:47 2015 +0100

config: add CFG_DISABLED flag and mark system_id settings with that flag

If configuration setting is marked in config_setting.h with CFG_DISABLED
flag, default value is always used for such setting, no matter if it's defined
by user (in --config/lvm.conf/lvmlocal.conf).

A warning message is displayed if this happens:

For example:

[1] f21/~ # lvm dumpconfig --validate
  WARNING: Configuration setting global/system_id_source is disabled. Using default value.
  LVM configuration valid.

[1] f21/~ # pvs
  WARNING: Configuration setting global/system_id_source is disabled. Using default value.
  PV         VG     Fmt  Attr PSize   PFree
  /dev/sdb          lvm2 ---  128.00m 128.00m
  ...
---
 lib/config/config.c          |   31 ++++++++++++++++++++++++-------
 lib/config/config.h          |   21 ++++++++++++---------
 lib/config/config_settings.h |    9 +++++----
 3 files changed, 41 insertions(+), 20 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index d7b11c3..effe93d 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -1145,6 +1145,16 @@ static int _apply_local_profile(struct cmd_context *cmd, struct profile *profile
 	return override_config_tree_from_profile(cmd, profile);
 }
 
+static int _config_disabled(struct cmd_context *cmd, cfg_def_item_t *item, const char *path)
+{
+	if ((item->flags & CFG_DISABLED) && dm_config_tree_find_node(cmd->cft, path)) {
+		log_warn("WARNING: Configuration setting %s is disabled. Using default value.", path);
+		return 1;
+	}
+
+	return 0;
+}
+
 const struct dm_config_node *find_config_node(struct cmd_context *cmd, struct dm_config_tree *cft, int id)
 {
 	cfg_def_item_t *item = cfg_def_get_item_p(id);
@@ -1189,7 +1199,8 @@ const char *find_config_tree_str(struct cmd_context *cmd, int id, struct profile
 	if (item->type != CFG_TYPE_STRING)
 		log_error(INTERNAL_ERROR "%s cfg tree element not declared as string.", path);
 
-	str = dm_config_tree_find_str(cmd->cft, path, cfg_def_get_default_value(cmd, item, CFG_TYPE_STRING, profile));
+	str = _config_disabled(cmd, item, path) ? cfg_def_get_default_value(cmd, item, CFG_TYPE_STRING, profile)
+						: dm_config_tree_find_str(cmd->cft, path, cfg_def_get_default_value(cmd, item, CFG_TYPE_STRING, profile));
 
 	if (profile_applied)
 		remove_config_tree_by_source(cmd, profile->source);
@@ -1212,7 +1223,8 @@ const char *find_config_tree_str_allow_empty(struct cmd_context *cmd, int id, st
 	if (!(item->flags & CFG_ALLOW_EMPTY))
 		log_error(INTERNAL_ERROR "%s cfg tree element not declared to allow empty values.", path);
 
-	str = dm_config_tree_find_str_allow_empty(cmd->cft, path, cfg_def_get_default_value(cmd, item, CFG_TYPE_STRING, profile));
+	str = _config_disabled(cmd, item, path) ? cfg_def_get_default_value(cmd, item, CFG_TYPE_STRING, profile)
+						: dm_config_tree_find_str_allow_empty(cmd->cft, path, cfg_def_get_default_value(cmd, item, CFG_TYPE_STRING, profile));
 
 	if (profile_applied)
 		remove_config_tree_by_source(cmd, profile->source);
@@ -1233,7 +1245,8 @@ int find_config_tree_int(struct cmd_context *cmd, int id, struct profile *profil
 	if (item->type != CFG_TYPE_INT)
 		log_error(INTERNAL_ERROR "%s cfg tree element not declared as integer.", path);
 
-	i = dm_config_tree_find_int(cmd->cft, path, cfg_def_get_default_value(cmd, item, CFG_TYPE_INT, profile));
+	i = _config_disabled(cmd, item, path) ? cfg_def_get_default_value(cmd, item, CFG_TYPE_INT, profile)
+					      : dm_config_tree_find_int(cmd->cft, path, cfg_def_get_default_value(cmd, item, CFG_TYPE_INT, profile));
 
 	if (profile_applied)
 		remove_config_tree_by_source(cmd, profile->source);
@@ -1254,7 +1267,8 @@ int64_t find_config_tree_int64(struct cmd_context *cmd, int id, struct profile *
 	if (item->type != CFG_TYPE_INT)
 		log_error(INTERNAL_ERROR "%s cfg tree element not declared as integer.", path);
 
-	i64 = dm_config_tree_find_int64(cmd->cft, path, cfg_def_get_default_value(cmd, item, CFG_TYPE_INT, profile));
+	i64 = _config_disabled(cmd, item, path) ? cfg_def_get_default_value(cmd, item, CFG_TYPE_INT, profile)
+						: dm_config_tree_find_int64(cmd->cft, path, cfg_def_get_default_value(cmd, item, CFG_TYPE_INT, profile));
 
 	if (profile_applied)
 		remove_config_tree_by_source(cmd, profile->source);
@@ -1275,7 +1289,8 @@ float find_config_tree_float(struct cmd_context *cmd, int id, struct profile *pr
 	if (item->type != CFG_TYPE_FLOAT)
 		log_error(INTERNAL_ERROR "%s cfg tree element not declared as float.", path);
 
-	f = dm_config_tree_find_float(cmd->cft, path, cfg_def_get_default_value(cmd, item, CFG_TYPE_FLOAT, profile));
+	f = _config_disabled(cmd, item, path) ? cfg_def_get_default_value(cmd, item, CFG_TYPE_FLOAT, profile)
+					      : dm_config_tree_find_float(cmd->cft, path, cfg_def_get_default_value(cmd, item, CFG_TYPE_FLOAT, profile));
 
 	if (profile_applied)
 		remove_config_tree_by_source(cmd, profile->source);
@@ -1294,7 +1309,8 @@ int find_config_bool(struct cmd_context *cmd, struct dm_config_tree *cft, int id
 	if (item->type != CFG_TYPE_BOOL)
 		log_error(INTERNAL_ERROR "%s cfg tree element not declared as boolean.", path);
 
-	b = dm_config_tree_find_bool(cft, path, cfg_def_get_default_value(cmd, item, CFG_TYPE_BOOL, NULL));
+	b = _config_disabled(cmd, item, path) ? cfg_def_get_default_value(cmd, item, CFG_TYPE_BOOL, NULL)
+					      : dm_config_tree_find_bool(cft, path, cfg_def_get_default_value(cmd, item, CFG_TYPE_BOOL, NULL));
 
 	return b;
 }
@@ -1312,7 +1328,8 @@ int find_config_tree_bool(struct cmd_context *cmd, int id, struct profile *profi
 	if (item->type != CFG_TYPE_BOOL)
 		log_error(INTERNAL_ERROR "%s cfg tree element not declared as boolean.", path);
 
-	b = dm_config_tree_find_bool(cmd->cft, path, cfg_def_get_default_value(cmd, item, CFG_TYPE_BOOL, profile));
+	b = _config_disabled(cmd, item, path) ? cfg_def_get_default_value(cmd, item, CFG_TYPE_BOOL, profile)
+					      : dm_config_tree_find_bool(cmd->cft, path, cfg_def_get_default_value(cmd, item, CFG_TYPE_BOOL, profile));
 
 	if (profile_applied)
 		remove_config_tree_by_source(cmd, profile->source);
diff --git a/lib/config/config.h b/lib/config/config.h
index 965214e..ba34354 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -90,24 +90,27 @@ typedef union {
 
 /* configuration definition item flags: */
 
+
 /* whether the configuration item name is variable */
-#define CFG_NAME_VARIABLE	0x01
+#define CFG_NAME_VARIABLE	0x001
 /* whether empty value is allowed */
-#define CFG_ALLOW_EMPTY		0x02
+#define CFG_ALLOW_EMPTY		0x002
 /* whether the configuration item is for advanced use only */
-#define CFG_ADVANCED		0x04
+#define CFG_ADVANCED		0x004
 /* whether the configuration item is not officially supported */
-#define CFG_UNSUPPORTED		0x08
+#define CFG_UNSUPPORTED		0x008
 /* whether the configuration item is customizable by a profile */
-#define CFG_PROFILABLE		0x10
+#define CFG_PROFILABLE		0x010
 /* whether the configuration item is customizable by a profile */
 /* and whether it can be attached to VG/LV metadata at the same time
  * The CFG_PROFILABLE_METADATA flag incorporates CFG_PROFILABLE flag!!! */
-#define CFG_PROFILABLE_METADATA 0x30
+#define CFG_PROFILABLE_METADATA 0x030
 /* whether the default value is undefned */
-#define CFG_DEFAULT_UNDEFINED	0x40
-/* whether the defualt value is calculated during run time */
-#define CFG_DEFAULT_RUN_TIME	0x80
+#define CFG_DEFAULT_UNDEFINED	0x040
+/* whether the default value is calculated during run time */
+#define CFG_DEFAULT_RUN_TIME	0x080
+/* whether the configuration setting is disabled (and hence defaults always used) */
+#define CFG_DISABLED		0x100
 
 /* configuration definition item structure */
 typedef struct cfg_def_item {
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 4083785..f22039a 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -43,6 +43,7 @@
  * 				CFG_PROFILABLE - this node is customizable by a profile
  * 				CFG_PROFILABLE_METADATA - profilable and attachable to VG/LV metadata
  * 				CFG_DEFAULT_UNDEFINED - node's default value is undefined
+ * 				CFG_DISABLED - configuration is disabled (defaults always used)
  * type:		allowed type for the value of simple configuation setting, one of:
  * 				CFG_TYPE_BOOL
  * 				CFG_TYPE_INT
@@ -193,8 +194,8 @@ cfg_array(global_cache_check_options_CFG, "cache_check_options", global_CFG_SECT
 cfg(global_cache_dump_executable_CFG, "cache_dump_executable", global_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, CACHE_DUMP_CMD, vsn(2, 2, 108), NULL)
 cfg(global_cache_repair_executable_CFG, "cache_repair_executable", global_CFG_SECTION, CFG_ALLOW_EMPTY, CFG_TYPE_STRING, CACHE_REPAIR_CMD, vsn(2, 2, 108), NULL)
 cfg_array(global_cache_repair_options_CFG, "cache_repair_options", global_CFG_SECTION, 0, CFG_TYPE_STRING, "#S" DEFAULT_CACHE_REPAIR_OPTIONS, vsn(2, 2, 108), NULL)
-cfg(global_system_id_source_CFG, "system_id_source", global_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_SYSTEM_ID_SOURCE, vsn(2, 2, 117), NULL)
-cfg(global_system_id_file_CFG, "system_id_file", global_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 117), NULL)
+cfg(global_system_id_source_CFG, "system_id_source", global_CFG_SECTION, CFG_DISABLED, CFG_TYPE_STRING, DEFAULT_SYSTEM_ID_SOURCE, vsn(2, 2, 117), NULL)
+cfg(global_system_id_file_CFG, "system_id_file", global_CFG_SECTION, CFG_DISABLED | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 117), NULL)
 
 cfg(activation_checks_CFG, "checks", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_ACTIVATION_CHECKS, vsn(2, 2, 86), NULL)
 cfg(activation_udev_sync_CFG, "udev_sync", activation_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_UDEV_SYNC, vsn(2, 2, 51), NULL)
@@ -281,7 +282,7 @@ cfg(tags_hosttags_CFG, "hosttags", tags_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_H
 cfg_section(tag_CFG_SUBSECTION, "tag", tags_CFG_SECTION, CFG_NAME_VARIABLE | CFG_DEFAULT_UNDEFINED, vsn(1, 0, 18), NULL)
 cfg(tag_host_list_CFG, "host_list", tag_CFG_SUBSECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 18), NULL)
 
-cfg(local_system_id_CFG, "system_id", local_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 117), NULL)
-cfg_array(local_extra_system_ids_CFG, "extra_system_ids", local_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 117), NULL)
+cfg(local_system_id_CFG, "system_id", local_CFG_SECTION, CFG_DISABLED | CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 117), NULL)
+cfg_array(local_extra_system_ids_CFG, "extra_system_ids", local_CFG_SECTION, CFG_DISABLED | CFG_ALLOW_EMPTY | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(2, 2, 117), NULL)
 
 cfg(CFG_COUNT, NULL, root_CFG_SECTION, 0, CFG_TYPE_INT, 0, vsn(0, 0, 0), NULL)


