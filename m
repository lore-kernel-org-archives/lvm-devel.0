From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 20 Jul 2009 18:44:14 -0000
Subject: LVM2/lib/device dev-md.c
Message-ID: <20090720184414.19085.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2009-07-20 18:44:14

Modified files:
	lib/device     : dev-md.c 

Log message:
	Cast MINOR() in _md_sysfs_attribute_snprintf()'s dm_snprintf() call.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-md.c.diff?cvsroot=lvm2&r1=1.15&r2=1.16

--- LVM2/lib/device/dev-md.c	2009/07/20 18:33:16	1.15
+++ LVM2/lib/device/dev-md.c	2009/07/20 18:44:13	1.16
@@ -149,7 +149,7 @@
 	if (stat(path, &info) < 0) {
 		/* old sysfs structure */
 		ret = dm_snprintf(path, size, "%s/block/md%d/md/%s",
-				  sysfs_dir, MINOR(dev->dev), attribute);
+				  sysfs_dir, (int)MINOR(dev->dev), attribute);
 		if (ret < 0) {
 			log_error("dm_snprintf old md %s failed", attribute);
 			return ret;


