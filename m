From: David Teigland <teigland@sourceware.org>
Date: Mon, 10 Jun 2019 15:39:51 -0400
Subject: master - fix command definition for pvchange -a
Message-ID: <201906101939.x5AJdpV3006180@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e225bf59ffdad0de1bb976ffdb65d77979cb5381
Commit:        e225bf59ffdad0de1bb976ffdb65d77979cb5381
Parent:        b7850faba72a50e49783a3b01e6833fc1a99873b
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Jun 10 11:35:26 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Jun 10 13:43:20 2019 -0500

fix command definition for pvchange -a

The -a was being included in the set of "one or more"
options instead of an actual required option.  Even
though the cmd def was not implementing the restrictions
correctly, the command internally was.

Adjust the cmd def code which did not support a command
with some real required options and a set of "one or more"
options.
---
 tools/command-lines.in |    2 +-
 tools/command.c        |   93 ++++++++++++++++++++++++++++++++++++++---------
 tools/command.h        |   12 ++++++-
 tools/lvchange.c       |    4 +-
 tools/lvmcmdline.c     |   30 ++++++++--------
 5 files changed, 104 insertions(+), 37 deletions(-)

diff --git a/tools/command-lines.in b/tools/command-lines.in
index 4601239..c9d4fd6 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -1404,7 +1404,7 @@ OO_PVCHANGE: --autobackup Bool, --force, --reportformat ReportFmt, --uuid
 OO_PVCHANGE_META: --allocatable Bool, --addtag Tag, --deltag Tag,
 --uuid, --metadataignore Bool
 
-pvchange OO_PVCHANGE_META --all
+pvchange --all OO_PVCHANGE_META
 OO: OO_PVCHANGE
 IO: --ignoreskippedcluster
 ID: pvchange_properties_all
diff --git a/tools/command.c b/tools/command.c
index bf2879f..246d181 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -1070,7 +1070,7 @@ static void _add_required_opt_line(struct cmd_context *cmdtool, struct command *
  * (This is the special case of vgchange/lvchange where one
  * optional option is required, and others are then optional.)
  * The set of options from OO_FOO are saved in required_opt_args,
- * and flag CMD_FLAG_ONE_REQUIRED_OPT is set on the cmd indicating
+ * and flag CMD_FLAG_ANY_REQUIRED_OPT is set on the cmd indicating
  * this special case.
  */
  
@@ -1104,6 +1104,7 @@ static void _add_required_line(struct cmd_context *cmdtool, struct command *cmd,
 	int i;
 	int takes_arg;
 	int prev_was_opt = 0, prev_was_pos = 0;
+	int orig_ro_count = 0;
 
 	/* argv[0] is command name */
 
@@ -1128,10 +1129,20 @@ static void _add_required_line(struct cmd_context *cmdtool, struct command *cmd,
 			prev_was_pos = 1;
 
 		} else if (!strncmp(argv[i], "OO_", 3)) {
-			/* one required_opt_arg is required, special case lv/vgchange */
-			cmd->cmd_flags |= CMD_FLAG_ONE_REQUIRED_OPT;
+			/*
+			 * the first ro_count entries in required_opt_arg required,
+			 * after which one or more of the next any_ro_count entries
+			 * in required_opt_arg are required.  required_opt_arg
+			 * has a total of ro_count+any_ro_count entries.
+			 */
+			cmd->cmd_flags |= CMD_FLAG_ANY_REQUIRED_OPT;
+			orig_ro_count = cmd->ro_count;
+
 			_include_required_opt_args(cmdtool, cmd, argv[i]);
 
+			cmd->any_ro_count = cmd->ro_count - orig_ro_count;
+			cmd->ro_count = orig_ro_count;
+
 		} else if (prev_was_pos) {
 			/* set property for previous required_pos_arg */
 			_update_prev_pos_arg(cmd, argv[i], REQUIRED);
@@ -1773,7 +1784,7 @@ static void _print_usage_def(struct command *cmd, int opt_enum, struct arg_def *
 void print_usage(struct command *cmd, int longhelp, int desc_first)
 {
 	struct command_name *cname = _find_command_name(cmd->name);
-	int onereq = (cmd->cmd_flags & CMD_FLAG_ONE_REQUIRED_OPT) ? 1 : 0;
+	int any_req = (cmd->cmd_flags & CMD_FLAG_ANY_REQUIRED_OPT) ? 1 : 0;
 	int include_extents = 0;
 	int ro, rp, oo, op, opt_enum, first;
 
@@ -1788,20 +1799,31 @@ void print_usage(struct command *cmd, int longhelp, int desc_first)
 
 	printf("  %s", cmd->name);
 
-	if (onereq && cmd->ro_count) {
+	if (any_req) {
+		for (ro = 0; ro < cmd->ro_count; ro++) {
+			opt_enum = cmd->required_opt_args[ro].opt;
+
+			if (opt_names[opt_enum].short_opt)
+				printf(" -%c|%s", opt_names[opt_enum].short_opt, opt_names[opt_enum].long_opt);
+			else
+				printf(" %s", opt_names[opt_enum].long_opt);
+
+			if (cmd->required_opt_args[ro].def.val_bits) {
+				printf(" ");
+				_print_usage_def(cmd, opt_enum, &cmd->required_opt_args[ro].def);
+			}
+		}
+
 		/* one required option in a set */
 		first = 1;
 
 		/* options with short and long */
-		for (ro = 0; ro < cmd->ro_count; ro++) {
+		for (ro = cmd->ro_count; ro < cmd->ro_count + cmd->any_ro_count; ro++) {
 			opt_enum = cmd->required_opt_args[ro].opt;
 
 			if (!opt_names[opt_enum].short_opt)
 				continue;
 
-			if ((opt_enum == size_ARG) && command_has_alternate_extents(cmd->name))
-				include_extents = 1;
-
 			if (first)
 				printf("\n\t(");
 			else
@@ -1817,7 +1839,7 @@ void print_usage(struct command *cmd, int longhelp, int desc_first)
 		}
 
 		/* options with only long */
-		for (ro = 0; ro < cmd->ro_count; ro++) {
+		for (ro = cmd->ro_count; ro < cmd->ro_count + cmd->any_ro_count; ro++) {
 			opt_enum = cmd->required_opt_args[ro].opt;
 
 			if (opt_names[opt_enum].short_opt)
@@ -1843,7 +1865,7 @@ void print_usage(struct command *cmd, int longhelp, int desc_first)
 		printf(" )\n");
 	}
 
-	if (!onereq && cmd->ro_count) {
+	if (!any_req && cmd->ro_count) {
 		for (ro = 0; ro < cmd->ro_count; ro++) {
 			opt_enum = cmd->required_opt_args[ro].opt;
 
@@ -1863,7 +1885,7 @@ void print_usage(struct command *cmd, int longhelp, int desc_first)
 	}
 
 	if (cmd->rp_count) {
-		if (onereq)
+		if (any_req)
 			printf("\t");
 		for (rp = 0; rp < cmd->rp_count; rp++) {
 			if (cmd->required_pos_args[rp].def.val_bits) {
@@ -2403,7 +2425,7 @@ static const char *_man_long_opt_name(const char *cmdname, int opt_enum)
 static void _print_man_usage(char *lvmname, struct command *cmd)
 {
 	struct command_name *cname;
-	int onereq = (cmd->cmd_flags & CMD_FLAG_ONE_REQUIRED_OPT) ? 1 : 0;
+	int any_req = (cmd->cmd_flags & CMD_FLAG_ANY_REQUIRED_OPT) ? 1 : 0;
 	int sep, ro, rp, oo, op, opt_enum;
 	int need_ro_indent_end = 0;
 	int include_extents = 0;
@@ -2413,10 +2435,45 @@ static void _print_man_usage(char *lvmname, struct command *cmd)
 
 	printf("\\fB%s\\fP", lvmname);
 
-	if (!onereq)
+	if (!any_req)
 		goto ro_normal;
 
 	/*
+	 * required options that follow command name, all required
+	 */
+	if (cmd->ro_count) {
+		sep = 0;
+
+		for (ro = 0; ro < cmd->ro_count; ro++) {
+
+			/* avoid long line wrapping */
+			if ((cmd->ro_count > 2) && (sep == 2)) {
+				printf("\n.RS 5\n");
+				need_ro_indent_end = 1;
+			}
+
+			opt_enum = cmd->required_opt_args[ro].opt;
+
+			if ((opt_enum == size_ARG) && command_has_alternate_extents(cmd->name))
+				include_extents = 1;
+
+			if (opt_names[opt_enum].short_opt) {
+				printf(" \\fB-%c\\fP|\\fB%s\\fP",
+				       opt_names[opt_enum].short_opt,
+				       _man_long_opt_name(cmd->name, opt_enum));
+			} else
+				printf(" \\fB%s\\fP", opt_names[cmd->required_opt_args[ro].opt].long_opt);
+
+			if (cmd->required_opt_args[ro].def.val_bits) {
+				printf(" ");
+				_print_def_man(cname, opt_enum, &cmd->required_opt_args[ro].def, 1);
+			}
+
+			sep++;
+		}
+	}
+
+	/*
 	 * one required option in a set, print as:
 	 * ( -a|--a,
 	 *   -b|--b,
@@ -2427,7 +2484,7 @@ static void _print_man_usage(char *lvmname, struct command *cmd)
 	 * and the second loop prints those without short opts.
 	 */
 
-	if (cmd->ro_count) {
+	if (cmd->any_ro_count) {
 		printf("\n");
 		printf(".RS 4\n");
 		printf("(");
@@ -2435,7 +2492,7 @@ static void _print_man_usage(char *lvmname, struct command *cmd)
 		sep = 0;
 
 		/* print required options with a short opt */
-		for (ro = 0; ro < cmd->ro_count; ro++) {
+		for (ro = cmd->ro_count; ro < cmd->ro_count + cmd->any_ro_count; ro++) {
 			opt_enum = cmd->required_opt_args[ro].opt;
 
 			if (!opt_names[opt_enum].short_opt)
@@ -2467,7 +2524,7 @@ static void _print_man_usage(char *lvmname, struct command *cmd)
 		}
 
 		/* print required options without a short opt */
-		for (ro = 0; ro < cmd->ro_count; ro++) {
+		for (ro = cmd->ro_count; ro < cmd->ro_count + cmd->any_ro_count; ro++) {
 			opt_enum = cmd->required_opt_args[ro].opt;
 
 			if (opt_names[opt_enum].short_opt)
@@ -2497,7 +2554,7 @@ static void _print_man_usage(char *lvmname, struct command *cmd)
 		printf(".RE\n");
 	}
 
-	/* print required position args on a new line after the onereq set */
+	/* print required position args on a new line after the any_req set */
 	if (cmd->rp_count) {
 		printf(".RS 4\n");
 		for (rp = 0; rp < cmd->rp_count; rp++) {
diff --git a/tools/command.h b/tools/command.h
index c2e3e6a..dae3d05 100644
--- a/tools/command.h
+++ b/tools/command.h
@@ -164,8 +164,16 @@ struct cmd_rule {
 /*
  * one or more from required_opt_args is required,
  * then the rest are optional.
+ *
+ * CMD_FLAG_ANY_REQUIRED_OPT: for lvchange/vgchange special case.
+ * The first ro_count entries of required_opt_args must be met
+ * (ro_count may be 0.)  After this, one or more options must be
+ * set from the remaining required_opt_args.  So, the first
+ * ro_count options in required_opt_args must match, and after
+ * that one or more of the remaining options in required_opt_args
+ * must match.
  */
-#define CMD_FLAG_ONE_REQUIRED_OPT   1  /* lvchange/vgchage require one item from required_opt_args */
+#define CMD_FLAG_ANY_REQUIRED_OPT   1
 #define CMD_FLAG_SECONDARY_SYNTAX   2  /* allows syntax variants to be suppressed in certain output */
 #define CMD_FLAG_PREVIOUS_SYNTAX    4  /* allows syntax variants to not be advertised in output */
 #define CMD_FLAG_PARSE_ERROR        8  /* error parsing command-lines.in def */
@@ -202,6 +210,8 @@ struct command {
 
 	struct cmd_rule rules[CMD_MAX_RULES];
 
+	int any_ro_count;
+
 	int ro_count;
 	int oo_count;
 	int rp_count;
diff --git a/tools/lvchange.c b/tools/lvchange.c
index ad5abdd..7bdf997 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -1084,7 +1084,7 @@ static int _lvchange_properties_single(struct cmd_context *cmd,
 	 */
 
 	/* First group of options which allow for one metadata commit/update for the whole group */
-	for (i = 0; i < cmd->command->ro_count; i++) {
+	for (i = 0; i < cmd->command->ro_count + cmd->command->any_ro_count; i++) {
 		opt_enum = cmd->command->required_opt_args[i].opt;
 
 		if (!arg_is_set(cmd, opt_enum))
@@ -1206,7 +1206,7 @@ static int _lvchange_properties_single(struct cmd_context *cmd,
 		return_ECMD_FAILED;
 
 	/* Second group of options which need per option metadata commit+reload(s) */
-	for (i = 0; i < cmd->command->ro_count; i++) {
+	for (i = 0; i < cmd->command->ro_count + cmd->command->any_ro_count; i++) {
 		opt_enum = cmd->command->required_opt_args[i].opt;
 
 		if (!arg_is_set(cmd, opt_enum))
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 94e527c..922c52d 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1192,7 +1192,7 @@ static void _set_valid_args_for_command_name(int ci)
 		if (strcmp(commands[i].name, command_names[ci].name))
 			continue;
 
-		for (ro = 0; ro < commands[i].ro_count; ro++) {
+		for (ro = 0; ro < (commands[i].ro_count + commands[i].any_ro_count); ro++) {
 			opt_enum = commands[i].required_opt_args[ro].opt;
 			all_args[opt_enum] = 1;
 
@@ -1533,7 +1533,7 @@ static int _command_required_pos_matches(struct cmd_context *cmd, int ci, int rp
  * For each command[i], check how many required opt/pos args cmd matches.
  * Save the command[i] that matches the most.
  *
- * commands[i].cmd_flags & CMD_FLAG_ONE_REQUIRED_OPT means
+ * commands[i].cmd_flags & CMD_FLAG_ANY_REQUIRED_OPT means
  * any one item from commands[i].required_opt_args needs to be
  * set to match.
  *
@@ -1551,7 +1551,7 @@ static struct command *_find_command(struct cmd_context *cmd, const char *path,
 	const char *name;
 	char opts_msg[MAX_OPTS_MSG];
 	char check_opts_msg[MAX_OPTS_MSG];
-	int match_required, match_ro, match_rp, match_type, match_unused, mismatch_required;
+	int match_required, match_ro, match_rp, match_any_ro, match_type, match_unused, mismatch_required;
 	int best_i = 0, best_required = 0, best_type = 0, best_unused = 0;
 	int close_i = 0, close_ro = 0, close_type = 0;
 	int only_i = 0;
@@ -1600,6 +1600,7 @@ static struct command *_find_command(struct cmd_context *cmd, const char *path,
 		match_required = 0;	/* required parameters that match */
 		match_ro = 0;		/* required opt_args that match */
 		match_rp = 0;		/* required pos_args that match */
+		match_any_ro = 0;
 		match_type = 0;		/* type arg matches */
 		match_unused = 0;	/* options set that are not accepted by command */
 		mismatch_required = 0;	/* required parameters that do not match */
@@ -1628,20 +1629,19 @@ static struct command *_find_command(struct cmd_context *cmd, const char *path,
 			}
 		}
 
-		/*
-		 * Special case where missing required_opt_arg's does not matter
-		 * if one required_opt_arg did match.
-		 */
-		if (commands[i].cmd_flags & CMD_FLAG_ONE_REQUIRED_OPT) {
-			if (match_ro) {
-				/* one or more of the required_opt_args is used */
-				mismatch_required = 0;
-			} else {
-				/* not even one of the required_opt_args is used */
-				mismatch_required = 1;
+		for (ro = commands[i].ro_count; ro < commands[i].ro_count + commands[i].any_ro_count; ro++) {
+			if (_command_required_opt_matches(cmd, i, ro)) {
+				/* log_warn("match %d any ro opt %d", i, commands[i].required_opt_args[ro].opt); */
+				match_any_ro++;
 			}
 		}
 
+		if ((commands[i].cmd_flags & CMD_FLAG_ANY_REQUIRED_OPT) && !match_any_ro) {
+			/* not even one of the any ro is used */
+			/* log_warn("match %d not one from any", i); */
+			mismatch_required = 1;
+		}
+
 		/* match required_pos_args */
 
 		for (rp = 0; rp < commands[i].rp_count; rp++) {
@@ -1697,7 +1697,7 @@ static struct command *_find_command(struct cmd_context *cmd, const char *path,
 			accepted = 0;
 
 			/* NB in some cases required_opt_args are optional */
-			for (j = 0; j < commands[i].ro_count; j++) {
+			for (j = 0; j < commands[i].ro_count + commands[i].any_ro_count; j++) {
 				if (commands[i].required_opt_args[j].opt == opt_enum) {
 					accepted = 1;
 					break;


