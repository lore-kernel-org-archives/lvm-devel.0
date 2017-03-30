From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Thu, 30 Mar 2017 11:55:11 -0400
Subject: master - man-generator: add '.' to all messages
Message-ID: <201703301555.v2UFtBfu009312@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b3854155d9331868a92324b4ac6f03d04dd59baa
Commit:        b3854155d9331868a92324b4ac6f03d04dd59baa
Parent:        99dc49c7dda2244000eaa3b91b129923c8ed26e8
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Mar 30 17:54:36 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Mar 30 17:54:36 2017 +0200

man-generator: add '.' to all messages

---
 tools/command.c |   42 +++++++++++++++++++++---------------------
 1 files changed, 21 insertions(+), 21 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index 9a80812..0eecb24 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -425,7 +425,7 @@ static int lvp_name_to_enum(struct command *cmd, char *str)
 			return lv_props[i].lvp_enum;
 	}
 
-	log_error("Parsing command defs: unknown lv property %s", str);
+	log_error("Parsing command defs: unknown lv property %s.", str);
 	cmd->cmd_flags |= CMD_FLAG_PARSE_ERROR;
 	return LVP_NONE;
 }
@@ -441,7 +441,7 @@ static int lvt_name_to_enum(struct command *cmd, char *str)
 			return lv_types[i].lvt_enum;
 	}
 
-	log_error("Parsing command defs: unknown lv type %s", str);
+	log_error("Parsing command defs: unknown lv type %s.", str);
 	cmd->cmd_flags |= CMD_FLAG_PARSE_ERROR;
 	return LVT_NONE;
 }
@@ -522,7 +522,7 @@ static int is_opt_name(char *str)
 		return 1;
 
 	if ((str[0] == '-') && (str[1] != '-'))
-		log_error("Parsing command defs: options must be specified in long form: %s", str);
+		log_error("Parsing command defs: options must be specified in long form: %s.", str);
 
 	return 0;
 }
@@ -624,7 +624,7 @@ static void set_pos_def(struct command *cmd, char *str, struct arg_def *def)
 		val_enum = val_str_to_num(name);
 
 		if (!val_enum) {
-			log_error("Parsing command defs: unknown pos arg: %s", name);
+			log_error("Parsing command defs: unknown pos arg: %s.", name);
 			cmd->cmd_flags |= CMD_FLAG_PARSE_ERROR;
 			return;
 		}
@@ -673,7 +673,7 @@ static void set_opt_def(struct command *cmd, char *str, struct arg_def *def)
 				val_enum = conststr_VAL;
 
 			else {
-				log_error("Parsing command defs: unknown opt arg: %s", name);
+				log_error("Parsing command defs: unknown opt arg: %s.", name);
 				cmd->cmd_flags |= CMD_FLAG_PARSE_ERROR;
 				return;
 			}
@@ -725,7 +725,7 @@ static void add_oo_definition_line(const char *name, const char *line)
 	if ((colon = strchr(oo->name, ':')))
 		*colon = '\0';
 	else {
-		log_error("Parsing command defs: invalid OO definition");
+		log_error("Parsing command defs: invalid OO definition.");
 		return;
 	}
 
@@ -750,7 +750,7 @@ static void append_oo_definition_line(const char *new_line)
 	len = strlen(old_line) + strlen(new_line) + 2;
 	line = dm_malloc(len);
 	if (!line) {
-		log_error("Parsing command defs: no memory");
+		log_error("Parsing command defs: no memory.");
 		return;
 	}
 
@@ -797,7 +797,7 @@ static void include_optional_opt_args(struct command *cmd, const char *str)
 	int line_argc;
 
 	if (!(oo_line = get_oo_line(str))) {
-		log_error("Parsing command defs: no OO line found for %s", str);
+		log_error("Parsing command defs: no OO line found for %s.", str);
 		cmd->cmd_flags |= CMD_FLAG_PARSE_ERROR;
 		return;
 	}
@@ -940,7 +940,7 @@ static void update_prev_pos_arg(struct command *cmd, char *str, int required)
 	if (!strcmp(str, "..."))
 		def->flags |= ARG_DEF_FLAG_MAY_REPEAT;
 	else {
-		log_error("Parsing command defs: unknown pos arg: %s", str);
+		log_error("Parsing command defs: unknown pos arg: %s.", str);
 		cmd->cmd_flags |= CMD_FLAG_PARSE_ERROR;
 		return;
 	}
@@ -967,7 +967,7 @@ static void add_optional_opt_line(struct command *cmd, int argc, char *argv[])
 		else if (takes_arg)
 			update_prev_opt_arg(cmd, argv[i], OPTIONAL);
 		else {
-			log_error("Parsing command defs: can't parse argc %d argv %s prev %s",
+			log_error("Parsing command defs: can't parse argc %d argv %s prev %s.",
 				i, argv[i], argv[i-1]);
 			cmd->cmd_flags |= CMD_FLAG_PARSE_ERROR;
 			return;
@@ -993,7 +993,7 @@ static void add_ignore_opt_line(struct command *cmd, int argc, char *argv[])
 		else if (takes_arg)
 			update_prev_opt_arg(cmd, argv[i], IGNORE);
 		else {
-			log_error("Parsing command defs: can't parse argc %d argv %s prev %s",
+			log_error("Parsing command defs: can't parse argc %d argv %s prev %s.",
 				i, argv[i], argv[i-1]);
 			cmd->cmd_flags |= CMD_FLAG_PARSE_ERROR;
 			return;
@@ -1028,7 +1028,7 @@ static void add_required_opt_line(struct command *cmd, int argc, char *argv[])
 		else if (takes_arg)
 			update_prev_opt_arg(cmd, argv[i], REQUIRED);
 		else {
-			log_error("Parsing command defs: can't parse argc %d argv %s prev %s",
+			log_error("Parsing command defs: can't parse argc %d argv %s prev %s.",
 				  i, argv[i], argv[i-1]);
 			cmd->cmd_flags |= CMD_FLAG_PARSE_ERROR;
 			return;
@@ -1053,7 +1053,7 @@ static void include_required_opt_args(struct command *cmd, char *str)
 	int line_argc;
 
 	if (!(oo_line = get_oo_line(str))) {
-		log_error("Parsing command defs: no OO line found for %s", str);
+		log_error("Parsing command defs: no OO line found for %s.", str);
 		cmd->cmd_flags |= CMD_FLAG_PARSE_ERROR;
 		return;
 	}
@@ -1107,7 +1107,7 @@ static void add_required_line(struct command *cmd, int argc, char *argv[])
 			/* set property for previous required_pos_arg */
 			update_prev_pos_arg(cmd, argv[i], REQUIRED);
 		} else {
-			log_error("Parsing command defs: can't parse argc %d argv %s prev %s",
+			log_error("Parsing command defs: can't parse argc %d argv %s prev %s.",
 				  i, argv[i], argv[i-1]);
 			cmd->cmd_flags |= CMD_FLAG_PARSE_ERROR;
 			return;
@@ -1135,7 +1135,7 @@ static void add_rule(struct command *cmd, char *line)
 	int check = 0;
 
 	if (cmd->rule_count == CMD_MAX_RULES) {
-		log_error("Parsing command defs: too many rules for cmd");
+		log_error("Parsing command defs: too many rules for cmd.");
 		cmd->cmd_flags |= CMD_FLAG_PARSE_ERROR;
 		return;
 	}
@@ -1165,7 +1165,7 @@ static void add_rule(struct command *cmd, char *line)
 		else if (!strncmp(arg, "--", 2)) {
 			if (!rule->opts) {
 				if (!(rule->opts = dm_malloc(MAX_RULE_OPTS * sizeof(int)))) {
-					log_error("Parsing command defs: no mem");
+					log_error("Parsing command defs: no mem.");
 					cmd->cmd_flags |= CMD_FLAG_PARSE_ERROR;
 					return;
 				}
@@ -1174,7 +1174,7 @@ static void add_rule(struct command *cmd, char *line)
 
 			if (!rule->check_opts) {
 				if (!(rule->check_opts = dm_malloc(MAX_RULE_OPTS * sizeof(int)))) {
-					log_error("Parsing command defs: no mem");
+					log_error("Parsing command defs: no mem.");
 					cmd->cmd_flags |= CMD_FLAG_PARSE_ERROR;
 					return;
 				}
@@ -1509,7 +1509,7 @@ int define_commands(const char *run_name)
 		}
 
 		if (!skip)
-			log_error("Parsing command defs: can't process input line %s", line_orig);
+			log_error("Parsing command defs: can't process input line %s.", line_orig);
 	}
 
 	for (i = 0; i < COMMAND_COUNT; i++) {
@@ -2857,7 +2857,7 @@ static void _print_man_option_desc(struct command_name *cname, int opt_enum)
 		buf[bi++] = desc[di];
 
 		if (bi == DESC_LINE) {
-			log_error("Parsing command defs: print_man_option_desc line too long");
+			log_error("Parsing command defs: print_man_option_desc line too long.");
 			exit(EXIT_FAILURE);
 		}
 
@@ -3433,14 +3433,14 @@ int main(int argc, char *argv[])
 	}
 
 	if (!primary && !secondary) {
-		log_error("Usage: %s --primary|--secondary <command> [/path/to/description-file]", argv[0]);
+		log_error("Usage: %s --primary|--secondary <command> [/path/to/description-file].", argv[0]);
 		exit(EXIT_FAILURE);
 	}
 
 	if (optind < argc)
 		cmdname = strdup(argv[optind++]);
 	else {
-		log_error("Missing command name");
+		log_error("Missing command name.");
 		exit(EXIT_FAILURE);
 	}
 


