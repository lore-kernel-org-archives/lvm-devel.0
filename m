From: agk@sourceware.org <agk@sourceware.org>
Date: 14 Feb 2007 16:51:48 -0000
Subject: LVM2 ./WHATS_NEW tools/lvm-static.c tools/lvm. ...
Message-ID: <20070214165148.19768.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-02-14 16:51:48

Modified files:
	.              : WHATS_NEW 
	tools          : lvm-static.c lvm.c lvm2cmdline.h lvmcmdline.c 

Log message:
	Exclude readline support from lvm.static

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.575&r2=1.576
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvm-static.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvm.c.diff?cvsroot=lvm2&r1=1.101&r2=1.102
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvm2cmdline.h.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.40&r2=1.41

--- LVM2/WHATS_NEW	2007/02/14 15:18:30	1.575
+++ LVM2/WHATS_NEW	2007/02/14 16:51:47	1.576
@@ -1,5 +1,6 @@
 Version 2.02.23 - 
 ====================================
+  Exclude readline support from lvm.static.
   Fix a leak in a reporting error path (2.02.19).
 
 Version 2.02.22 - 13th February 2007
--- LVM2/tools/lvm-static.c	2005/02/18 18:58:31	1.1
+++ LVM2/tools/lvm-static.c	2007/02/14 16:51:48	1.2
@@ -19,3 +19,8 @@
 {
 	return lvm2_main(argc, argv, 1);
 }
+
+int lvm_shell(struct cmd_context *cmd, struct cmdline_context *cmdline)
+{
+	return 0;
+}
--- LVM2/tools/lvm.c	2005/02/18 18:57:48	1.101
+++ LVM2/tools/lvm.c	2007/02/14 16:51:48	1.102
@@ -13,9 +13,233 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
+#include "tools.h"
 #include "lvm2cmdline.h"
 
 int main(int argc, char **argv)
 {
 	return lvm2_main(argc, argv, 0);
 }
+
+#ifdef READLINE_SUPPORT
+
+#  include <readline/readline.h>
+#  include <readline/history.h>
+#  ifndef HAVE_RL_COMPLETION_MATCHES
+#    define rl_completion_matches(a, b) completion_matches((char *)a, b)
+#  endif
+
+static struct cmdline_context *_cmdline;
+
+/* List matching commands */
+static char *_list_cmds(const char *text, int state)
+{
+	static int i = 0;
+	static size_t len = 0;
+
+	/* Initialise if this is a new completion attempt */
+	if (!state) {
+		i = 0;
+		len = strlen(text);
+	}
+
+	while (i < _cmdline->num_commands)
+		if (!strncmp(text, _cmdline->commands[i++].name, len))
+			return strdup(_cmdline->commands[i - 1].name);
+
+	return NULL;
+}
+
+/* List matching arguments */
+static char *_list_args(const char *text, int state)
+{
+	static int match_no = 0;
+	static size_t len = 0;
+	static struct command *com;
+
+	/* Initialise if this is a new completion attempt */
+	if (!state) {
+		char *s = rl_line_buffer;
+		int j = 0;
+
+		match_no = 0;
+		com = NULL;
+		len = strlen(text);
+
+		/* Find start of first word in line buffer */
+		while (isspace(*s))
+			s++;
+
+		/* Look for word in list of commands */
+		for (j = 0; j < _cmdline->num_commands; j++) {
+			const char *p;
+			char *q = s;
+
+			p = _cmdline->commands[j].name;
+			while (*p == *q) {
+				p++;
+				q++;
+			}
+			if ((!*p) && *q == ' ') {
+				com = _cmdline->commands + j;
+				break;
+			}
+		}
+
+		if (!com)
+			return NULL;
+	}
+
+	/* Short form arguments */
+	if (len < 3) {
+		while (match_no < com->num_args) {
+			char s[3];
+			char c;
+			if (!(c = (_cmdline->the_args +
+				   com->valid_args[match_no++])->short_arg))
+				continue;
+
+			sprintf(s, "-%c", c);
+			if (!strncmp(text, s, len))
+				return strdup(s);
+		}
+	}
+
+	/* Long form arguments */
+	if (match_no < com->num_args)
+		match_no = com->num_args;
+
+	while (match_no - com->num_args < com->num_args) {
+		const char *l;
+		l = (_cmdline->the_args +
+		     com->valid_args[match_no++ - com->num_args])->long_arg;
+		if (*(l + 2) && !strncmp(text, l, len))
+			return strdup(l);
+	}
+
+	return NULL;
+}
+
+/* Custom completion function */
+static char **_completion(const char *text, int start_pos, int end_pos)
+{
+	char **match_list = NULL;
+	int p = 0;
+
+	while (isspace((int) *(rl_line_buffer + p)))
+		p++;
+
+	/* First word should be one of our commands */
+	if (start_pos == p)
+		match_list = rl_completion_matches(text, _list_cmds);
+
+	else if (*text == '-')
+		match_list = rl_completion_matches(text, _list_args);
+	/* else other args */
+
+	/* No further completion */
+	rl_attempted_completion_over = 1;
+	return match_list;
+}
+
+static int _hist_file(char *buffer, size_t size)
+{
+	char *e = getenv("HOME");
+
+	if (dm_snprintf(buffer, size, "%s/.lvm_history", e) < 0) {
+		log_error("$HOME/.lvm_history: path too long");
+		return 0;
+	}
+
+	return 1;
+}
+
+static void _read_history(struct cmd_context *cmd)
+{
+	char hist_file[PATH_MAX];
+
+	if (!_hist_file(hist_file, sizeof(hist_file)))
+		return;
+
+	if (read_history(hist_file))
+		log_very_verbose("Couldn't read history from %s.", hist_file);
+
+	stifle_history(find_config_tree_int(cmd, "shell/history_size",
+				       DEFAULT_MAX_HISTORY));
+
+}
+
+static void _write_history(void)
+{
+	char hist_file[PATH_MAX];
+
+	if (!_hist_file(hist_file, sizeof(hist_file)))
+		return;
+
+	if (write_history(hist_file))
+		log_very_verbose("Couldn't write history to %s.", hist_file);
+}
+
+int lvm_shell(struct cmd_context *cmd, struct cmdline_context *cmdline)
+{
+	int argc, ret;
+	char *input = NULL, *args[MAX_ARGS], **argv;
+
+	rl_readline_name = "lvm";
+	rl_attempted_completion_function = (CPPFunction *) _completion;
+
+	_read_history(cmd);
+
+	_cmdline = cmdline;
+
+	_cmdline->interactive = 1;
+	while (1) {
+		free(input);
+		input = readline("lvm> ");
+
+		/* EOF */
+		if (!input) {
+			printf("\n");
+			break;
+		}
+
+		/* empty line */
+		if (!*input)
+			continue;
+
+		add_history(input);
+
+		argv = args;
+
+		if (lvm_split(input, &argc, argv, MAX_ARGS) == MAX_ARGS) {
+			log_error("Too many arguments, sorry.");
+			continue;
+		}
+
+		if (!strcmp(argv[0], "lvm")) {
+			argv++;
+			argc--;
+		}
+
+		if (!argc)
+			continue;
+
+		if (!strcmp(argv[0], "quit") || !strcmp(argv[0], "exit")) {
+			remove_history(history_length - 1);
+			log_error("Exiting.");
+			break;
+		}
+
+		ret = lvm_run_command(cmd, argc, argv);
+		if (ret == ENO_SUCH_CMD)
+			log_error("No such command '%s'.  Try 'help'.",
+				  argv[0]);
+
+		_write_history();
+	}
+
+	free(input);
+	return 0;
+}
+
+#endif	/* READLINE_SUPPORT */
--- LVM2/tools/lvm2cmdline.h	2006/08/18 21:17:18	1.4
+++ LVM2/tools/lvm2cmdline.h	2007/02/14 16:51:48	1.5
@@ -18,6 +18,14 @@
 
 struct cmd_context;
 
+struct cmdline_context {
+        struct arg *the_args;
+        struct command *commands;
+        int num_commands;
+        int commands_size;
+        int interactive;
+};
+
 int lvm2_main(int argc, char **argv, unsigned is_static);
 
 void *cmdlib_lvm2_init(unsigned is_static);
@@ -27,5 +35,6 @@
 void lvm_register_commands(void);
 int lvm_split(char *str, int *argc, char **argv, int max);
 int lvm_run_command(struct cmd_context *cmd, int argc, char **argv);
+int lvm_shell(struct cmd_context *cmd, struct cmdline_context *cmdline);
 
 #endif
--- LVM2/tools/lvmcmdline.c	2007/01/25 14:37:48	1.40
+++ LVM2/tools/lvmcmdline.c	2007/02/14 16:51:48	1.41
@@ -41,30 +41,16 @@
 #  define OPTIND_INIT 1
 #endif
 
-#ifdef READLINE_SUPPORT
-#  include <readline/readline.h>
-#  include <readline/history.h>
-#  ifndef HAVE_RL_COMPLETION_MATCHES
-#    define rl_completion_matches(a, b) completion_matches((char *)a, b)
-#  endif
-#endif
-
 /*
- * Exported table of valid switches
+ * Table of valid switches
  */
-struct arg the_args[ARG_COUNT + 1] = {
-
+static struct arg _the_args[ARG_COUNT + 1] = {
 #define arg(a, b, c, d) {b, "", "--" c, d, 0, NULL, 0, 0, INT64_C(0), UINT64_C(0), SIGN_NONE, PERCENT_NONE, NULL},
 #include "args.h"
 #undef arg
-
 };
 
-static int _array_size;
-static int _num_commands;
-static struct command *_commands;
-
-static int _interactive;
+static struct cmdline_context _cmdline;
 
 int yes_no_arg(struct cmd_context *cmd __attribute((unused)), struct arg *a)
 {
@@ -412,21 +398,21 @@
 
 static void __alloc(int size)
 {
-	if (!(_commands = dm_realloc(_commands, sizeof(*_commands) * size))) {
+	if (!(_cmdline.commands = dm_realloc(_cmdline.commands, sizeof(*_cmdline.commands) * size))) {
 		log_fatal("Couldn't allocate memory.");
 		exit(ECMD_FAILED);
 	}
 
-	_array_size = size;
+	_cmdline.commands_size = size;
 }
 
 static void _alloc_command(void)
 {
-	if (!_array_size)
+	if (!_cmdline.commands_size)
 		__alloc(32);
 
-	if (_array_size <= _num_commands)
-		__alloc(2 * _array_size);
+	if (_cmdline.commands_size <= _cmdline.num_commands)
+		__alloc(2 * _cmdline.commands_size);
 }
 
 static void _create_new_command(const char *name, command_fn command,
@@ -437,7 +423,7 @@
 
 	_alloc_command();
 
-	nc = _commands + _num_commands++;
+	nc = _cmdline.commands + _cmdline.num_commands++;
 
 	nc->name = name;
 	nc->desc = desc;
@@ -495,17 +481,17 @@
 	namebase = strdup(name);
 	base = basename(namebase);
 
-	for (i = 0; i < _num_commands; i++) {
-		if (!strcmp(base, _commands[i].name))
+	for (i = 0; i < _cmdline.num_commands; i++) {
+		if (!strcmp(base, _cmdline.commands[i].name))
 			break;
 	}
 
 	free(namebase);
 
-	if (i >= _num_commands)
+	if (i >= _cmdline.num_commands)
 		return 0;
 
-	return _commands + i;
+	return _cmdline.commands + i;
 }
 
 static void _usage(const char *name)
@@ -527,7 +513,7 @@
  */
 static void _add_getopt_arg(int arg, char **ptr, struct option **o)
 {
-	struct arg *a = the_args + arg;
+	struct arg *a = _cmdline.the_args + arg;
 
 	if (a->short_arg) {
 		*(*ptr)++ = a->short_arg;
@@ -556,12 +542,12 @@
 
 	for (i = 0; i < com->num_args; i++) {
 		arg = com->valid_args[i];
-		a = the_args + arg;
+		a = _cmdline.the_args + arg;
 
 		/*
 		 * opt should equal either the
 		 * short arg, or the index into
-		 * 'the_args'.
+		 * the_args.
 		 */
 		if ((a->short_arg && (opt == a->short_arg)) ||
 		    (!a->short_arg && (opt == arg)))
@@ -580,7 +566,7 @@
 	struct arg *a;
 
 	for (i = 0; i < ARG_COUNT; i++) {
-		a = the_args + i;
+		a = _cmdline.the_args + i;
 
 		/* zero the count and arg */
 		a->count = 0;
@@ -651,15 +637,15 @@
 
 	if (arg_count(cmd, oldarg) && arg_count(cmd, newarg)) {
 		log_error("%s and %s are synonyms.  Please only supply one.",
-			  the_args[oldarg].long_arg, the_args[newarg].long_arg);
+			  _cmdline.the_args[oldarg].long_arg, _cmdline.the_args[newarg].long_arg);
 		return 0;
 	}
 
 	if (!arg_count(cmd, oldarg))
 		return 1;
 
-	old = the_args + oldarg;
-	new = the_args + newarg;
+	old = _cmdline.the_args + oldarg;
+	new = _cmdline.the_args + newarg;
 
 	new->count = old->count;
 	new->value = old->value;
@@ -782,8 +768,8 @@
 	log_error("Use 'lvm help <command>' for more information");
 	log_error(" ");
 
-	for (i = 0; i < _num_commands; i++) {
-		struct command *com = _commands + i;
+	for (i = 0; i < _cmdline.num_commands; i++) {
+		struct command *com = _cmdline.commands + i;
 
 		log_error("%-16.16s%s", com->name, com->desc);
 	}
@@ -959,7 +945,7 @@
 	 */
 	dm_pool_empty(cmd->mem);
 
-	if (ret == EINVALID_CMD_LINE && !_interactive)
+	if (ret == EINVALID_CMD_LINE && !_cmdline.interactive)
 		_usage(cmd->command->name);
 
 	log_debug("Completed: %s", cmd->cmd_line);
@@ -1030,7 +1016,9 @@
 {
 	struct cmd_context *cmd;
 
-	if (!(cmd = create_toolcontext(&the_args[0], is_static, 0))) {
+	_cmdline.the_args = &_the_args[0];
+
+	if (!(cmd = create_toolcontext(_cmdline.the_args, is_static, 0))) {
 		stack;
 		return NULL;
 	}
@@ -1046,10 +1034,10 @@
 {
 	int i;
 
-	for (i = 0; i < _num_commands; i++)
-		dm_free(_commands[i].valid_args);
+	for (i = 0; i < _cmdline.num_commands; i++)
+		dm_free(_cmdline.commands[i].valid_args);
 
-	dm_free(_commands);
+	dm_free(_cmdline.commands);
 }
 
 void lvm_fin(struct cmd_context *cmd)
@@ -1106,218 +1094,6 @@
 	return ret;
 }
 
-#ifdef READLINE_SUPPORT
-/* List matching commands */
-static char *_list_cmds(const char *text, int state)
-{
-	static int i = 0;
-	static size_t len = 0;
-
-	/* Initialise if this is a new completion attempt */
-	if (!state) {
-		i = 0;
-		len = strlen(text);
-	}
-
-	while (i < _num_commands)
-		if (!strncmp(text, _commands[i++].name, len))
-			return strdup(_commands[i - 1].name);
-
-	return NULL;
-}
-
-/* List matching arguments */
-static char *_list_args(const char *text, int state)
-{
-	static int match_no = 0;
-	static size_t len = 0;
-	static struct command *com;
-
-	/* Initialise if this is a new completion attempt */
-	if (!state) {
-		char *s = rl_line_buffer;
-		int j = 0;
-
-		match_no = 0;
-		com = NULL;
-		len = strlen(text);
-
-		/* Find start of first word in line buffer */
-		while (isspace(*s))
-			s++;
-
-		/* Look for word in list of commands */
-		for (j = 0; j < _num_commands; j++) {
-			const char *p;
-			char *q = s;
-
-			p = _commands[j].name;
-			while (*p == *q) {
-				p++;
-				q++;
-			}
-			if ((!*p) && *q == ' ') {
-				com = _commands + j;
-				break;
-			}
-		}
-
-		if (!com)
-			return NULL;
-	}
-
-	/* Short form arguments */
-	if (len < 3) {
-		while (match_no < com->num_args) {
-			char s[3];
-			char c;
-			if (!(c = (the_args +
-				   com->valid_args[match_no++])->short_arg))
-				continue;
-
-			sprintf(s, "-%c", c);
-			if (!strncmp(text, s, len))
-				return strdup(s);
-		}
-	}
-
-	/* Long form arguments */
-	if (match_no < com->num_args)
-		match_no = com->num_args;
-
-	while (match_no - com->num_args < com->num_args) {
-		const char *l;
-		l = (the_args +
-		     com->valid_args[match_no++ - com->num_args])->long_arg;
-		if (*(l + 2) && !strncmp(text, l, len))
-			return strdup(l);
-	}
-
-	return NULL;
-}
-
-/* Custom completion function */
-static char **_completion(const char *text, int start_pos, int end_pos)
-{
-	char **match_list = NULL;
-	int p = 0;
-
-	while (isspace((int) *(rl_line_buffer + p)))
-		p++;
-
-	/* First word should be one of our commands */
-	if (start_pos == p)
-		match_list = rl_completion_matches(text, _list_cmds);
-
-	else if (*text == '-')
-		match_list = rl_completion_matches(text, _list_args);
-	/* else other args */
-
-	/* No further completion */
-	rl_attempted_completion_over = 1;
-	return match_list;
-}
-
-static int _hist_file(char *buffer, size_t size)
-{
-	char *e = getenv("HOME");
-
-	if (dm_snprintf(buffer, size, "%s/.lvm_history", e) < 0) {
-		log_error("$HOME/.lvm_history: path too long");
-		return 0;
-	}
-
-	return 1;
-}
-
-static void _read_history(struct cmd_context *cmd)
-{
-	char hist_file[PATH_MAX];
-
-	if (!_hist_file(hist_file, sizeof(hist_file)))
-		return;
-
-	if (read_history(hist_file))
-		log_very_verbose("Couldn't read history from %s.", hist_file);
-
-	stifle_history(find_config_tree_int(cmd, "shell/history_size",
-				       DEFAULT_MAX_HISTORY));
-
-}
-
-static void _write_history(void)
-{
-	char hist_file[PATH_MAX];
-
-	if (!_hist_file(hist_file, sizeof(hist_file)))
-		return;
-
-	if (write_history(hist_file))
-		log_very_verbose("Couldn't write history to %s.", hist_file);
-}
-
-static int _shell(struct cmd_context *cmd)
-{
-	int argc, ret;
-	char *input = NULL, *args[MAX_ARGS], **argv;
-
-	rl_readline_name = "lvm";
-	rl_attempted_completion_function = (CPPFunction *) _completion;
-
-	_read_history(cmd);
-
-	_interactive = 1;
-	while (1) {
-		free(input);
-		input = readline("lvm> ");
-
-		/* EOF */
-		if (!input) {
-			printf("\n");
-			break;
-		}
-
-		/* empty line */
-		if (!*input)
-			continue;
-
-		add_history(input);
-
-		argv = args;
-
-		if (lvm_split(input, &argc, argv, MAX_ARGS) == MAX_ARGS) {
-			log_error("Too many arguments, sorry.");
-			continue;
-		}
-
-		if (!strcmp(argv[0], "lvm")) {
-			argv++;
-			argc--;
-		}
-
-		if (!argc)
-			continue;
-
-		if (!strcmp(argv[0], "quit") || !strcmp(argv[0], "exit")) {
-			remove_history(history_length - 1);
-			log_error("Exiting.");
-			break;
-		}
-
-		ret = lvm_run_command(cmd, argc, argv);
-		if (ret == ENO_SUCH_CMD)
-			log_error("No such command '%s'.  Try 'help'.",
-				  argv[0]);
-
-		_write_history();
-	}
-
-	free(input);
-	return 0;
-}
-
-#endif
-
 /*
  * Determine whether we should fall back and exec the equivalent LVM1 tool
  */
@@ -1403,7 +1179,7 @@
 	}
 #ifdef READLINE_SUPPORT
 	if (!alias && argc == 1) {
-		ret = _shell(cmd);
+		ret = lvm_shell(cmd, &_cmdline);
 		goto out;
 	}
 #endif


