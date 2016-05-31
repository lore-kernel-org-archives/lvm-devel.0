From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 31 May 2016 06:46:43 +0000 (UTC)
Subject: master - toollib: simplify internal selection calls for non-reporting tools
Message-ID: <20160531064643.38B9F60535@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=815f1ee26d5ee5c64493f83a78f8c074fc8c82d8
Commit:        815f1ee26d5ee5c64493f83a78f8c074fc8c82d8
Parent:        7d4d0ff606a78909041c0b734a3ceacc94a47fa0
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon May 30 16:28:47 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon May 30 16:44:18 2016 +0200

toollib: simplify internal selection calls for non-reporting tools

Some of the variables were set superfluously - we can just use existing
"struct processing_handle" which includes "struct selection_handle".
---
 lib/report/report.h |    3 +-
 tools/reporter.c    |    3 +-
 tools/toollib.c     |   70 +++++++++++++++++++-------------------------------
 tools/toollib.h     |    6 ++--
 4 files changed, 34 insertions(+), 48 deletions(-)

diff --git a/lib/report/report.h b/lib/report/report.h
index 088a1ca..8db84e0 100644
--- a/lib/report/report.h
+++ b/lib/report/report.h
@@ -60,6 +60,7 @@ struct selection_handle {
 
 struct field;
 struct report_handle;
+struct processing_handle;
 
 typedef int (*field_report_fn) (struct report_handle * dh, struct field * field,
 				const void *data);
@@ -72,7 +73,7 @@ void *report_init_for_selection(struct cmd_context *cmd, report_type_t *report_t
 				const char *selection);
 const char *report_get_field_prefix(report_type_t report_type);
 int report_for_selection(struct cmd_context *cmd,
-			 struct selection_handle *sh,
+			 struct processing_handle *parent_handle,
 			 struct physical_volume *pv,
 			 struct volume_group *vg,
 			 struct logical_volume *lv);
diff --git a/tools/reporter.c b/tools/reporter.c
index bd77513..f572d31 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -549,11 +549,12 @@ static int _report_all_in_pv(struct cmd_context *cmd, struct processing_handle *
 }
 
 int report_for_selection(struct cmd_context *cmd,
-			 struct selection_handle *sh,
+			 struct processing_handle *parent_handle,
 			 struct physical_volume *pv,
 			 struct volume_group *vg,
 			 struct logical_volume *lv)
 {
+	struct selection_handle *sh = parent_handle->selection_handle;
 	int args_are_pvs = sh->orig_report_type == PVS;
 	int do_lv_info, do_lv_seg_status;
 	struct processing_handle *handle;
diff --git a/tools/toollib.c b/tools/toollib.c
index 2f03a91..b86b8ff 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1764,74 +1764,61 @@ void destroy_processing_handle(struct cmd_context *cmd, struct processing_handle
 
 
 int select_match_vg(struct cmd_context *cmd, struct processing_handle *handle,
-		    struct volume_group *vg, int *selected)
+		    struct volume_group *vg)
 {
-	struct selection_handle *sh = handle->selection_handle;
-
-	if (!handle->internal_report_for_select) {
-		*selected = 1;
+	if (!handle->internal_report_for_select)
 		return 1;
-	}
 
-	sh->orig_report_type = VGS;
-
-	if (!report_for_selection(cmd, sh, NULL, vg, NULL)) {
+	handle->selection_handle->orig_report_type = VGS;
+	if (!report_for_selection(cmd, handle, NULL, vg, NULL)) {
 		log_error("Selection failed for VG %s.", vg->name);
 		return 0;
 	}
-
-	sh->orig_report_type = 0;
-	*selected = sh->selected;
+	handle->selection_handle->orig_report_type = 0;
 
 	return 1;
 }
 
 int select_match_lv(struct cmd_context *cmd, struct processing_handle *handle,
-		    struct volume_group *vg, struct logical_volume *lv, int *selected)
+		    struct volume_group *vg, struct logical_volume *lv)
 {
-	struct selection_handle *sh = handle->selection_handle;
-
-	if (!handle->internal_report_for_select) {
-		*selected = 1;
+	if (!handle->internal_report_for_select)
 		return 1;
-	}
 
-	sh->orig_report_type = LVS;
-
-	if (!report_for_selection(cmd, sh, NULL, vg, lv)) {
+	handle->selection_handle->orig_report_type = LVS;
+	if (!report_for_selection(cmd, handle, NULL, vg, lv)) {
 		log_error("Selection failed for LV %s.", lv->name);
 		return 0;
 	}
-
-	sh->orig_report_type = 0;
-	*selected = sh->selected;
+	handle->selection_handle->orig_report_type = 0;
 
 	return 1;
 }
 
 int select_match_pv(struct cmd_context *cmd, struct processing_handle *handle,
-		    struct volume_group *vg, struct physical_volume *pv, int *selected)
+		    struct volume_group *vg, struct physical_volume *pv)
 {
-	struct selection_handle *sh = handle->selection_handle;
-
-	if (!handle->internal_report_for_select) {
-		*selected = 1;
+	if (!handle->internal_report_for_select)
 		return 1;
-	}
 
-	sh->orig_report_type = PVS;
-
-	if (!report_for_selection(cmd, sh, pv, vg, NULL)) {
+	handle->selection_handle->orig_report_type = PVS;
+	if (!report_for_selection(cmd, handle, pv, vg, NULL)) {
 		log_error("Selection failed for PV %s.", dev_name(pv->dev));
 		return 0;
 	}
-
-	sh->orig_report_type = 0;
-	*selected = sh->selected;
+	handle->selection_handle->orig_report_type = 0;
 
 	return 1;
 }
 
+static int _select_matches(struct processing_handle *handle)
+{
+	if (!handle->internal_report_for_select)
+		return 1;
+
+	return handle->selection_handle->selected;
+}
+
 static int _process_vgnameid_list(struct cmd_context *cmd, uint32_t read_flags,
 				  struct dm_list *vgnameids_to_process,
 				  struct dm_list *arg_vgnames,
@@ -1845,7 +1832,6 @@ static int _process_vgnameid_list(struct cmd_context *cmd, uint32_t read_flags,
 	const char *vg_name;
 	const char *vg_uuid;
 	uint32_t lockd_state = 0;
-	int selected;
 	int whole_selected = 0;
 	int ret_max = ECMD_PROCESSED;
 	int ret;
@@ -1897,7 +1883,7 @@ static int _process_vgnameid_list(struct cmd_context *cmd, uint32_t read_flags,
 		if ((process_all ||
 		    (!dm_list_empty(arg_vgnames) && str_list_match_item(arg_vgnames, vg_name)) ||
 		    (!dm_list_empty(arg_tags) && str_list_match_list(arg_tags, &vg->tags, NULL))) &&
-		    select_match_vg(cmd, handle, vg, &selected) && selected) {
+		    select_match_vg(cmd, handle, vg) && _select_matches(handle)) {
 
 			log_very_verbose("Process single VG %s", vg_name);
 
@@ -2264,7 +2250,6 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 {
 	int ret_max = ECMD_PROCESSED;
 	int ret = 0;
-	int selected;
 	int whole_selected = 0;
 	int handle_supplied = handle != NULL;
 	unsigned process_lv;
@@ -2369,7 +2354,7 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 		if (!process_lv && tags_supplied && str_list_match_list(tags_in, &lvl->lv->tags, NULL))
 			process_lv = 1;
 
-		process_lv = process_lv && select_match_lv(cmd, handle, vg, lvl->lv, &selected) && selected;
+		process_lv = process_lv && select_match_lv(cmd, handle, vg, lvl->lv) && _select_matches(handle);
 
 		if (sigint_caught()) {
 			ret_max = ECMD_FAILED;
@@ -2432,7 +2417,7 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 				process_lv = 1;
 			}
 
-			process_lv = process_lv && select_match_lv(cmd, handle, vg, lvl->lv, &selected) && selected;
+			process_lv = process_lv && select_match_lv(cmd, handle, vg, lvl->lv) && _select_matches(handle);
 
 			if (sigint_caught()) {
 				ret_max = ECMD_FAILED;
@@ -3164,7 +3149,6 @@ static int _process_pvs_in_vg(struct cmd_context *cmd,
 	struct pv_list *pvl;
 	struct device_id_list *dil;
 	const char *pv_name;
-	int selected;
 	int process_pv;
 	int ret_max = ECMD_PROCESSED;
 	int ret = 0;
@@ -3203,7 +3187,7 @@ static int _process_pvs_in_vg(struct cmd_context *cmd,
 		    str_list_match_list(arg_tags, &pv->tags, NULL))
 			process_pv = 1;
 
-		process_pv = process_pv && select_match_pv(cmd, handle, vg, pv, &selected) && selected;
+		process_pv = process_pv && select_match_pv(cmd, handle, vg, pv) && _select_matches(handle);
 
 		if (process_pv) {
 			if (skip)
diff --git a/tools/toollib.h b/tools/toollib.h
index a366e68..06d0ef9 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -147,11 +147,11 @@ int init_selection_handle(struct cmd_context *cmd, struct processing_handle *han
 void destroy_processing_handle(struct cmd_context *cmd, struct processing_handle *handle);
 
 int select_match_vg(struct cmd_context *cmd, struct processing_handle *handle,
-		    struct volume_group *vg, int *selected);
+		    struct volume_group *vg);
 int select_match_lv(struct cmd_context *cmd, struct processing_handle *handle,
-		    struct volume_group *vg, struct logical_volume *lv, int *selected);
+		    struct volume_group *vg, struct logical_volume *lv);
 int select_match_pv(struct cmd_context *cmd, struct processing_handle *handle,
-		    struct volume_group *vg, struct physical_volume *pv, int *selected);
+		    struct volume_group *vg, struct physical_volume *pv);
 
 const char *extract_vgname(struct cmd_context *cmd, const char *lv_name);
 const char *skip_dev_dir(struct cmd_context *cmd, const char *vg_name,


