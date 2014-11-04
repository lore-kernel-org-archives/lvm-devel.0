From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue,  4 Nov 2014 19:16:10 +0000 (UTC)
Subject: master - dmeventd: Add basic thread debugging messages.
Message-ID: <20141104191610.D484760D28@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=160777bb3eda1cae32511292070c92e076305ef6
Commit:        160777bb3eda1cae32511292070c92e076305ef6
Parent:        89f635a0759dd9499155b4bf6bf8c07090444ade
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Nov 4 18:56:20 2014 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Nov 4 18:56:20 2014 +0000

dmeventd: Add basic thread debugging messages.

Only with -DDEBUG.
---
 WHATS_NEW                   |    1 +
 daemons/dmeventd/dmeventd.c |   91 ++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 90 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 6c76fa9..8acbc3d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.112 - 
 =====================================
+  Add basic thread debugging messages to dmeventd.
   Include threads being shutdown in dmeventd device registration responses.
   Inital support for external users of thin pools based on transaction_id.
   Report some basic percentage info for cache pools.
diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 1b950cf..e8d1e3b 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -117,6 +117,73 @@ static int _foreground = 0;
 static int _restart = 0;
 static char **_initial_registrations = 0;
 
+/* FIXME Make configurable at runtime */
+#ifdef DEBUG
+#  define DEBUGLOG(fmt, args...) debuglog("[Thr %x]: " fmt, (int)pthread_self(), ## args)
+void debuglog(const char *fmt, ... ) __attribute__ ((format(printf, 1, 2)));
+
+void debuglog(const char *fmt, ...)
+{
+	va_list ap;
+
+	va_start(ap, fmt);
+	vsyslog(LOG_DEBUG, fmt, ap);
+	va_end(ap);
+}
+
+static const char *decode_cmd(uint32_t cmd)
+{
+	static char buf[128];
+	const char *command;
+
+	switch (cmd) {
+	case DM_EVENT_CMD_ACTIVE:
+		command = "ACTIVE";
+		break;
+	case DM_EVENT_CMD_REGISTER_FOR_EVENT:
+		command = "REGISTER_FOR_EVENT";
+		break;
+	case DM_EVENT_CMD_UNREGISTER_FOR_EVENT:
+		command = "UNREGISTER_FOR_EVENT";
+		break;
+	case DM_EVENT_CMD_GET_REGISTERED_DEVICE:
+		command = "GET_REGISTERED_DEVICE";
+		break;
+	case DM_EVENT_CMD_GET_NEXT_REGISTERED_DEVICE:
+		command = "GET_NEXT_REGISTERED_DEVICE";
+		break;
+	case DM_EVENT_CMD_SET_TIMEOUT:
+		command = "SET_TIMEOUT";
+		break;
+	case DM_EVENT_CMD_GET_TIMEOUT:
+		command = "GET_TIMEOUT";
+		break;
+	case DM_EVENT_CMD_HELLO:
+		command = "HELLO";
+		break;
+	case DM_EVENT_CMD_DIE:
+		command = "DIE";
+		break;
+	case DM_EVENT_CMD_GET_STATUS:
+		command = "GET_STATUS";
+		break;
+	case DM_EVENT_CMD_GET_PARAMETERS:
+		command = "GET_PARAMETERS";
+		break;
+	default:
+		command = "unknown";
+		break;
+	}
+
+	snprintf(buf, sizeof(buf), "%s (0x%x)", command, cmd);
+
+	return buf;
+}
+
+#else
+#  define DEBUGLOG(fmt, args...) do { } while (0)
+#endif
+
 /* Data kept about a DSO. */
 struct dso_data {
 	struct dm_list list;
@@ -538,6 +605,7 @@ static void *_timeout_thread(void *unused __attribute__((unused)))
 	struct timespec timeout;
 	time_t curr_time;
 
+	DEBUGLOG("Timeout thread starting.");
 	timeout.tv_nsec = 0;
 	pthread_cleanup_push(_exit_timeout, NULL);
 	pthread_mutex_lock(&_timeout_mutex);
@@ -549,6 +617,7 @@ static void *_timeout_thread(void *unused __attribute__((unused)))
 		dm_list_iterate_items_gen(thread, &_timeout_registry, timeout_list) {
 			if (thread->next_time <= curr_time) {
 				thread->next_time = curr_time + thread->timeout;
+				DEBUGLOG("Sending SIGALRM to Thr %x for timeout.", (int) thread->thread);
 				pthread_kill(thread->thread, SIGALRM);
 			}
 
@@ -560,6 +629,7 @@ static void *_timeout_thread(void *unused __attribute__((unused)))
 				       &timeout);
 	}
 
+	DEBUGLOG("Timeout thread finished.");
 	pthread_cleanup_pop(1);
 
 	return NULL;
@@ -643,6 +713,7 @@ static int _event_wait(struct thread_status *thread, struct dm_task **task)
 
 	*task = 0;
 
+	DEBUGLOG("Preparing waitevent task for %s", thread->device.uuid);
 	if (!(dmt = dm_task_create(DM_DEVICE_WAITEVENT)))
 		return DM_WAIT_RETRY;
 
@@ -661,6 +732,8 @@ static int _event_wait(struct thread_status *thread, struct dm_task **task)
 	if (!_in_event_counter++)
 		dm_log_init(_no_intr_log);
 	_unlock_mutex();
+
+	DEBUGLOG("Starting waitevent task for %s", thread->device.uuid);
 	/*
 	 * This is so that you can break out of waiting on an event,
 	 * either for a timeout event, or to cancel the thread.
@@ -687,6 +760,7 @@ static int _event_wait(struct thread_status *thread, struct dm_task **task)
 			ret = DM_WAIT_FATAL;
 		}
 	}
+	DEBUGLOG("Completed waitevent task for %s", thread->device.uuid);
 
 	pthread_sigmask(SIG_SETMASK, &set, NULL);
 	_lock_mutex();
@@ -735,6 +809,7 @@ static void _monitor_unregister(void *arg)
 {
 	struct thread_status *thread = arg, *thread_iter;
 
+	DEBUGLOG("_monitor_unregister thread cleanup handler running");
 	if (!_do_unregister_device(thread))
 		syslog(LOG_ERR, "%s: %s unregister failed\n", __func__,
 		       thread->device.name);
@@ -760,6 +835,7 @@ static void _monitor_unregister(void *arg)
 			_unlock_mutex();
 			return;
 		}
+	DEBUGLOG("Marking Thr %x as DONE and unused.", (int)thread->thread);
 	thread->status = DM_THREAD_DONE;
 	UNLINK_THREAD(thread);
 	LINK(thread, &_thread_registry_unused);
@@ -863,6 +939,7 @@ static void *_monitor_thread(void *arg)
 		}
 	}
 
+	DEBUGLOG("Finished _monitor_thread");
 	pthread_cleanup_pop(1);
 
 	return NULL;
@@ -876,6 +953,7 @@ static int _create_thread(struct thread_status *thread)
 
 static int _terminate_thread(struct thread_status *thread)
 {
+	DEBUGLOG("Sending SIGALRM to terminate Thr %x.", (int)thread->thread);
 	return pthread_kill(thread->thread, SIGALRM);
 }
 
@@ -1099,6 +1177,7 @@ static int _unregister_for_event(struct message_data *message_data)
 	 * unlink and terminate its monitoring thread.
 	 */
 	if (!thread->events) {
+		DEBUGLOG("Marking Thr %x unused (no events).", (int)thread->thread);
 		UNLINK_THREAD(thread);
 		LINK(thread, &_thread_registry_unused);
 	}
@@ -1516,6 +1595,9 @@ static void _process_request(struct dm_event_fifos *fifos)
 {
 	int die;
 	struct dm_event_daemon_message msg = { 0 };
+#ifdef DEBUG
+	const char *cmd;
+#endif
 
 	/*
 	 * Read the request from the client (client_read, client_write
@@ -1524,6 +1606,7 @@ static void _process_request(struct dm_event_fifos *fifos)
 	if (!_client_read(fifos, &msg))
 		return;
 
+	DEBUGLOG("%s processing...", cmd = decode_cmd(msg.cmd));
 	die = (msg.cmd == DM_EVENT_CMD_DIE) ? 1 : 0;
 
 	/* _do_process_request fills in msg (if memory allows for
@@ -1535,6 +1618,8 @@ static void _process_request(struct dm_event_fifos *fifos)
 
 	dm_free(msg.data);
 
+	DEBUGLOG("%s completed.", cmd);
+
 	if (die) {
 		if (unlink(DMEVENTD_PIDFILE))
 			perror(DMEVENTD_PIDFILE ": unlink failed");
@@ -1601,6 +1686,7 @@ static void _cleanup_unused_threads(void)
 		}
 
 		if (thread->status == DM_THREAD_DONE) {
+			DEBUGLOG("Destroying Thr %x.", (int)thread->thread);
 			dm_list_del(l);
 			_unlock_mutex();
 			join_ret = pthread_join(thread->thread, NULL);
@@ -1617,6 +1703,7 @@ static void _cleanup_unused_threads(void)
 
 static void _sig_alarm(int signum __attribute__((unused)))
 {
+	DEBUGLOG("Received SIGALRM.");
 	pthread_testcancel();
 }
 
@@ -1940,8 +2027,8 @@ static void restart(void)
 
 	if (version < 1) {
 		fprintf(stderr, "WARNING: The running dmeventd instance is too old.\n"
-			        "Protocol version %d (required: 1). Action cancelled.\n",
-			        version);
+				"Protocol version %d (required: 1). Action cancelled.\n",
+				version);
 		goto bad;
 	}
 


