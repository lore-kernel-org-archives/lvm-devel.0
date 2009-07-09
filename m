From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 9 Jul 2009 10:19:07 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20090709101907.15836.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-09 10:19:07

Modified files:
	.              : WHATS_NEW 

Log message:
	Update WHATS_NEW for recent vgcreate changes

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1169&r2=1.1170

--- LVM2/WHATS_NEW	2009/07/08 22:22:12	1.1169
+++ LVM2/WHATS_NEW	2009/07/09 10:19:07	1.1170
@@ -1,5 +1,10 @@
 Version 2.02.49 - 
 ================================
+  Update vgsplit and vgcreate to call the new vg_create, then call 'set' fns.
+  Change vg_create to take minimal parameters, obtain a lock, and return vg_t.
+  Refactor vgchange extent_size, max_lv, max_pv, and alloc_policy for liblvm.
+  Update t-vgcreate-usage.sh to test for default vg properties.
+  Fix memory leak in vgsplit when re-reading the vg.
   Make exit/cleanup code more robust when some lvm init function fails.
   Use implicit set of LCK_NONBLOCK instead of explicit vg_read() flag.
   Remove unnecessary locking and existence code from new vg_read() interface.


