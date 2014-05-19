From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 19 May 2014 13:43:55 +0000 (UTC)
Subject: master - config: fix incorrect profile initialization on cmd context refresh
Message-ID: <20140519134355.48FF460CFE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9a324df3b329f1a28462f246219522da62a022ce
Commit:        9a324df3b329f1a28462f246219522da62a022ce
Parent:        c42f72867a653974f07e6e1db52f41691356e5b7
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon May 19 13:59:23 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon May 19 15:39:55 2014 +0200

config: fix incorrect profile initialization on cmd context refresh

When cmd refresh is called, we need to move any already loaded profiles
to profiles_to_load list which will cause their reload on subsequent
use. In addition to that, we need to take into account any change
in config/profile configuration setting on cmd context refresh
since this setting could be overriden with --config.

Also, when running commands in the shell, we need to remove the
global profile used from the configuration cascade so the profile
is not incorrectly reused next time when the --profile option is
not specified anymore for the next command in the shell.

This bug only affected profile specified by --profile cmd line
arg, not profiles referenced from LVM metadata.
---
 WHATS_NEW                  |    1 +
 lib/commands/toolcontext.c |   50 ++++++++++++++++++++++++++++++++++---------
 lib/config/config.h        |    2 +-
 tools/lvmcmdline.c         |   18 +++++++++------
 4 files changed, 52 insertions(+), 19 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 72834a8..06d0854 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.107 - 
 ==================================
+  Fix wrong profile reuse from previous run if another cmd is run in lvm shell.
   Move cache description from lvm(8) to lvmcache(7) man page.
   Display skipped prompt in silent mode.
   Make reporting commands show help about possible sort keys on '-O help'.
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 03b06d2..904ae83 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -630,8 +630,9 @@ static int _init_profiles(struct cmd_context *cmd)
 {
 	const char *dir;
 	struct profile_params *pp;
+	int initialized = cmd->profile_params != NULL;
 
-	if (!(pp = dm_pool_zalloc(cmd->libmem, sizeof(*pp)))) {
+	if (!initialized && !(pp = dm_pool_zalloc(cmd->libmem, sizeof(*pp)))) {
 		log_error("profile_params alloc failed");
 		return 0;
 	}
@@ -639,11 +640,15 @@ static int _init_profiles(struct cmd_context *cmd)
 	if (!(dir = find_config_tree_str(cmd, config_profile_dir_CFG, NULL)))
 		return_0;
 
-	pp->dir = dm_pool_strdup(cmd->libmem, dir);
-	dm_list_init(&pp->profiles_to_load);
-	dm_list_init(&pp->profiles);
+	if (initialized) {
+		dm_strncpy(cmd->profile_params->dir, dir, sizeof(pp->dir));
+	} else {
+		dm_strncpy(pp->dir, dir, sizeof(pp->dir));
+		dm_list_init(&pp->profiles_to_load);
+		dm_list_init(&pp->profiles);
+		cmd->profile_params = pp;
+	}
 
-	cmd->profile_params = pp;
 	return 1;
 }
 
@@ -693,7 +698,7 @@ static void _destroy_config(struct cmd_context *cmd)
 {
 	struct config_tree_list *cfl;
 	struct dm_config_tree *cft;
-	struct profile *profile;
+	struct profile *profile, *tmp_profile;
 
 	/*
 	 * Configuration cascade:
@@ -713,12 +718,17 @@ static void _destroy_config(struct cmd_context *cmd)
 	/* CONFIG_PROFILE */
 	if (cmd->profile_params) {
 		remove_config_tree_by_source(cmd, CONFIG_PROFILE);
-		dm_list_iterate_items(profile, &cmd->profile_params->profiles_to_load)
-			config_destroy(profile->cft);
-		dm_list_iterate_items(profile, &cmd->profile_params->profiles)
+		/*
+		 * Destroy config trees for any loaded profiles and
+		 * move these profiles to profile_to_load list.
+		 * Whenever these profiles are referenced later,
+		 * they will get loaded again automatically.
+		 */
+		dm_list_iterate_items_safe(profile, tmp_profile, &cmd->profile_params->profiles) {
 			config_destroy(profile->cft);
-		dm_list_init(&cmd->profile_params->profiles_to_load);
-		dm_list_init(&cmd->profile_params->profiles);
+			profile->cft = NULL;
+			dm_list_move(&cmd->profile_params->profiles_to_load, &profile->list);
+		}
 	}
 
 	/* CONFIG_STRING */
@@ -1595,6 +1605,8 @@ int refresh_filters(struct cmd_context *cmd)
 int refresh_toolcontext(struct cmd_context *cmd)
 {
 	struct dm_config_tree *cft_cmdline, *cft_tmp;
+	const char *profile_name;
+	struct profile *profile;
 
 	log_verbose("Reloading config files");
 
@@ -1617,7 +1629,13 @@ int refresh_toolcontext(struct cmd_context *cmd)
 	_destroy_dev_types(cmd);
 	_destroy_tags(cmd);
 
+	/* save config string passed on the command line */
 	cft_cmdline = remove_config_tree_by_source(cmd, CONFIG_STRING);
+
+	/* save the global profile name used */
+	profile_name = cmd->profile_params->global_profile ?
+			cmd->profile_params->global_profile->name : NULL;
+
 	_destroy_config(cmd);
 
 	cmd->config_initialized = 0;
@@ -1634,6 +1652,13 @@ int refresh_toolcontext(struct cmd_context *cmd)
 	if (cft_cmdline)
 		cmd->cft = dm_config_insert_cascaded_tree(cft_cmdline, cft_tmp);
 
+	/* Reload the global profile. */
+	if (profile_name) {
+		if (!(profile = add_profile(cmd, profile_name)) ||
+		    !override_config_tree_from_profile(cmd, profile))
+			return_0;
+	}
+
 	/* Uses cmd->cft i.e. cft_cmdline + lvm.conf */
 	_init_logging(cmd);
 
@@ -1657,6 +1682,9 @@ int refresh_toolcontext(struct cmd_context *cmd)
 	if (!_process_config(cmd))
 		return_0;
 
+	if (!_init_profiles(cmd))
+		return_0;
+
 	if (!(cmd->dev_types = create_dev_types(cmd->proc_dir,
 						find_config_tree_node(cmd, devices_types_CFG, NULL))))
 		return_0;
diff --git a/lib/config/config.h b/lib/config/config.h
index 4967b27..df5841c 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -41,7 +41,7 @@ struct profile {
 };
 
 struct profile_params {
-	const char *dir;                /* subdir in LVM_SYSTEM_DIR where LVM looks for profiles */
+	char dir[PATH_MAX];             /* subdir in LVM_SYSTEM_DIR where LVM looks for profiles */
 	struct profile *global_profile; /* profile that overrides any other VG/LV-based profile ('--profile' cmd line arg) */
 	struct dm_list profiles_to_load;/* list of profiles which are only added, but still need to be loaded for any use */
 	struct dm_list profiles;	/* list of profiles which are loaded already and which are ready for use */
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 7e4d9a6..69e5781 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1081,11 +1081,11 @@ static const char *_copy_command_line(struct cmd_context *cmd, int argc, char **
 
 int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 {
+	struct dm_config_tree *config_string_cft, *config_profile_cft;
+	struct profile *profile;
 	int ret = 0;
 	int locking_type;
 	int monitoring;
-	struct dm_config_tree *old_cft;
-	struct profile *profile;
 
 	init_error_message_produced(0);
 
@@ -1124,9 +1124,8 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 	if (arg_count(cmd, config_ARG) || !cmd->config_initialized || config_files_changed(cmd)) {
 		/* Reinitialise various settings inc. logging, filters */
 		if (!refresh_toolcontext(cmd)) {
-			old_cft = remove_config_tree_by_source(cmd, CONFIG_STRING);
-			if (old_cft)
-				dm_config_destroy(old_cft);
+			if ((config_string_cft = remove_config_tree_by_source(cmd, CONFIG_STRING)))
+				dm_config_destroy(config_string_cft);
 			log_error("Updated config file invalid. Aborting.");
 			return ECMD_FAILED;
 		}
@@ -1204,8 +1203,13 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 		lvmcache_destroy(cmd, 1, 0);
 	}
 
-	if ((old_cft = remove_config_tree_by_source(cmd, CONFIG_STRING))) {
-		dm_config_destroy(old_cft);
+	if ((config_string_cft = remove_config_tree_by_source(cmd, CONFIG_STRING)))
+		dm_config_destroy(config_string_cft);
+
+	config_profile_cft = remove_config_tree_by_source(cmd, CONFIG_PROFILE);
+	cmd->profile_params->global_profile = NULL;
+
+	if (config_string_cft || config_profile_cft) {
 		/* Move this? */
 		if (!refresh_toolcontext(cmd))
 			stack;


