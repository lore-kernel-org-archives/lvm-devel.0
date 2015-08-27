From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 27 Aug 2015 21:02:52 +0000 (UTC)
Subject: master - lvmlockd: fix starting dlm global lockspace
Message-ID: <20150827210252.4537260DA5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3c1924c9c0d45cbce67aa3c1dad70737a6956cc3
Commit:        3c1924c9c0d45cbce67aa3c1dad70737a6956cc3
Parent:        e4d5d05119f5df66121134621d564b8c468ed5f1
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Aug 27 16:00:24 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Aug 27 16:00:24 2015 -0500

lvmlockd: fix starting dlm global lockspace

lvmlockd would fail to recognize that the global lockspace
failed to start if the dlm wasn't running, so future attempts
to start the dlm global lockspace would do nothing, thinking
it was already running.
---
 daemons/lvmlockd/lvmlockd-core.c     |   13 ++++++++-----
 daemons/lvmlockd/lvmlockd-dlm.c      |    4 ----
 daemons/lvmlockd/lvmlockd-internal.h |    2 +-
 3 files changed, 9 insertions(+), 10 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index c2c3fef..14705b0 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -2403,6 +2403,9 @@ out_act:
 	ls->drop_vg = drop_vg;
 	pthread_mutex_unlock(&lockspaces_mutex);
 
+	if (gl_use_dlm && !strcmp(ls->name, gl_lsname_dlm))
+		dlm_gl_lockspace_running = 0;
+
 	/* worker_thread will join this thread, and free the ls */
 	pthread_mutex_lock(&worker_mutex);
 	worker_wake = 1;
@@ -2584,21 +2587,21 @@ static int add_dlm_global_lockspace(struct action *act)
 {
 	int rv;
 
-	if (gl_running_dlm)
+	if (dlm_gl_lockspace_running)
 		return -EEXIST;
-	gl_running_dlm = 1;
+	dlm_gl_lockspace_running = 1;
 
 	/*
 	 * There's a short period after which a previous gl lockspace thread
-	 * has set gl_running_dlm = 0, but before its ls struct has been
-	 * deleted, during which this add_lockspace_thread() can fail with
+	 * has set dlm_gl_lockspace_running = 0, but before its ls struct has
+	 * been deleted, during which this add_lockspace_thread() can fail with
 	 * -EAGAIN.
 	 */
 
 	rv = add_lockspace_thread(gl_lsname_dlm, NULL, NULL, LD_LM_DLM, NULL, act);
 	if (rv < 0) {
 		log_error("add_dlm_global_lockspace add_lockspace_thread %d", rv);
-		gl_running_dlm = 0;
+		dlm_gl_lockspace_running = 0;
 	}
 
 	return rv;
diff --git a/daemons/lvmlockd/lvmlockd-dlm.c b/daemons/lvmlockd/lvmlockd-dlm.c
index 676c944..6640821 100644
--- a/daemons/lvmlockd/lvmlockd-dlm.c
+++ b/daemons/lvmlockd/lvmlockd-dlm.c
@@ -260,10 +260,6 @@ int lm_rem_lockspace_dlm(struct lockspace *ls, int free_vg)
  out:
 	free(lmd);
 	ls->lm_data = NULL;
-
-	if (!strcmp(ls->name, gl_lsname_dlm))
-		gl_running_dlm = 0;
-
 	return 0;
 }
 
diff --git a/daemons/lvmlockd/lvmlockd-internal.h b/daemons/lvmlockd/lvmlockd-internal.h
index efb04f9..9d360ed 100644
--- a/daemons/lvmlockd/lvmlockd-internal.h
+++ b/daemons/lvmlockd/lvmlockd-internal.h
@@ -313,7 +313,7 @@ static inline int list_empty(const struct list_head *head)
  * or when disable_gl matches.
  */
 
-EXTERN int gl_running_dlm;
+EXTERN int dlm_gl_lockspace_running;
 EXTERN int gl_type_static;
 EXTERN int gl_use_dlm;
 EXTERN int gl_use_sanlock;


