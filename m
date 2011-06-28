From: agk@sourceware.org <agk@sourceware.org>
Date: 28 Jun 2011 00:23:07 -0000
Subject: LVM2 ./WHATS_NEW lib/commands/toolcontext.c
Message-ID: <20110628002307.9943.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-06-28 00:23:07

Modified files:
	.              : WHATS_NEW 
	lib/commands   : toolcontext.c 

Log message:
	Remove enforcement of udev verification when using non-standard /dev location.
	If you change the dev dir, it's your responsibility to adjust udev rules
	or tell lvm not to use udev too.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2027&r2=1.2028
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.122&r2=1.123

--- LVM2/WHATS_NEW	2011/06/27 21:43:58	1.2027
+++ LVM2/WHATS_NEW	2011/06/28 00:23:06	1.2028
@@ -1,5 +1,6 @@
 Version 2.02.86 -  
 =================================
+  Remove enforcement of udev verification when using non-standard /dev location.
   Fix to preserve exclusive activation of mirror while up-converting.
   Reject allocation if number of extents is not divisible by area count.
   Fix issue preventing cluster mirror creation.
--- LVM2/lib/commands/toolcontext.c	2011/06/27 23:43:04	1.122
+++ LVM2/lib/commands/toolcontext.c	2011/06/28 00:23:06	1.123
@@ -200,51 +200,6 @@
 	reset_lvm_errno(1);
 }
 
-/*
- * Prevent people disabling udev fallback if using a non-standard dev dir.
- * FIXME: Remove this function.  lvm.conf provides sufficient control.
- */
-static int _enforce_udev_fallback(struct cmd_context *cmd)
-{
-#ifdef UDEV_SYNC_SUPPORT
-	const char *udev_dev_dir;
-	size_t udev_dev_dir_len;
-	unsigned dirs_match;
-
-	if (!(udev_dev_dir = udev_get_dev_dir()) ||
-	    !*udev_dev_dir) {
-		log_error("Could not get udev dev path.");
-		return 0;
-	}
-	udev_dev_dir_len = strlen(udev_dev_dir);
-
-	/* There's always a slash at the end of dev_dir. But check udev_dev_dir! */
-	if (udev_dev_dir[udev_dev_dir_len - 1] != '/')
-		dirs_match = (udev_dev_dir_len + 1 == strlen(cmd->dev_dir)) &&
-			    !strncmp(cmd->dev_dir, udev_dev_dir, udev_dev_dir_len);
-	else
-		dirs_match = !strcmp(cmd->dev_dir, udev_dev_dir);
-
-	if (!dirs_match) {
-		log_debug("The path %s used for creating device nodes and "
-			  "symlinks that is set in the configuration differs "
-			  "from the path %s that is used by udev. All warnings "
-			  "about udev not working correctly while processing "
-			  "particular nodes and symlinks will be suppressed. "
-			  "These nodes and symlinks will be managed in each "
-			  "directory separately.",
-			   cmd->dev_dir, udev_dev_dir);
-		dm_udev_set_checking(0);
-		init_udev_checking(0);
-
-		/* Device directories differ - we must use the fallback code! */
-		cmd->default_settings.udev_fallback = 1;
-	}
-
-#endif
-	return 1;
-}
-
 static int _process_config(struct cmd_context *cmd)
 {
 	mode_t old_umask;
@@ -337,11 +292,9 @@
 	 * in runtime and still have only udev to create the nodes and symlinks
 	 * without any fallback.
 	 */
-	if ((cmd->default_settings.udev_fallback = cmd->default_settings.udev_rules ?
+	cmd->default_settings.udev_fallback = cmd->default_settings.udev_rules ?
 		find_config_tree_int(cmd, "activation/verify_udev_operations",
-				     DEFAULT_VERIFY_UDEV_OPERATIONS) : 1) &&
-	    !_enforce_udev_fallback(cmd))
-		return_0;
+				     DEFAULT_VERIFY_UDEV_OPERATIONS) : 1;
 
 #else
 	/* We must use old node/symlink creation code if not compiled with udev support at all! */


