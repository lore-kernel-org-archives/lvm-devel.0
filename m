From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 28 Jul 2010 10:30:29 -0000
Subject: LVM2/libdm/ioctl libdm-iface.c
Message-ID: <20100728103029.30900.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2010-07-28 10:30:29

Modified files:
	libdm/ioctl    : libdm-iface.c 

Log message:
	Revert unsuccessful table load preparation in combined "create, load and resume" scenario.
	
	There was missing "revert" call in _create_and_load_v4 fn while the preparation
	for table load ends up with failure in create/load/resume sequence. Otherwise
	we could end up with a device being created, but not table-loaded nor resumed.
	
	Even though the table is not loaded and the device is not resumed at this
	stage, we still need to synchronize with udev when calling the revert
	"remove" ioctl - there's still a remove uevent generated! The "revert"
	code does exactly that.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.76&r2=1.77

--- LVM2/libdm/ioctl/libdm-iface.c	2010/06/23 12:54:46	1.76
+++ LVM2/libdm/ioctl/libdm-iface.c	2010/07/28 10:30:28	1.77
@@ -1655,14 +1655,16 @@
 	if (!(task = dm_task_create(DM_DEVICE_RELOAD))) {
 		log_error("Failed to create device-mapper task struct");
 		_udev_complete(dmt);
-		return 0;
+		r = 0;
+		goto revert;
 	}
 
 	/* Copy across relevant fields */
 	if (dmt->dev_name && !dm_task_set_name(task, dmt->dev_name)) {
 		dm_task_destroy(task);
 		_udev_complete(dmt);
-		return 0;
+		r = 0;
+		goto revert;
 	}
 
 	task->read_only = dmt->read_only;


