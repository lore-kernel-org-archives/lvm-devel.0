From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 11 Apr 2012 09:12:03 -0000
Subject: LVM2 ./WHATS_NEW lib/device/dev-cache.c
Message-ID: <20120411091203.4205.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-04-11 09:12:03

Modified files:
	.              : WHATS_NEW 
	lib/device     : dev-cache.c 

Log message:
	Change message severity to log_very_verbose for missing dev info in udev db.
	
	Libudev does not provide transactions when querying udev database - once we
	get the list of block devices (devices/obtain_device_list_from_udev=1) and
	we iterate over the list to get more detailed information about device node
	and symlink names used etc., the device could be removed just in between we
	get the list and put a query for more info. In this case, libudev returns
	NULL value as the device does not exist anymore.
	
	Recently, we've added a warning message to reveal such situations. However,
	this could be misleading if the device is not related to the LVM action
	we're just processing - the non-related block device could be removed in
	parallel and this is not an error but a possible and normal operation.
	
	(N.B. This "missing info" should not happen when devices are related to
	the LVM action we're just processing since all such processing should be
	synchronized with udev and the udev db must always be in consistent state
	after the sync point. But we can't filter this situation out from others,
	non-related devices, so we have to lower the message verbosity here for a
	general solution.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2377&r2=1.2378
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-cache.c.diff?cvsroot=lvm2&r1=1.74&r2=1.75

--- LVM2/WHATS_NEW	2012/04/11 01:23:29	1.2377
+++ LVM2/WHATS_NEW	2012/04/11 09:12:02	1.2378
@@ -1,5 +1,6 @@
 Version 2.02.96 - 
 ================================
+  Change message severity to log_very_verbose for missing dev info in udev db.
   Fix problems when specifying PVs during RAID down-converts.
   Fix ability to handle failures in mirrored log (regression intro 2.02.89).
   Fix unlocking volume group in vgreduce in error path.
--- LVM2/lib/device/dev-cache.c	2012/03/06 02:39:25	1.74
+++ LVM2/lib/device/dev-cache.c	2012/04/11 09:12:03	1.75
@@ -497,7 +497,7 @@
 {
 	struct udev_enumerate *udev_enum = NULL;
 	struct udev_list_entry *device_entry, *symlink_entry;
-	const char *node_name, *symlink_name;
+	const char *entry_name, *node_name, *symlink_name;
 	struct udev_device *device;
 	int r = 1;
 
@@ -508,20 +508,34 @@
 	    udev_enumerate_scan_devices(udev_enum))
 		goto bad;
 
+	/*
+	 * Report any missing information as "log_very_verbose" only, do not
+	 * report it as a "warning" or "error" - the record could be removed
+	 * by the time we ask for more info (node name, symlink name...).
+	 * Whatever removes *any* block device in the system (even unrelated
+	 * to our operation), we would have a warning/error on output then.
+	 * That could be misleading. If there's really any problem with missing
+	 * information from udev db, we can still have a look at the verbose log.
+	 */
 	udev_list_entry_foreach(device_entry, udev_enumerate_get_list_entry(udev_enum)) {
-		if (!(device = udev_device_new_from_syspath(udev, udev_list_entry_get_name(device_entry)))) {
-			log_warn("WARNING: udev failed to return a device entry.");
+		entry_name = udev_list_entry_get_name(device_entry);
+
+		if (!(device = udev_device_new_from_syspath(udev, entry_name))) {
+			log_very_verbose("udev failed to return a device for entry %s.",
+					 entry_name);
 			continue;
 		}
 
 		if (!(node_name = udev_device_get_devnode(device)))
-			log_warn("WARNING: udev failed to return a device node.");
+			log_very_verbose("udev failed to return a device node for entry %s.",
+					 entry_name);
 		else
 			r &= _insert(node_name, 0, 0);
 
 		udev_list_entry_foreach(symlink_entry, udev_device_get_devlinks_list_entry(device)) {
 			if (!(symlink_name = udev_list_entry_get_name(symlink_entry)))
-				log_warn("WARNING: udev failed to return a symlink name.");
+				log_very_verbose("udev failed to return a symlink name for entry %s.",
+						 entry_name);
 			else
 				r &= _insert(symlink_name, 0, 0);
 		}


