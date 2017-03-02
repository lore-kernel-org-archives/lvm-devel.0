From: David Teigland <teigland@sourceware.org>
Date: Thu, 2 Mar 2017 17:58:41 -0500
Subject: master - lvcreate: munge size value in help output
Message-ID: <201703022258.v22MweBC023877@int-mx14.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f35028339830330ef331ff15a7e5f1274bfd63a2
Commit:        f35028339830330ef331ff15a7e5f1274bfd63a2
Parent:        af7c8e7106632899925c26fff3be37a2de0c8a35
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Mar 2 14:33:50 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Mar 2 16:58:19 2017 -0600

lvcreate: munge size value in help output

Add hack to omit the [+|-] from the --size
value.  Same hack exists in man generator.
---
 tools/command.c |   31 +++++++++++++++++++++++--------
 1 files changed, 23 insertions(+), 8 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index 28c77e4..f55b2ef 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -1574,7 +1574,7 @@ static void _print_usage_description(struct command *cmd)
 	}
 }
 
-static void print_usage_def(struct arg_def *def)
+static void print_usage_def(struct command *cmd, int opt_enum, struct arg_def *def)
 {
 	int val_enum;
 	int lvt_enum;
@@ -1592,7 +1592,20 @@ static void print_usage_def(struct arg_def *def)
 			else {
 				if (sep) printf("|");
 
-				if (!val_names[val_enum].usage)
+				/*
+				 * FIXME: this is a terrible hack that's needed
+				 * until we can differentiate which commands
+				 * use --size with a signed number and which
+				 * commands use only a positive --size.
+				 * (See the same hack when generating man pages
+				 * in print_val_man.)
+				 */
+				if (!strcmp(cmd->name, "lvcreate") &&
+				    (opt_enum == size_ARG) &&
+				    (!strcmp(val_names[val_enum].usage, "[+|-]Size[m|UNIT]")))
+					printf("Size[m|UNIT]");
+
+				else if (!val_names[val_enum].usage)
 					printf("%s", val_names[val_enum].name);
 				else
 					printf("%s", val_names[val_enum].usage);
@@ -1639,6 +1652,8 @@ void print_usage(struct command *cmd, int longhelp, int desc_first)
 		first = 1;
 
 		for (ro = 0; ro < cmd->ro_count; ro++) {
+			opt_enum = cmd->required_opt_args[ro].opt;
+
 			if (onereq) {
 				if (first)
 					printf("\n\t(");
@@ -1650,7 +1665,7 @@ void print_usage(struct command *cmd, int longhelp, int desc_first)
 			printf(" %s", opt_names[cmd->required_opt_args[ro].opt].long_opt);
 			if (cmd->required_opt_args[ro].def.val_bits) {
 				printf(" ");
-				print_usage_def(&cmd->required_opt_args[ro].def);
+				print_usage_def(cmd, opt_enum, &cmd->required_opt_args[ro].def);
 			}
 		}
 		if (onereq)
@@ -1663,7 +1678,7 @@ void print_usage(struct command *cmd, int longhelp, int desc_first)
 		for (rp = 0; rp < cmd->rp_count; rp++) {
 			if (cmd->required_pos_args[rp].def.val_bits) {
 				printf(" ");
-				print_usage_def(&cmd->required_pos_args[rp].def);
+				print_usage_def(cmd, 0, &cmd->required_pos_args[rp].def);
 			}
 		}
 	}
@@ -1704,7 +1719,7 @@ void print_usage(struct command *cmd, int longhelp, int desc_first)
 			printf(" %s", opt_names[opt_enum].long_opt);
 			if (cmd->optional_opt_args[oo].def.val_bits) {
 				printf(" ");
-				print_usage_def(&cmd->optional_opt_args[oo].def);
+				print_usage_def(cmd, opt_enum, &cmd->optional_opt_args[oo].def);
 			}
 
 			printf(" ]");
@@ -1723,7 +1738,7 @@ void print_usage(struct command *cmd, int longhelp, int desc_first)
 		for (op = 0; op < cmd->op_count; op++) {
 			if (cmd->optional_pos_args[op].def.val_bits) {
 				printf(" ");
-				print_usage_def(&cmd->optional_pos_args[op].def);
+				print_usage_def(cmd, 0, &cmd->optional_pos_args[op].def);
 			}
 		}
 	}
@@ -1754,7 +1769,7 @@ void print_usage_common_lvm(struct command_name *cname, struct command *cmd)
 		printf(" %s", opt_names[opt_enum].long_opt);
 		if (lvm_all.optional_opt_args[oo].def.val_bits) {
 			printf(" ");
-			print_usage_def(&lvm_all.optional_opt_args[oo].def);
+			print_usage_def(cmd, opt_enum, &lvm_all.optional_opt_args[oo].def);
 		}
 		printf(" ]");
 	}
@@ -1792,7 +1807,7 @@ void print_usage_common_cmd(struct command_name *cname, struct command *cmd)
 			printf(" %s", opt_names[opt_enum].long_opt);
 			if (cmd->optional_opt_args[oo].def.val_bits) {
 				printf(" ");
-				print_usage_def(&cmd->optional_opt_args[oo].def);
+				print_usage_def(cmd, opt_enum, &cmd->optional_opt_args[oo].def);
 			}
 			break;
 		}


