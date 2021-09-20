From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 20 Sep 2021 13:30:06 +0000 (GMT)
Subject: main - cov: handle better leak reports
Message-ID: <20210920133006.799DA3858C60@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3e7e9cc5e6abc4ddb1777e7c7b9d7bc42a7f57a7
Commit:        3e7e9cc5e6abc4ddb1777e7c7b9d7bc42a7f57a7
Parent:        825e49a2447810a806905723bc91072eb7b8b423
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Sep 19 20:27:34 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 20 14:26:09 2021 +0200

cov: handle better leak reports

Rewrite code so the leaks are eliminated from Coverity.
---
 tools/command.c | 33 ++++++++++++++++++++++-----------
 1 file changed, 22 insertions(+), 11 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index 37f6a6153..48f572f7e 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -757,6 +757,9 @@ static void _set_opt_def(struct cmd_context *cmdtool, struct command *cmd, char
 			def->num = (uint64_t)atoi(name);
 
 		if (val_enum == conststr_VAL) {
+#ifdef MAN_PAGE_GENERATOR
+			free((void*)def->str);
+#endif
 			def->str = dm_pool_strdup(cmdtool->libmem, name);
 
 			if (!def->str) {
@@ -1539,20 +1542,27 @@ int define_commands(struct cmd_context *cmdtool, const char *run_name)
 		 */
 
 		if (_is_desc_line(line_argv[0]) && !skip && cmd) {
-			char *desc = dm_pool_strdup(cmdtool->libmem, line_orig);
-			if (cmd->desc && desc) {
-				int newlen = strlen(cmd->desc) + strlen(desc) + 2;
+			if (cmd->desc) {
+				size_t newlen = strlen(cmd->desc) + strlen(line_orig) + 2;
 				char *newdesc = dm_pool_alloc(cmdtool->libmem, newlen);
-				if (newdesc) {
-					snprintf(newdesc, newlen, "%s %s", cmd->desc, desc);
-					cmd->desc = newdesc;
-				} else {
+
+				if (!newdesc) {
 					/* FIXME */
 					stack;
 					return 0;
 				}
-			} else
-				cmd->desc = desc;
+
+				snprintf(newdesc, newlen, "%s %s", cmd->desc, line_orig);
+#ifdef MAN_PAGE_GENERATOR
+				free((void*)cmd->desc);
+#endif
+				cmd->desc = newdesc;
+			} else if (!(cmd->desc = dm_pool_strdup(cmdtool->libmem, line_orig))) {
+				/* FIXME */
+				stack;
+				return 0;
+			}
+
 			continue;
 		}
 
@@ -1572,6 +1582,9 @@ int define_commands(struct cmd_context *cmdtool, const char *run_name)
 		}
 
 		if (_is_id_line(line_argv[0]) && cmd) {
+#ifdef MAN_PAGE_GENERATOR
+			free((void*)cmd->command_id);
+#endif
 			cmd->command_id = dm_pool_strdup(cmdtool->libmem, line_argv[1]);
 
 			if (!cmd->command_id) {
@@ -3674,8 +3687,6 @@ static int _print_man(char *name, char *des_file, int secondary)
 				printf(".P\n");
 			}
 		}
-
-		continue;
 	}
 
 	return 1;


