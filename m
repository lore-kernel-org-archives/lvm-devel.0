From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 27 Aug 2015 20:31:55 +0000 (UTC)
Subject: master - lvmlockd: remove list of inactive lockspaces
Message-ID: <20150827203155.B062C60758@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e4d5d05119f5df66121134621d564b8c468ed5f1
Commit:        e4d5d05119f5df66121134621d564b8c468ed5f1
Parent:        e3f1b1dccb4db799ccbb054ad15a825e3a3eccba
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Aug 27 15:23:14 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Aug 27 15:23:14 2015 -0500

lvmlockd: remove list of inactive lockspaces

This was only used to return two flags indicating specific
reasons for a lock failure so that a more specific error
message could be printed by the command (lockspace had been
stopped, or lockspace had an error starting.)

Remove the list, given its limited usefulness, the fact it
would easily become inaccurate, and the fact it was causing
misleading error messages.  The error conditions it was meant
to help could be reported differently.
---
 daemons/lvmlockd/lvmlockd-core.c     |  136 ++--------------------------------
 daemons/lvmlockd/lvmlockd-internal.h |    3 -
 lib/locking/lvmlockd.c               |   78 -------------------
 lib/locking/lvmlockd.h               |    2 -
 4 files changed, 8 insertions(+), 211 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index ac2d224..c2c3fef 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -185,18 +185,9 @@ static int restart_fds[2];
  * Each lockspace has its own thread to do locking.
  * The lockspace thread makes synchronous lock requests to dlm/sanlock.
  * Every vg with a lockd type, i.e. "dlm", "sanlock", should be on this list.
- *
- * lockspaces_inactive holds old ls structs for vgs that have been
- * stopped, or for vgs that failed to start.  The old ls structs
- * are removed from the inactive list and freed when a new ls with
- * the same name is started and added to the standard lockspaces list.
- * Keeping this bit of "history" for the ls allows us to return a
- * more informative error message if a vg lock request is made for
- * an ls that has been stopped or failed to start.
  */
 static pthread_mutex_t lockspaces_mutex;
 static struct list_head lockspaces;
-static struct list_head lockspaces_inactive;
 
 /*
  * Client thread reads client requests and writes client results.
@@ -264,7 +255,6 @@ static int alloc_new_structs; /* used for initializing in setup_structs */
 
 static int add_lock_action(struct action *act);
 static int str_to_lm(const char *str);
-static int clear_lockspace_inactive(char *name);
 static int setup_dump_socket(void);
 static void send_dump_buf(int fd, int dump_len);
 static int dump_info(int *dump_len);
@@ -737,8 +727,6 @@ static const char *op_str(int x)
 		return "running_lm";
 	case LD_OP_FIND_FREE_LOCK:
 		return "find_free_lock";
-	case LD_OP_FORGET_VG_NAME:
-		return "forget_vg_name";
 	case LD_OP_KILL_VG:
 		return "kill_vg";
 	case LD_OP_DROP_VG:
@@ -2009,13 +1997,6 @@ static int other_sanlock_vgs_exist(struct lockspace *ls_rem)
 {
 	struct lockspace *ls;
 
-	list_for_each_entry(ls, &lockspaces_inactive, list) {
-		if (ls->lm_type != LD_LM_SANLOCK)
-			continue;
-		log_debug("other sanlock vg exists inactive %s", ls->name);
-		return 1;
-	}
-
 	list_for_each_entry(ls, &lockspaces, list) {
 		if (ls->lm_type != LD_LM_SANLOCK)
 			continue;
@@ -2422,10 +2403,7 @@ out_act:
 	ls->drop_vg = drop_vg;
 	pthread_mutex_unlock(&lockspaces_mutex);
 
-	/*
-	 * worker_thread will join this thread, and free the
-	 * ls or move it to lockspaces_inactive.
-	 */
+	/* worker_thread will join this thread, and free the ls */
 	pthread_mutex_lock(&worker_mutex);
 	worker_wake = 1;
 	pthread_cond_signal(&worker_cond);
@@ -2580,8 +2558,6 @@ static int add_lockspace_thread(const char *ls_name,
 	if (act)
 		list_add(&act->list, &ls->actions);
 
-	clear_lockspace_inactive(ls->name);
-
 	list_add_tail(&ls->list, &lockspaces);
 	pthread_mutex_unlock(&lockspaces_mutex);
 
@@ -2826,65 +2802,6 @@ static int count_lockspace_starting(uint32_t client_id)
 	return count;
 }
 
-/* lockspaces_mutex is held */
-static struct lockspace *find_lockspace_inactive(char *ls_name)
-{
-	struct lockspace *ls;
-
-	list_for_each_entry(ls, &lockspaces_inactive, list) {
-		if (!strcmp(ls->name, ls_name))
-			return ls;
-	}
-
-	return NULL;
-}
-
-/* lockspaces_mutex is held */
-static int clear_lockspace_inactive(char *ls_name)
-{
-	struct lockspace *ls;
-
-	ls = find_lockspace_inactive(ls_name);
-	if (ls) {
-		list_del(&ls->list);
-		free(ls);
-		return 1;
-	}
-
-	return 0;
-}
-
-static int forget_lockspace_inactive(char *vg_name)
-{
-	char ls_name[MAX_NAME+1];
-	int found;
-
-	memset(ls_name, 0, sizeof(ls_name));
-	vg_ls_name(vg_name, ls_name);
-
-	log_debug("forget_lockspace_inactive %s", ls_name);
-
-	pthread_mutex_lock(&lockspaces_mutex);
-	found = clear_lockspace_inactive(ls_name);
-	pthread_mutex_unlock(&lockspaces_mutex);
-
-	if (found)
-		return 0;
-	return -ENOENT;
-}
-
-static void free_lockspaces_inactive(void)
-{
-	struct lockspace *ls, *safe;
-
-	pthread_mutex_lock(&lockspaces_mutex);
-	list_for_each_entry_safe(ls, safe, &lockspaces_inactive, list) {
-		list_del(&ls->list);
-		free(ls);
-	}
-	pthread_mutex_unlock(&lockspaces_mutex);
-}
-
 /*
  * Loop through all lockspaces, and:
  * - if do_stop is set, stop any that are not stopped
@@ -2958,15 +2875,14 @@ static int for_each_lockspace(int do_stop, int do_free, int do_force)
 				pthread_join(ls->thread, NULL);
 				list_del(&ls->list);
 
+				/* FIXME: will free_vg ever not be set? */
 
-				/* In future we may need to free ls->actions here */
-				free_ls_resources(ls);
-
-				if (ls->free_vg)
+				if (ls->free_vg) {
+					/* In future we may need to free ls->actions here */
+					free_ls_resources(ls);
 					free(ls);
-				else
-					list_add(&ls->list, &lockspaces_inactive);
-				free_count++;
+					free_count++;
+				}
 			} else {
 				need_free++;
 			}
@@ -3486,12 +3402,6 @@ static void client_send_result(struct client *cl, struct action *act)
 	if (act->flags & LD_AF_DUP_GL_LS)
 		strcat(result_flags, "DUP_GL_LS,");
 
-	if (act->flags & LD_AF_INACTIVE_LS)
-		strcat(result_flags, "INACTIVE_LS,");
-
-	if (act->flags & LD_AF_ADD_LS_ERROR)
-		strcat(result_flags, "ADD_LS_ERROR,");
-
 	if (act->flags & LD_AF_WARN_GL_REMOVED)
 		strcat(result_flags, "WARN_GL_REMOVED,");
 	
@@ -3635,19 +3545,8 @@ static int add_lock_action(struct action *act)
 	pthread_mutex_lock(&lockspaces_mutex);
 	if (ls_name[0])
 		ls = find_lockspace_name(ls_name);
+	pthread_mutex_unlock(&lockspaces_mutex);
 	if (!ls) {
-		int ls_inactive = 0;
-		int ls_create_fail = 0;
-
-		if (ls_name[0])
-			ls = find_lockspace_inactive(ls_name);
-		if (ls) {
-			ls_inactive = 1;
-			ls_create_fail = ls->create_fail;
-			ls = NULL;
-		}
-		pthread_mutex_unlock(&lockspaces_mutex);
-
 		if (act->op == LD_OP_UPDATE && act->rt == LD_RT_VG) {
 			log_debug("lockspace not found ignored for vg update");
 			return -ENOLS;
@@ -3676,14 +3575,6 @@ static int add_lock_action(struct action *act)
 			log_debug("lockspace not found ignored for unlock");
 			return -ENOLS;
 
-		} else if (act->op == LD_OP_LOCK && act->rt == LD_RT_VG && ls_inactive) {
-			/* ls has been stopped or previously failed to start */
-			log_debug("lockspace inactive create_fail %d %s",
-				  ls_create_fail, ls_name);
-			act->flags |= LD_AF_INACTIVE_LS;
-			if (ls_create_fail)
-				act->flags |= LD_AF_ADD_LS_ERROR;
-			return -ENOLS;
 		} else {
 			log_debug("lockspace not found %s", ls_name);
 			return -ENOLS;
@@ -3853,11 +3744,6 @@ static int str_to_op_rt(const char *req_name, int *op, int *rt)
 		*rt = LD_RT_VG;
 		return 0;
 	}
-	if (!strcmp(req_name, "forget_vg_name")) {
-		*op = LD_OP_FORGET_VG_NAME;
-		*rt = LD_RT_VG;
-		return 0;
-	}
 	if (!strcmp(req_name, "kill_vg")) {
 		*op = LD_OP_KILL_VG;
 		*rt = LD_RT_VG;
@@ -4437,10 +4323,6 @@ static void client_recv_action(struct client *cl)
 	case LD_OP_DROP_VG:
 		rv = add_lock_action(act);
 		break;
-	case LD_OP_FORGET_VG_NAME:
-		act->result = forget_lockspace_inactive(act->vg_name);
-		add_client_result(act);
-		break;
 	default:
 		rv = -EINVAL;
 	};
@@ -5619,7 +5501,6 @@ static int main_loop(daemon_state *ds_arg)
 	strcpy(gl_lsname_dlm, S_NAME_GL_DLM);
 
 	INIT_LIST_HEAD(&lockspaces);
-	INIT_LIST_HEAD(&lockspaces_inactive);
 	pthread_mutex_init(&lockspaces_mutex, NULL);
 	pthread_mutex_init(&pollfd_mutex, NULL);
 	pthread_mutex_init(&log_mutex, NULL);
@@ -5759,7 +5640,6 @@ static int main_loop(daemon_state *ds_arg)
 	}
 
 	for_each_lockspace_retry(DO_STOP, DO_FREE, DO_FORCE);
-	free_lockspaces_inactive();
 	close_worker_thread();
 	close_client_thread();
 	closelog();
diff --git a/daemons/lvmlockd/lvmlockd-internal.h b/daemons/lvmlockd/lvmlockd-internal.h
index 46ae67f..efb04f9 100644
--- a/daemons/lvmlockd/lvmlockd-internal.h
+++ b/daemons/lvmlockd/lvmlockd-internal.h
@@ -50,7 +50,6 @@ enum {
 	LD_OP_RENAME_FINAL,
 	LD_OP_RUNNING_LM,
 	LD_OP_FIND_FREE_LOCK,
-	LD_OP_FORGET_VG_NAME,
 	LD_OP_KILL_VG,
 	LD_OP_DROP_VG,
 };
@@ -101,8 +100,6 @@ struct client {
 #define LD_AF_SEARCH_LS            0x00000200
 #define LD_AF_WAIT_STARTING        0x00001000
 #define LD_AF_DUP_GL_LS            0x00002000
-#define LD_AF_INACTIVE_LS          0x00004000
-#define LD_AF_ADD_LS_ERROR         0x00008000
 #define LD_AF_ADOPT                0x00010000
 #define LD_AF_WARN_GL_REMOVED	   0x00020000
 
diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index 394657c..f3e2e2c 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -118,12 +118,6 @@ static void _flags_str_to_lockd_flags(const char *flags_str, uint32_t *lockd_fla
 	if (strstr(flags_str, "DUP_GL_LS"))
 		*lockd_flags |= LD_RF_DUP_GL_LS;
 
-	if (strstr(flags_str, "INACTIVE_LS"))
-		*lockd_flags |= LD_RF_INACTIVE_LS;
-
-	if (strstr(flags_str, "ADD_LS_ERROR"))
-		*lockd_flags |= LD_RF_ADD_LS_ERROR;
-
 	if (strstr(flags_str, "WARN_GL_REMOVED"))
 		*lockd_flags |= LD_RF_WARN_GL_REMOVED;
 }
@@ -825,37 +819,6 @@ static int _free_vg_sanlock(struct cmd_context *cmd, struct volume_group *vg)
 	return ret;
 }
 
-/*
- * Tell lvmlockd to forget about an old VG name.
- * lvmlockd remembers previous lockd VGs so that it can provide more
- * informative error messages (see INACTIVE_LS, ADD_LS_ERROR).
- *
- * If a new local VG is created with the same name as a previous lockd VG,
- * lvmlockd's memory of the previous lockd VG interferes (causes incorrect
- * lockd_vg failures).
- *
- * We could also remove the list of inactive (old) VG names from lvmlockd,
- * and then this function would not be needed, but this would also reduce
- * the ability to have helpful error messages.
- */
-
-static void _forget_vg_name(struct cmd_context *cmd, struct volume_group *vg)
-{
-	daemon_reply reply;
-
-	if (!_use_lvmlockd)
-		return;
-	if (!_lvmlockd_connected)
-		return;
-
-	reply = _lockd_send("forget_vg_name",
-				"pid = %d", getpid(),
-				"vg_name = %s", vg->name,
-				NULL);
-
-	daemon_reply_destroy(reply);
-}
-
 /* vgcreate */
 
 int lockd_init_vg(struct cmd_context *cmd, struct volume_group *vg,
@@ -863,7 +826,6 @@ int lockd_init_vg(struct cmd_context *cmd, struct volume_group *vg,
 {
 	switch (get_lock_type_from_string(lock_type)) {
 	case LOCK_TYPE_NONE:
-		_forget_vg_name(cmd, vg);
 		return 1;
 	case LOCK_TYPE_CLVM:
 		return 1;
@@ -1841,46 +1803,6 @@ int lockd_vg(struct cmd_context *cmd, const char *vg_name, const char *def_mode,
 	}
 
 	/*
-	 * An unused/previous lockspace for the VG was found.
-	 * This means it must be a lockd VG, not local.  The
-	 * lockspace needs to be started to be used.
-	 */
-	if ((result == -ENOLS) && (lockd_flags & LD_RF_INACTIVE_LS)) {
-		if (!strcmp(mode, "un")) {
-			ret = 1;
-			goto out;
-		} else if (!strcmp(mode, "sh")) {
-			log_warn("VG %s lock skipped: lockspace is inactive", vg_name);
-			ret = 1;
-			goto out;
-		} else {
-			log_error("VG %s lock failed: lockspace is inactive", vg_name);
-			ret = 0;
-			goto out;
-		}
-	}
-
-	/*
-	 * An unused lockspace for the VG was found.  The previous
-	 * start of the lockspace failed, so we can print a more useful
-	 * error message.
-	 */
-	if ((result == -ENOLS) && (lockd_flags & LD_RF_ADD_LS_ERROR)) {
-		if (!strcmp(mode, "un")) {
-			ret = 1;
-			goto out;
-		} else if (!strcmp(mode, "sh")) {
-			log_warn("VG %s lock skipped: lockspace start error", vg_name);
-			ret = 1;
-			goto out;
-		} else {
-			log_error("VG %s lock failed: lockspace start error", vg_name);
-			ret = 0;
-			goto out;
-		}
-	}
-
-	/*
 	 * No lockspace for the VG was found.  It may be a local
 	 * VG that lvmlockd doesn't keep track of, or it may be
 	 * a lockd VG that lvmlockd doesn't yet know about (it hasn't
diff --git a/lib/locking/lvmlockd.h b/lib/locking/lvmlockd.h
index 4bec782..51c2905 100644
--- a/lib/locking/lvmlockd.h
+++ b/lib/locking/lvmlockd.h
@@ -28,8 +28,6 @@
 #define LD_RF_NO_GL_LS          0x00000002
 #define LD_RF_WARN_GL_REMOVED   0x00000004
 #define LD_RF_DUP_GL_LS         0x00000008
-#define LD_RF_INACTIVE_LS       0x00000010
-#define LD_RF_ADD_LS_ERROR      0x00000020
 
 /* lockd_state flags */
 #define LDST_EX			0x00000001


