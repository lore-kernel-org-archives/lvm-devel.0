From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 26 Jun 2013 14:55:46 +0000 (UTC)
Subject: dev-peter-config-profiles - config: add support for loading profiles
Message-ID: <20130626145546.3450F60F23@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=070ffe7822089eefac9c4ed867ada0ee45634536
Commit:        070ffe7822089eefac9c4ed867ada0ee45634536
Parent:        f15a403a256f033d18bd53f8d155cb2686e02a1c
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jun 25 12:27:04 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jun 26 16:53:49 2013 +0200

config: add support for loading profiles

This patch adds --profile arg to lvm cmds and adds config/profile_dir
configuration setting to select the directory where profile are stored
By default it's /etc/lvm/profile.

The profiles are loaded using the new "load_profile" fn and all
profiles are stored in a cmd context withing the new
"struct profile_params":

struct profile_params {
  const char *dir;
  struct profile *global_profile;
  struct dm_list profiles;
};

...where "dir" is the directory with profiles, "global_profile" is
the profile that is set globally via the --profile arg (IOW, not
set per VG/LV basis based on metadata record) and the "profiles"
is the list with loaded profiles.
---
 doc/example.conf.in          |    3 +
 lib/commands/toolcontext.c   |   89 +++++++++++++++++++++++++++++++++++++++++-
 lib/commands/toolcontext.h   |    3 +
 lib/config/config.h          |   14 +++++++
 lib/config/config_settings.h |    1 +
 tools/args.h                 |    1 +
 tools/lvmcmdline.c           |   13 ++++++-
 7 files changed, 122 insertions(+), 2 deletions(-)

diff --git a/doc/example.conf.in b/doc/example.conf.in
index 1620721..9ae754f 100644
--- a/doc/example.conf.in
+++ b/doc/example.conf.in
@@ -23,6 +23,9 @@ config {
 
     # If enabled, any configuration mismatch aborts the LVM2 process.
     abort_on_errors = 0
+
+    # Directory where LVM looks for configuration profiles.
+    profile_dir = "@DEFAULT_SYS_DIR@/profiles"
 }
 
 # This section allows you to configure which block devices should
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 4299d8c..b4658f5 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -597,6 +597,51 @@ static int _load_config_file(struct cmd_context *cmd, const char *tag)
 	return 1;
 }
 
+struct profile *load_profile(struct cmd_context *cmd, const char *profile_name)
+{
+	static char profile_path[PATH_MAX];
+	struct profile *profile;
+
+	/* Do some sanity checks first. */
+	if (!profile_name || !*profile_name) {
+		log_error("Undefined profile name.");
+		return NULL;
+	}
+
+	if (strchr(profile_name, '/')) {
+		log_error("%s: bad profile name, it contains '/'.", profile_name);
+		return NULL;
+	}
+
+	/* Check if the profile is already loaded... */
+	dm_list_iterate_items(profile, &cmd->profile_params->profiles) {
+		if (!strcmp(profile->name, profile_name))
+			return profile;
+	}
+
+	/* ...if it's not loaded yet, load it and add it to the profile list. */
+	if (dm_snprintf(profile_path, sizeof(profile_path), "%s/%s.profile",
+		cmd->profile_params->dir, profile_name) < 0) {
+		log_error("LVM_SYSTEM_DIR or profile name too long");
+		return NULL;
+	}
+
+	if (!(profile = dm_pool_zalloc(cmd->libmem, sizeof(*profile)))) {
+		log_error("profile allocation failed");
+		return NULL;
+	}
+
+	profile->name = dm_pool_strdup(cmd->libmem, profile_name);
+	if (!(profile->cft = _open_and_read_config_file(profile_path, CONFIG_PROFILE))) {
+		dm_pool_free(cmd->libmem, profile);
+		return_NULL;
+	}
+
+	dm_list_add(&cmd->profile_params->profiles, &profile->list);
+
+	return profile;
+}
+
 /* Find and read first config file */
 static int _init_lvm_conf(struct cmd_context *cmd)
 {
@@ -629,6 +674,34 @@ static int _init_tag_configs(struct cmd_context *cmd)
 	return 1;
 }
 
+static int _init_profiles(struct cmd_context *cmd)
+{
+	static char default_dir[PATH_MAX];
+	const char *dir;
+	struct profile_params *pp;
+
+	if (!(pp = dm_pool_zalloc(cmd->libmem, sizeof(*pp)))) {
+		log_error("profile_params alloc failed");
+		return 0;
+	}
+
+	if (!(dir = find_config_tree_str(cmd, config_profile_dir_CFG))) {
+		if (dm_snprintf(default_dir, sizeof(default_dir), "%s/%s",
+				cmd->system_dir, DEFAULT_PROFILE_SUBDIR) == -1) {
+			log_error("Couldn't create default profile path '%s/%s'.",
+				  cmd->system_dir, DEFAULT_PROFILE_SUBDIR);
+			return 0;
+		}
+		dir = default_dir;
+	}
+
+	pp->dir = dm_pool_strdup(cmd->libmem, dir);
+	dm_list_init(&pp->profiles);
+
+	cmd->profile_params = pp;
+	return 1;
+}
+
 static struct dm_config_tree *_merge_config_files(struct cmd_context *cmd, struct dm_config_tree *cft)
 {
 	struct config_tree_list *cfl;
@@ -675,12 +748,14 @@ static void _destroy_config(struct cmd_context *cmd)
 {
 	struct config_tree_list *cfl;
 	struct dm_config_tree *cft;
+	struct profile *profile;
 
 	/*
 	 * Configuration cascade:
-	 * CONFIG_STRING -> CONFIG_FILE/CONFIG_MERGED_FILES
+	 * CONFIG_STRING -> CONFIG_PROFILE -> CONFIG_FILE/CONFIG_MERGED_FILES
 	 *
 	 * CONFIG_STRING - the configuration string passed in command line via '--config'
+	 * CONFIG_PROFILE - the profile used or selected via '--profile'
 	 * CONFIG_MERGED_FILES - merged master lvm.conf and tag configurations
 	 * CONFIG_FILE - master lvm.conf only
 	 */
@@ -695,6 +770,14 @@ static void _destroy_config(struct cmd_context *cmd)
 		config_destroy(cfl->cft);
 	dm_list_init(&cmd->config_files);
 
+	/* CONFIG_PROFILE */
+	if (cmd->profile_params) {
+		remove_config_tree_by_source(cmd, CONFIG_PROFILE);
+		dm_list_iterate_items(profile, &cmd->profile_params->profiles)
+			config_destroy(profile->cft);
+		dm_list_init(&cmd->profile_params->profiles);
+	}
+
 	/* CONFIG_STRING */
 	if ((cft = remove_config_tree_by_source(cmd, CONFIG_STRING)))
 		config_destroy(cft);
@@ -1463,6 +1546,9 @@ struct cmd_context *create_toolcontext(unsigned is_long_lived,
 	if (!_process_config(cmd))
 		goto_out;
 
+	if (!_init_profiles(cmd))
+		goto_out;
+
 	if (!(cmd->dev_types = create_dev_types(cmd->proc_dir,
 						find_config_tree_node(cmd, devices_types_CFG))))
 		goto_out;
@@ -1506,6 +1592,7 @@ out:
 		cmd = NULL;
 	}
 
+
 	return cmd;
 }
 
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index f6a09a7..7551245 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -51,6 +51,7 @@ struct config_info {
 };
 
 struct dm_config_tree;
+struct profile_params;
 struct archive_params;
 struct backup_params;
 struct arg_values;
@@ -104,6 +105,8 @@ struct cmd_context {
 	struct config_info current_settings;
 	struct dm_hash_table *cft_def_hash; /* cft definition hash used for validity check */
 
+	struct profile_params *profile_params;
+
 	struct archive_params *archive_params;
 	struct backup_params *backup_params;
 	const char *stripe_filler;
diff --git a/lib/config/config.h b/lib/config/config.h
index 2f5cee6..93811fb 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -34,6 +34,18 @@ typedef enum {
 	CONFIG_PROFILE
 } config_source_t;
 
+struct profile {
+	struct dm_list list;
+	const char *name;
+	struct dm_config_tree *cft;
+};
+
+struct profile_params {
+	const char *dir;
+	struct profile *global_profile;
+	struct dm_list profiles;
+};
+
 #define CFG_PATH_MAX_LEN 64
 
 /*
@@ -114,6 +126,8 @@ enum {
 #undef cfg_array
 };
 
+struct profile *load_profile(struct cmd_context *cmd, const char *profile_name);
+
 int config_def_get_path(char *buf, size_t buf_size, int id);
 int config_def_check(struct cmd_context *cmd, int force, int skip, int suppress_messages);
 
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 6229f2e..65d869b 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -68,6 +68,7 @@ cfg_section(tags_CFG_SECTION, "tags", root_CFG_SECTION, 0, vsn(1, 0, 18), NULL)
 
 cfg(config_checks_CFG, "checks", config_CFG_SECTION, 0, CFG_TYPE_BOOL, 1, vsn(2, 2, 99), "Configuration tree check on each LVM command execution.")
 cfg(config_abort_on_errors_CFG, "abort_on_errors", config_CFG_SECTION, 0, CFG_TYPE_BOOL, 0, vsn(2,2,99), "Abort LVM command execution if configuration is invalid.")
+cfg(config_profile_dir_CFG, "profile_dir", config_CFG_SECTION, 0, CFG_TYPE_STRING, 0, vsn(2, 2, 99), "Directory with configuration profiles.")
 
 cfg(devices_dir_CFG, "dir", devices_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_DEV_DIR, vsn(1, 0, 0), NULL)
 cfg_array(devices_scan_CFG, "scan", devices_CFG_SECTION, 0, CFG_TYPE_STRING, "#S/dev", vsn(1, 0, 0), NULL)
diff --git a/tools/args.h b/tools/args.h
index 2fed97e..cadd211 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -91,6 +91,7 @@ arg(writemostly_ARG, '\0', "writemostly", string_arg, ARG_GROUPABLE)
 arg(writebehind_ARG, '\0', "writebehind", int_arg, 0)
 arg(minrecoveryrate_ARG, '\0', "minrecoveryrate", size_kb_arg, 0)
 arg(maxrecoveryrate_ARG, '\0', "maxrecoveryrate", size_kb_arg, 0)
+arg(profile_ARG, '\0', "profile", string_arg, 0)
 
 /* Allow some variations */
 arg(resizable_ARG, '\0', "resizable", yes_no_arg, 0)
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 51bbcd2..9bf3d93 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -620,7 +620,8 @@ void lvm_register_commands(void)
 					    debug_ARG, help_ARG, help2_ARG, \
 					    version_ARG, verbose_ARG, \
 					    yes_ARG, \
-					    quiet_ARG, config_ARG, -1);
+					    quiet_ARG, config_ARG, \
+					    profile_ARG, -1);
 #include "commands.h"
 #undef xx
 }
@@ -1051,6 +1052,7 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 	int locking_type;
 	int monitoring;
 	struct dm_config_tree *old_cft;
+	struct profile *profile;
 
 	init_error_message_produced(0);
 
@@ -1091,6 +1093,15 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 		}
 	}
 
+	if (arg_count(cmd, profile_ARG)) {
+		if (!(profile = load_profile(cmd, arg_str_value(cmd, profile_ARG, NULL)))) {
+			log_error("Failed to load configuration profile.");
+			return ECMD_FAILED;
+		}
+		log_debug("Setting global configuration profile \"%s\".", profile->name);
+		cmd->profile_params->global_profile = profile;
+	}
+
 	if ((ret = _get_settings(cmd)))
 		goto_out;
 	_apply_settings(cmd);


