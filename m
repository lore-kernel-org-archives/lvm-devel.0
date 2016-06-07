From: David Teigland <teigland@fedoraproject.org>
Date: Tue,  7 Jun 2016 15:18:04 +0000 (UTC)
Subject: master - lvmetad: handle update failures
Message-ID: <20160607151804.C1CAE61EF8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ed6ffc7a342149dab60086bcabd5fbd2d12ceeb7
Commit:        ed6ffc7a342149dab60086bcabd5fbd2d12ceeb7
Parent:        851ccfccaf3dae184e0bd5f222bdcfcef33fa3b8
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri May 20 13:32:14 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jun 7 10:17:00 2016 -0500

lvmetad: handle update failures

If a command gets stuck during an lvmetad update, lvmetad
will cancel that update after the timeout.  The next command
to check the lvmetad will see that lvmetad needs to be
populated because lvmetad will return token of "none" after
a timed out update (same as when lvmetad is not populated
at all after starting.)

If a command gets an error during an lvmetad update, it
will now just quit and leave its updating token in place.
That update will be cancelled after the timeout.
---
 daemons/lvmetad/lvmetactl.c    |   26 +++
 daemons/lvmetad/lvmetad-core.c |  210 +++++++++++++++++++---
 lib/cache/lvmetad.c            |  389 +++++++++++++++++++++++++++++----------
 3 files changed, 498 insertions(+), 127 deletions(-)

diff --git a/daemons/lvmetad/lvmetactl.c b/daemons/lvmetad/lvmetactl.c
index 30ca1d6..dd2ee1e 100644
--- a/daemons/lvmetad/lvmetactl.c
+++ b/daemons/lvmetad/lvmetactl.c
@@ -55,24 +55,32 @@ int main(int argc, char **argv)
 	if (!strcmp(cmd, "dump")) {
 		reply = daemon_send_simple(h, "dump",
 					   "token = %s", "skip",
+					   "pid = " FMTd64, (int64_t)getpid(),
+					   "cmd = %s", "lvmetactl",
 					   NULL);
 		printf("%s\n", reply.buffer.mem);
 
 	} else if (!strcmp(cmd, "pv_list")) {
 		reply = daemon_send_simple(h, "pv_list",
 					   "token = %s", "skip",
+					   "pid = " FMTd64, (int64_t)getpid(),
+					   "cmd = %s", "lvmetactl",
 					   NULL);
 		printf("%s\n", reply.buffer.mem);
 
 	} else if (!strcmp(cmd, "vg_list")) {
 		reply = daemon_send_simple(h, "vg_list",
 					   "token = %s", "skip",
+					   "pid = " FMTd64, (int64_t)getpid(),
+					   "cmd = %s", "lvmetactl",
 					   NULL);
 		printf("%s\n", reply.buffer.mem);
 
 	} else if (!strcmp(cmd, "get_global_info")) {
 		reply = daemon_send_simple(h, "get_global_info",
 					   "token = %s", "skip",
+					   "pid = " FMTd64, (int64_t)getpid(),
+					   "cmd = %s", "lvmetactl",
 					   NULL);
 		printf("%s\n", reply.buffer.mem);
 
@@ -86,6 +94,8 @@ int main(int argc, char **argv)
 		reply = daemon_send_simple(h, "set_global_info",
 					   "global_invalid = " FMTd64, (int64_t) val,
 					   "token = %s", "skip",
+					   "pid = " FMTd64, (int64_t)getpid(),
+					   "cmd = %s", "lvmetactl",
 					   NULL);
 		print_reply(reply);
 
@@ -100,6 +110,8 @@ int main(int argc, char **argv)
 					   "global_disable = " FMTd64, (int64_t) val,
 					   "disable_reason = %s", LVMETAD_DISABLE_REASON_DIRECT,
 					   "token = %s", "skip",
+					   "pid = " FMTd64, (int64_t)getpid(),
+					   "cmd = %s", "lvmetactl",
 					   NULL);
 		print_reply(reply);
 
@@ -123,18 +135,24 @@ int main(int argc, char **argv)
 						   "name = %s", name,
 						   "version = " FMTd64, (int64_t) ver,
 						   "token = %s", "skip",
+						   "pid = " FMTd64, (int64_t)getpid(),
+						   "cmd = %s", "lvmetactl",
 						   NULL);
 		} else if (uuid) {
 			reply = daemon_send_simple(h, "set_vg_info",
 						   "uuid = %s", uuid,
 						   "version = " FMTd64, (int64_t) ver,
 						   "token = %s", "skip",
+						   "pid = " FMTd64, (int64_t)getpid(),
+						   "cmd = %s", "lvmetactl",
 						   NULL);
 		} else if (name) {
 			reply = daemon_send_simple(h, "set_vg_info",
 						   "name = %s", name,
 						   "version = " FMTd64, (int64_t) ver,
 						   "token = %s", "skip",
+						   "pid = " FMTd64, (int64_t)getpid(),
+						   "cmd = %s", "lvmetactl",
 						   NULL);
 		} else {
 			printf("name or uuid required\n");
@@ -153,6 +171,8 @@ int main(int argc, char **argv)
 		reply = daemon_send_simple(h, "vg_lookup",
 					   "name = %s", name,
 					   "token = %s", "skip",
+					   "pid = " FMTd64, (int64_t)getpid(),
+					   "cmd = %s", "lvmetactl",
 					   NULL);
 		printf("%s\n", reply.buffer.mem);
 
@@ -166,6 +186,8 @@ int main(int argc, char **argv)
 		reply = daemon_send_simple(h, "vg_lookup",
 					   "uuid = %s", uuid,
 					   "token = %s", "skip",
+					   "pid = " FMTd64, (int64_t)getpid(),
+					   "cmd = %s", "lvmetactl",
 					   NULL);
 		printf("%s\n", reply.buffer.mem);
 
@@ -182,6 +204,8 @@ int main(int argc, char **argv)
 		reply = daemon_send_simple(h, "vg_lookup",
 					   "uuid = %s", uuid,
 					   "token = %s", "skip",
+					   "pid = " FMTd64, (int64_t)getpid(),
+					   "cmd = %s", "lvmetactl",
 					   NULL);
 		/* printf("%s\n", reply.buffer.mem); */
 
@@ -208,6 +232,8 @@ int main(int argc, char **argv)
 		reply = daemon_send_simple(h, "pv_lookup",
 					   "uuid = %s", uuid,
 					   "token = %s", "skip",
+					   "pid = " FMTd64, (int64_t)getpid(),
+					   "cmd = %s", "lvmetactl",
 					   NULL);
 		printf("%s\n", reply.buffer.mem);
 
diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 51db92f..ca1e4ed 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -207,6 +207,8 @@ struct vg_info {
 
 #define VGFL_INVALID 0x00000001
 
+#define CMD_NAME_SIZE 32
+
 typedef struct {
 	daemon_idle *idle;
 	log_state *log; /* convenience */
@@ -222,12 +224,25 @@ typedef struct {
 	struct dm_hash_table *vgname_to_vgid;
 	struct dm_hash_table *pvid_to_vgid;
 	char token[128];
+	char update_cmd[CMD_NAME_SIZE];
+	int update_pid;
+	int update_timeout;
+	uint64_t update_begin;
 	uint32_t flags; /* GLFL_ */
 	pthread_mutex_t token_lock;
 	pthread_mutex_t info_lock;
 	pthread_rwlock_t cache_lock;
 } lvmetad_state;
 
+static uint64_t _monotonic_seconds(void)
+{
+	struct timespec ts;
+
+	if (clock_gettime(CLOCK_MONOTONIC, &ts) < 0)
+		return 0;
+	return ts.tv_sec;
+}
+
 static void destroy_metadata_hashes(lvmetad_state *s)
 {
 	struct dm_hash_node *n = NULL;
@@ -2366,24 +2381,28 @@ static response set_global_info(lvmetad_state *s, request r)
 #define REASON_BUF_SIZE 64
 
 /*
- * FIXME: save the time when "updating" begins, and add a config setting for
- * how long we'll allow an update to take.  Before returning "updating" as the
- * token value in get_global_info, check if the update has exceeded the max
- * allowed time.  If so, then clear the current cache state and return "none"
- * as the current token value, so that the command will repopulate our cache.
+ * Save the time when "updating" begins, and the config setting for how long
+ * the update is allowed to take.  Before returning "updating" as the token
+ * value in get_global_info, check if the update has exceeded the max allowed
+ * time.  If so, then return "none" as the current token value (i.e.
+ * uninitialized), so that the command will repopulate our cache.
  *
- * This will resolve the problem of a command starting to update the cache and
- * then failing, leaving the token set to "update in progress".
+ * This automatically clears a stuck update, where a command started to update
+ * the cache and then failed, leaving the token set to "update in progress".
  */
 
 static response get_global_info(lvmetad_state *s, request r)
 {
 	char reason[REASON_BUF_SIZE];
+	char flag_str[64];
+	int pid;
 
 	/* This buffer should be large enough to hold all the possible reasons. */
 
 	memset(reason, 0, sizeof(reason));
 
+	pid = (int)daemon_request_int(r, "pid", 0);
+
 	if (s->flags & GLFL_DISABLE) {
 		snprintf(reason, REASON_BUF_SIZE - 1, "%s%s%s",
 			 (s->flags & GLFL_DISABLE_REASON_DIRECT)     ? LVMETAD_DISABLE_REASON_DIRECT "," : "",
@@ -2394,17 +2413,46 @@ static response get_global_info(lvmetad_state *s, request r)
 	if (!reason[0])
 		strcpy(reason, "none");
 
-	DEBUGLOG(s, "global info invalid is %d disable is %d reason %s",
-		 (s->flags & GLFL_INVALID) ? 1 : 0,
-		 (s->flags & GLFL_DISABLE) ? 1 : 0, reason);
+	/*
+	 * If the current update has timed out, then return
+	 * token of "none" which means "uninitialized" so that
+	 * the caller will repopulate lvmetad.
+	 */
+	if (s->update_begin && s->update_timeout) {
+		if (_monotonic_seconds() - s->update_begin >= s->update_timeout) {
+			DEBUGLOG(s, "global info cancel update after timeout %d len %d begin %llu pid %d cmd %s",
+				 s->update_timeout,
+				 (int)(_monotonic_seconds() - s->update_begin),
+				 (unsigned long long)s->update_begin,
+				 s->update_pid, s->update_cmd);
+			memset(s->token, 0, sizeof(s->token));
+			s->update_begin = 0;
+			s->update_timeout = 0;
+			s->update_pid = 0;
+			memset(s->update_cmd, 0, CMD_NAME_SIZE);
+		}
+	}
+
+	memset(flag_str, 0, sizeof(flag_str));
+	if (s->flags & GLFL_INVALID)
+		strcat(flag_str, "Invalid");
+	if (s->flags & GLFL_DISABLE)
+		strcat(flag_str, "Disable");
+	if (!flag_str[0])
+		strcat(flag_str, "none");
+
+	DEBUGLOG(s, "%d global info flags %s reason %s token %s update_pid %d",
+		 pid, flag_str, reason, s->token[0] ? s->token : "none", s->update_pid);
 
-	return daemon_reply_simple("OK", "global_invalid = " FMTd64,
-					 (int64_t)((s->flags & GLFL_INVALID) ? 1 : 0),
-					 "global_disable = " FMTd64,
-					 (int64_t)((s->flags & GLFL_DISABLE) ? 1 : 0),
+	return daemon_reply_simple("OK", "global_invalid = " FMTd64, (int64_t)((s->flags & GLFL_INVALID) ? 1 : 0),
+					 "global_disable = " FMTd64, (int64_t)((s->flags & GLFL_DISABLE) ? 1 : 0),
 					 "disable_reason = %s", reason,
-					 "token = %s",
-					 s->token[0] ? s->token : "none",
+					 "daemon_pid = " FMTd64, (int64_t)getpid(),
+					 "token = %s", s->token[0] ? s->token : "none",
+					 "update_cmd = %s", s->update_cmd,
+					 "update_pid = " FMTd64, (int64_t)s->update_pid,
+					 "update_begin = " FMTd64, (int64_t)s->update_begin,
+					 "update_timeout = " FMTd64, (int64_t)s->update_timeout,
 					 NULL);
 }
 
@@ -2593,37 +2641,145 @@ static response handler(daemon_state s, client_handle h, request r)
 {
 	response res = { 0 };
 	lvmetad_state *state = s.private;
-	const char *rq = daemon_request_str(r, "request", "NONE");
-	const char *token = daemon_request_str(r, "token", "NONE");
 	char prev_token[128] = { 0 };
+	const char *rq;
+	const char *token;
+	const char *cmd;
+	int prev_in_progress, this_in_progress;
+	int update_timeout;
+	int pid;
 	int cache_lock = 0;
 	int info_lock = 0;
 
+	rq = daemon_request_str(r, "request", "NONE");
+	token = daemon_request_str(r, "token", "NONE");
+	pid = (int)daemon_request_int(r, "pid", 0);
+	cmd = daemon_request_str(r, "cmd", "NONE");
+	update_timeout = (int)daemon_request_int(r, "update_timeout", 0);
+
 	pthread_mutex_lock(&state->token_lock);
+
+	/*
+	 * token_update: start populating the cache, i.e. a full update.
+	 * To populate the lvmetad cache, a command does:
+	 *
+	 * - token_update, setting token to "update in progress"
+	 *   (further requests during the update continue using
+	 *   this same "update in progress" token)
+	 * - pv_clear_all, to clear the current cache
+	 * - pv_gone, for each PV
+	 * - pv_found, for each PV to populate the cache
+	 * - token_update, setting token to filter hash
+	 */
 	if (!strcmp(rq, "token_update")) {
-		memcpy(prev_token, state->token, 128);
-		strncpy(state->token, token, 128);
-		state->token[127] = 0;
+		prev_in_progress = !strcmp(state->token, LVMETAD_TOKEN_UPDATE_IN_PROGRESS);
+		this_in_progress = !strcmp(token, LVMETAD_TOKEN_UPDATE_IN_PROGRESS);
+
+		if (!prev_in_progress && this_in_progress) {
+			/* New update is starting (filter token is replaced by update token) */
+
+			memcpy(prev_token, state->token, 128);
+			strncpy(state->token, token, 128);
+			state->token[127] = 0;
+			state->update_begin = _monotonic_seconds();
+			state->update_timeout = update_timeout;
+			state->update_pid = pid;
+			strncpy(state->update_cmd, cmd, CMD_NAME_SIZE - 1);
+
+			DEBUGLOG(state, "token_update begin %llu timeout %d pid %d cmd %s",
+				 (unsigned long long)state->update_begin,
+				 state->update_timeout,
+				 state->update_pid,
+				 state->update_cmd);
+
+		} else if (prev_in_progress && this_in_progress) {
+			/* Current update is cancelled and replaced by a new update */
+
+			DEBUGLOG(state, "token_update replacing pid %d begin %llu len %d cmd %s",
+				 state->update_pid,
+				 (unsigned long long)state->update_begin,
+				 (int)(_monotonic_seconds() - state->update_begin),
+				 state->update_cmd);
+
+			memcpy(prev_token, state->token, 128);
+			strncpy(state->token, token, 128);
+			state->token[127] = 0;
+			state->update_begin = _monotonic_seconds();
+			state->update_timeout = update_timeout;
+			state->update_pid = pid;
+			strncpy(state->update_cmd, cmd, CMD_NAME_SIZE - 1);
+
+			DEBUGLOG(state, "token_update begin %llu timeout %d pid %d cmd %s",
+				 (unsigned long long)state->update_begin,
+				 state->update_timeout,
+				 state->update_pid,
+				 state->update_cmd);
+
+		} else if (prev_in_progress && !this_in_progress) {
+			/* Update is finished, update token is replaced by filter token */
+
+			if (state->update_pid != pid) {
+				/* If a pid doing update was cancelled, ignore its token update at the end. */
+				DEBUGLOG(state, "token_update ignored from cancelled update pid %d", pid);
+				pthread_mutex_unlock(&state->token_lock);
+
+				return daemon_reply_simple("token_mismatch",
+							   "expected = %s", state->token,
+							   "received = %s", token,
+							   "update_pid = " FMTd64, (int64_t)state->update_pid,
+							   "reason = %s", "another command has populated the cache");
+			}
+
+			DEBUGLOG(state, "token_update end len %d pid %d new token %s",
+				 (int)(_monotonic_seconds() - state->update_begin),
+				 state->update_pid, token);
+
+			memcpy(prev_token, state->token, 128);
+			strncpy(state->token, token, 128);
+			state->token[127] = 0;
+			state->update_begin = 0;
+			state->update_timeout = 0;
+			state->update_pid = 0;
+			memset(state->update_cmd, 0, CMD_NAME_SIZE);
+		}
 		pthread_mutex_unlock(&state->token_lock);
+
 		return daemon_reply_simple("OK",
 					   "prev_token = %s", prev_token,
+					   "update_pid = " FMTd64, (int64_t)state->update_pid,
 					   NULL);
 	}
 
 	if (strcmp(token, state->token) && strcmp(rq, "dump") && strcmp(token, "skip")) {
 		pthread_mutex_unlock(&state->token_lock);
+
+		DEBUGLOG(state, "token_mismatch current \"%s\" got \"%s\" from pid %d cmd %s",
+			 state->token, token, pid, cmd ?: "none");
+
+		return daemon_reply_simple("token_mismatch",
+					   "expected = %s", state->token,
+					   "received = %s", token,
+					   "update_pid = " FMTd64, (int64_t)state->update_pid,
+					   "reason = %s", "another command has populated the cache");
+	}
+
+	/* If a pid doing update was cancelled, ignore its update messages. */
+	if (!strcmp(token, LVMETAD_TOKEN_UPDATE_IN_PROGRESS) &&
+	    state->update_pid && pid && (state->update_pid != pid)) {
+		pthread_mutex_unlock(&state->token_lock);
+
+		DEBUGLOG(state, "token_mismatch ignore update from pid %d current update pid %d",
+			 pid, state->update_pid);
+
 		return daemon_reply_simple("token_mismatch",
 					   "expected = %s", state->token,
 					   "received = %s", token,
-					   "reason = %s",
-					   "lvmetad cache is invalid due to a global_filter change or due to a running rescan", NULL);
+					   "update_pid = " FMTd64, (int64_t)state->update_pid,
+					   "reason = %s", "another command has populated the lvmetad cache");
 	}
+
 	pthread_mutex_unlock(&state->token_lock);
 
-	/*
-	 * TODO Add a stats call, with transaction count/rate, time since last
-	 * update &c.
-	 */
 
 	if (!strcmp(rq, "pv_found") ||
 	    !strcmp(rq, "pv_gone") ||
diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index bb86e88..02f0897 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -27,16 +27,15 @@
 
 #include <time.h>
 
-#define SCAN_TIMEOUT_SECONDS	80
-#define MAX_RESCANS		10	/* Maximum number of times to scan all PVs and retry if the daemon returns a token mismatch error */
-
 static daemon_handle _lvmetad = { .error = 0 };
 static int _lvmetad_use = 0;
 static int _lvmetad_connected = 0;
+static int _lvmetad_daemon_pid = 0;
 
 static char *_lvmetad_token = NULL;
 static const char *_lvmetad_socket = NULL;
 static struct cmd_context *_lvmetad_cmd = NULL;
+static int64_t _lvmetad_update_timeout;
 
 static int _found_lvm1_metadata = 0;
 
@@ -135,6 +134,8 @@ int lvmetad_connect(struct cmd_context *cmd)
 		return 0;
 	}
 
+	_lvmetad_update_timeout = find_config_tree_int(cmd, global_lvmetad_update_wait_time_CFG, NULL);
+
 	_lvmetad = lvmetad_open(_lvmetad_socket);
 
 	if (_lvmetad.socket_fd >= 0 && !_lvmetad.error) {
@@ -248,13 +249,15 @@ int lvmetad_token_matches(struct cmd_context *cmd)
 	uint64_t now = 0, wait_start = 0;
 	int ret = 1;
 
-	wait_sec = (unsigned int)find_config_tree_int(cmd, global_lvmetad_update_wait_time_CFG, NULL);
+	wait_sec = (unsigned int)_lvmetad_update_timeout;
 
 retry:
-	log_debug_lvmetad("lvmetad send get_global_info");
+	log_debug_lvmetad("Sending lvmetad get_global_info");
 
 	reply = daemon_send_simple(_lvmetad, "get_global_info",
 				   "token = %s", "skip",
+				   "pid = " FMTd64, (int64_t)getpid(),
+				   "cmd = %s", get_cmd_name(),
 				   NULL);
 	if (reply.error) {
 		log_warn("WARNING: Not using lvmetad after send error (%d).", reply.error);
@@ -271,6 +274,8 @@ retry:
 		goto fail;
 	}
 
+	_lvmetad_daemon_pid = (int)daemon_reply_int(reply, "daemon_pid", 0);
+
 	/*
 	 * If lvmetad is being updated by another command, then sleep and retry
 	 * until the token shows the update is done, and go on to the token
@@ -278,13 +283,6 @@ retry:
 	 *
 	 * Between retries, sleep for a random period between 1 and 2 seconds.
 	 * Retry in this way for up to a configurable period of time.
-	 *
-	 * If lvmetad is still being updated after the timeout period,
-	 * then disable this command's use of lvmetad.
-	 *
-	 * FIXME: lvmetad could return the number of objects in its cache along with
-	 * the update message so that callers could detect when a rescan has
-	 * stalled while updating lvmetad.
 	 */
 	if (!strcmp(daemon_token, LVMETAD_TOKEN_UPDATE_IN_PROGRESS)) {
 		if (!(now = _monotonic_seconds()))
@@ -293,7 +291,7 @@ retry:
 		if (!wait_start)
 			wait_start = now;
 
-		if (now - wait_start >= wait_sec) {
+		if (now - wait_start > wait_sec) {
 			log_warn("WARNING: Not using lvmetad after %u sec lvmetad_update_wait_time.", wait_sec);
 			goto fail;
 		}
@@ -354,12 +352,14 @@ static int _lvmetad_is_updating(struct cmd_context *cmd, int do_wait)
 	uint64_t now = 0, wait_start = 0;
 	int ret = 0;
 
-	wait_sec = (unsigned int)find_config_tree_int(cmd, global_lvmetad_update_wait_time_CFG, NULL);
+	wait_sec = (unsigned int)_lvmetad_update_timeout;
 retry:
-	log_debug_lvmetad("lvmetad send get_global_info");
+	log_debug_lvmetad("Sending lvmetad get_global_info");
 
 	reply = daemon_send_simple(_lvmetad, "get_global_info",
 				   "token = %s", "skip",
+				   "pid = " FMTd64, (int64_t)getpid(),
+				   "cmd = %s", get_cmd_name(),
 				   NULL);
 	if (reply.error)
 		goto out;
@@ -405,23 +405,28 @@ static daemon_reply _lvmetad_send(struct cmd_context *cmd, const char *id, ...)
 	va_list ap;
 	daemon_reply reply = { 0 };
 	daemon_request req;
+	const char *token_expected;
 	unsigned int delay_usec;
 	unsigned int wait_sec = 0;
 	uint64_t now = 0, wait_start = 0;
+	int daemon_in_update;
+	int we_are_in_update;
 
 	if (!_lvmetad_connected || !_lvmetad_use) {
 		reply.error = ECONNRESET;
 		return reply;
 	}
 
-	if (cmd)
-		wait_sec = (unsigned int)find_config_tree_int(cmd, global_lvmetad_update_wait_time_CFG, NULL);
+	wait_sec = (unsigned int)_lvmetad_update_timeout;
 retry:
-	log_debug_lvmetad("lvmetad_send %s", id);
-
 	req = daemon_request_make(id);
 
-	if (_lvmetad_token && !daemon_request_extend(req, "token = %s", _lvmetad_token, NULL)) {
+	if (!daemon_request_extend(req,
+				   "token = %s", _lvmetad_token ?: "none",
+				   "update_timeout = " FMTd64, (int64_t)wait_sec,
+				   "pid = " FMTd64, (int64_t)getpid(),
+				   "cmd = %s", get_cmd_name(),
+				   NULL)) {
 		reply.error = ENOMEM;
 		return reply;
 	}
@@ -437,22 +442,40 @@ retry:
 	if (reply.error == ECONNRESET)
 		log_warn("WARNING: lvmetad connection failed, cannot reconnect."); 
 
+	/*
+	 * For the "token_update" message, the result is handled entirely
+	 * by the _token_update() function, so return the reply immediately.
+	 */
+	if (!strcmp(id, "token_update"))
+		return reply;
+
+	/*
+	 * For other messages it may be useful to retry and resend the
+	 * message, so check for that case before returning the reply.
+	 * The reply will be checked further in lvmetad_handle_reply.
+	 */
+
 	if (reply.error)
-		goto out;
+		return reply;
 
 	if (!strcmp(daemon_reply_str(reply, "response", ""), "token_mismatch")) {
-		if (!strcmp(daemon_reply_str(reply, "expected", ""), LVMETAD_TOKEN_UPDATE_IN_PROGRESS)) {
+		token_expected = daemon_reply_str(reply, "expected", "");
+		daemon_in_update = !strcmp(token_expected, LVMETAD_TOKEN_UPDATE_IN_PROGRESS);
+		we_are_in_update = !strcmp(_lvmetad_token, LVMETAD_TOKEN_UPDATE_IN_PROGRESS);
+
+		if (daemon_in_update && !we_are_in_update) {
 			/*
-			 * Another command is updating the lvmetad cache, and
-			 * we cannot use lvmetad until the update is finished.
-			 * Retry our request for a while; the update should
-			 * finish shortly.  This should not usually happen
-			 * because this command already checked that the token
-			 * is usable in lvmetad_token_matches(), but it's
-			 * possible for another command's rescan to slip in
-			 * between the time we call lvmetad_token_matches()
-			 * and the time we get here to lvmetad_send().
+			 * Another command is updating lvmetad, and we cannot
+			 * use lvmetad until the update is finished.  Retry our
+			 * request for a while; the update should finish
+			 * shortly.  This should not usually happen because
+			 * this command already checked that the token is
+			 * usable in lvmetad_token_matches(), but it's possible
+			 * for another command's rescan to slip in between the
+			 * time we call lvmetad_token_matches() and the time we
+			 * get here to lvmetad_send().
 			 */
+
 			if (!(now = _monotonic_seconds()))
 				goto out;
 
@@ -472,61 +495,122 @@ retry:
 			usleep(delay_usec);
 			daemon_reply_destroy(reply);
 			goto retry;
+
 		} else {
-			/*
-			 * Another command has updated the lvmetad cache, and
-			 * has done so using a different device filter from our
-			 * own, which has made the lvmetad token and our token
-			 * not match.  This should not usually happen because
-			 * this command has already checked for a matching token
-			 * in lvmetad_token_matches(), but it's possible for
-			 * another command's rescan to slip in between the time
-			 * we call lvmetad_token_matches() and the time we get
-			 * here to lvmetad_send().  With a mismatched token
-			 * (different set of devices), we cannot use the lvmetad
-			 * cache.
-			 *
-			 * FIXME: it would be nice to have this command ignore
-			 * lvmetad at this point and revert to disk scanning,
-			 * but the layers above lvmetad_send are not yet able
-			 * to switch modes in the middle of processing.
-			 *
-			 * (The advantage of lvmetad_check_token is that it
-			 * can rescan to get the token in sync, or if that
-			 * fails it can make the command revert to scanning
-			 * from the start.)
-			 */
-			log_warn("WARNING: Cannot use lvmetad while it caches different devices.");
+			/* See lvmetad_handle_reply for handling other cases. */
 		}
 	}
 out:
 	return reply;
 }
 
+/*
+ * token_update happens when starting or ending an lvmetad update.
+ * When starting we set the token to "update in progress".
+ * When ending we set the token to our filter:<hash>.
+ *
+ * From the perspective of a command, the lvmetad state is one of:
+ * "none" - the lvmetad cache is not populated and an update is required.
+ * "filter:<matching_hash>" - the command with can use the lvmetad cache.
+ * "filter:<unmatching_hash>" - the lvmetad cache must be updated to be used.
+ * "update in progress" - a command is updating the lvmetad cache.
+ *
+ * . If none, the command will update (scan and populate lvmetad),
+ *   then use the cache.
+ *
+ * . If filter is matching, the command will use the cache.
+ *
+ * . If filter is unmatching, the command will update (scan and
+ *   populate lvmetad), then use the cache.
+ *
+ * . If update in progress, the command will wait for a while for the state
+ *   to become non-updating.  If it changes, see above, if it doesn't change,
+ *   then the command either reverts to not using lvmetad, or does an update
+ *   (scan and populate lvmetad) and then uses the cache.
+ *
+ * A command that is explicitly intended to update the cache will always do
+ * that (it may wait for a while first to allow a current update to complete).
+ * A command that is not explicitly intended to update the cache may choose
+ * to revert to scanning and not use lvmetad.
+ *
+ * Because two different updates from two commands can potentially overlap,
+ * lvmetad saves the pid of the latest update to start, so it can reject messages
+ * from preempted updates.  This prevents an invalid mix of two different updates.
+ * (The command makes use of the update_pid to print more informative messages.)
+ *
+ * If lvmetad detects that a command doing an update is taking too long, it will
+ * change the token from "update in progress" to "none", which means a new update
+ * is required, causing the next command to do an update.  This effectively
+ * cancels/preempts a slow/stuck update, and helps to automatically resolve
+ * some failure cases.
+ */
+
 static int _token_update(int *replaced_update)
 {
 	daemon_reply reply;
+	const char *token_expected;
 	const char *prev_token;
+	int update_pid;
+	int ending_our_update;
 
-	log_debug_lvmetad("Sending updated token to lvmetad: %s", _lvmetad_token ? : "<NONE>");
+	log_debug_lvmetad("Sending lvmetad token_update %s", _lvmetad_token);
 	reply = _lvmetad_send(NULL, "token_update", NULL);
 
 	if (replaced_update)
 		*replaced_update = 0;
 
-	if (reply.error || strcmp(daemon_reply_str(reply, "response", ""), "OK")) {
+	if (reply.error) {
+		log_warn("WARNING: lvmetad token update error: %s", strerror(reply.error));
+		daemon_reply_destroy(reply);
+		return 0;
+	}
+
+	update_pid = (int)daemon_reply_int(reply, "update_pid", 0);
+
+	/*
+	 * A mismatch can only happen when this command attempts to set the
+	 * token to filter:<hash> at the end of its update, but the update has
+	 * been preempted in lvmetad by a new one (from update_pid).
+	 */
+	if (!strcmp(daemon_reply_str(reply, "response", ""), "token_mismatch")) {
+		token_expected = daemon_reply_str(reply, "expected", "");
+
+		ending_our_update = strcmp(_lvmetad_token, LVMETAD_TOKEN_UPDATE_IN_PROGRESS);
+
+		log_debug_lvmetad("Received token update mismatch expected \"%s\" our token \"%s\" update_pid %d our pid %d",
+				  token_expected, _lvmetad_token, update_pid, getpid());
+
+		if (ending_our_update && (update_pid != getpid())) {
+			log_warn("WARNING: lvmetad was updated by another command (pid %d).", update_pid);
+		} else {
+			/*
+			 * Shouldn't happen.
+			 * If we're ending our update and our pid matches the update_pid,
+			 * then there would not be a mismatch.
+			 * If we're starting a new update, lvmetad never returns a
+			 * token mismatch.
+			 * In any case, it doesn't hurt to just return an error here.
+			 */
+			log_error(INTERNAL_ERROR "lvmetad token update mismatch pid %d matches our own pid %d", update_pid, getpid());
+		}
+
+		daemon_reply_destroy(reply);
+		return 0;
+	}
+
+	if (strcmp(daemon_reply_str(reply, "response", ""), "OK")) {
+		log_error("Failed response from lvmetad for token update.");
 		daemon_reply_destroy(reply);
 		return 0;
 	}
 
 	if ((prev_token = daemon_reply_str(reply, "prev_token", NULL))) {
 		if (!strcmp(prev_token, LVMETAD_TOKEN_UPDATE_IN_PROGRESS))
-			if (replaced_update)
+			if (replaced_update && (update_pid != getpid()))
 				*replaced_update = 1;
 	}
 
 	daemon_reply_destroy(reply);
-
 	return 1;
 }
 
@@ -539,8 +623,12 @@ static int _token_update(int *replaced_update)
  */
 static int _lvmetad_handle_reply(daemon_reply reply, const char *id, const char *object, int *found)
 {
-	int action_modifies = 0;
+	const char *token_expected;
 	const char *action;
+	int action_modifies = 0;
+	int daemon_in_update;
+	int we_are_in_update;
+	int update_pid;
 
 	if (!id)
 		action = "<none>";
@@ -574,33 +662,111 @@ static int _lvmetad_handle_reply(daemon_reply reply, const char *id, const char
 	}
 
 	if (reply.error) {
-		log_error("Request to %s %s%sin lvmetad gave response %s.",
-			  action, object, *object ? " " : "", strerror(reply.error));
+		log_warn("WARNING: lvmetad cannot be used due to error: %s", strerror(reply.error));
 		goto fail;
 	}
 
 	/*
-	 * See the description of the token mismatch errors in lvmetad_send.
+	 * Errors related to token mismatch.
 	 */
+
 	if (!strcmp(daemon_reply_str(reply, "response", ""), "token_mismatch")) {
-		if (!strcmp(daemon_reply_str(reply, "expected", ""), LVMETAD_TOKEN_UPDATE_IN_PROGRESS)) {
+
+		token_expected = daemon_reply_str(reply, "expected", "");
+		update_pid = (int)daemon_reply_int(reply, "update_pid", 0);
+
+		log_debug("lvmetad token mismatch, expected \"%s\" our token \"%s\"",
+			  token_expected, _lvmetad_token);
+
+		daemon_in_update = !strcmp(token_expected, LVMETAD_TOKEN_UPDATE_IN_PROGRESS);
+		we_are_in_update = !strcmp(_lvmetad_token, LVMETAD_TOKEN_UPDATE_IN_PROGRESS);
+
+		if (daemon_in_update && we_are_in_update) {
+
 			/*
-			 * lvmetad_send retried up to the limit and eventually
-			 * printed a warning and gave up.
+			 * When we do not match the update_pid, it means our
+			 * update was cancelled and another process is now
+			 * updating the cache.
 			 */
-			log_error("Request to %s %s%sin lvmetad failed after lvmetad_update_wait_time expired.",
-				  action, object, *object ? " " : "");
-		} else {
+
+			if (update_pid != getpid()) {
+				log_warn("WARNING: lvmetad is being updated by another command (pid %d).", update_pid);
+			} else {
+				/* Shouldn't happen */
+				log_error(INTERNAL_ERROR "lvmetad update by pid %d matches our own pid %d", update_pid, getpid());
+			}
+			/* We don't care if the action was modifying during a token update. */
+			action_modifies = 0;
+			goto fail;
+
+		} else if (daemon_in_update && !we_are_in_update) {
+
+			/*
+			 * Another command is updating lvmetad, and we cannot
+			 * use lvmetad until the update is finished.
+			 * lvmetad_send resent this message up to the limit and
+			 * eventually gave up.  The caller may choose to not
+			 * use lvmetad at this point and revert to scanning.
+			 */
+
+			log_warn("WARNING: lvmetad is being updated and cannot be used.");
+			goto fail;
+
+		} else if (!daemon_in_update && we_are_in_update) {
+
+			/*
+			 * We are updating lvmetad after setting the token to
+			 * "update in progress", but lvmetad has a non-update
+			 * token and is rejecting our update messages.  This
+			 * must mean that lvmetad cancelled our update (we were
+			 * probably too slow, taking longer than the timeout),
+			 * so another command completed an update and set the
+			 * token based on its filter.  Here we've attempt to
+			 * continue our cache update, and find we've been
+			 * preempted, so we should just abort our failed
+			 * update.
+			 */
+
+			log_warn("WARNING: lvmetad was updated by another command.");
+			/* We don't care if the action was modifying during a token update. */
+			action_modifies = 0;
+			goto fail;
+
+		} else if (!daemon_in_update && !we_are_in_update) {
+
 			/*
-			 * lvmetad is caching different devices based on a different
-			 * device filter which causes a token mismatch.
+			 * Another command has updated the lvmetad cache, and
+			 * has done so using a different device filter from our
+			 * own, which has made the lvmetad token and our token
+			 * not match.  This should not usually happen because
+			 * this command has already checked for a matching token
+			 * in lvmetad_token_matches(), but it's possible for
+			 * another command's rescan to slip in between the time
+			 * we call lvmetad_token_matches() and the time we get
+			 * here to lvmetad_send().  With a mismatched token
+			 * (different set of devices), we cannot use the lvmetad
+			 * cache.
+			 *
+			 * FIXME: it would be nice to have this command ignore
+			 * lvmetad at this point and revert to disk scanning,
+			 * but the layers above lvmetad_send are not yet able
+			 * to switch modes in the middle of processing.
+			 *
+			 * (The advantage of lvmetad_check_token is that it
+			 * can rescan to get the token in sync, or if that
+			 * fails it can make the command revert to scanning
+			 * from the start.)
 			 */
-			log_error("Request to %s %s%sin lvmetad failed after device filter mismatch.",
-				  action, object, *object ? " " : "");
+
+			log_warn("WARNING: Cannot use lvmetad while it caches different devices.");
+			goto fail;
 		}
-		goto fail;
 	}
 
+	/*
+	 * Non-token-mismatch related error checking.
+	 */
+
 	/* All OK? */
 	if (!strcmp(daemon_reply_str(reply, "response", ""), "OK")) {
 		if (found)
@@ -634,14 +800,20 @@ static int _lvmetad_handle_reply(daemon_reply reply, const char *id, const char
 		  daemon_reply_str(reply, "reason", "<missing>"));
 fail:
 	/*
-	 * If the failed lvmetad message was updating lvmetad, it is important
-	 * to restart lvmetad (or at least rescan.)
-	 *
-	 * FIXME: attempt to set the disabled state in lvmetad here so that
-	 * commands will not use it until it's been properly repopulated.
+	 * If the failed lvmetad message was updating lvmetad with new metadata
+	 * that has been changed by this command, it is important to restart
+	 * lvmetad (or at least rescan.)  (An lvmetad update that is just
+	 * scanning disks to populate the cache is not a problem, so we try to
+	 * avoid printing a "corruption" warning in that case.)
 	 */
-	if (action_modifies)
+
+	if (action_modifies) {
+		/*
+		 * FIXME: experiment with killing the lvmetad process here, e.g.
+		 * kill(_lvmetad_daemon_pid, SIGKILL);
+		 */
 		log_warn("WARNING: To avoid corruption, restart lvmetad (or disable with use_lvmetad=0).");
+	}
 
 	return 0;
 }
@@ -1617,7 +1789,6 @@ int lvmetad_pvscan_single(struct cmd_context *cmd, struct device *dev,
 	struct _lvmetad_pvscan_baton baton;
 	/* Create a dummy instance. */
 	struct format_instance_ctx fic = { .type = 0 };
-	struct metadata_area *mda;
 
 	if (!lvmetad_used()) {
 		log_error("Cannot proceed since lvmetad is not active.");
@@ -1644,24 +1815,15 @@ int lvmetad_pvscan_single(struct cmd_context *cmd, struct device *dev,
 		log_warn("WARNING: Disabling lvmetad cache which does not support obsolete (lvm1) metadata.");
 		lvmetad_set_disabled(cmd, LVMETAD_DISABLE_REASON_LVM1);
 		_found_lvm1_metadata = 1;
+		/*
+		 * return 1 (success) so that we'll continue to populate lvmetad
+		 * instead of leaving the update incomplete.
+		 */
 		return 1;
 	}
 
 	lvmcache_foreach_mda(info, _lvmetad_pvscan_single, &baton);
 
-	/*
-	 * LVM1 VGs have no MDAs and lvmcache_foreach_mda isn't worth fixing
-	 * to use pseudo-mdas for PVs.
-	 * Note that the single_device parameter also gets ignored and this code
-	 * can scan further devices.
-	 */
-	if (!baton.vg && !(baton.fid->fmt->features & FMT_MDAS)) {
-		/* This code seems to be unreachable */
-		if ((mda = (struct metadata_area *)dm_list_first(&baton.fid->metadata_areas_in_use)))
-			baton.vg = mda->ops->vg_read(baton.fid, lvmcache_vgname_from_info(info),
-						     mda, NULL, NULL, 1);
-	}
-
 	if (!baton.vg)
 		lvmcache_fmt(info)->ops->destroy_instance(baton.fid);
 
@@ -1758,12 +1920,12 @@ int lvmetad_pvscan_all_devs(struct cmd_context *cmd, int do_wait)
 	if (!replacing_other_update && replaced_update) {
 		if (do_wait && !retries) {
 			retries = 1;
-			log_warn("WARNING: lvmetad update in progress, retry update.");
+			log_warn("WARNING: lvmetad update in progress, retrying update.");
 			dev_iter_destroy(iter);
 			_lvmetad_token = future_token;
 			goto retry;
 		}
-		log_error("Concurrent lvmetad updates failed.");
+		log_warn("WARNING: lvmetad update in progress, skipping update.");
 		dev_iter_destroy(iter);
 		_lvmetad_token = future_token;
 		return 0;
@@ -1784,8 +1946,12 @@ int lvmetad_pvscan_all_devs(struct cmd_context *cmd, int do_wait)
 			stack;
 			break;
 		}
-		if (!lvmetad_pvscan_single(cmd, dev, NULL, NULL))
+
+		if (!lvmetad_pvscan_single(cmd, dev, NULL, NULL)) {
 			ret = 0;
+			stack;
+			break;
+		}
 	}
 
 	init_silent(was_silent);
@@ -1793,6 +1959,17 @@ int lvmetad_pvscan_all_devs(struct cmd_context *cmd, int do_wait)
 	dev_iter_destroy(iter);
 
 	_lvmetad_token = future_token;
+
+	/*
+	 * If we failed to fully and successfully populate lvmetad just leave
+	 * the existing "update in progress" token in place so lvmetad will
+	 * time out our update and force another command to do it.
+	 * (We could try to set the token to empty here, but that doesn't
+	 * help much.)
+	 */
+	if (!ret)
+		return 0;
+
 	if (!_token_update(NULL)) {
 		log_error("Failed to update lvmetad token after device scan.");
 		return 0;
@@ -1802,7 +1979,7 @@ int lvmetad_pvscan_all_devs(struct cmd_context *cmd, int do_wait)
 	 * If lvmetad is disabled, and no lvm1 metadata was seen and no
 	 * duplicate PVs were seen, then re-enable lvmetad.
 	 */
-	if (ret && lvmetad_is_disabled(cmd, &reason) &&
+	if (lvmetad_is_disabled(cmd, &reason) &&
 	    !lvmcache_found_duplicate_pvs() && !_found_lvm1_metadata) {
 		log_debug_lvmetad("Enabling lvmetad which was previously disabled.");
 		lvmetad_clear_disabled(cmd);
@@ -1820,6 +1997,7 @@ int lvmetad_vg_clear_outdated_pvs(struct volume_group *vg)
 	if (!id_write_format(&vg->id, uuid, sizeof(uuid)))
 		return_0;
 
+	log_debug_lvmetad("Sending lvmetad vg_clear_outdated_pvs");
 	reply = _lvmetad_send(vg->cmd, "vg_clear_outdated_pvs", "vgid = %s", uuid, NULL);
 	result = _lvmetad_handle_reply(reply, "vg_clear_outdated_pvs", vg->name, NULL);
 	daemon_reply_destroy(reply);
@@ -2057,6 +2235,8 @@ void lvmetad_validate_global_cache(struct cmd_context *cmd, int force)
 
 	reply = daemon_send_simple(_lvmetad, "get_global_info",
 				   "token = %s", "skip",
+				   "pid = " FMTd64, (int64_t)getpid(),
+				   "cmd = %s", get_cmd_name(),
 				   NULL);
 
 	if (reply.error) {
@@ -2115,6 +2295,8 @@ void lvmetad_validate_global_cache(struct cmd_context *cmd, int force)
 	reply = daemon_send_simple(_lvmetad, "set_global_info",
 				   "token = %s", "skip",
 				   "global_invalid = " FMTd64, INT64_C(0),
+				   "pid = " FMTd64, (int64_t)getpid(),
+				   "cmd = %s", get_cmd_name(),
 				   NULL);
 	if (reply.error)
 		log_error("lvmetad_validate_global_cache set_global_info error %d", reply.error);
@@ -2161,6 +2343,7 @@ int lvmetad_vg_is_foreign(struct cmd_context *cmd, const char *vgname, const cha
 	if (!id_write_format((const struct id*)vgid, uuid, sizeof(uuid)))
 		return_0;
 
+	log_debug_lvmetad("Sending lvmetad vg_clear_outdated_pvs");
 	reply = _lvmetad_send(cmd, "vg_lookup",
 			      "uuid = %s", uuid,
 			      "name = %s", vgname,
@@ -2321,12 +2504,14 @@ void lvmetad_set_disabled(struct cmd_context *cmd, const char *reason)
 	if (!_lvmetad_use)
 		return;
 
-	log_debug_lvmetad("lvmetad send disabled %s", reason);
+	log_debug_lvmetad("Sending lvmetad disabled %s", reason);
 
 	reply = daemon_send_simple(_lvmetad, "set_global_info",
 				   "token = %s", "skip",
 				   "global_disable = " FMTd64, (int64_t)1,
 				   "disable_reason = %s", reason,
+				   "pid = " FMTd64, (int64_t)getpid(),
+				   "cmd = %s", get_cmd_name(),
 				   NULL);
 	if (reply.error)
 		log_error("Failed to send message to lvmetad %d", reply.error);
@@ -2344,11 +2529,13 @@ void lvmetad_clear_disabled(struct cmd_context *cmd)
 	if (!_lvmetad_use)
 		return;
 
-	log_debug_lvmetad("lvmetad send disabled 0");
+	log_debug_lvmetad("Sending lvmetad disabled 0");
 
 	reply = daemon_send_simple(_lvmetad, "set_global_info",
 				   "token = %s", "skip",
 				   "global_disable = " FMTd64, (int64_t)0,
+				   "pid = " FMTd64, (int64_t)getpid(),
+				   "cmd = %s", get_cmd_name(),
 				   NULL);
 	if (reply.error)
 		log_error("Failed to send message to lvmetad %d", reply.error);
@@ -2367,6 +2554,8 @@ int lvmetad_is_disabled(struct cmd_context *cmd, const char **reason)
 
 	reply = daemon_send_simple(_lvmetad, "get_global_info",
 				   "token = %s", "skip",
+				   "pid = " FMTd64, (int64_t)getpid(),
+				   "cmd = %s", get_cmd_name(),
 				   NULL);
 
 	if (reply.error) {


