From: David Teigland <teigland@sourceware.org>
Date: Thu, 31 May 2018 10:15:01 -0400
Subject: master - lvmlockd: enable repairing shared VG while reading it
Message-ID: <201805311415.w4VEF1pr031281@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6cd052333719e4ae23bfaaa03011ed1a2f384f69
Commit:        6cd052333719e4ae23bfaaa03011ed1a2f384f69
Parent:        063d065388b6437b77815cb1d13a72395a46fd45
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed May 30 12:48:18 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed May 30 12:56:46 2018 -0500

lvmlockd: enable repairing shared VG while reading it

When the lvmlockd lock is shared, upgrade it to ex
when repair (writing) is needed during vg_read.

Pass the lockd state through additional read-related
functions so the instances of repair scattered through
vg_read can be handled.

(Temporary solution until the ad hoc repairs can be
pulled out of vg_read into a top level, centralized
repair function.)
---
 daemons/clvmd/lvm-functions.c    |    2 +-
 lib/metadata/metadata-exported.h |    2 +-
 lib/metadata/metadata.c          |   75 +++++++++++++++++++++-----------------
 tools/toollib.c                  |    2 +-
 4 files changed, 45 insertions(+), 36 deletions(-)

diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index 34da66d..24ed7a0 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -832,7 +832,7 @@ void lvm_do_backup(const char *vgname)
 
 	pthread_mutex_lock(&lvm_lock);
 
-	vg = vg_read_internal(cmd, vgname, NULL /*vgid*/, WARN_PV_READ, &consistent);
+	vg = vg_read_internal(cmd, vgname, NULL /*vgid*/, 0, WARN_PV_READ, &consistent);
 
 	if (vg && consistent)
 		check_current_backup(vg);
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 97184ed..ccf6004 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -652,7 +652,7 @@ int vg_write(struct volume_group *vg);
 int vg_commit(struct volume_group *vg);
 void vg_revert(struct volume_group *vg);
 struct volume_group *vg_read_internal(struct cmd_context *cmd, const char *vg_name,
-				      const char *vgid, uint32_t warn_flags, int *consistent);
+				      const char *vgid, uint32_t lockd_state, uint32_t warn_flags, int *consistent);
 
 #define get_pvs( cmd ) get_pvs_internal((cmd), NULL, NULL)
 #define get_pvs_perserve_vg( cmd, pv_list, vg_list ) get_pvs_internal((cmd), (pv_list), (vg_list))
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 3f6c2e4..da66e15 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3541,7 +3541,7 @@ static int _is_foreign_vg(struct volume_group *vg)
 	return vg->cmd->system_id && strcmp(vg->system_id, vg->cmd->system_id);
 }
 
-static int _repair_inconsistent_vg(struct volume_group *vg)
+static int _repair_inconsistent_vg(struct volume_group *vg, uint32_t lockd_state)
 {
 	unsigned saved_handles_missing_pvs = vg->cmd->handles_missing_pvs;
 
@@ -3556,9 +3556,8 @@ static int _repair_inconsistent_vg(struct volume_group *vg)
 		return 0;
 	}
 
-	/* FIXME: do this at higher level where lvmlockd lock can be changed. */
-	if (is_lockd_type(vg->lock_type)) {
-		log_verbose("Skip metadata repair for shared VG.");
+	if (is_lockd_type(vg->lock_type) && !(lockd_state & LDST_EX)) {
+		log_verbose("Skip metadata repair for shared VG without exclusive lock.");
 		return 0;
 	}
 
@@ -3581,7 +3580,7 @@ static int _repair_inconsistent_vg(struct volume_group *vg)
 	return 1;
 }
 
-static int _wipe_outdated_pvs(struct cmd_context *cmd, struct volume_group *vg, struct dm_list *to_check)
+static int _wipe_outdated_pvs(struct cmd_context *cmd, struct volume_group *vg, struct dm_list *to_check, uint32_t lockd_state)
 {
 	struct pv_list *pvl, *pvl2;
 	char uuid[64] __attribute__((aligned(8)));
@@ -3603,14 +3602,8 @@ static int _wipe_outdated_pvs(struct cmd_context *cmd, struct volume_group *vg,
 		return 0;
 	}
 
-	/*
-	 * FIXME: do this at higher level where lvmlockd lock can be changed.
-	 * Also if we're reading the VG with the --shared option (not using
-	 * lvmlockd), we can see a VG while it's being written by another
-	 * host, same as the foreign VG case.
-	 */
-	if (is_lockd_type(vg->lock_type)) {
-		log_debug_metadata("Skip wiping outdated PVs for shared VG.");
+	if (is_lockd_type(vg->lock_type) && !(lockd_state & LDST_EX)) {
+		log_verbose("Skip wiping outdated PVs for shared VG without exclusive lock.");
 		return 0;
 	}
 
@@ -3619,6 +3612,8 @@ static int _wipe_outdated_pvs(struct cmd_context *cmd, struct volume_group *vg,
 			if (pvl->pv->dev == pvl2->pv->dev)
 				goto next_pv;
 		}
+
+
 		if (!id_write_format(&pvl->pv->id, uuid, sizeof(uuid)))
 			return_0;
 		log_warn("WARNING: Removing PV %s (%s) that no longer belongs to VG %s",
@@ -3639,6 +3634,7 @@ next_pv:
 
 static int _check_or_repair_pv_ext(struct cmd_context *cmd,
 				   struct volume_group *vg,
+				   uint32_t lockd_state,
 				   int repair, int *inconsistent_pvs)
 {
 	char uuid[64] __attribute__((aligned(8)));
@@ -3688,10 +3684,7 @@ static int _check_or_repair_pv_ext(struct cmd_context *cmd,
 					    "VG %s but not marked as used.",
 					    pv_dev_name(pvl->pv), vg->name);
 				*inconsistent_pvs = 1;
-			} else if (is_lockd_type(vg->lock_type)) {
-				/*
-				 * FIXME: decide how to handle repair for shared VGs.
-				 */
+			} else if (is_lockd_type(vg->lock_type) && !(lockd_state & LDST_EX)) {
 				log_warn("Skip repair of PV %s that is in shared "
 					    "VG %s but not marked as used.",
 					    pv_dev_name(pvl->pv), vg->name);
@@ -3715,7 +3708,7 @@ static int _check_or_repair_pv_ext(struct cmd_context *cmd,
 
 	r = 1;
 out:
-	if ((pvs_fixed > 0) && !_repair_inconsistent_vg(vg))
+	if ((pvs_fixed > 0) && !_repair_inconsistent_vg(vg, lockd_state))
 		return_0;
 
 	return r;
@@ -3738,6 +3731,7 @@ out:
 static struct volume_group *_vg_read(struct cmd_context *cmd,
 				     const char *vgname,
 				     const char *vgid,
+				     uint32_t lockd_state, 
 				     uint32_t warn_flags, 
 				     int *consistent, unsigned precommitted)
 {
@@ -3787,10 +3781,10 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 			dm_list_iterate_items(pvl, &correct_vg->pvs)
 				reappeared += _check_reappeared_pv(correct_vg, pvl->pv, *consistent);
 			if (reappeared && *consistent)
-				*consistent = _repair_inconsistent_vg(correct_vg);
+				*consistent = _repair_inconsistent_vg(correct_vg, lockd_state);
 			else
 				*consistent = !reappeared;
-			if (_wipe_outdated_pvs(cmd, correct_vg, &correct_vg->pvs_outdated)) {
+			if (_wipe_outdated_pvs(cmd, correct_vg, &correct_vg->pvs_outdated, lockd_state)) {
 				/* clear the list */
 				dm_list_init(&correct_vg->pvs_outdated);
 				lvmetad_vg_clear_outdated_pvs(correct_vg);
@@ -4310,13 +4304,13 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 		dm_list_iterate_items(pvl, &all_pvs)
 			_check_reappeared_pv(correct_vg, pvl->pv, 1);
 
-		if (!_repair_inconsistent_vg(correct_vg)) {
+		if (!_repair_inconsistent_vg(correct_vg, lockd_state)) {
 			_free_pv_list(&all_pvs);
 			release_vg(correct_vg);
 			return NULL;
 		}
 
-		if (!_wipe_outdated_pvs(cmd, correct_vg, &all_pvs)) {
+		if (!_wipe_outdated_pvs(cmd, correct_vg, &all_pvs, lockd_state)) {
 			_free_pv_list(&all_pvs);
 			release_vg(correct_vg);
 			return_NULL;
@@ -4340,7 +4334,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 	}
 
 	/* We have the VG now finally, check if PV ext info is in sync with VG metadata. */
-	if (!cmd->is_clvmd && !_check_or_repair_pv_ext(cmd, correct_vg,
+	if (!cmd->is_clvmd && !_check_or_repair_pv_ext(cmd, correct_vg, lockd_state,
 				     skipped_rescan ? 0 : *consistent,
 				     &inconsistent_pvs)) {
 		release_vg(correct_vg);
@@ -4502,13 +4496,15 @@ static int _check_devs_used_correspond_with_vg(struct volume_group *vg)
 	return 1;
 }
 
-struct volume_group *vg_read_internal(struct cmd_context *cmd, const char *vgname,
-				      const char *vgid, uint32_t warn_flags, int *consistent)
+struct volume_group *vg_read_internal(struct cmd_context *cmd,
+				      const char *vgname, const char *vgid,
+				      uint32_t lockd_state, uint32_t warn_flags,
+				      int *consistent)
 {
 	struct volume_group *vg;
 	struct lv_list *lvl;
 
-	if (!(vg = _vg_read(cmd, vgname, vgid, warn_flags, consistent, 0)))
+	if (!(vg = _vg_read(cmd, vgname, vgid, lockd_state, warn_flags, consistent, 0)))
 		goto_out;
 
 	if (!check_pv_dev_sizes(vg))
@@ -4616,7 +4612,7 @@ struct volume_group *vg_read_by_vgid(struct cmd_context *cmd,
 
 	label_scan_setup_bcache();
 
-	if (!(vg = _vg_read(cmd, vgname, vgid, warn_flags, &consistent, precommitted))) {
+	if (!(vg = _vg_read(cmd, vgname, vgid, 0, warn_flags, &consistent, precommitted))) {
 		log_error("Rescan devices to look for missing VG.");
 		goto scan;
 	}
@@ -4637,7 +4633,7 @@ struct volume_group *vg_read_by_vgid(struct cmd_context *cmd,
 	lvmcache_label_scan(cmd);
 	warn_flags |= SKIP_RESCAN;
 
-	if (!(vg = _vg_read(cmd, vgname, vgid, warn_flags, &consistent, precommitted)))
+	if (!(vg = _vg_read(cmd, vgname, vgid, 0, warn_flags, &consistent, precommitted)))
 		goto fail;
 
 	label_scan_destroy(cmd); /* drop bcache to close devs, keep lvmcache */
@@ -4876,7 +4872,7 @@ static int _get_pvs(struct cmd_context *cmd, uint32_t warn_flags,
 
 		warn_flags |= WARN_INCONSISTENT;
 
-		if (!(vg = vg_read_internal(cmd, vgname, (!vgslist) ? vgid : NULL, warn_flags, &consistent))) {
+		if (!(vg = vg_read_internal(cmd, vgname, (!vgslist) ? vgid : NULL, 0, warn_flags, &consistent))) {
 			stack;
 			continue;
 		}
@@ -5189,17 +5185,30 @@ int vg_check_status(const struct volume_group *vg, uint64_t status)
  * VG is left unlocked on failure
  */
 static struct volume_group *_recover_vg(struct cmd_context *cmd,
-			 const char *vg_name, const char *vgid)
+			 const char *vg_name, const char *vgid, uint32_t lockd_state)
 {
 	int consistent = 1;
 	struct volume_group *vg;
+	uint32_t state = 0;
 
 	unlock_vg(cmd, NULL, vg_name);
 
 	if (!lock_vol(cmd, vg_name, LCK_VG_WRITE, NULL))
 		return_NULL;
 
-	if (!(vg = vg_read_internal(cmd, vg_name, vgid, WARN_PV_READ, &consistent))) {
+	/*
+	 * Convert vg lock in lvmlockd from sh to ex.
+	 */
+	if (!(lockd_state & LDST_FAIL) && !(lockd_state & LDST_EX)) {
+		log_debug("Upgrade lvmlockd lock to repair vg %s.", vg_name);
+		if (!lockd_vg(cmd, vg_name, "ex", 0, &state)) {
+			log_warn("Skip repair for shared VG without exclusive lock.");
+			return NULL;
+		}
+		lockd_state |= LDST_EX;
+	}
+
+	if (!(vg = vg_read_internal(cmd, vg_name, vgid, lockd_state, WARN_PV_READ, &consistent))) {
 		unlock_vg(cmd, NULL, vg_name);
 		return_NULL;
 	}
@@ -5473,7 +5482,7 @@ static struct volume_group *_vg_lock_and_read(struct cmd_context *cmd, const cha
 		warn_flags |= WARN_INCONSISTENT;
 
 	/* If consistent == 1, we get NULL here if correction fails. */
-	if (!(vg = vg_read_internal(cmd, vg_name, vgid, warn_flags, &consistent))) {
+	if (!(vg = vg_read_internal(cmd, vg_name, vgid, lockd_state, warn_flags, &consistent))) {
 		if (consistent_in && !consistent) {
 			failure |= FAILED_INCONSISTENT;
 			goto bad;
@@ -5490,7 +5499,7 @@ static struct volume_group *_vg_lock_and_read(struct cmd_context *cmd, const cha
 	/* consistent == 0 when VG is not found, but failed == FAILED_NOTFOUND */
 	if (!consistent && !failure) {
 		release_vg(vg);
-		if (!(vg = _recover_vg(cmd, vg_name, vgid))) {
+		if (!(vg = _recover_vg(cmd, vg_name, vgid, lockd_state))) {
 			if (is_orphan_vg(vg_name))
 				log_error("Recovery of standalone physical volumes failed.");
 			else
diff --git a/tools/toollib.c b/tools/toollib.c
index 0fc86cf..19f4c33 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -5730,7 +5730,7 @@ do_command:
 	if (pp->preserve_existing && pp->orphan_vg_name) {
 		log_debug("Using existing orphan PVs in %s.", pp->orphan_vg_name);
 
-		if (!(orphan_vg = vg_read_internal(cmd, pp->orphan_vg_name, NULL, 0, &consistent))) {
+		if (!(orphan_vg = vg_read_internal(cmd, pp->orphan_vg_name, NULL, 0, 0, &consistent))) {
 			log_error("Cannot read orphans VG %s.", pp->orphan_vg_name);
 			goto bad;
 		}


