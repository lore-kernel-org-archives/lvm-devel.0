From: David Teigland <teigland@sourceware.org>
Date: Fri, 1 Jun 2018 14:16:03 -0400
Subject: master - lvmlockd: primarily use vg_is_shared
Message-ID: <201806011816.w51IG3lw002027@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b6f0f20da25ac4ab6b5294129fd2f383bf818062
Commit:        b6f0f20da25ac4ab6b5294129fd2f383bf818062
Parent:        c4497ee9e849d2d6c74412de21c6c3823d4de5f1
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jun 1 10:04:54 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jun 1 13:15:22 2018 -0500

lvmlockd: primarily use vg_is_shared

to check if a vg uses an lvmlockd lock_type,
instead of the equivalent but longer is_lockd_type.
---
 lib/cache/lvmetad.c       |    6 +++---
 lib/locking/lvmlockd.c    |   12 ++++++------
 lib/metadata/lv_manip.c   |    2 +-
 lib/metadata/metadata.c   |   12 ++++++------
 lib/metadata/mirror.c     |    2 +-
 lib/metadata/raid_manip.c |    2 +-
 lib/metadata/vg.c         |    2 +-
 tools/lvconvert.c         |   14 +++++++-------
 tools/lvcreate.c          |    4 ++--
 tools/pvmove.c            |    2 +-
 tools/pvscan.c            |    2 +-
 tools/vgchange.c          |    2 +-
 tools/vgcreate.c          |    2 +-
 tools/vgexport.c          |    2 +-
 tools/vgimport.c          |    2 +-
 tools/vgmerge.c           |    2 +-
 tools/vgsplit.c           |    2 +-
 17 files changed, 36 insertions(+), 36 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index aa1edc9..fc46c07 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -1069,14 +1069,14 @@ struct volume_group *lvmetad_vg_lookup(struct cmd_context *cmd, const char *vgna
 		 * host.
 		 */
 
-		if (is_lockd_type(vg->lock_type) && cmd->include_shared_vgs) {
+		if (vg_is_shared(vg) && cmd->include_shared_vgs) {
 			log_debug_lvmetad("Rescan VG %s because including shared", vgname);
 			rescan = 1;
-		} else if (is_lockd_type(vg->lock_type) && cmd->lockd_vg_rescan) {
+		} else if (vg_is_shared(vg) && cmd->lockd_vg_rescan) {
 			log_debug_lvmetad("Rescan VG %s because no lvmlockd lock is held", vgname);
 			rescan = 1;
 		} else if (dm_config_find_node(reply.cft->root, "vg_invalid")) {
-			if (!is_lockd_type(vg->lock_type)) {
+			if (!vg_is_shared(vg)) {
 				/* Can happen if a previous command failed/crashed without updating lvmetad. */
 				log_warn("WARNING: Reading VG %s from disk because lvmetad metadata is invalid.", vgname);
 			} else {
diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index 8750c32..103286d 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -1020,7 +1020,7 @@ int lockd_start_vg(struct cmd_context *cmd, struct volume_group *vg, int start_i
 
 	memset(uuid, 0, sizeof(uuid));
 
-	if (!is_lockd_type(vg->lock_type))
+	if (!vg_is_shared(vg))
 		return 1;
 
 	if (!_use_lvmlockd) {
@@ -1111,7 +1111,7 @@ int lockd_stop_vg(struct cmd_context *cmd, struct volume_group *vg)
 	int result;
 	int ret;
 
-	if (!is_lockd_type(vg->lock_type))
+	if (!vg_is_shared(vg)))
 		return 1;
 	if (!_use_lvmlockd)
 		return 0;
@@ -1996,7 +1996,7 @@ int lockd_vg_update(struct volume_group *vg)
 	int result;
 	int ret;
 
-	if (!is_lockd_type(vg->lock_type))
+	if (!vg_is_shared(vg))
 		return 1;
 	if (!_use_lvmlockd)
 		return 0;
@@ -2253,7 +2253,7 @@ static int _lockd_lv_mirror(struct cmd_context *cmd, struct logical_volume *lv,
 int lockd_lv(struct cmd_context *cmd, struct logical_volume *lv,
 	     const char *def_mode, uint32_t flags)
 {
-	if (!is_lockd_type(lv->vg->lock_type))
+	if (!vg_is_shared(lv->vg))
 		return 1;
 
 	if (!_use_lvmlockd) {
@@ -2586,7 +2586,7 @@ int lockd_rename_vg_before(struct cmd_context *cmd, struct volume_group *vg)
 	int result;
 	int ret;
 
-	if (!is_lockd_type(vg->lock_type))
+	if (!vg_is_shared(vg))
 		return 1;
 	if (!_use_lvmlockd)
 		return 0;
@@ -2650,7 +2650,7 @@ int lockd_rename_vg_final(struct cmd_context *cmd, struct volume_group *vg, int
 	int result;
 	int ret;
 
-	if (!is_lockd_type(vg->lock_type))
+	if (!vg_is_shared(vg))
 		return 1;
 	if (!_use_lvmlockd)
 		return 0;
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index c36f60f..b78e5d0 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7801,7 +7801,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		lv->status |= LV_TEMPORARY;
 
 	if (seg_is_cache(lp)) {
-		if (is_lockd_type(lv->vg->lock_type)) {
+		if (vg_is_shared(vg)) {
 			if (is_change_activating(lp->activate)) {
 				if (!lv_active_change(cmd, lv, CHANGE_AEY, 0)) {
 					log_error("Aborting. Failed to activate LV %s.",
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 87b9616..6525cf9 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2576,7 +2576,7 @@ int vg_validate(struct volume_group *vg)
 		goto out;
 	}
 
-	if (is_lockd_type(vg->lock_type)) {
+	if (vg_is_shared(vg)) {
 		if (!vg->lock_args) {
 			log_error(INTERNAL_ERROR "VG %s with lock_type %s without lock_args",
 				  vg->name, vg->lock_type);
@@ -2612,7 +2612,7 @@ int vg_validate(struct volume_group *vg)
 	}
 
 	dm_list_iterate_items(lvl, &vg->lvs) {
-		if (is_lockd_type(vg->lock_type)) {
+		if (vg_is_shared(vg)) {
 			if (lockd_lv_uses_lock(lvl->lv)) {
 				if (vg->skip_validate_lock_args)
 					continue;
@@ -3556,7 +3556,7 @@ static int _repair_inconsistent_vg(struct volume_group *vg, uint32_t lockd_state
 		return 0;
 	}
 
-	if (is_lockd_type(vg->lock_type) && !(lockd_state & LDST_EX)) {
+	if (vg_is_shared(vg) && !(lockd_state & LDST_EX)) {
 		log_verbose("Skip metadata repair for shared VG without exclusive lock.");
 		return 0;
 	}
@@ -3602,7 +3602,7 @@ static int _wipe_outdated_pvs(struct cmd_context *cmd, struct volume_group *vg,
 		return 0;
 	}
 
-	if (is_lockd_type(vg->lock_type) && !(lockd_state & LDST_EX)) {
+	if (vg_is_shared(vg) && !(lockd_state & LDST_EX)) {
 		log_verbose("Skip wiping outdated PVs for shared VG without exclusive lock.");
 		return 0;
 	}
@@ -3684,7 +3684,7 @@ static int _check_or_repair_pv_ext(struct cmd_context *cmd,
 					    "VG %s but not marked as used.",
 					    pv_dev_name(pvl->pv), vg->name);
 				*inconsistent_pvs = 1;
-			} else if (is_lockd_type(vg->lock_type) && !(lockd_state & LDST_EX)) {
+			} else if (vg_is_shared(vg) && !(lockd_state & LDST_EX)) {
 				log_warn("Skip repair of PV %s that is in shared "
 					    "VG %s but not marked as used.",
 					    pv_dev_name(pvl->pv), vg->name);
@@ -5260,7 +5260,7 @@ static int _access_vg_lock_type(struct cmd_context *cmd, struct volume_group *vg
 	/*
 	 * Local VG requires no lock from lvmlockd.
 	 */
-	if (!is_lockd_type(vg->lock_type))
+	if (!vg_is_shared(vg))
 		return 1;
 
 	/*
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 1aa35fb..5b01873 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -426,7 +426,7 @@ static int _activate_lv_like_model(struct logical_volume *model,
 {
 	/* FIXME: run all cases through lv_active_change when clvm variants are gone. */
 
-	if (is_lockd_type(lv->vg->lock_type))
+	if (vg_is_shared(vg))
 		return lv_active_change(lv->vg->cmd, lv, CHANGE_AEY, 0);
 
 	if (lv_is_active_exclusive(model)) {
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index f53915b..9b4cb83 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -3426,7 +3426,7 @@ int lv_raid_split(struct logical_volume *lv, int yes, const char *split_name,
 
 	/* FIXME: run all cases through lv_active_change when clvm variants are gone. */
 
-	if (is_lockd_type(lvl->lv->vg->lock_type)) {
+	if (vg_is_shared(lvl->lv->vg)) {
 		if (!lv_active_change(lv->vg->cmd, lvl->lv, CHANGE_AEY, 0))
 			return_0;
 	} else if (!activate_lv_excl_local(cmd, lvl->lv))
diff --git a/lib/metadata/vg.c b/lib/metadata/vg.c
index 71f6e14..b44c7ca 100644
--- a/lib/metadata/vg.c
+++ b/lib/metadata/vg.c
@@ -709,7 +709,7 @@ char *vg_attr_dup(struct dm_pool *mem, const struct volume_group *vg)
 
 	if (vg_is_clustered(vg))
 		repstr[5] = 'c';
-	else if (is_lockd_type(vg->lock_type))
+	else if (vg_is_shared(vg))
 		repstr[5] = 's';
 	else
 		repstr[5] = '-';
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 1f7fd79..be4b1d0 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1802,7 +1802,7 @@ static int _lvconvert_splitsnapshot(struct cmd_context *cmd, struct logical_volu
 		return 0;
 	}
 
-	if (is_lockd_type(vg->lock_type)) {
+	if (vg_is_shared(vg)) {
 		/* FIXME: we need to create a lock for the new LV. */
 		log_error("Unable to split snapshots in VG with lock_type %s.", vg->lock_type);
 		return 0;
@@ -2622,7 +2622,7 @@ static int _lvconvert_to_thin_with_external(struct cmd_context *cmd,
 	 */
 	lvc.lv_name = origin_name;
 
-	if (is_lockd_type(vg->lock_type)) {
+	if (vg_is_shared(vg)) {
 		/*
 		 * FIXME: external origins don't work in lockd VGs.
 		 * Prior to the lvconvert, there's a lock associated with
@@ -2936,7 +2936,7 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 	zero_metadata = (to_cachepool) ? arg_int_value(cmd, zero_ARG, 1) : 1;
 
 	/* An existing LV needs to have its lock freed once it becomes a data LV. */
-	if (is_lockd_type(vg->lock_type) && lv->lock_args) {
+	if (vg_is_shared(vg) && lv->lock_args) {
 		lockd_data_args = dm_pool_strdup(cmd->mem, lv->lock_args);
 		lockd_data_name = dm_pool_strdup(cmd->mem, lv->name);
 		memcpy(&lockd_data_id, &lv->lvid.id[1], sizeof(struct id));
@@ -2975,7 +2975,7 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 		}
 
 		/* An existing LV needs to have its lock freed once it becomes a meta LV. */
-		if (is_lockd_type(vg->lock_type) && metadata_lv->lock_args) {
+		if (vg_is_shared(vg) && metadata_lv->lock_args) {
 			lockd_meta_args = dm_pool_strdup(cmd->mem, metadata_lv->lock_args);
 			lockd_meta_name = dm_pool_strdup(cmd->mem, metadata_lv->name);
 			memcpy(&lockd_meta_id, &metadata_lv->lvid.id[1], sizeof(struct id));
@@ -3241,7 +3241,7 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 	 * Locks are removed from existing LVs that are being converted to
 	 * data and meta LVs (they are unlocked and deleted below.)
 	 */
-	if (is_lockd_type(vg->lock_type)) {
+	if (vg_is_shared(vg)) {
 		if (to_cachepool) {
 			data_lv->lock_args = NULL;
 			metadata_lv->lock_args = NULL;
@@ -3851,7 +3851,7 @@ static int _lvconvert_combine_split_snapshot_single(struct cmd_context *cmd,
 {
 	const char *origin_name = cmd->position_argv[0];
 
-	if (is_lockd_type(lv->vg->lock_type)) {
+	if (vg_is_shared(lv->vg)) {
 		log_error("Unable to combine split snapshots in VG with lock_type %s", lv->vg->lock_type);
 		return ECMD_FAILED;
 	}
@@ -4225,7 +4225,7 @@ static int _lvconvert_swap_pool_metadata_single(struct cmd_context *cmd,
 	struct logical_volume *metadata_lv;
 	const char *metadata_name;
 
-	if (is_lockd_type(lv->vg->lock_type)) {
+	if (vg_is_shared(lv->vg)) {
 		/* FIXME: need to swap locks betwen LVs? */
 		log_error("Unable to swap pool metadata in VG with lock_type %s", lv->vg->lock_type);
 		goto out;
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 867cde1..5c9d448 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -1231,7 +1231,7 @@ static int _determine_cache_argument(struct volume_group *vg,
 					    display_lvname(lv));
 				return 1;
 
-			} else if (is_lockd_type(vg->lock_type)) {
+			} else if (vg_is_shared(vg)) {
 				if (!lv_active_change(cmd, lv, CHANGE_AEY, 0)) {
 					log_error("Cannot activate cache origin %s.",
 						   display_lvname(lv));
@@ -1645,7 +1645,7 @@ static int _lvcreate_single(struct cmd_context *cmd, const char *vg_name,
 			    lp->snapshot ? " as snapshot of " : "",
 			    lp->snapshot ? lp->origin_name : "", lp->segtype->name);
 
-	if (is_lockd_type(vg->lock_type)) {
+	if (vg_is_shared(vg)) {
 		if (cmd->command->command_enum == lvcreate_thin_vol_with_thinpool_or_sparse_snapshot_CMD) {
 			log_error("Use lvconvert to create thin pools and cache pools in a shared VG.");
 			goto out;
diff --git a/tools/pvmove.c b/tools/pvmove.c
index 2f7bf60..68194b8 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -642,7 +642,7 @@ static int _pvmove_setup_single(struct cmd_context *cmd,
 	 * other hosts.  For LVs that are active on multiple hosts (sh), we
 	 * would need to used cluster mirrors.
 	 */
-	if (is_lockd_type(vg->lock_type)) {
+	if (vg_is_shared(vg))) {
 		if (!lv) {
 			log_error("pvmove in a shared VG requires a named LV.");
 			return ECMD_FAILED;
diff --git a/tools/pvscan.c b/tools/pvscan.c
index e31c7f9..c7c2744 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -197,7 +197,7 @@ static int _pvscan_autoactivate_single(struct cmd_context *cmd, const char *vg_n
 	if (vg_is_exported(vg))
 		return ECMD_PROCESSED;
 
-	if (is_lockd_type(vg->lock_type))
+	if (vg_is_shared(vg)))
 		return ECMD_PROCESSED;
 
 	log_debug("pvscan autoactivating VG %s.", vg_name);
diff --git a/tools/vgchange.c b/tools/vgchange.c
index e231c86..ee6c3b9 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -631,7 +631,7 @@ static int _vgchange_lock_start(struct cmd_context *cmd, struct volume_group *vg
 	int auto_opt = 0;
 	int r;
 
-	if (!is_lockd_type(vg->lock_type))
+	if (!vg_is_shared(vg))
 		return 1;
 
 	if (arg_is_set(cmd, force_ARG))
diff --git a/tools/vgcreate.c b/tools/vgcreate.c
index e9f9073..52c4825 100644
--- a/tools/vgcreate.c
+++ b/tools/vgcreate.c
@@ -207,7 +207,7 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 	 * used after this command completes (otherwise, the VG can only be
 	 * read without locks until the lockspace is done starting.)
 	 */
-	if (is_lockd_type(vg->lock_type)) {
+	if (vg_is_shared(vg)) {
 		const char *start_opt = arg_str_value(cmd, lockopt_ARG, NULL);
 
 		if (!lockd_start_vg(cmd, vg, 1)) {
diff --git a/tools/vgexport.c b/tools/vgexport.c
index 76cf819..86dad3a 100644
--- a/tools/vgexport.c
+++ b/tools/vgexport.c
@@ -28,7 +28,7 @@ static int vgexport_single(struct cmd_context *cmd __attribute__((unused)),
 		goto bad;
 	}
 
-	if (is_lockd_type(vg->lock_type)) {
+	if (vg_is_shared(vg)) {
 		struct lv_list *lvl;
 		dm_list_iterate_items(lvl, &vg->lvs) {
 			if (!lockd_lv_uses_lock(lvl->lv))
diff --git a/tools/vgimport.c b/tools/vgimport.c
index ea50198..8ef8709 100644
--- a/tools/vgimport.c
+++ b/tools/vgimport.c
@@ -38,7 +38,7 @@ static int _vgimport_single(struct cmd_context *cmd,
 
 	vg->status &= ~EXPORTED_VG;
 
-	if (!is_lockd_type(vg->lock_type))
+	if (!vg_is_shared(vg))
 		vg->system_id = cmd->system_id ? dm_pool_strdup(vg->vgmem, cmd->system_id) : NULL;
 
 	dm_list_iterate_items(pvl, &vg->pvs) {
diff --git a/tools/vgmerge.c b/tools/vgmerge.c
index 67c3498..920ed73 100644
--- a/tools/vgmerge.c
+++ b/tools/vgmerge.c
@@ -26,7 +26,7 @@ static struct volume_group *_vgmerge_vg_read(struct cmd_context *cmd,
 		return NULL;
 	}
 
-	if (is_lockd_type(vg->lock_type)) {
+	if (vg_is_shared(vg)) {
 		log_error("vgmerge not allowed for lock_type %s", vg->lock_type);
 		unlock_and_release_vg(cmd, vg, vg_name);
 		return NULL;
diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index 2d39111..e30a671 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -517,7 +517,7 @@ static struct volume_group *_vgsplit_from(struct cmd_context *cmd,
 		return NULL;
 	}
 
-	if (is_lockd_type(vg_from->lock_type)) {
+	if (vg_is_shared(vg_from)) {
 		log_error("vgsplit not allowed for lock_type %s", vg_from->lock_type);
 		unlock_and_release_vg(cmd, vg_from, vg_name_from);
 		return NULL;


