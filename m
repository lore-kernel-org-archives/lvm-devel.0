From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 20 Jun 2016 09:41:19 +0000 (UTC)
Subject: master - log: annotate processing code with log_set_report_{context, object_type, id_and_name}
Message-ID: <20160620094119.C5F286100F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6ca28ca4c69b66b07ebcc19cea02b8317c6df0bf
Commit:        6ca28ca4c69b66b07ebcc19cea02b8317c6df0bf
Parent:        1b107adc1da26efe6e328e969c69d619436b0366
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri May 20 13:26:02 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jun 20 11:33:43 2016 +0200

log: annotate processing code with log_set_report_{context,object_type,id_and_name}

---
 WHATS_NEW       |    1 +
 tools/toollib.c |  201 ++++++++++++++++++++++++++++++++++++++++++++++---------
 2 files changed, 170 insertions(+), 32 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 823eeaf..fedc1e8 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.158 - 
 =================================
+  Annotate processing code with log report hooks for per-object command log.
   Also pass common printed messages (besides warnings and errors) to log report.
   Log warnings and errors via report during cmd processing if this is enabled.
   Make it possible to iterate over internal 'orphan' VGs in process_each_vg fn.
diff --git a/tools/toollib.c b/tools/toollib.c
index fe162d1..08178f6 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1736,6 +1736,7 @@ struct processing_handle *init_processing_handle(struct cmd_context *cmd, struct
 	} else
 		handle->saved_log_report_state = log_get_report_state();
 
+	log_set_report_context(LOG_REPORT_CONTEXT_PROCESSING);
 	return handle;
 }
 
@@ -1847,6 +1848,7 @@ static int _process_vgnameid_list(struct cmd_context *cmd, uint32_t read_flags,
 				  struct processing_handle *handle,
 				  process_single_vg_fn_t process_single_vg)
 {
+	log_report_t saved_log_report_state = log_get_report_state();
 	char uuid[64] __attribute__((aligned(8)));
 	struct volume_group *vg;
 	struct vgnameid_list *vgnl;
@@ -1861,6 +1863,8 @@ static int _process_vgnameid_list(struct cmd_context *cmd, uint32_t read_flags,
 	int process_all = 0;
 	int already_locked;
 
+	log_set_report_object_type(LOG_REPORT_OBJECT_TYPE_VG);
+
 	/*
 	 * If no VG names or tags were supplied, then process all VGs.
 	 */
@@ -1871,19 +1875,24 @@ static int _process_vgnameid_list(struct cmd_context *cmd, uint32_t read_flags,
 	 * FIXME If one_vgname, only proceed if exactly one VG matches tags or selection.
 	 */
 	dm_list_iterate_items(vgnl, vgnameids_to_process) {
-		if (sigint_caught())
-			return_ECMD_FAILED;
-
 		vg_name = vgnl->vg_name;
 		vg_uuid = vgnl->vgid;
 		skip = 0;
 		notfound = 0;
 
+		uuid[0] = '\0';
 		if (vg_uuid && !is_orphan_vg(vg_name) &&
 		    !id_write_format((const struct id*)vg_uuid, uuid, sizeof(uuid)))
 			stack;
 
-		log_very_verbose("Processing VG %s %s", vg_name, vg_uuid ? uuid : "");
+		log_set_report_object_name_and_id(vg_name, uuid);
+
+		if (sigint_caught()) {
+			ret_max = ECMD_FAILED;
+			goto_out;
+		}
+
+		log_very_verbose("Processing VG %s %s", vg_name, uuid);
 
 		if (!lockd_vg(cmd, vg_name, NULL, 0, &lockd_state)) {
 			ret_max = ECMD_FAILED;
@@ -1923,10 +1932,14 @@ endvg:
 		release_vg(vg);
 		if (!lockd_vg(cmd, vg_name, "un", 0, &lockd_state))
 			stack;
+
+		log_set_report_object_name_and_id(NULL, NULL);
 	}
 
 	/* the VG is selected if at least one LV is selected */
 	_set_final_selection_result(handle, whole_selected);
+out:
+	log_restore_report_state(saved_log_report_state);
 	return ret_max;
 }
 
@@ -2100,6 +2113,7 @@ int process_each_vg(struct cmd_context *cmd,
 		    struct processing_handle *handle,
 		    process_single_vg_fn_t process_single_vg)
 {
+	log_report_t saved_log_report_state = log_get_report_state();
 	int handle_supplied = handle != NULL;
 	struct dm_list arg_tags;		/* str_list */
 	struct dm_list arg_vgnames;		/* str_list */
@@ -2110,6 +2124,7 @@ int process_each_vg(struct cmd_context *cmd,
 	int ret_max = ECMD_PROCESSED;
 	int ret;
 
+	log_set_report_object_type(LOG_REPORT_OBJECT_TYPE_VG);
 	log_debug("Processing each VG");
 
 	/* Disable error in vg_read so we can print it from ignore_vg. */
@@ -2221,6 +2236,7 @@ out:
 	if (!handle_supplied)
 		destroy_processing_handle(cmd, handle);
 
+	log_restore_report_state(saved_log_report_state);
 	return ret_max;
 }
 
@@ -2272,6 +2288,9 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 			  struct processing_handle *handle,
 			  process_single_lv_fn_t process_single_lv)
 {
+	log_report_t saved_log_report_state = log_get_report_state();
+	char lv_uuid[64] __attribute__((aligned(8)));
+	char vg_uuid[64] __attribute__((aligned(8)));
 	int ret_max = ECMD_PROCESSED;
 	int ret = 0;
 	int whole_selected = 0;
@@ -2286,6 +2305,12 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 	struct lv_list *final_lvl;
 	struct glv_list *glvl, *tglvl;
 
+	log_set_report_object_type(LOG_REPORT_OBJECT_TYPE_LV);
+
+	vg_uuid[0] = '\0';
+	if (!id_write_format(&vg->id, vg_uuid, sizeof(vg_uuid)))
+		stack;
+
 	dm_list_init(&final_lvs);
 
 	if (!vg_check_status(vg, EXPORTED_VG)) {
@@ -2316,7 +2341,15 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 	    (tags_supplied && str_list_match_list(tags_in, &vg->tags, NULL)))
 		process_all = 1;
 
+	log_set_report_object_group_and_group_id(vg->name, vg_uuid);
+
 	dm_list_iterate_items(lvl, &vg->lvs) {
+		lv_uuid[0] = '\0';
+		if (!id_write_format(&lvl->lv->lvid.id[1], lv_uuid, sizeof(lv_uuid)))
+			stack;
+
+		log_set_report_object_name_and_id(lvl->lv->name, lv_uuid);
+
 		if (sigint_caught()) {
 			ret_max = ECMD_FAILED;
 			goto_out;
@@ -2398,8 +2431,15 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 		final_lvl->lv = lvl->lv;
 		dm_list_add(&final_lvs, &final_lvl->list);
 	}
+	log_set_report_object_name_and_id(NULL, NULL);
 
 	dm_list_iterate_items(lvl, &final_lvs) {
+		lv_uuid[0] = '\0';
+		if (!id_write_format(&lvl->lv->lvid.id[1], lv_uuid, sizeof(lv_uuid)))
+			stack;
+
+		log_set_report_object_name_and_id(lvl->lv->name, lv_uuid);
+
 		if (sigint_caught()) {
 			ret_max = ECMD_FAILED;
 			goto_out;
@@ -2422,9 +2462,12 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 		if (ret > ret_max)
 			ret_max = ret;
 
-		if (stop_on_error && ret != ECMD_PROCESSED)
+		if (stop_on_error && ret != ECMD_PROCESSED) {
+			log_set_report_object_name_and_id(NULL, NULL);
 			goto_out;
+		}
 	}
+	log_set_report_object_name_and_id(NULL, NULL);
 
 	if (handle->include_historical_lvs && !tags_supplied) {
 		if (!dm_list_size(&_historical_lv.segments))
@@ -2432,6 +2475,12 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 		_historical_lv.vg = vg;
 
 		dm_list_iterate_items_safe(glvl, tglvl, &vg->historical_lvs) {
+			lv_uuid[0] = '\0';
+			if (!id_write_format(&glvl->glv->historical->lvid.id[1], lv_uuid, sizeof(lv_uuid)))
+				stack;
+
+			log_set_report_object_name_and_id(glvl->glv->historical->name, lv_uuid);
+
 			process_lv = process_all;
 
 			if (lvargs_supplied &&
@@ -2463,9 +2512,12 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 			if (ret > ret_max)
 				ret_max = ret;
 
-			if (stop_on_error && ret != ECMD_PROCESSED)
+			if (stop_on_error && ret != ECMD_PROCESSED) {
+				log_set_report_object_name_and_id(NULL, NULL);
 				goto_out;
+			}
 		}
+		log_set_report_object_name_and_id(NULL, NULL);
 	}
 
 	if (lvargs_supplied) {
@@ -2474,6 +2526,7 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 		 * this leads to miscalculation that depends on the order of args.
 		 */
 		dm_list_iterate_items(sl, arg_lvnames) {
+			log_set_report_object_name_and_id(sl->str, NULL);
 			log_error("Failed to find logical volume \"%s/%s\"",
 				  vg->name, sl->str);
 			if (ret_max < ECMD_FAILED)
@@ -2481,10 +2534,14 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 		}
 	}
 out:
+	log_set_report_object_name_and_id(NULL, NULL);
+	log_set_report_object_group_and_group_id(NULL, NULL);
 	if (!handle_supplied)
 		destroy_processing_handle(cmd, handle);
 	else
 		_set_final_selection_result(handle, whole_selected);
+	log_restore_report_state(saved_log_report_state);
+
 	return ret_max;
 }
 
@@ -2627,6 +2684,7 @@ static int _process_lv_vgnameid_list(struct cmd_context *cmd, uint32_t read_flag
 				     struct processing_handle *handle,
 				     process_single_lv_fn_t process_single_lv)
 {
+	log_report_t saved_log_report_state = log_get_report_state();
 	char uuid[64] __attribute__((aligned(8)));
 	struct volume_group *vg;
 	struct vgnameid_list *vgnl;
@@ -2644,15 +2702,25 @@ static int _process_lv_vgnameid_list(struct cmd_context *cmd, uint32_t read_flag
 	int notfound;
 	int already_locked;
 
-	dm_list_iterate_items(vgnl, vgnameids_to_process) {
-		if (sigint_caught())
-			return_ECMD_FAILED;
+	log_set_report_object_type(LOG_REPORT_OBJECT_TYPE_VG);
 
+	dm_list_iterate_items(vgnl, vgnameids_to_process) {
 		vg_name = vgnl->vg_name;
 		vg_uuid = vgnl->vgid;
 		skip = 0;
 		notfound = 0;
 
+		uuid[0] = '\0';
+		if (vg_uuid && !id_write_format((const struct id*)vg_uuid, uuid, sizeof(uuid)))
+			stack;
+
+		log_set_report_object_name_and_id(vg_name, uuid);
+
+		if (sigint_caught()) {
+			ret_max = ECMD_FAILED;
+			goto_out;
+		}
+
 		/*
 		 * arg_lvnames contains some elements that are just "vgname"
 		 * which means process all lvs in the vg.  Other elements
@@ -2678,14 +2746,12 @@ static int _process_lv_vgnameid_list(struct cmd_context *cmd, uint32_t read_flag
 				if (!str_list_add(cmd->mem, &lvnames,
 						  dm_pool_strdup(cmd->mem, lvn + 1))) {
 					log_error("strlist allocation failed.");
-					return ECMD_FAILED;
+					ret_max = ECMD_FAILED;
+					goto out;
 				}
 			}
 		}
 
-		if (vg_uuid && !id_write_format((const struct id*)vg_uuid, uuid, sizeof(uuid)))
-			stack;
-
 		log_very_verbose("Processing VG %s %s", vg_name, vg_uuid ? uuid : "");
 
 		if (!lockd_vg(cmd, vg_name, NULL, 0, &lockd_state)) {
@@ -2717,8 +2783,10 @@ endvg:
 		release_vg(vg);
 		if (!lockd_vg(cmd, vg_name, "un", 0, &lockd_state))
 			stack;
+		log_set_report_object_name_and_id(NULL, NULL);
 	}
-
+out:
+	log_restore_report_state(saved_log_report_state);
 	return ret_max;
 }
 
@@ -2732,6 +2800,7 @@ int process_each_lv(struct cmd_context *cmd,
 		    struct processing_handle *handle,
 		    process_single_lv_fn_t process_single_lv)
 {
+	log_report_t saved_log_report_state = log_get_report_state();
 	int handle_supplied = handle != NULL;
 	struct dm_list arg_tags;		/* str_list */
 	struct dm_list arg_vgnames;		/* str_list */
@@ -2743,6 +2812,8 @@ int process_each_lv(struct cmd_context *cmd,
 	int ret_max = ECMD_PROCESSED;
 	int ret;
 
+	log_set_report_object_type(LOG_REPORT_OBJECT_TYPE_LV);
+
 	/* Disable error in vg_read so we can print it from ignore_vg. */
 	cmd->vg_read_print_access_error = 0;
 
@@ -2850,6 +2921,7 @@ out:
 	if (!handle_supplied)
 		destroy_processing_handle(cmd, handle);
 
+	log_restore_report_state(saved_log_report_state);
 	return ret_max;
 }
 
@@ -3172,6 +3244,9 @@ static int _process_pvs_in_vg(struct cmd_context *cmd,
 			      struct processing_handle *handle,
 			      process_single_pv_fn_t process_single_pv)
 {
+	log_report_t saved_log_report_state = log_get_report_state();
+	char pv_uuid[64] __attribute__((aligned(8)));
+	char vg_uuid[64] __attribute__((aligned(8)));
 	int handle_supplied = handle != NULL;
 	struct physical_volume *pv;
 	struct pv_list *pvl;
@@ -3181,6 +3256,12 @@ static int _process_pvs_in_vg(struct cmd_context *cmd,
 	int ret_max = ECMD_PROCESSED;
 	int ret = 0;
 
+	log_set_report_object_type(LOG_REPORT_OBJECT_TYPE_PV);
+
+	vg_uuid[0] = '\0';
+	if (!id_write_format(&vg->id, vg_uuid, sizeof(vg_uuid)))
+		stack;
+
 	if (!handle && (!(handle = init_processing_handle(cmd, NULL)))) {
 		ret_max = ECMD_FAILED;
 		goto_out;
@@ -3192,15 +3273,22 @@ static int _process_pvs_in_vg(struct cmd_context *cmd,
 		goto_out;
 	}
 
+	log_set_report_object_group_and_group_id(vg->name, vg_uuid);
+
 	dm_list_iterate_items(pvl, &vg->pvs) {
+		pv = pvl->pv;
+		pv_name = pv_dev_name(pv);
+		pv_uuid[0]='\0';
+		if (!id_write_format(&pv->id, pv_uuid, sizeof(pv_uuid)))
+			stack;
+
+		log_set_report_object_name_and_id(pv_name, pv_uuid);
+
 		if (sigint_caught()) {
 			ret_max = ECMD_FAILED;
 			goto_out;
 		}
 
-		pv = pvl->pv;
-		pv_name = pv_dev_name(pv);
-
 		process_pv = process_all_pvs;
 
 		/* Remove each arg_devices entry as it is processed. */
@@ -3249,10 +3337,15 @@ static int _process_pvs_in_vg(struct cmd_context *cmd,
 	 	 */
 		if (!process_all_pvs && dm_list_empty(arg_tags) && dm_list_empty(arg_devices))
 			break;
+		log_set_report_object_name_and_id(NULL, NULL);
 	}
 out:
+	log_set_report_object_name_and_id(NULL, NULL);
+	log_set_report_object_group_and_group_id(NULL, NULL);
 	if (!handle_supplied)
 		destroy_processing_handle(cmd, handle);
+	log_restore_report_state(saved_log_report_state);
+
 	return ret_max;
 }
 
@@ -3277,6 +3370,8 @@ static int _process_pvs_in_vgs(struct cmd_context *cmd, uint32_t read_flags,
 			       struct processing_handle *handle,
 			       process_single_pv_fn_t process_single_pv)
 {
+	log_report_t saved_log_report_state = log_get_report_state();
+	char uuid[64] __attribute__((aligned(8)));
 	struct volume_group *vg;
 	struct vgnameid_list *vgnl;
 	const char *vg_name;
@@ -3288,15 +3383,26 @@ static int _process_pvs_in_vgs(struct cmd_context *cmd, uint32_t read_flags,
 	int notfound;
 	int already_locked;
 
-	dm_list_iterate_items(vgnl, all_vgnameids) {
-		if (sigint_caught())
-			return_ECMD_FAILED;
+	log_set_report_object_type(LOG_REPORT_OBJECT_TYPE_VG);
 
+	dm_list_iterate_items(vgnl, all_vgnameids) {
 		vg_name = vgnl->vg_name;
 		vg_uuid = vgnl->vgid;
 		skip = 0;
 		notfound = 0;
 
+		uuid[0] = '\0';
+		if (vg_uuid && !is_orphan_vg(vg_name) &&
+		    !id_write_format((const struct id*)vg_uuid, uuid, sizeof(uuid)))
+			stack;
+
+		log_set_report_object_name_and_id(vg_name, uuid);
+
+		if (sigint_caught()) {
+			ret_max = ECMD_FAILED;
+			goto_out;
+		}
+
 		if (!lockd_vg(cmd, vg_name, NULL, 0, &lockd_state)) {
 			ret_max = ECMD_FAILED;
 			continue;
@@ -3339,9 +3445,12 @@ endvg:
 
 		/* Quit early when possible. */
 		if (!process_all_pvs && dm_list_empty(arg_tags) && dm_list_empty(arg_devices))
-			return ret_max;
-	}
+			goto_out;
 
+		log_set_report_object_name_and_id(NULL, NULL);
+	}
+out:
+	log_restore_report_state(saved_log_report_state);
 	return ret_max;
 }
 
@@ -3351,6 +3460,7 @@ int process_each_pv(struct cmd_context *cmd,
 		    struct processing_handle *handle,
 		    process_single_pv_fn_t process_single_pv)
 {
+	log_report_t saved_log_report_state = log_get_report_state();
 	struct dm_list arg_tags;	/* str_list */
 	struct dm_list arg_pvnames;	/* str_list */
 	struct dm_list arg_devices;	/* device_id_list */
@@ -3364,6 +3474,7 @@ int process_each_pv(struct cmd_context *cmd,
 	int ret_max = ECMD_PROCESSED;
 	int ret;
 
+	log_set_report_object_type(LOG_REPORT_OBJECT_TYPE_PV);
 	log_debug("Processing each PV");
 
 	/*
@@ -3398,8 +3509,8 @@ int process_each_pv(struct cmd_context *cmd,
 	 * names/paths into arg_devices which can be used to match below.
 	 */
 	if ((ret = _get_arg_pvnames(cmd, argc, argv, &arg_pvnames, &arg_tags)) != ECMD_PROCESSED) {
-		stack;
-		return ret;
+		ret_max = ret;
+		goto_out;
 	}
 
 	if ((cmd->command->flags & DISALLOW_TAG_ARGS) && !dm_list_empty(&arg_tags)) {
@@ -3414,8 +3525,10 @@ int process_each_pv(struct cmd_context *cmd,
 	process_all_devices = process_all_pvs && (cmd->command->flags & ENABLE_ALL_DEVS) && all_is_set;
 
 	/* Needed for a current listing of the global VG namespace. */
-	if (!only_this_vgname && !lockd_gl(cmd, "sh", 0))
-		return_ECMD_FAILED;
+	if (!only_this_vgname && !lockd_gl(cmd, "sh", 0)) {
+		ret_max = ECMD_FAILED;
+		goto_out;
+	}
 
 	/*
 	 * This full scan would be done by _get_all_devices() if
@@ -3431,8 +3544,8 @@ int process_each_pv(struct cmd_context *cmd,
 	}
 
 	if (!get_vgnameids(cmd, &all_vgnameids, only_this_vgname, 1)) {
-		stack;
-		return ret;
+		ret_max = ret;
+		goto_out;
 	}
 
 	/*
@@ -3441,8 +3554,8 @@ int process_each_pv(struct cmd_context *cmd,
 	 * any devs remaining in all_devices are processed.
 	 */
 	if ((ret = _get_all_devices(cmd, &all_devices) != ECMD_PROCESSED)) {
-		stack;
-		return ret;
+		ret_max = ret;
+		goto_out;
 	}
 
 	if ((ret = _get_arg_devices(cmd, &arg_pvnames, &arg_devices)) != ECMD_PROCESSED)
@@ -3568,6 +3681,7 @@ skip_missed:
 	if (ret > ret_max)
 		ret_max = ret;
 out:
+	log_restore_report_state(saved_log_report_state);
 	return ret_max;
 }
 
@@ -3575,14 +3689,33 @@ int process_each_pv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 			  struct processing_handle *handle,
 			  process_single_pv_fn_t process_single_pv)
 {
+	log_report_t saved_log_report_state = log_get_report_state();
+	char pv_uuid[64] __attribute__((aligned(8)));
+	char vg_uuid[64] __attribute__((aligned(8)));
 	int whole_selected = 0;
 	int ret_max = ECMD_PROCESSED;
 	int ret;
 	struct pv_list *pvl;
 
+	log_set_report_object_type(LOG_REPORT_OBJECT_TYPE_PV);
+
+	vg_uuid[0] = '\0';
+	if (!id_write_format(&vg->id, vg_uuid, sizeof(vg_uuid)))
+		stack;
+
+	log_set_report_object_group_and_group_id(vg->name, vg_uuid);
+
 	dm_list_iterate_items(pvl, &vg->pvs) {
-		if (sigint_caught())
-			return_ECMD_FAILED;
+		pv_uuid[0] = '\0';
+		if (!id_write_format(&pvl->pv->id, pv_uuid, sizeof(pv_uuid)))
+			stack;
+
+		log_set_report_object_name_and_id(pv_dev_name(pvl->pv), pv_uuid);
+
+		if (sigint_caught()) {
+			ret_max = ECMD_FAILED;
+			goto_out;
+		}
 
 		ret = process_single_pv(cmd, vg, pvl->pv, handle);
 		_update_selection_result(handle, &whole_selected);
@@ -3590,9 +3723,13 @@ int process_each_pv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 			stack;
 		if (ret > ret_max)
 			ret_max = ret;
+
+		log_set_report_object_name_and_id(NULL, NULL);
 	}
 
 	_set_final_selection_result(handle, whole_selected);
+out:
+	log_restore_report_state(saved_log_report_state);
 	return ret_max;
 }
 


