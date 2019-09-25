From: David Teigland <teigland@sourceware.org>
Date: Wed, 25 Sep 2019 15:31:45 -0400
Subject: stable-2.02 - lvmetad: fix sync cache to lvmetad
Message-ID: <201909251931.x8PJVjVY003514@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5d6bf1efb225b964bfff398277e68345acdac1d0
Commit:        5d6bf1efb225b964bfff398277e68345acdac1d0
Parent:        2327f3997bfb70d67299f3dfa45436132e0a8521
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Sep 25 14:23:14 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Sep 25 14:31:08 2019 -0500

lvmetad: fix sync cache to lvmetad

error could be reproduced follow those steps:
    #!/bin/bash
    vgcreate vgtest /dev/sdb
    lvcreate -L 100M -n lv1 vgtest
    while :
    do
        service lvm2-lvmetad restart
        vgs &
        pvscan &
        lvcreate -L 100M -n lv2 vgtest &
        lvchange /dev/vgtest/lv1 --addtag xxxxx &
        wait
        if ! lvs|grep lv2;then
            echo "err create"
            break
        fi
        sleep 1
        lvremove -y /dev/vgtest/lv2
        lvchange /dev/vgtest/lv1 --deltag xxxxx
    done

and then fail to create vgtest/lv2, actually lv2 was created, while
the metadata written on disk is replaced by lvchange. It could look
up lv2 by calling dmsetup table, while lvs could not.

This is because, when lvmetad restarted, several lvm commands update
token concurrently, when lvcreate recieve "token_mismatch", it cancle
communicating with lvmetad, which leads to that lvmetad cache is not
sync with the metadata on disk, then lv2 is not committed to lvmetad
cache. The metadata of vgtest which lvchange query from lvmetad is
out of date. After lvchange, it use the old metadata cover the new one.

This patch let lvm process update token synchronously, only one command
update lvmetad token at a time.

lvmetad_pvscan_single send the metadata on a pv by sending "pv_found"
to lvmetad, while the metadata maybe out of date after waiting for the
chance to update lvmetad token. Call label_read to read metadata again.

Token mismatch may lead to problems, increase log level.

Signed-off-by: wangjufeng<wangjufeng@huawei.com>
---
 daemons/lvmetad/lvmetad-core.c |   21 ++++++++++++++++-----
 lib/cache/lvmetad.c            |   31 +++++++++++++++++++++++++++++--
 2 files changed, 45 insertions(+), 7 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 9ae359b..2628022 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -2669,6 +2669,7 @@ static response handler(daemon_state s, client_handle h, request r)
 	int pid;
 	int cache_lock = 0;
 	int info_lock = 0;
+	uint64_t timegap = 0;
 
 	rq = daemon_request_str(r, "request", "NONE");
 	token = daemon_request_str(r, "token", "NONE");
@@ -2711,12 +2712,22 @@ static response handler(daemon_state s, client_handle h, request r)
 				 state->update_cmd);
 
 		} else if (prev_in_progress && this_in_progress) {
+			timegap = _monotonic_seconds() - state->update_begin;
+			if (timegap < state->update_timeout) {
+				pthread_mutex_unlock(&state->token_lock);
+				return daemon_reply_simple("token_updating",
+							   "expected = %s", state->token,
+							   "update_pid = " FMTd64, (int64_t)state->update_pid,
+							   "reason = %s", "another command has populated the cache",
+							   NULL);
+			}
+
 			/* Current update is cancelled and replaced by a new update */
 
-			DEBUGLOG(state, "token_update replacing pid %d begin %llu len %d cmd %s",
+			WARN(state, "token_update replacing pid %d begin %llu len %d cmd %s",
 				 state->update_pid,
 				 (unsigned long long)state->update_begin,
-				 (int)(_monotonic_seconds() - state->update_begin),
+				 (int)(timegap),
 				 state->update_cmd);
 
 			(void) dm_strncpy(prev_token, state->token, sizeof(prev_token));
@@ -2726,7 +2737,7 @@ static response handler(daemon_state s, client_handle h, request r)
 			state->update_pid = pid;
 			strncpy(state->update_cmd, cmd, CMD_NAME_SIZE - 1);
 
-			DEBUGLOG(state, "token_update begin %llu timeout %d pid %d cmd %s",
+			WARN(state, "token_update begin %llu timeout %d pid %d cmd %s",
 				 (unsigned long long)state->update_begin,
 				 state->update_timeout,
 				 state->update_pid,
@@ -2737,7 +2748,7 @@ static response handler(daemon_state s, client_handle h, request r)
 
 			if (state->update_pid != pid) {
 				/* If a pid doing update was cancelled, ignore its token update at the end. */
-				DEBUGLOG(state, "token_update ignored from cancelled update pid %d", pid);
+				WARN(state, "token_update ignored from cancelled update pid %d", pid);
 				pthread_mutex_unlock(&state->token_lock);
 
 				return daemon_reply_simple("token_mismatch",
@@ -2748,7 +2759,7 @@ static response handler(daemon_state s, client_handle h, request r)
 							   NULL);
 			}
 
-			DEBUGLOG(state, "token_update end len %d pid %d new token %s",
+			WARN(state, "token_update end len %d pid %d new token %s",
 				 (int)(_monotonic_seconds() - state->update_begin),
 				 state->update_pid, token);
 
diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index d242260..61ba53e 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -565,7 +565,12 @@ static int _token_update(int *replaced_update)
 	const char *reply_str;
 	int update_pid;
 	int ending_our_update;
+	unsigned int wait_sec = 0;
+	uint64_t now = 0, wait_start = 0;
+	wait_sec = (unsigned int)_lvmetad_update_timeout;
+	unsigned int delay_usec = 0;
 
+retry:
 	log_debug_lvmetad("Sending lvmetad token_update %s", _lvmetad_token);
 	reply = _lvmetad_send(NULL, "token_update", NULL);
 
@@ -581,6 +586,28 @@ static int _token_update(int *replaced_update)
 	update_pid = (int)daemon_reply_int(reply, "update_pid", 0);
 	reply_str = daemon_reply_str(reply, "response", "");
 
+	if (!strcmp(reply_str, "token_updating")) {
+		daemon_reply_destroy(reply);
+		if (!(now = _monotonic_seconds())) {
+			log_print_unless_silent("_monotonic_seconds error");
+			return 0;
+		}
+
+		if (!wait_start)
+			wait_start = now;
+
+		if (now - wait_start <= wait_sec) {
+			log_warn("lvmetad is being updated, retry for %u more seconds.",
+				 wait_sec - (unsigned int)(now - wait_start));
+			delay_usec = 1000000 + lvm_even_rand(&_lvmetad_cmd->rand_seed, 1000000);
+			usleep(delay_usec);
+			goto retry;
+		}
+
+		log_print_unless_silent("Not using lvmetad after %u sec lvmetad_update_wait_time, no more try.", wait_sec);
+		return 0;
+	}
+
 	/*
 	 * A mismatch can only happen when this command attempts to set the
 	 * token to filter:<hash> at the end of its update, but the update has
@@ -591,11 +618,11 @@ static int _token_update(int *replaced_update)
 
 		ending_our_update = strcmp(_lvmetad_token, LVMETAD_TOKEN_UPDATE_IN_PROGRESS);
 
-		log_debug_lvmetad("Received token update mismatch expected \"%s\" our token \"%s\" update_pid %d our pid %d",
+		log_print_unless_silent("Received token update mismatch expected \"%s\" our token \"%s\" update_pid %d our pid %d",
 				  token_expected, _lvmetad_token, update_pid, getpid());
 
 		if (ending_our_update && (update_pid != getpid())) {
-			log_warn("WARNING: lvmetad was updated by another command (pid %d).", update_pid);
+			log_print_unless_silent("WARNING: lvmetad was updated by another command (pid %d).", update_pid);
 		} else {
 			/*
 			 * Shouldn't happen.


