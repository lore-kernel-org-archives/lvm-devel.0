From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue,  8 Dec 2015 01:02:32 +0000 (UTC)
Subject: master - dmeventd: Extend checks on client socket.
Message-ID: <20151208010232.B20FC60E8F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=94dab390ef68de3a56b67bce771b48445aa13d09
Commit:        94dab390ef68de3a56b67bce771b48445aa13d09
Parent:        00bab9d9cd8581e905634658a6cda33d998b1b85
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Dec 8 00:54:32 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Dec 8 00:59:39 2015 +0000

dmeventd: Extend checks on client socket.

Reinstate and extend checks removed by e1b111b02accb4145b82b8b47ce57ed93b1a7184.

The code has always assumed that only root has access to the directory
containing the fifos and that they are under the complete control of
dmeventd code.  If anything is found not to be as expected, then open()
should certainly not be attempted!
---
 WHATS_NEW_DM                          |    1 +
 daemons/dmeventd/libdevmapper-event.c |   35 +++++++++++++++++++++++++++++++-
 2 files changed, 34 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 9dd51aa..f6e9d2a 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.114 -
 ====================================
+  Extend validity checks on dmeventd client socket.
 
 Version 1.02.113 - 5th December 2015
 ====================================
diff --git a/daemons/dmeventd/libdevmapper-event.c b/daemons/dmeventd/libdevmapper-event.c
index f1441f5..b49af45 100644
--- a/daemons/dmeventd/libdevmapper-event.c
+++ b/daemons/dmeventd/libdevmapper-event.c
@@ -412,12 +412,41 @@ static int _start_daemon(char *dmeventd_path, struct dm_event_fifos *fifos)
 	char default_dmeventd_path[] = DMEVENTD_PATH;
 	char *args[] = { dmeventd_path ? : default_dmeventd_path, NULL };
 
+	/*
+	 * FIXME Explicitly verify the code's requirement that client_path is secure:
+	 * - All parent directories owned by root without group/other write access unless sticky.
+	 */
+
+	/* If client fifo path exists, only use it if it is root-owned fifo mode 0600 */
+	if ((lstat(fifos->client_path, &statbuf) < 0)) {
+		if (errno == ENOENT)
+			/* Jump ahead if fifo does not already exist. */
+			goto start_server;
+		else {
+			log_sys_error("stat", fifos->client_path);
+			return 0;
+		}
+	} else if (!S_ISFIFO(statbuf.st_mode)) {
+		log_error("%s must be a fifo.", fifos->client_path);
+		return 0;
+	} else if (statbuf.st_uid) {
+		log_error("%s must be owned by uid 0.", fifos->client_path);
+		return 0;
+	} else if (statbuf.st_mode & (S_IEXEC | S_IRWXG | S_IRWXO)) {
+		log_error("%s must have mode 0600.", fifos->client_path);
+		return 0;
+	}
+
 	/* Anyone listening?  If not, errno will be ENXIO */
 	fifos->client = open(fifos->client_path, O_WRONLY | O_NONBLOCK);
 	if (fifos->client >= 0) {
+		/* Should never happen if all the above checks passed. */
 		if ((fstat(fifos->client, &statbuf) < 0) ||
-		    !S_ISFIFO(statbuf.st_mode)) {
-			log_error("%s is not a fifo.", fifos->client_path);
+		    !S_ISFIFO(statbuf.st_mode) || statbuf.st_uid ||
+		    (statbuf.st_mode & (S_IEXEC | S_IRWXG | S_IRWXO))) {
+			log_error("%s is no longer a secure root-owned fifo with mode 0600.", fifos->client_path);
+			if (close(fifos->client))
+				log_sys_debug("close", fifos->client_path);
 			return 0;
 		}
 
@@ -431,6 +460,7 @@ static int _start_daemon(char *dmeventd_path, struct dm_event_fifos *fifos)
 		return 0;
 	}
 
+start_server:
 	/* server is not running */
 
 	if ((args[0][0] == '/') && stat(args[0], &statbuf)) {
@@ -724,6 +754,7 @@ int dm_event_get_registered_device(struct dm_event_handler *dmevh, int next)
 
 	uuid = dm_task_get_uuid(dmt);
 
+	/* FIXME Distinguish errors connecting to daemon */
 	if (_do_event(next ? DM_EVENT_CMD_GET_NEXT_REGISTERED_DEVICE :
 		      DM_EVENT_CMD_GET_REGISTERED_DEVICE, dmevh->dmeventd_path,
 		      &msg, dmevh->dso, uuid, dmevh->mask, 0)) {


