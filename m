From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Fri, 24 Mar 2017 13:58:01 -0400
Subject: master - man-generator: more escaped '-'
Message-ID: <201703241758.v2OHw16A010305@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=66b2084b96271350b840e492e9ea54b1e7eb2f01
Commit:        66b2084b96271350b840e492e9ea54b1e7eb2f01
Parent:        d823c65d508f95ad3cd491a047ae1953a55a5c3c
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Mar 24 18:57:45 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Mar 24 18:57:45 2017 +0100

man-generator: more escaped '-'

---
 tools/command.c |   30 +++++++++++++++---------------
 1 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index 4a2b21f..812366f 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -2140,7 +2140,7 @@ static void print_val_man(struct command_name *cname, int opt_enum, int val_enum
 	}
 
 	if (val_enum == ssizemb_VAL) {
-		printf("[\\fB+\\fP|\\fB-\\fP]\\fISize\\fP[m|UNIT]");
+		printf("[\\fB+\\fP|\\fB\\-\\fP]\\fISize\\fP[m|UNIT]");
 		return;
 	}
 
@@ -2150,7 +2150,7 @@ static void print_val_man(struct command_name *cname, int opt_enum, int val_enum
 	}
 
 	if (val_enum == nsizemb_VAL) {
-		printf("[\\fB-\\fP]\\fISize\\fP[m|UNIT]");
+		printf("[\\fB\\-\\fP]\\fISize\\fP[m|UNIT]");
 		return;
 	}
 
@@ -2160,7 +2160,7 @@ static void print_val_man(struct command_name *cname, int opt_enum, int val_enum
 	}
 
 	if (val_enum == sextents_VAL) {
-		printf("[\\fB+\\fP|\\fB-\\fP]\\fINumber\\fP[PERCENT]");
+		printf("[\\fB+\\fP|\\fB\\-\\fP]\\fINumber\\fP[PERCENT]");
 		return;
 	}
 
@@ -2170,7 +2170,7 @@ static void print_val_man(struct command_name *cname, int opt_enum, int val_enum
 	}
 
 	if (val_enum == nextents_VAL) {
-		printf("[\\fB-\\fP]\\fINumber\\fP[PERCENT]");
+		printf("[\\fB\\-\\fP]\\fINumber\\fP[PERCENT]");
 		return;
 	}
 
@@ -2180,7 +2180,7 @@ static void print_val_man(struct command_name *cname, int opt_enum, int val_enum
 	}
 
 	if (val_enum == ssizekb_VAL) {
-		printf("[\\fB+\\fP|\\fB-\\fP]\\fISize\\fP[k|UNIT]");
+		printf("[\\fB+\\fP|\\fB\\-\\fP]\\fISize\\fP[k|UNIT]");
 		return;
 	}
 
@@ -2190,7 +2190,7 @@ static void print_val_man(struct command_name *cname, int opt_enum, int val_enum
 	}
 
 	if (val_enum == snumber_VAL) {
-		printf("[\\fB+\\fP|\\fB-\\fP]\\fINumber\\fP");
+		printf("[\\fB+\\fP|\\fB\\-\\fP]\\fINumber\\fP");
 		return;
 	}
 
@@ -2400,7 +2400,7 @@ static void _print_man_usage(char *lvmname, struct command *cmd)
 			}
 
 			if (opt_names[opt_enum].short_opt) {
-				printf(" \\fB-%c\\fP|\\fB%s\\fP",
+				printf(" \\fB\\-%c\\fP|\\fB%s\\fP",
 				       opt_names[opt_enum].short_opt,
 				       man_long_opt_name(cmd->name, opt_enum));
 			} else {
@@ -2490,7 +2490,7 @@ static void _print_man_usage(char *lvmname, struct command *cmd)
 				include_extents = 1;
 
 			if (opt_names[opt_enum].short_opt) {
-				printf(" \\fB-%c\\fP|\\fB%s\\fP",
+				printf(" \\fB\\-%c\\fP|\\fB%s\\fP",
 				       opt_names[opt_enum].short_opt,
 				       man_long_opt_name(cmd->name, opt_enum));
 			} else {
@@ -2543,7 +2543,7 @@ static void _print_man_usage(char *lvmname, struct command *cmd)
 			 * in opt_names[] according to the command name.
 			 */
 			printf(".ad l\n");
-			printf("[ \\fB-l\\fP|\\fB\\-\\-extents\\fP ");
+			printf("[ \\fB\\-l\\fP|\\fB\\-\\-extents\\fP ");
 			print_val_man(cname, extents_ARG, opt_names[extents_ARG].val_enum);
 			printf(" ]\n");
 			printf(".ad b\n");
@@ -2568,7 +2568,7 @@ static void _print_man_usage(char *lvmname, struct command *cmd)
 				printf(".br\n");
 			printf(".ad l\n");
 
-			printf("[ \\fB-%c\\fP|\\fB%s\\fP",
+			printf("[ \\fB\\-%c\\fP|\\fB%s\\fP",
 				opt_names[opt_enum].short_opt,
 				man_long_opt_name(cmd->name, opt_enum));
 
@@ -2693,7 +2693,7 @@ static void _print_man_usage_common_lvm(struct command *cmd)
 			if (cmd->optional_opt_args[oo].opt != opt_enum)
 				continue;
 
-			printf("[ \\fB-%c\\fP|\\fB%s\\fP",
+			printf("[ \\fB\\-%c\\fP|\\fB%s\\fP",
 				opt_names[opt_enum].short_opt,
 				man_long_opt_name(cmd->name, opt_enum));
 
@@ -2790,7 +2790,7 @@ static void _print_man_usage_common_cmd(struct command *cmd)
 			if (cmd->optional_opt_args[oo].opt != opt_enum)
 				continue;
 
-			printf("[ \\fB-%c\\fP|\\fB%s\\fP",
+			printf("[ \\fB\\-%c\\fP|\\fB%s\\fP",
 				opt_names[opt_enum].short_opt,
 				man_long_opt_name(cmd->name, opt_enum));
 
@@ -2953,7 +2953,7 @@ static void _print_man_all_options_list(struct command_name *cname)
 		printf(".ad l\n");
 
 		if (opt_names[opt_enum].short_opt) {
-			printf(" \\fB-%c\\fP|\\fB%s\\fP",
+			printf(" \\fB\\-%c\\fP|\\fB%s\\fP",
 				opt_names[opt_enum].short_opt,
 				man_long_opt_name(cname->name, opt_enum));
 		} else {
@@ -3001,7 +3001,7 @@ static void _print_man_all_options_desc(struct command_name *cname)
 		printf(".ad l\n");
 
 		if (opt_names[opt_enum].short_opt) {
-			printf("\\fB-%c\\fP|\\fB%s\\fP",
+			printf("\\fB\\-%c\\fP|\\fB%s\\fP",
 			       opt_names[opt_enum].short_opt,
 			       man_long_opt_name(cname->name, opt_enum));
 		} else {
@@ -3132,7 +3132,7 @@ static void _print_man_all_positions_desc(struct command_name *cname)
 		       "generally accepts a suffix indicating a range (or multiple ranges)\n"
 		       "of physical extents (PEs). When the first PE is omitted, it defaults\n"
 		       "to the start of the device, and when the last PE is omitted it defaults to end.\n"
-		       "Start and end range (inclusive): \\fIPV\\fP[\\fB:\\fP\\fIPE\\fP\\fB-\\fP\\fIPE\\fP]...\n"
+		       "Start and end range (inclusive): \\fIPV\\fP[\\fB:\\fP\\fIPE\\fP\\fB\\-\\fP\\fIPE\\fP]...\n"
 		       "Start and length range (counting from 0): \\fIPV\\fP[\\fB:\\fP\\fIPE\\fP\\fB+\\fP\\fIPE\\fP]...\n");
 	}
 


