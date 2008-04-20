From: agk@sourceware.org <agk@sourceware.org>
Date: 20 Apr 2008 00:15:09 -0000
Subject: LVM2 ./WHATS_NEW lib/config/defaults.h lib/rep ...
Message-ID: <20080420001509.22952.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-04-20 00:15:08

Modified files:
	.              : WHATS_NEW 
	lib/config     : defaults.h 
	lib/report     : report.c report.h 
	tools          : args.h commands.h reporter.c 

Log message:
	Add --prefixes to reporting tools for field name prefix output format.
	
	E.g. lvs --prefixes --noheadings --unbuffered --units m --nosuffix
	
	(Used '--prefixes' for now, but I'm looking for a better name.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.854&r2=1.855
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/defaults.h.diff?cvsroot=lvm2&r1=1.39&r2=1.40
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.79&r2=1.80
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.h.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/args.h.diff?cvsroot=lvm2&r1=1.56&r2=1.57
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.110&r2=1.111
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/reporter.c.diff?cvsroot=lvm2&r1=1.35&r2=1.36

--- LVM2/WHATS_NEW	2008/04/18 12:50:24	1.854
+++ LVM2/WHATS_NEW	2008/04/20 00:15:08	1.855
@@ -1,5 +1,6 @@
 Version 2.02.36 - 
 =================================
+  Add --prefixes to reporting tools for field name prefix output format.
   Fix lvconvert -m0 allocatable space check.
 
 Version 2.02.35 - 15th April 2008
--- LVM2/lib/config/defaults.h	2008/01/17 15:31:18	1.39
+++ LVM2/lib/config/defaults.h	2008/04/20 00:15:08	1.40
@@ -102,6 +102,7 @@
 #define DEFAULT_REP_ALIGNED 1
 #define DEFAULT_REP_BUFFERED 1
 #define DEFAULT_REP_HEADINGS 1
+#define DEFAULT_REP_PREFIXES 0
 #define DEFAULT_REP_SEPARATOR " "
 
 #define DEFAULT_LVS_COLS "lv_name,vg_name,lv_attr,lv_size,origin,snap_percent,move_pv,mirror_log,copy_percent,convert_lv"
--- LVM2/lib/report/report.c	2008/04/10 17:19:02	1.79
+++ LVM2/lib/report/report.c	2008/04/20 00:15:08	1.80
@@ -386,7 +386,7 @@
 	const uint32_t status = *(const uint32_t *) data;
 	char *repstr;
 
-	if (!(repstr = dm_pool_zalloc(mem, 4))) {
+	if (!(repstr = dm_pool_zalloc(mem, 3))) {
 		log_error("dm_pool_alloc failed");
 		return 0;
 	}
@@ -1077,9 +1077,10 @@
 
 void *report_init(struct cmd_context *cmd, const char *format, const char *keys,
 		  report_type_t *report_type, const char *separator,
-		  int aligned, int buffered, int headings)
+		  int aligned, int buffered, int headings, int field_prefixes)
 {
 	uint32_t report_flags = 0;
+	void *rh;
 
 	if (aligned)
 		report_flags |= DM_REPORT_OUTPUT_ALIGNED;
@@ -1090,8 +1091,16 @@
 	if (headings)
 		report_flags |= DM_REPORT_OUTPUT_HEADINGS;
 
-	return dm_report_init(report_type, _report_types, _fields, format,
-			      separator, report_flags, keys, cmd);
+	if (field_prefixes)
+		report_flags |= DM_REPORT_OUTPUT_FIELD_NAME_PREFIX;
+
+	rh = dm_report_init(report_type, _report_types, _fields, format,
+			    separator, report_flags, keys, cmd);
+
+	if (field_prefixes)
+		dm_report_set_output_field_name_prefix(rh, "lvm2_");
+
+	return rh;
 }
 
 /*
--- LVM2/lib/report/report.h	2007/08/20 20:55:27	1.5
+++ LVM2/lib/report/report.h	2008/04/20 00:15:08	1.6
@@ -28,7 +28,7 @@
 
 void *report_init(struct cmd_context *cmd, const char *format, const char *keys,
 		  report_type_t *report_type, const char *separator,
-		  int aligned, int buffered, int headings);
+		  int aligned, int buffered, int headings, int field_prefixes);
 void report_free(void *handle);
 int report_object(void *handle, struct volume_group *vg,
 		  struct logical_volume *lv, struct physical_volume *pv,
--- LVM2/tools/args.h	2007/11/09 16:51:54	1.56
+++ LVM2/tools/args.h	2008/04/20 00:15:08	1.57
@@ -53,6 +53,7 @@
 arg(config_ARG, '\0', "config", string_arg, 0)
 arg(trustcache_ARG, '\0', "trustcache", NULL, 0)
 arg(ignoremonitoring_ARG, '\0', "ignoremonitoring", NULL, 0)
+arg(prefixes_ARG, '\0', "prefixes", NULL, 0)
 
 /* Allow some variations */
 arg(resizable_ARG, '\0', "resizable", yes_no_arg, 0)
--- LVM2/tools/commands.h	2008/04/09 13:47:13	1.110
+++ LVM2/tools/commands.h	2008/04/20 00:15:08	1.111
@@ -368,6 +368,7 @@
    "\t[-o|--options [+]Field[,Field]]\n"
    "\t[-O|--sort [+|-]key1[,[+|-]key2[,...]]]\n"
    "\t[-P|--partial] " "\n"
+   "\t[--prefixes]\n"
    "\t[--segments]\n"
    "\t[--separator Separator]\n"
    "\t[--trustcache]\n"
@@ -378,8 +379,9 @@
    "\t[LogicalVolume[Path] [LogicalVolume[Path]...]]\n",
 
    aligned_ARG, all_ARG, ignorelockingfailure_ARG, noheadings_ARG,
-   nolocking_ARG, nosuffix_ARG, options_ARG, partial_ARG, segments_ARG,
-   separator_ARG, sort_ARG, trustcache_ARG, unbuffered_ARG, units_ARG)
+   nolocking_ARG, nosuffix_ARG, options_ARG, partial_ARG, prefixes_ARG,
+   segments_ARG, separator_ARG, sort_ARG, trustcache_ARG, unbuffered_ARG,
+   units_ARG)
 
 xx(lvscan,
    "List all logical volumes in all volume groups",
@@ -575,6 +577,7 @@
    "\t[-o|--options [+]Field[,Field]]\n"
    "\t[-O|--sort [+|-]key1[,[+|-]key2[,...]]]\n"
    "\t[-P|--partial] " "\n"
+   "\t[--prefixes]\n"
    "\t[--segments]\n"
    "\t[--separator Separator]\n"
    "\t[--trustcache]\n"
@@ -585,8 +588,9 @@
    "\t[PhysicalVolume [PhysicalVolume...]]\n",
 
    aligned_ARG, all_ARG, ignorelockingfailure_ARG, noheadings_ARG,
-   nolocking_ARG, nosuffix_ARG, options_ARG, partial_ARG, segments_ARG,
-   separator_ARG, sort_ARG, trustcache_ARG, unbuffered_ARG, units_ARG)
+   nolocking_ARG, nosuffix_ARG, options_ARG, partial_ARG, prefixes_ARG,
+   segments_ARG, separator_ARG, sort_ARG, trustcache_ARG, unbuffered_ARG,
+   units_ARG)
 
 xx(pvscan,
    "List all physical volumes",
@@ -890,6 +894,7 @@
    "\t[-o|--options [+]Field[,Field]]\n"
    "\t[-O|--sort [+|-]key1[,[+|-]key2[,...]]]\n"
    "\t[-P|--partial] " "\n"
+   "\t[--prefixes]\n"
    "\t[--separator Separator]\n"
    "\t[--trustcache]\n"
    "\t[--unbuffered]\n"
@@ -899,8 +904,8 @@
    "\t[VolumeGroupName [VolumeGroupName...]]\n",
 
    aligned_ARG, all_ARG, ignorelockingfailure_ARG, noheadings_ARG,
-   nolocking_ARG, nosuffix_ARG, options_ARG, partial_ARG, separator_ARG,
-   sort_ARG, trustcache_ARG, unbuffered_ARG, units_ARG)
+   nolocking_ARG, nosuffix_ARG, options_ARG, partial_ARG, prefixes_ARG,
+   separator_ARG, sort_ARG, trustcache_ARG, unbuffered_ARG, units_ARG)
 
 xx(vgscan,
    "Search for all volume groups",
--- LVM2/tools/reporter.c	2008/01/30 14:00:02	1.35
+++ LVM2/tools/reporter.c	2008/04/20 00:15:08	1.36
@@ -158,7 +158,7 @@
 	char *str;
 	const char *keys = NULL, *options = NULL, *separator;
 	int r = ECMD_PROCESSED;
-	int aligned, buffered, headings;
+	int aligned, buffered, headings, field_prefixes;
 	unsigned args_are_pvs;
 
 	aligned = find_config_tree_int(cmd, "report/aligned",
@@ -169,6 +169,8 @@
 				   DEFAULT_REP_HEADINGS);
 	separator = find_config_tree_str(cmd, "report/separator",
 				    DEFAULT_REP_SEPARATOR);
+	field_prefixes = find_config_tree_int(cmd, "report/prefixes",
+					      DEFAULT_REP_PREFIXES);
 
 	args_are_pvs = (report_type == PVS || report_type == PVSEGS) ? 1 : 0;
 
@@ -270,10 +272,14 @@
 		buffered = 0;
 	if (arg_count(cmd, noheadings_ARG))
 		headings = 0;
+	if (arg_count(cmd, prefixes_ARG)) {
+		aligned = 0;
+		field_prefixes = 1;
+	}
 
 	if (!(report_handle = report_init(cmd, options, keys, &report_type,
 					  separator, aligned, buffered,
-					  headings))) {
+					  headings, field_prefixes))) {
 		stack;
 		return ECMD_FAILED;
 	}


