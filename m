From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 13 Apr 2016 19:06:38 +0000 (UTC)
Subject: master - lvmetad: preemptively check and rescan in commands
Message-ID: <20160413190638.7B16560645@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=56c68b3476f52a07c877496a07ebef619724e224
Commit:        56c68b3476f52a07c877496a07ebef619724e224
Parent:        a28c81cbae308e371ece31679615d673b29fccec
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jan 28 16:40:26 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Apr 13 14:05:42 2016 -0500

lvmetad: preemptively check and rescan in commands

Move checking the lvmetad state, and the possible rescan,
out of lvmetad_send() to the start of the command.

Previously, the token mismatch and rescan would occur
within lvmetad_send() for some other request.  Now,
the token mismatch is detected earlier, so the
rescan can be done before the main command is in
progress.  Rescanning deep within the processing of
another command will disturb the lvmcache state of
that other command.

A rescan already exists at the start of the command
for the case where foreign VGs are going to be read.
This same rescan is now also performed when there is
an lvmetad token mismatch (from a changed global_filter).

The commands pvscan/vgscan/lvscan/vgimport are excluded
from this preemptive checking/rescanning for lvmetad
because they want to do rescanning themselves explicitly.

If rescanning devices fails, then lvmetad has not been
correctly repopulated and should not be used, so make
the command revert to not using lvmetad.
---
 daemons/lvmetad/lvmetad-core.c |   21 ++-
 lib/cache/lvmetad.c            |  571 +++++++++++++++++++++++++++++++++-------
 lib/cache/lvmetad.h            |    6 +-
 lib/config/config_settings.h   |    5 +
 lib/config/defaults.h          |    1 +
 tools/commands.h               |    8 +-
 tools/lvmcmdline.c             |   25 ++-
 tools/lvscan.c                 |   20 ++-
 tools/pvscan.c                 |   30 ++-
 tools/tools.h                  |    2 +
 tools/vgimport.c               |    8 +-
 tools/vgscan.c                 |   21 +-
 12 files changed, 593 insertions(+), 125 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 5374c0a..090255a 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -2614,10 +2614,25 @@ static response set_global_info(lvmetad_state *s, request r)
 	return daemon_reply_simple("OK", NULL);
 }
 
+#define REASON_BUF_SIZE 64
+
+/*
+ * FIXME: save the time when "updating" begins, and add a config setting for
+ * how long we'll allow an update to take.  Before returning "updating" as the
+ * token value in get_global_info, check if the update has exceeded the max
+ * allowed time.  If so, then clear the current cache state and return "none"
+ * as the current token value, so that the command will repopulate our cache.
+ *
+ * This will resolve the problem of a command starting to update the cache and
+ * then failing, leaving the token set to "update in progress".
+ */
+
 static response get_global_info(lvmetad_state *s, request r)
 {
 	return daemon_reply_simple("OK", "global_invalid = " FMTd64,
 					 (int64_t)((s->flags & GLFL_INVALID) ? 1 : 0),
+					 "token = %s",
+					 s->token[0] ? s->token : "none",
 					 NULL);
 }
 
@@ -2815,13 +2830,17 @@ static response handler(daemon_state s, client_handle h, request r)
 	lvmetad_state *state = s.private;
 	const char *rq = daemon_request_str(r, "request", "NONE");
 	const char *token = daemon_request_str(r, "token", "NONE");
+	char prev_token[128] = { 0 };
 
 	pthread_mutex_lock(&state->token_lock);
 	if (!strcmp(rq, "token_update")) {
+		memcpy(prev_token, state->token, 128);
 		strncpy(state->token, token, 128);
 		state->token[127] = 0;
 		pthread_mutex_unlock(&state->token_lock);
-		return daemon_reply_simple("OK", NULL);
+		return daemon_reply_simple("OK",
+					   "prev_token = %s", prev_token,
+					   NULL);
 	}
 
 	if (strcmp(token, state->token) && strcmp(rq, "dump") && strcmp(token, "skip")) {
diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index a483e04..8cc804a 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -24,6 +24,8 @@
 #include "lvm-signal.h"
 #include "lvmlockd.h"
 
+#include <time.h>
+
 #define SCAN_TIMEOUT_SECONDS	80
 #define MAX_RESCANS		10	/* Maximum number of times to scan all PVs and retry if the daemon returns a token mismatch error */
 
@@ -37,6 +39,15 @@ static struct cmd_context *_lvmetad_cmd = NULL;
 
 static struct volume_group *lvmetad_pvscan_vg(struct cmd_context *cmd, struct volume_group *vg);
 
+static uint64_t _monotonic_seconds(void)
+{
+	struct timespec ts;
+
+	if (clock_gettime(CLOCK_MONOTONIC, &ts) < 0)
+		return 0;
+	return ts.tv_sec;
+}
+
 static int _log_debug_inequality(const char *name, struct dm_config_node *a, struct dm_config_node *b)
 {
 	int result = 0;
@@ -132,6 +143,9 @@ static void _lvmetad_connect(void)
 				  _lvmetad.socket_fd);
 		_lvmetad_connected = 1;
 	}
+
+	if (!_lvmetad_connected)
+		_lvmetad_use = 0;
 }
 
 void lvmetad_connect_or_warn(void)
@@ -145,6 +159,9 @@ void lvmetad_connect_or_warn(void)
 		if ((_lvmetad.socket_fd < 0 || _lvmetad.error))
 			log_warn("WARNING: Failed to connect to lvmetad. Falling back to internal scanning.");
 	}
+
+	if (!_lvmetad_connected)
+		_lvmetad_use = 0;
 }
 
 int lvmetad_used(void)
@@ -210,82 +227,314 @@ void lvmetad_set_socket(const char *sock)
 	_lvmetad_socket = sock;
 }
 
+/*
+ * Check if lvmetad's token matches our token.  The token is a hash of the
+ * global filter used to populate lvmetad.  The lvmetad token was set by the
+ * last command to populate lvmetad, and it was set to the hash of the global
+ * filter that command used when scanning to populate lvmetad.
+ *
+ * Our token is a hash of the global filter this command is using.
+ *
+ * If the lvmetad token is not set (or "none"), then lvmetad has not been
+ * populated.  If the lvmetad token is "update in progress", then lvmetad is
+ * currently being populated -- this should be temporary, so wait for a while
+ * for the current update to finish and then compare our token with the new one
+ * (hopefully it will match).  If the lvmetad token otherwise differs from
+ * ours, then lvmetad was populated using a different global filter that we are
+ * using.
+ *
+ * Return 1 if the lvmetad token matches ours.  We can use it as is.
+ *
+ * Return 0 if the lvmetad token does not match ours (lvmetad is empty or
+ * populated using a different global filter).  The caller will repopulate
+ * lvmetad (via lvmetad_pvscan_all_devs) before using lvmetad.
+ *
+ * If we time out waiting for an lvmetad update to finish, then disable this
+ * command's use of lvmetad and return 0.
+ */
+
+int lvmetad_token_matches(struct cmd_context *cmd)
+{
+	daemon_reply reply;
+	const char *daemon_token;
+	unsigned int delay_usec = 0;
+	unsigned int wait_sec = 0;
+	uint64_t now = 0, wait_start = 0;
+	int ret = 1;
+
+	wait_sec = (unsigned int)find_config_tree_int(cmd, global_lvmetad_update_wait_time_CFG, NULL);
+
+retry:
+	log_debug_lvmetad("lvmetad send get_global_info");
+
+	reply = daemon_send_simple(_lvmetad, "get_global_info",
+				   "token = %s", "skip",
+				   NULL);
+	if (reply.error) {
+		log_warn("WARNING: Not using lvmetad after send error (%d).", reply.error);
+		goto fail;
+	}
+
+	if (strcmp(daemon_reply_str(reply, "response", ""), "OK")) {
+		log_warn("WARNING: Not using lvmetad after response error.");
+		goto fail;
+	}
+
+	if (!(daemon_token = daemon_reply_str(reply, "token", NULL))) {
+		log_warn("WARNING: Not using lvmetad with older version."); 
+		goto fail;
+	}
+
+	/*
+	 * If lvmetad is being updated by another command, then sleep and retry
+	 * until the token shows the update is done, and go on to the token
+	 * comparison.
+	 *
+	 * Between retries, sleep for a random period between 1 and 2 seconds.
+	 * Retry in this way for up to a configurable period of time.
+	 *
+	 * If lvmetad is still being updated after the timeout period,
+	 * then disable this command's use of lvmetad.
+	 *
+	 * (lvmetad could return the number of objects in its cache along with
+	 * the update message so that callers could detect when a rescan has
+	 * stalled while updating lvmetad.)
+	 */
+	if (!strcmp(daemon_token, "update in progress")) {
+		if (!(now = _monotonic_seconds()))
+			goto fail;
+
+		if (!wait_start)
+			wait_start = now;
+
+		if (now - wait_start >= wait_sec) {
+			log_warn("WARNING: Not using lvmetad after %u sec lvmetad_update_wait_time.", wait_sec);
+			goto fail;
+		}
+
+		log_warn("WARNING: lvmetad is being updated, retrying (setup) for %u more seconds.",
+			 wait_sec - (unsigned int)(now - wait_start));
+
+		/* Delay a random period between 1 and 2 seconds. */
+		delay_usec = 1000000 + lvm_even_rand(&_lvmetad_cmd->rand_seed, 1000000);
+		usleep(delay_usec);
+		daemon_reply_destroy(reply);
+		goto retry;
+	}
+
+	/*
+	 * lvmetad is empty, not yet populated.
+	 * The caller should do a disk scan to populate lvmetad.
+	 */
+	if (!strcmp(daemon_token, "none")) {
+		ret = 0;
+		goto out;
+	}
+
+	/*
+	 * lvmetad has an unmatching token; it was last populated using
+	 * a different global filter.
+	 * The caller should do a disk scan to populate lvmetad with
+	 * our global filter.
+	 */
+	if (strcmp(daemon_token, _lvmetad_token)) {
+		ret = 0;
+		goto out;
+	}
+
+out:
+	daemon_reply_destroy(reply);
+	return ret;
+
+fail:
+	daemon_reply_destroy(reply);
+	/* The command will not use lvmetad and will revert to scanning. */
+	lvmetad_set_active(cmd, 0);
+	return 0;
+}
+
+/*
+ * Wait up to lvmetad_update_wait_time for the lvmetad updating state to be
+ * finished.
+ *
+ * Return 0 if lvmetad is not updating or there's an error and we can't tell.
+ * Return 1 if lvmetad is updating.
+ */
+static int _lvmetad_is_updating(struct cmd_context *cmd, int do_wait)
+{
+	daemon_reply reply;
+	const char *daemon_token;
+	unsigned int wait_sec = 0;
+	uint64_t now = 0, wait_start = 0;
+	int ret = 0;
+
+	wait_sec = (unsigned int)find_config_tree_int(cmd, global_lvmetad_update_wait_time_CFG, NULL);
+retry:
+	log_debug_lvmetad("lvmetad send get_global_info");
+
+	reply = daemon_send_simple(_lvmetad, "get_global_info",
+				   "token = %s", "skip",
+				   NULL);
+	if (reply.error)
+		goto out;
+
+	if (strcmp(daemon_reply_str(reply, "response", ""), "OK"))
+		goto out;
+
+	if (!(daemon_token = daemon_reply_str(reply, "token", NULL)))
+		goto out;
+
+	if (!strcmp(daemon_token, "update in progress")) {
+		ret = 1;
+
+		if (!do_wait)
+			goto out;
+
+		if (!(now = _monotonic_seconds()))
+			goto out;
+
+		if (!wait_start)
+			wait_start = now;
+
+		if (now - wait_start >= wait_sec)
+			goto out;
+
+		log_warn("WARNING: lvmetad is being updated, waiting for %u more seconds.",
+			 wait_sec - (unsigned int)(now - wait_start));
+
+		usleep(1000000);
+		daemon_reply_destroy(reply);
+		goto retry;
+	} else {
+		ret = 0;
+	}
+
+out:
+	daemon_reply_destroy(reply);
+	return ret;
+}
+
 static int _lvmetad_pvscan_all_devs(struct cmd_context *cmd, activation_handler handler,
-				    int ignore_obsolete);
+				    int ignore_obsolete, int do_wait);
 
-static daemon_reply _lvmetad_send(const char *id, ...)
+static daemon_reply _lvmetad_send(struct cmd_context *cmd, const char *id, ...)
 {
 	va_list ap;
-	daemon_reply repl = { 0 };
+	daemon_reply reply = { 0 };
 	daemon_request req;
-	unsigned num_rescans = 0;
-	unsigned total_usecs_waited = 0;
-	unsigned max_remaining_sleep_times = 1;
-	unsigned wait_usecs;
+	unsigned int delay_usec;
+	unsigned int wait_sec = 0;
+	uint64_t now = 0, wait_start = 0;
 
+	if (cmd)
+		wait_sec = (unsigned int)find_config_tree_int(cmd, global_lvmetad_update_wait_time_CFG, NULL);
 retry:
+	log_debug_lvmetad("lvmetad_send %s", id);
+
 	req = daemon_request_make(id);
 
 	if (_lvmetad_token && !daemon_request_extend(req, "token = %s", _lvmetad_token, NULL)) {
-		repl.error = ENOMEM;
-		return repl;
+		reply.error = ENOMEM;
+		return reply;
 	}
 
 	va_start(ap, id);
 	daemon_request_extend_v(req, ap);
 	va_end(ap);
 
-	repl = daemon_send(_lvmetad, req);
+	reply = daemon_send(_lvmetad, req);
 
 	daemon_request_destroy(req);
 
-	/*
-	 * If another process is trying to scan, it might have the
-	 * same future token id and it's better to wait and avoid doing
-	 * the work multiple times. For the case where the future token is
-	 * different, the wait is randomized so that multiple waiting
-	 * processes do not start scanning all at once.
-	 *
-	 * If the token is mismatched because of global_filter changes,
-	 * we re-scan immediately, but if we lose the potential race for
-	 * the update, we back off for a short while (0.05-0.5 seconds) and
-	 * try again.
-	 */
-	if (!repl.error && !strcmp(daemon_reply_str(repl, "response", ""), "token_mismatch") &&
-	    num_rescans < MAX_RESCANS && total_usecs_waited < (SCAN_TIMEOUT_SECONDS * 1000000) && !test_mode()) {
-		if (!strcmp(daemon_reply_str(repl, "expected", ""), "update in progress") ||
-		    max_remaining_sleep_times) {
-			wait_usecs = 50000 + lvm_even_rand(&_lvmetad_cmd->rand_seed, 450000); /* between 0.05s and 0.5s */
-			(void) usleep(wait_usecs);
-			total_usecs_waited += wait_usecs;
-			if (max_remaining_sleep_times)
-				max_remaining_sleep_times--;	/* Sleep once before rescanning the first time, then 5 times each time after that. */
+	if (reply.error)
+		goto out;
+
+	if (!strcmp(daemon_reply_str(reply, "response", ""), "token_mismatch")) {
+		if (!strcmp(daemon_reply_str(reply, "expected", ""), "update in progress")) {
+			/*
+			 * Another command is updating the lvmetad cache, and
+			 * we cannot use lvmetad until the update is finished.
+			 * Retry our request for a while; the update should
+			 * finish shortly.  This should not usually happen
+			 * because this command already checked that the token
+			 * is usable in lvmetad_token_matches(), but it's
+			 * possible for another command's rescan to slip in
+			 * between the time we call lvmetad_token_matches()
+			 * and the time we get here to lvmetad_send().
+			 */
+			if (!(now = _monotonic_seconds()))
+				goto out;
+
+			if (!wait_start)
+				wait_start = now;
+
+			if (!wait_sec || (now - wait_start >= wait_sec)) {
+				log_warn("WARNING: Cannot use lvmetad after %u sec lvmetad_update_wait_time.", wait_sec);
+				goto out;
+			}
+
+			log_warn("WARNING: lvmetad is being updated, retrying (%s) for %u more seconds.",
+				 id, wait_sec - (unsigned int)(now - wait_start));
+
+			/* Delay a random period between 1 and 2 seconds. */
+			delay_usec = 1000000 + lvm_even_rand(&_lvmetad_cmd->rand_seed, 1000000);
+			usleep(delay_usec);
+			daemon_reply_destroy(reply);
+			goto retry;
 		} else {
-			/* If the re-scan fails here, we try again later. */
-			(void) _lvmetad_pvscan_all_devs(_lvmetad_cmd, NULL, 0);
-			num_rescans++;
-			max_remaining_sleep_times = 5;
+			/*
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
+			 */
+			log_warn("WARNING: Cannot use lvmetad while it caches different devices.");
 		}
-		daemon_reply_destroy(repl);
-		goto retry;
 	}
-
-	return repl;
+out:
+	return reply;
 }
 
-static int _token_update(void)
+static int _token_update(int *replaced_update)
 {
-	daemon_reply repl;
+	daemon_reply reply;
+	const char *prev_token;
 
 	log_debug_lvmetad("Sending updated token to lvmetad: %s", _lvmetad_token ? : "<NONE>");
-	repl = _lvmetad_send("token_update", NULL);
+	reply = _lvmetad_send(NULL, "token_update", NULL);
+
+	if (replaced_update)
+		*replaced_update = 0;
 
-	if (repl.error || strcmp(daemon_reply_str(repl, "response", ""), "OK")) {
-		daemon_reply_destroy(repl);
+	if (reply.error || strcmp(daemon_reply_str(reply, "response", ""), "OK")) {
+		daemon_reply_destroy(reply);
 		return 0;
 	}
 
-	daemon_reply_destroy(repl);
+	if ((prev_token = daemon_reply_str(reply, "prev_token", NULL))) {
+		if (!strcmp(prev_token, "update in progress"))
+			if (replaced_update)
+				*replaced_update = 1;
+	}
+
+	daemon_reply_destroy(reply);
 
 	return 1;
 }
@@ -297,13 +546,68 @@ static int _token_update(void)
  * If found is set, *found indicates whether or not device exists,
  * and missing device is not treated as an error.
  */
-static int _lvmetad_handle_reply(daemon_reply reply, const char *action, const char *object,
-				 int *found)
+static int _lvmetad_handle_reply(daemon_reply reply, const char *id, const char *object, int *found)
 {
+	int action_modifies = 0;
+	const char *action;
+
+	if (!id)
+		action = "<none>";
+	else if (!strcmp(id, "pv_list"))
+		action = "list PVs";
+	else if (!strcmp(id, "vg_list"))
+		action = "list VGs";
+	else if (!strcmp(id, "vg_lookup"))
+		action = "lookup VG";
+	else if (!strcmp(id, "pv_lookup"))
+		action = "lookup PV";
+	else if (!strcmp(id, "pv_clear_all"))
+		action = "clear info about all PVs";
+	else if (!strcmp(id, "vg_clear_outdated_pvs"))
+		action = "clear the list of outdated PVs";
+	else if (!strcmp(id, "vg_update")) {
+		action = "update VG";
+		action_modifies = 1;
+	} else if (!strcmp(id, "vg_remove")) {
+		action = "remove VG";
+		action_modifies = 1;
+	} else if (!strcmp(id, "pv_found")) {
+		action = "update PV";
+		action_modifies = 1;
+	} else if (!strcmp(id, "pv_gone")) {
+		action = "drop PV";
+		action_modifies = 1;
+	} else {
+		log_error(INTERNAL_ERROR "Unchecked lvmetad message %s.", id);
+		action = "action unknown";
+	}
+
 	if (reply.error) {
 		log_error("Request to %s %s%sin lvmetad gave response %s.",
 			  action, object, *object ? " " : "", strerror(reply.error));
-		return 0;
+		goto fail;
+	}
+
+	/*
+	 * See the description of the token mismatch errors in lvmetad_send.
+	 */
+	if (!strcmp(daemon_reply_str(reply, "response", ""), "token_mismatch")) {
+		if (!strcmp(daemon_reply_str(reply, "expected", ""), "update in progress")) {
+			/*
+			 * lvmetad_send retried up to the limit and eventually
+			 * printed a warning and gave up.
+			 */
+			log_error("Request to %s %s%sin lvmetad failed after lvmetad_update_wait_time expired.",
+				  action, object, *object ? " " : "");
+		} else {
+			/*
+			 * lvmetad is caching different devices based on a different
+			 * device filter which causes a token mismatch.
+			 */
+			log_error("Request to %s %s%sin lvmetad failed after device filter mismatch.",
+				  action, object, *object ? " " : "");
+		}
+		goto fail;
 	}
 
 	/* All OK? */
@@ -330,10 +634,23 @@ static int _lvmetad_handle_reply(daemon_reply reply, const char *action, const c
 		return 1;
 	}
 
+	/*
+	 * Generic error message for error cases not specifically checked above.
+	 */
 	log_error("Request to %s %s%sin lvmetad gave response %s. Reason: %s",
 		  action, object, *object ? " " : "", 
 		  daemon_reply_str(reply, "response", "<missing>"),
 		  daemon_reply_str(reply, "reason", "<missing>"));
+fail:
+	/*
+	 * If the failed lvmetad message was updating lvmetad, it is important
+	 * to restart lvmetad (or at least rescan.)
+	 *
+	 * FIXME: attempt to set the disabled state in lvmetad here so that
+	 * commands will not use it until it's been properly repopulated.
+	 */
+	if (action_modifies)
+		log_error("lvmetad update failed.  Restart lvmetad immediately.");
 
 	return 0;
 }
@@ -537,7 +854,7 @@ struct volume_group *lvmetad_vg_lookup(struct cmd_context *cmd, const char *vgna
 
 	if (vgid && vgname) {
 		log_debug_lvmetad("Asking lvmetad for VG %s %s", uuid, vgname);
-		reply = _lvmetad_send("vg_lookup",
+		reply = _lvmetad_send(cmd, "vg_lookup",
 				      "uuid = %s", uuid,
 				      "name = %s", vgname,
 				      NULL);
@@ -545,12 +862,12 @@ struct volume_group *lvmetad_vg_lookup(struct cmd_context *cmd, const char *vgna
 
 	} else if (vgid) {
 		log_debug_lvmetad("Asking lvmetad for VG vgid %s", uuid);
-		reply = _lvmetad_send("vg_lookup", "uuid = %s", uuid, NULL);
+		reply = _lvmetad_send(cmd, "vg_lookup", "uuid = %s", uuid, NULL);
 		diag_name = uuid;
 
 	} else if (vgname) {
 		log_debug_lvmetad("Asking lvmetad for VG %s", vgname);
-		reply = _lvmetad_send("vg_lookup", "name = %s", vgname, NULL);
+		reply = _lvmetad_send(cmd, "vg_lookup", "name = %s", vgname, NULL);
 		diag_name = vgname;
 
 	} else {
@@ -558,7 +875,7 @@ struct volume_group *lvmetad_vg_lookup(struct cmd_context *cmd, const char *vgna
 		goto out;
 	}
 
-	if (_lvmetad_handle_reply(reply, "lookup VG", diag_name, &found) && found) {
+	if (_lvmetad_handle_reply(reply, "vg_lookup", diag_name, &found) && found) {
 
 		if ((found == 2) && vgname) {
 			log_error("Multiple VGs found with the same name: %s.", vgname);
@@ -718,10 +1035,10 @@ int lvmetad_vg_update(struct volume_group *vg)
 	}
 
 	log_debug_lvmetad("Sending lvmetad updated metadata for VG %s (seqno %" PRIu32 ")", vg->name, vg->seqno);
-	reply = _lvmetad_send("vg_update", "vgname = %s", vg->name,
+	reply = _lvmetad_send(vg->cmd, "vg_update", "vgname = %s", vg->name,
 			      "metadata = %t", vg->cft_precommitted, NULL);
 
-	if (!_lvmetad_handle_reply(reply, "update VG", vg->name, NULL)) {
+	if (!_lvmetad_handle_reply(reply, "vg_update", vg->name, NULL)) {
 		daemon_reply_destroy(reply);
 		return 0;
 	}
@@ -770,8 +1087,8 @@ int lvmetad_vg_remove(struct volume_group *vg)
 		return_0;
 
 	log_debug_lvmetad("Telling lvmetad to remove VGID %s (%s)", uuid, vg->name);
-	reply = _lvmetad_send("vg_remove", "uuid = %s", uuid, NULL);
-	result = _lvmetad_handle_reply(reply, "remove VG", vg->name, NULL);
+	reply = _lvmetad_send(vg->cmd, "vg_remove", "uuid = %s", uuid, NULL);
+	result = _lvmetad_handle_reply(reply, "vg_remove", vg->name, NULL);
 
 	daemon_reply_destroy(reply);
 
@@ -792,8 +1109,8 @@ int lvmetad_pv_lookup(struct cmd_context *cmd, struct id pvid, int *found)
 		return_0;
 
 	log_debug_lvmetad("Asking lvmetad for PV %s", uuid);
-	reply = _lvmetad_send("pv_lookup", "uuid = %s", uuid, NULL);
-	if (!_lvmetad_handle_reply(reply, "lookup PV", "", found))
+	reply = _lvmetad_send(cmd, "pv_lookup", "uuid = %s", uuid, NULL);
+	if (!_lvmetad_handle_reply(reply, "pv_lookup", "", found))
 		goto_out;
 
 	if (found && !*found)
@@ -823,8 +1140,8 @@ int lvmetad_pv_lookup_by_dev(struct cmd_context *cmd, struct device *dev, int *f
 		return_0;
 
 	log_debug_lvmetad("Asking lvmetad for PV on %s", dev_name(dev));
-	reply = _lvmetad_send("pv_lookup", "device = %" PRId64, (int64_t) dev->dev, NULL);
-	if (!_lvmetad_handle_reply(reply, "lookup PV", dev_name(dev), found))
+	reply = _lvmetad_send(cmd, "pv_lookup", "device = %" PRId64, (int64_t) dev->dev, NULL);
+	if (!_lvmetad_handle_reply(reply, "pv_lookup", dev_name(dev), found))
 		goto_out;
 
 	if (found && !*found)
@@ -852,8 +1169,8 @@ int lvmetad_pv_list_to_lvmcache(struct cmd_context *cmd)
 		return 1;
 
 	log_debug_lvmetad("Asking lvmetad for complete list of known PVs");
-	reply = _lvmetad_send("pv_list", NULL);
-	if (!_lvmetad_handle_reply(reply, "list PVs", "", NULL)) {
+	reply = _lvmetad_send(cmd, "pv_list", NULL);
+	if (!_lvmetad_handle_reply(reply, "pv_list", "", NULL)) {
 		daemon_reply_destroy(reply);
 		return_0;
 	}
@@ -877,8 +1194,8 @@ int lvmetad_get_vgnameids(struct cmd_context *cmd, struct dm_list *vgnameids)
 	struct dm_config_node *cn;
 
 	log_debug_lvmetad("Asking lvmetad for complete list of known VG ids/names");
-	reply = _lvmetad_send("vg_list", NULL);
-	if (!_lvmetad_handle_reply(reply, "list VGs", "", NULL)) {
+	reply = _lvmetad_send(cmd, "vg_list", NULL);
+	if (!_lvmetad_handle_reply(reply, "vg_list", "", NULL)) {
 		daemon_reply_destroy(reply);
 		return_0;
 	}
@@ -930,8 +1247,8 @@ int lvmetad_vg_list_to_lvmcache(struct cmd_context *cmd)
 		return 1;
 
 	log_debug_lvmetad("Asking lvmetad for complete list of known VGs");
-	reply = _lvmetad_send("vg_list", NULL);
-	if (!_lvmetad_handle_reply(reply, "list VGs", "", NULL)) {
+	reply = _lvmetad_send(cmd, "vg_list", NULL);
+	if (!_lvmetad_handle_reply(reply, "vg_list", "", NULL)) {
 		daemon_reply_destroy(reply);
 		return_0;
 	}
@@ -1089,7 +1406,7 @@ int lvmetad_pv_found(const struct id *pvid, struct device *dev, const struct for
 		}
 
 		log_debug_lvmetad("Telling lvmetad to store PV %s (%s) in VG %s", dev_name(dev), uuid, vg->name);
-		reply = _lvmetad_send("pv_found",
+		reply = _lvmetad_send(vg->cmd, "pv_found",
 				      "pvmeta = %t", pvmeta,
 				      "vgname = %s", vg->name,
 				      "metadata = %t", vgmeta,
@@ -1101,12 +1418,12 @@ int lvmetad_pv_found(const struct id *pvid, struct device *dev, const struct for
 		 * It might or might not be an orphan.
 		 */
 		log_debug_lvmetad("Telling lvmetad to store PV %s (%s)", dev_name(dev), uuid);
-		reply = _lvmetad_send("pv_found", "pvmeta = %t", pvmeta, NULL);
+		reply = _lvmetad_send(NULL, "pv_found", "pvmeta = %t", pvmeta, NULL);
 	}
 
 	dm_config_destroy(pvmeta);
 
-	result = _lvmetad_handle_reply(reply, "update PV", uuid, NULL);
+	result = _lvmetad_handle_reply(reply, "pv_found", uuid, NULL);
 
 	if (vg && result &&
 	    (daemon_reply_int(reply, "seqno_after", -1) != vg->seqno ||
@@ -1196,9 +1513,9 @@ int lvmetad_pv_gone(dev_t devno, const char *pv_name, activation_handler handler
 	 */
 
 	log_debug_lvmetad("Telling lvmetad to forget any PV on %s", pv_name);
-	reply = _lvmetad_send("pv_gone", "device = %" PRId64, (int64_t) devno, NULL);
+	reply = _lvmetad_send(NULL, "pv_gone", "device = %" PRId64, (int64_t) devno, NULL);
 
-	result = _lvmetad_handle_reply(reply, "drop PV", pv_name, &found);
+	result = _lvmetad_handle_reply(reply, "pv_gone", pv_name, &found);
 	/* We don't care whether or not the daemon had the PV cached. */
 
 	daemon_reply_destroy(reply);
@@ -1431,15 +1748,36 @@ int lvmetad_pvscan_single(struct cmd_context *cmd, struct device *dev,
 	return 1;
 
 bad:
-	/* FIXME kill lvmetad automatically if we can */
-	log_error("Update of lvmetad failed. This is a serious problem.\n"
-		  "It is strongly recommended that you restart lvmetad immediately.");
-
 	return 0;
 }
 
+/*
+ * Update the lvmetad cache: clear the current lvmetad cache, and scan all
+ * devs, sending all info from the devs to lvmetad.
+ *
+ * We want only one command to be doing this at a time.  When do_wait is set,
+ * this will first check if lvmetad is currently being updated by another
+ * command, and if so it will delay until that update is finished, or until a
+ * timeout, at which point it will go ahead and do the lvmetad update.
+ *
+ * Callers that have already checked and waited for the updating state, e.g. by
+ * using lvmetad_token_matches(), will generaly set do_wait to 0.  Callers that
+ * have not checked for the updating state yet will generally set do_wait to 1.
+ *
+ * If another command doing an update failed, it left lvmetad in the "update in
+ * progess" state, so we can't just wait until that state has cleared, but have
+ * to go ahead after a timeout.
+ *
+ * The _lvmetad_is_updating check avoids most races to update lvmetad from
+ * multiple commands (which shouldn't generally happen anway) but does not
+ * eliminate them.  If an update race happens, the second will see that the
+ * previous token was "update in progress" when it calls _token_update().  It
+ * will then fail, and the command calling lvmetad_pvscan_all_devs() will
+ * generally revert disk scanning and not use lvmetad.
+ */
+
 static int _lvmetad_pvscan_all_devs(struct cmd_context *cmd, activation_handler handler,
-				    int ignore_obsolete)
+				    int ignore_obsolete, int do_wait)
 {
 	struct dev_iter *iter;
 	struct device *dev;
@@ -1447,12 +1785,27 @@ static int _lvmetad_pvscan_all_devs(struct cmd_context *cmd, activation_handler
 	int r = 1;
 	char *future_token;
 	int was_silent;
+	int replacing_other_update = 0;
+	int replaced_update = 0;
+	int retries = 0;
 
 	if (!lvmetad_active()) {
 		log_error("Cannot proceed since lvmetad is not active.");
 		return 0;
 	}
 
+ retry:
+	/*
+	 * If another update is in progress, delay to allow it to finish,
+	 * rather than interrupting it with our own update.
+	 */
+	if (do_wait && _lvmetad_is_updating(cmd, 1)) {
+		log_warn("WARNING: lvmetad update is interrupting another update in progress.");
+		replacing_other_update = 1;
+	}
+
+	log_verbose("Scanning all devices to update lvmetad.");
+
 	if (!(iter = dev_iter_create(cmd->lvmetad_filter, 1))) {
 		log_error("dev_iter creation failed");
 		return 0;
@@ -1460,15 +1813,38 @@ static int _lvmetad_pvscan_all_devs(struct cmd_context *cmd, activation_handler
 
 	future_token = _lvmetad_token;
 	_lvmetad_token = (char *) "update in progress";
-	if (!_token_update()) {
+
+	if (!_token_update(&replaced_update)) {
+		log_error("Failed to update lvmetad which had an update in progress.");
+		dev_iter_destroy(iter);
+		_lvmetad_token = future_token;
+		return 0;
+	}
+
+	/*
+	 * if _token_update() sets replaced_update to 1, it means that we set
+	 * "update in progress" when the lvmetad was already set to "udpate in
+	 * progress".  This detects a race between two commands doing updates
+	 * at once.  The attempt above to avoid this race using
+	 * _lvmetad_is_updating isn't perfect.
+	 */
+	if (!replacing_other_update && replaced_update) {
+		if (do_wait && !retries) {
+			retries = 1;
+			log_warn("WARNING: lvmetad update in progress, retry update.");
+			dev_iter_destroy(iter);
+			_lvmetad_token = future_token;
+			goto retry;
+		}
+		log_error("Concurrent lvmetad updates failed.");
 		dev_iter_destroy(iter);
 		_lvmetad_token = future_token;
 		return 0;
 	}
 
 	log_debug_lvmetad("Telling lvmetad to clear its cache");
-	reply = _lvmetad_send("pv_clear_all", NULL);
-	if (!_lvmetad_handle_reply(reply, "clear info about all PVs", "", NULL))
+	reply = _lvmetad_send(cmd, "pv_clear_all", NULL);
+	if (!_lvmetad_handle_reply(reply, "pv_clear_all", "", NULL))
 		r = 0;
 	daemon_reply_destroy(reply);
 
@@ -1490,15 +1866,15 @@ static int _lvmetad_pvscan_all_devs(struct cmd_context *cmd, activation_handler
 	dev_iter_destroy(iter);
 
 	_lvmetad_token = future_token;
-	if (!_token_update())
+	if (!_token_update(NULL))
 		return 0;
 
 	return r;
 }
 
-int lvmetad_pvscan_all_devs(struct cmd_context *cmd, activation_handler handler)
+int lvmetad_pvscan_all_devs(struct cmd_context *cmd, activation_handler handler, int do_wait)
 {
-	return _lvmetad_pvscan_all_devs(cmd, handler, 0);
+	return _lvmetad_pvscan_all_devs(cmd, handler, 0, do_wait);
 }
 
 /* 
@@ -1507,7 +1883,7 @@ int lvmetad_pvscan_all_devs(struct cmd_context *cmd, activation_handler handler)
  */
 int lvmetad_pvscan_foreign_vgs(struct cmd_context *cmd, activation_handler handler)
 {
-	return _lvmetad_pvscan_all_devs(cmd, handler, 1);
+	return _lvmetad_pvscan_all_devs(cmd, handler, 1, 1);
 }
 
 int lvmetad_vg_clear_outdated_pvs(struct volume_group *vg)
@@ -1519,8 +1895,8 @@ int lvmetad_vg_clear_outdated_pvs(struct volume_group *vg)
 	if (!id_write_format(&vg->id, uuid, sizeof(uuid)))
 		return_0;
 
-	reply = _lvmetad_send("vg_clear_outdated_pvs", "vgid = %s", uuid, NULL);
-	result = _lvmetad_handle_reply(reply, "clear the list of outdated PVs", vg->name, NULL);
+	reply = _lvmetad_send(vg->cmd, "vg_clear_outdated_pvs", "vgid = %s", uuid, NULL);
+	result = _lvmetad_handle_reply(reply, "vg_clear_outdated_pvs", vg->name, NULL);
 	daemon_reply_destroy(reply);
 
 	return result;
@@ -1555,9 +1931,8 @@ static int _lvmetad_get_pv_cache_list(struct cmd_context *cmd, struct dm_list *p
 
 	log_debug_lvmetad("Asking lvmetad for complete list of known PVs");
 
-	reply = _lvmetad_send("pv_list", NULL);
-	if (!_lvmetad_handle_reply(reply, "list PVs", "", NULL)) {
-		log_error("lvmetad message failed.");
+	reply = _lvmetad_send(cmd, "pv_list", NULL);
+	if (!_lvmetad_handle_reply(reply, "pv_list", "", NULL)) {
 		daemon_reply_destroy(reply);
 		return_0;
 	}
@@ -1752,6 +2127,8 @@ void lvmetad_validate_global_cache(struct cmd_context *cmd, int force)
 	if (force)
 		goto do_scan;
 
+	log_debug_lvmetad("lvmetad validate send get_global_info");
+
 	reply = daemon_send_simple(_lvmetad, "get_global_info",
 				   "token = %s", "skip",
 				   NULL);
@@ -1782,10 +2159,18 @@ void lvmetad_validate_global_cache(struct cmd_context *cmd, int force)
 
 	/*
 	 * Update the local lvmetad cache so it correctly reflects any
-	 * changes made on remote hosts.
+	 * changes made on remote hosts.  (It's possible that this command
+	 * already refreshed the local lvmetad because of a token change,
+	 * but we need to do it again here since we now hold the global
+	 * lock.  Another host may have changed things between the time
+	 * we rescanned for the token, and the time we acquired the global
+	 * lock.)
 	 */
-	if (!lvmetad_pvscan_all_devs(cmd, NULL))
-		stack; /* FIXME: Anything more on this error path ? */
+	if (!lvmetad_pvscan_all_devs(cmd, NULL, 1)) {
+		log_warn("WARNING: Not using lvmetad because cache update failed.");
+		lvmetad_set_active(cmd, 0);
+		return;
+	}
 
 	/*
 	 * Clear the global_invalid flag in lvmetad.
@@ -1793,6 +2178,8 @@ void lvmetad_validate_global_cache(struct cmd_context *cmd, int force)
 	 * from lvmetad will not see global_invalid until
 	 * another host makes another global change.
 	 */
+	log_debug_lvmetad("lvmetad validate send set_global_info");
+
 	reply = daemon_send_simple(_lvmetad, "set_global_info",
 				   "token = %s", "skip",
 				   "global_invalid = " FMTd64, INT64_C(0),
@@ -1842,7 +2229,7 @@ int lvmetad_vg_is_foreign(struct cmd_context *cmd, const char *vgname, const cha
 	if (!id_write_format((const struct id*)vgid, uuid, sizeof(uuid)))
 		return_0;
 
-	reply = _lvmetad_send("vg_lookup",
+	reply = _lvmetad_send(cmd, "vg_lookup",
 			      "uuid = %s", uuid,
 			      "name = %s", vgname,
 			       NULL);
diff --git a/lib/cache/lvmetad.h b/lib/cache/lvmetad.h
index ce4affa..5820956 100644
--- a/lib/cache/lvmetad.h
+++ b/lib/cache/lvmetad.h
@@ -163,11 +163,12 @@ struct volume_group *lvmetad_vg_lookup(struct cmd_context *cmd,
 int lvmetad_pvscan_single(struct cmd_context *cmd, struct device *dev,
 			  activation_handler handler, int ignore_obsolete);
 
-int lvmetad_pvscan_all_devs(struct cmd_context *cmd, activation_handler handler);
+int lvmetad_pvscan_all_devs(struct cmd_context *cmd, activation_handler handler, int do_wait);
 int lvmetad_pvscan_foreign_vgs(struct cmd_context *cmd, activation_handler handler);
 
 int lvmetad_vg_clear_outdated_pvs(struct volume_group *vg);
 void lvmetad_validate_global_cache(struct cmd_context *cmd, int force);
+int lvmetad_token_matches(struct cmd_context *cmd);
 
 int lvmetad_vg_is_foreign(struct cmd_context *cmd, const char *vgname, const char *vgid);
 
@@ -195,11 +196,12 @@ int lvmetad_vg_is_foreign(struct cmd_context *cmd, const char *vgname, const cha
 #    define lvmetad_get_vgnameids(cmd, vgnameids)       do { } while (0)
 #    define lvmetad_vg_lookup(cmd, vgname, vgid)	(NULL)
 #    define lvmetad_pvscan_single(cmd, dev, handler, ignore_obsolete)	(0)
-#    define lvmetad_pvscan_all_devs(cmd, handler)	(0)
+#    define lvmetad_pvscan_all_devs(cmd, handler, do_wait)	(0)
 #    define lvmetad_pvscan_foreign_vgs(cmd, handler)	(0)
 #    define lvmetad_vg_clear_outdated_pvs(vg)           (1)
 #    define lvmetad_validate_global_cache(cmd, force)	do { } while (0)
 #    define lvmetad_vg_is_foreign(cmd, vgname, vgid) (0)
+#    define lvmetad_token_matches(cmd) (1)
 
 #  endif	/* LVMETAD_SUPPORT */
 
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 330e223..5d5ac48 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -854,6 +854,11 @@ cfg(global_use_lvmetad_CFG, "use_lvmetad", global_CFG_SECTION, 0, CFG_TYPE_BOOL,
 	"scanning from the LVM system entirely, including lvmetad, use\n"
 	"devices/global_filter.\n")
 
+cfg(global_lvmetad_update_wait_time_CFG, "lvmetad_update_wait_time", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_LVMETAD_UPDATE_WAIT_TIME, vsn(2, 2, 151), NULL, 0, NULL,
+	"The number of seconds a command will wait for lvmetad update to finish.\n"
+	"After waiting for this period, a command will not use lvmetad, and\n"
+	"will revert to disk scanning.\n")
+
 cfg(global_use_lvmlockd_CFG, "use_lvmlockd", global_CFG_SECTION, 0, CFG_TYPE_BOOL, 0, vsn(2, 2, 124), NULL, 0, NULL,
 	"Use lvmlockd for locking among hosts using LVM on shared storage.\n"
 	"Applicable only if LVM is compiled with lockd support in which\n"
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index a6806cd..5e10ce0 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -52,6 +52,7 @@
 #define DEFAULT_FALLBACK_TO_CLUSTERED_LOCKING 1
 #define DEFAULT_WAIT_FOR_LOCKS 1
 #define DEFAULT_LVMLOCKD_LOCK_RETRIES 3
+#define DEFAULT_LVMETAD_UPDATE_WAIT_TIME 10
 #define DEFAULT_PRIORITISE_WRITE_LOCKS 1
 #define DEFAULT_USE_MLOCKALL 0
 #define DEFAULT_METADATA_READ_ONLY 0
diff --git a/tools/commands.h b/tools/commands.h
index aba5b40..f49e57f 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -698,7 +698,7 @@ xx(lvs,
 
 xx(lvscan,
    "List all logical volumes in all volume groups",
-   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH,
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH | NO_LVMETAD_AUTOSCAN,
    "lvscan\n"
    "\t[-a|--all]\n"
    "\t[-b|--blockdevice]\n"
@@ -971,7 +971,7 @@ xx(pvs,
 
 xx(pvscan,
    "List all physical volumes",
-   PERMITTED_READ_ONLY | LOCKD_VG_SH,
+   PERMITTED_READ_ONLY | LOCKD_VG_SH | NO_LVMETAD_AUTOSCAN,
    "pvscan\n"
    "\t[-b|--background]\n"
    "\t[--cache [-a|--activate ay] [ DevicePath | -j|--major major --minor minor]...]\n"
@@ -1243,7 +1243,7 @@ xx(vgextend,
 
 xx(vgimport,
    "Register exported volume group with system",
-   ALL_VGS_IS_DEFAULT,
+   ALL_VGS_IS_DEFAULT | NO_LVMETAD_AUTOSCAN,
    "vgimport\n"
    "\t[-a|--all]\n"
    "\t[--commandprofile ProfileName]\n"
@@ -1382,7 +1382,7 @@ xx(vgs,
 
 xx(vgscan,
    "Search for all volume groups",
-   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH,
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH | NO_LVMETAD_AUTOSCAN,
    "vgscan "
    "\t[--cache]\n"
    "\t[--commandprofile ProfileName]\n"
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 2ee54e8..48c660b 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1643,13 +1643,26 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 	}
 
 	/*
-	 * Other hosts might have changed foreign VGs so enforce a rescan
-	 * before processing any command using them.
+	 * pvscan/vgscan/lvscan/vgimport want their own control over rescanning
+	 * to populate lvmetad and have similar code of their own.
+	 * Other commands use this general policy for using lvmetad.
+	 *
+	 * The lvmetad cache may need to be repopulated before we use it because:
+	 * - We are reading foreign VGs which others hosts may have changed
+	 *   which our lvmetad would not have seen.
+	 * - lvmetad may have just been started and no command has been run
+	 *   to populate it yet (e.g. no pvscan --cache was run).
+	 * - Another local command may have run with a different global filter
+	 *   which changed the content of lvmetad from what we want (recognized
+	 *   by different token values.)
 	 */
-	if (cmd->include_foreign_vgs && lvmetad_used() &&
-	    !lvmetad_pvscan_foreign_vgs(cmd, NULL)) {
-		log_error("Failed to scan devices.");
-		return ECMD_FAILED;
+	if (lvmetad_used() && !(cmd->command->flags & NO_LVMETAD_AUTOSCAN)) {
+		if (cmd->include_foreign_vgs || !lvmetad_token_matches(cmd)) {
+			if (lvmetad_used() && !lvmetad_pvscan_all_devs(cmd, NULL, cmd->include_foreign_vgs ? 1 : 0)) {
+				log_warn("WARNING: Not using lvmetad because cache update failed.");
+				lvmetad_set_active(cmd, 0);
+			}
+		}
 	}
 
 	/*
diff --git a/tools/lvscan.c b/tools/lvscan.c
index 751ecb6..666626c 100644
--- a/tools/lvscan.c
+++ b/tools/lvscan.c
@@ -21,10 +21,8 @@ static int _lvscan_single_lvmetad(struct cmd_context *cmd, struct logical_volume
 	struct dm_list all_pvs;
 	char pvid_s[64] __attribute__((aligned(8)));
 
-	if (!lvmetad_used()) {
-		log_verbose("Ignoring lvscan --cache because lvmetad is not in use.");
+	if (!lvmetad_used())
 		return ECMD_PROCESSED;
-	}
 
 	dm_list_init(&all_pvs);
 
@@ -98,6 +96,22 @@ int lvscan(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
+	if (!lvmetad_used() && arg_is_set(cmd, cache_long_ARG))
+		log_verbose("Ignoring lvscan --cache because lvmetad is not in use.");
+
+	/* Needed because this command has NO_LVMETAD_AUTOSCAN. */
+	if (lvmetad_used() && !lvmetad_token_matches(cmd)) {
+		if (lvmetad_used() && !lvmetad_pvscan_all_devs(cmd, NULL, 0)) {
+			log_warn("WARNING: Not using lvmetad because cache update failed.");
+			lvmetad_set_active(cmd, 0);
+		}
+
+		/*
+		 * FIXME: doing lvscan --cache after a full scan is pointless.
+		 * Should the cache case just exit here?
+		 */
+	}
+
 	return process_each_lv(cmd, argc, argv, 0, NULL,
 			       &lvscan_single);
 }
diff --git a/tools/pvscan.c b/tools/pvscan.c
index b224c30..10297a3 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -234,8 +234,6 @@ static int _pvscan_lvmetad(struct cmd_context *cmd, int argc, char **argv)
 	dev_t devno;
 	activation_handler handler = NULL;
 
-	cmd->include_foreign_vgs = 1;
-
 	/*
 	 * Return here immediately if lvmetad is not used.
 	 * Also return if locking_type=3 (clustered) as we
@@ -273,11 +271,29 @@ static int _pvscan_lvmetad(struct cmd_context *cmd, int argc, char **argv)
 
 	/* Scan everything? */
 	if (!argc && !devno_args) {
-		if (!lvmetad_pvscan_all_devs(cmd, handler))
+		if (!lvmetad_pvscan_all_devs(cmd, handler, 1)) {
+			log_error("Failed to update cache.");
 			ret = ECMD_FAILED;
+		}
 		goto out;
 	}
 
+	/*
+	 * FIXME: when specific devs are named, we generally don't
+	 * want to scan any other devs, but if lvmetad is not yet
+	 * populated, the first 'pvscan --cache dev' does need to
+	 * do a full scan.  We want to remove the need for this
+	 * case so that 'pvscan --cache dev' is guaranteed to never
+	 * scan any devices other than those specified.
+	 */
+	if (lvmetad_used() && !lvmetad_token_matches(cmd)) {
+		if (lvmetad_used() && !lvmetad_pvscan_all_devs(cmd, NULL, 0)) {
+			log_error("Failed to update cache.");
+			ret = ECMD_FAILED;
+			goto out;
+		}
+	}
+
 	log_verbose("Using physical volume(s) on command line");
 
 	/* Process any command line PVs first. */
@@ -404,6 +420,14 @@ int pvscan(struct cmd_context *cmd, int argc, char **argv)
 			  arg_count(cmd, exported_ARG) ?
 			  "of exported volume group(s)" : "in no volume group");
 
+	/* Needed because this command has NO_LVMETAD_AUTOSCAN. */
+	if (lvmetad_used() && !lvmetad_token_matches(cmd)) {
+		if (lvmetad_used() && !lvmetad_pvscan_all_devs(cmd, NULL, 0)) {
+			log_warn("WARNING: Not using lvmetad because cache update failed.");
+			lvmetad_set_active(cmd, 0);
+		}
+	}
+
 	if (!lock_vol(cmd, VG_GLOBAL, LCK_VG_WRITE, NULL)) {
 		log_error("Unable to obtain global lock.");
 		return ECMD_FAILED;
diff --git a/tools/tools.h b/tools/tools.h
index 3762e8e..7b1bda3 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -110,6 +110,8 @@ struct arg_value_group_list {
 #define REQUIRES_FULL_LABEL_SCAN 0x00000080
 /* Command must use all specified arg names and fail if all cannot be used. */
 #define MUST_USE_ALL_ARGS        0x00000100
+/* Command wants to control the device scan for lvmetad itself. */
+#define NO_LVMETAD_AUTOSCAN      0x00000200
  
 /* a register of the lvm commands */
 struct command {
diff --git a/tools/vgimport.c b/tools/vgimport.c
index caeaf09..3c08876 100644
--- a/tools/vgimport.c
+++ b/tools/vgimport.c
@@ -93,9 +93,11 @@ int vgimport(struct cmd_context *cmd, int argc, char **argv)
 	 * We need to reread it to see that it's been exported before we can
 	 * import it.
 	 */
-	if (lvmetad_active() && !lvmetad_pvscan_all_devs(cmd, NULL)) {
-		log_error("Failed to scan devices.");
-		return ECMD_FAILED;
+	if (lvmetad_used()) {
+		if (!lvmetad_pvscan_all_devs(cmd, NULL, 1)) {
+			log_warn("WARNING: Not using lvmetad because cache update failed.");
+			lvmetad_set_active(cmd, 0);
+		}
 	}
 
 	return process_each_vg(cmd, argc, argv, NULL,
diff --git a/tools/vgscan.c b/tools/vgscan.c
index a5b04a3..9dc0000 100644
--- a/tools/vgscan.c
+++ b/tools/vgscan.c
@@ -61,21 +61,20 @@ int vgscan(struct cmd_context *cmd, int argc, char **argv)
 		cmd->filter->wipe(cmd->filter);
 	lvmcache_destroy(cmd, 1, 0);
 
-	if (arg_count(cmd, cache_long_ARG)) {
-		cmd->include_foreign_vgs = 1;
+	if (!lvmetad_used() && arg_is_set(cmd, cache_long_ARG))
+		log_verbose("Ignoring vgscan --cache command because lvmetad is not in use.");
 
-		if (lvmetad_active()) {
-			if (!lvmetad_pvscan_all_devs(cmd, NULL))
-				return ECMD_FAILED;
-		}
-		else {
-			log_error("Cannot proceed since lvmetad is not active.");
-			unlock_vg(cmd, VG_GLOBAL);
-			return ECMD_FAILED;
+	if (lvmetad_used() && (arg_is_set(cmd, cache_long_ARG) || !lvmetad_token_matches(cmd))) {
+		if (lvmetad_used() && !lvmetad_pvscan_all_devs(cmd, NULL, arg_is_set(cmd, cache_long_ARG))) {
+			log_warn("WARNING: Not using lvmetad because cache update failed.");
+			lvmetad_set_active(cmd, 0);
 		}
 	}
 
-	log_print_unless_silent("Reading all physical volumes.  This may take a while...");
+	if (!lvmetad_used())
+		log_print_unless_silent("Reading all physical volumes.  This may take a while...");
+	else
+		log_print_unless_silent("Reading volume groups from cache.");
 
 	maxret = process_each_vg(cmd, argc, argv, NULL, 0, NULL,
 				 &vgscan_single);


