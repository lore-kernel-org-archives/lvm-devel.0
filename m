From: David Teigland <teigland@sourceware.org>
Date: Fri, 7 Jul 2017 16:37:10 -0400
Subject: master - commands: fix handing of ENO_SUCH_CMD in script
Message-ID: <201707072037.v67KbA4A021390@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cf3a6bbbe881d9a4ba6d108304f0c07ee6cd8d1a
Commit:        cf3a6bbbe881d9a4ba6d108304f0c07ee6cd8d1a
Parent:        85f1814e9dc574c271cfdae91adfe2628ff62fa9
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon May 8 10:50:27 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jul 7 15:34:27 2017 -0500

commands: fix handing of ENO_SUCH_CMD in script

Fix the error messages when an unrecognized command is
run from a script.  We shouldn't attempt to parse options
for an unrecognized command name, which causes misleading
errors about bad options, but rather exit right when we
know the command name is not valid.  Also don't complain
about exiting without an error message when running a
script if no command didn't exist.
---
 tools/lvmcmdline.c |   16 ++++++++++------
 1 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 2e71abf..1b7940f 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -2748,7 +2748,8 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 		return_ECMD_FAILED;
 
 	/* Look up command - will be NULL if not recognised */
-	cmd->cname = find_command_name(cmd->name);
+	if (!(cmd->cname = find_command_name(cmd->name)))
+		return ENO_SUCH_CMD;
 
 	if (!_process_command_line(cmd, &argc, &argv)) {
 		log_error("Error during parsing of command line.");
@@ -2765,10 +2766,6 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 
 	log_debug("Parsing: %s", cmd->cmd_line);
 
-	/* Having validated cmdline args, return if we didn't recognised the command */
-	if (!cmd->cname)
-		return ENO_SUCH_CMD;
-
 	if (!(cmd->command = _find_command(cmd, cmd->name, &argc, argv)))
 		return EINVALID_CMD_LINE;
 
@@ -3293,7 +3290,7 @@ static int _run_script(struct cmd_context *cmd, int argc, char **argv)
 {
 	FILE *script;
 	char buffer[CMD_LEN];
-	int ret = 0;
+	int ret = ENO_SUCH_CMD;
 	int magic_number = 0;
 	char *script_file = argv[0];
 
@@ -3328,6 +3325,13 @@ static int _run_script(struct cmd_context *cmd, int argc, char **argv)
 		if (!strcmp(argv[0], "quit") || !strcmp(argv[0], "exit"))
 			break;
 		ret = lvm_run_command(cmd, argc, argv);
+		/*
+		 * FIXME: handling scripts with invalid or failing commands
+		 * could use some cleaning up, e.g. error_message_produced
+		 * check and error are repeated again in the caller.
+		 */
+		if (ret == ENO_SUCH_CMD)
+			break;
 		if (ret != ECMD_PROCESSED) {
 			if (!error_message_produced()) {
 				log_debug(INTERNAL_ERROR "Failed command did not use log_error");


