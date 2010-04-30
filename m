From: agk@sourceware.org <agk@sourceware.org>
Date: 30 Apr 2010 14:49:48 -0000
Subject: LVM2 ./VERSION ./VERSION_DM ./WHATS_NEW ./WHAT ...
Message-ID: <20100430144948.31377.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-04-30 14:49:45

Modified files:
	.              : VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM 
	                 configure 
	daemons/clvmd  : clvmd-command.c 
	man            : clvmd.8.in 
	scripts        : relpath.awk 

Log message:
	pre-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.232&r2=1.233
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION_DM.diff?cvsroot=lvm2&r1=1.43&r2=1.44
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1544&r2=1.1545
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.365&r2=1.366
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.125&r2=1.126
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-command.c.diff?cvsroot=lvm2&r1=1.32&r2=1.33
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/clvmd.8.in.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/relpath.awk.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/VERSION	2010/04/19 15:24:00	1.232
+++ LVM2/VERSION	2010/04/30 14:49:42	1.233
@@ -1 +1 @@
-2.02.64(2)-cvs (2010-04-14)
+2.02.64(2)-cvs (2010-04-30)
--- LVM2/VERSION_DM	2010/04/14 21:47:48	1.43
+++ LVM2/VERSION_DM	2010/04/30 14:49:43	1.44
@@ -1 +1 @@
-1.02.47-cvs (2010-04-14)
+1.02.47-cvs (2010-04-30)
--- LVM2/WHATS_NEW	2010/04/30 12:37:04	1.1544
+++ LVM2/WHATS_NEW	2010/04/30 14:49:43	1.1545
@@ -1,12 +1,13 @@
-Version 2.02.64 -
+Version 2.02.64 - 30th April 2010
 =================================
+  Avoid pointless initialisation when the 'version' command is run directly.
   Fix memory leak for invalid regex pattern input.
   Display invalid regex pattern for filter configuration in case of error.
   Remove no-longer-used arg_ptr_value.
-  Fix -M and --type to use strings not pointers that change on config refresh.
+  Fix -M and --type to use strings, not pointers that change on config refresh.
   Fix lvconvert error message when existing mirrored LV is not found.
-  Disallow the direct removal of a merging snapshot.
   Set appropriate udev flags for reserved LVs.
+  Disallow the direct removal of a merging snapshot.
   Don't preload the origin when removing a snapshot whose merge is pending.
   Disallow the addition of mirror images while a conversion is happening.
   Disallow primary mirror image removal when mirror is not in-sync.
@@ -15,9 +16,10 @@
   Increment lvm2app version from 1 to 2 (memory allocation changes).
   Change lvm2app memory alloc/free for pv/vg/lv properties.
   Change daemon lock filename from lvm2_monitor to lvm2-monitor for consistency.
+  Install symbolic .so links with relative paths between usrlibdir and libdir.
   Add awk script relpath.awk to calculate paths for relative symlinks.
+  Use @AWK@ in makefiles.
   Fix double DESTDIR usage for infodir and mandir.
-  Install symbolic .so links with relative paths between usrlibdir and libdir.
 
 Version 2.02.63 - 14th April 2010
 =================================
--- LVM2/WHATS_NEW_DM	2010/04/29 01:48:19	1.365
+++ LVM2/WHATS_NEW_DM	2010/04/30 14:49:43	1.366
@@ -1,4 +1,4 @@
-Version 1.02.47 -
+Version 1.02.47 - 30th April 2010
 =================================
   Add support for new IMPORT{db} udev rule.
   Add DM_UDEV_PRIMARY_SOURCE_FLAG udev flag to recognize proper DM events.
--- LVM2/configure	2010/04/09 21:42:48	1.125
+++ LVM2/configure	2010/04/30 14:49:43	1.126
@@ -15609,6 +15609,7 @@
 
 
 
+
 ################################################################################
 ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/misc/lvm-version.h lib/snapshot/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_monitoring_init_red_hat scripts/Makefile test/Makefile test/api/Makefile tools/Makefile udev/Makefile"
 
--- LVM2/daemons/clvmd/clvmd-command.c	2010/04/20 14:07:38	1.32
+++ LVM2/daemons/clvmd/clvmd-command.c	2010/04/30 14:49:44	1.33
@@ -371,6 +371,7 @@
 	/*
 	 * Build the command-line
 	 */
+	/* FIXME missing strup error checks */
 	argv[0] = strdup("clvmd");
 
 	/* Propogate debug options */
--- LVM2/man/clvmd.8.in	2010/04/20 14:07:38	1.3
+++ LVM2/man/clvmd.8.in	2010/04/30 14:49:44	1.4
@@ -76,10 +76,11 @@
 devices on a cluster system are changed.
 .TP
 .I \-S
-Tells the running clvmd to exit and restart. This is a preferred option
-to killing and restarting clvmd as it will preserve exclusive LV locks.
-If a full stop & restart is done instead, exclusive LV locks will be
-re-acquired as shared.
+Tells the running clvmd to exit and reexecute itself, for example at the
+end of a package upgrade.  The new instance is instructed to reacquire
+any locks in the same state as they were previously held.  (Alternative
+methods of restarting the daemon have the side effect of changing
+exclusive LV locks into shared locks.)
 .TP
 .I \-I
 Selects the cluster manager to use for locking and internal communications,
--- LVM2/scripts/relpath.awk	2010/04/30 13:58:08	1.2
+++ LVM2/scripts/relpath.awk	2010/04/30 14:49:45	1.3
@@ -1,4 +1,4 @@
-#!/bin/awk -f
+#!/usr/bin/awk -f
 #
 # Copyright (C) 2010 Red Hat, Inc. All rights reserved.
 #


