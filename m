From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 26 Jul 2009 11:21:33 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20090726112133.6864.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-26 11:21:32

Modified files:
	.              : WHATS_NEW 

Log message:
	Update WHATS_NEW for recent checkins

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1202&r2=1.1203

--- LVM2/WHATS_NEW	2009/07/24 23:28:55	1.1202
+++ LVM2/WHATS_NEW	2009/07/26 11:21:32	1.1203
@@ -1,5 +1,9 @@
 Version 2.02.50 - 
 ================================
+  Update test/api/test.c to call new liblvm functions.
+  Add liblvm function lvm_vg_create_lv_linear.
+  Update lvm_vg_extend to do an implicit pvcreate on the device.
+  Refactor pvcreate and lvcreate for liblvm.
   Add global/wait_for_locks to lvm.conf so blocking for locks can be disabled.
   All LV locks are non-blocking so remove LCK_NONBLOCK from separate macros.
   Fix race condition with vgcreate and vgextend on same device (2.02.49).


