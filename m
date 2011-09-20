From: Peter Rajnoha <prajnoha@redhat.com>
Date: Tue, 20 Sep 2011 14:55:45 +0200
Subject: [PATCH 1/7][retry remove] Add new "dm_task_retry_remove" fn to libdm and make "retry remove ioctl" logic to be used on demand
Message-ID: <4E788D51.1060600@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Part of this patch is revert of the original "retry remove" patch,
moving the retry loop higher from the _do_dm_ioctl into the dm_task_run.
(However, now we get the "device or resource busy" error repeated on output
instead of silently trying the ioctl several times)

Also, the retry logic is switched on by calling the dm_task_retry_remove fn.

Peter
---
 libdm/ioctl/libdm-iface.c   |   40 +++++++++++++++++++++++-----------------
 libdm/ioctl/libdm-targets.h |    1 +
 libdm/libdevmapper.h        |    1 +
 3 files changed, 25 insertions(+), 17 deletions(-)

diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index a6097d3..be7a7fd 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -828,6 +828,13 @@ int dm_task_secure_data(struct dm_task *dmt)
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
@@ -1539,14 +1546,11 @@ static const char *_sanitise_message(char *message)
 	return sanitised_message;
 }
 
-#define DM_REMOVE_IOCTL_RETRIES 25
-
 static struct dm_ioctl *_do_dm_ioctl(struct dm_task *dmt, unsigned command,
-				     unsigned repeat_count)
+				     unsigned repeat_count, int *retry)
 {
 	struct dm_ioctl *dmi;
 	int ioctl_with_uevent;
-	int retries = DM_REMOVE_IOCTL_RETRIES;
 
 	dmi = _flatten(dmt, repeat_count);
 	if (!dmi) {
@@ -1630,23 +1634,11 @@ static struct dm_ioctl *_do_dm_ioctl(struct dm_task *dmt, unsigned command,
 		  dmt->sector, _sanitise_message(dmt->message),
 		  dmi->data_size);
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
@@ -1658,6 +1650,10 @@ repeat_dm_ioctl:
 					  "failed: %s",
 					  _cmd_data_v4[dmt->type].name,
 					  strerror(errno));
+
+			*retry = dmt->retry_remove && (errno == EBUSY) &&
+				 (dmt->type == DM_DEVICE_REMOVE);
+
 			_dm_zfree_dmi(dmi);
 			return NULL;
 		}
@@ -1680,6 +1676,8 @@ void dm_task_update_nodes(void)
 	update_devs();
 }
 
+#define DM_IOCTL_RETRIES 25
+
 int dm_task_run(struct dm_task *dmt)
 {
 	struct dm_ioctl *dmi;
@@ -1687,6 +1685,8 @@ int dm_task_run(struct dm_task *dmt)
 	int check_udev;
 	int rely_on_udev;
 	int suspended_counter;
+	int ioctl_retries = DM_IOCTL_RETRIES;
+	int retry;
 
 	if ((unsigned) dmt->type >=
 	    (sizeof(_cmd_data_v4) / sizeof(*_cmd_data_v4))) {
@@ -1734,7 +1734,13 @@ int dm_task_run(struct dm_task *dmt)
 
 	/* FIXME Detect and warn if cookie set but should not be. */
 repeat_ioctl:
-	if (!(dmi = _do_dm_ioctl(dmt, command, _ioctl_buffer_double_factor))) {
+	if (!(dmi = _do_dm_ioctl(dmt, command, _ioctl_buffer_double_factor, &retry))) {
+		if (retry && ioctl_retries--) {
+			log_debug("device-mapper: retrying ioctl");
+			usleep(200000);
+			goto repeat_ioctl;
+		}
+
 		_udev_complete(dmt);
 		return 0;
 	}
diff --git a/libdm/ioctl/libdm-targets.h b/libdm/ioctl/libdm-targets.h
index 82792e0..ca08fe8 100644
--- a/libdm/ioctl/libdm-targets.h
+++ b/libdm/ioctl/libdm-targets.h
@@ -63,6 +63,7 @@ struct dm_task {
 	int cookie_set;
 	int new_uuid;
 	int secure_data;
+	int retry_remove;
 	int enable_checks;
 
 	char *uuid;
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index c0b9fff..628d7da 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -191,6 +191,7 @@ int dm_task_skip_lockfs(struct dm_task *dmt);
 int dm_task_query_inactive_table(struct dm_task *dmt);
 int dm_task_suppress_identical_reload(struct dm_task *dmt);
 int dm_task_secure_data(struct dm_task *dmt);
+int dm_task_retry_remove(struct dm_task *dmt);
 
 /*
  * Enable checks for common mistakes such as issuing ioctls in an unsafe order.


