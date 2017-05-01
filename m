From: David Teigland <teigland@sourceware.org>
Date: Mon, 1 May 2017 16:29:51 -0400
Subject: master - commands: fix memory debug for cmd defs
Message-ID: <201705012029.v41KTpwY023894@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=15eaf703fcfc548ff687a07002f35b06f9fd8c7d
Commit:        15eaf703fcfc548ff687a07002f35b06f9fd8c7d
Parent:        54726a4950756b8f0c3e19c4c7d5feb6fb838e00
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Apr 28 16:27:19 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon May 1 15:27:14 2017 -0500

commands: fix memory debug for cmd defs

Clean up the handling of memory used for cmd defs
so it doesn't trip up memory debugging.

Allocate memory for commands[] from libmem.

Free temporary memory used by define_commands()
at the end of the function.

Clear all the command def state in in lvm_fin().
---
 tools/command.c     |   97 +++++++++++++++++++++++++++++++--------------------
 tools/command.h     |    2 +-
 tools/lvm2cmdline.h |    2 +-
 tools/lvmcmdlib.c   |    2 +-
 tools/lvmcmdline.c  |   17 +++++++--
 5 files changed, 76 insertions(+), 44 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index 816901b..347475b 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -40,14 +40,18 @@
  */
 #ifdef MAN_PAGE_GENERATOR
 
+struct cmd_context {
+	void *libmem;
+};
+
 #define log_error(fmt, args...) \
 do { \
 	printf(fmt "\n", ##args); \
 } while (0)
 
 #define dm_malloc malloc
-#define dm_free free
 #define dm_strdup strdup
+#define dm_free free
 #define dm_snprintf snprintf
 
 static int dm_strncpy(char *dest, const char *src, size_t n)
@@ -61,6 +65,16 @@ static int dm_strncpy(char *dest, const char *src, size_t n)
 	return 0;
 }
 
+static char *dm_pool_strdup(void *p, const char *str)
+{
+	return strdup(str);
+}
+
+static void *dm_pool_alloc(void *p, size_t size)
+{
+	return malloc(size);
+}
+
 /* needed to include args.h */
 #define ARG_COUNTABLE 0x00000001
 #define ARG_GROUPABLE 0x00000002
@@ -281,7 +295,7 @@ static struct oo_line oo_lines[MAX_OO_LINES];
  */
 #include "command-lines-input.h"
 
-static void add_optional_opt_line(struct command *cmd, int argc, char *argv[]);
+static void add_optional_opt_line(struct cmd_context *cmdtool, struct command *cmd, int argc, char *argv[]);
 
 /*
  * modifies buf, replacing the sep characters with \0
@@ -648,7 +662,7 @@ static void set_pos_def(struct command *cmd, char *str, struct arg_def *def)
  * Parse str for anything that can follow --option.
  */
 
-static void set_opt_def(struct command *cmd, char *str, struct arg_def *def)
+static void set_opt_def(struct cmd_context *cmdtool, struct command *cmd, char *str, struct arg_def *def)
 {
 	char *argv[MAX_LINE_ARGC];
 	int argc;
@@ -686,7 +700,7 @@ static void set_opt_def(struct command *cmd, char *str, struct arg_def *def)
 			def->num = (uint64_t)atoi(name);
 
 		if (val_enum == conststr_VAL)
-			def->str = dm_strdup(name);
+			def->str = dm_pool_strdup(cmdtool->libmem, name);
 
 		if (val_enum == lv_VAL) {
 			if (strchr(name, '_'))
@@ -789,7 +803,7 @@ static char *get_oo_line(const char *str)
  * i.e. include common options from an OO_FOO definition.
  */
 
-static void include_optional_opt_args(struct command *cmd, const char *str)
+static void include_optional_opt_args(struct cmd_context *cmdtool, struct command *cmd, const char *str)
 {
 	char *oo_line;
 	char *line;
@@ -808,7 +822,7 @@ static void include_optional_opt_args(struct command *cmd, const char *str)
 	}
 
 	split_line(line, &line_argc, line_argv, ' ');
-	add_optional_opt_line(cmd, line_argc, line_argv);
+	add_optional_opt_line(cmdtool, cmd, line_argc, line_argv);
 	dm_free(line);
 }
 
@@ -873,7 +887,7 @@ skip:
  * for the value that appears after --option.
  */
 
-static void update_prev_opt_arg(struct command *cmd, char *str, int required)
+static void update_prev_opt_arg(struct cmd_context *cmdtool, struct command *cmd, char *str, int required)
 {
 	struct arg_def def = { 0 };
 	char *comma;
@@ -890,7 +904,7 @@ static void update_prev_opt_arg(struct command *cmd, char *str, int required)
 	if ((comma = strchr(str, ',')))
 		*comma = '\0';
 
-	set_opt_def(cmd, str, &def);
+	set_opt_def(cmdtool, cmd, str, &def);
 
 	if (required > 0)
 		cmd->required_opt_args[cmd->ro_count-1].def = def;
@@ -948,7 +962,7 @@ static void update_prev_pos_arg(struct command *cmd, char *str, int required)
 
 /* Process what follows OO:, which are the optional opt args for the cmd def. */
 
-static void add_optional_opt_line(struct command *cmd, int argc, char *argv[])
+static void add_optional_opt_line(struct cmd_context *cmdtool, struct command *cmd, int argc, char *argv[])
 {
 	int takes_arg = 0;
 	int already;
@@ -963,9 +977,9 @@ static void add_optional_opt_line(struct command *cmd, int argc, char *argv[])
 		if (is_opt_name(argv[i]))
 			add_opt_arg(cmd, argv[i], &takes_arg, &already, OPTIONAL);
 		else if (!strncmp(argv[i], "OO_", 3))
-			include_optional_opt_args(cmd, argv[i]);
+			include_optional_opt_args(cmdtool, cmd, argv[i]);
 		else if (takes_arg)
-			update_prev_opt_arg(cmd, argv[i], OPTIONAL);
+			update_prev_opt_arg(cmdtool, cmd, argv[i], OPTIONAL);
 		else {
 			log_error("Parsing command defs: can't parse argc %d argv %s prev %s.",
 				i, argv[i], argv[i-1]);
@@ -980,7 +994,7 @@ static void add_optional_opt_line(struct command *cmd, int argc, char *argv[])
 
 /* Process what follows IO:, which are the ignore options for the cmd def. */
 
-static void add_ignore_opt_line(struct command *cmd, int argc, char *argv[])
+static void add_ignore_opt_line(struct cmd_context *cmdtool, struct command *cmd, int argc, char *argv[])
 {
 	int takes_arg = 0;
 	int i;
@@ -991,7 +1005,7 @@ static void add_ignore_opt_line(struct command *cmd, int argc, char *argv[])
 		if (is_opt_name(argv[i]))
 			add_opt_arg(cmd, argv[i], &takes_arg, NULL, IGNORE);
 		else if (takes_arg)
-			update_prev_opt_arg(cmd, argv[i], IGNORE);
+			update_prev_opt_arg(cmdtool, cmd, argv[i], IGNORE);
 		else {
 			log_error("Parsing command defs: can't parse argc %d argv %s prev %s.",
 				i, argv[i], argv[i-1]);
@@ -1017,7 +1031,7 @@ static void add_optional_pos_line(struct command *cmd, int argc, char *argv[])
 	}
 }
 
-static void add_required_opt_line(struct command *cmd, int argc, char *argv[])
+static void add_required_opt_line(struct cmd_context *cmdtool, struct command *cmd, int argc, char *argv[])
 {
 	int takes_arg = 0;
 	int i;
@@ -1026,7 +1040,7 @@ static void add_required_opt_line(struct command *cmd, int argc, char *argv[])
 		if (is_opt_name(argv[i]))
 			add_opt_arg(cmd, argv[i], &takes_arg, NULL, REQUIRED);
 		else if (takes_arg)
-			update_prev_opt_arg(cmd, argv[i], REQUIRED);
+			update_prev_opt_arg(cmdtool, cmd, argv[i], REQUIRED);
 		else {
 			log_error("Parsing command defs: can't parse argc %d argv %s prev %s.",
 				  i, argv[i], argv[i-1]);
@@ -1045,7 +1059,7 @@ static void add_required_opt_line(struct command *cmd, int argc, char *argv[])
  * this special case.
  */
  
-static void include_required_opt_args(struct command *cmd, char *str)
+static void include_required_opt_args(struct cmd_context *cmdtool, struct command *cmd, char *str)
 {
 	char *oo_line;
 	char *line;
@@ -1064,13 +1078,13 @@ static void include_required_opt_args(struct command *cmd, char *str)
 	}
 
 	split_line(line, &line_argc, line_argv, ' ');
-	add_required_opt_line(cmd, line_argc, line_argv);
+	add_required_opt_line(cmdtool, cmd, line_argc, line_argv);
 	dm_free(line);
 }
 
 /* Process what follows command_name, which are required opt/pos args. */
 
-static void add_required_line(struct command *cmd, int argc, char *argv[])
+static void add_required_line(struct cmd_context *cmdtool, struct command *cmd, int argc, char *argv[])
 {
 	int i;
 	int takes_arg;
@@ -1088,7 +1102,7 @@ static void add_required_line(struct command *cmd, int argc, char *argv[])
 
 		} else if (prev_was_opt && takes_arg) {
 			/* set value for previous required_opt_arg */
-			update_prev_opt_arg(cmd, argv[i], REQUIRED);
+			update_prev_opt_arg(cmdtool, cmd, argv[i], REQUIRED);
 			prev_was_opt = 0;
 			prev_was_pos = 0;
 
@@ -1101,7 +1115,7 @@ static void add_required_line(struct command *cmd, int argc, char *argv[])
 		} else if (!strncmp(argv[i], "OO_", 3)) {
 			/* one required_opt_arg is required, special case lv/vgchange */
 			cmd->cmd_flags |= CMD_FLAG_ONE_REQUIRED_OPT;
-			include_required_opt_args(cmd, argv[i]);
+			include_required_opt_args(cmdtool, cmd, argv[i]);
 
 		} else if (prev_was_pos) {
 			/* set property for previous required_pos_arg */
@@ -1125,7 +1139,7 @@ static void add_flags(struct command *cmd, char *line)
 
 #define MAX_RULE_OPTS 64
 
-static void add_rule(struct command *cmd, char *line)
+static void add_rule(struct cmd_context *cmdtool, struct command *cmd, char *line)
 {
 	struct cmd_rule *rule;
 	char *line_argv[MAX_LINE_ARGC];
@@ -1164,7 +1178,7 @@ static void add_rule(struct command *cmd, char *line)
 
 		else if (!strncmp(arg, "--", 2)) {
 			if (!rule->opts) {
-				if (!(rule->opts = dm_malloc(MAX_RULE_OPTS * sizeof(int)))) {
+				if (!(rule->opts = dm_pool_alloc(cmdtool->libmem, MAX_RULE_OPTS * sizeof(int)))) {
 					log_error("Parsing command defs: no mem.");
 					cmd->cmd_flags |= CMD_FLAG_PARSE_ERROR;
 					return;
@@ -1173,7 +1187,7 @@ static void add_rule(struct command *cmd, char *line)
 			}
 
 			if (!rule->check_opts) {
-				if (!(rule->check_opts = dm_malloc(MAX_RULE_OPTS * sizeof(int)))) {
+				if (!(rule->check_opts = dm_pool_alloc(cmdtool->libmem, MAX_RULE_OPTS * sizeof(int)))) {
 					log_error("Parsing command defs: no mem.");
 					cmd->cmd_flags |= CMD_FLAG_PARSE_ERROR;
 					return;
@@ -1348,7 +1362,7 @@ static int copy_line(char *line, int max_line, int *position)
 	return 1;
 }
 
-int define_commands(const char *run_name)
+int define_commands(struct cmd_context *cmdtool, const char *run_name)
 {
 	struct command *cmd = NULL;
 	char line[MAX_LINE];
@@ -1400,7 +1414,7 @@ int define_commands(const char *run_name)
 			cmd = &commands[cmd_count];
 			cmd->command_index = cmd_count;
 			cmd_count++;
-			cmd->name = dm_strdup(name);
+			cmd->name = dm_pool_strdup(cmdtool->libmem, name);
 
 			if (run_name && strcmp(run_name, name)) {
 				skip = 1;
@@ -1412,10 +1426,10 @@ int define_commands(const char *run_name)
 			skip = 0;
 
 			cmd->pos_count = 1;
-			add_required_line(cmd, line_argc, line_argv);
+			add_required_line(cmdtool, cmd, line_argc, line_argv);
 
 			/* Every cmd gets the OO_ALL options */
-			include_optional_opt_args(cmd, "OO_ALL:");
+			include_optional_opt_args(cmdtool, cmd, "OO_ALL:");
 			continue;
 		}
 
@@ -1425,15 +1439,13 @@ int define_commands(const char *run_name)
 		 */
 
 		if (is_desc_line(line_argv[0]) && !skip && cmd) {
-			char *desc = dm_strdup(line_orig);
+			char *desc = dm_pool_strdup(cmdtool->libmem, line_orig);
 			if (cmd->desc) {
 				int newlen = strlen(cmd->desc) + strlen(desc) + 2;
-				char *newdesc = dm_malloc(newlen);
+				char *newdesc = dm_pool_alloc(cmdtool->libmem, newlen);
 				if (newdesc) {
 					memset(newdesc, 0, newlen);
 					snprintf(newdesc, newlen, "%s %s", cmd->desc, desc);
-					dm_free((char *)cmd->desc);
-					dm_free(desc);
 					cmd->desc = newdesc;
 				}
 			} else
@@ -1447,12 +1459,12 @@ int define_commands(const char *run_name)
 		}
 
 		if (is_rule_line(line_argv[0]) && !skip && cmd) {
-			add_rule(cmd, line_orig);
+			add_rule(cmdtool, cmd, line_orig);
 			continue;
 		}
 
 		if (is_id_line(line_argv[0]) && cmd) {
-			cmd->command_id = dm_strdup(line_argv[1]);
+			cmd->command_id = dm_pool_strdup(cmdtool->libmem, line_argv[1]);
 			continue;
 		}
 
@@ -1467,7 +1479,7 @@ int define_commands(const char *run_name)
 
 		/* OO: ... */
 		if (is_oo_line(line_argv[0]) && !skip && cmd) {
-			add_optional_opt_line(cmd, line_argc, line_argv);
+			add_optional_opt_line(cmdtool, cmd, line_argc, line_argv);
 			prev_was_oo_def = 0;
 			prev_was_oo = 1;
 			prev_was_op = 0;
@@ -1485,7 +1497,7 @@ int define_commands(const char *run_name)
 
 		/* IO: ... */
 		if (is_io_line(line_argv[0]) && !skip && cmd) {
-			add_ignore_opt_line(cmd, line_argc, line_argv);
+			add_ignore_opt_line(cmdtool, cmd, line_argc, line_argv);
 			prev_was_oo = 0;
 			prev_was_op = 0;
 			continue;
@@ -1499,7 +1511,7 @@ int define_commands(const char *run_name)
 		}
 
 		if (prev_was_oo && cmd) {
-			add_optional_opt_line(cmd, line_argc, line_argv);
+			add_optional_opt_line(cmdtool, cmd, line_argc, line_argv);
 			continue;
 		}
 
@@ -1517,7 +1529,15 @@ int define_commands(const char *run_name)
 			return 0;
 	}
 
-	include_optional_opt_args(&lvm_all, "OO_ALL");
+	include_optional_opt_args(cmdtool, &lvm_all, "OO_ALL");
+
+	for (i = 0; i < oo_line_count; i++) {
+		struct oo_line *oo = &oo_lines[i];
+		dm_free(oo->name);
+		dm_free(oo->line);
+	}
+	memset(&oo_lines, 0, sizeof(oo_lines));
+	oo_line_count = 0;
 
 	return 1;
 }
@@ -3422,6 +3442,7 @@ static void _print_man_secondary(char *name)
 
 int main(int argc, char *argv[])
 {
+	struct cmd_context cmdtool;
 	char *cmdname = NULL;
 	char *desfile = NULL;
 	char *stdout_buf;
@@ -3478,7 +3499,7 @@ int main(int argc, char *argv[])
 	if (optind < argc)
 		desfile = argv[optind++];
 
-	define_commands(NULL);
+	define_commands(&cmdtool, NULL);
 
 	configure_command_option_values(cmdname);
 
diff --git a/tools/command.h b/tools/command.h
index 339863c..a84e374 100644
--- a/tools/command.h
+++ b/tools/command.h
@@ -255,7 +255,7 @@ struct lv_type {
 };
 
 
-int define_commands(const char *run_name);
+int define_commands(struct cmd_context *cmdtool, const char *run_name);
 int command_id_to_enum(const char *str);
 void print_usage(struct command *cmd, int longhelp, int desc_first);
 void print_usage_common_cmd(struct command_name *cname, struct command *cmd);
diff --git a/tools/lvm2cmdline.h b/tools/lvm2cmdline.h
index 48c2c37..0073f90 100644
--- a/tools/lvm2cmdline.h
+++ b/tools/lvm2cmdline.h
@@ -32,7 +32,7 @@ void *cmdlib_lvm2_init(unsigned static_compile);
 void lvm_fin(struct cmd_context *cmd);
 
 struct cmd_context *init_lvm(unsigned set_connections, unsigned set_filters);
-int lvm_register_commands(const char *name);
+int lvm_register_commands(struct cmd_context *cmdtool, const char *name);
 int lvm_split(char *str, int *argc, char **argv, int max);
 int lvm_run_command(struct cmd_context *cmd, int argc, char **argv);
 int lvm_return_code(int ret);
diff --git a/tools/lvmcmdlib.c b/tools/lvmcmdlib.c
index 8f15c1f..5944576 100644
--- a/tools/lvmcmdlib.c
+++ b/tools/lvmcmdlib.c
@@ -34,7 +34,7 @@ void *cmdlib_lvm2_init(unsigned static_compile)
 	if (!(cmd = init_lvm(1, 1)))
 		return NULL;
 
-	if (!lvm_register_commands(NULL))
+	if (!lvm_register_commands(cmd, NULL))
 		return NULL;
 
 	return (void *) cmd;
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 29ec06b..9e77d48 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1241,7 +1241,16 @@ static const struct command_function *_find_command_id_function(int command_enum
 	return NULL;
 }
 
-int lvm_register_commands(const char *run_name)
+static void _unregister_commands(void)
+{
+	_cmdline.commands = NULL;
+	_cmdline.num_commands = 0;
+	_cmdline.command_names = NULL;
+	_cmdline.num_command_names = 0;
+	memset(&commands, 0, sizeof(commands));
+}
+
+int lvm_register_commands(struct cmd_context *cmd, const char *run_name)
 {
 	int i;
 
@@ -1255,7 +1264,7 @@ int lvm_register_commands(const char *run_name)
 	 * populate commands[] array with command definitions
 	 * by parsing command-lines.in/command-lines-input.h
 	 */
-	if (!define_commands(run_name)) {
+	if (!define_commands(cmd, run_name)) {
 		log_error(INTERNAL_ERROR "Failed to parse command definitions.");
 		return 0;
 	}
@@ -1285,6 +1294,7 @@ int lvm_register_commands(const char *run_name)
 	}
 
 	_cmdline.command_names = command_names;
+	_cmdline.num_command_names = 0;
 
 	for (i = 0; i < MAX_COMMAND_NAMES; i++) {
 		if (!command_names[i].name)
@@ -3268,6 +3278,7 @@ struct cmd_context *init_lvm(unsigned set_connections, unsigned set_filters)
 
 void lvm_fin(struct cmd_context *cmd)
 {
+	_unregister_commands();
 	destroy_toolcontext(cmd);
 	udev_fin_library_context();
 }
@@ -3448,7 +3459,7 @@ int lvm2_main(int argc, char **argv)
 	if (run_name && !find_command_name(run_name))
 		run_name = NULL;
 
-	if (!lvm_register_commands(run_name)) {
+	if (!lvm_register_commands(cmd, run_name)) {
 		ret = ECMD_FAILED;
 		goto out;
 	}


