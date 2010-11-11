From: agk@sourceware.org <agk@sourceware.org>
Date: 11 Nov 2010 17:29:09 -0000
Subject: LVM2 ./WHATS_NEW lib/commands/toolcontext.c li ...
Message-ID: <20101111172909.22001.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-11-11 17:29:06

Modified files:
	.              : WHATS_NEW 
	lib/commands   : toolcontext.c toolcontext.h 
	lib/metadata   : lv_manip.c metadata-exported.h 
	liblvm         : lvm_lv.c 
	tools          : args.h lvchange.c lvcreate.c lvm.c 
	                 lvm2cmdline.h lvmcmdline.c pvchange.c tools.h 
	                 vgchange.c vgcreate.c 

Log message:
	Support repetition of --addtag and --deltag arguments.
	Add infrastructure for specific cmdline arguments to be repeated in groups.
	Split the_args cmdline arguments and values into arg_props and arg_values.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1795&r2=1.1796
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.107&r2=1.108
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.h.diff?cvsroot=lvm2&r1=1.40&r2=1.41
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.237&r2=1.238
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.169&r2=1.170
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_lv.c.diff?cvsroot=lvm2&r1=1.27&r2=1.28
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/args.h.diff?cvsroot=lvm2&r1=1.80&r2=1.81
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvchange.c.diff?cvsroot=lvm2&r1=1.126&r2=1.127
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.224&r2=1.225
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvm.c.diff?cvsroot=lvm2&r1=1.114&r2=1.115
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvm2cmdline.h.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.129&r2=1.130
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvchange.c.diff?cvsroot=lvm2&r1=1.84&r2=1.85
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/tools.h.diff?cvsroot=lvm2&r1=1.72&r2=1.73
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.116&r2=1.117
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgcreate.c.diff?cvsroot=lvm2&r1=1.80&r2=1.81

--- LVM2/WHATS_NEW	2010/11/10 16:14:02	1.1795
+++ LVM2/WHATS_NEW	2010/11/11 17:29:05	1.1796
@@ -1,7 +1,10 @@
 Version 2.02.77 -
 ===================================
-  Fix fsadm need of using '-f' for downsize of unmounted filesystem.
-  Fix fsadm regression in detection of mounted filesystem for older systems (2.0.75).
+  Support repetition of --addtag and --deltag arguments.
+  Add infrastructure for specific cmdline arguments to be repeated in groups.
+  Split the_args cmdline arguments and values into arg_props and arg_values.
+FIXME??? Fix fsadm need of using '-f' for downsize of unmounted filesystem.
+  Fix fsadm to detect mounted filesystems on older systems. (2.0.75)
   Extend cling allocation policy to recognise PV tags (cling_by_tags).
   Add allocation/cling_tag_list to lvm.conf.
   Regenerate configure with 'autoreconf' for --enable-ocf. (2.02.76)
--- LVM2/lib/commands/toolcontext.c	2010/10/25 11:20:55	1.107
+++ LVM2/lib/commands/toolcontext.c	2010/11/11 17:29:05	1.108
@@ -1136,6 +1136,7 @@
 	cmd->handles_missing_pvs = 0;
 	cmd->handles_unknown_segments = 0;
 	cmd->hosttags = 0;
+	dm_list_init(&cmd->arg_value_groups);
 	dm_list_init(&cmd->formats);
 	dm_list_init(&cmd->segtypes);
 	dm_list_init(&cmd->tags);
--- LVM2/lib/commands/toolcontext.h	2010/10/25 11:20:55	1.40
+++ LVM2/lib/commands/toolcontext.h	2010/11/11 17:29:06	1.41
@@ -49,6 +49,7 @@
 struct config_tree;
 struct archive_params;
 struct backup_params;
+struct arg_values;
 
 /* FIXME Split into tool & library contexts */
 /* command-instance-related variables needed by library */
@@ -68,6 +69,8 @@
 	const char *cmd_line;
 	struct command *command;
 	char **argv;
+	struct arg_values *arg_values;
+	struct dm_list arg_value_groups;
 	unsigned is_long_lived:1;	/* Optimises persistent_filter handling */
 	unsigned handles_missing_pvs:1;
 	unsigned handles_unknown_segments:1;
--- LVM2/lib/metadata/lv_manip.c	2010/11/11 12:32:34	1.237
+++ LVM2/lib/metadata/lv_manip.c	2010/11/11 17:29:06	1.238
@@ -3248,7 +3248,7 @@
 	if (!archive(vg))
 		return 0;
 
-	if (lp->tag) {
+	if (!dm_list_empty(&lp->tags)) {
 		if (!(vg->fid->fmt->features & FMT_TAGS)) {
 			log_error("Volume group %s does not support tags",
 				  vg->name);
@@ -3283,11 +3283,8 @@
 			    lv->minor);
 	}
 
-	if (lp->tag && !str_list_add(cmd->mem, &lv->tags, lp->tag)) {
-		log_error("Failed to add tag %s to %s/%s",
-			  lp->tag, lv->vg->name, lv->name);
-		return 0;
-	}
+	if (!dm_list_empty(&lp->tags))
+		dm_list_splice(&lv->tags, &lp->tags);
 
 	if (!lv_extend(lv, lp->segtype, lp->stripes, lp->stripe_size,
 		       1, lp->extents, NULL, 0u, 0u, lp->pvh, lp->alloc))
--- LVM2/lib/metadata/metadata-exported.h	2010/10/12 16:41:17	1.169
+++ LVM2/lib/metadata/metadata-exported.h	2010/11/11 17:29:06	1.170
@@ -516,7 +516,7 @@
 	uint32_t read_ahead; /* all */
 	alloc_policy_t alloc; /* all */
 
-	const char *tag; /* all */
+	struct dm_list tags;	/* all */
 };
 
 int lv_create_single(struct volume_group *vg,
--- LVM2/liblvm/lvm_lv.c	2010/10/25 14:09:08	1.27
+++ LVM2/liblvm/lvm_lv.c	2010/11/11 17:29:06	1.28
@@ -113,7 +113,7 @@
 	lp->permission = LVM_READ | LVM_WRITE;
 	lp->read_ahead = DM_READ_AHEAD_NONE;
 	lp->alloc = ALLOC_INHERIT;
-	lp->tag = NULL;
+	dm_list_init(&lp->tags);
 }
 
 /* Set default for linear segment specific LV parameters */
--- LVM2/tools/args.h	2010/10/13 10:34:32	1.80
+++ LVM2/tools/args.h	2010/11/11 17:29:06	1.81
@@ -40,8 +40,8 @@
 arg(removemissing_ARG, '\0', "removemissing", NULL, 0)
 arg(restoremissing_ARG, '\0', "restoremissing", NULL, 0)
 arg(abort_ARG, '\0', "abort", NULL, 0)
-arg(addtag_ARG, '\0', "addtag", tag_arg, 0)
-arg(deltag_ARG, '\0', "deltag", tag_arg, 0)
+arg(addtag_ARG, '\0', "addtag", tag_arg, ARG_GROUPABLE)
+arg(deltag_ARG, '\0', "deltag", tag_arg, ARG_GROUPABLE)
 arg(refresh_ARG, '\0', "refresh", NULL, 0)
 arg(mknodes_ARG, '\0', "mknodes", NULL, 0)
 arg(minor_ARG, '\0', "minor", minor_arg, 0)
@@ -90,11 +90,11 @@
 arg(colon_ARG, 'c', "colon", NULL, 0)
 arg(columns_ARG, 'C', "columns", NULL, 0)
 arg(contiguous_ARG, 'C', "contiguous", yes_no_arg, 0)
-arg(debug_ARG, 'd', "debug", NULL, ARG_REPEATABLE)
+arg(debug_ARG, 'd', "debug", NULL, ARG_COUNTABLE)
 arg(exported_ARG, 'e', "exported", NULL, 0)
 arg(physicalextent_ARG, 'E', "physicalextent", NULL, 0)
 arg(file_ARG, 'f', "file", string_arg, 0)
-arg(force_ARG, 'f', "force", NULL, ARG_REPEATABLE)
+arg(force_ARG, 'f', "force", NULL, ARG_COUNTABLE)
 arg(full_ARG, 'f', "full", NULL, 0)
 arg(help_ARG, 'h', "help", NULL, 0)
 arg(help2_ARG, '?', "", NULL, 0)
@@ -137,7 +137,7 @@
 arg(uuid_ARG, 'u', "uuid", NULL, 0)
 arg(uuidstr_ARG, 'u', "uuid", string_arg, 0)
 arg(uuidlist_ARG, 'U', "uuidlist", NULL, 0)
-arg(verbose_ARG, 'v', "verbose", NULL, ARG_REPEATABLE)
+arg(verbose_ARG, 'v', "verbose", NULL, ARG_COUNTABLE)
 arg(volumegroup_ARG, 'V', "volumegroup", NULL, 0)
 arg(allocatable_ARG, 'x', "allocatable", yes_no_arg, 0)
 arg(resizeable_ARG, 'x', "resizeable", yes_no_arg, 0)
--- LVM2/tools/lvchange.c	2010/10/26 01:37:59	1.126
+++ LVM2/tools/lvchange.c	2010/11/11 17:29:06	1.127
@@ -495,14 +495,20 @@
 			int arg)
 {
 	const char *tag;
+	struct arg_value_group_list *current_group;
 
-	if (!(tag = arg_str_value(cmd, arg, NULL))) {
-		log_error("Failed to get tag");
-		return 0;
-	}
+	dm_list_iterate_items(current_group, &cmd->arg_value_groups) {
+		if (!grouped_arg_is_set(current_group->arg_values, arg))
+			continue;
 
-	if (!lv_change_tag(lv, tag, arg == addtag_ARG))
-		return_0;
+		if (!(tag = grouped_arg_str_value(current_group->arg_values, arg, NULL))) {
+			log_error("Failed to get tag");
+			return 0;
+		}
+
+		if (!lv_change_tag(lv, tag, arg == addtag_ARG))
+			return_0;
+	}
 
 	log_very_verbose("Updating logical volume \"%s\" on disk(s)", lv->name);
 
--- LVM2/tools/lvcreate.c	2010/10/25 12:05:46	1.224
+++ LVM2/tools/lvcreate.c	2010/11/11 17:29:06	1.225
@@ -327,9 +327,12 @@
 {
 	int contiguous;
 	unsigned pagesize;
+	struct arg_value_group_list *current_group;
+	const char *tag;
 
 	memset(lp, 0, sizeof(*lp));
 	memset(lcp, 0, sizeof(*lcp));
+	dm_list_init(&lp->tags);
 
 	/*
 	 * Check selected options are compatible and determine segtype
@@ -507,7 +510,20 @@
 		return 0;
 	}
 
-	lp->tag = arg_str_value(cmd, addtag_ARG, NULL);
+	dm_list_iterate_items(current_group, &cmd->arg_value_groups) {
+		if (!grouped_arg_is_set(current_group->arg_values, addtag_ARG))
+			continue;
+
+		if (!(tag = grouped_arg_str_value(current_group->arg_values, addtag_ARG, NULL))) {
+			log_error("Failed to get tag");
+			return 0;
+		}
+
+		if (!str_list_add(cmd->mem, &lp->tags, tag)) {
+                	log_error("Unable to allocate memory for tag %s", tag);
+			return 0;
+		}
+        }
 
 	lcp->pv_count = argc;
 	lcp->pvs = argv;
--- LVM2/tools/lvm.c	2010/10/25 12:57:00	1.114
+++ LVM2/tools/lvm.c	2010/11/11 17:29:06	1.115
@@ -95,7 +95,7 @@
 		while (match_no < com->num_args) {
 			char s[3];
 			char c;
-			if (!(c = (_cmdline->the_args +
+			if (!(c = (_cmdline->arg_props +
 				   com->valid_args[match_no++])->short_arg))
 				continue;
 
@@ -111,7 +111,7 @@
 
 	while (match_no - com->num_args < com->num_args) {
 		const char *l;
-		l = (_cmdline->the_args +
+		l = (_cmdline->arg_props +
 		     com->valid_args[match_no++ - com->num_args])->long_arg;
 		if (*(l + 2) && !strncmp(text, l, len))
 			return strdup(l);
--- LVM2/tools/lvm2cmdline.h	2010/01/11 19:19:17	1.9
+++ LVM2/tools/lvm2cmdline.h	2010/11/11 17:29:06	1.10
@@ -19,7 +19,7 @@
 struct cmd_context;
 
 struct cmdline_context {
-        struct arg *the_args;
+        struct arg_props *arg_props;
         struct command *commands;
         int num_commands;
         int commands_size;
--- LVM2/tools/lvmcmdline.c	2010/10/25 11:20:56	1.129
+++ LVM2/tools/lvmcmdline.c	2010/11/11 17:29:06	1.130
@@ -50,8 +50,8 @@
 /*
  * Table of valid switches
  */
-static struct arg _the_args[ARG_COUNT + 1] = {
-#define arg(a, b, c, d, e) {b, "", "--" c, d, e, 0, NULL, 0, 0, INT64_C(0), UINT64_C(0), SIGN_NONE, PERCENT_NONE},
+static struct arg_props _arg_props[ARG_COUNT + 1] = {
+#define arg(a, b, c, d, e) {b, "", "--" c, d, e},
 #include "args.h"
 #undef arg
 };
@@ -59,10 +59,14 @@
 static struct cmdline_context _cmdline;
 
 /* Command line args */
-/* FIXME: Move static _the_args into cmd? */
-unsigned arg_count(const struct cmd_context *cmd __attribute__((unused)), int a)
+unsigned arg_count(const struct cmd_context *cmd, int a)
 {
-	return _the_args[a].count;
+	return cmd->arg_values[a].count;
+}
+
+unsigned grouped_arg_count(const struct arg_values *av, int a)
+{
+	return av[a].count;
 }
 
 unsigned arg_is_set(const struct cmd_context *cmd, int a)
@@ -70,71 +74,81 @@
 	return arg_count(cmd, a) ? 1 : 0;
 }
 
-const char *arg_value(struct cmd_context *cmd __attribute__((unused)), int a)
+unsigned grouped_arg_is_set(const struct arg_values *av, int a)
+{
+	return grouped_arg_count(av, a) ? 1 : 0;
+}
+
+const char *arg_value(struct cmd_context *cmd, int a)
 {
-	return _the_args[a].value;
+	return cmd->arg_values[a].value;
 }
 
 const char *arg_str_value(struct cmd_context *cmd, int a, const char *def)
 {
-	return arg_count(cmd, a) ? _the_args[a].value : def;
+	return arg_count(cmd, a) ? cmd->arg_values[a].value : def;
+}
+
+const char *grouped_arg_str_value(const struct arg_values *av, int a, const char *def)
+{
+	return grouped_arg_count(av, a) ? av[a].value : def;
 }
 
 int32_t arg_int_value(struct cmd_context *cmd, int a, const int32_t def)
 {
-	return arg_count(cmd, a) ? _the_args[a].i_value : def;
+	return arg_count(cmd, a) ? cmd->arg_values[a].i_value : def;
 }
 
 uint32_t arg_uint_value(struct cmd_context *cmd, int a, const uint32_t def)
 {
-	return arg_count(cmd, a) ? _the_args[a].ui_value : def;
+	return arg_count(cmd, a) ? cmd->arg_values[a].ui_value : def;
 }
 
 int64_t arg_int64_value(struct cmd_context *cmd, int a, const int64_t def)
 {
-	return arg_count(cmd, a) ? _the_args[a].i64_value : def;
+	return arg_count(cmd, a) ? cmd->arg_values[a].i64_value : def;
 }
 
 uint64_t arg_uint64_value(struct cmd_context *cmd, int a, const uint64_t def)
 {
-	return arg_count(cmd, a) ? _the_args[a].ui64_value : def;
+	return arg_count(cmd, a) ? cmd->arg_values[a].ui64_value : def;
 }
 
 /* No longer used.
 const void *arg_ptr_value(struct cmd_context *cmd, int a, const void *def)
 {
-	return arg_count(cmd, a) ? _the_args[a].ptr : def;
+	return arg_count(cmd, a) ? cmd->arg_values[a].ptr : def;
 }
 */
 
 sign_t arg_sign_value(struct cmd_context *cmd, int a, const sign_t def)
 {
-	return arg_count(cmd, a) ? _the_args[a].sign : def;
+	return arg_count(cmd, a) ? cmd->arg_values[a].sign : def;
 }
 
 percent_t arg_percent_value(struct cmd_context *cmd, int a, const percent_t def)
 {
-	return arg_count(cmd, a) ? _the_args[a].percent : def;
+	return arg_count(cmd, a) ? cmd->arg_values[a].percent : def;
 }
 
-int arg_count_increment(struct cmd_context *cmd __attribute__((unused)), int a)
+int arg_count_increment(struct cmd_context *cmd, int a)
 {
-	return _the_args[a].count++;
+	return cmd->arg_values[a].count++;
 }
 
-int yes_no_arg(struct cmd_context *cmd __attribute__((unused)), struct arg *a)
+int yes_no_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av)
 {
-	a->sign = SIGN_NONE;
-	a->percent = PERCENT_NONE;
+	av->sign = SIGN_NONE;
+	av->percent = PERCENT_NONE;
 
-	if (!strcmp(a->value, "y")) {
-		a->i_value = 1;
-		a->ui_value = 1;
+	if (!strcmp(av->value, "y")) {
+		av->i_value = 1;
+		av->ui_value = 1;
 	}
 
-	else if (!strcmp(a->value, "n")) {
-		a->i_value = 0;
-		a->ui_value = 0;
+	else if (!strcmp(av->value, "n")) {
+		av->i_value = 0;
+		av->ui_value = 0;
 	}
 
 	else
@@ -143,37 +157,36 @@
 	return 1;
 }
 
-int yes_no_excl_arg(struct cmd_context *cmd __attribute__((unused)),
-		    struct arg *a)
+int yes_no_excl_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av)
 {
-	a->sign = SIGN_NONE;
-	a->percent = PERCENT_NONE;
+	av->sign = SIGN_NONE;
+	av->percent = PERCENT_NONE;
 
-	if (!strcmp(a->value, "e") || !strcmp(a->value, "ey") ||
-	    !strcmp(a->value, "ye")) {
-		a->i_value = CHANGE_AE;
-		a->ui_value = CHANGE_AE;
+	if (!strcmp(av->value, "e") || !strcmp(av->value, "ey") ||
+	    !strcmp(av->value, "ye")) {
+		av->i_value = CHANGE_AE;
+		av->ui_value = CHANGE_AE;
 	}
 
-	else if (!strcmp(a->value, "y")) {
-		a->i_value = CHANGE_AY;
-		a->ui_value = CHANGE_AY;
+	else if (!strcmp(av->value, "y")) {
+		av->i_value = CHANGE_AY;
+		av->ui_value = CHANGE_AY;
 	}
 
-	else if (!strcmp(a->value, "n") || !strcmp(a->value, "en") ||
-		 !strcmp(a->value, "ne")) {
-		a->i_value = CHANGE_AN;
-		a->ui_value = CHANGE_AN;
+	else if (!strcmp(av->value, "n") || !strcmp(av->value, "en") ||
+		 !strcmp(av->value, "ne")) {
+		av->i_value = CHANGE_AN;
+		av->ui_value = CHANGE_AN;
 	}
 
-	else if (!strcmp(a->value, "ln") || !strcmp(a->value, "nl")) {
-		a->i_value = CHANGE_ALN;
-		a->ui_value = CHANGE_ALN;
+	else if (!strcmp(av->value, "ln") || !strcmp(av->value, "nl")) {
+		av->i_value = CHANGE_ALN;
+		av->ui_value = CHANGE_ALN;
 	}
 
-	else if (!strcmp(a->value, "ly") || !strcmp(a->value, "yl")) {
-		a->i_value = CHANGE_ALY;
-		a->ui_value = CHANGE_ALY;
+	else if (!strcmp(av->value, "ly") || !strcmp(av->value, "yl")) {
+		av->i_value = CHANGE_ALY;
+		av->ui_value = CHANGE_ALY;
 	}
 
 	else
@@ -182,30 +195,30 @@
 	return 1;
 }
 
-int metadatatype_arg(struct cmd_context *cmd, struct arg *a)
+int metadatatype_arg(struct cmd_context *cmd, struct arg_values *av)
 {
-	return get_format_by_name(cmd, a->value) ? 1 : 0;
+	return get_format_by_name(cmd, av->value) ? 1 : 0;
 }
 
-static int _get_int_arg(struct arg *a, char **ptr)
+static int _get_int_arg(struct arg_values *av, char **ptr)
 {
 	char *val;
 	long v;
 
-	a->percent = PERCENT_NONE;
+	av->percent = PERCENT_NONE;
 
-	val = a->value;
+	val = av->value;
 	switch (*val) {
 	case '+':
-		a->sign = SIGN_PLUS;
+		av->sign = SIGN_PLUS;
 		val++;
 		break;
 	case '-':
-		a->sign = SIGN_MINUS;
+		av->sign = SIGN_MINUS;
 		val++;
 		break;
 	default:
-		a->sign = SIGN_NONE;
+		av->sign = SIGN_NONE;
 	}
 
 	if (!isdigit(*val))
@@ -216,16 +229,16 @@
 	if (*ptr == val)
 		return 0;
 
-	a->i_value = (int32_t) v;
-	a->ui_value = (uint32_t) v;
-	a->i64_value = (int64_t) v;
-	a->ui64_value = (uint64_t) v;
+	av->i_value = (int32_t) v;
+	av->ui_value = (uint32_t) v;
+	av->i64_value = (int64_t) v;
+	av->ui64_value = (uint64_t) v;
 
 	return 1;
 }
 
 /* Size stored in sectors */
-static int _size_arg(struct cmd_context *cmd __attribute__((unused)), struct arg *a, int factor)
+static int _size_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av, int factor)
 {
 	char *ptr;
 	int i;
@@ -234,20 +247,20 @@
 	double v;
 	uint64_t v_tmp, adjustment;
 
-	a->percent = PERCENT_NONE;
+	av->percent = PERCENT_NONE;
 
-	val = a->value;
+	val = av->value;
 	switch (*val) {
 	case '+':
-		a->sign = SIGN_PLUS;
+		av->sign = SIGN_PLUS;
 		val++;
 		break;
 	case '-':
-		a->sign = SIGN_MINUS;
+		av->sign = SIGN_MINUS;
 		val++;
 		break;
 	default:
-		a->sign = SIGN_NONE;
+		av->sign = SIGN_NONE;
 	}
 
 	if (!isdigit(*val))
@@ -289,50 +302,50 @@
 	} else
 		v *= factor;
 
-	a->i_value = (int32_t) v;
-	a->ui_value = (uint32_t) v;
-	a->i64_value = (int64_t) v;
-	a->ui64_value = (uint64_t) v;
+	av->i_value = (int32_t) v;
+	av->ui_value = (uint32_t) v;
+	av->i64_value = (int64_t) v;
+	av->ui64_value = (uint64_t) v;
 
 	return 1;
 }
 
-int size_kb_arg(struct cmd_context *cmd, struct arg *a)
+int size_kb_arg(struct cmd_context *cmd, struct arg_values *av)
 {
-	return _size_arg(cmd, a, 2);
+	return _size_arg(cmd, av, 2);
 }
 
-int size_mb_arg(struct cmd_context *cmd, struct arg *a)
+int size_mb_arg(struct cmd_context *cmd, struct arg_values *av)
 {
-	return _size_arg(cmd, a, 2048);
+	return _size_arg(cmd, av, 2048);
 }
 
-int int_arg(struct cmd_context *cmd __attribute__((unused)), struct arg *a)
+int int_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av)
 {
 	char *ptr;
 
-	if (!_get_int_arg(a, &ptr) || (*ptr) || (a->sign == SIGN_MINUS))
+	if (!_get_int_arg(av, &ptr) || (*ptr) || (av->sign == SIGN_MINUS))
 		return 0;
 
 	return 1;
 }
 
-int int_arg_with_sign(struct cmd_context *cmd __attribute__((unused)), struct arg *a)
+int int_arg_with_sign(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av)
 {
 	char *ptr;
 
-	if (!_get_int_arg(a, &ptr) || (*ptr))
+	if (!_get_int_arg(av, &ptr) || (*ptr))
 		return 0;
 
 	return 1;
 }
 
 int int_arg_with_sign_and_percent(struct cmd_context *cmd __attribute__((unused)),
-				  struct arg *a)
+				  struct arg_values *av)
 {
 	char *ptr;
 
-	if (!_get_int_arg(a, &ptr))
+	if (!_get_int_arg(av, &ptr))
 		return 0;
 
 	if (!*ptr)
@@ -342,32 +355,32 @@
 		return 0;
 
 	if (!strcasecmp(ptr, "V") || !strcasecmp(ptr, "VG"))
-		a->percent = PERCENT_VG;
+		av->percent = PERCENT_VG;
 	else if (!strcasecmp(ptr, "L") || !strcasecmp(ptr, "LV"))
-		a->percent = PERCENT_LV;
+		av->percent = PERCENT_LV;
 	else if (!strcasecmp(ptr, "P") || !strcasecmp(ptr, "PV") ||
 		 !strcasecmp(ptr, "PVS"))
-		a->percent = PERCENT_PVS;
+		av->percent = PERCENT_PVS;
 	else if (!strcasecmp(ptr, "F") || !strcasecmp(ptr, "FR") ||
 		 !strcasecmp(ptr, "FREE"))
-		a->percent = PERCENT_FREE;
+		av->percent = PERCENT_FREE;
 	else if (!strcasecmp(ptr, "O") || !strcasecmp(ptr, "OR") ||
 		 !strcasecmp(ptr, "ORIGIN"))
-		a->percent = PERCENT_ORIGIN;
+		av->percent = PERCENT_ORIGIN;
 	else
 		return 0;
 
 	return 1;
 }
 
-int minor_arg(struct cmd_context *cmd __attribute__((unused)), struct arg *a)
+int minor_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av)
 {
 	char *ptr;
 
-	if (!_get_int_arg(a, &ptr) || (*ptr) || (a->sign == SIGN_MINUS))
+	if (!_get_int_arg(av, &ptr) || (*ptr) || (av->sign == SIGN_MINUS))
 		return 0;
 
-	if (a->i_value > 255) {
+	if (av->i_value > 255) {
 		log_error("Minor number outside range 0-255");
 		return 0;
 	}
@@ -375,14 +388,14 @@
 	return 1;
 }
 
-int major_arg(struct cmd_context *cmd __attribute__((unused)), struct arg *a)
+int major_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av)
 {
 	char *ptr;
 
-	if (!_get_int_arg(a, &ptr) || (*ptr) || (a->sign == SIGN_MINUS))
+	if (!_get_int_arg(av, &ptr) || (*ptr) || (av->sign == SIGN_MINUS))
 		return 0;
 
-	if (a->i_value > 255) {
+	if (av->i_value > 255) {
 		log_error("Major number outside range 0-255");
 		return 0;
 	}
@@ -393,14 +406,14 @@
 }
 
 int string_arg(struct cmd_context *cmd __attribute__((unused)),
-	       struct arg *a __attribute__((unused)))
+	       struct arg_values *av __attribute__((unused)))
 {
 	return 1;
 }
 
-int tag_arg(struct cmd_context *cmd __attribute__((unused)), struct arg *a)
+int tag_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av)
 {
-	char *pos = a->value;
+	char *pos = av->value;
 
 	if (*pos == '@')
 		pos++;
@@ -408,20 +421,20 @@
 	if (!validate_name(pos))
 		return 0;
 
-	a->value = pos;
+	av->value = pos;
 
 	return 1;
 }
 
-int permission_arg(struct cmd_context *cmd __attribute__((unused)), struct arg *a)
+int permission_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av)
 {
-	a->sign = SIGN_NONE;
+	av->sign = SIGN_NONE;
 
-	if ((!strcmp(a->value, "rw")) || (!strcmp(a->value, "wr")))
-		a->ui_value = LVM_READ | LVM_WRITE;
+	if ((!strcmp(av->value, "rw")) || (!strcmp(av->value, "wr")))
+		av->ui_value = LVM_READ | LVM_WRITE;
 
-	else if (!strcmp(a->value, "r"))
-		a->ui_value = LVM_READ;
+	else if (!strcmp(av->value, "r"))
+		av->ui_value = LVM_READ;
 
 	else
 		return 0;
@@ -429,45 +442,45 @@
 	return 1;
 }
 
-int alloc_arg(struct cmd_context *cmd __attribute__((unused)), struct arg *a)
+int alloc_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av)
 {
 	alloc_policy_t alloc;
 
-	a->sign = SIGN_NONE;
+	av->sign = SIGN_NONE;
 
-	alloc = get_alloc_from_string(a->value);
+	alloc = get_alloc_from_string(av->value);
 	if (alloc == ALLOC_INVALID)
 		return 0;
 
-	a->ui_value = (uint32_t) alloc;
+	av->ui_value = (uint32_t) alloc;
 
 	return 1;
 }
 
-int segtype_arg(struct cmd_context *cmd, struct arg *a)
+int segtype_arg(struct cmd_context *cmd, struct arg_values *av)
 {
-	return get_segtype_from_string(cmd, a->value) ? 1 : 0;
+	return get_segtype_from_string(cmd, av->value) ? 1 : 0;
 }
 
 /*
  * Positive integer, zero or "auto".
  */
-int readahead_arg(struct cmd_context *cmd __attribute__((unused)), struct arg *a)
+int readahead_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av)
 {
-	if (!strcasecmp(a->value, "auto")) {
-		a->ui_value = DM_READ_AHEAD_AUTO;
+	if (!strcasecmp(av->value, "auto")) {
+		av->ui_value = DM_READ_AHEAD_AUTO;
 		return 1;
 	}
 
-	if (!strcasecmp(a->value, "none")) {
-		a->ui_value = DM_READ_AHEAD_NONE;
+	if (!strcasecmp(av->value, "none")) {
+		av->ui_value = DM_READ_AHEAD_NONE;
 		return 1;
 	}
 
-	if (!_size_arg(cmd, a, 1))
+	if (!_size_arg(cmd, av, 1))
 		return 0;
 
-	if (a->sign == SIGN_MINUS)
+	if (av->sign == SIGN_MINUS)
 		return 0;
 
 	return 1;
@@ -476,22 +489,21 @@
 /*
  * Non-zero, positive integer, "all", or "unmanaged"
  */
-int metadatacopies_arg(struct cmd_context *cmd __attribute__((unused)),
-			 struct arg *a)
+int metadatacopies_arg(struct cmd_context *cmd, struct arg_values *av)
 {
 	if (!strncmp(cmd->command->name, "vg", 2)) {
-		if (!strcasecmp(a->value, "all")) {
-			a->ui_value = VGMETADATACOPIES_ALL;
+		if (!strcasecmp(av->value, "all")) {
+			av->ui_value = VGMETADATACOPIES_ALL;
 			return 1;
 		}
 
-		if (!strcasecmp(a->value, "unmanaged")) {
-			a->ui_value = VGMETADATACOPIES_UNMANAGED;
+		if (!strcasecmp(av->value, "unmanaged")) {
+			av->ui_value = VGMETADATACOPIES_UNMANAGED;
 			return 1;
 		}
 	}
 
-	return int_arg(cmd, a);
+	return int_arg(cmd, av);
 }
 
 static void __alloc(int size)
@@ -618,7 +630,7 @@
  */
 static void _add_getopt_arg(int arg, char **ptr, struct option **o)
 {
-	struct arg *a = _cmdline.the_args + arg;
+	struct arg_props *a = _cmdline.arg_props + arg;
 
 	if (a->short_arg) {
 		*(*ptr)++ = a->short_arg;
@@ -640,14 +652,14 @@
 #endif
 }
 
-static struct arg *_find_arg(struct command *com, int opt)
+static int _find_arg(struct command *com, int opt)
 {
-	struct arg *a;
+	struct arg_props *a;
 	int i, arg;
 
 	for (i = 0; i < com->num_args; i++) {
 		arg = com->valid_args[i];
-		a = _cmdline.the_args + arg;
+		a = _cmdline.arg_props + arg;
 
 		/*
 		 * opt should equal either the
@@ -656,30 +668,25 @@
 		 */
 		if ((a->short_arg && (opt == a->short_arg)) ||
 		    (!a->short_arg && (opt == arg)))
-			return a;
+			return arg;
 	}
 
-	return 0;
+	return -1;
 }
 
 static int _process_command_line(struct cmd_context *cmd, int *argc,
 				 char ***argv)
 {
-	int i, opt;
+	int i, opt, arg;
 	char str[((ARG_COUNT + 1) * 2) + 1], *ptr = str;
 	struct option opts[ARG_COUNT + 1], *o = opts;
-	struct arg *a;
-
-	for (i = 0; i < ARG_COUNT; i++) {
-		a = _cmdline.the_args + i;
+	struct arg_props *a;
+	struct arg_values *av;
+	struct arg_value_group_list *current_group = NULL;
 
-		/* zero the count and arg */
-		a->count = 0;
-		a->value = 0;
-		a->i_value = 0;
-		a->ui_value = 0;
-		a->i64_value = 0;
-		a->ui64_value = 0;
+	if (!(cmd->arg_values = dm_pool_zalloc(cmd->mem, sizeof(*cmd->arg_values) * ARG_COUNT))) {
+		log_fatal("Unable to allocate memory for command line arguments.");
+		return 0;
 	}
 
 	/* fill in the short and long opts */
@@ -697,15 +704,33 @@
 		if (opt == '?')
 			return 0;
 
-		a = _find_arg(cmd->command, opt);
-
-		if (!a) {
+		if ((arg = _find_arg(cmd->command, opt)) < 0) {
 			log_fatal("Unrecognised option.");
 			return 0;
 		}
 
-		if (a->count && !(a->flags & ARG_REPEATABLE)) {
-			log_error("Option%s%c%s%s may not be repeated",
+		a = _cmdline.arg_props + arg;
+
+		av = &cmd->arg_values[arg];
+
+		if (a->flags & ARG_GROUPABLE) {
+			/* Start a new group of arguments the first time or if a non-countable argument is repeated. */
+			if (!current_group || (current_group->arg_values[arg].count && !(a->flags & ARG_COUNTABLE))) {
+				/* FIXME Reduce size including only groupable args */
+				if (!(current_group = dm_pool_zalloc(cmd->mem, sizeof(struct arg_value_group_list) + sizeof(*cmd->arg_values) * ARG_COUNT))) {
+					log_fatal("Unable to allocate memory for command line arguments.");
+					return 0;
+				}
+
+				dm_list_add(&cmd->arg_value_groups, &current_group->list);
+			}
+			/* Maintain total argument count as well as count within each group */
+			av->count++;
+			av = &current_group->arg_values[arg];
+		}
+
+		if (av->count && !(a->flags & ARG_COUNTABLE)) {
+			log_error("Option%s%c%s%s may not be repeated.",
 				  a->short_arg ? " -" : "",
 				  a->short_arg ? : ' ',
 				  (a->short_arg && a->long_arg) ?
@@ -719,15 +744,15 @@
 				return 0;
 			}
 
-			a->value = optarg;
+			av->value = optarg;
 
-			if (!a->fn(cmd, a)) {
-				log_error("Invalid argument %s", optarg);
+			if (!a->fn(cmd, av)) {
+				log_error("Invalid argument for %s: %s", a->long_arg, optarg);
 				return 0;
 			}
 		}
 
-		a->count++;
+		av->count++;
 	}
 
 	*argc -= optind;
@@ -737,20 +762,20 @@
 
 static int _merge_synonym(struct cmd_context *cmd, int oldarg, int newarg)
 {
-	const struct arg *old;
-	struct arg *new;
+	const struct arg_values *old;
+	struct arg_values *new;
 
 	if (arg_count(cmd, oldarg) && arg_count(cmd, newarg)) {
 		log_error("%s and %s are synonyms.  Please only supply one.",
-			  _cmdline.the_args[oldarg].long_arg, _cmdline.the_args[newarg].long_arg);
+			  _cmdline.arg_props[oldarg].long_arg, _cmdline.arg_props[newarg].long_arg);
 		return 0;
 	}
 
 	if (!arg_count(cmd, oldarg))
 		return 1;
 
-	old = _cmdline.the_args + oldarg;
-	new = _cmdline.the_args + newarg;
+	old = cmd->arg_values + oldarg;
+	new = cmd->arg_values + newarg;
 
 	new->count = old->count;
 	new->value = old->value;
@@ -1120,6 +1145,7 @@
 	/*
 	 * free off any memory the command used.
 	 */
+	dm_list_init(&cmd->arg_value_groups);
 	dm_pool_empty(cmd->mem);
 
 	reset_lvm_errno(1);
@@ -1250,11 +1276,11 @@
 {
 	struct cmd_context *cmd;
 
-	_cmdline.the_args = &_the_args[0];
-
 	if (!(cmd = create_toolcontext(0, NULL)))
 		return_NULL;
 
+	_cmdline.arg_props = &_arg_props[0];
+
 	if (stored_errno()) {
 		destroy_toolcontext(cmd);
 		return_NULL;
--- LVM2/tools/pvchange.c	2010/09/23 12:02:34	1.84
+++ LVM2/tools/pvchange.c	2010/11/11 17:29:06	1.85
@@ -36,6 +36,8 @@
 	int r = 0;
 	int mda_ignore = 0;
 
+	struct arg_value_group_list *current_group;
+
 	if (arg_count(cmd, addtag_ARG))
 		tagarg = addtag_ARG;
 	else if (arg_count(cmd, deltag_ARG))
@@ -47,10 +49,6 @@
 	if (arg_count(cmd, metadataignore_ARG))
 		mda_ignore = !strcmp(arg_str_value(cmd, metadataignore_ARG, "n"),
 				      "y");
-	else if (tagarg && !(tag = arg_str_value(cmd, tagarg, NULL))) {
-		log_error("Failed to get tag");
-		return 0;
-	}
 
 	/* If in a VG, must change using volume group. */
 	if (!is_orphan(pv)) {
@@ -108,16 +106,25 @@
 		}
 	} else if (tagarg) {
 		/* tag or deltag */
-		if ((tagarg == addtag_ARG)) {
-			if (!str_list_add(cmd->mem, &pv->tags, tag)) {
-				log_error("Failed to add tag %s to physical "
-					  "volume %s", tag, pv_name);
+
+		dm_list_iterate_items(current_group, &cmd->arg_value_groups) {
+			if (!grouped_arg_is_set(current_group->arg_values, tagarg))
+				continue;
+
+			if (!(tag = grouped_arg_str_value(current_group->arg_values, tagarg, NULL))) {
+				log_error("Failed to get tag");
 				goto out;
 			}
-		} else {
-			if (!str_list_del(&pv->tags, tag)) {
+
+			if ((tagarg == addtag_ARG)) {
+				if (!str_list_add(cmd->mem, &pv->tags, tag)) {
+					log_error("Failed to add tag %s to physical "
+						  "volume %s", tag, pv_name);
+					goto out;
+				}
+			} else if (!str_list_del(&pv->tags, tag)) {
 				log_error("Failed to remove tag %s from "
-					  "physical volume" "%s", tag, pv_name);
+				  	"physical volume" "%s", tag, pv_name);
 				goto out;
 			}
 		}
@@ -202,8 +209,8 @@
 	struct dm_list *vgnames;
 	struct str_list *sll;
 
-	if (arg_count(cmd, allocatable_ARG) + arg_count(cmd, addtag_ARG) +
-	    arg_count(cmd, deltag_ARG) + arg_count(cmd, uuid_ARG) +
+	if (arg_count(cmd, allocatable_ARG) + arg_is_set(cmd, addtag_ARG) +
+	    arg_is_set(cmd, deltag_ARG) + arg_count(cmd, uuid_ARG) +
 	    arg_count(cmd, metadataignore_ARG) != 1) {
 		log_error("Please give exactly one option of -x, -uuid, "
 			  "--addtag or --deltag");
--- LVM2/tools/tools.h	2010/10/25 11:20:56	1.72
+++ LVM2/tools/tools.h	2010/11/11 17:29:06	1.73
@@ -95,17 +95,10 @@
 	CHANGE_ALN = 4
 };
 
-#define ARG_REPEATABLE 0x00000001
-
-/* a global table of possible arguments */
-struct arg {
-	const char short_arg;
-	char _padding[7];
-	const char *long_arg;
-
-	int (*fn) (struct cmd_context * cmd, struct arg * a);
-	uint32_t flags;
+#define ARG_COUNTABLE 0x00000001	/* E.g. -vvvv */
+#define ARG_GROUPABLE 0x00000002	/* E.g. --addtag */
 
+struct arg_values {
 	unsigned count;
 	char *value;
 	int32_t i_value;
@@ -117,6 +110,21 @@
 /*	void *ptr; // Currently not used. */
 };
 
+/* a global table of possible arguments */
+struct arg_props {
+	const char short_arg;
+	char _padding[7];
+	const char *long_arg;
+
+	int (*fn) (struct cmd_context *cmd, struct arg_values *av);
+	uint32_t flags;
+};
+
+struct arg_value_group_list {
+        struct dm_list list;
+        struct arg_values arg_values[0];
+};
+
 #define CACHE_VGMETADATA	0x00000001
 #define PERMITTED_READ_ONLY 	0x00000002
 
@@ -136,24 +144,24 @@
 void usage(const char *name);
 
 /* the argument verify/normalise functions */
-int yes_no_arg(struct cmd_context *cmd, struct arg *a);
-int yes_no_excl_arg(struct cmd_context *cmd, struct arg *a);
-int size_kb_arg(struct cmd_context *cmd, struct arg *a);
-int size_mb_arg(struct cmd_context *cmd, struct arg *a);
-int int_arg(struct cmd_context *cmd, struct arg *a);
-int int_arg_with_sign(struct cmd_context *cmd, struct arg *a);
-int int_arg_with_sign_and_percent(struct cmd_context *cmd, struct arg *a);
-int major_arg(struct cmd_context *cmd, struct arg *a);
-int minor_arg(struct cmd_context *cmd, struct arg *a);
-int string_arg(struct cmd_context *cmd, struct arg *a);
-int tag_arg(struct cmd_context *cmd, struct arg *a);
-int permission_arg(struct cmd_context *cmd, struct arg *a);
-int metadatatype_arg(struct cmd_context *cmd, struct arg *a);
-int units_arg(struct cmd_context *cmd, struct arg *a);
-int segtype_arg(struct cmd_context *cmd, struct arg *a);
-int alloc_arg(struct cmd_context *cmd, struct arg *a);
-int readahead_arg(struct cmd_context *cmd, struct arg *a);
-int metadatacopies_arg(struct cmd_context *cmd __attribute__((unused)), struct arg *a);
+int yes_no_arg(struct cmd_context *cmd, struct arg_values *av);
+int yes_no_excl_arg(struct cmd_context *cmd, struct arg_values *av);
+int size_kb_arg(struct cmd_context *cmd, struct arg_values *av);
+int size_mb_arg(struct cmd_context *cmd, struct arg_values *av);
+int int_arg(struct cmd_context *cmd, struct arg_values *av);
+int int_arg_with_sign(struct cmd_context *cmd, struct arg_values *av);
+int int_arg_with_sign_and_percent(struct cmd_context *cmd, struct arg_values *av);
+int major_arg(struct cmd_context *cmd, struct arg_values *av);
+int minor_arg(struct cmd_context *cmd, struct arg_values *av);
+int string_arg(struct cmd_context *cmd, struct arg_values *av);
+int tag_arg(struct cmd_context *cmd, struct arg_values *av);
+int permission_arg(struct cmd_context *cmd, struct arg_values *av);
+int metadatatype_arg(struct cmd_context *cmd, struct arg_values *av);
+int units_arg(struct cmd_context *cmd, struct arg_values *av);
+int segtype_arg(struct cmd_context *cmd, struct arg_values *av);
+int alloc_arg(struct cmd_context *cmd, struct arg_values *av);
+int readahead_arg(struct cmd_context *cmd, struct arg_values *av);
+int metadatacopies_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av);
 
 /* we use the enums to access the switches */
 unsigned arg_count(const struct cmd_context *cmd, int a);
@@ -169,6 +177,10 @@
 percent_t arg_percent_value(struct cmd_context *cmd, int a, const percent_t def);
 int arg_count_increment(struct cmd_context *cmd, int a);
 
+unsigned grouped_arg_count(const struct arg_values *av, int a);
+unsigned grouped_arg_is_set(const struct arg_values *av, int a);
+const char *grouped_arg_str_value(const struct arg_values *av, int a, const char *def);
+
 const char *command_name(struct cmd_context *cmd);
 
 int pvmove_poll(struct cmd_context *cmd, const char *pv, unsigned background);
--- LVM2/tools/vgchange.c	2010/10/29 21:15:23	1.116
+++ LVM2/tools/vgchange.c	2010/11/11 17:29:06	1.117
@@ -364,14 +364,21 @@
 			 int arg)
 {
 	const char *tag;
+	struct arg_value_group_list *current_group;
 
-	if (!(tag = arg_str_value(cmd, arg, NULL))) {
-		log_error("Failed to get tag");
-		return 0;
-	}
+	dm_list_iterate_items(current_group, &cmd->arg_value_groups) {
+		if (!grouped_arg_is_set(current_group->arg_values, arg))
+			continue;
+
+		if (!(tag = grouped_arg_str_value(current_group->arg_values, arg, NULL))) {
+			log_error("Failed to get tag");
+			return 0;
+		}
 
-	if (!vg_change_tag(vg, tag, arg == addtag_ARG))
-		return_0;
+		if (!vg_change_tag(vg, tag, arg == addtag_ARG))
+			return_0;
+
+	}
 
 	return 1;
 }
--- LVM2/tools/vgcreate.c	2010/06/30 20:03:53	1.80
+++ LVM2/tools/vgcreate.c	2010/11/11 17:29:06	1.81
@@ -24,6 +24,7 @@
 	const char *clustered_message = "";
 	char *vg_name;
 	struct pvcreate_params pp;
+	struct arg_value_group_list *current_group;
 
 	if (!argc) {
 		log_error("Please provide volume group name and "
@@ -85,21 +86,24 @@
 			 "(0 means unlimited)", vg->max_pv);
 
 	if (arg_count(cmd, addtag_ARG)) {
-		if (!(tag = arg_str_value(cmd, addtag_ARG, NULL))) {
-			log_error("Failed to get tag");
-			goto bad;
-		}
+		dm_list_iterate_items(current_group, &cmd->arg_value_groups) {
+			if (!grouped_arg_is_set(current_group->arg_values, addtag_ARG))
+				continue;
+
+			if (!(tag = grouped_arg_str_value(current_group->arg_values, addtag_ARG, NULL))) {
+				log_error("Failed to get tag");
+				goto bad;
+			}
 
-		if (!vg_change_tag(vg, tag, 1))
-			goto_bad;
+			if (!vg_change_tag(vg, tag, 1))
+				goto_bad;
+		}
 	}
 
-	if (vg_is_clustered(vg)) {
+	if (vg_is_clustered(vg))
 		clustered_message = "Clustered ";
-	} else {
-		if (locking_is_clustered())
-			clustered_message = "Non-clustered ";
-	}
+	else if (locking_is_clustered())
+		clustered_message = "Non-clustered ";
 
 	if (!archive(vg))
 		goto_bad;


