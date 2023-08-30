From: Peter Rajnoha (@prajnoha) <gitlab@mg.gitlab.com>
Date: Wed, 30 Aug 2023 10:07:51 +0000
Subject: [Git][lvmteam/lvm2][main] 6 commits: libdm: report: support reporting field IDs in headings
Message-ID: <64ef14f7b4d19_28a85985948@gitlab-sidekiq-low-urgency-cpu-bound-v2-5d49b59bf-67mgj.mail>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



Peter Rajnoha pushed to branch main at LVM team / lvm2


Commits:
12b60e7c by Peter Rajnoha at 2023-08-28T15:44:57+02:00
libdm: report: support reporting field IDs in headings

Add new DM_REPORT_OUTPUT_FIELD_IDS_IN_HEADINGS report output flag.
If enabled, column IDs are reported instead of column names in report
headings.

The &#39;column IDs&#39; are IDs as found in &#39;const struct dm_report_field_type *fields&#39;
array that is passed during report initialization (that is, a call to
dm_report_init/dm_report_init_with_selection). In this case, the &#39;id&#39;
dm_report_field_type member is used instead of the &#39;heading&#39; member.

- - - - -
14d0a9ee by Peter Rajnoha at 2023-08-28T15:44:57+02:00
report: support printing full column names in report headings

Reuse existing report/headings config setting to make it possible to
change the type of headings to display:
  0 - no headings
  1 - column name abbreviations (default and original functionality)
  2 - full column names (column names are equal to exact names that
      -o|--options also accepts to set report output)

Also, add &#39;--headings none|abbrev|full|0|1|2&#39; command line option
so we are able to select the heading type for each LVM reporting
command directly.

- - - - -
5a1248f1 by Peter Rajnoha at 2023-08-28T15:44:57+02:00
dmsetup: support printing full column names in report headings

Add &#39;--headings none|abbrev|full|0|1|2&#39; command line option to select
the heading type.

  none|0   - no headings
  abbrev|1 - column name abbreviations
  full|2   - full column names (column names are equal to exact names
             that -o|--options also accepts to set report output)

- - - - -
5a6d1369 by Peter Rajnoha at 2023-08-28T15:44:58+02:00
make: generate

- - - - -
2ab2da5e by Peter Rajnoha at 2023-08-28T15:44:58+02:00
man: update lvmreport man page about report/headings and --headings

- - - - -
1f02c5f2 by Peter Rajnoha at 2023-08-28T15:44:58+02:00
tests: add shell/report-headings.sh

- - - - -


25 changed files:

- WHATS_NEW
- WHATS_NEW_DM
- conf/example.conf.in
- device_mapper/all.h
- device_mapper/libdm-report.c
- lib/config/config_settings.h
- lib/report/report.c
- lib/report/report.h
- libdm/dm-tools/dmsetup.c
- libdm/libdevmapper.h
- libdm/libdm-report.c
- man/dmsetup.8_main
- man/lvm-fullreport.8_pregen
- man/lvmreport.7_main
- man/lvs.8_pregen
- man/pvs.8_pregen
- man/vgs.8_pregen
- + test/shell/report-headings.sh
- tools/args.h
- tools/command-lines.in
- tools/command.c
- tools/lvmcmdline.c
- tools/reporter.c
- tools/tools.h
- tools/vals.h


Changes:

=====================================
WHATS_NEW
=====================================
@@ -1,5 +1,7 @@
 version 2.03.23 - 
 ==================================
+  Recognize lvm.conf report/headings=2 for full column names in report headings.
+  Add --headings none|abbrev|full cmd line option to set report headings type.
   Require writable LV for convertion to vdo pool.
   Fix return value from lvconvert integrity remove.
   Preserve UUID for pool metadata spare.


=====================================
WHATS_NEW_DM
=====================================
@@ -1,5 +1,7 @@
 Version 1.02.197 - 
 ===================================
+  Add dmsetup --headings none|abbrev|full to set report headings type.
+  Add DM_REPORT_OUTPUT_FIELD_IDS_IN_HEADINGS to provide alternative headings.
 
 Version 1.02.196 - 02nd August 2023
 ===================================


=====================================
conf/example.conf.in
=====================================
@@ -2017,7 +2017,11 @@ activation {
 	# buffered = 1
 
 	# Configuration option report/headings.
-	# Show headings for columns on report.
+	# Format of LVM command's report output headings.
+	# Accepted values:
+	#   0 no headings,
+	#   1 headings with column abbreviations,
+	#   2 headings with full column names.
 	# This configuration option has an automatic default value.
 	# headings = 1
 


=====================================
device_mapper/all.h
=====================================
@@ -1875,6 +1875,7 @@ const void *dm_report_value_cache_get(struct dm_report *rh, const char *name);
 #define DM_REPORT_OUTPUT_FIELD_UNQUOTED		0x00000010
 #define DM_REPORT_OUTPUT_COLUMNS_AS_ROWS	0x00000020
 #define DM_REPORT_OUTPUT_MULTIPLE_TIMES		0x00000040
+#define DM_REPORT_OUTPUT_FIELD_IDS_IN_HEADINGS	0x00000080
 
 struct dm_report *dm_report_init(uint32_t *report_types,
 				 const struct dm_report_object_type *types,


=====================================
device_mapper/libdm-report.c
=====================================
@@ -4263,7 +4263,9 @@ static int _report_headings(struct dm_report *rh)
 
 		fields = fp->implicit ? _implicit_report_fields : rh->fields;
 
-		heading = fields[fp->field_num].heading;
+		heading = rh->flags & DM_REPORT_OUTPUT_FIELD_IDS_IN_HEADINGS ?
+				fields[fp->field_num].id : fields[fp->field_num].heading;
+
 		if (rh->flags & DM_REPORT_OUTPUT_ALIGNED) {
 			if (dm_snprintf(buf, buf_size, "%-*.*s",
 					 fp->width, fp->width, heading) < 0) {
@@ -4315,6 +4317,7 @@ static void _recalculate_fields(struct dm_report *rh)
 	struct row *row;
 	struct dm_report_field *field;
 	int len;
+	size_t id_len;
 
 	dm_list_iterate_items(row, &rh->rows) {
 		dm_list_iterate_items(field, &row->fields) {
@@ -4329,6 +4332,12 @@ static void _recalculate_fields(struct dm_report *rh)
 					field->props->width = len;
 
 			}
+
+			if (rh->flags & DM_REPORT_OUTPUT_FIELD_IDS_IN_HEADINGS) {
+				id_len = strlen(rh->fields[field->props->field_num].id);
+				if (field->props->width < id_len)
+					field->props->width = id_len;
+			}
 		}
 	}
 
@@ -4740,6 +4749,7 @@ static int _output_as_rows(struct dm_report *rh)
 	struct field_properties *fp;
 	struct dm_report_field *field;
 	struct row *row;
+	const char *heading;
 
 	dm_list_iterate_items(fp, &rh->field_props) {
 		if (fp->flags & FLD_HIDDEN) {
@@ -4758,7 +4768,10 @@ static int _output_as_rows(struct dm_report *rh)
 		}
 
 		if ((rh->flags & DM_REPORT_OUTPUT_HEADINGS)) {
-			if (!dm_pool_grow_object(rh->mem, fields[fp->field_num].heading, 0)) {
+			heading = rh->flags & DM_REPORT_OUTPUT_FIELD_IDS_IN_HEADINGS ?
+				fields[fp->field_num].id : fields[fp->field_num].heading;
+
+			if (!dm_pool_grow_object(rh->mem, heading, 0)) {
 				log_error("dm_report: Failed to extend row for field name");
 				goto bad;
 			}


=====================================
lib/config/config_settings.h
=====================================
@@ -1863,8 +1863,12 @@ cfg(report_buffered_CFG, "buffered", report_CFG_SECTION, CFG_PROFILABLE | CFG_DE
 	"execution. Otherwise, if buffering is not used, each object is\n"
 	"reported as soon as its processing is finished.\n")
 
-cfg(report_headings_CFG, "headings", report_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_REP_HEADINGS, vsn(1, 0, 0), NULL, 0, NULL,
-	"Show headings for columns on report.\n")
+cfg(report_headings_CFG, "headings", report_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_REP_HEADINGS, vsn(1, 0, 0), NULL, 0, NULL,
+	"Format of LVM command's report output headings.\n"
+	"Accepted values:\n"
+	"  0 no headings,\n"
+	"  1 headings with column abbreviations,\n"
+	"  2 headings with full column names.\n")
 
 cfg(report_separator_CFG, "separator", report_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_REP_SEPARATOR, vsn(1, 0, 0), NULL, 0, NULL,
 	"A separator to use on report after each field.\n")


=====================================
lib/report/report.c
=====================================
@@ -4421,11 +4421,28 @@ static const struct dm_report_field_type _log_fields[] = {
 #undef SNUM
 #undef FIELD
 
+report_headings_t report_headings_str_to_type(const char *str)
+{
+	if (!str || !*str)
+		return REPORT_HEADINGS_UNKNOWN;
+
+	if (!strcmp(str, "none") || !strcmp(str, "0"))
+		return REPORT_HEADINGS_NONE;
+
+	if (!strcmp(str, "abbrev") || !strcmp(str, "1"))
+		return REPORT_HEADINGS_ABBREV;
+
+	if (!strcmp(str, "full") || !strcmp(str, "2"))
+		return REPORT_HEADINGS_FULL;
+
+	return REPORT_HEADINGS_UNKNOWN;
+}
+
 void *report_init(struct cmd_context *cmd, const char *format, const char *keys,
 		  report_type_t *report_type, const char *separator,
-		  int aligned, int buffered, int headings, int field_prefixes,
-		  int quoted, int columns_as_rows, const char *selection,
-		  int multiple_output)
+		  int aligned, int buffered, report_headings_t headings,
+		  int field_prefixes, int quoted, int columns_as_rows,
+		  const char *selection, int multiple_output)
 {
 	uint32_t report_flags = 0;
 	const struct dm_report_object_type *types;
@@ -4439,8 +4456,12 @@ void *report_init(struct cmd_context *cmd, const char *format, const char *keys,
 	if (buffered)
 		report_flags |= DM_REPORT_OUTPUT_BUFFERED;
 
-	if (headings)
+	if (headings) {
+		/* any out of bound headings type value maps to REPORT_HEADINGS_ABBREV */
 		report_flags |= DM_REPORT_OUTPUT_HEADINGS;
+		if (headings == REPORT_HEADINGS_FULL)
+			report_flags |= DM_REPORT_OUTPUT_FIELD_IDS_IN_HEADINGS;
+	}
 
 	if (field_prefixes)
 		report_flags |= DM_REPORT_OUTPUT_FIELD_NAME_PREFIX;


=====================================
lib/report/report.h
=====================================
@@ -35,6 +35,13 @@ typedef enum {
 	DEVTYPES	= 2048
 } report_type_t;
 
+typedef enum {
+	REPORT_HEADINGS_UNKNOWN  = -1,
+	REPORT_HEADINGS_NONE     =  0,
+	REPORT_HEADINGS_ABBREV   =  1,
+	REPORT_HEADINGS_FULL     =  2
+} report_headings_t;
+
 /*
  * The "struct selection_handle" is used only for selection
  * of items that should be processed further (not for display!).
@@ -81,13 +88,15 @@ struct processing_handle;
 typedef int (*field_report_fn) (struct report_handle * dh, struct field * field,
 				const void *data);
 
+report_headings_t report_headings_str_to_type(const char *str);
+
 int report_format_init(struct cmd_context *cmd);
 
 void *report_init(struct cmd_context *cmd, const char *format, const char *keys,
 		  report_type_t *report_type, const char *separator,
-		  int aligned, int buffered, int headings, int field_prefixes,
-		  int quoted, int columns_as_rows, const char *selection,
-		  int multiple_output);
+		  int aligned, int buffered, report_headings_t headings,
+		  int field_prefixes, int quoted, int columns_as_rows,
+		  const char *selection, int multiple_output);
 int report_get_single_selection(struct cmd_context *cmd, report_type_t report_type, const char **selection);
 void *report_init_for_selection(struct cmd_context *cmd, report_type_t *report_type,
 				const char *selection);


=====================================
libdm/dm-tools/dmsetup.c
=====================================
@@ -178,6 +178,7 @@ enum {
 	GID_ARG,
 	GROUP_ARG,
 	GROUP_ID_ARG,
+	HEADINGS_ARG,
 	HELP_ARG,
 	HISTOGRAM_ARG,
 	INACTIVE_ARG,
@@ -4775,6 +4776,11 @@ static int _report_init(const struct command *cmd, const char *subcommand)
 		_report_type |= DR_STATS_META;
 	}
 
+	if (_switches[NOHEADINGS_ARG] && _switches[HEADINGS_ARG]) {
+		log_error("Only one of --headings and --noheadings permitted.");
+		return 0;
+	}
+
 	/* emulate old dmsetup behaviour */
 	if (_switches[NOHEADINGS_ARG]) {
 		separator = ":";
@@ -4782,6 +4788,9 @@ static int _report_init(const struct command *cmd, const char *subcommand)
 		headings = 0;
 	}
 
+	if (_switches[HEADINGS_ARG])
+		headings = _int_args[HEADINGS_ARG];
+
 	if (_switches[UNBUFFERED_ARG])
 		buffered = 0;
 
@@ -4848,8 +4857,11 @@ static int _report_init(const struct command *cmd, const char *subcommand)
 	if (buffered)
 		flags |= DM_REPORT_OUTPUT_BUFFERED;
 
-	if (headings)
+	if (headings) {
 		flags |= DM_REPORT_OUTPUT_HEADINGS;
+		if (headings == 2)
+			flags |= DM_REPORT_OUTPUT_FIELD_IDS_IN_HEADINGS;
+	}
 
 	if (field_prefixes)
 		flags |= DM_REPORT_OUTPUT_FIELD_NAME_PREFIX;
@@ -6166,7 +6178,8 @@ static int _stats_help(CMD_ARGS);
  *       [--units <u>] [--programid <id>] [--regionid <id>]
  *       [-o <fields>] [-O|--sort <sort_fields>]
  *       [-S|--select <selection>] [--nameprefixes]
- *       [--noheadings] [--separator <separator>]
+ *       [--noheadings|--headings none|abbrev|full|0|1|2]
+ *       [--separator <separator>]
  *       [--allprograms|--programid id] [<device>...]
  *   ungroup --groupid <id> [--allprograms|--programid id]
  *       [--alldevices|<device>...]
@@ -6336,7 +6349,8 @@ static void _dmsetup_usage(FILE *out)
 		"        [--udevcookie <cookie>] [--noudevrules] [--noudevsync] [--verifyudev]\n"
 		"        [-y|--yes] [--readahead {[+]<sectors>|auto|none}] [--retry]\n"
 		"        [-c|-C|--columns] [-o <fields>] [-O|--sort <sort_fields>]\n"
-		"        [-S|--select <selection>] [--nameprefixes] [--noheadings]\n"
+		"        [-S|--select <selection>] [--nameprefixes]\n"
+		"        [--noheadings|--headings none|abbrev|full|0|1|2]\n"
 		"        [--separator <separator>]\n\n",
 		_base_commands[_base_command].name);
 
@@ -6866,6 +6880,7 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 		{"gid", 1, &ind, GID_ARG},
 		{"group", 0, &ind, GROUP_ARG},
 		{"groupid", 1, &ind, GROUP_ID_ARG},
+		{"headings", 1, &ind, HEADINGS_ARG},
 		{"help", 0, &ind, HELP_ARG},
 		{"histogram", 0, &ind, HISTOGRAM_ARG},
 		{"inactive", 0, &ind, INACTIVE_ARG},
@@ -7170,6 +7185,19 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 			_switches[EXEC_ARG]++;
 			_command_to_exec = optarg;
 		}
+		if (ind == HEADINGS_ARG) {
+			_switches[HEADINGS_ARG]++;
+			if (!strcasecmp(optarg, "none") || !strcmp(optarg, "0"))
+				_int_args[HEADINGS_ARG] = 0;
+			else if (!strcasecmp(optarg, "abbrev") || !strcmp(optarg, "1"))
+				_int_args[HEADINGS_ARG] = 1;
+			else if (!strcasecmp(optarg, "full") || !strcmp(optarg, "2"))
+				_int_args[HEADINGS_ARG] = 2;
+			else {
+				log_error("Unknown headings type.");
+				return 0;
+			}
+		}
 		if (ind == TARGET_ARG) {
 			_switches[TARGET_ARG]++;
 			_target = optarg;


=====================================
libdm/libdevmapper.h
=====================================
@@ -3058,6 +3058,7 @@ const void *dm_report_value_cache_get(struct dm_report *rh, const char *name);
 #define DM_REPORT_OUTPUT_FIELD_UNQUOTED		0x00000010
 #define DM_REPORT_OUTPUT_COLUMNS_AS_ROWS	0x00000020
 #define DM_REPORT_OUTPUT_MULTIPLE_TIMES		0x00000040
+#define DM_REPORT_OUTPUT_FIELD_IDS_IN_HEADINGS	0x00000080
 
 struct dm_report *dm_report_init(uint32_t *report_types,
 				 const struct dm_report_object_type *types,


=====================================
libdm/libdm-report.c
=====================================
@@ -4262,7 +4262,9 @@ static int _report_headings(struct dm_report *rh)
 
 		fields = fp->implicit ? _implicit_report_fields : rh->fields;
 
-		heading = fields[fp->field_num].heading;
+		heading = rh->flags & DM_REPORT_OUTPUT_FIELD_IDS_IN_HEADINGS ?
+				fields[fp->field_num].id : fields[fp->field_num].heading;
+
 		if (rh->flags & DM_REPORT_OUTPUT_ALIGNED) {
 			if (dm_snprintf(buf, buf_size, "%-*.*s",
 					 fp->width, fp->width, heading) < 0) {
@@ -4314,6 +4316,7 @@ static void _recalculate_fields(struct dm_report *rh)
 	struct row *row;
 	struct dm_report_field *field;
 	int len;
+	size_t id_len;
 
 	dm_list_iterate_items(row, &rh->rows) {
 		dm_list_iterate_items(field, &row->fields) {
@@ -4328,6 +4331,12 @@ static void _recalculate_fields(struct dm_report *rh)
 					field->props->width = len;
 
 			}
+
+			if (rh->flags & DM_REPORT_OUTPUT_FIELD_IDS_IN_HEADINGS) {
+				id_len = strlen(rh->fields[field->props->field_num].id);
+				if (field->props->width < id_len)
+					field->props->width = id_len;
+			}
 		}
 	}
 
@@ -4739,6 +4748,7 @@ static int _output_as_rows(struct dm_report *rh)
 	struct field_properties *fp;
 	struct dm_report_field *field;
 	struct row *row;
+	const char *heading;
 
 	dm_list_iterate_items(fp, &rh->field_props) {
 		if (fp->flags & FLD_HIDDEN) {
@@ -4757,7 +4767,10 @@ static int _output_as_rows(struct dm_report *rh)
 		}
 
 		if ((rh->flags & DM_REPORT_OUTPUT_HEADINGS)) {
-			if (!dm_pool_grow_object(rh->mem, fields[fp->field_num].heading, 0)) {
+			heading = rh->flags & DM_REPORT_OUTPUT_FIELD_IDS_IN_HEADINGS ?
+				fields[fp->field_num].id : fields[fp->field_num].heading;
+
+			if (!dm_pool_grow_object(rh->mem, heading, 0)) {
 				log_error("dm_report: Failed to extend row for field name");
 				goto bad;
 			}


=====================================
man/dmsetup.8_main
=====================================
@@ -91,6 +91,7 @@ dmsetup \(em low level logical volume management
 .  IR fields ]
 .  RB [ -O | --sort
 .  IR sort_fields ]
+.  RB [ --idsinheadings ]
 .  RB [ --nameprefixes ]
 .  RB [ --separator
 .  IR separator ]
@@ -502,6 +503,10 @@ Specify the minor number.
 When creating a device, don't load any table.
 .
 .TP
+.B --idsinheadings
+Show column identifiers instead of names in report output headings.
+.
+.TP
 .B --nameprefixes
 Add a "DM_" prefix plus the field name to the output.  Useful with
 \fB--noheadings\fP to produce a list of


=====================================
man/lvm-fullreport.8_pregen
=====================================
@@ -43,6 +43,8 @@ if information changes between commands.
 .br
 [    \fB--foreign\fP ]
 .br
+[    \fB--headings\fP \fBnone\fP|\fBabbrev\fP|\fBfull\fP|\fB0\fP|\fB1\fP|\fB2\fP ]
+.br
 [    \fB--ignorelockingfailure\fP ]
 .br
 [    \fB--logonly\fP ]
@@ -196,6 +198,14 @@ Report/display foreign VGs that would otherwise be skipped.
 See \fBlvmsystemid\fP(7) for more information about foreign VGs.
 .
 .HP
+\fB--headings\fP \fBnone\fP|\fBabbrev\fP|\fBfull\fP|\fB0\fP|\fB1\fP|\fB2\fP
+.br
+Type of headings to use in report output.
+\fBnone\fP or \fB0\fP: No headings.
+\fBabbrev\fP or \fB1\fP: Column name abbreviations.
+\fBfull\fP or \fB2\fP: Full column names.
+.
+.HP
 \fB-h\fP|\fB--help\fP
 .br
 Display help text.


=====================================
man/lvmreport.7_main
=====================================
@@ -181,12 +181,15 @@ Overrides report/aligned configuration setting.
 .TP
 .B --binary
 Overrides report/binary_values_as_numeric configuration setting.
+TP
+.B --headings
+Overrides report/headings congiguration settings.
 .TP
 .B --nameprefixes
 Overrides report/prefixes configuration setting.
 .TP
 .B --noheadings
-Overrides report/noheadings configuration setting.
+Overrides report/headings configuration setting.
 .TP
 .B --nosuffix
 Overrides global/suffix configuration setting.
@@ -1298,6 +1301,26 @@ binary_values_as_numeric=1
   lvol1 4.00m 100.00            1
   lvol0 4.00m                   1
 .fi
+.P
+In certain cases, you may find it more useful to report full column names
+instead of abbreviated column names in report headings. To do this, use
+\fBreport/headings=2\fP configuration setting (or \fB--headings full\fP
+or \fB--headings 2\fP command line option). The full column names are
+the exact names that you also use in \fIFieldSet\fP for \fB-o|--options\fP.
+These names are unambiguous, without spaces (one word only) and they also
+make it easier to match the output with requested \fIFieldSet\fP:
+.P
+.nf
+# lvs -o+seg_start,seg_start_pe
+  LV    VG LSize Cpy%Sync Start Start
+  lvol0 vg 4.00m             0      0
+  lvol1 vg 4.00m 100.00      0      0
+
+# lvs --headings full -o+seg_start,seg_start_pe
+  lv_name vg_name lv_size copy_percent seg_start seg_start_pe
+  lvol0   vg        4.00m                     0             0
+  lvol1   vg        4.00m 100.00              0             0
+.fi
 .
 .SS Changing output format
 .


=====================================
man/lvs.8_pregen
=====================================
@@ -43,6 +43,8 @@ lvs produces formatted output about LVs.
 .br
 [    \fB--foreign\fP ]
 .br
+[    \fB--headings\fP \fBnone\fP|\fBabbrev\fP|\fBfull\fP|\fB0\fP|\fB1\fP|\fB2\fP ]
+.br
 [    \fB--ignorelockingfailure\fP ]
 .br
 [    \fB--logonly\fP ]
@@ -199,6 +201,14 @@ Report/display foreign VGs that would otherwise be skipped.
 See \fBlvmsystemid\fP(7) for more information about foreign VGs.
 .
 .HP
+\fB--headings\fP \fBnone\fP|\fBabbrev\fP|\fBfull\fP|\fB0\fP|\fB1\fP|\fB2\fP
+.br
+Type of headings to use in report output.
+\fBnone\fP or \fB0\fP: No headings.
+\fBabbrev\fP or \fB1\fP: Column name abbreviations.
+\fBfull\fP or \fB2\fP: Full column names.
+.
+.HP
 \fB-h\fP|\fB--help\fP
 .br
 Display help text.


=====================================
man/pvs.8_pregen
=====================================
@@ -41,6 +41,8 @@ pvs produces formatted output about PVs.
 .br
 [    \fB--foreign\fP ]
 .br
+[    \fB--headings\fP \fBnone\fP|\fBabbrev\fP|\fBfull\fP|\fB0\fP|\fB1\fP|\fB2\fP ]
+.br
 [    \fB--ignorelockingfailure\fP ]
 .br
 [    \fB--logonly\fP ]
@@ -196,6 +198,14 @@ Report/display foreign VGs that would otherwise be skipped.
 See \fBlvmsystemid\fP(7) for more information about foreign VGs.
 .
 .HP
+\fB--headings\fP \fBnone\fP|\fBabbrev\fP|\fBfull\fP|\fB0\fP|\fB1\fP|\fB2\fP
+.br
+Type of headings to use in report output.
+\fBnone\fP or \fB0\fP: No headings.
+\fBabbrev\fP or \fB1\fP: Column name abbreviations.
+\fBfull\fP or \fB2\fP: Full column names.
+.
+.HP
 \fB-h\fP|\fB--help\fP
 .br
 Display help text.


=====================================
man/vgs.8_pregen
=====================================
@@ -39,6 +39,8 @@ vgs produces formatted output about VGs.
 .br
 [    \fB--foreign\fP ]
 .br
+[    \fB--headings\fP \fBnone\fP|\fBabbrev\fP|\fBfull\fP|\fB0\fP|\fB1\fP|\fB2\fP ]
+.br
 [    \fB--ignorelockingfailure\fP ]
 .br
 [    \fB--logonly\fP ]
@@ -193,6 +195,14 @@ Report/display foreign VGs that would otherwise be skipped.
 See \fBlvmsystemid\fP(7) for more information about foreign VGs.
 .
 .HP
+\fB--headings\fP \fBnone\fP|\fBabbrev\fP|\fBfull\fP|\fB0\fP|\fB1\fP|\fB2\fP
+.br
+Type of headings to use in report output.
+\fBnone\fP or \fB0\fP: No headings.
+\fBabbrev\fP or \fB1\fP: Column name abbreviations.
+\fBfull\fP or \fB2\fP: Full column names.
+.
+.HP
 \fB-h\fP|\fB--help\fP
 .br
 Display help text.


=====================================
test/shell/report-headings.sh
=====================================
@@ -0,0 +1,130 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2023 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+SKIP_WITH_LVMLOCKD=1
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+aux prepare_pvs 1
+
+aux lvmconf 'log/prefix=""'
+aux lvmconf 'report/compact_output=0'
+aux lvmconf 'report/compact_output_cols=""'
+
+OPTS="ba_start,seg_start,seg_start_pe"
+
+aux lvmconf 'report/headings=0'
+
+pvs -o $OPTS > out
+not grep "BA Start Start Start" out
+not grep "pv_ba_start seg_start seg_start_pe" out
+
+
+aux lvmconf 'report/headings=1'
+
+pvs -o $OPTS > out
+grep "BA Start Start Start" out
+
+pvs --headings 1 -o $OPTS > out
+grep "BA Start Start Start" out
+
+pvs --headings abbrev -o $OPTS > out
+grep "BA Start Start Start" out
+
+pvs --headings 2 -o $OPTS > out
+grep "pv_ba_start seg_start seg_start_pe" out
+
+pvs --headings full -o $OPTS > out
+grep "pv_ba_start seg_start seg_start_pe" out
+
+pvs --headings none -o $OPTS > out
+not grep "BA Start Start Start" out
+not grep "pv_ba_start seg_start seg_start_pe" out
+
+pvs --rows -o $OPTS > out
+grep "BA Start 0" out
+grep "Start 0" out
+
+pvs --rows --headings 1 -o $OPTS > out
+grep "BA Start" out
+grep "Start 0" out;
+
+pvs --rows --headings abbrev -o $OPTS > out
+grep "BA Start" out
+grep "Start 0" out;
+
+pvs --rows --headings 2 -o $OPTS > out
+grep "pv_ba_start 0" out
+grep "seg_start 0" out
+grep "seg_start_pe 0" out
+
+pvs --rows --headings full -o $OPTS > out
+grep "pv_ba_start 0" out
+grep "seg_start 0" out
+grep "seg_start_pe 0" out
+
+
+aux lvmconf 'report/headings=2'
+
+pvs -o $OPTS > out
+grep "pv_ba_start seg_start seg_start_pe" out
+
+pvs --headings 1 -o $OPTS > out
+grep "BA Start Start Start" out
+
+pvs --headings abbrev -o $OPTS > out
+grep "BA Start Start Start" out
+
+pvs --headings 2 -o $OPTS > out
+grep "pv_ba_start seg_start seg_start_pe" out
+
+pvs --headings full -o $OPTS > out
+grep "pv_ba_start seg_start seg_start_pe" out
+
+pvs --rows -o $OPTS > out
+grep "pv_ba_start 0" out
+grep "seg_start 0" out
+grep "seg_start_pe 0" out
+
+pvs --rows --headings 1 -o $OPTS > out
+grep "BA Start" out
+grep "Start 0" out;
+
+pvs --rows --headings abbrev -o $OPTS > out
+grep "BA Start" out
+grep "Start 0" out;
+
+pvs --rows --headings 2 -o $OPTS > out
+grep "pv_ba_start 0" out
+grep "seg_start 0" out
+grep "seg_start_pe 0" out
+
+pvs --rows --headings full -o $OPTS > out
+grep "pv_ba_start 0" out
+grep "seg_start 0" out
+grep "seg_start_pe 0" out
+
+
+# if report/headings=100 (out of bound value), then it is as if "1" was used
+aux lvmconf 'report/headings=100'
+
+pvs -o $OPTS > out
+grep "BA Start Start Start" out
+
+
+# if using --nameprefixes, the report/headings=2 is ignored
+pvs --headings 2 --nameprefixes -o $OPTS > out
+grep "LVM2_PV_BA_START='0 ' LVM2_SEG_START='0 ' LVM2_SEG_START_PE='0'" out
+
+# --noheadings and --headings not allowed
+not pvs --headings 1 --noheadings


=====================================
tools/args.h
=====================================
@@ -334,6 +334,12 @@ arg(handlemissingpvs_ARG, '\0', "handlemissingpvs", 0, 0, 0,
     "Allows a polling operation to continue when PVs are missing,\n"
     "e.g. for repairs due to faulty devices.\n")
 
+arg(headings_ARG, '\0', "headings", headings_VAL, 0, 0,
+    "Type of headings to use in report output.\n"
+    "\\fBnone\\fP or \\fB0\\fP: No headings.\n"
+    "\\fBabbrev\\fP or \\fB1\\fP: Column name abbreviations.\n"
+    "\\fBfull\\fP or \\fB2\\fP: Full column names.\n")
+
 arg(ignoreadvanced_ARG, '\0', "ignoreadvanced", 0, 0, 0,
     "Exclude advanced configuration settings from the output.\n")
 


=====================================
tools/command-lines.in
=====================================
@@ -210,7 +210,7 @@ OO_ALL: --commandprofile String, --config String, --debug,
 # options for pvs, lvs, vgs, fullreport
 #
 OO_REPORT: --aligned, --all, --binary, --configreport ConfigReport, --foreign,
---ignorelockingfailure, --logonly,
+--headings HeadingsType --ignorelockingfailure, --logonly,
 --nameprefixes, --noheadings, --nosuffix,
 --options String, --readonly, --reportformat ReportFmt, --rows,
 --select String, --separator String, --shared, --sort String,
@@ -1531,6 +1531,7 @@ OO: --history, --segments, OO_REPORT
 OP: VG|LV|Tag ...
 IO: --partial, --ignoreskippedcluster, --trustcache
 ID: lvs_general
+RULE: --noheadings not --headings
 
 ---
 
@@ -1644,6 +1645,7 @@ OO: --segments, OO_REPORT
 OP: PV|Tag ...
 IO: --partial, --ignoreskippedcluster, --trustcache
 ID: pvs_general
+RULE: --noheadings not --headings
 
 ---
 
@@ -1952,6 +1954,7 @@ OO: OO_REPORT
 OP: VG|Tag ...
 IO: --partial, --ignoreskippedcluster, --trustcache
 ID: vgs_general
+RULE: --noheadings not --headings
 
 ---
 
@@ -2007,6 +2010,7 @@ OO: OO_REPORT
 OP: VG ...
 IO: --partial, --ignoreskippedcluster, --trustcache
 ID: fullreport_general
+RULE: --noheadings not --headings
 
 lastlog
 OO: --reportformat ReportFmt, --select String


=====================================
tools/command.c
=====================================
@@ -126,6 +126,7 @@ static inline int configreport_arg(struct cmd_context *cmd __attribute__((unused
 static inline int configtype_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av) { return 0; }
 static inline int repairtype_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av) { return 0; }
 static inline int dumptype_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av) { return 0; }
+static inline int headings_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av) { return 0; }
 
 /* needed to include commands.h when building man page generator */
 #define CACHE_VGMETADATA        0x00000001


=====================================
tools/lvmcmdline.c
=====================================
@@ -1136,6 +1136,11 @@ int dumptype_arg(struct cmd_context *cmd, struct arg_values *av)
 	return 0;
 }
 
+int headings_arg(struct cmd_context *cmd, struct arg_values *av)
+{
+	return report_headings_str_to_type(av->value) != REPORT_HEADINGS_UNKNOWN;
+}
+
 /*
  * FIXME: there's been a confusing mixup among:
  * resizeable, resizable, allocatable, allocation.


=====================================
tools/reporter.c
=====================================
@@ -48,9 +48,9 @@ struct report_args {
 	char **argv;
 	dm_report_group_type_t report_group_type;
 	report_type_t report_type;
+	report_headings_t headings;
 	int aligned;
 	int buffered;
-	int headings;
 	int field_prefixes;
 	int quoted;
 	int columns_as_rows;
@@ -1247,9 +1247,11 @@ out:
 
 static int _config_report(struct cmd_context *cmd, struct report_args *args, struct single_report_args *single_args)
 {
+	const char *str;
+
 	args->aligned = find_config_tree_bool(cmd, report_aligned_CFG, NULL);
 	args->buffered = find_config_tree_bool(cmd, report_buffered_CFG, NULL);
-	args->headings = find_config_tree_bool(cmd, report_headings_CFG, NULL);
+	args->headings = find_config_tree_int(cmd, report_headings_CFG, NULL);
 	args->separator = find_config_tree_str(cmd, report_separator_CFG, NULL);
 	args->field_prefixes = find_config_tree_bool(cmd, report_prefixes_CFG, NULL);
 	args->quoted = find_config_tree_bool(cmd, report_quoted_CFG, NULL);
@@ -1344,7 +1346,13 @@ static int _config_report(struct cmd_context *cmd, struct report_args *args, str
 	if (arg_is_set(cmd, unbuffered_ARG) && !arg_is_set(cmd, sort_ARG))
 		args->buffered = 0;
 	if (arg_is_set(cmd, noheadings_ARG))
-		args->headings = 0;
+		args->headings = REPORT_HEADINGS_NONE;
+	if ((str = arg_str_value(cmd, headings_ARG, NULL))) {
+		if ((args->headings = report_headings_str_to_type(str)) == REPORT_HEADINGS_UNKNOWN) {
+			log_error("Unknown --headings value.");
+			return 0;
+		}
+	}
 	if (arg_is_set(cmd, nameprefixes_ARG)) {
 		args->aligned = 0;
 		args->field_prefixes = 1;


=====================================
tools/tools.h
=====================================
@@ -191,6 +191,7 @@ int configreport_arg(struct cmd_context *cmd __attribute__((unused)), struct arg
 int configtype_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av);
 int repairtype_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av);
 int dumptype_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av);
+int headings_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av);
 
 /* we use the enums to access the switches */
 int arg_is_valid_for_command(const struct cmd_context *cmd, int a);


=====================================
tools/vals.h
=====================================
@@ -143,6 +143,7 @@ val(configreport_VAL, configreport_arg, "ConfigReport", "log|vg|lv|pv|pvseg|seg"
 val(configtype_VAL, configtype_arg, "ConfigType", "current|default|diff|full|list|missing|new|profilable|profilable-command|profilable-metadata")
 val(repairtype_VAL, repairtype_arg, "RepairType", "pv_header|metadata|label_header")
 val(dumptype_VAL, dumptype_arg, "DumpType", "headers|metadata|metadata_all|metadata_search")
+val(headings_VAL, headings_arg, "HeadingsType", "none|abbrev|full|0|1|2")
 
 /* this should always be last */
 val(VAL_COUNT, NULL, NULL, NULL)



View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/compare/c4b42e9f59c93c75c96d4e31cb87d3a29d1c005f...1f02c5f2e4bc1c8871d1a0943a6e859fa86c02fa

-- 
View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/compare/c4b42e9f59c93c75c96d4e31cb87d3a29d1c005f...1f02c5f2e4bc1c8871d1a0943a6e859fa86c02fa
You're receiving this email because of your account on gitlab.com.


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20230830/706d4971/attachment-0001.htm>
