From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 11 Dec 2008 03:31:48 -0000
Subject: LVM2 lib/commands/toolcontext.c tools/lvmcmdline.c
Message-ID: <20081211033148.26654.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-12-11 03:31:47

Modified files:
	lib/commands   : toolcontext.c 
	tools          : lvmcmdline.c 

Log message:
	Move init_test() from _apply_settings into _init_logging().
	
	This one we actually need to move.  _init_logging() is called from
	create_toolcontext(), which makes this call:
	/* Test mode */
	cmd->default_settings.test =
	find_config_tree_int(cmd, "global/test", 0);
	
	But it does not call init_test().  So we need an init_test() somewhere.
	The most logical place is to put it inside _init_logging(), since this
	is where the config value is read and default_settings are set.  Placing
	the init_test() call here matches what is done with other variables and
	seems to make sense.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.65&r2=1.66
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.80&r2=1.81

--- LVM2/lib/commands/toolcontext.c	2008/12/07 04:27:56	1.65
+++ LVM2/lib/commands/toolcontext.c	2008/12/11 03:31:47	1.66
@@ -162,6 +162,7 @@
 	/* Test mode */
 	cmd->default_settings.test =
 	    find_config_tree_int(cmd, "global/test", 0);
+	init_test(cmd->default_settings.test);
 
 	/* Settings for logging to file */
 	if (find_config_tree_int(cmd, "log/overwrite", DEFAULT_OVERWRITE))
--- LVM2/tools/lvmcmdline.c	2008/12/11 03:31:10	1.80
+++ LVM2/tools/lvmcmdline.c	2008/12/11 03:31:47	1.81
@@ -1091,7 +1091,6 @@
 	if (!(cmd = create_toolcontext(_cmdline.the_args, is_static, 0)))
 		return_NULL;
 
-	init_test(cmd->current_settings.test);
 	init_full_scan_done(0);
 	init_mirror_in_sync(0);
 


