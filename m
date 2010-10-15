From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 15 Oct 2010 16:24:02 -0000
Subject: LVM2 doc/example.conf.in man/lvm.conf.5.in
Message-ID: <20101015162402.16002.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-10-15 16:24:01

Modified files:
	doc            : example.conf.in 
	man            : lvm.conf.5.in 

Log message:
	Fixes for the devices/disable_after_error_count documentation.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.in.diff?cvsroot=lvm2&r1=1.13&r2=1.14
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvm.conf.5.in.diff?cvsroot=lvm2&r1=1.14&r2=1.15

--- LVM2/doc/example.conf.in	2010/10/13 15:45:18	1.13
+++ LVM2/doc/example.conf.in	2010/10/15 16:24:00	1.14
@@ -139,7 +139,7 @@
     # During each LVM operation errors received from each device are counted.
     # If the counter of a particular device exceeds the limit set here, no
     # further I/O is sent to that device for the remainder of the respective
-    # operation.
+    # operation. Setting the parameter to 0 disables the counters altogether.
     disable_after_error_count = 0
 
     # Allow use of pvcreate --uuid without requiring --restorefile.
--- LVM2/man/lvm.conf.5.in	2010/10/13 15:40:39	1.14
+++ LVM2/man/lvm.conf.5.in	2010/10/15 16:24:01	1.15
@@ -166,10 +166,11 @@
 \fBdata_alignment_offset_detection\fP (if enabled) or the pvcreate
 commandline.
 .IP
-\fBdev_max_error_count\fP \(em Maximum number of error counts per device
-before disabling devices. This option prevents a broken device from
-being accessed repeatedly. If set to 0, no access control to devices is
-done.
+\fBdisable_after_error_count\fP \(em During each LVM operation errors received
+from each device are counted.  If the counter of a particular device exceeds
+the limit set here, no further I/O is sent to that device for the remainder of
+the respective operation. Setting the parameter to 0 disables the counters
+altogether.
 .TP
 \fBlog\fP \(em Default log settings
 .IP


