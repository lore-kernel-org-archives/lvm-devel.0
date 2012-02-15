From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 15 Feb 2012 11:33:54 -0000
Subject: LVM2/libdm libdm-common.h ioctl/libdm-iface.c
Message-ID: <20120215113354.13179.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-02-15 11:33:53

Modified files:
	libdm          : libdm-common.h 
	libdm/ioctl    : libdm-iface.c 

Log message:
	Add DEV_NAME macro.
	
	Use the DEV_NAME macro to use the mangled form of the name if present,
	use normal name otherwise (we store both forms - mangled and unmangled in
	struct dm_task). Mangled form should be always preferred over unmangled
	with the exception of the situations where we divide one task into several
	others (like "create and load") - we need to avoid mangling the name twice
	(because of multiple dm_task_set_name calls)!

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.h.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.135&r2=1.136

--- LVM2/libdm/libdm-common.h	2012/02/15 11:27:02	1.11
+++ LVM2/libdm/libdm-common.h	2012/02/15 11:33:53	1.12
@@ -18,6 +18,8 @@
 
 #include "libdevmapper.h"
 
+#define DEV_NAME(dmt) (dmt->mangled_dev_name ? : dmt->dev_name)
+
 int mangle_name(const char *str, size_t len, char *buf,
 		size_t buf_len, dm_string_mangling_t mode);
 
--- LVM2/libdm/ioctl/libdm-iface.c	2012/02/15 11:27:02	1.135
+++ LVM2/libdm/ioctl/libdm-iface.c	2012/02/15 11:33:53	1.136
@@ -664,9 +664,7 @@
 
 	if (*dmt->dmi.v4->name)
 		dev_name = dmt->dmi.v4->name;
-	else if (dmt->dev_name)
-		dev_name = dmt->dev_name;
-	else {
+	else if (!(dev_name = DEV_NAME(dmt))) {
 		log_error("Get read ahead request failed: device name unrecorded.");
 		return 0;
 	}
@@ -1041,7 +1039,7 @@
 	}
 
 	/* Does driver support device number referencing? */
-	if (_dm_version_minor < 3 && !dmt->dev_name && !dmt->uuid && dmi->dev) {
+	if (_dm_version_minor < 3 && !DEV_NAME(dmt) && !dmt->uuid && dmi->dev) {
 		if (!_lookup_dev_name(dmi->dev, dmi->name, sizeof(dmi->name))) {
 			log_error("Unable to find name for device (%" PRIu32
 				  ":%" PRIu32 ")", dmt->major, dmt->minor);
@@ -1053,9 +1051,9 @@
 	}
 
 	/* FIXME Until resume ioctl supplies name, use dev_name for readahead */
-	if (dmt->dev_name && (dmt->type != DM_DEVICE_RESUME || dmt->minor < 0 ||
+	if (DEV_NAME(dmt) && (dmt->type != DM_DEVICE_RESUME || dmt->minor < 0 ||
 			      dmt->major < 0))
-		strncpy(dmi->name, dmt->dev_name, sizeof(dmi->name));
+		strncpy(dmi->name, DEV_NAME(dmt), sizeof(dmi->name));
 
 	if (dmt->uuid)
 		strncpy(dmi->uuid, dmt->uuid, sizeof(dmi->uuid));
@@ -1464,7 +1462,7 @@
 		else
 			log_error(INTERNAL_ERROR "Attempt to suspend device %s%s%s%.0d%s%.0d%s%s"
 				  "that uses already-suspended device (%u:%u)", 
-				  dmt->dev_name ? : "", dmt->uuid ? : "", 
+				  DEV_NAME(dmt) ? : "", dmt->uuid ? : "",
 				  dmt->major > 0 ? "(" : "",
 				  dmt->major > 0 ? dmt->major : 0,
 				  dmt->major > 0 ? ":" : "",
@@ -1675,6 +1673,7 @@
 	int suspended_counter;
 	unsigned ioctl_retry = 1;
 	int retryable = 0;
+	const char *dev_name = DEV_NAME(dmt);
 
 	if ((unsigned) dmt->type >=
 	    (sizeof(_cmd_data_v4) / sizeof(*_cmd_data_v4))) {
@@ -1689,7 +1688,7 @@
 	if (dmt->type == DM_DEVICE_CREATE && dmt->head)
 		return _create_and_load_v4(dmt);
 
-	if (dmt->type == DM_DEVICE_MKNODES && !dmt->dev_name &&
+	if (dmt->type == DM_DEVICE_MKNODES && !dev_name &&
 	    !dmt->uuid && dmt->major <= 0)
 		return _mknodes_v4(dmt);
 
@@ -1710,7 +1709,7 @@
 			  "are known to be suspended: "
 			  "%s%s%s %s%.0d%s%.0d%s%s",
 			  suspended_counter,
-			  dmt->dev_name ? : "",
+			  dev_name ? : "",
 			  dmt->uuid ? " UUID " : "",
 			  dmt->uuid ? : "",
 			  dmt->major > 0 ? "(" : "",
@@ -1769,32 +1768,32 @@
 	switch (dmt->type) {
 	case DM_DEVICE_CREATE:
 		if ((dmt->add_node == DM_ADD_NODE_ON_CREATE) &&
-		    dmt->dev_name && *dmt->dev_name && !rely_on_udev)
-			add_dev_node(dmt->dev_name, MAJOR(dmi->dev),
+		    dev_name && *dev_name && !rely_on_udev)
+			add_dev_node(dev_name, MAJOR(dmi->dev),
 				     MINOR(dmi->dev), dmt->uid, dmt->gid,
 				     dmt->mode, check_udev, rely_on_udev);
 		break;
 	case DM_DEVICE_REMOVE:
 		/* FIXME Kernel needs to fill in dmi->name */
-		if (dmt->dev_name && !rely_on_udev)
-			rm_dev_node(dmt->dev_name, check_udev, rely_on_udev);
+		if (dev_name && !rely_on_udev)
+			rm_dev_node(dev_name, check_udev, rely_on_udev);
 		break;
 
 	case DM_DEVICE_RENAME:
 		/* FIXME Kernel needs to fill in dmi->name */
-		if (!dmt->new_uuid && dmt->dev_name)
-			rename_dev_node(dmt->dev_name, dmt->newname,
+		if (!dmt->new_uuid && dev_name)
+			rename_dev_node(dev_name, dmt->newname,
 					check_udev, rely_on_udev);
 		break;
 
 	case DM_DEVICE_RESUME:
 		if ((dmt->add_node == DM_ADD_NODE_ON_RESUME) &&
-		    dmt->dev_name && *dmt->dev_name)
-			add_dev_node(dmt->dev_name, MAJOR(dmi->dev),
+		    dev_name && *dev_name)
+			add_dev_node(dev_name, MAJOR(dmi->dev),
 				     MINOR(dmi->dev), dmt->uid, dmt->gid,
 				     dmt->mode, check_udev, rely_on_udev);
 		/* FIXME Kernel needs to fill in dmi->name */
-		set_dev_node_read_ahead(dmt->dev_name,
+		set_dev_node_read_ahead(dev_name,
 					MAJOR(dmi->dev), MINOR(dmi->dev),
 					dmt->read_ahead, dmt->read_ahead_flags);
 		break;
@@ -1804,8 +1803,8 @@
 			add_dev_node(dmi->name, MAJOR(dmi->dev),
 				     MINOR(dmi->dev), dmt->uid,
 				     dmt->gid, dmt->mode, 0, rely_on_udev);
-		else if (dmt->dev_name)
-			rm_dev_node(dmt->dev_name, 0, rely_on_udev);
+		else if (dev_name)
+			rm_dev_node(dev_name, 0, rely_on_udev);
 		break;
 
 	case DM_DEVICE_STATUS:


