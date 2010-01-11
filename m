From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 11 Jan 2010 15:36:26 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/.exported_symbols li ...
Message-ID: <20100111153626.31532.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2010-01-11 15:36:25

Modified files:
	.              : WHATS_NEW_DM 
	libdm          : .exported_symbols libdevmapper.h libdm-common.c 
	tools          : dmsetup.c 

Log message:
	Add support to disable udev checking: DM_UDEV_DISABLE_CHECKING=1 env. variable.
	
	Sometimes it is really needed to switch off udev checking and the warnings we show when
	we detect that udev has not done its job right - the messages like "Udev should have done
	this and that. Falling back to direct node creation/removal. " etc.
	
	This would be especially handy while setting DM_DEV_DIR env var that could be set to a
	different location than standard /dev (udev can't create nodes/symlinks out of that one
	directory that is configured into udevd). The exact same situation happens while we're
	running our tests.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.326&r2=1.327
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/.exported_symbols.diff?cvsroot=lvm2&r1=1.46&r2=1.47
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.104&r2=1.105
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.91&r2=1.92
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.131&r2=1.132

--- LVM2/WHATS_NEW_DM	2010/01/07 19:54:21	1.326
+++ LVM2/WHATS_NEW_DM	2010/01/11 15:36:24	1.327
@@ -1,5 +1,6 @@
 Version 1.02.41 -
 ====================================
+  Add support to disable udev checking: DM_UDEV_DISABLE_CHECKING=1 env. variable.
   Add dm_tree_add_dev_with_udev_flags to provide wider support for udev flags.
   Add --noudevrules option for dmsetup to disable /dev node management by udev.
   Update code to show all fields for 'dmsetup info -c -o all'.
--- LVM2/libdm/.exported_symbols	2010/01/07 19:54:22	1.46
+++ LVM2/libdm/.exported_symbols	2010/01/11 15:36:24	1.47
@@ -163,5 +163,7 @@
 dm_cookie_supported
 dm_udev_set_sync_support
 dm_udev_get_sync_support
+dm_udev_set_checking
+dm_udev_get_checking
 dm_udev_complete
 dm_udev_wait
--- LVM2/libdm/libdevmapper.h	2010/01/07 19:54:22	1.104
+++ LVM2/libdm/libdevmapper.h	2010/01/11 15:36:24	1.105
@@ -1086,6 +1086,8 @@
  */
 void dm_udev_set_sync_support(int sync_with_udev);
 int dm_udev_get_sync_support(void);
+void dm_udev_set_checking(int checking);
+int dm_udev_get_checking(void);
 int dm_udev_complete(uint32_t cookie);
 int dm_udev_wait(uint32_t cookie);
 
--- LVM2/libdm/libdm-common.c	2009/11/13 12:43:22	1.91
+++ LVM2/libdm/libdm-common.c	2010/01/11 15:36:24	1.92
@@ -52,6 +52,7 @@
 #ifdef UDEV_SYNC_SUPPORT
 static int _udev_running = -1;
 static int _sync_with_udev = 1;
+static int _udev_checking = 1;
 #endif
 
 /*
@@ -428,7 +429,8 @@
 				  dev_name);
 			return 0;
 		}
-	} else if (dm_udev_get_sync_support() && check_udev)
+	} else if (dm_udev_get_sync_support() && dm_udev_get_checking() &&
+		   check_udev)
 		log_warn("%s not set up by udev: Falling back to direct "
 			 "node creation.", path);
 
@@ -462,7 +464,8 @@
 
 	if (stat(path, &info) < 0)
 		return 1;
-	else if (dm_udev_get_sync_support() && check_udev)
+	else if (dm_udev_get_sync_support() && dm_udev_get_checking() &&
+		 check_udev)
 		log_warn("Node %s was not removed by udev. "
 			 "Falling back to direct node removal.", path);
 
@@ -492,7 +495,8 @@
 				  "is already present", newpath);
 			return 0;
 		}
-		else if (dm_udev_get_sync_support() && check_udev) {
+		else if (dm_udev_get_sync_support() && dm_udev_get_checking() &&
+			 check_udev) {
 			if (stat(oldpath, &info) < 0 &&
 				 errno == ENOENT)
 				/* assume udev already deleted this */
@@ -516,7 +520,8 @@
 			return 0;
 		}
 	}
-	else if (dm_udev_get_sync_support() && check_udev)
+	else if (dm_udev_get_sync_support() && dm_udev_get_checking() &&
+		 check_udev)
 		log_warn("The node %s should have been renamed to %s "
 			 "by udev but new node is not present. "
 			 "Falling back to direct node rename.",
@@ -884,6 +889,15 @@
 	return 0;
 }
 
+void dm_udev_set_checking(int checking)
+{
+}
+
+int dm_udev_get_checking(void)
+{
+	return 0;
+}
+
 int dm_task_set_cookie(struct dm_task *dmt, uint32_t *cookie, uint16_t flags)
 {
 	if (dm_cookie_supported())
@@ -963,6 +977,19 @@
 	return dm_cookie_supported() && _udev_running && _sync_with_udev;
 }
 
+void dm_udev_set_checking(int checking)
+{
+	if ((_udev_checking = checking))
+		log_debug("DM udev checking enabled");
+	else
+		log_debug("DM udev checking disabled");
+}
+
+int dm_udev_get_checking(void)
+{
+	return _udev_checking;
+}
+
 static int _get_cookie_sem(uint32_t cookie, int *semid)
 {
 	if (cookie >> 16 != DM_COOKIE_MAGIC) {
--- LVM2/tools/dmsetup.c	2010/01/07 19:45:12	1.131
+++ LVM2/tools/dmsetup.c	2010/01/11 15:36:25	1.132
@@ -3158,6 +3158,7 @@
 	struct command *c;
 	int r = 1;
 	const char *dev_dir;
+	const char *disable_udev_checking;
 
 	(void) setlocale(LC_ALL, "");
 
@@ -3207,6 +3208,11 @@
 	if (_switches[NOUDEVSYNC_ARG])
 		dm_udev_set_sync_support(0);
 
+	disable_udev_checking = getenv("DM_UDEV_DISABLE_CHECKING");
+	if ((disable_udev_checking && *disable_udev_checking) &&
+	    !strcmp(disable_udev_checking, "1"))
+		dm_udev_set_checking(0);
+
       doit:
 	if (!c->fn(argc, argv, NULL)) {
 		fprintf(stderr, "Command failed\n");


