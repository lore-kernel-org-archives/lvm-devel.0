From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  9 Nov 2015 16:05:48 +0000 (UTC)
Subject: master - libdaemon: fix passing 32bit values for %d
Message-ID: <20151109160548.963F960222@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=32762e2a9c897723fa1c124f5ba723d430448902
Commit:        32762e2a9c897723fa1c124f5ba723d430448902
Parent:        e207ededd607fe30cf1f10d5c4415ed30b2d030c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 9 15:15:37 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 9 17:04:10 2015 +0100

libdaemon: fix passing 32bit values for %d

Since %d is now prohibited for its great confusion,
replace it with  FMTd64 and correctly converted int64_t
parameter.
---
 WHATS_NEW                        |    1 +
 daemons/lvmetad/lvmetactl.c      |   20 +++++++++---------
 daemons/lvmlockd/lvmlockctl.c    |    8 +++---
 daemons/lvmlockd/lvmlockd-core.c |   24 ++++++++++----------
 daemons/lvmpolld/lvmpolld-core.c |    2 +-
 lib/cache/lvmetad.c              |    2 +-
 lib/locking/lvmlockd.c           |   42 +++++++++++++++++++-------------------
 lib/lvmpolld/lvmpolld-client.c   |    8 +++---
 8 files changed, 54 insertions(+), 53 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 7dc5a45..5938a99 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.135 - 
 ====================================
+  Fix passing of 32bit values through daemons (mostly lvmlockd).
   Use local memory pool for whole alloc_handle manipulation.
   Add missing pointer validation after dm_get_next_target().
   Do not deref NULL pointer in debug message for _match_pv_tags().
diff --git a/daemons/lvmetad/lvmetactl.c b/daemons/lvmetad/lvmetactl.c
index f524178..de40bef 100644
--- a/daemons/lvmetad/lvmetactl.c
+++ b/daemons/lvmetad/lvmetactl.c
@@ -77,7 +77,7 @@ int main(int argc, char **argv)
 		val = atoi(argv[2]);
 
 		reply = daemon_send_simple(h, "set_global_info",
-					   "global_invalid = %d", val,
+					   "global_invalid = " FMTd64, (int64_t) val,
 					   "token = %s", "skip",
 					   NULL);
 		print_reply(reply);
@@ -106,21 +106,21 @@ int main(int argc, char **argv)
 			reply = daemon_send_simple(h, "set_vg_info",
 						   "uuid = %s", uuid,
 						   "name = %s", name,
-						   "version = %d", ver,
-						    "token = %s", "skip",
-						    NULL);
+						   "version = " FMTd64, (int64_t) ver,
+						   "token = %s", "skip",
+						   NULL);
 		} else if (uuid) {
 			reply = daemon_send_simple(h, "set_vg_info",
 						   "uuid = %s", uuid,
-						   "version = %d", ver,
-						    "token = %s", "skip",
-						    NULL);
+						   "version = " FMTd64, (int64_t) ver,
+						   "token = %s", "skip",
+						   NULL);
 		} else if (name) {
 			reply = daemon_send_simple(h, "set_vg_info",
 						   "name = %s", name,
-						   "version = %d", ver,
-						    "token = %s", "skip",
-						    NULL);
+						   "version = " FMTd64, (int64_t) ver,
+						   "token = %s", "skip",
+						   NULL);
 		} else {
 			printf("name or uuid required\n");
 			return -1;
diff --git a/daemons/lvmlockd/lvmlockctl.c b/daemons/lvmlockd/lvmlockctl.c
index d0d680a..2e1acd4 100644
--- a/daemons/lvmlockd/lvmlockctl.c
+++ b/daemons/lvmlockd/lvmlockctl.c
@@ -456,7 +456,7 @@ static int do_able(const char *req_name)
 
 	reply = _lvmlockd_send(req_name,
 				"cmd = %s", "lvmlockctl",
-				"pid = %d", getpid(),
+				"pid = " FMTd64, (int64_t) getpid(),
 				"vg_name = %s", arg_vg_name,
 				NULL);
 
@@ -487,7 +487,7 @@ static int do_stop_lockspaces(void)
 
 	reply = _lvmlockd_send("stop_all",
 				"cmd = %s", "lvmlockctl",
-				"pid = %d", getpid(),
+				"pid = " FMTd64, (int64_t) getpid(),
 				"opts = %s", opts[0] ? opts : "none",
 				NULL);
 
@@ -522,7 +522,7 @@ static int do_kill(void)
 
 	reply = _lvmlockd_send("kill_vg",
 				"cmd = %s", "lvmlockctl",
-				"pid = %d", getpid(),
+				"pid = " FMTd64, (int64_t) getpid(),
 				"vg_name = %s", arg_vg_name,
 				NULL);
 
@@ -568,7 +568,7 @@ static int do_drop(void)
 
 	reply = _lvmlockd_send("drop_vg",
 				"cmd = %s", "lvmlockctl",
-				"pid = %d", getpid(),
+				"pid = " FMTd64, (int64_t) getpid(),
 				"vg_name = %s", arg_vg_name,
 				NULL);
 
diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index 9b06e7d..6d5f579 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -1252,7 +1252,7 @@ static int res_lock(struct lockspace *ls, struct resource *r, struct action *act
 					   "token = %s", "skip",
 					   "uuid = %s", uuid,
 					   "name = %s", ls->vg_name,
-					   "version = %d", (int)new_version,
+					   "version = " FMTd64, (int64_t)new_version,
 					   NULL);
 			pthread_mutex_unlock(&lvmetad_mutex);
 
@@ -1270,7 +1270,7 @@ static int res_lock(struct lockspace *ls, struct resource *r, struct action *act
 		pthread_mutex_lock(&lvmetad_mutex);
 		reply = daemon_send_simple(lvmetad_handle, "set_global_info",
 						   "token = %s", "skip",
-						   "global_invalid = %d", 1,
+						   "global_invalid = " FMTd64, INT64_C(1),
 						   NULL);
 		pthread_mutex_unlock(&lvmetad_mutex);
 
@@ -3624,9 +3624,9 @@ static int client_send_result(struct client *cl, struct action *act)
 			  act->result, vg_args ? vg_args : "", lv_args ? lv_args : "");
 
 		res = daemon_reply_simple("OK",
-					  "op = %d", act->op,
-					  "op_result = %d", act->result,
-					  "lm_result = %d", act->lm_rv,
+					  "op = " FMTd64, (int64_t)act->op,
+					  "op_result = " FMTd64, (int64_t) act->result,
+					  "lm_result = " FMTd64, (int64_t) act->lm_rv,
 					  "vg_lock_args = %s", vg_args,
 					  "lv_lock_args = %s", lv_args,
 					  "result_flags = %s", result_flags[0] ? result_flags : "none",
@@ -3655,8 +3655,8 @@ static int client_send_result(struct client *cl, struct action *act)
 			  act->result, dump_len);
 
 		res = daemon_reply_simple("OK",
-					  "result = %d", act->result,
-					  "dump_len = %d", dump_len,
+					  "result = " FMTd64, (int64_t) act->result,
+					  "dump_len = " FMTd64, (int64_t) dump_len,
 					  NULL);
 	} else {
 		/*
@@ -3669,10 +3669,10 @@ static int client_send_result(struct client *cl, struct action *act)
 			  act->result, (act->result == -ENOLS) ? "ENOLS" : "", result_flags);
 
 		res = daemon_reply_simple("OK",
-					  "op = %d", act->op,
+					  "op = " FMTd64, (int64_t) act->op,
 					  "lock_type = %s", lm_str(act->lm_type),
-					  "op_result = %d", act->result,
-					  "lm_result = %d", act->lm_rv,
+					  "op_result = " FMTd64, (int64_t) act->result,
+					  "lm_result = " FMTd64, (int64_t) act->lm_rv,
 					  "result_flags = %s", result_flags[0] ? result_flags : "none",
 					  NULL);
 	}
@@ -4399,9 +4399,9 @@ static void client_recv_action(struct client *cl)
 		buffer_init(&res.buffer);
 
 		res = daemon_reply_simple("OK",
-					  "result = %d", result,
+					  "result = " FMTd64, (int64_t) result,
 					  "protocol = %s", lvmlockd_protocol,
-					  "version = %d", lvmlockd_protocol_version,
+					  "version = " FMTd64, (int64_t) lvmlockd_protocol_version,
 					  NULL);
 		buffer_write(cl->fd, &res.buffer);
 		buffer_destroy(&res.buffer);
diff --git a/daemons/lvmpolld/lvmpolld-core.c b/daemons/lvmpolld/lvmpolld-core.c
index 68072d9..0baa205 100644
--- a/daemons/lvmpolld/lvmpolld-core.c
+++ b/daemons/lvmpolld/lvmpolld-core.c
@@ -539,7 +539,7 @@ static response progress_info(client_handle h, struct lvmpolld_state *ls, reques
 		if (st.polling_finished)
 			r = daemon_reply_simple(LVMPD_RESP_FINISHED,
 						"reason = %s", st.cmd_state.signal ? LVMPD_REAS_SIGNAL : LVMPD_REAS_RETCODE,
-						LVMPD_PARM_VALUE " = %d", (int64_t)(st.cmd_state.signal ?: st.cmd_state.retcode),
+						LVMPD_PARM_VALUE " = " FMTd64, (int64_t)(st.cmd_state.signal ?: st.cmd_state.retcode),
 						NULL);
 		else
 			r = daemon_reply_simple(LVMPD_RESP_IN_PROGRESS, NULL);
diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 5c10cf4..7ef1c8c 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -1744,7 +1744,7 @@ void lvmetad_validate_global_cache(struct cmd_context *cmd, int force)
 	 */
 	reply = daemon_send_simple(_lvmetad, "set_global_info",
 				   "token = %s", "skip",
-				   "global_invalid = %d", 0,
+				   "global_invalid = " FMTd64, INT64_C(0),
 				   NULL);
 	if (reply.error)
 		log_error("lvmetad_validate_global_cache set_global_info error %d", reply.error);
diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index 2bc34c8..1af40b7 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -248,7 +248,7 @@ static int _lockd_request(struct cmd_context *cmd,
 	if (vg_name && lv_name) {
 		reply = _lockd_send(req_name,
 					"cmd = %s", cmd_name,
-					"pid = %d", pid,
+					"pid = " FMTd64, (int64_t) pid,
 					"mode = %s", mode,
 					"opts = %s", opts ?: "none",
 					"vg_name = %s", vg_name,
@@ -268,7 +268,7 @@ static int _lockd_request(struct cmd_context *cmd,
 	} else if (vg_name) {
 		reply = _lockd_send(req_name,
 					"cmd = %s", cmd_name,
-					"pid = %d", pid,
+					"pid = " FMTd64, (int64_t) pid,
 					"mode = %s", mode,
 					"opts = %s", opts ?: "none",
 					"vg_name = %s", vg_name,
@@ -285,7 +285,7 @@ static int _lockd_request(struct cmd_context *cmd,
 	} else {
 		reply = _lockd_send(req_name,
 					"cmd = %s", cmd_name,
-					"pid = %d", pid,
+					"pid = " FMTd64, (int64_t) pid,
 					"mode = %s", mode,
 					"opts = %s", opts ?: "none",
 					"vg_lock_type = %s", vg_lock_type ?: "none",
@@ -436,7 +436,7 @@ int handle_sanlock_lv(struct cmd_context *cmd, struct volume_group *vg)
 	 * Ask lvmlockd/sanlock to look for an unused lock.
 	 */
 	reply = _lockd_send("find_free_lock",
-			"pid = %d", getpid(),
+			"pid = " FMTd64, (int64_t) getpid(),
 			"vg_name = %s", vg->name,
 			NULL);
 
@@ -489,7 +489,7 @@ static int _init_vg_dlm(struct cmd_context *cmd, struct volume_group *vg)
 		return 0;
 
 	reply = _lockd_send("init_vg",
-				"pid = %d", getpid(),
+				"pid = " FMTd64, (int64_t) getpid(),
 				"vg_name = %s", vg->name,
 				"vg_lock_type = %s", "dlm",
 				NULL);
@@ -603,7 +603,7 @@ static int _init_vg_sanlock(struct cmd_context *cmd, struct volume_group *vg, in
 	 */
 
 	reply = _lockd_send("init_vg",
-				"pid = %d", getpid(),
+				"pid = " FMTd64, (int64_t) getpid(),
 				"vg_name = %s", vg->name,
 				"vg_lock_type = %s", "sanlock",
 				"vg_lock_args = %s", vg->sanlock_lv->name,
@@ -699,7 +699,7 @@ static int _free_vg_dlm(struct cmd_context *cmd, struct volume_group *vg)
 		return 0;
 
 	reply = _lockd_send("free_vg",
-				"pid = %d", getpid(),
+				"pid = " FMTd64, (int64_t) getpid(),
 				"vg_name = %s", vg->name,
 				"vg_lock_type = %s", vg->lock_type,
 				"vg_lock_args = %s", vg->lock_args,
@@ -738,7 +738,7 @@ static int _busy_vg_dlm(struct cmd_context *cmd, struct volume_group *vg)
 	 */
 
 	reply = _lockd_send("busy_vg",
-				"pid = %d", getpid(),
+				"pid = " FMTd64, (int64_t) getpid(),
 				"vg_name = %s", vg->name,
 				"vg_lock_type = %s", vg->lock_type,
 				"vg_lock_args = %s", vg->lock_args,
@@ -797,7 +797,7 @@ static int _free_vg_sanlock(struct cmd_context *cmd, struct volume_group *vg)
 	}
 
 	reply = _lockd_send("free_vg",
-				"pid = %d", getpid(),
+				"pid = " FMTd64, (int64_t) getpid(),
 				"vg_name = %s", vg->name,
 				"vg_lock_type = %s", vg->lock_type,
 				"vg_lock_args = %s", vg->lock_args,
@@ -1010,13 +1010,13 @@ int lockd_start_vg(struct cmd_context *cmd, struct volume_group *vg, int start_i
 	}
 
 	reply = _lockd_send("start_vg",
-				"pid = %d", getpid(),
+				"pid = " FMTd64, (int64_t) getpid(),
 				"vg_name = %s", vg->name,
 				"vg_lock_type = %s", vg->lock_type,
 				"vg_lock_args = %s", vg->lock_args ?: "none",
 				"vg_uuid = %s", uuid[0] ? uuid : "none",
-				"version = %d", (int64_t)vg->seqno,
-				"host_id = %d", host_id,
+				"version = " FMTd64, (int64_t) vg->seqno,
+				"host_id = " FMTd64, (int64_t) host_id,
 				"opts = %s", start_init ? "start_init" : "none",
 				NULL);
 
@@ -1076,7 +1076,7 @@ int lockd_stop_vg(struct cmd_context *cmd, struct volume_group *vg)
 		  vg->name, vg->lock_type ? vg->lock_type : "empty");
 
 	reply = _lockd_send("stop_vg",
-			"pid = %d", getpid(),
+			"pid = " FMTd64, (int64_t) getpid(),
 			"vg_name = %s", vg->name,
 			NULL);
 
@@ -1123,7 +1123,7 @@ int lockd_start_wait(struct cmd_context *cmd)
 		return 0;
 
 	reply = _lockd_send("start_wait",
-			"pid = %d", getpid(),
+			"pid = " FMTd64, (int64_t) getpid(),
 			NULL);
 
 	if (!_lockd_result(reply, &result, NULL)) {
@@ -1915,9 +1915,9 @@ int lockd_vg_update(struct volume_group *vg)
 		return 0;
 
 	reply = _lockd_send("vg_update",
-				"pid = %d", getpid(),
+				"pid = " FMTd64, (int64_t) getpid(),
 				"vg_name = %s", vg->name,
-				"version = %d", (int64_t)vg->seqno,
+				"version = " FMTd64, (int64_t) vg->seqno,
 				NULL);
 
 	if (!_lockd_result(reply, &result, NULL)) {
@@ -2176,7 +2176,7 @@ static int _init_lv_sanlock(struct cmd_context *cmd, struct volume_group *vg,
 		return_0;
 
 	reply = _lockd_send("init_lv",
-				"pid = %d", getpid(),
+				"pid = " FMTd64, (int64_t) getpid(),
 				"vg_name = %s", vg->name,
 				"lv_name = %s", lv_name,
 				"lv_uuid = %s", lv_uuid,
@@ -2243,7 +2243,7 @@ static int _free_lv(struct cmd_context *cmd, struct volume_group *vg,
 		return_0;
 
 	reply = _lockd_send("free_lv",
-				"pid = %d", getpid(),
+				"pid = " FMTd64, (int64_t) getpid(),
 				"vg_name = %s", vg->name,
 				"lv_name = %s", lv_name,
 				"lv_uuid = %s", lv_uuid,
@@ -2464,7 +2464,7 @@ int lockd_rename_vg_before(struct cmd_context *cmd, struct volume_group *vg)
 	 */
 
 	reply = _lockd_send("rename_vg_before",
-			"pid = %d", getpid(),
+			"pid = " FMTd64, (int64_t) getpid(),
 			"vg_name = %s", vg->name,
 			"vg_lock_type = %s", vg->lock_type,
 			"vg_lock_args = %s", vg->lock_args,
@@ -2529,7 +2529,7 @@ int lockd_rename_vg_final(struct cmd_context *cmd, struct volume_group *vg, int
 		 * with the new VG (lockspace) name.
 		 */
 		reply = _lockd_send("rename_vg_final",
-				"pid = %d", getpid(),
+				"pid = " FMTd64, (int64_t) getpid(),
 				"vg_name = %s", vg->name,
 				"vg_lock_type = %s", vg->lock_type,
 				"vg_lock_args = %s", vg->lock_args,
@@ -2573,7 +2573,7 @@ const char *lockd_running_lock_type(struct cmd_context *cmd, int *found_multiple
 		return NULL;
 
 	reply = _lockd_send("running_lm",
-			"pid = %d", getpid(),
+			"pid = " FMTd64, (int64_t) getpid(),
 			NULL);
 
 	if (!_lockd_result(reply, &result, NULL)) {
diff --git a/lib/lvmpolld/lvmpolld-client.c b/lib/lvmpolld/lvmpolld-client.c
index f7faa8b..827589f 100644
--- a/lib/lvmpolld/lvmpolld-client.c
+++ b/lib/lvmpolld/lvmpolld-client.c
@@ -147,7 +147,7 @@ static struct progress_info _request_progress_info(const char *uuid, unsigned ab
 	}
 
 	if (abort_polling &&
-	    !daemon_request_extend(req, LVMPD_PARM_ABORT " = %d", (int64_t)abort_polling, NULL)) {
+	    !daemon_request_extend(req, LVMPD_PARM_ABORT " = " FMTd64, (int64_t) abort_polling, NULL)) {
 		log_error("Failed to create " LVMPD_REQ_PROGRESS " request.");
 		goto out_req;
 	}
@@ -228,14 +228,14 @@ static int _process_poll_init(const struct cmd_context *cmd, const char *poll_ty
 	}
 
 	if (parms->aborting &&
-	    !(daemon_request_extend(req, LVMPD_PARM_ABORT " = %d", (int64_t)(parms->aborting), NULL))) {
+	    !(daemon_request_extend(req, LVMPD_PARM_ABORT " = " FMTd64, (int64_t) (parms->aborting), NULL))) {
 		log_error("Failed to create %s request." , poll_type);
 		goto out_req;
 	}
 
 	if (cmd->handles_missing_pvs &&
-	    !(daemon_request_extend(req, LVMPD_PARM_HANDLE_MISSING_PVS " = %d",
-				    (int64_t)(cmd->handles_missing_pvs), NULL))) {
+	    !(daemon_request_extend(req, LVMPD_PARM_HANDLE_MISSING_PVS " = " FMTd64,
+				    (int64_t) (cmd->handles_missing_pvs), NULL))) {
 		log_error("Failed to create %s request." , poll_type);
 		goto out_req;
 	}


