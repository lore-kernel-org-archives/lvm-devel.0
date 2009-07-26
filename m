From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 26 Jul 2009 16:05:50 -0000
Subject: LVM2/liblvm .exported_symbols lvm.h lvm_vg.c
Message-ID: <20090726160550.11586.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-26 16:05:50

Modified files:
	liblvm         : .exported_symbols lvm.h lvm_vg.c 

Log message:
	Rename lvm_vg_get_free_count to lvm_vg_get_free_extent_count.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/.exported_symbols.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm.h.diff?cvsroot=lvm2&r1=1.16&r2=1.17
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_vg.c.diff?cvsroot=lvm2&r1=1.11&r2=1.12

--- LVM2/liblvm/.exported_symbols	2009/07/26 14:36:52	1.11
+++ LVM2/liblvm/.exported_symbols	2009/07/26 16:05:49	1.12
@@ -10,7 +10,7 @@
 lvm_vg_get_free
 lvm_vg_get_extent_size
 lvm_vg_get_extent_count
-lvm_vg_get_free_count
+lvm_vg_get_free_extent_count
 lvm_vg_get_pv_count
 lvm_lv_get_uuid
 lvm_lv_get_name
--- LVM2/liblvm/lvm.h	2009/07/26 14:36:52	1.16
+++ LVM2/liblvm/lvm.h	2009/07/26 16:05:49	1.17
@@ -264,7 +264,7 @@
 uint64_t lvm_vg_get_free(const vg_t *vg);
 uint64_t lvm_vg_get_extent_size(const vg_t *vg);
 uint64_t lvm_vg_get_extent_count(const vg_t *vg);
-uint64_t lvm_vg_get_free_count(const vg_t *vg);
+uint64_t lvm_vg_get_free_extent_count(const vg_t *vg);
 uint64_t lvm_vg_get_pv_count(const vg_t *vg);
 uint64_t lvm_lv_get_size(const lv_t *lv);
 
--- LVM2/liblvm/lvm_vg.c	2009/07/26 13:06:59	1.11
+++ LVM2/liblvm/lvm_vg.c	2009/07/26 16:05:49	1.12
@@ -211,7 +211,7 @@
 	return vg_extent_count(vg);
 }
 
-uint64_t lvm_vg_get_free_count(const vg_t *vg)
+uint64_t lvm_vg_get_free_extent_count(const vg_t *vg)
 {
 	return vg_free_count(vg);
 }


