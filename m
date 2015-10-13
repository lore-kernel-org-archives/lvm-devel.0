From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 13 Oct 2015 14:03:35 +0000 (UTC)
Subject: master - dmeventd: fix loging report
Message-ID: <20151013140335.95AB160EDB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d60794c3a3948f5ec5d4c529569ba66d9a635e55
Commit:        d60794c3a3948f5ec5d4c529569ba66d9a635e55
Parent:        1b1c01a27b359f8e91c3c9e08684c435d8fd51c2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 9 22:16:33 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 13 14:40:46 2015 +0200

dmeventd: fix loging report

msg.cmd holds return value from processing after _do_process_request,
so save it before call.
---
 daemons/dmeventd/dmeventd.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index ffc941f..37cf8e9 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -1564,6 +1564,7 @@ static void _process_request(struct dm_event_fifos *fifos)
 {
 	int die;
 	struct dm_event_daemon_message msg = { 0 };
+	int cmd;
 
 	/*
 	 * Read the request from the client (client_read, client_write
@@ -1572,7 +1573,8 @@ static void _process_request(struct dm_event_fifos *fifos)
 	if (!_client_read(fifos, &msg))
 		return;
 
-	DEBUGLOG("%s (0x%x) processing...", decode_cmd(msg.cmd), msg.cmd);
+	cmd = msg.cmd;
+	DEBUGLOG("%s (0x%x) processing...", decode_cmd(cmd), cmd);
 
 	die = (msg.cmd == DM_EVENT_CMD_DIE) ? 1 : 0;
 
@@ -1585,7 +1587,7 @@ static void _process_request(struct dm_event_fifos *fifos)
 
 	dm_free(msg.data);
 
-	DEBUGLOG("%s (0x%x) completed.", decode_cmd(msg.cmd), msg.cmd);
+	DEBUGLOG("%s (0x%x) completed (=%d).", decode_cmd(cmd), cmd, msg.cmd);
 
 	if (die) {
 		if (unlink(DMEVENTD_PIDFILE))


