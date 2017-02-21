From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 21 Feb 2017 21:00:56 +0000 (UTC)
Subject: master - man/help: enclose each option in brackets
Message-ID: <20170221210056.32A6E60CD1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=263050bc073e509f84de4c4da160887f412376fc
Commit:        263050bc073e509f84de4c4da160887f412376fc
Parent:        c1ce371b59257a236115d2d6a3cb24af17faf55d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Feb 21 14:59:52 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Feb 21 14:59:52 2017 -0600

man/help: enclose each option in brackets

Placing [] around each individual option is the most
common style, and it improves the readability.
---
 tools/command.c |   73 +++++++++++++++++++------------------------------------
 1 files changed, 25 insertions(+), 48 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index ed38740..0d40af6 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -1654,8 +1654,6 @@ void print_usage(struct command *cmd, int longhelp)
 		goto op_count;
 
 	if (cmd->oo_count) {
-		first = 1;
-
 		for (oo = 0; oo < cmd->oo_count; oo++) {
 			opt_enum = cmd->optional_opt_args[oo].opt;
 
@@ -1680,24 +1678,18 @@ void print_usage(struct command *cmd, int longhelp)
 			if ((cname->variants > 1) && cname->common_options[opt_enum])
 				continue;
 
-			if (first)
-				printf("\n\t[");
-			else
-				printf("\n\t ");
-			first = 0;
+			printf("\n\t[");
 
 			printf(" %s", opt_names[opt_enum].long_opt);
 			if (cmd->optional_opt_args[oo].def.val_bits) {
 				printf(" ");
 				print_usage_def(&cmd->optional_opt_args[oo].def);
 			}
+
+			printf(" ]");
 		}
 
-		if (first)
-			printf("\n\t[");
-		else
-			printf("\n\t ");
-		printf(" COMMON_OPTIONS ]");
+		printf("\n\t[ COMMON_OPTIONS ]");
 	}
 
  op_count:
@@ -1724,33 +1716,29 @@ void print_usage(struct command *cmd, int longhelp)
 
 void print_usage_common_lvm(struct command_name *cname, struct command *cmd)
 {
-	int oo, opt_enum, first = 1;
+	int oo, opt_enum;
 
 	printf("  Common options for lvm:");
 
 	for (oo = 0; oo < lvm_all.oo_count; oo++) {
 		opt_enum = lvm_all.optional_opt_args[oo].opt;
 
-		if (first)
-			printf("\n\t[");
-		else
-			printf("\n\t ");
-		first = 0;
+		printf("\n\t[");
 
 		printf(" %s", opt_names[opt_enum].long_opt);
 		if (lvm_all.optional_opt_args[oo].def.val_bits) {
 			printf(" ");
 			print_usage_def(&lvm_all.optional_opt_args[oo].def);
 		}
+		printf(" ]");
 	}
 
-	printf(" ]");
 	printf("\n\n");
 }
 
 void print_usage_common_cmd(struct command_name *cname, struct command *cmd)
 {
-	int oo, opt_enum, first = 1;
+	int oo, opt_enum;
 
 	/*
 	 * when there's more than one variant, options that
@@ -1769,11 +1757,7 @@ void print_usage_common_cmd(struct command_name *cname, struct command *cmd)
 		if (is_lvm_all_opt(opt_enum))
 			continue;
 
-		if (first)
-			printf("\n\t[");
-		else
-			printf("\n\t ");
-		first = 0;
+		printf("\n\t[");
 
 		for (oo = 0; oo < cmd->oo_count; oo++) {
 			if (cmd->optional_opt_args[oo].opt != opt_enum)
@@ -1786,9 +1770,9 @@ void print_usage_common_cmd(struct command_name *cname, struct command *cmd)
 			}
 			break;
 		}
+		printf(" ]");
 	}
 
-	printf(" ]");
 	printf("\n\n");
 }
 
@@ -2161,7 +2145,6 @@ void print_man_usage(char *lvmname, struct command *cmd)
 
 	if (cmd->oo_count) {
 		printf(".RS 4\n");
-		printf("[");
 
 		/* print optional options with short opts */
 
@@ -2179,10 +2162,9 @@ void print_man_usage(char *lvmname, struct command *cmd)
 
 			if (sep) {
 				printf("\n.br\n");
-				printf(" ");
 			}
 
-			printf(" \\fB-%c\\fP|\\fB%s\\fP",
+			printf("[ \\fB-%c\\fP|\\fB%s\\fP",
 				opt_names[opt_enum].short_opt,
 				man_long_opt_name(cmd->name, opt_enum));
 
@@ -2190,6 +2172,7 @@ void print_man_usage(char *lvmname, struct command *cmd)
 				printf(" ");
 				print_def_man(&cmd->optional_opt_args[oo].def, 1);
 			}
+			printf(" ]");
 			sep = 1;
 		}
 
@@ -2209,11 +2192,10 @@ void print_man_usage(char *lvmname, struct command *cmd)
 
 			if (sep) {
 				printf("\n.br\n");
-				printf(" ");
 			}
 
 			/* space alignment without short opt */
-			printf("   ");
+			printf("[   ");
 
 			printf(" \\fB%s\\fP", man_long_opt_name(cmd->name, opt_enum));
 
@@ -2221,17 +2203,16 @@ void print_man_usage(char *lvmname, struct command *cmd)
 				printf(" ");
 				print_def_man(&cmd->optional_opt_args[oo].def, 1);
 			}
+			printf(" ]");
 			sep = 1;
 		}
 
 		if (sep) {
 			printf("\n.br\n");
-			printf(" ");
 			/* space alignment without short opt */
 			/* printf("   "); */
 		}
-		printf(" COMMON_OPTIONS");
-		printf(" ]\n");
+		printf("[ COMMON_OPTIONS ]\n");
 		printf(".RE\n");
 		printf(".br\n");
 	}
@@ -2290,7 +2271,6 @@ void print_man_usage_common_lvm(struct command *cmd)
 	sep = 0;
 
 	printf(".RS 4\n");
-	printf("[");
 
 	/* print those with short opts */
 	for (i = 0; i < ARG_COUNT; i++) {
@@ -2304,14 +2284,13 @@ void print_man_usage_common_lvm(struct command *cmd)
 
 		if (sep) {
 			printf("\n.br\n");
-			printf(" ");
 		}
 
 		for (oo = 0; oo < cmd->oo_count; oo++) {
 			if (cmd->optional_opt_args[oo].opt != opt_enum)
 				continue;
 
-			printf(" \\fB-%c\\fP|\\fB%s\\fP",
+			printf("[ \\fB-%c\\fP|\\fB%s\\fP",
 				opt_names[opt_enum].short_opt,
 				man_long_opt_name(cmd->name, opt_enum));
 
@@ -2319,6 +2298,7 @@ void print_man_usage_common_lvm(struct command *cmd)
 				printf(" ");
 				print_def_man(&cmd->optional_opt_args[oo].def, 1);
 			}
+			printf(" ]");
 			sep = 1;
 			break;
 		}
@@ -2337,7 +2317,6 @@ void print_man_usage_common_lvm(struct command *cmd)
 
 		if (sep) {
 			printf("\n.br\n");
-			printf(" ");
 		}
 
 		for (oo = 0; oo < cmd->oo_count; oo++) {
@@ -2345,7 +2324,7 @@ void print_man_usage_common_lvm(struct command *cmd)
 				continue;
 
 			/* space alignment without short opt */
-			printf("   ");
+			printf("[   ");
 
 			printf(" \\fB%s\\fP", man_long_opt_name(cmd->name, opt_enum));
 
@@ -2353,13 +2332,13 @@ void print_man_usage_common_lvm(struct command *cmd)
 				printf(" ");
 				print_def_man(&cmd->optional_opt_args[oo].def, 1);
 			}
+			printf(" ]");
 			sep = 1;
 			break;
 		}
 	}
 
-	printf(" ]\n");
-	printf(".RE\n");
+	printf("\n.RE\n");
 	return;
 }
 
@@ -2380,7 +2359,6 @@ void print_man_usage_common_cmd(struct command *cmd)
 	sep = 0;
 
 	printf(".RS 4\n");
-	printf("[");
 
 	/* print those with short opts */
 	for (i = 0; i < ARG_COUNT; i++) {
@@ -2401,14 +2379,13 @@ void print_man_usage_common_cmd(struct command *cmd)
 
 		if (sep) {
 			printf("\n.br\n");
-			printf(" ");
 		}
 
 		for (oo = 0; oo < cmd->oo_count; oo++) {
 			if (cmd->optional_opt_args[oo].opt != opt_enum)
 				continue;
 
-			printf(" \\fB-%c\\fP|\\fB%s\\fP",
+			printf("[ \\fB-%c\\fP|\\fB%s\\fP",
 				opt_names[opt_enum].short_opt,
 				man_long_opt_name(cmd->name, opt_enum));
 
@@ -2416,6 +2393,7 @@ void print_man_usage_common_cmd(struct command *cmd)
 				printf(" ");
 				print_def_man(&cmd->optional_opt_args[oo].def, 1);
 			}
+			printf(" ]");
 			sep = 1;
 			break;
 		}
@@ -2441,7 +2419,6 @@ void print_man_usage_common_cmd(struct command *cmd)
 
 		if (sep) {
 			printf("\n.br\n");
-			printf(" ");
 		}
 
 		for (oo = 0; oo < cmd->oo_count; oo++) {
@@ -2449,7 +2426,7 @@ void print_man_usage_common_cmd(struct command *cmd)
 				continue;
 
 			/* space alignment without short opt */
-			printf("   ");
+			printf("[   ");
 
 			printf(" \\fB%s\\fP", man_long_opt_name(cmd->name, opt_enum));
 
@@ -2457,13 +2434,13 @@ void print_man_usage_common_cmd(struct command *cmd)
 				printf(" ");
 				print_def_man(&cmd->optional_opt_args[oo].def, 1);
 			}
+			printf(" ]");
 			sep = 1;
 			break;
 		}
 	}
 
-	printf(" ]\n");
-	printf(".RE\n");
+	printf("\n.RE\n");
 	printf(".br\n");
 	printf("\n");
 	return;


