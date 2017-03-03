From: David Teigland <teigland@sourceware.org>
Date: Fri, 3 Mar 2017 15:27:12 -0500
Subject: master - man/help: rework extents and size output
Message-ID: <201703032027.v23KRCo8013373@int-mx14.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9a50df291a616e4fe2b0f569b41ac3b2b7d08a33
Commit:        9a50df291a616e4fe2b0f569b41ac3b2b7d08a33
Parent:        e7ee89d80b0b876cd73573338022b1308d59b209
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Mar 3 14:21:36 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Mar 3 14:23:50 2017 -0600

man/help: rework extents and size output

Clean up and correct the details around --extents and --size.

lvcreate/lvresize/lvreduce/lvextend all now display the
extents option in usages.

The Size and Number value variables for --size and --extents
are now displayed without the [+|-] prefix for lvcreate.
---
 man/lvcreate.8.des |    2 +-
 man/lvextend.8.des |    4 +
 man/lvreduce.8.des |    5 ++
 man/lvresize.8.des |    5 ++
 tools/args.h       |   15 +++-
 tools/command.c    |  177 ++++++++++++++++++++++++++++------------------------
 tools/command.h    |    1 +
 tools/lvmcmdline.c |   10 +--
 tools/vals.h       |    4 +-
 9 files changed, 128 insertions(+), 95 deletions(-)

diff --git a/man/lvcreate.8.des b/man/lvcreate.8.des
index b77006b..acc07b3 100644
--- a/man/lvcreate.8.des
+++ b/man/lvcreate.8.des
@@ -29,7 +29,7 @@ to improve performance.
 .SS Usage notes
 
 In the usage section below, \fB--size\fP \fISize\fP can be replaced
-in each case with \fB--extents\fP \fINumber\fP.  See both descriptions
+with \fB--extents\fP \fINumber\fP.  See both descriptions
 the options section.
 
 In the usage section below, \fB--name\fP is omitted from the required
diff --git a/man/lvextend.8.des b/man/lvextend.8.des
index 2a3781d..346bd23 100644
--- a/man/lvextend.8.des
+++ b/man/lvextend.8.des
@@ -3,3 +3,7 @@ extents from the VG's free physical extents. A copy\-on\-write snapshot LV
 can also be extended to provide more space to hold COW blocks. Use
 \fBlvconvert\fP(8) to change the number of data images in a RAID or
 mirrored LV.
+
+In the usage section below, \fB--size\fP \fISize\fP can be replaced
+with \fB--extents\fP \fINumber\fP.  See both descriptions
+the options section.
diff --git a/man/lvreduce.8.des b/man/lvreduce.8.des
index 7f0ba0c..3d5fc2a 100644
--- a/man/lvreduce.8.des
+++ b/man/lvreduce.8.des
@@ -12,3 +12,8 @@ system.
 Sizes will be rounded if necessary. For example, the LV size must be an
 exact number of extents, and the size of a striped segment must be a
 multiple of the number of stripes.
+
+In the usage section below, \fB--size\fP \fISize\fP can be replaced
+with \fB--extents\fP \fINumber\fP.  See both descriptions
+the options section.
+
diff --git a/man/lvresize.8.des b/man/lvresize.8.des
index 7fdcacc..6f39ef7 100644
--- a/man/lvresize.8.des
+++ b/man/lvresize.8.des
@@ -1,2 +1,7 @@
 lvresize resizes an LV in the same way as lvextend and lvreduce. See
 \fBlvextend\fP(8) and \fBlvreduce\fP(8) for more information.
+
+In the usage section below, \fB--size\fP \fISize\fP can be replaced
+with \fB--extents\fP \fINumber\fP.  See both descriptions
+the options section.
+
diff --git a/tools/args.h b/tools/args.h
index 83700b3..5512bed 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -1022,10 +1022,9 @@ arg(extents_ARG, 'l', "extents", extents_VAL, 0, 0,
     "When expressed as a percentage, the size defines an upper limit for the\n"
     "number of logical extents in the new LV. The precise number of logical\n"
     "extents in the new LV is not determined until the command has completed.\n"
-    "The plus prefix \\fB+\\fP can be used, in which case\n"
-    "the value is added to the current size,\n"
-    "or the minus prefix \\fB-\\fP can be used, in which case\n"
-    "the value is subtracted from the current size.\n")
+    "The plus \\fB+\\fP or minus \\fB-\\fP prefix can be used, in which case\n"
+    "the value is not an absolute size, but is an amount added or subtracted\n"
+    "relative to the current size.\n")
 
 arg(list_ARG, 'l', "list", 0, 0, 0,
     "#lvmconfig\n"
@@ -1042,6 +1041,14 @@ arg(list_ARG, 'l', "list", 0, 0, 0,
 arg(lvmpartition_ARG, 'l', "lvmpartition", 0, 0, 0,
     "Only report PVs.\n")
 
+/*
+ * FIXME: for lvcreate, size only accepts absolute values, no +|-,
+ * for lvresize, size can relative +|-, for lvreduce, size
+ * can be relative -, and for lvextend, size can be relative +.
+ * Should we define separate val enums for each of those cases,
+ * and at the start of the command, change the val type for
+ * size_ARG?  The same for extents_ARG.
+ */
 arg(size_ARG, 'L', "size", ssizemb_VAL, 0, 0,
     "#lvcreate\n"
     "Specifies the size of the new LV.\n"
diff --git a/tools/command.c b/tools/command.c
index 7f6bd2b..cab6f09 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -1319,6 +1319,20 @@ void factor_common_options(void)
 	}
 }
 
+/* FIXME: use a flag in command_name struct? */
+
+int command_has_alternate_extents(const char *name)
+{
+	if (name[0] != 'l')
+		return 0;
+	if (!strcmp(name, "lvcreate") ||
+	    !strcmp(name, "lvresize") ||
+	    !strcmp(name, "lvextend") ||
+	    !strcmp(name, "lvreduce"))
+		return 1;
+	return 0;
+}
+
 static int long_name_compare(const void *on1, const void *on2)
 {
 	const struct opt_name * const *optname1 = (const void *)on1;
@@ -1574,6 +1588,33 @@ static void _print_usage_description(struct command *cmd)
 	}
 }
 
+static void print_val_usage(struct command *cmd, int val_enum)
+{
+	int squash_sign_prefix;
+
+	/*
+	 * lvcreate does not take a relative [+|-] value
+	 * for --size or --extents.
+	 * Should we also squash - for lvextend and + for lvreduce?
+	 */
+	squash_sign_prefix = !strcmp(cmd->name, "lvcreate");
+
+	if ((val_enum == ssizemb_VAL) && squash_sign_prefix) {
+		printf("Size[m|UNIT]");
+		return;
+	}
+
+	if ((val_enum == extents_VAL) && squash_sign_prefix) {
+		printf("Number[PERCENT]");
+		return;
+	}
+
+	if (!val_names[val_enum].usage)
+		printf("%s", val_names[val_enum].name);
+	else
+		printf("%s", val_names[val_enum].usage);
+}
+
 static void print_usage_def(struct command *cmd, int opt_enum, struct arg_def *def)
 {
 	int val_enum;
@@ -1591,25 +1632,7 @@ static void print_usage_def(struct command *cmd, int opt_enum, struct arg_def *d
 
 			else {
 				if (sep) printf("|");
-
-				/*
-				 * FIXME: this is a terrible hack that's needed
-				 * until we can differentiate which commands
-				 * use --size with a signed number and which
-				 * commands use only a positive --size.
-				 * (See the same hack when generating man pages
-				 * in print_val_man.)
-				 */
-				if (!strcmp(cmd->name, "lvcreate") &&
-				    (opt_enum == size_ARG) &&
-				    (!strcmp(val_names[val_enum].usage, "[+|-]Size[m|UNIT]")))
-					printf("Size[m|UNIT]");
-
-				else if (!val_names[val_enum].usage)
-					printf("%s", val_names[val_enum].name);
-				else
-					printf("%s", val_names[val_enum].usage);
-
+				print_val_usage(cmd, val_enum);
 				sep = 1;
 			}
 
@@ -1655,8 +1678,7 @@ void print_usage(struct command *cmd, int longhelp, int desc_first)
 		for (ro = 0; ro < cmd->ro_count; ro++) {
 			opt_enum = cmd->required_opt_args[ro].opt;
 
-			/* special case */
-			if (!strcmp(cmd->name, "lvcreate") && (opt_enum == size_ARG))
+			if ((opt_enum == size_ARG) && command_has_alternate_extents(cmd->name))
 				include_extents = 1;
 
 			if (onereq) {
@@ -1695,8 +1717,11 @@ void print_usage(struct command *cmd, int longhelp, int desc_first)
 		goto op_count;
 
 	if (cmd->oo_count) {
-		if (include_extents)
-			printf("\n\t[ --extents Number[PERCENT] ]");
+		if (include_extents) {
+			printf("\n\t[ --extents ");
+			print_val_usage(cmd, extents_VAL);
+			printf(" ]");
+		}
 
 		for (oo = 0; oo < cmd->oo_count; oo++) {
 			opt_enum = cmd->optional_opt_args[oo].opt;
@@ -1827,13 +1852,15 @@ void print_usage_common_cmd(struct command_name *cname, struct command *cmd)
 
 void print_usage_notes(struct command_name *cname, struct command *cmd)
 {
-
-	if (!strcmp(cname->name, "lvcreate")) {
+	if (command_has_alternate_extents(cname->name)) {
 		printf("  Special options for command:\n");
 		printf("        [ --extents Number[PERCENT] ]\n"
-		       "        The --extents option can be used in place of --size in each case.\n"
-		       "        The number allows an optional percent suffix (see man lvcreate).\n");
+		       "        The --extents option can be used in place of --size.\n"
+		       "        The number allows an optional percent suffix.\n");
 		printf("\n");
+	}
+
+	if (!strcmp(cname->name, "lvcreate")) {
 		printf("        [ --name String ]\n"
 		       "        The --name option is not required but is typically used.\n"
 		       "        When a name is not specified, a new LV name is generated\n"
@@ -1887,68 +1914,73 @@ void print_usage_notes(struct command_name *cname, struct command *cmd)
 
 #ifdef MAN_PAGE_GENERATOR
 
-static void print_val_man(struct command_name *cname, const char *str)
+/*
+ * FIXME: this just replicates the val usage strings
+ * that officially lives in vals.h.  Should there
+ * be some programatic way to add man markup to
+ * the strings in vals.h without replicating it?
+ * Otherwise, this function has to be updated in
+ * sync with any string changes in vals.h
+ */
+static void print_val_man(struct command_name *cname, int val_enum)
 {
+	const char *str = val_names[val_enum].usage;
 	char *line;
 	char *line_argv[MAX_LINE_ARGC];
 	int line_argc;
 	int i;
+	int squash_sign_prefix;
 
 	/*
-	 * FIXME: this is a terrible hack that needs to be fixed.
-	 * lvcreate and lvresize both use --size, and --size
-	 * accepts a signed number, and a signed number is
-	 * printed with a [+|-] prefix.  But lvcreate does not
-	 * accept negative numbers.  We need to do something to
-	 * have two (or more) variants of --size, one that can
-	 * accept a sign and one that cannot.  For now, this
-	 * hack just detects when we're going to print
-	 * [+|-]Size for "lvcreate" and overrides it to
-	 * omit the +|-.
+	 * lvcreate does not take a relative [+|-] value
+	 * for --size or --extents.
+	 * Should we also squash - for lvextend and + for lvreduce?
 	 */
-	if (!strcmp(cname->name, "lvcreate") && !strcmp(str, "[+|-]Size[m|UNIT]")) {
-		printf("\\fISize\\fP[m|UNIT]");
+	squash_sign_prefix = !strcmp(cname->name, "lvcreate");
+
+	if (val_enum == ssizemb_VAL) {
+		if (squash_sign_prefix)
+			printf("\\fISize\\fP[m|UNIT]");
+		else
+			printf("[\\fB+\\fP|\\fB-\\fP]\\fISize\\fP[m|UNIT]");
 		return;
 	}
-	if (!strcmp(cname->name, "lvcreate") && !strcmp(str, "[+|-]Number[%VG|%PVS|%FREE]")) {
-		printf("\\fINumber\\fP[\\fB%%VG\\fP|\\fB%%PVS\\fP|\\fB%%FREE\\fP]");
+
+	if (val_enum == extents_VAL) {
+		if (squash_sign_prefix)
+			printf("\\fINumber\\fP[PERCENT]");
+		else
+			printf("[\\fB+\\fP|\\fB-\\fP]\\fINumber\\fP[PERCENT]");
 		return;
 	}
 
-	/*
-	 * Doing bold k before UNIT creates a lot of
-	 * visual "noise" that makes the text hard to read.
-	 * The extra markup in this case doesn't add anything
-	 * that isn't already obvious.
-	 */
-
-	if (!strcmp(str, "Size[k|UNIT]")) {
+	if (val_enum == sizekb_VAL) {
 		printf("\\fISize\\fP[k|UNIT]");
 		return;
 	}
 
-	if (!strcmp(str, "Size[m|UNIT]")) {
+	if (val_enum == sizemb_VAL) {
 		printf("\\fISize\\fP[m|UNIT]");
 		return;
 	}
 
-	if (!strcmp(str, "[+|-]Size[k|UNIT]")) {
+	if (val_enum == ssizekb_VAL) {
 		printf("[\\fB+\\fP|\\fB-\\fP]\\fISize\\fP[k|UNIT]");
 		return;
 	}
 
-	if (!strcmp(str, "[+|-]Size[m|UNIT]")) {
+	if (val_enum == ssizemb_VAL) {
 		printf("[\\fB+\\fP|\\fB-\\fP]\\fISize\\fP[m|UNIT]");
 		return;
 	}
 
-	if (!strcmp(str, "[+|-]Number")) {
-		printf("[\\fB+\\fP|\\fB-\\fP]\\fINumber\\fP");
+	if (val_enum == regionsize_VAL) {
+		printf("\\fISize\\fP[m|UNIT]");
 		return;
 	}
 
-	if (!strcmp(str, "[+|-]Number[%VG|%PVS|%FREE]")) {
-		printf("[\\fB+\\fP|\\fB-\\fP]\\fINumber\\fP[\\fB%%VG\\fP|\\fB%%PVS\\fP|\\fB%%FREE\\fP]");
+	if (val_enum == snumber_VAL) {
+		printf("[\\fB+\\fP|\\fB-\\fP]\\fINumber\\fP");
 		return;
 	}
 
@@ -1957,24 +1989,6 @@ static void print_val_man(struct command_name *cname, const char *str)
 		return;
 	}
 
-	/*
-	 * I think this bit is almost unnecessary with the specific
-	 * ones checked above.
-	 */
-	if (strstr(str, "Number[") || strstr(str, "]Number")) {
-		for (i = 0; i < strlen(str); i++) {
-			if (str[i] == 'N')
-				printf("\\fI");
-			if (str[i] == 'r') {
-				printf("%c", str[i]);
-				printf("\\fP");
-				continue;
-			}
-			printf("%c", str[i]);
-		}
-		return;
-	}
-
 	if (!strcmp(str, "Number") ||
 	    !strcmp(str, "String") ||
 	    !strncmp(str, "VG", 2) ||
@@ -2032,7 +2046,7 @@ static void print_def_man(struct command_name *cname, struct arg_def *def, int u
 					printf("%s", val_names[val_enum].name);
 					printf("\\fP");
 				} else {
-					print_val_man(cname, val_names[val_enum].usage);
+					print_val_man(cname, val_enum);
 				}
 
 				sep = 1;
@@ -2242,8 +2256,7 @@ void print_man_usage(char *lvmname, struct command *cmd)
 
 			opt_enum = cmd->required_opt_args[ro].opt;
 
-			/* special case */
-			if (!strcmp(cmd->name, "lvcreate") && (opt_enum == size_ARG))
+			if ((opt_enum == size_ARG) && command_has_alternate_extents(cmd->name))
 				include_extents = 1;
 
 			if (opt_names[opt_enum].short_opt) {
@@ -2293,7 +2306,9 @@ void print_man_usage(char *lvmname, struct command *cmd)
 
 		if (include_extents) {
 			printf(".ad l\n");
-			printf("[ \\fB-l\\fP|\\fB--extents\\fP \\fINumber\\fP[PERCENT] ]\n");
+			printf("[ \\fB-l\\fP|\\fB--extents\\fP ");
+			print_val_man(cname, extents_VAL);
+			printf(" ]\n");
 			printf(".ad b\n");
 			sep = 1;
 		}
@@ -2724,7 +2739,7 @@ void print_man_all_options_list(struct command_name *cname)
 			printf("\\fP");
 		} else {
 			printf(" ");
-			print_val_man(cname, val_names[val_enum].usage);
+			print_val_man(cname, val_enum);
 		}
 
 		printf("\n.ad b\n");
@@ -2772,7 +2787,7 @@ void print_man_all_options_desc(struct command_name *cname)
 			printf("\\fP");
 		} else {
 			printf(" ");
-			print_val_man(cname, val_names[val_enum].usage);
+			print_val_man(cname, val_enum);
 		}
 
 		if (opt_names[opt_enum].flags & ARG_COUNTABLE)
diff --git a/tools/command.h b/tools/command.h
index 33f083b..0109853 100644
--- a/tools/command.h
+++ b/tools/command.h
@@ -218,5 +218,6 @@ void print_usage_common_cmd(struct command_name *cname, struct command *cmd);
 void print_usage_common_lvm(struct command_name *cname, struct command *cmd);
 void print_usage_notes(struct command_name *cname, struct command *cmd);
 void factor_common_options(void);
+int command_has_alternate_extents(const char *name);
 
 #endif
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 4a109a6..53856ce 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1275,13 +1275,9 @@ static int _command_required_opt_matches(struct cmd_context *cmd, int ci, int ro
 	 * For some commands, --size and --extents are interchangable,
 	 * but command[] definitions use only --size.
 	 */
-	if ((opt_enum == size_ARG) && arg_is_set(cmd, extents_ARG)) {
-		if (!strcmp(commands[ci].name, "lvcreate") ||
-		    !strcmp(commands[ci].name, "lvresize") ||
-		    !strcmp(commands[ci].name, "lvextend") ||
-		    !strcmp(commands[ci].name, "lvreduce"))
-			goto check_val;
-	}
+	if ((opt_enum == size_ARG) && arg_is_set(cmd, extents_ARG) &&
+	    command_has_alternate_extents(commands[ci].name))
+		goto check_val;
 
 	return 0;
 
diff --git a/tools/vals.h b/tools/vals.h
index b946742..ed572ee 100644
--- a/tools/vals.h
+++ b/tools/vals.h
@@ -121,14 +121,14 @@ val(ssizekb_VAL, ssize_kb_arg, "SSizeKB", "[+|-]Size[k|UNIT]")
 val(ssizemb_VAL, ssize_mb_arg, "SSizeMB", "[+|-]Size[m|UNIT]")
 val(regionsize_VAL, regionsize_arg, "RegionSize", "Size[m|UNIT]")
 val(snumber_VAL, int_arg_with_sign, "SNumber", "[+|-]Number")
-val(extents_VAL, extents_arg, "Extents", "[+|-]Number[%VG|%PVS|%FREE]")
+val(extents_VAL, extents_arg, "Extents", "[+|-]Number[PERCENT]")
 val(permission_VAL, permission_arg, "Permission", "rw|r")
 val(metadatatype_VAL, metadatatype_arg, "MetadataType", "lvm2|lvm1")
 val(units_VAL, string_arg, "Units", "r|R|h|H|b|B|s|S|k|K|m|M|g|G|t|T|p|P|e|E")
 val(segtype_VAL, segtype_arg, "SegType", "linear|striped|snapshot|mirror|raid|thin|cache|thin-pool|cache-pool")
 val(alloc_VAL, alloc_arg, "Alloc", "contiguous|cling|cling_by_tags|normal|anywhere|inherit")
 val(locktype_VAL, locktype_arg, "LockType", "sanlock|dlm|none")
-val(readahead_VAL, readahead_arg, "Readahead", "auto|none|NumberSectors")
+val(readahead_VAL, readahead_arg, "Readahead", "auto|none|Number")
 val(vgmetadatacopies_VAL, vgmetadatacopies_arg, "MetadataCopiesVG", "all|unmanaged|Number")
 val(pvmetadatacopies_VAL, pvmetadatacopies_arg, "MetadataCopiesPV", "0|1|2")
 val(metadatacopies_VAL, metadatacopies_arg, "unused", "unused")


