From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 14 Mar 2012 12:12:29 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20120314121229.13399.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-03-14 12:12:28

Modified files:
	.              : WHATS_NEW 

Log message:
	WHATS_NEW

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2353&r2=1.2354

--- LVM2/WHATS_NEW	2012/03/13 20:21:26	1.2353
+++ LVM2/WHATS_NEW	2012/03/14 12:12:21	1.2354
@@ -1,5 +1,6 @@
 Version 2.02.96 - 
 ================================
+  Detect lvm binary path in lvmetad udev rules.
   Fix error message when pvmove LV activation fails with name already in use.
   Better structure layout for device_info in dev_subsystem_name().
   Change message severity for creation of VG over uninitialised devices.


