From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 6 Aug 2009 15:00:26 -0000
Subject: LVM2/libdm libdm-common.c
Message-ID: <20090806150026.12694.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2009-08-06 15:00:25

Modified files:
	libdm          : libdm-common.c 

Log message:
	Detect udev problems in _rename_dev_node.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.74&r2=1.75

--- LVM2/libdm/libdm-common.c	2009/08/05 19:50:08	1.74
+++ LVM2/libdm/libdm-common.c	2009/08/06 15:00:25	1.75
@@ -381,6 +381,29 @@
 	return 1;
 }
 
+static int _rm_dev_node(const char *dev_name)
+{
+	char path[PATH_MAX];
+	struct stat info;
+
+	_build_dev_path(path, sizeof(path), dev_name);
+
+	if (stat(path, &info) < 0)
+		return 1;
+	else if (dm_udev_get_sync_support())
+		log_warn("Node %s was not removed by udev. "
+			 "Falling back to direct node removal.", path);
+
+	if (unlink(path) < 0) {
+		log_error("Unable to unlink device node for '%s'", dev_name);
+		return 0;
+	}
+
+	log_debug("Removed %s", path);
+
+	return 1;
+}
+
 static int _rename_dev_node(const char *old_name, const char *new_name)
 {
 	char oldpath[PATH_MAX];
@@ -396,6 +419,19 @@
 				  "is already present", newpath);
 			return 0;
 		}
+		else if (dm_udev_get_sync_support()) {
+			if (stat(oldpath, &info) < 0 &&
+				 errno == ENOENT)
+				/* assume udev already deleted this */
+				return 1;
+			else {
+				log_warn("The node %s should have been renamed to %s "
+					 "by udev but old node is still present. "
+					 "Falling back to direct old node removal.",
+					 oldpath, newpath);
+				return _rm_dev_node(old_name);
+			}
+		}
 
 		if (unlink(newpath) < 0) {
 			if (errno == EPERM) {
@@ -407,6 +443,11 @@
 			return 0;
 		}
 	}
+	else if (dm_udev_get_sync_support())
+		log_warn("The node %s should have been renamed to %s "
+			 "by udev but new node is not present. "
+			 "Falling back to direct node rename.",
+			 oldpath, newpath);
 
 	if (rename(oldpath, newpath) < 0) {
 		log_error("Unable to rename device node from '%s' to '%s'",
@@ -419,29 +460,6 @@
 	return 1;
 }
 
-static int _rm_dev_node(const char *dev_name)
-{
-	char path[PATH_MAX];
-	struct stat info;
-
-	_build_dev_path(path, sizeof(path), dev_name);
-
-	if (stat(path, &info) < 0)
-		return 1;
-	else if (dm_udev_get_sync_support())
-		log_warn("Node %s was not removed by udev. "
-			 "Falling back to direct node removal.", path);
-
-	if (unlink(path) < 0) {
-		log_error("Unable to unlink device node for '%s'", dev_name);
-		return 0;
-	}
-
-	log_debug("Removed %s", path);
-
-	return 1;
-}
-
 #ifdef linux
 static int _open_dev_node(const char *dev_name)
 {


