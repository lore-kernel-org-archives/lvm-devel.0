From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 26 Jul 2009 22:19:14 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20090726221914.24527.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-26 22:19:14

Modified files:
	.              : WHATS_NEW 

Log message:
	Update WHATS_NEW for latest liblvm changes

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1203&r2=1.1204

--- LVM2/WHATS_NEW	2009/07/26 11:21:32	1.1203
+++ LVM2/WHATS_NEW	2009/07/26 22:19:14	1.1204
@@ -1,5 +1,13 @@
 Version 2.02.50 - 
 ================================
+  Update liblvm unit tests in test/api for latest liblvm changes.
+  Add lvm_lv_is_active and lvm_lv_is_suspended liblvm APIs.
+  Add lvm_lv_activate and lvm_lv_deactivate liblvm APIs.
+  Add lvm_scan liblvm function.
+  Update lvm.h to clarify API behavior and return codes.
+  Add lvm_vg_remove_lv liblvm function.
+  Add numeric liblvm 'get' functions required by anaconda.
+  Refactor vg_size, vg_free, and pv_mda_count field calculations for liblvm.
   Update test/api/test.c to call new liblvm functions.
   Add liblvm function lvm_vg_create_lv_linear.
   Update lvm_vg_extend to do an implicit pvcreate on the device.


