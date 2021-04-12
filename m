From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 12 Apr 2021 07:55:44 +0000 (GMT)
Subject: main - man-generator: improve hyphenation for longer option list
Message-ID: <20210412075544.27FE839FCC4C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d86b5836442a357e6c01ee897b5d530e14494f73
Commit:        d86b5836442a357e6c01ee897b5d530e14494f73
Parent:        b76283c4b377b3fffd5c20974e4a99e6407d71cb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Apr 11 00:47:00 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 12 09:54:16 2021 +0200

man-generator: improve hyphenation for longer option list

Disable hyphenation around longer option lists (>42 chars)
and use \: to markup places for line splits.

The code ATM is somewhat mixtured so it's not easy to encapsulate
section .nh ... .hy.

ATM global _was_hyphen is used to properly finish sections after
disabled hyphenation.
---
 tools/command.c | 47 ++++++++++++++++++++++++++++++++++-------------
 1 file changed, 34 insertions(+), 13 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index 38b11b8eb..7e0c2584d 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -301,6 +301,14 @@ static struct oo_line _oo_lines[MAX_OO_LINES];
 
 static void __add_optional_opt_line(struct cmd_context *cmdtool, struct command *cmd, int argc, char *argv[]);
 
+static unsigned _was_hyphen = 0;
+static void printf_hyphen(char c)
+{
+	/* When .hy 1 was printed, we do not want to emit empty space */
+	printf("%c%c\n", _was_hyphen ? '\n' : ' ', c);
+	_was_hyphen = 0;
+}
+
 /*
  * modifies buf, replacing the sep characters with \0
  * argv pointers point to positions in buf
@@ -1901,7 +1909,7 @@ void print_usage(struct command *cmd, int longhelp, int desc_first)
 			}
 		}
 
-		printf(" )\n");
+		printf_hyphen(')');
 	}
 
 	if (!any_req && cmd->ro_count) {
@@ -2252,6 +2260,8 @@ static void _print_val_man(struct command_name *cname, int opt_enum, int val_enu
 	char *line_argv[MAX_LINE_ARGC];
 	int line_argc;
 	int i;
+
+	_was_hyphen = 0;
 	int is_relative_opt = (opt_enum == size_ARG) ||
 			      (opt_enum == extents_ARG) ||
 			      (opt_enum == poolmetadatasize_ARG) ||
@@ -2357,15 +2367,20 @@ static void _print_val_man(struct command_name *cname, int opt_enum, int val_enu
 	if (strchr(str, '|')) {
 		if (!(line = strdup(str)))
 			return;
+		if ((_was_hyphen = (strlen(line) > 42)))
+			/* TODO: prevent line to end with already printed space */
+			printf("\n.nh\n");
 		_split_line(line, &line_argc, line_argv, '|');
 		for (i = 0; i < line_argc; i++) {
 			if (i)
-				printf("|");
+				printf("|%s", _was_hyphen ? "\\:" : "");
 			if (strstr(line_argv[i], "Number"))
 				printf("\\fI%s\\fP", line_argv[i]);
 			else
 				printf("\\fB%s\\fP", line_argv[i]);
 		}
+		if (_was_hyphen)
+			printf("\n.hy");
 		free(line);
 		return;
 	}
@@ -2391,9 +2406,13 @@ static void _print_def_man(struct command_name *cname, int opt_enum, struct arg_
 			else {
 				if (sep) printf("|");
 
-				if (!usage || !val_names[val_enum].usage)
+				if (!usage || !val_names[val_enum].usage) {
+					if (_was_hyphen) {
+						printf("\n");
+						_was_hyphen = 0;
+					}
 					printf("\\fI%s\\fP", val_names[val_enum].name);
-				else
+				} else
 					_print_val_man(cname, opt_enum, val_enum);
 
 				sep = 1;
@@ -2470,6 +2489,7 @@ static void _print_man_usage(char *lvmname, struct command *cmd)
 	int need_ro_indent_end = 0;
 	int include_extents = 0;
 
+	_was_hyphen = 0;
 	if (!(cname = _find_command_name(cmd->name)))
 		return;
 
@@ -2590,7 +2610,7 @@ static void _print_man_usage(char *lvmname, struct command *cmd)
 			sep++;
 		}
 
-		printf(" )\n");
+		printf_hyphen(')');
 		printf(".RE\n");
 	}
 
@@ -2689,7 +2709,8 @@ static void _print_man_usage(char *lvmname, struct command *cmd)
 			printf(".ad l\n");
 			printf("[ \\fB-l\\fP|\\fB--extents\\fP ");
 			_print_val_man(cname, extents_ARG, opt_names[extents_ARG].val_enum);
-			printf(" ]\n");
+
+			printf_hyphen(']');
 			printf(".ad b\n");
 			sep = 1;
 		}
@@ -2720,7 +2741,7 @@ static void _print_man_usage(char *lvmname, struct command *cmd)
 				printf(" ");
 				_print_def_man(cname, opt_enum, &cmd->optional_opt_args[oo].def, 1);
 			}
-			printf(" ]\n");
+			printf_hyphen(']');
 			printf(".ad b\n");
 			sep = 1;
 		}
@@ -2752,7 +2773,7 @@ static void _print_man_usage(char *lvmname, struct command *cmd)
 				printf(" ");
 				_print_def_man(cname, opt_enum, &cmd->optional_opt_args[oo].def, 1);
 			}
-			printf(" ]\n");
+			printf_hyphen(']');
 			printf(".ad b\n");
 			sep = 1;
 		}
@@ -2783,7 +2804,7 @@ static void _print_man_usage(char *lvmname, struct command *cmd)
 		}
 	}
 
-	printf(" ]\n");
+	printf_hyphen(']');
 	printf(".RE\n");
 }
 
@@ -2845,7 +2866,7 @@ static void _print_man_usage_common_lvm(struct command *cmd)
 				printf(" ");
 				_print_def_man(cname, opt_enum, &cmd->optional_opt_args[oo].def, 1);
 			}
-			printf(" ]\n");
+			printf_hyphen(']');
 			printf(".ad b\n");
 			sep = 1;
 			break;
@@ -2880,7 +2901,7 @@ static void _print_man_usage_common_lvm(struct command *cmd)
 				printf(" ");
 				_print_def_man(cname, opt_enum, &cmd->optional_opt_args[oo].def, 1);
 			}
-			printf(" ]\n");
+			printf_hyphen(']');
 			printf(".ad b\n");
 			sep = 1;
 			break;
@@ -2942,7 +2963,7 @@ static void _print_man_usage_common_cmd(struct command *cmd)
 				printf(" ");
 				_print_def_man(cname, opt_enum, &cmd->optional_opt_args[oo].def, 1);
 			}
-			printf(" ]\n");
+			printf_hyphen(']');
 			printf(".ad b\n");
 			sep = 1;
 			break;
@@ -2984,7 +3005,7 @@ static void _print_man_usage_common_cmd(struct command *cmd)
 				printf(" ");
 				_print_def_man(cname, opt_enum, &cmd->optional_opt_args[oo].def, 1);
 			}
-			printf(" ]\n");
+			printf_hyphen(']');
 			printf(".ad b\n");
 			sep = 1;
 			break;


