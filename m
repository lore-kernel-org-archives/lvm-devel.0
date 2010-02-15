From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 15 Feb 2010 16:26:50 -0000
Subject: LVM2 ./WHATS_NEW tools/lvmcmdline.c
Message-ID: <20100215162650.32495.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2010-02-15 16:26:50

Modified files:
	.              : WHATS_NEW 
	tools          : lvmcmdline.c 

Log message:
	Don't use LVM_UDEV_DISABLE_CHECKING environment variable anymore.
	
	Set the state automatically based on udev and libdevmapper dev path comparison.
	If these paths differ, disable udev checking.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1426&r2=1.1427
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.114&r2=1.115

--- LVM2/WHATS_NEW	2010/02/14 03:23:07	1.1426
+++ LVM2/WHATS_NEW	2010/02/15 16:26:48	1.1427
@@ -1,5 +1,6 @@
 Version 2.02.61 - 
 ===================================
+  Don't use LVM_UDEV_DISABLE_CHECKING env. var. anymore and set the state automatically.
   Add lvm2app exports lvm_pv_get_size(), lvm_pv_get_free(), and lvm_pv_get_dev_size().
   Fix off by 512 sizes for lvm2app.
   Add 'fail_if_percent_unsupported' arg to _percent() and _percent_run().
--- LVM2/tools/lvmcmdline.c	2010/02/03 03:58:08	1.114
+++ LVM2/tools/lvmcmdline.c	2010/02/15 16:26:49	1.115
@@ -42,6 +42,11 @@
 #  define OPTIND_INIT 1
 #endif
 
+#ifdef HAVE_UDEV_QUEUE_GET_UDEV_IS_ACTIVE
+#  define LIBUDEV_I_KNOW_THE_API_IS_SUBJECT_TO_CHANGE
+#  include <libudev.h>
+#endif
+
 /*
  * Table of valid switches
  */
@@ -912,17 +917,45 @@
 	cmd->handles_missing_pvs = 0;
 }
 
-static void _set_udev_checking()
+static int _set_udev_checking(struct cmd_context *cmd)
 {
-	const char *e;
+#ifdef HAVE_UDEV_QUEUE_GET_UDEV_IS_ACTIVE
+	struct udev *udev;
+	const char *udev_dev_dir;
+	size_t udev_dev_dir_len;
+	int dirs_diff;
+
+	if (!(udev = udev_new()) ||
+	    !(udev_dev_dir = udev_get_dev_path(udev)) ||
+	    !*udev_dev_dir) {
+		log_error("Could not get udev dev path.");
+		return 0;
+	}
+	udev_dev_dir_len = strlen(udev_dev_dir);
+
+	/* There's always a slash at the end of dev_dir. But check udev_dev_dir! */
+	if (udev_dev_dir[udev_dev_dir_len - 1] != '/')
+		dirs_diff = strncmp(cmd->dev_dir, udev_dev_dir,
+				    udev_dev_dir_len);
+	else
+		dirs_diff = strcmp(cmd->dev_dir, udev_dev_dir);
 
-	if ((e = getenv("DM_UDEV_DISABLE_CHECKING")) &&
-		!strcmp(e, "1"))
+	if (dirs_diff) {
+		log_debug("The path %s used for creating device nodes and "
+			  "symlinks that is set in the configuration differs "
+			  "from the path %s that is used by udev. All warnings "
+			  "about udev not working correctly while processing "
+			  "particular nodes and symlinks will be suppressed. "
+			  "These nodes and symlinks will be managed in each "
+			  "directory separately.",
+			   cmd->dev_dir, udev_dev_dir);
 		dm_udev_set_checking(0);
-
-	if ((e = getenv("LVM_UDEV_DISABLE_CHECKING")) &&
-		!strcmp(e, "1"))
 		init_udev_checking(0);
+	}
+
+	udev_unref(udev);
+#endif
+	return 1;
 }
 
 static const char *_copy_command_line(struct cmd_context *cmd, int argc, char **argv)
@@ -1019,7 +1052,8 @@
 	log_debug("O_DIRECT will be used");
 #endif
 
-	_set_udev_checking();
+	if (!_set_udev_checking(cmd))
+		goto_out;
 
 	if ((ret = _process_common_commands(cmd)))
 		goto_out;


