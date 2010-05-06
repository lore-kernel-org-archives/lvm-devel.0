From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 6 May 2010 11:15:58 -0000
Subject: LVM2 ./WHATS_NEW lib/locking/locking.c lib/loc ...
Message-ID: <20100506111558.1469.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2010-05-06 11:15:56

Modified files:
	.              : WHATS_NEW 
	lib/locking    : locking.c locking.h 
	liblvm         : lvm_base.c 
	man            : lvchange.8.in vgchange.8.in 
	tools          : args.h commands.h lvchange.c lvmcmdline.c 
	                 toollib.c vgchange.c 

Log message:
	Add new --sysinit option for vgchange and lvchange.
	
	A shortcut for --ignorelockingfailure, --ignoremonitoring, --poll n options
	and LVM_SUPPRESS_LOCKING_FAILURE_MESSAGES environment variable used all at
	once in initialisation scripts (e.g. rc.sysinit or initrd).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1548&r2=1.1549
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.c.diff?cvsroot=lvm2&r1=1.79&r2=1.80
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.h.diff?cvsroot=lvm2&r1=1.53&r2=1.54
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_base.c.diff?cvsroot=lvm2&r1=1.15&r2=1.16
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvchange.8.in.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgchange.8.in.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/args.h.diff?cvsroot=lvm2&r1=1.73&r2=1.74
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.145&r2=1.146
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvchange.c.diff?cvsroot=lvm2&r1=1.119&r2=1.120
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.121&r2=1.122
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.196&r2=1.197
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.101&r2=1.102

--- LVM2/WHATS_NEW	2010/05/06 10:10:15	1.1548
+++ LVM2/WHATS_NEW	2010/05/06 11:15:55	1.1549
@@ -1,5 +1,6 @@
 Version 2.02.65 - 
 =================================
+  Add new --sysinit option for vgchange and lvchange.
   Suppress duplicate error messages about read failures and missing devices.
   Install plugins to $(libdir)/device-mapper and $(libdir)/lvm2.
   Add dm_list_splice() function to join two lists together.
--- LVM2/lib/locking/locking.c	2010/04/13 01:54:33	1.79
+++ LVM2/lib/locking/locking.c	2010/05/06 11:15:55	1.80
@@ -217,10 +217,8 @@
  * Select a locking type
  * type: locking type; if < 0, then read config tree value
  */
-int init_locking(int type, struct cmd_context *cmd)
+int init_locking(int type, struct cmd_context *cmd, int suppress_messages)
 {
-	int suppress_messages = 0;
-
 	if (ignorelockingfailure() && getenv("LVM_SUPPRESS_LOCKING_FAILURE_MESSAGES"))
 		suppress_messages = 1;
 
--- LVM2/lib/locking/locking.h	2010/01/05 16:09:34	1.53
+++ LVM2/lib/locking/locking.h	2010/05/06 11:15:55	1.54
@@ -19,7 +19,7 @@
 #include "uuid.h"
 #include "config.h"
 
-int init_locking(int type, struct cmd_context *cmd);
+int init_locking(int type, struct cmd_context *cmd, int suppress_messages);
 void fin_locking(void);
 void reset_locking(void);
 int vg_write_lock_held(void);
--- LVM2/liblvm/lvm_base.c	2010/03/17 14:45:28	1.15
+++ LVM2/liblvm/lvm_base.c	2010/05/06 11:15:55	1.16
@@ -50,7 +50,7 @@
 
 	/* FIXME: locking_type config option needed? */
 	/* initialize locking */
-	if (!init_locking(-1, cmd)) {
+	if (!init_locking(-1, cmd, 0)) {
 		/* FIXME: use EAGAIN as error code here */
 		lvm_quit((lvm_t) cmd);
 		return NULL;
--- LVM2/man/lvchange.8.in	2010/03/23 22:30:20	1.7
+++ LVM2/man/lvchange.8.in	2010/05/06 11:15:55	1.8
@@ -13,6 +13,7 @@
 [\-\-ignoremonitoring]
 [\-\-monitor {y|n}]
 [\-\-poll {y|n}]
+[\-\-sysinit]
 [\-\-noudevsync]
 [\-M|\-\-persistent y|n] [\-\-minor minor]
 [\-P|\-\-partial]
@@ -71,6 +72,15 @@
 immediately poll a logical volume when it is activated, use \fB--poll
 n\fP to defer and then \fB--poll y\fP to restart the process.
 .TP
+.I \-\-sysinit
+Indicates that lvchange(8) is being invoked from early system initialisation
+scripts (e.g. rc.sysinit or an initrd), before writeable filesystems are
+available. As such, some functionality needs to be disabled and this option
+acts as a shortcut which selects an appropriate set of options. Currently
+this is equivalent to using  \fB--ignorelockingfailure\fP, \fB--ignoremonitoring\fP,
+\fB--poll n\fP and setting \fBLVM_SUPPRESS_LOCKING_FAILURE_MESSAGES\fP
+environment variable.
+.TP
 .I \-\-noudevsync
 Disable udev synchronisation. The
 process will not wait for notification from udev.
--- LVM2/man/vgchange.8.in	2010/03/23 22:30:20	1.8
+++ LVM2/man/vgchange.8.in	2010/05/06 11:15:55	1.9
@@ -19,6 +19,7 @@
 .RB [ \-h | \-\-help]
 .RB [ \-\-ignorelockingfailure]
 .RB [ \-\-ignoremonitoring]
+.RB [ \-\-sysinit]
 .RB [ \-\-noudevsync ]
 .RB [ \-l | \-\-logicalvolume
 .IR MaxLogicalVolumes ]
@@ -96,6 +97,15 @@
 immediately poll a logical volume when it is activated, use \fB--poll
 n\fP to defer and then \fB--poll y\fP to restart the process.
 .TP
+.BR \-\-sysinit
+Indicates that vgchange(8) is being invoked from early system initialisation
+scripts (e.g. rc.sysinit or an initrd), before writeable filesystems are
+available. As such, some functionality needs to be disabled and this option
+acts as a shortcut which selects an appropriate set of options. Currently
+this is equivalent to using  \fB--ignorelockingfailure\fP, \fB--ignoremonitoring\fP,
+\fB--poll n\fP and setting \fBLVM_SUPPRESS_LOCKING_FAILURE_MESSAGES\fP
+environment variable.
+.TP
 .BR \-\-noudevsync
 Disable udev synchronisation. The
 process will not wait for notification from udev.
--- LVM2/tools/args.h	2010/04/13 01:54:33	1.73
+++ LVM2/tools/args.h	2010/05/06 11:15:55	1.74
@@ -66,6 +66,7 @@
 arg(noudevsync_ARG, '\0', "noudevsync", NULL, 0)
 arg(poll_ARG, '\0', "poll", yes_no_arg, 0)
 arg(stripes_long_ARG, '\0', "stripes", int_arg, 0)
+arg(sysinit_ARG, '\0', "sysinit", NULL, 0)
 
 /* Allow some variations */
 arg(resizable_ARG, '\0', "resizable", yes_no_arg, 0)
--- LVM2/tools/commands.h	2010/04/20 18:17:56	1.145
+++ LVM2/tools/commands.h	2010/05/06 11:15:55	1.146
@@ -80,6 +80,7 @@
    "\t[-r|--readahead ReadAheadSectors|auto|none]\n"
    "\t[--refresh]\n"
    "\t[--resync]\n"
+   "\t[--sysinit]\n"
    "\t[-t|--test]\n"
    "\t[-v|--verbose]\n"
    "\t[-y|--yes]\n"
@@ -90,7 +91,7 @@
    ignorelockingfailure_ARG, ignoremonitoring_ARG, major_ARG, minor_ARG,
    monitor_ARG, noudevsync_ARG, partial_ARG, permission_ARG, persistent_ARG,
    poll_ARG, readahead_ARG, resync_ARG, refresh_ARG, addtag_ARG, deltag_ARG,
-   test_ARG, yes_ARG)
+   sysinit_ARG, test_ARG, yes_ARG)
 
 xx(lvconvert,
    "Change logical volume layout",
@@ -711,6 +712,7 @@
    "\t[--poll {y|n}]\n"
    "\t[--noudevsync]\n"
    "\t[--refresh]\n"
+   "\t[--sysinit]\n"
    "\t[-t|--test]" "\n"
    "\t[-u|--uuid] " "\n"
    "\t[-v|--verbose] " "\n"
@@ -729,7 +731,7 @@
    clustered_ARG, deltag_ARG, ignorelockingfailure_ARG, ignoremonitoring_ARG,
    logicalvolume_ARG, maxphysicalvolumes_ARG, monitor_ARG, noudevsync_ARG,
    partial_ARG, physicalextentsize_ARG, poll_ARG, refresh_ARG, resizeable_ARG,
-   resizable_ARG, test_ARG, uuid_ARG)
+   resizable_ARG, sysinit_ARG, test_ARG, uuid_ARG)
 
 xx(vgck,
    "Check the consistency of volume group(s)",
--- LVM2/tools/lvchange.c	2010/03/29 16:09:41	1.119
+++ LVM2/tools/lvchange.c	2010/05/06 11:15:56	1.120
@@ -586,9 +586,12 @@
 	 * should only be started if the LV is not already active. So:
 	 * 1) change the activation code to say if the LV was actually activated
 	 * 2) make polling of an LV tightly coupled with LV activation
+	 *
+	 * Do not initiate any polling if --sysinit option is used.
 	 */
-	init_background_polling(arg_int_value(cmd, poll_ARG,
-					      DEFAULT_BACKGROUND_POLLING));
+	init_background_polling(arg_count(cmd, sysinit_ARG) ? 0 :
+						arg_int_value(cmd, poll_ARG,
+						DEFAULT_BACKGROUND_POLLING));
 
 	/* access permission change */
 	if (arg_count(cmd, permission_ARG)) {
@@ -730,8 +733,9 @@
 	     arg_count(cmd, addtag_ARG) || arg_count(cmd, deltag_ARG) ||
 	     arg_count(cmd, resync_ARG) || arg_count(cmd, alloc_ARG));
 
-	if (arg_count(cmd, ignorelockingfailure_ARG) && !avail_only) {
-		log_error("Only -a permitted with --ignorelockingfailure");
+	if ((arg_count(cmd, ignorelockingfailure_ARG) ||
+	     arg_count(cmd, sysinit_ARG)) && !avail_only) {
+		log_error("Only -a permitted with --ignorelockingfailure and --sysinit");
 		return EINVALID_CMD_LINE;
 	}
 
@@ -759,6 +763,11 @@
 		return EINVALID_CMD_LINE;
 	}
 
+	if (arg_count(cmd, poll_ARG) && arg_count(cmd, sysinit_ARG)) {
+		log_error("Only one of --poll and --sysinit permitted");
+		return EINVALID_CMD_LINE;
+	}
+
 	return process_each_lv(cmd, argc, argv,
 			       avail_only ? 0 : READ_FOR_UPDATE, NULL,
 			       &lvchange_single);
--- LVM2/tools/lvmcmdline.c	2010/05/05 22:37:53	1.121
+++ LVM2/tools/lvmcmdline.c	2010/05/06 11:15:56	1.122
@@ -793,7 +793,7 @@
 			  "be activated read-only.");
 	}
 
-	if (arg_count(cmd, ignorelockingfailure_ARG))
+	if (arg_count(cmd, ignorelockingfailure_ARG) || arg_count(cmd, sysinit_ARG))
 		init_ignorelockingfailure(1);
 	else
 		init_ignorelockingfailure(0);
@@ -1049,7 +1049,7 @@
 	else
 		locking_type = -1;
 
-	if (!init_locking(locking_type, cmd)) {
+	if (!init_locking(locking_type, cmd, arg_count(cmd, sysinit_ARG))) {
 		ret = ECMD_FAILED;
 		goto out;
 	}
--- LVM2/tools/toollib.c	2010/04/28 12:23:11	1.196
+++ LVM2/tools/toollib.c	2010/05/06 11:15:56	1.197
@@ -1372,8 +1372,9 @@
 	*monitoring_mode = DEFAULT_DMEVENTD_MONITOR;
 
 	if (arg_count(cmd, monitor_ARG) &&
-	    arg_count(cmd, ignoremonitoring_ARG)) {
-		log_error("Conflicting monitor and ignoremonitoring options");
+	    (arg_count(cmd, ignoremonitoring_ARG) ||
+	     arg_count(cmd, sysinit_ARG))) {
+		log_error("--ignoremonitoring or --sysinit option not allowed with --monitor option");
 		return 0;
 	}
 
@@ -1381,6 +1382,7 @@
 		*monitoring_mode = arg_int_value(cmd, monitor_ARG,
 						 DEFAULT_DMEVENTD_MONITOR);
 	else if (is_static() || arg_count(cmd, ignoremonitoring_ARG) ||
+		 arg_count(cmd, sysinit_ARG) ||
 		 !find_config_tree_bool(cmd, "activation/monitoring",
 					DEFAULT_DMEVENTD_MONITOR))
 		*monitoring_mode = DMEVENTD_MONITOR_IGNORE;
--- LVM2/tools/vgchange.c	2010/03/29 16:09:41	1.101
+++ LVM2/tools/vgchange.c	2010/05/06 11:15:56	1.102
@@ -540,9 +540,12 @@
 	 * should only be started if the LV is not already active. So:
 	 * 1) change the activation code to say if the LV was actually activated
 	 * 2) make polling of an LV tightly coupled with LV activation
+	 *
+	 * Do not initiate any polling if --sysinit option is used.
 	 */
-	init_background_polling(arg_int_value(cmd, poll_ARG,
-					      DEFAULT_BACKGROUND_POLLING));
+	init_background_polling(arg_count(cmd, sysinit_ARG) ? 0 :
+						arg_int_value(cmd, poll_ARG,
+						DEFAULT_BACKGROUND_POLLING));
 
 	if (arg_count(cmd, available_ARG))
 		r = _vgchange_available(cmd, vg);
@@ -615,9 +618,14 @@
 		return EINVALID_CMD_LINE;
 	}
 
-	if (arg_count(cmd, ignorelockingfailure_ARG) &&
-	    !arg_count(cmd, available_ARG)) {
-		log_error("--ignorelockingfailure only available with -a");
+	if ((arg_count(cmd, ignorelockingfailure_ARG) ||
+	     arg_count(cmd, sysinit_ARG)) && !arg_count(cmd, available_ARG)) {
+		log_error("Only -a premitted with --ignorelockingfailure and --sysinit");
+		return EINVALID_CMD_LINE;
+	}
+
+	if (arg_count(cmd, poll_ARG) && arg_count(cmd, sysinit_ARG)) {
+		log_error("Only one of --poll and --sysinit permitted.");
 		return EINVALID_CMD_LINE;
 	}
 


