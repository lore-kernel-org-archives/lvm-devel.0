From: agk@sourceware.org <agk@sourceware.org>
Date: 25 Sep 2009 18:08:05 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/libdm-common.c
Message-ID: <20090925180805.26100.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-09-25 18:08:04

Modified files:
	.              : WHATS_NEW_DM 
	libdm          : libdm-common.c 

Log message:
	Handle any path supplied to dm_task_set_name() by looking up in /dev/mapper.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.300&r2=1.301
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.81&r2=1.82

--- LVM2/WHATS_NEW_DM	2009/09/15 13:54:29	1.300
+++ LVM2/WHATS_NEW_DM	2009/09/25 18:08:04	1.301
@@ -1,5 +1,6 @@
 Version 1.02.38 - 
 =====================================
+  Handle any path supplied to dm_task_set_name() by looking up in /dev/mapper.
 
 Version 1.02.37 - 15th September 2009
 =====================================
--- LVM2/libdm/libdm-common.c	2009/09/15 11:41:39	1.81
+++ LVM2/libdm/libdm-common.c	2009/09/25 18:08:04	1.82
@@ -23,6 +23,7 @@
 #include <sys/param.h>
 #include <sys/ioctl.h>
 #include <fcntl.h>
+#include <dirent.h>
 
 #ifdef UDEV_SYNC_SUPPORT
 #  include <sys/types.h>
@@ -183,9 +184,54 @@
 	return dmt;
 }
 
+/*
+ * Find the name associated with a given device number by scanning _dm_dir.
+ */
+static char *_translate_name(dev_t st_rdev, const char *devname)
+{
+	const char *name;
+	char path[PATH_MAX];
+	struct dirent *dirent;
+	DIR *d;
+	struct stat buf;
+	char *new_name = NULL;
+
+	if (!(d = opendir(_dm_dir))) {
+		log_sys_error("opendir", _dm_dir);
+		return NULL;
+	}
+
+	while ((dirent = readdir(d))) {
+		name = dirent->d_name;
+
+		if (!strcmp(name, ".") || !strcmp(name, ".."))
+			continue;
+
+		if (dm_snprintf(path, sizeof(path), "%s/%s", _dm_dir,
+				name) == -1) {
+			log_error("Couldn't create path for %s", name);
+			continue;
+		}
+
+		if (stat(path, &buf))
+			continue;
+
+		if (buf.st_rdev == st_rdev) {
+			new_name = dm_strdup(name);
+			break;
+		}
+	}
+
+	if (closedir(d))
+		log_sys_error("closedir", _dm_dir);
+
+	return new_name;
+}
+
 int dm_task_set_name(struct dm_task *dmt, const char *name)
 {
 	char *pos;
+	char *new_name = NULL;
 	char path[PATH_MAX];
 	struct stat st1, st2;
 
@@ -194,8 +240,8 @@
 		dmt->dev_name = NULL;
 	}
 
-	/* If path was supplied, remove it if it points to the same device
-	 * as its last component.
+	/*
+	 * Path supplied for existing device?
 	 */
 	if ((pos = strrchr(name, '/'))) {
 		if (dmt->type == DM_DEVICE_CREATE) {
@@ -203,23 +249,38 @@
 			return 0;
 		}
 
+		if (stat(name, &st1)) {
+			log_error("Device %s not found", name);
+			return 0;
+		}
+
+		/*
+		 * If supplied path points to same device as last component
+		 * under /dev/mapper, use that name directly.  Otherwise call
+		 * _translate_name() to scan _dm_dir for a match.
+		 */
 		snprintf(path, sizeof(path), "%s/%s", _dm_dir, pos + 1);
 
-		if (stat(name, &st1) || stat(path, &st2) ||
-		    !(st1.st_dev == st2.st_dev)) {
+		if (!stat(path, &st2) && (st1.st_rdev == st2.st_rdev))
+			name = pos + 1;
+		else if ((new_name = _translate_name(st1.st_rdev, pos + 1)))
+			name = new_name;
+		else {
 			log_error("Device %s not found", name);
 			return 0;
 		}
-
-		name = pos + 1;
 	}
 
 	if (strlen(name) >= DM_NAME_LEN) {
 		log_error("Name \"%s\" too long", name);
+		if (new_name)
+			dm_free(new_name);
 		return 0;
 	}
 
-	if (!(dmt->dev_name = dm_strdup(name))) {
+	if (new_name)
+		dmt->dev_name = new_name;
+	else if (!(dmt->dev_name = dm_strdup(name))) {
 		log_error("dm_task_set_name: strdup(%s) failed", name);
 		return 0;
 	}


