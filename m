From: agk@sourceware.org <agk@sourceware.org>
Date: 23 Jan 2007 15:58:08 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/lvm-functions.c ...
Message-ID: <20070123155808.14964.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-01-23 15:58:06

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : lvm-functions.c 
	lib/commands   : toolcontext.c toolcontext.h 
	tools          : lvmcmdline.c 

Log message:
	Fix refresh_toolcontext() always to wipe persistent device filter cache.
	Add is_long_lived to toolcontext.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.551&r2=1.552
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.26&r2=1.27
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.43&r2=1.44
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.h.diff?cvsroot=lvm2&r1=1.18&r2=1.19
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.38&r2=1.39

--- LVM2/WHATS_NEW	2007/01/23 13:08:34	1.551
+++ LVM2/WHATS_NEW	2007/01/23 15:58:05	1.552
@@ -1,5 +1,7 @@
 Version 2.02.20 -
 ===================================
+  Fix refresh_toolcontext() always to wipe persistent device filter cache.
+  Add is_long_lived to toolcontext.
   Add --clustered to man pages.
   Streamline dm_report_field_* interface.
   Change remaining dmeventd terminology 'register' to 'monitor'.
--- LVM2/daemons/clvmd/lvm-functions.c	2007/01/19 22:21:45	1.26
+++ LVM2/daemons/clvmd/lvm-functions.c	2007/01/23 15:58:05	1.27
@@ -575,7 +575,7 @@
 /* Called to initialise the LVM context of the daemon */
 int init_lvm(int using_gulm)
 {
-	if (!(cmd = create_toolcontext(NULL, 0))) {
+	if (!(cmd = create_toolcontext(NULL, 0, 1))) {
 		log_error("Failed to allocate command context");
 		return 0;
 	}
--- LVM2/lib/commands/toolcontext.c	2006/11/04 03:34:09	1.43
+++ LVM2/lib/commands/toolcontext.c	2007/01/23 15:58:05	1.44
@@ -575,7 +575,7 @@
 	    filters[0] : composite_filter_create(nr_filt, filters);
 }
 
-static int _init_filters(struct cmd_context *cmd)
+static int _init_filters(struct cmd_context *cmd, unsigned load_persistent_cache)
 {
 	const char *dev_cache;
 	struct dev_filter *f3, *f4;
@@ -608,8 +608,13 @@
 	if (!*cmd->sys_dir)
 		cmd->dump_filter = 0;
 
-	if (!stat(dev_cache, &st) &&
-	    (st.st_ctime != config_file_timestamp(cmd->cft)) &&
+	/*
+	 * Only load persistent filter device cache on startup if it is newer
+	 * than the config file and this is not a long-lived process.
+	 */
+	if (load_persistent_cache && !cmd->is_long_lived &&
+	    !stat(dev_cache, &st) &&
+	    (st.st_ctime > config_file_timestamp(cmd->cft)) &&
 	    !persistent_filter_load(f4, NULL))
 		log_verbose("Failed to load existing device cache from %s",
 			    dev_cache);
@@ -881,7 +886,8 @@
 }
 
 /* Entry point */
-struct cmd_context *create_toolcontext(struct arg *the_args, unsigned is_static)
+struct cmd_context *create_toolcontext(struct arg *the_args, unsigned is_static,
+				       unsigned is_long_lived)
 {
 	struct cmd_context *cmd;
 
@@ -905,6 +911,7 @@
 	memset(cmd, 0, sizeof(*cmd));
 	cmd->args = the_args;
 	cmd->is_static = is_static;
+	cmd->is_long_lived = is_long_lived;
 	cmd->hosttags = 0;
 	list_init(&cmd->formats);
 	list_init(&cmd->segtypes);
@@ -953,7 +960,7 @@
 	if (!_init_dev_cache(cmd))
 		goto error;
 
-	if (!_init_filters(cmd))
+	if (!_init_filters(cmd, 1))
 		goto error;
 
 	if (!(cmd->mem = dm_pool_create("command", 4 * 1024))) {
@@ -1022,10 +1029,10 @@
 {
 	log_verbose("Reloading config files");
 
-	if (cmd->config_valid) {
-		if (cmd->dump_filter)
-			persistent_filter_dump(cmd->filter);
-	}
+	/*
+	 * Don't update the persistent filter cache as we will
+	 * perform a full rescan.
+	 */
 
 	activation_release();
 	lvmcache_destroy();
@@ -1064,7 +1071,7 @@
 	if (!_init_dev_cache(cmd))
 		return 0;
 
-	if (!_init_filters(cmd))
+	if (!_init_filters(cmd, 0))
 		return 0;
 
 	if (!_init_formats(cmd))
--- LVM2/lib/commands/toolcontext.h	2006/08/18 21:17:18	1.18
+++ LVM2/lib/commands/toolcontext.h	2007/01/23 15:58:06	1.19
@@ -65,6 +65,7 @@
 	struct arg *args;
 	char **argv;
 	unsigned is_static;	/* Static binary? */
+	unsigned is_long_lived;	/* Optimises persistent_filter handling */
 
 	struct dev_filter *filter;
 	int dump_filter;	/* Dump filter when exiting? */
@@ -88,7 +89,7 @@
 	char proc_dir[PATH_MAX];
 };
 
-struct cmd_context *create_toolcontext(struct arg *the_args, unsigned is_static);
+struct cmd_context *create_toolcontext(struct arg *the_args, unsigned is_static, unsigned is_long_lived);
 void destroy_toolcontext(struct cmd_context *cmd);
 int refresh_toolcontext(struct cmd_context *cmd);
 int config_files_changed(struct cmd_context *cmd);
--- LVM2/tools/lvmcmdline.c	2006/11/14 15:28:50	1.38
+++ LVM2/tools/lvmcmdline.c	2007/01/23 15:58:06	1.39
@@ -1030,7 +1030,7 @@
 {
 	struct cmd_context *cmd;
 
-	if (!(cmd = create_toolcontext(&the_args[0], is_static))) {
+	if (!(cmd = create_toolcontext(&the_args[0], is_static, 0))) {
 		stack;
 		return NULL;
 	}


