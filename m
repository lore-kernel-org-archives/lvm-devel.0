From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 20 Jun 2016 09:40:44 +0000 (UTC)
Subject: master - conf: add report/{vgs, pvs, lvs, pvsegs, segs}_{cols, sort}_full config settings
Message-ID: <20160620094044.3B1146031C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9c37b7ed7c33bb6e66daf369fd563c52f6743282
Commit:        9c37b7ed7c33bb6e66daf369fd563c52f6743282
Parent:        26c43c6ce525f5b338a2fbdae72bf308d42708d7
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jun 14 12:38:40 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jun 20 11:33:42 2016 +0200

conf: add report/{vgs,pvs,lvs,pvsegs,segs}_{cols,sort}_full config settings

---
 WHATS_NEW                    |    1 +
 conf/example.conf.in         |   60 ++++++++++++++++++++++++++++++++++++++++++
 lib/config/config_settings.h |   40 ++++++++++++++++++++++++++++
 tools/reporter.c             |   16 +++++-----
 4 files changed, 109 insertions(+), 8 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 79dfe09..4e87e47 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.158 - 
 =================================
+  Add report/{pvs,vgs,lvs,pvsegs,segs}_{cols,sort}_full to lvm.conf.
   Add lvm fullreport command for joined PV, VG, LV and segment report per VG.
   Integrate report group handling and cmd log report into cmd processing code.
   Add log/report_command_log to lvm.conf to enable or disable cmd log report.
diff --git a/conf/example.conf.in b/conf/example.conf.in
index 69bb668..1918a3d 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -1900,6 +1900,66 @@ activation {
 	# This configuration option has an automatic default value.
 	# pvsegs_cols_verbose = "pv_name,vg_name,pv_fmt,pv_attr,pv_size,pv_free,pvseg_start,pvseg_size,lv_name,seg_start_pe,segtype,seg_pe_ranges"
 
+	# Configuration option report/vgs_cols_full.
+	# List of columns to report for lvm fullreport's 'vgs' subreport.
+	# See 'vgs -o help' for the list of possible fields.
+	# This configuration option has an automatic default value.
+	# vgs_cols_full = "vg_all"
+
+	# Configuration option report/pvs_cols_full.
+	# List of columns to report for lvm fullreport's 'vgs' subreport.
+	# See 'pvs -o help' for the list of possible fields.
+	# This configuration option has an automatic default value.
+	# pvs_cols_full = "pv_all"
+
+	# Configuration option report/lvs_cols_full.
+	# List of columns to report for lvm fullreport's 'lvs' subreport.
+	# See 'lvs -o help' for the list of possible fields.
+	# This configuration option has an automatic default value.
+	# lvs_cols_full = "lv_all"
+
+	# Configuration option report/pvsegs_cols_full.
+	# List of columns to report for lvm fullreport's 'pvseg' subreport.
+	# See 'pvs --segments -o help' for the list of possible fields.
+	# This configuration option has an automatic default value.
+	# pvsegs_cols_full = "pvseg_all,pv_uuid,lv_uuid"
+
+	# Configuration option report/segs_cols_full.
+	# List of columns to report for lvm fullreport's 'seg' subreport.
+	# See 'lvs --segments -o help' for the list of possible fields.
+	# This configuration option has an automatic default value.
+	# segs_cols_full = "seg_all,lv_uuid"
+
+	# Configuration option report/vgs_sort_full.
+	# List of columns to sort by when reporting lvm fullreport's 'vgs' subreport.
+	# See 'vgs -o help' for the list of possible fields.
+	# This configuration option has an automatic default value.
+	# vgs_sort_full = "vg_name"
+
+	# Configuration option report/pvs_sort_full.
+	# List of columns to sort by when reporting lvm fullreport's 'vgs' subreport.
+	# See 'pvs -o help' for the list of possible fields.
+	# This configuration option has an automatic default value.
+	# pvs_sort_full = "pv_name"
+
+	# Configuration option report/lvs_sort_full.
+	# List of columns to sort by when reporting lvm fullreport's 'lvs' subreport.
+	# See 'lvs -o help' for the list of possible fields.
+	# This configuration option has an automatic default value.
+	# lvs_sort_full = "vg_name,lv_name"
+
+	# Configuration option report/pvsegs_sort_full.
+	# List of columns to sort by when reporting for lvm fullreport's 'pvseg' subreport.
+	# See 'pvs --segments -o help' for the list of possible fields.
+	# This configuration option has an automatic default value.
+	# pvsegs_sort_full = "pv_uuid,pvseg_start"
+
+	# Configuration option report/segs_sort_full.
+	# List of columns to sort by when reporting lvm fullreport's 'seg' subreport.
+	# See 'lvs --segments -o help' for the list of possible fields.
+	# This configuration option has an automatic default value.
+	# segs_sort_full = "lv_uuid,seg_start"
+
 	# Configuration option report/mark_hidden_devices.
 	# Use brackets [] to mark hidden devices.
 	# This configuration option has an automatic default value.
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 09c9ab5..89e0771 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -1743,6 +1743,46 @@ cfg(report_pvsegs_cols_verbose_CFG, "pvsegs_cols_verbose", report_CFG_SECTION, C
 	"List of columns to sort by when reporting 'pvs --segments' command in verbose mode.\n"
 	"See 'pvs --segments -o help' for the list of possible fields.\n")
 
+cfg(report_vgs_cols_full_CFG, "vgs_cols_full", report_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_VGS_COLS_FULL, vsn(2, 2, 158), NULL, 0, NULL,
+	"List of columns to report for lvm fullreport's 'vgs' subreport.\n"
+	"See 'vgs -o help' for the list of possible fields.\n")
+
+cfg(report_pvs_cols_full_CFG, "pvs_cols_full", report_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_PVS_COLS_FULL, vsn(2, 2, 158), NULL, 0, NULL,
+	"List of columns to report for lvm fullreport's 'vgs' subreport.\n"
+	"See 'pvs -o help' for the list of possible fields.\n")
+
+cfg(report_lvs_cols_full_CFG, "lvs_cols_full", report_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_LVS_COLS_FULL, vsn(2, 2, 158), NULL, 0, NULL,
+	"List of columns to report for lvm fullreport's 'lvs' subreport.\n"
+	"See 'lvs -o help' for the list of possible fields.\n")
+
+cfg(report_pvsegs_cols_full_CFG, "pvsegs_cols_full", report_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_PVSEGS_COLS_FULL, vsn(2, 2, 158), NULL, 0, NULL,
+	"List of columns to report for lvm fullreport's 'pvseg' subreport.\n"
+	"See 'pvs --segments -o help' for the list of possible fields.\n")
+
+cfg(report_segs_cols_full_CFG, "segs_cols_full", report_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_SEGS_COLS_FULL, vsn(2, 2, 158), NULL, 0, NULL,
+	"List of columns to report for lvm fullreport's 'seg' subreport.\n"
+	"See 'lvs --segments -o help' for the list of possible fields.\n")
+
+cfg(report_vgs_sort_full_CFG, "vgs_sort_full", report_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_VGS_SORT_FULL, vsn(2, 2, 158), NULL, 0, NULL,
+	"List of columns to sort by when reporting lvm fullreport's 'vgs' subreport.\n"
+	"See 'vgs -o help' for the list of possible fields.\n")
+
+cfg(report_pvs_sort_full_CFG, "pvs_sort_full", report_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_PVS_SORT_FULL, vsn(2, 2, 158), NULL, 0, NULL,
+	"List of columns to sort by when reporting lvm fullreport's 'vgs' subreport.\n"
+	"See 'pvs -o help' for the list of possible fields.\n")
+
+cfg(report_lvs_sort_full_CFG, "lvs_sort_full", report_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_LVS_SORT_FULL, vsn(2, 2, 158), NULL, 0, NULL,
+	"List of columns to sort by when reporting lvm fullreport's 'lvs' subreport.\n"
+	"See 'lvs -o help' for the list of possible fields.\n")
+
+cfg(report_pvsegs_sort_full_CFG, "pvsegs_sort_full", report_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_PVSEGS_SORT_FULL, vsn(2, 2, 158), NULL, 0, NULL,
+	"List of columns to sort by when reporting for lvm fullreport's 'pvseg' subreport.\n"
+	"See 'pvs --segments -o help' for the list of possible fields.\n")
+
+cfg(report_segs_sort_full_CFG, "segs_sort_full", report_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_SEGS_SORT_FULL, vsn(2, 2, 158), NULL, 0, NULL,
+	"List of columns to sort by when reporting lvm fullreport's 'seg' subreport.\n"
+	"See 'lvs --segments -o help' for the list of possible fields.\n")
+
 cfg(report_mark_hidden_devices_CFG, "mark_hidden_devices", report_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, 1, vsn(2, 2, 140), NULL, 0, NULL,
 	"Use brackets [] to mark hidden devices.\n")
 
diff --git a/tools/reporter.c b/tools/reporter.c
index 2037f6e..408d410 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -1055,11 +1055,11 @@ out:
 	return r;
 }
 
-#define _set_full_report_single(args,type,name) \
+#define _set_full_report_single(cmd,args,type,name) \
 	do { \
 		args->single_args[REPORT_IDX_FULL_ ## type].report_type = type; \
-		args->single_args[REPORT_IDX_FULL_ ## type].keys = DEFAULT_ ## type ## _SORT_FULL; \
-		args->single_args[REPORT_IDX_FULL_ ## type].options = DEFAULT_ ## type ## _COLS_FULL; \
+		args->single_args[REPORT_IDX_FULL_ ## type].keys = find_config_tree_str(cmd, report_ ## name ## _sort_full_CFG, NULL); \
+		args->single_args[REPORT_IDX_FULL_ ## type].options = find_config_tree_str(cmd, report_ ## name ## _cols_full_CFG, NULL); \
 		if (!_set_report_prefix_and_name(&args->single_args[REPORT_IDX_FULL_ ## type])) \
 			return_0; \
 	} while (0)
@@ -1125,11 +1125,11 @@ static int _config_report(struct cmd_context *cmd, struct report_args *args, str
 				single_args->options = find_config_tree_str(cmd, report_pvsegs_cols_verbose_CFG, NULL);
 			break;
 		case FULL:
-			_set_full_report_single(args, VGS, vgs);
-			_set_full_report_single(args, LVS, lvs);
-			_set_full_report_single(args, PVS, pvs);
-			_set_full_report_single(args, PVSEGS, pvsegs);
-			_set_full_report_single(args, SEGS, segs);
+			_set_full_report_single(cmd, args, VGS, vgs);
+			_set_full_report_single(cmd, args, LVS, lvs);
+			_set_full_report_single(cmd, args, PVS, pvs);
+			_set_full_report_single(cmd, args, PVSEGS, pvsegs);
+			_set_full_report_single(cmd, args, SEGS, segs);
 			break;
 		case CMDLOG:
 			single_args->keys = find_config_tree_str(cmd, log_command_log_sort_CFG, NULL);


