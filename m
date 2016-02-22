From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 22 Feb 2016 15:37:05 +0000 (UTC)
Subject: master - lvmlockd: invalidate name in lockspace struct after remove
Message-ID: <20160222153705.3B61160E9E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c716813651c2691c44bc709040cd16fbf363a74e
Commit:        c716813651c2691c44bc709040cd16fbf363a74e
Parent:        161ae36363f5fa1b1469fd3a42c096c878002b31
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Feb 22 09:32:39 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Feb 22 09:36:35 2016 -0600

lvmlockd: invalidate name in lockspace struct after remove

After the lockspace has been successfully removed,
invalidate the name field in the lockspace struct.
The struct remains on the list of lockspaces until
the struct can be freed later.  Until the struct is
freed, its name will prevent another new lockspace
from being created with the same name.
---
 daemons/lvmlockd/lvmlockd-core.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index 76a7650..c273d25 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -2269,6 +2269,7 @@ static void *lockspace_thread_main(void *arg_in)
 	struct action *act_op_free = NULL;
 	struct list_head tmp_act;
 	struct list_head act_close;
+	char tmp_name[MAX_NAME+1];
 	int free_vg = 0;
 	int drop_vg = 0;
 	int error = 0;
@@ -2634,6 +2635,10 @@ out_act:
 	ls->drop_vg = drop_vg;
 	if (ls->lm_type == LD_LM_DLM && !strcmp(ls->name, gl_lsname_dlm))
 		global_dlm_lockspace_exists = 0;
+	/* Avoid a name collision of the same lockspace is added again before this thread is cleaned up. */
+	memset(tmp_name, 0, sizeof(tmp_name));
+	snprintf(tmp_name, MAX_NAME, "REM:%s", ls->name);
+	memcpy(ls->name, tmp_name, MAX_NAME);
 	pthread_mutex_unlock(&lockspaces_mutex);
 
 	/* worker_thread will join this thread, and free the ls */
@@ -3113,6 +3118,8 @@ static int for_each_lockspace(int do_stop, int do_free, int do_force)
 
 				/* FIXME: will free_vg ever not be set? */
 
+				log_debug("free ls %s", ls->name);
+
 				if (ls->free_vg) {
 					/* In future we may need to free ls->actions here */
 					free_ls_resources(ls);


