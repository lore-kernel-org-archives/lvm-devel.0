From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 18 Apr 2014 14:55:46 +0000 (UTC)
Subject: master - cleanup: dmeventd drop setting of size
Message-ID: <20140418145546.3015361056@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1f701c7bf6dfd9893f7ebf18cb572de4fd3fcdde
Commit:        1f701c7bf6dfd9893f7ebf18cb572de4fd3fcdde
Parent:        78c6dea48efff2a45e47f29aa171f18b5b8c46b0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 18 15:12:59 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 18 16:52:59 2014 +0200

cleanup: dmeventd drop setting of size

Size is not used when msg->data is NULL.
---
 daemons/dmeventd/dmeventd.c |   16 +++++-----------
 1 files changed, 5 insertions(+), 11 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 85f1b34..7decbcb 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -382,7 +382,6 @@ static int _parse_message(struct message_data *message_data)
 
 	dm_free(msg->data);
 	msg->data = NULL;
-	msg->size = 0;
 
 	return ret;
 }
@@ -1128,10 +1127,8 @@ static int _registered_device(struct message_data *message_data,
 	if ((r = dm_asprintf(&(msg->data), "%s %s %s %u",
 			     message_data->id,
 			     thread->dso_data->dso_name,
-			     thread->device.uuid, events)) < 0) {
-		msg->size = 0;
+			     thread->device.uuid, events)) < 0)
 		return -ENOMEM;
-	}
 
 	msg->size = (uint32_t) r;
 
@@ -1242,10 +1239,9 @@ static int _get_timeout(struct message_data *message_data)
 	if ((thread = _lookup_thread_status(message_data))) {
 		msg->size = dm_asprintf(&(msg->data), "%s %" PRIu32,
 					message_data->id, thread->timeout);
-	} else {
+	} else
 		msg->data = NULL;
-		msg->size = 0;
-	}
+
 	_unlock_mutex();
 
 	return thread ? 0 : -ENODEV;
@@ -1384,7 +1380,6 @@ static int _client_read(struct dm_event_fifos *fifos,
 	if (bytes != size) {
 		dm_free(msg->data);
 		msg->data = NULL;
-		msg->size = 0;
 		return 0;
 	}
 
@@ -1491,11 +1486,10 @@ static int _do_process_request(struct dm_event_daemon_message *msg)
 		answer = msg->data;
 		if (answer) {
 			msg->size = dm_asprintf(&(msg->data), "%s %s %d", answer,
-						msg->cmd == DM_EVENT_CMD_DIE ? "DYING" : "HELLO",
+						(msg->cmd == DM_EVENT_CMD_DIE) ? "DYING" : "HELLO",
 						DM_EVENT_PROTOCOL_VERSION);
 			dm_free(answer);
-		} else
-			msg->size = 0;
+		}
 	} else if (msg->cmd != DM_EVENT_CMD_ACTIVE && !_parse_message(&message_data)) {
 		stack;
 		ret = -EINVAL;


