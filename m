From: David Teigland <teigland@fedoraproject.org>
Date: Thu,  3 Sep 2015 21:48:55 +0000 (UTC)
Subject: master - lvmlockd: improve log messages for adding dlm global lockspace
Message-ID: <20150903214855.7E710606F5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c27015368b590dc42f15ef8d55faa279e912666a
Commit:        c27015368b590dc42f15ef8d55faa279e912666a
Parent:        5da497d0a81e100d803a1384a9394b0b513f176b
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Sep 3 13:39:56 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Sep 3 16:47:54 2015 -0500

lvmlockd: improve log messages for adding dlm global lockspace

---
 daemons/lvmlockd/lvmlockd-core.c |   20 ++++++++++----------
 1 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index f2a01dc..36be584 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -2545,10 +2545,13 @@ static int add_lockspace_thread(const char *ls_name,
 	pthread_mutex_lock(&lockspaces_mutex);
 	ls2 = find_lockspace_name(ls->name);
 	if (ls2) {
-		if (ls2->thread_stop)
+		if (ls2->thread_stop) {
+			log_debug("add_lockspace_thread %s exists and stopping", ls->name);
 			rv = -EAGAIN;
-		else
+		} else {
+			log_debug("add_lockspace_thread %s exists", ls->name);
 			rv = -EEXIST;
+		}
 		pthread_mutex_unlock(&lockspaces_mutex);
 		free_resource(r);
 		free(ls);
@@ -2567,6 +2570,7 @@ static int add_lockspace_thread(const char *ls_name,
 
 	rv = pthread_create(&ls->thread, NULL, lockspace_thread_main, ls);
 	if (rv < 0) {
+		log_error("add_lockspace_thread %s pthread error %d %d", ls->name, rv, errno);
 		pthread_mutex_lock(&lockspaces_mutex);
 		list_del(&ls->list);
 		pthread_mutex_unlock(&lockspaces_mutex);
@@ -2601,7 +2605,7 @@ static int add_dlm_global_lockspace(struct action *act)
 
 	rv = add_lockspace_thread(gl_lsname_dlm, NULL, NULL, LD_LM_DLM, NULL, act);
 	if (rv < 0) {
-		log_error("add_dlm_global_lockspace add_lockspace_thread %d", rv);
+		log_debug("add_dlm_global_lockspace add_lockspace_thread %d", rv);
 		dlm_gl_lockspace_running = 0;
 	}
 
@@ -2685,20 +2689,16 @@ static int add_lockspace(struct action *act)
 	}
 
 	if (act->rt == LD_RT_VG) {
-		if (gl_use_dlm) {
-			rv = add_dlm_global_lockspace(NULL);
-			if (rv < 0 && rv != -EEXIST)
-				return rv;
-		}
+		if (gl_use_dlm)
+			add_dlm_global_lockspace(NULL);
 
 		vg_ls_name(act->vg_name, ls_name);
 
 		rv = add_lockspace_thread(ls_name, act->vg_name, act->vg_uuid,
 					  act->lm_type, act->vg_args,
 					  act);
-
 		if (rv)
-			log_error("add_lockspace %s add_lockspace_thread %d", ls_name, rv);
+			log_debug("add_lockspace %s add_lockspace_thread %d", ls_name, rv);
 		return rv;
 	}
 


