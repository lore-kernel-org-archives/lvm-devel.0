From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 23 Mar 2010 15:13:03 -0000
Subject: LVM2/tools lvmcmdline.c
Message-ID: <20100323151303.31930.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2010-03-23 15:13:03

Modified files:
	tools          : lvmcmdline.c 

Log message:
	UDEV_SYNC_SUPPORT, not UDEV_SYNC!

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.116&r2=1.117

--- LVM2/tools/lvmcmdline.c	2010/03/23 14:43:19	1.116
+++ LVM2/tools/lvmcmdline.c	2010/03/23 15:13:03	1.117
@@ -919,7 +919,7 @@
 
 static int _set_udev_checking(struct cmd_context *cmd)
 {
-#ifdef UDEV_SYNC
+#ifdef UDEV_SYNC_SUPPORT
 	struct udev *udev;
 	const char *udev_dev_dir;
 	size_t udev_dev_dir_len;


