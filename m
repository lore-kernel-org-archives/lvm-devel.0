From: David Teigland <teigland@sourceware.org>
Date: Mon, 24 Jul 2017 16:19:15 -0400
Subject: master - vgchange: separate change locktype and allow recovery
Message-ID: <201707242019.v6OKJFiL004968@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f611b68f3c02b9af2521d7ea61061af3709fe87c
Commit:        f611b68f3c02b9af2521d7ea61061af3709fe87c
Parent:        876c4a1b3bdf2d2f9202438a406a803efa01bf9a
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jul 12 16:03:41 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Jul 24 14:12:08 2017 -0500

vgchange: separate change locktype and allow recovery

Add an independent command definition for "vgchange --locktype",
and split the implementation out of the set of common metadata
changes.  It is unlike normal metadata changes, and can only
be run by itself.  (Changing the lock type is similar in
principle to changing the VG name or the VG system ID; it
effects the ability of any host to see or access the VG.)

At some point this command lost the ability to forcibly change
the lock type of a shared VG to "none" (making it a local VG).
This can be necessary to repair shared VGs (e.g. recovery steps
that occur in vg_read are disabled for shared VGs because
they are not locked properly, or recovering sanlock locks
when the PV holding them is lost.)

"vgchange --locktype none --lockopt force VG" is used as the
method of forcing the shared VG to become local so that it
can be repaired.
---
 man/lvmlockd.8_main    |   24 ++-
 tools/command-lines.in |    7 +-
 tools/lvmcmdline.c     |    2 +
 tools/tools.h          |    2 +
 tools/vgchange.c       |  531 +++++++++++++++++++++++++++---------------------
 5 files changed, 329 insertions(+), 237 deletions(-)

diff --git a/man/lvmlockd.8_main b/man/lvmlockd.8_main
index 552eb94..1dbdaf9 100644
--- a/man/lvmlockd.8_main
+++ b/man/lvmlockd.8_main
@@ -610,12 +610,26 @@ The command deactivates the LV.  After deactivating the LV, the command
 uses lvmlockd to release the current lock on the LV.
 
 
+.SS manually repairing a shared VG
+
+Some failure conditions may not be repairable while the VG has a shared
+lock type.  In these cases, it may be possible to repair the VG by
+forcibly changing the lock type to "none".  This is done by adding
+"--lock-opt force" to the normal command for changing the lock type:
+vgchange --lock-type none VG.  The VG lockspace should first be stopped on
+all hosts, and be certain that no hosts are using the VG before this is
+done.
+
+
 .SS recover from lost PV holding sanlock locks
 
-The general approach is to change the VG lock type to "none", and then
-change the lock type back to "sanlock".  This recreates the internal
-lvmlock LV and the necessary locks on it.  Additional steps may be
-required to deal with the missing PV.
+In a sanlock VG, the sanlock locks are held on the hidden "lvmlock" LV.
+If the PV holding this LV is lost, a new lvmlock LV needs to be created.
+To do this, ensure no hosts are using the VG, then forcibly change the
+lock type to "none" (see above).  Then change the lock type back to
+"sanlock" with the normal command for changing the lock type:  vgchange
+--lock-type sanlock VG.  This recreates the internal lvmlock LV with the
+necessary locks.
 
 
 .SS locking system failures
@@ -733,7 +747,7 @@ cat /sys/kernel/config/dlm/cluster/cluster_name
 .IP \[bu] 2
 Change the VG lock type to none:
 .br
-vgchange --lock-type none --force <vgname>
+vgchange --lock-type none --lock-opt force <vgname>
 
 .IP \[bu] 2
 Change the VG lock type back to dlm which sets the new cluster name:
diff --git a/tools/command-lines.in b/tools/command-lines.in
index 7f9c31f..da097af 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -1474,7 +1474,7 @@ OO_VGCHANGE: --autobackup Bool, --ignoremonitoring, --ignoreskippedcluster,
 OO_VGCHANGE_META: --addtag Tag, --deltag Tag,
 --logicalvolume Uint32, --maxphysicalvolumes Uint32, --alloc Alloc, --uuid,
 --clustered Bool, --pvmetadatacopies MetadataCopiesPV, --vgmetadatacopies MetadataCopiesVG,
---physicalextentsize SizeMB, --resizeable Bool, --systemid String, --locktype LockType,
+--physicalextentsize SizeMB, --resizeable Bool, --systemid String,
 --profile String, --detachprofile, --metadataprofile String
 
 vgchange OO_VGCHANGE_META
@@ -1522,6 +1522,11 @@ OP: VG|Tag|Select ...
 ID: vgchange_lockstop
 DESC: Stop the lockspace of a shared VG in lvmlockd.
 
+vgchange --locktype LockType VG
+OO: --lockopt String
+ID: vgchange_locktype
+DESC: Change the lock type for a shared VG.
+
 ---
 
 vgck
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index a952c8c..f23e994 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -103,6 +103,8 @@ static const struct command_function command_functions[CMD_COUNT] = {
 	{ lvchange_poll_CMD, lvchange_monitor_poll_cmd },
 	{ lvchange_persistent_CMD, lvchange_persistent_cmd },
 
+	{ vgchange_locktype_CMD, vgchange_locktype_cmd },
+
 	/* lvconvert utilities related to repair. */
 	{ lvconvert_repair_pvs_or_thinpool_CMD,	lvconvert_repair_pvs_or_thinpool_cmd },
 	{ lvconvert_replace_pv_CMD, lvconvert_replace_pv_cmd },
diff --git a/tools/tools.h b/tools/tools.h
index 9543147..8255cdc 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -223,6 +223,8 @@ int vgchange_activate(struct cmd_context *cmd, struct volume_group *vg,
 
 int vgchange_background_polling(struct cmd_context *cmd, struct volume_group *vg);
 
+int vgchange_locktype_cmd(struct cmd_context *cmd, int argc, char **argv);
+
 struct lv_prop *get_lv_prop(int lvp_enum);
 struct lv_type *get_lv_type(int lvt_enum);
 struct command *get_command(int cmd_enum);
diff --git a/tools/vgchange.c b/tools/vgchange.c
index 2a8f868..dc453f8 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -528,228 +528,6 @@ static int _vgchange_profile(struct cmd_context *cmd,
 	return 1;
 }
 
-static int _vgchange_locktype(struct cmd_context *cmd,
-			      struct volume_group *vg)
-{
-	const char *lock_type = arg_str_value(cmd, locktype_ARG, NULL);
-	struct lv_list *lvl;
-	struct logical_volume *lv;
-	int lv_lock_count = 0;
-
-	if (!lock_type) {
-		log_error(INTERNAL_ERROR "No locktype_ARG.");
-		return 0;
-	}
-
-	/*
-	 * This is a special/forced exception to change the lock type to none.
-	 * It's needed for recovery cases and skips the normal steps of undoing
-	 * the current lock type.  It's a way to forcibly get access to a VG
-	 * when the normal locking mechanisms are not working.
-	 *
-	 * It ignores: the current lvm locking config, lvmlockd, the state of
-	 * the vg on other hosts, etc.  It is meant to just remove any locking
-	 * related metadata from the VG (cluster/lock_type flags, lock_type,
-	 * lock_args).
-	 *
-	 * This can be necessary when manually recovering from certain failures.
-	 * e.g. when a pv is lost containing the lvmlock lv (holding sanlock
-	 * leases), the vg lock_type needs to be changed to none, and then
-	 * back to sanlock, which recreates the lvmlock lv and leases.
-	 */
-	if (!strcmp(lock_type, "none") && arg_is_set(cmd, force_ARG)) {
-		if (yes_no_prompt("Forcibly change VG %s lock type to none? [y/n]: ", vg->name) == 'n') {
-			log_error("VG lock type not changed.");
-			return 0;
-		}
-
-		vg->status &= ~CLUSTERED;
-		vg->lock_type = "none";
-		vg->lock_args = NULL;
-
-		dm_list_iterate_items(lvl, &vg->lvs)
-			lvl->lv->lock_args = NULL;
-
-		return 1;
-	}
-
-	if (!vg->lock_type) {
-		if (vg_is_clustered(vg))
-			vg->lock_type = "clvm";
-		else
-			vg->lock_type = "none";
-	}
-
-	if (!strcmp(vg->lock_type, lock_type)) {
-		log_warn("New lock type %s matches the current lock type %s.",
-			 lock_type, vg->lock_type);
-		return 1;
-	}
-
-	if (is_lockd_type(vg->lock_type) && is_lockd_type(lock_type)) {
-		log_error("Cannot change lock type directly from \"%s\" to \"%s\".",
-			  vg->lock_type, lock_type);
-		log_error("First change lock type to \"none\", then to \"%s\".",
-			  lock_type);
-		return 0;
-	}
-
-	/*
-	 * When lvm is currently using clvm, this function is just an alternative
-	 * to vgchange -c{y,n}, and can:
-	 * - change none to clvm
-	 * - change clvm to none
-	 * - it CANNOT change to or from a lockd type
-	 */
-	if (locking_is_clustered()) {
-		if (is_lockd_type(lock_type)) {
-			log_error("Changing to lock type %s requires lvmlockd.", lock_type);
-			return 0;
-		}
-
-		return _vgchange_clustered(cmd, vg);
-	}
-
-	/*
-	 * When lvm is currently using lvmlockd, this function can:
-	 * - change none to lockd type
-	 * - change none to clvm (with warning about not being able to use it)
-	 * - change lockd type to none
-	 * - change lockd type to clvm (with warning about not being able to use it)
-	 * - change clvm to none
-	 * - change clvm to lockd type
-	 */
-
-	if (lvs_in_vg_activated(vg)) {
-		log_error("Changing VG %s lock type not allowed with active LVs",
-			  vg->name);
-		return 0;
-	}
-
-	/* none to clvm */
-	if (!strcmp(vg->lock_type, "none") && !strcmp(lock_type, "clvm")) {
-		log_warn("New clvm lock type will not be usable with lvmlockd.");
-		vg->status |= CLUSTERED;
-		vg->lock_type = "clvm"; /* this is optional */
-		return 1;
-	}
-
-	/* clvm to none */
-	if (!strcmp(vg->lock_type, "clvm") && !strcmp(lock_type, "none")) {
-		vg->status &= ~CLUSTERED;
-		vg->lock_type = "none";
-		return 1;
-	}
-
-	/* clvm to ..., first undo clvm */
-	if (!strcmp(vg->lock_type, "clvm")) {
-		vg->status &= ~CLUSTERED;
-	}
-
-	/*
-	 * lockd type to ..., first undo lockd type
-	 */
-	if (is_lockd_type(vg->lock_type)) {
-		if (!lockd_free_vg_before(cmd, vg, 1))
-			return 0;
-
-		lockd_free_vg_final(cmd, vg);
-
-		vg->status &= ~CLUSTERED;
-		vg->lock_type = "none";
-		vg->lock_args = NULL;
-
-		dm_list_iterate_items(lvl, &vg->lvs)
-			lvl->lv->lock_args = NULL;
-	}
-
-	/* ... to clvm */
-	if (!strcmp(lock_type, "clvm")) {
-		log_warn("New clvm lock type will not be usable with lvmlockd.");
-		vg->status |= CLUSTERED;
-		vg->lock_type = "clvm"; /* this is optional */
-		vg->system_id = NULL;
-		return 1;
-	}
-
-	/* ... to lockd type */
-	if (is_lockd_type(lock_type)) {
-		/*
-		 * For lock_type dlm, lockd_init_vg() will do a single
-		 * vg_write() that sets lock_type, sets lock_args, clears
-		 * system_id, and sets all LV lock_args to dlm.
-		 * For lock_type sanlock, lockd_init_vg() needs to know
-		 * how many LV locks are needed so that it can make the
-		 * sanlock lv large enough.
-		 */
-		dm_list_iterate_items(lvl, &vg->lvs) {
-			lv = lvl->lv;
-
-			if (lockd_lv_uses_lock(lv)) {
-				lv_lock_count++;
-
-				if (!strcmp(lock_type, "dlm"))
-					lv->lock_args = "dlm";
-			}
-		}
-
-		/*
-		 * See below.  We cannot set valid LV lock_args until stage 1
-		 * of the change is done, so we need to skip the validation of
-		 * the lock_args during stage 1.
-		 */
-		if (!strcmp(lock_type, "sanlock"))
-			vg->skip_validate_lock_args = 1;
-
-		vg->system_id = NULL;
-
-		if (!lockd_init_vg(cmd, vg, lock_type, lv_lock_count)) {
-			log_error("Failed to initialize lock args for lock type %s", lock_type);
-			return 0;
-		}
-
-		/*
-		 * For lock_type sanlock, there must be multiple steps
-		 * because the VG needs an active lvmlock LV before
-		 * LV lock areas can be allocated, which must be done
-		 * before LV lock_args are written.  So, the LV lock_args
-		 * remain unset during the first stage of the conversion.
-		 *
-		 * Stage 1:
-		 * lockd_init_vg() creates and activates the lvmlock LV,
-		 * then sets lock_type, sets lock_args, and clears system_id.
-		 *
-		 * Stage 2:
-		 * We get here, and can now set LV lock_args.  This uses
-		 * the standard code path for allocating LV locks in
-		 * vg_write() by setting LV lock_args to "pending",
-		 * which tells vg_write() to call lockd_init_lv()
-		 * and sets the lv->lock_args value before writing the VG.
-		 */
-		if (!strcmp(lock_type, "sanlock")) {
-			dm_list_iterate_items(lvl, &vg->lvs) {
-				lv = lvl->lv;
-				if (lockd_lv_uses_lock(lv))
-					lv->lock_args = "pending";
-			}
-
-			vg->skip_validate_lock_args = 0;
-		}
-
-		return 1;
-	}
-
-	/* ... to none */
-	if (!strcmp(lock_type, "none")) {
-		vg->lock_type = NULL;
-		vg->system_id = cmd->system_id ? dm_pool_strdup(vg->vgmem, cmd->system_id) : NULL;
-		return 1;
-	}
-
-	log_error("Cannot change to unknown lock type %s", lock_type);
-	return 0;
-}
-
 /*
  * This function will not be called unless the local host is allowed to use the
  * VG.  Either the VG has no system_id, or the VG and host have matching
@@ -934,7 +712,6 @@ static int vgchange_single(struct cmd_context *cmd, const char *vg_name,
 		{ metadataprofile_ARG, &_vgchange_profile },
 		{ profile_ARG, &_vgchange_profile },
 		{ detachprofile_ARG, &_vgchange_profile },
-		{ locktype_ARG, &_vgchange_locktype },
 		{ systemid_ARG, &_vgchange_system_id },
 	};
 
@@ -1049,11 +826,6 @@ static int _lockd_vgchange(struct cmd_context *cmd, int argc, char **argv)
 {
 	/* The default vg lock mode is ex, but these options only need sh. */
 
-	if (!lvmlockd_use() && arg_is_set(cmd, locktype_ARG)) {
-		log_error("Using lock type requires lvmlockd.");
-		return 0;
-	}
-
 	if (!lvmlockd_use() && (arg_is_set(cmd, lockstart_ARG) || arg_is_set(cmd, lockstop_ARG))) {
 		log_error("Using lock start and lock stop requires lvmlockd.");
 		return 0;
@@ -1094,10 +866,10 @@ static int _lockd_vgchange(struct cmd_context *cmd, int argc, char **argv)
 	 * named vgs.
 	 */
 
-	if (arg_is_set(cmd, systemid_ARG) || arg_is_set(cmd, locktype_ARG))
+	if (arg_is_set(cmd, systemid_ARG))
 		cmd->cname->flags &= ~ALL_VGS_IS_DEFAULT;
 
-	if (arg_is_set(cmd, systemid_ARG) || arg_is_set(cmd, locktype_ARG)) {
+	if (arg_is_set(cmd, systemid_ARG)) {
 		/*
 		 * This is a special case where taking the global lock is
 		 * not needed to protect global state, because the change is
@@ -1144,7 +916,6 @@ int vgchange(struct cmd_context *cmd, int argc, char **argv)
 		arg_is_set(cmd, clustered_ARG) ||
 		arg_is_set(cmd, alloc_ARG) ||
 		arg_is_set(cmd, vgmetadatacopies_ARG) ||
-		arg_is_set(cmd, locktype_ARG) ||
 		arg_is_set(cmd, systemid_ARG);
 
 	int update = update_partial_safe || update_partial_unsafe;
@@ -1272,3 +1043,301 @@ int vgchange(struct cmd_context *cmd, int argc, char **argv)
 	destroy_processing_handle(cmd, handle);
 	return ret;
 }
+
+static int _vgchange_locktype(struct cmd_context *cmd, struct volume_group *vg)
+{
+	const char *lock_type = arg_str_value(cmd, locktype_ARG, NULL);
+	const char *lockopt = arg_str_value(cmd, lockopt_ARG, NULL);
+	struct lv_list *lvl;
+	struct logical_volume *lv;
+	int lv_lock_count = 0;
+
+	/* Special recovery case. */
+	if (lockopt && !strcmp(lock_type, "none") && !strcmp(lockopt, "force")) {
+		vg->status &= ~CLUSTERED;
+		vg->lock_type = "none";
+		vg->lock_args = NULL;
+
+		dm_list_iterate_items(lvl, &vg->lvs)
+			lvl->lv->lock_args = NULL;
+
+		return 1;
+	}
+
+	if (!vg->lock_type) {
+		if (vg_is_clustered(vg))
+			vg->lock_type = "clvm";
+		else
+			vg->lock_type = "none";
+	}
+
+	if (!strcmp(vg->lock_type, lock_type)) {
+		log_warn("New lock type %s matches the current lock type %s.",
+			 lock_type, vg->lock_type);
+		return 1;
+	}
+
+	if (is_lockd_type(vg->lock_type) && is_lockd_type(lock_type)) {
+		log_error("Cannot change lock type directly from \"%s\" to \"%s\".",
+			  vg->lock_type, lock_type);
+		log_error("First change lock type to \"none\", then to \"%s\".",
+			  lock_type);
+		return 0;
+	}
+
+	/*
+	 * When lvm is currently using clvm, this function is just an alternative
+	 * to vgchange -c{y,n}, and can:
+	 * - change none to clvm
+	 * - change clvm to none
+	 * - it CANNOT change to or from a lockd type
+	 */
+	if (locking_is_clustered()) {
+		if (is_lockd_type(lock_type)) {
+			log_error("Changing to lock type %s requires lvmlockd.", lock_type);
+			return 0;
+		}
+
+		return _vgchange_clustered(cmd, vg);
+	}
+
+	/*
+	 * When lvm is currently using lvmlockd, this function can:
+	 * - change none to lockd type
+	 * - change none to clvm (with warning about not being able to use it)
+	 * - change lockd type to none
+	 * - change lockd type to clvm (with warning about not being able to use it)
+	 * - change clvm to none
+	 * - change clvm to lockd type
+	 */
+
+	if (lvs_in_vg_activated(vg)) {
+		log_error("Changing VG %s lock type not allowed with active LVs",
+			  vg->name);
+		return 0;
+	}
+
+	/* none to clvm */
+	if (!strcmp(vg->lock_type, "none") && !strcmp(lock_type, "clvm")) {
+		log_warn("New clvm lock type will not be usable with lvmlockd.");
+		vg->status |= CLUSTERED;
+		vg->lock_type = "clvm"; /* this is optional */
+		return 1;
+	}
+
+	/* clvm to none */
+	if (!strcmp(vg->lock_type, "clvm") && !strcmp(lock_type, "none")) {
+		vg->status &= ~CLUSTERED;
+		vg->lock_type = "none";
+		return 1;
+	}
+
+	/* clvm to ..., first undo clvm */
+	if (!strcmp(vg->lock_type, "clvm")) {
+		vg->status &= ~CLUSTERED;
+	}
+
+	/*
+	 * lockd type to ..., first undo lockd type
+	 */
+	if (is_lockd_type(vg->lock_type)) {
+		if (!lockd_free_vg_before(cmd, vg, 1))
+			return 0;
+
+		lockd_free_vg_final(cmd, vg);
+
+		vg->status &= ~CLUSTERED;
+		vg->lock_type = "none";
+		vg->lock_args = NULL;
+
+		dm_list_iterate_items(lvl, &vg->lvs)
+			lvl->lv->lock_args = NULL;
+	}
+
+	/* ... to clvm */
+	if (!strcmp(lock_type, "clvm")) {
+		log_warn("New clvm lock type will not be usable with lvmlockd.");
+		vg->status |= CLUSTERED;
+		vg->lock_type = "clvm"; /* this is optional */
+		vg->system_id = NULL;
+		return 1;
+	}
+
+	/* ... to lockd type */
+	if (is_lockd_type(lock_type)) {
+		/*
+		 * For lock_type dlm, lockd_init_vg() will do a single
+		 * vg_write() that sets lock_type, sets lock_args, clears
+		 * system_id, and sets all LV lock_args to dlm.
+		 * For lock_type sanlock, lockd_init_vg() needs to know
+		 * how many LV locks are needed so that it can make the
+		 * sanlock lv large enough.
+		 */
+		dm_list_iterate_items(lvl, &vg->lvs) {
+			lv = lvl->lv;
+
+			if (lockd_lv_uses_lock(lv)) {
+				lv_lock_count++;
+
+				if (!strcmp(lock_type, "dlm"))
+					lv->lock_args = "dlm";
+			}
+		}
+
+		/*
+		 * See below.  We cannot set valid LV lock_args until stage 1
+		 * of the change is done, so we need to skip the validation of
+		 * the lock_args during stage 1.
+		 */
+		if (!strcmp(lock_type, "sanlock"))
+			vg->skip_validate_lock_args = 1;
+
+		vg->system_id = NULL;
+
+		if (!lockd_init_vg(cmd, vg, lock_type, lv_lock_count)) {
+			log_error("Failed to initialize lock args for lock type %s", lock_type);
+			return 0;
+		}
+
+		/*
+		 * For lock_type sanlock, there must be multiple steps
+		 * because the VG needs an active lvmlock LV before
+		 * LV lock areas can be allocated, which must be done
+		 * before LV lock_args are written.  So, the LV lock_args
+		 * remain unset during the first stage of the conversion.
+		 *
+		 * Stage 1:
+		 * lockd_init_vg() creates and activates the lvmlock LV,
+		 * then sets lock_type, sets lock_args, and clears system_id.
+		 *
+		 * Stage 2:
+		 * We get here, and can now set LV lock_args.  This uses
+		 * the standard code path for allocating LV locks in
+		 * vg_write() by setting LV lock_args to "pending",
+		 * which tells vg_write() to call lockd_init_lv()
+		 * and sets the lv->lock_args value before writing the VG.
+		 */
+		if (!strcmp(lock_type, "sanlock")) {
+			dm_list_iterate_items(lvl, &vg->lvs) {
+				lv = lvl->lv;
+				if (lockd_lv_uses_lock(lv))
+					lv->lock_args = "pending";
+			}
+
+			vg->skip_validate_lock_args = 0;
+		}
+
+		return 1;
+	}
+
+	/* ... to none */
+	if (!strcmp(lock_type, "none")) {
+		vg->lock_type = NULL;
+		vg->system_id = cmd->system_id ? dm_pool_strdup(vg->vgmem, cmd->system_id) : NULL;
+		return 1;
+	}
+
+	log_error("Cannot change to unknown lock type %s", lock_type);
+	return 0;
+}
+
+static int _vgchange_locktype_single(struct cmd_context *cmd, const char *vg_name,
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
+	if (!_vgchange_locktype(cmd, vg))
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
+int vgchange_locktype_cmd(struct cmd_context *cmd, int argc, char **argv)
+{
+	struct processing_handle *handle;
+	const char *lock_type = arg_str_value(cmd, locktype_ARG, NULL);
+	const char *lockopt = arg_str_value(cmd, lockopt_ARG, NULL);
+	int ret;
+
+	/*
+	 * vgchange --locktype none --lockopt force VG
+	 *
+	 * This is a special/forced exception to change the lock type to none.
+	 * It's needed for recovery cases and skips the normal steps of undoing
+	 * the current lock type.  It's a way to forcibly get access to a VG
+	 * when the normal locking mechanisms are not working.
+	 *
+	 * It ignores: the current lvm locking config, lvmlockd, the state of
+	 * the vg on other hosts, etc.  It is meant to just remove any locking
+	 * related metadata from the VG (cluster/lock_type flags, lock_type,
+	 * lock_args).
+	 *
+	 * This can be necessary when manually recovering from certain failures.
+	 * e.g. when a pv is lost containing the lvmlock lv (holding sanlock
+	 * leases), the vg lock_type needs to be changed to none, and then
+	 * back to sanlock, which recreates the lvmlock lv and leases.
+	 *
+	 * Set lockd_gl_disable, lockd_vg_disable, lockd_lv_disable to
+	 * disable locking.  lockd_gl(), lockd_vg() and lockd_lv() will
+	 * just return success when they see the disable flag set.
+	 */
+	if (lockopt && !strcmp(lockopt, "force")) {
+		if (strcmp(lock_type, "none")) {
+			log_error("Lock type can only be forced to \"none\" for recovery.");
+			return 0;
+		}
+
+		if (yes_no_prompt("Forcibly change VG lock type to none? [y/n]: ") == 'n') {
+			log_error("VG lock type not changed.");
+			return 0;
+		}
+
+		cmd->lockd_gl_disable = 1;
+		cmd->lockd_vg_disable = 1;
+		cmd->lockd_lv_disable = 1;
+		cmd->handles_missing_pvs = 1;
+		goto process;
+	}
+
+	if (!lvmlockd_use()) {
+		log_error("Using lock type requires lvmlockd.");
+		return 0;
+	}
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
+process:
+	if (!(handle = init_processing_handle(cmd, NULL))) {
+		log_error("Failed to initialize processing handle.");
+		return ECMD_FAILED;
+	}
+
+	ret = process_each_vg(cmd, argc, argv, NULL, NULL, READ_FOR_UPDATE, 0, handle, &_vgchange_locktype_single);
+
+	destroy_processing_handle(cmd, handle);
+	return ret;
+}
+


