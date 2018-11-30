From: David Teigland <teigland@sourceware.org>
Date: Fri, 30 Nov 2018 16:05:40 -0500
Subject: 2018-06-01-stable - lvmetad: only disable if repair will do something
Message-ID: <201811302105.wAUL5ej1002577@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=322d4ed05e348c6d88f3cb880485e5777298c361
Commit:        322d4ed05e348c6d88f3cb880485e5777298c361
Parent:        a01e1fec0fe7c2fa61577c0e636e907cde7279ea
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Nov 30 14:20:43 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Nov 30 14:54:19 2018 -0600

lvmetad: only disable if repair will do something

lvconvert --repair would disable lvmetad at the start of
the command.  This would leave lvmetad disabled even if the
command did nothing.  Move the step to disable lvmetad until
later, just before some actual repair is done.  There are
now numerous cases where nothing is actually done and lvmetad
is not disabled.
---
 lib/cache/lvmetad.c |   33 +++++++++++++++++++++++++++++----
 tools/lvconvert.c   |   13 +++++++++++++
 tools/lvmcmdline.c  |    2 --
 3 files changed, 42 insertions(+), 6 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index acbb52e..1b48fd3 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -31,6 +31,7 @@ static daemon_handle _lvmetad = { .error = 0 };
 static int _lvmetad_use = 0;
 static int _lvmetad_connected = 0;
 static int _lvmetad_daemon_pid = 0;
+static int _was_connected = 0;
 
 static char *_lvmetad_token = NULL;
 static const char *_lvmetad_socket = NULL;
@@ -114,8 +115,10 @@ static int _log_debug_inequality(const char *name, struct dm_config_node *a, str
 
 void lvmetad_disconnect(void)
 {
-	if (_lvmetad_connected)
+	if (_lvmetad_connected) {
 		daemon_close(_lvmetad);
+		_was_connected = 1;
+	}
 
 	_lvmetad_connected = 0;
 	_lvmetad_use = 0;
@@ -2973,14 +2976,33 @@ int lvmetad_vg_is_foreign(struct cmd_context *cmd, const char *vgname, const cha
  */
 void lvmetad_set_disabled(struct cmd_context *cmd, const char *reason)
 {
+	daemon_handle tmph = { .error = 0 };
 	daemon_reply reply;
+	int dis = 0;
 
-	if (!_lvmetad_use)
-		return;
+	/*
+	 * If we were using lvmetad at the start of the command, but are not
+	 * now, then _was_connected should still be set.  In this case we
+	 * want to make a temp connection just to disable it.
+	 */
+	if (!_lvmetad_use) {
+		if (_was_connected) {
+			/* Create a special temp connection just to send disable */
+			tmph = lvmetad_open(_lvmetad_socket);
+			if (tmph.socket_fd < 0 || tmph.error) {
+				log_warn("Failed to connect to lvmetad to disable.");
+				return;
+			}
+			dis = 1;
+		} else {
+			/* We were never using lvmetad, don't start now. */
+			return;
+		}
+	}
 
 	log_debug_lvmetad("Sending lvmetad disabled %s", reason);
 
-	reply = daemon_send_simple(_lvmetad, "set_global_info",
+	reply = daemon_send_simple(tmph, "set_global_info",
 				   "token = %s", "skip",
 				   "global_disable = " FMTd64, (int64_t)1,
 				   "disable_reason = %s", reason,
@@ -2994,6 +3016,9 @@ void lvmetad_set_disabled(struct cmd_context *cmd, const char *reason)
 		log_error("Failed response from lvmetad.");
 
 	daemon_reply_destroy(reply);
+
+	if (dis)
+		daemon_close(tmph);
 }
 
 void lvmetad_clear_disabled(struct cmd_context *cmd)
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index d7a618d..028781f 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -17,6 +17,7 @@
 #include "polldaemon.h"
 #include "lv_alloc.h"
 #include "lvconvert_poll.h"
+#include "lvmetad-client.h"
 
 #define MAX_PDATA_ARGS	10	/* Max number of accepted args for d-m-p-d tools */
 
@@ -1073,6 +1074,9 @@ static int _lvconvert_mirrors_repair(struct cmd_context *cmd,
 		return 1;
 	}
 
+	log_warn("WARNING: Disabling lvmetad cache for repair command.");
+	lvmetad_set_disabled(cmd, LVMETAD_DISABLE_REASON_REPAIR);
+
 	failed_mimages = _failed_mirrors_count(lv);
 	failed_logs = _failed_logs_count(lv);
 
@@ -2321,6 +2325,9 @@ static int _lvconvert_thin_pool_repair(struct cmd_context *cmd,
 		goto deactivate_pmslv;
 	}
 
+	log_warn("WARNING: Disabling lvmetad cache for repair command.");
+	lvmetad_set_disabled(cmd, LVMETAD_DISABLE_REASON_REPAIR);
+
 	if (!(ret = exec_cmd(cmd, (const char * const *)argv, &status, 1))) {
 		log_error("Repair of thin metadata volume of thin pool %s failed (status:%d). "
 			  "Manual repair required!",
@@ -2519,6 +2526,9 @@ static int _lvconvert_cache_repair(struct cmd_context *cmd,
 		goto deactivate_pmslv;
 	}
 
+	log_warn("WARNING: Disabling lvmetad cache for repair command.");
+	lvmetad_set_disabled(cmd, LVMETAD_DISABLE_REASON_REPAIR);
+
 	if (!(ret = exec_cmd(cmd, (const char * const *)argv, &status, 1))) {
 		log_error("Repair of cache metadata volume of cache %s failed (status:%d). "
 			  "Manual repair required!",
@@ -3538,6 +3548,9 @@ static int _lvconvert_repair_pvs_raid(struct cmd_context *cmd, struct logical_vo
 	_lvconvert_repair_pvs_raid_ask(cmd, &do_it);
 
 	if (do_it) {
+		log_warn("WARNING: Disabling lvmetad cache for repair command.");
+		lvmetad_set_disabled(cmd, LVMETAD_DISABLE_REASON_REPAIR);
+
 		if (!(failed_pvs = _failed_pv_list(lv->vg)))
 			return_0;
 
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 298ead7..a9c3e41 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -2914,8 +2914,6 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 	}
 
 	if (cmd->command->command_enum == lvconvert_repair_CMD) {
-		log_warn("WARNING: Disabling lvmetad cache for repair command.");
-		lvmetad_set_disabled(cmd, LVMETAD_DISABLE_REASON_REPAIR);
 		log_warn("WARNING: Not using lvmetad because of repair.");
 		lvmetad_make_unused(cmd);
 	}


