From: David Teigland <teigland@fedoraproject.org>
Date: Fri,  9 Dec 2016 21:22:44 +0000 (UTC)
Subject: master - lvmetad: fix segfault in daemon_reply_simple
Message-ID: <20161209212244.B8F4360CD5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c459f23565e86eb9a8a116995cda7dcaed858b9f
Commit:        c459f23565e86eb9a8a116995cda7dcaed858b9f
Parent:        30ad254d84047ffe3eba98943855b53a893390e2
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Dec 9 15:17:53 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Dec 9 15:22:30 2016 -0600

lvmetad: fix segfault in daemon_reply_simple

missing NULL termination
---
 WHATS_NEW                      |    1 +
 daemons/lvmetad/lvmetad-core.c |    9 ++++++---
 2 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 595b667..37a0dc7 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.169 - 
 =====================================
+  Fix segfault in lvmetad from missing NULL in daemon_reply_simple.
   Simplify internal _info_run() and use _setup_task_run() for mknod.
   Better API for internal function _setup_task_run.
   Avoid using lv_has_target_type() call within lv_info_with_seg_status.
diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index ee0c52f..1faae11 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -2745,7 +2745,8 @@ static response handler(daemon_state s, client_handle h, request r)
 							   "expected = %s", state->token,
 							   "received = %s", token,
 							   "update_pid = " FMTd64, (int64_t)state->update_pid,
-							   "reason = %s", "another command has populated the cache");
+							   "reason = %s", "another command has populated the cache",
+							   NULL);
 			}
 
 			DEBUGLOG(state, "token_update end len %d pid %d new token %s",
@@ -2778,7 +2779,8 @@ static response handler(daemon_state s, client_handle h, request r)
 					   "expected = %s", state->token,
 					   "received = %s", token,
 					   "update_pid = " FMTd64, (int64_t)state->update_pid,
-					   "reason = %s", "another command has populated the cache");
+					   "reason = %s", "another command has populated the cache",
+					   NULL);
 	}
 
 	/* If a pid doing update was cancelled, ignore its update messages. */
@@ -2793,7 +2795,8 @@ static response handler(daemon_state s, client_handle h, request r)
 					   "expected = %s", state->token,
 					   "received = %s", token,
 					   "update_pid = " FMTd64, (int64_t)state->update_pid,
-					   "reason = %s", "another command has populated the lvmetad cache");
+					   "reason = %s", "another command has populated the lvmetad cache",
+					   NULL);
 	}
 
 	pthread_mutex_unlock(&state->token_lock);


