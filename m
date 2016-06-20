From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 20 Jun 2016 09:40:19 +0000 (UTC)
Subject: master - report: add CMDLOG report type
Message-ID: <20160620094019.0E8B860FDF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=99c2a2b960d24d4826e3e66b4879de4bad13fbab
Commit:        99c2a2b960d24d4826e3e66b4879de4bad13fbab
Parent:        094fce37765964a9c3b32d1473e75c7d121eace1
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue May 10 15:15:48 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jun 20 11:33:08 2016 +0200

report: add CMDLOG report type

This is a preparation for new CMDLOG report type which is going to be
used for reporting LVM command log.

The new report type introduces several new fields (log_seq_num, log_type,
log_context, log_object_type, log_object_group, log_object_id, object_name,
log_message, log_errno, log_ret_code) as well as new configuration settings
to set this report type (report/command_log_sort and report/command_log_cols
lvm.conf settings).

This patch also introduces internal report_cmdlog helper function
which is a wrapper over dm_report_object to report command log via
CMDLOG report type and which is going to be used throughout the code
to report the log items.
---
 WHATS_NEW                   |    3 ++
 lib/config/defaults.h       |    2 +
 lib/report/columns-cmdlog.h |   40 ++++++++++++++++++++++++++++++++++
 lib/report/report.c         |   50 ++++++++++++++++++++++++++++++++++++++++--
 lib/report/report.h         |   40 +++++++++++++++++++++++++--------
 tools/reporter.c            |    7 ++++++
 6 files changed, 129 insertions(+), 13 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index c91e28d..2c360cb 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,8 @@
 Version 2.02.158 - 
 =================================
+  Add log_object_{type,name,id,group,group_id} fields to cmd log.
+  Add log_{seq_num,type,context,message,errno,ret_code} fields to cmd log.
+  Add CMDLOG report type - a separate report type for command logging.
 
 Version 2.02.157 - 17th June 2016
 =================================
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 07ca5de..82e3716 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -215,6 +215,7 @@
 #define DEFAULT_SEGS_COLS "lv_name,vg_name,lv_attr,stripes,segtype,seg_size"
 #define DEFAULT_PVSEGS_COLS "pv_name,vg_name,pv_fmt,pv_attr,pv_size,pv_free,pvseg_start,pvseg_size"
 #define DEFAULT_DEVTYPES_COLS "devtype_name,devtype_max_partitions,devtype_description"
+#define DEFAULT_COMMAND_LOG_COLS "log_seq_num,log_type,log_context,log_object_type,log_object_name,log_object_id,log_object_group,log_object_group_id,log_message,log_errno,log_ret_code"
 
 #define DEFAULT_LVS_COLS_VERB "lv_name,vg_name,seg_count,lv_attr,lv_size,lv_major,lv_minor,lv_kernel_major,lv_kernel_minor,pool_lv,origin,data_percent,metadata_percent,move_pv,copy_percent,mirror_log,convert_lv,lv_uuid,lv_profile"
 #define DEFAULT_VGS_COLS_VERB "vg_name,vg_attr,vg_extent_size,pv_count,lv_count,snap_count,vg_size,vg_free,vg_uuid,vg_profile"
@@ -229,6 +230,7 @@
 #define DEFAULT_SEGS_SORT "vg_name,lv_name,seg_start"
 #define DEFAULT_PVSEGS_SORT "pv_name,pvseg_start"
 #define DEFAULT_DEVTYPES_SORT "devtype_name"
+#define DEFAULT_COMMAND_LOG_SORT "log_seq_num"
 
 #define DEFAULT_MIRROR_DEVICE_FAULT_POLICY "remove"
 #define DEFAULT_MIRROR_LOG_FAULT_POLICY "allocate"
diff --git a/lib/report/columns-cmdlog.h b/lib/report/columns-cmdlog.h
new file mode 100644
index 0000000..3dd7df5
--- /dev/null
+++ b/lib/report/columns-cmdlog.h
@@ -0,0 +1,40 @@
+/*
+ * Copyright (C) 2016 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+/*
+ * This file defines the fields (columns) for the command log reporting.
+ *
+ * The preferred order of the field descriptions in the help text
+ * determines the order the entries appear in this file.
+ *
+ * When adding new entries take care to use the existing style.
+ * Displayed fields names normally have a type prefix and use underscores.
+ * Field-specific internal functions names normally match the displayed
+ * field names but without underscores.
+ * Help text ends with a full stop.
+ */
+
+/* *INDENT-OFF* */
+FIELD(CMDLOG, cmd_log_item, NUM, "Seq", seq_num, 3, uint32, log_seq_num, "Log sequence number.", 0)
+FIELD(CMDLOG, cmd_log_item, STR, "LogType", type, 7, string, log_type, "Log type.", 0)
+FIELD(CMDLOG, cmd_log_item, STR, "Context", context, 7, string, log_context, "Current context.", 0)
+FIELD(CMDLOG, cmd_log_item, STR, "ObjType", object_type_name, 7, string, log_object_type, "Current object type.", 0)
+FIELD(CMDLOG, cmd_log_item, STR, "ObjName", object_name, 7, string, log_object_name, "Current object name.", 0)
+FIELD(CMDLOG, cmd_log_item, STR, "ObjID", object_id, 7, string, log_object_id, "Current object ID.", 0)
+FIELD(CMDLOG, cmd_log_item, STR, "ObjGrp", object_group, 7, string, log_object_group, "Current object group.", 0)
+FIELD(CMDLOG, cmd_log_item, STR, "ObjGrpID", object_group_id, 8, string, log_object_group_id, "Current object group ID.", 0)
+FIELD(CMDLOG, cmd_log_item, STR, "Msg", msg, 7, string, log_message, "Log message.", 0)
+FIELD(CMDLOG, cmd_log_item, SNUM, "Errno", current_errno, 5, int32, log_errno, "Errno.", 0)
+FIELD(CMDLOG, cmd_log_item, SNUM, "RetCode", ret_code, 7, int32, log_ret_code, "Return code.", 0)
+/* *INDENT-ON* */
diff --git a/lib/report/report.c b/lib/report/report.c
index 8e08c75..eec9756 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -3622,6 +3622,16 @@ static void *_obj_get_devtypes(void *obj)
 	return obj;
 }
 
+static void *_obj_get_cmdlog(void *obj)
+{
+	return obj;
+}
+
+static const struct dm_report_object_type _log_report_types[] = {
+	{ CMDLOG, "Command Log", "log_", _obj_get_cmdlog },
+	{ 0, "", "", NULL },
+};
+
 static const struct dm_report_object_type _report_types[] = {
 	{ VGS, "Volume Group", "vg_", _obj_get_vg },
 	{ LVS, "Logical Volume", "lv_", _obj_get_lv },
@@ -3656,6 +3666,8 @@ static const struct dm_report_object_type _devtypes_report_types[] = {
 	{type, sorttype, offsetof(type_ ## strct, field), width ? : sizeof(head) - 1, \
 	 #id, head, &_ ## func ## _disp, desc},
 
+typedef struct cmd_log_item type_cmd_log_item;
+
 typedef struct physical_volume type_pv;
 typedef struct logical_volume type_lv;
 typedef struct volume_group type_vg;
@@ -3675,6 +3687,11 @@ static const struct dm_report_field_type _devtypes_fields[] = {
 {0, 0, 0, 0, "", "", NULL, NULL},
 };
 
+static const struct dm_report_field_type _log_fields[] = {
+#include "columns-cmdlog.h"
+{0, 0, 0, 0, "", "", NULL, NULL},
+};
+
 #undef STR
 #undef NUM
 #undef BIN
@@ -3712,7 +3729,11 @@ void *report_init(struct cmd_context *cmd, const char *format, const char *keys,
 	if (columns_as_rows)
 		report_flags |= DM_REPORT_OUTPUT_COLUMNS_AS_ROWS;
 
-	if (*report_type & DEVTYPES) {
+	if (*report_type & CMDLOG) {
+		types = _log_report_types;
+		fields = _log_fields;
+		reserved_values = NULL;
+	} else if (*report_type & DEVTYPES) {
 		types = _devtypes_report_types;
 		fields = _devtypes_fields;
 		reserved_values = NULL;
@@ -3748,8 +3769,12 @@ const char *report_get_field_prefix(report_type_t report_type_id)
 {
 	const struct dm_report_object_type *report_types, *report_type;
 
-	report_types = report_type_id & DEVTYPES ? _devtypes_report_types
-						 : _report_types;
+	if (report_type_id & CMDLOG)
+		report_types = _log_report_types;
+	else if (report_type_id & DEVTYPES)
+		report_types = _devtypes_report_types;
+	else
+		report_types = _report_types;
 
 	for (report_type = report_types; report_type->id; report_type++) {
 		if (report_type_id & report_type->id)
@@ -3825,3 +3850,22 @@ int report_devtypes(void *handle)
 
 	return 1;
 }
+
+int report_cmdlog(void *handle, const char *type, const char *context,
+		  const char *object_type_name, const char *object_name,
+		  const char *object_id, const char *object_group,
+		  const char *object_group_id, const char *msg,
+		  int current_errno, int ret_code)
+{
+	static uint32_t seq_num = 1;
+
+	struct cmd_log_item log_item = {seq_num++, type, context, object_type_name,
+					object_name ? : "", object_id ? : "",
+					object_group ? : "", object_group_id ? : "",
+					msg ? : "", current_errno, ret_code};
+
+	if (handle)
+		return dm_report_object(handle, &log_item);
+
+	return 1;
+}
diff --git a/lib/report/report.h b/lib/report/report.h
index 8db84e0..06ffe70 100644
--- a/lib/report/report.h
+++ b/lib/report/report.h
@@ -21,16 +21,17 @@
 #include "activate.h"
 
 typedef enum {
-	LVS		= 1,
-	LVSINFO		= 2,
-	LVSSTATUS	= 4,
-	LVSINFOSTATUS   = 8,
-	PVS		= 16,
-	VGS		= 32,
-	SEGS		= 64,
-	PVSEGS		= 128,
-	LABEL		= 256,
-	DEVTYPES	= 512
+	CMDLOG		= 1,
+	LVS		= 2,
+	LVSINFO		= 4,
+	LVSSTATUS	= 8,
+	LVSINFOSTATUS   = 16,
+	PVS		= 32,
+	VGS		= 64,
+	SEGS		= 128,
+	PVSEGS		= 256,
+	LABEL		= 512,
+	DEVTYPES	= 1024
 } report_type_t;
 
 /*
@@ -58,6 +59,20 @@ struct selection_handle {
 	int selected;
 };
 
+struct cmd_log_item {
+	uint32_t seq_num;
+	const char *type;
+	const char *context;
+	const char *object_type_name;
+	const char *object_name;
+	const char *object_id;
+	const char *object_group;
+	const char *object_group_id;
+	const char *msg;
+	int current_errno;
+	int ret_code;
+};
+
 struct field;
 struct report_handle;
 struct processing_handle;
@@ -84,6 +99,11 @@ int report_object(void *handle, int selection_only, const struct volume_group *v
 		  const struct lv_with_info_and_seg_status *lvdm,
 		  const struct label *label);
 int report_devtypes(void *handle);
+int report_cmdlog(void *handle, const char *type, const char *context,
+		  const char *object_type_name, const char *object_name,
+		  const char *object_id, const char *object_group,
+		  const char *object_group_id, const char *msg,
+		  int current_errno, int ret_code);
 int report_output(void *handle);
 
 #endif
diff --git a/tools/reporter.c b/tools/reporter.c
index f572d31..6ba1b5b 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -877,6 +877,9 @@ static int _do_report(struct cmd_context *cmd, struct report_args *args)
 				r = process_each_vg(cmd, args->argc, args->argv, NULL, NULL,
 						    0, handle, &_pvsegs_in_vg);
 			break;
+		case CMDLOG:
+			/* Log is reported throughout the code via report_cmdlog calls. */
+			break;
 		default:
 			log_error(INTERNAL_ERROR "_do_report: unknown report type.");
 			return 0;
@@ -959,6 +962,10 @@ static int _config_report(struct cmd_context *cmd, struct report_args *args)
 			else
 				args->options = find_config_tree_str(cmd, report_pvsegs_cols_verbose_CFG, NULL);
 			break;
+		case CMDLOG:
+			args->keys = DEFAULT_COMMAND_LOG_SORT;
+			args->options = DEFAULT_COMMAND_LOG_COLS;
+			break;
 		default:
 			log_error(INTERNAL_ERROR "_report: unknown report type.");
 			return 0;


