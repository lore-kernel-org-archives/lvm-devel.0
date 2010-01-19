From: agk@sourceware.org <agk@sourceware.org>
Date: 19 Jan 2010 18:21:04 -0000
Subject: LVM2/daemons/cmirrord functions.c
Message-ID: <20100119182104.2078.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-01-19 18:21:04

Modified files:
	daemons/cmirrord: functions.c 

Log message:
	Remove mknod() and add FIXMEs.
	In the udev-world, this function should work differently.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/cmirrord/functions.c.diff?cvsroot=lvm2&r1=1.15&r2=1.16

--- LVM2/daemons/cmirrord/functions.c	2010/01/19 17:24:29	1.15
+++ LVM2/daemons/cmirrord/functions.c	2010/01/19 18:21:03	1.16
@@ -289,6 +289,7 @@
 	return 0;
 }
 
+/* FIXME Rewrite this function taking advantage of the udev changes (where in use) to improve its efficiency! */
 static int find_disk_path(char *major_minor_str, char *path_rtn, int *unlink_path)
 {
 	int r;
@@ -311,6 +312,7 @@
 	if (r != 2)
 		return -EINVAL;
 
+	/* FIXME dm_dir() */
 	LOG_DBG("Checking /dev/mapper for device %d:%d", major, minor);
 	/* Check /dev/mapper dir */
 	dp = opendir("/dev/mapper");
@@ -340,17 +342,18 @@
 
 	closedir(dp);
 
+	/* FIXME Find out why this was here and deal with underlying problem. */
 	LOG_DBG("Path not found for %d/%d", major, minor);
-	LOG_DBG("Creating /dev/mapper/%d-%d", major, minor);
-	sprintf(path_rtn, "/dev/mapper/%d-%d", major, minor);
-	r = mknod(path_rtn, S_IFBLK | S_IRUSR | S_IWUSR, MKDEV(major, minor));
+	return -ENOENT;
 
+	// LOG_DBG("Creating /dev/mapper/%d-%d", major, minor);
+	// sprintf(path_rtn, "/dev/mapper/%d-%d", major, minor);
+	// r = mknod(path_rtn, S_IFBLK | S_IRUSR | S_IWUSR, MKDEV(major, minor));
 	/*
 	 * If we have to make the path, we unlink it after we open it
 	 */
-	*unlink_path = 1;
-
-	return r ? -errno : 0;
+	// *unlink_path = 1;
+	// return r ? -errno : 0;
 }
 
 static int _clog_ctr(char *uuid, uint64_t luid,


