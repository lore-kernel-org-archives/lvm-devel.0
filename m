From: agk@sourceware.org <agk@sourceware.org>
Date: 6 Jun 2008 17:36:20 -0000
Subject: LVM2 ./VERSION ./WHATS_NEW lib/log/log.c lib/l ...
Message-ID: <20080606173620.8023.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-06-06 17:36:19

Modified files:
	.              : VERSION WHATS_NEW 
	lib/log        : log.c log.h 
	lib/metadata   : metadata.c 
	lib/report     : report.c 
	tools          : commands.h lvm.c lvmcmdline.c 

Log message:
	back out unnecessary changes for this release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.174&r2=1.175
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.887&r2=1.888
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/log/log.c.diff?cvsroot=lvm2&r1=1.44&r2=1.45
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/log/log.h.diff?cvsroot=lvm2&r1=1.39&r2=1.40
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.178&r2=1.179
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.82&r2=1.83
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.113&r2=1.114
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvm.c.diff?cvsroot=lvm2&r1=1.107&r2=1.108
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.65&r2=1.66

--- LVM2/VERSION	2008/04/29 16:11:26	1.174
+++ LVM2/VERSION	2008/06/06 17:36:18	1.175
@@ -1 +1 @@
-2.02.37-cvs (2008-04-29)
+2.02.37-cvs (2008-06-06)
--- LVM2/WHATS_NEW	2008/06/06 17:24:28	1.887
+++ LVM2/WHATS_NEW	2008/06/06 17:36:18	1.888
@@ -1,10 +1,3 @@
-Version 2.02.38 - 
-=================================
-  In script-processing mode, stop if any command fails.
-  Warn if command exits with non-zero status code without a prior log_error.
-  Check lv_count in vg_validate.
-  Add --prefixes to reporting tools for field name prefix output format.
-
 Version 2.02.37 - 6th June 2008
 ===============================
   Make clvmd-cman use a hash rather than an array for node updown info.
--- LVM2/lib/log/log.c	2008/05/30 15:27:44	1.44
+++ LVM2/lib/log/log.c	2008/06/06 17:36:18	1.45
@@ -51,7 +51,6 @@
 static int _mirror_in_sync = 0;
 static int _dmeventd_monitor = DEFAULT_DMEVENTD_MONITOR;
 static int _ignore_suspended_devices = 0;
-static int _error_message_produced = 0;
 
 static lvm2_log_fn_t _lvm2_log_fn = NULL;
 
@@ -239,16 +238,6 @@
 	_indent = indent;
 }
 
-void init_error_message_produced(int error_message_produced)
-{
-	_error_message_produced = error_message_produced;
-}
-
-int error_message_produced(void)
-{
-	return _error_message_produced;
-}
-
 int test_mode()
 {
 	return _test;
@@ -333,9 +322,6 @@
 	if (_log_suppress == 2)
 		return;
 
-	if (level <= _LOG_ERR)
-		_error_message_produced = 1;
-
 	trformat = _(format);
 
 	if (_lvm2_log_fn) {
--- LVM2/lib/log/log.h	2008/05/30 15:27:44	1.39
+++ LVM2/lib/log/log.h	2008/06/06 17:36:18	1.40
@@ -79,7 +79,6 @@
 void init_mirror_in_sync(int in_sync);
 void init_dmeventd_monitor(int reg);
 void init_ignore_suspended_devices(int ignore);
-void init_error_message_produced(int error_message_produced);
 
 void set_cmd_name(const char *cmd_name);
 
@@ -95,7 +94,6 @@
 int security_level(void);
 int mirror_in_sync(void);
 int ignore_suspended_devices(void);
-int error_message_produced(void);
 
 #define DMEVENTD_MONITOR_IGNORE -1
 int dmeventd_monitor_mode(void);
--- LVM2/lib/metadata/metadata.c	2008/06/06 11:12:50	1.178
+++ LVM2/lib/metadata/metadata.c	2008/06/06 17:36:19	1.179
@@ -1213,11 +1213,10 @@
 
 	if ((lv_count = (uint32_t) list_size(&vg->lvs)) !=
 	    vg->lv_count + 2 * vg->snapshot_count) {
-		log_error("Internal error: #internal LVs (%u) != #LVs (%"
+		log_debug("Internal error: #internal LVs (%u) != #LVs (%"
 			  PRIu32 ") + 2 * #snapshots (%" PRIu32 ") in VG %s",
 			  list_size(&vg->lvs), vg->lv_count,
 			  vg->snapshot_count, vg->name);
-		r = 0;
 	}
 
 	list_iterate_items(lvl, &vg->lvs) {
--- LVM2/lib/report/report.c	2008/04/29 16:11:27	1.82
+++ LVM2/lib/report/report.c	2008/06/06 17:36:19	1.83
@@ -1091,15 +1091,9 @@
 	if (headings)
 		report_flags |= DM_REPORT_OUTPUT_HEADINGS;
 
-	if (field_prefixes)
-		report_flags |= DM_REPORT_OUTPUT_FIELD_NAME_PREFIX;
-
 	rh = dm_report_init(report_type, _report_types, _fields, format,
 			    separator, report_flags, keys, cmd);
 
-	if (field_prefixes)
-		dm_report_set_output_field_name_prefix(rh, "lvm2_");
-
 	return rh;
 }
 
--- LVM2/tools/commands.h	2008/04/29 16:11:28	1.113
+++ LVM2/tools/commands.h	2008/06/06 17:36:19	1.114
@@ -368,7 +368,6 @@
    "\t[-o|--options [+]Field[,Field]]\n"
    "\t[-O|--sort [+|-]key1[,[+|-]key2[,...]]]\n"
    "\t[-P|--partial] " "\n"
-   "\t[--prefixes]\n"
    "\t[--segments]\n"
    "\t[--separator Separator]\n"
    "\t[--trustcache]\n"
@@ -379,7 +378,7 @@
    "\t[LogicalVolume[Path] [LogicalVolume[Path]...]]\n",
 
    aligned_ARG, all_ARG, ignorelockingfailure_ARG, noheadings_ARG,
-   nolocking_ARG, nosuffix_ARG, options_ARG, partial_ARG, prefixes_ARG,
+   nolocking_ARG, nosuffix_ARG, options_ARG, partial_ARG, 
    segments_ARG, separator_ARG, sort_ARG, trustcache_ARG, unbuffered_ARG,
    units_ARG)
 
@@ -577,7 +576,6 @@
    "\t[-o|--options [+]Field[,Field]]\n"
    "\t[-O|--sort [+|-]key1[,[+|-]key2[,...]]]\n"
    "\t[-P|--partial] " "\n"
-   "\t[--prefixes]\n"
    "\t[--segments]\n"
    "\t[--separator Separator]\n"
    "\t[--trustcache]\n"
@@ -588,7 +586,7 @@
    "\t[PhysicalVolume [PhysicalVolume...]]\n",
 
    aligned_ARG, all_ARG, ignorelockingfailure_ARG, noheadings_ARG,
-   nolocking_ARG, nosuffix_ARG, options_ARG, partial_ARG, prefixes_ARG,
+   nolocking_ARG, nosuffix_ARG, options_ARG, partial_ARG, 
    segments_ARG, separator_ARG, sort_ARG, trustcache_ARG, unbuffered_ARG,
    units_ARG)
 
@@ -894,7 +892,6 @@
    "\t[-o|--options [+]Field[,Field]]\n"
    "\t[-O|--sort [+|-]key1[,[+|-]key2[,...]]]\n"
    "\t[-P|--partial] " "\n"
-   "\t[--prefixes]\n"
    "\t[--separator Separator]\n"
    "\t[--trustcache]\n"
    "\t[--unbuffered]\n"
@@ -904,7 +901,7 @@
    "\t[VolumeGroupName [VolumeGroupName...]]\n",
 
    aligned_ARG, all_ARG, ignorelockingfailure_ARG, noheadings_ARG,
-   nolocking_ARG, nosuffix_ARG, options_ARG, partial_ARG, prefixes_ARG,
+   nolocking_ARG, nosuffix_ARG, options_ARG, partial_ARG, 
    separator_ARG, sort_ARG, trustcache_ARG, unbuffered_ARG, units_ARG)
 
 xx(vgscan,
--- LVM2/tools/lvm.c	2008/06/03 17:48:13	1.107
+++ LVM2/tools/lvm.c	2008/06/06 17:36:19	1.108
@@ -236,10 +236,6 @@
 			log_error("No such command '%s'.  Try 'help'.",
 				  argv[0]);
 
-                if ((ret != ECMD_PROCESSED) && !error_message_produced()) {
-			log_debug("Internal error: Failed command did not use log_error");
-			log_error("Command failed with status code %d.", ret);
-		}
 		_write_history();
 	}
 
--- LVM2/tools/lvmcmdline.c	2008/06/03 17:48:13	1.65
+++ LVM2/tools/lvmcmdline.c	2008/06/06 17:36:19	1.66
@@ -875,8 +875,6 @@
 	int ret = 0;
 	int locking_type;
 
-	init_error_message_produced(0);
-
 	/* each command should start out with sigint flag cleared */
 	sigint_clear();
 
@@ -1098,14 +1096,7 @@
 			continue;
 		if (!strcmp(argv[0], "quit") || !strcmp(argv[0], "exit"))
 			break;
-		ret = lvm_run_command(cmd, argc, argv);
-		if (ret != ECMD_PROCESSED) {
-			if (!error_message_produced()) {
-				log_debug("Internal error: Failed command did not use log_error");
-				log_error("Command failed with status code %d.", ret);
-			}
-			break;
-		}
+		lvm_run_command(cmd, argc, argv);
 	}
 
 	if (fclose(script))
@@ -1227,11 +1218,6 @@
 	if (ret == ENO_SUCH_CMD)
 		log_error("No such command.  Try 'help'.");
 
-	if ((ret != ECMD_PROCESSED) && !error_message_produced()) {
-		log_debug("Internal error: Failed command did not use log_error");
-		log_error("Command failed with status code %d.", ret);
-	}
-
       out:
 	lvm_fin(cmd);
 	if (ret == ECMD_PROCESSED)


