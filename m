From: David Teigland <teigland@sourceware.org>
Date: Fri, 10 Mar 2017 11:45:26 -0500
Subject: master - commands: coverity fixes
Message-ID: <201703101645.v2AGjQDu031852@int-mx11.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=053547d770191d9ca180359d7bbfdc9f0528c036
Commit:        053547d770191d9ca180359d7bbfdc9f0528c036
Parent:        93644be44b4067c6ebc1d450589ca510129b3b60
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Mar 10 10:19:21 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Mar 10 10:40:59 2017 -0600

commands: coverity fixes

---
 tools/command.c |   38 +++++++++++++++++++-------------------
 1 files changed, 19 insertions(+), 19 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index 88b7216..aacc647 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -711,7 +711,7 @@ static void set_opt_def(struct command *cmd, char *str, struct arg_def *def)
  * oo->line = "--opt1 ...";
  */
 
-static void add_oo_definition_line(struct command *cmd, const char *name, const char *line)
+static void add_oo_definition_line(const char *name, const char *line)
 {
 	struct oo_line *oo;
 	char *colon;
@@ -724,7 +724,6 @@ static void add_oo_definition_line(struct command *cmd, const char *name, const
 		*colon = '\0';
 	else {
 		log_error("Parsing command defs: invalid OO definition");
-		cmd->cmd_flags |= CMD_FLAG_PARSE_ERROR;
 		return;
 	}
 
@@ -734,7 +733,7 @@ static void add_oo_definition_line(struct command *cmd, const char *name, const
 
 /* Support OO_FOO: continuing on multiple lines. */
 
-static void append_oo_definition_line(struct command *cmd, const char *new_line)
+static void append_oo_definition_line(const char *new_line)
 {
 	struct oo_line *oo;
 	char *old_line;
@@ -750,7 +749,6 @@ static void append_oo_definition_line(struct command *cmd, const char *new_line)
 	line = dm_malloc(len);
 	if (!line) {
 		log_error("Parsing command defs: no memory");
-		cmd->cmd_flags |= CMD_FLAG_PARSE_ERROR;
 		return;
 	}
 
@@ -1424,7 +1422,7 @@ int define_commands(char *run_name)
 		 * context of the existing command[].
 		 */
 
-		if (is_desc_line(line_argv[0]) && !skip) {
+		if (is_desc_line(line_argv[0]) && !skip && cmd) {
 			char *desc = dm_strdup(line_orig);
 			if (cmd->desc) {
 				int newlen = strlen(cmd->desc) + strlen(desc) + 2;
@@ -1432,32 +1430,33 @@ int define_commands(char *run_name)
 				if (newdesc) {
 					memset(newdesc, 0, newlen);
 					snprintf(newdesc, newlen, "%s %s", cmd->desc, desc);
-					cmd->desc = newdesc;
+					dm_free((char *)cmd->desc);
 					dm_free(desc);
+					cmd->desc = newdesc;
 				}
 			} else
 				cmd->desc = desc;
 			continue;
 		}
 
-		if (is_flags_line(line_argv[0]) && !skip) {
+		if (is_flags_line(line_argv[0]) && !skip && cmd) {
 			add_flags(cmd, line_orig);
 			continue;
 		}
 
-		if (is_rule_line(line_argv[0]) && !skip) {
+		if (is_rule_line(line_argv[0]) && !skip && cmd) {
 			add_rule(cmd, line_orig);
 			continue;
 		}
 
-		if (is_id_line(line_argv[0])) {
+		if (is_id_line(line_argv[0]) && cmd) {
 			cmd->command_id = dm_strdup(line_argv[1]);
 			continue;
 		}
 
 		/* OO_FOO: ... */
 		if (is_oo_definition(line_argv[0])) {
-			add_oo_definition_line(cmd, line_argv[0], line_orig);
+			add_oo_definition_line(line_argv[0], line_orig);
 			prev_was_oo_def = 1;
 			prev_was_oo = 0;
 			prev_was_op = 0;
@@ -1465,7 +1464,7 @@ int define_commands(char *run_name)
 		}
 
 		/* OO: ... */
-		if (is_oo_line(line_argv[0]) && !skip) {
+		if (is_oo_line(line_argv[0]) && !skip && cmd) {
 			add_optional_opt_line(cmd, line_argc, line_argv);
 			prev_was_oo_def = 0;
 			prev_was_oo = 1;
@@ -1474,7 +1473,7 @@ int define_commands(char *run_name)
 		}
 
 		/* OP: ... */
-		if (is_op_line(line_argv[0]) && !skip) {
+		if (is_op_line(line_argv[0]) && !skip && cmd) {
 			add_optional_pos_line(cmd, line_argc, line_argv);
 			prev_was_oo_def = 0;
 			prev_was_oo = 0;
@@ -1483,7 +1482,7 @@ int define_commands(char *run_name)
 		}
 
 		/* IO: ... */
-		if (is_io_line(line_argv[0]) && !skip) {
+		if (is_io_line(line_argv[0]) && !skip && cmd) {
 			add_ignore_opt_line(cmd, line_argc, line_argv);
 			prev_was_oo = 0;
 			prev_was_op = 0;
@@ -1493,19 +1492,21 @@ int define_commands(char *run_name)
 		/* handle OO_FOO:, OO:, OP: continuing on multiple lines */
 
 		if (prev_was_oo_def) {
-			append_oo_definition_line(cmd, line_orig);
+			append_oo_definition_line(line_orig);
 			continue;
 		}
 
-		if (prev_was_oo) {
+		if (prev_was_oo && cmd) {
 			add_optional_opt_line(cmd, line_argc, line_argv);
 			continue;
 		}
 
-		if (prev_was_op) {
+		if (prev_was_op && cmd) {
 			add_optional_pos_line(cmd, line_argc, line_argv);
 			continue;
 		}
+
+		log_error("Parsing command defs: can't process input line %s", line_orig);
 	}
 
 	for (i = 0; i < COMMAND_COUNT; i++) {
@@ -2158,7 +2159,7 @@ static void print_val_man(struct command_name *cname, int opt_enum, int val_enum
 			if (strstr(line_argv[i], "Number"))
 				printf("\\fI%s\\fP", line_argv[i]);
 			else
-				printf("\\%\\fB%s\\fP", line_argv[i]);
+				printf("\\fB%s\\fP", line_argv[i]);
 		}
 		return;
 	}
@@ -3426,8 +3427,7 @@ int main(int argc, char *argv[])
 
 	define_commands(NULL);
 
-	if (cmdname)
-		configure_command_option_values(cmdname);
+	configure_command_option_values(cmdname);
 
 	factor_common_options();
 


