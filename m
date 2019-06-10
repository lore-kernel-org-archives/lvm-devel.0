From: David Teigland <teigland@sourceware.org>
Date: Mon, 10 Jun 2019 11:36:50 -0400
Subject: master - locking: reset global_ex flag at end of cmd
Message-ID: <201906101536.x5AFaoUv019409@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=36cbc6db24f8aa01fb1c1be095b22a672434f754
Commit:        36cbc6db24f8aa01fb1c1be095b22a672434f754
Parent:        4c020b4d4afff51272252f58e5251f79c26f6603
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Jun 10 10:07:30 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Jun 10 10:34:58 2019 -0500

locking: reset global_ex flag at end of cmd

These two flags may be not reset at the end of
the command when the unlock is implicit, which
is a problem if the cmd struct is reused.
Clear the flags in the general fin_locking.
---
 lib/locking/locking.c |   10 +++++++++-
 lib/locking/locking.h |    2 +-
 tools/lvmcmdline.c    |    2 +-
 3 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/lib/locking/locking.c b/lib/locking/locking.c
index 630a3bc..c3ea536 100644
--- a/lib/locking/locking.c
+++ b/lib/locking/locking.c
@@ -156,12 +156,20 @@ int init_locking(struct cmd_context *cmd,
 	return 1;
 }
 
-void fin_locking(void)
+void fin_locking(struct cmd_context *cmd)
 {
 	/* file locking disabled */
 	if (!_locking.flags)
 		return;
 
+	/*
+	 * These may be automatically released when the
+	 * command ends, without an explicit unlock call,
+	 * in which case these flags would not be cleared.
+	 */
+	cmd->lockf_global_ex = 0;
+	cmd->lockd_global_ex = 0;
+
 	_locking.fin_locking();
 }
 
diff --git a/lib/locking/locking.h b/lib/locking/locking.h
index 41faf68..746667a 100644
--- a/lib/locking/locking.h
+++ b/lib/locking/locking.h
@@ -22,7 +22,7 @@
 struct logical_volume;
 
 int init_locking(struct cmd_context *cmd, int file_locking_sysinit, int file_locking_readonly, int file_locking_ignorefail);
-void fin_locking(void);
+void fin_locking(struct cmd_context *cmd);
 void reset_locking(void);
 int vg_write_lock_held(void);
 
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 30f54e6..8091b39 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -3043,7 +3043,7 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 		ret = cmd->command->fn(cmd, argc, argv);
 
 	lvmlockd_disconnect();
-	fin_locking();
+	fin_locking(cmd);
 
 	if (!_cmd_no_meta_proc(cmd) && find_config_tree_bool(cmd, global_notify_dbus_CFG, NULL))
 		lvmnotify_send(cmd);


