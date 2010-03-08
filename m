From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 8 Mar 2010 16:04:33 -0000
Subject: LVM2 ./WHATS_NEW_DM man/dmsetup.8.in
Message-ID: <20100308160433.15217.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-03-08 16:04:32

Modified files:
	.              : WHATS_NEW_DM 
	man            : dmsetup.8.in 

Log message:
	Add --showkeys parameter description into dmsetup man page.
	
	Also fix minor warning (-c is parameter) in man page formatting.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.346&r2=1.347
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/dmsetup.8.in.diff?cvsroot=lvm2&r1=1.31&r2=1.32

--- LVM2/WHATS_NEW_DM	2010/02/16 00:27:01	1.346
+++ LVM2/WHATS_NEW_DM	2010/03/08 16:04:32	1.347
@@ -1,5 +1,6 @@
 Version 1.02.45 -
 ====================================
+  Add --showkeys parameter description into dmsetup man page.
 
 Version 1.02.44 - 15th February 2010
 ====================================
--- LVM2/man/dmsetup.8.in	2010/02/15 16:32:24	1.31
+++ LVM2/man/dmsetup.8.in	2010/03/08 16:04:32	1.32
@@ -54,7 +54,7 @@
 .I [device_name]
 .br
 .B dmsetup table
-.I [--target target_type]
+.I [--target target_type] [--showkeys]
 .I [device_name]
 .br
 .B dmsetup wait
@@ -210,7 +210,8 @@
     Number of targets in the live table
 .br
     UUID
-.IP \fBinfo -c|-C|--columns
+.IP \fBinfo
+.I -c|-C|--columns
 .I [--noheadings] [--separator separator] [-o fields] [-O|--sort sort_fields]
 .I [device_name]
 .br
@@ -312,13 +313,15 @@
 the --noflush option.  This lets outstanding I/O that has not yet reached the
 device to remain unflushed.
 .IP \fBtable
-.I [--target target_type]
+.I [--target target_type] [--showkeys]
 .I [device_name]
 .br
 Outputs the current table for the device in a format that can be fed
 back in using the create or load commands.
 With --target, only information relating to the specified target type
 is displayed.
+By default encryption keys are suppressed in table output (crypt target)
+unless --showkeys parameter is supplied.
 .IP \fBtargets
 .br
 Displays the names and versions of the currently-loaded targets.


