From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 26 May 2015 13:58:28 +0000 (UTC)
Subject: master - libdm: Add dm_task_get_errno to return ioctl errno.
Message-ID: <20150526135829.01390603F9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f9510548667754d9209b232348ccd2d806c0f1d8
Commit:        f9510548667754d9209b232348ccd2d806c0f1d8
Parent:        b244fffc182ef15ff23d4fc11658997347f66d79
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue May 26 14:52:13 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue May 26 14:52:13 2015 +0100

libdm: Add dm_task_get_errno to return ioctl errno.

There are reports of unexplained ioctl failures when using dmeventd.
An explanation might be that the wrong value of errno is being used.

Change libdevmapper to store an errno set by from dm ioctl() directly
and provide it to the caller through a new dm_task_get_errno() function.
---
 WHATS_NEW_DM                |    2 ++
 daemons/dmeventd/dmeventd.c |   25 ++++++++++++++-----------
 libdm/ioctl/libdm-iface.c   |   22 +++++++++++++++-------
 libdm/ioctl/libdm-targets.h |    1 +
 libdm/libdevmapper.h        |    5 +++++
 5 files changed, 37 insertions(+), 18 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 00c11e8..4dabdea 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,7 @@
 Version 1.02.98 - 
 ===============================
+  Add dm_task_get_errno() to return any unexpected errno from a dm ioctl call.
+  Use copy of errno made after each dm ioctl call in case errno changes later.
 
 Version 1.02.97 - 15th May 2015
 ===============================
diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index e8d1e3b..ad27060 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -710,6 +710,7 @@ static int _event_wait(struct thread_status *thread, struct dm_task **task)
 	int ret = DM_WAIT_RETRY;
 	struct dm_task *dmt;
 	struct dm_info info;
+	int ioctl_errno;
 
 	*task = 0;
 
@@ -739,25 +740,27 @@ static int _event_wait(struct thread_status *thread, struct dm_task **task)
 	 * either for a timeout event, or to cancel the thread.
 	 */
 	set = _unblock_sigalrm();
-	errno = 0;
 	if (dm_task_run(dmt)) {
 		thread->current_events |= DM_EVENT_DEVICE_ERROR;
 		ret = DM_WAIT_INTR;
 
 		if ((ret = dm_task_get_info(dmt, &info)))
 			thread->event_nr = info.event_nr;
-	} else if (thread->events & DM_EVENT_TIMEOUT && errno == EINTR) {
-		thread->current_events |= DM_EVENT_TIMEOUT;
-		ret = DM_WAIT_INTR;
-	} else if (thread->status == DM_THREAD_SHUTDOWN && errno == EINTR) {
-		ret = DM_WAIT_FATAL;
 	} else {
-		syslog(LOG_NOTICE, "dm_task_run failed, errno = %d, %s",
-		       errno, strerror(errno));
-		if (errno == ENXIO) {
-			syslog(LOG_ERR, "%s disappeared, detaching",
-			       thread->device.name);
+		ioctl_errno = dm_task_get_errno(dmt);
+		if (thread->events & DM_EVENT_TIMEOUT && ioctl_errno == EINTR) {
+			thread->current_events |= DM_EVENT_TIMEOUT;
+			ret = DM_WAIT_INTR;
+		} else if (thread->status == DM_THREAD_SHUTDOWN && ioctl_errno == EINTR)
 			ret = DM_WAIT_FATAL;
+		else {
+			syslog(LOG_NOTICE, "dm_task_run failed, errno = %d, %s",
+			       ioctl_errno, strerror(ioctl_errno));
+			if (ioctl_errno == ENXIO) {
+				syslog(LOG_ERR, "%s disappeared, detaching",
+				       thread->device.name);
+				ret = DM_WAIT_FATAL;
+			}
 		}
 	}
 	DEBUGLOG("Completed waitevent task for %s", thread->device.uuid);
diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index face593..e3b33b8 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -1717,6 +1717,8 @@ static struct dm_ioctl *_do_dm_ioctl(struct dm_task *dmt, unsigned command,
 	struct dm_ioctl *dmi;
 	int ioctl_with_uevent;
 
+	dmt->ioctl_errno = 0;
+
 	dmi = _flatten(dmt, buffer_repeat_count);
 	if (!dmi) {
 		log_error("Couldn't create ioctl argument.");
@@ -1803,12 +1805,13 @@ static struct dm_ioctl *_do_dm_ioctl(struct dm_task *dmt, unsigned command,
 #ifdef DM_IOCTLS
 	if (ioctl(_control_fd, command, dmi) < 0 &&
 	    dmt->expected_errno != errno) {
-		if (errno == ENXIO && ((dmt->type == DM_DEVICE_INFO) ||
-				       (dmt->type == DM_DEVICE_MKNODES) ||
-				       (dmt->type == DM_DEVICE_STATUS)))
+		dmt->ioctl_errno = errno;
+		if (dmt->ioctl_errno == ENXIO && ((dmt->type == DM_DEVICE_INFO) ||
+						  (dmt->type == DM_DEVICE_MKNODES) ||
+						  (dmt->type == DM_DEVICE_STATUS)))
 			dmi->flags &= ~DM_EXISTS_FLAG;	/* FIXME */
 		else {
-			if (_log_suppress || errno == EINTR)
+			if (_log_suppress || dmt->ioctl_errno == EINTR)
 				log_verbose("device-mapper: %s ioctl on %s%s%s%.0d%s%.0d%s%s "
 					    "failed: %s",
 				    	    _cmd_data_v4[dmt->type].name,
@@ -1819,7 +1822,7 @@ static struct dm_ioctl *_do_dm_ioctl(struct dm_task *dmt, unsigned command,
 					    dmt->minor > 0 ? dmt->minor : 0,
 					    dmt->major > 0 && dmt->minor == 0 ? "0" : "",
 					    dmt->major > 0 ? ")" : "",
-					    strerror(errno));
+					    strerror(dmt->ioctl_errno));
 			else
 				log_error("device-mapper: %s ioctl on %s%s%s%.0d%s%.0d%s%s "
 					  "failed: %s",
@@ -1831,14 +1834,14 @@ static struct dm_ioctl *_do_dm_ioctl(struct dm_task *dmt, unsigned command,
 					  dmt->minor > 0 ? dmt->minor : 0,
 					  dmt->major > 0 && dmt->minor == 0 ? "0" : "",
 					  dmt->major > 0 ? ")" : "",
-					  strerror(errno));
+					  strerror(dmt->ioctl_errno));
 
 			/*
 			 * It's sometimes worth retrying after EBUSY in case
 			 * it's a transient failure caused by an asynchronous
 			 * process quickly scanning the device.
 			 */
-			*retryable = errno == EBUSY;
+			*retryable = dmt->ioctl_errno == EBUSY;
 
 			goto error;
 		}
@@ -1876,6 +1879,11 @@ void dm_task_update_nodes(void)
 #define DM_IOCTL_RETRIES 25
 #define DM_RETRY_USLEEP_DELAY 200000
 
+int dm_task_get_errno(struct dm_task *dmt)
+{
+	return dmt->ioctl_errno;
+}
+
 int dm_task_run(struct dm_task *dmt)
 {
 	struct dm_ioctl *dmi;
diff --git a/libdm/ioctl/libdm-targets.h b/libdm/ioctl/libdm-targets.h
index 100681f..5545459 100644
--- a/libdm/ioctl/libdm-targets.h
+++ b/libdm/ioctl/libdm-targets.h
@@ -68,6 +68,7 @@ struct dm_task {
 	int deferred_remove;
 	int enable_checks;
 	int expected_errno;
+	int ioctl_errno;
 
 	char *uuid;
 	char *mangled_uuid;
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 8295e3c..c811641 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -393,6 +393,11 @@ int dm_get_status_thin(struct dm_pool *mem, const char *params,
 int dm_task_run(struct dm_task *dmt);
 
 /*
+ * The errno from the last device-mapper ioctl performed by dm_task_run.
+ */
+int dm_task_get_errno(struct dm_task *dmt);
+
+/*
  * Call this to make or remove the device nodes associated with previously
  * issued commands.
  */


