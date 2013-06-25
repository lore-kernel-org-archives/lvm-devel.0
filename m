From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 25 Jun 2013 11:47:55 +0000 (UTC)
Subject: master - cleanup: reformat code of dmeventd
Message-ID: <20130625114755.3681C61386@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=01174b8b8b140280976182c143e764d525c54939
Commit:        01174b8b8b140280976182c143e764d525c54939
Parent:        88288ab43322c94750c25db249451be769931984
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 21 21:20:01 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 25 13:47:39 2013 +0200

cleanup: reformat code of dmeventd

---
 daemons/dmeventd/dmeventd.c |   31 +++++++++++++++----------------
 1 files changed, 15 insertions(+), 16 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 50bd1df..e9924f6 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -214,7 +214,7 @@ static pthread_mutex_t _timeout_mutex = PTHREAD_MUTEX_INITIALIZER;
 static pthread_cond_t _timeout_cond = PTHREAD_COND_INITIALIZER;
 
 /* Allocate/free the status structure for a monitoring thread. */
-static struct thread_status *_alloc_thread_status(struct message_data *data,
+static struct thread_status *_alloc_thread_status(const struct message_data *data,
 						  struct dso_data *dso_data)
 {
 	struct thread_status *ret = (typeof(ret)) dm_zalloc(sizeof(*ret));
@@ -330,8 +330,8 @@ static void _free_message(struct message_data *message_data)
 static int _parse_message(struct message_data *message_data)
 {
 	int ret = 0;
-	char *p = message_data->msg->data;
 	struct dm_event_daemon_message *msg = message_data->msg;
+	char *p = msg->data;
 
 	if (!msg->data)
 		return 0;
@@ -358,8 +358,9 @@ static int _parse_message(struct message_data *message_data)
 	dm_free(msg->data);
 	msg->data = NULL;
 	msg->size = 0;
+
 	return ret;
-};
+}
 
 /* Global mutex to lock access to lists et al. See _global_mutex
    above. */
@@ -426,8 +427,8 @@ static struct thread_status *_lookup_thread_status(struct message_data *data)
 	struct thread_status *thread;
 
 	dm_list_iterate_items(thread, &_thread_registry)
-	    if (!strcmp(data->device_uuid, thread->device.uuid))
-		return thread;
+		if (!strcmp(data->device_uuid, thread->device.uuid))
+			return thread;
 
 	return NULL;
 }
@@ -503,6 +504,7 @@ static void _exit_timeout(void *unused __attribute__((unused)))
 /* Wake up monitor threads every so often. */
 static void *_timeout_thread(void *unused __attribute__((unused)))
 {
+	struct thread_status *thread;
 	struct timespec timeout;
 	time_t curr_time;
 
@@ -511,8 +513,6 @@ static void *_timeout_thread(void *unused __attribute__((unused)))
 	pthread_mutex_lock(&_timeout_mutex);
 
 	while (!dm_list_empty(&_timeout_registry)) {
-		struct thread_status *thread;
-
 		timeout.tv_sec = 0;
 		curr_time = time(NULL);
 
@@ -552,7 +552,7 @@ static int _register_for_timeout(struct thread_status *thread)
 	if (!_timeout_running) {
 		pthread_t timeout_id;
 
-		if (!(ret = -_pthread_create_smallstack(&timeout_id, _timeout_thread, NULL)))
+		if (!(ret = _pthread_create_smallstack(&timeout_id, _timeout_thread, NULL)))
 			_timeout_running = 1;
 	}
 
@@ -986,11 +986,9 @@ static int _register_for_event(struct message_data *message_data)
 	   events. However, if timeout thread cannot be started, it
 	   usually means we are so starved on resources that we are
 	   almost as good as dead already... */
-	if (thread_new->events & DM_EVENT_TIMEOUT) {
-		ret = -_register_for_timeout(thread_new);
-		if (ret)
-			goto outth;
-	}
+	if ((thread_new->events & DM_EVENT_TIMEOUT) &&
+	    (ret = -_register_for_timeout(thread_new)))
+		goto out;
 
 	if (!(thread = _lookup_thread_status(message_data))) {
 		_unlock_mutex();
@@ -1008,8 +1006,9 @@ static int _register_for_event(struct message_data *message_data)
 			_do_unregister_device(thread);
 			_free_thread_status(thread);
 			goto out;
-		} else
-			LINK_THREAD(thread);
+		}
+
+		LINK_THREAD(thread);
 	}
 
 	/* Or event # into events bitfield. */
@@ -1452,7 +1451,7 @@ static int _do_process_request(struct dm_event_daemon_message *msg)
 		if (answer) {
 			msg->size = dm_asprintf(&(msg->data), "%s %s %d", answer,
 						msg->cmd == DM_EVENT_CMD_DIE ? "DYING" : "HELLO",
-                                                DM_EVENT_PROTOCOL_VERSION);
+						DM_EVENT_PROTOCOL_VERSION);
 			dm_free(answer);
 		} else
 			msg->size = 0;


