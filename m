From: agk@sourceware.org <agk@sourceware.org>
Date: 27 Jun 2011 23:43:05 -0000
Subject: LVM2 lib/commands/toolcontext.c tools/lvmcmdline.c
Message-ID: <20110627234305.26844.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-06-27 23:43:04

Modified files:
	lib/commands   : toolcontext.c 
	tools          : lvmcmdline.c 

Log message:
	Move _set_lvm_fallback into toolcontext, fix string comparison (/devtest
	matched /dev) and note that function should go anyway as it can be
	overriding a valid config.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.121&r2=1.122
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.143&r2=1.144

--- LVM2/lib/commands/toolcontext.c	2011/06/27 21:43:59	1.121
+++ LVM2/lib/commands/toolcontext.c	2011/06/27 23:43:04	1.122
@@ -200,6 +200,51 @@
 	reset_lvm_errno(1);
 }
 
+/*
+ * Prevent people disabling udev fallback if using a non-standard dev dir.
+ * FIXME: Remove this function.  lvm.conf provides sufficient control.
+ */
+static int _enforce_udev_fallback(struct cmd_context *cmd)
+{
+#ifdef UDEV_SYNC_SUPPORT
+	const char *udev_dev_dir;
+	size_t udev_dev_dir_len;
+	unsigned dirs_match;
+
+	if (!(udev_dev_dir = udev_get_dev_dir()) ||
+	    !*udev_dev_dir) {
+		log_error("Could not get udev dev path.");
+		return 0;
+	}
+	udev_dev_dir_len = strlen(udev_dev_dir);
+
+	/* There's always a slash at the end of dev_dir. But check udev_dev_dir! */
+	if (udev_dev_dir[udev_dev_dir_len - 1] != '/')
+		dirs_match = (udev_dev_dir_len + 1 == strlen(cmd->dev_dir)) &&
+			    !strncmp(cmd->dev_dir, udev_dev_dir, udev_dev_dir_len);
+	else
+		dirs_match = !strcmp(cmd->dev_dir, udev_dev_dir);
+
+	if (!dirs_match) {
+		log_debug("The path %s used for creating device nodes and "
+			  "symlinks that is set in the configuration differs "
+			  "from the path %s that is used by udev. All warnings "
+			  "about udev not working correctly while processing "
+			  "particular nodes and symlinks will be suppressed. "
+			  "These nodes and symlinks will be managed in each "
+			  "directory separately.",
+			   cmd->dev_dir, udev_dev_dir);
+		dm_udev_set_checking(0);
+		init_udev_checking(0);
+
+		/* Device directories differ - we must use the fallback code! */
+		cmd->default_settings.udev_fallback = 1;
+	}
+
+#endif
+	return 1;
+}
+
 static int _process_config(struct cmd_context *cmd)
 {
 	mode_t old_umask;
@@ -285,20 +330,23 @@
 								"activation/udev_sync",
 								DEFAULT_UDEV_SYNC);
 
-	#ifdef UDEV_SYNC_SUPPORT
+#ifdef UDEV_SYNC_SUPPORT
 	/*
 	 * We need udev rules to be applied, otherwise we would end up with no
 	 * nodes and symlinks! However, we can disable the synchronization itself
 	 * in runtime and still have only udev to create the nodes and symlinks
 	 * without any fallback.
 	 */
-	cmd->default_settings.udev_fallback = cmd->default_settings.udev_rules ?
-					find_config_tree_int(cmd, "activation/verify_udev_operations",
-							     DEFAULT_VERIFY_UDEV_OPERATIONS) : 1;
-	#else
+	if ((cmd->default_settings.udev_fallback = cmd->default_settings.udev_rules ?
+		find_config_tree_int(cmd, "activation/verify_udev_operations",
+				     DEFAULT_VERIFY_UDEV_OPERATIONS) : 1) &&
+	    !_enforce_udev_fallback(cmd))
+		return_0;
+
+#else
 	/* We must use old node/symlink creation code if not compiled with udev support at all! */
 	cmd->default_settings.udev_fallback = 1;
-	#endif
+#endif
 
 	cmd->stripe_filler = find_config_tree_str(cmd,
 						  "activation/missing_stripe_filler",
--- LVM2/tools/lvmcmdline.c	2011/06/17 14:50:54	1.143
+++ LVM2/tools/lvmcmdline.c	2011/06/27 23:43:04	1.144
@@ -42,10 +42,6 @@
 #  define OPTIND_INIT 1
 #endif
 
-#ifdef UDEV_SYNC_SUPPORT
-#  include <libudev.h>
-#endif
-
 /*
  * Table of valid switches
  */
@@ -864,8 +860,10 @@
 	} else
 		init_trust_cache(0);
 
-	if (arg_count(cmd, noudevsync_ARG))
+	if (arg_count(cmd, noudevsync_ARG)) {
 		cmd->current_settings.udev_sync = 0;
+		cmd->current_settings.udev_fallback = 1;
+	}
 
 	/* Handle synonyms */
 	if (!_merge_synonym(cmd, resizable_ARG, resizeable_ARG) ||
@@ -952,47 +950,6 @@
 	cmd->handles_missing_pvs = 0;
 }
 
-static int _set_udev_fallback(struct cmd_context *cmd)
-{
-#ifdef UDEV_SYNC_SUPPORT
-	const char *udev_dev_dir;
-	size_t udev_dev_dir_len;
-	int dirs_diff;
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
-		dirs_diff = strncmp(cmd->dev_dir, udev_dev_dir,
-				    udev_dev_dir_len);
-	else
-		dirs_diff = strcmp(cmd->dev_dir, udev_dev_dir);
-
-	if (dirs_diff) {
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
-		cmd->current_settings.udev_fallback = 1;
-	}
-
-#endif
-	return 1;
-}
-
 static const char *_copy_command_line(struct cmd_context *cmd, int argc, char **argv)
 {
 	int i, space;
@@ -1091,9 +1048,6 @@
 	log_debug("O_DIRECT will be used");
 #endif
 
-	if (!_set_udev_fallback(cmd))
-		goto_out;
-
 	if ((ret = _process_common_commands(cmd))) {
 		if (ret != ECMD_PROCESSED)
 			stack;


