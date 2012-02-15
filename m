From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 15 Feb 2012 15:10:32 -0000
Subject: LVM2/udev 13-dm-disk.rules
Message-ID: <20120215151032.14788.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-02-15 15:10:31

Modified files:
	udev           : 13-dm-disk.rules 

Log message:
	typo

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/udev/13-dm-disk.rules.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/udev/13-dm-disk.rules	2012/02/15 14:50:34	1.6
+++ LVM2/udev/13-dm-disk.rules	2012/02/15 15:10:31	1.7
@@ -25,7 +25,7 @@
 ENV{ID_FS_USAGE}=="filesystem|other", ENV{ID_FS_LABEL_ENC}=="?*", SYMLINK+="disk/by-label/$env{ID_FS_LABEL_ENC}"
 
 # Add inotify watch to track changes on this device.
-# Using the watch rule is not optimal - it generetes a lot of spurious
+# Using the watch rule is not optimal - it generates a lot of spurious
 # and useless events whenever the device opened for read-write is closed.
 # The best would be to generete the event directly in the tool changing
 # relevant information so only relevant events will be processed


