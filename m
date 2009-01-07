From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 7 Jan 2009 12:17:40 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/libdm-common.c libdm ...
Message-ID: <20090107121740.15222.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2009-01-07 12:17:40

Modified files:
	.              : WHATS_NEW_DM 
	libdm          : libdm-common.c 
	libdm/ioctl    : libdm-iface.c 

Log message:
	Add checks for device names in dmsetup and show proper error messages.
	
	Checks added for DM device names to allow only names < DM_NAME_LEN,
	otherwise a part of lengthy name would be silently ignored and could
	cause confusion while using dmsetup. Also, the name should not contain
	'/' character, if it is used in context of creating a new device
	or renaming the existing one (because we do not consider full path
	to devices, they do not exist in filesystem yet) and appropriate error
	messages are shown.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.258&r2=1.259
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.63&r2=1.64
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.54&r2=1.55

--- LVM2/WHATS_NEW_DM	2008/12/11 16:25:51	1.258
+++ LVM2/WHATS_NEW_DM	2009/01/07 12:17:40	1.259
@@ -1,5 +1,6 @@
 Version 1.02.30 -
 ====================================
+  Add checks for device names in dmsetup and show proper error messages.
   Replace _dm_snprintf with EMIT_PARAMS macro for creating target lines
 
 Version 1.02.29 - 10th November 2008
--- LVM2/libdm/libdm-common.c	2008/11/04 15:07:45	1.63
+++ LVM2/libdm/libdm-common.c	2009/01/07 12:17:40	1.64
@@ -143,18 +143,27 @@
 	 * as its last component.
 	 */
 	if ((pos = strrchr(name, '/'))) {
+		if (dmt->type == DM_DEVICE_CREATE) {
+			log_error("Name \"%s\" invalid. It contains \"/\".", name);
+			return 0;
+		}
+
 		snprintf(path, sizeof(path), "%s/%s", _dm_dir, pos + 1);
 
 		if (stat(name, &st1) || stat(path, &st2) ||
 		    !(st1.st_dev == st2.st_dev)) {
-			log_error("dm_task_set_name: Device %s not found",
-				  name);
+			log_error("Device %s not found", name);
 			return 0;
 		}
 
 		name = pos + 1;
 	}
 
+	if (strlen(name) >= DM_NAME_LEN) {
+		log_error("Name \"%s\" too long", name);
+		return 0;
+	}
+
 	if (!(dmt->dev_name = dm_strdup(name))) {
 		log_error("dm_task_set_name: strdup(%s) failed", name);
 		return 0;
--- LVM2/libdm/ioctl/libdm-iface.c	2008/11/03 18:59:59	1.54
+++ LVM2/libdm/ioctl/libdm-iface.c	2009/01/07 12:17:40	1.55
@@ -1018,6 +1018,16 @@
 
 int dm_task_set_newname(struct dm_task *dmt, const char *newname)
 {
+	if (strchr(newname, '/')) {
+		log_error("Name \"%s\" invalid. It contains \"/\".", newname);
+		return 0;
+	}
+
+	if (strlen(newname) >= DM_NAME_LEN) {
+		log_error("Name \"%s\" too long", newname);
+		return 0;
+	}
+
 	if (!(dmt->newname = dm_strdup(newname))) {
 		log_error("dm_task_set_newname: strdup(%s) failed", newname);
 		return 0;


