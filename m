From: agk@sourceware.org <agk@sourceware.org>
Date: 24 Jun 2008 22:48:54 -0000
Subject: LVM2 lib/config/defaults.h lib/report/report.c ...
Message-ID: <20080624224854.13220.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-06-24 22:48:53

Modified files:
	lib/config     : defaults.h 
	lib/report     : report.c report.h 
	tools          : args.h commands.h reporter.c 
	.              : WHATS_NEW 

Log message:
	Add --rows to reports.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/defaults.h.diff?cvsroot=lvm2&r1=1.41&r2=1.42
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.85&r2=1.86
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.h.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/args.h.diff?cvsroot=lvm2&r1=1.59&r2=1.60
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.117&r2=1.118
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/reporter.c.diff?cvsroot=lvm2&r1=1.38&r2=1.39
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.915&r2=1.916

--- LVM2/lib/config/defaults.h	2008/06/24 21:21:03	1.41
+++ LVM2/lib/config/defaults.h	2008/06/24 22:48:53	1.42
@@ -101,6 +101,7 @@
 
 #define DEFAULT_REP_ALIGNED 1
 #define DEFAULT_REP_BUFFERED 1
+#define DEFAULT_REP_COLUMNS_AS_ROWS 0
 #define DEFAULT_REP_HEADINGS 1
 #define DEFAULT_REP_PREFIXES 0
 #define DEFAULT_REP_QUOTED 1
--- LVM2/lib/report/report.c	2008/06/24 21:21:04	1.85
+++ LVM2/lib/report/report.c	2008/06/24 22:48:53	1.86
@@ -1078,7 +1078,7 @@
 void *report_init(struct cmd_context *cmd, const char *format, const char *keys,
 		  report_type_t *report_type, const char *separator,
 		  int aligned, int buffered, int headings, int field_prefixes,
-		  int quoted)
+		  int quoted, int columns_as_rows)
 {
 	uint32_t report_flags = 0;
 	void *rh;
@@ -1098,6 +1098,9 @@
 	if (!quoted)
 		report_flags |= DM_REPORT_OUTPUT_FIELD_UNQUOTED;
 
+	if (columns_as_rows)
+		report_flags |= DM_REPORT_OUTPUT_COLUMNS_AS_ROWS;
+
 	rh = dm_report_init(report_type, _report_types, _fields, format,
 			    separator, report_flags, keys, cmd);
 
--- LVM2/lib/report/report.h	2008/06/24 21:21:04	1.7
+++ LVM2/lib/report/report.h	2008/06/24 22:48:53	1.8
@@ -29,7 +29,7 @@
 void *report_init(struct cmd_context *cmd, const char *format, const char *keys,
 		  report_type_t *report_type, const char *separator,
 		  int aligned, int buffered, int headings, int field_prefixes,
-		  int quoted);
+		  int quoted, int columns_as_rows);
 void report_free(void *handle);
 int report_object(void *handle, struct volume_group *vg,
 		  struct logical_volume *lv, struct physical_volume *pv,
--- LVM2/tools/args.h	2008/06/24 21:21:04	1.59
+++ LVM2/tools/args.h	2008/06/24 22:48:53	1.60
@@ -55,6 +55,7 @@
 arg(ignoremonitoring_ARG, '\0', "ignoremonitoring", NULL, 0)
 arg(nameprefixes_ARG, '\0', "nameprefixes", NULL, 0)
 arg(unquoted_ARG, '\0', "unquoted", NULL, 0)
+arg(rows_ARG, '\0', "rows", NULL, 0)
 
 /* Allow some variations */
 arg(resizable_ARG, '\0', "resizable", yes_no_arg, 0)
--- LVM2/tools/commands.h	2008/06/24 21:21:04	1.117
+++ LVM2/tools/commands.h	2008/06/24 22:48:53	1.118
@@ -372,6 +372,7 @@
    "\t[-o|--options [+]Field[,Field]]\n"
    "\t[-O|--sort [+|-]key1[,[+|-]key2[,...]]]\n"
    "\t[-P|--partial] " "\n"
+   "\t[--rows]\n"
    "\t[--segments]\n"
    "\t[--separator Separator]\n"
    "\t[--trustcache]\n"
@@ -384,8 +385,8 @@
 
    aligned_ARG, all_ARG, ignorelockingfailure_ARG, nameprefixes_ARG,
    noheadings_ARG, nolocking_ARG, nosuffix_ARG, options_ARG, partial_ARG, 
-   segments_ARG, separator_ARG, sort_ARG, trustcache_ARG, unbuffered_ARG,
-   units_ARG, unquoted_ARG)
+   rows_ARG, segments_ARG, separator_ARG, sort_ARG, trustcache_ARG,
+   unbuffered_ARG, units_ARG, unquoted_ARG)
 
 xx(lvscan,
    "List all logical volumes in all volume groups",
@@ -582,6 +583,7 @@
    "\t[-o|--options [+]Field[,Field]]\n"
    "\t[-O|--sort [+|-]key1[,[+|-]key2[,...]]]\n"
    "\t[-P|--partial] " "\n"
+   "\t[--rows]\n"
    "\t[--segments]\n"
    "\t[--separator Separator]\n"
    "\t[--trustcache]\n"
@@ -594,8 +596,8 @@
 
    aligned_ARG, all_ARG, ignorelockingfailure_ARG, nameprefixes_ARG,
    noheadings_ARG, nolocking_ARG, nosuffix_ARG, options_ARG, partial_ARG,
-   segments_ARG, separator_ARG, sort_ARG, trustcache_ARG, unbuffered_ARG,
-   units_ARG, unquoted_ARG)
+   rows_ARG, segments_ARG, separator_ARG, sort_ARG, trustcache_ARG,
+   unbuffered_ARG, units_ARG, unquoted_ARG)
 
 xx(pvscan,
    "List all physical volumes",
@@ -900,6 +902,7 @@
    "\t[-o|--options [+]Field[,Field]]\n"
    "\t[-O|--sort [+|-]key1[,[+|-]key2[,...]]]\n"
    "\t[-P|--partial] " "\n"
+   "\t[--rows]\n"
    "\t[--separator Separator]\n"
    "\t[--trustcache]\n"
    "\t[--unbuffered]\n"
@@ -911,7 +914,7 @@
 
    aligned_ARG, all_ARG, ignorelockingfailure_ARG, nameprefixes_ARG,
    noheadings_ARG, nolocking_ARG, nosuffix_ARG, options_ARG, partial_ARG, 
-   separator_ARG, sort_ARG, trustcache_ARG, unbuffered_ARG, units_ARG,
+   rows_ARG, separator_ARG, sort_ARG, trustcache_ARG, unbuffered_ARG, units_ARG,
    unquoted_ARG)
 
 xx(vgscan,
--- LVM2/tools/reporter.c	2008/06/24 21:21:04	1.38
+++ LVM2/tools/reporter.c	2008/06/24 22:48:53	1.39
@@ -159,6 +159,7 @@
 	const char *keys = NULL, *options = NULL, *separator;
 	int r = ECMD_PROCESSED;
 	int aligned, buffered, headings, field_prefixes, quoted;
+	int columns_as_rows;
 	unsigned args_are_pvs;
 
 	aligned = find_config_tree_int(cmd, "report/aligned",
@@ -173,6 +174,8 @@
 					      DEFAULT_REP_PREFIXES);
 	quoted = find_config_tree_int(cmd, "report/quoted",
 				     DEFAULT_REP_QUOTED);
+	columns_as_rows = find_config_tree_int(cmd, "report/columns_as_rows",
+					       DEFAULT_REP_COLUMNS_AS_ROWS);
 
 	args_are_pvs = (report_type == PVS || report_type == PVSEGS) ? 1 : 0;
 
@@ -280,10 +283,13 @@
 	}
 	if (arg_count(cmd, unquoted_ARG))
 		quoted = 0;
+	if (arg_count(cmd, rows_ARG))
+		columns_as_rows = 1;
 
 	if (!(report_handle = report_init(cmd, options, keys, &report_type,
 					  separator, aligned, buffered,
-					  headings, field_prefixes, quoted))) {
+					  headings, field_prefixes, quoted,
+					  columns_as_rows))) {
 		stack;
 		return ECMD_FAILED;
 	}
--- LVM2/WHATS_NEW	2008/06/24 21:21:04	1.915
+++ LVM2/WHATS_NEW	2008/06/24 22:48:53	1.916
@@ -1,6 +1,6 @@
 Version 2.02.39 -
 ================================
-  Add --unquoted to reporting tools.
+  Add --unquoted and --rows to reporting tools.
   Add and use uninitialized_var() macro to suppress invalid compiler warnings.
   Introduce enum for md minor sb version to suppress compiler warning.
   Avoid undefined return value after _memlock manipulation in lvm2_run.


