From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 3 May 2010 21:06:53 -0000
Subject: LVM2/libdm libdm-common.c ioctl/libdm-iface.c
Message-ID: <20100503210653.28324.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2010-05-03 21:06:53

Modified files:
	libdm          : libdm-common.c 
	libdm/ioctl    : libdm-iface.c 

Log message:
	Synchronize "remove" dm task while reverting unsuccessful "create" dm task
	(with table provided).
	
	This remove ioctl generates udev events like any other hence it needs to be
	synchronized properly as well. Also, add dm task type in debug log when
	setting a cookie (for better debugging).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.94&r2=1.95
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.71&r2=1.72

--- LVM2/libdm/libdm-common.c	2010/03/23 14:43:18	1.94
+++ LVM2/libdm/libdm-common.c	2010/05/03 21:06:53	1.95
@@ -1192,7 +1192,7 @@
 	dmt->cookie_set = 1;
 
 	log_debug("Udev cookie 0x%" PRIx32 " (semid %d) assigned to dm_task "
-		  "with flags 0x%" PRIx16, *cookie, semid, flags);
+		  "type %d with flags 0x%" PRIx16, *cookie, semid, dmt->type, flags);
 
 	return 1;
 
--- LVM2/libdm/ioctl/libdm-iface.c	2010/04/28 13:37:37	1.71
+++ LVM2/libdm/ioctl/libdm-iface.c	2010/05/03 21:06:53	1.72
@@ -1546,6 +1546,7 @@
 {
 	struct dm_task *task;
 	int r;
+	uint32_t cookie;
 
 	/* Use new task struct to create the device */
 	if (!(task = dm_task_create(DM_DEVICE_CREATE))) {
@@ -1625,7 +1626,18 @@
  	dmt->type = DM_DEVICE_REMOVE;
 	dm_free(dmt->uuid);
 	dmt->uuid = NULL;
-	dmt->cookie_set = 0;
+
+	/*
+	 * Also udev-synchronize "remove" dm task that is a part of this revert!
+	 * But only if the original dm task was supposed to be synchronized.
+	 */
+	if (dmt->cookie_set) {
+		cookie = (dmt->event_nr & ~DM_UDEV_FLAGS_MASK) |
+			 (DM_COOKIE_MAGIC << DM_UDEV_FLAGS_SHIFT);
+		dm_task_set_cookie(dmt, &cookie,
+				   (dmt->event_nr & DM_UDEV_FLAGS_MASK) >>
+				    DM_UDEV_FLAGS_SHIFT);
+	}
 
 	if (!dm_task_run(dmt))
 		log_error("Failed to revert device creation.");


