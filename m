From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 13 Feb 2017 18:10:39 +0000 (UTC)
Subject: master - command struct: remove command name refs
Message-ID: <20170213181039.38B306039D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=013c080756dcc2faaecc80b489d85d7ab1384cbf
Commit:        013c080756dcc2faaecc80b489d85d7ab1384cbf
Parent:        d9d5b8414bb5ead7dbd223606a735497c0c069f9
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jan 13 15:08:51 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Feb 13 08:20:10 2017 -0600

command struct: remove command name refs

Change run time access to the command_name struct
cmd->cname instead of indirectly through
cmd->command->cname. This removes the two run time
fields from struct command.
---
 lib/commands/toolcontext.h |    1 +
 tools/command.h            |    4 ----
 tools/lvconvert.c          |    4 ++--
 tools/lvmcmdline.c         |   23 +++++++++++------------
 tools/pvscan.c             |    2 +-
 tools/toollib.c            |   18 +++++++++---------
 tools/vgchange.c           |    2 +-
 tools/vgimportclone.c      |    2 +-
 8 files changed, 26 insertions(+), 30 deletions(-)

diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 2dc1c28..20b24f9 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -89,6 +89,7 @@ struct cmd_context {
 	 */
 	const char *cmd_line;
 	const char *name; /* needed before cmd->command is set */
+	struct command_name *cname;
 	struct command *command;
 	char **argv;
 	struct arg_values *opt_arg_values;
diff --git a/tools/command.h b/tools/command.h
index d66ec52..c9be260 100644
--- a/tools/command.h
+++ b/tools/command.h
@@ -164,13 +164,9 @@ struct command {
 	const char *command_line_id;
 	int command_line_enum; /* <command_line_id>_CMD */
 
-	struct command_name *cname;
-
 	command_fn fn;                      /* old style */
 	struct command_function *functions; /* new style */
 
-	unsigned int flags; /* copied from command_name.flags from commands.h */
-
 	unsigned int cmd_flags; /* CMD_FLAG_ */
 
 	/* definitions of opt/pos args */
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 757e8b4..1d7dc1b 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -4512,7 +4512,7 @@ static int _lvconvert_merge_mirror_images_single(struct cmd_context *cmd,
 int lvconvert_merge_mirror_images_cmd(struct cmd_context *cmd, int argc, char **argv)
 {
 	/* arg can be a VG name, which is the standard option usage */
-	cmd->command->flags &= ~GET_VGNAME_FROM_OPTIONS;
+	cmd->cname->flags &= ~GET_VGNAME_FROM_OPTIONS;
 
 	return process_each_lv(cmd, cmd->position_argc, cmd->position_argv, NULL, NULL, READ_FOR_UPDATE,
 			       NULL, &_lvconvert_visible_check, &_lvconvert_merge_mirror_images_single);
@@ -4552,7 +4552,7 @@ int lvconvert_merge_cmd(struct cmd_context *cmd, int argc, char **argv)
 
 	handle->custom_handle = &lr;
 
-	cmd->command->flags &= ~GET_VGNAME_FROM_OPTIONS;
+	cmd->cname->flags &= ~GET_VGNAME_FROM_OPTIONS;
 
 	ret = process_each_lv(cmd, cmd->position_argc, cmd->position_argv, NULL, NULL, READ_FOR_UPDATE,
 			      handle, NULL, &_lvconvert_merge_generic_single);
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index ddc87f9..dda4b16 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1092,7 +1092,6 @@ static void _define_commands(void)
 
 void lvm_register_commands(void)
 {
-	struct command_name *cname;
 	int i;
 
 	memset(&commands, 0, sizeof(commands));
@@ -1102,13 +1101,8 @@ void lvm_register_commands(void)
 	_cmdline.commands = commands;
 	_cmdline.num_commands = COMMAND_COUNT;
 
-	for (i = 0; i < COMMAND_COUNT; i++) {
-		if (!(cname = _find_command_name(commands[i].name)))
-			log_error(INTERNAL_ERROR "Failed to find command name %s.", commands[i].name);
-		commands[i].cname = cname;
-		commands[i].flags = cname->flags;
+	for (i = 0; i < COMMAND_COUNT; i++)
 		commands[i].functions = _find_command_function(commands[i].command_line_enum);
-	}
 
 	_cmdline.command_names = command_names;
 
@@ -2193,7 +2187,7 @@ static int _get_settings(struct cmd_context *cmd)
 
 	cmd->current_settings.archive = arg_int_value(cmd, autobackup_ARG, cmd->current_settings.archive);
 	cmd->current_settings.backup = arg_int_value(cmd, autobackup_ARG, cmd->current_settings.backup);
-	cmd->current_settings.cache_vgmetadata = cmd->command->flags & CACHE_VGMETADATA ? 1 : 0;
+	cmd->current_settings.cache_vgmetadata = cmd->cname->flags & CACHE_VGMETADATA ? 1 : 0;
 
 	if (arg_is_set(cmd, readonly_ARG)) {
 		cmd->current_settings.activation = 0;
@@ -2201,7 +2195,7 @@ static int _get_settings(struct cmd_context *cmd)
 		cmd->current_settings.backup = 0;
 	}
 
-	if (cmd->command->flags & LOCKD_VG_SH)
+	if (cmd->cname->flags & LOCKD_VG_SH)
 		cmd->lockd_vg_default_sh = 1;
 
 	cmd->partial_activation = 0;
@@ -2613,7 +2607,7 @@ static int _init_lvmlockd(struct cmd_context *cmd)
 
 static int _cmd_no_meta_proc(struct cmd_context *cmd)
 {
-	return cmd->command->flags & NO_METADATA_PROCESSING;
+	return cmd->cname->flags & NO_METADATA_PROCESSING;
 }
 
 int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
@@ -2688,6 +2682,11 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 
 	log_debug("Parsing: %s", cmd->cmd_line);
 
+	if (!(cmd->cname = _find_command_name(cmd->name))) {
+		log_error("Command name not found.\n");
+		return EINVALID_CMD_LINE;
+	}
+
 	if (!(cmd->command = _find_command(cmd, cmd->name, &argc, argv)))
 		return EINVALID_CMD_LINE;
 
@@ -2772,7 +2771,7 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 	}
 
 	if (cmd->metadata_read_only &&
-	    !(cmd->command->flags & PERMITTED_READ_ONLY)) {
+	    !(cmd->cname->flags & PERMITTED_READ_ONLY)) {
 		log_error("%s: Command not permitted while global/metadata_read_only "
 			  "is set.", cmd->cmd_line);
 		goto out;
@@ -2832,7 +2831,7 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 	 * In this case, disable the *use* of lvmetad by this command, reverting to
 	 * disk scanning.
 	 */
-	if (lvmetad_used() && !(cmd->command->flags & NO_LVMETAD_AUTOSCAN)) {
+	if (lvmetad_used() && !(cmd->cname->flags & NO_LVMETAD_AUTOSCAN)) {
 		if (cmd->include_foreign_vgs || !lvmetad_token_matches(cmd)) {
 			if (lvmetad_used() && !lvmetad_pvscan_all_devs(cmd, cmd->include_foreign_vgs ? 1 : 0)) {
 				log_warn("WARNING: Not using lvmetad because cache update failed.");
diff --git a/tools/pvscan.c b/tools/pvscan.c
index e2b0a83..ca33a2a 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -284,7 +284,7 @@ static int _pvscan_autoactivate(struct cmd_context *cmd, struct pvscan_aa_params
 	handle->custom_handle = pp;
 
 	if (all_vgs) {
-		cmd->command->flags |= ALL_VGS_IS_DEFAULT;
+		cmd->cname->flags |= ALL_VGS_IS_DEFAULT;
 		pp->refresh_all = 1;
 	}
 
diff --git a/tools/toollib.c b/tools/toollib.c
index 36599e0..2c0096f 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -2093,7 +2093,7 @@ static void _choose_vgs_to_process(struct cmd_context *cmd,
 		 * matches the UUID of a VG.  (--select should generally
 		 * be used to select a VG by uuid instead.)
 		 */
-		if (!found && (cmd->command->flags & ALLOW_UUID_AS_NAME))
+		if (!found && (cmd->cname->flags & ALLOW_UUID_AS_NAME))
 			arg_is_uuid = id_read_format_try(&id, sl->str);
 
 		if (!found && arg_is_uuid) {
@@ -2162,7 +2162,7 @@ int process_each_vg(struct cmd_context *cmd,
 	struct dm_list arg_vgnames;		/* str_list */
 	struct dm_list vgnameids_on_system;	/* vgnameid_list */
 	struct dm_list vgnameids_to_process;	/* vgnameid_list */
-	int enable_all_vgs = (cmd->command->flags & ALL_VGS_IS_DEFAULT);
+	int enable_all_vgs = (cmd->cname->flags & ALL_VGS_IS_DEFAULT);
 	int process_all_vgs_on_system = 0;
 	int ret_max = ECMD_PROCESSED;
 	int ret;
@@ -2209,7 +2209,7 @@ int process_each_vg(struct cmd_context *cmd,
 	 * label scan to be done.  get_vgnameids() will scan labels
 	 * (when not using lvmetad).
 	 */
-	if (cmd->command->flags & REQUIRES_FULL_LABEL_SCAN) {
+	if (cmd->cname->flags & REQUIRES_FULL_LABEL_SCAN) {
 		dev_cache_full_scan(cmd->full_filter);
 		lvmcache_force_next_label_scan();
 	}
@@ -3655,7 +3655,7 @@ int process_each_lv(struct cmd_context *cmd,
 	struct dm_list arg_lvnames;		/* str_list */
 	struct dm_list vgnameids_on_system;	/* vgnameid_list */
 	struct dm_list vgnameids_to_process;	/* vgnameid_list */
-	int enable_all_vgs = (cmd->command->flags & ALL_VGS_IS_DEFAULT);
+	int enable_all_vgs = (cmd->cname->flags & ALL_VGS_IS_DEFAULT);
 	int process_all_vgs_on_system = 0;
 	int ret_max = ECMD_PROCESSED;
 	int ret;
@@ -3674,7 +3674,7 @@ int process_each_lv(struct cmd_context *cmd,
 	/*
 	 * Find any LVs, VGs or tags explicitly provided on the command line.
 	 */
-	if (cmd->command->flags & GET_VGNAME_FROM_OPTIONS)
+	if (cmd->cname->flags & GET_VGNAME_FROM_OPTIONS)
 		ret = _get_arg_lvnames_using_options(cmd, argc, argv, &arg_vgnames, &arg_lvnames, &arg_tags);
 	else
 		ret = _get_arg_lvnames(cmd, argc, argv, one_vgname, one_lvname, &arg_vgnames, &arg_lvnames, &arg_tags);
@@ -4032,7 +4032,7 @@ static int _process_duplicate_pvs(struct cmd_context *cmd,
 		if (!process_all_devices && !dil)
 			continue;
 
-		if (!(cmd->command->flags & ENABLE_DUPLICATE_DEVS))
+		if (!(cmd->cname->flags & ENABLE_DUPLICATE_DEVS))
 			continue;
 
 		/*
@@ -4387,7 +4387,7 @@ int process_each_pv(struct cmd_context *cmd,
 		goto_out;
 	}
 
-	if ((cmd->command->flags & DISALLOW_TAG_ARGS) && !dm_list_empty(&arg_tags)) {
+	if ((cmd->cname->flags & DISALLOW_TAG_ARGS) && !dm_list_empty(&arg_tags)) {
 		log_error("Tags cannot be used with this command.");
 		return ECMD_FAILED;
 	}
@@ -4396,7 +4396,7 @@ int process_each_pv(struct cmd_context *cmd,
 
 	process_all_pvs = dm_list_empty(&arg_pvnames) && dm_list_empty(&arg_tags);
 
-	process_all_devices = process_all_pvs && (cmd->command->flags & ENABLE_ALL_DEVS) && all_is_set;
+	process_all_devices = process_all_pvs && (cmd->cname->flags & ENABLE_ALL_DEVS) && all_is_set;
 
 	/* Needed for a current listing of the global VG namespace. */
 	if (!only_this_vgname && !lockd_gl(cmd, "sh", 0)) {
@@ -5285,7 +5285,7 @@ int pvcreate_each_device(struct cmd_context *cmd,
 	struct pv_list *vgpvl;
 	const char *pv_name;
 	int consistent = 0;
-	int must_use_all = (cmd->command->flags & MUST_USE_ALL_ARGS);
+	int must_use_all = (cmd->cname->flags & MUST_USE_ALL_ARGS);
 	int found;
 	unsigned i;
 
diff --git a/tools/vgchange.c b/tools/vgchange.c
index 4cf8a3c..2a8f868 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -1095,7 +1095,7 @@ static int _lockd_vgchange(struct cmd_context *cmd, int argc, char **argv)
 	 */
 
 	if (arg_is_set(cmd, systemid_ARG) || arg_is_set(cmd, locktype_ARG))
-		cmd->command->flags &= ~ALL_VGS_IS_DEFAULT;
+		cmd->cname->flags &= ~ALL_VGS_IS_DEFAULT;
 
 	if (arg_is_set(cmd, systemid_ARG) || arg_is_set(cmd, locktype_ARG)) {
 		/*
diff --git a/tools/vgimportclone.c b/tools/vgimportclone.c
index b23b14e..1f86ad6 100644
--- a/tools/vgimportclone.c
+++ b/tools/vgimportclone.c
@@ -240,7 +240,7 @@ int vgimportclone(struct cmd_context *cmd, int argc, char **argv)
 	 */
 
 	log_debug("Finding devices to import.");
-	cmd->command->flags |= ENABLE_DUPLICATE_DEVS;
+	cmd->cname->flags |= ENABLE_DUPLICATE_DEVS;
 	process_each_pv(cmd, argc, argv, NULL, 0, READ_ALLOW_EXPORTED, handle, _vgimportclone_pv_single);
 
 	if (vp.found_args != argc) {


