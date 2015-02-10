From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 10 Feb 2015 15:12:48 +0000 (UTC)
Subject: master - toollib: replace void *handle with struct processing_handle for use in processing functions (process_each_*/process_single_* and related)
Message-ID: <20150210151248.A31D560D19@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=51d96a170314b7ce75f233d42501262805384770
Commit:        51d96a170314b7ce75f233d42501262805384770
Parent:        2a19866a74c5101d262586ad0e08317e9a514977
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Nov 27 15:02:13 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Feb 10 16:05:24 2015 +0100

toollib: replace void *handle with struct processing_handle for use in processing functions (process_each_*/process_single_* and related)

This patch replaces "void *handle" with "struct processing_handle *handle"
in process_each_*, process_single_* and related functions.

The struct processing_handle consists of two handles inside now:

  - the "struct selection_handle *selection_handle" used for
    applying selection criteria while processing process_each_*,
    process_single_* and related functions (patches using this
    logic will follow)

  - the "void* custom_handle" (this is actually the original handle
    used before this patch - a pointer to custom data passed into
    process_each_*, process_single_* and related functions).
---
 lib/report/report.h |   25 ++++++++++++
 tools/lvchange.c    |    2 +-
 tools/lvconvert.c   |   10 +++-
 tools/lvdisplay.c   |    4 +-
 tools/lvscan.c      |    2 +-
 tools/polldaemon.c  |   10 +++-
 tools/pvdisplay.c   |    5 +-
 tools/pvresize.c    |    9 +++-
 tools/reporter.c    |  102 +++++++++++++++++++++++++++------------------------
 tools/toollib.c     |   33 +++++++++-------
 tools/toollib.h     |   88 ++++++++++++++++++++++++++++++++++++-------
 tools/vgcfgbackup.c |    9 +++-
 tools/vgchange.c    |    2 +-
 tools/vgck.c        |    2 +-
 tools/vgconvert.c   |    2 +-
 tools/vgdisplay.c   |    2 +-
 tools/vgexport.c    |    2 +-
 tools/vgimport.c    |    2 +-
 tools/vgmknodes.c   |    2 +-
 tools/vgreduce.c    |    2 +-
 tools/vgremove.c    |    2 +-
 tools/vgscan.c      |    2 +-
 22 files changed, 214 insertions(+), 105 deletions(-)

diff --git a/lib/report/report.h b/lib/report/report.h
index 563f684e18..aef6d72 100644
--- a/lib/report/report.h
+++ b/lib/report/report.h
@@ -34,6 +34,31 @@ typedef enum {
 	DEVTYPES	= 1024
 } report_type_t;
 
+/*
+ * The "struct selection_handle" is used only for selection
+ * of items that should be processed further (not for display!).
+ *
+ * It consists of selection reporting handle "selection_rh"
+ * used for the selection itself (not for display on output!).
+ * The items are reported directly in memory to a buffer and
+ * then compared against selection criteria. Once we know the
+ * result of the selection, the buffer is dropped!
+ *
+ * The "orig_report_type" is the original requested report type.
+ * The "report_type" is the reporting type actually used which
+ * also counts with report types of the fields used in selection
+ * criteria.
+ *
+ * The "selected" variable is used for propagating the result
+ * of the selection.
+ */
+struct selection_handle {
+	struct dm_report *selection_rh;
+	report_type_t orig_report_type;
+	report_type_t report_type;
+	int selected;
+};
+
 struct field;
 struct report_handle;
 
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 8a175e0..17e977f 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -848,7 +848,7 @@ static int lvchange_activation_skip(struct logical_volume *lv)
 
 
 static int _lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
-			   void *handle __attribute__((unused)))
+			   struct processing_handle *handle __attribute__((unused)))
 {
 	int doit = 0, docmds = 0;
 	struct logical_volume *origin;
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 20f017a..f9f666d 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -3486,9 +3486,9 @@ out:
 }
 
 static int _lvconvert_merge_single(struct cmd_context *cmd, struct logical_volume *lv,
-				  void *handle)
+				   struct processing_handle *handle)
 {
-	struct lvconvert_params *lp = handle;
+	struct lvconvert_params *lp = (struct lvconvert_params *) handle->custom_handle;
 	const char *vg_name;
 	struct logical_volume *refreshed_lv;
 	int ret;
@@ -3542,13 +3542,17 @@ int lvconvert(struct cmd_context * cmd, int argc, char **argv)
 		.target_attr = ~0,
 	};
 
+	struct processing_handle handle = { .internal_report_for_select = 1,
+					    .selection_handle = NULL,
+					    .custom_handle = &lp };
+
 	if (!_read_params(cmd, argc, argv, &lp)) {
 		stack;
 		return EINVALID_CMD_LINE;
 	}
 
 	if (lp.merge)
-		return process_each_lv(cmd, argc, argv, READ_FOR_UPDATE, &lp,
+		return process_each_lv(cmd, argc, argv, READ_FOR_UPDATE, &handle,
 				       &_lvconvert_merge_single);
 
 	return lvconvert_single(cmd, &lp);
diff --git a/tools/lvdisplay.c b/tools/lvdisplay.c
index fb3420a..6b1540f 100644
--- a/tools/lvdisplay.c
+++ b/tools/lvdisplay.c
@@ -16,7 +16,7 @@
 #include "tools.h"
 
 static int _lvdisplay_single(struct cmd_context *cmd, struct logical_volume *lv,
-			     void *handle)
+			     struct processing_handle *handle __attribute__ ((unused)))
 {
 	if (!arg_count(cmd, all_ARG) && !lv_is_visible(lv))
 		return ECMD_PROCESSED;
@@ -24,7 +24,7 @@ static int _lvdisplay_single(struct cmd_context *cmd, struct logical_volume *lv,
 	if (arg_count(cmd, colon_ARG))
 		lvdisplay_colons(lv);
 	else {
-		lvdisplay_full(cmd, lv, handle);
+		lvdisplay_full(cmd, lv, NULL);
 		if (arg_count(cmd, maps_ARG))
 			lvdisplay_segments(lv);
 	}
diff --git a/tools/lvscan.c b/tools/lvscan.c
index 2d7be07..fa9d976 100644
--- a/tools/lvscan.c
+++ b/tools/lvscan.c
@@ -48,7 +48,7 @@ static int _lvscan_single_lvmetad(struct cmd_context *cmd, struct logical_volume
 }
 
 static int lvscan_single(struct cmd_context *cmd, struct logical_volume *lv,
-			 void *handle __attribute__((unused)))
+			 struct processing_handle *handle __attribute__((unused)))
 {
 	struct lvinfo info;
 	int inkernel, snap_active = 1;
diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index 8d5c6ba..3eb9b17 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -189,9 +189,9 @@ static int _wait_for_single_lv(struct cmd_context *cmd, const char *name, const
 }
 
 static int _poll_vg(struct cmd_context *cmd, const char *vgname,
-		    struct volume_group *vg, void *handle)
+		    struct volume_group *vg, struct processing_handle *handle)
 {
-	struct daemon_parms *parms = (struct daemon_parms *) handle;
+	struct daemon_parms *parms = (struct daemon_parms *) handle->custom_handle;
 	struct lv_list *lvl;
 	struct logical_volume *lv;
 	const char *name;
@@ -229,9 +229,13 @@ static int _poll_vg(struct cmd_context *cmd, const char *vgname,
 static void _poll_for_all_vgs(struct cmd_context *cmd,
 			      struct daemon_parms *parms)
 {
+	struct processing_handle handle = { .internal_report_for_select = 1,
+					    .selection_handle = NULL,
+					    .custom_handle = parms };
+
 	while (1) {
 		parms->outstanding_count = 0;
-		process_each_vg(cmd, 0, NULL, READ_FOR_UPDATE, parms, _poll_vg);
+		process_each_vg(cmd, 0, NULL, READ_FOR_UPDATE, &handle, _poll_vg);
 		if (!parms->outstanding_count)
 			break;
 		sleep(parms->interval);
diff --git a/tools/pvdisplay.c b/tools/pvdisplay.c
index 50522d9..94a3bbf 100644
--- a/tools/pvdisplay.c
+++ b/tools/pvdisplay.c
@@ -17,7 +17,8 @@
 
 static int _pvdisplay_single(struct cmd_context *cmd,
 			     struct volume_group *vg,
-			     struct physical_volume *pv, void *handle)
+			     struct physical_volume *pv,
+			     struct processing_handle *handle __attribute__((unused)))
 {
 	const char *pv_name = pv_dev_name(pv);
 	int ret = ECMD_PROCESSED;
@@ -48,7 +49,7 @@ static int _pvdisplay_single(struct cmd_context *cmd,
 		goto out;
 	}
 
-	pvdisplay_full(cmd, pv, handle);
+	pvdisplay_full(cmd, pv, NULL);
 
 	if (arg_count(cmd, maps_ARG))
 		pvdisplay_segments(pv);
diff --git a/tools/pvresize.c b/tools/pvresize.c
index 631e63e..a2f6b8b 100644
--- a/tools/pvresize.c
+++ b/tools/pvresize.c
@@ -26,9 +26,9 @@ struct pvresize_params {
 static int _pvresize_single(struct cmd_context *cmd,
 			    struct volume_group *vg,
 			    struct physical_volume *pv,
-			    void *handle)
+			    struct processing_handle *handle)
 {
-	struct pvresize_params *params = (struct pvresize_params *) handle;
+	struct pvresize_params *params = (struct pvresize_params *) handle->custom_handle;
 
 	if (!params) {
 		log_error(INTERNAL_ERROR "Invalid resize params.");
@@ -47,6 +47,9 @@ static int _pvresize_single(struct cmd_context *cmd,
 int pvresize(struct cmd_context *cmd, int argc, char **argv)
 {
 	struct pvresize_params params;
+	struct processing_handle handle = { .internal_report_for_select = 1,
+					    .selection_handle = NULL,
+					    .custom_handle = &params };
 	int ret;
 
 	if (!argc) {
@@ -65,7 +68,7 @@ int pvresize(struct cmd_context *cmd, int argc, char **argv)
 	params.done = 0;
 	params.total = 0;
 
-	ret = process_each_pv(cmd, argc, argv, NULL, READ_FOR_UPDATE, &params,
+	ret = process_each_pv(cmd, argc, argv, NULL, READ_FOR_UPDATE, &handle,
 			      _pvresize_single);
 
 	log_print_unless_silent("%d physical volume(s) resized / %d physical volume(s) "
diff --git a/tools/reporter.c b/tools/reporter.c
index 7517ac5..3d7e5dd 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -16,12 +16,13 @@
 #include "tools.h"
 #include "report.h"
 
-static int _process_each_devtype(struct cmd_context *cmd, int argc, void *handle)
+static int _process_each_devtype(struct cmd_context *cmd, int argc,
+				 struct processing_handle *handle)
 {
 	if (argc)
 		log_warn("WARNING: devtypes currently ignores command line arguments.");
 
-	if (!report_devtypes(handle))
+	if (!report_devtypes(handle->custom_handle))
 		return_ECMD_FAILED;
 
 	return ECMD_PROCESSED;
@@ -29,9 +30,9 @@ static int _process_each_devtype(struct cmd_context *cmd, int argc, void *handle
 
 static int _vgs_single(struct cmd_context *cmd __attribute__((unused)),
 		       const char *vg_name, struct volume_group *vg,
-		       void *handle)
+		       struct processing_handle *handle)
 {
-	if (!report_object(handle, vg, NULL, NULL, NULL, NULL, NULL, NULL))
+	if (!report_object(handle->custom_handle, vg, NULL, NULL, NULL, NULL, NULL, NULL))
 		return_ECMD_FAILED;
 
 	check_current_backup(vg);
@@ -85,7 +86,7 @@ static int _do_info_and_status(struct cmd_context *cmd,
 static int _do_lvs_with_info_and_status_single(struct cmd_context *cmd,
 					       const struct logical_volume *lv,
 					       int do_info, int do_status,
-					       void *handle)
+					       struct processing_handle *handle)
 {
 	struct lv_with_info_and_seg_status status = {
 		.seg_status.type = SEG_STATUS_NONE
@@ -95,9 +96,9 @@ static int _do_lvs_with_info_and_status_single(struct cmd_context *cmd,
 	if (!_do_info_and_status(cmd, lv, NULL, &status, do_info, do_status))
 		goto_out;
 
-	if (!report_object(handle, lv->vg, lv, NULL, NULL, NULL,
-			   &status, NULL))
-		goto_out;
+	if (!report_object(handle->custom_handle, lv->vg, lv,
+			   NULL, NULL, NULL, &status, NULL))
+		goto out;
 
 	r = ECMD_PROCESSED;
 out:
@@ -108,25 +109,25 @@ out:
 }
 
 static int _lvs_single(struct cmd_context *cmd, struct logical_volume *lv,
-		       void *handle)
+		       struct processing_handle *handle)
 {
 	return _do_lvs_with_info_and_status_single(cmd, lv, 0, 0, handle);
 }
 
 static int _lvs_with_info_single(struct cmd_context *cmd, struct logical_volume *lv,
-				 void *handle)
+				 struct processing_handle *handle)
 {
 	return _do_lvs_with_info_and_status_single(cmd, lv, 1, 0, handle);
 }
 
 static int _lvs_with_status_single(struct cmd_context *cmd, struct logical_volume *lv,
-				   void *handle)
+				   struct processing_handle *handle)
 {
 	return _do_lvs_with_info_and_status_single(cmd, lv, 0, 1, handle);
 }
 
 static int _lvs_with_info_and_status_single(struct cmd_context *cmd, struct logical_volume *lv,
-					    void *handle)
+					    struct processing_handle *handle)
 {
 	return _do_lvs_with_info_and_status_single(cmd, lv, 1, 1, handle);
 }
@@ -134,7 +135,7 @@ static int _lvs_with_info_and_status_single(struct cmd_context *cmd, struct logi
 static int _do_segs_with_info_and_status_single(struct cmd_context *cmd,
 						const struct lv_segment *seg,
 						int do_info, int do_status,
-						void *handle)
+						struct processing_handle *handle)
 {
 	struct lv_with_info_and_seg_status status = {
 		.seg_status.type = SEG_STATUS_NONE
@@ -144,7 +145,7 @@ static int _do_segs_with_info_and_status_single(struct cmd_context *cmd,
 	if (!_do_info_and_status(cmd, seg->lv, seg, &status, do_info, do_status))
 		goto_out;
 
-	if (!report_object(handle, seg->lv->vg, seg->lv, NULL, seg, NULL,
+	if (!report_object(handle->custom_handle, seg->lv->vg, seg->lv, NULL, seg, NULL,
 			   &status, NULL))
 		goto_out;
 
@@ -157,31 +158,31 @@ out:
 }
 
 static int _segs_single(struct cmd_context *cmd, struct lv_segment *seg,
-			void *handle)
+			struct processing_handle *handle)
 {
 	return _do_segs_with_info_and_status_single(cmd, seg, 0, 0, handle);
 }
 
 static int _segs_with_info_single(struct cmd_context *cmd, struct lv_segment *seg,
-				  void *handle)
+				  struct processing_handle *handle)
 {
 	return _do_segs_with_info_and_status_single(cmd, seg, 1, 0, handle);
 }
 
 static int _segs_with_status_single(struct cmd_context *cmd, struct lv_segment *seg,
-				    void *handle)
+				    struct processing_handle *handle)
 {
 	return _do_segs_with_info_and_status_single(cmd, seg, 0, 1, handle);
 }
 
 static int _segs_with_info_and_status_single(struct cmd_context *cmd, struct lv_segment *seg,
-					     void *handle)
+					     struct processing_handle *handle)
 {
 	return _do_segs_with_info_and_status_single(cmd, seg, 1, 1, handle);
 }
 
 static int _lvsegs_single(struct cmd_context *cmd, struct logical_volume *lv,
-			  void *handle)
+			  struct processing_handle *handle)
 {
 	if (!arg_count(cmd, all_ARG) && !lv_is_visible(lv))
 		return ECMD_PROCESSED;
@@ -190,7 +191,7 @@ static int _lvsegs_single(struct cmd_context *cmd, struct logical_volume *lv,
 }
 
 static int _lvsegs_with_info_single(struct cmd_context *cmd, struct logical_volume *lv,
-				    void *handle)
+				    struct processing_handle *handle)
 {
 	if (!arg_count(cmd, all_ARG) && !lv_is_visible(lv))
 		return ECMD_PROCESSED;
@@ -199,7 +200,7 @@ static int _lvsegs_with_info_single(struct cmd_context *cmd, struct logical_volu
 }
 
 static int _lvsegs_with_status_single(struct cmd_context *cmd, struct logical_volume *lv,
-				      void *handle)
+				      struct processing_handle *handle)
 {
 	if (!arg_count(cmd, all_ARG) && !lv_is_visible(lv))
 		return ECMD_PROCESSED;
@@ -208,7 +209,7 @@ static int _lvsegs_with_status_single(struct cmd_context *cmd, struct logical_vo
 }
 
 static int _lvsegs_with_info_and_status_single(struct cmd_context *cmd, struct logical_volume *lv,
-					       void *handle)
+					       struct processing_handle *handle)
 {
 	if (!arg_count(cmd, all_ARG) && !lv_is_visible(lv))
 		return ECMD_PROCESSED;
@@ -221,7 +222,7 @@ static int _do_pvsegs_sub_single(struct cmd_context *cmd,
 				 struct pv_segment *pvseg,
 				 int do_info,
 				 int do_status,
-				 void *handle)
+				 struct processing_handle *handle)
 {
 	int ret = ECMD_PROCESSED;
 	struct lv_segment *seg = pvseg->lvseg;
@@ -267,8 +268,8 @@ static int _do_pvsegs_sub_single(struct cmd_context *cmd,
 	if (seg && !_do_info_and_status(cmd, seg->lv, seg, &status, do_info, do_status))
 		goto_out;
 
-	if (!report_object(handle, vg, seg ? seg->lv : &_free_logical_volume, pvseg->pv,
-			   seg ? : &_free_lv_segment, pvseg, &status,
+	if (!report_object(handle->custom_handle, vg, seg ? seg->lv : &_free_logical_volume,
+			   pvseg->pv, seg ? : &_free_lv_segment, pvseg, &status,
 			   pv_label(pvseg->pv))) {
 		ret = ECMD_FAILED;
 		goto_out;
@@ -284,7 +285,7 @@ static int _do_pvsegs_sub_single(struct cmd_context *cmd,
 static int _pvsegs_sub_single(struct cmd_context *cmd,
 			      struct volume_group *vg,
 			      struct pv_segment *pvseg,
-			      void *handle)
+			      struct processing_handle *handle)
 {
 	return _do_pvsegs_sub_single(cmd, vg, pvseg, 0, 0, handle);
 }
@@ -292,7 +293,7 @@ static int _pvsegs_sub_single(struct cmd_context *cmd,
 static int _pvsegs_with_lv_info_sub_single(struct cmd_context *cmd,
 					   struct volume_group *vg,
 					   struct pv_segment *pvseg,
-					   void *handle)
+					   struct processing_handle *handle)
 {
 	return _do_pvsegs_sub_single(cmd, vg, pvseg, 1, 0, handle);
 }
@@ -300,7 +301,7 @@ static int _pvsegs_with_lv_info_sub_single(struct cmd_context *cmd,
 static int _pvsegs_with_lv_status_sub_single(struct cmd_context *cmd,
 					     struct volume_group *vg,
 					     struct pv_segment *pvseg,
-					     void *handle)
+					     struct processing_handle *handle)
 {
 	return _do_pvsegs_sub_single(cmd, vg, pvseg, 0, 1, handle);
 }
@@ -308,7 +309,7 @@ static int _pvsegs_with_lv_status_sub_single(struct cmd_context *cmd,
 static int _pvsegs_with_lv_info_and_status_sub_single(struct cmd_context *cmd,
 						      struct volume_group *vg,
 						      struct pv_segment *pvseg,
-						      void *handle)
+						      struct processing_handle *handle)
 {
 	return _do_pvsegs_sub_single(cmd, vg, pvseg, 1, 1, handle);
 }
@@ -316,7 +317,7 @@ static int _pvsegs_with_lv_info_and_status_sub_single(struct cmd_context *cmd,
 static int _pvsegs_single(struct cmd_context *cmd,
 			  struct volume_group *vg,
 			  struct physical_volume *pv,
-			  void *handle)
+			  struct processing_handle *handle)
 {
 	return process_each_segment_in_pv(cmd, vg, pv, handle, _pvsegs_sub_single);
 }
@@ -324,7 +325,7 @@ static int _pvsegs_single(struct cmd_context *cmd,
 static int _pvsegs_with_lv_info_single(struct cmd_context *cmd,
 				       struct volume_group *vg,
 				       struct physical_volume *pv,
-				       void *handle)
+				       struct processing_handle *handle)
 {
 	return process_each_segment_in_pv(cmd, vg, pv, handle, _pvsegs_with_lv_info_sub_single);
 }
@@ -332,7 +333,7 @@ static int _pvsegs_with_lv_info_single(struct cmd_context *cmd,
 static int _pvsegs_with_lv_status_single(struct cmd_context *cmd,
 					 struct volume_group *vg,
 					 struct physical_volume *pv,
-					 void *handle)
+					 struct processing_handle *handle)
 {
 	return process_each_segment_in_pv(cmd, vg, pv, handle, _pvsegs_with_lv_status_sub_single);
 }
@@ -340,24 +341,25 @@ static int _pvsegs_with_lv_status_single(struct cmd_context *cmd,
 static int _pvsegs_with_lv_info_and_status_single(struct cmd_context *cmd,
 						  struct volume_group *vg,
 						  struct physical_volume *pv,
-						  void *handle)
+						  struct processing_handle *handle)
 {
 	return process_each_segment_in_pv(cmd, vg, pv, handle, _pvsegs_with_lv_info_and_status_sub_single);
 }
 
 static int _pvs_single(struct cmd_context *cmd, struct volume_group *vg,
-		       struct physical_volume *pv, void *handle)
+		       struct physical_volume *pv,
+		       struct processing_handle *handle)
 {
-	if (!report_object(handle, vg, NULL, pv, NULL, NULL, NULL, NULL))
+	if (!report_object(handle->custom_handle, vg, NULL, pv, NULL, NULL, NULL, NULL))
 		return_ECMD_FAILED;
 
 	return ECMD_PROCESSED;
 }
 
 static int _label_single(struct cmd_context *cmd, struct label *label,
-		         void *handle)
+		         struct processing_handle *handle)
 {
-	if (!report_object(handle, NULL, NULL, NULL, NULL, NULL, NULL, label))
+	if (!report_object(handle->custom_handle, NULL, NULL, NULL, NULL, NULL, NULL, label))
 		return_ECMD_FAILED;
 
 	return ECMD_PROCESSED;
@@ -365,7 +367,7 @@ static int _label_single(struct cmd_context *cmd, struct label *label,
 
 static int _pvs_in_vg(struct cmd_context *cmd, const char *vg_name,
 		      struct volume_group *vg,
-		      void *handle)
+		      struct processing_handle *handle)
 {
 	int skip;
 
@@ -380,7 +382,7 @@ static int _pvs_in_vg(struct cmd_context *cmd, const char *vg_name,
 
 static int _pvsegs_in_vg(struct cmd_context *cmd, const char *vg_name,
 			 struct volume_group *vg,
-			 void *handle)
+			 struct processing_handle *handle)
 {
 	int skip;
 
@@ -397,6 +399,7 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 		   report_type_t report_type)
 {
 	void *report_handle;
+	struct processing_handle handle = {0};
 	const char *opts;
 	char *str;
 	const char *keys = NULL, *options = NULL, *selection = NULL, *separator;
@@ -565,9 +568,12 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 		}
 	}
 
+	handle.internal_report_for_select = 0;
+	handle.custom_handle = report_handle;
+
 	switch (report_type) {
 	case DEVTYPES:
-		r = _process_each_devtype(cmd, argc, report_handle);
+		r = _process_each_devtype(cmd, argc, &handle);
 		break;
 	case LVSINFO:
 		/* fall through */
@@ -576,7 +582,7 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 	case LVSINFOSTATUS:
 		/* fall through */
 	case LVS:
-		r = process_each_lv(cmd, argc, argv, 0, report_handle,
+		r = process_each_lv(cmd, argc, argv, 0, &handle,
 				    lv_info_needed && !lv_segment_status_needed ? &_lvs_with_info_single :
 				    !lv_info_needed && lv_segment_status_needed ? &_lvs_with_status_single :
 				    lv_info_needed && lv_segment_status_needed ? &_lvs_with_info_and_status_single :
@@ -584,24 +590,24 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 		break;
 	case VGS:
 		r = process_each_vg(cmd, argc, argv, 0,
-				    report_handle, &_vgs_single);
+				    &handle, &_vgs_single);
 		break;
 	case LABEL:
 		r = process_each_label(cmd, argc, argv,
-				       report_handle, &_label_single);
+				       &handle, &_label_single);
 		break;
 	case PVS:
 		if (args_are_pvs)
 			r = process_each_pv(cmd, argc, argv, NULL, 0,
-					    report_handle, &_pvs_single);
+					    &handle, &_pvs_single);
 		else
 			r = process_each_vg(cmd, argc, argv, 0,
-					    report_handle, &_pvs_in_vg);
+					    &handle, &_pvs_in_vg);
 		break;
 	case SEGSSTATUS:
 		/* fall through */
 	case SEGS:
-		r = process_each_lv(cmd, argc, argv, 0, report_handle,
+		r = process_each_lv(cmd, argc, argv, 0, &handle,
 				    lv_info_needed && !lv_segment_status_needed ? &_lvsegs_with_info_single :
 				    !lv_info_needed && lv_segment_status_needed ? &_lvsegs_with_status_single :
 				    lv_info_needed && lv_segment_status_needed ? &_lvsegs_with_info_and_status_single :
@@ -610,14 +616,14 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 	case PVSEGS:
 		if (args_are_pvs)
 			r = process_each_pv(cmd, argc, argv, NULL, 0,
-					    report_handle,
+					    &handle,
 					    lv_info_needed && !lv_segment_status_needed ? &_pvsegs_with_lv_info_single :
 					    !lv_info_needed && lv_segment_status_needed ? &_pvsegs_with_lv_status_single :
 					    lv_info_needed && lv_segment_status_needed ? &_pvsegs_with_lv_info_and_status_single :
 											 &_pvsegs_single);
 		else
 			r = process_each_vg(cmd, argc, argv, 0,
-					    report_handle, &_pvsegs_in_vg);
+					    &handle, &_pvsegs_in_vg);
 		break;
 	}
 
diff --git a/tools/toollib.c b/tools/toollib.c
index c634b17..759769e 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -203,7 +203,7 @@ int ignore_vg(struct volume_group *vg, const char *vg_name, int allow_inconsiste
 int process_each_segment_in_pv(struct cmd_context *cmd,
 			       struct volume_group *vg,
 			       struct physical_volume *pv,
-			       void *handle,
+			       struct processing_handle *handle,
 			       process_single_pvseg_fn_t process_single_pvseg)
 {
 	struct pv_segment *pvseg;
@@ -235,7 +235,7 @@ int process_each_segment_in_pv(struct cmd_context *cmd,
 
 int process_each_segment_in_lv(struct cmd_context *cmd,
 			       struct logical_volume *lv,
-			       void *handle,
+			       struct processing_handle *handle,
 			       process_single_seg_fn_t process_single_seg)
 {
 	struct lv_segment *seg;
@@ -1236,7 +1236,8 @@ int change_tag(struct cmd_context *cmd, struct volume_group *vg,
 	return 1;
 }
 
-int process_each_label(struct cmd_context *cmd, int argc, char **argv, void *handle,
+int process_each_label(struct cmd_context *cmd, int argc, char **argv,
+		       struct processing_handle *handle,
 		       process_single_label_fn_t process_single_label)
 {
 	struct label *label;
@@ -1564,7 +1565,8 @@ int select_match_pv(struct cmd_context *cmd, struct volume_group *vg,
 static int _process_vgnameid_list(struct cmd_context *cmd, uint32_t flags,
 				  struct dm_list *vgnameids_to_process,
 				  struct dm_list *arg_vgnames,
-				  struct dm_list *arg_tags, void *handle,
+				  struct dm_list *arg_tags,
+				  struct processing_handle *handle,
 				  process_single_vg_fn_t process_single_vg)
 {
 	struct volume_group *vg;
@@ -1657,7 +1659,7 @@ static int _copy_str_to_vgnameid_list(struct cmd_context *cmd, struct dm_list *s
  * Call process_single_vg() for each VG selected by the command line arguments.
  */
 int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
-		    uint32_t flags, void *handle,
+		    uint32_t flags, struct processing_handle *handle,
 		    process_single_vg_fn_t process_single_vg)
 {
 	struct dm_list arg_tags;		/* str_list */
@@ -1716,7 +1718,8 @@ int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
 int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 			  struct dm_list *arg_lvnames, const struct dm_list *tags_in,
 			  int stop_on_error,
-			  void *handle, process_single_lv_fn_t process_single_lv)
+			  struct processing_handle *handle,
+			  process_single_lv_fn_t process_single_lv)
 {
 	int ret_max = ECMD_PROCESSED;
 	int ret = 0;
@@ -1939,7 +1942,7 @@ static int _process_lv_vgnameid_list(struct cmd_context *cmd, uint32_t flags,
 				     struct dm_list *arg_vgnames,
 				     struct dm_list *arg_lvnames,
 				     struct dm_list *arg_tags,
-				     void *handle,
+				     struct processing_handle *handle,
 				     process_single_lv_fn_t process_single_lv)
 {
 	struct volume_group *vg;
@@ -2023,7 +2026,7 @@ static int _process_lv_vgnameid_list(struct cmd_context *cmd, uint32_t flags,
  * Call process_single_lv() for each LV selected by the command line arguments.
  */
 int process_each_lv(struct cmd_context *cmd, int argc, char **argv, uint32_t flags,
-		    void *handle, process_single_lv_fn_t process_single_lv)
+		    struct processing_handle *handle, process_single_lv_fn_t process_single_lv)
 {
 	struct dm_list arg_tags;		/* str_list */
 	struct dm_list arg_vgnames;		/* str_list */
@@ -2219,7 +2222,8 @@ static struct device_id_list *_device_list_find_pvid(struct dm_list *devices, st
 }
 
 static int _process_device_list(struct cmd_context *cmd, struct dm_list *all_devices,
-				void *handle, process_single_pv_fn_t process_single_pv)
+				struct processing_handle *handle,
+				process_single_pv_fn_t process_single_pv)
 {
 	struct physical_volume pv_dummy;
 	struct physical_volume *pv;
@@ -2260,7 +2264,7 @@ static int _process_pvs_in_vg(struct cmd_context *cmd,
 			      int process_all_pvs,
 			      int process_all_devices,
 			      int skip,
-			      void *handle,
+			      struct processing_handle *handle,
 			      process_single_pv_fn_t process_single_pv)
 {
 	struct physical_volume *pv;
@@ -2423,7 +2427,7 @@ static int _process_pvs_in_vgs(struct cmd_context *cmd, uint32_t flags,
 			       struct dm_list *arg_tags,
 			       int process_all_pvs,
 			       int process_all_devices,
-			       void *handle,
+			       struct processing_handle *handle,
 			       process_single_pv_fn_t process_single_pv)
 {
 	struct volume_group *vg;
@@ -2480,7 +2484,7 @@ int process_each_pv(struct cmd_context *cmd,
 		    int argc, char **argv,
 		    const char *only_this_vgname,
 		    uint32_t flags,
-		    void *handle,
+		    struct processing_handle *handle,
 		    process_single_pv_fn_t process_single_pv)
 {
 	struct dm_list arg_tags;	/* str_list */
@@ -2570,7 +2574,8 @@ out:
 }
 
 int process_each_pv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
-			  void *handle, process_single_pv_fn_t process_single_pv)
+			  struct processing_handle *handle,
+			  process_single_pv_fn_t process_single_pv)
 {
 	int ret_max = ECMD_PROCESSED;
 	int ret;
@@ -2591,7 +2596,7 @@ int process_each_pv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 }
 
 int lvremove_single(struct cmd_context *cmd, struct logical_volume *lv,
-		    void *handle __attribute__((unused)))
+		    struct processing_handle *handle __attribute__((unused)))
 {
 	/*
 	 * Single force is equivalent to single --yes
diff --git a/tools/toollib.h b/tools/toollib.h
index 56259fb..cc86227 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -17,66 +17,124 @@
 #define _LVM_TOOLLIB_H
 
 #include "metadata-exported.h"
+#include "report.h"
 
 int become_daemon(struct cmd_context *cmd, int skip_lvm);
 
 int ignore_vg(struct volume_group *vg, const char *vg_name, int allow_inconsistent, int *skip);
 
+/*
+ * The "struct processing_handle" is used as a handle for processing
+ * functions (process_each_* and related).
+ *
+ * The "custom_handle" is any handle used to pass custom data into
+ * process_each_* and related functions.
+ *
+ * The "internal_report_for_select=0" makes processing function to
+ * skip checking the report/selection criteria (if given on cmd line)
+ * before executing the action on the item.
+ *
+ * The "selection_handle" is only used if "internal_report_for_select=1".
+ *
+ * Some important notes about selection:
+ * =====================================
+ * In case we're processing for display, the selection is directly
+ * a part of reporting for the display on output so we don't need to
+ * report the item in memory to get the selection result, then dropping
+ * the report and then reporting the same thing again for it to be
+ * displayed on output.
+ * For example, compare these code paths:
+ *
+ *   - when reporting for display on output:
+ *      _report -> process_each_* -> ... -> dm_report_object
+ *      (Here the dm_report_object does both selection and
+ *       reporting for display on output.)
+ *
+ *   - for any other processing and reporting for selection:
+ *      process_each_* -> _select_match_* -> ... -> dm_report_object_is_selected
+ *                                                            |
+ *                                                            --> (selection result) --> ...
+ *      (Here the dm_report_object_is_selected just gets
+ *       the selection result and it drops reporting buffer
+ *       immediately. Then based on the selection result,
+ *       the process_each_* action on the item is executed
+ *       or not...)
+ *
+ * Simply, we want to avoid this double reporting when reporting
+ * for display on output:
+ *     _report -> process_each_* -> _select_match_* -> ... -> dm_report_object_is_selected
+ *                                                                      |
+ *                                                                      --> (selection result) -> dm_report_object
+ *
+ * So whenever the processing action is "to display item on output", use
+ * "internal_report_for_select=0" as report/selection is already
+ * a part of that reporting for display (dm_report_object).
+ */
+struct processing_handle {
+	int internal_report_for_select;
+	struct selection_handle *selection_handle;
+	void *custom_handle;
+};
+
 typedef int (*process_single_vg_fn_t) (struct cmd_context * cmd,
 				       const char *vg_name,
 				       struct volume_group * vg,
-				       void *handle);
+				       struct processing_handle *handle);
 typedef int (*process_single_pv_fn_t) (struct cmd_context *cmd,
 				  struct volume_group *vg,
 				  struct physical_volume *pv,
-				  void *handle);
+				  struct processing_handle *handle);
 typedef int (*process_single_label_fn_t) (struct cmd_context *cmd,
 					  struct label *label,
-					  void *handle);
+					  struct processing_handle *handle);
 typedef int (*process_single_lv_fn_t) (struct cmd_context *cmd,
 				  struct logical_volume *lv,
-				  void *handle);
+				  struct processing_handle *handle);
 typedef int (*process_single_seg_fn_t) (struct cmd_context * cmd,
 					struct lv_segment * seg,
-					void *handle);
+					struct processing_handle *handle);
 typedef int (*process_single_pvseg_fn_t) (struct cmd_context * cmd,
 					  struct volume_group * vg,
 					  struct pv_segment * pvseg,
-					  void *handle);
+					  struct processing_handle *handle);
 
 int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
-		    uint32_t flags, void *handle,
+		    uint32_t flags, struct processing_handle *handle,
 		    process_single_vg_fn_t process_single_vg);
 
 int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
 		    const char *vg_name, uint32_t lock_type,
-		    void *handle, process_single_pv_fn_t process_single_pv);
+		    struct processing_handle *handle,
+		    process_single_pv_fn_t process_single_pv);
 
 int process_each_label(struct cmd_context *cmd, int argc, char **argv,
-		       void *handle, process_single_label_fn_t process_single_label);
+		       struct processing_handle *handle,
+		       process_single_label_fn_t process_single_label);
 
 int process_each_segment_in_pv(struct cmd_context *cmd,
 			       struct volume_group *vg,
 			       struct physical_volume *pv,
-			       void *handle,
+			       struct processing_handle *handle,
 			       process_single_pvseg_fn_t process_single_pvseg);
 
 int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
-		    uint32_t flags, void *handle,
+		    uint32_t flags, struct processing_handle *handle,
 		    process_single_lv_fn_t process_single_lv);
 
 
 int process_each_segment_in_lv(struct cmd_context *cmd,
-			       struct logical_volume *lv, void *handle,
+			       struct logical_volume *lv,
+			       struct processing_handle *handle,
 			       process_single_seg_fn_t process_single_seg);
 
 int process_each_pv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
-			  void *handle, process_single_pv_fn_t process_single_pv);
+			  struct processing_handle *handle,
+			  process_single_pv_fn_t process_single_pv);
 
 
 int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 			  struct dm_list *arg_lvnames, const struct dm_list *tagsl,
-			  int stop_on_error, void *handle,
+			  int stop_on_error, struct processing_handle *handle,
 			  process_single_lv_fn_t process_single_lv);
 
 int select_match_vg(struct cmd_context *cmd, struct volume_group *vg,
@@ -145,6 +203,6 @@ int validate_restricted_lvname_param(struct cmd_context *cmd, const char **vg_na
 				     const char **lv_name);
 
 int lvremove_single(struct cmd_context *cmd, struct logical_volume *lv,
-                    void *handle __attribute__((unused)));
+                    struct processing_handle *handle __attribute__((unused)));
 
 #endif
diff --git a/tools/vgcfgbackup.c b/tools/vgcfgbackup.c
index 7cf19bc..ee65f18 100644
--- a/tools/vgcfgbackup.c
+++ b/tools/vgcfgbackup.c
@@ -49,9 +49,9 @@ static char *_expand_filename(const char *template, const char *vg_name,
 
 static int vg_backup_single(struct cmd_context *cmd, const char *vg_name,
 			    struct volume_group *vg,
-			    void *handle)
+			    struct processing_handle *handle)
 {
-	char **last_filename = (char **)handle;
+	char **last_filename = (char **)handle->custom_handle;
 	char *filename;
 
 	if (arg_count(cmd, file_ARG)) {
@@ -83,11 +83,14 @@ int vgcfgbackup(struct cmd_context *cmd, int argc, char **argv)
 {
 	int ret;
 	char *last_filename = NULL;
+	struct processing_handle handle = { .internal_report_for_select = 1,
+					    .selection_handle = NULL,
+					    .custom_handle = &last_filename };
 
 	init_pvmove(1);
 
 	ret = process_each_vg(cmd, argc, argv, READ_ALLOW_INCONSISTENT,
-			      &last_filename, &vg_backup_single);
+			      &handle, &vg_backup_single);
 
 	dm_free(last_filename);
 
diff --git a/tools/vgchange.c b/tools/vgchange.c
index e5d700d..e3f852b 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -473,7 +473,7 @@ static int _vgchange_profile(struct cmd_context *cmd,
 
 static int vgchange_single(struct cmd_context *cmd, const char *vg_name,
 			   struct volume_group *vg,
-			   void *handle __attribute__((unused)))
+			   struct processing_handle *handle __attribute__((unused)))
 {
 	int ret = ECMD_PROCESSED;
 	unsigned i;
diff --git a/tools/vgck.c b/tools/vgck.c
index b9d05ae..1631289 100644
--- a/tools/vgck.c
+++ b/tools/vgck.c
@@ -18,7 +18,7 @@
 static int vgck_single(struct cmd_context *cmd __attribute__((unused)),
 		       const char *vg_name,
 		       struct volume_group *vg,
-		       void *handle __attribute__((unused)))
+		       struct processing_handle *handle __attribute__((unused)))
 {
 	if (!vg_check_status(vg, EXPORTED_VG))
 		return_ECMD_FAILED;
diff --git a/tools/vgconvert.c b/tools/vgconvert.c
index 1089344..50b3e44 100644
--- a/tools/vgconvert.c
+++ b/tools/vgconvert.c
@@ -17,7 +17,7 @@
 
 static int vgconvert_single(struct cmd_context *cmd, const char *vg_name,
 			    struct volume_group *vg,
-			    void *handle __attribute__((unused)))
+			    struct processing_handle *handle __attribute__((unused)))
 {
 	struct physical_volume *pv, *existing_pv;
 	struct pvcreate_restorable_params rp;
diff --git a/tools/vgdisplay.c b/tools/vgdisplay.c
index 59d741a..3c34727 100644
--- a/tools/vgdisplay.c
+++ b/tools/vgdisplay.c
@@ -17,7 +17,7 @@
 
 static int vgdisplay_single(struct cmd_context *cmd, const char *vg_name,
 			    struct volume_group *vg,
-			    void *handle __attribute__((unused)))
+			    struct processing_handle *handle __attribute__((unused)))
 {
 	if (arg_count(cmd, activevolumegroups_ARG) && !lvs_in_vg_activated(vg))
 		return ECMD_PROCESSED;
diff --git a/tools/vgexport.c b/tools/vgexport.c
index d9f8efa..aeff612 100644
--- a/tools/vgexport.c
+++ b/tools/vgexport.c
@@ -18,7 +18,7 @@
 static int vgexport_single(struct cmd_context *cmd __attribute__((unused)),
 			   const char *vg_name,
 			   struct volume_group *vg,
-			   void *handle __attribute__((unused)))
+			   struct processing_handle *handle __attribute__((unused)))
 {
 	struct pv_list *pvl;
 
diff --git a/tools/vgimport.c b/tools/vgimport.c
index 7cb9337..857f4a9 100644
--- a/tools/vgimport.c
+++ b/tools/vgimport.c
@@ -18,7 +18,7 @@
 static int vgimport_single(struct cmd_context *cmd __attribute__((unused)),
 			   const char *vg_name,
 			   struct volume_group *vg,
-			   void *handle __attribute__((unused)))
+			   struct processing_handle *handle __attribute__((unused)))
 {
 	struct pv_list *pvl;
 	struct physical_volume *pv;
diff --git a/tools/vgmknodes.c b/tools/vgmknodes.c
index 9ba0677..92eb2d0 100644
--- a/tools/vgmknodes.c
+++ b/tools/vgmknodes.c
@@ -16,7 +16,7 @@
 #include "tools.h"
 
 static int _vgmknodes_single(struct cmd_context *cmd, struct logical_volume *lv,
-			     void *handle __attribute__((unused)))
+			     struct processing_handle *handle __attribute__((unused)))
 {
 	if (arg_count(cmd, refresh_ARG) && lv_is_visible(lv))
 		if (!lv_refresh(cmd, lv))
diff --git a/tools/vgreduce.c b/tools/vgreduce.c
index 7af5a76..0adf1bb 100644
--- a/tools/vgreduce.c
+++ b/tools/vgreduce.c
@@ -123,7 +123,7 @@ static int _make_vg_consistent(struct cmd_context *cmd, struct volume_group *vg)
 /* Or take pv_name instead? */
 static int _vgreduce_single(struct cmd_context *cmd, struct volume_group *vg,
 			    struct physical_volume *pv,
-			    void *handle __attribute__((unused)))
+			    struct processing_handle *handle __attribute__((unused)))
 {
 	int r;
 
diff --git a/tools/vgremove.c b/tools/vgremove.c
index 1dce41f..315e1dc 100644
--- a/tools/vgremove.c
+++ b/tools/vgremove.c
@@ -17,7 +17,7 @@
 
 static int vgremove_single(struct cmd_context *cmd, const char *vg_name,
 			   struct volume_group *vg,
-			   void *handle __attribute__((unused)))
+			   struct processing_handle *handle __attribute__((unused)))
 {
 	/*
 	 * Single force is equivalent to sinle --yes
diff --git a/tools/vgscan.c b/tools/vgscan.c
index bca98cc..b3af9bc 100644
--- a/tools/vgscan.c
+++ b/tools/vgscan.c
@@ -17,7 +17,7 @@
 
 static int vgscan_single(struct cmd_context *cmd, const char *vg_name,
 			 struct volume_group *vg,
-			 void *handle __attribute__((unused)))
+			 struct processing_handle *handle __attribute__((unused)))
 {
 	log_print_unless_silent("Found %svolume group \"%s\" using metadata type %s",
 				vg_is_exported(vg) ? "exported " : "", vg_name,


