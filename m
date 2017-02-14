From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 14 Feb 2017 15:52:16 +0000 (UTC)
Subject: master - commands: improve help/usage output
Message-ID: <20170214155216.3596860E93@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f46b28bdb6f8c0f7bae7a8b4fb4b886332831318
Commit:        f46b28bdb6f8c0f7bae7a8b4fb4b886332831318
Parent:        c868562a7968db9b0d00df9b1d0a8967a9aacaa3
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Feb 14 09:49:26 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Feb 14 09:52:09 2017 -0600

commands: improve help/usage output

Replace --help --help with --long-help.
Some blank lines were needed.
Add 'lvm help all' to print help for all commands.
---
 tools/args.h           |    7 +++-
 tools/command-lines.in |    2 +-
 tools/command.c        |    5 ++-
 tools/lvmcmdline.c     |   95 ++++++++++++++++++++++++++++--------------------
 4 files changed, 64 insertions(+), 45 deletions(-)

diff --git a/tools/args.h b/tools/args.h
index b33df9a..f64b126 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -244,6 +244,9 @@ arg(locktype_ARG, '\0', "locktype", locktype_VAL, 0, 0,
 arg(logonly_ARG, '\0', "logonly", 0, 0, 0,
     "Suppress command report and display only log report.\n")
 
+arg(longhelp_ARG, '\0', "longhelp", 0, 0, 0,
+    "Display long help text.\n")
+
 arg(maxrecoveryrate_ARG, '\0', "maxrecoveryrate", sizekb_VAL, 0, 0,
     "Sets the maximum recovery rate for a RAID LV.  The rate value\n"
     "is an amount of data per second for each device in the array.\n"
@@ -920,8 +923,8 @@ arg(force_ARG, 'f', "force", 0, ARG_COUNTABLE, 0,
 /* Not used. */
 arg(full_ARG, 'f', "full", 0, 0, 0, NULL)
 
-arg(help_ARG, 'h', "help", 0, ARG_COUNTABLE, 0,
-    "Display help text. Repeat this option for more information.\n")
+arg(help_ARG, 'h', "help", 0, 0, 0,
+    "Display help text.\n")
 
 arg(cache_ARG, 'H', "cache", 0, 0, 0,
     "Specifies the command is handling a cache LV or cache pool.\n"
diff --git a/tools/command-lines.in b/tools/command-lines.in
index 2eddd41..b6aa1d1 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -187,7 +187,7 @@
 # OO_ALL is included in every command automatically.
 #
 OO_ALL: --commandprofile String, --config String, --debug,
---driverloaded Bool, --help, --profile String, --quiet,
+--driverloaded Bool, --help, --longhelp, --profile String, --quiet,
 --verbose, --version, --yes, --test
 
 #
diff --git a/tools/command.c b/tools/command.c
index 0ff5cd7..a968bed 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -1640,7 +1640,7 @@ void print_usage(struct command *cmd)
 
 	printf(" ]");
  done:
-	printf("\n");
+	printf("\n\n");
 	return;
 }
 
@@ -1704,7 +1704,8 @@ void print_usage_common(struct command_name *cname, struct command *cmd)
 		}
 	}
 
-	printf(" ]\n");
+	printf(" ]");
+	printf("\n\n");
 }
 
 #ifdef MAN_PAGE_GENERATOR
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 43278ff..494f01f 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1384,7 +1384,7 @@ static struct command *_find_command(struct cmd_context *cmd, const char *path,
 			continue;
 
 		/* For help and version just return the first entry with matching name. */
-		if (arg_is_set(cmd, help_ARG) || arg_is_set(cmd, help2_ARG) || arg_is_set(cmd, version_ARG))
+		if (arg_is_set(cmd, help_ARG) || arg_is_set(cmd, help2_ARG) || arg_is_set(cmd, longhelp_ARG) || arg_is_set(cmd, version_ARG))
 			return &commands[i];
 
 		match_required = 0;    /* required parameters that match */
@@ -1661,7 +1661,40 @@ static void _short_usage(const char *name)
 	log_error("Run `%s --help' for more information.", name);
 }
 
-static int _usage(const char *name, int help_count)
+static void _usage_notes(void)
+{
+	/*
+	 * Excluding commonly understood syntax style like the meanings of:
+	 * [ ] for optional, ... for repeatable, | for one of the following,
+	 * -- for an option name, lower case strings and digits for literals.
+	 */
+	log_print("Usage notes:");
+	log_print(". Variable parameters are: Number, String, PV, VG, LV, Tag.");
+	log_print(". Select indicates that a required positional parameter can");
+	log_print("  be omitted if the --select option is used.");
+	log_print(". --size Number can be replaced with --extents NumberExtents.");
+	log_print(". When --name is omitted from lvcreate, a new LV name is");
+	log_print("  generated with the \"lvol\" prefix and a unique numeric suffix.");
+	log_print(". The required VG parameter in lvcreate may be omitted when");
+	log_print("  the VG name is included in another option, e.g. --name VG/LV.");
+	log_print(". For required options listed in parentheses, e.g. (--A, --B),");
+	log_print("  any one is required, after which the others are optional.");
+	log_print(". The _new suffix indicates the VG or LV must not yet exist.");
+	log_print(". LV followed by _<type> indicates that an LV of the given type");
+	log_print("  is required.  (raid represents any raid<N> type.)");
+	log_print(". Input units are always treated as base two values, regardless of");
+	log_print("  unit capitalization, e.g. 'k' and 'K' both refer to 1024.");
+	log_print(". The default input unit is specified by letter, followed by |unit");
+	log_print("  which represents other possible input units: bBsSkKmMgGtTpPeE.");
+	log_print(". Output units can be specified with the --units option, for which");
+	log_print("  lower/upper case letters refer to base 2/10 values.");
+	log_print("  formats that are recognized, e.g. for compatibility.");
+	log_print(". See man pages for short option equivalents of long option names,");
+	log_print("  and for more detailed descriptions of variable parameters.");
+	log_print(" ");
+}
+
+static int _usage(const char *name, int longhelp)
 {
 	struct command_name *cname = find_command_name(name);
 	struct command *cmd;
@@ -1678,52 +1711,33 @@ static int _usage(const char *name, int help_count)
 		if (strcmp(_cmdline.commands[i].name, name))
 			continue;
 
-		if ((_cmdline.commands[i].cmd_flags & CMD_FLAG_SECONDARY_SYNTAX) && (help_count < 3))
+		if ((_cmdline.commands[i].cmd_flags & CMD_FLAG_SECONDARY_SYNTAX) && !longhelp)
 			continue;
 
 		print_usage(&_cmdline.commands[i]);
 		cmd = &_cmdline.commands[i];
-		printf("\n");
 	}
 
 	/* Common options are printed once for all variants of a command name. */
 	print_usage_common(cname, cmd);
 
-	if (help_count > 1) {
-		/*
-		 * Excluding commonly understood syntax style like the meanings of:
-		 * [ ] for optional, ... for repeatable, | for one of the following,
-		 * -- for an option name, lower case strings and digits for literals.
-		 */
-		log_print("Usage notes:");
-		log_print(". Variable parameters are: Number, String, PV, VG, LV, Tag.");
-		log_print(". Select indicates that a required positional parameter can");
-		log_print("  be omitted if the --select option is used.");
-		log_print(". --size Number can be replaced with --extents NumberExtents.");
-		log_print(". When --name is omitted from lvcreate, a new LV name is");
-		log_print("  generated with the \"lvol\" prefix and a unique numeric suffix.");
-		log_print(". The required VG parameter in lvcreate may be omitted when");
-		log_print("  the VG name is included in another option, e.g. --name VG/LV.");
-		log_print(". For required options listed in parentheses, e.g. (--A, --B),");
-		log_print("  any one is required, after which the others are optional.");
-		log_print(". The _new suffix indicates the VG or LV must not yet exist.");
-		log_print(". LV followed by _<type> indicates that an LV of the given type");
-		log_print("  is required.  (raid represents any raid<N> type.)");
-		log_print(". Input units are always treated as base two values, regardless of");
-		log_print("  unit capitalization, e.g. 'k' and 'K' both refer to 1024.");
-		log_print(". The default input unit is specified by letter, followed by |unit");
-		log_print("  which represents other possible input units: bBsSkKmMgGtTpPeE.");
-		log_print(". Output units can be specified with the --units option, for which");
-		log_print("  lower/upper case letters refer to base 2/10 values.");
-		log_print(". Use --help --help --help to print secondary command syntax");
-		log_print("  formats that are recognized, e.g. for compatibility.");
-		log_print(". See man pages for short option equivalents of long option names,");
-		log_print("  and for more detailed descriptions of variable parameters.");
-	}
+	if (longhelp)
+		_usage_notes();
 
 	return 1;
 }
 
+static void _usage_all(void)
+{
+	int i;
+
+	for (i = 0; i < MAX_COMMAND_NAMES; i++) {
+		if (!command_names[i].name)
+			break;
+		_usage(command_names[i].name, 0);
+	}
+}
+
 /*
  * Sets up the arguments to pass to getopt_long().
  *
@@ -2158,11 +2172,10 @@ static int _get_settings(struct cmd_context *cmd)
 
 static int _process_common_commands(struct cmd_context *cmd)
 {
-	if (arg_is_set(cmd, help_ARG) || arg_is_set(cmd, help2_ARG)) {
-		_usage(cmd->name, arg_count(cmd, help_ARG));
-
-		if (arg_count(cmd, help_ARG) < 2)
-			log_print("(Use --help --help for usage notes.)");
+	if (arg_is_set(cmd, help_ARG) ||
+	    arg_is_set(cmd, longhelp_ARG) ||
+	    arg_is_set(cmd, help2_ARG)) {
+		_usage(cmd->name, arg_is_set(cmd, longhelp_ARG));
 		return ECMD_PROCESSED;
 	}
 
@@ -2195,6 +2208,8 @@ int help(struct cmd_context *cmd __attribute__((unused)), int argc, char **argv)
 
 	if (!argc)
 		_display_help();
+	else if (argc == 1 && !strcmp(argv[0], "all"))
+		_usage_all();
 	else {
 		int i;
 		for (i = 0; i < argc; i++)


