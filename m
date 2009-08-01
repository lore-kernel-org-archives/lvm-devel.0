From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 1 Aug 2009 17:14:53 -0000
Subject: LVM2/lib/device dev-md.c device.c
Message-ID: <20090801171453.4548.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2009-08-01 17:14:52

Modified files:
	lib/device     : dev-md.c device.c 

Log message:
	Fix error handling of device-related stat() calls to be ENOENT aware.
	
	Signed-off-by: Mike Snitzer <snitzer@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-md.c.diff?cvsroot=lvm2&r1=1.17&r2=1.18
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/device.c.diff?cvsroot=lvm2&r1=1.31&r2=1.32

--- LVM2/lib/device/dev-md.c	2009/08/01 17:11:02	1.17
+++ LVM2/lib/device/dev-md.c	2009/08/01 17:14:52	1.18
@@ -151,7 +151,11 @@
 		return ret;
 	}
 
-	if (stat(path, &info) < 0) {
+	if (stat(path, &info) == -1) {
+		if (errno != ENOENT) {
+			log_sys_error("stat", path);
+			return ret;
+		}
 		/* old sysfs structure */
 		ret = dm_snprintf(path, size, "%s/block/md%d/md/%s",
 				  sysfs_dir, (int)MINOR(dev), attribute);
--- LVM2/lib/device/device.c	2009/08/01 17:11:02	1.31
+++ LVM2/lib/device/device.c	2009/08/01 17:14:52	1.32
@@ -304,8 +304,11 @@
 		return ret;
 	}
 
-	if (stat(path, &info) < 0)
+	if (stat(path, &info) == -1) {
+		if (errno != ENOENT)
+			log_sys_error("stat", path);
 		return ret;
+	}
 
 	/*
 	 * extract parent's path from the partition's symlink, e.g.:
@@ -326,8 +329,11 @@
 	}
 
 	/* finally, parse 'dev' attribute and create corresponding dev_t */
-	if (stat(path, &info) < 0) {
-		log_error("sysfs file %s does not exist", path);
+	if (stat(path, &info) == -1) {
+		if (errno == ENOENT)
+			log_error("sysfs file %s does not exist", path);
+		else
+			log_sys_error("stat", path);
 		return ret;
 	}
 
@@ -386,7 +392,11 @@
 	 * - if not: either the kernel doesn't have topology support
 	 *   or the device could be a partition
 	 */
-	if (stat(path, &info) < 0) {
+	if (stat(path, &info) == -1) {
+		if (errno != ENOENT) {
+			log_sys_error("stat", path);
+			return 0;
+		}
 		if (!get_primary_dev(sysfs_dir, dev, &primary))
 			return 0;
 
@@ -397,8 +407,11 @@
 			log_error("primary dm_snprintf %s failed", attribute);
 			return 0;
 		}
-		if (stat(path, &info) < 0)
+		if (stat(path, &info) == -1) {
+			if (errno != ENOENT)
+				log_sys_error("stat", path);
 			return 0;
+		}
 	}
 
 	if (!(fp = fopen(path, "r"))) {


