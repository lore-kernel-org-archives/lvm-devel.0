From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 13 May 2010 18:38:41 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/activate.h lib/a ...
Message-ID: <20100513183841.1542.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-05-13 18:38:40

Modified files:
	.              : WHATS_NEW 
	lib/activate   : activate.h dev_manager.c 
	lib/filters    : filter.c 

Log message:
	Skip also special lvm devices in scan (if ignore suspended is used).
	
	This should avoid various races between dmeventd on multiple nodes
	in cluster where one node already repairing device and another
	run full scan and locks the device.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1556&r2=1.1557
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.h.diff?cvsroot=lvm2&r1=1.66&r2=1.67
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.187&r2=1.188
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/filters/filter.c.diff?cvsroot=lvm2&r1=1.51&r2=1.52

--- LVM2/WHATS_NEW	2010/05/13 13:04:03	1.1556
+++ LVM2/WHATS_NEW	2010/05/13 18:38:38	1.1557
@@ -1,5 +1,6 @@
 Version 2.02.65 - 
 =================================
+  Skip internal lvm devices in scan if ignore suspended devices is requested.
   Do not merge old device cache after we run full scan. (2.02.56)
   Add pkgconfigdir Makefile variable for make install override.
   Switch usage of Libs.private: to Requires.private: in devmapper.pc, lvm2app.pc.
--- LVM2/lib/activate/activate.h	2010/04/23 02:57:41	1.66
+++ LVM2/lib/activate/activate.h	2010/05/13 18:38:38	1.67
@@ -110,6 +110,6 @@
 /*
  * Returns 1 if mapped device is not suspended.
  */
-int device_is_usable(dev_t dev);
+int device_is_usable(struct device *dev);
 
 #endif
--- LVM2/lib/activate/dev_manager.c	2010/04/23 14:16:33	1.187
+++ LVM2/lib/activate/dev_manager.c	2010/05/13 18:38:38	1.188
@@ -126,11 +126,11 @@
 	return r;
 }
 
-int device_is_usable(dev_t dev)
+int device_is_usable(struct device *dev)
 {
 	struct dm_task *dmt;
 	struct dm_info info;
-	const char *name;
+	const char *name, *uuid;
 	uint64_t start, length;
 	char *target_type = NULL;
 	char *params;
@@ -142,7 +142,7 @@
 		return 0;
 	}
 
-	if (!dm_task_set_major_minor(dmt, MAJOR(dev), MINOR(dev), 1))
+	if (!dm_task_set_major_minor(dmt, MAJOR(dev->dev), MINOR(dev->dev), 1))
 		goto_out;
 
 	if (!dm_task_run(dmt)) {
@@ -157,6 +157,7 @@
 		goto out;
 
 	name = dm_task_get_name(dmt);
+	uuid = dm_task_get_uuid(dmt);
 
 	/* FIXME Also check for mirror block_on_error and mpath no paths */
 	/* For now, we exclude all mirrors */
@@ -165,12 +166,21 @@
 		next = dm_get_next_target(dmt, next, &start, &length,
 					  &target_type, &params);
 		/* Skip if target type doesn't match */
-		if (target_type && !strcmp(target_type, "mirror"))
+		if (target_type && !strcmp(target_type, "mirror")) {
+			log_debug("%s: Mirror device not usable.", dev_name(dev));
 			goto out;
+		}
 	} while (next);
 
 	/* FIXME Also check dependencies? */
 
+	/* Check internal lvm devices */
+	if (is_reserved_lvname(name) && uuid &&
+	    !strncmp(uuid, UUID_PREFIX, sizeof(UUID_PREFIX) - 1)) {
+		log_debug("%s: Reserved internal LVM device not usable.", dev_name(dev));
+		goto out;
+	}
+
 	r = 1;
 
       out:
--- LVM2/lib/filters/filter.c	2009/12/11 13:16:38	1.51
+++ LVM2/lib/filters/filter.c	2010/05/13 18:38:40	1.52
@@ -132,8 +132,8 @@
 
 	/* Skip suspended devices */
 	if (MAJOR(dev->dev) == _device_mapper_major &&
-	    ignore_suspended_devices() && !device_is_usable(dev->dev)) {
-		log_debug("%s: Skipping: Suspended dm device", name);
+	    ignore_suspended_devices() && !device_is_usable(dev)) {
+		log_debug("%s: Skipping: Suspended or internal dm device", name);
 		return 0;
 	}
 


