From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 19 Oct 2011 16:36:03 -0000
Subject: LVM2/libdm libdm-deptree.c ioctl/libdm-iface.c ...
Message-ID: <20111019163603.26848.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-19 16:36:02

Modified files:
	libdm          : libdm-deptree.c 
	libdm/ioctl    : libdm-iface.c libdm-targets.h 

Log message:
	Add internal expected_errno dm_tast var
	
	Certain errno codes could be expected in some situations thus
	add experimental support for them.
	
	When expected errno is set after ioctl error - function skips error
	printing and exits succefully.
	
	Currently only useful for thin pool messages.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.128&r2=1.129
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.124&r2=1.125
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-targets.h.diff?cvsroot=lvm2&r1=1.32&r2=1.33

--- LVM2/libdm/libdm-deptree.c	2011/10/17 14:16:25	1.128
+++ LVM2/libdm/libdm-deptree.c	2011/10/19 16:36:01	1.129
@@ -111,6 +111,7 @@
 struct thin_message {
 	struct dm_list list;
 	struct dm_thin_message message;
+	int expected_errno;
 };
 
 /* Replicator-log has a list of sites */
@@ -1314,6 +1315,9 @@
 	if (!dm_task_set_message(dmt, buf))
 		goto_out;
 
+        /* Internal functionality of dm_task */
+	dmt->expected_errno = tm->expected_errno;
+
 	if (!dm_task_run(dmt))
 		goto_out;
 
@@ -2912,11 +2916,13 @@
 		if (!_thin_validate_device_id(message->u.m_create_thin.device_id))
 			return_0;
 		tm->message.u.m_create_thin.device_id = message->u.m_create_thin.device_id;
+		tm->expected_errno = EEXIST;
 		break;
 	case DM_THIN_MESSAGE_DELETE:
 		if (!_thin_validate_device_id(message->u.m_delete.device_id))
 			return_0;
 		tm->message.u.m_delete.device_id = message->u.m_delete.device_id;
+		tm->expected_errno = ENODATA;
 		break;
 	case DM_THIN_MESSAGE_TRIM:
 		if (!_thin_validate_device_id(message->u.m_trim.device_id))
--- LVM2/libdm/ioctl/libdm-iface.c	2011/10/17 14:36:06	1.124
+++ LVM2/libdm/ioctl/libdm-iface.c	2011/10/19 16:36:02	1.125
@@ -1635,7 +1635,8 @@
 		  dmt->sector, _sanitise_message(dmt->message),
 		  dmi->data_size, retry_repeat_count);
 #ifdef DM_IOCTLS
-	if (ioctl(_control_fd, command, dmi) < 0) {
+	if (ioctl(_control_fd, command, dmi) < 0 &&
+	    dmt->expected_errno != errno) {
 		if (errno == ENXIO && ((dmt->type == DM_DEVICE_INFO) ||
 				       (dmt->type == DM_DEVICE_MKNODES) ||
 				       (dmt->type == DM_DEVICE_STATUS)))
--- LVM2/libdm/ioctl/libdm-targets.h	2011/09/22 17:09:49	1.32
+++ LVM2/libdm/ioctl/libdm-targets.h	2011/10/19 16:36:02	1.33
@@ -65,6 +65,7 @@
 	int secure_data;
 	int retry_remove;
 	int enable_checks;
+	int expected_errno;
 
 	char *uuid;
 };


