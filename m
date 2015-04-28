From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 28 Apr 2015 13:44:22 +0000 (UTC)
Subject: master - config: also evaluate default unconfigured values in runtime for 'cfg_runtime' settings
Message-ID: <20150428134422.75A7960FF7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ae0014e2dfd84b2348c7c8dd57f83159c79fda85
Commit:        ae0014e2dfd84b2348c7c8dd57f83159c79fda85
Parent:        afcf47246458a9b1ec37ab1b55348b615c58c81a
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Apr 28 15:29:08 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Apr 28 15:36:35 2015 +0200

config: also evaluate default unconfigured values in runtime for 'cfg_runtime' settings

The settings which have their default value evaluated in runtime should
have their 'unconfigured' counterparts also evaluated in runtime since
those values can be constructed by using other settings.

For example, before this patch:

$ lvm dumpconfig --type default --unconfigured devices/cache_dir devices/cache
cache_dir="@DEFAULT_SYS_DIR@/@DEFAULT_CACHE_SUBDIR@"
cache="/etc/lvm/cache/.cache

With this patch applied:

$ lvm dumpconfig --type default --unconfigured devices/cache_dir devices/cache
cache_dir="@DEFAULT_SYS_DIR@/@DEFAULT_CACHE_SUBDIR@"
cache="@DEFAULT_SYS_DIR@/@DEFAULT_CACHE_SUBDIR@/.cache"
---
 lib/config/config.c          |   53 ++++++++++++++++++++++++++++++++++++-----
 lib/config/config.h          |   38 ++++++++++++++++++++---------
 lib/config/config_settings.h |   50 +++++++++++++++++++-------------------
 3 files changed, 97 insertions(+), 44 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index 331bd00..fbe7cb9 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -65,11 +65,11 @@ struct config_source {
  * Map each ID to respective definition of the configuration item.
  */
 static struct cfg_def_item _cfg_def_items[CFG_COUNT + 1] = {
-#define cfg_section(id, name, parent, flags, since_version, unconfigured_value, comment) {id, parent, name, CFG_TYPE_SECTION, {0}, flags, since_version, unconfigured_value, comment},
-#define cfg(id, name, parent, flags, type, default_value, since_version, unconfigured_value, comment) {id, parent, name, type, {.v_##type = default_value}, flags, since_version, unconfigured_value, comment},
-#define cfg_runtime(id, name, parent, flags, type, since_version, unconfigured_value, comment) {id, parent, name, type, {.fn_##type = get_default_##id}, flags | CFG_DEFAULT_RUN_TIME, since_version, unconfigured_value, comment},
-#define cfg_array(id, name, parent, flags, types, default_value, since_version, unconfigured_value, comment) {id, parent, name, CFG_TYPE_ARRAY | types, {.v_CFG_TYPE_STRING = default_value}, flags, since_version, unconfigured_value, comment},
-#define cfg_array_runtime(id, name, parent, flags, types, since_version, unconfigured_value, comment) {id, parent, name, CFG_TYPE_ARRAY | types, {.fn_CFG_TYPE_STRING = get_default_##id}, flags | CFG_DEFAULT_RUN_TIME, since_version, unconfigured_value, comment},
+#define cfg_section(id, name, parent, flags, since_version, comment) {id, parent, name, CFG_TYPE_SECTION, {0}, flags, since_version, {0}, comment},
+#define cfg(id, name, parent, flags, type, default_value, since_version, unconfigured_value, comment) {id, parent, name, type, {.v_##type = default_value}, flags, since_version, {.v_UNCONFIGURED = unconfigured_value}, comment},
+#define cfg_runtime(id, name, parent, flags, type, since_version, comment) {id, parent, name, type, {.fn_##type = get_default_##id}, flags | CFG_DEFAULT_RUN_TIME, since_version, {.fn_UNCONFIGURED = get_default_unconfigured_##id}, comment},
+#define cfg_array(id, name, parent, flags, types, default_value, since_version, unconfigured_value, comment) {id, parent, name, CFG_TYPE_ARRAY | types, {.v_CFG_TYPE_STRING = default_value}, flags, since_version, {.v_UNCONFIGURED = unconfigured_value}, comment},
+#define cfg_array_runtime(id, name, parent, flags, types, since_version, comment) {id, parent, name, CFG_TYPE_ARRAY | types, {.fn_CFG_TYPE_STRING = get_default_##id}, flags | CFG_DEFAULT_RUN_TIME, since_version, {.fn_UNCONFIGURED = get_default_unconfigured_##id}, comment},
 #include "config_settings.h"
 #undef cfg_section
 #undef cfg
@@ -604,6 +604,7 @@ struct timespec config_file_timestamp(struct dm_config_tree *cft)
 }
 
 #define cfg_def_get_item_p(id) (&_cfg_def_items[id])
+#define cfg_def_get_default_unconfigured_value_hint(cmd,item) ((item->flags & CFG_DEFAULT_RUN_TIME) ? item->default_unconfigured_value.fn_UNCONFIGURED(cmd) : item->default_unconfigured_value.v_UNCONFIGURED)
 #define cfg_def_get_default_value_hint(cmd,item,type,profile) ((item->flags & CFG_DEFAULT_RUN_TIME) ? item->default_value.fn_##type(cmd,profile) : item->default_value.v_##type)
 #define cfg_def_get_default_value(cmd,item,type,profile) (item->flags & CFG_DEFAULT_UNDEFINED ? 0 : cfg_def_get_default_value_hint(cmd,item,type,profile))
 
@@ -1675,9 +1676,9 @@ static struct dm_config_node *_add_def_node(struct dm_config_tree *cft,
 
 	cn->id = def->id;
 
-	if (spec->unconfigured && def->unconfigured_value) {
+	if (spec->unconfigured && def->default_unconfigured_value.v_UNCONFIGURED) {
 		cn->v->type = DM_CFG_STRING;
-		cn->v->v.str = def->unconfigured_value;
+		cn->v->v.str = cfg_def_get_default_unconfigured_value_hint(spec->cmd, def);
 	} else if (!(def->type & CFG_TYPE_ARRAY)) {
 		switch (def->type) {
 			case CFG_TYPE_SECTION:
@@ -2007,6 +2008,11 @@ const char *get_default_devices_cache_dir_CFG(struct cmd_context *cmd, struct pr
 	return dm_pool_strdup(cmd->mem, buf);
 }
 
+const char *get_default_unconfigured_devices_cache_dir_CFG(struct cmd_context *cmd)
+{
+	return "@DEFAULT_SYS_DIR@/@DEFAULT_CACHE_SUBDIR@";
+}
+
 const char *get_default_devices_cache_CFG(struct cmd_context *cmd, struct profile *profile)
 {
 	const char *cache_dir = NULL, *cache_file_prefix = NULL;
@@ -2041,6 +2047,24 @@ const char *get_default_devices_cache_CFG(struct cmd_context *cmd, struct profil
 	return dm_pool_strdup(cmd->mem, buf);
 }
 
+const char *get_default_unconfigured_devices_cache_CFG(struct cmd_context *cmd)
+{
+	const char *cache_file_prefix = NULL;
+	static char buf[PATH_MAX];
+
+	if (find_config_tree_node(cmd, devices_cache_file_prefix_CFG, NULL))
+		cache_file_prefix = find_config_tree_str_allow_empty(cmd, devices_cache_file_prefix_CFG, NULL);
+
+	if (dm_snprintf(buf, sizeof(buf), "%s/%s.cache",
+			get_default_unconfigured_devices_cache_dir_CFG(cmd),
+			cache_file_prefix ? : DEFAULT_CACHE_FILE_PREFIX) < 0) {
+		log_error("Persistent cache filename too long.");
+		return NULL;
+	}
+
+	return dm_pool_strdup(cmd->mem, buf);
+}
+
 const char *get_default_backup_backup_dir_CFG(struct cmd_context *cmd, struct profile *profile)
 {
 	static char buf[PATH_MAX];
@@ -2054,6 +2078,11 @@ const char *get_default_backup_backup_dir_CFG(struct cmd_context *cmd, struct pr
 	return dm_pool_strdup(cmd->mem, buf);
 }
 
+const char *get_default_unconfigured_backup_backup_dir_CFG(struct cmd_context *cmd)
+{
+	return "@DEFAULT_SYS_DIR@/@DEFAULT_BACKUP_SUBDIR@";
+}
+
 const char *get_default_backup_archive_dir_CFG(struct cmd_context *cmd, struct profile *profile)
 {
 	static char buf[PATH_MAX];
@@ -2067,6 +2096,11 @@ const char *get_default_backup_archive_dir_CFG(struct cmd_context *cmd, struct p
 	return dm_pool_strdup(cmd->mem, buf);
 }
 
+const char *get_default_unconfigured_backup_archive_dir_CFG(struct cmd_context *cmd)
+{
+	return "@DEFAULT_SYS_DIR@/@DEFAULT_ARCHIVE_SUBDIR@";
+}
+
 const char *get_default_config_profile_dir_CFG(struct cmd_context *cmd, struct profile *profile)
 {
 	static char buf[PATH_MAX];
@@ -2080,6 +2114,11 @@ const char *get_default_config_profile_dir_CFG(struct cmd_context *cmd, struct p
 	return dm_pool_strdup(cmd->mem, buf);
 }
 
+const char *get_default_unconfigured_config_profile_dir_CFG(struct cmd_context *cmd)
+{
+	return "@DEFAULT_SYS_DIR@/@DEFAULT_PROFILE_SUBDIR@";
+}
+
 const char *get_default_activation_mirror_image_fault_policy_CFG(struct cmd_context *cmd, struct profile *profile)
 {
 	return find_config_tree_str(cmd, activation_mirror_device_fault_policy_CFG, profile);
diff --git a/lib/config/config.h b/lib/config/config.h
index 1c367bd..193f4e3 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -72,6 +72,7 @@ typedef int (*t_fn_CFG_TYPE_INT) (struct cmd_context *cmd, struct profile *profi
 typedef float (*t_fn_CFG_TYPE_FLOAT) (struct cmd_context *cmd, struct profile *profile);
 typedef const char* (*t_fn_CFG_TYPE_STRING) (struct cmd_context *cmd, struct profile *profile);
 typedef const char* (*t_fn_CFG_TYPE_ARRAY) (struct cmd_context *cmd, struct profile *profile);
+typedef const char* (*t_fn_UNCONFIGURED) (struct cmd_context *cmd);
 
 /* configuration definition item value (for item's default value) */
 typedef union {
@@ -88,6 +89,11 @@ typedef union {
 	t_fn_CFG_TYPE_ARRAY fn_CFG_TYPE_ARRAY;
 } cfg_def_value_t;
 
+typedef union {
+	const char *v_UNCONFIGURED;
+	t_fn_UNCONFIGURED fn_UNCONFIGURED;
+} cfg_def_unconfigured_value_t;
+
 /* configuration definition item flags: */
 
 
@@ -114,15 +120,15 @@ typedef union {
 
 /* configuration definition item structure */
 typedef struct cfg_def_item {
-	int id;				/* ID of this item */
-	int parent;			/* ID of parent item */
-	const char *name;		/* name of the item in configuration tree */
-	int type;			/* configuration item type (bits of cfg_def_type_t) */
-	cfg_def_value_t default_value;	/* default value (only for settings) */
-	uint16_t flags;			/* configuration item definition flags */
-	uint16_t since_version;		/* version this item appeared in */
-	const char *unconfigured_value;	/* value in terms of @FOO@, pre-configured */
-	const char *comment;		/* brief comment */
+	int id;								/* ID of this item */
+	int parent;							/* ID of parent item */
+	const char *name;						/* name of the item in configuration tree */
+	int type;							/* configuration item type (bits of cfg_def_type_t) */
+	cfg_def_value_t default_value;					/* default value (only for settings) */
+	uint16_t flags;							/* configuration item definition flags */
+	uint16_t since_version;						/* version this item appeared in */
+	cfg_def_unconfigured_value_t default_unconfigured_value;	/* default value in terms of @FOO@, pre-configured (only for settings) */
+	const char *comment;						/* comment */
 } cfg_def_item_t;
 
 /* configuration definition tree types */
@@ -165,11 +171,11 @@ struct config_def_tree_spec {
  * Register ID for each possible item in the configuration tree.
  */
 enum {
-#define cfg_section(id, name, parent, flags, since_version, unconfigured_value, comment) id,
+#define cfg_section(id, name, parent, flags, since_version, comment) id,
 #define cfg(id, name, parent, flags, type, default_value, since_version, unconfigured_value, comment) id,
-#define cfg_runtime(id, name, parent, flags, type, since_version, unconfigured_value, comment) id,
+#define cfg_runtime(id, name, parent, flags, type, since_version, comment) id,
 #define cfg_array(id, name, parent, flags, types, default_value, since_version, unconfigured_value, comment) id,
-#define cfg_array_runtime(id, name, parent, flags, types, since_version, unconfigured_value, comment) id,
+#define cfg_array_runtime(id, name, parent, flags, types, since_version, comment) id,
 #include "config_settings.h"
 #undef cfg_section
 #undef cfg
@@ -260,12 +266,20 @@ int find_config_tree_bool(struct cmd_context *cmd, int id, struct profile *profi
  * value is evaluated at runtime based on command context.
  */
 const char *get_default_devices_cache_dir_CFG(struct cmd_context *cmd, struct profile *profile);
+const char *get_default_unconfigured_devices_cache_dir_CFG(struct cmd_context *cmd);
 const char *get_default_devices_cache_CFG(struct cmd_context *cmd, struct profile *profile);
+const char *get_default_unconfigured_devices_cache_CFG(struct cmd_context *cmd);
 const char *get_default_backup_backup_dir_CFG(struct cmd_context *cmd, struct profile *profile);
+const char *get_default_unconfigured_backup_backup_dir_CFG(struct cmd_context *cmd);
 const char *get_default_backup_archive_dir_CFG(struct cmd_context *cmd, struct profile *profile);
+const char *get_default_unconfigured_backup_archive_dir_CFG(struct cmd_context *cmd);
 const char *get_default_config_profile_dir_CFG(struct cmd_context *cmd, struct profile *profile);
+const char *get_default_unconfigured_config_profile_dir_CFG(struct cmd_context *cmd);
 const char *get_default_activation_mirror_image_fault_policy_CFG(struct cmd_context *cmd, struct profile *profile);
+#define get_default_unconfigured_activation_mirror_image_fault_policy_CFG NULL
 int get_default_allocation_thin_pool_chunk_size_CFG(struct cmd_context *cmd, struct profile *profile);
+#define get_default_unconfigured_allocation_thin_pool_chunk_size_CFG NULL
 int get_default_allocation_cache_pool_chunk_size_CFG(struct cmd_context *cmd, struct profile *profile);
+#define get_default_unconfigured_allocation_cache_pool_chunk_size_CFG NULL
 
 #endif
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index dcbc332..76b040b 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -71,46 +71,46 @@
  */
 #include "defaults.h"
 
-cfg_section(root_CFG_SECTION, "(root)", root_CFG_SECTION, 0, vsn(0, 0, 0), NULL, NULL)
+cfg_section(root_CFG_SECTION, "(root)", root_CFG_SECTION, 0, vsn(0, 0, 0), NULL)
 
-cfg_section(config_CFG_SECTION, "config", root_CFG_SECTION, 0, vsn(2, 2, 99), NULL,
+cfg_section(config_CFG_SECTION, "config", root_CFG_SECTION, 0, vsn(2, 2, 99),
 	"How LVM configuration settings are handled.\n")
 
-cfg_section(devices_CFG_SECTION, "devices", root_CFG_SECTION, 0, vsn(1, 0, 0), NULL,
+cfg_section(devices_CFG_SECTION, "devices", root_CFG_SECTION, 0, vsn(1, 0, 0),
 	"How LVM uses block devices.\n")
 
-cfg_section(allocation_CFG_SECTION, "allocation", root_CFG_SECTION, CFG_PROFILABLE, vsn(2, 2, 77), NULL,
+cfg_section(allocation_CFG_SECTION, "allocation", root_CFG_SECTION, CFG_PROFILABLE, vsn(2, 2, 77),
 	"How LVM selects free space for Logical Volumes.\n")
 
-cfg_section(log_CFG_SECTION, "log", root_CFG_SECTION, 0, vsn(1, 0, 0), NULL,
+cfg_section(log_CFG_SECTION, "log", root_CFG_SECTION, 0, vsn(1, 0, 0),
 	"How LVM log information is reported.\n")
 
-cfg_section(backup_CFG_SECTION, "backup", root_CFG_SECTION, 0, vsn(1, 0, 0), NULL,
+cfg_section(backup_CFG_SECTION, "backup", root_CFG_SECTION, 0, vsn(1, 0, 0),
 	"How LVM metadata is backed up and archived.\n"
 	"In LVM, a 'backup' is a copy of the metadata for the\n"
 	"current system, and an 'archive' contains old metadata\n"
 	"configurations. They are stored in a human readable\n"
 	"text format.\n")
 
-cfg_section(shell_CFG_SECTION, "shell", root_CFG_SECTION, 0, vsn(1, 0, 0), NULL,
+cfg_section(shell_CFG_SECTION, "shell", root_CFG_SECTION, 0, vsn(1, 0, 0),
 	"Settings for running LVM in shell (readline) mode.\n")
 
-cfg_section(global_CFG_SECTION, "global", root_CFG_SECTION, CFG_PROFILABLE, vsn(1, 0, 0), NULL,
+cfg_section(global_CFG_SECTION, "global", root_CFG_SECTION, CFG_PROFILABLE, vsn(1, 0, 0),
 	"Miscellaneous global LVM settings.\n")
 
-cfg_section(activation_CFG_SECTION, "activation", root_CFG_SECTION, CFG_PROFILABLE, vsn(1, 0, 0), NULL, NULL)
-cfg_section(metadata_CFG_SECTION, "metadata", root_CFG_SECTION, CFG_ADVANCED, vsn(1, 0, 0), NULL, NULL)
+cfg_section(activation_CFG_SECTION, "activation", root_CFG_SECTION, CFG_PROFILABLE, vsn(1, 0, 0), NULL)
+cfg_section(metadata_CFG_SECTION, "metadata", root_CFG_SECTION, CFG_ADVANCED, vsn(1, 0, 0), NULL)
 
-cfg_section(report_CFG_SECTION, "report", root_CFG_SECTION, CFG_ADVANCED | CFG_PROFILABLE, vsn(1, 0, 0), NULL,
+cfg_section(report_CFG_SECTION, "report", root_CFG_SECTION, CFG_ADVANCED | CFG_PROFILABLE, vsn(1, 0, 0),
 	"LVM report command output formatting.\n")
 
-cfg_section(dmeventd_CFG_SECTION, "dmeventd", root_CFG_SECTION, 0, vsn(1, 2, 3), NULL,
+cfg_section(dmeventd_CFG_SECTION, "dmeventd", root_CFG_SECTION, 0, vsn(1, 2, 3),
 	"Settings for the LVM event daemon.\n")
 
-cfg_section(tags_CFG_SECTION, "tags", root_CFG_SECTION, 0, vsn(1, 0, 18), NULL,
+cfg_section(tags_CFG_SECTION, "tags", root_CFG_SECTION, 0, vsn(1, 0, 18),
 	"Host tag settings.\n")
 
-cfg_section(local_CFG_SECTION, "local", root_CFG_SECTION, 0, vsn(2, 2, 117), NULL,
+cfg_section(local_CFG_SECTION, "local", root_CFG_SECTION, 0, vsn(2, 2, 117),
 	"LVM settings that are specific to the local host.\n")
 
 cfg(config_checks_CFG, "checks", config_CFG_SECTION, 0, CFG_TYPE_BOOL, 1, vsn(2, 2, 99), NULL,
@@ -124,7 +124,7 @@ cfg(config_checks_CFG, "checks", config_CFG_SECTION, 0, CFG_TYPE_BOOL, 1, vsn(2,
 cfg(config_abort_on_errors_CFG, "abort_on_errors", config_CFG_SECTION, 0, CFG_TYPE_BOOL, 0, vsn(2,2,99), NULL,
 	"Abort the LVM process if a configuration mismatch is found.\n")
 
-cfg_runtime(config_profile_dir_CFG, "profile_dir", config_CFG_SECTION, 0, CFG_TYPE_STRING, vsn(2, 2, 99), "@DEFAULT_SYS_DIR@/@DEFAULT_PROFILE_SUBDIR@",
+cfg_runtime(config_profile_dir_CFG, "profile_dir", config_CFG_SECTION, 0, CFG_TYPE_STRING, vsn(2, 2, 99),
 	"Directory where LVM looks for configuration profiles.\n")
 
 cfg(devices_dir_CFG, "dir", devices_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_DEV_DIR, vsn(1, 0, 0), NULL,
@@ -221,10 +221,10 @@ cfg_array(devices_global_filter_CFG, "global_filter", devices_CFG_SECTION, CFG_D
 	"system components. The syntax is the same as devices/filter.\n"
 	"Devices rejected by global_filter are not opened by LVM.\n")
 
-cfg_runtime(devices_cache_CFG, "cache", devices_CFG_SECTION, 0, CFG_TYPE_STRING, vsn(1, 0, 0), NULL,
+cfg_runtime(devices_cache_CFG, "cache", devices_CFG_SECTION, 0, CFG_TYPE_STRING, vsn(1, 0, 0),
 	"The path can be set using the devices/cache_dir setting.\n")
 
-cfg_runtime(devices_cache_dir_CFG, "cache_dir", devices_CFG_SECTION, 0, CFG_TYPE_STRING, vsn(1, 2, 19), "@DEFAULT_SYS_DIR@/@DEFAULT_CACHE_SUBDIR@",
+cfg_runtime(devices_cache_dir_CFG, "cache_dir", devices_CFG_SECTION, 0, CFG_TYPE_STRING, vsn(1, 2, 19),
 	"Directory in which to store the device cache file.\n"
 	"The results of filtering are cached on disk to avoid\n"
 	"rescanning dud devices (which can take a very long time).\n"
@@ -426,7 +426,7 @@ cfg(allocation_cache_pool_cachemode_CFG, "cache_pool_cachemode", allocation_CFG_
 	"writeback - Data blocks are written from the cache back\n"
 	"to disk after some delay to improve performance.\n")
 
-cfg_runtime(allocation_cache_pool_chunk_size_CFG, "cache_pool_chunk_size", allocation_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_INT, vsn(2, 2, 106), NULL,
+cfg_runtime(allocation_cache_pool_chunk_size_CFG, "cache_pool_chunk_size", allocation_CFG_SECTION, CFG_DEFAULT_UNDEFINED, CFG_TYPE_INT, vsn(2, 2, 106),
 	"The minimal chunk size (in kiB) for cache pool volumes.\n"
 	"Using a chunk_size that is too large can result in wasteful\n"
 	"use of the cache, where small reads and writes can cause\n"
@@ -461,7 +461,7 @@ cfg(allocation_thin_pool_chunk_size_policy_CFG, "thin_pool_chunk_size_policy", a
 	"device hints exposed in sysfs - the optimal_io_size.\n"
 	"The chunk size is always at least 512KiB.\n")
 
-cfg_runtime(allocation_thin_pool_chunk_size_CFG, "thin_pool_chunk_size", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_UNDEFINED, CFG_TYPE_INT, vsn(2, 2, 99), NULL,
+cfg_runtime(allocation_thin_pool_chunk_size_CFG, "thin_pool_chunk_size", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_UNDEFINED, CFG_TYPE_INT, vsn(2, 2, 99),
 	"The minimal chunk size (in KB) for thin pool volumes.\n"
 	"Larger chunk sizes may improve performance for plain\n"
 	"thin volumes, however using them for snapshot volumes\n"
@@ -533,7 +533,7 @@ cfg(backup_backup_CFG, "backup", backup_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_B
 	"Maintain a backup of the current metadata configuration.\n"
 	"Think very hard before turning this off!\n")
 
-cfg_runtime(backup_backup_dir_CFG, "backup_dir", backup_CFG_SECTION, 0, CFG_TYPE_STRING, vsn(1, 0, 0), "@DEFAULT_SYS_DIR@/@DEFAULT_BACKUP_SUBDIR@",
+cfg_runtime(backup_backup_dir_CFG, "backup_dir", backup_CFG_SECTION, 0, CFG_TYPE_STRING, vsn(1, 0, 0),
 	"Location of the metadata backup files.\n"
 	"Remember to back up this directory regularly!\n")
 
@@ -541,7 +541,7 @@ cfg(backup_archive_CFG, "archive", backup_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT
 	"Maintain an archive of old metadata configurations.\n"
 	"Think very hard before turning this off.\n")
 
-cfg_runtime(backup_archive_dir_CFG, "archive_dir", backup_CFG_SECTION, 0, CFG_TYPE_STRING, vsn(1, 0, 0), "@DEFAULT_SYS_DIR@/@DEFAULT_ARCHIVE_SUBDIR@",
+cfg_runtime(backup_archive_dir_CFG, "archive_dir", backup_CFG_SECTION, 0, CFG_TYPE_STRING, vsn(1, 0, 0),
 	"Location of the metdata archive files.\n"
 	"Remember to back up this directory regularly!\n")
 
@@ -1053,7 +1053,7 @@ cfg(activation_raid_fault_policy_CFG, "raid_fault_policy", activation_CFG_SECTIO
 	"allocate - Attempt to use any extra physical volumes in the\n"
 	"volume group as spares and replace faulty devices.\n")
 
-cfg_runtime(activation_mirror_image_fault_policy_CFG, "mirror_image_fault_policy", activation_CFG_SECTION, 0, CFG_TYPE_STRING, vsn(2, 2, 57), NULL,
+cfg_runtime(activation_mirror_image_fault_policy_CFG, "mirror_image_fault_policy", activation_CFG_SECTION, 0, CFG_TYPE_STRING, vsn(2, 2, 57),
 	"Defines how a device failure in a 'mirror' LV is handled.\n"
 	"An LV with the 'mirror' segment type is composed of mirror\n"
 	"images (copies) and a mirror log.\n"
@@ -1252,8 +1252,8 @@ cfg_array(metadata_dirs_CFG, "dirs", metadata_CFG_SECTION, CFG_ADVANCED | CFG_DE
 	"Example:\n"
 	"dirs = [ \"/etc/lvm/metadata\", \"/mnt/disk2/lvm/metadata2\" ]\n")
 
-cfg_section(metadata_disk_areas_CFG_SUBSECTION, "disk_areas", metadata_CFG_SECTION, CFG_ADVANCED | CFG_UNSUPPORTED | CFG_DEFAULT_UNDEFINED, vsn(1, 0, 0), NULL, NULL)
-cfg_section(disk_area_CFG_SUBSECTION, "disk_area", metadata_disk_areas_CFG_SUBSECTION, CFG_NAME_VARIABLE | CFG_ADVANCED | CFG_UNSUPPORTED | CFG_DEFAULT_UNDEFINED, vsn(1, 0, 0), NULL, NULL)
+cfg_section(metadata_disk_areas_CFG_SUBSECTION, "disk_areas", metadata_CFG_SECTION, CFG_ADVANCED | CFG_UNSUPPORTED | CFG_DEFAULT_UNDEFINED, vsn(1, 0, 0), NULL)
+cfg_section(disk_area_CFG_SUBSECTION, "disk_area", metadata_disk_areas_CFG_SUBSECTION, CFG_NAME_VARIABLE | CFG_ADVANCED | CFG_UNSUPPORTED | CFG_DEFAULT_UNDEFINED, vsn(1, 0, 0), NULL)
 cfg(disk_area_start_sector_CFG, "start_sector", disk_area_CFG_SUBSECTION, CFG_ADVANCED | CFG_UNSUPPORTED | CFG_DEFAULT_UNDEFINED, CFG_TYPE_INT, 0, vsn(1, 0, 0), NULL, NULL)
 cfg(disk_area_size_CFG, "size", disk_area_CFG_SUBSECTION, CFG_ADVANCED | CFG_UNSUPPORTED | CFG_DEFAULT_UNDEFINED, CFG_TYPE_INT, 0, vsn(1, 0, 0), NULL, NULL)
 cfg(disk_area_id_CFG, "id", disk_area_CFG_SUBSECTION, CFG_ADVANCED | CFG_UNSUPPORTED | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, NULL, vsn(1, 0, 0), NULL, NULL)
@@ -1402,7 +1402,7 @@ cfg(tags_hosttags_CFG, "hosttags", tags_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_H
 	"Create a host tag using the machine name.\n"
 	"The machine name is nodename returned by uname(2).\n")
 
-cfg_section(tag_CFG_SUBSECTION, "tag", tags_CFG_SECTION, CFG_NAME_VARIABLE | CFG_DEFAULT_UNDEFINED, vsn(1, 0, 18), NULL,
+cfg_section(tag_CFG_SUBSECTION, "tag", tags_CFG_SECTION, CFG_NAME_VARIABLE | CFG_DEFAULT_UNDEFINED, vsn(1, 0, 18),
 	"Replace this subsection name with a custom tag name.\n"
 	"Multiple subsections like this can be created.\n"
 	"The '@' prefix for tags is optional.\n"


