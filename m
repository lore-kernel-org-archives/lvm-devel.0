From: Alasdair Kergon <agk@sourceware.org>
Date: Thu, 2 Mar 2017 11:43:23 -0500
Subject: master - tools: Fix overriding of current_settings.
Message-ID: <201703021643.v22GhNDR023302@int-mx11.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=70c1fa3764639afd0d2e81968c4495bb3f3c6a73
Commit:        70c1fa3764639afd0d2e81968c4495bb3f3c6a73
Parent:        8df3f300ba9c6d68d6151ecc5e09543251d17db0
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Mar 2 16:41:41 2017 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Mar 2 16:41:41 2017 +0000

tools: Fix overriding of current_settings.

Settings specified in other command line args take precedence over
profiles and --config, which takes precedence over settings in actual
config files.

Since commit 1e2420bca85da9a37570871cd70192e9ae831786 ('commands: new
method for defining commands') commands like this:
  lvchange --config 'global/test=1' -ay vg
have been printing the 'TEST MODE' message, but nevertheless making
real changes.
---
 tools/lvmcmdline.c |   49 +++++++++++++++++++++++++++++++++++--------------
 1 files changed, 35 insertions(+), 14 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index f5b095c..d5385a8 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -2018,7 +2018,12 @@ int version(struct cmd_context *cmd __attribute__((unused)),
 	return ECMD_PROCESSED;
 }
 
-static void _get_output_settings(struct cmd_context *cmd)
+static void _reset_current_settings_to_default(struct cmd_context *cmd)
+{
+	cmd->current_settings = cmd->default_settings;
+}
+
+static void _get_current_output_settings_from_args(struct cmd_context *cmd)
 {
 	if (arg_is_set(cmd, debug_ARG))
 		cmd->current_settings.debug = _LOG_FATAL + (arg_count(cmd, debug_ARG) - 1);
@@ -2033,7 +2038,7 @@ static void _get_output_settings(struct cmd_context *cmd)
 	}
 }
 
-static void _apply_output_settings(struct cmd_context *cmd)
+static void _apply_current_output_settings(struct cmd_context *cmd)
 {
 	init_debug(cmd->current_settings.debug);
 	init_debug_classes_logged(cmd->default_settings.debug_classes);
@@ -2041,10 +2046,12 @@ static void _apply_output_settings(struct cmd_context *cmd)
 	init_silent(cmd->current_settings.silent);
 }
 
-static int _get_settings(struct cmd_context *cmd)
+static int _get_current_settings(struct cmd_context *cmd)
 {
 	const char *activation_mode;
 
+	_get_current_output_settings_from_args(cmd);
+
 	if (arg_is_set(cmd, test_ARG))
 		cmd->current_settings.test = arg_is_set(cmd, test_ARG);
 
@@ -2217,8 +2224,10 @@ int help(struct cmd_context *cmd __attribute__((unused)), int argc, char **argv)
 	return ret;
 }
 
-static void _apply_settings(struct cmd_context *cmd)
+static void _apply_current_settings(struct cmd_context *cmd)
 {
+	_apply_current_output_settings(cmd);
+
 	init_test(cmd->current_settings.test);
 	init_full_scan_done(0);
 	init_mirror_in_sync(0);
@@ -2542,13 +2551,12 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 	}
 
 	/*
-	 * log_debug() can be enabled now that we know the settings
-	 * from the command.  Previous calls to log_debug() will
-	 * do nothing.
+	 * Now we have the command line args, set up any known output logging
+	 * options immediately.
 	 */
-	cmd->current_settings = cmd->default_settings;
-	_get_output_settings(cmd);
-	_apply_output_settings(cmd);
+	_reset_current_settings_to_default(cmd);
+	_get_current_output_settings_from_args(cmd);
+	_apply_current_output_settings(cmd);
 
 	log_debug("Parsing: %s", cmd->cmd_line);
 
@@ -2609,9 +2617,17 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 	if (arg_is_set(cmd, readonly_ARG))
 		cmd->metadata_read_only = 1;
 
-	if ((ret = _get_settings(cmd)))
+	/*
+	 * Now that all configs, profiles and command lines args are available,
+	 * freshly calculate and apply all settings.  Specific command line
+	 * options take precedence over config files (which include --config as
+	 * that is treated like a config file).
+	 */
+	_reset_current_settings_to_default(cmd);
+	if ((ret = _get_current_settings(cmd)))
 		goto_out;
-	_apply_settings(cmd);
+	_apply_current_settings(cmd);
+
 	if (cmd->degraded_activation)
 		log_debug("DEGRADED MODE. Incomplete RAID LVs will be processed.");
 
@@ -2762,8 +2778,13 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 
 	log_debug("Completed: %s", cmd->cmd_line);
 
-	cmd->current_settings = cmd->default_settings;
-	_apply_settings(cmd);
+	/*
+	 * Reset all settings back to the persistent defaults that
+	 * ignore everything supplied on the command line of the
+	 * completed command.
+	 */
+	_reset_current_settings_to_default(cmd);
+	_apply_current_settings(cmd);
 
 	/*
 	 * free off any memory the command used.


