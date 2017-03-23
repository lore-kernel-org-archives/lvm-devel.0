From: Alasdair Kergon <agk@sourceware.org>
Date: Thu, 23 Mar 2017 19:22:53 -0400
Subject: master - tools: Reinstate lvm script processing.
Message-ID: <201703232322.v2NNMr13027926@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2eaca7ab63345594ccfd7133ddf92729b7e7691c
Commit:        2eaca7ab63345594ccfd7133ddf92729b7e7691c
Parent:        fe3b9bb7d47ef168c16cc35e306a41cbb38e869c
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Mar 23 23:03:25 2017 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Mar 23 23:20:53 2017 +0000

tools: Reinstate lvm script processing.

We check for a script if the command isn't recognised (ENO_SUCH_CMD).
(Also added a few comments and fixed some whitespace.)
---
 tools/command.c     |    2 +-
 tools/command.h     |    2 +-
 tools/lvm2cmdline.h |    2 +-
 tools/lvmcmdline.c  |   97 ++++++++++++++++++++++++--------------------------
 4 files changed, 50 insertions(+), 53 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index 5c0e151..325632f 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -1348,7 +1348,7 @@ static int copy_line(char *line, int max_line, int *position)
 	return 1;
 }
 
-int define_commands(char *run_name)
+int define_commands(const char *run_name)
 {
 	struct command *cmd = NULL;
 	char line[MAX_LINE];
diff --git a/tools/command.h b/tools/command.h
index 668428f..339863c 100644
--- a/tools/command.h
+++ b/tools/command.h
@@ -255,7 +255,7 @@ struct lv_type {
 };
 
 
-int define_commands(char *run_name);
+int define_commands(const char *run_name);
 int command_id_to_enum(const char *str);
 void print_usage(struct command *cmd, int longhelp, int desc_first);
 void print_usage_common_cmd(struct command_name *cname, struct command *cmd);
diff --git a/tools/lvm2cmdline.h b/tools/lvm2cmdline.h
index 7353c7a..48c2c37 100644
--- a/tools/lvm2cmdline.h
+++ b/tools/lvm2cmdline.h
@@ -32,7 +32,7 @@ void *cmdlib_lvm2_init(unsigned static_compile);
 void lvm_fin(struct cmd_context *cmd);
 
 struct cmd_context *init_lvm(unsigned set_connections, unsigned set_filters);
-int lvm_register_commands(char *name);
+int lvm_register_commands(const char *name);
 int lvm_split(char *str, int *argc, char **argv, int max);
 int lvm_run_command(struct cmd_context *cmd, int argc, char **argv);
 int lvm_return_code(int ret);
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 9cb506a..6f70481 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -736,7 +736,7 @@ int int_arg_with_plus(struct cmd_context *cmd __attribute__((unused)), struct ar
 }
 
 static int _extents_arg(struct cmd_context *cmd __attribute__((unused)),
-		        struct arg_values *av)
+			struct arg_values *av)
 {
 	char *ptr;
 
@@ -1237,7 +1237,7 @@ static const struct command_function *_find_command_id_function(int command_enum
 	return NULL;
 }
 
-int lvm_register_commands(char *name)
+int lvm_register_commands(const char *run_name)
 {
 	int i;
 
@@ -1251,7 +1251,7 @@ int lvm_register_commands(char *name)
 	 * populate commands[] array with command definitions
 	 * by parsing command-lines.in/command-lines-input.h
 	 */
-	if (!define_commands(name)) {
+	if (!define_commands(run_name)) {
 		log_error(INTERNAL_ERROR "Failed to parse command definitions.");
 		return 0;
 	}
@@ -1510,12 +1510,12 @@ static struct command *_find_command(struct cmd_context *cmd, const char *path,
 		if (arg_is_set(cmd, help_ARG) || arg_is_set(cmd, help2_ARG) || arg_is_set(cmd, longhelp_ARG) || arg_is_set(cmd, version_ARG))
 			return &commands[i];
 
-		match_required = 0;    /* required parameters that match */
-		match_ro = 0;          /* required opt_args that match */
-		match_rp = 0;          /* required pos_args that match */
-		match_type = 0;        /* type arg matches */
-		match_unused = 0;      /* options set that are not accepted by command */
-		mismatch_required = 0; /* required parameters that do not match */
+		match_required = 0;	/* required parameters that match */
+		match_ro = 0;		/* required opt_args that match */
+		match_rp = 0;		/* required pos_args that match */
+		match_type = 0;		/* type arg matches */
+		match_unused = 0;	/* options set that are not accepted by command */
+		mismatch_required = 0;	/* required parameters that do not match */
 		temp_unused_count = 0;
 		memset(&temp_unused_options, 0, sizeof(temp_unused_options));
 
@@ -1807,7 +1807,7 @@ static int _usage(const char *name, int longhelp, int skip_notes)
 	 * Looks at all variants of each command name and figures out
 	 * which options are common to all variants (for compact output)
 	 */
-        factor_common_options();
+	factor_common_options();
 
 	log_print("%s - %s\n", name, cname->desc);
 
@@ -1974,14 +1974,10 @@ static int _process_command_line(struct cmd_context *cmd, int *argc, char ***arg
 	struct opt_name *a;
 	struct arg_values *av;
 	struct arg_value_group_list *current_group = NULL;
-	struct command_name *cname;
 	int arg_enum; /* e.g. foo_ARG */
 	int goval;    /* the number returned from getopt_long identifying what it found */
 	int i;
 
-	if (!(cname = find_command_name(cmd->name)))
-		return_0;
-
 	if (!(cmd->opt_arg_values = dm_pool_zalloc(cmd->mem, sizeof(*cmd->opt_arg_values) * ARG_COUNT))) {
 		log_fatal("Unable to allocate memory for command line arguments.");
 		return 0;
@@ -1992,8 +1988,9 @@ static int _process_command_line(struct cmd_context *cmd, int *argc, char ***arg
 	 * array (opts) to pass to the getopt_long() function.  IOW we generate
 	 * the arguments to pass to getopt_long() from the opt_names data.
 	 */
-	for (i = 0; i < cname->num_args; i++)
-		_add_getopt_arg(cname->valid_args[i], &ptr, &o);
+	if (cmd->cname)
+		for (i = 0; i < cmd->cname->num_args; i++)
+			_add_getopt_arg(cmd->cname->valid_args[i], &ptr, &o);
 
 	*ptr = '\0';
 	memset(o, 0, sizeof(*o));
@@ -2673,8 +2670,11 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 	if (!(cmd->cmd_line = _copy_command_line(cmd, argc, argv)))
 		return_ECMD_FAILED;
 
+	/* Look up command - will be NULL if not recognised */
+	cmd->cname = find_command_name(cmd->name);
+
 	if (!_process_command_line(cmd, &argc, &argv)) {
-		log_error("Command name not found.");
+		log_error("Error during parsing of command line.");
 		return EINVALID_CMD_LINE;
 	}
 
@@ -2688,10 +2688,9 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 
 	log_debug("Parsing: %s", cmd->cmd_line);
 
-	if (!(cmd->cname = find_command_name(cmd->name))) {
-		log_error("Command name not found.\n");
-		return EINVALID_CMD_LINE;
-	}
+	/* Having validated cmdline args, return if we didn't recognised the command */
+	if (!cmd->cname)
+		return ENO_SUCH_CMD;
 
 	if (!(cmd->command = _find_command(cmd, cmd->name, &argc, argv)))
 		return EINVALID_CMD_LINE;
@@ -3311,7 +3310,7 @@ int lvm2_main(int argc, char **argv)
 	int ret, alias = 0;
 	struct custom_fds custom_fds;
 	struct cmd_context *cmd;
-	char *name;
+	const char *run_name;
 
 	if (!argv)
 		return -1;
@@ -3351,26 +3350,25 @@ int lvm2_main(int argc, char **argv)
 	if (!(cmd = init_lvm(0, 0)))
 		return -1;
 
+	/* Store original argv location so we may customise it if we become a daemon */
 	cmd->argv = argv;
 
-	if (!alias && argc == 1)
-		name = NULL;
-	else if (alias)
-		name = (char *)dm_basename(argv[0]);
-	else
-		name = argv[1];
-
-	if (!lvm_register_commands(name)) {
-		ret = ECMD_FAILED;
-		goto out;
-	}
+	/*
+	 * If the invocation command name wasn't itself an alias, shift to the
+	 * first arg.  After this point, run_name holds one of:
+	 *   the LVM command name we want to run;
+	 *   the LVM script name (handled through ENO_SUCH_CMD below);
+	 *   NULL for a shell (if readline is enabled).
+	 */
+	if (!alias) {
+		argc--;
+		argv++;
+		run_name = argv[0];
+	} else
+		run_name = dm_basename(argv[0]);
 
 	if (_lvm1_fallback(cmd)) {
 		/* Attempt to run equivalent LVM1 tool instead */
-		if (!alias) {
-			argv++;
-			argc--;
-		}
 		if (!argc) {
 			log_error("Falling back to LVM1 tools, but no "
 				  "command specified.");
@@ -3381,8 +3379,14 @@ int lvm2_main(int argc, char **argv)
 		ret = ECMD_FAILED;
 		goto_out;
 	}
+
+	if (!lvm_register_commands(run_name)) {
+		ret = ECMD_FAILED;
+		goto out;
+	}
+
+	if (!alias && !argc) {
 #ifdef READLINE_SUPPORT
-	if (!alias && argc == 1) {
 		_nonroot_warning();
 		if (!_prepare_profiles(cmd)) {
 			ret = ECMD_FAILED;
@@ -3390,19 +3394,12 @@ int lvm2_main(int argc, char **argv)
 		}
 		ret = lvm_shell(cmd, &_cmdline);
 		goto out;
-	}
+#else
+		log_fatal("Please supply an LVM command.");
+		_display_help();
+		ret = EINVALID_CMD_LINE;
+		goto out;
 #endif
-
-	if (!alias) {
-		if (argc < 2) {
-			log_fatal("Please supply an LVM command.");
-			_display_help();
-			ret = EINVALID_CMD_LINE;
-			goto out;
-		}
-
-		argc--;
-		argv++;
 	}
 
 	_nonroot_warning();


