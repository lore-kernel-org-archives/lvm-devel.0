From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  9 Nov 2015 09:28:03 +0000 (UTC)
Subject: master - dmeventd: reorder tou
Message-ID: <20151109092803.484BD60644@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e1b111b02accb4145b82b8b47ce57ed93b1a7184
Commit:        e1b111b02accb4145b82b8b47ce57ed93b1a7184
Parent:        8b857bfdc60668c3cdeeb6c11ffe32def0371a39
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Nov 7 21:50:27 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 9 10:00:33 2015 +0100

dmeventd: reorder tou

---
 daemons/dmeventd/libdevmapper-event.c |   15 ++++++---------
 1 files changed, 6 insertions(+), 9 deletions(-)

diff --git a/daemons/dmeventd/libdevmapper-event.c b/daemons/dmeventd/libdevmapper-event.c
index 9b3b424..85eab5a 100644
--- a/daemons/dmeventd/libdevmapper-event.c
+++ b/daemons/dmeventd/libdevmapper-event.c
@@ -412,17 +412,15 @@ static int _start_daemon(char *dmeventd_path, struct dm_event_fifos *fifos)
 	char default_dmeventd_path[] = DMEVENTD_PATH;
 	char *args[] = { dmeventd_path ? : default_dmeventd_path, NULL };
 
-	if (stat(fifos->client_path, &statbuf))
-		goto start_server;
-
-	if (!S_ISFIFO(statbuf.st_mode)) {
-		log_error("%s is not a fifo.", fifos->client_path);
-		return 0;
-	}
-
 	/* Anyone listening?  If not, errno will be ENXIO */
 	fifos->client = open(fifos->client_path, O_WRONLY | O_NONBLOCK);
 	if (fifos->client >= 0) {
+		if ((fstat(fifos->client, &statbuf) < 0) ||
+		    !S_ISFIFO(statbuf.st_mode)) {
+			log_error("%s is not a fifo.", fifos->client_path);
+			return 0;
+		}
+
 		/* server is running and listening */
 		if (close(fifos->client))
 			log_sys_debug("close", fifos->client_path);
@@ -433,7 +431,6 @@ static int _start_daemon(char *dmeventd_path, struct dm_event_fifos *fifos)
 		return 0;
 	}
 
-      start_server:
 	/* server is not running */
 
 	if ((args[0][0] == '/') && stat(args[0], &statbuf)) {


