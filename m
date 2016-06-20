From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 20 Jun 2016 19:02:15 +0000 (UTC)
Subject: master - lvmlockd: always try to connect to lvmetad
Message-ID: <20160620190215.534F361487@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=47a29f6b2eb78a71ba6eafa9f47c7519a629155f
Commit:        47a29f6b2eb78a71ba6eafa9f47c7519a629155f
Parent:        b12961e7ebd6fb29d760daafd3c16e4ba3e54e80
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Jun 20 13:47:26 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Jun 20 14:01:46 2016 -0500

lvmlockd: always try to connect to lvmetad

Reconnect to lvmetad if either the send fails (e.g. lvmetad
was restarted since lvmlockd last connected), or if no
lvmetad connection exists (e.g. lvmetad was started after
lvmlockd so no previous connection existed.)
---
 daemons/lvmlockd/lvmlockd-core.c |   32 ++++++++++++++++++--------------
 1 files changed, 18 insertions(+), 14 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index f92ca01..f61939a 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -1013,6 +1013,7 @@ static daemon_reply send_lvmetad(const char *id, ...)
 	daemon_reply reply;
 	va_list ap;
 	int retries = 0;
+	int err;
 
 	va_start(ap, id);
 
@@ -1022,20 +1023,27 @@ static daemon_reply send_lvmetad(const char *id, ...)
 	 */
 	pthread_mutex_lock(&lvmetad_mutex);
 retry:
-	reply = daemon_send_simple_v(lvmetad_handle, id, ap);
-
-	/* lvmetad may have been restarted */
-	if ((reply.error == ECONNRESET) && (retries < 2)) {
-		daemon_close(lvmetad_handle);
-		lvmetad_connected = 0;
-
+	if (!lvmetad_connected) {
 		lvmetad_handle = lvmetad_open(NULL);
 		if (lvmetad_handle.error || lvmetad_handle.socket_fd < 0) {
-			log_error("lvmetad_open reconnect error %d", lvmetad_handle.error);
+			err = lvmetad_handle.error ?: lvmetad_handle.socket_fd;
+			pthread_mutex_unlock(&lvmetad_mutex);
+			log_error("lvmetad_open reconnect error %d", err);
+			memset(&reply, 0, sizeof(reply));
+			reply.error = err;
+			return reply;
 		} else {
 			log_debug("lvmetad reconnected");
 			lvmetad_connected = 1;
 		}
+	}
+
+	reply = daemon_send_simple_v(lvmetad_handle, id, ap);
+
+	/* lvmetad may have been restarted */
+	if ((reply.error == ECONNRESET) && (retries < 2)) {
+		daemon_close(lvmetad_handle);
+		lvmetad_connected = 0;
 		retries++;
 		goto retry;
 	}
@@ -1240,10 +1248,6 @@ static int res_lock(struct lockspace *ls, struct resource *r, struct action *act
 		rv = -EREMOVED;
 	}
 
-	if (!lvmetad_connected && inval_meta)
-		log_debug("S %s R %s res_lock no lvmetad connection to invalidate",
-			  ls->name, r->name);
-
 	/*
 	 * r is vglk: tell lvmetad to set the vg invalid
 	 * flag, and provide the new r_version.  If lvmetad finds
@@ -1259,7 +1263,7 @@ static int res_lock(struct lockspace *ls, struct resource *r, struct action *act
 	 * caches, and tell lvmetad to set global invalid to 0.
 	 */
 
-	if (lvmetad_connected && inval_meta && (r->type == LD_RT_VG)) {
+	if (inval_meta && (r->type == LD_RT_VG)) {
 		daemon_reply reply;
 		char *uuid;
 
@@ -1283,7 +1287,7 @@ static int res_lock(struct lockspace *ls, struct resource *r, struct action *act
 		daemon_reply_destroy(reply);
 	}
 
-	if (lvmetad_connected && inval_meta && (r->type == LD_RT_GL)) {
+	if (inval_meta && (r->type == LD_RT_GL)) {
 		daemon_reply reply;
 
 		log_debug("S %s R %s res_lock set lvmetad global invalid",


