From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 13 Oct 2015 14:04:15 +0000 (UTC)
Subject: master - dmeventd: new initialization of plugin threads
Message-ID: <20151013140415.C1150602D1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=76ea01dd207ce185891418c3f8ffdcff14bf2672
Commit:        76ea01dd207ce185891418c3f8ffdcff14bf2672
Parent:        362558cd66bc08f8a46ababef66f2df21e8bd6fc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 13 09:43:09 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 13 15:55:05 2015 +0200

dmeventd: new initialization of plugin threads

Rework thread creation code to better use resources.

New code will not leak 'timeout' registered thread on error path.

Also if the thread already exist - avoid creation of thread
object and it's later destruction.

If the race is noticed during adding new monitoring thread,
such thread is put on cleanup list and -EEXIST is reported.
---
 WHATS_NEW_DM                |    1 +
 daemons/dmeventd/dmeventd.c |  170 +++++++++++++++++++++---------------------
 2 files changed, 86 insertions(+), 85 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index efe8b37..f041ed1 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.110 - 
 ======================================
+  Reworked thread initialization for dmeventd plugins.
   Dmeventd handles snapshot overflow for now equally as invalid.
   Convert dmeventd to use common logging macro system from libdm.
   Return -ENOMEM when device registration fails instead of 0 (=success).
diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 3e54f79..ba7d01c 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -990,91 +990,6 @@ static int _active(struct message_data *message_data)
 }
 
 /*
- * Register for an event.
- *
- * Only one caller at a time here, because we use
- * a FIFO and lock it against multiple accesses.
- */
-static int _register_for_event(struct message_data *message_data)
-{
-	int ret = 0;
-	struct thread_status *thread, *thread_new = NULL;
-	struct dso_data *dso_data;
-
-	if (!(dso_data = _lookup_dso(message_data)) &&
-	    !(dso_data = _load_dso(message_data))) {
-		stack;
-#ifdef ELIBACC
-		ret = -ELIBACC;
-#else
-		ret = -ENODEV;
-#endif
-		goto out;
-	}
-
-	/* Preallocate thread status struct to avoid deadlock. */
-	if (!(thread_new = _alloc_thread_status(message_data, dso_data))) {
-		stack;
-		ret = -ENOMEM;
-		goto out;
-	}
-
-	if (!_fill_device_data(thread_new)) {
-		stack;
-		ret = -ENODEV;
-		goto out;
-	}
-
-	/* If creation of timeout thread fails (as it may), we fail
-	   here completely. The client is responsible for either
-	   retrying later or trying to register without timeout
-	   events. However, if timeout thread cannot be started, it
-	   usually means we are so starved on resources that we are
-	   almost as good as dead already... */
-	if ((thread_new->events & DM_EVENT_TIMEOUT) &&
-	    (ret = -_register_for_timeout(thread_new)))
-		goto out;
-
-	_lock_mutex();
-	if (!(thread = _lookup_thread_status(message_data))) {
-		_unlock_mutex();
-
-		if (!_do_register_device(thread_new)) {
-			ret = -ENOMEM;
-			goto_out;
-		}
-
-		thread = thread_new;
-		thread_new = NULL;
-
-		/* Try to create the monitoring thread for this device. */
-		_lock_mutex();
-		if ((ret = -_create_thread(thread))) {
-			_unlock_mutex();
-			_do_unregister_device(thread);
-			_free_thread_status(thread);
-			goto out;
-		}
-
-		LINK_THREAD(thread);
-	}
-
-	/* Or event # into events bitfield. */
-	thread->events |= message_data->events_field;
-	_unlock_mutex();
-
-      out:
-	/*
-	 * Deallocate thread status after releasing
-	 * the lock in case we haven't used it.
-	 */
-	if (thread_new)
-		_free_thread_status(thread_new);
-
-	return ret;
-}
-
-/*
  * Unregister for an event.
  *
  * Only one caller at a time here as with register_for_event().
@@ -1128,6 +1043,91 @@ static int _unregister_for_event(struct message_data *message_data)
 }
 
 /*
+ * Register for an event.
+ *
+ * Only one caller at a time here, because we use
+ * a FIFO and lock it against multiple accesses.
+ */
+static int _register_for_event(struct message_data *message_data)
+{
+	int ret = 0;
+	struct thread_status *thread;
+	struct dso_data *dso_data;
+
+	if (!(dso_data = _lookup_dso(message_data)) &&
+	    !(dso_data = _load_dso(message_data))) {
+		stack;
+#ifdef ELIBACC
+		ret = -ELIBACC;
+#else
+		ret = -ENODEV;
+#endif
+		return ret;
+	}
+
+	_lock_mutex();
+
+	if ((thread = _lookup_thread_status(message_data)))
+		/* Or event # into events bitfield. */
+		thread->events |= message_data->events_field;
+
+	_unlock_mutex();
+
+	if (!thread) {
+		if (!(thread = _alloc_thread_status(message_data, dso_data))) {
+			stack;
+			return -ENOMEM;
+		}
+
+		if (!_fill_device_data(thread)) {
+			ret = -ENODEV;
+			goto_out;
+		}
+
+		if (!_do_register_device(thread)) {
+			ret = -ENOMEM;
+			goto_out;
+		}
+
+		if ((ret = -_create_thread(thread))) {
+			_do_unregister_device(thread);
+			goto_out;
+		}
+
+		_lock_mutex();
+		if (_lookup_thread_status(message_data)) {
+			DEBUGLOG("Race, uuid already registered, marking Thr %x unused.",
+				 (int)thread->thread);
+			thread->status = DM_THREAD_SHUTDOWN;
+			thread->events = 0;
+			LINK(thread, &_thread_registry_unused);
+			_unlock_mutex();
+			ret = -EEXIST; /* race ? */
+			goto_out;
+		}
+
+		LINK_THREAD(thread);
+		_unlock_mutex();
+	}
+
+	/* If creation of timeout thread fails (as it may), we fail
+	   here completely. The client is responsible for either
+	   retrying later or trying to register without timeout
+	   events. However, if timeout thread cannot be started, it
+	   usually means we are so starved on resources that we are
+	   almost as good as dead already... */
+	if ((thread->events & DM_EVENT_TIMEOUT) &&
+	    (ret = -_register_for_timeout(thread)))
+		_unregister_for_event(message_data);
+
+	return ret;
+out:
+	_free_thread_status(thread);
+
+	return ret;
+}
+
+/*
  * Get registered device.
  *
  * Only one caller at a time here as with register_for_event().


