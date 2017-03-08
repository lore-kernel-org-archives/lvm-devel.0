From: David Teigland <teigland@sourceware.org>
Date: Wed, 8 Mar 2017 12:04:47 -0500
Subject: master - commands: combine duplicate arrays for opt and val
Message-ID: <201703081704.v28H4hcM031155@int-mx09.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=690f60473352e9909df95fae96a5d99b8b0c9db7
Commit:        690f60473352e9909df95fae96a5d99b8b0c9db7
Parent:        f48e6b2690c43120ec87e4fa913b2bd952a53511
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Mar 7 11:47:44 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Mar 8 11:03:02 2017 -0600

commands: combine duplicate arrays for opt and val

command.c and lvmcmdline.c each had a full array defining
all options and values.  This duplication was not removed
when the command.c code was merged into the run time.
---
 tools/command.c     |   25 -------------------
 tools/command.h     |   24 ++++++++++++++++++
 tools/lvm.c         |    8 +++---
 tools/lvm2cmdline.h |    2 +-
 tools/lvmcmdline.c  |   66 ++++++++++++++++++++++----------------------------
 tools/tools.h       |   20 ---------------
 tools/vals.h        |    2 +-
 7 files changed, 59 insertions(+), 88 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index d184208..71056bf 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -167,31 +167,6 @@ enum {
 #include "command.h"       /* defines struct command */
 #include "command-count.h" /* defines COMMAND_COUNT */
 
-
-/* see opt_names[] below, also see arg_props[] in tools.h and args.h */
-
-struct opt_name {
-	const char *name;       /* "foo_ARG" */
-	int opt_enum;           /* foo_ARG */
-	const char short_opt;   /* -f */
-	char _padding[7];
-	const char *long_opt;   /* --foo */
-	int val_enum;           /* xyz_VAL when --foo takes a val like "--foo xyz" */
-	uint32_t flags;
-	uint32_t prio;
-	const char *desc;
-};
-
-/* see val_names[] below, also see val_props[] in tools.h and vals.h */
-
-struct val_name {
-	const char *enum_name;  /* "foo_VAL" */
-	int val_enum;           /* foo_VAL */
-	int (*fn) (struct cmd_context *cmd, struct arg_values *av); /* foo_arg() */
-	const char *name;       /* FooVal */
-	const char *usage;
-};
-
 /* see lvp_names[] below, also see lv_props[] in tools.h and lv_props.h */
 
 struct lvp_name {
diff --git a/tools/command.h b/tools/command.h
index 2e4dba3..7652d74 100644
--- a/tools/command.h
+++ b/tools/command.h
@@ -211,6 +211,30 @@ struct command {
 	int pos_count; /* temp counter used by create-command */
 };
 
+/* see global opt_names[] */
+
+struct opt_name {
+	const char *name;       /* "foo_ARG" */
+	int opt_enum;           /* foo_ARG */
+	const char short_opt;   /* -f */
+	char _padding[7];
+	const char *long_opt;   /* --foo */
+	int val_enum;           /* xyz_VAL when --foo takes a val like "--foo xyz" */
+	uint32_t flags;
+	uint32_t prio;
+	const char *desc;
+};
+
+/* see global val_names[] */
+
+struct val_name {
+	const char *enum_name;  /* "foo_VAL" */
+	int val_enum;           /* foo_VAL */
+	int (*fn) (struct cmd_context *cmd, struct arg_values *av); /* foo_arg() */
+	const char *name;       /* FooVal */
+	const char *usage;
+};
+
 int define_commands(char *run_name);
 int command_id_to_enum(const char *str);
 void print_usage(struct command *cmd, int longhelp, int desc_first);
diff --git a/tools/lvm.c b/tools/lvm.c
index 5fd9918..0554007 100644
--- a/tools/lvm.c
+++ b/tools/lvm.c
@@ -97,8 +97,8 @@ static char *_list_args(const char *text, int state)
 		while (match_no < cname->num_args) {
 			char s[3];
 			char c;
-			if (!(c = (_cmdline->arg_props +
-				   cname->valid_args[match_no++])->short_arg))
+			if (!(c = (_cmdline->opt_names +
+				   cname->valid_args[match_no++])->short_opt))
 				continue;
 
 			sprintf(s, "-%c", c);
@@ -113,8 +113,8 @@ static char *_list_args(const char *text, int state)
 
 	while (match_no - cname->num_args < cname->num_args) {
 		const char *l;
-		l = (_cmdline->arg_props +
-		     cname->valid_args[match_no++ - cname->num_args])->long_arg;
+		l = (_cmdline->opt_names +
+		     cname->valid_args[match_no++ - cname->num_args])->long_opt;
 		if (*(l + 2) && !strncmp(text, l, len))
 			return strdup(l);
 	}
diff --git a/tools/lvm2cmdline.h b/tools/lvm2cmdline.h
index 5c5eaee..7353c7a 100644
--- a/tools/lvm2cmdline.h
+++ b/tools/lvm2cmdline.h
@@ -19,7 +19,7 @@
 struct cmd_context;
 
 struct cmdline_context {
-	struct arg_props *arg_props;
+	struct opt_name *opt_names;
 	struct command *commands;
 	int num_commands;
 	struct command_name *command_names;
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index ad638af..404641f 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -53,20 +53,12 @@ extern char *optarg;
 /*
  * Table of valid --option values.
  */
-static struct val_props _val_props[VAL_COUNT + 1] = {
-#define val(a, b, c, d) {a, b, c, d},
-#include "vals.h"
-#undef val
-};
+extern struct val_name val_names[VAL_COUNT + 1];
 
 /*
  * Table of valid --option's
  */
-static struct arg_props _arg_props[ARG_COUNT + 1] = {
-#define arg(a, b, c, d, e, f, g) {a, b, "", "--" c, d, e, f, g},
-#include "args.h"
-#undef arg
-};
+extern struct opt_name opt_names[ARG_COUNT + 1];
 
 /*
  * Table of LV properties
@@ -277,7 +269,7 @@ unsigned grouped_arg_is_set(const struct arg_values *av, int a)
 
 const char *arg_long_option_name(int a)
 {
-	return _cmdline.arg_props[a].long_arg;
+	return _cmdline.opt_names[a].long_opt;
 }
 
 const char *arg_value(const struct cmd_context *cmd, int a)
@@ -316,7 +308,7 @@ int32_t first_grouped_arg_int_value(const struct cmd_context *cmd, int a, const
 
 int32_t arg_int_value(const struct cmd_context *cmd, int a, const int32_t def)
 {
-	return (_cmdline.arg_props[a].flags & ARG_GROUPABLE) ?
+	return (_cmdline.opt_names[a].flags & ARG_GROUPABLE) ?
 		first_grouped_arg_int_value(cmd, a, def) : (arg_is_set(cmd, a) ? cmd->opt_arg_values[a].i_value : def);
 }
 
@@ -1088,7 +1080,7 @@ static void _set_valid_args_for_command_name(int ci)
 
 	for (i = 0; i < ARG_COUNT; i++) {
 		if (all_args[i]) {
-			opt_enum = _cmdline.arg_props[i].arg_enum;
+			opt_enum = _cmdline.opt_names[i].opt_enum;
 
 			command_names[ci].valid_args[num_args] = opt_enum;
 			num_args++;
@@ -1789,12 +1781,12 @@ static void _usage_all(void)
  * can't have more than 'a' long arguments.
  */
 
-static void _add_getopt_arg(int arg_enum, char **optstrp, struct option **longoptsp)
+static void _add_getopt_arg(int opt_enum, char **optstrp, struct option **longoptsp)
 {
-	struct arg_props *a = _cmdline.arg_props + arg_enum;
+	struct opt_name *a = _cmdline.opt_names + opt_enum;
 
-	if (a->short_arg) {
-		*(*optstrp)++ = a->short_arg;
+	if (a->short_opt) {
+		*(*optstrp)++ = a->short_opt;
 
 		if (a->val_enum)
 			*(*optstrp)++ = ':';
@@ -1802,8 +1794,8 @@ static void _add_getopt_arg(int arg_enum, char **optstrp, struct option **longop
 #ifdef HAVE_GETOPTLONG
 	/* long_arg is "--foo", so +2 is the offset of the name after "--" */
 
-	if (*(a->long_arg + 2)) {
-		(*longoptsp)->name = a->long_arg + 2;
+	if (*(a->long_opt + 2)) {
+		(*longoptsp)->name = a->long_opt + 2;
 		(*longoptsp)->has_arg = a->val_enum ? 1 : 0;
 		(*longoptsp)->flag = NULL;
 
@@ -1820,10 +1812,10 @@ static void _add_getopt_arg(int arg_enum, char **optstrp, struct option **longop
 		 * (11 is the enum value for --cachepool, so 11+128)
 		 */
 
-		if (a->short_arg)
-			(*longoptsp)->val = a->short_arg;
+		if (a->short_opt)
+			(*longoptsp)->val = a->short_opt;
 		else
-			(*longoptsp)->val = arg_enum + 128;
+			(*longoptsp)->val = opt_enum + 128;
 		(*longoptsp)++;
 	}
 #endif
@@ -1856,14 +1848,14 @@ static int _find_arg(const char *cmd_name, int goval)
 	for (i = 0; i < cname->num_args; i++) {
 		arg_enum = cname->valid_args[i];
 
-		/* assert arg_enum == _cmdline.arg_props[arg_enum].arg_enum */
+		/* assert arg_enum == _cmdline.opt_names[arg_enum].arg_enum */
 
 		/* the value returned by getopt matches the ascii value of single letter option */
-		if (_cmdline.arg_props[arg_enum].short_arg && (goval == _cmdline.arg_props[arg_enum].short_arg))
+		if (_cmdline.opt_names[arg_enum].short_opt && (goval == _cmdline.opt_names[arg_enum].short_opt))
 			return arg_enum;
 
 		/* the value returned by getopt matches the enum value plus 128 */
-		if (!_cmdline.arg_props[arg_enum].short_arg && (goval == (arg_enum + 128)))
+		if (!_cmdline.opt_names[arg_enum].short_opt && (goval == (arg_enum + 128)))
 			return arg_enum;
 	}
 
@@ -1874,7 +1866,7 @@ static int _process_command_line(struct cmd_context *cmd, int *argc, char ***arg
 {
 	char str[((ARG_COUNT + 1) * 2) + 1], *ptr = str;
 	struct option opts[ARG_COUNT + 1], *o = opts;
-	struct arg_props *a;
+	struct opt_name *a;
 	struct arg_values *av;
 	struct arg_value_group_list *current_group = NULL;
 	struct command_name *cname;
@@ -1893,7 +1885,7 @@ static int _process_command_line(struct cmd_context *cmd, int *argc, char ***arg
 	/*
 	 * create the short-form character array (str) and the long-form option
 	 * array (opts) to pass to the getopt_long() function.  IOW we generate
-	 * the arguments to pass to getopt_long() from the args.h/arg_props data.
+	 * the arguments to pass to getopt_long() from the opt_names data.
 	 */
 	for (i = 0; i < cname->num_args; i++)
 		_add_getopt_arg(cname->valid_args[i], &ptr, &o);
@@ -1917,7 +1909,7 @@ static int _process_command_line(struct cmd_context *cmd, int *argc, char ***arg
 			return 0;
 		}
 
-		a = _cmdline.arg_props + arg_enum;
+		a = _cmdline.opt_names + arg_enum;
 
 		av = &cmd->opt_arg_values[arg_enum];
 
@@ -1947,10 +1939,10 @@ static int _process_command_line(struct cmd_context *cmd, int *argc, char ***arg
 
 		if (av->count && !(a->flags & ARG_COUNTABLE)) {
 			log_error("Option%s%c%s%s may not be repeated.",
-				  a->short_arg ? " -" : "",
-				  a->short_arg ? : ' ',
-				  (a->short_arg && a->long_arg) ?
-				  "/" : "", a->long_arg ? : "");
+				  a->short_opt ? " -" : "",
+				  a->short_opt ? : ' ',
+				  (a->short_opt && a->long_opt) ?
+				  "/" : "", a->long_opt ? : "");
 			return 0;
 		}
 
@@ -1962,8 +1954,8 @@ static int _process_command_line(struct cmd_context *cmd, int *argc, char ***arg
 
 			av->value = optarg;
 
-			if (!_val_props[a->val_enum].fn(cmd, av)) {
-				log_error("Invalid argument for %s: %s", a->long_arg, optarg);
+			if (!val_names[a->val_enum].fn(cmd, av)) {
+				log_error("Invalid argument for %s: %s", a->long_opt, optarg);
 				return 0;
 			}
 		}
@@ -1997,12 +1989,12 @@ static int _merge_synonym(struct cmd_context *cmd, int oldarg, int newarg)
 
 	if (arg_is_set(cmd, oldarg) && arg_is_set(cmd, newarg)) {
 		log_error("%s and %s are synonyms.  Please only supply one.",
-			  _cmdline.arg_props[oldarg].long_arg, _cmdline.arg_props[newarg].long_arg);
+			  _cmdline.opt_names[oldarg].long_opt, _cmdline.opt_names[newarg].long_opt);
 		return 0;
 	}
 
 	/* Not groupable? */
-	if (!(_cmdline.arg_props[oldarg].flags & ARG_GROUPABLE)) {
+	if (!(_cmdline.opt_names[oldarg].flags & ARG_GROUPABLE)) {
 		if (arg_is_set(cmd, oldarg))
 			_copy_arg_values(cmd->opt_arg_values, oldarg, newarg);
 		return 1;
@@ -3085,7 +3077,7 @@ struct cmd_context *init_lvm(unsigned set_connections, unsigned set_filters)
 		return_NULL;
 	}
 
-	_cmdline.arg_props = &_arg_props[0];
+	_cmdline.opt_names = &opt_names[0];
 
 	if (stored_errno()) {
 		destroy_toolcontext(cmd);
diff --git a/tools/tools.h b/tools/tools.h
index f2c926f..cb3ffa0 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -108,32 +108,12 @@ struct arg_values {
 /*	void *ptr; // Currently not used. */
 };
 
-/* a global table of possible --option's */
-struct arg_props {
-	int arg_enum; /* foo_ARG from args.h */
-	const char short_arg;
-	char _padding[7];
-	const char *long_arg;
-	int val_enum; /* foo_VAL from vals.h */
-	uint32_t flags;
-	uint32_t prio;
-	const char *desc;
-};
-
 struct arg_value_group_list {
         struct dm_list list;
         struct arg_values arg_values[0];
 	uint32_t prio;
 };
 
-/* a global table of possible --option values */
-struct val_props {
-	int val_enum; /* foo_VAL from vals.h */
-	int (*fn) (struct cmd_context *cmd, struct arg_values *av);
-	const char *name;
-	const char *usage;
-};
-
 /* a global table of possible LV properties */
 struct lv_props {
 	int lvp_enum; /* is_foo_LVP from lv_props.h */
diff --git a/tools/vals.h b/tools/vals.h
index ed572ee..4c70640 100644
--- a/tools/vals.h
+++ b/tools/vals.h
@@ -63,7 +63,7 @@
  * then also be added to the usage string for the val type here.
  * It would be nice if the accepted values could be defined in a
  * more consistent way, and perhaps in a single place, perhaps in
- * struct val_props.
+ * struct val_names.
  *
  * The usage text for an option is not always the full
  * set of words accepted for an option, but may be a


