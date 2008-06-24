From: agk@sourceware.org <agk@sourceware.org>
Date: 24 Jun 2008 21:21:05 -0000
Subject: LVM2 lib/config/defaults.h lib/report/report.c ...
Message-ID: <20080624212105.7494.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-06-24 21:21:04

Modified files:
	lib/config     : defaults.h 
	lib/report     : report.c report.h 
	tools          : args.h commands.h reporter.c 
	.              : WHATS_NEW 

Log message:
	Add --unquoted to reporting tools.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/defaults.h.diff?cvsroot=lvm2&r1=1.40&r2=1.41
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.84&r2=1.85
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.h.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/args.h.diff?cvsroot=lvm2&r1=1.58&r2=1.59
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.116&r2=1.117
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/reporter.c.diff?cvsroot=lvm2&r1=1.37&r2=1.38
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.914&r2=1.915

--- LVM2/lib/config/defaults.h	2008/04/20 00:15:08	1.40
+++ LVM2/lib/config/defaults.h	2008/06/24 21:21:03	1.41
@@ -103,6 +103,7 @@
 #define DEFAULT_REP_BUFFERED 1
 #define DEFAULT_REP_HEADINGS 1
 #define DEFAULT_REP_PREFIXES 0
+#define DEFAULT_REP_QUOTED 1
 #define DEFAULT_REP_SEPARATOR " "
 
 #define DEFAULT_LVS_COLS "lv_name,vg_name,lv_attr,lv_size,origin,snap_percent,move_pv,mirror_log,copy_percent,convert_lv"
--- LVM2/lib/report/report.c	2008/06/06 19:28:34	1.84
+++ LVM2/lib/report/report.c	2008/06/24 21:21:04	1.85
@@ -1077,7 +1077,8 @@
 
 void *report_init(struct cmd_context *cmd, const char *format, const char *keys,
 		  report_type_t *report_type, const char *separator,
-		  int aligned, int buffered, int headings, int field_prefixes)
+		  int aligned, int buffered, int headings, int field_prefixes,
+		  int quoted)
 {
 	uint32_t report_flags = 0;
 	void *rh;
@@ -1094,6 +1095,9 @@
 	if (field_prefixes)
 		report_flags |= DM_REPORT_OUTPUT_FIELD_NAME_PREFIX;
 
+	if (!quoted)
+		report_flags |= DM_REPORT_OUTPUT_FIELD_UNQUOTED;
+
 	rh = dm_report_init(report_type, _report_types, _fields, format,
 			    separator, report_flags, keys, cmd);
 
--- LVM2/lib/report/report.h	2008/04/20 00:15:08	1.6
+++ LVM2/lib/report/report.h	2008/06/24 21:21:04	1.7
@@ -28,7 +28,8 @@
 
 void *report_init(struct cmd_context *cmd, const char *format, const char *keys,
 		  report_type_t *report_type, const char *separator,
-		  int aligned, int buffered, int headings, int field_prefixes);
+		  int aligned, int buffered, int headings, int field_prefixes,
+		  int quoted);
 void report_free(void *handle);
 int report_object(void *handle, struct volume_group *vg,
 		  struct logical_volume *lv, struct physical_volume *pv,
--- LVM2/tools/args.h	2008/06/06 19:28:35	1.58
+++ LVM2/tools/args.h	2008/06/24 21:21:04	1.59
@@ -54,6 +54,7 @@
 arg(trustcache_ARG, '\0', "trustcache", NULL, 0)
 arg(ignoremonitoring_ARG, '\0', "ignoremonitoring", NULL, 0)
 arg(nameprefixes_ARG, '\0', "nameprefixes", NULL, 0)
+arg(unquoted_ARG, '\0', "unquoted", NULL, 0)
 
 /* Allow some variations */
 arg(resizable_ARG, '\0', "resizable", yes_no_arg, 0)
--- LVM2/tools/commands.h	2008/06/12 13:24:02	1.116
+++ LVM2/tools/commands.h	2008/06/24 21:21:04	1.117
@@ -377,6 +377,7 @@
    "\t[--trustcache]\n"
    "\t[--unbuffered]\n"
    "\t[--units hsbkmgtHKMGT]\n"
+   "\t[--unquoted]\n"
    "\t[-v|--verbose]\n"
    "\t[--version]" "\n"
    "\t[LogicalVolume[Path] [LogicalVolume[Path]...]]\n",
@@ -384,7 +385,7 @@
    aligned_ARG, all_ARG, ignorelockingfailure_ARG, nameprefixes_ARG,
    noheadings_ARG, nolocking_ARG, nosuffix_ARG, options_ARG, partial_ARG, 
    segments_ARG, separator_ARG, sort_ARG, trustcache_ARG, unbuffered_ARG,
-   units_ARG)
+   units_ARG, unquoted_ARG)
 
 xx(lvscan,
    "List all logical volumes in all volume groups",
@@ -586,6 +587,7 @@
    "\t[--trustcache]\n"
    "\t[--unbuffered]\n"
    "\t[--units hsbkmgtHKMGT]\n"
+   "\t[--unquoted]\n"
    "\t[-v|--verbose]\n"
    "\t[--version]\n"
    "\t[PhysicalVolume [PhysicalVolume...]]\n",
@@ -593,7 +595,7 @@
    aligned_ARG, all_ARG, ignorelockingfailure_ARG, nameprefixes_ARG,
    noheadings_ARG, nolocking_ARG, nosuffix_ARG, options_ARG, partial_ARG,
    segments_ARG, separator_ARG, sort_ARG, trustcache_ARG, unbuffered_ARG,
-   units_ARG)
+   units_ARG, unquoted_ARG)
 
 xx(pvscan,
    "List all physical volumes",
@@ -902,13 +904,15 @@
    "\t[--trustcache]\n"
    "\t[--unbuffered]\n"
    "\t[--units hsbkmgtHKMGT]\n"
+   "\t[--unquoted]\n"
    "\t[-v|--verbose]\n"
    "\t[--version]\n"
    "\t[VolumeGroupName [VolumeGroupName...]]\n",
 
    aligned_ARG, all_ARG, ignorelockingfailure_ARG, nameprefixes_ARG,
    noheadings_ARG, nolocking_ARG, nosuffix_ARG, options_ARG, partial_ARG, 
-   separator_ARG, sort_ARG, trustcache_ARG, unbuffered_ARG, units_ARG)
+   separator_ARG, sort_ARG, trustcache_ARG, unbuffered_ARG, units_ARG,
+   unquoted_ARG)
 
 xx(vgscan,
    "Search for all volume groups",
--- LVM2/tools/reporter.c	2008/06/06 19:28:35	1.37
+++ LVM2/tools/reporter.c	2008/06/24 21:21:04	1.38
@@ -158,7 +158,7 @@
 	char *str;
 	const char *keys = NULL, *options = NULL, *separator;
 	int r = ECMD_PROCESSED;
-	int aligned, buffered, headings, field_prefixes;
+	int aligned, buffered, headings, field_prefixes, quoted;
 	unsigned args_are_pvs;
 
 	aligned = find_config_tree_int(cmd, "report/aligned",
@@ -171,6 +171,8 @@
 				    DEFAULT_REP_SEPARATOR);
 	field_prefixes = find_config_tree_int(cmd, "report/prefixes",
 					      DEFAULT_REP_PREFIXES);
+	quoted = find_config_tree_int(cmd, "report/quoted",
+				     DEFAULT_REP_QUOTED);
 
 	args_are_pvs = (report_type == PVS || report_type == PVSEGS) ? 1 : 0;
 
@@ -276,10 +278,12 @@
 		aligned = 0;
 		field_prefixes = 1;
 	}
+	if (arg_count(cmd, unquoted_ARG))
+		quoted = 0;
 
 	if (!(report_handle = report_init(cmd, options, keys, &report_type,
 					  separator, aligned, buffered,
-					  headings, field_prefixes))) {
+					  headings, field_prefixes, quoted))) {
 		stack;
 		return ECMD_FAILED;
 	}
--- LVM2/WHATS_NEW	2008/06/23 19:26:20	1.914
+++ LVM2/WHATS_NEW	2008/06/24 21:21:04	1.915
@@ -1,17 +1,15 @@
 Version 2.02.39 -
 ================================
-  Suppress invalid 'sb_offset' compiler warning with uninitialzed_var().
-  Add uninitialzed_var() macro to suppress invalid compiler warnings.
-  Suppress 'sb_offset' compiler warning by using enum for md minor sb version. 
-  lvm2_run: Don't return uninitialized "ret" for _memlock_inc or _memlock_dec.
-  Avoid link failure when configuring without --enable-cmdlib.
-  Avoid link failure when configuring without --enable-readline.
-  Make clvmd return immediately if other nodes are down in an openais cluster.
-  Make clvmd return immediately if other nodes are down in a gulm cluster.
-  Improve/Fix read ahead 'auto' calculation for stripe_size
-  Fix lvchange output for -r auto setting if auto is already set
-  Add testcase for read ahead
-  Fix ambiguous use of identifier 'error_message_produced'.
+  Add --unquoted to reporting tools.
+  Add and use uninitialized_var() macro to suppress invalid compiler warnings.
+  Introduce enum for md minor sb version to suppress compiler warning.
+  Avoid undefined return value after _memlock manipulation in lvm2_run.
+  Avoid link failure if configured without --enable-cmdlib or --enable-readline.
+  Make clvmd return at once if other nodes down in a gulm or openais cluster.
+  Fix and improve readahead 'auto' calculation for stripe_size.
+  Fix lvchange output for -r auto setting if auto is already set.
+  Add test case for readahead.
+  Fix ambiguous use of identifier error_message_produced.
   Begin syncing configure.in for merge/unification with device-mapper.
   Fix add_mirror_images not to dereference uninitialized log_lv upon failure.
   Don't call openlog for every debug line output by clvmd.


