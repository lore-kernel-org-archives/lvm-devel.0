From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 13 Feb 2015 10:29:33 +0000 (UTC)
Subject: master - cleanup: replace static struct processing_handle initializer with common init_processing_handle
Message-ID: <20150213102933.086E5613B0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=66b10d6d126fdf476cf43eec25820b021752b383
Commit:        66b10d6d126fdf476cf43eec25820b021752b383
Parent:        1a729331432167008f4298903adb78d75abb267c
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Feb 13 10:36:06 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Feb 13 11:26:57 2015 +0100

cleanup: replace static struct processing_handle initializer with common init_processing_handle

It's cleaner this way - do not mix static and dynamic
(init_processing_handle) initializers. Use the dynamic one everywhere.
This makes it easier to manage the code - there are no "exceptions"
then and we don't need to take care about two ways of initializing the
same thing - just use one common initializer throughout and it's clear.

Also, add more comments, mainly in the report_for_selection fn explaining
what is being done and why with respect to the processing_handle and
selection_handle.
---
 lib/report/report.h |    3 +-
 tools/lvconvert.c   |   15 ++++++++----
 tools/polldaemon.c  |   24 ++++++++++++-------
 tools/pvresize.c    |   16 +++++++++----
 tools/reporter.c    |   63 ++++++++++++++++++++++++++++++++++++++------------
 tools/toollib.c     |    6 ++--
 tools/vgcfgbackup.c |   15 ++++++++----
 7 files changed, 99 insertions(+), 43 deletions(-)

diff --git a/lib/report/report.h b/lib/report/report.h
index 5bd8b79..84c5f91 100644
--- a/lib/report/report.h
+++ b/lib/report/report.h
@@ -71,7 +71,8 @@ void *report_init(struct cmd_context *cmd, const char *format, const char *keys,
 		  int quoted, int columns_as_rows, const char *selection);
 void *report_init_for_selection(struct cmd_context *cmd, report_type_t *report_type,
 				const char *selection);
-int report_for_selection(struct selection_handle *sh,
+int report_for_selection(struct cmd_context *cmd,
+			 struct selection_handle *sh,
 			 struct physical_volume *pv,
 			 struct volume_group *vg,
 			 struct logical_volume *lv);
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 2df2483..b2527e4 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -3542,10 +3542,15 @@ int lvconvert(struct cmd_context * cmd, int argc, char **argv)
 	struct lvconvert_params lp = {
 		.target_attr = ~0,
 	};
+	struct processing_handle *handle = NULL;
 
-	struct processing_handle handle = { .internal_report_for_select = 1,
-					    .selection_handle = NULL,
-					    .custom_handle = &lp };
+	if (!(handle = init_processing_handle(cmd))) {
+		log_error("Failed to initialize processing handle.");
+		ret = ECMD_FAILED;
+		goto out;
+	}
+
+	handle->custom_handle = &lp;
 
 	if (!_read_params(cmd, argc, argv, &lp)) {
 		ret = EINVALID_CMD_LINE;
@@ -3553,11 +3558,11 @@ int lvconvert(struct cmd_context * cmd, int argc, char **argv)
 	}
 
 	if (lp.merge)
-		ret = process_each_lv(cmd, argc, argv, READ_FOR_UPDATE, &handle,
+		ret = process_each_lv(cmd, argc, argv, READ_FOR_UPDATE, handle,
 				    &_lvconvert_merge_single);
 	else
 		ret = lvconvert_single(cmd, &lp);
 out:
-	destroy_processing_handle(cmd, &handle, 0);
+	destroy_processing_handle(cmd, handle, 1);
 	return ret;
 }
diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index 204c495..722a385 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -227,21 +227,17 @@ static int _poll_vg(struct cmd_context *cmd, const char *vgname,
 }
 
 static void _poll_for_all_vgs(struct cmd_context *cmd,
-			      struct daemon_parms *parms)
+			      struct processing_handle *handle)
 {
-	struct processing_handle handle = { .internal_report_for_select = 1,
-					    .selection_handle = NULL,
-					    .custom_handle = parms };
+	struct daemon_parms *parms = (struct daemon_parms *) handle->custom_handle;
 
 	while (1) {
 		parms->outstanding_count = 0;
-		process_each_vg(cmd, 0, NULL, READ_FOR_UPDATE, &handle, _poll_vg);
+		process_each_vg(cmd, 0, NULL, READ_FOR_UPDATE, handle, _poll_vg);
 		if (!parms->outstanding_count)
 			break;
 		sleep(parms->interval);
 	}
-
-	destroy_processing_handle(cmd, &handle, 0);
 }
 
 /*
@@ -255,6 +251,7 @@ int poll_daemon(struct cmd_context *cmd, const char *name, const char *uuid,
 		uint64_t lv_type, struct poll_functions *poll_fns,
 		const char *progress_title)
 {
+	struct processing_handle *handle = NULL;
 	struct daemon_parms parms;
 	int daemon_mode = 0;
 	int ret = ECMD_PROCESSED;
@@ -306,10 +303,18 @@ int poll_daemon(struct cmd_context *cmd, const char *name, const char *uuid,
 			stack;
 			ret = ECMD_FAILED;
 		}
-	} else
-		_poll_for_all_vgs(cmd, &parms);
+	} else {
+		if (!(handle = init_processing_handle(cmd))) {
+			log_error("Failed to initialize processing handle.");
+			ret = ECMD_FAILED;
+		} else {
+			handle->custom_handle = &parms;
+			_poll_for_all_vgs(cmd, handle);
+		}
+	}
 
 	if (parms.background && daemon_mode == 1) {
+		destroy_processing_handle(cmd, handle, 1);
 		/*
 		 * child was successfully forked:
 		 * background polldaemon must not return to the caller
@@ -320,5 +325,6 @@ int poll_daemon(struct cmd_context *cmd, const char *name, const char *uuid,
 		_exit(lvm_return_code(ret));
 	}
 
+	destroy_processing_handle(cmd, handle, 1);
 	return ret;
 }
diff --git a/tools/pvresize.c b/tools/pvresize.c
index f6253d9..ec638a4 100644
--- a/tools/pvresize.c
+++ b/tools/pvresize.c
@@ -47,9 +47,7 @@ static int _pvresize_single(struct cmd_context *cmd,
 int pvresize(struct cmd_context *cmd, int argc, char **argv)
 {
 	struct pvresize_params params;
-	struct processing_handle handle = { .internal_report_for_select = 1,
-					    .selection_handle = NULL,
-					    .custom_handle = &params };
+	struct processing_handle *handle = NULL;
 	int ret = ECMD_PROCESSED;
 
 	if (!argc) {
@@ -70,12 +68,20 @@ int pvresize(struct cmd_context *cmd, int argc, char **argv)
 	params.done = 0;
 	params.total = 0;
 
-	ret = process_each_pv(cmd, argc, argv, NULL, READ_FOR_UPDATE, &handle,
+	if (!(handle = init_processing_handle(cmd))) {
+		log_error("Failed to initialize processing handle.");
+		ret = ECMD_FAILED;
+		goto out;
+	}
+
+	handle->custom_handle = &params;
+
+	ret = process_each_pv(cmd, argc, argv, NULL, READ_FOR_UPDATE, handle,
 			      _pvresize_single);
 
 	log_print_unless_silent("%d physical volume(s) resized / %d physical volume(s) "
 				"not resized", params.done, params.total - params.done);
 out:
-	destroy_processing_handle(cmd, &handle, 0);
+	destroy_processing_handle(cmd, handle, 1);
 	return ret;
 }
diff --git a/tools/reporter.c b/tools/reporter.c
index 0bfed51..9cc87bd 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -447,7 +447,8 @@ static int _get_final_report_type(int args_are_pvs,
 	return 1;
 }
 
-int report_for_selection(struct selection_handle *sh,
+int report_for_selection(struct cmd_context *cmd,
+			 struct selection_handle *sh,
 			 struct physical_volume *pv,
 			 struct volume_group *vg,
 			 struct logical_volume *lv)
@@ -455,9 +456,7 @@ int report_for_selection(struct selection_handle *sh,
 	static const char *incorrect_report_type_msg = "report_for_selection: incorrect report type";
 	int args_are_pvs = sh->orig_report_type == PVS;
 	int do_lv_info, do_lv_seg_status;
-	struct processing_handle handle = { .internal_report_for_select = 0,
-					    .selection_handle = sh,
-					    .custom_handle = NULL };
+	struct processing_handle *handle;
 	int r = 0;
 
 	if (!_get_final_report_type(args_are_pvs,
@@ -467,19 +466,46 @@ int report_for_selection(struct selection_handle *sh,
 				    &sh->report_type))
 		return_0;
 
+	if (!(handle = init_processing_handle(cmd)))
+		return_0;
+
+	/*
+	 * We're already reporting for select so override
+	 * internal_report_for_select to 0 as we can call
+	 * process_each_* functions again and we could
+	 * end up in an infinite loop if we didn't stop
+	 * internal reporting for select right here.
+	 *
+	 * So the overall call trace from top to bottom looks like this:
+	 *
+	 * process_each_* (top-level one, using processing_handle with internal reporting enabled and selection_handle) ->
+	 *   select_match_*(processing_handle with selection_handle) ->
+	 *     report for selection ->
+	 *     	 (creating new processing_handle here with internal reporting disabled!!!)
+	 *       reporting_fn OR process_each_* (using *new* processing_handle with original selection_handle) 
+	 *
+	 * The selection_handle is still reused so we can track
+	 * whether any of the items the top-level one is composed
+	 * of are still selected or not unerneath. Do not destroy
+	 * this selection handle - it needs to be passed to upper
+	 * layers to check the overall selection status.
+	 */
+	handle->internal_report_for_select = 0;
+	handle->selection_handle = sh;
+
 	/*
 	 * Remember:
-	 *   sh->orig_report_type is the original report type requested
-	 *   sh->report_type is the report type actually used (it counts with all types of fields used in selection)
+	 *   sh->orig_report_type is the original report type requested (what are we selecting? PV/VG/LV?)
+	 *   sh->report_type is the report type actually used (it counts with all types of fields used in selection criteria)
 	 */
 	switch (sh->orig_report_type) {
 		case LVS:
 			switch (sh->report_type) {
 				case LVS:
-					r = _do_lvs_with_info_and_status_single(vg->cmd, lv, do_lv_info, do_lv_seg_status, &handle);
+					r = _do_lvs_with_info_and_status_single(vg->cmd, lv, do_lv_info, do_lv_seg_status, handle);
 					break;
 				case SEGS:
-					r = process_each_segment_in_lv(vg->cmd, lv, &handle,
+					r = process_each_segment_in_lv(vg->cmd, lv, handle,
 								       do_lv_info && !do_lv_seg_status ? &_segs_with_info_single :
 								       !do_lv_info && do_lv_seg_status ? &_segs_with_status_single :
 								       do_lv_info && do_lv_seg_status ? &_segs_with_info_and_status_single :
@@ -493,27 +519,27 @@ int report_for_selection(struct selection_handle *sh,
 		case VGS:
 			switch (sh->report_type) {
 				case VGS:
-					r = _vgs_single(vg->cmd, vg->name, vg, &handle);
+					r = _vgs_single(vg->cmd, vg->name, vg, handle);
 					break;
 				case LVS:
-					r = process_each_lv_in_vg(vg->cmd, vg, NULL, NULL, 0, &handle,
+					r = process_each_lv_in_vg(vg->cmd, vg, NULL, NULL, 0, handle,
 								  do_lv_info && !do_lv_seg_status ? &_lvs_with_info_single :
 								  !do_lv_info && do_lv_seg_status ? &_lvs_with_status_single :
 								  do_lv_info && do_lv_seg_status ? &_lvs_with_info_and_status_single :
 												   &_lvs_single);
 					break;
 				case SEGS:
-					r = process_each_lv_in_vg(vg->cmd, vg, NULL, NULL, 0, &handle,
+					r = process_each_lv_in_vg(vg->cmd, vg, NULL, NULL, 0, handle,
 								  do_lv_info && !do_lv_seg_status ? &_lvsegs_with_info_single :
 								  !do_lv_info && do_lv_seg_status ? &_lvsegs_with_status_single :
 								  do_lv_info && do_lv_seg_status ? &_lvsegs_with_info_and_status_single :
 												   &_lvsegs_single);
 					break;
 				case PVS:
-					r = process_each_pv_in_vg(vg->cmd, vg, &handle, &_pvs_single);
+					r = process_each_pv_in_vg(vg->cmd, vg, handle, &_pvs_single);
 					break;
 				case PVSEGS:
-					r = process_each_pv_in_vg(vg->cmd, vg, &handle,
+					r = process_each_pv_in_vg(vg->cmd, vg, handle,
 								  do_lv_info && !do_lv_seg_status ? &_pvsegs_with_lv_info_single :
 								  !do_lv_info && do_lv_seg_status ? &_pvsegs_with_lv_status_single :
 								  do_lv_info && do_lv_seg_status ? &_pvsegs_with_lv_info_and_status_single :
@@ -527,10 +553,10 @@ int report_for_selection(struct selection_handle *sh,
 		case PVS:
 			switch (sh->report_type) {
 				case PVS:
-					r = _pvs_single(vg->cmd, vg, pv, &handle);
+					r = _pvs_single(vg->cmd, vg, pv, handle);
 					break;
 				case PVSEGS:
-					r = process_each_segment_in_pv(vg->cmd, vg, pv, &handle,
+					r = process_each_segment_in_pv(vg->cmd, vg, pv, handle,
 								       do_lv_info && !do_lv_seg_status ? &_pvsegs_with_lv_info_sub_single :
 								       !do_lv_info && do_lv_seg_status ? &_pvsegs_with_lv_status_sub_single :
 								       do_lv_info && do_lv_seg_status ? &_pvsegs_with_lv_info_and_status_sub_single :
@@ -546,6 +572,13 @@ int report_for_selection(struct selection_handle *sh,
 			break;
 	}
 
+	/*
+	 * Keep the selection handle provided from the caller -
+	 * do not destroy it - the caller will still use it to
+	 * pass the result through it to layers above.
+	 */
+	handle->selection_handle = NULL;
+	destroy_processing_handle(cmd, handle, 1);
 	return r;
 }
 
diff --git a/tools/toollib.c b/tools/toollib.c
index 43c7fc1..4e0d0e7 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1639,7 +1639,7 @@ int select_match_vg(struct cmd_context *cmd, struct processing_handle *handle,
 
 	sh->orig_report_type = VGS;
 
-	if (!report_for_selection(sh, NULL, vg, NULL)) {
+	if (!report_for_selection(cmd, sh, NULL, vg, NULL)) {
 		log_error("Selection failed for VG %s.", vg->name);
 		return 0;
 	}
@@ -1662,7 +1662,7 @@ int select_match_lv(struct cmd_context *cmd, struct processing_handle *handle,
 
 	sh->orig_report_type = LVS;
 
-	if (!report_for_selection(sh, NULL, vg, lv)) {
+	if (!report_for_selection(cmd, sh, NULL, vg, lv)) {
 		log_error("Selection failed for LV %s.", lv->name);
 		return 0;
 	}
@@ -1685,7 +1685,7 @@ int select_match_pv(struct cmd_context *cmd, struct processing_handle *handle,
 
 	sh->orig_report_type = PVS;
 
-	if (!report_for_selection(sh, pv, vg, NULL)) {
+	if (!report_for_selection(cmd, sh, pv, vg, NULL)) {
 		log_error("Selection failed for PV %s.", dev_name(pv->dev));
 		return 0;
 	}
diff --git a/tools/vgcfgbackup.c b/tools/vgcfgbackup.c
index 0a6c5f2..a25a718 100644
--- a/tools/vgcfgbackup.c
+++ b/tools/vgcfgbackup.c
@@ -83,19 +83,24 @@ int vgcfgbackup(struct cmd_context *cmd, int argc, char **argv)
 {
 	int ret;
 	char *last_filename = NULL;
-	struct processing_handle handle = { .internal_report_for_select = 1,
-					    .selection_handle = NULL,
-					    .custom_handle = &last_filename };
+	struct processing_handle *handle = NULL;
+
+	if (!(handle = init_processing_handle(cmd))) {
+		log_error("Failed to initialize processing handle.");
+		return ECMD_FAILED;
+	}
+
+	handle->custom_handle = &last_filename;
 
 	init_pvmove(1);
 
 	ret = process_each_vg(cmd, argc, argv, READ_ALLOW_INCONSISTENT,
-			      &handle, &vg_backup_single);
+			      handle, &vg_backup_single);
 
 	dm_free(last_filename);
 
 	init_pvmove(0);
 
-	destroy_processing_handle(cmd, &handle, 0);
+	destroy_processing_handle(cmd, handle, 1);
 	return ret;
 }


