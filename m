From: agk@sourceware.org <agk@sourceware.org>
Date: 8 Dec 2011 21:24:12 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/lvm-functions.c ...
Message-ID: <20111208212412.30358.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-12-08 21:24:10

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : lvm-functions.c 
	daemons/lvmetad: testclient.c 
	lib/commands   : toolcontext.c toolcontext.h 
	lib/mm         : memlock.c 
	liblvm         : lvm_base.c 
	tools          : lvmcmdline.c 

Log message:
	Only use built-in stack size in clvmd - ignore lvm.conf.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2204&r2=1.2205
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.127&r2=1.128
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/testclient.c.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.142&r2=1.143
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.h.diff?cvsroot=lvm2&r1=1.47&r2=1.48
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mm/memlock.c.diff?cvsroot=lvm2&r1=1.46&r2=1.47
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_base.c.diff?cvsroot=lvm2&r1=1.22&r2=1.23
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.148&r2=1.149

--- LVM2/WHATS_NEW	2011/12/06 19:30:15	1.2204
+++ LVM2/WHATS_NEW	2011/12/08 21:24:08	1.2205
@@ -47,7 +47,7 @@
   Fix lv_info open_count test for disabled verify_udev_operations (2.02.86).
   Simplify code for lvm worker thread in clvmd.                     
   Use pthread_barrier to synchronize clvmd threads at startup.
-  Limit clvmd's thread size to 128KiB.
+  Limit clvmd's thread size to 128KiB and ignore activation/reserved_stack.
   Reduce default preallocated stack size to 64KiB.
   Add check for access through NULL pointer when refresh_filter() fails.
   Use pthread condition for SINGLENODE lock implementation.
--- LVM2/daemons/clvmd/lvm-functions.c	2011/12/08 18:32:34	1.127
+++ LVM2/daemons/clvmd/lvm-functions.c	2011/12/08 21:24:08	1.128
@@ -880,7 +880,7 @@
 	if (!get_initial_state(excl_uuid))
 		log_error("Cannot load initial lock states.");
 
-	if (!(cmd = create_toolcontext(1, NULL, 0))) {
+	if (!(cmd = create_toolcontext(1, NULL, 0, 1))) {
 		log_error("Failed to allocate command context");
 		return 0;
 	}
--- LVM2/daemons/lvmetad/testclient.c	2011/07/20 15:15:41	1.9
+++ LVM2/daemons/lvmetad/testclient.c	2011/12/08 21:24:08	1.10
@@ -108,7 +108,7 @@
 
 	if (argc > 1) {
 		int i;
-		struct cmd_context *cmd = create_toolcontext(0, NULL, 0);
+		struct cmd_context *cmd = create_toolcontext(0, NULL, 0, 0);
 		for (i = 1; i < argc; ++i) {
 			const char *uuid = NULL;
 			scan(h, argv[i]);
--- LVM2/lib/commands/toolcontext.c	2011/11/28 20:37:51	1.142
+++ LVM2/lib/commands/toolcontext.c	2011/12/08 21:24:09	1.143
@@ -1224,7 +1224,8 @@
 /* Entry point */
 struct cmd_context *create_toolcontext(unsigned is_long_lived,
 				       const char *system_dir,
-				       unsigned set_buffering)
+				       unsigned set_buffering,
+				       unsigned threaded)
 {
 	struct cmd_context *cmd;
 
@@ -1246,6 +1247,7 @@
 		return NULL;
 	}
 	cmd->is_long_lived = is_long_lived;
+	cmd->threaded = threaded ? 1 : 0;
 	cmd->handles_missing_pvs = 0;
 	cmd->handles_unknown_segments = 0;
 	cmd->independent_metadata_areas = 0;
--- LVM2/lib/commands/toolcontext.h	2011/11/28 20:37:52	1.47
+++ LVM2/lib/commands/toolcontext.h	2011/12/08 21:24:09	1.48
@@ -85,6 +85,7 @@
 	unsigned partial_activation:1;
 	unsigned si_unit_consistency:1;
 	unsigned metadata_read_only:1;
+	unsigned threaded:1;		/* Set if running within a thread e.g. clvmd */
 
 	unsigned independent_metadata_areas:1;	/* Active formats have MDAs outside PVs */
 
@@ -117,7 +118,8 @@
  */
 struct cmd_context *create_toolcontext(unsigned is_long_lived,
 				       const char *system_dir,
-				       unsigned set_buffering);
+				       unsigned set_buffering,
+				       unsigned threaded);
 void destroy_toolcontext(struct cmd_context *cmd);
 int refresh_toolcontext(struct cmd_context *cmd);
 int refresh_filters(struct cmd_context *cmd);
--- LVM2/lib/mm/memlock.c	2011/08/30 14:55:18	1.46
+++ LVM2/lib/mm/memlock.c	2011/12/08 21:24:09	1.47
@@ -445,9 +445,10 @@
 
 void memlock_init(struct cmd_context *cmd)
 {
-	_size_stack = find_config_tree_int(cmd,
-				      "activation/reserved_stack",
-				      DEFAULT_RESERVED_STACK) * 1024;
+	/* When threaded, caller already limited stack size so just use the default. */
+	_size_stack = 1024 * (cmd->threaded ? DEFAULT_RESERVED_STACK :
+					      find_config_tree_int(cmd, "activation/reserved_stack",
+								   DEFAULT_RESERVED_STACK));
 	_size_malloc_tmp = find_config_tree_int(cmd,
 					   "activation/reserved_memory",
 					   DEFAULT_RESERVED_MEMORY) * 1024;
--- LVM2/liblvm/lvm_base.c	2011/06/15 13:29:48	1.22
+++ LVM2/liblvm/lvm_base.c	2011/12/08 21:24:09	1.23
@@ -37,7 +37,7 @@
 	/* create context */
 	/* FIXME: split create_toolcontext */
 	/* FIXME: make all globals configurable */
-	cmd = create_toolcontext(0, system_dir, 1);
+	cmd = create_toolcontext(0, system_dir, 1, 0);
 	if (!cmd)
 		return NULL;
 
--- LVM2/tools/lvmcmdline.c	2011/09/16 12:10:02	1.148
+++ LVM2/tools/lvmcmdline.c	2011/12/08 21:24:10	1.149
@@ -1237,7 +1237,7 @@
 	if (!udev_init_library_context())
 		stack;
 
-	if (!(cmd = create_toolcontext(0, NULL, 1)))
+	if (!(cmd = create_toolcontext(0, NULL, 1, 0)))
 		return_NULL;
 
 	_cmdline.arg_props = &_arg_props[0];


