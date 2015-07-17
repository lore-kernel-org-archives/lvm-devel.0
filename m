From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 17 Jul 2015 16:16:32 +0000 (UTC)
Subject: master - lvmlockd: improve errors when lvm is built without a lock manager
Message-ID: <20150717161632.D0064606F3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=85b42d7c9551993f2d9cb48bb84e555ba0af5197
Commit:        85b42d7c9551993f2d9cb48bb84e555ba0af5197
Parent:        c7fc06a262bacb6355485edebc5f7b7037471106
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jul 16 16:28:57 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jul 17 11:16:18 2015 -0500

lvmlockd: improve errors when lvm is built without a lock manager

When lvmlockd is compiled without support for one of the
lock managers (sanlock or dlm), and a command tries to use
one of them, explain that in the error message.
---
 daemons/lvmlockd/lvmlockd-core.c     |   21 +++++++++++++++++----
 daemons/lvmlockd/lvmlockd-internal.h |   20 ++++++++++++++++++++
 lib/locking/lvmlockd.c               |   13 ++++++++++++-
 3 files changed, 49 insertions(+), 5 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index 19d96f0..a01c8a6 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -4167,9 +4167,9 @@ static void client_recv_action(struct client *cl)
 		strncpy(cl->name, cl_name, MAX_NAME);
 
 	if (!gl_use_dlm && !gl_use_sanlock && (lm > 0)) {
-		if (lm == LD_LM_DLM)
+		if (lm == LD_LM_DLM && lm_support_dlm())
 			gl_use_dlm = 1;
-		else if (lm == LD_LM_SANLOCK)
+		else if (lm == LD_LM_SANLOCK && lm_support_sanlock())
 			gl_use_sanlock = 1;
 
 		log_debug("set gl_use_%s", lm_str(lm));
@@ -4233,6 +4233,18 @@ static void client_recv_action(struct client *cl)
 		  cl->name[0] ? cl->name : "client", cl->pid, cl->id,
 		  op_str(act->op), rt_str(act->rt), act->vg_name, mode_str(act->mode), opts);
 
+	if (lm == LD_LM_DLM && !lm_support_dlm()) {
+		log_debug("dlm not supported");
+		rv = -EPROTONOSUPPORT;
+		goto out;
+	}
+
+	if (lm == LD_LM_SANLOCK && !lm_support_sanlock()) {
+		log_debug("sanlock not supported");
+		rv = -EPROTONOSUPPORT;
+		goto out;
+	}
+
 	switch (act->op) {
 	case LD_OP_START:
 		rv = add_lockspace(act);
@@ -4265,6 +4277,7 @@ static void client_recv_action(struct client *cl)
 		rv = -EINVAL;
 	};
 
+out:
 	if (rv < 0) {
 		act->result = rv;
 		add_client_result(act);
@@ -5685,9 +5698,9 @@ int main(int argc, char *argv[])
 			break;
 		case 'g':
 			lm = str_to_lm(optarg);
-			if (lm == LD_LM_DLM)
+			if (lm == LD_LM_DLM && lm_support_dlm())
 				gl_use_dlm = 1;
-			else if (lm == LD_LM_SANLOCK)
+			else if (lm == LD_LM_SANLOCK && lm_support_sanlock())
 				gl_use_sanlock = 1;
 			else {
 				fprintf(stderr, "invalid gl-type option");
diff --git a/daemons/lvmlockd/lvmlockd-internal.h b/daemons/lvmlockd/lvmlockd-internal.h
index e9b6277..1fd7125 100644
--- a/daemons/lvmlockd/lvmlockd-internal.h
+++ b/daemons/lvmlockd/lvmlockd-internal.h
@@ -350,6 +350,11 @@ int lm_get_lockspaces_dlm(struct list_head *ls_rejoin);
 int lm_data_size_dlm(void);
 int lm_is_running_dlm(void);
 
+static inline int lm_support_dlm(void)
+{
+	return 1;
+}
+
 #else
 
 static inline int lm_init_vg_dlm(char *ls_name, char *vg_name, uint32_t flags, char *vg_args)
@@ -410,6 +415,11 @@ static inline int lm_is_running_dlm(void)
 	return 0;
 }
 
+static inline int lm_support_dlm(void)
+{
+	return 0;
+}
+
 #endif /* dlm support */
 
 #ifdef LOCKDSANLOCK_SUPPORT
@@ -437,6 +447,11 @@ int lm_data_size_sanlock(void);
 int lm_is_running_sanlock(void);
 int lm_find_free_lock_sanlock(struct lockspace *ls, uint64_t *free_offset);
 
+static inline int lm_support_sanlock(void)
+{
+	return 1;
+}
+
 #else
 
 static inline int lm_init_vg_sanlock(char *ls_name, char *vg_name, uint32_t flags, char *vg_args)
@@ -537,6 +552,11 @@ static inline int lm_find_free_lock_sanlock(struct lockspace *ls, uint64_t *free
 	return -1;
 }
 
+static inline int lm_support_sanlock(void)
+{
+	return 0;
+}
+
 #endif /* sanlock support */
 
 #endif	/* _LVM_LVMLOCKD_INTERNAL_H */
diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index a0dff8a..ac8c155 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -522,6 +522,9 @@ static int _init_vg_dlm(struct cmd_context *cmd, struct volume_group *vg)
 	case -EMANAGER:
 		log_error("VG %s init failed: lock manager dlm is not running", vg->name);
 		break;
+	case -EPROTONOSUPPORT:
+		log_error("VG %s init failed: lock manager dlm is not supported by lvmlockd", vg->name);
+		break;
 	default:
 		log_error("VG %s init failed: %d", vg->name, result);
 	}
@@ -624,6 +627,9 @@ static int _init_vg_sanlock(struct cmd_context *cmd, struct volume_group *vg)
 	case -EMANAGER:
 		log_error("VG %s init failed: lock manager sanlock is not running", vg->name);
 		break;
+	case -EPROTONOSUPPORT:
+		log_error("VG %s init failed: lock manager sanlock is not supported by lvmlockd", vg->name);
+		break;
 	case -EMSGSIZE:
 		log_error("VG %s init failed: no disk space for leases", vg->name);
 		break;
@@ -952,6 +958,9 @@ int lockd_start_vg(struct cmd_context *cmd, struct volume_group *vg)
 	case -EMANAGER:
 		log_error("VG %s start failed: lock manager %s is not running", vg->name, vg->lock_type);
 		break;
+	case -EPROTONOSUPPORT:
+		log_error("VG %s start failed: lock manager %s is not supported by lvmlockd", vg->name, vg->lock_type);
+		break;
 	default:
 		log_error("VG %s start failed: %d", vg->name, result);
 	}
@@ -1233,8 +1242,10 @@ int lockd_gl_create(struct cmd_context *cmd, const char *def_mode, const char *v
 	if (result < 0) {
 		if (result == -ESTARTING)
 			log_error("Global lock failed: lockspace is starting.");
-		else if (result -EAGAIN)
+		else if (result == -EAGAIN)
 			log_error("Global lock failed: held by other host.");
+		else if (result == -EPROTONOSUPPORT)
+			log_error("VG create failed: lock manager %s is not supported by lvmlockd.", vg_lock_type);
 		else
 			log_error("Global lock failed: error %d", result);
 		return 0;


