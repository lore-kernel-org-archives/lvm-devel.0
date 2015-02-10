From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 10 Feb 2015 15:13:18 +0000 (UTC)
Subject: master - select: initialize selection handle for process_each_* fns with initial report type
Message-ID: <20150210151318.84EB360CFB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7f2eebf519c039eea4d8d4f41fd44b04182093f2
Commit:        7f2eebf519c039eea4d8d4f41fd44b04182093f2
Parent:        80cca53611d3603c12db08ddc1b25bfd6b874436
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Feb 10 13:46:37 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Feb 10 16:10:17 2015 +0100

select: initialize selection handle for process_each_* fns with initial report type

This is a followup patch for previous patchset that enables selection in
process_each_* fns to fix an issue where field prefixes are not
automatically used for fields in selection criteria.

Use initial report type that matches the intention of each process_each_* functions:
- _process_pvs_in_vg - PVS
- process_each_vg - VGS
- process_each_lv and process_each_lv_in_vg - LVS

This is not normally needed for the selection handle init, BUT we would
miss the field prefix matching, e.g.

lvchange -ay -S 'name=lvol0'

The "name" above would not work if we didn't initialize reporting with
the LVS type at its start. If we pass proper init type, reporting code
can deduce the prefix automatically ("lv_name" in this case).

This report type is then changed further based on what selection criteria we
have. When doing pure selection, not report output, the final report type
is purely based on combination of this initial report type and report types
of the fields used in selection criteria.
---
 tools/pvchange.c |    2 +-
 tools/toollib.c  |   12 +++++++-----
 tools/toollib.h  |    3 ++-
 3 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/tools/pvchange.c b/tools/pvchange.c
index b164509..1788620 100644
--- a/tools/pvchange.c
+++ b/tools/pvchange.c
@@ -170,7 +170,7 @@ int pvchange(struct cmd_context *cmd, int argc, char **argv)
 	/* FIXME: use process_each_pv for pvchange. */
 
 	if (!(handle = init_processing_handle(cmd)) ||
-	    (handle->internal_report_for_select && !init_selection_handle(cmd, handle))) {
+	    (handle->internal_report_for_select && !init_selection_handle(cmd, handle, PVS))) {
 		log_error("Failed to initialize processing handle.");
 		r = ECMD_FAILED;
 		goto out;
diff --git a/tools/toollib.c b/tools/toollib.c
index 34286e3..a452676 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1594,7 +1594,8 @@ struct processing_handle *init_processing_handle(struct cmd_context *cmd)
 	return handle;
 }
 
-int init_selection_handle(struct cmd_context *cmd, struct processing_handle *handle)
+int init_selection_handle(struct cmd_context *cmd, struct processing_handle *handle,
+			  report_type_t initial_report_type)
 {
 	struct selection_handle *sh;
 
@@ -1603,6 +1604,7 @@ int init_selection_handle(struct cmd_context *cmd, struct processing_handle *han
 		return 0;
 	}
 
+	sh->report_type = initial_report_type;
 	if (!(sh->selection_rh = report_init_for_selection(cmd, &sh->report_type,
 					arg_str_value(cmd, select_ARG, NULL)))) {
 		dm_pool_free(cmd->mem, sh);
@@ -1841,7 +1843,7 @@ int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
 		goto_out;
 
 	if (handle->internal_report_for_select && !handle->selection_handle &&
-	    !init_selection_handle(cmd, handle))
+	    !init_selection_handle(cmd, handle, VGS))
 		goto_out;
 
 	ret = _process_vgnameid_list(cmd, flags, &vgnameids_to_process,
@@ -1887,7 +1889,7 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 	}
 
 	if (handle->internal_report_for_select && !handle->selection_handle &&
-	    !init_selection_handle(cmd, handle)) {
+	    !init_selection_handle(cmd, handle, LVS)) {
 		ret_max = ECMD_FAILED;
 		goto_out;
 	}
@@ -2216,7 +2218,7 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv, uint32_t fla
 		goto_out;
 
 	if (handle->internal_report_for_select && !handle->selection_handle &&
-	    !init_selection_handle(cmd, handle))
+	    !init_selection_handle(cmd, handle, LVS))
 		goto_out;
 
 	/*
@@ -2455,7 +2457,7 @@ static int _process_pvs_in_vg(struct cmd_context *cmd,
 	}
 
 	if (handle->internal_report_for_select && !handle->selection_handle &&
-	    !init_selection_handle(cmd, handle)) {
+	    !init_selection_handle(cmd, handle, PVS)) {
 		ret_max = ECMD_FAILED;
 		goto_out;
 	}
diff --git a/tools/toollib.h b/tools/toollib.h
index 4050117..3a2c5f8 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -138,7 +138,8 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 			  process_single_lv_fn_t process_single_lv);
 
 struct processing_handle *init_processing_handle(struct cmd_context *cmd);
-int init_selection_handle(struct cmd_context *cmd, struct processing_handle *handle);
+int init_selection_handle(struct cmd_context *cmd, struct processing_handle *handle,
+			  report_type_t initial_report_type);
 void destroy_processing_handle(struct cmd_context *cmd, struct processing_handle *handle,
 			       int deallocate_handle_root);
 


