From: David Teigland <teigland@fedoraproject.org>
Date: Mon,  6 Jul 2015 16:45:08 +0000 (UTC)
Subject: master - config: remove read_only_lock_modes
Message-ID: <20150706164508.1F6D36053C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=633aea92fbcb228417ac2b4a1ac3d808460d8df5
Commit:        633aea92fbcb228417ac2b4a1ac3d808460d8df5
Parent:        e1733a6271fc0a270bcb5bd2a4b43b62e4a1ddd0
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Jul 6 11:42:52 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Jul 6 11:44:28 2015 -0500

config: remove read_only_lock_modes

It had been added as part of lvmlockd code, but it does
not seem particularly useful.
---
 lib/config/config_settings.h |    4 ----
 lib/locking/lvmlockd.c       |   15 ---------------
 2 files changed, 0 insertions(+), 19 deletions(-)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index b300b3a..74d421a 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -845,10 +845,6 @@ cfg(global_sanlock_lv_extend_CFG, "sanlock_lv_extend", global_CFG_SECTION, CFG_D
 	"the amount specified here.  Setting this to 0 disables the\n"
 	"automatic extension and can cause lvcreate to fail.\n")
 
-cfg(global_read_only_lock_modes_CFG, "read_only_lock_modes", global_CFG_SECTION, 0, CFG_TYPE_BOOL, 0, vsn(2, 2, 124), NULL, 0, NULL,
-	"Limit commands to actions that use read locks.\n"
-	"This disallows any actions that require a write (exclusive) lock.\n")
-
 cfg(global_thin_check_executable_CFG, "thin_check_executable", global_CFG_SECTION, CFG_ALLOW_EMPTY | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, THIN_CHECK_CMD, vsn(2, 2, 94), "@THIN_CHECK_CMD@", 0, NULL,
 	"The full path to the thin_check command.\n"
 	"LVM uses this command to check that a thin metadata\n"
diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index 9e138d0..4fdb818 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -1130,11 +1130,6 @@ int lockd_gl_create(struct cmd_context *cmd, const char *def_mode, const char *v
 		return 0;
 	}
 
-	if (!strcmp(mode, "ex") && find_config_tree_bool(cmd, global_read_only_lock_modes_CFG, NULL)) {
-		log_error("Exclusive global lock not allowed with read_only_lock_modes");
-		return 0;
-	}
-
  req:
 	if (!_lockd_request(cmd, "lock_gl",
 			      NULL, vg_lock_type, NULL, NULL, NULL, NULL, mode, NULL,
@@ -1365,11 +1360,6 @@ int lockd_gl(struct cmd_context *cmd, const char *def_mode, uint32_t flags)
 		return 0;
 	}
 
-	if (!strcmp(mode, "ex") && find_config_tree_bool(cmd, global_read_only_lock_modes_CFG, NULL)) {
-		log_error("Exclusive global lock not allowed with read_only_lock_modes");
-		return 0;
-	}
-
  req:
 	log_debug("lockd global mode %s", mode);
 
@@ -1579,11 +1569,6 @@ int lockd_vg(struct cmd_context *cmd, const char *vg_name, const char *def_mode,
 	if (!mode)
 		mode = cmd->lockd_vg_default_sh ? "sh" : "ex";
 
-	if (!strcmp(mode, "ex") && find_config_tree_bool(cmd, global_read_only_lock_modes_CFG, NULL)) {
-		log_error("Exclusive VG lock not allowed with read_only_lock_modes");
-		return 0;
-	}
-
 	if (!strcmp(mode, "ex"))
 		*lockd_state |= LDST_EX;
 


