From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 12 Dec 2013 12:43:41 +0000 (UTC)
Subject: master - dmeventd: change locking code
Message-ID: <20131212124341.0D4FA6024C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b87c148499c6a9dd8c6d34d9991350e203d37fe9
Commit:        b87c148499c6a9dd8c6d34d9991350e203d37fe9
Parent:        4fc97980b6e0f31c04d0325cd7ac4e84cdc58cc6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Jun 30 16:07:26 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Dec 12 13:38:55 2013 +0100

dmeventd: change locking code

Ensure global lock is being hold when working with thread->.
---
 WHATS_NEW_DM                |    1 +
 daemons/dmeventd/dmeventd.c |   12 +++++-------
 2 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 97c3c43..1e30d2a 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.84 -
 ====================================
+  Ensure global mutex is being hold when working with dmeventd thread.
   Drop taking timeout mutex for un/registering dmeventd monitor.
   Allow section names in config file data to be quoted strings.
   Close fifos before exiting in dmeventd restart() error path.
diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 47a341e..baa4fc3 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -832,10 +832,8 @@ static void *_monitor_thread(void *arg)
 			_unlock_mutex();
 			break;
 		}
-		_unlock_mutex();
 
 		if (thread->events & thread->current_events) {
-			_lock_mutex();
 			thread->processing = 1;
 			_unlock_mutex();
 
@@ -847,6 +845,7 @@ static void *_monitor_thread(void *arg)
 			thread->processing = 0;
 			_unlock_mutex();
 		} else {
+			_unlock_mutex();
 			dm_task_destroy(task);
 			thread->current_task = NULL;
 		}
@@ -1000,8 +999,6 @@ static int _register_for_event(struct message_data *message_data)
 		goto out;
 	}
 
-	_lock_mutex();
-
 	/* If creation of timeout thread fails (as it may), we fail
 	   here completely. The client is responsible for either
 	   retrying later or trying to register without timeout
@@ -1010,8 +1007,9 @@ static int _register_for_event(struct message_data *message_data)
 	   almost as good as dead already... */
 	if ((thread_new->events & DM_EVENT_TIMEOUT) &&
 	    (ret = -_register_for_timeout(thread_new)))
-		goto outth;
+		goto out;
 
+	_lock_mutex();
 	if (!(thread = _lookup_thread_status(message_data))) {
 		_unlock_mutex();
 
@@ -1035,8 +1033,6 @@ static int _register_for_event(struct message_data *message_data)
 
 	/* Or event # into events bitfield. */
 	thread->events |= message_data->events_field;
-
-    outth:
 	_unlock_mutex();
 
       out:
@@ -1569,8 +1565,10 @@ static void _cleanup_unused_threads(void)
 
 		if (thread->status == DM_THREAD_DONE) {
 			dm_list_del(l);
+			_unlock_mutex();
 			join_ret = pthread_join(thread->thread, NULL);
 			_free_thread_status(thread);
+			_lock_mutex();
 		}
 	}
 


