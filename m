From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 18 Sep 2013 00:26:27 +0000 (UTC)
Subject: master - reporting: Add devtypes command.
Message-ID: <20130918002627.D71826113E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a3a5f58c21edba308dd8ced15860e52b5b902890
Commit:        a3a5f58c21edba308dd8ced15860e52b5b902890
Parent:        d1bcb21e02a33a03795c2e35bd4d16ea67107c5d
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Sep 18 01:09:15 2013 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Sep 18 01:09:15 2013 +0100

reporting: Add devtypes command.

Add internal devtypes reporting command to display built-in recognised
block device types.  (The output does not include any additional
types added by a configuration file.)

> lvm devtypes -o help
  Device Types Fields
  -------------------
    devtype_all            - All fields in this section.
    devtype_name           - Name of Device Type exactly as it appears in /proc/devices.
    devtype_max_partitions - Maximum number of partitions. (How many device minor numbers get reserved for each device.)
    devtype_description    - Description of Device Type.

> lvm devtypes
  DevType       MaxParts Description
  aoe                 16 ATA over Ethernet
  ataraid             16 ATA Raid
  bcache               1 bcache block device cache
  blkext               1 Extended device partitions
...
---
 WHATS_NEW                     |    1 +
 include/.symlinks.in          |    1 +
 lib/config/config_settings.h  |    3 ++
 lib/config/defaults.h         |    3 ++
 lib/report/columns-devtypes.h |   32 ++++++++++++++++++++++++
 lib/report/properties.c       |    1 -
 lib/report/report.c           |   54 ++++++++++++++++++++++++++++++++++++++++-
 lib/report/report.h           |   14 ++++++----
 man/lvm.8.in                  |    2 +
 tools/commands.h              |   24 ++++++++++++++++++
 tools/reporter.c              |   26 +++++++++++++++++++
 11 files changed, 153 insertions(+), 8 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 29fb822..df893ae 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.101 - 
 ===================================
+  Add devtypes report command to display built-in recognised block device types.
   Fix CC Makefile override which had reverted to using built-in value. (2.02.75)
   Recognise bcache block devices in filter (experimental).
   Run lvm2-activation-net after lvm2-activation service to prevent parallel run.
diff --git a/include/.symlinks.in b/include/.symlinks.in
index 6de35b8..44076c8 100644
--- a/include/.symlinks.in
+++ b/include/.symlinks.in
@@ -16,6 +16,7 @@
 @top_srcdir@/lib/device/dev-cache.h
 @top_srcdir@/lib/device/dev-type.h
 @top_srcdir@/lib/device/device.h
+ at top_srcdir@/lib/device/device-types.h
 @top_srcdir@/lib/display/display.h
 @top_srcdir@/lib/filters/filter.h
 @top_srcdir@/lib/format1/format1.h
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 3992764..3549b6d 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -209,6 +209,9 @@ cfg(report_separator_CFG, "separator", report_CFG_SECTION, 0, CFG_TYPE_STRING, D
 cfg(report_prefixes_CFG, "prefixes", report_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_REP_PREFIXES, vsn(2, 2, 36), NULL)
 cfg(report_quoted_CFG, "quoted", report_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_REP_QUOTED, vsn(2, 2, 39), NULL)
 cfg(report_colums_as_rows_CFG, "colums_as_rows", report_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_REP_COLUMNS_AS_ROWS, vsn(1, 0, 0), NULL)
+cfg(report_devtypes_sort_CFG, "devtypes_sort", report_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_DEVTYPES_SORT, vsn(2, 2, 101), NULL)
+cfg(report_devtypes_cols_CFG, "devtypes_cols", report_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_DEVTYPES_COLS, vsn(2, 2, 101), NULL)
+cfg(report_devtypes_cols_verbose_CFG, "devtypes_cols_verbose", report_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_DEVTYPES_COLS_VERB, vsn(2, 2, 101), NULL)
 cfg(report_lvs_sort_CFG, "lvs_sort", report_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_LVS_SORT, vsn(1, 0, 0), NULL)
 cfg(report_lvs_cols_CFG, "lvs_cols", report_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_LVS_COLS, vsn(1, 0, 0), NULL)
 cfg(report_lvs_cols_verbose_CFG, "lvs_cols_verbose", report_CFG_SECTION, 0, CFG_TYPE_STRING, DEFAULT_LVS_COLS_VERB, vsn(1, 0, 0), NULL)
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 5a456cf..d200331 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -165,18 +165,21 @@
 #define DEFAULT_PVS_COLS "pv_name,vg_name,pv_fmt,pv_attr,pv_size,pv_free"
 #define DEFAULT_SEGS_COLS "lv_name,vg_name,lv_attr,stripes,segtype,seg_size"
 #define DEFAULT_PVSEGS_COLS "pv_name,vg_name,pv_fmt,pv_attr,pv_size,pv_free,pvseg_start,pvseg_size"
+#define DEFAULT_DEVTYPES_COLS "devtype_name,devtype_max_partitions,devtype_description"
 
 #define DEFAULT_LVS_COLS_VERB "lv_name,vg_name,seg_count,lv_attr,lv_size,lv_major,lv_minor,lv_kernel_major,lv_kernel_minor,pool_lv,origin,data_percent,metadata_percent,move_pv,copy_percent,mirror_log,convert_lv,lv_uuid,lv_profile"
 #define DEFAULT_VGS_COLS_VERB "vg_name,vg_attr,vg_extent_size,pv_count,lv_count,snap_count,vg_size,vg_free,vg_uuid,vg_profile"
 #define DEFAULT_PVS_COLS_VERB "pv_name,vg_name,pv_fmt,pv_attr,pv_size,pv_free,dev_size,pv_uuid"
 #define DEFAULT_SEGS_COLS_VERB "lv_name,vg_name,lv_attr,seg_start,seg_size,stripes,segtype,stripesize,chunksize"
 #define DEFAULT_PVSEGS_COLS_VERB "pv_name,vg_name,pv_fmt,pv_attr,pv_size,pv_free,pvseg_start,pvseg_size,lv_name,seg_start_pe,segtype,seg_pe_ranges"
+#define DEFAULT_DEVTYPES_COLS_VERB "devtype_name,devtype_max_partitions,devtype_description"
 
 #define DEFAULT_LVS_SORT "vg_name,lv_name"
 #define DEFAULT_VGS_SORT "vg_name"
 #define DEFAULT_PVS_SORT "pv_name"
 #define DEFAULT_SEGS_SORT "vg_name,lv_name,seg_start"
 #define DEFAULT_PVSEGS_SORT "pv_name,pvseg_start"
+#define DEFAULT_DEVTYPES_SORT "devtype_name"
 
 #define DEFAULT_MIRROR_DEVICE_FAULT_POLICY "remove"
 #define DEFAULT_MIRROR_LOG_FAULT_POLICY "allocate"
diff --git a/lib/report/columns-devtypes.h b/lib/report/columns-devtypes.h
new file mode 100644
index 0000000..5f61890
--- /dev/null
+++ b/lib/report/columns-devtypes.h
@@ -0,0 +1,32 @@
+/*
+ * Copyright (C) 2013 Red Hat, Inc. All rights reserved.
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
+ * This file defines the fields (columns) for the devtypes reporting command.
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
+FIELD(DEVTYPES, devtype, STR, "DevType", name, 7, chars, devtype_name, "Name of Device Type exactly as it appears in /proc/devices.", 0)
+FIELD(DEVTYPES, devtype, NUM, "MaxParts", max_partitions, 8, int8, devtype_max_partitions, "Maximum number of partitions. (How many device minor numbers get reserved for each device.)", 0)
+FIELD(DEVTYPES, devtype, STR, "Description", desc, 11, string, devtype_description, "Description of Device Type.", 0)
+/* *INDENT-ON* */
diff --git a/lib/report/properties.c b/lib/report/properties.c
index 3eeb78a..62a1a35 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -331,7 +331,6 @@ GET_PVSEG_NUM_PROPERTY_FN(pvseg_start, pvseg->pe)
 GET_PVSEG_NUM_PROPERTY_FN(pvseg_size, (SECTOR_SIZE * pvseg->len))
 #define _pvseg_size_set prop_not_implemented_set
 
-
 struct lvm_property_type _properties[] = {
 #include "columns.h"
 	{ 0, "", 0, 0, 0, { .integer = 0 }, prop_not_implemented_get, prop_not_implemented_set },
diff --git a/lib/report/report.c b/lib/report/report.c
index 77332a2..347b830 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -22,6 +22,7 @@
 #include "activate.h"
 #include "segtype.h"
 #include "lvmcache.h"
+#include "device-types.h"
 
 #include <stddef.h> /* offsetof() */
 
@@ -47,6 +48,13 @@ static int _string_disp(struct dm_report *rh, struct dm_pool *mem __attribute__(
 	return dm_report_field_string(rh, field, (const char * const *) data);
 }
 
+static int _chars_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
+		       struct dm_report_field *field,
+		       const void *data, void *private __attribute__((unused)))
+{
+	return dm_report_field_string(rh, field, (const char * const *) &data);
+}
+
 static int _dev_name_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
 			  struct dm_report_field *field,
 			  const void *data, void *private __attribute__((unused)))
@@ -456,6 +464,15 @@ static int _uint32_disp(struct dm_report *rh, struct dm_pool *mem __attribute__(
 	return dm_report_field_uint32(rh, field, data);
 }
 
+static int _int8_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
+		       struct dm_report_field *field,
+		       const void *data, void *private __attribute__((unused)))
+{
+	const int32_t val = *(const int8_t *)data;
+
+	return dm_report_field_int32(rh, field, &val);
+}
+
 static int _int32_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
 		       struct dm_report_field *field,
 		       const void *data, void *private __attribute__((unused)))
@@ -1270,6 +1287,11 @@ static void *_obj_get_pvseg(void *obj)
 	return ((struct lvm_report_object *)obj)->pvseg;
 }
 
+static void *_obj_get_devtypes(void *obj)
+{
+	return obj;
+}
+
 static const struct dm_report_object_type _report_types[] = {
 	{ VGS, "Volume Group", "vg_", _obj_get_vg },
 	{ LVS, "Logical Volume", "lv_", _obj_get_lv },
@@ -1280,6 +1302,11 @@ static const struct dm_report_object_type _report_types[] = {
 	{ 0, "", "", NULL },
 };
 
+static const struct dm_report_object_type _devtypes_report_types[] = {
+	{ DEVTYPES, "Device Types", "devtype_", _obj_get_devtypes },
+	{ 0, "", "", NULL },
+};
+
 /*
  * Import column definitions
  */
@@ -1296,11 +1323,18 @@ typedef struct volume_group type_vg;
 typedef struct lv_segment type_seg;
 typedef struct pv_segment type_pvseg;
 
+typedef dev_known_type_t type_devtype;
+
 static const struct dm_report_field_type _fields[] = {
 #include "columns.h"
 {0, 0, 0, 0, "", "", NULL, NULL},
 };
 
+static const struct dm_report_field_type _devtypes_fields[] = {
+#include "columns-devtypes.h"
+{0, 0, 0, 0, "", "", NULL, NULL},
+};
+
 #undef STR
 #undef NUM
 #undef FIELD
@@ -1311,6 +1345,7 @@ void *report_init(struct cmd_context *cmd, const char *format, const char *keys,
 		  int quoted, int columns_as_rows)
 {
 	uint32_t report_flags = 0;
+	int devtypes_report = *report_type & DEVTYPES ? 1 : 0;
 	void *rh;
 
 	if (aligned)
@@ -1331,7 +1366,8 @@ void *report_init(struct cmd_context *cmd, const char *format, const char *keys,
 	if (columns_as_rows)
 		report_flags |= DM_REPORT_OUTPUT_COLUMNS_AS_ROWS;
 
-	rh = dm_report_init(report_type, _report_types, _fields, format,
+	rh = dm_report_init(report_type, devtypes_report ? _devtypes_report_types : _report_types,
+			    devtypes_report ? _devtypes_fields : _fields, format,
 			    separator, report_flags, keys, cmd);
 
 	if (rh && field_prefixes)
@@ -1361,3 +1397,19 @@ int report_object(void *handle, struct volume_group *vg,
 
 	return dm_report_object(handle, &obj);
 }
+
+static int _report_devtype_single(void *handle, const dev_known_type_t *devtype)
+{
+	return dm_report_object(handle, (void *)devtype);
+}
+
+int report_devtypes(void *handle)
+{
+	int devtypeind = 0;
+
+	while (_dev_known_types[devtypeind].name[0])
+		if (!_report_devtype_single(handle, &_dev_known_types[devtypeind++]))
+			return 0;
+
+	return 1;
+}
diff --git a/lib/report/report.h b/lib/report/report.h
index 26cc2f7..bda8553 100644
--- a/lib/report/report.h
+++ b/lib/report/report.h
@@ -19,12 +19,13 @@
 #include "metadata-exported.h"
 
 typedef enum {
-	LVS	= 1,
-	PVS	= 2,
-	VGS	= 4,
-	SEGS	= 8,
-	PVSEGS	= 16,
-	LABEL	= 32
+	LVS		= 1,
+	PVS		= 2,
+	VGS		= 4,
+	SEGS		= 8,
+	PVSEGS		= 16,
+	LABEL		= 32,
+	DEVTYPES	= 64
 } report_type_t;
 
 struct field;
@@ -41,6 +42,7 @@ void report_free(void *handle);
 int report_object(void *handle, struct volume_group *vg,
 		  struct logical_volume *lv, struct physical_volume *pv,
 		  struct lv_segment *seg, struct pv_segment *pvseg);
+int report_devtypes(void *handle);
 int report_output(void *handle);
 
 #endif
diff --git a/man/lvm.8.in b/man/lvm.8.in
index 61fd74a..da471ab 100644
--- a/man/lvm.8.in
+++ b/man/lvm.8.in
@@ -46,6 +46,8 @@ being created in the filesystem for them.
 \fBdumpconfig\fP \(em Display the configuration information after
 loading \fBlvm.conf\fP(5) and any other configuration files.
 .TP
+\fBdevtypes\fP \(dm Display the recognised built-in block device types.
+.TP
 \fBformats\fP \(em Display recognised metadata formats.
 .TP
 \fBhelp\fP \(em Display the help text.
diff --git a/tools/commands.h b/tools/commands.h
index a8623bf..a0cd5d7 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -28,6 +28,30 @@ xx(e2fsadm,
     extents_ARG, size_ARG, nofsck_ARG, test_ARG)
 *********/
 
+xx(devtypes,
+   "Display recognised built-in block device types",
+   PERMITTED_READ_ONLY,
+   "devtypes" "\n"
+   "\t[--aligned]\n"
+   "\t[-d|--debug]\n"
+   "\t[-h|--help]\n"
+   "\t[--nameprefixes]\n"
+   "\t[--noheadings]\n"
+   "\t[--nosuffix]\n"
+   "\t[-o|--options [+]Field[,Field]]\n"
+   "\t[-O|--sort [+|-]key1[,[+|-]key2[,...]]]\n"
+   "\t[--rows]\n"
+   "\t[--separator Separator]\n"
+   "\t[--unbuffered]\n"
+   "\t[--unquoted]\n"
+   "\t[-v|--verbose]\n"
+   "\t[--version]" "\n",
+
+   aligned_ARG, nameprefixes_ARG,
+   noheadings_ARG, nosuffix_ARG, options_ARG,
+   rows_ARG, separator_ARG, sort_ARG,
+   unbuffered_ARG, unquoted_ARG)
+
 xx(dumpconfig,
    "Dump configuration",
    PERMITTED_READ_ONLY,
diff --git a/tools/reporter.c b/tools/reporter.c
index a6941e3..44a9aa8 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -16,6 +16,17 @@
 #include "tools.h"
 #include "report.h"
 
+static int _process_each_devtype(struct cmd_context *cmd, int argc, void *handle)
+{
+	if (argc)
+		log_warn("WARNING: devtypes currently ignores command line arguments.");
+
+	if (!report_devtypes(handle))
+		return_ECMD_FAILED;
+
+	return ECMD_PROCESSED;
+}
+
 static int _vgs_single(struct cmd_context *cmd __attribute__((unused)),
 		       const char *vg_name, struct volume_group *vg,
 		       void *handle)
@@ -235,6 +246,13 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 			report_type == PVSEGS) ? 1 : 0;
 
 	switch (report_type) {
+	case DEVTYPES:
+		keys = find_config_tree_str(cmd, report_devtypes_sort_CFG, NULL);
+		if (!arg_count(cmd, verbose_ARG))
+			options = find_config_tree_str(cmd, report_devtypes_cols_CFG, NULL);
+		else
+			options = find_config_tree_str(cmd, report_devtypes_cols_verbose_CFG, NULL);
+		break;
 	case LVS:
 		keys = find_config_tree_str(cmd, report_lvs_sort_CFG, NULL);
 		if (!arg_count(cmd, verbose_ARG))
@@ -350,6 +368,9 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 		report_type = LVS;
 
 	switch (report_type) {
+	case DEVTYPES:
+		r = _process_each_devtype(cmd, argc, report_handle);
+		break;
 	case LVS:
 		r = process_each_lv(cmd, argc, argv, 0, report_handle,
 				    &_lvs_single);
@@ -418,3 +439,8 @@ int pvs(struct cmd_context *cmd, int argc, char **argv)
 
 	return _report(cmd, argc, argv, type);
 }
+
+int devtypes(struct cmd_context *cmd, int argc, char **argv)
+{
+	return _report(cmd, argc, argv, DEVTYPES);
+}


