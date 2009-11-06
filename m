From: agk@sourceware.org <agk@sourceware.org>
Date: 6 Nov 2009 01:41:00 -0000
Subject: LVM2/man dmsetup.8.in
Message-ID: <20091106014100.26891.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-11-06 01:40:59

Modified files:
	man            : dmsetup.8.in 

Log message:
	.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/dmsetup.8.in.diff?cvsroot=lvm2&r1=1.28&r2=1.29

--- LVM2/man/dmsetup.8.in	2009/11/06 00:43:09	1.28
+++ LVM2/man/dmsetup.8.in	2009/11/06 01:40:59	1.29
@@ -282,7 +282,7 @@
 Splits given device name into subsystem constituents.
 Default subsystem is LVM.
 .IP \fBstatus
-.I [--target target_type] [--inactive]
+.I [--target target_type]
 .I [device_name]
 .br
 Outputs status information for each of the device's targets.
@@ -301,7 +301,7 @@
 the --noflush option.  This lets outstanding I/O that has not yet reached the
 device to remain unflushed.
 .IP \fBtable
-.I [--target target_type] [--inactive]
+.I [--target target_type]
 .I [device_name]
 .br
 Outputs the current table for the device in a format that can be fed


