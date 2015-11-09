From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  9 Nov 2015 16:05:57 +0000 (UTC)
Subject: master - lvmlockd: add missing error checks
Message-ID: <20151109160557.2DCBE60D27@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d6767d753f19cc4bb94f50e19ef22a591ebe280e
Commit:        d6767d753f19cc4bb94f50e19ef22a591ebe280e
Parent:        c2d5cfbdb8529305a7dbde3652b7963fed1e3b59
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 9 16:38:14 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 9 17:04:10 2015 +0100

lvmlockd: add missing error checks

Detect error from function and report them.
---
 daemons/lvmlockd/lvmlockd-core.c |   14 ++++++++++----
 1 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index 49f408b..b4be116 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -3029,6 +3029,7 @@ static int for_each_lockspace(int do_stop, int do_free, int do_force)
 	int free_count = 0;
 	int done;
 	int stop;
+	int perrno;
 
 	pthread_mutex_lock(&lockspaces_mutex);
 
@@ -3071,7 +3072,9 @@ static int for_each_lockspace(int do_stop, int do_free, int do_force)
 			 * thread touches the ls struct under lockspaces_mutex.
 			 */
 			if (done) {
-				pthread_join(ls->thread, NULL);
+				if ((perrno = pthread_join(ls->thread, NULL)))
+					log_error("pthread_join error %s", strerror(perrno));
+
 				list_del(&ls->list);
 
 				/* FIXME: will free_vg ever not be set? */
@@ -3690,7 +3693,8 @@ static int client_send_result(struct client *cl, struct action *act)
 	if (dump_fd >= 0) {
 		/* To avoid deadlock, send data here after the reply. */
 		send_dump_buf(dump_fd, dump_len);
-		close(dump_fd);
+		if (close(dump_fd))
+			log_error("dump close failed");
 	}
 
 	return rv;
@@ -4604,7 +4608,8 @@ static void *client_thread_main(void *arg_in)
 					act_un->mode = LD_LK_UN;
 					act_un->flags |= LD_AF_LV_UNLOCK;
 					act_un->flags &= ~LD_AF_LV_LOCK;
-					add_lock_action(act_un);
+					if (add_lock_action(act_un) < 0)
+						log_debug("add_lock_action unlock failed");
 				}
 			}
 
@@ -4710,7 +4715,8 @@ static void close_client_thread(void)
 	client_stop = 1;
 	pthread_cond_signal(&client_cond);
 	pthread_mutex_unlock(&client_mutex);
-	pthread_join(client_thread, NULL);
+	if (pthread_join(client_thread, NULL))
+		log_error("pthread_join of client thread failed.");
 }
 
 /*


