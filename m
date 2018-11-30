From: David Teigland <teigland@sourceware.org>
Date: Fri, 30 Nov 2018 16:50:27 -0500
Subject: 2018-06-01-stable - lvmetad: fix disabling in previous commit
Message-ID: <201811302150.wAULoRpS009685@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9764ee0b3f21ed717e1b6248ce4c41dd552bb0ec
Commit:        9764ee0b3f21ed717e1b6248ce4c41dd552bb0ec
Parent:        322d4ed05e348c6d88f3cb880485e5777298c361
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Nov 30 15:49:03 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Nov 30 15:49:03 2018 -0600

lvmetad: fix disabling in previous commit

it broke the case where a connection already exists.
---
 lib/cache/lvmetad.c |   18 ++++++++++++++----
 1 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 1b48fd3..f068fc6 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -2978,7 +2978,7 @@ void lvmetad_set_disabled(struct cmd_context *cmd, const char *reason)
 {
 	daemon_handle tmph = { .error = 0 };
 	daemon_reply reply;
-	int dis = 0;
+	int tmp_con = 0;
 
 	/*
 	 * If we were using lvmetad at the start of the command, but are not
@@ -2993,7 +2993,7 @@ void lvmetad_set_disabled(struct cmd_context *cmd, const char *reason)
 				log_warn("Failed to connect to lvmetad to disable.");
 				return;
 			}
-			dis = 1;
+			tmp_con = 1;
 		} else {
 			/* We were never using lvmetad, don't start now. */
 			return;
@@ -3002,13 +3002,23 @@ void lvmetad_set_disabled(struct cmd_context *cmd, const char *reason)
 
 	log_debug_lvmetad("Sending lvmetad disabled %s", reason);
 
-	reply = daemon_send_simple(tmph, "set_global_info",
+	if (tmp_con)
+		reply = daemon_send_simple(tmph, "set_global_info",
 				   "token = %s", "skip",
 				   "global_disable = " FMTd64, (int64_t)1,
 				   "disable_reason = %s", reason,
 				   "pid = " FMTd64, (int64_t)getpid(),
 				   "cmd = %s", get_cmd_name(),
 				   NULL);
+	else
+		reply = daemon_send_simple(_lvmetad, "set_global_info",
+				   "token = %s", "skip",
+				   "global_disable = " FMTd64, (int64_t)1,
+				   "disable_reason = %s", reason,
+				   "pid = " FMTd64, (int64_t)getpid(),
+				   "cmd = %s", get_cmd_name(),
+				   NULL);
+
 	if (reply.error)
 		log_error("Failed to send message to lvmetad %d", reply.error);
 
@@ -3017,7 +3027,7 @@ void lvmetad_set_disabled(struct cmd_context *cmd, const char *reason)
 
 	daemon_reply_destroy(reply);
 
-	if (dis)
+	if (tmp_con)
 		daemon_close(tmph);
 }
 


