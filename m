From: David Teigland <teigland@sourceware.org>
Date: Fri, 3 Mar 2017 16:14:27 -0500
Subject: master - help: show short opt with long opt
Message-ID: <201703032114.v23LEROk007023@int-mx11.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e4ef3d04ad3a2870f94557250006e4c93431b0bb
Commit:        e4ef3d04ad3a2870f94557250006e4c93431b0bb
Parent:        547bdb63e1757288586ea5b74b228f35bb8d2af2
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Mar 3 15:12:46 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Mar 3 15:14:18 2017 -0600

help: show short opt with long opt

e.g. show -n|--name instead of just --name
---
 tools/command.c |  145 +++++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 files changed, 140 insertions(+), 5 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index cab6f09..436e759 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -1675,9 +1675,14 @@ void print_usage(struct command *cmd, int longhelp, int desc_first)
 	if (cmd->ro_count) {
 		first = 1;
 
+		/* print options with short opts */
+
 		for (ro = 0; ro < cmd->ro_count; ro++) {
 			opt_enum = cmd->required_opt_args[ro].opt;
 
+			if (!opt_names[opt_enum].short_opt)
+				continue;
+
 			if ((opt_enum == size_ARG) && command_has_alternate_extents(cmd->name))
 				include_extents = 1;
 
@@ -1689,12 +1694,41 @@ void print_usage(struct command *cmd, int longhelp, int desc_first)
 				first = 0;
 			}
 
-			printf(" %s", opt_names[cmd->required_opt_args[ro].opt].long_opt);
+			printf(" -%c|%s", opt_names[opt_enum].short_opt, opt_names[opt_enum].long_opt);
+			if (cmd->required_opt_args[ro].def.val_bits) {
+				printf(" ");
+				print_usage_def(cmd, opt_enum, &cmd->required_opt_args[ro].def);
+			}
+		}
+
+		/* print options without short opts */
+
+		for (ro = 0; ro < cmd->ro_count; ro++) {
+			opt_enum = cmd->required_opt_args[ro].opt;
+
+			if (opt_names[opt_enum].short_opt)
+				continue;
+
+			if ((opt_enum == size_ARG) && command_has_alternate_extents(cmd->name))
+				include_extents = 1;
+
+			if (onereq) {
+				if (first)
+					printf("\n\t(");
+				else {
+					printf(",\n\t ");
+					printf("   "); /* align for no short opt */
+				}
+				first = 0;
+			}
+
+			printf(" %s", opt_names[opt_enum].long_opt);
 			if (cmd->required_opt_args[ro].def.val_bits) {
 				printf(" ");
 				print_usage_def(cmd, opt_enum, &cmd->required_opt_args[ro].def);
 			}
 		}
+
 		if (onereq)
 			printf(" )\n");
 	}
@@ -1718,14 +1752,19 @@ void print_usage(struct command *cmd, int longhelp, int desc_first)
 
 	if (cmd->oo_count) {
 		if (include_extents) {
-			printf("\n\t[ --extents ");
+			printf("\n\t[ -l|--extents ");
 			print_val_usage(cmd, extents_VAL);
 			printf(" ]");
 		}
 
+		/* print optional options with short opts */
+
 		for (oo = 0; oo < cmd->oo_count; oo++) {
 			opt_enum = cmd->optional_opt_args[oo].opt;
 
+			if (!opt_names[opt_enum].short_opt)
+				continue;
+
 			/*
 			 * Skip common lvm options in lvm_all which
 			 * are printed at the end under "Common options for lvm"
@@ -1749,7 +1788,47 @@ void print_usage(struct command *cmd, int longhelp, int desc_first)
 
 			printf("\n\t[");
 
-			printf(" %s", opt_names[opt_enum].long_opt);
+			printf(" -%c|%s", opt_names[opt_enum].short_opt, opt_names[opt_enum].long_opt);
+			if (cmd->optional_opt_args[oo].def.val_bits) {
+				printf(" ");
+				print_usage_def(cmd, opt_enum, &cmd->optional_opt_args[oo].def);
+			}
+
+			printf(" ]");
+		}
+
+		/* print optional options without short opts */
+
+		for (oo = 0; oo < cmd->oo_count; oo++) {
+			opt_enum = cmd->optional_opt_args[oo].opt;
+
+			if (opt_names[opt_enum].short_opt)
+				continue;
+
+			/*
+			 * Skip common lvm options in lvm_all which
+			 * are printed at the end under "Common options for lvm"
+			 * see print_common_options_lvm()
+			 */
+
+			if (is_lvm_all_opt(opt_enum))
+				continue;
+
+			/*
+			 * When there is more than one variant,
+			 * skip common command options from
+			 * cname->common_options (options common
+			 * to all variants), which are printed at
+			 * the end under "Common options for command"
+			 * see print_common_options_cmd()
+			 */
+
+			if ((cname->variants > 1) && cname->common_options[opt_enum])
+				continue;
+
+			printf("\n\t[");
+
+			printf("    %s", opt_names[opt_enum].long_opt);
 			if (cmd->optional_opt_args[oo].def.val_bits) {
 				printf(" ");
 				print_usage_def(cmd, opt_enum, &cmd->optional_opt_args[oo].def);
@@ -1794,12 +1873,35 @@ void print_usage_common_lvm(struct command_name *cname, struct command *cmd)
 
 	printf("  Common options for lvm:");
 
+	/* print options with short opts */
+
+	for (oo = 0; oo < lvm_all.oo_count; oo++) {
+		opt_enum = lvm_all.optional_opt_args[oo].opt;
+
+		if (!opt_names[opt_enum].short_opt)
+			continue;
+
+		printf("\n\t[");
+
+		printf(" -%c|%s", opt_names[opt_enum].short_opt, opt_names[opt_enum].long_opt);
+		if (lvm_all.optional_opt_args[oo].def.val_bits) {
+			printf(" ");
+			print_usage_def(cmd, opt_enum, &lvm_all.optional_opt_args[oo].def);
+		}
+		printf(" ]");
+	}
+
+	/* print options without short opts */
+
 	for (oo = 0; oo < lvm_all.oo_count; oo++) {
 		opt_enum = lvm_all.optional_opt_args[oo].opt;
 
+		if (opt_names[opt_enum].short_opt)
+			continue;
+
 		printf("\n\t[");
 
-		printf(" %s", opt_names[opt_enum].long_opt);
+		printf("    %s", opt_names[opt_enum].long_opt);
 		if (lvm_all.optional_opt_args[oo].def.val_bits) {
 			printf(" ");
 			print_usage_def(cmd, opt_enum, &lvm_all.optional_opt_args[oo].def);
@@ -1824,6 +1926,8 @@ void print_usage_common_cmd(struct command_name *cname, struct command *cmd)
 
 	printf("  Common options for command:");
 
+	/* print options with short opts */
+
 	for (opt_enum = 0; opt_enum < ARG_COUNT; opt_enum++) {
 		if (!cname->common_options[opt_enum])
 			continue;
@@ -1831,13 +1935,44 @@ void print_usage_common_cmd(struct command_name *cname, struct command *cmd)
 		if (is_lvm_all_opt(opt_enum))
 			continue;
 
+		if (!opt_names[opt_enum].short_opt)
+			continue;
+
 		printf("\n\t[");
 
 		for (oo = 0; oo < cmd->oo_count; oo++) {
 			if (cmd->optional_opt_args[oo].opt != opt_enum)
 				continue;
 
-			printf(" %s", opt_names[opt_enum].long_opt);
+			printf(" -%c|%s", opt_names[opt_enum].short_opt, opt_names[opt_enum].long_opt);
+			if (cmd->optional_opt_args[oo].def.val_bits) {
+				printf(" ");
+				print_usage_def(cmd, opt_enum, &cmd->optional_opt_args[oo].def);
+			}
+			break;
+		}
+		printf(" ]");
+	}
+
+	/* print options without short opts */
+
+	for (opt_enum = 0; opt_enum < ARG_COUNT; opt_enum++) {
+		if (!cname->common_options[opt_enum])
+			continue;
+
+		if (is_lvm_all_opt(opt_enum))
+			continue;
+
+		if (opt_names[opt_enum].short_opt)
+			continue;
+
+		printf("\n\t[");
+
+		for (oo = 0; oo < cmd->oo_count; oo++) {
+			if (cmd->optional_opt_args[oo].opt != opt_enum)
+				continue;
+
+			printf("    %s", opt_names[opt_enum].long_opt);
 			if (cmd->optional_opt_args[oo].def.val_bits) {
 				printf(" ");
 				print_usage_def(cmd, opt_enum, &cmd->optional_opt_args[oo].def);


