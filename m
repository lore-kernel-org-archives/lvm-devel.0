From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 20 Jul 2009 18:33:16 -0000
Subject: LVM2/lib/device dev-md.c
Message-ID: <20090720183316.11023.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2009-07-20 18:33:16

Modified files:
	lib/device     : dev-md.c 

Log message:
	Cast MAJOR() and MINOR() to int when used with "%d" in dm_snprintf() call.
	Fixes SEGV in _md_sysfs_attribute_snprintf() on 32-bit systems.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-md.c.diff?cvsroot=lvm2&r1=1.14&r2=1.15

--- LVM2/lib/device/dev-md.c	2009/07/06 19:04:25	1.14
+++ LVM2/lib/device/dev-md.c	2009/07/20 18:33:16	1.15
@@ -139,8 +139,8 @@
 	if (!sysfs_dir || !*sysfs_dir)
 		return ret;
 
-	ret = dm_snprintf(path, size, "%s/dev/block/%d:%d/md/%s",
-	      sysfs_dir, MAJOR(dev->dev), MINOR(dev->dev), attribute);
+	ret = dm_snprintf(path, size, "%s/dev/block/%d:%d/md/%s", sysfs_dir,
+			  (int)MAJOR(dev->dev), (int)MINOR(dev->dev), attribute);
 	if (ret < 0) {
 		log_error("dm_snprintf md %s failed", attribute);
 		return ret;


