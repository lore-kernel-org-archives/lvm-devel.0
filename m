From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 13 Oct 2015 14:03:37 +0000 (UTC)
Subject: master - dmeventd: log all commands with CMD: prefix
Message-ID: <20151013140337.B4C7060EDB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=11a084cf42e79f130e4389bac57688cfd6657fc1
Commit:        11a084cf42e79f130e4389bac57688cfd6657fc1
Parent:        d60794c3a3948f5ec5d4c529569ba66d9a635e55
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 13 11:19:59 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 13 14:40:46 2015 +0200

dmeventd: log all commands with CMD: prefix

For easier grep of all processed command - add CMD: prefix to them.

Use  >>>  for entring command processing
and  <<<  when command is processed.
---
 daemons/dmeventd/dmeventd.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 37cf8e9..844b2a6 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -1574,7 +1574,7 @@ static void _process_request(struct dm_event_fifos *fifos)
 		return;
 
 	cmd = msg.cmd;
-	DEBUGLOG("%s (0x%x) processing...", decode_cmd(cmd), cmd);
+	DEBUGLOG(">>> CMD:%s (0x%x) processing...", decode_cmd(cmd), cmd);
 
 	die = (msg.cmd == DM_EVENT_CMD_DIE) ? 1 : 0;
 
@@ -1587,7 +1587,7 @@ static void _process_request(struct dm_event_fifos *fifos)
 
 	dm_free(msg.data);
 
-	DEBUGLOG("%s (0x%x) completed (=%d).", decode_cmd(cmd), cmd, msg.cmd);
+	DEBUGLOG("<<< CMD:%s (0x%x) completed (=%d).", decode_cmd(cmd), cmd, msg.cmd);
 
 	if (die) {
 		if (unlink(DMEVENTD_PIDFILE))


