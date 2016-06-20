From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 20 Jun 2016 09:41:23 +0000 (UTC)
Subject: master - refactor: move 'interactive' field from struct command_line to struct cmd_context as 'is_interactive' switch
Message-ID: <20160620094123.EADA0606C9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c33c0545aff1d531972682c8777e5db5e8da5676
Commit:        c33c0545aff1d531972682c8777e5db5e8da5676
Parent:        0ab118774029cc955512c4a41930956ccd96a138
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri May 20 14:23:43 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jun 20 11:33:43 2016 +0200

refactor: move 'interactive' field from struct command_line to struct cmd_context as 'is_interactive' switch

---
 lib/commands/toolcontext.h |    1 +
 tools/lvm.c                |    3 ++-
 tools/lvm2cmdline.h        |    1 -
 tools/lvmcmdline.c         |    2 +-
 4 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index f4beae1..c04455c 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -113,6 +113,7 @@ struct cmd_context {
 	 * Switches.
 	 */
 	unsigned is_long_lived:1;		/* optimises persistent_filter handling */
+	unsigned is_interactive:1;
 	unsigned check_pv_dev_sizes:1;
 	unsigned handles_missing_pvs:1;
 	unsigned handles_unknown_segments:1;
diff --git a/tools/lvm.c b/tools/lvm.c
index b7cec81..18e3490 100644
--- a/tools/lvm.c
+++ b/tools/lvm.c
@@ -193,7 +193,7 @@ int lvm_shell(struct cmd_context *cmd, struct cmdline_context *cmdline)
 
 	_cmdline = cmdline;
 
-	_cmdline->interactive = 1;
+	cmd->is_interactive = 1;
 	while (1) {
 		free(input);
 		input = readline("lvm> ");
@@ -246,6 +246,7 @@ int lvm_shell(struct cmd_context *cmd, struct cmdline_context *cmdline)
 		}
 		_write_history();
 	}
+	cmd->is_interactive = 0;
 
 	free(input);
 	return 0;
diff --git a/tools/lvm2cmdline.h b/tools/lvm2cmdline.h
index 3b68af7..80bd03e 100644
--- a/tools/lvm2cmdline.h
+++ b/tools/lvm2cmdline.h
@@ -23,7 +23,6 @@ struct cmdline_context {
         struct command *commands;
         int num_commands;
         int commands_size;
-        int interactive;
 };
 
 int lvm2_main(int argc, char **argv);
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 5533cb1..870a8c3 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1739,7 +1739,7 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 			stack;
 	}
 
-	if (ret == EINVALID_CMD_LINE && !_cmdline.interactive)
+	if (ret == EINVALID_CMD_LINE && !cmd->is_interactive)
 		_short_usage(cmd->command->name);
 
 	log_debug("Completed: %s", cmd->cmd_line);


