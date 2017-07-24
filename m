From: David Teigland <teigland@sourceware.org>
Date: Mon, 24 Jul 2017 16:12:10 -0400
Subject: master - vgchange: split out code for systemid
Message-ID: <201707242012.v6OKCAhn004012@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1460cac27391ace1047588bb915d2734e4703fa6
Commit:        1460cac27391ace1047588bb915d2734e4703fa6
Parent:        07cd88dcfa1411f23f5c0c8189377eee8ea2ee50
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jul 13 13:43:39 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Jul 24 14:12:08 2017 -0500

vgchange: split out code for systemid

Use the command definitions to separate the implementation
of vgchange systemid from the rest of vgchange.
---
 tools/command-lines.in |    6 ++-
 tools/lvmcmdline.c     |    1 +
 tools/tools.h          |    1 +
 tools/vgchange.c       |  112 ++++++++++++++++++++++++++----------------------
 4 files changed, 68 insertions(+), 52 deletions(-)

diff --git a/tools/command-lines.in b/tools/command-lines.in
index 4cfbe74..f2ad915 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -1474,7 +1474,7 @@ OO_VGCHANGE: --autobackup Bool, --ignoremonitoring, --ignoreskippedcluster,
 OO_VGCHANGE_META: --addtag Tag, --deltag Tag,
 --logicalvolume Uint32, --maxphysicalvolumes Uint32, --alloc Alloc, --uuid,
 --clustered Bool, --pvmetadatacopies MetadataCopiesPV, --vgmetadatacopies MetadataCopiesVG,
---physicalextentsize SizeMB, --resizeable Bool, --systemid String,
+--physicalextentsize SizeMB, --resizeable Bool,
 --profile String, --detachprofile, --metadataprofile String
 
 vgchange OO_VGCHANGE_META
@@ -1510,6 +1510,10 @@ OP: VG|Tag|Select ...
 ID: vgchange_refresh
 DESC: Reactivate LVs using the latest metadata.
 
+vgchange --systemid String VG
+ID: vgchange_systemid
+DESC: Change the system ID of a VG.
+
 vgchange --lockstart
 OO: --lockopt String, --select String
 OP: VG|Tag|Select ...
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index dda75c6..ae55e12 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -106,6 +106,7 @@ static const struct command_function command_functions[CMD_COUNT] = {
 	{ vgchange_locktype_CMD, vgchange_locktype_cmd },
 	{ vgchange_lockstart_CMD, vgchange_lock_start_stop_cmd },
 	{ vgchange_lockstop_CMD, vgchange_lock_start_stop_cmd },
+	{ vgchange_systemid_CMD, vgchange_systemid_cmd },
 
 	/* lvconvert utilities related to repair. */
 	{ lvconvert_repair_pvs_or_thinpool_CMD,	lvconvert_repair_pvs_or_thinpool_cmd },
diff --git a/tools/tools.h b/tools/tools.h
index b2ddad2..ba4edeb 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -225,6 +225,7 @@ int vgchange_background_polling(struct cmd_context *cmd, struct volume_group *vg
 
 int vgchange_locktype_cmd(struct cmd_context *cmd, int argc, char **argv);
 int vgchange_lock_start_stop_cmd(struct cmd_context *cmd, int argc, char **argv);
+int vgchange_systemid_cmd(struct cmd_context *cmd, int argc, char **argv);
 
 struct lv_prop *get_lv_prop(int lvp_enum);
 struct lv_type *get_lv_type(int lvt_enum);
diff --git a/tools/vgchange.c b/tools/vgchange.c
index 43ad962..263b5a6 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -690,7 +690,6 @@ static int vgchange_single(struct cmd_context *cmd, const char *vg_name,
 			   struct volume_group *vg,
 			   struct processing_handle *handle)
 {
-	struct vgchange_params *vp = (struct vgchange_params *)handle->custom_handle;
 	int ret = ECMD_PROCESSED;
 	unsigned i;
 	struct lv_list *lvl;
@@ -712,7 +711,6 @@ static int vgchange_single(struct cmd_context *cmd, const char *vg_name,
 		{ metadataprofile_ARG, &_vgchange_profile },
 		{ profile_ARG, &_vgchange_profile },
 		{ detachprofile_ARG, &_vgchange_profile },
-		{ systemid_ARG, &_vgchange_system_id },
 	};
 
 	if (vg_is_exported(vg)) {
@@ -803,51 +801,6 @@ static int vgchange_single(struct cmd_context *cmd, const char *vg_name,
 	return ret;
 }
 
-/*
- * vgchange can do different things that require different
- * locking, so look at each of those things here.
- *
- * Set up overrides for the default VG locking for various special cases.
- * The VG lock will be acquired in process_each_vg.
- *
- * Acquire the gl lock according to which kind of vgchange command this is.
- */
-
-static int _lockd_vgchange(struct cmd_context *cmd, int argc, char **argv)
-{
-	/* The default vg lock mode is ex, but these options only need sh. */
-
-	if (arg_is_set(cmd, activate_ARG) || arg_is_set(cmd, refresh_ARG)) {
-		cmd->lockd_vg_default_sh = 1;
-		/* Allow deactivating if locks fail. */
-		if (is_change_activating((activation_change_t)arg_uint_value(cmd, activate_ARG, CHANGE_AY)))
-			cmd->lockd_vg_enforce_sh = 1;
-	}
-
-	/*
-	 * Changing system_id or lock_type must only be done on explicitly
-	 * named vgs.
-	 */
-
-	if (arg_is_set(cmd, systemid_ARG))
-		cmd->cname->flags &= ~ALL_VGS_IS_DEFAULT;
-
-	if (arg_is_set(cmd, systemid_ARG)) {
-		/*
-		 * This is a special case where taking the global lock is
-		 * not needed to protect global state, because the change is
-		 * only to an existing VG.  But, taking the global lock ex is
-		 * helpful in this case to trigger a global cache validation
-		 * on other hosts, to cause them to see the new system_id or
-		 * lock_type.
-		 */
-		if (!lockd_gl(cmd, "ex", LDGL_UPDATE_NAMES))
-			return 0;
-	}
-
-	return 1;
-}
-
 int vgchange(struct cmd_context *cmd, int argc, char **argv)
 {
 	struct processing_handle *handle;
@@ -875,8 +828,7 @@ int vgchange(struct cmd_context *cmd, int argc, char **argv)
 		arg_is_set(cmd, physicalextentsize_ARG) ||
 		arg_is_set(cmd, clustered_ARG) ||
 		arg_is_set(cmd, alloc_ARG) ||
-		arg_is_set(cmd, vgmetadatacopies_ARG) ||
-		arg_is_set(cmd, systemid_ARG);
+		arg_is_set(cmd, vgmetadatacopies_ARG);
 
 	int update = update_partial_safe || update_partial_unsafe;
 
@@ -964,8 +916,14 @@ int vgchange(struct cmd_context *cmd, int argc, char **argv)
 	if (arg_is_set(cmd, activate_ARG))
 		cmd->include_active_foreign_vgs = 1;
 
-	if (!_lockd_vgchange(cmd, argc, argv))
-		return_ECMD_FAILED;
+	/* The default vg lock mode is ex, but these options only need sh. */
+	if ((cmd->command->command_enum == vgchange_activate_CMD) ||
+	    (cmd->command->command_enum == vgchange_refresh_CMD)) {
+		cmd->lockd_vg_default_sh = 1;
+		/* Allow deactivating if locks fail. */
+		if (is_change_activating((activation_change_t)arg_uint_value(cmd, activate_ARG, CHANGE_AY)))
+			cmd->lockd_vg_enforce_sh = 1;
+	}
 
 	if (update)
 		flags |= READ_FOR_UPDATE;
@@ -1360,3 +1318,55 @@ int vgchange_lock_start_stop_cmd(struct cmd_context *cmd, int argc, char **argv)
 	return ret;
 }
 
+static int _vgchange_systemid_single(struct cmd_context *cmd, const char *vg_name,
+			             struct volume_group *vg,
+			             struct processing_handle *handle)
+{
+	if (vg_is_exported(vg)) {
+		log_error("Volume group \"%s\" is exported", vg_name);
+		return ECMD_FAILED;
+	}
+
+	if (!archive(vg))
+		return_ECMD_FAILED;
+
+	if (!_vgchange_system_id(cmd, vg))
+		return_ECMD_FAILED;
+
+	if (!vg_write(vg) || !vg_commit(vg))
+		return_ECMD_FAILED;
+
+	backup(vg);
+
+	log_print_unless_silent("Volume group \"%s\" successfully changed", vg->name);
+
+	return ECMD_PROCESSED;
+}
+
+int vgchange_systemid_cmd(struct cmd_context *cmd, int argc, char **argv)
+{
+	struct processing_handle *handle;
+	int ret;
+
+	/*
+	 * This is a special case where taking the global lock is
+	 * not needed to protect global state, because the change is
+	 * only to an existing VG.  But, taking the global lock ex is
+	 * helpful in this case to trigger a global cache validation
+	 * on other hosts, to cause them to see the new system_id or
+	 * lock_type.
+	 */
+	if (!lockd_gl(cmd, "ex", LDGL_UPDATE_NAMES))
+		return 0;
+
+	if (!(handle = init_processing_handle(cmd, NULL))) {
+		log_error("Failed to initialize processing handle.");
+		return ECMD_FAILED;
+	}
+
+	ret = process_each_vg(cmd, argc, argv, NULL, NULL, READ_FOR_UPDATE, 0, handle, &_vgchange_systemid_single);
+
+	destroy_processing_handle(cmd, handle);
+	return ret;
+}
+


