From: David Teigland <teigland@sourceware.org>
Date: Fri, 18 May 2018 17:01:59 -0400
Subject: master - lvmlockd: suppress error messages related to lvmetad
Message-ID: <201805182101.w4IL1xCB007156@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a9f2c1e1f568d7fc7ffba7ec702b584f34f678c6
Commit:        a9f2c1e1f568d7fc7ffba7ec702b584f34f678c6
Parent:        bc275bcddf3fac6ea691e2dfda0ca3531c4b3c0c
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri May 18 16:00:54 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri May 18 16:00:54 2018 -0500

lvmlockd: suppress error messages related to lvmetad

Log lvmetad related messages as debug, not as errors,
when using lvmlockd without lvmetad.
---
 daemons/lvmlockd/lvmlockd-core.c |   38 +++++++++++++++++++++++++++++---------
 1 files changed, 29 insertions(+), 9 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index df6e214..861fb4a 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -1009,6 +1009,8 @@ static void add_work_action(struct action *act)
 	pthread_mutex_unlock(&worker_mutex);
 }
 
+#define ERR_LVMETAD_NOT_RUNNING -200
+
 static daemon_reply send_lvmetad(const char *id, ...)
 {
 	daemon_reply reply;
@@ -1029,9 +1031,9 @@ retry:
 		if (lvmetad_handle.error || lvmetad_handle.socket_fd < 0) {
 			err = lvmetad_handle.error ?: lvmetad_handle.socket_fd;
 			pthread_mutex_unlock(&lvmetad_mutex);
-			log_error("lvmetad_open reconnect error %d", err);
+			log_debug("lvmetad_open reconnect error %d", err);
 			memset(&reply, 0, sizeof(reply));
-			reply.error = err;
+			reply.error = ERR_LVMETAD_NOT_RUNNING;
 			va_end(ap);
 			return reply;
 		} else {
@@ -1265,6 +1267,15 @@ static int res_lock(struct lockspace *ls, struct resource *r, struct action *act
 	 * caches, and tell lvmetad to set global invalid to 0.
 	 */
 
+	/*
+	 * lvmetad not running:
+	 * Even if we have not previously found lvmetad running,
+	 * we attempt to connect and invalidate in case it has
+	 * been started while lvmlockd is running.  We don't
+	 * want to allow lvmetad to be used with invalid data if
+	 * it happens to be enabled and started after lvmlockd.
+	 */
+
 	if (inval_meta && (r->type == LD_RT_VG)) {
 		daemon_reply reply;
 		char *uuid;
@@ -1284,8 +1295,10 @@ static int res_lock(struct lockspace *ls, struct resource *r, struct action *act
 				     "version = " FMTd64, (int64_t)new_version,
 				     NULL);
 
-		if (reply.error || strcmp(daemon_reply_str(reply, "response", ""), "OK"))
-			log_error("set_vg_info in lvmetad failed %d", reply.error);
+		if (reply.error || strcmp(daemon_reply_str(reply, "response", ""), "OK")) {
+			if (reply.error != ERR_LVMETAD_NOT_RUNNING)
+				log_error("set_vg_info in lvmetad failed %d", reply.error);
+		}
 		daemon_reply_destroy(reply);
 	}
 
@@ -1300,8 +1313,10 @@ static int res_lock(struct lockspace *ls, struct resource *r, struct action *act
 				     "global_invalid = " FMTd64, INT64_C(1),
 				     NULL);
 
-		if (reply.error || strcmp(daemon_reply_str(reply, "response", ""), "OK"))
-			log_error("set_global_info in lvmetad failed %d", reply.error);
+		if (reply.error || strcmp(daemon_reply_str(reply, "response", ""), "OK")) {
+			if (reply.error != ERR_LVMETAD_NOT_RUNNING)
+				log_error("set_global_info in lvmetad failed %d", reply.error);
+		}
 		daemon_reply_destroy(reply);
 	}
 
@@ -5848,7 +5863,7 @@ static int main_loop(daemon_state *ds_arg)
 	pthread_mutex_init(&lvmetad_mutex, NULL);
 	lvmetad_handle = lvmetad_open(NULL);
 	if (lvmetad_handle.error || lvmetad_handle.socket_fd < 0)
-		log_error("lvmetad_open error %d", lvmetad_handle.error);
+		log_debug("lvmetad_open error %d", lvmetad_handle.error);
 	else
 		lvmetad_connected = 1;
 
@@ -5856,8 +5871,13 @@ static int main_loop(daemon_state *ds_arg)
 	 * Attempt to rejoin lockspaces and adopt locks from a previous
 	 * instance of lvmlockd that left behind lockspaces/locks.
 	 */
-	if (adopt_opt)
-		adopt_locks();
+	if (adopt_opt) {
+		/* FIXME: implement this without lvmetad */
+		if (!lvmetad_connected)
+			log_error("Cannot adopt locks without lvmetad running.");
+		else
+			adopt_locks();
+	}
 
 	while (1) {
 		rv = poll(pollfd, pollfd_maxi + 1, -1);


