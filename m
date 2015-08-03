From: David Teigland <teigland@fedoraproject.org>
Date: Mon,  3 Aug 2015 15:23:19 +0000 (UTC)
Subject: master - lvmlockd: automatically remove the dlm global lockspace
Message-ID: <20150803152319.A5AE560F48@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d11f8d42287025ff8584b9d6f1d5e70a0d78371b
Commit:        d11f8d42287025ff8584b9d6f1d5e70a0d78371b
Parent:        71dbe47619794ed673a892f533c348a472411195
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jul 31 16:45:43 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Aug 3 10:23:01 2015 -0500

lvmlockd: automatically remove the dlm global lockspace

The dlm global lockspace is automatically added when the
first dlm VG lockspace is added.  Reverse this by removing
the dlm global lockspace after the last dlm VG lockspace
is removed.  (Remove old non-working code that did this
based on an old command that could explicitly add/remove
the dlm global lockspace.)
---
 daemons/lvmlockd/lvmlockd-core.c     |   47 ++++++++-------------------------
 daemons/lvmlockd/lvmlockd-dlm.c      |    4 +--
 daemons/lvmlockd/lvmlockd-internal.h |    4 +--
 3 files changed, 14 insertions(+), 41 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index b299050..2f470f5 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -2506,18 +2506,8 @@ static int add_dlm_global_lockspace(struct action *act)
 
 	if (gl_running_dlm)
 		return -EEXIST;
-
 	gl_running_dlm = 1;
 
-	/* Keep track of whether we automatically added
-	   the global ls, so we know to automatically
-	   remove it. */
-
-	if (act)
-		gl_auto_dlm = 0;
-	else
-		gl_auto_dlm = 1;
-
 	/*
 	 * There's a short period after which a previous gl lockspace thread
 	 * has set gl_running_dlm = 0, but before its ls struct has been
@@ -2526,11 +2516,9 @@ static int add_dlm_global_lockspace(struct action *act)
 	 */
 
 	rv = add_lockspace_thread(gl_lsname_dlm, NULL, NULL, LD_LM_DLM, NULL, act);
-
 	if (rv < 0) {
 		log_error("add_dlm_global_lockspace add_lockspace_thread %d", rv);
 		gl_running_dlm = 0;
-		gl_auto_dlm = 0;
 	}
 
 	return rv;
@@ -2583,28 +2571,12 @@ out:
 }
 
 /*
- * When the first dlm lockspace is added for a vg,
- * automatically add a separate dlm lockspace for the
- * global lock if it hasn't been done explicitly.
- * This is to make the dlm global lockspace work similarly to
- * the sanlock global lockspace, which is "automatic" by
- * nature of being one of the vg lockspaces.
+ * When the first dlm lockspace is added for a vg, automatically add a separate
+ * dlm lockspace for the global lock.
  *
- * For sanlock, a separate lockspace is not used for
- * the global lock, but the gl lock lives in a vg
- * lockspace, (although it's recommended to create a
+ * For sanlock, a separate lockspace is not used for the global lock, but the
+ * gl lock lives in a vg lockspace, (although it's recommended to create a
  * special vg dedicated to holding the gl).
- *
- * N.B. for dlm, if this is an add+WAIT action for a vg
- * lockspace, and this triggered the automatic addition
- * of the global lockspace, then the action may complete
- * for the vg ls add, while the gl ls add is still in
- * progress.  If the caller wants to ensure that the
- * gl ls add is complete, they should explicitly add+WAIT
- * the gl ls.
- *
- * If this function returns and error, the caller
- * will queue the act with that error for the client.
  */
 
 static int add_lockspace(struct action *act)
@@ -2614,6 +2586,11 @@ static int add_lockspace(struct action *act)
 
 	memset(ls_name, 0, sizeof(ls_name));
 
+	/*
+	 * FIXME: I don't think this is used any more.
+	 * Remove it, or add the ability to start the global
+	 * dlm lockspace using lvmlockctl?
+	 */
 	if (act->rt == LD_RT_GL) {
 		if (gl_use_dlm) {
 			rv = add_dlm_global_lockspace(act);
@@ -2697,13 +2674,13 @@ static int rem_lockspace(struct action *act)
 	pthread_mutex_unlock(&lockspaces_mutex);
 
 	/*
-	 * If the dlm global lockspace was automatically added when
-	 * the first dlm vg lockspace was added, then reverse that
+	 * The dlm global lockspace was automatically added when
+	 * the first dlm vg lockspace was added, now reverse that
 	 * by automatically removing the dlm global lockspace when
 	 * the last dlm vg lockspace is removed.
 	 */
 
-	if (rt == LD_RT_VG && gl_use_dlm && gl_auto_dlm)
+	if (rt == LD_RT_VG && gl_use_dlm)
 		rem_dlm_global_lockspace();
 
 	return 0;
diff --git a/daemons/lvmlockd/lvmlockd-dlm.c b/daemons/lvmlockd/lvmlockd-dlm.c
index eaa2657..f1b060a 100644
--- a/daemons/lvmlockd/lvmlockd-dlm.c
+++ b/daemons/lvmlockd/lvmlockd-dlm.c
@@ -247,10 +247,8 @@ int lm_rem_lockspace_dlm(struct lockspace *ls, int free_vg)
 	free(lmd);
 	ls->lm_data = NULL;
 
-	if (!strcmp(ls->name, gl_lsname_dlm)) {
+	if (!strcmp(ls->name, gl_lsname_dlm))
 		gl_running_dlm = 0;
-		gl_auto_dlm = 0;
-	}
 
 	return 0;
 }
diff --git a/daemons/lvmlockd/lvmlockd-internal.h b/daemons/lvmlockd/lvmlockd-internal.h
index 1ecb5dc..78ae88d 100644
--- a/daemons/lvmlockd/lvmlockd-internal.h
+++ b/daemons/lvmlockd/lvmlockd-internal.h
@@ -307,6 +307,7 @@ static inline int list_empty(const struct list_head *head)
  * or when disable_gl matches.
  */
 
+EXTERN int gl_running_dlm;
 EXTERN int gl_type_static;
 EXTERN int gl_use_dlm;
 EXTERN int gl_use_sanlock;
@@ -315,9 +316,6 @@ EXTERN pthread_mutex_t gl_type_mutex;
 EXTERN char gl_lsname_dlm[MAX_NAME+1];
 EXTERN char gl_lsname_sanlock[MAX_NAME+1];
 
-EXTERN int gl_running_dlm;
-EXTERN int gl_auto_dlm;
-
 EXTERN int daemon_test; /* run as much as possible without a live lock manager */
 EXTERN int daemon_debug;
 EXTERN int daemon_host_id;


