From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 9 Jan 2012 12:26:16 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/libdm-common.c libdm ...
Message-ID: <20120109122616.27980.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-01-09 12:26:15

Modified files:
	.              : WHATS_NEW_DM 
	libdm          : libdm-common.c libdm-common.h 
	libdm/ioctl    : libdm-iface.c 

Log message:
	Use sysfs to set/get of read-ahead
	
	If we know major:minor number of device (which is known after resume) we will
	try to use  sysfs to set/get read ahead parameters of device.
	This avoid potential problem of blocking commands like 'dmsetup info' awaiting
	for device being usable for open/close - i.e. overfilled thin pool may block
	such command.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.526&r2=1.527
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.129&r2=1.130
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.h.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.130&r2=1.131

--- LVM2/WHATS_NEW_DM	2011/12/21 12:47:44	1.526
+++ LVM2/WHATS_NEW_DM	2012/01/09 12:26:14	1.527
@@ -1,5 +1,6 @@
 Version 1.02.68 -
 ==================================
+  Use sysfs to set/get of read-ahead setting if possible.
   Fix lvm2-monitor init script to use normalized output when using vgs.
   Add test for max length (DM_MAX_TYPE_NAME) of target type name.
   Include a copy of kernel DM documentation in doc/kernel.
--- LVM2/libdm/libdm-common.c	2011/12/18 21:56:03	1.129
+++ LVM2/libdm/libdm-common.c	2012/01/09 12:26:15	1.130
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2012 Red Hat, Inc. All rights reserved.
  *
  * This file is part of the device-mapper userspace tools.
  *
@@ -59,6 +59,7 @@
 
 static char _dm_dir[PATH_MAX] = DEV_DIR DM_DIR;
 static char _sysfs_dir[PATH_MAX] = "/sys/";
+static char _path0[PATH_MAX];           /* path buffer, safe 4kB on stack */
 
 static int _verbose = 0;
 static int _suspended_dev_counter = 0;
@@ -658,12 +659,53 @@
 	return fd;
 }
 
-int get_dev_node_read_ahead(const char *dev_name, uint32_t *read_ahead)
+int get_dev_node_read_ahead(const char *dev_name, uint32_t major, uint32_t minor,
+			    uint32_t *read_ahead)
 {
+	char buf[24];
+	int len;
 	int r = 1;
 	int fd;
 	long read_ahead_long;
 
+	/*
+	 * If we know the device number, use sysfs if we can.
+	 * Otherwise use BLKRAGET ioctl.
+	 */
+	if (*_sysfs_dir && major != 0) {
+		if (dm_snprintf(_path0, sizeof(_path0), "%sdev/block/%" PRIu32
+				":%" PRIu32 "/bdi/read_ahead_kb", _sysfs_dir,
+				major, minor) < 0) {
+			log_error("Failed to build sysfs_path.");
+			return 0;
+		}
+
+		if ((fd = open(_path0, O_RDONLY, 0)) != -1) {
+			/* Reading from sysfs, expecting number\n */
+			if ((len = read(fd, buf, sizeof(buf))) < 1) {
+				log_sys_error("read", _path0);
+				r = 0;
+			} else {
+				buf[len] = 0; /* kill \n and ensure \0 */
+				*read_ahead = atoi(buf) * 2;
+				log_debug("%s (%d:%d): read ahead is %" PRIu32,
+					  dev_name, major, minor, *read_ahead);
+			}
+
+			if (close(fd))
+				log_sys_debug("close", _path0);
+
+			return r;
+		}
+
+		log_sys_debug("open", _path0);
+		/* Fall back to use dev_name */
+	}
+
+	/*
+	 * Open/close dev_name may block the process
+	 * (i.e. overfilled thin pool volume)
+	 */
 	if (!*dev_name) {
 		log_error("Empty device name passed to BLKRAGET");
 		return 0;
@@ -676,23 +718,64 @@
 		log_sys_error("BLKRAGET", dev_name);
 		*read_ahead = 0;
 		r = 0;
-	}  else {
+	} else {
 		*read_ahead = (uint32_t) read_ahead_long;
 		log_debug("%s: read ahead is %" PRIu32, dev_name, *read_ahead);
 	}
 
 	if (close(fd))
-		stack;
+		log_sys_debug("close", dev_name);
 
 	return r;
 }
 
-static int _set_read_ahead(const char *dev_name, uint32_t read_ahead)
+static int _set_read_ahead(const char *dev_name, uint32_t major, uint32_t minor,
+			   uint32_t read_ahead)
 {
+	char buf[24];
+	int len;
 	int r = 1;
 	int fd;
 	long read_ahead_long = (long) read_ahead;
 
+	log_debug("%s (%d:%d): Setting read ahead to %" PRIu32, dev_name,
+		  major, minor, read_ahead);
+
+	/*
+	 * If we know the device number, use sysfs if we can.
+	 * Otherwise use BLKRASET ioctl. RA is set after resume.
+	 */
+	if (*_sysfs_dir && major != 0) {
+		if (dm_snprintf(_path0, sizeof(_path0), "%sdev/block/%" PRIu32
+				":%" PRIu32 "/bdi/read_ahead_kb",
+				_sysfs_dir, major, minor) < 0) {
+			log_error("Failed to build sysfs_path.");
+			return 0;
+		}
+
+		/* Sysfs is kB based, round up to kB */
+		if ((len = dm_snprintf(buf, sizeof(buf), "%" PRIu32,
+				       (read_ahead + 1) / 2)) < 0) {
+			log_error("Failed to build size in kB.");
+			return 0;
+		}
+
+		if ((fd = open(_path0, O_WRONLY, 0)) != -1) {
+			if (write(fd, buf, len) < len) {
+				log_sys_error("write", _path0);
+				r = 0;
+			}
+
+			if (close(fd))
+				log_sys_debug("close", _path0);
+
+			return r;
+		}
+
+		log_sys_debug("open", _path0);
+		/* Fall back to use dev_name */
+	}
+
 	if (!*dev_name) {
 		log_error("Empty device name passed to BLKRAGET");
 		return 0;
@@ -701,21 +784,20 @@
 	if ((fd = _open_dev_node(dev_name)) < 0)
 		return_0;
 
-	log_debug("%s: Setting read ahead to %" PRIu32, dev_name, read_ahead);
-
 	if (ioctl(fd, BLKRASET, read_ahead_long)) {
 		log_sys_error("BLKRASET", dev_name);
 		r = 0;
 	}
 
 	if (close(fd))
-		stack;
+		log_sys_debug("close", dev_name);
 
 	return r;
 }
 
-static int _set_dev_node_read_ahead(const char *dev_name, uint32_t read_ahead,
-				    uint32_t read_ahead_flags)
+static int _set_dev_node_read_ahead(const char *dev_name,
+				    uint32_t major, uint32_t minor,
+				    uint32_t read_ahead, uint32_t read_ahead_flags)
 {
 	uint32_t current_read_ahead;
 
@@ -726,7 +808,7 @@
 		read_ahead = 0;
 
 	if (read_ahead_flags & DM_READ_AHEAD_MINIMUM_FLAG) {
-		if (!get_dev_node_read_ahead(dev_name, &current_read_ahead))
+		if (!get_dev_node_read_ahead(dev_name, major, minor, &current_read_ahead))
 			return_0;
 
 		if (current_read_ahead > read_ahead) {
@@ -737,7 +819,7 @@
 		}
 	}
 
-	return _set_read_ahead(dev_name, read_ahead);
+	return _set_read_ahead(dev_name, major, minor, read_ahead);
 }
 
 #else
@@ -749,8 +831,9 @@
 	return 1;
 }
 
-static int _set_dev_node_read_ahead(const char *dev_name, uint32_t read_ahead,
-				    uint32_t read_ahead_flags)
+static int _set_dev_node_read_ahead(const char *dev_name,
+				    uint32_t major, uint32_t minor,
+				    uint32_t read_ahead, uint32_t read_ahead_flags)
 {
 	return 1;
 }
@@ -778,8 +861,8 @@
 	case NODE_RENAME:
 		return _rename_dev_node(old_name, dev_name, warn_if_udev_failed);
 	case NODE_READ_AHEAD:
-		return _set_dev_node_read_ahead(dev_name, read_ahead,
-						read_ahead_flags);
+		return _set_dev_node_read_ahead(dev_name, major, minor,
+						read_ahead, read_ahead_flags);
 	default:
 		; /* NOTREACHED */
 	}
@@ -993,13 +1076,14 @@
 			      0, 0, "", 0, 0, check_udev, rely_on_udev);
 }
 
-int set_dev_node_read_ahead(const char *dev_name, uint32_t read_ahead,
-			    uint32_t read_ahead_flags)
+int set_dev_node_read_ahead(const char *dev_name,
+                            uint32_t major, uint32_t minor,
+			    uint32_t read_ahead, uint32_t read_ahead_flags)
 {
 	if (read_ahead == DM_READ_AHEAD_AUTO)
 		return 1;
 
-	return _stack_node_op(NODE_READ_AHEAD, dev_name, 0, 0, 0, 0,
+	return _stack_node_op(NODE_READ_AHEAD, dev_name, major, minor, 0, 0,
                               0, "", read_ahead, read_ahead_flags, 0, 0);
 }
 
--- LVM2/libdm/libdm-common.h	2011/06/27 21:43:59	1.9
+++ LVM2/libdm/libdm-common.h	2012/01/09 12:26:15	1.10
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2012 Red Hat, Inc. All rights reserved.
  *
  * This file is part of the device-mapper userspace tools.
  *
@@ -27,9 +27,10 @@
 int rm_dev_node(const char *dev_name, int check_udev, unsigned rely_on_udev);
 int rename_dev_node(const char *old_name, const char *new_name,
 		    int check_udev, unsigned rely_on_udev);
-int get_dev_node_read_ahead(const char *dev_name, uint32_t *read_ahead);
-int set_dev_node_read_ahead(const char *dev_name, uint32_t read_ahead,
-			    uint32_t read_ahead_flags);
+int get_dev_node_read_ahead(const char *dev_name, uint32_t major, uint32_t minor,
+			    uint32_t *read_ahead);
+int set_dev_node_read_ahead(const char *dev_name, uint32_t major, uint32_t minor,
+			    uint32_t read_ahead, uint32_t read_ahead_flags);
 void update_devs(void);
 void selinux_release(void);
 
--- LVM2/libdm/ioctl/libdm-iface.c	2011/11/30 02:02:12	1.130
+++ LVM2/libdm/ioctl/libdm-iface.c	2012/01/09 12:26:15	1.131
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2012 Red Hat, Inc. All rights reserved.
  *
  * This file is part of the device-mapper userspace tools.
  *
@@ -665,7 +665,8 @@
 		return 0;
 	}
 
-	return get_dev_node_read_ahead(dev_name, read_ahead);
+	return get_dev_node_read_ahead(dev_name, MAJOR(dmt->dmi.v4->dev),
+				       MINOR(dmt->dmi.v4->dev), read_ahead);
 }
 
 const char *dm_task_get_name(const struct dm_task *dmt)
@@ -1818,8 +1819,9 @@
 				     MINOR(dmi->dev), dmt->uid, dmt->gid,
 				     dmt->mode, check_udev, rely_on_udev);
 		/* FIXME Kernel needs to fill in dmi->name */
-		set_dev_node_read_ahead(dmt->dev_name, dmt->read_ahead,
-					dmt->read_ahead_flags);
+		set_dev_node_read_ahead(dmt->dev_name,
+					MAJOR(dmi->dev), MINOR(dmi->dev),
+					dmt->read_ahead, dmt->read_ahead_flags);
 		break;
 	
 	case DM_DEVICE_MKNODES:


