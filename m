From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 26 Jul 2009 13:06:59 -0000
Subject: LVM2/liblvm .exported_symbols lvm.h lvm_lv.c l ...
Message-ID: <20090726130659.6869.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-26 13:06:59

Modified files:
	liblvm         : .exported_symbols lvm.h lvm_lv.c lvm_pv.c 
	                 lvm_vg.c 

Log message:
	Add most all liblvm 'get' functions needed for anaconda.
	
	Add the most straightforward 'get' functions required for anaconda.
	These are the ones that return simple uint64_t values.
	The other more complex ones involve the lv_attr bits.  These will
	come in a separate patch series since each lv_attr bit will be returned
	in a separate API instred of returning the string and requiring the
	user to parse it.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/.exported_symbols.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm.h.diff?cvsroot=lvm2&r1=1.14&r2=1.15
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_lv.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_pv.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_vg.c.diff?cvsroot=lvm2&r1=1.10&r2=1.11

--- LVM2/liblvm/.exported_symbols	2009/07/26 02:34:36	1.9
+++ LVM2/liblvm/.exported_symbols	2009/07/26 13:06:59	1.10
@@ -1,12 +1,20 @@
 lvm_create
 lvm_destroy
 lvm_reload_config
+lvm_pv_get_name
 lvm_pv_get_uuid
+lvm_pv_get_mda_count
+lvm_vg_get_name
 lvm_vg_get_uuid
+lvm_vg_get_size
+lvm_vg_get_free
+lvm_vg_get_extent_size
+lvm_vg_get_extent_count
+lvm_vg_get_free_count
+lvm_vg_get_pv_count
 lvm_lv_get_uuid
-lvm_pv_get_name
-lvm_vg_get_name
 lvm_lv_get_name
+lvm_lv_get_size
 lvm_vg_create
 lvm_vg_extend
 lvm_vg_set_extent_size
--- LVM2/liblvm/lvm.h	2009/07/26 02:34:36	1.14
+++ LVM2/liblvm/lvm.h	2009/07/26 13:06:59	1.15
@@ -243,6 +243,21 @@
 char *lvm_lv_get_name(const lv_t *lv);
 
 /**
+ * Get various pv, vg, or lv properties.
+ * For full description of each property, consult the man pages for pvs,
+ * vgs, and lvs.
+ * FIXME: What value to return for invalid handle or other errors?
+ */
+uint64_t lvm_pv_get_mda_count(const pv_t *pv);
+uint64_t lvm_vg_get_size(const vg_t *vg);
+uint64_t lvm_vg_get_free(const vg_t *vg);
+uint64_t lvm_vg_get_extent_size(const vg_t *vg);
+uint64_t lvm_vg_get_extent_count(const vg_t *vg);
+uint64_t lvm_vg_get_free_count(const vg_t *vg);
+uint64_t lvm_vg_get_pv_count(const vg_t *vg);
+uint64_t lvm_lv_get_size(const lv_t *lv);
+
+/**
  * Close a VG opened with lvm_vg_create
  *
  * This API releases a VG handle and any resources associated with the handle.
--- LVM2/liblvm/lvm_lv.c	2009/07/26 02:34:36	1.2
+++ LVM2/liblvm/lvm_lv.c	2009/07/26 13:06:59	1.3
@@ -20,6 +20,12 @@
 #include "segtype.h"
 #include <string.h>
 
+/* FIXME: have lib/report/report.c _disp function call lv_size()? */
+uint64_t lvm_lv_get_size(const lv_t *lv)
+{
+	return lv_size(lv);
+}
+
 char *lvm_lv_get_uuid(const lv_t *lv)
 {
 	char uuid[64] __attribute((aligned(8)));
--- LVM2/liblvm/lvm_pv.c	2009/07/23 23:40:05	1.1
+++ LVM2/liblvm/lvm_pv.c	2009/07/26 13:06:59	1.2
@@ -38,3 +38,7 @@
 	return name;
 }
 
+uint64_t lvm_pv_get_mda_count(const pv_t *pv)
+{
+	return (uint64_t) pv_mda_count(pv);
+}
--- LVM2/liblvm/lvm_vg.c	2009/07/26 01:54:40	1.10
+++ LVM2/liblvm/lvm_vg.c	2009/07/26 13:06:59	1.11
@@ -190,6 +190,37 @@
 	return list;
 }
 
+/* FIXME: invalid handle? return INTMAX? */
+uint64_t lvm_vg_get_size(const vg_t *vg)
+{
+	return vg_size(vg);
+}
+
+uint64_t lvm_vg_get_free(const vg_t *vg)
+{
+	return vg_free(vg);
+}
+
+uint64_t lvm_vg_get_extent_size(const vg_t *vg)
+{
+	return vg_extent_size(vg);
+}
+
+uint64_t lvm_vg_get_extent_count(const vg_t *vg)
+{
+	return vg_extent_count(vg);
+}
+
+uint64_t lvm_vg_get_free_count(const vg_t *vg)
+{
+	return vg_free_count(vg);
+}
+
+uint64_t lvm_vg_get_pv_count(const vg_t *vg)
+{
+	return vg_pv_count(vg);
+}
+
 char *lvm_vg_get_uuid(const vg_t *vg)
 {
 	char uuid[64] __attribute((aligned(8)));


