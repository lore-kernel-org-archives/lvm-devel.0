From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 11 Sep 2015 18:24:53 +0000 (UTC)
Subject: master - lvmlockd: optimize dlm global lockspace creation
Message-ID: <20150911182453.C35B86017F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=18dfbbb150e04026e4c11822e5f80f79da691d08
Commit:        18dfbbb150e04026e4c11822e5f80f79da691d08
Parent:        0a26c20b88ab5fe7894a2e2207fd492aaca41095
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Sep 10 10:31:25 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Sep 11 13:20:01 2015 -0500

lvmlockd: optimize dlm global lockspace creation

Set a flag indicating that the dlm global lockspace
exists to avoid going through the entire process of
trying to add it before finding it exists.
---
 daemons/lvmlockd/lvmlockd-core.c     |   18 ++++++++++++++++--
 daemons/lvmlockd/lvmlockd-internal.h |    3 +--
 2 files changed, 17 insertions(+), 4 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index 0b0161a..8f89181 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -2546,6 +2546,8 @@ out_act:
 	ls->thread_done = 1;
 	ls->free_vg = free_vg;
 	ls->drop_vg = drop_vg;
+	if (ls->lm_type == LD_LM_DLM && !strcmp(ls->name, gl_lsname_dlm))
+		global_dlm_lockspace_exists = 0;
 	pthread_mutex_unlock(&lockspaces_mutex);
 
 	/* worker_thread will join this thread, and free the ls */
@@ -2702,6 +2704,8 @@ static int add_lockspace_thread(const char *ls_name,
 	if (act)
 		list_add(&act->list, &ls->actions);
 
+	if (ls->lm_type == LD_LM_DLM && !strcmp(ls->name, gl_lsname_dlm))
+		global_dlm_lockspace_exists = 1;
 	list_add_tail(&ls->list, &lockspaces);
 	pthread_mutex_unlock(&lockspaces_mutex);
 
@@ -2729,15 +2733,25 @@ static int add_dlm_global_lockspace(struct action *act)
 {
 	int rv;
 
+	if (global_dlm_lockspace_exists)
+		return 0;
+
 	/*
-	 * FIXME: optimize this by setting a flag to indicate that the
-	 * dlm global lockspace is running so we can quit here.
+	 * FIXME: if the dlm global lockspace is started without a global
+	 * lock request, insert an internal gl sh lock request?
 	 */
 
 	rv = add_lockspace_thread(gl_lsname_dlm, NULL, NULL, LD_LM_DLM, NULL, act);
 	if (rv < 0)
 		log_debug("add_dlm_global_lockspace add_lockspace_thread %d", rv);
 
+	/*
+	 * EAGAIN may be returned for a short period because
+	 * global_dlm_lockspace_exists is set to 0 before the
+	 * ls is removed from the lockspaces list by the
+	 * worker_thread.
+	 */
+
 	return rv;
 }
 
diff --git a/daemons/lvmlockd/lvmlockd-internal.h b/daemons/lvmlockd/lvmlockd-internal.h
index 6bdd4c7..55ac460 100644
--- a/daemons/lvmlockd/lvmlockd-internal.h
+++ b/daemons/lvmlockd/lvmlockd-internal.h
@@ -316,10 +316,9 @@ static inline int list_empty(const struct list_head *head)
 EXTERN int gl_type_static;
 EXTERN int gl_use_dlm;
 EXTERN int gl_use_sanlock;
-EXTERN pthread_mutex_t gl_type_mutex;
-
 EXTERN char gl_lsname_dlm[MAX_NAME+1];
 EXTERN char gl_lsname_sanlock[MAX_NAME+1];
+EXTERN int global_dlm_lockspace_exists;
 
 EXTERN int daemon_test; /* run as much as possible without a live lock manager */
 EXTERN int daemon_debug;


