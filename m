From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 15 Feb 2017 21:50:03 +0000 (UTC)
Subject: master - commands: use dm wrappers for malloc/free
Message-ID: <20170215215003.D9B5360E0E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=81c0ed9fc6d598ef221e2089e1fd125990a7a626
Commit:        81c0ed9fc6d598ef221e2089e1fd125990a7a626
Parent:        6a5c9ba34902193ac9d03fe30976d259391905b3
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Feb 15 15:49:18 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Feb 15 15:49:18 2017 -0600

commands: use dm wrappers for malloc/free

---
 tools/command.c |   38 +++++++++++++++++++++-----------------
 1 files changed, 21 insertions(+), 17 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index aa33d5c..ac72c49 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -45,6 +45,10 @@ do { \
 	printf(fmt "\n", ##args); \
 } while (0)
 
+#define dm_malloc malloc
+#define dm_free free
+#define dm_strdup strdup
+
 /* needed to include args.h */
 #define ARG_COUNTABLE 0x00000001
 #define ARG_GROUPABLE 0x00000002
@@ -680,7 +684,7 @@ static void set_opt_def(struct command *cmd, char *str, struct arg_def *def)
 			def->num = (uint64_t)atoi(name);
 
 		if (val_enum == conststr_VAL)
-			def->str = strdup(name);
+			def->str = dm_strdup(name);
 
 		if (val_enum == lv_VAL) {
 			if (strstr(name, "_"))
@@ -714,7 +718,7 @@ static void add_oo_definition_line(const char *name, const char *line)
 	char *start;
 
 	oo = &oo_lines[oo_line_count++];
-	oo->name = strdup(name);
+	oo->name = dm_strdup(name);
 
 	if ((colon = strstr(oo->name, ":")))
 		*colon = '\0';
@@ -724,7 +728,7 @@ static void add_oo_definition_line(const char *name, const char *line)
 	}
 
 	start = strstr(line, ":") + 2;
-	oo->line = strdup(start);
+	oo->line = dm_strdup(start);
 }
 
 /* Support OO_FOO: continuing on multiple lines. */
@@ -742,7 +746,7 @@ static void append_oo_definition_line(const char *new_line)
 
 	/* +2 = 1 space between old and new + 1 terminating \0 */
 	len = strlen(old_line) + strlen(new_line) + 2;
-	line = malloc(len);
+	line = dm_malloc(len);
 	if (!line) {
 		log_error("Parsing command defs: no memory");
 		exit(EXIT_FAILURE);
@@ -753,7 +757,7 @@ static void append_oo_definition_line(const char *new_line)
 	strcat(line, " ");
 	strcat(line, new_line);
 
-	free(oo->line);
+	dm_free(oo->line);
 	oo->line = line;
 }
 
@@ -800,12 +804,12 @@ static void include_optional_opt_args(struct command *cmd, const char *str)
 		exit(EXIT_FAILURE);
 	}
 
-	if (!(line = strdup(oo_line)))
+	if (!(line = dm_strdup(oo_line)))
 		exit(EXIT_FAILURE);
 
 	split_line(line, &line_argc, line_argv, ' ');
 	add_optional_opt_line(cmd, line_argc, line_argv);
-	free(line);
+	dm_free(line);
 }
 
 /*
@@ -1027,12 +1031,12 @@ static void include_required_opt_args(struct command *cmd, char *str)
 		exit(EXIT_FAILURE);
 	}
 
-	if (!(line = strdup(oo_line)))
+	if (!(line = dm_strdup(oo_line)))
 		exit(EXIT_FAILURE);
 
 	split_line(line, &line_argc, line_argv, ' ');
 	add_required_opt_line(cmd, line_argc, line_argv);
-	free(line);
+	dm_free(line);
 }
 
 /* Process what follows command_name, which are required opt/pos args. */
@@ -1128,7 +1132,7 @@ static void add_rule(struct command *cmd, char *line)
 
 		else if (!strncmp(arg, "--", 2)) {
 			if (!rule->opts) {
-				if (!(rule->opts = malloc(MAX_RULE_OPTS * sizeof(int)))) {
+				if (!(rule->opts = dm_malloc(MAX_RULE_OPTS * sizeof(int)))) {
 					log_error("Parsing command defs: no mem");
 					exit(EXIT_FAILURE);
 				}
@@ -1136,7 +1140,7 @@ static void add_rule(struct command *cmd, char *line)
 			}
 
 			if (!rule->check_opts) {
-				if (!(rule->check_opts = malloc(MAX_RULE_OPTS * sizeof(int)))) {
+				if (!(rule->check_opts = dm_malloc(MAX_RULE_OPTS * sizeof(int)))) {
 					log_error("Parsing command defs: no mem");
 					exit(EXIT_FAILURE);
 				}
@@ -1343,7 +1347,7 @@ int define_commands(char *run_name)
 			cmd = &commands[cmd_count];
 			cmd->command_index = cmd_count;
 			cmd_count++;
-			cmd->name = strdup(name);
+			cmd->name = dm_strdup(name);
 
 			if (run_name && strcmp(run_name, name)) {
 				skip = 1;
@@ -1368,15 +1372,15 @@ int define_commands(char *run_name)
 		 */
 
 		if (is_desc_line(line_argv[0]) && !skip) {
-			char *desc = strdup(line_orig);
+			char *desc = dm_strdup(line_orig);
 			if (cmd->desc) {
 				int newlen = strlen(cmd->desc) + strlen(desc) + 2;
-				char *newdesc = malloc(newlen);
+				char *newdesc = dm_malloc(newlen);
 				if (newdesc) {
 					memset(newdesc, 0, newlen);
 					snprintf(newdesc, newlen, "%s %s", cmd->desc, desc);
 					cmd->desc = newdesc;
-					free(desc);
+					dm_free(desc);
 				}
 			} else
 				cmd->desc = desc;
@@ -1394,7 +1398,7 @@ int define_commands(char *run_name)
 		}
 
 		if (is_id_line(line_argv[0])) {
-			cmd->command_id = strdup(line_argv[1]);
+			cmd->command_id = dm_strdup(line_argv[1]);
 			continue;
 		}
 
@@ -1757,7 +1761,7 @@ static void print_val_man(const char *str)
 
 	if (strstr(str, "|")) {
 		int len = strlen(str);
-		line = strdup(str);
+		line = dm_strdup(str);
 		split_line(line, &line_argc, line_argv, '|');
 		for (i = 0; i < line_argc; i++) {
 			if (i) {


