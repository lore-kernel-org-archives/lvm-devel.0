From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 2 Mar 2012 23:01:10 -0000
Subject: LVM2/daemons/dmeventd dmeventd.c
Message-ID: <20120302230110.30891.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-02 23:01:10

Modified files:
	daemons/dmeventd: dmeventd.c 

Log message:
	Code refactoring
	
	Properly test for dm_asprintf result.
	Keep unlocking of mutex in the same function and do not spread lock and
	unlock over functions.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/dmeventd.c.diff?cvsroot=lvm2&r1=1.95&r2=1.96

--- LVM2/daemons/dmeventd/dmeventd.c	2012/03/02 22:57:25	1.95
+++ LVM2/daemons/dmeventd/dmeventd.c	2012/03/02 23:01:10	1.96
@@ -1000,10 +1000,8 @@
 	   almost as good as dead already... */
 	if (thread_new->events & DM_EVENT_TIMEOUT) {
 		ret = -_register_for_timeout(thread_new);
-		if (ret) {
-		    _unlock_mutex();
-		    goto out;
-		}
+		if (ret)
+			goto outth;
 	}
 
 	if (!(thread = _lookup_thread_status(message_data))) {
@@ -1029,6 +1027,7 @@
 	/* Or event # into events bitfield. */
 	thread->events |= message_data->events.field;
 
+    outth:
 	_unlock_mutex();
 
       out:
@@ -1105,15 +1104,19 @@
 	const char *id = message_data->id;
 	const char *dso = thread->dso_data->dso_name;
 	const char *dev = thread->device.uuid;
+	int r;
 	unsigned events = ((thread->status == DM_THREAD_RUNNING)
 			   && (thread->events)) ? thread->events : thread->
 	    events | DM_EVENT_REGISTRATION_PENDING;
 
 	dm_free(msg->data);
 
-	msg->size = dm_asprintf(&(msg->data), fmt, id, dso, dev, events);
+	if ((r = dm_asprintf(&(msg->data), fmt, id, dso, dev, events)) < 0) {
+		msg->size = 0;
+		return -ENOMEM;
+	}
 
-	_unlock_mutex();
+	msg->size = (uint32_t) r;
 
 	return 0;
 }
@@ -1146,6 +1149,7 @@
 static int _get_registered_dev(struct message_data *message_data, int next)
 {
 	struct thread_status *thread, *hit = NULL;
+	int ret = -ENOENT;
 
 	_lock_mutex();
 
@@ -1162,10 +1166,8 @@
 	 * If we got a registered device and want the next one ->
 	 * fetch next conforming element off the list.
 	 */
-	if (hit && !next) {
-		_unlock_mutex();
-		return _registered_device(message_data, hit);
-	}
+	if (hit && !next)
+		goto reg;
 
 	if (!hit)
 		goto out;
@@ -1181,13 +1183,13 @@
 		}
 	}
 
-	_unlock_mutex();
-	return _registered_device(message_data, hit);
+      reg:
+	ret = _registered_device(message_data, hit);
 
       out:
 	_unlock_mutex();
-	
-	return -ENOENT;
+
+	return ret;
 }
 
 static int _get_registered_device(struct message_data *message_data)


