From: agk@sourceware.org <agk@sourceware.org>
Date: 2 Jul 2011 01:17:10 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/ioctl/libdm-iface.c
Message-ID: <20110702011710.25785.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-07-02 01:17:10

Modified files:
	.              : WHATS_NEW_DM 
	libdm/ioctl    : libdm-iface.c 

Log message:
	Report internal error if suspending a device using an already-suspended dev.
	This catches the recent pvmove problem trapping I/O between layers.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.477&r2=1.478
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.112&r2=1.113

--- LVM2/WHATS_NEW_DM	2011/07/01 14:09:19	1.477
+++ LVM2/WHATS_NEW_DM	2011/07/02 01:17:09	1.478
@@ -1,5 +1,6 @@
 Version 1.02.65 - 
 ==================================
+  Report internal error if suspending a device using an already-suspended dev.
   Add dmsetup --checks and dm_task_enable_checks framework to validate ioctls.
   Add age_in_minutes parameter to dmsetup udevcomplete_all.
   Return immediately from dm_lib_exit() if called more than once.
--- LVM2/libdm/ioctl/libdm-iface.c	2011/07/01 14:09:20	1.112
+++ LVM2/libdm/ioctl/libdm-iface.c	2011/07/02 01:17:10	1.113
@@ -1884,13 +1884,104 @@
 	return r;
 }
 
-static int _suspend_with_validation_v4(struct dm_task *dmt)
+static int _check_children_not_suspended_v4(struct dm_task *dmt, uint64_t device)
 {
+	struct dm_task *task;
+	struct dm_info info;
+	struct dm_deps *deps;
+	int r = 0;
+	uint32_t i;
+
+	/* Find dependencies */
+	if (!(task = dm_task_create(DM_DEVICE_DEPS)))
+		return 0;
+
+	/* Copy across or set relevant fields */
+	if (device) {
+		task->major = MAJOR(device);
+		task->minor = MINOR(device);
+	} else {
+		if (dmt->dev_name && !dm_task_set_name(task, dmt->dev_name))
+			goto out;
+
+		if (dmt->uuid && !dm_task_set_uuid(task, dmt->uuid))
+			goto out;
+
+		task->major = dmt->major;
+		task->minor = dmt->minor;
+	}
+
+	task->uid = dmt->uid;
+	task->gid = dmt->gid;
+	task->mode = dmt->mode;
+	/* FIXME: Just for udev_check in dm_task_run. Can we avoid this? */
+	task->event_nr = dmt->event_nr & DM_UDEV_FLAGS_MASK;
+	task->cookie_set = dmt->cookie_set;
+	task->add_node = dmt->add_node;
+	
+	if (!(r = dm_task_run(task)))
+		goto out;
+
+	if (!dm_task_get_info(task, &info) || !info.exists)
+		goto out;
+
 	/*
-	 * FIXME Ensure we can't leave any I/O trapped between suspended devices.
+	 * Warn if any of the devices this device depends upon are already
+	 * suspended: I/O could become trapped between the two devices.
 	 */
+	if (info.suspended) {
+		if (!device)
+			log_debug("Attempting to suspend a device that is already suspended "
+				  "(%u:%u)", info.major, info.minor);
+		else
+			log_error(INTERNAL_ERROR "Attempt to suspend device %s%s%s%.0d%s%.0d%s%s"
+				  "that uses already-suspended device (%u:%u)", 
+				  dmt->dev_name ? : "", dmt->uuid ? : "", 
+				  dmt->major > 0 ? "(" : "",
+				  dmt->major > 0 ? dmt->major : 0,
+				  dmt->major > 0 ? ":" : "",
+				  dmt->minor > 0 ? dmt->minor : 0,
+				  dmt->major > 0 && dmt->minor == 0 ? "0" : "",
+				  dmt->major > 0 ? ") " : "",
+				  info.major, info.minor);
+
+		/* No need for further recursion */
+		r = 1;
+		goto out;
+	}
+
+        if (!(deps = dm_task_get_deps(task)))
+                goto out;
+
+	for (i = 0; i < deps->count; i++) {
+		/* Only recurse with dm devices */
+		if (MAJOR(deps->device[i]) != _dm_device_major)
+			continue;
+
+		if (!_check_children_not_suspended_v4(task, deps->device[i]))
+			goto out;
+	}
+
+	r = 1;
+
+out:
+	dm_task_destroy(task);
+
+	return r;
+}
+
+static int _suspend_with_validation_v4(struct dm_task *dmt)
+{
+	/* Avoid recursion */
 	dmt->enable_checks = 0;
-	
+
+	/*
+	 * Ensure we can't leave any I/O trapped between suspended devices.
+	 */
+	if (!_check_children_not_suspended_v4(dmt, 0))
+		return 0;
+
+	/* Finally, perform the original suspend. */
 	return dm_task_run(dmt);
 }
 


