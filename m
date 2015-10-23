From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 23 Oct 2015 08:55:04 +0000 (UTC)
Subject: master - dmeventd: debug error paths
Message-ID: <20151023085504.DE155610F9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cff1c728d8c80b3393c461f6229066f633b67fc2
Commit:        cff1c728d8c80b3393c461f6229066f633b67fc2
Parent:        2786cd27da3e7c6176940495ba57653ead7cfe08
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 23 09:43:06 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 23 10:54:13 2015 +0200

dmeventd: debug error paths

---
 daemons/dmeventd/dmeventd.c |   13 +++++++++----
 1 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 6f3bfff..af03091 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -446,8 +446,10 @@ static int _pthread_create_smallstack(pthread_t *t, void *(*fun)(void *), void *
 	 * Linux these functions always succeed (but portable and future-proof
 	 * applications should nevertheless handle a possible error return).
 	 */
-	if ((r = pthread_attr_init(&attr)) != 0)
+	if ((r = pthread_attr_init(&attr)) != 0) {
+		log_sys_error("pthread_attr_init", "");
 		return r;
+	}
 
 	/*
 	 * We use a smaller stack since it gets preallocated in its entirety
@@ -462,7 +464,8 @@ static int _pthread_create_smallstack(pthread_t *t, void *(*fun)(void *), void *
 		t = &tmp;
 	}
 
-	r = pthread_create(t, &attr, fun, arg);
+	if ((r = pthread_create(t, &attr, fun, arg)))
+		log_sys_error("pthread_create", "");
 
 	pthread_attr_destroy(&attr);
 
@@ -1150,7 +1153,7 @@ static int _register_for_event(struct message_data *message_data)
 		}
 
 		if ((ret = _create_thread(thread))) {
-			log_sys_error("pthread_create", "");
+			stack;
 			_free_thread_status(thread);
 			return -ret;
 		}
@@ -1169,8 +1172,10 @@ static int _register_for_event(struct message_data *message_data)
 	   usually means we are so starved on resources that we are
 	   almost as good as dead already... */
 	if ((message_data->events_field & DM_EVENT_TIMEOUT) &&
-	    (ret = _register_for_timeout(thread)))
+	    (ret = _register_for_timeout(thread))) {
+		stack;
 		_unregister_for_event(message_data);
+	}
 
 	return -ret;
 }


