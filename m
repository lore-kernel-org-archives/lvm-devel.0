From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  2 Mar 2021 21:58:29 +0000 (GMT)
Subject: main - cmdline: use binary search
Message-ID: <20210302215829.151393834402@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=081e47912e6c80f233fec5d472e32e1ac4f19a78
Commit:        081e47912e6c80f233fec5d472e32e1ac4f19a78
Parent:        589c6545627cdc5a90bf4c2e4640c42d9623bb47
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 25 18:09:52 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 2 22:54:40 2021 +0100

cmdline: use binary search

Reduce strcmp() call count by using binary search to find
commands in cmd_names[] and command_names[] arrays.
---
 tools/command.c    | 56 ++++++++++++++++++++++++++++++++-------
 tools/command.h    |  1 +
 tools/lvmcmdline.c | 77 ++++++++++++++++++++++++++++++++----------------------
 3 files changed, 94 insertions(+), 40 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index 131d2d3d3..282c9fa43 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -426,12 +426,19 @@ static int _opt_str_to_num(struct command *cmd, char *str)
 int command_id_to_enum(const char *str)
 {
 	int i;
+	int first = 1, last = CMD_COUNT - 1, middle;
 
-	for (i = 1; i < CMD_COUNT; i++) {
-		if (!strcmp(str, cmd_names[i].name))
-			return cmd_names[i].cmd_enum;
+	while (first <= last) {
+		middle = first + (last - first) / 2;
+		if ((i = strcmp(cmd_names[middle].name, str)) < 0)
+			first = middle + 1;
+		else if (i > 0)
+			last = middle - 1;
+		else
+			return cmd_names[middle].cmd_enum;
 	}
 
+	log_error("Cannot find command %s.", str);
 	return CMD_NONE;
 }
 
@@ -509,20 +516,51 @@ static uint64_t _lv_to_bits(struct command *cmd, char *name)
 	return lvt_bits;
 }
 
-static struct command_name *_find_command_name(const char *name)
+struct command_name *find_command_name(const char *name)
 {
+	static int _command_names_count = -1;
+	int first = 0, last, middle;
 	int i;
 
-	if (!islower(name[0]))
-		return NULL; /* Commands starts with lower-case */
+	if (_command_names_count == -1) {
+		/* Validate cmd_names & command_names arrays are properly sorted */
+		for (i = 1; i < CMD_COUNT - 2; i++)
+			if (strcmp(cmd_names[i].name, cmd_names[i + 1].name) > 0) {
+				log_error("File cmds.h has unsorted name entry %s.",
+					  cmd_names[i].name);
+				return 0;
+			}
+		for (i = 1; command_names[i].name; i++) /* assume > 1 */
+			if (strcmp(command_names[i - 1].name, command_names[i].name) > 0) {
+				log_error("File commands.h has unsorted name entry %s.",
+					  command_names[i].name);
+				return 0;
+			}
+		_command_names_count = i - 1;
+	}
+	last = _command_names_count;
 
-	for (i = 0; command_names[i].name; i++)
-		if (!strcmp(command_names[i].name, name))
-			return &command_names[i];
+	while (first <= last) {
+		middle = first + (last - first) / 2;
+		if ((i = strcmp(command_names[middle].name, name)) < 0)
+			first = middle + 1;
+		else if (i > 0)
+			last = middle - 1;
+		else
+			return &command_names[middle];
+	}
 
 	return NULL;
 }
 
+static struct command_name *_find_command_name(const char *name)
+{
+	if (!islower(name[0]))
+		return NULL; /* Commands starts with lower-case */
+
+	return find_command_name(name);
+}
+
 static const char *_is_command_name(char *str)
 {
 	const struct command_name *c;
diff --git a/tools/command.h b/tools/command.h
index c0d7977dc..325ad1dd0 100644
--- a/tools/command.h
+++ b/tools/command.h
@@ -272,5 +272,6 @@ void print_usage_notes(struct command_name *cname);
 void factor_common_options(void);
 int command_has_alternate_extents(const char *name);
 void configure_command_option_values(const char *name);
+struct command_name *find_command_name(const char *name);
 
 #endif
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 8ad1f5e99..588c78d72 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -80,6 +80,7 @@ extern struct command_name command_names[];
  * Table of commands (as defined in command-lines.in)
  */
 struct command commands[COMMAND_COUNT];
+struct command *commands_idx[COMMAND_COUNT];
 
 static struct cmdline_context _cmdline;
 
@@ -1216,19 +1217,35 @@ static void _set_valid_args_for_command_name(int ci)
 	int opt_enum; /* foo_ARG from args.h */
 	int opt_syn;
 	int i, ro, oo, io;
+	int first = 0, last = COMMAND_COUNT - 1, middle;
+	const char *name = command_names[ci].name;
+
+	/* all_args is indexed by the foo_ARG enum vals */
+	/* Binary search in sorted array of long options (with duplicates) */
+	while (first <= last) {
+		middle = first + (last - first) / 2;
+		if ((i = strcmp(commands_idx[middle]->name, name)) < 0)
+			first = middle + 1;
+		else if (i > 0)
+			last = middle - 1;
+		else {
+			/* Matching command found.
+			 * As sorted array contains duplicates, found 1st. and last such cmd. */
+			i = middle;
+			while (middle > first && !strcmp(commands_idx[middle - 1]->name, name))
+				middle--;
+			while (i < last && !strcmp(commands_idx[i + 1]->name, name))
+				i++;
+			last = i;
+			break;
+		}
+	}
 
-	/*
-	 * all_args is indexed by the foo_ARG enum vals
-	 */
-
-	for (i = 0; i < COMMAND_COUNT; i++) {
-		if (strcmp(commands[i].name, command_names[ci].name))
-			continue;
-
+	while (middle <= last) {
+		i = commands_idx[middle++]->command_index;
 		for (ro = 0; ro < (commands[i].ro_count + commands[i].any_ro_count); ro++) {
 			opt_enum = commands[i].required_opt_args[ro].opt;
 			all_args[opt_enum] = 1;
-
 		}
 		for (oo = 0; oo < commands[i].oo_count; oo++) {
 			opt_enum = commands[i].optional_opt_args[oo].opt;
@@ -1275,17 +1292,6 @@ static void _set_valid_args_for_command_name(int ci)
 	command_names[ci].num_args = num_args;
 }
 
-static struct command_name *_find_command_name(const char *name)
-{
-	int i;
-
-	for (i = 0; command_names[i].name; i++)
-		if (!strcmp(command_names[i].name, name))
-			return &command_names[i];
-
-	return NULL;
-}
-
 static const struct command_function *_find_command_id_function(int command_enum)
 {
 	int i;
@@ -1309,6 +1315,14 @@ static void _unregister_commands(void)
 	memset(&commands, 0, sizeof(commands));
 }
 
+static int _command_name_compare(const void *on1, const void *on2)
+{
+	const struct command * const *optname1 = on1;
+	const struct command * const *optname2 = on2;
+
+	return strcmp((*optname1)->name, (*optname2)->name);
+}
+
 int lvm_register_commands(struct cmd_context *cmd, const char *run_name)
 {
 	int i;
@@ -1332,6 +1346,8 @@ int lvm_register_commands(struct cmd_context *cmd, const char *run_name)
 	_cmdline.num_commands = COMMAND_COUNT;
 
 	for (i = 0; i < COMMAND_COUNT; i++) {
+		commands_idx[i] = &commands[i];
+		commands[i].command_index = i;
 		commands[i].command_enum = command_id_to_enum(commands[i].command_id);
 
 		if (!commands[i].command_enum) {
@@ -1346,22 +1362,21 @@ int lvm_register_commands(struct cmd_context *cmd, const char *run_name)
 
 		/* old style */
 		if (!commands[i].functions) {
-			struct command_name *cname = _find_command_name(commands[i].name);
+			struct command_name *cname = find_command_name(commands[i].name);
 			if (cname)
 				commands[i].fn = cname->fn;
 		}
 	}
 
-	/* Check how many command entries we have */
+	/* Sort all commands by its name for quick binary search */
+	qsort(commands_idx, COMMAND_COUNT, sizeof(long), _command_name_compare);
+
 	for (i = 0; command_names[i].name; i++)
-		;
+		_set_valid_args_for_command_name(i);
 
-	_cmdline.num_command_names = i;
+	_cmdline.num_command_names = i; /* Also counted how many command entries we have */
 	_cmdline.command_names = command_names;
 
-	for (i = 0; i < _cmdline.num_command_names; i++)
-		_set_valid_args_for_command_name(i);
-
 	return 1;
 }
 
@@ -2002,7 +2017,7 @@ static void _short_usage(const char *name)
 
 static int _usage(const char *name, int longhelp, int skip_notes)
 {
-	struct command_name *cname = _find_command_name(name);
+	struct command_name *cname = find_command_name(name);
 	struct command *cmd = NULL;
 	int show_full = longhelp;
 	int i;
@@ -2163,7 +2178,7 @@ static int _find_arg(const char *cmd_name, int goval)
 	int arg_enum;
 	int i;
 
-	if (!(cname = _find_command_name(cmd_name)))
+	if (!(cname = find_command_name(cmd_name)))
 		return -1;
 
 	for (i = 0; i < cname->num_args; i++) {
@@ -3051,7 +3066,7 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 		return_ECMD_FAILED;
 
 	/* Look up command - will be NULL if not recognised */
-	if (!(cmd->cname = _find_command_name(cmd->name)))
+	if (!(cmd->cname = find_command_name(cmd->name)))
 		return ENO_SUCH_CMD;
 
 	if (!_process_command_line(cmd, &argc, &argv)) {
@@ -3699,7 +3714,7 @@ int lvm2_main(int argc, char **argv)
 	 */
 	if (!run_name)
 		run_shell = 1;
-	else if (!_find_command_name(run_name))
+	else if (!find_command_name(run_name))
 		run_script = 1;
 	else
 		run_command_name = run_name;


