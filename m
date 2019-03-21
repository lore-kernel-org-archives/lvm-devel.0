From: David Teigland <teigland@sourceware.org>
Date: Thu, 21 Mar 2019 13:46:11 -0400
Subject: master - warn about changes to an active lv with shared lock
Message-ID: <201903211746.x2LHkBaK030607@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9b4926aaff7f8644c8492cd68ab0b7079416ef3a
Commit:        9b4926aaff7f8644c8492cd68ab0b7079416ef3a
Parent:        7f757ab6166074dd3286983c05a30623095845ff
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Mar 7 11:20:41 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Mar 21 12:38:20 2019 -0500

warn about changes to an active lv with shared lock

When an LV is active with a shared lock, a command can be
run to change the LV with --lockopt skiplv (to override the
exclusive lock the command ordinarily requires which is not
compatible with the outstanding shared lock.)

In this case, other commands may have the LV active and may
need to refresh the LV, so print warning stating this.
---
 daemons/lvmlockd/lvmlockd-core.c     |   41 ++++++++++++++++
 daemons/lvmlockd/lvmlockd-internal.h |    1 +
 lib/locking/lvmlockd.c               |   84 ++++++++++++++++++++++++++++++++-
 3 files changed, 123 insertions(+), 3 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index 60ae537..40a2f21 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -725,6 +725,8 @@ static const char *op_str(int x)
 		return "rename_final";
 	case LD_OP_RUNNING_LM:
 		return "running_lm";
+	case LD_OP_QUERY_LOCK:
+		return "query_lock";
 	case LD_OP_FIND_FREE_LOCK:
 		return "find_free_lock";
 	case LD_OP_KILL_VG:
@@ -2196,6 +2198,7 @@ static int process_op_during_kill(struct action *act)
 	case LD_OP_UPDATE:
 	case LD_OP_RENAME_BEFORE:
 	case LD_OP_RENAME_FINAL:
+	case LD_OP_QUERY_LOCK:
 	case LD_OP_FIND_FREE_LOCK:
 		return 0;
 	};
@@ -2420,6 +2423,19 @@ static void *lockspace_thread_main(void *arg_in)
 				break;
 			}
 
+			if (act->op == LD_OP_QUERY_LOCK) {
+				r = find_resource_act(ls, act, 0);
+				if (!r)
+					act->result = -ENOENT;
+				else {
+					act->result = 0;
+					act->mode = r->mode;
+				}
+				list_del(&act->list);
+				add_client_result(act);
+				continue;
+			}
+
 			if (act->op == LD_OP_FIND_FREE_LOCK && act->rt == LD_RT_VG) {
 				uint64_t free_offset = 0;
 				int sector_size = 0;
@@ -3673,6 +3689,20 @@ static int client_send_result(struct client *cl, struct action *act)
 					  "result_flags = %s", result_flags[0] ? result_flags : "none",
 					  NULL);
 
+	} else if (act->op == LD_OP_QUERY_LOCK) {
+
+		log_debug("send %s[%d] cl %u %s %s rv %d mode %d",
+			  cl->name[0] ? cl->name : "client", cl->pid, cl->id,
+			  op_str(act->op), rt_str(act->rt),
+			  act->result, act->mode);
+
+		res = daemon_reply_simple("OK",
+					  "op = " FMTd64, (int64_t)act->op,
+					  "op_result = " FMTd64, (int64_t) act->result,
+					  "lock_type = %s", lm_str(act->lm_type),
+					  "mode = %s", mode_str(act->mode),
+					  NULL);
+
 	} else if (act->op == LD_OP_DUMP_LOG || act->op == LD_OP_DUMP_INFO) {
 		/*
 		 * lvmlockctl creates the unix socket then asks us to write to it.
@@ -4003,6 +4033,16 @@ static int str_to_op_rt(const char *req_name, int *op, int *rt)
 		*rt = 0;
 		return 0;
 	}
+	if (!strcmp(req_name, "query_lock_vg")) {
+		*op = LD_OP_QUERY_LOCK;
+		*rt = LD_RT_VG;
+		return 0;
+	}
+	if (!strcmp(req_name, "query_lock_lv")) {
+		*op = LD_OP_QUERY_LOCK;
+		*rt = LD_RT_LV;
+		return 0;
+	}
 	if (!strcmp(req_name, "find_free_lock")) {
 		*op = LD_OP_FIND_FREE_LOCK;
 		*rt = LD_RT_VG;
@@ -4582,6 +4622,7 @@ static void client_recv_action(struct client *cl)
 	case LD_OP_DISABLE:
 	case LD_OP_FREE:
 	case LD_OP_RENAME_BEFORE:
+	case LD_OP_QUERY_LOCK:
 	case LD_OP_FIND_FREE_LOCK:
 	case LD_OP_KILL_VG:
 	case LD_OP_DROP_VG:
diff --git a/daemons/lvmlockd/lvmlockd-internal.h b/daemons/lvmlockd/lvmlockd-internal.h
index 04645fa..f0fa85f 100644
--- a/daemons/lvmlockd/lvmlockd-internal.h
+++ b/daemons/lvmlockd/lvmlockd-internal.h
@@ -53,6 +53,7 @@ enum {
 	LD_OP_KILL_VG,
 	LD_OP_DROP_VG,
 	LD_OP_BUSY,
+	LD_OP_QUERY_LOCK,
 };
 
 /* resource types */
diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index 5ecdc64..a143689 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -2031,6 +2031,59 @@ int lockd_vg_update(struct volume_group *vg)
 	return ret;
 }
 
+static int _query_lock_lv(struct cmd_context *cmd, struct volume_group *vg,
+			  const char *lv_name, char *lv_uuid,
+			  const char *lock_args, int *ex, int *sh)
+{
+	daemon_reply reply;
+	const char *opts = NULL;
+	const char *reply_str;
+	int result;
+	int ret;
+
+	log_debug("lockd query LV %s/%s", vg->name, lv_name);
+
+	reply = _lockd_send("query_lock_lv",
+				"pid = " FMTd64, (int64_t) getpid(),
+				"opts = %s", opts ?: "none",
+				"vg_name = %s", vg->name,
+				"lv_name = %s", lv_name,
+				"lv_uuid = %s", lv_uuid,
+				"vg_lock_type = %s", vg->lock_type,
+				"vg_lock_args = %s", vg->lock_args,
+				"lv_lock_args = %s", lock_args ?: "none",
+				NULL);
+
+	if (!_lockd_result(reply, &result, NULL)) {
+		/* No result from lvmlockd, it is probably not running. */
+		log_error("Lock query failed for LV %s/%s", vg->name, lv_name);
+		return 0;
+	} else {
+		ret = (result < 0) ? 0 : 1;
+	}
+
+	if (!ret)
+		log_error("query_lock_lv lvmlockd result %d", result);
+
+	if (!(reply_str = daemon_reply_str(reply, "mode", NULL))) {
+		log_error("query_lock_lv mode not returned");
+		ret = 0;
+	}
+
+	if (reply_str && !strcmp(reply_str, "ex"))
+		*ex = 1;
+	else if (reply_str && !strcmp(reply_str, "sh"))
+		*sh = 1;
+
+	daemon_reply_destroy(reply);
+
+	/* The lv was not active/locked. */
+	if (result == -ENOENT)
+		return 1;
+
+	return 1;
+}
+
 /*
  * When this is called directly (as opposed to being called from
  * lockd_lv), the caller knows that the LV has a lock.
@@ -2055,6 +2108,34 @@ int lockd_lv_name(struct cmd_context *cmd, struct volume_group *vg,
 		return 0;
 	}
 
+	if (!id_write_format(lv_id, lv_uuid, sizeof(lv_uuid)))
+		return_0;
+
+	if (cmd->lockd_lv_disable && !strcmp(vg->lock_type, "dlm")) {
+		/*
+		 * If the command is updating an LV with a shared lock,
+		 * and using --lockopt skiplv to skip the incompat ex
+		 * lock, then check if an existing sh lock exists.
+		 */
+
+		if (!strcmp(cmd->name, "lvextend") ||
+		    !strcmp(cmd->name, "lvresize") ||
+		    !strcmp(cmd->name, "lvchange") ||
+		    !strcmp(cmd->name, "lvconvert")) {
+			int ex = 0, sh = 0;
+
+			if (!_query_lock_lv(cmd, vg, lv_name, lv_uuid, lock_args, &ex, &sh))
+				return 1;
+
+			if (sh) {
+				log_warn("WARNING: shared LV may require refresh on other hosts where it is active.");
+				return 1;
+			}
+		}
+
+		return 1;
+	}
+
 	if (cmd->lockd_lv_disable)
 		return 1;
 
@@ -2063,9 +2144,6 @@ int lockd_lv_name(struct cmd_context *cmd, struct volume_group *vg,
 	if (!_lvmlockd_connected)
 		return 0;
 
-	if (!id_write_format(lv_id, lv_uuid, sizeof(lv_uuid)))
-		return_0;
-
 	/*
 	 * For lvchange/vgchange activation, def_mode is "sh" or "ex"
 	 * according to the specific -a{e,s}y mode designation.


