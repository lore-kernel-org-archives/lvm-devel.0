From: agk@sourceware.org <agk@sourceware.org>
Date: 29 Apr 2010 01:38:15 -0000
Subject: LVM2 ./WHATS_NEW lib/commands/toolcontext.c li ...
Message-ID: <20100429013815.24707.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-04-29 01:38:14

Modified files:
	.              : WHATS_NEW 
	lib/commands   : toolcontext.c toolcontext.h 
	tools          : lvcreate.c lvmcmdline.c lvresize.c tools.h 

Log message:
	Remove no-longer-used arg_ptr_value.
	Fix -M and --type to use strings not pointers that change on config refresh.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1540&r2=1.1541
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.93&r2=1.94
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.h.diff?cvsroot=lvm2&r1=1.37&r2=1.38
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.220&r2=1.221
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.117&r2=1.118
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.121&r2=1.122
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/tools.h.diff?cvsroot=lvm2&r1=1.66&r2=1.67

--- LVM2/WHATS_NEW	2010/04/27 15:26:58	1.1540
+++ LVM2/WHATS_NEW	2010/04/29 01:38:12	1.1541
@@ -1,5 +1,8 @@
 Version 2.02.64 -
 =================================
+  Remove no-longer-used arg_ptr_value.
+  Fix -M and --type to use strings not pointers that change on config refresh.
+  Fix regression in down-convert of mirror images with partial PV specification.
   Fix lvconvert error message when existing mirrored LV is not found.
   Disallow the direct removal of a merging snapshot.
   Set appropriate udev flags for reserved LVs.
--- LVM2/lib/commands/toolcontext.c	2010/04/01 10:34:09	1.93
+++ LVM2/lib/commands/toolcontext.c	2010/04/29 01:38:14	1.94
@@ -733,6 +733,19 @@
 	return 1;
 }
 
+struct format_type *get_format_by_name(struct cmd_context *cmd, const char *format)
+{
+        struct format_type *fmt;
+
+        dm_list_iterate_items(fmt, &cmd->formats)
+                if (!strcasecmp(fmt->name, format) ||
+                    !strcasecmp(fmt->name + 3, format) ||
+                    (fmt->alias && !strcasecmp(fmt->alias, format)))
+                        return fmt;
+
+        return NULL;
+}
+
 static int _init_formats(struct cmd_context *cmd)
 {
 	const char *format;
@@ -806,8 +819,8 @@
 	dm_list_iterate_items(fmt, &cmd->formats) {
 		if (!strcasecmp(fmt->name, format) ||
 		    (fmt->alias && !strcasecmp(fmt->alias, format))) {
-			cmd->default_settings.fmt = fmt;
-			cmd->fmt = cmd->default_settings.fmt;
+			cmd->default_settings.fmt_name = fmt->name;
+			cmd->fmt = fmt;
 			return 1;
 		}
 	}
@@ -1190,7 +1203,7 @@
 	return cmd;
 }
 
-static void _destroy_formats(struct dm_list *formats)
+static void _destroy_formats(struct cmd_context *cmd, struct dm_list *formats)
 {
 	struct dm_list *fmtl, *tmp;
 	struct format_type *fmt;
@@ -1268,7 +1281,7 @@
 	lvmcache_destroy(cmd, 0);
 	label_exit();
 	_destroy_segtypes(&cmd->segtypes);
-	_destroy_formats(&cmd->formats);
+	_destroy_formats(cmd, &cmd->formats);
 	if (cmd->filter) {
 		cmd->filter->destroy(cmd->filter);
 		cmd->filter = NULL;
@@ -1329,7 +1342,7 @@
 	lvmcache_destroy(cmd, 0);
 	label_exit();
 	_destroy_segtypes(&cmd->segtypes);
-	_destroy_formats(&cmd->formats);
+	_destroy_formats(cmd, &cmd->formats);
 	if (cmd->filter)
 		cmd->filter->destroy(cmd->filter);
 	if (cmd->mem)
--- LVM2/lib/commands/toolcontext.h	2010/01/07 19:54:22	1.37
+++ LVM2/lib/commands/toolcontext.h	2010/04/29 01:38:14	1.38
@@ -38,7 +38,7 @@
 	int udev_sync;
 	int cache_vgmetadata;
 	const char *msg_prefix;
-	struct format_type *fmt;
+	const char *fmt_name;
 	uint64_t unit_factor;
 	int cmd_name;		/* Show command name? */
 	mode_t umask;
@@ -110,4 +110,6 @@
 int config_files_changed(struct cmd_context *cmd);
 int init_lvmcache_orphans(struct cmd_context *cmd);
 
+struct format_type *get_format_by_name(struct cmd_context *cmd, const char *format);
+
 #endif
--- LVM2/tools/lvcreate.c	2010/04/13 01:54:34	1.220
+++ LVM2/tools/lvcreate.c	2010/04/29 01:38:14	1.221
@@ -330,9 +330,7 @@
 	/*
 	 * Check selected options are compatible and determine segtype
 	 */
-	lp->segtype = (const struct segment_type *)
-	    arg_ptr_value(cmd, type_ARG,
-			  get_segtype_from_string(cmd, "striped"));
+	lp->segtype = get_segtype_from_string(cmd, arg_str_value(cmd, type_ARG, "striped"));
 
 	if (arg_count(cmd, snapshot_ARG) || seg_is_snapshot(lp) ||
 	    arg_count(cmd, virtualsize_ARG))
--- LVM2/tools/lvmcmdline.c	2010/03/23 15:13:03	1.117
+++ LVM2/tools/lvmcmdline.c	2010/04/29 01:38:14	1.118
@@ -51,7 +51,7 @@
  * Table of valid switches
  */
 static struct arg _the_args[ARG_COUNT + 1] = {
-#define arg(a, b, c, d, e) {b, "", "--" c, d, e, 0, NULL, 0, 0, INT64_C(0), UINT64_C(0), SIGN_NONE, PERCENT_NONE, NULL},
+#define arg(a, b, c, d, e) {b, "", "--" c, d, e, 0, NULL, 0, 0, INT64_C(0), UINT64_C(0), SIGN_NONE, PERCENT_NONE},
 #include "args.h"
 #undef arg
 };
@@ -100,10 +100,12 @@
 	return arg_count(cmd, a) ? _the_args[a].ui64_value : def;
 }
 
+/* No longer used.
 const void *arg_ptr_value(struct cmd_context *cmd, int a, const void *def)
 {
 	return arg_count(cmd, a) ? _the_args[a].ptr : def;
 }
+*/
 
 sign_t arg_sign_value(struct cmd_context *cmd, int a, const sign_t def)
 {
@@ -182,21 +184,7 @@
 
 int metadatatype_arg(struct cmd_context *cmd, struct arg *a)
 {
-	struct format_type *fmt;
-	char *format;
-
-	format = a->value;
-
-	dm_list_iterate_items(fmt, &cmd->formats) {
-		if (!strcasecmp(fmt->name, format) ||
-		    !strcasecmp(fmt->name + 3, format) ||
-		    (fmt->alias && !strcasecmp(fmt->alias, format))) {
-			a->ptr = fmt;
-			return 1;
-		}
-	}
-
-	return 0;
+	return get_format_by_name(cmd, a->value) ? 1 : 0;
 }
 
 static int _get_int_arg(struct arg *a, char **ptr)
@@ -458,10 +446,7 @@
 
 int segtype_arg(struct cmd_context *cmd, struct arg *a)
 {
-	if (!(a->ptr = (void *) get_segtype_from_string(cmd, a->value)))
-		return 0;
-
-	return 1;
+	return get_segtype_from_string(cmd, a->value) ? 1 : 0;
 }
 
 /*
@@ -912,8 +897,9 @@
 
 	set_activation(cmd->current_settings.activation);
 
-	cmd->fmt = arg_ptr_value(cmd, metadatatype_ARG,
-				 cmd->current_settings.fmt);
+	cmd->fmt = get_format_by_name(cmd, arg_str_value(cmd, metadatatype_ARG,
+				      cmd->current_settings.fmt_name));
+
 	cmd->handles_missing_pvs = 0;
 }
 
--- LVM2/tools/lvresize.c	2010/04/09 01:00:11	1.121
+++ LVM2/tools/lvresize.c	2010/04/29 01:38:14	1.122
@@ -420,7 +420,8 @@
 	}
 
 	/* FIXME Support LVs with mixed segment types */
-	if (lp->segtype != arg_ptr_value(cmd, type_ARG, lp->segtype)) {
+	if (lp->segtype != get_segtype_from_string(cmd, arg_str_value(cmd, type_ARG,
+								      lp->segtype->name))) {
 		log_error("VolumeType does not match (%s)", lp->segtype->name);
 		return EINVALID_CMD_LINE;
 	}
--- LVM2/tools/tools.h	2010/02/03 03:58:08	1.66
+++ LVM2/tools/tools.h	2010/04/29 01:38:14	1.67
@@ -114,7 +114,7 @@
 	uint64_t ui64_value;
 	sign_t sign;
 	percent_t percent;
-	void *ptr;
+/*	void *ptr; // Currently not used. */
 };
 
 #define CACHE_VGMETADATA 0x00000001


