From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 22 Apr 2011 12:07:36 -0000
Subject: LVM2/tools lvmcmdline.c
Message-ID: <20110422120736.20261.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-04-22 12:07:36

Modified files:
	tools          : lvmcmdline.c 

Log message:
	Use common udev_get_dev_dir() to get current device directory managed by udev.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.140&r2=1.141

--- LVM2/tools/lvmcmdline.c	2011/04/22 12:05:33	1.140
+++ LVM2/tools/lvmcmdline.c	2011/04/22 12:07:35	1.141
@@ -955,13 +955,11 @@
 static int _set_udev_checking(struct cmd_context *cmd)
 {
 #ifdef UDEV_SYNC_SUPPORT
-	struct udev *udev;
 	const char *udev_dev_dir;
 	size_t udev_dev_dir_len;
 	int dirs_diff;
 
-	if (!(udev = udev_new()) ||
-	    !(udev_dev_dir = udev_get_dev_path(udev)) ||
+	if (!(udev_dev_dir = udev_get_dev_dir()) ||
 	    !*udev_dev_dir) {
 		log_error("Could not get udev dev path.");
 		return 0;
@@ -988,7 +986,6 @@
 		init_udev_checking(0);
 	}
 
-	udev_unref(udev);
 #endif
 	return 1;
 }


