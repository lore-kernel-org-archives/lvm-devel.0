From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 10 Mar 2014 11:27:17 +0000 (UTC)
Subject: master - cleanup: dmeventd code simplified
Message-ID: <20140310112717.4FF36603FB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7b17dfed69e50eabdc288f48a2fde16d4000709f
Commit:        7b17dfed69e50eabdc288f48a2fde16d4000709f
Parent:        341055ddb3bfaf3297aa068abf0d2412bc4cfd0b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 10 09:44:26 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 10 12:24:10 2014 +0100

cleanup: dmeventd code simplified

Improve readbility of code.
---
 daemons/dmeventd/dmeventd.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 621ae36..343180d 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -466,7 +466,7 @@ static int _get_status(struct message_data *message_data)
 	int i, j;
 	int ret = -1;
 	int count = dm_list_size(&_thread_registry);
-	int size = 0, current = 0;
+	int size = 0, current;
 	char *buffers[count];
 	char *message;
 
@@ -510,8 +510,8 @@ static int _get_status(struct message_data *message_data)
  out:
 	for (j = 0; j < i; ++j)
 		dm_free(buffers[j]);
-	return ret;
 
+	return ret;
 }
 
 static int _get_parameters(struct message_data *message_data) {
@@ -818,7 +818,7 @@ static struct dm_task *_get_device_status(struct thread_status *ts)
 static void *_monitor_thread(void *arg)
 {
 	struct thread_status *thread = arg;
-	int wait_error = 0;
+	int wait_error;
 	struct dm_task *task;
 
 	pthread_setcanceltype(PTHREAD_CANCEL_DEFERRED, NULL);
@@ -1413,9 +1413,10 @@ static int _client_read(struct dm_event_fifos *fifos,
 		dm_free(msg->data);
 		msg->data = NULL;
 		msg->size = 0;
+		return 0;
 	}
 
-	return bytes == size;
+	return 1;
 }
 
 /*
@@ -1528,7 +1529,7 @@ static int _do_process_request(struct dm_event_daemon_message *msg)
 /* Only one caller at a time. */
 static void _process_request(struct dm_event_fifos *fifos)
 {
-	int die = 0;
+	int die;
 	struct dm_event_daemon_message msg = { 0 };
 
 	/*
@@ -1538,8 +1539,7 @@ static void _process_request(struct dm_event_fifos *fifos)
 	if (!_client_read(fifos, &msg))
 		return;
 
-	if (msg.cmd == DM_EVENT_CMD_DIE)
-		die = 1;
+	die = (msg.cmd == DM_EVENT_CMD_DIE) ? 1 : 0;
 
 	/* _do_process_request fills in msg (if memory allows for
 	   data, otherwise just cmd and size = 0) */


