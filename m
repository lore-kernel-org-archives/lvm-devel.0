From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 10 Dec 2015 16:51:45 +0000 (UTC)
Subject: master - lvmlockd: reconnect to lvmetad if it's restarted
Message-ID: <20151210165145.EBC8B60D87@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=dcb26b5f136ad861356d5c118921a254cae2cab4
Commit:        dcb26b5f136ad861356d5c118921a254cae2cab4
Parent:        bdba4e7a931f1e77f9c7cf6837a6c8b33b35a099
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Dec 10 10:50:19 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Dec 10 10:50:19 2015 -0600

lvmlockd: reconnect to lvmetad if it's restarted

If lvmetad is restarted after lvmlockd has connected
to it, then lvmlockd should reconnect.
---
 daemons/lvmlockd/lvmlockd-core.c |   80 ++++++++++++++++++++++++-------------
 1 files changed, 52 insertions(+), 28 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index fe24e25..e495d3b 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -1020,6 +1020,43 @@ static void add_work_action(struct action *act)
 	pthread_mutex_unlock(&worker_mutex);
 }
 
+static daemon_reply send_lvmetad(const char *id, ...)
+{
+	daemon_reply reply;
+	va_list ap;
+	int retries = 0;
+
+	va_start(ap, id);
+
+	/*
+	 * mutex is used because all threads share a single
+	 * lvmetad connection/handle.
+	 */
+	pthread_mutex_lock(&lvmetad_mutex);
+retry:
+	reply = daemon_send_simple_v(lvmetad_handle, id, ap);
+
+	/* lvmetad may have been restarted */
+	if ((reply.error == ECONNRESET) && (retries < 2)) {
+		daemon_close(lvmetad_handle);
+		lvmetad_connected = 0;
+
+		lvmetad_handle = lvmetad_open(NULL);
+		if (lvmetad_handle.error || lvmetad_handle.socket_fd < 0) {
+			log_error("lvmetad_open reconnect error %d", lvmetad_handle.error);
+		} else {
+			log_debug("lvmetad reconnected");
+			lvmetad_connected = 1;
+		}
+		retries++;
+		goto retry;
+	}
+	pthread_mutex_unlock(&lvmetad_mutex);
+
+	va_end(ap);
+	return reply;
+}
+
 static int res_lock(struct lockspace *ls, struct resource *r, struct action *act, int *retry)
 {
 	struct lock *lk;
@@ -1246,14 +1283,12 @@ static int res_lock(struct lockspace *ls, struct resource *r, struct action *act
 		else
 			uuid = ls->vg_uuid;
 
-		pthread_mutex_lock(&lvmetad_mutex);
-		reply = daemon_send_simple(lvmetad_handle, "set_vg_info",
-					   "token = %s", "skip",
-					   "uuid = %s", uuid,
-					   "name = %s", ls->vg_name,
-					   "version = " FMTd64, (int64_t)new_version,
-					   NULL);
-			pthread_mutex_unlock(&lvmetad_mutex);
+		reply = send_lvmetad("set_vg_info",
+				     "token = %s", "skip",
+				     "uuid = %s", uuid,
+				     "name = %s", ls->vg_name,
+				     "version = " FMTd64, (int64_t)new_version,
+				     NULL);
 
 		if (reply.error || strcmp(daemon_reply_str(reply, "response", ""), "OK"))
 			log_error("set_vg_info in lvmetad failed %d", reply.error);
@@ -1266,12 +1301,10 @@ static int res_lock(struct lockspace *ls, struct resource *r, struct action *act
 		log_debug("S %s R %s res_lock set lvmetad global invalid",
 			  ls->name, r->name);
 
-		pthread_mutex_lock(&lvmetad_mutex);
-		reply = daemon_send_simple(lvmetad_handle, "set_global_info",
-						   "token = %s", "skip",
-						   "global_invalid = " FMTd64, INT64_C(1),
-						   NULL);
-		pthread_mutex_unlock(&lvmetad_mutex);
+		reply = send_lvmetad("set_global_info",
+				     "token = %s", "skip",
+				     "global_invalid = " FMTd64, INT64_C(1),
+				     NULL);
 
 		if (reply.error || strcmp(daemon_reply_str(reply, "response", ""), "OK"))
 			log_error("set_global_info in lvmetad failed %d", reply.error);
@@ -4747,15 +4780,11 @@ static int get_lockd_vgs(struct list_head *vg_lockd)
 	const char *lock_type;
 	const char *lock_args;
 	char find_str_path[PATH_MAX];
-	int mutex_unlocked = 0;
 	int rv = 0;
 
 	INIT_LIST_HEAD(&update_vgs);
 
-	pthread_mutex_lock(&lvmetad_mutex);
-	reply = daemon_send_simple(lvmetad_handle, "vg_list",
-				   "token = %s", "skip",
-				   NULL);
+	reply = send_lvmetad("vg_list", "token = %s", "skip", NULL);
 
 	if (reply.error || strcmp(daemon_reply_str(reply, "response", ""), "OK")) {
 		log_error("vg_list from lvmetad failed %d", reply.error);
@@ -4792,10 +4821,10 @@ static int get_lockd_vgs(struct list_head *vg_lockd)
 	/* get vg_name and lock_type for each vg uuid entry in update_vgs */
 
 	list_for_each_entry(ls, &update_vgs, list) {
-		reply = daemon_send_simple(lvmetad_handle, "vg_lookup",
-					   "token = %s", "skip",
-					   "uuid = %s", ls->vg_uuid,
-					   NULL);
+		reply = send_lvmetad("vg_lookup",
+				     "token = %s", "skip",
+				     "uuid = %s", ls->vg_uuid,
+				     NULL);
 
 		if (reply.error || strcmp(daemon_reply_str(reply, "response", ""), "OK")) {
 			log_error("vg_lookup from lvmetad failed %d", reply.error);
@@ -4884,8 +4913,6 @@ static int get_lockd_vgs(struct list_head *vg_lockd)
 		if (rv < 0)
 			break;
 	}
-	pthread_mutex_unlock(&lvmetad_mutex);
-	mutex_unlocked = 1;
 out:
 	/* Return lockd VG's on the vg_lockd list. */
 
@@ -4898,9 +4925,6 @@ out:
 			free(ls);
 	}
 
-	if (!mutex_unlocked)
-		pthread_mutex_unlock(&lvmetad_mutex);
-
 	return rv;
 }
 


