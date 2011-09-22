From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 22 Sep 2011 17:09:50 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/libdevmapper.h libdm ...
Message-ID: <20110922170950.22096.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-09-22 17:09:49

Modified files:
	.              : WHATS_NEW_DM 
	libdm          : libdevmapper.h 
	libdm/ioctl    : libdm-iface.c libdm-targets.h 

Log message:
	Add dm_task_retry_remove fn to use retry logic for device removal.
	
	This call ensures that the dm device removal is retried several
	times before failing.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.499&r2=1.500
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.149&r2=1.150
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.120&r2=1.121
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-targets.h.diff?cvsroot=lvm2&r1=1.31&r2=1.32

--- LVM2/WHATS_NEW_DM	2011/09/13 15:13:41	1.499
+++ LVM2/WHATS_NEW_DM	2011/09/22 17:09:48	1.500
@@ -1,6 +1,6 @@
 Version 1.02.68 -
 ==================================
-  Retry DM_DEVICE_REMOVE ioctl if device is busy.
+  Add dm_task_retry_remove fn to use retry logic for device removal.
   Remove unused passed parameters for _mirror_emit_segment_line().
   Add dm_config and string character escaping functions to libdevmapper.
   Mark unreleased memory pools as internal error.
--- LVM2/libdm/libdevmapper.h	2011/09/02 01:32:09	1.149
+++ LVM2/libdm/libdevmapper.h	2011/09/22 17:09:48	1.150
@@ -191,6 +191,7 @@
 int dm_task_query_inactive_table(struct dm_task *dmt);
 int dm_task_suppress_identical_reload(struct dm_task *dmt);
 int dm_task_secure_data(struct dm_task *dmt);
+int dm_task_retry_remove(struct dm_task *dmt);
 
 /*
  * Enable checks for common mistakes such as issuing ioctls in an unsafe order.
--- LVM2/libdm/ioctl/libdm-iface.c	2011/09/13 15:13:41	1.120
+++ LVM2/libdm/ioctl/libdm-iface.c	2011/09/22 17:09:48	1.121
@@ -828,6 +828,13 @@
 	return 1;
 }
 
+int dm_task_retry_remove(struct dm_task *dmt)
+{
+	dmt->retry_remove = 1;
+
+	return 1;
+}
+
 int dm_task_query_inactive_table(struct dm_task *dmt)
 {
 	dmt->query_inactive_table = 1;
@@ -1539,16 +1546,15 @@
 	return sanitised_message;
 }
 
-#define DM_REMOVE_IOCTL_RETRIES 25
-
 static struct dm_ioctl *_do_dm_ioctl(struct dm_task *dmt, unsigned command,
-				     unsigned repeat_count)
+				     unsigned buffer_repeat_count,
+				     unsigned retry_repeat_count,
+				     int *retryable)
 {
 	struct dm_ioctl *dmi;
 	int ioctl_with_uevent;
-	int retries = DM_REMOVE_IOCTL_RETRIES;
 
-	dmi = _flatten(dmt, repeat_count);
+	dmi = _flatten(dmt, buffer_repeat_count);
 	if (!dmi) {
 		log_error("Couldn't create ioctl argument.");
 		return NULL;
@@ -1609,7 +1615,7 @@
 	}
 
 	log_debug("dm %s %s%s %s%s%s %s%.0d%s%.0d%s"
-		  "%s%c%c%s%s%s%s%s %.0" PRIu64 " %s [%u]",
+		  "%s%c%c%s%s%s%s%s%s %.0" PRIu64 " %s [%u] (*%u)",
 		  _cmd_data_v4[dmt->type].name,
 		  dmt->new_uuid ? "UUID " : "",
 		  dmi->name, dmi->uuid, dmt->newname ? " " : "",
@@ -1624,29 +1630,18 @@
 		  dmt->no_flush ? 'N' : 'F',
 		  dmt->read_only ? "R" : "",
 		  dmt->skip_lockfs ? "S " : "",
+		  dmt->retry_remove ? "T " : "",
 		  dmt->secure_data ? "W " : "",
 		  dmt->query_inactive_table ? "I " : "",
 		  dmt->enable_checks ? "C" : "",
 		  dmt->sector, _sanitise_message(dmt->message),
-		  dmi->data_size);
+		  dmi->data_size, retry_repeat_count);
 #ifdef DM_IOCTLS
-repeat_dm_ioctl:
 	if (ioctl(_control_fd, command, dmi) < 0) {
 		if (errno == ENXIO && ((dmt->type == DM_DEVICE_INFO) ||
 				       (dmt->type == DM_DEVICE_MKNODES) ||
 				       (dmt->type == DM_DEVICE_STATUS)))
 			dmi->flags &= ~DM_EXISTS_FLAG;	/* FIXME */
-		/*
-		 * FIXME: This is a workaround for asynchronous events generated
-		 *        as a result of using the WATCH udev rule with which we
-		 *        have no way of synchronizing. Processing such events in
-		 *        parallel causes devices to be open.
-		 */
-		else if (errno == EBUSY && (dmt->type == DM_DEVICE_REMOVE) && retries--) {
-			log_debug("device-mapper: device is busy, retrying removal");
-			usleep(200000);
-			goto repeat_dm_ioctl;
-		}
 		else {
 			if (_log_suppress)
 				log_verbose("device-mapper: %s ioctl "
@@ -1658,6 +1653,9 @@
 					  "failed: %s",
 					  _cmd_data_v4[dmt->type].name,
 					  strerror(errno));
+
+			*retryable = errno == EBUSY;
+
 			_dm_zfree_dmi(dmi);
 			return NULL;
 		}
@@ -1680,6 +1678,9 @@
 	update_devs();
 }
 
+#define DM_IOCTL_RETRIES 25
+#define DM_RETRY_USLEEP_DELAY 200000
+
 int dm_task_run(struct dm_task *dmt)
 {
 	struct dm_ioctl *dmi;
@@ -1687,6 +1688,8 @@
 	int check_udev;
 	int rely_on_udev;
 	int suspended_counter;
+	unsigned ioctl_retry = 1;
+	int retryable;
 
 	if ((unsigned) dmt->type >=
 	    (sizeof(_cmd_data_v4) / sizeof(*_cmd_data_v4))) {
@@ -1734,7 +1737,14 @@
 
 	/* FIXME Detect and warn if cookie set but should not be. */
 repeat_ioctl:
-	if (!(dmi = _do_dm_ioctl(dmt, command, _ioctl_buffer_double_factor))) {
+	if (!(dmi = _do_dm_ioctl(dmt, command, _ioctl_buffer_double_factor,
+				 ioctl_retry, &retryable))) {
+		if (retryable && dmt->type == DM_DEVICE_REMOVE &&
+		    dmt->retry_remove && ++ioctl_retry <= DM_IOCTL_RETRIES) {
+			usleep(DM_RETRY_USLEEP_DELAY);
+			goto repeat_ioctl;
+		}
+
 		_udev_complete(dmt);
 		return 0;
 	}
--- LVM2/libdm/ioctl/libdm-targets.h	2011/08/09 17:56:48	1.31
+++ LVM2/libdm/ioctl/libdm-targets.h	2011/09/22 17:09:49	1.32
@@ -63,6 +63,7 @@
 	int cookie_set;
 	int new_uuid;
 	int secure_data;
+	int retry_remove;
 	int enable_checks;
 
 	char *uuid;


