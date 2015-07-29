From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 29 Jul 2015 19:49:14 +0000 (UTC)
Subject: master - vgremove: warn when removing sanlock global lock
Message-ID: <20150729194914.9E61460DD7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9aabf441bdb8480f2e99722955fedcb4a19d760d
Commit:        9aabf441bdb8480f2e99722955fedcb4a19d760d
Parent:        772b54a08bae19f59d93ca456691e3ce3cbb00da
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Jul 27 14:51:43 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jul 29 14:27:32 2015 -0500

vgremove: warn when removing sanlock global lock

When the sanlock VG holding the global lock is removed,
print a warning indicating that the global needs to be
enabled in another sanlock VG.
---
 daemons/lvmlockd/lvmlockd-core.c     |   58 +++++++++++++++++++++++++++++++---
 daemons/lvmlockd/lvmlockd-internal.h |    2 +
 lib/locking/lvmlockd.c               |   12 +++++--
 lib/locking/lvmlockd.h               |    2 +-
 4 files changed, 64 insertions(+), 10 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index 1361569..dc0d3e7 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -1966,6 +1966,30 @@ static void free_ls_resources(struct lockspace *ls)
 }
 
 /*
+ * ls is the vg being removed that holds the global lock.
+ * check if any other vgs will be left without a global lock.
+ */
+
+static int other_sanlock_vgs_exist(struct lockspace *ls_rem)
+{
+	struct lockspace *ls;
+
+	list_for_each_entry(ls, &lockspaces_inactive, list) {
+		log_debug("other sanlock vg exists inactive %s", ls->name);
+		return 1;
+	}
+
+	list_for_each_entry(ls, &lockspaces, list) {
+		if (!strcmp(ls->name, ls_rem->name))
+			continue;
+		log_debug("other sanlock vg exists %s", ls->name);
+		return 1;
+	}
+
+	return 0;
+}
+
+/*
  * Process actions queued for this lockspace by
  * client_recv_action / add_lock_action.
  *
@@ -1981,6 +2005,7 @@ static void *lockspace_thread_main(void *arg_in)
 	struct lockspace *ls = arg_in;
 	struct resource *r, *r2;
 	struct action *add_act, *act, *safe;
+	struct action *act_op_free = NULL;
 	struct list_head tmp_act;
 	struct list_head act_close;
 	int free_vg = 0;
@@ -2253,9 +2278,10 @@ out_act:
 
 	pthread_mutex_lock(&ls->mutex);
 	list_for_each_entry_safe(act, safe, &ls->actions, list) {
-		if (act->op == LD_OP_FREE)
+		if (act->op == LD_OP_FREE) {
+			act_op_free = act;
 			act->result = 0;
-		else if (act->op == LD_OP_STOP)
+		} else if (act->op == LD_OP_STOP)
 			act->result = 0;
 		else if (act->op == LD_OP_RENAME_BEFORE)
 			act->result = 0;
@@ -2266,6 +2292,19 @@ out_act:
 	}
 	pthread_mutex_unlock(&ls->mutex);
 
+	/*
+	 * If this freed a sanlock vg that had gl enabled, and other sanlock
+	 * vgs exist, return a flag so the command can warn that the gl has
+	 * been removed and may need to be enabled in another sanlock vg.
+	 */
+
+	if (free_vg && ls->sanlock_gl_enabled && act_op_free) {
+		pthread_mutex_lock(&lockspaces_mutex);
+		if (other_sanlock_vgs_exist(ls))
+			act_op_free->flags |= LD_AF_WARN_GL_REMOVED;
+		pthread_mutex_unlock(&lockspaces_mutex);
+	}
+
 	pthread_mutex_lock(&client_mutex);
 	list_for_each_entry_safe(act, safe, &tmp_act, list) {
 		list_del(&act->list);
@@ -2276,11 +2315,12 @@ out_act:
 
 	pthread_mutex_lock(&lockspaces_mutex);
 	ls->thread_done = 1;
+	ls->free_vg = free_vg;
 	pthread_mutex_unlock(&lockspaces_mutex);
 
 	/*
-	 * worker_thread will join this thread, and move the
-	 * ls struct from lockspaces list to lockspaces_inactive.
+	 * worker_thread will join this thread, and free the
+	 * ls or move it to lockspaces_inactive.
 	 */
 	pthread_mutex_lock(&worker_mutex);
 	worker_wake = 1;
@@ -2837,9 +2877,14 @@ static int for_each_lockspace(int do_stop, int do_free, int do_force)
 				pthread_join(ls->thread, NULL);
 				list_del(&ls->list);
 
+
 				/* In future we may need to free ls->actions here */
 				free_ls_resources(ls);
-				list_add(&ls->list, &lockspaces_inactive);
+
+				if (ls->free_vg)
+					free(ls);
+				else
+					list_add(&ls->list, &lockspaces_inactive);
 				free_count++;
 			} else {
 				need_free++;
@@ -3363,6 +3408,9 @@ static void client_send_result(struct client *cl, struct action *act)
 
 	if (act->flags & LD_AF_ADD_LS_ERROR)
 		strcat(result_flags, "ADD_LS_ERROR,");
+
+	if (act->flags & LD_AF_WARN_GL_REMOVED)
+		strcat(result_flags, "WARN_GL_REMOVED,");
 	
 	if (act->op == LD_OP_INIT) {
 		/*
diff --git a/daemons/lvmlockd/lvmlockd-internal.h b/daemons/lvmlockd/lvmlockd-internal.h
index 7bbddb4..1ecb5dc 100644
--- a/daemons/lvmlockd/lvmlockd-internal.h
+++ b/daemons/lvmlockd/lvmlockd-internal.h
@@ -101,6 +101,7 @@ struct client {
 #define LD_AF_INACTIVE_LS          0x00004000
 #define LD_AF_ADD_LS_ERROR         0x00008000
 #define LD_AF_ADOPT                0x00010000
+#define LD_AF_WARN_GL_REMOVED	   0x00020000
 
 /*
  * Number of times to repeat a lock request after
@@ -182,6 +183,7 @@ struct lockspace {
 	unsigned int thread_done : 1;
 	unsigned int sanlock_gl_enabled: 1;
 	unsigned int sanlock_gl_dup: 1;
+	unsigned int free_vg: 1;
 
 	struct list_head actions;	/* new client actions */
 	struct list_head resources;	/* resource/lock state for gl/vg/lv */
diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index 84eb861..66c6615 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -115,9 +115,6 @@ static void _flags_str_to_lockd_flags(const char *flags_str, uint32_t *lockd_fla
 	if (strstr(flags_str, "NO_GL_LS"))
 		*lockd_flags |= LD_RF_NO_GL_LS;
 
-	if (strstr(flags_str, "LOCAL_LS"))
-		*lockd_flags |= LD_RF_LOCAL_LS;
-
 	if (strstr(flags_str, "DUP_GL_LS"))
 		*lockd_flags |= LD_RF_DUP_GL_LS;
 
@@ -126,6 +123,9 @@ static void _flags_str_to_lockd_flags(const char *flags_str, uint32_t *lockd_fla
 
 	if (strstr(flags_str, "ADD_LS_ERROR"))
 		*lockd_flags |= LD_RF_ADD_LS_ERROR;
+
+	if (strstr(flags_str, "WARN_GL_REMOVED"))
+		*lockd_flags |= LD_RF_WARN_GL_REMOVED;
 }
 
 /*
@@ -722,6 +722,7 @@ static int _free_vg_dlm(struct cmd_context *cmd, struct volume_group *vg)
 static int _free_vg_sanlock(struct cmd_context *cmd, struct volume_group *vg)
 {
 	daemon_reply reply;
+	uint32_t lockd_flags = 0;
 	int result;
 	int ret;
 
@@ -743,7 +744,7 @@ static int _free_vg_sanlock(struct cmd_context *cmd, struct volume_group *vg)
 				"vg_lock_args = %s", vg->lock_args,
 				NULL);
 
-	if (!_lockd_result(reply, &result, NULL)) {
+	if (!_lockd_result(reply, &result, &lockd_flags)) {
 		ret = 0;
 	} else {
 		ret = (result < 0) ? 0 : 1;
@@ -764,6 +765,9 @@ static int _free_vg_sanlock(struct cmd_context *cmd, struct volume_group *vg)
 		goto out;
 	}
 
+	if (lockd_flags & LD_RF_WARN_GL_REMOVED)
+		log_warn("VG %s held the sanlock global lock, enable global lock in another VG.", vg->name);
+
 	/*
 	 * The usleep delay gives sanlock time to close the lock lv,
 	 * and usually avoids having an annoying error printed.
diff --git a/lib/locking/lvmlockd.h b/lib/locking/lvmlockd.h
index ffd6a99..f141635 100644
--- a/lib/locking/lvmlockd.h
+++ b/lib/locking/lvmlockd.h
@@ -27,7 +27,7 @@
 /* lvmlockd result flags */
 #define LD_RF_NO_LOCKSPACES     0x00000001
 #define LD_RF_NO_GL_LS          0x00000002
-#define LD_RF_LOCAL_LS          0x00000004
+#define LD_RF_WARN_GL_REMOVED   0x00000004
 #define LD_RF_DUP_GL_LS         0x00000008
 #define LD_RF_INACTIVE_LS       0x00000010
 #define LD_RF_ADD_LS_ERROR      0x00000020


