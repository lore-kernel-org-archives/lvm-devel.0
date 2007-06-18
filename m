From: agk@sourceware.org <agk@sourceware.org>
Date: 18 Jun 2007 14:14:34 -0000
Subject: LVM2 ./WHATS_NEW man/lvchange.8 man/vgchange.8 ...
Message-ID: <20070618141434.9996.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-06-18 14:14:34

Modified files:
	.              : WHATS_NEW 
	man            : lvchange.8 vgchange.8 
	tools          : args.h commands.h lvchange.c vgchange.c 

Log message:
	Add --ignoremonitoring to disable all dmeventd interaction.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.636&r2=1.637
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvchange.8.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgchange.8.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/args.h.diff?cvsroot=lvm2&r1=1.49&r2=1.50
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.96&r2=1.97
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvchange.c.diff?cvsroot=lvm2&r1=1.79&r2=1.80
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.57&r2=1.58

--- LVM2/WHATS_NEW	2007/06/15 20:48:55	1.636
+++ LVM2/WHATS_NEW	2007/06/18 14:14:33	1.637
@@ -1,5 +1,6 @@
 Version 2.02.27 - 
 ================================
+  Add --ignoremonitoring to disable all dmeventd interaction.
 
 Version 2.02.26 - 15th June 2007
 ================================
--- LVM2/man/lvchange.8	2007/02/13 16:04:01	1.12
+++ LVM2/man/lvchange.8	2007/06/18 14:14:33	1.13
@@ -10,6 +10,7 @@
 [\-\-resync]
 [\-h/\-?/\-\-help]
 [\-\-ignorelockingfailure]
+[\-\-ignoremonitoring]
 [\-\-monitor {y|n}]
 [\-M/\-\-persistent y/n] [\-\-minor minor]
 [\-P/\-\-partial]
@@ -60,6 +61,11 @@
 \fBmirror_image_fault_policy\fP and \fBmirror_log_fault_policy\fP
 set in \fBlvm.conf\fP.
 .TP
+.I \-\-ignoremonitoring
+Make no attempt to interact with dmeventd unless \-\-monitor
+is specified.
+Do not use this if dmeventd is already monitoring a device.
+.TP
 .I \-M, \-\-persistent y/n
 Set to y to make the minor number specified persistent.
 .TP
--- LVM2/man/vgchange.8	2007/01/23 13:08:34	1.12
+++ LVM2/man/vgchange.8	2007/06/18 14:14:33	1.13
@@ -16,6 +16,7 @@
 .IR Tag ]
 .RB [ \-h | \-\-help]
 .RB [ \-\-ignorelockingfailure]
+.RB [ \-\-ignoremonitoring]
 .RB [ \-l | \-\-logicalvolume
 .IR MaxLogicalVolumes ]
 .RB [ -p | \-\-maxphysicalvolumes
@@ -80,6 +81,12 @@
 set in 
 .BR lvm.conf (5).
 .TP
+.BR \-\-ignoremonitoring
+Make no attempt to interact with dmeventd unless 
+.BR \-\-monitor
+is specified.
+Do not use this if dmeventd is already monitoring a device.
+.TP
 .BR \-l ", " \-\-logicalvolume " " \fIMaxLogicalVolumes\fR
 Changes the maximum logical volume number of an existing inactive
 volume group.
--- LVM2/tools/args.h	2006/10/24 17:18:24	1.49
+++ LVM2/tools/args.h	2007/06/18 14:14:33	1.50
@@ -51,6 +51,7 @@
 arg(monitor_ARG, '\0', "monitor", yes_no_arg)
 arg(config_ARG, '\0', "config", string_arg)
 arg(trustcache_ARG, '\0', "trustcache", NULL)
+arg(ignoremonitoring_ARG, '\0', "ignoremonitoring", NULL)
 
 /* Allow some variations */
 arg(resizable_ARG, '\0', "resizable", yes_no_arg)
--- LVM2/tools/commands.h	2007/04/25 20:03:16	1.96
+++ LVM2/tools/commands.h	2007/06/18 14:14:33	1.97
@@ -66,6 +66,7 @@
    "\t[-f|--force]\n"
    "\t[-h|--help]\n"
    "\t[--ignorelockingfailure]\n"
+   "\t[--ignoremonitoring]\n"
    "\t[--monitor {y|n}]\n"
    "\t[-M|--persistent y|n] [--major major] [--minor minor]\n"
    "\t[-P|--partial] " "\n"
@@ -80,9 +81,9 @@
    "\tLogicalVolume[Path] [LogicalVolume[Path]...]\n",
 
    alloc_ARG, autobackup_ARG, available_ARG, contiguous_ARG, force_ARG,
-   ignorelockingfailure_ARG, major_ARG, minor_ARG, monitor_ARG,
-   partial_ARG, permission_ARG, persistent_ARG, readahead_ARG, resync_ARG,
-   refresh_ARG, addtag_ARG, deltag_ARG, test_ARG, yes_ARG)
+   ignorelockingfailure_ARG, ignoremonitoring_ARG, major_ARG, minor_ARG,
+   monitor_ARG, partial_ARG, permission_ARG, persistent_ARG, readahead_ARG,
+   resync_ARG, refresh_ARG, addtag_ARG, deltag_ARG, test_ARG, yes_ARG)
 
 xx(lvconvert,
    "Change logical volume layout",
@@ -617,6 +618,7 @@
    "\t[-d|--debug] " "\n"
    "\t[-h|--help] " "\n"
    "\t[--ignorelockingfailure]\n"
+   "\t[--ignoremonitoring]\n"
    "\t[--monitor {y|n}]\n"
    "\t[-t|--test]" "\n"
    "\t[-u|--uuid] " "\n"
@@ -633,9 +635,9 @@
    "\t[VolumeGroupName...]\n",
 
    addtag_ARG, alloc_ARG, allocation_ARG, autobackup_ARG, available_ARG,
-   clustered_ARG, deltag_ARG, ignorelockingfailure_ARG, logicalvolume_ARG,
-   maxphysicalvolumes_ARG, monitor_ARG, partial_ARG, physicalextentsize_ARG,
-   resizeable_ARG, resizable_ARG, test_ARG, uuid_ARG)
+   clustered_ARG, deltag_ARG, ignorelockingfailure_ARG, ignoremonitoring_ARG,
+   logicalvolume_ARG, maxphysicalvolumes_ARG, monitor_ARG, partial_ARG,
+   physicalextentsize_ARG, resizeable_ARG, resizable_ARG, test_ARG, uuid_ARG)
 
 xx(vgck,
    "Check the consistency of volume group(s)",
--- LVM2/tools/lvchange.c	2007/06/15 10:11:14	1.79
+++ LVM2/tools/lvchange.c	2007/06/18 14:14:33	1.80
@@ -600,7 +600,7 @@
 	}
 
 	init_dmeventd_monitor(arg_int_value(cmd, monitor_ARG,
-					    cmd->is_static ?
+					    (cmd->is_static || arg_count(cmd, ignoremonitoring_ARG)) ?
 					    DMEVENTD_MONITOR_IGNORE : DEFAULT_DMEVENTD_MONITOR));
 
 	/* access permission change */
--- LVM2/tools/vgchange.c	2007/01/24 23:43:27	1.57
+++ LVM2/tools/vgchange.c	2007/06/18 14:14:33	1.58
@@ -536,7 +536,7 @@
 	}
 
 	init_dmeventd_monitor(arg_int_value(cmd, monitor_ARG,
-					    cmd->is_static ?
+					    (cmd->is_static || arg_count(cmd, ignoremonitoring_ARG)) ?
 					    DMEVENTD_MONITOR_IGNORE : DEFAULT_DMEVENTD_MONITOR));
 
 	if (arg_count(cmd, available_ARG))


