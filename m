From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 18 Jan 2016 20:51:18 +0000 (UTC)
Subject: master - pvmove: use toollib
Message-ID: <20160118205118.ECB64607A5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6d7dc87cb356162f912b13c8a0cd198037c0226b
Commit:        6d7dc87cb356162f912b13c8a0cd198037c0226b
Parent:        5cd4d46f303ecf5212b5de0eb96c0a356453d289
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jan 12 14:57:52 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Jan 18 14:48:30 2016 -0600

pvmove: use toollib

Previously, pvmove used the function find_pv_in_vg() which did the
equivalent of process_each_pv() by doing:

  find_pv_by_name() -> get_pvs() ->

  get_pvs_internal() -> _get_pvs() -> get_vgids() ->

  /* equivalent to process_each_pv */
  dm_list_iterate_items(vgids)
    vg = vg_read_internal()
    dm_list_iterate_items(&vg->pvs)

With the found 'pv', it would do vg_read() on pv_vg_name(pv),
and then do the actual pvmove processing.

This commit simplifies by using process_each_pv() and putting
the actual pvmove processing into the "single" function.
This eliminates both find_pv_by_name() and the vg_read().
The processing code that followed vg_read remains the same.

The return code for the pvmove command is not based on the
process_each_pv return code, but is based on the success/fail
conditions in the existing code.
---
 tools/pvmove.c  |  232 ++++++++++++++++++++++++++-----------------------------
 tools/toollib.h |    2 +-
 2 files changed, 110 insertions(+), 124 deletions(-)

diff --git a/tools/pvmove.c b/tools/pvmove.c
index d3eb1ab..be2fab5 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -22,6 +22,21 @@
 
 #define PVMOVE_FIRST_TIME   0x00000001      /* Called for first time */
 
+struct pvmove_params {
+	char *pv_name_arg; /* original unmodified arg */
+	char *lv_name_arg; /* original unmodified arg */
+	alloc_policy_t alloc;
+	int pv_count;
+	char **pv_names;
+
+	union lvid *lvid;
+	char *id_vg_name;
+	char *id_lv_name;
+	unsigned in_progress;
+	int setup_result;
+	int found_pv;
+};
+
 static int _pvmove_target_present(struct cmd_context *cmd, int clustered)
 {
 	const struct segment_type *segtype;
@@ -586,63 +601,39 @@ static int _copy_id_components(struct cmd_context *cmd,
 	return 1;
 }
 
-static int _set_up_pvmove(struct cmd_context *cmd, const char *pv_name,
-			  int argc, char **argv, union lvid *lvid, char **vg_name_copy,
-			  char **lv_mirr_name)
+static int _pvmove_setup_single(struct cmd_context *cmd,
+				struct volume_group *vg,
+				struct physical_volume *pv,
+				struct processing_handle *handle)
 {
+	struct pvmove_params *pp = (struct pvmove_params *) handle->custom_handle;
 	const char *lv_name = NULL;
-	const char *vg_name;
-	char *pv_name_arg;
-	struct volume_group *vg;
 	struct dm_list *source_pvl;
 	struct dm_list *allocatable_pvs;
-	alloc_policy_t alloc;
 	struct dm_list *lvs_changed;
-	struct physical_volume *pv;
 	struct logical_volume *lv_mirr;
-	uint32_t lockd_state = 0;
+	const char *pv_name = pv_dev_name(pv);
 	unsigned flags = PVMOVE_FIRST_TIME;
 	unsigned exclusive;
 	int r = ECMD_FAILED;
 
-	pv_name_arg = argv[0];
-	argc--;
-	argv++;
-
-	/* Find PV (in VG) */
-	if (!(pv = find_pv_by_name(cmd, pv_name, 0, 0))) {
-		stack;
-		return EINVALID_CMD_LINE;
-	}
-
-	vg_name = pv_vg_name(pv);
+	pp->found_pv = 1;
+	pp->setup_result = ECMD_FAILED;
 
-	if (arg_count(cmd, name_ARG)) {
-		if (!(lv_name = _extract_lvname(cmd, vg_name, arg_value(cmd, name_ARG)))) {
-			stack;
-			free_pv_fid(pv);
-			return EINVALID_CMD_LINE;
+	if (pp->lv_name_arg) {
+		if (!(lv_name = _extract_lvname(cmd, vg->name, pp->lv_name_arg))) {
+			log_error("Failed to find an LV name.");
+			pp->setup_result = EINVALID_CMD_LINE;
+			return ECMD_FAILED;
 		}
 
 		if (!validate_name(lv_name)) {
 			log_error("Logical volume name %s is invalid", lv_name);
-			free_pv_fid(pv);
-			return EINVALID_CMD_LINE;
+			pp->setup_result = EINVALID_CMD_LINE;
+			return ECMD_FAILED;
 		}
 	}
 
-	/* Read VG */
-	log_verbose("Finding volume group \"%s\"", vg_name);
-
-	if (!lockd_vg(cmd, vg_name, "ex", 0, &lockd_state))
-		return_ECMD_FAILED;
-
-	vg = vg_read(cmd, vg_name, NULL, READ_FOR_UPDATE, lockd_state);
-	if (vg_read_error(vg)) {
-		release_vg(vg);
-		goto out_ret;
-	}
-
 	/*
 	 * We cannot move blocks from under the sanlock leases, so disallow
 	 * pvmoving any PVs used by the lvmlock LV.
@@ -657,8 +648,8 @@ static int _set_up_pvmove(struct cmd_context *cmd, const char *pv_name,
 				if (seg_type(lvseg, s) == AREA_PV) {
 					sanlock_pv = seg_pv(lvseg, s);
 					if (sanlock_pv->dev == pv->dev) {
-						log_error("Cannot pvmove device %s used for sanlock leases.", pv_dev_name(pv));
-						goto out;
+						log_error("Cannot pvmove device %s used for sanlock leases.", pv_name);
+						return ECMD_FAILED;
 					}
 				}
 			}
@@ -669,7 +660,7 @@ static int _set_up_pvmove(struct cmd_context *cmd, const char *pv_name,
 
 	if ((lv_mirr = find_pvmove_lv(vg, pv_dev(pv), PVMOVE))) {
 		log_print_unless_silent("Detected pvmove in progress for %s", pv_name);
-		if (argc || lv_name)
+		if (pp->pv_count || lv_name)
 			log_error("Ignoring remaining command line arguments");
 
 		if (!(lvs_changed = lvs_using_lv(cmd, vg, lv_mirr))) {
@@ -687,23 +678,22 @@ static int _set_up_pvmove(struct cmd_context *cmd, const char *pv_name,
 	} else {
 		/* Determine PE ranges to be moved */
 		if (!(source_pvl = create_pv_list(cmd->mem, vg, 1,
-						  &pv_name_arg, 0)))
+						  &pp->pv_name_arg, 0)))
 			goto_out;
 
-		alloc = (alloc_policy_t) arg_uint_value(cmd, alloc_ARG, ALLOC_INHERIT);
-		if (alloc == ALLOC_INHERIT)
-			alloc = vg->alloc;
+		if (pp->alloc == ALLOC_INHERIT)
+			pp->alloc = vg->alloc;
 
 		/* Get PVs we can use for allocation */
-		if (!(allocatable_pvs = _get_allocatable_pvs(cmd, argc, argv,
-							     vg, pv, alloc)))
+		if (!(allocatable_pvs = _get_allocatable_pvs(cmd, pp->pv_count, pp->pv_names,
+							     vg, pv, pp->alloc)))
 			goto_out;
 
 		if (!archive(vg))
 			goto_out;
 
 		if (!(lv_mirr = _set_up_pvmove_lv(cmd, vg, source_pvl, lv_name,
-						  allocatable_pvs, alloc,
+						  allocatable_pvs, pp->alloc,
 						  &lvs_changed, &exclusive)))
 			goto_out;
 	}
@@ -716,7 +706,7 @@ static int _set_up_pvmove(struct cmd_context *cmd, const char *pv_name,
 	/* init_pvmove(1); */
 	/* vg->status |= PVMOVE; */
 
-	if (!_copy_id_components(cmd, lv_mirr, vg_name_copy, lv_mirr_name, lvid))
+	if (!_copy_id_components(cmd, lv_mirr, &pp->id_vg_name, &pp->id_lv_name, pp->lvid))
 		goto out;
 
 	if (flags & PVMOVE_FIRST_TIME)
@@ -724,70 +714,33 @@ static int _set_up_pvmove(struct cmd_context *cmd, const char *pv_name,
 			goto_out;
 
 	/* LVs are all in status LOCKED */
+	pp->setup_result = ECMD_PROCESSED;
 	r = ECMD_PROCESSED;
 out:
-	free_pv_fid(pv);
-	unlock_and_release_vg(cmd, vg, vg_name);
-out_ret:
-	/*
-	 * Release explicitly because the command may continue running
-	 * for some time monitoring the progress, and we don not want
-	 * or need the lockd lock held over that.
-	 */
-	if (!lockd_vg(cmd, vg_name, "un", 0, &lockd_state))
-		stack;
-
 	return r;
 }
 
-static int _read_poll_id_from_pvname(struct cmd_context *cmd, const char *pv_name,
-				     union lvid *lvid, char **vg_name_copy,
-				     char **lv_name_copy, unsigned *in_progress)
+static int _pvmove_read_single(struct cmd_context *cmd,
+				struct volume_group *vg,
+				struct physical_volume *pv,
+				struct processing_handle *handle)
 {
-	int ret = 0;
-	const char *vg_name;
+	struct pvmove_params *pp = (struct pvmove_params *) handle->custom_handle;
 	struct logical_volume *lv;
-	struct physical_volume *pv;
-	struct volume_group *vg;
-	uint32_t lockd_state = 0;
-
-	if (!pv_name) {
-		log_error(INTERNAL_ERROR "Invalid PV name parameter.");
-		return 0;
-	}
+	int ret = ECMD_FAILED;
 
-	if (!(pv = find_pv_by_name(cmd, pv_name, 0, 0)))
-		return_0;
-
-	vg_name = pv_vg_name(pv);
-
-	if (!lockd_vg(cmd, vg_name, "sh", 0, &lockd_state))
-		return_0;
-
-	/* need read-only access */
-	vg = vg_read(cmd, vg_name, NULL, 0, lockd_state);
-	if (vg_read_error(vg)) {
-		log_error("ABORTING: Can't read VG for %s.", pv_name);
-		release_vg(vg);
-		ret = 0;
-		goto out;
-	}
+	pp->found_pv = 1;
 
 	if (!(lv = find_pvmove_lv(vg, pv_dev(pv), PVMOVE))) {
 		log_print_unless_silent("%s: No pvmove in progress - already finished or aborted.",
-					pv_name);
-		ret = 1;
-		*in_progress = 0;
-	} else if (_copy_id_components(cmd, lv, vg_name_copy, lv_name_copy, lvid)) {
-		ret = 1;
-		*in_progress = 1;
+					pv_dev_name(pv));
+		ret = ECMD_PROCESSED;
+		pp->in_progress = 0;
+	} else if (_copy_id_components(cmd, lv, &pp->id_vg_name, &pp->id_lv_name, pp->lvid)) {
+		ret = ECMD_PROCESSED;
+		pp->in_progress = 1;
 	}
 
-	unlock_and_release_vg(cmd, vg, vg_name);
-out:
-	if (!lockd_vg(cmd, vg_name, "un", 0, &lockd_state))
-		stack;
-	free_pv_fid(pv);
 	return ret;
 }
 
@@ -859,11 +812,12 @@ int pvmove_poll(struct cmd_context *cmd, const char *pv_name,
 
 int pvmove(struct cmd_context *cmd, int argc, char **argv)
 {
-	char *colon;
-	int ret;
-	unsigned in_progress = 1;
+	struct pvmove_params pp = { 0 };
+	struct processing_handle *handle = NULL;
 	union lvid *lvid = NULL;
-	char *pv_name = NULL, *vg_name = NULL, *lv_name = NULL;
+	char *pv_name = NULL;
+	char *colon;
+	unsigned is_abort = arg_is_set(cmd, abort_ARG);
 
 	/* dm raid1 target must be present in every case */
 	if (!_pvmove_target_present(cmd, 0)) {
@@ -895,6 +849,12 @@ int pvmove(struct cmd_context *cmd, int argc, char **argv)
 			log_error("Failed to allocate lvid.");
 			return ECMD_FAILED;
 		}
+		pp.lvid = lvid;
+
+		if (!(pp.pv_name_arg = dm_pool_strdup(cmd->mem, argv[0]))) {
+			log_error("Failed to clone PV name.");
+			return ECMD_FAILED;
+		}
 
 		if (!(pv_name = dm_pool_strdup(cmd->mem, argv[0]))) {
 			log_error("Failed to clone PV name.");
@@ -907,31 +867,56 @@ int pvmove(struct cmd_context *cmd, int argc, char **argv)
 		if (colon)
 			*colon = '\0';
 
-		/*
-		 * To do a reverse mapping from PV name to VG name, we need the
-		 * correct global mapping of PVs to VGs.
-		 */
-		if (!lockd_gl(cmd, "sh", 0)) {
-			stack;
+		argc--;
+		argv++;
+
+		pp.pv_count = argc;
+		pp.pv_names = argv;
+
+		if (arg_count(cmd, name_ARG)) {
+			if (!(pp.lv_name_arg = dm_pool_strdup(cmd->mem, arg_value(cmd, name_ARG))))  {
+				log_error("Failed to clone LV name.");
+				return ECMD_FAILED;
+			}
+		}
+
+		pp.alloc = (alloc_policy_t) arg_uint_value(cmd, alloc_ARG, ALLOC_INHERIT);
+
+		pp.in_progress = 1;
+
+		/* Normal pvmove setup requires ex lock from lvmlockd. */
+		if (is_abort)
+			cmd->lockd_vg_default_sh = 1;
+
+		if (!(handle = init_processing_handle(cmd))) {
+			log_error("Failed to initialize processing handle.");
 			return ECMD_FAILED;
 		}
 
-		/*
-		 * FIXME: use process_each_pv() where the "single" function
-		 * depends on the abort arg.  The single functions would not
-		 * need to use find_pv_by_name() (which includes a hidden
-		 * equivalent of process_each_pv), or vg_read().
-		 */
-		if (!arg_count(cmd, abort_ARG)) {
-			if ((ret = _set_up_pvmove(cmd, pv_name, argc, argv, lvid, &vg_name, &lv_name)) != ECMD_PROCESSED) {
+		handle->custom_handle = &pp;
+
+		process_each_pv(cmd, 1, &pv_name, NULL,
+				is_abort ? 0 : READ_FOR_UPDATE,
+				handle,
+				is_abort ? &_pvmove_read_single : &_pvmove_setup_single);
+
+		destroy_processing_handle(cmd, handle);
+
+		if (!is_abort) {
+			if (!pp.found_pv) {
+				stack;
+				return EINVALID_CMD_LINE;
+			}
+
+			if (pp.setup_result != ECMD_PROCESSED) {
 				stack;
-				return ret;
+				return pp.setup_result;
 			}
 		} else {
-			if (!_read_poll_id_from_pvname(cmd, pv_name, lvid, &vg_name, &lv_name, &in_progress))
+			if (!pp.found_pv)
 				return_ECMD_FAILED;
 
-			if (!in_progress)
+			if (!pp.in_progress)
 				return ECMD_PROCESSED;
 		}
 
@@ -943,6 +928,7 @@ int pvmove(struct cmd_context *cmd, int argc, char **argv)
 		lockd_gl(cmd, "un", 0);
 	}
 
-	return pvmove_poll(cmd, pv_name, lvid ? lvid->s : NULL, vg_name, lv_name,
+	return pvmove_poll(cmd, pv_name, lvid ? lvid->s : NULL,
+			   pp.id_vg_name, pp.id_lv_name,
 			   arg_is_set(cmd, background_ARG));
 }
diff --git a/tools/toollib.h b/tools/toollib.h
index 400bac5..e1ac323 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -102,7 +102,7 @@ int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
 		    process_single_vg_fn_t process_single_vg);
 
 int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
-		    const char *vg_name, uint32_t lock_type,
+		    const char *vg_name, uint32_t read_flags,
 		    struct processing_handle *handle,
 		    process_single_pv_fn_t process_single_pv);
 


