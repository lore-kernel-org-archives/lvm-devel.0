From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 12 Dec 2013 12:43:38 +0000 (UTC)
Subject: master - dmeventd: drop taking timeout mutex
Message-ID: <20131212124338.EBA8E6024C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4fc97980b6e0f31c04d0325cd7ac4e84cdc58cc6
Commit:        4fc97980b6e0f31c04d0325cd7ac4e84cdc58cc6
Parent:        10a13dc03cd4da2df3518f7a94014f167ec13d47
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Jun 30 16:06:39 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Dec 12 13:32:49 2013 +0100

dmeventd: drop taking timeout mutex

Taking _timeout_mutex is not needed when registering and unregistering.
Global mutex is already being hold for this case.
---
 WHATS_NEW_DM                |    1 +
 daemons/dmeventd/dmeventd.c |    9 ++++-----
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index b737a3e..97c3c43 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.84 -
 ====================================
+  Drop taking timeout mutex for un/registering dmeventd monitor.
   Allow section names in config file data to be quoted strings.
   Close fifos before exiting in dmeventd restart() error path.
   Move printf format string directly into dm_asprintf args list.
diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index f2d6671..47a341e 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -751,10 +751,8 @@ static void _monitor_unregister(void *arg)
 			return;
 		}
 	thread->status = DM_THREAD_DONE;
-	pthread_mutex_lock(&_timeout_mutex);
 	UNLINK_THREAD(thread);
 	LINK(thread, &_thread_registry_unused);
-	pthread_mutex_unlock(&_timeout_mutex);
 	_unlock_mutex();
 }
 
@@ -1083,17 +1081,18 @@ static int _unregister_for_event(struct message_data *message_data)
 
 	thread->events &= ~message_data->events_field;
 
-	if (!(thread->events & DM_EVENT_TIMEOUT))
+	if (!(thread->events & DM_EVENT_TIMEOUT)) {
+		_unlock_mutex();
 		_unregister_for_timeout(thread);
+		_lock_mutex();
+	}
 	/*
 	 * In case there's no events to monitor on this device ->
 	 * unlink and terminate its monitoring thread.
 	 */
 	if (!thread->events) {
-		pthread_mutex_lock(&_timeout_mutex);
 		UNLINK_THREAD(thread);
 		LINK(thread, &_thread_registry_unused);
-		pthread_mutex_unlock(&_timeout_mutex);
 	}
 	_unlock_mutex();
 


