From: agk@sourceware.org <agk@sourceware.org>
Date: 30 May 2008 15:27:45 -0000
Subject: LVM2 ./WHATS_NEW lib/log/log.c lib/log/log.h t ...
Message-ID: <20080530152745.21888.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-05-30 15:27:44

Modified files:
	.              : WHATS_NEW 
	lib/log        : log.c log.h 
	tools          : lvm.c lvmcmdline.c 

Log message:
	In script-processing mode, stop if any command fails.
	Warn if command exits with non-zero status code without a prior log_error.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.877&r2=1.878
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/log/log.c.diff?cvsroot=lvm2&r1=1.43&r2=1.44
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/log/log.h.diff?cvsroot=lvm2&r1=1.38&r2=1.39
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvm.c.diff?cvsroot=lvm2&r1=1.105&r2=1.106
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.63&r2=1.64

--- LVM2/WHATS_NEW	2008/05/28 22:27:47	1.877
+++ LVM2/WHATS_NEW	2008/05/30 15:27:44	1.878
@@ -1,5 +1,7 @@
 Version 2.02.38 - 
 =================================
+  In script-processing mode, stop if any command fails.
+  Warn if command exits with non-zero status code without a prior log_error.
   Make clvmd-cman use a hash rather than an array for node updown info.
   Check lv_count in vg_validate.
   Add --prefixes to reporting tools for field name prefix output format.
--- LVM2/lib/log/log.c	2008/04/07 13:53:26	1.43
+++ LVM2/lib/log/log.c	2008/05/30 15:27:44	1.44
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
--- LVM2/lib/log/log.h	2007/08/20 20:55:26	1.38
+++ LVM2/lib/log/log.h	2008/05/30 15:27:44	1.39
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
--- LVM2/tools/lvm.c	2008/01/31 12:19:36	1.105
+++ LVM2/tools/lvm.c	2008/05/30 15:27:44	1.106
@@ -236,6 +236,10 @@
 			log_error("No such command '%s'.  Try 'help'.",
 				  argv[0]);
 
+                if (ret && !error_message_produced()) {
+			log_debug("Internal error: Failed command did not use log_error");
+			log_error("Command failed with status code %d.", ret);
+		}
 		_write_history();
 	}
 
--- LVM2/tools/lvmcmdline.c	2008/04/08 12:49:21	1.63
+++ LVM2/tools/lvmcmdline.c	2008/05/30 15:27:44	1.64
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
+		if (ret) {
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
 
+	if (ret && !error_message_produced()) {
+		log_debug("Internal error: Failed command did not use log_error");
+		log_error("Command failed with status code %d.", ret);
+	}
+
       out:
 	lvm_fin(cmd);
 	if (ret == ECMD_PROCESSED)


