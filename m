From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 26 Jul 2009 16:06:47 -0000
Subject: LVM2 liblvm/.exported_symbols liblvm/lvm.h lib ...
Message-ID: <20090726160647.12511.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-26 16:06:46

Modified files:
	liblvm         : .exported_symbols lvm.h lvm_vg.c 
	test/api       : test.c 

Log message:
	Rename lvm_vg_get_free to lvm_vg_get_free_size.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/.exported_symbols.diff?cvsroot=lvm2&r1=1.13&r2=1.14
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm.h.diff?cvsroot=lvm2&r1=1.18&r2=1.19
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_vg.c.diff?cvsroot=lvm2&r1=1.13&r2=1.14
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/test.c.diff?cvsroot=lvm2&r1=1.11&r2=1.12

--- LVM2/liblvm/.exported_symbols	2009/07/26 16:06:21	1.13
+++ LVM2/liblvm/.exported_symbols	2009/07/26 16:06:46	1.14
@@ -7,7 +7,7 @@
 lvm_vg_get_name
 lvm_vg_get_uuid
 lvm_vg_get_size
-lvm_vg_get_free
+lvm_vg_get_free_size
 lvm_vg_get_extent_size
 lvm_vg_get_extent_count
 lvm_vg_get_free_extent_count
--- LVM2/liblvm/lvm.h	2009/07/26 16:06:21	1.18
+++ LVM2/liblvm/lvm.h	2009/07/26 16:06:46	1.19
@@ -261,7 +261,7 @@
  */
 uint64_t lvm_pv_get_mda_count(const pv_t *pv);
 uint64_t lvm_vg_get_size(const vg_t *vg);
-uint64_t lvm_vg_get_free(const vg_t *vg);
+uint64_t lvm_vg_get_free_size(const vg_t *vg);
 uint64_t lvm_vg_get_extent_size(const vg_t *vg);
 uint64_t lvm_vg_get_extent_count(const vg_t *vg);
 uint64_t lvm_vg_get_free_extent_count(const vg_t *vg);
--- LVM2/liblvm/lvm_vg.c	2009/07/26 16:06:21	1.13
+++ LVM2/liblvm/lvm_vg.c	2009/07/26 16:06:46	1.14
@@ -196,7 +196,7 @@
 	return vg_size(vg);
 }
 
-uint64_t lvm_vg_get_free(const vg_t *vg)
+uint64_t lvm_vg_get_free_size(const vg_t *vg)
 {
 	return vg_free(vg);
 }
--- LVM2/test/api/test.c	2009/07/26 16:06:21	1.11
+++ LVM2/test/api/test.c	2009/07/26 16:06:46	1.12
@@ -232,7 +232,7 @@
 {
 	printf("%s (%s): size=%"PRIu64", free=%"PRIu64", #pv=%"PRIu64"\n",
 		lvm_vg_get_name(vg), lvm_vg_get_uuid(vg),
-		lvm_vg_get_size(vg), lvm_vg_get_free(vg),
+		lvm_vg_get_size(vg), lvm_vg_get_free_size(vg),
 		lvm_vg_get_pv_count(vg));
 }
 


