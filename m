From: agk@sourceware.org <agk@sourceware.org>
Date: 24 Oct 2006 17:18:26 -0000
Subject: LVM2 ./WHATS_NEW man/lvchange.8 tools/args.h t ...
Message-ID: <20061024171826.19284.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2006-10-24 17:18:25

Modified files:
	.              : WHATS_NEW 
	man            : lvchange.8 
	tools          : args.h commands.h lvchange.c 

Log message:
	try forcesync -> resync

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.479&r2=1.480
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvchange.8.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/args.h.diff?cvsroot=lvm2&r1=1.48&r2=1.49
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.89&r2=1.90
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvchange.c.diff?cvsroot=lvm2&r1=1.71&r2=1.72

--- LVM2/WHATS_NEW	2006/10/23 23:03:55	1.479
+++ LVM2/WHATS_NEW	2006/10/24 17:18:24	1.480
@@ -1,6 +1,6 @@
 Version 2.02.13 -
 ===================================
-  Add lvchange --forcesync.
+  Add lvchange --resync.
   Perform high-level free space check before each allocation attempt.
   Don't allow a node to remove an LV that's exclusively active on anther node.
   Cope if same PV is included more than once in cmdline PE range list.
--- LVM2/man/lvchange.8	2006/10/24 17:09:40	1.10
+++ LVM2/man/lvchange.8	2006/10/24 17:18:24	1.11
@@ -7,7 +7,7 @@
 [\-A/\-\-autobackup y/n] [\-a/\-\-available y/n/ey/en/ly/ln]
 [\-\-alloc AllocationPolicy]
 [\-C/\-\-contiguous y/n] [\-d/\-\-debug] [\-\-deltag Tag]
-[\-\-forcesync]
+[\-\-resync]
 [\-h/\-?/\-\-help]
 [\-\-ignorelockingfailure]
 [\-\-monitor {y|n}]
@@ -41,7 +41,7 @@
 logical volume's allocation policy to contiguous, if all of the
 allocated physical extents are already contiguous.
 .TP
-.I \-\-forcesync
+.I \-\-resync
 Forces the complete resynchronization of a mirror.  In normal
 circumstances you should not need this option because synchronization
 happens automatically.  Data is read from the primary mirror device
--- LVM2/tools/args.h	2006/10/23 23:03:55	1.48
+++ LVM2/tools/args.h	2006/10/24 17:18:24	1.49
@@ -46,7 +46,7 @@
 arg(separator_ARG, '\0', "separator", string_arg)
 arg(mirrorsonly_ARG, '\0', "mirrorsonly", NULL)
 arg(nosync_ARG, '\0', "nosync", NULL)
-arg(forcesync_ARG, '\0', "forcesync", NULL)
+arg(resync_ARG, '\0', "resync", NULL)
 arg(corelog_ARG, '\0', "corelog", NULL)
 arg(monitor_ARG, '\0', "monitor", yes_no_arg)
 arg(config_ARG, '\0', "config", string_arg)
--- LVM2/tools/commands.h	2006/10/23 23:03:55	1.89
+++ LVM2/tools/commands.h	2006/10/24 17:18:25	1.90
@@ -61,7 +61,7 @@
    "\t[-d|--debug]\n"
    "\t[--deltag Tag]\n"
    "\t[-f|--force]\n"
-   "\t[--forcesync]\n"
+   "\t[--resync]\n"
    "\t[-h|--help]\n"
    "\t[--ignorelockingfailure]\n"
    "\t[--monitor {y|n}]\n"
@@ -77,7 +77,7 @@
    "\tLogicalVolume[Path] [LogicalVolume[Path]...]\n",
 
    alloc_ARG, autobackup_ARG, available_ARG, contiguous_ARG, force_ARG,
-   forcesync_ARG, ignorelockingfailure_ARG, major_ARG, minor_ARG, monitor_ARG,
+   resync_ARG, ignorelockingfailure_ARG, major_ARG, minor_ARG, monitor_ARG,
    partial_ARG, permission_ARG, persistent_ARG, readahead_ARG,
    refresh_ARG, addtag_ARG, deltag_ARG, test_ARG, yes_ARG)
 
--- LVM2/tools/lvchange.c	2006/10/24 15:30:33	1.71
+++ LVM2/tools/lvchange.c	2006/10/24 17:18:25	1.72
@@ -175,7 +175,7 @@
 	return 1;
 }
 
-static int lvchange_forcesync(struct cmd_context *cmd,
+static int lvchange_resync(struct cmd_context *cmd,
 			      struct logical_volume *lv)
 {
 	int active = 0;
@@ -648,8 +648,8 @@
 	if (doit)
 		log_print("Logical volume \"%s\" changed", lv->name);
 
-	if (arg_count(cmd, forcesync_ARG))
-		if (!lvchange_forcesync(cmd, lv))
+	if (arg_count(cmd, resync_ARG))
+		if (!lvchange_resync(cmd, lv))
 			return ECMD_FAILED;
 
 	/* availability change */
@@ -680,9 +680,9 @@
 	    && !arg_count(cmd, persistent_ARG) && !arg_count(cmd, addtag_ARG)
 	    && !arg_count(cmd, deltag_ARG) && !arg_count(cmd, refresh_ARG)
 	    && !arg_count(cmd, alloc_ARG) && !arg_count(cmd, monitor_ARG)
-	    && !arg_count(cmd, forcesync_ARG)) {
+	    && !arg_count(cmd, resync_ARG)) {
 		log_error("Need 1 or more of -a, -C, -j, -m, -M, -p, -r, "
-			  "--forcesync, --refresh, --alloc, --addtag, --deltag "
+			  "--resync, --refresh, --alloc, --addtag, --deltag "
 			  "or --monitor");
 		return EINVALID_CMD_LINE;
 	}


