From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 13 Oct 2015 19:00:56 +0000 (UTC)
Subject: master - dmeventd: compilable without DEBUG CFLAG
Message-ID: <20151013190056.12F0D602FE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ccc39be053b9a186abc6a020f516ff5f425981d6
Commit:        ccc39be053b9a186abc6a020f516ff5f425981d6
Parent:        0cf787a377548394f4588b671c2890ee1a45098b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 13 20:57:59 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 13 20:59:35 2015 +0200

dmeventd: compilable without DEBUG CFLAG

Missed compilability without DEBUG.
---
 daemons/dmeventd/dmeventd.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index ba7d01c..56c504a 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -112,8 +112,6 @@ static int _restart = 0;
 static char **_initial_registrations = 0;
 
 /* FIXME Make configurable at runtime */
-#ifdef DEBUG
-#  define DEBUGLOG  log_debug
 __attribute__((format(printf, 4, 5)))
 static void _dmeventd_log(int level, const char *file, int line,
 			  const char *format, ...)
@@ -124,6 +122,8 @@ static void _dmeventd_log(int level, const char *file, int line,
 	va_end(ap);
 }
 
+#ifdef DEBUG
+#  define DEBUGLOG  log_debug
 static const char *decode_cmd(uint32_t cmd)
 {
 	switch (cmd) {
@@ -1535,8 +1535,9 @@ static void _process_request(struct dm_event_fifos *fifos)
 {
 	int die;
 	struct dm_event_daemon_message msg = { 0 };
+#ifdef DEBUG
 	int cmd;
-
+#endif
 	/*
 	 * Read the request from the client (client_read, client_write
 	 * give true on success and false on failure).
@@ -1544,7 +1545,9 @@ static void _process_request(struct dm_event_fifos *fifos)
 	if (!_client_read(fifos, &msg))
 		return;
 
+#ifdef DEBUG
 	cmd = msg.cmd;
+#endif
 	DEBUGLOG(">>> CMD:%s (0x%x) processing...", decode_cmd(cmd), cmd);
 
 	die = (msg.cmd == DM_EVENT_CMD_DIE) ? 1 : 0;


