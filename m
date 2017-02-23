From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 23 Feb 2017 23:08:50 +0000 (UTC)
Subject: master - man: improve line breaks
Message-ID: <20170223230850.DAAC3603CD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ffe3ca26e05f9bb10f004bafe6866b189d7ac385
Commit:        ffe3ca26e05f9bb10f004bafe6866b189d7ac385
Parent:        3fd3c9430d5f0b3291c0111ddcd4ddd524dd26ed
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Feb 23 17:06:42 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Feb 23 17:06:42 2017 -0600

man: improve line breaks

Borrow tricks from dmsetup man page to improve
the line break and indentation using .ad l, .ad b,
and soft break \%.
---
 tools/command.c |   98 +++++++++++++++++++++++++++++++------------------------
 1 files changed, 55 insertions(+), 43 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index 04b44ad..8d5a96b 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -1850,21 +1850,12 @@ static void print_val_man(const char *str)
 		line = dm_strdup(str);
 		split_line(line, &line_argc, line_argv, '|');
 		for (i = 0; i < line_argc; i++) {
-			if (i) {
+			if (i)
 				printf("|");
-
-				/* this is a hack to add a line break for
-				   a long string of opt values */
-				if ((len > 40) && (i >= (line_argc / 2) + 1)) {
-					printf("\n");
-					printf("       ");
-					len = 0;
-				}
-			}
 			if (strstr(line_argv[i], "Number"))
 				printf("\\fI%s\\fP", line_argv[i]);
 			else
-				printf("\\fB%s\\fP", line_argv[i]);
+				printf("\\%\\fB%s\\fP", line_argv[i]);
 		}
 		return;
 	}
@@ -2016,8 +2007,10 @@ void print_man_usage(char *lvmname, struct command *cmd)
 				continue;
 
 			if (sep) {
-				printf(",");
-				printf("\n.br\n");
+				printf(",\n");
+				printf(".ad b\n");
+				printf(".br\n");
+				printf(".ad l\n");
 				printf(" ");
 			}
 
@@ -2046,10 +2039,13 @@ void print_man_usage(char *lvmname, struct command *cmd)
 				continue;
 
 			if (sep) {
-				printf(",");
-				printf("\n.br\n");
+				printf(",\n");
+				printf(".ad b\n");
+				printf(".br\n");
+				printf(".ad l\n");
 				printf(" ");
-			}
+			} else
+				printf(".ad l\n");
 
 			printf("   ");
 			printf(" \\fB%s\\fP", man_long_opt_name(cmd->name, opt_enum));
@@ -2164,9 +2160,9 @@ void print_man_usage(char *lvmname, struct command *cmd)
 			if ((cname->variants > 1) && cname->common_options[opt_enum])
 				continue;
 
-			if (sep) {
-				printf("\n.br\n");
-			}
+			if (sep)
+				printf(".br\n");
+			printf(".ad l\n");
 
 			printf("[ \\fB-%c\\fP|\\fB%s\\fP",
 				opt_names[opt_enum].short_opt,
@@ -2176,7 +2172,8 @@ void print_man_usage(char *lvmname, struct command *cmd)
 				printf(" ");
 				print_def_man(&cmd->optional_opt_args[oo].def, 1);
 			}
-			printf(" ]");
+			printf(" ]\n");
+			printf(".ad b\n");
 			sep = 1;
 		}
 
@@ -2194,9 +2191,9 @@ void print_man_usage(char *lvmname, struct command *cmd)
 			if ((cname->variants > 1) && cname->common_options[opt_enum])
 				continue;
 
-			if (sep) {
-				printf("\n.br\n");
-			}
+			if (sep)
+				printf(".br\n");
+			printf(".ad l\n");
 
 			/* space alignment without short opt */
 			printf("[   ");
@@ -2207,12 +2204,13 @@ void print_man_usage(char *lvmname, struct command *cmd)
 				printf(" ");
 				print_def_man(&cmd->optional_opt_args[oo].def, 1);
 			}
-			printf(" ]");
+			printf(" ]\n");
+			printf(".ad b\n");
 			sep = 1;
 		}
 
 		if (sep) {
-			printf("\n.br\n");
+			printf(".br\n");
 			/* space alignment without short opt */
 			/* printf("   "); */
 		}
@@ -2286,9 +2284,9 @@ void print_man_usage_common_lvm(struct command *cmd)
 		if (!is_lvm_all_opt(opt_enum))
 			continue;
 
-		if (sep) {
-			printf("\n.br\n");
-		}
+		if (sep)
+			printf(".br\n");
+		printf(".ad l\n");
 
 		for (oo = 0; oo < cmd->oo_count; oo++) {
 			if (cmd->optional_opt_args[oo].opt != opt_enum)
@@ -2302,7 +2300,8 @@ void print_man_usage_common_lvm(struct command *cmd)
 				printf(" ");
 				print_def_man(&cmd->optional_opt_args[oo].def, 1);
 			}
-			printf(" ]");
+			printf(" ]\n");
+			printf(".ad b\n");
 			sep = 1;
 			break;
 		}
@@ -2319,9 +2318,9 @@ void print_man_usage_common_lvm(struct command *cmd)
 		if (!is_lvm_all_opt(opt_enum))
 			continue;
 
-		if (sep) {
-			printf("\n.br\n");
-		}
+		if (sep)
+			printf(".br\n");
+		printf(".ad l\n");
 
 		for (oo = 0; oo < cmd->oo_count; oo++) {
 			if (cmd->optional_opt_args[oo].opt != opt_enum)
@@ -2336,7 +2335,8 @@ void print_man_usage_common_lvm(struct command *cmd)
 				printf(" ");
 				print_def_man(&cmd->optional_opt_args[oo].def, 1);
 			}
-			printf(" ]");
+			printf(" ]\n");
+			printf(".ad b\n");
 			sep = 1;
 			break;
 		}
@@ -2381,9 +2381,9 @@ void print_man_usage_common_cmd(struct command *cmd)
 		if (is_lvm_all_opt(opt_enum))
 			continue;
 
-		if (sep) {
-			printf("\n.br\n");
-		}
+		if (sep)
+			printf(".br\n");
+		printf(".ad l\n");
 
 		for (oo = 0; oo < cmd->oo_count; oo++) {
 			if (cmd->optional_opt_args[oo].opt != opt_enum)
@@ -2397,7 +2397,8 @@ void print_man_usage_common_cmd(struct command *cmd)
 				printf(" ");
 				print_def_man(&cmd->optional_opt_args[oo].def, 1);
 			}
-			printf(" ]");
+			printf(" ]\n");
+			printf(".ad b\n");
 			sep = 1;
 			break;
 		}
@@ -2421,9 +2422,9 @@ void print_man_usage_common_cmd(struct command *cmd)
 		if (is_lvm_all_opt(opt_enum))
 			continue;
 
-		if (sep) {
-			printf("\n.br\n");
-		}
+		if (sep)
+			printf(".br\n");
+		printf(".ad l\n");
 
 		for (oo = 0; oo < cmd->oo_count; oo++) {
 			if (cmd->optional_opt_args[oo].opt != opt_enum)
@@ -2438,7 +2439,8 @@ void print_man_usage_common_cmd(struct command *cmd)
 				printf(" ");
 				print_def_man(&cmd->optional_opt_args[oo].def, 1);
 			}
-			printf(" ]");
+			printf(" ]\n");
+			printf(".ad b\n");
 			sep = 1;
 			break;
 		}
@@ -2555,7 +2557,8 @@ void print_man_all_options_list(struct command_name *cname)
 			continue;
 
 		if (sep)
-			printf("\n.br\n");
+			printf(".br\n");
+		printf(".ad l\n");
 
 		printf(" \\fB-%c\\fP|\\fB%s\\fP",
 			opt_names[opt_enum].short_opt,
@@ -2575,6 +2578,8 @@ void print_man_all_options_list(struct command_name *cname)
 			print_val_man(val_names[val_enum].usage);
 		}
 
+		printf("\n.ad b\n");
+
 		sep = 1;
 	}
 
@@ -2589,7 +2594,8 @@ void print_man_all_options_list(struct command_name *cname)
 			continue;
 
 		if (sep)
-			printf("\n.br\n");
+			printf(".br\n");
+		printf(".ad l\n");
 
 		/* space alignment without short opt */
 		printf("   ");
@@ -2610,6 +2616,8 @@ void print_man_all_options_list(struct command_name *cname)
 			print_val_man(val_names[val_enum].usage);
 		}
 
+		printf("\n.ad b\n");
+
 		sep = 1;
 	}
 }
@@ -2632,6 +2640,8 @@ void print_man_all_options_desc(struct command_name *cname)
 
 		printf("\n.HP\n");
 
+		printf(".ad l\n");
+
 		if (opt_names[opt_enum].short_opt) {
 			printf("\\fB-%c\\fP|\\fB%s\\fP",
 			       opt_names[opt_enum].short_opt,
@@ -2663,6 +2673,8 @@ void print_man_all_options_desc(struct command_name *cname)
 			print_man_option_desc(cname, opt_enum);
 		}
 
+		printf(".ad b\n");
+
 		sep = 1;
 	}
 }


