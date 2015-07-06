From: David Teigland <teigland@fedoraproject.org>
Date: Mon,  6 Jul 2015 16:45:06 +0000 (UTC)
Subject: master - lockd: remove unused code for overriding lock modes
Message-ID: <20150706164506.03EE26100F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e1733a6271fc0a270bcb5bd2a4b43b62e4a1ddd0
Commit:        e1733a6271fc0a270bcb5bd2a4b43b62e4a1ddd0
Parent:        114744cee1488112f51c49cbe71366ce8bfbd3ea
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Jul 6 11:31:21 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Jul 6 11:44:28 2015 -0500

lockd: remove unused code for overriding lock modes

including the allow_override_lock_modes setting.

It was not possible to override default lock modes any longer,
since the command line options had already been removed.

A mechanism will probably be required later that puts part of
this back.
---
 lib/commands/toolcontext.h   |    5 --
 lib/config/config_settings.h |    3 -
 lib/locking/lvmlockd.c       |  120 +-----------------------------------------
 3 files changed, 1 insertions(+), 127 deletions(-)

diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 5e43dd8..283783f 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -149,11 +149,6 @@ struct cmd_context {
 	const char *report_list_item_separator;
 	int hosttags;
 
-	/* Locking */
-	const char *lock_gl_mode; /* gl mode, from --lock-gl */
-	const char *lock_vg_mode; /* vg mode, from --lock-vg */
-	const char *lock_lv_mode; /* lv mode, from --lock-lv */
-
 	const char *lib_dir;		/* Cache value global/library_dir */
 	char system_dir[PATH_MAX];
 	char dev_dir[PATH_MAX];
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 16fd0bd..b300b3a 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -845,9 +845,6 @@ cfg(global_sanlock_lv_extend_CFG, "sanlock_lv_extend", global_CFG_SECTION, CFG_D
 	"the amount specified here.  Setting this to 0 disables the\n"
 	"automatic extension and can cause lvcreate to fail.\n")
 
-cfg(global_allow_override_lock_modes_CFG, "allow_override_lock_modes", global_CFG_SECTION, 0, CFG_TYPE_BOOL, 0, vsn(2, 2, 124), NULL, 0, NULL,
-	"Allow command options to override normal locking.\n")
-
 cfg(global_read_only_lock_modes_CFG, "read_only_lock_modes", global_CFG_SECTION, 0, CFG_TYPE_BOOL, 0, vsn(2, 2, 124), NULL, 0, NULL,
 	"Limit commands to actions that use read locks.\n"
 	"This disallows any actions that require a write (exclusive) lock.\n")
diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index f80ed75..9e138d0 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -828,9 +828,6 @@ int lockd_init_vg(struct cmd_context *cmd, struct volume_group *vg,
 
 int lockd_free_vg_before(struct cmd_context *cmd, struct volume_group *vg)
 {
-	if (cmd->lock_vg_mode && !strcmp(cmd->lock_vg_mode, "na"))
-		return 1;
-
 	switch (get_lock_type_from_string(vg->lock_type)) {
 	case LOCK_TYPE_NONE:
 	case LOCK_TYPE_CLVM:
@@ -849,9 +846,6 @@ int lockd_free_vg_before(struct cmd_context *cmd, struct volume_group *vg)
 
 void lockd_free_vg_final(struct cmd_context *cmd, struct volume_group *vg)
 {
-	if (cmd->lock_vg_mode && !strcmp(cmd->lock_vg_mode, "na"))
-		return;
-
 	switch (get_lock_type_from_string(vg->lock_type)) {
 	case LOCK_TYPE_NONE:
 	case LOCK_TYPE_CLVM:
@@ -892,10 +886,6 @@ int lockd_start_vg(struct cmd_context *cmd, struct volume_group *vg)
 	if (!is_lockd_type(vg->lock_type))
 		return 1;
 
-	/* Skip starting the vg lockspace when the vg lock is skipped. */
-	if (cmd->lock_vg_mode && !strcmp(cmd->lock_vg_mode, "na"))
-		return 1;
-
 	if (!_use_lvmlockd) {
 		log_error("VG %s start failed: lvmlockd is not enabled", vg->name);
 		return 0;
@@ -1056,36 +1046,6 @@ int lockd_start_wait(struct cmd_context *cmd)
 	return ret;
 }
 
-static int _mode_num(const char *mode)
-{
-	if (!strcmp(mode, "na"))
-		return -2;
-	if (!strcmp(mode, "un"))
-		return -1;
-	if (!strcmp(mode, "nl"))
-		return 0;
-	if (!strcmp(mode, "sh"))
-		return 1;
-	if (!strcmp(mode, "ex"))
-		return 2;
-	return -3;
-}
-
-/* same rules as strcmp */
-static int _mode_compare(const char *m1, const char *m2)
-{
-	int n1 = _mode_num(m1);
-	int n2 = _mode_num(m2);
-
-	if (n1 < n2)
-		return -1;
-	if (n1 == n2)
-		return 0;
-	if (n1 > n2)
-		return 1;
-	return -2;
-}
-
 /*
  * lockd_gl_create() is a variation of lockd_gl() used only by vgcreate.
  * It handles the case that when using sanlock, the global lock does
@@ -1161,21 +1121,6 @@ int lockd_gl_create(struct cmd_context *cmd, const char *def_mode, const char *v
 		return 0;
 	}
 
-	/*
-	 * A specific lock mode was given on the command line.
-	 */
-	if (cmd->lock_gl_mode) {
-		mode = cmd->lock_gl_mode;
-		if (mode && def_mode && strcmp(mode, "enable") && (_mode_compare(mode, def_mode) < 0)) {
-			if (!find_config_tree_bool(cmd, global_allow_override_lock_modes_CFG, NULL)) {
-				log_error("Disallowed lock-gl mode \"%s\"", mode);
-				return 0;
-			} else {
-				log_warn("WARNING: overriding default global lock mode.");
-			}
-		}
-	}
-
 	log_debug("lockd global lock_type %s", vg_lock_type);
 
 	if (!mode)
@@ -1409,28 +1354,10 @@ int lockd_gl(struct cmd_context *cmd, const char *def_mode, uint32_t flags)
 		return 1;
 
 	if (def_mode && !strcmp(def_mode, "un")) {
-		if (cmd->lock_gl_mode && !strcmp(cmd->lock_gl_mode, "na"))
-			return 1;
-
 		mode = "un";
 		goto req;
 	}
 
-	/*
-	 * A specific lock mode was given on the command line.
-	 */
-	if (cmd->lock_gl_mode) {
-		mode = cmd->lock_gl_mode;
-		if (mode && def_mode && (_mode_compare(mode, def_mode) < 0)) {
-			if (!find_config_tree_bool(cmd, global_allow_override_lock_modes_CFG, NULL)) {
-				log_error("Disallowed lock-gl mode \"%s\"", mode);
-				return 0;
-			} else {
-				log_warn("WARNING: overriding default global lock mode.");
-			}
-		}
-	}
-
 	if (!mode)
 		mode = def_mode;
 	if (!mode) {
@@ -1629,9 +1556,6 @@ int lockd_vg(struct cmd_context *cmd, const char *vg_name, const char *def_mode,
 	 * passed back to lockd_vg() for the corresponding unlock.
 	 */
 	if (def_mode && !strcmp(def_mode, "un")) {
-		if (cmd->lock_vg_mode && !strcmp(cmd->lock_vg_mode, "na"))
-			return 1;
-
 		if (prev_state & LDST_FAIL) {
 			log_debug("VG %s unlock skipped: lockd_state is failed", vg_name);
 			return 1;
@@ -1642,21 +1566,6 @@ int lockd_vg(struct cmd_context *cmd, const char *vg_name, const char *def_mode,
 	}
 
 	/*
-	 * A specific lock mode was given on the command line.
-	 */
-	if (cmd->lock_vg_mode) {
-		mode = cmd->lock_vg_mode;
-		if (mode && def_mode && (_mode_compare(mode, def_mode) < 0)) {
-			if (!find_config_tree_bool(cmd, global_allow_override_lock_modes_CFG, NULL)) {
-				log_error("Disallowed lock-vg mode \"%s\"", mode);
-				return 0;
-			} else {
-				log_warn("WARNING: overriding default VG lock mode.");
-			}
-		}
-	}
-
-	/*
 	 * The default mode may not have been provided in the
 	 * function args.  This happens when lockd_vg is called
 	 * from a process_each function that handles different
@@ -1918,30 +1827,9 @@ int lockd_lv_name(struct cmd_context *cmd, struct volume_group *vg,
 	 * For lvchange/vgchange activation, def_mode is "sh" or "ex"
 	 * according to the specific -a{e,s}y mode designation.
 	 * No e,s designation gives NULL def_mode.
-	 *
-	 * The --lock-lv option is saved in cmd->lock_lv_mode.
 	 */
 
-	if (cmd->lock_lv_mode && def_mode && strcmp(cmd->lock_lv_mode, "na") &&
-	    strcmp(cmd->lock_lv_mode, def_mode)) {
-		log_error("Different LV lock modes from activation %s and lock-lv %s",
-			  def_mode, cmd->lock_lv_mode);
-		return 0;
-	}
-
-	/* A specific lock mode was given on the command line. */
-	if (cmd->lock_lv_mode && (_mode_compare(cmd->lock_lv_mode, "sh") < 0)) {
-		if (!find_config_tree_bool(cmd, global_allow_override_lock_modes_CFG, NULL)) {
-			log_error("Disallowed lock-lv mode \"%s\"", cmd->lock_lv_mode);
-			return 0;
-		} else {
-			log_warn("WARNING: overriding default LV lock mode.");
-		}
-	}
-
-	if (cmd->lock_lv_mode)
-		mode = cmd->lock_lv_mode;
-	else if (def_mode)
+	if (def_mode)
 		mode = def_mode;
 
 	if (mode && !strcmp(mode, "sh") && (flags & LDLV_MODE_NO_SH)) {
@@ -2250,9 +2138,6 @@ int lockd_init_lv(struct cmd_context *cmd, struct volume_group *vg, struct logic
 {
 	int lock_type_num = get_lock_type_from_string(vg->lock_type);
 
-	if (cmd->lock_lv_mode && !strcmp(cmd->lock_lv_mode, "na"))
-		return 1;
-
 	switch (lock_type_num) {
 	case LOCK_TYPE_NONE:
 	case LOCK_TYPE_CLVM:
@@ -2374,9 +2259,6 @@ int lockd_init_lv(struct cmd_context *cmd, struct volume_group *vg, struct logic
 int lockd_free_lv(struct cmd_context *cmd, struct volume_group *vg,
 		  const char *lv_name, struct id *lv_id, const char *lock_args)
 {
-	if (cmd->lock_lv_mode && !strcmp(cmd->lock_lv_mode, "na"))
-		return 1;
-
 	switch (get_lock_type_from_string(vg->lock_type)) {
 	case LOCK_TYPE_NONE:
 	case LOCK_TYPE_CLVM:


