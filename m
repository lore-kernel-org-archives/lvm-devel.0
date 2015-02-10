From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 10 Feb 2015 15:12:55 +0000 (UTC)
Subject: master - toollib: add init_processing_handle, init_selection_handle and destroy_processing_handle helper functions
Message-ID: <20150210151255.0277560C2E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a91bc7a19b8f439fa1d21101ad5c11d72413d4c0
Commit:        a91bc7a19b8f439fa1d21101ad5c11d72413d4c0
Parent:        c3180c4a05ea947b379e9e9bc51e50d0ca329980
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Nov 28 14:46:18 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Feb 10 16:05:27 2015 +0100

toollib: add init_processing_handle, init_selection_handle and destroy_processing_handle helper functions

The init_processing_handle, init_selection_handle and
destroy_processing_handle are helper functions that allocate and
initialize the handles used when processing items in process_each_*
and related functions.
---
 tools/toollib.c |   53 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 tools/toollib.h |    5 +++++
 2 files changed, 58 insertions(+), 0 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 13cb034..0ce3c50 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1542,6 +1542,59 @@ static int _get_vgnameids_on_system(struct cmd_context *cmd,
 	return ECMD_PROCESSED;
 }
 
+struct processing_handle *init_processing_handle(struct cmd_context *cmd)
+{
+	struct processing_handle *handle;
+
+	if (!(handle = dm_pool_zalloc(cmd->mem, sizeof(struct processing_handle)))) {
+		log_error("_init_processing_handle: failed to allocate memory for processing handle");
+		return NULL;
+	}
+
+	/*
+	 * For any reporting tool, the internal_report_for_select is reset to 0
+	 * automatically because the internal reporting/selection is simply not
+	 * needed - the reporting/selection is already a part of the code path
+	 * used there.
+	 *
+	 * *The internal report for select is only needed for non-reporting tools!*
+	 */
+	handle->internal_report_for_select = arg_is_set(cmd, select_ARG);
+
+	return handle;
+}
+
+int init_selection_handle(struct cmd_context *cmd, struct processing_handle *handle)
+{
+	struct selection_handle *sh;
+
+	if (!(sh = dm_pool_zalloc(cmd->mem, sizeof(struct selection_handle)))) {
+		log_error("_init_selection_handle: failed to allocate memory for selection handle");
+		return 0;
+	}
+
+	if (!(sh->selection_rh = report_init_for_selection(cmd, &sh->report_type,
+					arg_str_value(cmd, select_ARG, NULL)))) {
+		dm_pool_free(cmd->mem, sh);
+		return_0;
+	}
+
+	handle->selection_handle = sh;
+	return 1;
+}
+
+void destroy_processing_handle(struct cmd_context *cmd, struct processing_handle *handle,
+			       int deallocate_handle_root)
+{
+	if (handle) {
+		if (handle->selection_handle && handle->selection_handle->selection_rh)
+			dm_report_free(handle->selection_handle->selection_rh);
+		if (deallocate_handle_root)
+			dm_pool_free(cmd->mem, handle);
+	}
+}
+
+
 int select_match_vg(struct cmd_context *cmd, struct processing_handle *handle,
 		    struct volume_group *vg, int *selected)
 {
diff --git a/tools/toollib.h b/tools/toollib.h
index ead36d3..4050117 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -137,6 +137,11 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 			  int stop_on_error, struct processing_handle *handle,
 			  process_single_lv_fn_t process_single_lv);
 
+struct processing_handle *init_processing_handle(struct cmd_context *cmd);
+int init_selection_handle(struct cmd_context *cmd, struct processing_handle *handle);
+void destroy_processing_handle(struct cmd_context *cmd, struct processing_handle *handle,
+			       int deallocate_handle_root);
+
 int select_match_vg(struct cmd_context *cmd, struct processing_handle *handle,
 		    struct volume_group *vg, int *selected);
 int select_match_lv(struct cmd_context *cmd, struct processing_handle *handle,


