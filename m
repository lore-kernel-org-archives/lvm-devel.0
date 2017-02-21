From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 21 Feb 2017 20:35:48 +0000 (UTC)
Subject: master - man/help: use separate common option lists
Message-ID: <20170221203548.C4BE460E31@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c1ce371b59257a236115d2d6a3cb24af17faf55d
Commit:        c1ce371b59257a236115d2d6a3cb24af17faf55d
Parent:        b7ae57c6a6fd69d23cc8c180920ddca372914419
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Feb 21 14:32:54 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Feb 21 14:32:54 2017 -0600

man/help: use separate common option lists

There are two kinds of common options:
1. options common to all variants of a given command name
2. options common to all lvm commands

Previously, both kinds of common options were listed together
under "Common options".  Now the first are printed under
"Common options for command" (when needed), and the second
are printed under "Common options for lvm" (always).
---
 tools/command-lines.in |   14 ----
 tools/command.c        |  193 ++++++++++++++++++++++++++++++++++++++----------
 tools/command.h        |    3 +-
 tools/lvmcmdline.c     |    7 +-
 4 files changed, 160 insertions(+), 57 deletions(-)

diff --git a/tools/command-lines.in b/tools/command-lines.in
index 606d2e7..348e7a4 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -191,20 +191,6 @@ OO_ALL: --commandprofile String, --config String, --debug,
 --verbose, --version, --yes, --test
 
 #
-# This list only applies to printing the usage text.
-# These common options are displayed once at the end of
-# a given command's usage.  This is done to avoid excessive
-# repetition of common options, which may obscure the more
-# interesting and relevant parts of a common prototype.
-# This definition is *only* used when generating the command
-# usage strings, and is the basis for the division between
-# the "usage" and "usage_common" strings. This OO defn does
-# not relate to which optional opts are accepted by commands,
-# which is defined by the OO line.
-#
-OO_USAGE_COMMON: OO_ALL, --force, --noudevsync
-
-#
 # options for pvs, lvs, vgs, fullreport
 #
 OO_REPORT: --aligned, --all, --binary, --configreport ConfigReport, --foreign,
diff --git a/tools/command.c b/tools/command.c
index e7596df..ed38740 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -1506,12 +1506,7 @@ int define_commands(char *run_name)
 			return 0;
 	}
 
-	/*
-	 * For usage.
-	 * Predefined string of options common to all commands
-	 * (for compact output)
-	 */
-	include_optional_opt_args(&lvm_all, "OO_USAGE_COMMON");
+	include_optional_opt_args(&lvm_all, "OO_ALL");
 
 	return 1;
 }
@@ -1665,12 +1660,23 @@ void print_usage(struct command *cmd, int longhelp)
 			opt_enum = cmd->optional_opt_args[oo].opt;
 
 			/*
-			 * Skip common opts in lvm_all and cname->common_options.
+			 * Skip common lvm options in lvm_all which
+			 * are printed at the end under "Common options for lvm"
+			 * see print_common_options_lvm()
 			 */
 
 			if (is_lvm_all_opt(opt_enum))
 				continue;
 
+			/*
+			 * When there is more than one variant,
+			 * skip common command options from
+			 * cname->common_options (options common
+			 * to all variants), which are printed at
+			 * the end under "Common options for command"
+			 * see print_common_options_cmd()
+			 */
+
 			if ((cname->variants > 1) && cname->common_options[opt_enum])
 				continue;
 
@@ -1716,11 +1722,35 @@ void print_usage(struct command *cmd, int longhelp)
 }
 
 
-void print_usage_common(struct command_name *cname, struct command *cmd)
+void print_usage_common_lvm(struct command_name *cname, struct command *cmd)
 {
 	int oo, opt_enum, first = 1;
 
-	printf("  Common options:");
+	printf("  Common options for lvm:");
+
+	for (oo = 0; oo < lvm_all.oo_count; oo++) {
+		opt_enum = lvm_all.optional_opt_args[oo].opt;
+
+		if (first)
+			printf("\n\t[");
+		else
+			printf("\n\t ");
+		first = 0;
+
+		printf(" %s", opt_names[opt_enum].long_opt);
+		if (lvm_all.optional_opt_args[oo].def.val_bits) {
+			printf(" ");
+			print_usage_def(&lvm_all.optional_opt_args[oo].def);
+		}
+	}
+
+	printf(" ]");
+	printf("\n\n");
+}
+
+void print_usage_common_cmd(struct command_name *cname, struct command *cmd)
+{
+	int oo, opt_enum, first = 1;
 
 	/*
 	 * when there's more than one variant, options that
@@ -1728,7 +1758,9 @@ void print_usage_common(struct command_name *cname, struct command *cmd)
 	 */
 
 	if (cname->variants < 2)
-		goto all;
+		return;
+
+	printf("  Common options for command:");
 
 	for (opt_enum = 0; opt_enum < ARG_COUNT; opt_enum++) {
 		if (!cname->common_options[opt_enum])
@@ -1756,25 +1788,6 @@ void print_usage_common(struct command_name *cname, struct command *cmd)
 		}
 	}
 
- all:
-	/* options that are common to all lvm commands */
-
-	for (oo = 0; oo < lvm_all.oo_count; oo++) {
-		opt_enum = lvm_all.optional_opt_args[oo].opt;
-
-		if (first)
-			printf("\n\t[");
-		else
-			printf("\n\t ");
-		first = 0;
-
-		printf(" %s", opt_names[opt_enum].long_opt);
-		if (lvm_all.optional_opt_args[oo].def.val_bits) {
-			printf(" ");
-			print_usage_def(&lvm_all.optional_opt_args[oo].def);
-		}
-	}
-
 	printf(" ]");
 	printf("\n\n");
 }
@@ -2215,7 +2228,7 @@ void print_man_usage(char *lvmname, struct command *cmd)
 			printf("\n.br\n");
 			printf(" ");
 			/* space alignment without short opt */
-			printf("   ");
+			/* printf("   "); */
 		}
 		printf(" COMMON_OPTIONS");
 		printf(" ]\n");
@@ -2263,7 +2276,7 @@ void print_man_usage(char *lvmname, struct command *cmd)
  * then options with only long names, alphabetically
  */
 
-void print_man_usage_common(struct command *cmd)
+void print_man_usage_common_lvm(struct command *cmd)
 {
 	struct command_name *cname;
 	int i, sep, rp, oo, op, opt_enum;
@@ -2271,6 +2284,99 @@ void print_man_usage_common(struct command *cmd)
 	if (!(cname = find_command_name(cmd->name)))
 		return;
 
+	printf("Common options for lvm:\n");
+	printf(".\n");
+
+	sep = 0;
+
+	printf(".RS 4\n");
+	printf("[");
+
+	/* print those with short opts */
+	for (i = 0; i < ARG_COUNT; i++) {
+		opt_enum = opt_names_alpha[i]->opt_enum;
+
+		if (!opt_names[opt_enum].short_opt)
+			continue;
+
+		if (!is_lvm_all_opt(opt_enum))
+			continue;
+
+		if (sep) {
+			printf("\n.br\n");
+			printf(" ");
+		}
+
+		for (oo = 0; oo < cmd->oo_count; oo++) {
+			if (cmd->optional_opt_args[oo].opt != opt_enum)
+				continue;
+
+			printf(" \\fB-%c\\fP|\\fB%s\\fP",
+				opt_names[opt_enum].short_opt,
+				man_long_opt_name(cmd->name, opt_enum));
+
+			if (cmd->optional_opt_args[oo].def.val_bits) {
+				printf(" ");
+				print_def_man(&cmd->optional_opt_args[oo].def, 1);
+			}
+			sep = 1;
+			break;
+		}
+
+	}
+
+	/* print those without short opts */
+	for (i = 0; i < ARG_COUNT; i++) {
+		opt_enum = opt_names_alpha[i]->opt_enum;
+
+		if (opt_names[opt_enum].short_opt)
+			continue;
+
+		if (!is_lvm_all_opt(opt_enum))
+			continue;
+
+		if (sep) {
+			printf("\n.br\n");
+			printf(" ");
+		}
+
+		for (oo = 0; oo < cmd->oo_count; oo++) {
+			if (cmd->optional_opt_args[oo].opt != opt_enum)
+				continue;
+
+			/* space alignment without short opt */
+			printf("   ");
+
+			printf(" \\fB%s\\fP", man_long_opt_name(cmd->name, opt_enum));
+
+			if (cmd->optional_opt_args[oo].def.val_bits) {
+				printf(" ");
+				print_def_man(&cmd->optional_opt_args[oo].def, 1);
+			}
+			sep = 1;
+			break;
+		}
+	}
+
+	printf(" ]\n");
+	printf(".RE\n");
+	return;
+}
+
+void print_man_usage_common_cmd(struct command *cmd)
+{
+	struct command_name *cname;
+	int i, sep, rp, oo, op, opt_enum;
+
+	if (!(cname = find_command_name(cmd->name)))
+		return;
+
+	if (cname->variants < 2)
+		return;
+
+	printf("Common options for command:\n");
+	printf(".\n");
+
 	sep = 0;
 
 	printf(".RS 4\n");
@@ -2286,7 +2392,11 @@ void print_man_usage_common(struct command *cmd)
 		if (!opt_names[opt_enum].short_opt)
 			continue;
 
-		if ((cname->variants < 2) && !is_lvm_all_opt(opt_enum))
+		/* common cmd options only used with variants */
+		if (cname->variants < 2)
+			continue;
+
+		if (is_lvm_all_opt(opt_enum))
 			continue;
 
 		if (sep) {
@@ -2322,7 +2432,11 @@ void print_man_usage_common(struct command *cmd)
 		if (opt_names[opt_enum].short_opt)
 			continue;
 
-		if ((cname->variants < 2) && !is_lvm_all_opt(opt_enum))
+		/* common cmd options only used with variants */
+		if (cname->variants < 2)
+			continue;
+
+		if (is_lvm_all_opt(opt_enum))
 			continue;
 
 		if (sep) {
@@ -2349,6 +2463,9 @@ void print_man_usage_common(struct command *cmd)
 	}
 
 	printf(" ]\n");
+	printf(".RE\n");
+	printf(".br\n");
+	printf("\n");
 	return;
 }
 
@@ -2811,9 +2928,8 @@ void print_man(char *name, char *des_file, int include_primary, int include_seco
 		cmd = &commands[i];
 
 		if (prev_cmd && strcmp(prev_cmd->name, cmd->name)) {
-			printf("Common options:\n");
-			printf(".\n");
-			print_man_usage_common(prev_cmd);
+			print_man_usage_common_cmd(prev_cmd);
+			print_man_usage_common_lvm(prev_cmd);
 
 			printf("\n");
 			printf(".SH OPTIONS\n");
@@ -2909,9 +3025,8 @@ void print_man(char *name, char *des_file, int include_primary, int include_seco
 		print_man_usage(lvmname, cmd);
 
 		if (i == (COMMAND_COUNT - 1)) {
-			printf("Common options:\n");
-			printf(".\n");
-			print_man_usage_common(cmd);
+			print_man_usage_common_cmd(cmd);
+			print_man_usage_common_lvm(cmd);
 
 			printf("\n");
 			printf(".SH OPTIONS\n");
diff --git a/tools/command.h b/tools/command.h
index 51c4551..c5c801a 100644
--- a/tools/command.h
+++ b/tools/command.h
@@ -214,7 +214,8 @@ struct command {
 int define_commands(char *run_name);
 int command_id_to_enum(const char *str);
 void print_usage(struct command *cmd, int longhelp);
-void print_usage_common(struct command_name *cname, struct command *cmd);
+void print_usage_common_cmd(struct command_name *cname, struct command *cmd);
+void print_usage_common_lvm(struct command_name *cname, struct command *cmd);
 void factor_common_options(void);
 
 #endif
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index ecb5802..02266c9 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1716,9 +1716,10 @@ static int _usage(const char *name, int longhelp)
 	}
 
 	/* Common options are printed once for all variants of a command name. */
-	if (longhelp)
-		print_usage_common(cname, cmd);
-	else
+	if (longhelp) {
+		print_usage_common_cmd(cname, cmd);
+		print_usage_common_lvm(cname, cmd);
+	} else
 		log_print("Use --longhelp to show all options.");
 
 	return 1;


