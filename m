From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 21 Feb 2017 18:28:14 +0000 (UTC)
Subject: master - commands: adjust default help output
Message-ID: <20170221182814.8D2BD6103B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=21fc35dd1bcd068ad4453e5c18b2d754bdcb12b0
Commit:        21fc35dd1bcd068ad4453e5c18b2d754bdcb12b0
Parent:        7e411b111f4d87a1f342a016299fe90c2d64ec2d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Feb 21 11:40:51 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Feb 21 12:27:51 2017 -0600

commands: adjust default help output

Remove the "usage notes" which should just
live in the man pages.

When there are 3 or more variants of a command,
print all the options produces a lot of output,
so require --longhelp to print all the options
in these cases.
---
 tools/command.c    |    7 ++++-
 tools/command.h    |    3 +-
 tools/lvmcmdline.c |   54 +++++++++++++++------------------------------------
 3 files changed, 23 insertions(+), 41 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index fe8c1f6..c425fd1 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -1229,7 +1229,7 @@ static int is_lvm_all_opt(int opt)
 
 /* Find common options for all variants of each command name. */
 
-static void factor_common_options(void)
+void factor_common_options(void)
 {
 	int cn, opt_enum, ci, oo, ro, found;
 	struct command *cmd;
@@ -1602,7 +1602,7 @@ static void print_usage_def(struct arg_def *def)
 		printf(" ...");
 }
 
-void print_usage(struct command *cmd)
+void print_usage(struct command *cmd, int longhelp)
 {
 	struct command_name *cname = find_command_name(cmd->name);
 	int onereq = (cmd->cmd_flags & CMD_FLAG_ONE_REQUIRED_OPT) ? 1 : 0;
@@ -1652,6 +1652,9 @@ void print_usage(struct command *cmd)
 		}
 	}
 
+	if (!longhelp)
+		goto done;
+
 	if (!cmd->oo_count)
 		goto op_count;
 
diff --git a/tools/command.h b/tools/command.h
index 2d8f628..51c4551 100644
--- a/tools/command.h
+++ b/tools/command.h
@@ -213,7 +213,8 @@ struct command {
 
 int define_commands(char *run_name);
 int command_id_to_enum(const char *str);
-void print_usage(struct command *cmd);
+void print_usage(struct command *cmd, int longhelp);
 void print_usage_common(struct command_name *cname, struct command *cmd);
+void factor_common_options(void);
 
 #endif
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 9fa8d94..ecb5802 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1564,7 +1564,7 @@ static struct command *_find_command(struct cmd_context *cmd, const char *path,
 		log_error("Run '%s --help' for more information.", name);
 		if (close_ro) {
 			log_warn("Closest command usage is:");
-			print_usage(&_cmdline.commands[close_i]);
+			print_usage(&_cmdline.commands[close_i], 0);
 		}
 		return NULL;
 	}
@@ -1677,39 +1677,6 @@ static void _short_usage(const char *name)
 	log_error("Run `%s --help' for more information.", name);
 }
 
-static void _usage_notes(void)
-{
-	/*
-	 * Excluding commonly understood syntax style like the meanings of:
-	 * [ ] for optional, ... for repeatable, | for one of the following,
-	 * -- for an option name, lower case strings and digits for literals.
-	 */
-	log_print("Usage notes:\n"
-		  ". Variable parameters are: Number, String, PV, VG, LV, Tag.\n"
-		  ". Select indicates that a required positional parameter can\n"
-		  "  be omitted if the --select option is used.\n"
-		  ". --size Number can be replaced with --extents NumberExtents.\n"
-		  ". When --name is omitted from lvcreate, a new LV name is\n"
-		  "  generated with the \"lvol\" prefix and a unique numeric suffix.\n"
-		  ". The required VG parameter in lvcreate may be omitted when\n"
-		  "  the VG name is included in another option, e.g. --name VG/LV.\n"
-		  ". For required options listed in parentheses, e.g. (--A, --B),\n"
-		  "  any one is required, after which the others are optional.\n"
-		  ". The _new suffix indicates the VG or LV must not yet exist.\n"
-		  ". LV followed by _<type> indicates that an LV of the given type\n"
-		  "  is required.  (raid represents any raid<N> type.)\n"
-		  ". Input units are always treated as base two values, regardless of\n"
-		  "  unit capitalization, e.g. 'k' and 'K' both refer to 1024.\n"
-		  ". The default input unit is specified by letter, followed by |unit\n"
-		  "  which represents other possible input units: bBsSkKmMgGtTpPeE.\n"
-		  ". Output units can be specified with the --units option, for which\n"
-		  "  lower/upper case letters refer to base 2/10 values.\n"
-		  "  formats that are recognized, e.g. for compatibility.\n"
-		  ". See man pages for short option equivalents of long option names,\n"
-		  "  and for more detailed descriptions of variable parameters.\n"
-		  "  \n");
-}
-
 static int _usage(const char *name, int longhelp)
 {
 	struct command_name *cname = find_command_name(name);
@@ -1721,8 +1688,19 @@ static int _usage(const char *name, int longhelp)
 		return 0;
 	}
 
+	/*
+	 * Looks at all variants of each command name and figures out
+	 * which options are common to all variants (for compact output)
+	 */
+        factor_common_options();
+
 	log_print("%s - %s\n", name, cname->desc);
 
+	/* Reduce the default output when there are several variants. */
+
+	if (cname->variants < 3)
+		longhelp = 1;
+
 	for (i = 0; i < COMMAND_COUNT; i++) {
 		if (strcmp(_cmdline.commands[i].name, name))
 			continue;
@@ -1733,15 +1711,15 @@ static int _usage(const char *name, int longhelp)
 		if ((_cmdline.commands[i].cmd_flags & CMD_FLAG_SECONDARY_SYNTAX) && !longhelp)
 			continue;
 
-		print_usage(&_cmdline.commands[i]);
+		print_usage(&_cmdline.commands[i], longhelp);
 		cmd = &_cmdline.commands[i];
 	}
 
 	/* Common options are printed once for all variants of a command name. */
-	print_usage_common(cname, cmd);
-
 	if (longhelp)
-		_usage_notes();
+		print_usage_common(cname, cmd);
+	else
+		log_print("Use --longhelp to show all options.");
 
 	return 1;
 }


