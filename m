From: Marian Csontos <mcsontos@redhat.com>
Date: Tue, 22 Sep 2015 13:16:10 +0200
Subject: [PATCH 4/4] dmeventd: Allocate new thread only when needed
In-Reply-To: <1442920570-29969-1-git-send-email-mcsontos@redhat.com>
References: <1442920570-29969-1-git-send-email-mcsontos@redhat.com>
Message-ID: <1442920570-29969-5-git-send-email-mcsontos@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

---
Another microoptimization?

Do we want to go through these hoops only to discard results later on?

These calls being called in front had justification earlier on when everything
was done in a single critical section protected by single lock/unlock pair. But
now when we are taking and releasing mutexes several times in one cycle this is
loosing grounds IMHO.

 daemons/dmeventd/dmeventd.c | 46 ++++++++++++++++++++++-----------------------
 1 file changed, 23 insertions(+), 23 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 82c8cc3..a4bf76e 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -1044,33 +1044,33 @@ static int _register_for_event(struct message_data *message_data)
 		goto out;
 	}
 
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
 	_lock_mutex();
 	if (!(thread = _lookup_thread_status(message_data))) {
 		_unlock_mutex();
 
+		/* Preallocate thread status struct to avoid deadlock. */
+		if (!(thread_new = _alloc_thread_status(message_data, dso_data))) {
+			stack;
+			ret = -ENOMEM;
+			goto out;
+		}
+
+		if (!_fill_device_data(thread_new)) {
+			stack;
+			ret = -ENODEV;
+			goto out;
+		}
+
+		/* If creation of timeout thread fails (as it may), we fail
+		   here completely. The client is responsible for either
+		   retrying later or trying to register without timeout
+		   events. However, if timeout thread cannot be started, it
+		   usually means we are so starved on resources that we are
+		   almost as good as dead already... */
+		if ((thread_new->events & DM_EVENT_TIMEOUT) &&
+		    (ret = -_register_for_timeout(thread_new)))
+			goto out;
+
 		if (!(ret = _do_register_device(thread_new)))
 			goto out;
 
-- 
1.8.3.1


