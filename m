From: David Teigland <teigland@fedoraproject.org>
Date: Mon,  9 Nov 2015 18:18:51 +0000 (UTC)
Subject: master - lvmlockd: reverse some unnecessary checking
Message-ID: <20151109181851.B68516036B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d2d5191b788cb75c541d00ffd75d8add3b77a9ad
Commit:        d2d5191b788cb75c541d00ffd75d8add3b77a9ad
Parent:        a0cb92cbb109eb21ef7570058d7b18d5c8ad2e98
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Nov 9 11:50:44 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Nov 9 12:18:43 2015 -0600

lvmlockd: reverse some unnecessary checking

These are unnecessary or not useful.
---
 daemons/lvmlockd/lvmlockd-core.c |   11 ++++-------
 1 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index c39f802..fe24e25 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -3073,7 +3073,7 @@ static int for_each_lockspace(int do_stop, int do_free, int do_force)
 			 */
 			if (done) {
 				if ((perrno = pthread_join(ls->thread, NULL)))
-					log_error("pthread_join error %s", strerror(perrno));
+					log_error("pthread_join error %d", perrno);
 
 				list_del(&ls->list);
 
@@ -3698,8 +3698,7 @@ static int client_send_result(struct client *cl, struct action *act)
 	if (dump_fd >= 0) {
 		/* To avoid deadlock, send data here after the reply. */
 		send_dump_buf(dump_fd, dump_len);
-		if (close(dump_fd))
-			log_error("dump close failed");
+		close(dump_fd);
 	}
 
 	return rv;
@@ -4613,8 +4612,7 @@ static void *client_thread_main(void *arg_in)
 					act_un->mode = LD_LK_UN;
 					act_un->flags |= LD_AF_LV_UNLOCK;
 					act_un->flags &= ~LD_AF_LV_LOCK;
-					if (add_lock_action(act_un) < 0)
-						log_debug("add_lock_action unlock failed");
+					add_lock_action(act_un);
 				}
 			}
 
@@ -4720,8 +4718,7 @@ static void close_client_thread(void)
 	client_stop = 1;
 	pthread_cond_signal(&client_cond);
 	pthread_mutex_unlock(&client_mutex);
-	if (pthread_join(client_thread, NULL))
-		log_error("pthread_join of client thread failed.");
+	pthread_join(client_thread, NULL);
 }
 
 /*


