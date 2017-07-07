From: David Teigland <teigland@sourceware.org>
Date: Fri, 7 Jul 2017 16:37:01 -0400
Subject: master - commands: centralize shell vs script vs command decision
Message-ID: <201707072037.v67Kb1kG021370@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=85f1814e9dc574c271cfdae91adfe2628ff62fa9
Commit:        85f1814e9dc574c271cfdae91adfe2628ff62fa9
Parent:        c995e40b6333fb83fc1eda7be0cc4ef43f1eb88e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon May 8 10:31:30 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jul 7 15:33:44 2017 -0500

commands: centralize shell vs script vs command decision

This clarifies the point where lvm decides if it is
running an lvm shell, command or a script.
---
 tools/lvmcmdline.c |   39 ++++++++++++++++++++++++++++++---------
 1 files changed, 30 insertions(+), 9 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 964e295..2e71abf 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -3292,7 +3292,6 @@ void lvm_fin(struct cmd_context *cmd)
 static int _run_script(struct cmd_context *cmd, int argc, char **argv)
 {
 	FILE *script;
-
 	char buffer[CMD_LEN];
 	int ret = 0;
 	int magic_number = 0;
@@ -3391,7 +3390,10 @@ int lvm2_main(int argc, char **argv)
 	int ret, alias = 0;
 	struct custom_fds custom_fds;
 	struct cmd_context *cmd;
+	int run_shell = 0;
+	int run_script = 0;
 	const char *run_name;
+	const char *run_command_name = NULL;
 
 	if (!argv)
 		return -1;
@@ -3461,16 +3463,30 @@ int lvm2_main(int argc, char **argv)
 		goto_out;
 	}
 
-	/* Can be the name of a script file. */
-	if (run_name && !find_command_name(run_name))
-		run_name = NULL;
+	/*
+	 * Decide if we are running a shell or a command or a script.  When
+	 * there is no run_name, it's a shell, when run_name is a recognized
+	 * lvm command it's that command, when run_name is not a recognized
+	 * command name, try it as an lvm script.
+	 */
+	if (!run_name)
+		run_shell = 1;
+	else if (!find_command_name(run_name))
+		run_script = 1;
+	else
+		run_command_name = run_name;
 
-	if (!lvm_register_commands(cmd, run_name)) {
+	/*
+	 * NULL run_command_name means register all command defs because
+	 * a script or shell needs to access any command name, while a
+	 * single command needs to access only defs for the named command.
+	 */
+	if (!lvm_register_commands(cmd, run_command_name)) {
 		ret = ECMD_FAILED;
 		goto out;
 	}
 
-	if (!alias && !argc) {
+	if (run_shell) {
 #ifdef READLINE_SUPPORT
 		_nonroot_warning();
 		if (!_prepare_profiles(cmd)) {
@@ -3488,11 +3504,16 @@ int lvm2_main(int argc, char **argv)
 	}
 
 	_nonroot_warning();
-	ret = lvm_run_command(cmd, argc, argv);
-	if ((ret == ENO_SUCH_CMD) && (!alias))
+
+	if (run_script)
 		ret = _run_script(cmd, argc, argv);
-	if (ret == ENO_SUCH_CMD)
+	else
+		ret = lvm_run_command(cmd, argc, argv);
+
+	if (ret == ENO_SUCH_CMD) {
 		log_error("No such command.  Try 'help'.");
+		goto out;
+	}
 
 	if ((ret != ECMD_PROCESSED) && !error_message_produced()) {
 		log_debug(INTERNAL_ERROR "Failed command did not use log_error");


