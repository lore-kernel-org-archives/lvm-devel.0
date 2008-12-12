From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 12 Dec 2008 03:30:42 -0000
Subject: LVM2 lib/commands/toolcontext.c tools/lvmcmdline.c
Message-ID: <20081212033042.3776.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-12-12 03:30:41

Modified files:
	lib/commands   : toolcontext.c 
	tools          : lvmcmdline.c 

Log message:
	Create _init_globals() and call from bottom of create_toolcontext().
	
	Move init_full_scan_done(0) and init_mirror_in_sync(0) from init_lvm()
	after call to create_toolcontext() to _init_globals(), called from bottom
	of create_toolcontext().  No functional change.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>
	Acked-by: James Cameron <james.cameron@hp.com>
	Acked-by: Alasdair G Kergon <agk@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.69&r2=1.70
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.86&r2=1.87

--- LVM2/lib/commands/toolcontext.c	2008/12/11 03:36:16	1.69
+++ LVM2/lib/commands/toolcontext.c	2008/12/12 03:30:41	1.70
@@ -990,6 +990,13 @@
 	cmd->rand_seed = (unsigned) time(NULL) + (unsigned) getpid();
 }
 
+static void _init_globals(struct cmd_context *cmd)
+{
+	init_full_scan_done(0);
+	init_mirror_in_sync(0);
+
+}
+
 /* Entry point */
 struct cmd_context *create_toolcontext(struct arg *the_args, unsigned is_static,
 				       unsigned is_long_lived)
@@ -1090,6 +1097,8 @@
 
 	_init_rand(cmd);
 
+	_init_globals(cmd);
+
 	cmd->default_settings.cache_vgmetadata = 1;
 	cmd->current_settings = cmd->default_settings;
 
--- LVM2/tools/lvmcmdline.c	2008/12/11 03:36:16	1.86
+++ LVM2/tools/lvmcmdline.c	2008/12/12 03:30:41	1.87
@@ -1091,9 +1091,6 @@
 	if (!(cmd = create_toolcontext(_cmdline.the_args, is_static, 0)))
 		return_NULL;
 
-	init_full_scan_done(0);
-	init_mirror_in_sync(0);
-
 	return cmd;
 }
 


