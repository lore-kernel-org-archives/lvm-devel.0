From: David Teigland <teigland@sourceware.org>
Date: Thu, 31 Jan 2019 10:40:05 -0500
Subject: 2018-06-01-stable - lvmlockd: make lockstart wait for existing start
Message-ID: <201901311540.x0VFe5FL007736@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=75886f59e46b7f9bcb2149d159a4867adb05ba0d
Commit:        75886f59e46b7f9bcb2149d159a4867adb05ba0d
Parent:        1d2de5dd130b0db81502ad5fce12f1ab148ede3e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jan 16 10:41:43 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jan 31 09:38:50 2019 -0600

lvmlockd: make lockstart wait for existing start

If there are two independent scripts doing:
  vgchange --lockstart vg
  lvchange -ay vg/lv

The first vgchange to do the lockstart will wait for
the lockstart to complete before returning.
The second vgchange to do the lockstart will see that
the start is already in progress (from the first) and
will do nothing.  This means the second does not wait
for any lockstart to complete, and moves on to the
lvchange which may find the lockspace still starting
and fail.

To fix this, make the vgchange lockstart command
wait for any lockstart's in progress to complete.
---
 daemons/lvmlockd/lvmlockd-core.c |    9 ++++++---
 lib/locking/lvmlockd.c           |   12 +++++++++---
 lib/locking/lvmlockd.h           |    2 +-
 tools/vgchange.c                 |    5 ++++-
 tools/vgcreate.c                 |    2 +-
 5 files changed, 21 insertions(+), 9 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index 861fb4a..0bf2927 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -2815,6 +2815,9 @@ static int add_lockspace_thread(const char *ls_name,
 		if (ls2->thread_stop) {
 			log_debug("add_lockspace_thread %s exists and stopping", ls->name);
 			rv = -EAGAIN;
+		} else if (!ls2->create_fail && !ls2->create_done) {
+			log_debug("add_lockspace_thread %s exists and starting", ls->name);
+			rv = -ESTARTING;
 		} else {
 			log_debug("add_lockspace_thread %s exists", ls->name);
 			rv = -EEXIST;
@@ -3056,7 +3059,7 @@ static int count_lockspace_starting(uint32_t client_id)
 
 	pthread_mutex_lock(&lockspaces_mutex);
 	list_for_each_entry(ls, &lockspaces, list) {
-		if (ls->start_client_id != client_id)
+		if (client_id && (ls->start_client_id != client_id))
 			continue;
 
 		if (!ls->create_done && !ls->create_fail) {
@@ -3457,7 +3460,7 @@ static void *worker_thread_main(void *arg_in)
 			add_client_result(act);
 
 		} else if (act->op == LD_OP_START_WAIT) {
-			act->result = count_lockspace_starting(act->client_id);
+			act->result = count_lockspace_starting(0);
 			if (!act->result)
 				add_client_result(act);
 			else
@@ -3491,7 +3494,7 @@ static void *worker_thread_main(void *arg_in)
 		list_for_each_entry_safe(act, safe, &delayed_list, list) {
 			if (act->op == LD_OP_START_WAIT) {
 				log_debug("work delayed start_wait for client %u", act->client_id);
-				act->result = count_lockspace_starting(act->client_id);
+				act->result = count_lockspace_starting(0);
 				if (!act->result) {
 					list_del(&act->list);
 					add_client_result(act);
diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index 24a46e7..788b62b 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -1009,7 +1009,7 @@ void lockd_free_vg_final(struct cmd_context *cmd, struct volume_group *vg)
  * that the VG lockspace being started is new.
  */
 
-int lockd_start_vg(struct cmd_context *cmd, struct volume_group *vg, int start_init)
+int lockd_start_vg(struct cmd_context *cmd, struct volume_group *vg, int start_init, int *exists)
 {
 	char uuid[64] __attribute__((aligned(8)));
 	daemon_reply reply;
@@ -1084,6 +1084,12 @@ int lockd_start_vg(struct cmd_context *cmd, struct volume_group *vg, int start_i
 		log_debug("VG %s start error: already started", vg->name);
 		ret = 1;
 		break;
+	case -ESTARTING:
+		log_debug("VG %s start error: already starting", vg->name);
+		if (exists)
+			*exists = 1;
+		ret = 1;
+		break;
 	case -EARGS:
 		log_error("VG %s start failed: invalid parameters for %s", vg->name, vg->lock_type);
 		break;
@@ -2662,7 +2668,7 @@ int lockd_rename_vg_final(struct cmd_context *cmd, struct volume_group *vg, int
 		 * Depending on the problem that caused the rename to
 		 * fail, it may make sense to not restart the VG here.
 		 */
-		if (!lockd_start_vg(cmd, vg, 0))
+		if (!lockd_start_vg(cmd, vg, 0, NULL))
 			log_error("Failed to restart VG %s lockspace.", vg->name);
 		return 1;
 	}
@@ -2702,7 +2708,7 @@ int lockd_rename_vg_final(struct cmd_context *cmd, struct volume_group *vg, int
 		}
 	}
 
-	if (!lockd_start_vg(cmd, vg, 1))
+	if (!lockd_start_vg(cmd, vg, 1, NULL))
 		log_error("Failed to start VG %s lockspace.", vg->name);
 
 	return 1;
diff --git a/lib/locking/lvmlockd.h b/lib/locking/lvmlockd.h
index cf23e9b..05a84e1 100644
--- a/lib/locking/lvmlockd.h
+++ b/lib/locking/lvmlockd.h
@@ -63,7 +63,7 @@ int lockd_rename_vg_final(struct cmd_context *cmd, struct volume_group *vg, int
 
 /* start and stop the lockspace for a vg */
 
-int lockd_start_vg(struct cmd_context *cmd, struct volume_group *vg, int start_init);
+int lockd_start_vg(struct cmd_context *cmd, struct volume_group *vg, int start_init, int *exists);
 int lockd_stop_vg(struct cmd_context *cmd, struct volume_group *vg);
 int lockd_start_wait(struct cmd_context *cmd);
 
diff --git a/tools/vgchange.c b/tools/vgchange.c
index 623517b..b2c739c 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -629,6 +629,7 @@ static int _vgchange_lock_start(struct cmd_context *cmd, struct volume_group *vg
 {
 	const char *start_opt = arg_str_value(cmd, lockopt_ARG, NULL);
 	int auto_opt = 0;
+	int exists = 0;
 	int r;
 
 	if (!is_lockd_type(vg->lock_type))
@@ -655,10 +656,12 @@ static int _vgchange_lock_start(struct cmd_context *cmd, struct volume_group *vg
 	}
 
 do_start:
-	r = lockd_start_vg(cmd, vg, 0);
+	r = lockd_start_vg(cmd, vg, 0, &exists);
 
 	if (r)
 		vp->lock_start_count++;
+	else if (exists)
+		vp->lock_start_count++;
 	if (!strcmp(vg->lock_type, "sanlock"))
 		vp->lock_start_sanlock = 1;
 
diff --git a/tools/vgcreate.c b/tools/vgcreate.c
index e9f9073..4356d99 100644
--- a/tools/vgcreate.c
+++ b/tools/vgcreate.c
@@ -210,7 +210,7 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 	if (is_lockd_type(vg->lock_type)) {
 		const char *start_opt = arg_str_value(cmd, lockopt_ARG, NULL);
 
-		if (!lockd_start_vg(cmd, vg, 1)) {
+		if (!lockd_start_vg(cmd, vg, 1, NULL)) {
 			log_error("Failed to start locking");
 			goto out;
 		}


