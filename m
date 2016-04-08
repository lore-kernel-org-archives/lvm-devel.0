From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  8 Apr 2016 09:03:14 +0000 (UTC)
Subject: master - cleanup: use common init/destroy_processing_handle in _report fn and cleanup error paths
Message-ID: <20160408090314.89E01609F7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=50866034a2e612250c45116674765da08820fb27
Commit:        50866034a2e612250c45116674765da08820fb27
Parent:        f2e59e05eda9283911a8c7ea14c73ea4c30f8fa8
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Apr 8 11:01:19 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Apr 8 11:01:19 2016 +0200

cleanup: use common init/destroy_processing_handle in _report fn and cleanup error paths

---
 tools/reporter.c |   58 +++++++++++++++++++++++++++--------------------------
 1 files changed, 30 insertions(+), 28 deletions(-)

diff --git a/tools/reporter.c b/tools/reporter.c
index 1a708c4..220e307 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -733,10 +733,10 @@ out:
 static int _report(struct cmd_context *cmd, int argc, char **argv,
 		   report_type_t report_type)
 {
-	void *report_handle;
-	struct processing_handle handle = {0};
+	void *report_handle = NULL;
+	struct processing_handle *handle = NULL;
 	const char *keys = NULL, *options = NULL, *selection = NULL, *separator;
-	int r = ECMD_PROCESSED;
+	int r = ECMD_FAILED;
 	int aligned, buffered, headings, field_prefixes, quoted;
 	int columns_as_rows;
 	unsigned args_are_pvs;
@@ -809,13 +809,13 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 		break;
 	default:
 		log_error(INTERNAL_ERROR "Unknown report type.");
-		return ECMD_FAILED;
+		goto out;
 	}
 
 	/* If -o supplied use it, else use default for report_type */
 	if (arg_count(cmd, options_ARG) &&
 	    ((r = _get_report_options(cmd, report_type, &options, &fields_to_compact) != ECMD_PROCESSED)))
-		return r;
+		goto_out;
 
 	/* -O overrides default sort settings */
 	keys = arg_str_value(cmd, sort_ARG, keys);
@@ -841,19 +841,24 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 	if (arg_count(cmd, select_ARG))
 		selection = arg_str_value(cmd, select_ARG, NULL);
 
+	if (!(handle = init_processing_handle(cmd)))
+		goto_out;
+
 	if (!(report_handle = report_init(cmd, options, keys, &report_type,
 					  separator, aligned, buffered,
 					  headings, field_prefixes, quoted,
 					  columns_as_rows, selection)))
-		return_ECMD_FAILED;
+		goto_out;
+
+	handle->internal_report_for_select = 0;
+	handle->include_historical_lvs = cmd->include_historical_lvs;
+	handle->custom_handle = report_handle;
 
 	if (!_get_final_report_type(args_are_pvs,
 				    report_type, &lv_info_needed,
 				    &lv_segment_status_needed,
-				    &report_type)) {
-		dm_report_free(report_handle);
-		return ECMD_FAILED;
-	}
+				    &report_type))
+		goto_out;
 
 	/*
 	 * We lock VG_GLOBAL to enable use of metadata cache.
@@ -864,18 +869,13 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 		lock_global = 1;
 		if (!lock_vol(cmd, VG_GLOBAL, LCK_VG_READ, NULL)) {
 			log_error("Unable to obtain global lock.");
-			dm_report_free(report_handle);
-			return ECMD_FAILED;
+			goto out;
 		}
 	}
 
-	handle.internal_report_for_select = 0;
-	handle.include_historical_lvs = cmd->include_historical_lvs;
-	handle.custom_handle = report_handle;
-
 	switch (report_type) {
 	case DEVTYPES:
-		r = _process_each_devtype(cmd, argc, &handle);
+		r = _process_each_devtype(cmd, argc, handle);
 		break;
 	case LVSINFO:
 		/* fall through */
@@ -884,7 +884,7 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 	case LVSINFOSTATUS:
 		/* fall through */
 	case LVS:
-		r = process_each_lv(cmd, argc, argv, 0, &handle,
+		r = process_each_lv(cmd, argc, argv, 0, handle,
 				    lv_info_needed && !lv_segment_status_needed ? &_lvs_with_info_single :
 				    !lv_info_needed && lv_segment_status_needed ? &_lvs_with_status_single :
 				    lv_info_needed && lv_segment_status_needed ? &_lvs_with_info_and_status_single :
@@ -892,25 +892,25 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 		break;
 	case VGS:
 		r = process_each_vg(cmd, argc, argv, NULL, 0,
-				    &handle, &_vgs_single);
+				    handle, &_vgs_single);
 		break;
 	case LABEL:
 		r = process_each_label(cmd, argc, argv,
-				       &handle, &_label_single);
+				       handle, &_label_single);
 		break;
 	case PVS:
 		if (args_are_pvs)
 			r = process_each_pv(cmd, argc, argv, NULL,
 					    arg_is_set(cmd, all_ARG), 0,
-					    &handle, &_pvs_single);
+					    handle, &_pvs_single);
 		else
 			r = process_each_vg(cmd, argc, argv, NULL, 0,
-					    &handle, &_pvs_in_vg);
+					    handle, &_pvs_in_vg);
 		break;
 	case SEGSSTATUS:
 		/* fall through */
 	case SEGS:
-		r = process_each_lv(cmd, argc, argv, 0, &handle,
+		r = process_each_lv(cmd, argc, argv, 0, handle,
 				    lv_info_needed && !lv_segment_status_needed ? &_lvsegs_with_info_single :
 				    !lv_info_needed && lv_segment_status_needed ? &_lvsegs_with_status_single :
 				    lv_info_needed && lv_segment_status_needed ? &_lvsegs_with_info_and_status_single :
@@ -920,14 +920,14 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 		if (args_are_pvs)
 			r = process_each_pv(cmd, argc, argv, NULL,
 					    arg_is_set(cmd, all_ARG), 0,
-					    &handle,
+					    handle,
 					    lv_info_needed && !lv_segment_status_needed ? &_pvsegs_with_lv_info_single :
 					    !lv_info_needed && lv_segment_status_needed ? &_pvsegs_with_lv_status_single :
 					    lv_info_needed && lv_segment_status_needed ? &_pvsegs_with_lv_info_and_status_single :
 											 &_pvsegs_single);
 		else
 			r = process_each_vg(cmd, argc, argv, NULL, 0,
-					    &handle, &_pvsegs_in_vg);
+					    handle, &_pvsegs_in_vg);
 		break;
 	}
 
@@ -942,11 +942,13 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 
 	dm_report_output(report_handle);
 
-	dm_report_free(report_handle);
-
 	if (lock_global)
 		unlock_vg(cmd, VG_GLOBAL);
-
+out:
+	if (handle)
+		destroy_processing_handle(cmd, handle);
+	if (report_handle)
+		dm_report_free(report_handle);
 	return r;
 }
 


