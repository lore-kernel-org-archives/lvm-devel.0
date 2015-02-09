From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon,  9 Feb 2015 13:19:47 +0000 (UTC)
Subject: master - lvm: recognize LVM_COMMAND_PROFILE env var for default command profile to use in LVM commands
Message-ID: <20150209131947.BA0D560D9B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b6f558adcc3b08cb627aca0a0cddbe65bdd19052
Commit:        b6f558adcc3b08cb627aca0a0cddbe65bdd19052
Parent:        4e4ea46cfee9afcfc9a48eb60925177890c5ec31
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Feb 9 14:16:24 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Feb 9 14:16:30 2015 +0100

lvm: recognize LVM_COMMAND_PROFILE env var for default command profile to use in LVM commands

Once LVM_COMMAND_PROFILE environment variable is specified, the profile
referenced is used just like it was specified using "<lvm command> --commandprofile".
If both --commandprofile cmd line option and LVM_COMMAND_PROFILE env
var is used, the --commandprofile cmd line option gets preference.
---
 WHATS_NEW          |    1 +
 man/lvm.8.in       |    8 ++++++-
 tools/lvmcmdline.c |   53 ++++++++++++++++++++++++++++++++++++++++++++-------
 3 files changed, 53 insertions(+), 9 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index cd4abfe..6488f44 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.117 - 
 ====================================
+  Add LVM_COMMAND_PROFILE env var to set default command profile name to use.
   set CLOEXEC flag on file descriptors originating in libdaemon
 
 Version 2.02.116 - 30th January 2015
diff --git a/man/lvm.8.in b/man/lvm.8.in
index 5347e94..f87729e 100644
--- a/man/lvm.8.in
+++ b/man/lvm.8.in
@@ -291,7 +291,9 @@ placing two stripes on the same Physical Volume.
 .IR \fB\-\-commandprofile " " \fIProfileName
 Selects the command configuration profile to use when processing an LVM command.
 See also \fBlvm.conf\fP(5) for more information about \fBcommand profile config\fP and
-the way it fits with other LVM configuration methods.
+the way it fits with other LVM configuration methods. Using \fB\-\-commandprofile\fP
+option overrides any command profile specified via \fBLVM_COMMAND_PROFILE\fP
+environment variable.
 .TP
 .IR \fB\-\-metadataprofile " " \fIProfileName
 Selects the metadata configuration profile to use when processing an LVM command.
@@ -480,6 +482,10 @@ All tools return a status code of zero on success or non-zero on failure.
 Directory containing \fI.lvm_history\fP if the internal readline
 shell is invoked.
 .TP
+.B LVM_COMMAND_PROFILE
+Name of default command profile to use for LVM commands. This profile
+is overriden by direct use of \fB\-\-commandprofile\fP command line option.
+.TP
 .B LVM_SYSTEM_DIR
 Directory containing \fBlvm.conf\fP(5) and other LVM system files.
 Defaults to "#DEFAULT_SYS_DIR#".
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 6149dbc..1cdc293 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1232,17 +1232,39 @@ static const char *_copy_command_line(struct cmd_context *cmd, int argc, char **
 
 static int _prepare_profiles(struct cmd_context *cmd)
 {
+	static const char COMMAND_PROFILE_ENV_VAR_NAME[] = "LVM_COMMAND_PROFILE";
+	static const char _cmd_profile_arg_preferred_over_env_var_msg[] = "Giving "
+				"preference to command profile specified on command "
+				"line over the one specified via environment variable.";
 	static const char _failed_to_add_profile_msg[] = "Failed to add %s %s.";
 	static const char _failed_to_apply_profile_msg[] = "Failed to apply %s %s.";
 	static const char _command_profile_source_name[] = "command profile";
 	static const char _metadata_profile_source_name[] = "metadata profile";
 	static const char _setting_global_profile_msg[] = "Setting global %s \"%s\".";
 
+	const char *env_cmd_profile_name = NULL;
 	const char *name;
 	struct profile *profile;
 	config_source_t source;
 	const char *source_name;
 
+	/* Check whether default global command profile is set via env. var. */
+	if ((env_cmd_profile_name = getenv(COMMAND_PROFILE_ENV_VAR_NAME))) {
+		if (!*env_cmd_profile_name)
+			env_cmd_profile_name = NULL;
+		else
+			log_debug("Command profile '%s' requested via "
+				  "environment variable.",
+				   env_cmd_profile_name);
+	}
+
+	if (!arg_count(cmd, profile_ARG) &&
+	    !arg_count(cmd, commandprofile_ARG) &&
+	    !arg_count(cmd, metadataprofile_ARG) &&
+	    !env_cmd_profile_name)
+		/* nothing to do */
+		return 1;
+
 	if (arg_count(cmd, profile_ARG)) {
 		/*
 		 * If --profile is used with dumpconfig, it's used
@@ -1274,6 +1296,15 @@ static int _prepare_profiles(struct cmd_context *cmd)
 					  "--commandprofile allowed.");
 				return 0;
 			}
+			/*
+			 * Prefer command profile specified on command
+			 * line over the profile specified via
+			 * COMMAND_PROFILE_ENV_VAR_NAME env. var.
+			 */
+			if (env_cmd_profile_name) {
+				log_debug(_cmd_profile_arg_preferred_over_env_var_msg);
+				env_cmd_profile_name = NULL;
+			}
 			source = CONFIG_PROFILE_COMMAND;
 			source_name = _command_profile_source_name;
 		}
@@ -1301,8 +1332,18 @@ static int _prepare_profiles(struct cmd_context *cmd)
 
 	}
 
-	if (arg_count(cmd, commandprofile_ARG)) {
-		name = arg_str_value(cmd, commandprofile_ARG, NULL);
+	if (arg_count(cmd, commandprofile_ARG) || env_cmd_profile_name) {
+		if (arg_count(cmd, commandprofile_ARG)) {
+			/*
+			 * Prefer command profile specified on command
+			 * line over the profile specified via
+			 * COMMAND_PROFILE_ENV_VAR_NAME env. var.
+			 */
+			if (env_cmd_profile_name)
+				log_debug(_cmd_profile_arg_preferred_over_env_var_msg);
+			name = arg_str_value(cmd, commandprofile_ARG, NULL);
+		} else
+			name = env_cmd_profile_name;
 		source_name = _command_profile_source_name;
 
 		if (!(profile = add_profile(cmd, name, CONFIG_PROFILE_COMMAND))) {
@@ -1394,12 +1435,8 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 		}
 	}
 
-	if (arg_count(cmd, profile_ARG) ||
-	    arg_count(cmd, commandprofile_ARG) ||
-	    arg_count(cmd, metadataprofile_ARG)) {
-		if (!_prepare_profiles(cmd))
-			return_ECMD_FAILED;
-	}
+	if (!_prepare_profiles(cmd))
+		return_ECMD_FAILED;
 
 	if (arg_count(cmd, readonly_ARG))
 		cmd->metadata_read_only = 1;


