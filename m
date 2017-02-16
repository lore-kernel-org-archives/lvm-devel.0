From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 16 Feb 2017 21:28:42 +0000 (UTC)
Subject: master - commands: track errors in command def parsing
Message-ID: <20170216212842.384B560563@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=298b11aed1f1517329dc6e5ead661855b1abfb05
Commit:        298b11aed1f1517329dc6e5ead661855b1abfb05
Parent:        1cb95fa5a050c5056d882ef9cbb01ce8040df019
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Feb 16 15:26:42 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Feb 16 15:26:42 2017 -0600

commands: track errors in command def parsing

When parsing command defs, track and report all
errors that are found.  Add an error return case
from define_commands so the standard error exit
path is used.
---
 tools/command.c     |  126 +++++++++++++++++++++++++++++++--------------------
 tools/command.h     |    1 +
 tools/lvm2cmdline.h |    2 +-
 tools/lvmcmdlib.c   |    3 +-
 tools/lvmcmdline.c  |   22 +++++++--
 5 files changed, 97 insertions(+), 57 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index 6814a54..5b31b4e 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -354,7 +354,7 @@ static int val_str_to_num(char *str)
 
 #define MAX_LONG_OPT_NAME_LEN 32
 
-static int opt_str_to_num(char *str)
+static int opt_str_to_num(struct command *cmd, char *str)
 {
 	char long_name[MAX_LONG_OPT_NAME_LEN];
 	char *p;
@@ -383,7 +383,8 @@ static int opt_str_to_num(char *str)
 		}
 
 		log_error("Parsing command defs: unknown opt str: %s %s", str, long_name);
-		exit(EXIT_FAILURE);
+		cmd->cmd_flags |= CMD_FLAG_PARSE_ERROR;
+		return ARG_UNUSED;
 	}
 
 	for (i = 0; i < ARG_COUNT; i++) {
@@ -397,7 +398,8 @@ static int opt_str_to_num(char *str)
 	}
 
 	log_error("Parsing command defs: unknown opt str: \"%s\"", str);
-	exit(EXIT_FAILURE);
+	cmd->cmd_flags |= CMD_FLAG_PARSE_ERROR;
+	return ARG_UNUSED;
 }
 
 /* "foo" string to foo_CMD int */
@@ -410,13 +412,13 @@ int command_id_to_enum(const char *str)
 		if (!strcmp(str, cmd_names[i].name))
 			return cmd_names[i].cmd_enum;
 	}
-	log_error("Parsing command defs: unknown cmd name %s", str);
-	exit(EXIT_FAILURE);
+
+	return CMD_NONE;
 }
 
 /* "lv_is_prop" to is_prop_LVP */
 
-static int lvp_name_to_enum(char *str)
+static int lvp_name_to_enum(struct command *cmd, char *str)
 {
 	int i;
 
@@ -424,13 +426,15 @@ static int lvp_name_to_enum(char *str)
 		if (!strcmp(str, lvp_names[i].name))
 			return lvp_names[i].lvp_enum;
 	}
+
 	log_error("Parsing command defs: unknown lv property %s", str);
-	exit(EXIT_FAILURE);
+	cmd->cmd_flags |= CMD_FLAG_PARSE_ERROR;
+	return LVP_NONE;
 }
 
 /* "type" to type_LVT */
 
-static int lvt_name_to_enum(char *str)
+static int lvt_name_to_enum(struct command *cmd, char *str)
 {
 	int i;
 
@@ -438,15 +442,17 @@ static int lvt_name_to_enum(char *str)
 		if (!strcmp(str, lvt_names[i].name))
 			return lvt_names[i].lvt_enum;
 	}
+
 	log_error("Parsing command defs: unknown lv type %s", str);
-	exit(EXIT_FAILURE);
+	cmd->cmd_flags |= CMD_FLAG_PARSE_ERROR;
+	return LVT_NONE;
 }
 
 /* LV_<type> to <type>_LVT */
 
-static int lv_to_enum(char *name)
+static int lv_to_enum(struct command *cmd, char *name)
 {
-	return lvt_name_to_enum(name + 3);
+	return lvt_name_to_enum(cmd, name + 3);
 }
 
 /*
@@ -460,7 +466,7 @@ static int lv_to_enum(char *name)
 
 #define LVTYPE_LEN 64
 
-static uint64_t lv_to_bits(char *name)
+static uint64_t lv_to_bits(struct command *cmd, char *name)
 {
 	char buf[LVTYPE_LEN];
 	char *argv[MAX_LINE_ARGC];
@@ -478,7 +484,7 @@ static uint64_t lv_to_bits(char *name)
 	for (i = 1; i < argc; i++) {
 		if (!strcmp(argv[i], "new"))
 			continue;
-		lvt_enum = lvt_name_to_enum(argv[i]);
+		lvt_enum = lvt_name_to_enum(cmd, argv[i]);
 		lvt_bits |= lvt_enum_to_bit(lvt_enum);
 	}
 
@@ -516,10 +522,8 @@ static int is_opt_name(char *str)
 	if (!strncmp(str, "--", 2))
 		return 1;
 
-	if ((str[0] == '-') && (str[1] != '-')) {
+	if ((str[0] == '-') && (str[1] != '-'))
 		log_error("Parsing command defs: options must be specified in long form: %s", str);
-		exit(EXIT_FAILURE);
-	}
 
 	return 0;
 }
@@ -625,13 +629,14 @@ static void set_pos_def(struct command *cmd, char *str, struct arg_def *def)
 
 		if (!val_enum) {
 			log_error("Parsing command defs: unknown pos arg: %s", name);
-			exit(EXIT_FAILURE);
+			cmd->cmd_flags |= CMD_FLAG_PARSE_ERROR;
+			return;
 		}
 
 		def->val_bits |= val_enum_to_bit(val_enum);
 
 		if ((val_enum == lv_VAL) && strstr(name, "_"))
-			def->lvt_bits = lv_to_bits(name);
+			def->lvt_bits = lv_to_bits(cmd, name);
 
 		if (strstr(name, "_new")) {
 			if (val_enum == lv_VAL)
@@ -673,7 +678,8 @@ static void set_opt_def(struct command *cmd, char *str, struct arg_def *def)
 
 			else {
 				log_error("Parsing command defs: unknown opt arg: %s", name);
-				exit(EXIT_FAILURE);
+				cmd->cmd_flags |= CMD_FLAG_PARSE_ERROR;
+				return;
 			}
 		}
 
@@ -688,7 +694,7 @@ static void set_opt_def(struct command *cmd, char *str, struct arg_def *def)
 
 		if (val_enum == lv_VAL) {
 			if (strstr(name, "_"))
-				def->lvt_bits = lv_to_bits(name);
+				def->lvt_bits = lv_to_bits(cmd, name);
 		}
 
 		if (strstr(name, "_new")) {
@@ -711,7 +717,7 @@ static void set_opt_def(struct command *cmd, char *str, struct arg_def *def)
  * oo->line = "--opt1 ...";
  */
 
-static void add_oo_definition_line(const char *name, const char *line)
+static void add_oo_definition_line(struct command *cmd, const char *name, const char *line)
 {
 	struct oo_line *oo;
 	char *colon;
@@ -724,7 +730,8 @@ static void add_oo_definition_line(const char *name, const char *line)
 		*colon = '\0';
 	else {
 		log_error("Parsing command defs: invalid OO definition");
-		exit(EXIT_FAILURE);
+		cmd->cmd_flags |= CMD_FLAG_PARSE_ERROR;
+		return;
 	}
 
 	start = strstr(line, ":") + 2;
@@ -733,7 +740,7 @@ static void add_oo_definition_line(const char *name, const char *line)
 
 /* Support OO_FOO: continuing on multiple lines. */
 
-static void append_oo_definition_line(const char *new_line)
+static void append_oo_definition_line(struct command *cmd, const char *new_line)
 {
 	struct oo_line *oo;
 	char *old_line;
@@ -749,7 +756,8 @@ static void append_oo_definition_line(const char *new_line)
 	line = dm_malloc(len);
 	if (!line) {
 		log_error("Parsing command defs: no memory");
-		exit(EXIT_FAILURE);
+		cmd->cmd_flags |= CMD_FLAG_PARSE_ERROR;
+		return;
 	}
 	memset(line, 0, len);
 
@@ -801,11 +809,14 @@ static void include_optional_opt_args(struct command *cmd, const char *str)
 
 	if (!(oo_line = get_oo_line(str))) {
 		log_error("Parsing command defs: no OO line found for %s", str);
-		exit(EXIT_FAILURE);
+		cmd->cmd_flags |= CMD_FLAG_PARSE_ERROR;
+		return;
 	}
 
-	if (!(line = dm_strdup(oo_line)))
-		exit(EXIT_FAILURE);
+	if (!(line = dm_strdup(oo_line))) {
+		cmd->cmd_flags |= CMD_FLAG_PARSE_ERROR;
+		return;
+	}
 
 	split_line(line, &line_argc, line_argv, ' ');
 	add_optional_opt_line(cmd, line_argc, line_argv);
@@ -838,7 +849,7 @@ static void add_opt_arg(struct command *cmd, char *str, int *takes_arg, int requ
 		goto skip;
 	}
 
-	opt = opt_str_to_num(str);
+	opt = opt_str_to_num(cmd, str);
 skip:
 	if (required > 0)
 		cmd->required_opt_args[cmd->ro_count++].opt = opt;
@@ -846,8 +857,6 @@ skip:
 		cmd->optional_opt_args[cmd->oo_count++].opt = opt;
 	else if (required < 0)
 		cmd->ignore_opt_args[cmd->io_count++].opt = opt;
-	else
-		exit(EXIT_FAILURE);
 
 	*takes_arg = opt_names[opt].val_enum ? 1 : 0;
 }
@@ -864,7 +873,8 @@ static void update_prev_opt_arg(struct command *cmd, char *str, int required)
 
 	if (str[0] == '-') {
 		log_error("Parsing command defs: option %s must be followed by an arg.", str);
-		exit(EXIT_FAILURE);
+		cmd->cmd_flags |= CMD_FLAG_PARSE_ERROR;
+		return;
 	}
 
 	/* opt_arg.def set here */
@@ -882,7 +892,7 @@ static void update_prev_opt_arg(struct command *cmd, char *str, int required)
 	else if (required < 0)
 		cmd->ignore_opt_args[cmd->io_count-1].def = def;
 	else
-		exit(EXIT_FAILURE);
+		return;
 }
 
 /*
@@ -926,7 +936,8 @@ static void update_prev_pos_arg(struct command *cmd, char *str, int required)
 		def->flags |= ARG_DEF_FLAG_MAY_REPEAT;
 	else {
 		log_error("Parsing command defs: unknown pos arg: %s", str);
-		exit(EXIT_FAILURE);
+		cmd->cmd_flags |= CMD_FLAG_PARSE_ERROR;
+		return;
 	}
 }
 
@@ -949,7 +960,8 @@ static void add_optional_opt_line(struct command *cmd, int argc, char *argv[])
 		else {
 			log_error("Parsing command defs: can't parse argc %d argv %s prev %s",
 				i, argv[i], argv[i-1]);
-			exit(EXIT_FAILURE);
+			cmd->cmd_flags |= CMD_FLAG_PARSE_ERROR;
+			return;
 		}
 	}
 }
@@ -971,7 +983,8 @@ static void add_ignore_opt_line(struct command *cmd, int argc, char *argv[])
 		else {
 			log_error("Parsing command defs: can't parse argc %d argv %s prev %s",
 				i, argv[i], argv[i-1]);
-			exit(EXIT_FAILURE);
+			cmd->cmd_flags |= CMD_FLAG_PARSE_ERROR;
+			return;
 		}
 	}
 }
@@ -1005,7 +1018,8 @@ static void add_required_opt_line(struct command *cmd, int argc, char *argv[])
 		else {
 			log_error("Parsing command defs: can't parse argc %d argv %s prev %s",
 				  i, argv[i], argv[i-1]);
-			exit(EXIT_FAILURE);
+			cmd->cmd_flags |= CMD_FLAG_PARSE_ERROR;
+			return;
 		}
 	}
 }
@@ -1028,11 +1042,14 @@ static void include_required_opt_args(struct command *cmd, char *str)
 
 	if (!(oo_line = get_oo_line(str))) {
 		log_error("Parsing command defs: no OO line found for %s", str);
-		exit(EXIT_FAILURE);
+		cmd->cmd_flags |= CMD_FLAG_PARSE_ERROR;
+		return;
 	}
 
-	if (!(line = dm_strdup(oo_line)))
-		exit(EXIT_FAILURE);
+	if (!(line = dm_strdup(oo_line))) {
+		cmd->cmd_flags |= CMD_FLAG_PARSE_ERROR;
+		return;
+	}
 
 	split_line(line, &line_argc, line_argv, ' ');
 	add_required_opt_line(cmd, line_argc, line_argv);
@@ -1080,9 +1097,9 @@ static void add_required_line(struct command *cmd, int argc, char *argv[])
 		} else {
 			log_error("Parsing command defs: can't parse argc %d argv %s prev %s",
 				  i, argv[i], argv[i-1]);
-			exit(EXIT_FAILURE);
+			cmd->cmd_flags |= CMD_FLAG_PARSE_ERROR;
+			return;
 		}
-
 	}
 }
 
@@ -1105,7 +1122,8 @@ static void add_rule(struct command *cmd, char *line)
 
 	if (cmd->rule_count == CMD_MAX_RULES) {
 		log_error("Parsing command defs: too many rules for cmd");
-		exit(EXIT_FAILURE);
+		cmd->cmd_flags |= CMD_FLAG_PARSE_ERROR;
+		return;
 	}
 
 	rule = &cmd->rules[cmd->rule_count++];
@@ -1134,7 +1152,8 @@ static void add_rule(struct command *cmd, char *line)
 			if (!rule->opts) {
 				if (!(rule->opts = dm_malloc(MAX_RULE_OPTS * sizeof(int)))) {
 					log_error("Parsing command defs: no mem");
-					exit(EXIT_FAILURE);
+					cmd->cmd_flags |= CMD_FLAG_PARSE_ERROR;
+					return;
 				}
 				memset(rule->opts, 0, MAX_RULE_OPTS * sizeof(int));
 			}
@@ -1142,19 +1161,20 @@ static void add_rule(struct command *cmd, char *line)
 			if (!rule->check_opts) {
 				if (!(rule->check_opts = dm_malloc(MAX_RULE_OPTS * sizeof(int)))) {
 					log_error("Parsing command defs: no mem");
-					exit(EXIT_FAILURE);
+					cmd->cmd_flags |= CMD_FLAG_PARSE_ERROR;
+					return;
 				}
 				memset(rule->check_opts, 0, MAX_RULE_OPTS * sizeof(int));
 			}
 
 			if (check)
-				rule->check_opts[rule->check_opts_count++] = opt_str_to_num(arg);
+				rule->check_opts[rule->check_opts_count++] = opt_str_to_num(cmd, arg);
 			else
-				rule->opts[rule->opts_count++] = opt_str_to_num(arg);
+				rule->opts[rule->opts_count++] = opt_str_to_num(cmd, arg);
 		}
 
 		else if (!strncmp(arg, "LV_", 3)) {
-			lvt_enum = lv_to_enum(arg);
+			lvt_enum = lv_to_enum(cmd, arg);
 
 			if (check)
 				rule->check_lvt_bits |= lvt_enum_to_bit(lvt_enum);
@@ -1163,7 +1183,7 @@ static void add_rule(struct command *cmd, char *line)
 		}
 
 		else if (!strncmp(arg, "lv_is_", 6)) {
-			lvp_enum = lvp_name_to_enum(arg);
+			lvp_enum = lvp_name_to_enum(cmd, arg);
 
 			if (check)
 				rule->check_lvp_bits |= lvp_enum_to_bit(lvp_enum);
@@ -1315,6 +1335,7 @@ int define_commands(char *run_name)
 	int prev_was_op = 0;
 	int copy_pos = 0;
 	int skip = 0;
+	int i;
 
 	if (run_name && !strcmp(run_name, "help"))
 		run_name = NULL;
@@ -1408,7 +1429,7 @@ int define_commands(char *run_name)
 
 		/* OO_FOO: ... */
 		if (is_oo_definition(line_argv[0])) {
-			add_oo_definition_line(line_argv[0], line_orig);
+			add_oo_definition_line(cmd, line_argv[0], line_orig);
 			prev_was_oo_def = 1;
 			prev_was_oo = 0;
 			prev_was_op = 0;
@@ -1444,7 +1465,7 @@ int define_commands(char *run_name)
 		/* handle OO_FOO:, OO:, OP: continuing on multiple lines */
 
 		if (prev_was_oo_def) {
-			append_oo_definition_line(line_orig);
+			append_oo_definition_line(cmd, line_orig);
 			continue;
 		}
 
@@ -1459,6 +1480,11 @@ int define_commands(char *run_name)
 		}
 	}
 
+	for (i = 0; i < COMMAND_COUNT; i++) {
+		if (commands[i].cmd_flags & CMD_FLAG_PARSE_ERROR)
+			return 0;
+	}
+
 	/*
 	 * For usage.
 	 * Predefined string of options common to all commands
diff --git a/tools/command.h b/tools/command.h
index 0c3f9f3..fcf0ccb 100644
--- a/tools/command.h
+++ b/tools/command.h
@@ -166,6 +166,7 @@ struct cmd_rule {
  */
 #define CMD_FLAG_ONE_REQUIRED_OPT   1  /* lvchange/vgchage require one item from required_opt_args */
 #define CMD_FLAG_SECONDARY_SYNTAX   2  /* allows syntax variants to be suppressed in certain output */
+#define CMD_FLAG_PARSE_ERROR        4  /* error parsing command-lines.in def */
 
 /* a register of the lvm commands */
 struct command {
diff --git a/tools/lvm2cmdline.h b/tools/lvm2cmdline.h
index 00162a4..5c5eaee 100644
--- a/tools/lvm2cmdline.h
+++ b/tools/lvm2cmdline.h
@@ -32,7 +32,7 @@ void *cmdlib_lvm2_init(unsigned static_compile);
 void lvm_fin(struct cmd_context *cmd);
 
 struct cmd_context *init_lvm(unsigned set_connections, unsigned set_filters);
-void lvm_register_commands(char *name);
+int lvm_register_commands(char *name);
 int lvm_split(char *str, int *argc, char **argv, int max);
 int lvm_run_command(struct cmd_context *cmd, int argc, char **argv);
 int lvm_return_code(int ret);
diff --git a/tools/lvmcmdlib.c b/tools/lvmcmdlib.c
index 9e50343..8f15c1f 100644
--- a/tools/lvmcmdlib.c
+++ b/tools/lvmcmdlib.c
@@ -34,7 +34,8 @@ void *cmdlib_lvm2_init(unsigned static_compile)
 	if (!(cmd = init_lvm(1, 1)))
 		return NULL;
 
-	lvm_register_commands(NULL);
+	if (!lvm_register_commands(NULL))
+		return NULL;
 
 	return (void *) cmd;
 }
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index e599ded..7e50d05 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1126,13 +1126,13 @@ static struct command_function *_find_command_id_function(int command_enum)
 	return NULL;
 }
 
-void lvm_register_commands(char *name)
+int lvm_register_commands(char *name)
 {
 	int i;
 
 	/* already initialized */
 	if (_cmdline.commands)
-		return;
+		return 1;
 
 	memset(&commands, 0, sizeof(commands));
 
@@ -1141,8 +1141,8 @@ void lvm_register_commands(char *name)
 	 * by parsing command-lines.in/command-lines-input.h
 	 */
 	if (!define_commands(name)) {
-		log_error("Failed to parse command definitions.");
-		return;
+		log_error(INTERNAL_ERROR "Failed to parse command definitions.");
+		return 0;
 	}
 
 	_cmdline.commands = commands;
@@ -1151,6 +1151,13 @@ void lvm_register_commands(char *name)
 	for (i = 0; i < COMMAND_COUNT; i++) {
 		commands[i].command_enum = command_id_to_enum(commands[i].command_id);
 
+		if (!commands[i].command_enum) {
+			log_error(INTERNAL_ERROR "Failed to find command id %s.", commands[i].command_id);
+			_cmdline.commands = NULL;
+			_cmdline.num_commands = 0;
+			return 0;
+		}
+
 		/* new style */
 		commands[i].functions = _find_command_id_function(commands[i].command_enum);
 
@@ -1172,6 +1179,8 @@ void lvm_register_commands(char *name)
 
 	for (i = 0; i < _cmdline.num_command_names; i++)
 		_set_valid_args_for_command_name(i);
+
+	return 1;
 }
 
 struct lv_props *get_lv_prop(int lvp_enum)
@@ -3214,7 +3223,10 @@ int lvm2_main(int argc, char **argv)
 	else
 		name = argv[1];
 
-	lvm_register_commands(name);
+	if (!lvm_register_commands(name)) {
+		ret = ECMD_FAILED;
+		goto out;
+	}
 
 	if (_lvm1_fallback(cmd)) {
 		/* Attempt to run equivalent LVM1 tool instead */


