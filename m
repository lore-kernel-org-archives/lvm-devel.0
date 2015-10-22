From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 22 Oct 2015 21:33:54 +0000 (UTC)
Subject: master - dmeventd: minimize locking time for get_imeout
Message-ID: <20151022213354.2129C6057E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=15dbd4b56a65dba2f19bb1685529731faa9894c6
Commit:        15dbd4b56a65dba2f19bb1685529731faa9894c6
Parent:        e2ea2a81476495f494915774c46c0b3c139d1c3f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 22 12:38:26 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 22 22:34:30 2015 +0200

dmeventd: minimize locking time for get_imeout

Don't hold lock when creating message (allocating memory).
Thread cannot dissapear as it's only the same thread which
may clean it.
---
 daemons/dmeventd/dmeventd.c |   18 +++++++++---------
 1 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 2f5fe67..26e611d 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -1292,18 +1292,18 @@ static int _get_timeout(struct message_data *message_data)
 	struct thread_status *thread;
 	struct dm_event_daemon_message *msg = message_data->msg;
 
-	dm_free(msg->data);
-
 	_lock_mutex();
-	if ((thread = _lookup_thread_status(message_data))) {
-		msg->size = dm_asprintf(&(msg->data), "%s %" PRIu32,
-					message_data->id, thread->timeout);
-	} else
-		msg->data = NULL;
-
+	thread = _lookup_thread_status(message_data);
 	_unlock_mutex();
 
-	return thread ? 0 : -ENODEV;
+	if (!thread)
+		return -ENODEV;
+
+	dm_free(msg->data);
+	msg->size = dm_asprintf(&(msg->data), "%s %" PRIu32,
+				message_data->id, thread->timeout);
+
+	return (msg->data && msg->size) ? 0 : -ENOMEM;
 }
 
 /* Open fifos used for client communication. */


