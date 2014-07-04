From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  4 Jul 2014 14:00:22 +0000 (UTC)
Subject: master - tools: add --binary arg to pvs, vgs, lvs and {pv, vg, lv}display -C and report/binary_values_as_numeric lvm.conf option
Message-ID: <20140704140022.CD7A460612@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=da545ce3b471e76b3ebcfcb5528118d8dd9264df
Commit:        da545ce3b471e76b3ebcfcb5528118d8dd9264df
Parent:        d2af4f84c94cb8202565ac32c5f1df673cd92e0c
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jul 2 13:16:32 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jul 4 15:40:17 2014 +0200

tools: add --binary arg to pvs,vgs,lvs and {pv,vg,lv}display -C and report/binary_values_as_numeric lvm.conf option

The --binary option, if used, causes all the binary values reported
in reporting commands to be displayed as "0" or "1" instead of descriptive
literal values (value "unknown" is still used for values that could not be
determined).

Also, add report/binary_values_as_numeric lvm.conf option with the same
functionality as the --binary option (the --binary option prevails
if both --binary cmd option and report/binary_values_as_numeric lvm.conf
option is used at the same time). The report/binary_values_as_numeric is
also profilable.

This makes it easier to use and check lvm reporting command output in scripts.
---
 conf/command_profile_template.profile.in |    1 +
 conf/example.conf.in                     |    6 +++++
 lib/commands/toolcontext.c               |    1 +
 lib/commands/toolcontext.h               |    1 +
 lib/config/config_settings.h             |    1 +
 lib/report/report.c                      |   15 +++++++++++++-
 man/lvdisplay.8.in                       |    1 +
 man/lvs.8.in                             |    6 +++++
 man/pvdisplay.8.in                       |    1 +
 man/pvs.8.in                             |    6 +++++
 man/vgdisplay.8.in                       |    1 +
 man/vgs.8.in                             |    6 +++++
 tools/args.h                             |    1 +
 tools/commands.h                         |   32 +++++++++++++++++------------
 tools/lvmcmdline.c                       |    3 ++
 15 files changed, 68 insertions(+), 14 deletions(-)

diff --git a/conf/command_profile_template.profile.in b/conf/command_profile_template.profile.in
index 36d4343..592a69d 100644
--- a/conf/command_profile_template.profile.in
+++ b/conf/command_profile_template.profile.in
@@ -13,6 +13,7 @@
 #
 global {
 	units="h"
+	report_binary_values_as_numeric=0
 	si_unit_consistency=1
 	suffix=1
 	lvdisplay_shows_full_device_path=0
diff --git a/conf/example.conf.in b/conf/example.conf.in
index 935d3e7..162770a 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -1022,6 +1022,12 @@ activation {
     # Output each column as a row. If set, this also implies report/prefixes=1.
     # colums_as_rows=0
 
+    # Use binary values "0" or "1" instead of descriptive literal values for
+    # columns that have exactly two valid values to report (not counting the
+    # "unknown" value which denotes that the value could not be determined).
+    #
+    # binary_values_as_numeric = 0
+
     # Comma separated list of columns to sort by when reporting 'lvm devtypes' command.
     # See 'lvm devtypes -o help' for the list of possible fields.
     # devtypes_sort="devtype_name"
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 18fa12d..6ac4a42 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -297,6 +297,7 @@ int process_profilable_config(struct cmd_context *cmd) {
 	}
 
 	cmd->si_unit_consistency = find_config_tree_bool(cmd, global_si_unit_consistency_CFG, NULL);
+	cmd->report_binary_values_as_numeric = find_config_tree_bool(cmd, report_binary_values_as_numeric_CFG, NULL);
 	cmd->default_settings.suffix = find_config_tree_bool(cmd, global_suffix_CFG, NULL);
 
 	return 1;
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 9023a6c..162af55 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -88,6 +88,7 @@ struct cmd_context {
 	unsigned partial_activation:1;
 	unsigned auto_set_activation_skip:1;
 	unsigned si_unit_consistency:1;
+	unsigned report_binary_values_as_numeric:1;
 	unsigned metadata_read_only:1;
 	unsigned ignore_clustered_vgs:1;
 	unsigned threaded:1;		/* Set if running within a thread e.g. clvmd */
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index d277e0e..2ddf888 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -233,6 +233,7 @@ cfg(report_separator_CFG, "separator", report_CFG_SECTION, CFG_PROFILABLE, CFG_T
 cfg(report_prefixes_CFG, "prefixes", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_REP_PREFIXES, vsn(2, 2, 36), NULL)
 cfg(report_quoted_CFG, "quoted", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_REP_QUOTED, vsn(2, 2, 39), NULL)
 cfg(report_colums_as_rows_CFG, "colums_as_rows", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, DEFAULT_REP_COLUMNS_AS_ROWS, vsn(1, 0, 0), NULL)
+cfg(report_binary_values_as_numeric_CFG, "binary_values_as_numeric", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_BOOL, 0, vsn(2, 2, 108), NULL)
 cfg(report_devtypes_sort_CFG, "devtypes_sort", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_DEVTYPES_SORT, vsn(2, 2, 101), NULL)
 cfg(report_devtypes_cols_CFG, "devtypes_cols", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_DEVTYPES_COLS, vsn(2, 2, 101), NULL)
 cfg(report_devtypes_cols_verbose_CFG, "devtypes_cols_verbose", report_CFG_SECTION, CFG_PROFILABLE, CFG_TYPE_STRING, DEFAULT_DEVTYPES_COLS_VERB, vsn(2, 2, 101), NULL)
diff --git a/lib/report/report.c b/lib/report/report.c
index d74321e..284a718 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -43,6 +43,8 @@ struct lvm_report_object {
 
 static const uint64_t _zero64 = UINT64_C(0);
 static const uint64_t _one64 = UINT64_C(1);
+static const char * const _str_zero = "0";
+static const char * const _str_one = "1";
 
 static const uint64_t _reserved_number_undef_64 = UINT64_C(-1);
 static const uint64_t _reserved_number_unmanaged_64 = UINT64_C(-2);
@@ -1173,11 +1175,22 @@ static int _lvactive_disp(struct dm_report *rh, struct dm_pool *mem,
 
 /* PV/VG/LV Attributes */
 
+/*
+ * Display either "0"/"1" or ""/"word" based on bin_value,
+ * cmd->report_binary_values_as_numeric selects the mode to use.
+*/
 static int _binary_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),
 			struct dm_report_field *field, int bin_value, const char *word,
 			void *private)
 {
-	return _field_set_value(field, bin_value ? word : "", bin_value ? &_one64 : &_zero64);
+	const struct cmd_context *cmd = (const struct cmd_context *) private;
+
+	if (cmd->report_binary_values_as_numeric)
+		/* "0"/"1" */
+		return _field_set_value(field, bin_value ? _str_one : _str_zero, bin_value ? &_one64 : &_zero64);
+	else
+		/* blank/"word" */
+		return _field_set_value(field, bin_value ? word : "", bin_value ? &_one64 : &_zero64);
 }
 
 static int _pvallocatable_disp(struct dm_report *rh, struct dm_pool *mem,
diff --git a/man/lvdisplay.8.in b/man/lvdisplay.8.in
index 1283d58..ed113dd 100644
--- a/man/lvdisplay.8.in
+++ b/man/lvdisplay.8.in
@@ -25,6 +25,7 @@ lvdisplay \(em display attributes of a logical volume
 .B lvdisplay
 .BR \-C | \-\-columns
 .RB [ \-\-aligned ]
+.RB [ \-\-binary ]
 .RB [ \-a | \-\-all ]
 .RB [ \-\-commandprofile
 .IR ProfileName ]
diff --git a/man/lvs.8.in b/man/lvs.8.in
index 1afd63d..b7e3ecc 100644
--- a/man/lvs.8.in
+++ b/man/lvs.8.in
@@ -4,6 +4,7 @@ lvs \(em report information about logical volumes
 .SH SYNOPSIS
 .B lvs
 .RB [ \-\-aligned ]
+.RB [ \-\-binary ]
 .RB [ \-a | \-\-all ]
 .RB [ \-\-commandprofile
 .IR ProfileName ]
@@ -44,6 +45,11 @@ for common options.
 .B \-\-aligned
 Use with \fB\-\-separator\fP to align the output columns.
 .TP
+.B \-\-binary
+Use binary values "0" or "1" instead of descriptive literal values
+for columns that have exactly two valid values to report (not counting
+the "unknown" value which denotes that the value could not be determined).
+.TP
 .B \-\-all
 Include information in the output about internal Logical Volumes that
 are components of normally-accessible Logical Volumes, such as mirrors,
diff --git a/man/pvdisplay.8.in b/man/pvdisplay.8.in
index 0399c1e..70c9bfc 100644
--- a/man/pvdisplay.8.in
+++ b/man/pvdisplay.8.in
@@ -26,6 +26,7 @@ pvdisplay \- display attributes of a physical volume
 .B pvdisplay
 .BR \-C | \-\-columns
 .RB [ \-\-aligned ]
+.RB [ \-\-binary ]
 .RB [ \-a | \-\-all ]
 .RB [ \-\-commandprofile
 .IR ProfileName ]
diff --git a/man/pvs.8.in b/man/pvs.8.in
index ccd84a5..605b13d 100644
--- a/man/pvs.8.in
+++ b/man/pvs.8.in
@@ -5,6 +5,7 @@ pvs \(em report information about physical volumes
 .B pvs
 .RB [ \-a | \-\-all ]
 .RB [ \-\-aligned ]
+.RB [ \-\-binary ]
 .RB [ \-\-commandprofile
 .IR ProfileName ]
 .RB [ \-d | \-\-debug ]
@@ -45,6 +46,11 @@ initialized with \fBpvcreate\fP(8).
 .B \-\-aligned
 Use with \fB\-\-separator\fP to align the output columns.
 .TP
+.B \-\-binary
+Use binary values "0" or "1" instead of descriptive literal values
+for columns that have exactly two valid values to report (not counting
+the "unknown" value which denotes that the value could not be determined).
+.TP
 .B \-\-nameprefixes
 Add an "LVM2_" prefix plus the field name to the output.  Useful
 with \fB\-\-noheadings\fP to produce a list of field=value pairs that can
diff --git a/man/vgdisplay.8.in b/man/vgdisplay.8.in
index 97cb314..1e472d3 100644
--- a/man/vgdisplay.8.in
+++ b/man/vgdisplay.8.in
@@ -26,6 +26,7 @@ vgdisplay \(em display attributes of volume groups
 .B vgdisplay
 .BR \-C | \-\-columns
 .RB [ \-\-aligned ]
+.RB [ \-\-binary ]
 .RB [ \-\-commandprofile
 .IR ProfileName ]
 .RB [ \-d | \-\-debug ]
diff --git a/man/vgs.8.in b/man/vgs.8.in
index de0ef9b..6dd52f1 100644
--- a/man/vgs.8.in
+++ b/man/vgs.8.in
@@ -5,6 +5,7 @@ vgs \(em report information about volume groups
 .B vgs
 .RB [ \-a | \-\-all ]
 .RB [ \-\-aligned ]
+.RB [ \-\-binary ]
 .RB [ \-\-commandprofile
 .IR ProfileName ]
 .RB [ \-d | \-\-debug ]
@@ -43,6 +44,11 @@ List all volume groups.  Equivalent to not specifying any volume groups.
 .B \-\-aligned
 Use with \fB\-\-separator\fP to align the output columns.
 .TP
+.B \-\-binary
+Use binary values "0" or "1" instead of descriptive literal values
+for columns that have exactly two valid values to report (not counting
+the "unknown" value which denotes that the value could not be determined).
+.TP
 .B \-\-nameprefixes
 Add an "LVM2_" prefix plus the field name to the output.  Useful
 with \fB\-\-noheadings\fP to produce a list of field=value pairs that can
diff --git a/tools/args.h b/tools/args.h
index 54e225f..d4a8643 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -32,6 +32,7 @@ arg(restorefile_ARG, '\0', "restorefile", string_arg, 0)
 arg(labelsector_ARG, '\0', "labelsector", int_arg, 0)
 arg(driverloaded_ARG, '\0', "driverloaded", yes_no_arg, 0)
 arg(aligned_ARG, '\0', "aligned", NULL, 0)
+arg(binary_ARG, '\0', "binary", NULL, 0)
 arg(unbuffered_ARG, '\0', "unbuffered", NULL, 0)
 arg(noheadings_ARG, '\0', "noheadings", NULL, 0)
 arg(segments_ARG, '\0', "segments", NULL, 0)
diff --git a/tools/commands.h b/tools/commands.h
index 1484aef..7d36bc5 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -33,6 +33,7 @@ xx(devtypes,
    PERMITTED_READ_ONLY,
    "devtypes" "\n"
    "\t[--aligned]\n"
+   "\t[--binary]\n"
    "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"
    "\t[-h|--help]\n"
@@ -49,7 +50,7 @@ xx(devtypes,
    "\t[-v|--verbose]\n"
    "\t[--version]" "\n",
 
-   aligned_ARG, nameprefixes_ARG,
+   aligned_ARG, binary_ARG, nameprefixes_ARG,
    noheadings_ARG, nosuffix_ARG, options_ARG,
    rows_ARG, select_ARG, separator_ARG, sort_ARG,
    unbuffered_ARG, unquoted_ARG)
@@ -562,6 +563,7 @@ xx(lvs,
    "lvs" "\n"
    "\t[-a|--all]\n"
    "\t[--aligned]\n"
+   "\t[--binary]\n"
    "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"
    "\t[-h|--help]\n"
@@ -586,11 +588,11 @@ xx(lvs,
    "\t[--version]" "\n"
    "\t[LogicalVolume[Path] [LogicalVolume[Path]...]]\n",
 
-   aligned_ARG, all_ARG, ignorelockingfailure_ARG, ignoreskippedcluster_ARG,
-   nameprefixes_ARG, noheadings_ARG, nolocking_ARG, nosuffix_ARG, options_ARG,
-   partial_ARG, readonly_ARG, rows_ARG, segments_ARG, select_ARG,
-   separator_ARG, sort_ARG, trustcache_ARG, unbuffered_ARG, units_ARG,
-   unquoted_ARG)
+   aligned_ARG, all_ARG, binary_ARG, ignorelockingfailure_ARG,
+   ignoreskippedcluster_ARG, nameprefixes_ARG, noheadings_ARG,
+   nolocking_ARG, nosuffix_ARG, options_ARG, partial_ARG,
+   readonly_ARG, rows_ARG, segments_ARG, select_ARG, separator_ARG,
+   sort_ARG, trustcache_ARG, unbuffered_ARG, units_ARG, unquoted_ARG)
 
 xx(lvscan,
    "List all logical volumes in all volume groups",
@@ -806,6 +808,7 @@ xx(pvs,
    "pvs" "\n"
    "\t[-a|--all]\n"
    "\t[--aligned]\n"
+   "\t[--binary]\n"
    "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]" "\n"
    "\t[-h|-?|--help] " "\n"
@@ -830,10 +833,11 @@ xx(pvs,
    "\t[--version]\n"
    "\t[PhysicalVolume [PhysicalVolume...]]\n",
 
-   aligned_ARG, all_ARG, ignorelockingfailure_ARG, ignoreskippedcluster_ARG,
-   nameprefixes_ARG, noheadings_ARG, nolocking_ARG, nosuffix_ARG, options_ARG,
-   partial_ARG, readonly_ARG, rows_ARG, segments_ARG, select_ARG, separator_ARG,
-   sort_ARG, trustcache_ARG, unbuffered_ARG, units_ARG, unquoted_ARG)
+   aligned_ARG, all_ARG, binary_ARG, ignorelockingfailure_ARG,
+   ignoreskippedcluster_ARG, nameprefixes_ARG, noheadings_ARG, nolocking_ARG,
+   nosuffix_ARG, options_ARG, partial_ARG, readonly_ARG, rows_ARG,
+   segments_ARG, select_ARG, separator_ARG, sort_ARG, trustcache_ARG,
+   unbuffered_ARG, units_ARG, unquoted_ARG)
 
 xx(pvscan,
    "List all physical volumes",
@@ -1194,6 +1198,7 @@ xx(vgs,
    PERMITTED_READ_ONLY,
    "vgs" "\n"
    "\t[--aligned]\n"
+   "\t[--binary]\n"
    "\t[-a|--all]\n"
    "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"
@@ -1218,9 +1223,10 @@ xx(vgs,
    "\t[--version]\n"
    "\t[VolumeGroupName [VolumeGroupName...]]\n",
 
-   aligned_ARG, all_ARG, ignorelockingfailure_ARG, ignoreskippedcluster_ARG,
-   nameprefixes_ARG, noheadings_ARG, nolocking_ARG, nosuffix_ARG, options_ARG,
-   partial_ARG, readonly_ARG, rows_ARG, select_ARG, separator_ARG, sort_ARG,
+   aligned_ARG, all_ARG, binary_ARG, ignorelockingfailure_ARG,
+   ignoreskippedcluster_ARG, nameprefixes_ARG, noheadings_ARG,
+   nolocking_ARG, nosuffix_ARG, options_ARG, partial_ARG,
+   readonly_ARG, rows_ARG, select_ARG, separator_ARG, sort_ARG,
    trustcache_ARG, unbuffered_ARG, units_ARG, unquoted_ARG)
 
 xx(vgscan,
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 66f691e..780e9d0 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -930,6 +930,9 @@ static int _get_settings(struct cmd_context *cmd)
 			return EINVALID_CMD_LINE;
 		}
 
+	if (arg_count(cmd, binary_ARG))
+		cmd->report_binary_values_as_numeric = 1;
+
 	if (arg_count(cmd, trustcache_ARG)) {
 		if (arg_count(cmd, all_ARG)) {
 			log_error("--trustcache is incompatible with --all");


