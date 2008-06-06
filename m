From: agk@sourceware.org <agk@sourceware.org>
Date: 6 Jun 2008 19:28:36 -0000
Subject: LVM2 ./VERSION ./WHATS_NEW lib/log/log.c lib/l ...
Message-ID: <20080606192836.21662.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-06-06 19:28:35

Modified files:
	.              : VERSION WHATS_NEW 
	lib/log        : log.c log.h 
	lib/metadata   : metadata.c 
	lib/report     : report.c 
	tools          : args.h commands.h lvm.c lvmcmdline.c reporter.c 

Log message:
	post-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.175&r2=1.176
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.888&r2=1.889
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/log/log.c.diff?cvsroot=lvm2&r1=1.45&r2=1.46
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/log/log.h.diff?cvsroot=lvm2&r1=1.40&r2=1.41
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.179&r2=1.180
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.83&r2=1.84
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/args.h.diff?cvsroot=lvm2&r1=1.57&r2=1.58
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.114&r2=1.115
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvm.c.diff?cvsroot=lvm2&r1=1.108&r2=1.109
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.66&r2=1.67
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/reporter.c.diff?cvsroot=lvm2&r1=1.36&r2=1.37

--- LVM2/VERSION	2008/06/06 17:36:18	1.175
+++ LVM2/VERSION	2008/06/06 19:28:33	1.176
@@ -1 +1 @@
-2.02.37-cvs (2008-06-06)
+2.02.38-cvs (2008-06-06)
--- LVM2/WHATS_NEW	2008/06/06 17:36:18	1.888
+++ LVM2/WHATS_NEW	2008/06/06 19:28:33	1.889
@@ -1,3 +1,10 @@
+Version 2.02.38 - 
+=================================
+  In script-processing mode, stop if any command fails.
+  Warn if command exits with non-zero status code without a prior log_error.
+  Check lv_count in vg_validate.
+  Add --nameprefixes to reporting tools for field name prefix output format.
+
 Version 2.02.37 - 6th June 2008
 ===============================
   Make clvmd-cman use a hash rather than an array for node updown info.
--- LVM2/lib/log/log.c	2008/06/06 17:36:18	1.45
+++ LVM2/lib/log/log.c	2008/06/06 19:28:33	1.46
@@ -51,6 +51,7 @@
 static int _mirror_in_sync = 0;
 static int _dmeventd_monitor = DEFAULT_DMEVENTD_MONITOR;
 static int _ignore_suspended_devices = 0;
+static int _error_message_produced = 0;
 
 static lvm2_log_fn_t _lvm2_log_fn = NULL;
 
@@ -238,6 +239,16 @@
 	_indent = indent;
 }
 
+void init_error_message_produced(int error_message_produced)
+{
+	_error_message_produced = error_message_produced;
+}
+
+int error_message_produced(void)
+{
+	return _error_message_produced;
+}
+
 int test_mode()
 {
 	return _test;
@@ -322,6 +333,9 @@
 	if (_log_suppress == 2)
 		return;
 
+	if (level <= _LOG_ERR)
+		_error_message_produced = 1;
+
 	trformat = _(format);
 
 	if (_lvm2_log_fn) {
--- LVM2/lib/log/log.h	2008/06/06 17:36:18	1.40
+++ LVM2/lib/log/log.h	2008/06/06 19:28:34	1.41
@@ -79,6 +79,7 @@
 void init_mirror_in_sync(int in_sync);
 void init_dmeventd_monitor(int reg);
 void init_ignore_suspended_devices(int ignore);
+void init_error_message_produced(int error_message_produced);
 
 void set_cmd_name(const char *cmd_name);
 
@@ -94,6 +95,7 @@
 int security_level(void);
 int mirror_in_sync(void);
 int ignore_suspended_devices(void);
+int error_message_produced(void);
 
 #define DMEVENTD_MONITOR_IGNORE -1
 int dmeventd_monitor_mode(void);
--- LVM2/lib/metadata/metadata.c	2008/06/06 17:36:19	1.179
+++ LVM2/lib/metadata/metadata.c	2008/06/06 19:28:34	1.180
@@ -1213,10 +1213,11 @@
 
 	if ((lv_count = (uint32_t) list_size(&vg->lvs)) !=
 	    vg->lv_count + 2 * vg->snapshot_count) {
-		log_debug("Internal error: #internal LVs (%u) != #LVs (%"
+		log_error("Internal error: #internal LVs (%u) != #LVs (%"
 			  PRIu32 ") + 2 * #snapshots (%" PRIu32 ") in VG %s",
 			  list_size(&vg->lvs), vg->lv_count,
 			  vg->snapshot_count, vg->name);
+		r = 0;
 	}
 
 	list_iterate_items(lvl, &vg->lvs) {
--- LVM2/lib/report/report.c	2008/06/06 17:36:19	1.83
+++ LVM2/lib/report/report.c	2008/06/06 19:28:34	1.84
@@ -1091,9 +1091,15 @@
 	if (headings)
 		report_flags |= DM_REPORT_OUTPUT_HEADINGS;
 
+	if (field_prefixes)
+		report_flags |= DM_REPORT_OUTPUT_FIELD_NAME_PREFIX;
+
 	rh = dm_report_init(report_type, _report_types, _fields, format,
 			    separator, report_flags, keys, cmd);
 
+	if (field_prefixes)
+		dm_report_set_output_field_name_prefix(rh, "lvm2_");
+
 	return rh;
 }
 
--- LVM2/tools/args.h	2008/04/20 00:15:08	1.57
+++ LVM2/tools/args.h	2008/06/06 19:28:35	1.58
@@ -53,7 +53,7 @@
 arg(config_ARG, '\0', "config", string_arg, 0)
 arg(trustcache_ARG, '\0', "trustcache", NULL, 0)
 arg(ignoremonitoring_ARG, '\0', "ignoremonitoring", NULL, 0)
-arg(prefixes_ARG, '\0', "prefixes", NULL, 0)
+arg(nameprefixes_ARG, '\0', "nameprefixes", NULL, 0)
 
 /* Allow some variations */
 arg(resizable_ARG, '\0', "resizable", yes_no_arg, 0)
--- LVM2/tools/commands.h	2008/06/06 17:36:19	1.114
+++ LVM2/tools/commands.h	2008/06/06 19:28:35	1.115
@@ -363,6 +363,7 @@
    "\t[-d|--debug]\n"
    "\t[-h|--help]\n"
    "\t[--ignorelockingfailure]\n"
+   "\t[--nameprefixes]\n"
    "\t[--noheadings]\n"
    "\t[--nosuffix]\n"
    "\t[-o|--options [+]Field[,Field]]\n"
@@ -377,8 +378,8 @@
    "\t[--version]" "\n"
    "\t[LogicalVolume[Path] [LogicalVolume[Path]...]]\n",
 
-   aligned_ARG, all_ARG, ignorelockingfailure_ARG, noheadings_ARG,
-   nolocking_ARG, nosuffix_ARG, options_ARG, partial_ARG, 
+   aligned_ARG, all_ARG, ignorelockingfailure_ARG, nameprefixes_ARG,
+   noheadings_ARG, nolocking_ARG, nosuffix_ARG, options_ARG, partial_ARG, 
    segments_ARG, separator_ARG, sort_ARG, trustcache_ARG, unbuffered_ARG,
    units_ARG)
 
@@ -570,8 +571,9 @@
    "\t[-a|--all]\n"
    "\t[-d|--debug]" "\n"
    "\t[-h|-?|--help] " "\n"
-   "\t[--noheadings]\n"
    "\t[--ignorelockingfailure]\n"
+   "\t[--nameprefixes]\n"
+   "\t[--noheadings]\n"
    "\t[--nosuffix]\n"
    "\t[-o|--options [+]Field[,Field]]\n"
    "\t[-O|--sort [+|-]key1[,[+|-]key2[,...]]]\n"
@@ -585,8 +587,8 @@
    "\t[--version]\n"
    "\t[PhysicalVolume [PhysicalVolume...]]\n",
 
-   aligned_ARG, all_ARG, ignorelockingfailure_ARG, noheadings_ARG,
-   nolocking_ARG, nosuffix_ARG, options_ARG, partial_ARG, 
+   aligned_ARG, all_ARG, ignorelockingfailure_ARG, nameprefixes_ARG,
+   noheadings_ARG, nolocking_ARG, nosuffix_ARG, options_ARG, partial_ARG,
    segments_ARG, separator_ARG, sort_ARG, trustcache_ARG, unbuffered_ARG,
    units_ARG)
 
@@ -887,6 +889,7 @@
    "\t[-d|--debug]\n"
    "\t[-h|--help]\n"
    "\t[--ignorelockingfailure]\n"
+   "\t[--nameprefixes]\n"
    "\t[--noheadings]\n"
    "\t[--nosuffix]\n"
    "\t[-o|--options [+]Field[,Field]]\n"
@@ -900,8 +903,8 @@
    "\t[--version]\n"
    "\t[VolumeGroupName [VolumeGroupName...]]\n",
 
-   aligned_ARG, all_ARG, ignorelockingfailure_ARG, noheadings_ARG,
-   nolocking_ARG, nosuffix_ARG, options_ARG, partial_ARG, 
+   aligned_ARG, all_ARG, ignorelockingfailure_ARG, nameprefixes_ARG,
+   noheadings_ARG, nolocking_ARG, nosuffix_ARG, options_ARG, partial_ARG, 
    separator_ARG, sort_ARG, trustcache_ARG, unbuffered_ARG, units_ARG)
 
 xx(vgscan,
--- LVM2/tools/lvm.c	2008/06/06 17:36:19	1.108
+++ LVM2/tools/lvm.c	2008/06/06 19:28:35	1.109
@@ -236,6 +236,10 @@
 			log_error("No such command '%s'.  Try 'help'.",
 				  argv[0]);
 
+                if ((ret != ECMD_PROCESSED) && !error_message_produced()) {
+			log_debug("Internal error: Failed command did not use log_error");
+			log_error("Command failed with status code %d.", ret);
+		}
 		_write_history();
 	}
 
--- LVM2/tools/lvmcmdline.c	2008/06/06 17:36:19	1.66
+++ LVM2/tools/lvmcmdline.c	2008/06/06 19:28:35	1.67
@@ -875,6 +875,8 @@
 	int ret = 0;
 	int locking_type;
 
+	init_error_message_produced(0);
+
 	/* each command should start out with sigint flag cleared */
 	sigint_clear();
 
@@ -1096,7 +1098,14 @@
 			continue;
 		if (!strcmp(argv[0], "quit") || !strcmp(argv[0], "exit"))
 			break;
-		lvm_run_command(cmd, argc, argv);
+		ret = lvm_run_command(cmd, argc, argv);
+		if (ret != ECMD_PROCESSED) {
+			if (!error_message_produced()) {
+				log_debug("Internal error: Failed command did not use log_error");
+				log_error("Command failed with status code %d.", ret);
+			}
+			break;
+		}
 	}
 
 	if (fclose(script))
@@ -1218,6 +1227,11 @@
 	if (ret == ENO_SUCH_CMD)
 		log_error("No such command.  Try 'help'.");
 
+	if ((ret != ECMD_PROCESSED) && !error_message_produced()) {
+		log_debug("Internal error: Failed command did not use log_error");
+		log_error("Command failed with status code %d.", ret);
+	}
+
       out:
 	lvm_fin(cmd);
 	if (ret == ECMD_PROCESSED)
--- LVM2/tools/reporter.c	2008/04/20 00:15:08	1.36
+++ LVM2/tools/reporter.c	2008/06/06 19:28:35	1.37
@@ -272,7 +272,7 @@
 		buffered = 0;
 	if (arg_count(cmd, noheadings_ARG))
 		headings = 0;
-	if (arg_count(cmd, prefixes_ARG)) {
+	if (arg_count(cmd, nameprefixes_ARG)) {
 		aligned = 0;
 		field_prefixes = 1;
 	}


