From: Malahal Naineni <malahal@us.ibm.com>
Date: Sun, 13 Dec 2009 01:18:45 -0800
Subject: [PATCH 3 of 4] Add dm_event_set_timeout/dm_event_unset_timeout interface
In-Reply-To: <patchbomb.1260695922@localhost>
References: <patchbomb.1260695922@localhost>
Message-ID: <1c364c686b5e7794e994.1260695925@localhost>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Will be used in mirror DSO to handle transient device failures.

Signed-off-by: Malahal Naineni <malahal@us.ibm.com>

diff -r 1e369d480df0 -r 1c364c686b5e daemons/dmeventd/.exported_symbols
--- a/daemons/dmeventd/.exported_symbols	Sun Dec 13 01:17:52 2009 -0800
+++ b/daemons/dmeventd/.exported_symbols	Sun Dec 13 01:17:57 2009 -0800
@@ -17,3 +17,5 @@ dm_event_unregister_handler
 dm_event_get_registered_device
 dm_event_handler_set_timeout
 dm_event_handler_get_timeout
+dm_event_set_timeout
+dm_event_unset_timeout
diff -r 1e369d480df0 -r 1c364c686b5e daemons/dmeventd/dmeventd.c
--- a/daemons/dmeventd/dmeventd.c	Sun Dec 13 01:17:52 2009 -0800
+++ b/daemons/dmeventd/dmeventd.c	Sun Dec 13 01:17:57 2009 -0800
@@ -1164,13 +1164,25 @@ static int _get_next_registered_device(s
 static int _set_timeout(struct message_data *message_data)
 {
 	struct thread_status *thread;
+	int ret = 0;
 
 	_lock_mutex();
-	if ((thread = _lookup_thread_status(message_data)))
-		thread->timeout = message_data->timeout.secs;
+	if ((thread = _lookup_thread_status(message_data))) {
+		/* INT_MAX timeout is used to unregister timeout,
+		 * register timeout for any other value. */
+		thread->events &= ~DM_EVENT_TIMEOUT;
+		_unregister_for_timeout(thread);
+		if (message_data->timeout.secs == INT_MAX) {
+			thread->timeout = 0;
+		} else {
+			thread->events |= DM_EVENT_TIMEOUT;
+			thread->timeout = message_data->timeout.secs;
+			ret = _register_for_timeout(thread);
+		}
+	}
 	_unlock_mutex();
 
-	return thread ? 0 : -ENODEV;
+	return (thread && ret == 0) ? 0 : -ENODEV;
 }
 
 static int _get_timeout(struct message_data *message_data)
diff -r 1e369d480df0 -r 1c364c686b5e daemons/dmeventd/libdevmapper-event.c
--- a/daemons/dmeventd/libdevmapper-event.c	Sun Dec 13 01:17:52 2009 -0800
+++ b/daemons/dmeventd/libdevmapper-event.c	Sun Dec 13 01:17:57 2009 -0800
@@ -770,27 +770,90 @@ int dm_event_get_registered_device(struc
 	return ret;
 }
 
-#if 0				/* left out for now */
+/* Get uuid of a device */
+static struct dm_task *_get_device_info_by_name(const char *dev_name)
+{
+	struct dm_task *dmt;
+	struct dm_info info;
+
+	if (!(dmt = dm_task_create(DM_DEVICE_INFO))) {
+		log_error("_get_device_info: dm_task creation for info failed");
+		return NULL;
+	}
+
+	dm_task_set_name(dmt, dev_name);
+
+	/* FIXME Add name or uuid or devno to messages */
+	if (!dm_task_run(dmt)) {
+		log_error("_get_device_info: dm_task_run() failed");
+		goto failed;
+	}
+
+	if (!dm_task_get_info(dmt, &info)) {
+		log_error("_get_device_info: failed to get info for device");
+		goto failed;
+	}
+
+	if (!info.exists) {
+		log_error("_get_device_info: device not found");
+		goto failed;
+	}
+
+	return dmt;
+
+failed:
+	dm_task_destroy(dmt);
+	return NULL;
+}
+
+int dm_event_unset_timeout(const char *dev_name)
+{
+	/* timeout of INT_MAX is used as no timeout that removes the
+	 * timer.  INT_MAX is chosen instead of -1 as atoi() is used in
+	 * dmeventd.c */
+	return dm_event_set_timeout(dev_name, INT_MAX);
+}
+
+int dm_event_set_timeout(const char *dev_name, uint32_t timeout)
+{
+	int ret = 1, err;
+	const char *uuid;
+	struct dm_task *dmt;
+	struct dm_event_daemon_message msg = { 0, 0, NULL };
+
+	if (!(dmt = _get_device_info_by_name(dev_name))) {
+		stack;
+		return 0;
+	}
+
+	uuid = dm_task_get_uuid(dmt);
+
+	if ((err = _do_event(DM_EVENT_CMD_SET_TIMEOUT, &msg,
+			     NULL, uuid, 0, timeout)) < 0) {
+		log_error("%s: event set timeout failed: %s",
+			  dm_task_get_name(dmt),
+			  msg.data ? msg.data : strerror(-err));
+		ret = 0;
+	}
+
+	if (msg.data)
+		dm_free(msg.data);
+
+	dm_task_destroy(dmt);
+
+	return ret;
+}
+
+#if 0
 
 static char *_skip_string(char *src, const int delimiter)
 {
-	src = srtchr(src, delimiter);
+	src = strchr(src, delimiter);
 	if (src && *(src + 1))
 		return src + 1;
 	return NULL;
 }
 
-int dm_event_set_timeout(const char *device_path, uint32_t timeout)
-{
-	struct dm_event_daemon_message msg = { 0, 0, NULL };
-
-	if (!device_exists(device_path))
-		return -ENODEV;
-
-	return _do_event(DM_EVENT_CMD_SET_TIMEOUT, &msg,
-			 NULL, device_path, 0, timeout);
-}
-
 int dm_event_get_timeout(const char *device_path, uint32_t *timeout)
 {
 	int ret;
diff -r 1e369d480df0 -r 1c364c686b5e daemons/dmeventd/libdevmapper-event.h
--- a/daemons/dmeventd/libdevmapper-event.h	Sun Dec 13 01:17:52 2009 -0800
+++ b/daemons/dmeventd/libdevmapper-event.h	Sun Dec 13 01:17:57 2009 -0800
@@ -102,5 +102,7 @@ void process_event(struct dm_task *dmt, 
 int register_device(const char *device_name, const char *uuid, int major, int minor, void **user);
 int unregister_device(const char *device_name, const char *uuid, int major,
 		      int minor, void **user);
+int dm_event_set_timeout(const char *dev_name, uint32_t timeout);
+int dm_event_unset_timeout(const char *dev_name);
 
 #endif


