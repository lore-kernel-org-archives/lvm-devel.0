From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 25 Aug 2017 08:24:48 -0400
Subject: master - lvmlockd: log pthread_join errno code
Message-ID: <201708251224.v7PCOm8n005069@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d79d9193298b04246c18dcacd8b372518eb10ffc
Commit:        d79d9193298b04246c18dcacd8b372518eb10ffc
Parent:        da9a8fdedc25645706ae198bad098f366351db58
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Aug 25 11:52:09 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Aug 25 14:20:59 2017 +0200

lvmlockd: log pthread_join errno code

Log possible errno with pthread_join (and one close() instance).
---
 daemons/lvmlockd/lvmlockd-core.c |   15 ++++++++++++---
 1 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index 253d86b..903da7c 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -3539,11 +3539,15 @@ static int setup_worker_thread(void)
 
 static void close_worker_thread(void)
 {
+	int perrno;
+
 	pthread_mutex_lock(&worker_mutex);
 	worker_stop = 1;
 	pthread_cond_signal(&worker_cond);
 	pthread_mutex_unlock(&worker_mutex);
-	pthread_join(worker_thread, NULL);
+
+	if ((perrno = pthread_join(worker_thread, NULL)))
+		log_error("pthread_join worker_thread error %d", perrno);
 }
 
 /* client_mutex is locked */
@@ -3769,7 +3773,8 @@ static int client_send_result(struct client *cl, struct action *act)
 	if (dump_fd >= 0) {
 		/* To avoid deadlock, send data here after the reply. */
 		send_dump_buf(dump_fd, dump_len);
-		close(dump_fd);
+		if (close(dump_fd))
+			log_error("failed to close dump socket %d", dump_fd);
 	}
 
 	return rv;
@@ -4786,11 +4791,15 @@ static int setup_client_thread(void)
 
 static void close_client_thread(void)
 {
+	int perrno;
+
 	pthread_mutex_lock(&client_mutex);
 	client_stop = 1;
 	pthread_cond_signal(&client_cond);
 	pthread_mutex_unlock(&client_mutex);
-	pthread_join(client_thread, NULL);
+
+	if ((perrno = pthread_join(client_thread, NULL)))
+		log_error("pthread_join client_thread error %d", perrno);
 }
 
 /*


