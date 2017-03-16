From: Alasdair Kergon <agk@sourceware.org>
Date: Thu, 16 Mar 2017 18:40:06 -0400
Subject: master - tools: Avoid man-generator compilation warnings.
Message-ID: <201703162240.v2GMe6ae025958@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2d007673947b26bd0807cb637abb2fb9563c5e41
Commit:        2d007673947b26bd0807cb637abb2fb9563c5e41
Parent:        ad4158bac72418ddd044110ab3663757cea6a649
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Mar 16 22:39:04 2017 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Mar 16 22:39:04 2017 +0000

tools: Avoid man-generator compilation warnings.

Unused variables and make fns with missing prototypes static.
---
 tools/command.c |   57 +++++++++++++++++++++++++++----------------------------
 1 files changed, 28 insertions(+), 29 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index 6335d06..e14291d 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -2174,7 +2174,6 @@ static void print_val_man(struct command_name *cname, int opt_enum, int val_enum
 	}
 
 	if (strchr(str, '|')) {
-		int len = strlen(str);
 		line = dm_strdup(str);
 		split_line(line, &line_argc, line_argv, '|');
 		for (i = 0; i < line_argc; i++) {
@@ -2294,7 +2293,7 @@ static char *man_long_opt_name(const char *cmdname, int opt_enum)
 	return long_opt_name;
 }
 
-void print_man_usage(char *lvmname, struct command *cmd)
+static void _print_man_usage(char *lvmname, struct command *cmd)
 {
 	struct command_name *cname;
 	int onereq = (cmd->cmd_flags & CMD_FLAG_ONE_REQUIRED_OPT) ? 1 : 0;
@@ -2602,10 +2601,10 @@ void print_man_usage(char *lvmname, struct command *cmd)
  * then options with only long names, alphabetically
  */
 
-void print_man_usage_common_lvm(struct command *cmd)
+static void _print_man_usage_common_lvm(struct command *cmd)
 {
 	struct command_name *cname;
-	int i, sep, rp, oo, op, opt_enum;
+	int i, sep, oo, opt_enum;
 
 	if (!(cname = find_command_name(cmd->name)))
 		return;
@@ -2689,10 +2688,10 @@ void print_man_usage_common_lvm(struct command *cmd)
 	return;
 }
 
-void print_man_usage_common_cmd(struct command *cmd)
+static void _print_man_usage_common_cmd(struct command *cmd)
 {
 	struct command_name *cname;
-	int i, sep, rp, oo, op, opt_enum;
+	int i, sep, oo, opt_enum;
 
 	if (!(cname = find_command_name(cmd->name)))
 		return;
@@ -2811,7 +2810,7 @@ void print_man_usage_common_cmd(struct command *cmd)
  * "another line of text."
  */
 
-static void print_man_option_desc(struct command_name *cname, int opt_enum)
+static void _print_man_option_desc(struct command_name *cname, int opt_enum)
 {
 	const char *desc = opt_names[opt_enum].desc;
 	char buf[DESC_LINE];
@@ -2878,7 +2877,7 @@ static void print_man_option_desc(struct command_name *cname, int opt_enum)
  * Print a list of all options names for a given command name.
  */
 
-void print_man_all_options_list(struct command_name *cname)
+static void _print_man_all_options_list(struct command_name *cname)
 {
 	int opt_enum, val_enum;
 	int sep = 0;
@@ -2927,7 +2926,7 @@ void print_man_all_options_list(struct command_name *cname)
  * All options used for a given command name, along with descriptions.
  */
 
-void print_man_all_options_desc(struct command_name *cname)
+static void _print_man_all_options_desc(struct command_name *cname)
 {
 	int opt_enum, val_enum;
 	int sep = 0;
@@ -2971,7 +2970,7 @@ void print_man_all_options_desc(struct command_name *cname)
 		if (opt_names[opt_enum].desc) {
 			printf("\n");
 			printf(".br\n");
-			print_man_option_desc(cname, opt_enum);
+			_print_man_option_desc(cname, opt_enum);
 		}
 
 		printf(".ad b\n");
@@ -2980,7 +2979,7 @@ void print_man_all_options_desc(struct command_name *cname)
 	}
 }
 
-void print_man_all_positions_desc(struct command_name *cname)
+static void _print_man_all_positions_desc(struct command_name *cname)
 {
 	struct command *cmd;
 	int ci, rp, op;
@@ -3136,7 +3135,7 @@ void print_man_all_positions_desc(struct command_name *cname)
 	       "For example, LVM_VG_NAME can generally be substituted for a required VG parameter.\n");
 }
 
-void print_desc_man(const char *desc)
+static void _print_desc_man(const char *desc)
 {
 	char buf[DESC_LINE] = {0};
 	int di = 0;
@@ -3211,7 +3210,7 @@ static void include_description_file(char *name, char *des_file)
 	close(fd);
 }
 
-void print_man(char *name, char *des_file, int secondary)
+static void _print_man(char *name, char *des_file, int secondary)
 {
 	struct command_name *cname;
 	struct command *cmd, *prev_cmd = NULL;
@@ -3233,13 +3232,13 @@ void print_man(char *name, char *des_file, int secondary)
 		cmd = &commands[i];
 
 		if (prev_cmd && strcmp(prev_cmd->name, cmd->name)) {
-			print_man_usage_common_cmd(prev_cmd);
-			print_man_usage_common_lvm(prev_cmd);
+			_print_man_usage_common_cmd(prev_cmd);
+			_print_man_usage_common_lvm(prev_cmd);
 
 			printf(".SH OPTIONS\n");
-			print_man_all_options_desc(cname);
+			_print_man_all_options_desc(cname);
 			printf(".SH VARIABLES\n");
-			print_man_all_positions_desc(cname);
+			_print_man_all_positions_desc(cname);
 
 			prev_cmd = NULL;
 		}
@@ -3291,7 +3290,7 @@ void print_man(char *name, char *des_file, int secondary)
 			/* listing them all when there's only 1 or 2 is just repetative */
 			if (cname->variants > 2) {
 				printf(".P\n");
-				print_man_all_options_list(cname);
+				_print_man_all_options_list(cname);
 			}
 
 			if (des_file) {
@@ -3302,21 +3301,21 @@ void print_man(char *name, char *des_file, int secondary)
 		}
 
 		if (cmd->desc) {
-			print_desc_man(cmd->desc);
+			_print_desc_man(cmd->desc);
 			printf(".P\n");
 		}
 
-		print_man_usage(lvmname, cmd);
+		_print_man_usage(lvmname, cmd);
 
 		if (i == (COMMAND_COUNT - 1)) {
-			print_man_usage_common_cmd(cmd);
-			print_man_usage_common_lvm(cmd);
+			_print_man_usage_common_cmd(cmd);
+			_print_man_usage_common_lvm(cmd);
 
 			printf("\n");
 			printf(".SH OPTIONS\n");
-			print_man_all_options_desc(cname);
+			_print_man_all_options_desc(cname);
 			printf(".SH VARIABLES\n");
-			print_man_all_positions_desc(cname);
+			_print_man_all_positions_desc(cname);
 		} else {
 			if (cname->variants > 2)
 				printf("-\n");
@@ -3327,7 +3326,7 @@ void print_man(char *name, char *des_file, int secondary)
 	}
 }
 
-void print_man_secondary(char *name)
+static void _print_man_secondary(char *name)
 {
 	struct command *cmd;
 	char *lvmname = name;
@@ -3360,11 +3359,11 @@ void print_man_secondary(char *name)
 		}
 
 		if (cmd->desc) {
-			print_desc_man(cmd->desc);
+			_print_desc_man(cmd->desc);
 			printf(".P\n");
 		}
 
-		print_man_usage(lvmname, cmd);
+		_print_man_usage(lvmname, cmd);
 
 		printf("-\n");
 		printf("\n");
@@ -3424,9 +3423,9 @@ int main(int argc, char *argv[])
 	factor_common_options();
 
 	if (primary)
-		print_man(cmdname, desfile, secondary);
+		_print_man(cmdname, desfile, secondary);
 	else if (secondary)
-		print_man_secondary(cmdname);
+		_print_man_secondary(cmdname);
 
 	return 0;
 }


