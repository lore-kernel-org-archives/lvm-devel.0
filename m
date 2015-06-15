From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 15 Jun 2015 12:48:37 +0000 (UTC)
Subject: master - dmeventd: better debug
Message-ID: <20150615124837.974C66006F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=edbdbddfb67990048512b6dbd6772fd69ad34f86
Commit:        edbdbddfb67990048512b6dbd6772fd69ad34f86
Parent:        3d5f7f90c882e0f7bfa8cafb87ce3db4ea91e4a0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jun 15 14:35:33 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jun 15 14:46:44 2015 +0200

dmeventd: better debug

Avoid using 'static' variable within threaded environmnent for debuging.
---
 daemons/dmeventd/dmeventd.c |   60 ++++++++++--------------------------------
 1 files changed, 15 insertions(+), 45 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 9fb3af7..fcfa423 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -133,51 +133,20 @@ void debuglog(const char *fmt, ...)
 
 static const char *decode_cmd(uint32_t cmd)
 {
-	static char buf[128];
-	const char *command;
-
 	switch (cmd) {
-	case DM_EVENT_CMD_ACTIVE:
-		command = "ACTIVE";
-		break;
-	case DM_EVENT_CMD_REGISTER_FOR_EVENT:
-		command = "REGISTER_FOR_EVENT";
-		break;
-	case DM_EVENT_CMD_UNREGISTER_FOR_EVENT:
-		command = "UNREGISTER_FOR_EVENT";
-		break;
-	case DM_EVENT_CMD_GET_REGISTERED_DEVICE:
-		command = "GET_REGISTERED_DEVICE";
-		break;
-	case DM_EVENT_CMD_GET_NEXT_REGISTERED_DEVICE:
-		command = "GET_NEXT_REGISTERED_DEVICE";
-		break;
-	case DM_EVENT_CMD_SET_TIMEOUT:
-		command = "SET_TIMEOUT";
-		break;
-	case DM_EVENT_CMD_GET_TIMEOUT:
-		command = "GET_TIMEOUT";
-		break;
-	case DM_EVENT_CMD_HELLO:
-		command = "HELLO";
-		break;
-	case DM_EVENT_CMD_DIE:
-		command = "DIE";
-		break;
-	case DM_EVENT_CMD_GET_STATUS:
-		command = "GET_STATUS";
-		break;
-	case DM_EVENT_CMD_GET_PARAMETERS:
-		command = "GET_PARAMETERS";
-		break;
-	default:
-		command = "unknown";
-		break;
+	case DM_EVENT_CMD_ACTIVE:			return "ACTIVE";
+	case DM_EVENT_CMD_REGISTER_FOR_EVENT:		return "REGISTER_FOR_EVENT";
+	case DM_EVENT_CMD_UNREGISTER_FOR_EVENT:		return "UNREGISTER_FOR_EVENT";
+	case DM_EVENT_CMD_GET_REGISTERED_DEVICE:	return "GET_REGISTERED_DEVICE";
+	case DM_EVENT_CMD_GET_NEXT_REGISTERED_DEVICE:	return "GET_NEXT_REGISTERED_DEVICE";
+	case DM_EVENT_CMD_SET_TIMEOUT:			return "SET_TIMEOUT";
+	case DM_EVENT_CMD_GET_TIMEOUT:			return "GET_TIMEOUT";
+	case DM_EVENT_CMD_HELLO:			return "HELLO";
+	case DM_EVENT_CMD_DIE:				return "DIE";
+	case DM_EVENT_CMD_GET_STATUS:			return "GET_STATUS";
+	case DM_EVENT_CMD_GET_PARAMETERS:		return "GET_PARAMETERS";
+	default:					return "unknown";
 	}
-
-	snprintf(buf, sizeof(buf), "%s (0x%x)", command, cmd);
-
-	return buf;
 }
 
 #else
@@ -1609,7 +1578,8 @@ static void _process_request(struct dm_event_fifos *fifos)
 	if (!_client_read(fifos, &msg))
 		return;
 
-	DEBUGLOG("%s processing...", cmd = decode_cmd(msg.cmd));
+	DEBUGLOG("%s (0x%x) processing...", decode_cmd(msg.cmd), msg.cmd);
+
 	die = (msg.cmd == DM_EVENT_CMD_DIE) ? 1 : 0;
 
 	/* _do_process_request fills in msg (if memory allows for
@@ -1621,7 +1591,7 @@ static void _process_request(struct dm_event_fifos *fifos)
 
 	dm_free(msg.data);
 
-	DEBUGLOG("%s completed.", cmd);
+	DEBUGLOG("%s (0x%x) completed.", decode_cmd(msg.cmd), msg.cmd);
 
 	if (die) {
 		if (unlink(DMEVENTD_PIDFILE))


