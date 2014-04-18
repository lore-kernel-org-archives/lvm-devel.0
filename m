From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 18 Apr 2014 14:55:44 +0000 (UTC)
Subject: master - cleanup: dmeventd improve _handle_request
Message-ID: <20140418145544.1CD3361056@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=78c6dea48efff2a45e47f29aa171f18b5b8c46b0
Commit:        78c6dea48efff2a45e47f29aa171f18b5b8c46b0
Parent:        0927605ec3214349f69d849f72d138696231f3e7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 18 14:45:45 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 18 16:52:45 2014 +0200

cleanup: dmeventd improve _handle_request

Let the compiler resolve cmd lookup and leave it to optimize it as it
needs.
---
 daemons/dmeventd/dmeventd.c |   57 ++++++++++++++++++++++---------------------
 1 files changed, 29 insertions(+), 28 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index b4080db..85f1b34 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -1447,34 +1447,35 @@ static int _client_write(struct dm_event_fifos *fifos,
 static int _handle_request(struct dm_event_daemon_message *msg,
 			  struct message_data *message_data)
 {
-	static struct request {
-		unsigned int cmd;
-		int (*f)(struct message_data *);
-	} requests[] = {
-		{ DM_EVENT_CMD_REGISTER_FOR_EVENT, _register_for_event},
-		{ DM_EVENT_CMD_UNREGISTER_FOR_EVENT, _unregister_for_event},
-		{ DM_EVENT_CMD_GET_REGISTERED_DEVICE, _get_registered_device},
-		{ DM_EVENT_CMD_GET_NEXT_REGISTERED_DEVICE,
-			_get_next_registered_device},
-		{ DM_EVENT_CMD_SET_TIMEOUT, _set_timeout},
-		{ DM_EVENT_CMD_GET_TIMEOUT, _get_timeout},
-		{ DM_EVENT_CMD_ACTIVE, _active},
-		{ DM_EVENT_CMD_GET_STATUS, _get_status},
-		/* dmeventd parameters of running dmeventd,
-		 * returns 'pid=<pid> daemon=<no/yes> exec_method=<direct/systemd>'
-		 * 	pid - pidfile of running dmeventd
-		 * 	daemon - running as a daemon or not (foreground)?
-		 * 	exec_method - "direct" if executed directly or
-		 * 		      "systemd" if executed via systemd
-		 */
-		{ DM_EVENT_CMD_GET_PARAMETERS, _get_parameters},
-	}, *req;
-
-	for (req = requests; req < requests + DM_ARRAY_SIZE(requests); ++req)
-		if (req->cmd == msg->cmd)
-			return req->f(message_data);
-
-	return -EINVAL;
+	switch (msg->cmd) {
+	case DM_EVENT_CMD_REGISTER_FOR_EVENT:
+		return _register_for_event(message_data);
+	case DM_EVENT_CMD_UNREGISTER_FOR_EVENT:
+		return _unregister_for_event(message_data);
+	case DM_EVENT_CMD_GET_REGISTERED_DEVICE:
+		return _get_registered_device(message_data);
+	case DM_EVENT_CMD_GET_NEXT_REGISTERED_DEVICE:
+		return _get_next_registered_device(message_data);
+	case DM_EVENT_CMD_SET_TIMEOUT:
+		return _set_timeout(message_data);
+	case DM_EVENT_CMD_GET_TIMEOUT:
+		return _get_timeout(message_data);
+	case DM_EVENT_CMD_ACTIVE:
+		return _active(message_data);
+	case DM_EVENT_CMD_GET_STATUS:
+		return _get_status(message_data);
+	/* dmeventd parameters of running dmeventd,
+	 * returns 'pid=<pid> daemon=<no/yes> exec_method=<direct/systemd>'
+	 * 	pid - pidfile of running dmeventd
+	 * 	daemon - running as a daemon or not (foreground)?
+	 * 	exec_method - "direct" if executed directly or
+	 * 		      "systemd" if executed via systemd
+	 */
+	case DM_EVENT_CMD_GET_PARAMETERS:
+		return _get_parameters(message_data);
+	default:
+		return -EINVAL;
+	}
 }
 
 /* Process a request passed from the communication thread. */


