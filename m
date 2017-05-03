From: David Teigland <teigland@sourceware.org>
Date: Wed, 3 May 2017 15:47:41 -0400
Subject: master - commands: check for memory failures
Message-ID: <201705031947.v43JlfTl027114@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f7edadf87087ab4357837f09bc9356dff24306f0
Commit:        f7edadf87087ab4357837f09bc9356dff24306f0
Parent:        cb573d1ec987f74cb28ccc5089be4214ed7de317
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed May 3 14:46:07 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed May 3 14:46:43 2017 -0500

commands: check for memory failures

just return for now
---
 tools/command.c |   27 ++++++++++++++++++++++++++-
 1 files changed, 26 insertions(+), 1 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index 0f69bbb..a08d068 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -40,6 +40,8 @@
  */
 #ifdef MAN_PAGE_GENERATOR
 
+#define stack
+
 struct cmd_context {
 	void *libmem;
 };
@@ -699,9 +701,16 @@ static void set_opt_def(struct cmd_context *cmdtool, struct command *cmd, char *
 		if (val_enum == constnum_VAL)
 			def->num = (uint64_t)atoi(name);
 
-		if (val_enum == conststr_VAL)
+		if (val_enum == conststr_VAL) {
 			def->str = dm_pool_strdup(cmdtool->libmem, name);
 
+			if (!def->str) {
+				/* FIXME */
+				stack;
+				return;
+			}
+		}
+
 		if (val_enum == lv_VAL) {
 			if (strchr(name, '_'))
 				def->lvt_bits = lv_to_bits(cmd, name);
@@ -1416,6 +1425,12 @@ int define_commands(struct cmd_context *cmdtool, const char *run_name)
 			cmd_count++;
 			cmd->name = dm_pool_strdup(cmdtool->libmem, name);
 
+			if (!cmd->name) {
+				/* FIXME */
+				stack;
+				return 0;
+			}
+
 			if (run_name && strcmp(run_name, name)) {
 				skip = 1;
 				prev_was_oo_def = 0;
@@ -1447,6 +1462,10 @@ int define_commands(struct cmd_context *cmdtool, const char *run_name)
 					memset(newdesc, 0, newlen);
 					snprintf(newdesc, newlen, "%s %s", cmd->desc, desc);
 					cmd->desc = newdesc;
+				} else {
+					/* FIXME */
+					stack;
+					return 0;
 				}
 			} else
 				cmd->desc = desc;
@@ -1465,6 +1484,12 @@ int define_commands(struct cmd_context *cmdtool, const char *run_name)
 
 		if (is_id_line(line_argv[0]) && cmd) {
 			cmd->command_id = dm_pool_strdup(cmdtool->libmem, line_argv[1]);
+
+			if (!cmd->command_id) {
+				/* FIXME */
+				stack;
+				return 0;
+			}
 			continue;
 		}
 


