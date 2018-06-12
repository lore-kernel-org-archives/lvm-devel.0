From: David Teigland <teigland@sourceware.org>
Date: Tue, 12 Jun 2018 12:42:13 -0400
Subject: master - Clean up repair and result values in vg_read
Message-ID: <201806121642.w5CGgDSM007234@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=981a3ba98ed6815a8b761261ed5652ec81294938
Commit:        981a3ba98ed6815a8b761261ed5652ec81294938
Parent:        9a8c36b8917edf00ea875e727b0b775ca5a87a43
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jun 12 09:44:37 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jun 12 11:08:26 2018 -0500

Clean up repair and result values in vg_read

Fix the confusing mix of input and output values
in the single variable.
---
 lib/metadata/metadata-exported.h |   11 ++--
 lib/metadata/metadata.c          |  104 +++++++++++++++++++-------------------
 lib/metadata/vg.c                |    3 +-
 tools/toollib.c                  |    3 +-
 4 files changed, 60 insertions(+), 61 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 36a87b5..501d0fa 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -653,8 +653,6 @@ void pvcreate_params_set_defaults(struct pvcreate_params *pp);
 int vg_write(struct volume_group *vg);
 int vg_commit(struct volume_group *vg);
 void vg_revert(struct volume_group *vg);
-struct volume_group *vg_read_internal(struct cmd_context *cmd, const char *vg_name,
-				      const char *vgid, uint32_t lockd_state, uint32_t warn_flags, int *consistent);
 
 /*
  * Add/remove LV to/from volume group
@@ -689,15 +687,18 @@ int lv_resize(struct logical_volume *lv,
 /*
  * Return a handle to VG metadata.
  */
+struct volume_group *vg_read_internal(struct cmd_context *cmd,
+                                      const char *vgname, const char *vgid,
+                                      uint32_t lockd_state, uint32_t warn_flags,
+                                      int enable_repair,
+                                      int *mdas_consistent);
 struct volume_group *vg_read(struct cmd_context *cmd, const char *vg_name,
 			     const char *vgid, uint32_t read_flags, uint32_t lockd_state);
 struct volume_group *vg_read_for_update(struct cmd_context *cmd, const char *vg_name,
 			 const char *vgid, uint32_t read_flags, uint32_t lockd_state);
 struct volume_group *vg_read_orphans(struct cmd_context *cmd,
                                              uint32_t warn_flags,
-                                             const char *orphan_vgname,
-                                             int *consistent);
-
+                                             const char *orphan_vgname);
 /* 
  * Test validity of a VG handle.
  */
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 9dc5627..a4308bc 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3276,8 +3276,7 @@ static int _vg_read_orphan_pv(struct lvmcache_info *info, void *baton)
 /* Make orphan PVs look like a VG. */
 struct volume_group *vg_read_orphans(struct cmd_context *cmd,
 					     uint32_t warn_flags,
-					     const char *orphan_vgname,
-					     int *consistent)
+					     const char *orphan_vgname)
 {
 	const struct format_type *fmt;
 	struct lvmcache_vginfo *vginfo;
@@ -3624,7 +3623,9 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 				     const char *vgid,
 				     uint32_t lockd_state, 
 				     uint32_t warn_flags, 
-				     int *consistent, unsigned precommitted)
+				     int enable_repair,
+				     int *mdas_consistent,
+				     unsigned precommitted)
 {
 	struct format_instance *fid = NULL;
 	struct format_instance_ctx fic;
@@ -3637,19 +3638,20 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 	int inconsistent_pvs = 0;
 	int inconsistent_mdas = 0;
 	int inconsistent_mda_count = 0;
-	int strip_historical_lvs = *consistent;
-	int update_old_pv_ext = *consistent;
+	int strip_historical_lvs = enable_repair;
+	int update_old_pv_ext = enable_repair;
 	unsigned use_precommitted = precommitted;
 	struct dm_list *pvids;
 	struct pv_list *pvl;
 	struct dm_list all_pvs;
 	char uuid[64] __attribute__((aligned(8)));
 	int skipped_rescan = 0;
-
 	int reappeared = 0;
 	struct cached_vg_fmtdata *vg_fmtdata = NULL;	/* Additional format-specific data about the vg */
 	unsigned use_previous_vg;
 
+	*mdas_consistent = 1;
+
 	if (is_orphan_vg(vgname)) {
 		log_very_verbose("Reading VG %s", vgname);
 
@@ -3658,7 +3660,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 				  "with pre-commit.");
 			return NULL;
 		}
-		return vg_read_orphans(cmd, warn_flags, vgname, consistent);
+		return vg_read_orphans(cmd, warn_flags, vgname);
 	}
 
 	uuid[0] = '\0';
@@ -3670,11 +3672,11 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 	if (lvmetad_used() && !use_precommitted) {
 		if ((correct_vg = lvmetad_vg_lookup(cmd, vgname, vgid))) {
 			dm_list_iterate_items(pvl, &correct_vg->pvs)
-				reappeared += _check_reappeared_pv(correct_vg, pvl->pv, *consistent);
-			if (reappeared && *consistent)
-				*consistent = _repair_inconsistent_vg(correct_vg, lockd_state);
+				reappeared += _check_reappeared_pv(correct_vg, pvl->pv, enable_repair);
+			if (reappeared && enable_repair)
+				*mdas_consistent = _repair_inconsistent_vg(correct_vg, lockd_state);
 			else
-				*consistent = !reappeared;
+				*mdas_consistent = !reappeared;
 			if (_wipe_outdated_pvs(cmd, correct_vg, &correct_vg->pvs_outdated, lockd_state)) {
 				/* clear the list */
 				dm_list_init(&correct_vg->pvs_outdated);
@@ -4153,7 +4155,6 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 				log_error(INTERNAL_ERROR "Too many inconsistent MDAs.");
 
 			if (!inconsistent_mda_count) {
-				*consistent = 0;
 				_free_pv_list(&all_pvs);
 				return correct_vg;
 			}
@@ -4162,13 +4163,9 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 			return NULL;
 		}
 
-		if (!*consistent) {
-			_free_pv_list(&all_pvs);
-			return correct_vg;
-		}
-
-		if (cmd->is_clvmd) {
+		if (!enable_repair) {
 			_free_pv_list(&all_pvs);
+			*mdas_consistent = 0;
 			return correct_vg;
 		}
 
@@ -4181,10 +4178,9 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 
 		/* Don't touch if vgids didn't match */
 		if (inconsistent_vgid) {
-			log_warn("WARNING: Inconsistent metadata UUIDs found for "
-				 "volume group %s.", vgname);
-			*consistent = 0;
+			log_warn("WARNING: Inconsistent metadata UUIDs found for volume group %s.", vgname);
 			_free_pv_list(&all_pvs);
+			*mdas_consistent = 0;
 			return correct_vg;
 		}
 
@@ -4225,16 +4221,13 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 	}
 
 	/* We have the VG now finally, check if PV ext info is in sync with VG metadata. */
-	if (!cmd->is_clvmd && !_check_or_repair_pv_ext(cmd, correct_vg, lockd_state,
-				     skipped_rescan ? 0 : *consistent,
+	if (!_check_or_repair_pv_ext(cmd, correct_vg, lockd_state, skipped_rescan ? 0 : enable_repair,
 				     &inconsistent_pvs)) {
 		release_vg(correct_vg);
 		return_NULL;
 	}
 
-	*consistent = !inconsistent_pvs;
-
-	if (!cmd->is_clvmd && correct_vg && *consistent && !skipped_rescan) {
+	if (correct_vg && enable_repair && !skipped_rescan) {
 		if (update_old_pv_ext && !_vg_update_old_pv_ext_if_needed(correct_vg)) {
 			release_vg(correct_vg);
 			return_NULL;
@@ -4246,6 +4239,9 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 		}
 	}
 
+	if (inconsistent_pvs)
+		*mdas_consistent = 0;
+
 	return correct_vg;
 }
 
@@ -4390,12 +4386,14 @@ static int _check_devs_used_correspond_with_vg(struct volume_group *vg)
 struct volume_group *vg_read_internal(struct cmd_context *cmd,
 				      const char *vgname, const char *vgid,
 				      uint32_t lockd_state, uint32_t warn_flags,
-				      int *consistent)
+				      int enable_repair,
+				      int *mdas_consistent)
 {
 	struct volume_group *vg;
 	struct lv_list *lvl;
 
-	if (!(vg = _vg_read(cmd, vgname, vgid, lockd_state, warn_flags, consistent, 0)))
+	if (!(vg = _vg_read(cmd, vgname, vgid, lockd_state,
+			    warn_flags, enable_repair, mdas_consistent, 0)))
 		goto_out;
 
 	if (!check_pv_dev_sizes(vg))
@@ -4435,7 +4433,7 @@ struct volume_group *vg_read_internal(struct cmd_context *cmd,
 
 	(void) _check_devs_used_correspond_with_vg(vg);
 out:
-	if (!*consistent && (warn_flags & WARN_INCONSISTENT)) {
+	if (!*mdas_consistent && (warn_flags & WARN_INCONSISTENT)) {
 		if (is_orphan_vg(vgname))
 			log_warn("WARNING: Found inconsistent standalone Physical Volumes.");
 		else
@@ -4756,7 +4754,7 @@ static struct volume_group *_recover_vg(struct cmd_context *cmd,
 			 const char *vg_name, const char *vgid,
 			 int is_shared, uint32_t lockd_state)
 {
-	int consistent = 1;
+	int mdas_consistent = 0;
 	struct volume_group *vg;
 	uint32_t state = 0;
 
@@ -4777,12 +4775,12 @@ static struct volume_group *_recover_vg(struct cmd_context *cmd,
 		lockd_state |= LDST_EX;
 	}
 
-	if (!(vg = vg_read_internal(cmd, vg_name, vgid, lockd_state, WARN_PV_READ, &consistent))) {
+	if (!(vg = vg_read_internal(cmd, vg_name, vgid, lockd_state, 0, 1, &mdas_consistent))) {
 		unlock_vg(cmd, NULL, vg_name);
 		return_NULL;
 	}
 
-	if (!consistent) {
+	if (!mdas_consistent) {
 		release_vg(vg);
 		unlock_vg(cmd, NULL, vg_name);
 		return_NULL;
@@ -5015,15 +5013,17 @@ static struct volume_group *_vg_lock_and_read(struct cmd_context *cmd, const cha
 			       uint32_t lockd_state)
 {
 	struct volume_group *vg = NULL;
-	int consistent = 1;
-	int consistent_in;
 	uint32_t failure = 0;
 	uint32_t warn_flags = 0;
+	int mdas_consistent = 1;
+	int enable_repair = 1;
 	int is_shared = 0;
 	int skip_lock = is_orphan_vg(vg_name) && (read_flags & PROCESS_SKIP_ORPHAN_LOCK);
 
-	if ((read_flags & READ_ALLOW_INCONSISTENT) || (lock_flags != LCK_VG_WRITE))
-		consistent = 0;
+	if ((read_flags & READ_ALLOW_INCONSISTENT) || (lock_flags != LCK_VG_WRITE)) {
+		enable_repair = 0;
+		warn_flags |= WARN_INCONSISTENT;
+	}
 
 	if (!validate_name(vg_name) && !is_orphan_vg(vg_name)) {
 		log_error("Volume group name \"%s\" has invalid characters.",
@@ -5043,18 +5043,7 @@ static struct volume_group *_vg_lock_and_read(struct cmd_context *cmd, const cha
 	if (is_orphan_vg(vg_name))
 		status_flags &= ~LVM_WRITE;
 
-	consistent_in = consistent;
-
-	warn_flags = WARN_PV_READ;
-	if (consistent || (read_flags & READ_WARN_INCONSISTENT))
-		warn_flags |= WARN_INCONSISTENT;
-
-	/* If consistent == 1, we get NULL here if correction fails. */
-	if (!(vg = vg_read_internal(cmd, vg_name, vgid, lockd_state, warn_flags, &consistent))) {
-		if (consistent_in && !consistent) {
-			failure |= FAILED_INCONSISTENT;
-			goto bad;
-		}
+	if (!(vg = vg_read_internal(cmd, vg_name, vgid, lockd_state, warn_flags, enable_repair, &mdas_consistent))) {
 		if (!(read_flags & READ_OK_NOTFOUND))
 			log_error("Volume group \"%s\" not found", vg_name);
 		failure |= FAILED_NOTFOUND;
@@ -5064,16 +5053,27 @@ static struct volume_group *_vg_lock_and_read(struct cmd_context *cmd, const cha
 	if (!_vg_access_permitted(cmd, vg, lockd_state, &failure))
 		goto bad;
 
-	/* consistent == 0 when VG is not found, but failed == FAILED_NOTFOUND */
-	if (!consistent && !failure) {
+	/*
+	 * If we called vg_read_internal above without repair enabled,
+	 * and the read found inconsistent mdas, then then get a write/ex
+	 * lock and call it again with repair enabled so it will fix
+	 * the inconsistent mdas.
+	 *
+	 * FIXME: factor vg repair out of vg_read.  The vg_read caller
+	 * should get an error about the vg have problems and then call
+	 * a repair-specific function if it wants to.  (NB there are
+	 * other kinds of repairs hidden in _vg_read that should be
+	 * pulled out in addition to _recover_vg).
+	 */
+	if (!mdas_consistent && !enable_repair) {
 		is_shared = vg_is_shared(vg);
 		release_vg(vg);
+
 		if (!(vg = _recover_vg(cmd, vg_name, vgid, is_shared, lockd_state))) {
 			if (is_orphan_vg(vg_name))
 				log_error("Recovery of standalone physical volumes failed.");
 			else
-				log_error("Recovery of volume group \"%s\" failed.",
-					  vg_name);
+				log_error("Recovery of volume group \"%s\" failed.", vg_name);
 			failure |= FAILED_RECOVERY;
 			goto bad_no_unlock;
 		}
diff --git a/lib/metadata/vg.c b/lib/metadata/vg.c
index d837a55..75a054f 100644
--- a/lib/metadata/vg.c
+++ b/lib/metadata/vg.c
@@ -671,7 +671,6 @@ int vgreduce_single(struct cmd_context *cmd, struct volume_group *vg,
 {
 	struct pv_list *pvl;
 	struct volume_group *orphan_vg = NULL;
-	int consistent;
 	int r = 0;
 	const char *name = pv_dev_name(pv);
 
@@ -715,7 +714,7 @@ int vgreduce_single(struct cmd_context *cmd, struct volume_group *vg,
 	vg->extent_count -= pv_pe_count(pv);
 
 	/* FIXME: we don't need to vg_read the orphan vg here */
-	orphan_vg = vg_read_orphans(cmd, 0, vg->fid->fmt->orphan_vg_name, &consistent);
+	orphan_vg = vg_read_orphans(cmd, 0, vg->fid->fmt->orphan_vg_name);
 
 	if (vg_read_error(orphan_vg))
 		goto bad;
diff --git a/tools/toollib.c b/tools/toollib.c
index fb37d07..7caab45 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -5348,7 +5348,6 @@ int pvcreate_each_device(struct cmd_context *cmd,
 	struct pv_list *vgpvl;
 	struct device_list *devl;
 	const char *pv_name;
-	int consistent = 0;
 	int must_use_all = (cmd->cname->flags & MUST_USE_ALL_ARGS);
 	int found;
 	unsigned i;
@@ -5639,7 +5638,7 @@ do_command:
 	if (pp->preserve_existing && pp->orphan_vg_name) {
 		log_debug("Using existing orphan PVs in %s.", pp->orphan_vg_name);
 
-		if (!(orphan_vg = vg_read_internal(cmd, pp->orphan_vg_name, NULL, 0, 0, &consistent))) {
+		if (!(orphan_vg = vg_read_orphans(cmd, 0, pp->orphan_vg_name))) {
 			log_error("Cannot read orphans VG %s.", pp->orphan_vg_name);
 			goto bad;
 		}


