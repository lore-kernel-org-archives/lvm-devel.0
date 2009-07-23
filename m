From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 23 Jul 2009 23:55:02 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20090723235502.26534.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-23 23:55:02

Modified files:
	.              : WHATS_NEW 

Log message:
	Update WHATS_NEW for liblvm commits

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1198&r2=1.1199

--- LVM2/WHATS_NEW	2009/07/22 21:09:13	1.1198
+++ LVM2/WHATS_NEW	2009/07/23 23:55:01	1.1199
@@ -1,5 +1,9 @@
 Version 2.02.50 - 
 ================================
+  Add lvm_{pv|vg|lv}_get_{name|uuid} liblvm functions.
+  Add lvm_vg_list_pvs and lvm_vg_list_lvs liblvm functions.
+  Remove unused handles lvseg, pvseg inside liblvm/lvm.h.
+  Add lvm_vg_open liblvm function.
   Add liblvm2app Makefile installation targets.
   Add liblvm pkgconfig file.
   Use newly-independent LVM_LIBAPI in liblvm soname.  E.g. liblvm2app.so.2.1.


