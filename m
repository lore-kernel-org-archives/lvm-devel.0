From: David Teigland <teigland@sourceware.org>
Date: Wed, 14 Apr 2021 22:25:24 +0000 (GMT)
Subject: main - man/help: change LV type listing
Message-ID: <20210414222524.89880385800A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8daf5cd45f7767d9b0cfdfde67e95e23d21f859c
Commit:        8daf5cd45f7767d9b0cfdfde67e95e23d21f859c
Parent:        353718785fb9da3bebe59d6f1011b1f1df0c61d1
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Apr 14 16:34:04 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Apr 14 17:25:10 2021 -0500

man/help: change LV type listing

Previously, accepted LV types were presented as a series of suffixes
after the "LV" on the command line.  The addition of many new types
resulted in this becoming too long, e.g

  lvconvert --type cache --cachepool LV LV_linear_striped_thinpool_vdo_vdopool_vdopooldata_raid

For man pages, move these types from the command line to a new line
dedicated to listing accepted LV types:

  lvconvert --type cache --cachepool LV LV1
  ...

  LV1 types: linear striped thinpool vdo vdopool vdopooldata raid

The special "LV1" is used as a reference to avoid confusion
with other LVs that may appear on the command line.  There
are currently no commands with more than one typed LV, but
if there are cases with more, then "LV2" could also be used.

For command line usage/-h output, drop the LV types from the
command line specification.  The more detailed is not needed
in the help output and can be found in the man page.
---
 tools/command.c | 91 +++++++++++++++++++++++++++++++++++++--------------------
 1 file changed, 60 insertions(+), 31 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index 52acc70a5..e776edaa2 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -34,6 +34,8 @@
 #include <ctype.h>
 #include <getopt.h>
 
+const char *_lvt_enum_to_name(int lvt_enum);
+
 /*
  * This file can be compiled by itself as a man page generator.
  */
@@ -1719,7 +1721,7 @@ void configure_command_option_values(const char *name)
 
 /* type_LVT to "type" */
 
-static const char *_lvt_enum_to_name(int lvt_enum)
+const char *_lvt_enum_to_name(int lvt_enum)
 {
 	return lv_types[lvt_enum].name;
 }
@@ -1789,7 +1791,6 @@ static void _print_val_usage(struct command *cmd, int opt_enum, int val_enum)
 static void _print_usage_def(struct command *cmd, int opt_enum, struct arg_def *def)
 {
 	int val_enum;
-	int lvt_enum;
 	int sep = 0;
 
 	for (val_enum = 0; val_enum < VAL_COUNT; val_enum++) {
@@ -1807,12 +1808,16 @@ static void _print_usage_def(struct command *cmd, int opt_enum, struct arg_def *
 				sep = 1;
 			}
 
+			/* Too many types have made this too long.  man page has this info. */
+			/*
 			if (val_enum == lv_VAL && def->lvt_bits) {
+				int lvt_enum;
 				for (lvt_enum = 1; lvt_enum < LVT_COUNT; lvt_enum++) {
 					if (lvt_bit_is_set(def->lvt_bits, lvt_enum))
 						printf("_%s", _lvt_enum_to_name(lvt_enum));
 				}
 			}
+			*/
 
 			if ((val_enum == vg_VAL) && (def->flags & ARG_DEF_FLAG_NEW_VG))
 				printf("_new");
@@ -2385,12 +2390,14 @@ static void _print_val_man(struct command_name *cname, int opt_enum, int val_enu
 	printf("\\fB%s\\fP", str);
 }
 
-static void _print_def_man(struct command_name *cname, int opt_enum, struct arg_def *def, int usage)
+static void _print_def_man(struct command_name *cname, int opt_enum, struct arg_def *def, int usage, uint64_t *lv_type_bits)
 {
 	int val_enum;
-	int lvt_enum;
 	int sep = 0;
 
+	if (lv_type_bits)
+		*lv_type_bits = 0;
+
 	for (val_enum = 0; val_enum < VAL_COUNT; val_enum++) {
 		if (def->val_bits & val_enum_to_bit(val_enum)) {
 
@@ -2408,22 +2415,21 @@ static void _print_def_man(struct command_name *cname, int opt_enum, struct arg_
 						printf("\n");
 						_was_hyphen = 0;
 					}
-					printf("\\fI%s\\fP", val_names[val_enum].name);
-				} else
+
+					/* special case to print LV1 instead of LV */
+					if ((val_enum == lv_VAL) && def->lvt_bits && lv_type_bits) {
+						printf("\\fILV1\\fP");
+						*lv_type_bits = def->lvt_bits;
+					} else {
+						printf("\\fI%s\\fP", val_names[val_enum].name);
+					}
+				} else {
 					_print_val_man(cname, opt_enum, val_enum);
+				}
 
 				sep = 1;
 			}
 
-			if (val_enum == lv_VAL && def->lvt_bits) {
-				printf("\\fI");
-				for (lvt_enum = 1; lvt_enum < LVT_COUNT; lvt_enum++) {
-					if (lvt_bit_is_set(def->lvt_bits, lvt_enum))
-						printf("_%s", _lvt_enum_to_name(lvt_enum));
-				}
-				printf("\\fP");
-			}
-
 			if (((val_enum == vg_VAL) && (def->flags & ARG_DEF_FLAG_NEW_VG)) ||
 			    ((val_enum == lv_VAL) && (def->flags & ARG_DEF_FLAG_NEW_LV)))
 				printf("\\fI_new\\fP");
@@ -2485,6 +2491,8 @@ static void _print_man_usage(char *lvmname, struct command *cmd)
 	int sep, ro, rp, oo, op, opt_enum;
 	int need_ro_indent_end = 0;
 	int include_extents = 0;
+	int lvt_enum;
+	uint64_t lv_type_bits = 0;
 
 	_was_hyphen = 0;
 	if (!(cname = _find_command_name(cmd->name)))
@@ -2523,7 +2531,7 @@ static void _print_man_usage(char *lvmname, struct command *cmd)
 
 			if (cmd->required_opt_args[ro].def.val_bits) {
 				printf(" ");
-				_print_def_man(cname, opt_enum, &cmd->required_opt_args[ro].def, 1);
+				_print_def_man(cname, opt_enum, &cmd->required_opt_args[ro].def, 1, NULL);
 			}
 
 			sep++;
@@ -2571,7 +2579,7 @@ static void _print_man_usage(char *lvmname, struct command *cmd)
 
 			if (cmd->required_opt_args[ro].def.val_bits) {
 				printf(" ");
-				_print_def_man(cname, opt_enum, &cmd->required_opt_args[ro].def, 1);
+				_print_def_man(cname, opt_enum, &cmd->required_opt_args[ro].def, 1, NULL);
 			}
 
 			sep++;
@@ -2595,7 +2603,7 @@ static void _print_man_usage(char *lvmname, struct command *cmd)
 
 			if (cmd->required_opt_args[ro].def.val_bits) {
 				printf(" ");
-				_print_def_man(cname, opt_enum, &cmd->required_opt_args[ro].def, 1);
+				_print_def_man(cname, opt_enum, &cmd->required_opt_args[ro].def, 1, NULL);
 			}
 
 			sep++;
@@ -2611,7 +2619,7 @@ static void _print_man_usage(char *lvmname, struct command *cmd)
 		for (rp = 0; rp < cmd->rp_count; rp++) {
 			if (cmd->required_pos_args[rp].def.val_bits) {
 				printf(" ");
-				_print_def_man(cname, 0, &cmd->required_pos_args[rp].def, 1);
+				_print_def_man(cname, 0, &cmd->required_pos_args[rp].def, 1, NULL);
 			}
 		}
 
@@ -2656,7 +2664,7 @@ static void _print_man_usage(char *lvmname, struct command *cmd)
 
 			if (cmd->required_opt_args[ro].def.val_bits) {
 				printf(" ");
-				_print_def_man(cname, opt_enum, &cmd->required_opt_args[ro].def, 1);
+				_print_def_man(cname, opt_enum, &cmd->required_opt_args[ro].def, 1, NULL);
 			}
 
 			sep++;
@@ -2668,7 +2676,8 @@ static void _print_man_usage(char *lvmname, struct command *cmd)
 		for (rp = 0; rp < cmd->rp_count; rp++) {
 			if (cmd->required_pos_args[rp].def.val_bits) {
 				printf(" ");
-				_print_def_man(cname, 0, &cmd->required_pos_args[rp].def, 1);
+				/* Only print lv_type_bits for one LV arg (no cases exist with more) */
+				_print_def_man(cname, 0, &cmd->required_pos_args[rp].def, 1, lv_type_bits ? NULL : &lv_type_bits);
 			}
 		}
 
@@ -2730,7 +2739,7 @@ static void _print_man_usage(char *lvmname, struct command *cmd)
 
 			if (cmd->optional_opt_args[oo].def.val_bits) {
 				printf(" ");
-				_print_def_man(cname, opt_enum, &cmd->optional_opt_args[oo].def, 1);
+				_print_def_man(cname, opt_enum, &cmd->optional_opt_args[oo].def, 1, NULL);
 			}
 			printf_hyphen(']');
 			printf(".ad b\n");
@@ -2762,7 +2771,7 @@ static void _print_man_usage(char *lvmname, struct command *cmd)
 
 			if (cmd->optional_opt_args[oo].def.val_bits) {
 				printf(" ");
-				_print_def_man(cname, opt_enum, &cmd->optional_opt_args[oo].def, 1);
+				_print_def_man(cname, opt_enum, &cmd->optional_opt_args[oo].def, 1, NULL);
 			}
 			printf_hyphen(']');
 			printf(".ad b\n");
@@ -2781,7 +2790,7 @@ static void _print_man_usage(char *lvmname, struct command *cmd)
 
  op_count:
 	if (!cmd->op_count)
-		return;
+		goto out;
 
 	printf(".RS 4\n");
 	printf("[");
@@ -2790,13 +2799,32 @@ static void _print_man_usage(char *lvmname, struct command *cmd)
 		for (op = 0; op < cmd->op_count; op++) {
 			if (cmd->optional_pos_args[op].def.val_bits) {
 				printf(" ");
-				_print_def_man(cname, 0, &cmd->optional_pos_args[op].def, 1);
+				_print_def_man(cname, 0, &cmd->optional_pos_args[op].def, 1, NULL);
 			}
 		}
 	}
 
 	printf_hyphen(']');
 	printf(".RE\n");
+
+out:
+	if (!lv_type_bits)
+		return;
+
+	printf(".br\n");
+	printf("\n");
+	printf(".RS 4\n");
+
+	if (lv_type_bits) {
+		printf("LV1 types:");
+		for (lvt_enum = 1; lvt_enum < LVT_COUNT; lvt_enum++) {
+			if (lvt_bit_is_set(lv_type_bits, lvt_enum))
+				printf(" %s", _lvt_enum_to_name(lvt_enum));
+		}
+		printf("\n");
+	}
+	printf(".RE\n");
+	printf(".br\n");
 }
 
 /*
@@ -2855,7 +2883,7 @@ static void _print_man_usage_common_lvm(struct command *cmd)
 
 			if (cmd->optional_opt_args[oo].def.val_bits) {
 				printf(" ");
-				_print_def_man(cname, opt_enum, &cmd->optional_opt_args[oo].def, 1);
+				_print_def_man(cname, opt_enum, &cmd->optional_opt_args[oo].def, 1, NULL);
 			}
 			printf_hyphen(']');
 			printf(".ad b\n");
@@ -2890,7 +2918,7 @@ static void _print_man_usage_common_lvm(struct command *cmd)
 
 			if (cmd->optional_opt_args[oo].def.val_bits) {
 				printf(" ");
-				_print_def_man(cname, opt_enum, &cmd->optional_opt_args[oo].def, 1);
+				_print_def_man(cname, opt_enum, &cmd->optional_opt_args[oo].def, 1, NULL);
 			}
 			printf_hyphen(']');
 			printf(".ad b\n");
@@ -2952,7 +2980,7 @@ static void _print_man_usage_common_cmd(struct command *cmd)
 
 			if (cmd->optional_opt_args[oo].def.val_bits) {
 				printf(" ");
-				_print_def_man(cname, opt_enum, &cmd->optional_opt_args[oo].def, 1);
+				_print_def_man(cname, opt_enum, &cmd->optional_opt_args[oo].def, 1, NULL);
 			}
 			printf_hyphen(']');
 			printf(".ad b\n");
@@ -2994,7 +3022,7 @@ static void _print_man_usage_common_cmd(struct command *cmd)
 
 			if (cmd->optional_opt_args[oo].def.val_bits) {
 				printf(" ");
-				_print_def_man(cname, opt_enum, &cmd->optional_opt_args[oo].def, 1);
+				_print_def_man(cname, opt_enum, &cmd->optional_opt_args[oo].def, 1, NULL);
 			}
 			printf_hyphen(']');
 			printf(".ad b\n");
@@ -3274,8 +3302,9 @@ static void _print_man_all_positions_desc(struct command_name *cname)
 		       "An LV positional arg generally includes the VG name and LV name, e.g. VG/LV.\n");
 
 		if (has_lv_type)
-			printf("LV followed by _<type> indicates that an LV of the\n"
-			       "given type is required. (raid represents raid<N> type)\n");
+			printf("LV1 indicates the LV must have a specific type, where the\n"
+			       "accepted LV types are listed. (raid represents raid<N> type).\n");
+
 	}
 
 	if (has_pv_val) {


