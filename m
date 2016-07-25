From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 25 Jul 2016 19:49:32 +0000 (UTC)
Subject: master - lvmlockd: improve error message about missing global lock
Message-ID: <20160725194932.C4A9460ED3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d0e15b86b53bd4960a7c15a7771548ab4aface8b
Commit:        d0e15b86b53bd4960a7c15a7771548ab4aface8b
Parent:        1efb1c23432f504db685c4ff9f2c08a5ba74e68f
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Jul 25 14:45:11 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Jul 25 14:49:01 2016 -0500

lvmlockd: improve error message about missing global lock

If the VG holding the global lock is removed, we can indicate
that as the reason for not being able to acquire the global
lock in subsequent error messages, and can suggest enabling
the global lock in another VG.  (This helpful error message
will go away if the global lock is enabled in another VG,
or if lvmlockd is restarted.)
---
 daemons/lvmlockd/lvmlockd-core.c     |    9 +++++++--
 daemons/lvmlockd/lvmlockd-internal.h |    1 +
 lib/locking/lvmlockd.c               |   17 ++++++++++++++++-
 3 files changed, 24 insertions(+), 3 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index b561529..8fcbdec 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -1654,6 +1654,9 @@ static int res_able(struct lockspace *ls, struct resource *r,
 	}
 
 	rv = lm_able_gl_sanlock(ls, act->op == LD_OP_ENABLE);
+
+	if (!rv && (act->op == LD_OP_ENABLE))
+		gl_vg_removed = 0;
 out:
 	return rv;
 }
@@ -2627,8 +2630,10 @@ out_act:
 
 	if (free_vg && ls->sanlock_gl_enabled && act_op_free) {
 		pthread_mutex_lock(&lockspaces_mutex);
-		if (other_sanlock_vgs_exist(ls))
+		if (other_sanlock_vgs_exist(ls)) {
 			act_op_free->flags |= LD_AF_WARN_GL_REMOVED;
+			gl_vg_removed = 1;
+		}
 		pthread_mutex_unlock(&lockspaces_mutex);
 	}
 
@@ -3668,7 +3673,7 @@ static int client_send_result(struct client *cl, struct action *act)
 	if (act->flags & LD_AF_DUP_GL_LS)
 		strcat(result_flags, "DUP_GL_LS,");
 
-	if (act->flags & LD_AF_WARN_GL_REMOVED)
+	if ((act->flags & LD_AF_WARN_GL_REMOVED) || gl_vg_removed)
 		strcat(result_flags, "WARN_GL_REMOVED,");
 	
 	if (act->op == LD_OP_INIT) {
diff --git a/daemons/lvmlockd/lvmlockd-internal.h b/daemons/lvmlockd/lvmlockd-internal.h
index 2e21981..a2280b8 100644
--- a/daemons/lvmlockd/lvmlockd-internal.h
+++ b/daemons/lvmlockd/lvmlockd-internal.h
@@ -320,6 +320,7 @@ static inline int list_empty(const struct list_head *head)
 EXTERN int gl_type_static;
 EXTERN int gl_use_dlm;
 EXTERN int gl_use_sanlock;
+EXTERN int gl_vg_removed;
 EXTERN char gl_lsname_dlm[MAX_NAME+1];
 EXTERN char gl_lsname_sanlock[MAX_NAME+1];
 EXTERN int global_dlm_lockspace_exists;
diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index 03d0014..8acf69c 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -969,6 +969,7 @@ int lockd_start_vg(struct cmd_context *cmd, struct volume_group *vg, int start_i
 {
 	char uuid[64] __attribute__((aligned(8)));
 	daemon_reply reply;
+	uint32_t lockd_flags = 0;
 	int host_id = 0;
 	int result;
 	int ret;
@@ -1018,13 +1019,16 @@ int lockd_start_vg(struct cmd_context *cmd, struct volume_group *vg, int start_i
 				"opts = %s", start_init ? "start_init" : "none",
 				NULL);
 
-	if (!_lockd_result(reply, &result, NULL)) {
+	if (!_lockd_result(reply, &result, &lockd_flags)) {
 		ret = 0;
 		result = -ELOCKD;
 	} else {
 		ret = (result < 0) ? 0 : 1;
 	}
 
+	if (lockd_flags & LD_RF_WARN_GL_REMOVED)
+		cmd->lockd_gl_removed = 1;
+
 	switch (result) {
 	case 0:
 		log_print_unless_silent("VG %s starting %s lockspace", vg->name, vg->lock_type);
@@ -1140,6 +1144,11 @@ int lockd_start_wait(struct cmd_context *cmd)
 
 	daemon_reply_destroy(reply);
 
+	if (cmd->lockd_gl_removed) {
+		log_error("Missing global lock: global lock was lost by removing a previous VG.");
+		log_error("To enable the global lock in another VG, see lvmlockctl --gl-enable.");
+	}
+
 	return ret;
 }
 
@@ -1556,6 +1565,12 @@ int lockd_gl(struct cmd_context *cmd, const char *def_mode, uint32_t flags)
 			goto allow;
 		}
 
+		if ((lockd_flags & LD_RF_NO_GL_LS) && (lockd_flags & LD_RF_WARN_GL_REMOVED)) {
+			log_warn("Skipping global lock: VG with global lock was removed");
+			force_cache_update = 1;
+			goto allow;
+		}
+
 		if ((lockd_flags & LD_RF_NO_GL_LS) || (lockd_flags & LD_RF_NO_LOCKSPACES)) {
 			log_warn("Skipping global lock: lockspace not found or started");
 			force_cache_update = 1;


