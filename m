From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 14 Feb 2010 03:21:08 -0000
Subject: LVM2 lib/metadata/metadata-exported.h lib/meta ...
Message-ID: <20100214032108.8391.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-02-14 03:21:07

Modified files:
	lib/metadata   : metadata-exported.h metadata.h 
	liblvm         : lvm_lv.c lvm_vg.c 

Log message:
	Fix off by 512 sizes for lvm2app.
	
	Internally we store sizes in sectors, but lvm2app exports sizes
	in bytes.  We could get fancier and allow units configuration but
	this fix should do for now.
	
	Fixes rhbz561422.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.129&r2=1.130
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.199&r2=1.200
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_lv.c.diff?cvsroot=lvm2&r1=1.16&r2=1.17
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_vg.c.diff?cvsroot=lvm2&r1=1.34&r2=1.35

--- LVM2/lib/metadata/metadata-exported.h	2010/02/03 14:08:40	1.129
+++ LVM2/lib/metadata/metadata-exported.h	2010/02/14 03:21:06	1.130
@@ -25,6 +25,7 @@
 
 #define MAX_STRIPES 128U
 #define SECTOR_SHIFT 9L
+#define SECTOR_SIZE ( 1L << SECTOR_SHIFT )
 #define STRIPE_SIZE_MIN ( (unsigned) lvm_getpagesize() >> SECTOR_SHIFT)	/* PAGESIZE in sectors */
 #define STRIPE_SIZE_MAX ( 512L * 1024L >> SECTOR_SHIFT)	/* 512 KB in sectors */
 #define STRIPE_SIZE_LIMIT ((UINT_MAX >> 2) + 1)
--- LVM2/lib/metadata/metadata.h	2009/09/28 17:46:16	1.199
+++ LVM2/lib/metadata/metadata.h	2010/02/14 03:21:06	1.200
@@ -28,7 +28,7 @@
 
 //#define MAX_STRIPES 128U
 //#define SECTOR_SHIFT 9L
-#define SECTOR_SIZE ( 1L << SECTOR_SHIFT )
+//#define SECTOR_SIZE ( 1L << SECTOR_SHIFT )
 //#define STRIPE_SIZE_MIN ( (unsigned) lvm_getpagesize() >> SECTOR_SHIFT)	/* PAGESIZE in sectors */
 //#define STRIPE_SIZE_MAX ( 512L * 1024L >> SECTOR_SHIFT)	/* 512 KB in sectors */
 //#define STRIPE_SIZE_LIMIT ((UINT_MAX >> 2) + 1)
--- LVM2/liblvm/lvm_lv.c	2009/08/13 12:17:32	1.16
+++ LVM2/liblvm/lvm_lv.c	2010/02/14 03:21:06	1.17
@@ -26,7 +26,7 @@
 /* FIXME: have lib/report/report.c _disp function call lv_size()? */
 uint64_t lvm_lv_get_size(const lv_t lv)
 {
-	return lv_size(lv);
+	return SECTOR_SIZE*lv_size(lv);
 }
 
 char *lvm_lv_get_uuid(const lv_t lv)
@@ -112,7 +112,7 @@
 	if (!vg_check_write_mode(vg))
 		return NULL;
 	memset(&lp, 0, sizeof(lp));
-	extents = extents_from_size(vg->cmd, size, vg->extent_size);
+	extents = extents_from_size(vg->cmd, size/SECTOR_SIZE, vg->extent_size);
 	_lv_set_default_params(&lp, vg, name, extents);
 	_lv_set_default_linear_params(vg->cmd, &lp);
 	if (!lv_create_single(vg, &lp))
--- LVM2/liblvm/lvm_vg.c	2010/02/03 14:08:40	1.34
+++ LVM2/liblvm/lvm_vg.c	2010/02/14 03:21:06	1.35
@@ -86,7 +86,7 @@
 	if (!vg_check_write_mode(vg))
 		return -1;
 
-	if (!vg_set_extent_size(vg, new_size))
+	if (!vg_set_extent_size(vg, new_size/SECTOR_SIZE))
 		return -1;
 	return 0;
 }
@@ -256,17 +256,17 @@
 /* FIXME: invalid handle? return INTMAX? */
 uint64_t lvm_vg_get_size(const vg_t vg)
 {
-	return vg_size(vg);
+	return SECTOR_SIZE*vg_size(vg);
 }
 
 uint64_t lvm_vg_get_free_size(const vg_t vg)
 {
-	return vg_free(vg);
+	return SECTOR_SIZE*vg_free(vg);
 }
 
 uint64_t lvm_vg_get_extent_size(const vg_t vg)
 {
-	return vg_extent_size(vg);
+	return SECTOR_SIZE*vg_extent_size(vg);
 }
 
 uint64_t lvm_vg_get_extent_count(const vg_t vg)


