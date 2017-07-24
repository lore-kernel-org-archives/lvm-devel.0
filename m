From: David Teigland <teigland@sourceware.org>
Date: Mon, 24 Jul 2017 16:12:07 -0400
Subject: master - vgchange: split out code for lockstart and lockstop
Message-ID: <201707242012.v6OKC7gi004002@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=07cd88dcfa1411f23f5c0c8189377eee8ea2ee50
Commit:        07cd88dcfa1411f23f5c0c8189377eee8ea2ee50
Parent:        f611b68f3c02b9af2521d7ea61061af3709fe87c
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jul 13 13:26:10 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Jul 24 14:12:08 2017 -0500

vgchange: split out code for lockstart and lockstop

Use the command definitions to separate the implementation
of lockstop and lockstart from the rest of vgchange.
---
 tools/command-lines.in |    4 +-
 tools/lvmcmdline.c     |    2 +
 tools/tools.h          |    1 +
 tools/vgchange.c       |  149 +++++++++++++++++++++++++++---------------------
 4 files changed, 89 insertions(+), 67 deletions(-)

diff --git a/tools/command-lines.in b/tools/command-lines.in
index da097af..4cfbe74 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -1511,13 +1511,13 @@ ID: vgchange_refresh
 DESC: Reactivate LVs using the latest metadata.
 
 vgchange --lockstart
-OO: --lockopt String, OO_VGCHANGE
+OO: --lockopt String, --select String
 OP: VG|Tag|Select ...
 ID: vgchange_lockstart
 DESC: Start the lockspace of a shared VG in lvmlockd.
 
 vgchange --lockstop
-OO: --lockopt String, OO_VGCHANGE
+OO: --lockopt String, --select String
 OP: VG|Tag|Select ...
 ID: vgchange_lockstop
 DESC: Stop the lockspace of a shared VG in lvmlockd.
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index f23e994..dda75c6 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -104,6 +104,8 @@ static const struct command_function command_functions[CMD_COUNT] = {
 	{ lvchange_persistent_CMD, lvchange_persistent_cmd },
 
 	{ vgchange_locktype_CMD, vgchange_locktype_cmd },
+	{ vgchange_lockstart_CMD, vgchange_lock_start_stop_cmd },
+	{ vgchange_lockstop_CMD, vgchange_lock_start_stop_cmd },
 
 	/* lvconvert utilities related to repair. */
 	{ lvconvert_repair_pvs_or_thinpool_CMD,	lvconvert_repair_pvs_or_thinpool_cmd },
diff --git a/tools/tools.h b/tools/tools.h
index 8255cdc..b2ddad2 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -224,6 +224,7 @@ int vgchange_activate(struct cmd_context *cmd, struct volume_group *vg,
 int vgchange_background_polling(struct cmd_context *cmd, struct volume_group *vg);
 
 int vgchange_locktype_cmd(struct cmd_context *cmd, int argc, char **argv);
+int vgchange_lock_start_stop_cmd(struct cmd_context *cmd, int argc, char **argv);
 
 struct lv_prop *get_lv_prop(int lvp_enum);
 struct lv_type *get_lv_type(int lvt_enum);
diff --git a/tools/vgchange.c b/tools/vgchange.c
index dc453f8..43ad962 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -715,8 +715,7 @@ static int vgchange_single(struct cmd_context *cmd, const char *vg_name,
 		{ systemid_ARG, &_vgchange_system_id },
 	};
 
-	if (vg_is_exported(vg) &&
-	    !(arg_is_set(cmd, lockstop_ARG) || arg_is_set(cmd, lockstart_ARG))) {
+	if (vg_is_exported(vg)) {
 		log_error("Volume group \"%s\" is exported", vg_name);
 		return ECMD_FAILED;
 	}
@@ -801,15 +800,7 @@ static int vgchange_single(struct cmd_context *cmd, const char *vg_name,
 	    !vgchange_background_polling(cmd, vg))
 			return_ECMD_FAILED;
 
-	if (arg_is_set(cmd, lockstart_ARG)) {
-		if (!_vgchange_lock_start(cmd, vg, vp))
-			return_ECMD_FAILED;
-	} else if (arg_is_set(cmd, lockstop_ARG)) {
-		if (!_vgchange_lock_stop(cmd, vg))
-			return_ECMD_FAILED;
-	}
-
-        return ret;
+	return ret;
 }
 
 /*
@@ -826,11 +817,6 @@ static int _lockd_vgchange(struct cmd_context *cmd, int argc, char **argv)
 {
 	/* The default vg lock mode is ex, but these options only need sh. */
 
-	if (!lvmlockd_use() && (arg_is_set(cmd, lockstart_ARG) || arg_is_set(cmd, lockstop_ARG))) {
-		log_error("Using lock start and lock stop requires lvmlockd.");
-		return 0;
-	}
-
 	if (arg_is_set(cmd, activate_ARG) || arg_is_set(cmd, refresh_ARG)) {
 		cmd->lockd_vg_default_sh = 1;
 		/* Allow deactivating if locks fail. */
@@ -838,29 +824,6 @@ static int _lockd_vgchange(struct cmd_context *cmd, int argc, char **argv)
 			cmd->lockd_vg_enforce_sh = 1;
 	}
 
-	if (arg_is_set(cmd, lockstop_ARG))
-		cmd->lockd_vg_default_sh = 1;
-
-	/*
-	 * Starting lockspaces.  For VGs not yet started, locks are not
-	 * available to acquire, and for VGs already started, there's nothing
-	 * to do, so disable VG locks.  Try to acquire the global lock sh to
-	 * validate the cache (if no gl is available, lockd_gl will force a
-	 * cache validation).  If the global lock is available, it can be
-	 * benficial to hold sh to serialize lock-start with vgremove of the
-	 * same VG from another host.
-	 */
-	if (arg_is_set(cmd, lockstart_ARG)) {
-		cmd->lockd_vg_disable = 1;
-
-		if (!lockd_gl(cmd, "sh", 0))
-			log_debug("No global lock for lock start");
-
-		/* Disable the lockd_gl in process_each_vg. */
-		cmd->lockd_gl_disable = 1;
-		return 1;
-	}
-
 	/*
 	 * Changing system_id or lock_type must only be done on explicitly
 	 * named vgs.
@@ -888,14 +851,11 @@ static int _lockd_vgchange(struct cmd_context *cmd, int argc, char **argv)
 int vgchange(struct cmd_context *cmd, int argc, char **argv)
 {
 	struct processing_handle *handle;
-	struct vgchange_params vp = { 0 };
 	uint32_t flags = 0;
 	int ret;
 
 	int noupdate =
 		arg_is_set(cmd, activate_ARG) ||
-		arg_is_set(cmd, lockstart_ARG) ||
-		arg_is_set(cmd, lockstop_ARG) ||
 		arg_is_set(cmd, monitor_ARG) ||
 		arg_is_set(cmd, poll_ARG) ||
 		arg_is_set(cmd, refresh_ARG);
@@ -1009,37 +969,14 @@ int vgchange(struct cmd_context *cmd, int argc, char **argv)
 
 	if (update)
 		flags |= READ_FOR_UPDATE;
-	if (arg_is_set(cmd, lockstart_ARG) || arg_is_set(cmd, lockstop_ARG))
-		flags |= READ_ALLOW_EXPORTED;
 
 	if (!(handle = init_processing_handle(cmd, NULL))) {
 		log_error("Failed to initialize processing handle.");
 		return ECMD_FAILED;
 	}
 
-	handle->custom_handle = &vp;
-
 	ret = process_each_vg(cmd, argc, argv, NULL, NULL, flags, 0, handle, &vgchange_single);
 
-	/* Wait for lock-start ops that were initiated in vgchange_lockstart. */
-
-	if (arg_is_set(cmd, lockstart_ARG) && vp.lock_start_count) {
-		const char *start_opt = arg_str_value(cmd, lockopt_ARG, NULL);
-
-		if (!lockd_gl(cmd, "un", 0))
-			stack;
-
-		if (!start_opt || !strcmp(start_opt, "auto")) {
-			if (vp.lock_start_sanlock)
-				log_print_unless_silent("Starting locking.  Waiting for sanlock may take 20 sec to 3 min...");
-			else
-				log_print_unless_silent("Starting locking.  Waiting until locks are ready...");
-			lockd_start_wait(cmd);
-		} else if (!strcmp(start_opt, "nowait") || !strcmp(start_opt, "autonowait")) {
-			log_print_unless_silent("Starting locking.  VG can only be read until locks are ready.");
-		}
-	}
-
 	destroy_processing_handle(cmd, handle);
 	return ret;
 }
@@ -1341,3 +1278,85 @@ process:
 	return ret;
 }
 
+static int _vgchange_lock_start_stop_single(struct cmd_context *cmd, const char *vg_name,
+					    struct volume_group *vg,
+					    struct processing_handle *handle)
+{
+	struct vgchange_params *vp = (struct vgchange_params *)handle->custom_handle;
+
+	if (arg_is_set(cmd, lockstart_ARG)) {
+		if (!_vgchange_lock_start(cmd, vg, vp))
+			return_ECMD_FAILED;
+	} else if (arg_is_set(cmd, lockstop_ARG)) {
+		if (!_vgchange_lock_stop(cmd, vg))
+			return_ECMD_FAILED;
+	}
+
+	return ECMD_PROCESSED;
+}
+
+int vgchange_lock_start_stop_cmd(struct cmd_context *cmd, int argc, char **argv)
+{
+	struct processing_handle *handle;
+	struct vgchange_params vp = { 0 };
+	int ret;
+
+	if (!lvmlockd_use()) {
+		log_error("Using lock start and lock stop requires lvmlockd.");
+		return 0;
+	}
+
+	if (!(handle = init_processing_handle(cmd, NULL))) {
+		log_error("Failed to initialize processing handle.");
+		return ECMD_FAILED;
+	}
+
+	if (arg_is_set(cmd, lockstop_ARG))
+		cmd->lockd_vg_default_sh = 1;
+
+	/*
+	 * Starting lockspaces.  For VGs not yet started, locks are not
+	 * available to acquire, and for VGs already started, there's nothing
+	 * to do, so disable VG locks.  Try to acquire the global lock sh to
+	 * validate the cache (if no gl is available, lockd_gl will force a
+	 * cache validation).  If the global lock is available, it can be
+	 * benficial to hold sh to serialize lock-start with vgremove of the
+	 * same VG from another host.
+	 */
+	if (arg_is_set(cmd, lockstart_ARG)) {
+		cmd->lockd_vg_disable = 1;
+
+		if (!lockd_gl(cmd, "sh", 0))
+			log_debug("No global lock for lock start");
+
+		/* Disable the lockd_gl in process_each_vg. */
+		cmd->lockd_gl_disable = 1;
+	}
+
+	handle->custom_handle = &vp;
+
+	ret = process_each_vg(cmd, argc, argv, NULL, NULL, READ_ALLOW_EXPORTED, 0, handle, &_vgchange_lock_start_stop_single);
+
+	/* Wait for lock-start ops that were initiated in vgchange_lockstart. */
+
+	if (arg_is_set(cmd, lockstart_ARG) && vp.lock_start_count) {
+		const char *start_opt = arg_str_value(cmd, lockopt_ARG, NULL);
+
+		if (!lockd_gl(cmd, "un", 0))
+			stack;
+
+		if (!start_opt || !strcmp(start_opt, "auto")) {
+			if (vp.lock_start_sanlock)
+				log_print_unless_silent("Starting locking.  Waiting for sanlock may take 20 sec to 3 min...");
+			else
+				log_print_unless_silent("Starting locking.  Waiting until locks are ready...");
+			lockd_start_wait(cmd);
+		} else if (!strcmp(start_opt, "nowait") || !strcmp(start_opt, "autonowait")) {
+			log_print_unless_silent("Starting locking.  VG can only be read until locks are ready.");
+		}
+	}
+
+	destroy_processing_handle(cmd, handle);
+	return ret;
+}
+


