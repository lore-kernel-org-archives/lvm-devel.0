From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 26 Apr 2011 09:09:25 -0000
Subject: LVM2/doc example.conf.in
Message-ID: <20110426090925.29816.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-04-26 09:09:24

Modified files:
	doc            : example.conf.in 

Log message:
	Uncomment obtain_device_list_from_udev setting in lvm.conf.
	
	Just for consistency with other settings we already have in lvm.conf.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.in.diff?cvsroot=lvm2&r1=1.23&r2=1.24

--- LVM2/doc/example.conf.in	2011/04/22 12:05:32	1.23
+++ LVM2/doc/example.conf.in	2011/04/26 09:09:24	1.24
@@ -27,7 +27,7 @@
     # fully. LVM2 needs to be compiled with udev support for this setting to
     # take effect. N.B. Any device node or symlink not managed by udev in
     # udev directory will be ignored with this setting on.
-    # obtain_device_list_from_udev = 1
+    obtain_device_list_from_udev = 1
 
     # If several entries in the scanned directories correspond to the
     # same block device and the tools need to display a name for device,


