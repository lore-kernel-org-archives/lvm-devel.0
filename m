From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 26 Sep 2011 10:17:58 -0000
Subject: LVM2 lib/activate/activate.c libdm/libdm-deptree.c
Message-ID: <20110926101758.13423.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-09-26 10:17:52

Modified files:
	lib/activate   : activate.c 
	libdm          : libdm-deptree.c 

Log message:
	Add log_error even for general device in use when we can't do the sysfs checks.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.213&r2=1.214
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.111&r2=1.112

--- LVM2/lib/activate/activate.c	2011/09/22 17:33:50	1.213
+++ LVM2/lib/activate/activate.c	2011/09/26 10:17:51	1.214
@@ -533,8 +533,15 @@
 		return 1;
 
 	/* If sysfs is not used, use open_count information only. */
-	if (!*dm_sysfs_dir())
-		return !info->open_count;
+	if (!*dm_sysfs_dir()) {
+		if (info->open_count) {
+			log_error("Logical volume %s/%s in use.",
+				  lv->vg->name, lv->name);
+			return 0;
+		}
+
+		return 1;
+	}
 
 	if (dm_device_has_holders(info->major, info->minor)) {
 		log_error("Logical volume %s/%s is used by another device.",
--- LVM2/libdm/libdm-deptree.c	2011/09/22 17:36:50	1.111
+++ LVM2/libdm/libdm-deptree.c	2011/09/26 10:17:52	1.112
@@ -947,8 +947,15 @@
 		return 1;
 
 	/* If sysfs is not used, use open_count information only. */
-	if (!*dm_sysfs_dir())
-		return !info->open_count;
+	if (!*dm_sysfs_dir()) {
+		if (info->open_count) {
+			log_error("Device %" PRIu32 ":%" PRIu32 " in use",
+				  info->major, info->minor);
+			return 0;
+		}
+
+		return 1;
+	}
 
 	if (dm_device_has_holders(info->major, info->minor)) {
 		log_error("Device %" PRIu32 ":%" PRIu32 " is used "


