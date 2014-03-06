From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  6 Mar 2014 11:20:57 +0000 (UTC)
Subject: master - config: add CFG_DEFAULT_RUN_TIME for config options with runtime defaults
Message-ID: <20140306112057.7CFBB60C21@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b53ec372864cea412505327012cc46dc06dec366
Commit:        b53ec372864cea412505327012cc46dc06dec366
Parent:        e2870c94cf501f15ff9b1201bf468b40c1efd6d3
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Mar 3 12:34:11 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Mar 6 10:54:17 2014 +0100

config: add CFG_DEFAULT_RUN_TIME for config options with runtime defaults

Previously, we declared a default value as undefined ("NULL") for
settings which require runtime context to be set first (e.g. settings
for paths that rely on SYSTEM_DIR environment variable or they depend
on any other setting in some way).

If we want to output default values as they are really used in runtime,
we should make it possible to define a default value as function which
is evaluated, not just providing a firm constant value as it was before.

This patch defines simple prototypes for such functions. Also, there's
new helper macros "cfg_runtime" and "cfg_array_runtime" - they provide
exactly the same functionality as the original "cfg" and "cfg_array"
macros when defining the configuration settings in config_settings.h,
but they don't set the constant default value. Instead, they automatically
link the configuration setting definition with one of these functions:

  typedef int (*t_fn_CFG_TYPE_BOOL) (struct cmd_context *cmd, struct profile *profile);
  typedef int (*t_fn_CFG_TYPE_INT) (struct cmd_context *cmd, struct profile *profile);
  typedef float (*t_fn_CFG_TYPE_FLOAT) (struct cmd_context *cmd, struct profile *profile);
  typedef const char* (*t_fn_CFG_TYPE_STRING) (struct cmd_context *cmd, struct profile *profile);
  typedef const char* (*t_fn_CFG_TYPE_ARRAY) (struct cmd_context *cmd, struct profile *profile);

(The new macros actually set the CFG_DEFAULT_RUNTIME flag properly and
set the default value link to the function accordingly).

Then such configuration setting requires a function of selected type to
be defined. This function has a predefined name:

  get_default_<id>

...where the <id> is the id of the setting as defined in
config_settings.h. For example "backup_archive_dir_CFG" if defined
as a setting with default value evaluated in runtime with "cfg_runtime"
will automatically have "get_default_backup_archive_dir_CFG" function
linked to this setting to get the default value.
---
 lib/config/config.c          |   27 ++++++++++++++++-----------
 lib/config/config.h          |   24 ++++++++++++++++++++++++
 lib/config/config_settings.h |   23 ++++++++++++++++-------
 tools/dumpconfig.c           |    2 ++
 4 files changed, 58 insertions(+), 18 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index cef00a0..5c6b5ba 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -62,11 +62,15 @@ struct config_source {
 static struct cfg_def_item _cfg_def_items[CFG_COUNT + 1] = {
 #define cfg_section(id, name, parent, flags, since_version, comment) {id, parent, name, CFG_TYPE_SECTION, {0}, flags, since_version, comment},
 #define cfg(id, name, parent, flags, type, default_value, since_version, comment) {id, parent, name, type, {.v_##type = default_value}, flags, since_version, comment},
+#define cfg_runtime(id, name, parent, flags, type, since_version, comment) {id, parent, name, type, {.fn_##type = get_default_##id}, flags | CFG_DEFAULT_RUN_TIME, since_version, comment},
 #define cfg_array(id, name, parent, flags, types, default_value, since_version, comment) {id, parent, name, CFG_TYPE_ARRAY | types, {.v_CFG_TYPE_STRING = default_value}, flags, since_version, comment},
+#define cfg_array_runtime(id, name, parent, flags, types, since_version, comment) {id, parent, name, CFG_TYPE_ARRAY | types, {.fn_CFG_TYPE_STRING = get_default_##id}, flags | CFG_DEFAULT_RUN_TIME, since_version, comment},
 #include "config_settings.h"
 #undef cfg_section
 #undef cfg
+#undef cfg_runtime
 #undef cfg_array
+#undef cfg_array_runtime
 };
 
 config_source_t config_get_source_type(struct dm_config_tree *cft)
@@ -474,7 +478,8 @@ time_t config_file_timestamp(struct dm_config_tree *cft)
 }
 
 #define cfg_def_get_item_p(id) (&_cfg_def_items[id])
-#define cfg_def_get_default_value(item,type) item->default_value.v_##type
+#define cfg_def_get_default_value(cmd,item,type,profile) ((item->flags & CFG_DEFAULT_RUN_TIME) ? item->default_value.fn_##type(cmd,profile) : item->default_value.v_##type)
+
 
 static int _cfg_def_make_path(char *buf, size_t buf_size, int id, cfg_def_item_t *item, int xlate)
 {
@@ -844,7 +849,7 @@ const char *find_config_tree_str(struct cmd_context *cmd, int id, struct profile
 	if (item->type != CFG_TYPE_STRING)
 		log_error(INTERNAL_ERROR "%s cfg tree element not declared as string.", path);
 
-	str = dm_config_tree_find_str(cmd->cft, path, cfg_def_get_default_value(item, CFG_TYPE_STRING));
+	str = dm_config_tree_find_str(cmd->cft, path, cfg_def_get_default_value(cmd, item, CFG_TYPE_STRING, profile));
 
 	if (profile_applied)
 		remove_config_tree_by_source(cmd, CONFIG_PROFILE);
@@ -870,7 +875,7 @@ const char *find_config_tree_str_allow_empty(struct cmd_context *cmd, int id, st
 	if (!(item->flags & CFG_ALLOW_EMPTY))
 		log_error(INTERNAL_ERROR "%s cfg tree element not declared to allow empty values.", path);
 
-	str = dm_config_tree_find_str_allow_empty(cmd->cft, path, cfg_def_get_default_value(item, CFG_TYPE_STRING));
+	str = dm_config_tree_find_str_allow_empty(cmd->cft, path, cfg_def_get_default_value(cmd, item, CFG_TYPE_STRING, profile));
 
 	if (profile_applied)
 		remove_config_tree_by_source(cmd, CONFIG_PROFILE);
@@ -894,7 +899,7 @@ int find_config_tree_int(struct cmd_context *cmd, int id, struct profile *profil
 	if (item->type != CFG_TYPE_INT)
 		log_error(INTERNAL_ERROR "%s cfg tree element not declared as integer.", path);
 
-	i = dm_config_tree_find_int(cmd->cft, path, cfg_def_get_default_value(item, CFG_TYPE_INT));
+	i = dm_config_tree_find_int(cmd->cft, path, cfg_def_get_default_value(cmd, item, CFG_TYPE_INT, profile));
 
 	if (profile_applied)
 		remove_config_tree_by_source(cmd, CONFIG_PROFILE);
@@ -918,7 +923,7 @@ int64_t find_config_tree_int64(struct cmd_context *cmd, int id, struct profile *
 	if (item->type != CFG_TYPE_INT)
 		log_error(INTERNAL_ERROR "%s cfg tree element not declared as integer.", path);
 
-	i64 = dm_config_tree_find_int64(cmd->cft, path, cfg_def_get_default_value(item, CFG_TYPE_INT));
+	i64 = dm_config_tree_find_int64(cmd->cft, path, cfg_def_get_default_value(cmd, item, CFG_TYPE_INT, profile));
 
 	if (profile_applied)
 		remove_config_tree_by_source(cmd, CONFIG_PROFILE);
@@ -942,7 +947,7 @@ float find_config_tree_float(struct cmd_context *cmd, int id, struct profile *pr
 	if (item->type != CFG_TYPE_FLOAT)
 		log_error(INTERNAL_ERROR "%s cfg tree element not declared as float.", path);
 
-	f = dm_config_tree_find_float(cmd->cft, path, cfg_def_get_default_value(item, CFG_TYPE_FLOAT));
+	f = dm_config_tree_find_float(cmd->cft, path, cfg_def_get_default_value(cmd, item, CFG_TYPE_FLOAT, profile));
 
 	if (profile_applied)
 		remove_config_tree_by_source(cmd, CONFIG_PROFILE);
@@ -966,7 +971,7 @@ int find_config_tree_bool(struct cmd_context *cmd, int id, struct profile *profi
 	if (item->type != CFG_TYPE_BOOL)
 		log_error(INTERNAL_ERROR "%s cfg tree element not declared as boolean.", path);
 
-	b = dm_config_tree_find_bool(cmd->cft, path, cfg_def_get_default_value(item, CFG_TYPE_BOOL));
+	b = dm_config_tree_find_bool(cmd->cft, path, cfg_def_get_default_value(cmd, item, CFG_TYPE_BOOL, profile));
 
 	if (profile_applied)
 		remove_config_tree_by_source(cmd, CONFIG_PROFILE);
@@ -1353,19 +1358,19 @@ static struct dm_config_node *_add_def_node(struct dm_config_tree *cft,
 				break;
 			case CFG_TYPE_BOOL:
 				cn->v->type = DM_CFG_INT;
-				cn->v->v.i = cfg_def_get_default_value(def, CFG_TYPE_BOOL);
+				cn->v->v.i = cfg_def_get_default_value(spec->cmd, def, CFG_TYPE_BOOL, NULL);
 				break;
 			case CFG_TYPE_INT:
 				cn->v->type = DM_CFG_INT;
-				cn->v->v.i = cfg_def_get_default_value(def, CFG_TYPE_INT);
+				cn->v->v.i = cfg_def_get_default_value(spec->cmd, def, CFG_TYPE_INT, NULL);
 				break;
 			case CFG_TYPE_FLOAT:
 				cn->v->type = DM_CFG_FLOAT;
-				cn->v->v.f = cfg_def_get_default_value(def, CFG_TYPE_FLOAT);
+				cn->v->v.f = cfg_def_get_default_value(spec->cmd, def, CFG_TYPE_FLOAT, NULL);
 				break;
 			case CFG_TYPE_STRING:
 				cn->v->type = DM_CFG_STRING;
-				if (!(str = cfg_def_get_default_value(def, CFG_TYPE_STRING)))
+				if (!(str = cfg_def_get_default_value(spec->cmd, def, CFG_TYPE_STRING, NULL)))
 					str = "";
 				cn->v->v.str = str;
 				break;
diff --git a/lib/config/config.h b/lib/config/config.h
index f716efb..aec72a0 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -63,11 +63,28 @@ typedef enum {
 	CFG_TYPE_STRING =	1 << 5,	/* setting */
 } cfg_def_type_t;
 
+typedef struct cfg_def_item cfg_def_item_t;
+
+/* function types to evaluate default value at runtime */
+typedef int (*t_fn_CFG_TYPE_BOOL) (struct cmd_context *cmd, struct profile *profile);
+typedef int (*t_fn_CFG_TYPE_INT) (struct cmd_context *cmd, struct profile *profile);
+typedef float (*t_fn_CFG_TYPE_FLOAT) (struct cmd_context *cmd, struct profile *profile);
+typedef const char* (*t_fn_CFG_TYPE_STRING) (struct cmd_context *cmd, struct profile *profile);
+typedef const char* (*t_fn_CFG_TYPE_ARRAY) (struct cmd_context *cmd, struct profile *profile);
+
 /* configuration definition item value (for item's default value) */
 typedef union {
+	/* static value - returns a variable */
 	const int v_CFG_TYPE_BOOL, v_CFG_TYPE_INT;
 	const float v_CFG_TYPE_FLOAT;
 	const char *v_CFG_TYPE_STRING, *v_CFG_TYPE_ARRAY;
+
+	/* run-time value - evaluates a function */
+	t_fn_CFG_TYPE_BOOL fn_CFG_TYPE_BOOL;
+	t_fn_CFG_TYPE_INT fn_CFG_TYPE_INT;
+	t_fn_CFG_TYPE_FLOAT fn_CFG_TYPE_FLOAT;
+	t_fn_CFG_TYPE_STRING fn_CFG_TYPE_STRING;
+	t_fn_CFG_TYPE_ARRAY fn_CFG_TYPE_ARRAY;
 } cfg_def_value_t;
 
 /* configuration definition item flags: */
@@ -84,6 +101,8 @@ typedef union {
 #define CFG_PROFILABLE		0x10
 /* whether the default value is undefned */
 #define CFG_DEFAULT_UNDEFINED	0x20
+/* whether the defualt value is calculated during run time */
+#define CFG_DEFAULT_RUN_TIME	0x40
 
 /* configuration definition item structure */
 typedef struct cfg_def_item {
@@ -109,6 +128,7 @@ typedef enum {
 
 /* configuration definition tree specification */
 struct config_def_tree_spec {
+	struct cmd_context *cmd;	/* command context (for run-time defaults */
 	cfg_def_tree_t type;		/* tree type */
 	uint16_t version;		/* tree@this LVM2 version */
 	int ignoreadvanced:1;		/* do not include advanced configs */
@@ -130,11 +150,15 @@ struct config_def_tree_spec {
 enum {
 #define cfg_section(id, name, parent, flags, since_version, comment) id,
 #define cfg(id, name, parent, flags, type, default_value, since_version, comment) id,
+#define cfg_runtime(id, name, parent, flags, type, since_version, comment) id,
 #define cfg_array(id, name, parent, flags, types, default_value, since_version, comment) id,
+#define cfg_array_runtime(id, name, parent, flags, types, since_version, comment) id,
 #include "config_settings.h"
 #undef cfg_section
 #undef cfg
+#undef cfg_runtime
 #undef cfg_array
+#undef cfg_array_runtime
 };
 
 struct profile *add_profile(struct cmd_context *cmd, const char *profile_name);
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index eb89e87..8d3d304 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -14,15 +14,24 @@
 
 /*
  * MACROS:
- * cfg_section(id, name, parent, flags, since_version, comment)
- * cfg(id, name, parent, flags, type, default_value, since_version, comment)
- * cfg_array(id, name, parent, flags, types, default_value, since_version, comment)
+ * - define a configuration section:
+ *   cfg_section(id, name, parent, flags, since_version, comment)
  *
- * VARIABLES:
- * cfg_section:		define a new configuration section
- * cfg:			define a new configuration setting of a simple type
- * cfg_array:		define a new configuration setting of array type
+ * - define a configuration setting of simple type:
+ *   cfg(id, name, parent, flags, type, default_value, since_version, comment)
+ *
+ * - define a configuration array of one or more types:
+ *   cfg_array(id, name, parent, flags, types, default_value, since_version, comment)
+ *
+ * If default value can't be assigned statically because it depends on some
+ * run-time checks or if it depends on other settings already defined,
+ * the configuration setting  or array can be defined with the
+ * "{cfg|cfg_array}_runtime" macro. In this case the  default value
+ * is evaluated by automatically calling "get_default_<id>" function.
+ * See config.h and "function types to evaluate default value at runtime".
  *
+ *
+ * VARIABLES:
  * id:			unique identifier
  * name:		configuration node name
  * parent:		id of parent configuration node
diff --git a/tools/dumpconfig.c b/tools/dumpconfig.c
index cb88bc6..dd86733 100644
--- a/tools/dumpconfig.c
+++ b/tools/dumpconfig.c
@@ -97,6 +97,8 @@ int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 	struct cft_check_handle *cft_check_handle = NULL;
 	int r = ECMD_PROCESSED;
 
+	tree_spec.cmd = cmd;
+
 	if (arg_count(cmd, configtype_ARG) && arg_count(cmd, validate_ARG)) {
 		log_error("Only one of --type and --validate permitted.");
 		return EINVALID_CMD_LINE;


