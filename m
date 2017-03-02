From: David Teigland <teigland@sourceware.org>
Date: Thu, 2 Mar 2017 10:48:27 -0500
Subject: master - commands: adjust syntax error message
Message-ID: <201703021548.v22FmRDf017764@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8df3f300ba9c6d68d6151ecc5e09543251d17db0
Commit:        8df3f300ba9c6d68d6151ecc5e09543251d17db0
Parent:        b76852bf35ca89f0c72bf30f1f86884ec53bc4c3
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Mar 2 09:37:54 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Mar 2 09:46:41 2017 -0600

commands: adjust syntax error message

---
 tools/command.c    |   11 ++++++++---
 tools/command.h    |    2 +-
 tools/lvmcmdline.c |    9 ++++-----
 3 files changed, 13 insertions(+), 9 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index 7c5bf7c..e0db503 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -1597,7 +1597,7 @@ static void print_usage_def(struct arg_def *def)
 		printf(" ...");
 }
 
-void print_usage(struct command *cmd, int longhelp)
+void print_usage(struct command *cmd, int longhelp, int desc_first)
 {
 	struct command_name *cname = find_command_name(cmd->name);
 	int onereq = (cmd->cmd_flags & CMD_FLAG_ONE_REQUIRED_OPT) ? 1 : 0;
@@ -1609,7 +1609,7 @@ void print_usage(struct command *cmd, int longhelp)
 	 */
 	factor_common_options();
 
-	if (cmd->desc)
+	if (desc_first && cmd->desc)
 		_print_usage_description(cmd);
 
 	printf("  %s", cmd->name);
@@ -1709,7 +1709,12 @@ void print_usage(struct command *cmd, int longhelp)
 
 	printf(" ]");
  done:
-	printf("\n\n");
+	printf("\n");
+
+	if (!desc_first && cmd->desc)
+		_print_usage_description(cmd);
+
+	printf("\n");
 	return;
 }
 
diff --git a/tools/command.h b/tools/command.h
index c5c801a..36554a3 100644
--- a/tools/command.h
+++ b/tools/command.h
@@ -213,7 +213,7 @@ struct command {
 
 int define_commands(char *run_name);
 int command_id_to_enum(const char *str);
-void print_usage(struct command *cmd, int longhelp);
+void print_usage(struct command *cmd, int longhelp, int desc_first);
 void print_usage_common_cmd(struct command_name *cname, struct command *cmd);
 void print_usage_common_lvm(struct command_name *cname, struct command *cmd);
 void factor_common_options(void);
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index e2be7c7..f5b095c 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1560,11 +1560,10 @@ static struct command *_find_command(struct cmd_context *cmd, const char *path,
 
 	if (!best_required) {
 		/* cmd did not have all the required opt/pos args of any command */
-		log_error("Failed to find a matching command definition.");
-		log_error("Run '%s --help' for more information.", name);
+		log_error("Incorrect syntax. Run '%s --help' for more information.", name);
 		if (close_ro) {
-			log_warn("Closest command usage is:");
-			print_usage(&_cmdline.commands[close_i], 0);
+			log_warn("Nearest similar command has syntax:");
+			print_usage(&_cmdline.commands[close_i], 0, 0);
 		}
 		return NULL;
 	}
@@ -1711,7 +1710,7 @@ static int _usage(const char *name, int longhelp)
 		if ((_cmdline.commands[i].cmd_flags & CMD_FLAG_SECONDARY_SYNTAX) && !longhelp)
 			continue;
 
-		print_usage(&_cmdline.commands[i], longhelp);
+		print_usage(&_cmdline.commands[i], longhelp, 1);
 		cmd = &_cmdline.commands[i];
 	}
 


