From: malahal@us.ibm.com <malahal@us.ibm.com>
Date: Tue, 22 Dec 2009 17:58:06 -0800
Subject: [PATCH 3 of 4] Add dm_event_set_timeout/dm_event_unset_timeout interface
In-Reply-To: <20091222105129.GD12491@agk-dp.fab.redhat.com>
References: <patchbomb.1260695922@localhost>
	<1c364c686b5e7794e994.1260695925@localhost>
	<20091222021255.GA14900@us.ibm.com>
	<20091222105129.GD12491@agk-dp.fab.redhat.com>
Message-ID: <20091223015806.GA9473@us.ibm.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Alasdair G Kergon [agk at redhat.com] wrote:
> Using a #define, please, rather than hard-coding -1 into the source.

Thank you. The following patch introduces DM_EVENT_REMOVE_TIMEOUT for
that purpose. This patch supersedes the previous patch (both patches are
against same source, so interdiff can be used to find just the
difference)

=============================================================================

Add dm_event_set_timeout/dm_event_unset_timeout interface

Will be used in mirror DSO to handle transient device failures.

Signed-off-by: Malahal Naineni <malahal@us.ibm.com>

diff -r c11c9f0a04f8 -r 0b6ad3b52702 daemons/dmeventd/.exported_symbols
--- a/daemons/dmeventd/.exported_symbols	Mon Dec 21 17:40:47 2009 -0800
+++ b/daemons/dmeventd/.exported_symbols	Tue Dec 22 15:53:11 2009 -0800
@@ -17,3 +17,5 @@ dm_event_unregister_handler
 dm_event_get_registered_device
 dm_event_handler_set_timeout
 dm_event_handler_get_timeout
+dm_event_set_timeout
+dm_event_unset_timeout
diff -r c11c9f0a04f8 -r 0b6ad3b52702 daemons/dmeventd/dmeventd.c
--- a/daemons/dmeventd/dmeventd.c	Mon Dec 21 17:40:47 2009 -0800
+++ b/daemons/dmeventd/dmeventd.c	Tue Dec 22 15:53:11 2009 -0800
@@ -155,7 +155,7 @@ struct message_data {
 	} events;
 	union {
 		char *str;
-		uint32_t secs;
+		int32_t secs;
 	} timeout;
 	struct dm_event_daemon_message *msg;	/* Pointer to message buffer. */
 };
@@ -187,7 +187,7 @@ struct thread_status {
 	enum dm_event_mask current_events;	/* bitfield for occured events. */
 	struct dm_task *current_task;
 	time_t next_time;
-	uint32_t timeout;
+	int32_t timeout;
 	struct dm_list timeout_list;
 	void *dso_private; /* dso per-thread status variable */
 };
@@ -363,7 +363,7 @@ static int _parse_message(struct message
 			message_data->events.field = i;
 		}
 		if (message_data->timeout.str) {
-			uint32_t secs = atoi(message_data->timeout.str);
+			int32_t secs = atoi(message_data->timeout.str);
 			dm_free(message_data->timeout.str);
 			message_data->timeout.secs = secs ? secs :
 			    DM_EVENT_DEFAULT_TIMEOUT;
@@ -1164,13 +1164,26 @@ static int _get_next_registered_device(s
 static int _set_timeout(struct message_data *message_data)
 {
 	struct thread_status *thread;
+	int ret = 0;
 
 	_lock_mutex();
-	if ((thread = _lookup_thread_status(message_data)))
-		thread->timeout = message_data->timeout.secs;
+	if ((thread = _lookup_thread_status(message_data))) {
+		/* A timeout of DM_EVENT_REMOVE_TIMEOUT is used to
+		 * unregister the timeout, register a timeout for any
+		 * other value.  */
+		thread->events &= ~DM_EVENT_TIMEOUT;
+		_unregister_for_timeout(thread);
+		if (message_data->timeout.secs != DM_EVENT_REMOVE_TIMEOUT) {
+			thread->events |= DM_EVENT_TIMEOUT;
+			thread->timeout = message_data->timeout.secs;
+			ret = _register_for_timeout(thread);
+		} else {
+			thread->timeout = 0;
+		}
+	}
 	_unlock_mutex();
 
-	return thread ? 0 : -ENODEV;
+	return (thread && ret == 0) ? 0 : -ENODEV;
 }
 
 static int _get_timeout(struct message_data *message_data)
diff -r c11c9f0a04f8 -r 0b6ad3b52702 daemons/dmeventd/dmeventd.h
--- a/daemons/dmeventd/dmeventd.h	Mon Dec 21 17:40:47 2009 -0800
+++ b/daemons/dmeventd/dmeventd.h	Tue Dec 22 15:53:11 2009 -0800
@@ -24,6 +24,7 @@
 #define DM_EVENT_PIDFILE	"/var/run/dmeventd.pid"
 
 #define DM_EVENT_DEFAULT_TIMEOUT 10
+#define DM_EVENT_REMOVE_TIMEOUT -1	/* used to unschedule a timeout */
 
 /* Commands for the daemon passed in the message below. */
 enum dm_event_command {
diff -r c11c9f0a04f8 -r 0b6ad3b52702 daemons/dmeventd/libdevmapper-event.c
--- a/daemons/dmeventd/libdevmapper-event.c	Mon Dec 21 17:40:47 2009 -0800
+++ b/daemons/dmeventd/libdevmapper-event.c	Tue Dec 22 15:53:11 2009 -0800
@@ -40,7 +40,7 @@ struct dm_event_handler {
 	char *uuid;
 	int major;
 	int minor;
-	uint32_t timeout;
+	int32_t timeout;
 
 	enum dm_event_mask mask;
 };
@@ -331,11 +331,11 @@ static int _daemon_write(struct dm_event
 static int _daemon_talk(struct dm_event_fifos *fifos,
 			struct dm_event_daemon_message *msg, int cmd,
 			const char *dso_name, const char *dev_name,
-			enum dm_event_mask evmask, uint32_t timeout)
+			enum dm_event_mask evmask, int32_t timeout)
 {
 	const char *dso = dso_name ? dso_name : "";
 	const char *dev = dev_name ? dev_name : "";
-	const char *fmt = "%d:%d %s %s %u %" PRIu32;
+	const char *fmt = "%d:%d %s %s %u %" PRId32;
 	int msg_size;
 	memset(msg, 0, sizeof(*msg));
 
@@ -550,7 +550,7 @@ failed:
 /* Handle the event (de)registration call and return negative error codes. */
 static int _do_event(int cmd, struct dm_event_daemon_message *msg,
 		     const char *dso_name, const char *dev_name,
-		     enum dm_event_mask evmask, uint32_t timeout)
+		     enum dm_event_mask evmask, int32_t timeout)
 {
 	int ret;
 	struct dm_event_fifos fifos;
@@ -770,27 +770,89 @@ int dm_event_get_registered_device(struc
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
+	/* timeout value of DM_EVENT_REMOVE_TIMEOUT is used to remove
+	 * the timer. */
+	return dm_event_set_timeout(dev_name, DM_EVENT_REMOVE_TIMEOUT);
+}
+
+int dm_event_set_timeout(const char *dev_name, int32_t timeout)
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
diff -r c11c9f0a04f8 -r 0b6ad3b52702 daemons/dmeventd/libdevmapper-event.h
--- a/daemons/dmeventd/libdevmapper-event.h	Mon Dec 21 17:40:47 2009 -0800
+++ b/daemons/dmeventd/libdevmapper-event.h	Tue Dec 22 15:53:11 2009 -0800
@@ -102,5 +102,7 @@ void process_event(struct dm_task *dmt, 
 int register_device(const char *device_name, const char *uuid, int major, int minor, void **user);
 int unregister_device(const char *device_name, const char *uuid, int major,
 		      int minor, void **user);
+int dm_event_set_timeout(const char *dev_name, int32_t timeout);
+int dm_event_unset_timeout(const char *dev_name);
 
 #endif


