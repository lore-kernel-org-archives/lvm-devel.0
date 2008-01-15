From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 15 Jan 2008 20:37:50 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20080115203750.20970.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-01-15 20:37:50

Modified files:
	.              : WHATS_NEW 

Log message:
	Update WHATS_NEW for vgsplit changes

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.759&r2=1.760

--- LVM2/WHATS_NEW	2008/01/14 21:11:47	1.759
+++ LVM2/WHATS_NEW	2008/01/15 20:37:49	1.760
@@ -1,5 +1,7 @@
 Version 2.02.30 -
 ===================================
+  Update vgsplit to include vgcreate-style options when new VG is destination.
+  Update vgsplit to accept existing VG as destination.
   lvconvert waits for completion of initial sync by default.
   Refactor vgcreate for parameter validation and add tests.
   Add new convert_lv field to lvs output.


