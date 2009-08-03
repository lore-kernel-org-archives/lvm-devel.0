From: agk@sourceware.org <agk@sourceware.org>
Date: 3 Aug 2009 18:33:08 -0000
Subject: LVM2/libdm libdm-common.c
Message-ID: <20090803183308.23850.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-08-03 18:33:08

Modified files:
	libdm          : libdm-common.c 

Log message:
	Add udev checks.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.72&r2=1.73

--- LVM2/libdm/libdm-common.c	2009/08/03 18:01:47	1.72
+++ LVM2/libdm/libdm-common.c	2009/08/03 18:33:08	1.73
@@ -355,7 +355,9 @@
 				  dev_name);
 			return 0;
 		}
-	}
+	} else if (dm_udev_get_sync_support())
+		log_warn("%s not set up by udev: Falling back to direct "
+			 "node creation.", path);
 
 	old_mask = umask(0);
 	if (mknod(path, S_IFBLK | mode, dev) < 0) {
@@ -426,6 +428,9 @@
 
 	if (stat(path, &info) < 0)
 		return 1;
+	else if (dm_udev_get_sync_support())
+		log_warn("Node %s was not removed by udev. "
+			 "Falling back to direct node removal.", path);
 
 	if (unlink(path) < 0) {
 		log_error("Unable to unlink device node for '%s'", dev_name);


