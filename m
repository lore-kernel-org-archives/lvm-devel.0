From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 22 Oct 2015 21:34:00 +0000 (UTC)
Subject: master - dmeventd: rework locking code
Message-ID: <20151022213400.6D7D16057E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9156c5d0888bf95b79d931682b51fc63c96ba236
Commit:        9156c5d0888bf95b79d931682b51fc63c96ba236
Parent:        466a1c72b7f24be4c932b503b3f8a3fb50a2eda5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 22 15:47:53 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 22 22:39:24 2015 +0200

dmeventd: rework locking code

Redesign threading code:

- plugin registration runs within its new created thread for
  improved parallel usage.

- wait task is created just once and used during whole plugin lifetime.

- event thread is based over  'events' filter being set - when
  filter is 0, such thread is 'unused'.

- event loop is  simplified.

- timeout thread is never signaling 'processing' thread.

- pending of events filter cnange is properly reported and
  running event thread is signalled when possible.

- helgrind is not reporting problems.
---
 WHATS_NEW_DM                |    1 +
 daemons/dmeventd/dmeventd.c |  497 ++++++++++++++++++++-----------------------
 2 files changed, 231 insertions(+), 267 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 5f92657..8c27139 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.110 - 
 ======================================
+  New design for thread cooperation in dmeventd.
   Dmeventd read device status with 'noflush'.
   Dmeventd closes control device when no device is monitored.
   Thin plugin for dmeventd improved percentage usage.
diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 8267dc4..d8c317e 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -85,23 +85,6 @@ static volatile sig_atomic_t _exit_now = 0;	/* set to '1' when signal is given t
 */
 static pthread_mutex_t _global_mutex;
 
-/*
-  There are three states a thread can attain (see struct
-  thread_status, field int status):
-
-  - DM_THREAD_RUNNING: thread has started up and is either working or
-  waiting for events... transitions to either SHUTDOWN or DONE
-  - DM_THREAD_SHUTDOWN: thread is still doing something, but it is
-  supposed to terminate (and transition to DONE) as soon as it
-  finishes whatever it was doing at the point of flipping state to
-  SHUTDOWN... the thread is still on the thread list
-  - DM_THREAD_DONE: thread has terminated and has been moved over to
-  unused thread list, cleanup pending
- */
-#define DM_THREAD_RUNNING  0
-#define DM_THREAD_SHUTDOWN 1
-#define DM_THREAD_DONE     2
-
 static const size_t THREAD_STACK_SIZE = 300 * 1024;
 
 static int _debug_level = 0;
@@ -204,6 +187,13 @@ struct message_data {
 	struct dm_event_daemon_message *msg;	/* Pointer to message buffer. */
 };
 
+/* There are three states a thread can attain. */
+enum {
+	DM_THREAD_REGISTERING,	/* Registering, transitions to RUNNING */
+	DM_THREAD_RUNNING,	/* Working on events, transitions to DONE */
+	DM_THREAD_DONE		/* Terminated and cleanup is pending */
+};
+
 /*
  * Housekeeping of thread+device states.
  *
@@ -222,18 +212,19 @@ struct thread_status {
 		char *name;
 		int major, minor;
 	} device;
-	uint32_t event_nr;	/* event number */
 	int processing;		/* Set when event is being processed */
 
-	int status;		/* see DM_THREAD_{RUNNING,SHUTDOWN,DONE}
-				   constants above */
-	enum dm_event_mask events;	/* bitfield for event filter. */
-	enum dm_event_mask current_events;	/* bitfield for occured events. */
-	struct dm_task *current_task;
+	int status;		/* See DM_THREAD_{REGISTERING,RUNNING,DONE} */
+
+	int events;		/* bitfield for event filter. */
+	int current_events;	/* bitfield for occured events. */
+	struct dm_task *wait_task;
+	int pending;		/* Set when event filter change is pending */
 	time_t next_time;
 	uint32_t timeout;
 	struct dm_list timeout_list;
 	void *dso_private; /* dso per-thread status variable */
+	/* TODO per-thread mutex */
 };
 static DM_LIST_INIT(_thread_registry);
 static DM_LIST_INIT(_thread_registry_unused);
@@ -379,34 +370,57 @@ bad:
 /* Allocate/free the thread status structure for a monitoring thread. */
 static void _free_thread_status(struct thread_status *thread)
 {
+
 	_lib_put(thread->dso_data);
-	if (thread->current_task)
-		dm_task_destroy(thread->current_task);
+	if (thread->wait_task)
+		dm_task_destroy(thread->wait_task);
 	dm_free(thread->device.uuid);
 	dm_free(thread->device.name);
 	dm_free(thread);
 }
 
-/* Allocate/free the status structure for a monitoring thread. */
+/* Note: events_field must not be 0, ensured by caller */
 static struct thread_status *_alloc_thread_status(const struct message_data *data,
 						  struct dso_data *dso_data)
 {
-	struct thread_status *ret;
-
-	if (!(ret = dm_zalloc(sizeof(*ret))))
-		return NULL;
+	struct thread_status *thread;
 
-	if (!(ret->device.uuid = dm_strdup(data->device_uuid))) {
-		dm_free(ret);
+	if (!(thread = dm_zalloc(sizeof(*thread)))) {
+		log_error("Cannot create new thread, out of memory.");
 		return NULL;
 	}
 
-	ret->dso_data = dso_data;
-	ret->events = data->events_field;
-	ret->timeout = data->timeout_secs;
-	dm_list_init(&ret->timeout_list);
+	_lib_get(dso_data);
+	thread->dso_data = dso_data;
 
-	return ret;
+	if (!(thread->wait_task = dm_task_create(DM_DEVICE_WAITEVENT)))
+		goto_out;
+
+	if (!dm_task_set_uuid(thread->wait_task, data->device_uuid))
+		goto_out;
+
+	if (!(thread->device.uuid = dm_strdup(data->device_uuid)))
+		goto_out;
+
+        /* Until real name resolved, use UUID */
+	if (!(thread->device.name = dm_strdup(data->device_uuid)))
+		goto_out;
+
+	/* runs ioctl and may register lvm2 pluging */
+	thread->processing = 1;
+	thread->status = DM_THREAD_REGISTERING;
+
+	thread->events = data->events_field;
+	thread->pending = DM_EVENT_REGISTRATION_PENDING;
+	thread->timeout = data->timeout_secs;
+	dm_list_init(&thread->timeout_list);
+
+	return thread;
+
+out:
+	_free_thread_status(thread);
+
+	return NULL;
 }
 
 /*
@@ -563,6 +577,8 @@ static int _fill_device_data(struct thread_status *ts)
 
 	ts->device.major = dmi.major;
 	ts->device.minor = dmi.minor;
+	dm_task_set_event_nr(ts->wait_task, dmi.event_nr);
+
 	ret = 1;
 fail:
 	dm_task_destroy(dmt);
@@ -711,8 +727,17 @@ static void *_timeout_thread(void *unused __attribute__((unused)))
 		dm_list_iterate_items_gen(thread, &_timeout_registry, timeout_list) {
 			if (thread->next_time <= curr_time) {
 				thread->next_time = curr_time + thread->timeout;
-				DEBUGLOG("Sending SIGALRM to Thr %x for timeout.", (int) thread->thread);
-				pthread_kill(thread->thread, SIGALRM);
+				_lock_mutex();
+				if (thread->processing) {
+					/* Cannot signal processing monitoring thread */
+					log_debug("Skipping SIGALRM to processing Thr %x for timeout.",
+						  (int) thread->thread);
+				} else {
+					DEBUGLOG("Sending SIGALRM to Thr %x for timeout.",
+						 (int) thread->thread);
+					pthread_kill(thread->thread, SIGALRM);
+				}
+				_unlock_mutex();
 			}
 
 			if (thread->next_time < timeout.tv_sec || !timeout.tv_sec)
@@ -781,69 +806,45 @@ enum {
 };
 
 /* Wait on a device until an event occurs. */
-static int _event_wait(struct thread_status *thread, struct dm_task **task)
+static int _event_wait(struct thread_status *thread)
 {
 	sigset_t set;
 	int ret = DM_WAIT_RETRY;
-	struct dm_task *dmt;
 	struct dm_info info;
-	int ioctl_errno;
-
-	*task = 0;
 
-	DEBUGLOG("Preparing waitevent task for %s", thread->device.uuid);
-	if (!(dmt = dm_task_create(DM_DEVICE_WAITEVENT)))
-		return DM_WAIT_RETRY;
+	/* TODO: audit libdm thread usage */
 
-	thread->current_task = dmt;
-
-	if (!dm_task_set_uuid(dmt, thread->device.uuid) ||
-	    !dm_task_set_event_nr(dmt, thread->event_nr))
-		goto out;
-
-	/*
-	 * Check if there are already some waiting events,
-	 * in this case the logging is unmodified.
-	 * TODO: audit libdm thread usage
-	 */
-	DEBUGLOG("Starting waitevent task for %s", thread->device.uuid);
 	/*
 	 * This is so that you can break out of waiting on an event,
 	 * either for a timeout event, or to cancel the thread.
 	 */
 	set = _unblock_sigalrm();
-	if (dm_task_run(dmt)) {
+
+	if (dm_task_run(thread->wait_task)) {
 		thread->current_events |= DM_EVENT_DEVICE_ERROR;
 		ret = DM_WAIT_INTR;
-
-		if ((ret = dm_task_get_info(dmt, &info)))
-			thread->event_nr = info.event_nr;
+		/* Update event_nr */
+		if (dm_task_get_info(thread->wait_task, &info))
+			dm_task_set_event_nr(thread->wait_task, info.event_nr);
 	} else {
-		ioctl_errno = dm_task_get_errno(dmt);
-		if (thread->events & DM_EVENT_TIMEOUT && ioctl_errno == EINTR) {
+		switch (dm_task_get_errno(thread->wait_task)) {
+		case ENXIO:
+			log_error("%s disappeared, detaching.",
+				  thread->device.name);
+			ret = DM_WAIT_FATAL;
+			break;
+		case EINTR:
 			thread->current_events |= DM_EVENT_TIMEOUT;
 			ret = DM_WAIT_INTR;
-		} else if (thread->status == DM_THREAD_SHUTDOWN && ioctl_errno == EINTR)
-			ret = DM_WAIT_FATAL;
-		else {
-			if (ioctl_errno == ENXIO) {
-				log_error("%s disappeared, detaching.",
-					  thread->device.name);
-				ret = DM_WAIT_FATAL;
-			} else
-				log_sys_error("dm_task_run", "");
+			break;
+		default:
+			log_sys_error("dm_task_run", "waitevent");
 		}
 	}
-	DEBUGLOG("Completed waitevent task for %s", thread->device.uuid);
 
 	pthread_sigmask(SIG_SETMASK, &set, NULL);
 
-      out:
-	if (ret == DM_WAIT_FATAL || ret == DM_WAIT_RETRY) {
-		dm_task_destroy(dmt);
-		thread->current_task = NULL;
-	} else
-		*task = dmt;
+	DEBUGLOG("Completed waitevent task for %s.", thread->device.name);
 
 	return ret;
 }
@@ -869,9 +870,27 @@ static int _do_unregister_device(struct thread_status *thread)
 }
 
 /* Process an event in the DSO. */
-static void _do_process_event(struct thread_status *thread, struct dm_task *task)
+static void _do_process_event(struct thread_status *thread)
 {
-	thread->dso_data->process_event(task, thread->current_events, &(thread->dso_private));
+	struct dm_task *task;
+
+	/* NOTE: timeout event gets status */
+	task = (thread->current_events & DM_EVENT_TIMEOUT)
+		? _get_device_status(thread) : thread->wait_task;
+
+	if (!task)
+		log_error("Lost event in Thr %x.", (int)thread->thread);
+	else {
+		thread->dso_data->process_event(task, thread->current_events, &(thread->dso_private));
+		if (task != thread->wait_task)
+			dm_task_destroy(task);
+	}
+}
+
+static void _thread_unused(struct thread_status *thread)
+{
+	UNLINK_THREAD(thread);
+	LINK(thread, &_thread_registry_unused);
 }
 
 /* Thread cleanup handler to unregister device. */
@@ -879,36 +898,30 @@ static void _monitor_unregister(void *arg)
 {
 	struct thread_status *thread = arg, *thread_iter;
 
-	DEBUGLOG("_monitor_unregister thread cleanup handler running");
-	if (!_do_unregister_device(thread))
+	dm_list_iterate_items(thread_iter, &_thread_registry)
+		if (thread_iter == thread) {
+			/* Relink to _unused */
+			_thread_unused(thread);
+			break;
+		}
+
+	thread->pending = 0;	/* Event pending resolved */
+	thread->processing = 1;	/* Process unregistering */
+
+	_unlock_mutex();
+
+	DEBUGLOG("Unregistering monitor for %s.", thread->device.name);
+	_unregister_for_timeout(thread);
+
+	if ((thread->status != DM_THREAD_REGISTERING) &&
+	    !_do_unregister_device(thread))
 		log_error("%s: %s unregister failed.", __func__,
 			  thread->device.name);
-	if (thread->current_task) {
-		dm_task_destroy(thread->current_task);
-		thread->current_task = NULL;
-	}
 
-	_lock_mutex();
-	if (thread->events & DM_EVENT_TIMEOUT) {
-		/* _unregister_for_timeout locks another mutex, we
-		   don't want to deadlock so we release our mutex for
-		   a bit */
-		_unlock_mutex();
-		_unregister_for_timeout(thread);
-		_lock_mutex();
-	}
-	/* we may have been relinked to unused registry since we were
-	   called, so check that */
-	dm_list_iterate_items(thread_iter, &_thread_registry_unused)
-		if (thread_iter == thread) {
-			thread->status = DM_THREAD_DONE;
-			_unlock_mutex();
-			return;
-		}
 	DEBUGLOG("Marking Thr %x as DONE and unused.", (int)thread->thread);
-	thread->status = DM_THREAD_DONE;
-	UNLINK_THREAD(thread);
-	LINK(thread, &_thread_registry_unused);
+
+	_lock_mutex();
+	thread->status = DM_THREAD_DONE; /* Last access to thread memory! */
 	_unlock_mutex();
 }
 
@@ -916,80 +929,64 @@ static void _monitor_unregister(void *arg)
 static void *_monitor_thread(void *arg)
 {
 	struct thread_status *thread = arg;
-	int wait_error;
-	struct dm_task *task;
+	int ret;
+	sigset_t pendmask;
 
 	pthread_setcanceltype(PTHREAD_CANCEL_DEFERRED, NULL);
 	pthread_cleanup_push(_monitor_unregister, thread);
 
-	/* Wait for do_process_request() to finish its task. */
-	_lock_mutex();
-	thread->status = DM_THREAD_RUNNING;
-	_unlock_mutex();
-
-	/* Loop forever awaiting/analyzing device events. */
-	while (1) {
-		thread->current_events = 0;
+	if (!_fill_device_data(thread)) {
+		log_error("Failed to fill device data for %s.", thread->device.uuid);
+		_lock_mutex();
+		goto out;
+	}
 
-		wait_error = _event_wait(thread, &task);
-		if (wait_error == DM_WAIT_RETRY) {
-			usleep(100); /* avoid busy loop */
-			continue;
-		}
+	if (!_do_register_device(thread)) {
+		log_error("Failed to register device %s.", thread->device.name);
+		_lock_mutex();
+		goto out;
+	}
 
-		if (wait_error == DM_WAIT_FATAL)
-			break;
+	_lock_mutex();
+	thread->status = DM_THREAD_RUNNING;
+	thread->processing = 0;
 
-		/* Timeout occurred, task is not filled properly.
-		 * We get device status here for processing it in DSO.
-		 */
-		if (wait_error == DM_WAIT_INTR &&
-		    thread->current_events & DM_EVENT_TIMEOUT) {
-			dm_task_destroy(task);
-			task = _get_device_status(thread);
-			/* FIXME: syslog fail here ? */
-			if (!(thread->current_task = task))
-				continue;
-		}
+	/* Loop awaiting/analyzing device events. */
+	while (thread->events) {
 
-		/*
-		 * We know that wait succeeded and stored a
-		 * pointer to dm_task with device status into task.
-		 */
+		thread->pending = 0; /* Event is no longer pending...  */
 
 		/*
-		 * Check against filter.
+		 * Check against bitmask filter.
 		 *
 		 * If there's current events delivered from _event_wait() AND
 		 * the device got registered for those events AND
 		 * those events haven't been processed yet, call
 		 * the DSO's process_event() handler.
 		 */
-		_lock_mutex();
-		if (thread->status == DM_THREAD_SHUTDOWN) {
-			_unlock_mutex();
-			break;
-		}
-
 		if (thread->events & thread->current_events) {
-			thread->processing = 1;
+			thread->processing = 1;  /* Cannot be removed/signaled */
 			_unlock_mutex();
 
-			_do_process_event(thread, task);
-			dm_task_destroy(task);
-			thread->current_task = NULL;
+			_do_process_event(thread);
+			thread->current_events = 0; /* Current events processed */
 
 			_lock_mutex();
 			thread->processing = 0;
-			_unlock_mutex();
 		} else {
 			_unlock_mutex();
-			dm_task_destroy(task);
-			thread->current_task = NULL;
+
+			if ((ret = _event_wait(thread)) == DM_WAIT_RETRY)
+				usleep(100); /* Avoid busy loop, wait without mutex */
+
+			_lock_mutex();
+
+			if (ret == DM_WAIT_FATAL)
+				break;
 		}
 	}
+out:
 
-	DEBUGLOG("Finished _monitor_thread.");
 	pthread_cleanup_pop(1);
 
 	return NULL;
@@ -1001,10 +998,36 @@ static int _create_thread(struct thread_status *thread)
 	return _pthread_create_smallstack(&thread->thread, _monitor_thread, thread);
 }
 
-static int _terminate_thread(struct thread_status *thread)
+/* Update events - needs to be locked */
+static int _update_events(struct thread_status *thread, int events)
 {
-	DEBUGLOG("Sending SIGALRM to terminate Thr %x.", (int)thread->thread);
-	return pthread_kill(thread->thread, SIGALRM);
+	int ret = 0;
+
+	if (thread->events == events)
+		return 0; /* Nothing has changed */
+
+	thread->events = events;
+	thread->pending = DM_EVENT_REGISTRATION_PENDING;
+
+	/* Only non-processing threads can be notified */
+	if (!thread->processing) {
+		DEBUGLOG("Sending SIGALRM to wakeup Thr %x.", (int)thread->thread);
+
+		/* Notify thread waiting in ioctl (to speed-up) */
+		if ((ret = pthread_kill(thread->thread, SIGALRM))) {
+			if (ret == ESRCH)
+				thread->events = 0;  /* thread is gone */
+			else
+				log_error("Unable to wakeup thread: %s",
+					  strerror(ret));
+		}
+	}
+
+	/* Threads with no events has to be moved to unused */
+	if (!thread->events)
+		_thread_unused(thread);
+
+	return -ret;
 }
 
 /* Return success on daemon active check. */
@@ -1020,8 +1043,8 @@ static int _active(struct message_data *message_data)
  */
 static int _unregister_for_event(struct message_data *message_data)
 {
-	int ret = 0;
 	struct thread_status *thread;
+	int ret;
 
 	/*
 	 * Clear event in bitfield and deactivate
@@ -1031,38 +1054,21 @@ static int _unregister_for_event(struct message_data *message_data)
 
 	if (!(thread = _lookup_thread_status(message_data))) {
 		_unlock_mutex();
-		ret = -ENODEV;
-		goto out;
+		return -ENODEV;
 	}
 
-	if (thread->status == DM_THREAD_DONE) {
-		/* the thread has terminated while we were not
-		   watching */
-		_unlock_mutex();
-		return 0;
-	}
+	/* AND mask event ~# from events bitfield. */
+	ret = _update_events(thread, (thread->events & ~message_data->events_field));
 
-	thread->events &= ~message_data->events_field;
+	_unlock_mutex();
 
-	if (!(thread->events & DM_EVENT_TIMEOUT)) {
-		_unlock_mutex();
+	/* If there are no events, thread is later garbage
+	 * collected by _cleanup_unused_threads */
+	if (message_data->events_field & DM_EVENT_TIMEOUT)
 		_unregister_for_timeout(thread);
-		_lock_mutex();
-	}
-	/*
-	 * In case there's no events to monitor on this device ->
-	 * unlink and terminate its monitoring thread.
-	 */
-	if (!thread->events) {
-		DEBUGLOG("Marking Thr %x unused (no events).", (int)thread->thread);
-		UNLINK_THREAD(thread);
-		LINK(thread, &_thread_registry_unused);
-	}
-	_unlock_mutex();
 
-	DEBUGLOG("Unregistered uuid:%s.", thread->device.uuid);
+	DEBUGLOG("Unregistered event for %s.", thread->device.name);
 
-      out:
 	return ret;
 }
 
@@ -1082,73 +1088,52 @@ static int _register_for_event(struct message_data *message_data)
 	    !(dso_data = _load_dso(message_data))) {
 		stack;
 #ifdef ELIBACC
-		ret = -ELIBACC;
+		ret = ELIBACC;
 #else
-		ret = -ENODEV;
+		ret = ENODEV;
 #endif
 		return ret;
 	}
 
 	_lock_mutex();
 
-	if ((thread = _lookup_thread_status(message_data)))
-		/* Or event # into events bitfield. */
-		thread->events |= message_data->events_field;
-
-	_unlock_mutex();
+	if ((thread = _lookup_thread_status(message_data))) {
+		/* OR event # into events bitfield. */
+		ret = _update_events(thread, (thread->events | message_data->events_field));
+	} else {
+		_unlock_mutex();
 
-	if (!thread) {
+		/* Only creating thread during event processing
+		 * Remaining initialization happens within monitoring thread */
 		if (!(thread = _alloc_thread_status(message_data, dso_data))) {
 			stack;
 			return -ENOMEM;
 		}
 
-		if (!_fill_device_data(thread)) {
-			ret = -ENODEV;
-			goto_out;
-		}
-
-		if (!_do_register_device(thread)) {
-			ret = -ENOMEM;
-			goto_out;
-		}
-
-		if ((ret = -_create_thread(thread))) {
-			_do_unregister_device(thread);
-			goto_out;
+		if ((ret = _create_thread(thread))) {
+			log_sys_error("pthread_create", "");
+			_free_thread_status(thread);
+			return -ret;
 		}
 
 		_lock_mutex();
-		if (_lookup_thread_status(message_data)) {
-			DEBUGLOG("Race, uuid already registered, marking Thr %x unused.",
-				 (int)thread->thread);
-			thread->status = DM_THREAD_SHUTDOWN;
-			thread->events = 0;
-			LINK(thread, &_thread_registry_unused);
-			_unlock_mutex();
-			ret = -EEXIST; /* race ? */
-			goto_out;
-		}
-
+		/* Note: same uuid can't be added in parallel */
 		LINK_THREAD(thread);
-		_unlock_mutex();
 	}
 
+	_unlock_mutex();
+
 	/* If creation of timeout thread fails (as it may), we fail
 	   here completely. The client is responsible for either
 	   retrying later or trying to register without timeout
 	   events. However, if timeout thread cannot be started, it
 	   usually means we are so starved on resources that we are
 	   almost as good as dead already... */
-	if ((thread->events & DM_EVENT_TIMEOUT) &&
-	    (ret = -_register_for_timeout(thread)))
+	if ((message_data->events_field & DM_EVENT_TIMEOUT) &&
+	    (ret = _register_for_timeout(thread)))
 		_unregister_for_event(message_data);
 
-	return ret;
-out:
-	_free_thread_status(thread);
-
-	return ret;
+	return -ret;
 }
 
 /*
@@ -1161,16 +1146,14 @@ static int _registered_device(struct message_data *message_data,
 {
 	int r;
 	struct dm_event_daemon_message *msg = message_data->msg;
-	unsigned events = ((thread->status == DM_THREAD_RUNNING) &&
-			   thread->events) ? thread->events :
-			    thread->events | DM_EVENT_REGISTRATION_PENDING;
 
 	dm_free(msg->data);
 
 	if ((r = dm_asprintf(&(msg->data), "%s %s %s %u",
 			     message_data->id,
 			     thread->dso_data->dso_name,
-			     thread->device.uuid, events)) < 0)
+			     thread->device.uuid,
+			     thread->events | thread->pending)) < 0)
 		return -ENOMEM;
 
 	msg->size = (uint32_t) r;
@@ -1182,7 +1165,6 @@ static int _registered_device(struct message_data *message_data,
 static int _want_registered_device(char *dso_name, char *device_uuid,
 				   struct thread_status *thread)
 {
-	DEBUGLOG("Looking for dso:%s  uuid:%s.", dso_name, device_uuid);
 	/* If DSO names and device paths are equal. */
 	if (dso_name && device_uuid)
 		return !strcmp(dso_name, thread->dso_data->dso_name) &&
@@ -1625,58 +1607,39 @@ static void _process_initial_registrations(void)
 
 static void _cleanup_unused_threads(void)
 {
-	int ret;
 	struct dm_list *l;
 	struct thread_status *thread;
-	int join_ret = 0;
+	int ret;
 
 	_lock_mutex();
+
 	while ((l = dm_list_first(&_thread_registry_unused))) {
 		thread = dm_list_item(l, struct thread_status);
-		if (thread->processing)
-			break;	/* cleanup on the next round */
+		if (thread->status != DM_THREAD_DONE) {
+			if (thread->processing)
+				break; /* cleanup on the next round */
 
-		if (thread->status == DM_THREAD_RUNNING) {
-			thread->status = DM_THREAD_SHUTDOWN;
-			break;
-		}
+			/* Signal possibly sleeping thread */
+			ret = pthread_kill(thread->thread, SIGALRM);
+			if (!ret || (ret != ESRCH))
+				break; /* check again on the next round */
 
-		if (thread->status == DM_THREAD_SHUTDOWN) {
-			if (!thread->events) {
-				/* turn codes negative -- should we be returning this? */
-				ret = _terminate_thread(thread);
+			/* thread is likely gone */
+		}
 
-				if (ret == ESRCH) {
-					thread->status = DM_THREAD_DONE;
-				} else if (ret) {
-					log_error("Unable to terminate thread: %s",
-						  strerror(ret));
-				}
-				break;
-			}
+		dm_list_del(l);
+		_unlock_mutex();
 
-			dm_list_del(l);
-			log_error("thread can't be on unused list unless !thread->events");
-			thread->status = DM_THREAD_RUNNING;
-			LINK_THREAD(thread);
+		DEBUGLOG("Destroying Thr %x.", (int)thread->thread);
 
-			continue;
-		}
+		if (pthread_join(thread->thread, NULL))
+			log_sys_error("pthread_join", "");
 
-		if (thread->status == DM_THREAD_DONE) {
-			dm_list_del(l);
-			_unlock_mutex();
-			DEBUGLOG("Destroying Thr %x.", (int)thread->thread);
-			join_ret = pthread_join(thread->thread, NULL);
-			_free_thread_status(thread);
-			_lock_mutex();
-		}
+		_free_thread_status(thread);
+		_lock_mutex();
 	}
 
 	_unlock_mutex();
-
-	if (join_ret)
-		log_error("Failed pthread_join: %s.", strerror(join_ret));
 }
 
 static void _sig_alarm(int signum __attribute__((unused)))


