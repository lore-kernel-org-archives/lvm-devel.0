From: David Teigland <teigland@fedoraproject.org>
Date: Thu,  3 Sep 2015 21:48:59 +0000 (UTC)
Subject: master - lvmlockd: fixes for starting dlm global lockspace
Message-ID: <20150903214859.B5885606F5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6240a7639d1473f7e22c8a8099176bc1b444d4d3
Commit:        6240a7639d1473f7e22c8a8099176bc1b444d4d3
Parent:        9e8b3d4a9825ecca3dc7a71f6379b63a27d6fa8c
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Sep 3 16:42:19 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Sep 3 16:47:54 2015 -0500

lvmlockd: fixes for starting dlm global lockspace

Remove the optimization/shortcut for starting the dlm global
lockspace when it was already running.

Reenable automatically starting the dlm global lockspace
when a command attempts to use it and it's not yet started.
This had become disabled at some point.
---
 daemons/lvmlockd/lvmlockd-core.c     |   71 +++++++++++++++++++---------------
 daemons/lvmlockd/lvmlockd-internal.h |    1 -
 2 files changed, 40 insertions(+), 32 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index 36be584..ae6f5a1 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -2404,9 +2404,6 @@ out_act:
 	ls->drop_vg = drop_vg;
 	pthread_mutex_unlock(&lockspaces_mutex);
 
-	if (gl_use_dlm && !strcmp(ls->name, gl_lsname_dlm))
-		dlm_gl_lockspace_running = 0;
-
 	/* worker_thread will join this thread, and free the ls */
 	pthread_mutex_lock(&worker_mutex);
 	worker_wake = 1;
@@ -2592,22 +2589,14 @@ static int add_dlm_global_lockspace(struct action *act)
 {
 	int rv;
 
-	if (dlm_gl_lockspace_running)
-		return -EEXIST;
-	dlm_gl_lockspace_running = 1;
-
 	/*
-	 * There's a short period after which a previous gl lockspace thread
-	 * has set dlm_gl_lockspace_running = 0, but before its ls struct has
-	 * been deleted, during which this add_lockspace_thread() can fail with
-	 * -EAGAIN.
+	 * FIXME: optimize this by setting a flag to indicate that the
+	 * dlm global lockspace is running so we can quit here.
 	 */
 
 	rv = add_lockspace_thread(gl_lsname_dlm, NULL, NULL, LD_LM_DLM, NULL, act);
-	if (rv < 0) {
+	if (rv < 0)
 		log_debug("add_dlm_global_lockspace add_lockspace_thread %d", rv);
-		dlm_gl_lockspace_running = 0;
-	}
 
 	return rv;
 }
@@ -3535,15 +3524,27 @@ static int add_lock_action(struct action *act)
 
 	memset(ls_name, 0, sizeof(ls_name));
 
-	/* Determine which lockspace this action is for, and set ls_name. */
+	/*
+	 * Determine which lockspace this action is for, and set ls_name.
+	 */
 
-	if (act->rt == LD_RT_GL && gl_use_sanlock &&
-	    (act->op == LD_OP_ENABLE || act->op == LD_OP_DISABLE))
-		vg_ls_name(act->vg_name, ls_name);
-	else if (act->rt == LD_RT_GL)
-		gl_ls_name(ls_name);
-	else
+	if (act->rt == LD_RT_GL) {
+		/* Global lock is requested */
+		if (gl_use_sanlock && (act->op == LD_OP_ENABLE || act->op == LD_OP_DISABLE)) {
+			vg_ls_name(act->vg_name, ls_name);
+		} else {
+			if (!gl_use_dlm && !gl_use_sanlock) {
+				if (lm_is_running_dlm())
+					gl_use_dlm = 1;
+				else if (lm_is_running_sanlock())
+					gl_use_sanlock = 1;
+			}
+			gl_ls_name(ls_name);
+		}
+	} else {
+		/* VG lock is requested */
 		vg_ls_name(act->vg_name, ls_name);
+	}
 
  retry:
 	pthread_mutex_lock(&lockspaces_mutex);
@@ -3552,35 +3553,43 @@ static int add_lock_action(struct action *act)
 	pthread_mutex_unlock(&lockspaces_mutex);
 	if (!ls) {
 		if (act->op == LD_OP_UPDATE && act->rt == LD_RT_VG) {
-			log_debug("lockspace not found ignored for vg update");
+			log_debug("lockspace \"%s\" not found ignored for vg update", ls_name);
 			return -ENOLS;
 
 		} else if (act->flags & LD_AF_SEARCH_LS) {
-			/* fail if we've already tried searching for the ls */
-			log_debug("lockspace search repeated %s", ls_name);
+			/*
+			 * Fail if we've already tried searching for the lockspace.
+			 */
+			log_debug("lockspace \"%s\" not found after search", ls_name);
 			return -ENOLS;
 
 		} else if (act->op == LD_OP_LOCK && act->rt == LD_RT_GL && gl_use_sanlock) {
-			/* gl may have been enabled in an existing vg */
-			log_debug("gl lockspace not found check sanlock vgs");
+			/*
+			 * The sanlock global lock may have been enabled in an existing VG,
+			 * so search existing VGs for an enabled global lock.
+			 */
+			log_debug("lockspace \"%s\" not found for sanlock gl, searching...", ls_name);
 			act->flags |= LD_AF_SEARCH_LS;
 			add_work_action(act);
 			return 0;
 
-		} else if (act->op == LD_OP_LOCK && act->rt == LD_RT_GL && gl_use_dlm) {
-			log_debug("gl lockspace not found add dlm global");
+		} else if (act->op == LD_OP_LOCK && act->rt == LD_RT_GL && act->mode != LD_LK_UN && gl_use_dlm) {
+			/*
+			 * Automatically start the dlm global lockspace when
+			 * a command tries to acquire the global lock.
+			 */
+			log_debug("lockspace \"%s\" not found for dlm gl, adding...", ls_name);
 			act->flags |= LD_AF_SEARCH_LS;
 			act->flags |= LD_AF_WAIT_STARTING;
 			add_dlm_global_lockspace(NULL);
-			gl_ls_name(ls_name);
 			goto retry;
 
 		} else if (act->op == LD_OP_LOCK && act->mode == LD_LK_UN) {
-			log_debug("lockspace not found ignored for unlock");
+			log_debug("lockspace \"%s\" not found for unlock ignored", ls_name);
 			return -ENOLS;
 
 		} else {
-			log_debug("lockspace not found %s", ls_name);
+			log_debug("lockspace \"%s\" not found", ls_name);
 			return -ENOLS;
 		}
 	}
diff --git a/daemons/lvmlockd/lvmlockd-internal.h b/daemons/lvmlockd/lvmlockd-internal.h
index 9d360ed..68dcd9d 100644
--- a/daemons/lvmlockd/lvmlockd-internal.h
+++ b/daemons/lvmlockd/lvmlockd-internal.h
@@ -313,7 +313,6 @@ static inline int list_empty(const struct list_head *head)
  * or when disable_gl matches.
  */
 
-EXTERN int dlm_gl_lockspace_running;
 EXTERN int gl_type_static;
 EXTERN int gl_use_dlm;
 EXTERN int gl_use_sanlock;


