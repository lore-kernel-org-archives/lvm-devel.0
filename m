From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 20 Jun 2016 09:41:21 +0000 (UTC)
Subject: master - log: annotate processing code with report_current_object_cmdlog
Message-ID: <20160620094121.D861861013@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0ab118774029cc955512c4a41930956ccd96a138
Commit:        0ab118774029cc955512c4a41930956ccd96a138
Parent:        6ca28ca4c69b66b07ebcc19cea02b8317c6df0bf
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon May 23 15:27:09 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jun 20 11:33:43 2016 +0200

log: annotate processing code with report_current_object_cmdlog

---
 WHATS_NEW           |    1 +
 lib/report/report.h |    3 +++
 tools/toollib.c     |   51 +++++++++++++++++++++++++++++++++++++++++++++++----
 3 files changed, 51 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index fedc1e8..f800eca 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.158 - 
 =================================
+  Report per-object return codes via cmd log while processing multiple objects.
   Annotate processing code with log report hooks for per-object command log.
   Also pass common printed messages (besides warnings and errors) to log report.
   Log warnings and errors via report during cmd processing if this is enabled.
diff --git a/lib/report/report.h b/lib/report/report.h
index f2880ec..e6fbc8d 100644
--- a/lib/report/report.h
+++ b/lib/report/report.h
@@ -111,6 +111,9 @@ int report_cmdlog(void *handle, const char *type, const char *context,
 		  const char *object_id, const char *object_group,
 		  const char *object_group_id, const char *msg,
 		  int current_errno, int ret_code);
+#define REPORT_OBJECT_CMDLOG_NAME "status"
+#define REPORT_OBJECT_CMDLOG_SUCCESS "success"
+#define REPORT_OBJECT_CMDLOG_FAILURE "failure"
 int report_current_object_cmdlog(const char *type, const char *msg, int32_t ret_code);
 int report_output(void *handle);
 
diff --git a/tools/toollib.c b/tools/toollib.c
index 08178f6..e044cb4 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -22,6 +22,10 @@
 #include <sys/wait.h>
 #include <sys/utsname.h>
 
+#define report_log_ret_code(ret_code) report_current_object_cmdlog(REPORT_OBJECT_CMDLOG_NAME, \
+					ret_code == ECMD_PROCESSED ? REPORT_OBJECT_CMDLOG_SUCCESS \
+								   : REPORT_OBJECT_CMDLOG_FAILURE, ret_code)
+
 struct device_id_list {
 	struct dm_list list;
 	struct device *dev;
@@ -1862,6 +1866,7 @@ static int _process_vgnameid_list(struct cmd_context *cmd, uint32_t read_flags,
 	int notfound;
 	int process_all = 0;
 	int already_locked;
+	int do_report_ret_code = 1;
 
 	log_set_report_object_type(LOG_REPORT_OBJECT_TYPE_VG);
 
@@ -1896,6 +1901,7 @@ static int _process_vgnameid_list(struct cmd_context *cmd, uint32_t read_flags,
 
 		if (!lockd_vg(cmd, vg_name, NULL, 0, &lockd_state)) {
 			ret_max = ECMD_FAILED;
+			report_log_ret_code(ret_max);
 			continue;
 		}
 
@@ -1905,6 +1911,7 @@ static int _process_vgnameid_list(struct cmd_context *cmd, uint32_t read_flags,
 		if (_ignore_vg(vg, vg_name, arg_vgnames, read_flags, &skip, &notfound)) {
 			stack;
 			ret_max = ECMD_FAILED;
+			report_log_ret_code(ret_max);
 			goto endvg;
 		}
 		if (skip || notfound)
@@ -1922,6 +1929,7 @@ static int _process_vgnameid_list(struct cmd_context *cmd, uint32_t read_flags,
 			_update_selection_result(handle, &whole_selected);
 			if (ret != ECMD_PROCESSED)
 				stack;
+			report_log_ret_code(ret);
 			if (ret > ret_max)
 				ret_max = ret;
 		}
@@ -1935,10 +1943,12 @@ endvg:
 
 		log_set_report_object_name_and_id(NULL, NULL);
 	}
-
 	/* the VG is selected if at least one LV is selected */
 	_set_final_selection_result(handle, whole_selected);
+	do_report_ret_code = 0;
 out:
+	if (do_report_ret_code)
+		report_log_ret_code(ret_max);
 	log_restore_report_state(saved_log_report_state);
 	return ret_max;
 }
@@ -2304,6 +2314,7 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 	struct dm_list final_lvs;
 	struct lv_list *final_lvl;
 	struct glv_list *glvl, *tglvl;
+	int do_report_ret_code = 1;
 
 	log_set_report_object_type(LOG_REPORT_OBJECT_TYPE_LV);
 
@@ -2459,11 +2470,12 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 			_update_selection_result(handle, &whole_selected);
 		if (ret != ECMD_PROCESSED)
 			stack;
+		report_log_ret_code(ret);
 		if (ret > ret_max)
 			ret_max = ret;
 
 		if (stop_on_error && ret != ECMD_PROCESSED) {
-			log_set_report_object_name_and_id(NULL, NULL);
+			do_report_ret_code = 0;
 			goto_out;
 		}
 	}
@@ -2509,11 +2521,12 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 				_update_selection_result(handle, &whole_selected);
 			if (ret != ECMD_PROCESSED)
 				stack;
+			report_log_ret_code(ret);
 			if (ret > ret_max)
 				ret_max = ret;
 
 			if (stop_on_error && ret != ECMD_PROCESSED) {
-				log_set_report_object_name_and_id(NULL, NULL);
+				do_report_ret_code = 0;
 				goto_out;
 			}
 		}
@@ -2531,9 +2544,13 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 				  vg->name, sl->str);
 			if (ret_max < ECMD_FAILED)
 				ret_max = ECMD_FAILED;
+			report_log_ret_code(ret_max);
 		}
 	}
+	do_report_ret_code = 0;
 out:
+	if (do_report_ret_code)
+		report_log_ret_code(ret_max);
 	log_set_report_object_name_and_id(NULL, NULL);
 	log_set_report_object_group_and_group_id(NULL, NULL);
 	if (!handle_supplied)
@@ -2701,6 +2718,7 @@ static int _process_lv_vgnameid_list(struct cmd_context *cmd, uint32_t read_flag
 	int skip;
 	int notfound;
 	int already_locked;
+	int do_report_ret_code = 1;
 
 	log_set_report_object_type(LOG_REPORT_OBJECT_TYPE_VG);
 
@@ -2756,6 +2774,7 @@ static int _process_lv_vgnameid_list(struct cmd_context *cmd, uint32_t read_flag
 
 		if (!lockd_vg(cmd, vg_name, NULL, 0, &lockd_state)) {
 			ret_max = ECMD_FAILED;
+			report_log_ret_code(ret_max);
 			continue;
 		}
 
@@ -2765,6 +2784,7 @@ static int _process_lv_vgnameid_list(struct cmd_context *cmd, uint32_t read_flag
 		if (_ignore_vg(vg, vg_name, arg_vgnames, read_flags, &skip, &notfound)) {
 			stack;
 			ret_max = ECMD_FAILED;
+			report_log_ret_code(ret_max);
 			goto endvg;
 		}
 		if (skip || notfound)
@@ -2774,6 +2794,7 @@ static int _process_lv_vgnameid_list(struct cmd_context *cmd, uint32_t read_flag
 					    handle, process_single_lv);
 		if (ret != ECMD_PROCESSED)
 			stack;
+		report_log_ret_code(ret);
 		if (ret > ret_max)
 			ret_max = ret;
 
@@ -2785,7 +2806,10 @@ endvg:
 			stack;
 		log_set_report_object_name_and_id(NULL, NULL);
 	}
+	do_report_ret_code = 0;
 out:
+	if (do_report_ret_code)
+		report_log_ret_code(ret_max);
 	log_restore_report_state(saved_log_report_state);
 	return ret_max;
 }
@@ -3253,6 +3277,7 @@ static int _process_pvs_in_vg(struct cmd_context *cmd,
 	struct device_id_list *dil;
 	const char *pv_name;
 	int process_pv;
+	int do_report_ret_code = 1;
 	int ret_max = ECMD_PROCESSED;
 	int ret = 0;
 
@@ -3327,6 +3352,7 @@ static int _process_pvs_in_vg(struct cmd_context *cmd,
 				ret = process_single_pv(cmd, vg, pv, handle);
 				if (ret != ECMD_PROCESSED)
 					stack;
+				report_log_ret_code(ret);
 				if (ret > ret_max)
 					ret_max = ret;
 			}
@@ -3339,7 +3365,10 @@ static int _process_pvs_in_vg(struct cmd_context *cmd,
 			break;
 		log_set_report_object_name_and_id(NULL, NULL);
 	}
+	do_report_ret_code = 0;
 out:
+	if (do_report_ret_code)
+		report_log_ret_code(ret_max);
 	log_set_report_object_name_and_id(NULL, NULL);
 	log_set_report_object_group_and_group_id(NULL, NULL);
 	if (!handle_supplied)
@@ -3382,6 +3411,7 @@ static int _process_pvs_in_vgs(struct cmd_context *cmd, uint32_t read_flags,
 	int skip;
 	int notfound;
 	int already_locked;
+	int do_report_ret_code;
 
 	log_set_report_object_type(LOG_REPORT_OBJECT_TYPE_VG);
 
@@ -3405,6 +3435,7 @@ static int _process_pvs_in_vgs(struct cmd_context *cmd, uint32_t read_flags,
 
 		if (!lockd_vg(cmd, vg_name, NULL, 0, &lockd_state)) {
 			ret_max = ECMD_FAILED;
+			report_log_ret_code(ret_max);
 			continue;
 		}
 
@@ -3416,6 +3447,7 @@ static int _process_pvs_in_vgs(struct cmd_context *cmd, uint32_t read_flags,
 		if (_ignore_vg(vg, vg_name, NULL, read_flags, &skip, &notfound)) {
 			stack;
 			ret_max = ECMD_FAILED;
+			report_log_ret_code(ret_max);
 			if (!skip)
 				goto endvg;
 			/* Drop through to eliminate a clustered VG's PVs from the devices list */
@@ -3433,6 +3465,7 @@ static int _process_pvs_in_vgs(struct cmd_context *cmd, uint32_t read_flags,
 					 handle, process_single_pv);
 		if (ret != ECMD_PROCESSED)
 			stack;
+		report_log_ret_code(ret);
 		if (ret > ret_max)
 			ret_max = ret;
 
@@ -3444,12 +3477,17 @@ endvg:
 			stack;
 
 		/* Quit early when possible. */
-		if (!process_all_pvs && dm_list_empty(arg_tags) && dm_list_empty(arg_devices))
+		if (!process_all_pvs && dm_list_empty(arg_tags) && dm_list_empty(arg_devices)) {
+			do_report_ret_code = 0;
 			goto_out;
+		}
 
 		log_set_report_object_name_and_id(NULL, NULL);
 	}
+	do_report_ret_code = 0;
 out:
+	if (do_report_ret_code)
+		report_log_ret_code(ret_max);
 	log_restore_report_state(saved_log_report_state);
 	return ret_max;
 }
@@ -3695,6 +3733,7 @@ int process_each_pv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 	int whole_selected = 0;
 	int ret_max = ECMD_PROCESSED;
 	int ret;
+	int do_report_ret_code = 1;
 	struct pv_list *pvl;
 
 	log_set_report_object_type(LOG_REPORT_OBJECT_TYPE_PV);
@@ -3721,6 +3760,7 @@ int process_each_pv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 		_update_selection_result(handle, &whole_selected);
 		if (ret != ECMD_PROCESSED)
 			stack;
+		report_log_ret_code(ret);
 		if (ret > ret_max)
 			ret_max = ret;
 
@@ -3728,7 +3768,10 @@ int process_each_pv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 	}
 
 	_set_final_selection_result(handle, whole_selected);
+	do_report_ret_code = 0;
 out:
+	if (do_report_ret_code)
+		report_log_ret_code(ret_max);
 	log_restore_report_state(saved_log_report_state);
 	return ret_max;
 }


