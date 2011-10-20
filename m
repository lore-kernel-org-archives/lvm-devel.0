From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 20 Oct 2011 10:38:04 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/ioctl/libdm-iface.c
Message-ID: <20111020103804.24039.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-20 10:38:04

Modified files:
	.              : WHATS_NEW_DM 
	libdm/ioctl    : libdm-iface.c 

Log message:
	Cleanup backtraces
	
	Make sure stacks are at the right places when something goes wrong here.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.511&r2=1.512
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.125&r2=1.126

--- LVM2/WHATS_NEW_DM	2011/10/17 13:15:35	1.511
+++ LVM2/WHATS_NEW_DM	2011/10/20 10:38:04	1.512
@@ -1,5 +1,6 @@
 Version 1.02.68 -
 ==================================
+  Cleanup backtraces for _create_and_load_v4().
   Fix alignment warning in bitcount calculation for raid segment.
   Allocate dm_tree structure from dm_tree pool.
   Update debug logging for _resume_node.
--- LVM2/libdm/ioctl/libdm-iface.c	2011/10/19 16:36:02	1.125
+++ LVM2/libdm/ioctl/libdm-iface.c	2011/10/20 10:38:04	1.126
@@ -1250,23 +1250,16 @@
 
 	/* Use new task struct to create the device */
 	if (!(task = dm_task_create(DM_DEVICE_CREATE))) {
-		log_error("Failed to create device-mapper task struct");
 		_udev_complete(dmt);
-		return 0;
+		return_0;
 	}
 
 	/* Copy across relevant fields */
-	if (dmt->dev_name && !dm_task_set_name(task, dmt->dev_name)) {
-		dm_task_destroy(task);
-		_udev_complete(dmt);
-		return 0;
-	}
+	if (dmt->dev_name && !dm_task_set_name(task, dmt->dev_name))
+		goto_bad;
 
-	if (dmt->uuid && !dm_task_set_uuid(task, dmt->uuid)) {
-		dm_task_destroy(task);
-		_udev_complete(dmt);
-		return 0;
-	}
+	if (dmt->uuid && !dm_task_set_uuid(task, dmt->uuid))
+		goto_bad;
 
 	task->major = dmt->major;
 	task->minor = dmt->minor;
@@ -1278,26 +1271,23 @@
 	task->cookie_set = dmt->cookie_set;
 	task->add_node = dmt->add_node;
 
-	r = dm_task_run(task);
+	if (!dm_task_run(task))
+		goto_bad;
+
 	dm_task_destroy(task);
-	if (!r) {
-		_udev_complete(dmt);
-		return 0;
-	}
 
 	/* Next load the table */
 	if (!(task = dm_task_create(DM_DEVICE_RELOAD))) {
-		log_error("Failed to create device-mapper task struct");
+		stack;
 		_udev_complete(dmt);
-		r = 0;
 		goto revert;
 	}
 
 	/* Copy across relevant fields */
 	if (dmt->dev_name && !dm_task_set_name(task, dmt->dev_name)) {
+		stack;
 		dm_task_destroy(task);
 		_udev_complete(dmt);
-		r = 0;
 		goto revert;
 	}
 
@@ -1311,7 +1301,9 @@
 	task->head = NULL;
 	task->tail = NULL;
 	dm_task_destroy(task);
+
 	if (!r) {
+		stack;
 		_udev_complete(dmt);
 		goto revert;
 	}
@@ -1321,13 +1313,11 @@
 	dm_free(dmt->uuid);
 	dmt->uuid = NULL;
 
-	r = dm_task_run(dmt);
-
-	if (r)
-		return r;
+	if (dm_task_run(dmt))
+		return 1;
 
       revert:
- 	dmt->type = DM_DEVICE_REMOVE;
+	dmt->type = DM_DEVICE_REMOVE;
 	dm_free(dmt->uuid);
 	dmt->uuid = NULL;
 
@@ -1347,7 +1337,13 @@
 	if (!dm_task_run(dmt))
 		log_error("Failed to revert device creation.");
 
-	return r;
+	return 0;
+
+      bad:
+	dm_task_destroy(task);
+	_udev_complete(dmt);
+
+	return 0;
 }
 
 uint64_t dm_task_get_existing_table_size(struct dm_task *dmt)
@@ -1720,7 +1716,7 @@
 
 	if (!_open_control()) {
 		_udev_complete(dmt);
-		return 0;
+		return_0;
 	}
 
 	if ((suspended_counter = dm_get_suspended_counter()) &&


