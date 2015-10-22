From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 22 Oct 2015 21:34:13 +0000 (UTC)
Subject: master - cleanup: easier to read code
Message-ID: <20151022213413.0E0306057E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8be60e6a65baf87b12862e07d24bd794608df2f2
Commit:        8be60e6a65baf87b12862e07d24bd794608df2f2
Parent:        39cffa4e9b027162430ea7f3c288256b232a1ed7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 22 10:57:57 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 22 22:46:10 2015 +0200

cleanup: easier to read code

Avoid using #ifdef code and use 'cmd' instead of 'die'.
---
 daemons/dmeventd/dmeventd.c |   14 ++++----------
 1 files changed, 4 insertions(+), 10 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 606ef30..9662c0e 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -1590,11 +1590,8 @@ static int _do_process_request(struct dm_event_daemon_message *msg)
 /* Only one caller at a time. */
 static void _process_request(struct dm_event_fifos *fifos)
 {
-	int die;
 	struct dm_event_daemon_message msg = { 0 };
-#ifdef DEBUG
 	int cmd;
-#endif
 	/*
 	 * Read the request from the client (client_read, client_write
 	 * give true on success and false on failure).
@@ -1602,12 +1599,9 @@ static void _process_request(struct dm_event_fifos *fifos)
 	if (!_client_read(fifos, &msg))
 		return;
 
-#ifdef DEBUG
 	cmd = msg.cmd;
-#endif
-	DEBUGLOG(">>> CMD:%s (0x%x) processing...", decode_cmd(cmd), cmd);
 
-	die = (msg.cmd == DM_EVENT_CMD_DIE) ? 1 : 0;
+	DEBUGLOG(">>> CMD:%s (0x%x) processing...", decode_cmd(cmd), cmd);
 
 	/* _do_process_request fills in msg (if memory allows for
 	   data, otherwise just cmd and size = 0) */
@@ -1616,11 +1610,11 @@ static void _process_request(struct dm_event_fifos *fifos)
 	if (!_client_write(fifos, &msg))
 		stack;
 
-	dm_free(msg.data);
+	DEBUGLOG("<<< CMD:%s (0x%x) completed (result %d).", decode_cmd(cmd), cmd, msg.cmd);
 
-	DEBUGLOG("<<< CMD:%s (0x%x) completed (=%d).", decode_cmd(cmd), cmd, msg.cmd);
+	dm_free(msg.data);
 
-	if (die) {
+	if (cmd == DM_EVENT_CMD_DIE) {
 		if (unlink(DMEVENTD_PIDFILE))
 			log_sys_error("unlink", DMEVENTD_PIDFILE);
 		_exit(0);


