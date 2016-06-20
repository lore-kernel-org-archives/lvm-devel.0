From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 20 Jun 2016 09:40:42 +0000 (UTC)
Subject: master - commands: report: add lvm fullreport command
Message-ID: <20160620094042.1F4406031C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=26c43c6ce525f5b338a2fbdae72bf308d42708d7
Commit:        26c43c6ce525f5b338a2fbdae72bf308d42708d7
Parent:        f1e7f35bb5982f6767bcaa8ab775bde580316c5d
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue May 3 11:18:16 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jun 20 11:33:42 2016 +0200

commands: report: add lvm fullreport command

lvm fullreport executes 5 subreports (vg, pv, lv, pvseg, seg) per each VG
(and so taking one VG lock each time) within one command which makes it
easier to produce full report about LVM entities.

Since all 5 subreports for a VG are done under a VG lock, the output is
more consistent mainly in cases where LVM entities may be changed in
parallel.
---
 WHATS_NEW             |    1 +
 lib/config/defaults.h |   12 +++
 lib/report/report.h   |   21 +++--
 tools/Makefile.in     |    2 +-
 tools/commands.h      |   38 +++++++++
 tools/reporter.c      |  219 ++++++++++++++++++++++++++++++++++++++-----------
 6 files changed, 235 insertions(+), 58 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 349bd30..79dfe09 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.158 - 
 =================================
+  Add lvm fullreport command for joined PV, VG, LV and segment report per VG.
   Integrate report group handling and cmd log report into cmd processing code.
   Add log/report_command_log to lvm.conf to enable or disable cmd log report.
   Add log/report_output_format to lvm.conf for default report output format.
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index ae8134f..6c7769a 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -226,6 +226,12 @@
 #define DEFAULT_PVSEGS_COLS_VERB "pv_name,vg_name,pv_fmt,pv_attr,pv_size,pv_free,pvseg_start,pvseg_size,lv_name,seg_start_pe,segtype,seg_pe_ranges"
 #define DEFAULT_DEVTYPES_COLS_VERB "devtype_name,devtype_max_partitions,devtype_description"
 
+#define DEFAULT_VGS_COLS_FULL "vg_all"
+#define DEFAULT_PVS_COLS_FULL "pv_all"
+#define DEFAULT_LVS_COLS_FULL "lv_all"
+#define DEFAULT_PVSEGS_COLS_FULL "pvseg_all,pv_uuid,lv_uuid"
+#define DEFAULT_SEGS_COLS_FULL "seg_all,lv_uuid"
+
 #define DEFAULT_LVS_SORT "vg_name,lv_name"
 #define DEFAULT_VGS_SORT "vg_name"
 #define DEFAULT_PVS_SORT "pv_name"
@@ -234,6 +240,12 @@
 #define DEFAULT_DEVTYPES_SORT "devtype_name"
 #define DEFAULT_COMMAND_LOG_SORT "log_seq_num"
 
+#define DEFAULT_VGS_SORT_FULL "vg_name"
+#define DEFAULT_PVS_SORT_FULL "pv_name"
+#define DEFAULT_LVS_SORT_FULL "vg_name,lv_name"
+#define DEFAULT_PVSEGS_SORT_FULL "pv_uuid,pvseg_start"
+#define DEFAULT_SEGS_SORT_FULL "lv_uuid,seg_start"
+
 #define DEFAULT_MIRROR_DEVICE_FAULT_POLICY "remove"
 #define DEFAULT_MIRROR_LOG_FAULT_POLICY "allocate"
 #define DEFAULT_SNAPSHOT_AUTOEXTEND_THRESHOLD 100
diff --git a/lib/report/report.h b/lib/report/report.h
index 62c52dc..20ccd99 100644
--- a/lib/report/report.h
+++ b/lib/report/report.h
@@ -22,16 +22,17 @@
 
 typedef enum {
 	CMDLOG		= 1,
-	LVS		= 2,
-	LVSINFO		= 4,
-	LVSSTATUS	= 8,
-	LVSINFOSTATUS   = 16,
-	PVS		= 32,
-	VGS		= 64,
-	SEGS		= 128,
-	PVSEGS		= 256,
-	LABEL		= 512,
-	DEVTYPES	= 1024
+	FULL		= 2,
+	LVS		= 4,
+	LVSINFO		= 8,
+	LVSSTATUS	= 16,
+	LVSINFOSTATUS   = 32,
+	PVS		= 64,
+	VGS		= 128,
+	SEGS		= 256,
+	PVSEGS		= 512,
+	LABEL		= 1024,
+	DEVTYPES	= 2048
 } report_type_t;
 
 /*
diff --git a/tools/Makefile.in b/tools/Makefile.in
index f2f9faa..bb29176 100644
--- a/tools/Makefile.in
+++ b/tools/Makefile.in
@@ -168,7 +168,7 @@ liblvm2cmd.$(LIB_SUFFIX).$(LIB_VERSION): liblvm2cmd.$(LIB_SUFFIX)
 
 .commands: $(srcdir)/commands.h $(srcdir)/cmdnames.h Makefile
 	$(CC) -E -P $(srcdir)/cmdnames.h 2> /dev/null | \
-		egrep -v '^ *(|#.*|config|devtypes|dumpconfig|formats|help|lvpoll|pvdata|segtypes|systemid|tags|version) *$$' > .commands
+		egrep -v '^ *(|#.*|config|devtypes|dumpconfig|formats|fullreport|help|lvpoll|pvdata|segtypes|systemid|tags|version) *$$' > .commands
 
 ifneq ("$(CFLOW_CMD)", "")
 CFLOW_SOURCES = $(addprefix $(srcdir)/, $(SOURCES))
diff --git a/tools/commands.h b/tools/commands.h
index 4db57d5..a9e4be5 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -136,6 +136,44 @@ xx(lvactivate,
    "Logical Volume(s)\n")
 ***********/
 
+xx(fullreport,
+   "Display full report",
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH,
+   "fullreport\n"
+   "\t[--aligned]\n"
+   "\t[--binary]\n"
+   "\t[-a|--all]\n"
+   "\t[--commandprofile ProfileName]\n"
+   "\t[-d|--debug]\n"
+   "\t[--foreign]\n"
+   "\t[-h|--help]\n"
+   "\t[--ignorelockingfailure]\n"
+   "\t[--ignoreskippedcluster]\n"
+   "\t[--nameprefixes]\n"
+   "\t[--noheadings]\n"
+   "\t[--nosuffix]\n"
+   "\t[-o|--options [+|-|#]Field[,Field]]\n"
+   "\t[-O|--sort [+|-]key1[,[+|-]key2[,...]]]\n"
+   "\t[-P|--partial]\n"
+   "\t[--readonly]\n"
+   "\t[--reportformat {json}]\n"
+   "\t[--rows]\n"
+   "\t[-S|--select Selection]\n"
+   "\t[--separator Separator]\n"
+   "\t[--trustcache]\n"
+   "\t[--unbuffered]\n"
+   "\t[--units hHbBsSkKmMgGtTpPeE]\n"
+   "\t[--unquoted]\n"
+   "\t[-v|--verbose]\n"
+   "\t[--version]\n"
+   "\t[VolumeGroupName [VolumeGroupName...]]\n",
+
+   aligned_ARG, all_ARG, binary_ARG, foreign_ARG, ignorelockingfailure_ARG,
+   ignoreskippedcluster_ARG, nameprefixes_ARG, noheadings_ARG, nolocking_ARG,
+   nosuffix_ARG, options_ARG, partial_ARG, readonly_ARG, reportformat_ARG,
+   rows_ARG, select_ARG, separator_ARG, shared_ARG, sort_ARG, trustcache_ARG,
+   unbuffered_ARG, units_ARG, unquoted_ARG)
+
 xx(lvchange,
    "Change the attributes of logical volume(s)",
    CACHE_VGMETADATA | PERMITTED_READ_ONLY,
diff --git a/tools/reporter.c b/tools/reporter.c
index 9f4f95a..2037f6e 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -21,6 +21,11 @@ typedef enum {
 	REPORT_IDX_NULL = -1,
 	REPORT_IDX_SINGLE,
 	REPORT_IDX_LOG,
+	REPORT_IDX_FULL_VGS,
+	REPORT_IDX_FULL_LVS,
+	REPORT_IDX_FULL_PVS,
+	REPORT_IDX_FULL_PVSEGS,
+	REPORT_IDX_FULL_SEGS,
 	REPORT_IDX_COUNT
 } report_idx_t;
 
@@ -48,6 +53,7 @@ struct report_args {
 	int quoted;
 	int columns_as_rows;
 	const char *separator;
+	struct volume_group *full_report_vg;
 	struct single_report_args single_args[REPORT_IDX_COUNT];
 };
 
@@ -457,8 +463,10 @@ static int _get_final_report_type(int args_are_pvs,
 	}
 
 	/* Change report type if fields specified makes this necessary */
-	if ((report_type & PVSEGS) ||
-	    ((report_type & (PVS | LABEL)) && (report_type & (LVS | LVSINFO | LVSSTATUS | LVSINFOSTATUS))))
+	if (report_type & FULL)
+		report_type = FULL;
+	else if ((report_type & PVSEGS) ||
+		 ((report_type & (PVS | LABEL)) && (report_type & (LVS | LVSINFO | LVSSTATUS | LVSINFOSTATUS))))
 		report_type = PVSEGS;
 	else if ((report_type & PVS) ||
 		 ((report_type & LABEL) && (report_type & VGS)))
@@ -829,6 +837,12 @@ static int _set_report_prefix_and_name(struct single_report_args *single_args)
 	const char *report_prefix;
 	size_t len;
 
+	if (single_args->report_type == FULL) {
+		single_args->report_prefix[0] = '\0';
+		single_args->report_name = single_args->report_prefix;
+		return 1;
+	}
+
 	report_prefix = report_get_field_prefix(single_args->report_type);
 	len = strlen(report_prefix);
 	if (report_prefix[len - 1] == '_')
@@ -850,27 +864,24 @@ static int _set_report_prefix_and_name(struct single_report_args *single_args)
 	return 1;
 }
 
-static int _do_report(struct cmd_context *cmd, struct report_args *args, struct single_report_args *single_args)
+static int _do_report(struct cmd_context *cmd, struct processing_handle *handle,
+		      struct report_args *args, struct single_report_args *single_args)
 {
-	struct processing_handle *handle = NULL;
+	void *orig_custom_handle = handle->custom_handle;
 	report_type_t report_type = single_args->report_type;
 	void *report_handle = NULL;
 	int lock_global = 0;
 	int lv_info_needed;
 	int lv_segment_status_needed;
+	int report_in_group = 0;
 	int r = ECMD_FAILED;
 
-	if (!(handle = init_processing_handle(cmd, NULL)))
-		goto_out;
-
 	if (!(report_handle = report_init(cmd, single_args->options, single_args->keys, &report_type,
 					  args->separator, args->aligned, args->buffered,
 					  args->headings, args->field_prefixes, args->quoted,
 					  args->columns_as_rows, single_args->selection)))
 		goto_out;
 
-	handle->internal_report_for_select = 0;
-	handle->include_historical_lvs = cmd->include_historical_lvs;
 	handle->custom_handle = report_handle;
 
 	if (!_get_final_report_type(single_args->args_are_pvs,
@@ -879,8 +890,11 @@ static int _do_report(struct cmd_context *cmd, struct report_args *args, struct
 				    &report_type))
 		goto_out;
 
-	if (!dm_report_group_push(handle->report_group, report_handle, (void *) single_args->report_name))
-		goto_out;
+	if (handle->report_group) {
+		if (!dm_report_group_push(handle->report_group, report_handle, (void *) single_args->report_name))
+			goto_out;
+		report_in_group = 1;
+	}
 
 	/*
 	 * We lock VG_GLOBAL to enable use of metadata cache.
@@ -906,48 +920,72 @@ static int _do_report(struct cmd_context *cmd, struct report_args *args, struct
 		case LVSINFOSTATUS:
 			/* fall through */
 		case LVS:
-			r = process_each_lv(cmd, args->argc, args->argv, NULL, NULL, 0, handle,
-					    lv_info_needed && !lv_segment_status_needed ? &_lvs_with_info_single :
-					    !lv_info_needed && lv_segment_status_needed ? &_lvs_with_status_single :
-					    lv_info_needed && lv_segment_status_needed ? &_lvs_with_info_and_status_single :
-											 &_lvs_single);
+			if (args->full_report_vg)
+				r = _report_all_in_vg(cmd, handle, args->full_report_vg, LVS, lv_info_needed, lv_segment_status_needed);
+			else
+				r = process_each_lv(cmd, args->argc, args->argv, NULL, NULL, 0, handle,
+						    lv_info_needed && !lv_segment_status_needed ? &_lvs_with_info_single :
+						    !lv_info_needed && lv_segment_status_needed ? &_lvs_with_status_single :
+						    lv_info_needed && lv_segment_status_needed ? &_lvs_with_info_and_status_single :
+												 &_lvs_single);
 			break;
 		case VGS:
-			r = process_each_vg(cmd, args->argc, args->argv, NULL, NULL, 0,
-					    handle, &_vgs_single);
+			if (args->full_report_vg)
+				r = _report_all_in_vg(cmd, handle, args->full_report_vg, VGS, lv_info_needed, lv_segment_status_needed);
+			else
+				r = process_each_vg(cmd, args->argc, args->argv, NULL, NULL, 0,
+						    handle, &_vgs_single);
 			break;
 		case LABEL:
 			r = process_each_label(cmd, args->argc, args->argv,
 					       handle, &_label_single);
 			break;
 		case PVS:
-			if (single_args->args_are_pvs)
-				r = process_each_pv(cmd, args->argc, args->argv, NULL,
-						    arg_is_set(cmd, all_ARG), 0,
-						    handle, &_pvs_single);
-			else
-				r = process_each_vg(cmd, args->argc, args->argv, NULL, NULL,
-						    0, handle, &_pvs_in_vg);
+			if (args->full_report_vg)
+				r = _report_all_in_vg(cmd, handle, args->full_report_vg, PVS, lv_info_needed, lv_segment_status_needed);
+			else {
+				if (single_args->args_are_pvs)
+					r = process_each_pv(cmd, args->argc, args->argv, NULL,
+							    arg_is_set(cmd, all_ARG), 0,
+							    handle, &_pvs_single);
+				else
+					r = process_each_vg(cmd, args->argc, args->argv, NULL, NULL,
+							    0, handle, &_pvs_in_vg);
+			}
 			break;
 		case SEGS:
-			r = process_each_lv(cmd, args->argc, args->argv, NULL, NULL, 0, handle,
-					    lv_info_needed && !lv_segment_status_needed ? &_lvsegs_with_info_single :
-					    !lv_info_needed && lv_segment_status_needed ? &_lvsegs_with_status_single :
-					    lv_info_needed && lv_segment_status_needed ? &_lvsegs_with_info_and_status_single :
-											 &_lvsegs_single);
+			if (args->full_report_vg)
+				r = _report_all_in_vg(cmd, handle, args->full_report_vg, SEGS, lv_info_needed, lv_segment_status_needed);
+			else
+				r = process_each_lv(cmd, args->argc, args->argv, NULL, NULL, 0, handle,
+						    lv_info_needed && !lv_segment_status_needed ? &_lvsegs_with_info_single :
+						    !lv_info_needed && lv_segment_status_needed ? &_lvsegs_with_status_single :
+						    lv_info_needed && lv_segment_status_needed ? &_lvsegs_with_info_and_status_single :
+												 &_lvsegs_single);
 			break;
 		case PVSEGS:
-			if (single_args->args_are_pvs)
-				r = process_each_pv(cmd, args->argc, args->argv, NULL,
-						    arg_is_set(cmd, all_ARG), 0,
-						    handle,
-						    lv_info_needed && !lv_segment_status_needed ? &_pvsegs_with_lv_info_single :
-						    !lv_info_needed && lv_segment_status_needed ? &_pvsegs_with_lv_status_single :
-						    lv_info_needed && lv_segment_status_needed ? &_pvsegs_with_lv_info_and_status_single :
+			if (args->full_report_vg)
+				r = _report_all_in_vg(cmd, handle, args->full_report_vg, PVSEGS, lv_info_needed, lv_segment_status_needed);
+			else {
+				if (single_args->args_are_pvs)
+					r = process_each_pv(cmd, args->argc, args->argv, NULL,
+							    arg_is_set(cmd, all_ARG), 0,
+							    handle,
+							    lv_info_needed && !lv_segment_status_needed ? &_pvsegs_with_lv_info_single :
+							    !lv_info_needed && lv_segment_status_needed ? &_pvsegs_with_lv_status_single :
+							    lv_info_needed && lv_segment_status_needed ? &_pvsegs_with_lv_info_and_status_single :
 												 &_pvsegs_single);
-			else
-				r = process_each_vg(cmd, args->argc, args->argv, NULL, NULL,
-						    0, handle, &_pvsegs_in_vg);
+				else
+					r = process_each_vg(cmd, args->argc, args->argv, NULL, NULL,
+							    0, handle, &_pvsegs_in_vg);
+			}
+			break;
+		case FULL:
+			/*
+			 * Full report's subreports already covered by combinations above with args->full_report_vg.
+			 * We shouldn't see report_type == FULL in this function.
+			 */
+			log_error(INTERNAL_ERROR "_do_report: full report requested at incorrect level");
 			break;
 		case CMDLOG:
 			/* Log is reported throughout the code via report_cmdlog calls. */
@@ -970,13 +1008,62 @@ static int _do_report(struct cmd_context *cmd, struct report_args *args, struct
 	if (lock_global)
 		unlock_vg(cmd, VG_GLOBAL);
 out:
-	if (handle)
-		destroy_processing_handle(cmd, handle);
-	if (report_handle)
+	if (report_handle) {
+		if (report_in_group && !dm_report_group_pop(handle->report_group))
+			stack;
 		dm_report_free(report_handle);
+	}
+
+	handle->custom_handle = orig_custom_handle;
+	return r;
+}
+
+static int _full_report_single(struct cmd_context *cmd,
+			       const char *vg_name,
+			       struct volume_group *vg,
+			       struct processing_handle *handle)
+{
+	struct report_args *args = (struct report_args *) handle->custom_handle;
+	int orphan = is_orphan_vg(vg->name);
+	int r = ECMD_FAILED;
+
+	if (orphan && !dm_list_size(&vg->pvs))
+		return ECMD_PROCESSED;
+
+	args->full_report_vg = vg;
+
+	if (!dm_report_group_push(handle->report_group, NULL, NULL))
+		goto out;
+
+	if (orphan) {
+		if (((r = _do_report(cmd, handle, args, &args->single_args[REPORT_IDX_FULL_PVS])) != ECMD_PROCESSED) ||
+		    ((r = _do_report(cmd, handle, args, &args->single_args[REPORT_IDX_FULL_PVSEGS])) != ECMD_PROCESSED))
+			stack;
+	} else {
+		if (((r = _do_report(cmd, handle, args, &args->single_args[REPORT_IDX_FULL_VGS])) != ECMD_PROCESSED) ||
+		    ((r = _do_report(cmd, handle, args, &args->single_args[REPORT_IDX_FULL_PVS])) != ECMD_PROCESSED) ||
+		    ((r = _do_report(cmd, handle, args, &args->single_args[REPORT_IDX_FULL_LVS])) != ECMD_PROCESSED) ||
+		    ((r = _do_report(cmd, handle, args, &args->single_args[REPORT_IDX_FULL_PVSEGS])) != ECMD_PROCESSED) ||
+		    ((r = _do_report(cmd, handle, args, &args->single_args[REPORT_IDX_FULL_SEGS])) != ECMD_PROCESSED))
+			stack;
+	}
+
+	if (!dm_report_group_pop(handle->report_group))
+		goto_out;
+out:
+	args->full_report_vg = NULL;
 	return r;
 }
 
+#define _set_full_report_single(args,type,name) \
+	do { \
+		args->single_args[REPORT_IDX_FULL_ ## type].report_type = type; \
+		args->single_args[REPORT_IDX_FULL_ ## type].keys = DEFAULT_ ## type ## _SORT_FULL; \
+		args->single_args[REPORT_IDX_FULL_ ## type].options = DEFAULT_ ## type ## _COLS_FULL; \
+		if (!_set_report_prefix_and_name(&args->single_args[REPORT_IDX_FULL_ ## type])) \
+			return_0; \
+	} while (0)
+
 static int _config_report(struct cmd_context *cmd, struct report_args *args, struct single_report_args *single_args)
 {
 	args->aligned = find_config_tree_bool(cmd, report_aligned_CFG, NULL);
@@ -1037,6 +1124,13 @@ static int _config_report(struct cmd_context *cmd, struct report_args *args, str
 			else
 				single_args->options = find_config_tree_str(cmd, report_pvsegs_cols_verbose_CFG, NULL);
 			break;
+		case FULL:
+			_set_full_report_single(args, VGS, vgs);
+			_set_full_report_single(args, LVS, lvs);
+			_set_full_report_single(args, PVS, pvs);
+			_set_full_report_single(args, PVSEGS, pvsegs);
+			_set_full_report_single(args, SEGS, segs);
+			break;
 		case CMDLOG:
 			single_args->keys = find_config_tree_str(cmd, log_command_log_sort_CFG, NULL);
 			single_args->options = find_config_tree_str(cmd, log_command_log_cols_CFG, NULL);
@@ -1046,7 +1140,8 @@ static int _config_report(struct cmd_context *cmd, struct report_args *args, str
 			return 0;
 	}
 
-	single_args->fields_to_compact = find_config_tree_str_allow_empty(cmd, report_compact_output_cols_CFG, NULL);
+	if (single_args->report_type != FULL)
+		single_args->fields_to_compact = find_config_tree_str_allow_empty(cmd, report_compact_output_cols_CFG, NULL);
 
 	/* If -o supplied use it, else use default for report_type */
 	if ((_get_report_options(cmd, args, single_args) != ECMD_PROCESSED))
@@ -1084,6 +1179,9 @@ static int _report(struct cmd_context *cmd, int argc, char **argv, report_type_t
 {
 	struct report_args args = {0};
 	struct single_report_args *single_args = &args.single_args[REPORT_IDX_SINGLE];
+	static char report_name[] = "report";
+	struct processing_handle *handle;
+	int r = ECMD_FAILED;
 
 	/*
 	 * Include foreign VGs that contain active LVs.
@@ -1097,10 +1195,33 @@ static int _report(struct cmd_context *cmd, int argc, char **argv, report_type_t
 	args.argv = argv;
 	single_args->report_type = report_type;
 
-	if (!_config_report(cmd, &args, single_args))
+	if (!(handle = init_processing_handle(cmd, NULL)))
 		return_ECMD_FAILED;
 
-	return _do_report(cmd, &args, single_args);
+	handle->internal_report_for_select = 0;
+	handle->include_historical_lvs = cmd->include_historical_lvs;
+
+	args.report_group_type = handle->report_group_type;
+
+	if (!_config_report(cmd, &args, single_args)) {
+		destroy_processing_handle(cmd, handle);
+		return_ECMD_FAILED;
+	}
+
+	if (!dm_report_group_push(handle->report_group, NULL, report_name)) {
+		log_error("Failed to add main report section to report group.");
+		destroy_processing_handle(cmd, handle);
+		return ECMD_FAILED;
+	}
+
+	if (single_args->report_type == FULL) {
+		handle->custom_handle = &args;
+		r = process_each_vg(cmd, argc, argv, NULL, NULL, 0, handle, &_full_report_single);
+	} else
+		r = _do_report(cmd, handle, &args, single_args);
+
+	destroy_processing_handle(cmd, handle);
+	return r;
 }
 
 int lvs(struct cmd_context *cmd, int argc, char **argv)
@@ -1132,6 +1253,11 @@ int pvs(struct cmd_context *cmd, int argc, char **argv)
 	return _report(cmd, argc, argv, type);
 }
 
+int fullreport(struct cmd_context *cmd, int argc, char **argv)
+{
+	return _report(cmd, argc, argv, FULL);
+}
+
 int devtypes(struct cmd_context *cmd, int argc, char **argv)
 {
 	return _report(cmd, argc, argv, DEVTYPES);
@@ -1143,7 +1269,6 @@ int devtypes(struct cmd_context *cmd, int argc, char **argv)
 int report_format_init(struct cmd_context *cmd, dm_report_group_type_t *report_group_type,
 		       struct dm_report_group **report_group, struct dm_report **log_rh)
 {
-	static char log_report_name[] = "log";
 	int config_set = find_config_tree_node(cmd, report_output_format_CFG, NULL) != NULL;
 	const char *config_format_str = find_config_tree_str(cmd, report_output_format_CFG, NULL);
 	const char *format_str = arg_str_value(cmd, reportformat_ARG, config_set ? config_format_str : NULL);


