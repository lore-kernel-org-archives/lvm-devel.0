From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 10 Feb 2015 15:12:59 +0000 (UTC)
Subject: master - toollib: select the whole structure if at least one of its items is selected
Message-ID: <20150210151259.3F59960CFD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=de273247118a9183eb8ba6a4615699edcb49dc2d
Commit:        de273247118a9183eb8ba6a4615699edcb49dc2d
Parent:        56011918e66adf1f639436fd6781a89ad61eb8f4
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Dec 3 14:20:00 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Feb 10 16:05:32 2015 +0100

toollib: select the whole structure if at least one of its items is selected

This applies to:
  - process_each_lv_in_vg - the VG is selected only if at least one of its LVs is selected
  - process_each_segment_in_lv - the LV is selected only if at least one of its LV segments is selected
  - process_each_pv_in_vg - the VG is selected only if at least one of its PVs is selected
  - process_each_segment_in_pv - the PV is selected only if at least one of its PV segments is selected

So this patch causes the selection result to be properly propagated up to callers.
---
 tools/toollib.c |   42 ++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 42 insertions(+), 0 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index e38aab1..7d406ba 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -198,6 +198,28 @@ int ignore_vg(struct volume_group *vg, const char *vg_name, int allow_inconsiste
 }
 
 /*
+ * This functiona updates the "selected" arg only if last item processed
+ * is selected so this implements the "whole structure is selected if
+ * at least one of its items is selected".
+ */
+static void _update_selection_result(struct processing_handle *handle, int *selected)
+{
+	if (!handle || !handle->selection_handle)
+		return;
+
+	if (handle->selection_handle->selected)
+		*selected = 1;
+}
+
+static void _set_final_selection_result(struct processing_handle *handle, int selected)
+{
+	if (!handle || !handle->selection_handle)
+		return;
+
+	handle->selection_handle->selected = selected;
+}
+
+/*
  * Metadata iteration functions
  */
 int process_each_segment_in_pv(struct cmd_context *cmd,
@@ -207,6 +229,7 @@ int process_each_segment_in_pv(struct cmd_context *cmd,
 			       process_single_pvseg_fn_t process_single_pvseg)
 {
 	struct pv_segment *pvseg;
+	int whole_selected = 0;
 	int ret_max = ECMD_PROCESSED;
 	int ret;
 	struct pv_segment _free_pv_segment = { .pv = pv };
@@ -223,6 +246,7 @@ int process_each_segment_in_pv(struct cmd_context *cmd,
 				return_ECMD_FAILED;
 
 			ret = process_single_pvseg(cmd, vg, pvseg, handle);
+			_update_selection_result(handle, &whole_selected);
 			if (ret != ECMD_PROCESSED)
 				stack;
 			if (ret > ret_max)
@@ -230,6 +254,8 @@ int process_each_segment_in_pv(struct cmd_context *cmd,
 		}
 	}
 
+	/* the PV is selected if at least one PV segment is selected */
+	_set_final_selection_result(handle, whole_selected);
 	return ret_max;
 }
 
@@ -239,6 +265,7 @@ int process_each_segment_in_lv(struct cmd_context *cmd,
 			       process_single_seg_fn_t process_single_seg)
 {
 	struct lv_segment *seg;
+	int whole_selected = 0;
 	int ret_max = ECMD_PROCESSED;
 	int ret;
 
@@ -247,12 +274,15 @@ int process_each_segment_in_lv(struct cmd_context *cmd,
 			return_ECMD_FAILED;
 
 		ret = process_single_seg(cmd, seg, handle);
+		_update_selection_result(handle, &whole_selected);
 		if (ret != ECMD_PROCESSED)
 			stack;
 		if (ret > ret_max)
 			ret_max = ret;
 	}
 
+	/* the LV is selected if at least one LV segment is selected */
+	_set_final_selection_result(handle, whole_selected);
 	return ret_max;
 }
 
@@ -1643,6 +1673,7 @@ static int _process_vgnameid_list(struct cmd_context *cmd, uint32_t flags,
 	const char *vg_name;
 	const char *vg_uuid;
 	int selected;
+	int whole_selected = 0;
 	int ret_max = ECMD_PROCESSED;
 	int ret;
 	int skip;
@@ -1680,6 +1711,7 @@ static int _process_vgnameid_list(struct cmd_context *cmd, uint32_t flags,
 		    (!dm_list_empty(arg_tags) && str_list_match_list(arg_tags, &vg->tags, NULL))) &&
 		    select_match_vg(cmd, handle, vg, &selected) && selected) {
 			ret = process_single_vg(cmd, vg_name, vg, handle);
+			_update_selection_result(handle, &whole_selected);
 			if (ret != ECMD_PROCESSED)
 				stack;
 			if (ret > ret_max)
@@ -1692,6 +1724,8 @@ static int _process_vgnameid_list(struct cmd_context *cmd, uint32_t flags,
 			unlock_and_release_vg(cmd, vg, vg_name);
 	}
 
+	/* the VG is selected if at least one LV is selected */
+	_set_final_selection_result(handle, whole_selected);
 	return ret_max;
 }
 
@@ -1800,6 +1834,7 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 	int ret_max = ECMD_PROCESSED;
 	int ret = 0;
 	int selected;
+	int whole_selected = 0;
 	int handle_supplied = handle != NULL;
 	unsigned process_lv;
 	unsigned process_all = 0;
@@ -1902,6 +1937,8 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 		log_very_verbose("Processing LV %s in VG %s.", lvl->lv->name, vg->name);
 
 		ret = process_single_lv(cmd, lvl->lv, handle);
+		if (handle_supplied)
+			_update_selection_result(handle, &whole_selected);
 		if (ret != ECMD_PROCESSED)
 			stack;
 		if (ret > ret_max)
@@ -1926,6 +1963,8 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 out:
 	if (!handle_supplied)
 		destroy_processing_handle(cmd, handle, 1);
+	else
+		_set_final_selection_result(handle, whole_selected);
 	return ret_max;
 }
 
@@ -2697,6 +2736,7 @@ int process_each_pv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 			  struct processing_handle *handle,
 			  process_single_pv_fn_t process_single_pv)
 {
+	int whole_selected = 0;
 	int ret_max = ECMD_PROCESSED;
 	int ret;
 	struct pv_list *pvl;
@@ -2706,12 +2746,14 @@ int process_each_pv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 			return_ECMD_FAILED;
 
 		ret = process_single_pv(cmd, vg, pvl->pv, handle);
+		_update_selection_result(handle, &whole_selected);
 		if (ret != ECMD_PROCESSED)
 			stack;
 		if (ret > ret_max)
 			ret_max = ret;
 	}
 
+	_set_final_selection_result(handle, whole_selected);
 	return ret_max;
 }
 


