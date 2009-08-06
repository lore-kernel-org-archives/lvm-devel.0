From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 6 Aug 2009 15:02:02 -0000
Subject: LVM2/libdm/ioctl libdm-iface.c
Message-ID: <20090806150202.2968.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2009-08-06 15:02:01

Modified files:
	libdm/ioctl    : libdm-iface.c 

Log message:
	Fix failure situations in dm_task_run for udev sync.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.60&r2=1.61

--- LVM2/libdm/ioctl/libdm-iface.c	2009/08/03 18:01:48	1.60
+++ LVM2/libdm/ioctl/libdm-iface.c	2009/08/06 15:02:01	1.61
@@ -1486,6 +1486,18 @@
 	return _process_all_v4(dmt);
 }
 
+/*
+ * If an operation that uses a cookie fails, decrement the
+ * semaphore instead of udev.
+ */
+static int _udev_complete(struct dm_task *dmt)
+{
+	if (dmt->cookie_set)
+		return dm_udev_complete(dmt->event_nr);
+
+	return 1;
+}
+
 static int _create_and_load_v4(struct dm_task *dmt)
 {
 	struct dm_task *task;
@@ -1494,17 +1506,20 @@
 	/* Use new task struct to create the device */
 	if (!(task = dm_task_create(DM_DEVICE_CREATE))) {
 		log_error("Failed to create device-mapper task struct");
+		_udev_complete(dmt);
 		return 0;
 	}
 
 	/* Copy across relevant fields */
 	if (dmt->dev_name && !dm_task_set_name(task, dmt->dev_name)) {
 		dm_task_destroy(task);
+		_udev_complete(dmt);
 		return 0;
 	}
 
 	if (dmt->uuid && !dm_task_set_uuid(task, dmt->uuid)) {
 		dm_task_destroy(task);
+		_udev_complete(dmt);
 		return 0;
 	}
 
@@ -1516,18 +1531,22 @@
 
 	r = dm_task_run(task);
 	dm_task_destroy(task);
-	if (!r)
-		return r;
+	if (!r) {
+		_udev_complete(dmt);
+		return 0;
+	}
 
 	/* Next load the table */
 	if (!(task = dm_task_create(DM_DEVICE_RELOAD))) {
 		log_error("Failed to create device-mapper task struct");
+		_udev_complete(dmt);
 		return 0;
 	}
 
 	/* Copy across relevant fields */
 	if (dmt->dev_name && !dm_task_set_name(task, dmt->dev_name)) {
 		dm_task_destroy(task);
+		_udev_complete(dmt);
 		return 0;
 	}
 
@@ -1540,8 +1559,10 @@
 	task->head = NULL;
 	task->tail = NULL;
 	dm_task_destroy(task);
-	if (!r)
+	if (!r) {
+		_udev_complete(dmt);
 		goto revert;
+	}
 
 	/* Use the original structure last so the info will be correct */
 	dmt->type = DM_DEVICE_RESUME;
@@ -1557,6 +1578,7 @@
  	dmt->type = DM_DEVICE_REMOVE;
 	dm_free(dmt->uuid);
 	dmt->uuid = NULL;
+	dmt->cookie_set = 0;
 
 	if (!dm_task_run(dmt))
 		log_error("Failed to revert device creation.");
@@ -1739,19 +1761,15 @@
 	if ((dmt->type == DM_DEVICE_RELOAD) && dmt->suppress_identical_reload)
 		return _reload_with_suppression_v4(dmt);
 
-	if (!_open_control())
+	if (!_open_control()) {
+		_udev_complete(dmt);
 		return 0;
+	}
 
 	/* FIXME Detect and warn if cookie set but should not be. */
 repeat_ioctl:
 	if (!(dmi = _do_dm_ioctl(dmt, command, _ioctl_buffer_double_factor))) {
-		/*
-		 * If an operation that uses a cookie fails, decrement the 
-		 * semaphore instead of udev.
-		 * FIXME Review error paths: found one where uevent fired too.
-		 */
-		if (dmt->cookie_set)
-			dm_udev_complete(dmt->event_nr);
+		_udev_complete(dmt);
 		return 0;
 	}
 


