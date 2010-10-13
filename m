From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 13 Oct 2010 15:45:19 -0000
Subject: LVM2/doc example.conf.in
Message-ID: <20101013154519.19643.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-10-13 15:45:19

Modified files:
	doc            : example.conf.in 

Log message:
	Tweak the lvm.conf comment about devices/disable_after_error_count.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.in.diff?cvsroot=lvm2&r1=1.12&r2=1.13

--- LVM2/doc/example.conf.in	2010/10/13 15:40:38	1.12
+++ LVM2/doc/example.conf.in	2010/10/13 15:45:18	1.13
@@ -136,9 +136,10 @@
     # in recovery situations.
     ignore_suspended_devices = 0
 
-    # During each LVM operation any errors received from a device are counted.
-    # If this counter exceeds the number here, no further I/O is sent to the
-    # device.
+    # During each LVM operation errors received from each device are counted.
+    # If the counter of a particular device exceeds the limit set here, no
+    # further I/O is sent to that device for the remainder of the respective
+    # operation.
     disable_after_error_count = 0
 
     # Allow use of pvcreate --uuid without requiring --restorefile.


