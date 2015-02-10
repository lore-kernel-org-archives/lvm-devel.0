From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 10 Feb 2015 15:12:57 +0000 (UTC)
Subject: master - toollib: initialize handles (including reporting for selection) for _select_match_* used in process_each_* fns
Message-ID: <20150210151257.1C13D60C2E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=56011918e66adf1f639436fd6781a89ad61eb8f4
Commit:        56011918e66adf1f639436fd6781a89ad61eb8f4
Parent:        a91bc7a19b8f439fa1d21101ad5c11d72413d4c0
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Nov 28 15:04:25 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Feb 10 16:05:29 2015 +0100

toollib: initialize handles (including reporting for selection) for _select_match_* used in process_each_* fns

Call _init_processing_handle, _init_selection_handle and
_destroy_processing_handle in process_each_* and related functions to
set up and destroy handles used while processing items.
---
 tools/lvconvert.c   |   16 ++++--
 tools/polldaemon.c  |    2 +
 tools/pvresize.c    |   11 +++--
 tools/toollib.c     |  135 +++++++++++++++++++++++++++++++++++----------------
 tools/vgcfgbackup.c |    1 +
 5 files changed, 113 insertions(+), 52 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index f9f666d..2df2483 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -3538,6 +3538,7 @@ static int _lvconvert_merge_single(struct cmd_context *cmd, struct logical_volum
 
 int lvconvert(struct cmd_context * cmd, int argc, char **argv)
 {
+	int ret = ECMD_PROCESSED;
 	struct lvconvert_params lp = {
 		.target_attr = ~0,
 	};
@@ -3547,13 +3548,16 @@ int lvconvert(struct cmd_context * cmd, int argc, char **argv)
 					    .custom_handle = &lp };
 
 	if (!_read_params(cmd, argc, argv, &lp)) {
-		stack;
-		return EINVALID_CMD_LINE;
+		ret = EINVALID_CMD_LINE;
+		goto_out;
 	}
 
 	if (lp.merge)
-		return process_each_lv(cmd, argc, argv, READ_FOR_UPDATE, &handle,
-				       &_lvconvert_merge_single);
-
-	return lvconvert_single(cmd, &lp);
+		ret = process_each_lv(cmd, argc, argv, READ_FOR_UPDATE, &handle,
+				    &_lvconvert_merge_single);
+	else
+		ret = lvconvert_single(cmd, &lp);
+out:
+	destroy_processing_handle(cmd, &handle, 0);
+	return ret;
 }
diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index 3eb9b17..204c495 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -240,6 +240,8 @@ static void _poll_for_all_vgs(struct cmd_context *cmd,
 			break;
 		sleep(parms->interval);
 	}
+
+	destroy_processing_handle(cmd, &handle, 0);
 }
 
 /*
diff --git a/tools/pvresize.c b/tools/pvresize.c
index a2f6b8b..f6253d9 100644
--- a/tools/pvresize.c
+++ b/tools/pvresize.c
@@ -50,16 +50,18 @@ int pvresize(struct cmd_context *cmd, int argc, char **argv)
 	struct processing_handle handle = { .internal_report_for_select = 1,
 					    .selection_handle = NULL,
 					    .custom_handle = &params };
-	int ret;
+	int ret = ECMD_PROCESSED;
 
 	if (!argc) {
 		log_error("Please supply physical volume(s)");
-		return EINVALID_CMD_LINE;
+		ret = EINVALID_CMD_LINE;
+		goto out;
 	}
 
 	if (arg_sign_value(cmd, physicalvolumesize_ARG, SIGN_NONE) == SIGN_MINUS) {
 		log_error("Physical volume size may not be negative");
-		return EINVALID_CMD_LINE;
+		ret = EINVALID_CMD_LINE;
+		goto out;
 	}
 
 	params.new_size = arg_uint64_value(cmd, physicalvolumesize_ARG,
@@ -73,6 +75,7 @@ int pvresize(struct cmd_context *cmd, int argc, char **argv)
 
 	log_print_unless_silent("%d physical volume(s) resized / %d physical volume(s) "
 				"not resized", params.done, params.total - params.done);
-
+out:
+	destroy_processing_handle(cmd, &handle, 0);
 	return ret;
 }
diff --git a/tools/toollib.c b/tools/toollib.c
index 0ce3c50..e38aab1 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1731,6 +1731,7 @@ int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
 		    uint32_t flags, struct processing_handle *handle,
 		    process_single_vg_fn_t process_single_vg)
 {
+	int handle_supplied = handle != NULL;
 	struct dm_list arg_tags;		/* str_list */
 	struct dm_list arg_vgnames;		/* str_list */
 	struct dm_list vgnameids_on_system;	/* vgnameid_list */
@@ -1747,10 +1748,8 @@ int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
 	/*
 	 * Find any VGs or tags explicitly provided on the command line.
 	 */
-	if ((ret = _get_arg_vgnames(cmd, argc, argv, &arg_vgnames, &arg_tags)) != ECMD_PROCESSED) {
-		stack;
-		return ret;
-	}
+	if ((ret = _get_arg_vgnames(cmd, argc, argv, &arg_vgnames, &arg_tags)) != ECMD_PROCESSED)
+		goto_out;
 
 	/*
 	 * Obtain the complete list of VGs present on the system if it is needed because:
@@ -1758,15 +1757,14 @@ int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
 	 *   no VG names were given and the command defaults to processing all VGs.
 	 */
 	if (((dm_list_empty(&arg_vgnames) && enable_all_vgs) || !dm_list_empty(&arg_tags)) &&
-	    ((ret = _get_vgnameids_on_system(cmd, &vgnameids_on_system, NULL, 0)) != ECMD_PROCESSED)) {
-		stack;
-		return ret;
-	}
+	    ((ret = _get_vgnameids_on_system(cmd, &vgnameids_on_system, NULL, 0)) != ECMD_PROCESSED))
+		goto_out;
 
 	if (dm_list_empty(&arg_vgnames) && dm_list_empty(&vgnameids_on_system)) {
 		/* FIXME Should be log_print, but suppressed for reporting cmds */
 		log_verbose("No volume groups found.");
-		return ECMD_PROCESSED;
+		ret = ECMD_PROCESSED;
+		goto out;
 	}
 
 	/*
@@ -1775,13 +1773,22 @@ int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
 	 */
 	if (!dm_list_empty(&vgnameids_on_system))
 		dm_list_splice(&vgnameids_to_process, &vgnameids_on_system);
-	else if ((ret = _copy_str_to_vgnameid_list(cmd, &arg_vgnames, &vgnameids_to_process)) != ECMD_PROCESSED) {
-		stack;
-		return ret;
-	}
+	else if ((ret = _copy_str_to_vgnameid_list(cmd, &arg_vgnames, &vgnameids_to_process)) != ECMD_PROCESSED)
+		goto_out;
+
+	if (!handle && !(handle = init_processing_handle(cmd)))
+		goto_out;
 
-	return _process_vgnameid_list(cmd, flags, &vgnameids_to_process,
-				      &arg_vgnames, &arg_tags, handle, process_single_vg);
+	if (handle->internal_report_for_select && !handle->selection_handle &&
+	    !init_selection_handle(cmd, handle))
+		goto_out;
+
+	ret = _process_vgnameid_list(cmd, flags, &vgnameids_to_process,
+				     &arg_vgnames, &arg_tags, handle, process_single_vg);
+out:
+	if (!handle_supplied)
+		destroy_processing_handle(cmd, handle, 1);
+	return ret;
 }
 
 int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
@@ -1793,6 +1800,7 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 	int ret_max = ECMD_PROCESSED;
 	int ret = 0;
 	int selected;
+	int handle_supplied = handle != NULL;
 	unsigned process_lv;
 	unsigned process_all = 0;
 	unsigned tags_supplied = 0;
@@ -1800,8 +1808,10 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 	struct lv_list *lvl;
 	struct dm_str_list *sl;
 
-	if (!vg_check_status(vg, EXPORTED_VG))
-		return_ECMD_FAILED;
+	if (!vg_check_status(vg, EXPORTED_VG)) {
+		ret_max = ECMD_FAILED;
+		goto_out;
+	}
 
 	if (tags_in && !dm_list_empty(tags_in))
 		tags_supplied = 1;
@@ -1809,6 +1819,17 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 	if (arg_lvnames && !dm_list_empty(arg_lvnames))
 		lvargs_supplied = 1;
 
+	if (!handle && !(handle = init_processing_handle(cmd))) {
+		ret_max = ECMD_FAILED;
+		goto_out;
+	}
+
+	if (handle->internal_report_for_select && !handle->selection_handle &&
+	    !init_selection_handle(cmd, handle)) {
+		ret_max = ECMD_FAILED;
+		goto_out;
+	}
+
 	/* Process all LVs in this VG if no restrictions given 
 	 * or if VG tags match. */
 	if ((!tags_supplied && !lvargs_supplied) ||
@@ -1820,8 +1841,10 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 	 * but it works since entries are allocated from vg mem pool.
 	 */
 	dm_list_iterate_items(lvl, &vg->lvs) {
-		if (sigint_caught())
-			return_ECMD_FAILED;
+		if (sigint_caught()) {
+			ret_max = ECMD_FAILED;
+			goto_out;
+		}
 
 		if (lvl->lv->status & SNAPSHOT)
 			continue;
@@ -1868,8 +1891,10 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 
 		process_lv = process_lv && select_match_lv(cmd, handle, vg, lvl->lv, &selected) && selected;
 
-		if (sigint_caught())
-			return_ECMD_FAILED;
+		if (sigint_caught()) {
+			ret_max = ECMD_FAILED;
+			goto_out;
+		}
 
 		if (!process_lv)
 			continue;
@@ -1883,7 +1908,7 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 			ret_max = ret;
 
 		if (stop_on_error && ret != ECMD_PROCESSED)
-			return ret_max;
+			goto_out;
 	}
 
 	if (lvargs_supplied) {
@@ -1898,7 +1923,9 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 				ret_max = ECMD_FAILED;
 		}
 	}
-
+out:
+	if (!handle_supplied)
+		destroy_processing_handle(cmd, handle, 1);
 	return ret_max;
 }
 
@@ -2097,6 +2124,7 @@ static int _process_lv_vgnameid_list(struct cmd_context *cmd, uint32_t flags,
 int process_each_lv(struct cmd_context *cmd, int argc, char **argv, uint32_t flags,
 		    struct processing_handle *handle, process_single_lv_fn_t process_single_lv)
 {
+	int handle_supplied = handle != NULL;
 	struct dm_list arg_tags;		/* str_list */
 	struct dm_list arg_vgnames;		/* str_list */
 	struct dm_list arg_lvnames;		/* str_list */
@@ -2115,26 +2143,31 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv, uint32_t fla
 	/*
 	 * Find any LVs, VGs or tags explicitly provided on the command line.
 	 */
-	if ((ret = _get_arg_lvnames(cmd, argc, argv, &arg_vgnames, &arg_lvnames, &arg_tags) != ECMD_PROCESSED)) {
-		stack;
-		return ret;
-	}
+	if ((ret = _get_arg_lvnames(cmd, argc, argv, &arg_vgnames, &arg_lvnames, &arg_tags) != ECMD_PROCESSED))
+		goto_out;
+
+	if (!handle && !(handle = init_processing_handle(cmd)))
+		goto_out;
+
+	if (handle->internal_report_for_select && !handle->selection_handle &&
+	    !init_selection_handle(cmd, handle))
+		goto_out;
 
 	/*
 	 * Obtain the complete list of VGs present on the system if it is needed because:
 	 *   any tags were supplied and need resolving; or
 	 *   no VG names were given and the command defaults to processing all VGs.
 	*/
-	if (((dm_list_empty(&arg_vgnames) && enable_all_vgs) || !dm_list_empty(&arg_tags)) &&
-	    (ret = _get_vgnameids_on_system(cmd, &vgnameids_on_system, NULL, 0) != ECMD_PROCESSED)) {
-		stack;
-		return ret;
-	}
+	if (((dm_list_empty(&arg_vgnames) && (enable_all_vgs ||
+	      handle->internal_report_for_select)) || !dm_list_empty(&arg_tags)) &&
+	    (ret = _get_vgnameids_on_system(cmd, &vgnameids_on_system, NULL, 0) != ECMD_PROCESSED))
+		goto_out;
 
 	if (dm_list_empty(&arg_vgnames) && dm_list_empty(&vgnameids_on_system)) {
 		/* FIXME Should be log_print, but suppressed for reporting cmds */
 		log_verbose("No volume groups found.");
-		return ECMD_PROCESSED;
+		ret = ECMD_PROCESSED;
+		goto out;
 	}
 
 	/*
@@ -2143,13 +2176,15 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv, uint32_t fla
 	 */
 	if (!dm_list_empty(&vgnameids_on_system))
 		dm_list_splice(&vgnameids_to_process, &vgnameids_on_system);
-	else if ((ret = _copy_str_to_vgnameid_list(cmd, &arg_vgnames, &vgnameids_to_process)) != ECMD_PROCESSED) {
-		stack;
-		return ret;
-	}
+	else if ((ret = _copy_str_to_vgnameid_list(cmd, &arg_vgnames, &vgnameids_to_process)) != ECMD_PROCESSED)
+		goto_out;
 
-	return _process_lv_vgnameid_list(cmd, flags, &vgnameids_to_process, &arg_vgnames, &arg_lvnames,
-					 &arg_tags, handle, process_single_lv);
+	ret = _process_lv_vgnameid_list(cmd, flags, &vgnameids_to_process, &arg_vgnames, &arg_lvnames,
+					&arg_tags, handle, process_single_lv);
+out:
+	if (!handle_supplied)
+		destroy_processing_handle(cmd, handle, 1);
+	return ret;
 }
 
 static int _get_arg_pvnames(struct cmd_context *cmd,
@@ -2336,6 +2371,7 @@ static int _process_pvs_in_vg(struct cmd_context *cmd,
 			      struct processing_handle *handle,
 			      process_single_pv_fn_t process_single_pv)
 {
+	int handle_supplied = handle != NULL;
 	struct physical_volume *pv;
 	struct pv_list *pvl;
 	struct device_id_list *dil;
@@ -2347,9 +2383,22 @@ static int _process_pvs_in_vg(struct cmd_context *cmd,
 	int ret_max = ECMD_PROCESSED;
 	int ret = 0;
 
+	if (!handle && (!(handle = init_processing_handle(cmd)))) {
+		ret_max = ECMD_FAILED;
+		goto_out;
+	}
+
+	if (handle->internal_report_for_select && !handle->selection_handle &&
+	    !init_selection_handle(cmd, handle)) {
+		ret_max = ECMD_FAILED;
+		goto_out;
+	}
+
 	dm_list_iterate_items(pvl, &vg->pvs) {
-		if (sigint_caught())
-			return_ECMD_FAILED;
+		if (sigint_caught()) {
+			ret_max = ECMD_FAILED;
+			goto_out;
+		}
 
 		pv = pvl->pv;
 		pv_name = pv_dev_name(pv);
@@ -2474,7 +2523,9 @@ static int _process_pvs_in_vg(struct cmd_context *cmd,
 		if (!process_all_pvs && dm_list_empty(arg_tags) && dm_list_empty(arg_devices))
 			break;
 	}
-
+out:
+	if (!handle_supplied)
+		destroy_processing_handle(cmd, handle, 1);
 	return ret_max;
 }
 
diff --git a/tools/vgcfgbackup.c b/tools/vgcfgbackup.c
index ee65f18..0a6c5f2 100644
--- a/tools/vgcfgbackup.c
+++ b/tools/vgcfgbackup.c
@@ -96,5 +96,6 @@ int vgcfgbackup(struct cmd_context *cmd, int argc, char **argv)
 
 	init_pvmove(0);
 
+	destroy_processing_handle(cmd, &handle, 0);
 	return ret;
 }


