From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 13 Sep 2011 15:13:42 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/ioctl/libdm-iface.c
Message-ID: <20110913151342.26443.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-09-13 15:13:41

Modified files:
	.              : WHATS_NEW_DM 
	libdm/ioctl    : libdm-iface.c 

Log message:
	Retry DM_DEVICE_REMOVE ioctl if device is busy.
	
	This is a workaround for long-lasting problem with using the WATCH udev
	rule. When trying to remove a DM device, this one can still be opened
	while processing the event in parallel (generated based on the WATCH
	udev rule).
	
	Let's use this until we have a proper solution.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.498&r2=1.499
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.119&r2=1.120

--- LVM2/WHATS_NEW_DM	2011/09/07 08:37:48	1.498
+++ LVM2/WHATS_NEW_DM	2011/09/13 15:13:41	1.499
@@ -1,5 +1,6 @@
 Version 1.02.68 -
 ==================================
+  Retry DM_DEVICE_REMOVE ioctl if device is busy.
   Remove unused passed parameters for _mirror_emit_segment_line().
   Add dm_config and string character escaping functions to libdevmapper.
   Mark unreleased memory pools as internal error.
--- LVM2/libdm/ioctl/libdm-iface.c	2011/08/19 17:02:48	1.119
+++ LVM2/libdm/ioctl/libdm-iface.c	2011/09/13 15:13:41	1.120
@@ -1539,11 +1539,14 @@
 	return sanitised_message;
 }
 
+#define DM_REMOVE_IOCTL_RETRIES 25
+
 static struct dm_ioctl *_do_dm_ioctl(struct dm_task *dmt, unsigned command,
 				     unsigned repeat_count)
 {
 	struct dm_ioctl *dmi;
 	int ioctl_with_uevent;
+	int retries = DM_REMOVE_IOCTL_RETRIES;
 
 	dmi = _flatten(dmt, repeat_count);
 	if (!dmi) {
@@ -1627,11 +1630,23 @@
 		  dmt->sector, _sanitise_message(dmt->message),
 		  dmi->data_size);
 #ifdef DM_IOCTLS
+repeat_dm_ioctl:
 	if (ioctl(_control_fd, command, dmi) < 0) {
 		if (errno == ENXIO && ((dmt->type == DM_DEVICE_INFO) ||
 				       (dmt->type == DM_DEVICE_MKNODES) ||
 				       (dmt->type == DM_DEVICE_STATUS)))
 			dmi->flags &= ~DM_EXISTS_FLAG;	/* FIXME */
+		/*
+		 * FIXME: This is a workaround for asynchronous events generated
+		 *        as a result of using the WATCH udev rule with which we
+		 *        have no way of synchronizing. Processing such events in
+		 *        parallel causes devices to be open.
+		 */
+		else if (errno == EBUSY && (dmt->type == DM_DEVICE_REMOVE) && retries--) {
+			log_debug("device-mapper: device is busy, retrying removal");
+			usleep(200000);
+			goto repeat_dm_ioctl;
+		}
 		else {
 			if (_log_suppress)
 				log_verbose("device-mapper: %s ioctl "


