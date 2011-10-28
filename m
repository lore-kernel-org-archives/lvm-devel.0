From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 28 Oct 2011 20:11:22 -0000
Subject: LVM2/libdm libdm-deptree.c
Message-ID: <20111028201122.26039.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-28 20:11:21

Modified files:
	libdm          : libdm-deptree.c 

Log message:
	Trying to fix the retry logic
	
	There should be no need for retry for our internal devices - it would be hinding
	our own bug in the tree processing.
	Update error messages to show also also device name.
	No WHATS_NEW - in release fix.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.138&r2=1.139

--- LVM2/libdm/libdm-deptree.c	2011/10/20 10:39:07	1.138
+++ LVM2/libdm/libdm-deptree.c	2011/10/28 20:11:21	1.139
@@ -977,7 +977,7 @@
 	return r;
 }
 
-static int _check_device_not_in_use(struct dm_info *info)
+static int _check_device_not_in_use(const char *name, struct dm_info *info)
 {
 	if (!info->exists)
 		return 1;
@@ -985,8 +985,8 @@
 	/* If sysfs is not used, use open_count information only. */
 	if (!*dm_sysfs_dir()) {
 		if (info->open_count) {
-			log_error("Device %" PRIu32 ":%" PRIu32 " in use",
-				  info->major, info->minor);
+			log_error("Device %s (%" PRIu32 ":%" PRIu32 ") in use",
+				  name, info->major, info->minor);
 			return 0;
 		}
 
@@ -994,14 +994,14 @@
 	}
 
 	if (dm_device_has_holders(info->major, info->minor)) {
-		log_error("Device %" PRIu32 ":%" PRIu32 " is used "
-			  "by another device.", info->major, info->minor);
+		log_error("Device %s (%" PRIu32 ":%" PRIu32 ") is used "
+			  "by another device.", name, info->major, info->minor);
 		return 0;
 	}
 
 	if (dm_device_has_mounted_fs(info->major, info->minor)) {
-		log_error("Device %" PRIu32 ":%" PRIu32 " contains "
-			  "a filesystem in use.", info->major, info->minor);
+		log_error("Device %s (%" PRIu32 ":%" PRIu32 ") contains "
+			  "a filesystem in use.", name, info->major, info->minor);
 		return 0;
 	}
 
@@ -1413,8 +1413,27 @@
 		    !info.exists)
 			continue;
 
-		if (!_check_device_not_in_use(&info))
-			continue;
+		if (info.open_count) {
+			/* Skip internal non-toplevel opened nodes */
+			if (level)
+				continue;
+
+			/* When retry is not allowed, error */
+			if (!child->dtree->retry_remove) {
+				log_error("Unable to deactivate open %s (%" PRIu32
+					  ":%" PRIu32 ")", name, info.major, info.minor);
+				r = 0;
+				continue;
+			}
+
+			/* Check toplevel node for holders/mounted fs */
+			if (!_check_device_not_in_use(name, &info)) {
+				stack;
+				r = 0;
+				continue;
+			}
+			/* Go on with retry */
+		}
 
 		/* Also checking open_count in parent nodes of presuspend_node */
 		if ((child->presuspend_node &&
@@ -1437,7 +1456,7 @@
 
 		if (!_deactivate_node(name, info.major, info.minor,
 				      &child->dtree->cookie, child->udev_flags,
-				      child->dtree->retry_remove)) {
+				      (level == 0) ? child->dtree->retry_remove : 0)) {
 			log_error("Unable to deactivate %s (%" PRIu32
 				  ":%" PRIu32 ")", name, info.major,
 				  info.minor);


