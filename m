From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 4 Feb 2020 11:23:02 -0500
Subject: master - command: validate reporting of previous argument
Message-ID: <14193.120020411225801673@us-mta-316.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e6a3c0901703bf98827e2da456daf0ced42dd96c
Commit:        e6a3c0901703bf98827e2da456daf0ced42dd96c
Parent:        4791d0f035e006e9541d27ef2c3dcb6ea561324a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jan 30 15:08:30 2020 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 4 17:22:06 2020 +0100

command: validate reporting of previous argument

When reporting parsing error, report 'previous' argument
only when there is one.
---
 tools/command.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index 0cbd877..50791b1 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -999,8 +999,8 @@ static void __add_optional_opt_line(struct cmd_context *cmdtool, struct command
 		else if (takes_arg)
 			_update_prev_opt_arg(cmdtool, cmd, argv[i], OPTIONAL);
 		else {
-			log_error("Parsing command defs: can't parse argc %d argv %s prev %s.",
-				i, argv[i], argv[i-1]);
+			log_error("Parsing command defs: can't parse argc %d argv %s%s%s.",
+				i, argv[i], (i > 0) ? " prev " : "", (i > 0) ? argv[i - 1] : "");
 			cmd->cmd_flags |= CMD_FLAG_PARSE_ERROR;
 			return;
 		}
@@ -1025,8 +1025,8 @@ static void _add_ignore_opt_line(struct cmd_context *cmdtool, struct command *cm
 		else if (takes_arg)
 			_update_prev_opt_arg(cmdtool, cmd, argv[i], IGNORE);
 		else {
-			log_error("Parsing command defs: can't parse argc %d argv %s prev %s.",
-				i, argv[i], argv[i-1]);
+			log_error("Parsing command defs: can't parse argc %d argv %s%s%s.",
+				  i, argv[i], (i > 0) ? " prev " : "", (i > 0) ? argv[i - 1] : "");
 			cmd->cmd_flags |= CMD_FLAG_PARSE_ERROR;
 			return;
 		}
@@ -1060,8 +1060,8 @@ static void _add_required_opt_line(struct cmd_context *cmdtool, struct command *
 		else if (takes_arg)
 			_update_prev_opt_arg(cmdtool, cmd, argv[i], REQUIRED);
 		else {
-			log_error("Parsing command defs: can't parse argc %d argv %s prev %s.",
-				  i, argv[i], argv[i-1]);
+			log_error("Parsing command defs: can't parse argc %d argv %s%s%s.",
+				  i, argv[i], (i > 0) ? " prev " : "", (i > 0) ? argv[i - 1] : "");
 			cmd->cmd_flags |= CMD_FLAG_PARSE_ERROR;
 			return;
 		}
@@ -1150,8 +1150,8 @@ static void _add_required_line(struct cmd_context *cmdtool, struct command *cmd,
 			/* set property for previous required_pos_arg */
 			_update_prev_pos_arg(cmd, argv[i], REQUIRED);
 		} else {
-			log_error("Parsing command defs: can't parse argc %d argv %s prev %s.",
-				  i, argv[i], argv[i-1]);
+			log_error("Parsing command defs: can't parse argc %d argv %s%s%s.",
+				  i, argv[i], (i > 0) ? " prev " : "", (i > 0) ? argv[i - 1] : "");
 			cmd->cmd_flags |= CMD_FLAG_PARSE_ERROR;
 			return;
 		}



