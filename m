From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 10 Feb 2015 15:12:50 +0000 (UTC)
Subject: master - report: add report_init_for_selection fn and modify report_object to support reporting for selection only
Message-ID: <20150210151250.BD07860093@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a64b39aef80d790dd4afe4ce8fdaa0ed1b0e2c48
Commit:        a64b39aef80d790dd4afe4ce8fdaa0ed1b0e2c48
Parent:        51d96a170314b7ce75f233d42501262805384770
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Dec 2 13:14:12 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Feb 10 16:05:25 2015 +0100

report: add report_init_for_selection fn and modify report_object to support reporting for selection only

The new "report_init_for_selection" is just a wrapper over
dm_report_init_with_selection that initializes reporting for selection
only. This means we're not going to do the actual reporting to output
for display and as such we intialize reporting as if no fields are reported
or sorted. The only fields "reported" are taken from the selection criteria
string and all such fields are marked as hidden automatically (FLD_HIDDEN flag).
These fields are used solely for selection criteria matching.

Also, modify existing report_object function that was used for reporting to
output for display. Now, it can either cause reporting to output or reporting
for selection only. The selection result is stored in struct selection_handle's
"selected" variable which can be handled further by any report_object caller.
---
 lib/report/report.c |   18 ++++++++++++++++--
 lib/report/report.h |    4 +++-
 tools/reporter.c    |   35 ++++++++++++++++++++++++-----------
 3 files changed, 43 insertions(+), 14 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index 53de714..cf3d9b6 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -2009,15 +2009,28 @@ void *report_init(struct cmd_context *cmd, const char *format, const char *keys,
 	return rh;
 }
 
+void *report_init_for_selection(struct cmd_context *cmd,
+				report_type_t *report_type,
+				const char *selection_criteria)
+{
+	return dm_report_init_with_selection(report_type, _report_types, _fields,
+					     "", DEFAULT_REP_SEPARATOR,
+					     DM_REPORT_OUTPUT_FIELD_UNQUOTED,
+					     "", selection_criteria,
+					     _report_reserved_values,
+					     cmd);
+}
+
 /*
  * Create a row of data for an object
  */
-int report_object(void *handle, const struct volume_group *vg,
+int report_object(void *handle, int selection_only, const struct volume_group *vg,
 		  const struct logical_volume *lv, const struct physical_volume *pv,
 		  const struct lv_segment *seg, const struct pv_segment *pvseg,
 		  const struct lv_with_info_and_seg_status *lvdm,
 		  const struct label *label)
 {
+	struct selection_handle *sh = selection_only ? (struct selection_handle *) handle : NULL;
 	struct device dummy_device = { .dev = 0 };
 	struct label dummy_label = { .dev = &dummy_device };
 	struct lvm_report_object obj = {
@@ -2051,7 +2064,8 @@ int report_object(void *handle, const struct volume_group *vg,
 	if (!obj.vg && pv)
 		_dummy_fid.fmt = pv->fmt;
 
-	return dm_report_object(handle, &obj);
+	return sh ? dm_report_object_is_selected(sh->selection_rh, &obj, 0, &sh->selected)
+		  : dm_report_object(handle, &obj);
 }
 
 static int _report_devtype_single(void *handle, const dev_known_type_t *devtype)
diff --git a/lib/report/report.h b/lib/report/report.h
index aef6d72..80a75fd 100644
--- a/lib/report/report.h
+++ b/lib/report/report.h
@@ -69,8 +69,10 @@ void *report_init(struct cmd_context *cmd, const char *format, const char *keys,
 		  report_type_t *report_type, const char *separator,
 		  int aligned, int buffered, int headings, int field_prefixes,
 		  int quoted, int columns_as_rows, const char *selection);
+void *report_init_for_selection(struct cmd_context *cmd, report_type_t *report_type,
+				const char *selection);
 void report_free(void *handle);
-int report_object(void *handle, const struct volume_group *vg,
+int report_object(void *handle, int selection_only, const struct volume_group *vg,
 		  const struct logical_volume *lv, const struct physical_volume *pv,
 		  const struct lv_segment *seg, const struct pv_segment *pvseg,
 		  const struct lv_with_info_and_seg_status *lvdm,
diff --git a/tools/reporter.c b/tools/reporter.c
index 3d7e5dd..3cba020 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -32,7 +32,10 @@ static int _vgs_single(struct cmd_context *cmd __attribute__((unused)),
 		       const char *vg_name, struct volume_group *vg,
 		       struct processing_handle *handle)
 {
-	if (!report_object(handle->custom_handle, vg, NULL, NULL, NULL, NULL, NULL, NULL))
+	struct selection_handle *sh = handle->selection_handle;
+
+	if (!report_object(sh ? : handle->custom_handle, sh != NULL,
+			   vg, NULL, NULL, NULL, NULL, NULL, NULL))
 		return_ECMD_FAILED;
 
 	check_current_backup(vg);
@@ -88,6 +91,7 @@ static int _do_lvs_with_info_and_status_single(struct cmd_context *cmd,
 					       int do_info, int do_status,
 					       struct processing_handle *handle)
 {
+	struct selection_handle *sh = handle->selection_handle;
 	struct lv_with_info_and_seg_status status = {
 		.seg_status.type = SEG_STATUS_NONE
 	};
@@ -96,8 +100,8 @@ static int _do_lvs_with_info_and_status_single(struct cmd_context *cmd,
 	if (!_do_info_and_status(cmd, lv, NULL, &status, do_info, do_status))
 		goto_out;
 
-	if (!report_object(handle->custom_handle, lv->vg, lv,
-			   NULL, NULL, NULL, &status, NULL))
+	if (!report_object(sh ? : handle->custom_handle, sh != NULL,
+			   lv->vg, lv, NULL, NULL, NULL, &status, NULL))
 		goto out;
 
 	r = ECMD_PROCESSED;
@@ -137,6 +141,7 @@ static int _do_segs_with_info_and_status_single(struct cmd_context *cmd,
 						int do_info, int do_status,
 						struct processing_handle *handle)
 {
+	struct selection_handle *sh = handle->selection_handle;
 	struct lv_with_info_and_seg_status status = {
 		.seg_status.type = SEG_STATUS_NONE
 	};
@@ -145,9 +150,9 @@ static int _do_segs_with_info_and_status_single(struct cmd_context *cmd,
 	if (!_do_info_and_status(cmd, seg->lv, seg, &status, do_info, do_status))
 		goto_out;
 
-	if (!report_object(handle->custom_handle, seg->lv->vg, seg->lv, NULL, seg, NULL,
-			   &status, NULL))
-		goto_out;
+	if (!report_object(sh ? : handle->custom_handle, sh != NULL,
+			   seg->lv->vg, seg->lv, NULL, seg, NULL, &status, NULL))
+	goto_out;
 
 	r = ECMD_PROCESSED;
 out:
@@ -224,6 +229,7 @@ static int _do_pvsegs_sub_single(struct cmd_context *cmd,
 				 int do_status,
 				 struct processing_handle *handle)
 {
+	struct selection_handle *sh = handle->selection_handle;
 	int ret = ECMD_PROCESSED;
 	struct lv_segment *seg = pvseg->lvseg;
 
@@ -268,9 +274,10 @@ static int _do_pvsegs_sub_single(struct cmd_context *cmd,
 	if (seg && !_do_info_and_status(cmd, seg->lv, seg, &status, do_info, do_status))
 		goto_out;
 
-	if (!report_object(handle->custom_handle, vg, seg ? seg->lv : &_free_logical_volume,
-			   pvseg->pv, seg ? : &_free_lv_segment, pvseg, &status,
-			   pv_label(pvseg->pv))) {
+	if (!report_object(sh ? : handle->custom_handle, sh != NULL,
+			   vg, seg ? seg->lv : &_free_logical_volume,
+			   pvseg->pv, seg ? : &_free_lv_segment, pvseg,
+			   &status, pv_label(pvseg->pv))) {
 		ret = ECMD_FAILED;
 		goto_out;
 	}
@@ -350,7 +357,10 @@ static int _pvs_single(struct cmd_context *cmd, struct volume_group *vg,
 		       struct physical_volume *pv,
 		       struct processing_handle *handle)
 {
-	if (!report_object(handle->custom_handle, vg, NULL, pv, NULL, NULL, NULL, NULL))
+	struct selection_handle *sh = handle->selection_handle;
+
+	if (!report_object(sh ? : handle->custom_handle, sh != NULL,
+			   vg, NULL, pv, NULL, NULL, NULL, NULL))
 		return_ECMD_FAILED;
 
 	return ECMD_PROCESSED;
@@ -359,7 +369,10 @@ static int _pvs_single(struct cmd_context *cmd, struct volume_group *vg,
 static int _label_single(struct cmd_context *cmd, struct label *label,
 		         struct processing_handle *handle)
 {
-	if (!report_object(handle->custom_handle, NULL, NULL, NULL, NULL, NULL, NULL, label))
+	struct selection_handle *sh = handle->selection_handle;
+
+	if (!report_object(sh ? : handle->custom_handle, sh != NULL,
+			   NULL, NULL, NULL, NULL, NULL, NULL, label))
 		return_ECMD_FAILED;
 
 	return ECMD_PROCESSED;


