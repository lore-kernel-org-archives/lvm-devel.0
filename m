From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 19 Apr 2021 13:00:52 +0000 (GMT)
Subject: main - man-generator: markup updates
Message-ID: <20210419130052.C29D8396903B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7bde16f5e17e8379f47696c731849176cd2f83b0
Commit:        7bde16f5e17e8379f47696c731849176cd2f83b0
Parent:        d94e5ba5afad7297852e4826be21ae30d39f9541
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Apr 17 00:21:31 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 19 14:40:07 2021 +0200

man-generator: markup updates

Emit .ad l / .ad b less frequently around larger blocks
we want to keep left aligned.

Avoid emittting empty lines.

Reduce .HP usage and replace it with .TP.
However keep .HP for all option listings, as i.e. html rendering
can't handle well combintion of .TP an .HP together and .TP alone
is not indenting 2nd. line of long option line.
(For .TP line we don't need to emit .br)

Surround .SH with dots for better look.

For some .TP use plain more readable .I for a line.

Support rendering of optional [Number] (for --units).

Use better markup for units and instead of long markup string,
show individual units with markup.
---
 tools/command.c | 166 ++++++++++++++++++++++++++++----------------------------
 1 file changed, 84 insertions(+), 82 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index cb261531c..b78271373 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -35,7 +35,7 @@
 #include <getopt.h>
 
 const char *_lvt_enum_to_name(int lvt_enum);
-
+const size_t _LONG_LINE = 42; /* length of line that neededs .nh .. .hy */
 /*
  * This file can be compiled by itself as a man page generator.
  */
@@ -2180,7 +2180,7 @@ void print_usage_common_cmd(struct command_name *cname, struct command *cmd)
 		printf(" ]");
 	}
 
-	printf("\n\n");
+	printf(".P\n");
 }
 
 void print_usage_notes(struct command_name *cname)
@@ -2369,13 +2369,19 @@ static void _print_val_man(struct command_name *cname, int opt_enum, int val_enu
 	if (strchr(str, '|')) {
 		if (!(line = strdup(str)))
 			return;
-		if ((_was_hyphen = (strlen(line) > 42)))
+		if ((_was_hyphen = (strlen(line) > _LONG_LINE)))
 			/* TODO: prevent line to end with already printed space */
-			printf("\n.nh\n");
+			printf("\\c\n.nh\n\\%%");
 		_split_line(line, &line_argc, line_argv, '|');
 		for (i = 0; i < line_argc; i++) {
 			if (i)
 				printf("|%s", _was_hyphen ? "\\:" : "");
+
+			if (strncmp(line_argv[i], "[Number]", 8) == 0) {
+				printf("[\\fINumber\\fP]");
+				line_argv[i] += 8;
+			}
+
 			if (strstr(line_argv[i], "Number"))
 				printf("\\fI%s\\fP", line_argv[i]);
 			else
@@ -2719,6 +2725,7 @@ static void _print_man_usage(char *lvmname, struct command *cmd)
 
 	if (cmd->oo_count) {
 		printf(".RS 4\n");
+		printf(".ad l\n");
 
 		if (include_extents) {
 			/*
@@ -2726,12 +2733,10 @@ static void _print_man_usage(char *lvmname, struct command *cmd)
 			 * actual val type for extents_ARG has been adjusted
 			 * in opt_names[] according to the command name.
 			 */
-			printf(".ad l\n");
 			printf("[ \\fB-l\\fP|\\fB--extents\\fP ");
 			_print_val_man(cname, extents_ARG, opt_names[extents_ARG].val_enum);
 
 			printf_hyphen(']');
-			printf(".ad b\n");
 			sep = 1;
 		}
 
@@ -2751,7 +2756,6 @@ static void _print_man_usage(char *lvmname, struct command *cmd)
 
 			if (sep)
 				printf(".br\n");
-			printf(".ad l\n");
 
 			printf("[ \\fB-%c\\fP|\\fB%s\\fP",
 				opt_names[opt_enum].short_opt,
@@ -2762,7 +2766,6 @@ static void _print_man_usage(char *lvmname, struct command *cmd)
 				_print_def_man(cname, opt_enum, &cmd->optional_opt_args[oo].def, 1, NULL);
 			}
 			printf_hyphen(']');
-			printf(".ad b\n");
 			sep = 1;
 		}
 
@@ -2782,7 +2785,6 @@ static void _print_man_usage(char *lvmname, struct command *cmd)
 
 			if (sep)
 				printf(".br\n");
-			printf(".ad l\n");
 
 			/* space alignment without short opt */
 			printf("[   ");
@@ -2794,7 +2796,6 @@ static void _print_man_usage(char *lvmname, struct command *cmd)
 				_print_def_man(cname, opt_enum, &cmd->optional_opt_args[oo].def, 1, NULL);
 			}
 			printf_hyphen(']');
-			printf(".ad b\n");
 			sep = 1;
 		}
 
@@ -2804,8 +2805,8 @@ static void _print_man_usage(char *lvmname, struct command *cmd)
 			/* printf("   "); */
 		}
 		printf("[ COMMON_OPTIONS ]\n");
+		printf(".ad b\n");
 		printf(".RE\n");
-		printf(".br\n");
 	}
 
  op_count:
@@ -2828,11 +2829,10 @@ static void _print_man_usage(char *lvmname, struct command *cmd)
 	printf(".RE\n");
 
 out:
+	printf(".P\n");
 	if (!lv_type_bits)
 		return;
 
-	printf(".br\n");
-	printf("\n");
 	printf(".RS 4\n");
 
 	if (lv_type_bits) {
@@ -2844,7 +2844,7 @@ out:
 		printf("\n");
 	}
 	printf(".RE\n");
-	printf(".br\n");
+	printf(".P\n");
 }
 
 /*
@@ -2878,6 +2878,7 @@ static void _print_man_usage_common_lvm(struct command *cmd)
 	sep = 0;
 
 	printf(".RS 4\n");
+	printf(".ad l\n");
 
 	/* print those with short opts */
 	for (i = 0; i < ARG_COUNT; i++) {
@@ -2891,7 +2892,6 @@ static void _print_man_usage_common_lvm(struct command *cmd)
 
 		if (sep)
 			printf(".br\n");
-		printf(".ad l\n");
 
 		for (oo = 0; oo < cmd->oo_count; oo++) {
 			if (cmd->optional_opt_args[oo].opt != opt_enum)
@@ -2906,7 +2906,6 @@ static void _print_man_usage_common_lvm(struct command *cmd)
 				_print_def_man(cname, opt_enum, &cmd->optional_opt_args[oo].def, 1, NULL);
 			}
 			printf_hyphen(']');
-			printf(".ad b\n");
 			sep = 1;
 			break;
 		}
@@ -2925,7 +2924,6 @@ static void _print_man_usage_common_lvm(struct command *cmd)
 
 		if (sep)
 			printf(".br\n");
-		printf(".ad l\n");
 
 		for (oo = 0; oo < cmd->oo_count; oo++) {
 			if (cmd->optional_opt_args[oo].opt != opt_enum)
@@ -2941,14 +2939,13 @@ static void _print_man_usage_common_lvm(struct command *cmd)
 				_print_def_man(cname, opt_enum, &cmd->optional_opt_args[oo].def, 1, NULL);
 			}
 			printf_hyphen(']');
-			printf(".ad b\n");
 			sep = 1;
 			break;
 		}
 	}
 
+	printf(".ad b\n");
 	printf(".RE\n");
-	return;
 }
 
 static void _print_man_usage_common_cmd(struct command *cmd)
@@ -2968,6 +2965,7 @@ static void _print_man_usage_common_cmd(struct command *cmd)
 	sep = 0;
 
 	printf(".RS 4\n");
+	printf(".ad l\n");
 
 	/* print those with short opts */
 	for (i = 0; i < ARG_COUNT; i++) {
@@ -2988,7 +2986,6 @@ static void _print_man_usage_common_cmd(struct command *cmd)
 
 		if (sep)
 			printf(".br\n");
-		printf(".ad l\n");
 
 		for (oo = 0; oo < cmd->oo_count; oo++) {
 			if (cmd->optional_opt_args[oo].opt != opt_enum)
@@ -3003,11 +3000,9 @@ static void _print_man_usage_common_cmd(struct command *cmd)
 				_print_def_man(cname, opt_enum, &cmd->optional_opt_args[oo].def, 1, NULL);
 			}
 			printf_hyphen(']');
-			printf(".ad b\n");
 			sep = 1;
 			break;
 		}
-
 	}
 
 	/* print those without short opts */
@@ -3029,7 +3024,6 @@ static void _print_man_usage_common_cmd(struct command *cmd)
 
 		if (sep)
 			printf(".br\n");
-		printf(".ad l\n");
 
 		for (oo = 0; oo < cmd->oo_count; oo++) {
 			if (cmd->optional_opt_args[oo].opt != opt_enum)
@@ -3045,15 +3039,14 @@ static void _print_man_usage_common_cmd(struct command *cmd)
 				_print_def_man(cname, opt_enum, &cmd->optional_opt_args[oo].def, 1, NULL);
 			}
 			printf_hyphen(']');
-			printf(".ad b\n");
 			sep = 1;
 			break;
 		}
 	}
 
+	printf(".ad b\n");
 	printf(".RE\n");
-	printf("\n");
-	return;
+	printf(".P\n");
 }
 
 /*
@@ -3146,6 +3139,7 @@ static void _print_man_all_options_list(struct command_name *cname)
 	int opt_enum, val_enum;
 	int sep = 0;
 	int i;
+	int adl = 0;
 
 	for (i = 0; i < ARG_COUNT; i++) {
 		opt_enum = opt_names_alpha[i]->opt_enum;
@@ -3155,7 +3149,11 @@ static void _print_man_all_options_list(struct command_name *cname)
 
 		if (sep)
 			printf(".br\n");
-		printf(".ad l\n");
+
+		if (!adl) {
+			printf(".ad l\n");
+			adl = 1;
+		}
 
 		if (opt_names[opt_enum].short_opt) {
 			printf(" \\fB-%c\\fP|\\fB%s\\fP",
@@ -3180,10 +3178,13 @@ static void _print_man_all_options_list(struct command_name *cname)
 			_print_val_man(cname, opt_enum, val_enum);
 		}
 
-		printf("\n.ad b\n");
-
+		printf("\n");
 		sep = 1;
 	}
+
+	if (adl)
+		printf(".ad b\n");
+
 }
 
 /*
@@ -3194,6 +3195,7 @@ static void _print_man_all_options_desc(struct command_name *cname)
 {
 	int opt_enum, val_enum;
 	int i;
+	int adl;
 
 	for (i = 0; i < ARG_COUNT; i++) {
 		opt_enum = opt_names_alpha[i]->opt_enum;
@@ -3201,9 +3203,22 @@ static void _print_man_all_options_desc(struct command_name *cname)
 		if (!cname->all_options[opt_enum])
 			continue;
 
-		printf(".HP\n");
+		val_enum = opt_names[opt_enum].val_enum;
 
-		printf(".ad l\n");
+		if (val_names[val_enum].usage &&
+		    (strlen(val_names[val_enum].usage) > _LONG_LINE)) {
+			printf(".\n.HP\n");
+			printf(".ad l\n");
+			adl = 1;
+		} else {
+			/* printf(".\n.TP\n");
+			 * ATM HTML rendering can't handle HP and TP mixing properly
+			 * so still keeping .HP usage for this case
+			 * untill some better workaround is found
+			 * .TP does not need .br */
+			printf(".\n.HP\n");
+			adl = 0;
+		}
 
 		if (opt_names[opt_enum].short_opt) {
 			printf("\\fB-%c\\fP|\\fB%s\\fP",
@@ -3213,7 +3228,6 @@ static void _print_man_all_options_desc(struct command_name *cname)
 			printf("\\fB%s\\fP", _man_long_opt_name(cname->name, opt_enum));
 		}
 
-		val_enum = opt_names[opt_enum].val_enum;
 
 		if (!val_names[val_enum].fn) {
 			/* takes no arg */
@@ -3230,13 +3244,15 @@ static void _print_man_all_options_desc(struct command_name *cname)
 		if (opt_names[opt_enum].flags & ARG_COUNTABLE)
 			printf(" ...");
 
-		if (opt_names[opt_enum].desc) {
-			printf("\n");
-			printf(".br\n");
+		printf("\n");
+		if (adl) {
 			printf(".ad b\n");
+		}
+		printf(".br\n");
+
+		if (opt_names[opt_enum].desc) {
 			_print_man_option_desc(cname, opt_enum);
-		} else
-			printf(".ad b\n");
+		}
 	}
 }
 
@@ -3299,11 +3315,9 @@ static void _print_man_all_positions_desc(struct command_name *cname)
 	}
 
 	if (has_vg_val) {
-		printf(".HP\n");
+		printf(".TP\n");
 
-		printf("\\fI%s\\fP", val_names[vg_VAL].name);
-		printf("\n");
-		printf(".br\n");
+		printf(".I %s\n", val_names[vg_VAL].name);
 		printf("Volume Group name.  See \\fBlvm\\fP(8) for valid names.\n");
 
 		if (!strcmp(cname->name, "lvcreate"))
@@ -3313,11 +3327,9 @@ static void _print_man_all_positions_desc(struct command_name *cname)
 	}
 
 	if (has_lv_val) {
-		printf(".HP\n");
+		printf(".TP\n");
 
-		printf("\\fI%s\\fP", val_names[lv_VAL].name);
-		printf("\n");
-		printf(".br\n");
+		printf(".I %s\n", val_names[lv_VAL].name);
 		printf("Logical Volume name.  See \\fBlvm\\fP(8) for valid names.\n"
 		       "An LV positional arg generally includes the VG name and LV name, e.g. VG/LV.\n");
 
@@ -3328,11 +3340,9 @@ static void _print_man_all_positions_desc(struct command_name *cname)
 	}
 
 	if (has_pv_val) {
-		printf(".HP\n");
+		printf(".TP\n");
 
-		printf("\\fI%s\\fP", val_names[pv_VAL].name);
-		printf("\n");
-		printf(".br\n");
+		printf(".I %s\n", val_names[pv_VAL].name);
 		printf("Physical Volume name, a device path under /dev.\n"
 		       "For commands managing physical extents, a PV positional arg\n"
 		       "generally accepts a suffix indicating a range (or multiple ranges)\n"
@@ -3343,21 +3353,17 @@ static void _print_man_all_positions_desc(struct command_name *cname)
 	}
 
 	if (has_tag_val) {
-		printf(".HP\n");
+		printf(".TP\n");
 
-		printf("\\fI%s\\fP", val_names[tag_VAL].name);
-		printf("\n");
-		printf(".br\n");
+		printf(".I %s\n", val_names[tag_VAL].name);
 		printf("Tag name.  See \\fBlvm\\fP(8) for information about tag names and using tags\n"
 		       "in place of a VG, LV or PV.\n");
 	}
 
 	if (has_select_val) {
-		printf(".HP\n");
+		printf(".TP\n");
 
-		printf("\\fI%s\\fP", val_names[select_VAL].name);
-		printf("\n");
-		printf(".br\n");
+		printf(".I %s\n", val_names[select_VAL].name);
 		printf("Select indicates that a required positional parameter can\n"
 		       "be omitted if the \\fB--select\\fP option is used.\n"
 		       "No arg appears in this position.\n");
@@ -3365,10 +3371,8 @@ static void _print_man_all_positions_desc(struct command_name *cname)
 
 	/* Every command uses a string arg somewhere. */
 
-	printf(".HP\n");
-	printf("\\fI%s\\fP", val_names[string_VAL].name);
-	printf("\n");
-	printf(".br\n");
+	printf(".TP\n");
+	printf(".I %s\n", val_names[string_VAL].name);
 	printf("See the option description for information about the string content.\n");
 
 	/*
@@ -3377,21 +3381,20 @@ static void _print_man_all_positions_desc(struct command_name *cname)
 	 * so common that we should probably always print it.
 	 */
 
-	printf(".HP\n");
-	printf("\\fISize\\fP[UNIT]");
-	printf("\n");
-	printf(".br\n");
+	printf(".TP\n");
+	printf(".IR Size [UNIT]\n");
 	printf("Size is an input number that accepts an optional unit.\n"
 	       "Input units are always treated as base two values, regardless of\n"
 	       "capitalization, e.g. 'k' and 'K' both refer to 1024.\n"
 	       "The default input unit is specified by letter, followed by |UNIT.\n"
-	       "UNIT represents other possible input units: \\fBbBsSkKmMgGtTpPeE\\fP.\n"
-	       "b|B is bytes, s|S is sectors of 512 bytes, k|K is KiB,\n"
-	       "m|M is MiB, g|G is GiB, t|T is TiB, p|P is PiB, e|E is EiB.\n"
+	       "UNIT represents other possible input units:\n"
+	       ".BR b | B\nis bytes,\n.BR s | S\nis sectors of 512 bytes,\n.BR k | K\nis KiB,\n"
+	       ".BR m | M\nis MiB,\n.BR g | G\nis GiB,\n.BR t | T\nis TiB,\n"
+	       ".BR p | P\nis PiB,\n.BR e | E\nis EiB.\n"
 	       "(This should not be confused with the output control --units, where\n"
 	       "capital letters mean multiple of 1000.)\n");
 
-	printf(".SH ENVIRONMENT VARIABLES\n");
+	printf(".\n.SH ENVIRONMENT VARIABLES\n.\n");
 	printf("See \\fBlvm\\fP(8) for information about environment variables used by lvm.\n"
 	       "For example, LVM_VG_NAME can generally be substituted for a required VG parameter.\n");
 }
@@ -3482,7 +3485,7 @@ static int _include_description_file(char *name, char *des_file)
 	}
 
 	buf[sz] = '\0';
-	printf(".SH DESCRIPTION\n%s", buf);
+	printf(".\n.SH DESCRIPTION\n.\n%s", buf);
 	r = 1;
 
 out_free:
@@ -3518,9 +3521,9 @@ static int _print_man(char *name, char *des_file, int secondary)
 			_print_man_usage_common_cmd(prev_cmd);
 			_print_man_usage_common_lvm(prev_cmd);
 
-			printf(".SH OPTIONS\n");
+			printf(".\n.SH OPTIONS\n.\n");
 			_print_man_all_options_desc(cname);
-			printf(".SH VARIABLES\n");
+			printf(".\n.SH VARIABLES\n.\n");
 			_print_man_all_positions_desc(cname);
 
 			prev_cmd = NULL;
@@ -3536,14 +3539,13 @@ static int _print_man(char *name, char *des_file, int secondary)
 			continue;
 
 		if (!prev_cmd || strcmp(prev_cmd->name, cmd->name)) {
-			printf(".SH NAME\n");
+			printf(".\n.SH NAME\n.\n");
 			if (cname && cname->desc)
 				printf("%s \\(em %s\n", lvmname, cname->desc);
 			else
 				printf("%s\n", lvmname);
 
-			printf(".\n");
-			printf(".SH SYNOPSIS\n");
+			printf(".\n.SH SYNOPSIS\n.\n");
 			prev_cmd = cmd;
 
 			if (!(cname = _find_command_name(cmd->name)))
@@ -3579,7 +3581,7 @@ static int _print_man(char *name, char *des_file, int secondary)
 			if (des_file && !_include_description_file(lvmname, des_file))
 				return 0;
 
-			printf(".SH USAGE\n");
+			printf(".\n.SH USAGE\n.\n");
 		}
 
 		if (cmd->desc) {
@@ -3593,17 +3595,17 @@ static int _print_man(char *name, char *des_file, int secondary)
 			_print_man_usage_common_cmd(cmd);
 			_print_man_usage_common_lvm(cmd);
 
-			printf("\n");
-			printf(".SH OPTIONS\n");
+			printf(".\n.SH OPTIONS\n.\n");
 			_print_man_all_options_desc(cname);
-			printf(".SH VARIABLES\n");
+			printf(".\n.SH VARIABLES\n.\n");
 			_print_man_all_positions_desc(cname);
 		} else {
-			if (cname->variants > 2)
+			if (cname->variants > 2) {
 				printf("\\(em\n");
+				printf(".P\n");
+			}
 		}
 
-		printf("\n");
 		continue;
 	}
 
@@ -3634,7 +3636,7 @@ static void _print_man_secondary(char *name)
 			continue;
 
 		if (!header) {
-			printf(".SH ADVANCED USAGE\n");
+			printf(".\n.SH ADVANCED USAGE\n.\n");
 			printf("Alternate command forms, advanced command usage, and listing of all valid syntax for completeness.\n");
 			printf(".P\n");
 			header = 1;


