From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 11 Sep 2015 19:12:48 +0000 (UTC)
Subject: master - lvmlockd: prevent vgremove of dlm VG while lockspace is used
Message-ID: <20150911191248.8FDA260D5F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6bc3d72a655395a7f1ca299d85000ff65280d24d
Commit:        6bc3d72a655395a7f1ca299d85000ff65280d24d
Parent:        854a559a494e81228905f6739de9150853ce2ea7
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Sep 11 14:06:46 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Sep 11 14:12:13 2015 -0500

lvmlockd: prevent vgremove of dlm VG while lockspace is used

This applies the same rule/logic to dlm VGs that has always
existed for sanlock VGs.  Allowing a dlm VG to be removed
while its lockspace was still running on other hosts largely
worked, but there were difficult problems if another VG with
the same name was recreated.  Forcing the VG lockspace to
be stopped, gives both sanlock and dlm VGs the same behavior.
---
 daemons/lvmlockd/lvmlockd-core.c     |   22 ++++++++++++-
 daemons/lvmlockd/lvmlockd-dlm.c      |   56 +++++++++++++++++++++++++++++++++
 daemons/lvmlockd/lvmlockd-internal.h |    7 ++++
 lib/locking/lvmlockd.c               |   57 ++++++++++++++++++++++++++++------
 4 files changed, 131 insertions(+), 11 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index ffeef5c..7d5b158 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -735,6 +735,8 @@ static const char *op_str(int x)
 		return "dump_log";
 	case LD_OP_DUMP_INFO:
 		return "dump_info";
+	case LD_OP_BUSY:
+		return "busy";
 	default:
 		return "op_unknown";
 	};
@@ -926,7 +928,7 @@ static int lm_unlock(struct lockspace *ls, struct resource *r, struct action *ac
 static int lm_hosts(struct lockspace *ls, int notify)
 {
 	if (ls->lm_type == LD_LM_DLM)
-		return 0;
+		return lm_hosts_dlm(ls, notify);
 	else if (ls->lm_type == LD_LM_SANLOCK)
 		return lm_hosts_sanlock(ls, notify);
 	return -1;
@@ -2364,6 +2366,18 @@ static void *lockspace_thread_main(void *arg_in)
 				break;
 			}
 
+			if (act->op == LD_OP_BUSY && act->rt == LD_RT_VG) {
+				log_debug("S %s checking if lockspace is busy", ls->name);
+				rv = lm_hosts(ls, 0);
+				if (rv)
+					act->result = -EBUSY;
+				else
+					act->result = 0;
+				list_del(&act->list);
+				add_client_result(act);
+				continue;
+			}
+
 			if (act->op == LD_OP_RENAME_BEFORE && act->rt == LD_RT_VG) {
 				/* vgrename */
 				log_debug("S %s checking for lockspace hosts", ls->name);
@@ -3825,6 +3839,11 @@ static int str_to_op_rt(const char *req_name, int *op, int *rt)
 		*rt = LD_RT_VG;
 		return 0;
 	}
+	if (!strcmp(req_name, "busy_vg")) {
+		*op = LD_OP_BUSY;
+		*rt = LD_RT_VG;
+		return 0;
+	}
 	if (!strcmp(req_name, "free_lv")) {
 		*op = LD_OP_FREE;
 		*rt = LD_RT_LV;
@@ -4477,6 +4496,7 @@ static void client_recv_action(struct client *cl)
 	case LD_OP_FIND_FREE_LOCK:
 	case LD_OP_KILL_VG:
 	case LD_OP_DROP_VG:
+	case LD_OP_BUSY:
 		rv = add_lock_action(act);
 		break;
 	default:
diff --git a/daemons/lvmlockd/lvmlockd-dlm.c b/daemons/lvmlockd/lvmlockd-dlm.c
index 7f65abc..acadf2d 100644
--- a/daemons/lvmlockd/lvmlockd-dlm.c
+++ b/daemons/lvmlockd/lvmlockd-dlm.c
@@ -662,6 +662,62 @@ int lm_unlock_dlm(struct lockspace *ls, struct resource *r,
 
 #define DLM_LOCKSPACES_PATH "/sys/kernel/config/dlm/cluster/spaces"
 
+/*
+ * FIXME: this should be implemented differently.
+ * It's not nice to use an aspect of the dlm clustering
+ * implementation, which could change.  It would be
+ * better to do something like use a special lock in the
+ * lockspace that was held PR by all nodes, and then an
+ * EX request on it could check if it's started (and
+ * possibly also notify others to stop it automatically).
+ * Or, possibly an enhancement to libdlm that would give
+ * info about lockspace members.
+ *
+ * (We could let the VG be removed while others still
+ * have the lockspace running, which largely works, but
+ * introduces problems if another VG with the same name is
+ * recreated while others still have the lockspace running
+ * for the previous VG.  We'd also want a way to clean up
+ * the stale lockspaces on the others eventually.)
+ */
+
+int lm_hosts_dlm(struct lockspace *ls, int notify)
+{
+	static const char closedir_err_msg[] = "lm_hosts_dlm: closedir failed";
+	char ls_nodes_path[PATH_MAX];
+	struct dirent *de;
+	DIR *ls_dir;
+	int count = 0;
+
+	memset(ls_nodes_path, 0, sizeof(ls_nodes_path));
+	snprintf(ls_nodes_path, PATH_MAX-1, "%s/%s/nodes",
+		 DLM_LOCKSPACES_PATH, ls->name);
+
+	if (!(ls_dir = opendir(ls_nodes_path)))
+		return -ECONNREFUSED;
+
+	while ((de = readdir(ls_dir))) {
+		if (de->d_name[0] == '.')
+			continue;
+		count++;
+	}
+
+	if (closedir(ls_dir))
+		log_error(closedir_err_msg);
+
+	if (!count) {
+		log_error("lm_hosts_dlm found no nodes in %s", ls_nodes_path);
+		return 0;
+	}
+
+	/*
+	 * Assume that a count of one node represents ourself,
+	 * and any value over one represents other nodes.
+	 */
+
+	return count - 1;
+}
+
 int lm_get_lockspaces_dlm(struct list_head *ls_rejoin)
 {
 	static const char closedir_err_msg[] = "lm_get_lockspace_dlm: closedir failed";
diff --git a/daemons/lvmlockd/lvmlockd-internal.h b/daemons/lvmlockd/lvmlockd-internal.h
index 55ac460..a90dd99 100644
--- a/daemons/lvmlockd/lvmlockd-internal.h
+++ b/daemons/lvmlockd/lvmlockd-internal.h
@@ -52,6 +52,7 @@ enum {
 	LD_OP_FIND_FREE_LOCK,
 	LD_OP_KILL_VG,
 	LD_OP_DROP_VG,
+	LD_OP_BUSY,
 };
 
 /* resource types */
@@ -364,6 +365,7 @@ int lm_rem_resource_dlm(struct lockspace *ls, struct resource *r);
 int lm_get_lockspaces_dlm(struct list_head *ls_rejoin);
 int lm_data_size_dlm(void);
 int lm_is_running_dlm(void);
+int lm_hosts_dlm(struct lockspace *ls, int notify);
 
 static inline int lm_support_dlm(void)
 {
@@ -435,6 +437,11 @@ static inline int lm_support_dlm(void)
 	return 0;
 }
 
+static inline int lm_hosts_dlm(struct lockspace *ls, int notify)
+{
+	return 0;
+}
+
 #endif /* dlm support */
 
 #ifdef LOCKDSANLOCK_SUPPORT
diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index 597a964..728dd99 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -698,15 +698,6 @@ static int _free_vg_dlm(struct cmd_context *cmd, struct volume_group *vg)
 	if (!_lvmlockd_connected)
 		return 0;
 
-	/*
-	 * For the dlm, free_vg means unlock the ex VG lock,
-	 * and include an indication in the lvb that the VG
-	 * has been removed.  Then, leave the lockspace.
-	 * If another host tries to acquire the VG lock, it
-	 * will see that the VG has been removed by looking
-	 * at the lvb value.
-	 */
-
 	reply = _lockd_send("free_vg",
 				"pid = %d", getpid(),
 				"vg_name = %s", vg->name,
@@ -730,6 +721,50 @@ static int _free_vg_dlm(struct cmd_context *cmd, struct volume_group *vg)
 
 /* called before vg_remove on disk */
 
+static int _busy_vg_dlm(struct cmd_context *cmd, struct volume_group *vg)
+{
+	daemon_reply reply;
+	uint32_t lockd_flags = 0;
+	int result;
+	int ret;
+
+	if (!_use_lvmlockd)
+		return 0;
+	if (!_lvmlockd_connected)
+		return 0;
+
+	/*
+	 * Check that other hosts do not have the VG lockspace started.
+	 */
+
+	reply = _lockd_send("busy_vg",
+				"pid = %d", getpid(),
+				"vg_name = %s", vg->name,
+				"vg_lock_type = %s", vg->lock_type,
+				"vg_lock_args = %s", vg->lock_args,
+				NULL);
+
+	if (!_lockd_result(reply, &result, &lockd_flags)) {
+		ret = 0;
+	} else {
+		ret = (result < 0) ? 0 : 1;
+	}
+
+	if (result == -EBUSY) {
+		log_error("Lockspace for \"%s\" not stopped on other hosts", vg->name);
+		goto out;
+	}
+
+	if (!ret)
+		log_error("_busy_vg_dlm lvmlockd result %d", result);
+
+ out:
+	daemon_reply_destroy(reply);
+	return ret;
+}
+
+/* called before vg_remove on disk */
+
 static int _free_vg_sanlock(struct cmd_context *cmd, struct volume_group *vg)
 {
 	daemon_reply reply;
@@ -881,8 +916,10 @@ int lockd_free_vg_before(struct cmd_context *cmd, struct volume_group *vg,
 	switch (lock_type_num) {
 	case LOCK_TYPE_NONE:
 	case LOCK_TYPE_CLVM:
-	case LOCK_TYPE_DLM:
 		return 1;
+	case LOCK_TYPE_DLM:
+		/* returning an error will prevent vg_remove() */
+		return _busy_vg_dlm(cmd, vg);
 	case LOCK_TYPE_SANLOCK:
 		/* returning an error will prevent vg_remove() */
 		return _free_vg_sanlock(cmd, vg);


