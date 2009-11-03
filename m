From: agk@sourceware.org <agk@sourceware.org>
Date: 3 Nov 2009 15:50:46 -0000
Subject: LVM2 ./WHATS_NEW ./WHATS_NEW_DM tools/dumpconf ...
Message-ID: <20091103155046.19199.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-11-03 15:50:44

Modified files:
	.              : WHATS_NEW WHATS_NEW_DM 
	tools          : dumpconfig.c lvconvert.c lvcreate.c 
	                 lvmcmdline.c lvresize.c polldaemon.c pvmove.c 
	                 reporter.c tools.h 

Log message:
	Tidy some uses of arg_count and introduce arg_is_set.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1312&r2=1.1313
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.310&r2=1.311
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dumpconfig.c.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.96&r2=1.97
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.208&r2=1.209
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.107&r2=1.108
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.114&r2=1.115
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/polldaemon.c.diff?cvsroot=lvm2&r1=1.28&r2=1.29
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvmove.c.diff?cvsroot=lvm2&r1=1.67&r2=1.68
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/reporter.c.diff?cvsroot=lvm2&r1=1.56&r2=1.57
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/tools.h.diff?cvsroot=lvm2&r1=1.64&r2=1.65

--- LVM2/WHATS_NEW	2009/11/03 11:17:46	1.1312
+++ LVM2/WHATS_NEW	2009/11/03 15:50:42	1.1313
@@ -1,5 +1,6 @@
 Version 2.02.55 -
 ===================================
+  Tidy some uses of arg_count and introduce arg_is_set.
   Export outnl and indent functions for modules.
   Flush stdout after yes/no prompt.
   Update vgsplit and vgcreate to use vg_set_clustered.
--- LVM2/WHATS_NEW_DM	2009/10/27 01:13:21	1.310
+++ LVM2/WHATS_NEW_DM	2009/11/03 15:50:42	1.311
@@ -1,5 +1,6 @@
 Version 1.02.40 - 
 ===================================
+  Fix hash lookup segfault when keys compared are different lengths.
 
 Version 1.02.39 - 26th October 2009
 ===================================
--- LVM2/tools/dumpconfig.c	2009/09/14 22:47:49	1.8
+++ LVM2/tools/dumpconfig.c	2009/11/03 15:50:43	1.9
@@ -17,10 +17,7 @@
 
 int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 {
-	const char *file = NULL;
-
-	if (arg_count(cmd, file_ARG))
-		file = arg_str_value(cmd, file_ARG, "");
+	const char *file = arg_str_value(cmd, file_ARG, NULL);
 
 	if (!write_config_file(cmd->cft, file, argc, argv)) {
 		stack;
--- LVM2/tools/lvconvert.c	2009/10/26 10:01:57	1.96
+++ LVM2/tools/lvconvert.c	2009/11/03 15:50:44	1.97
@@ -129,9 +129,7 @@
 		lp->mirrors_sign = arg_sign_value(cmd, mirrors_ARG, 0);
 	}
 
-	lp->alloc = ALLOC_INHERIT;
-	if (arg_count(cmd, alloc_ARG))
-		lp->alloc = arg_uint_value(cmd, alloc_ARG, lp->alloc);
+	lp->alloc = arg_uint_value(cmd, alloc_ARG, ALLOC_INHERIT);
 
 	if (lp->snapshot) {
 		if (arg_count(cmd, regionsize_ARG)) {
--- LVM2/tools/lvcreate.c	2009/09/14 22:47:49	1.208
+++ LVM2/tools/lvcreate.c	2009/11/03 15:50:44	1.209
@@ -33,8 +33,7 @@
 	char **argv = *pargv, *ptr;
 	char *vg_name;
 
-	if (arg_count(cmd, name_ARG))
-		lp->lv_name = arg_value(cmd, name_ARG);
+	lp->lv_name = arg_str_value(cmd, name_ARG, NULL);
 
 	if (lp->snapshot && !arg_count(cmd, virtualsize_ARG)) {
 		if (!argc) {
@@ -347,7 +346,7 @@
 
 	log_verbose("Setting logging type to %s", mirrorlog);
 
-	lp->nosync = arg_count(cmd, nosync_ARG) ? 1 : 0;
+	lp->nosync = arg_is_set(cmd, nosync_ARG);
 
 	if (arg_count(cmd, regionsize_ARG)) {
 		if (arg_sign_value(cmd, regionsize_ARG, 0) == SIGN_MINUS) {
@@ -521,10 +520,8 @@
 	/*
 	 * Permissions.
 	 */
-	if (arg_count(cmd, permission_ARG))
-		lp->permission = arg_uint_value(cmd, permission_ARG, 0);
-	else
-		lp->permission = LVM_READ | LVM_WRITE;
+	lp->permission = arg_uint_value(cmd, permission_ARG,
+					LVM_READ | LVM_WRITE);
 
 	/* Must not zero read only volume */
 	if (!(lp->permission & LVM_WRITE))
@@ -558,11 +555,7 @@
 		return 0;
 	}
 
-	if (arg_count(cmd, addtag_ARG) &&
-	    !(lp->tag = arg_str_value(cmd, addtag_ARG, NULL))) {
-		log_error("Failed to get tag");
-		return 0;
-	}
+	lp->tag = arg_str_value(cmd, addtag_ARG, NULL);
 
 	lcp->pv_count = argc;
 	lcp->pvs = argv;
--- LVM2/tools/lvmcmdline.c	2009/10/05 20:55:57	1.107
+++ LVM2/tools/lvmcmdline.c	2009/11/03 15:50:44	1.108
@@ -54,61 +54,58 @@
 static struct cmdline_context _cmdline;
 
 /* Command line args */
-/* FIXME: struct cmd_context * is unnecessary (large # files ) */
+/* FIXME: Move static _the_args into cmd? */
 unsigned arg_count(const struct cmd_context *cmd __attribute((unused)), int a)
 {
 	return _the_args[a].count;
 }
 
+unsigned arg_is_set(const struct cmd_context *cmd, int a)
+{
+	return arg_count(cmd, a) ? 1 : 0;
+}
+
 const char *arg_value(struct cmd_context *cmd __attribute((unused)), int a)
 {
 	return _the_args[a].value;
 }
 
-const char *arg_str_value(struct cmd_context *cmd __attribute((unused)),
-			  int a, const char *def)
+const char *arg_str_value(struct cmd_context *cmd, int a, const char *def)
 {
 	return arg_count(cmd, a) ? _the_args[a].value : def;
 }
 
-int32_t arg_int_value(struct cmd_context *cmd __attribute((unused)),
-		      int a, const int32_t def)
+int32_t arg_int_value(struct cmd_context *cmd, int a, const int32_t def)
 {
 	return arg_count(cmd, a) ? _the_args[a].i_value : def;
 }
 
-uint32_t arg_uint_value(struct cmd_context *cmd __attribute((unused)),
-			int a, const uint32_t def)
+uint32_t arg_uint_value(struct cmd_context *cmd, int a, const uint32_t def)
 {
 	return arg_count(cmd, a) ? _the_args[a].ui_value : def;
 }
 
-int64_t arg_int64_value(struct cmd_context *cmd __attribute((unused)),
-			int a, const int64_t def)
+int64_t arg_int64_value(struct cmd_context *cmd, int a, const int64_t def)
 {
 	return arg_count(cmd, a) ? _the_args[a].i64_value : def;
 }
 
-uint64_t arg_uint64_value(struct cmd_context *cmd __attribute((unused)),
-			  int a, const uint64_t def)
+uint64_t arg_uint64_value(struct cmd_context *cmd, int a, const uint64_t def)
 {
 	return arg_count(cmd, a) ? _the_args[a].ui64_value : def;
 }
 
-const void *arg_ptr_value(struct cmd_context *cmd __attribute((unused)),
-			  int a, const void *def)
+const void *arg_ptr_value(struct cmd_context *cmd, int a, const void *def)
 {
 	return arg_count(cmd, a) ? _the_args[a].ptr : def;
 }
 
-sign_t arg_sign_value(struct cmd_context *cmd __attribute((unused)),
-		      int a, const sign_t def)
+sign_t arg_sign_value(struct cmd_context *cmd, int a, const sign_t def)
 {
 	return arg_count(cmd, a) ? _the_args[a].sign : def;
 }
 
-percent_t arg_percent_value(struct cmd_context *cmd __attribute((unused)),
-			    int a, const percent_t def)
+percent_t arg_percent_value(struct cmd_context *cmd, int a, const percent_t def)
 {
 	return arg_count(cmd, a) ? _the_args[a].percent : def;
 }
--- LVM2/tools/lvresize.c	2009/07/07 01:18:35	1.114
+++ LVM2/tools/lvresize.c	2009/11/03 15:50:44	1.115
@@ -240,8 +240,8 @@
 		return 0;
 	}
 
-	lp->resizefs = arg_count(cmd, resizefs_ARG) ? 1 : 0;
-	lp->nofsck = arg_count(cmd, nofsck_ARG) ? 1 : 0;
+	lp->resizefs = arg_is_set(cmd, resizefs_ARG);
+	lp->nofsck = arg_is_set(cmd, nofsck_ARG);
 
 	if (!argc) {
 		log_error("Please provide the logical volume name");
--- LVM2/tools/polldaemon.c	2009/10/01 01:04:27	1.28
+++ LVM2/tools/polldaemon.c	2009/11/03 15:50:44	1.29
@@ -239,7 +239,7 @@
 {
 	struct daemon_parms parms;
 
-	parms.aborting = arg_count(cmd, abort_ARG) ? 1 : 0;
+	parms.aborting = arg_is_set(cmd, abort_ARG);
 	parms.background = background;
 	parms.interval = arg_uint_value(cmd, interval_ARG, DEFAULT_INTERVAL);
 	parms.progress_display = 1;
--- LVM2/tools/pvmove.c	2009/09/30 18:15:07	1.67
+++ LVM2/tools/pvmove.c	2009/11/03 15:50:44	1.68
@@ -608,6 +608,5 @@
 		}
 	}
 
-	return pvmove_poll(cmd, pv_name,
-			   arg_count(cmd, background_ARG) ? 1U : 0);
+	return pvmove_poll(cmd, pv_name, arg_is_set(cmd, background_ARG));
 }
--- LVM2/tools/reporter.c	2009/09/15 01:38:59	1.56
+++ LVM2/tools/reporter.c	2009/11/03 15:50:44	1.57
@@ -327,11 +327,9 @@
 	}
 
 	/* -O overrides default sort settings */
-	if (arg_count(cmd, sort_ARG))
-		keys = arg_str_value(cmd, sort_ARG, "");
+	keys = arg_str_value(cmd, sort_ARG, keys);
 
-	if (arg_count(cmd, separator_ARG))
-		separator = arg_str_value(cmd, separator_ARG, " ");
+	separator = arg_str_value(cmd, separator_ARG, separator);
 	if (arg_count(cmd, separator_ARG))
 		aligned = 0;
 	if (arg_count(cmd, aligned_ARG))
--- LVM2/tools/tools.h	2009/06/01 14:43:28	1.64
+++ LVM2/tools/tools.h	2009/11/03 15:50:44	1.65
@@ -153,7 +153,8 @@
 int readahead_arg(struct cmd_context *cmd, struct arg *a);
 
 /* we use the enums to access the switches */
-unsigned int arg_count(const struct cmd_context *cmd, int a);
+unsigned arg_count(const struct cmd_context *cmd, int a);
+unsigned arg_is_set(const struct cmd_context *cmd, int a);
 const char *arg_value(struct cmd_context *cmd, int a);
 const char *arg_str_value(struct cmd_context *cmd, int a, const char *def);
 int32_t arg_int_value(struct cmd_context *cmd, int a, const int32_t def); 


