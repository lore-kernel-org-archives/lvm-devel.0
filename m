From: David Teigland <teigland@sourceware.org>
Date: Tue, 15 Jan 2019 13:25:04 -0500
Subject: master - hints: fix hint flock when using lvm shell
Message-ID: <201901151825.x0FIP4Gn026841@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7b5abc3fb19c7569ad86107cfbf30f39ca261fed
Commit:        7b5abc3fb19c7569ad86107cfbf30f39ca261fed
Parent:        3cf7668e347af547e6d986ffbfa7fe0d5b425a7f
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jan 15 12:23:16 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jan 15 12:23:16 2019 -0600

hints: fix hint flock when using lvm shell

also cmd->use_hints needs to be set for each shell command
---
 lib/commands/toolcontext.c |    3 +++
 lib/label/hints.c          |   14 +++++++++-----
 lib/label/hints.h          |    2 ++
 tools/lvmcmdline.c         |    3 +++
 4 files changed, 17 insertions(+), 5 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 39ab3df..bd216aa 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -22,6 +22,7 @@
 #include "lib/activate/activate.h"
 #include "lib/filters/filter.h"
 #include "lib/label/label.h"
+#include "lib/label/hints.h"
 #include "lib/misc/lvm-file.h"
 #include "lib/format_text/format-text.h"
 #include "lib/display/display.h"
@@ -1781,6 +1782,7 @@ int refresh_toolcontext(struct cmd_context *cmd)
 	 */
 
 	activation_release();
+	hints_exit();
 	lvmcache_destroy(cmd, 0, 0);
 	label_scan_destroy(cmd);
 	label_exit();
@@ -1900,6 +1902,7 @@ void destroy_toolcontext(struct cmd_context *cmd)
 
 	archive_exit(cmd);
 	backup_exit(cmd);
+	hints_exit();
 	lvmcache_destroy(cmd, 0, 0);
 	label_scan_destroy(cmd);
 	label_exit();
diff --git a/lib/label/hints.c b/lib/label/hints.c
index bdd70a9..a9c40c2 100644
--- a/lib/label/hints.c
+++ b/lib/label/hints.c
@@ -344,6 +344,13 @@ static void _unlock_hints(void)
 	_hints_fd = -1;
 }
 
+void hints_exit(void)
+{
+	if (_hints_fd == -1)
+		return;
+	return _unlock_hints();
+}
+
 static struct hint *_find_hint_name(struct dm_list *hints, const char *name)
 {
 	struct hint *hint;
@@ -989,6 +996,8 @@ void clear_hint_file(struct cmd_context *cmd)
 	if (!cmd->enable_hints)
 		return;
 
+	log_debug("clear_hint_file");
+
 	/*
 	 * This function runs even when cmd->use_hints is 0,
 	 * which means this command does not use hints, but
@@ -999,11 +1008,6 @@ void clear_hint_file(struct cmd_context *cmd)
 	if (!_touch_nohints())
 		stack;
 
-	/*
-	 * We are relying on the command exit to release this flock,
-	 * we should probably add an explicit unlock_hints call.
-	 */
-
 	if (!_lock_hints(LOCK_EX, 0))
 		stack;
 
diff --git a/lib/label/hints.h b/lib/label/hints.h
index d80016e..a17214c 100644
--- a/lib/label/hints.h
+++ b/lib/label/hints.h
@@ -33,5 +33,7 @@ int get_hints(struct cmd_context *cmd, struct dm_list *hints, int *newhints,
 
 int validate_hints(struct cmd_context *cmd, struct dm_list *hints);
 
+void hints_exit(void);
+
 #endif
 
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 55a068f..49a6038 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -2331,6 +2331,8 @@ static int _get_current_settings(struct cmd_context *cmd)
 	/* Only certain commands need to be optimized by using hints. */
 	if (cmd->cname->flags & ALLOW_HINTS)
 		cmd->use_hints = 1;
+	else
+		cmd->use_hints = 0;
 
 	if ((hint_mode = find_config_tree_str(cmd, devices_hints_CFG, NULL))) {
 		if (!strcmp(hint_mode, "none"))
@@ -2986,6 +2988,7 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 
       out:
 
+	hints_exit();
 	lvmcache_destroy(cmd, 1, 1);
 	label_scan_destroy(cmd);
 


