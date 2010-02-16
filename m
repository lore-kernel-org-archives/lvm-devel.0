From: agk@sourceware.org <agk@sourceware.org>
Date: 16 Feb 2010 00:27:03 -0000
Subject: LVM2 ./VERSION ./VERSION_DM ./WHATS_NEW ./WHAT ...
Message-ID: <20100216002703.3352.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-02-16 00:27:02

Modified files:
	.              : VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM 
	liblvm         : lvm_lv.c lvm_pv.c lvm_vg.c 

Log message:
	post-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.226&r2=1.227
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION_DM.diff?cvsroot=lvm2&r1=1.38&r2=1.39
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1433&r2=1.1434
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.345&r2=1.346
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_lv.c.diff?cvsroot=lvm2&r1=1.17&r2=1.18
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_pv.c.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_vg.c.diff?cvsroot=lvm2&r1=1.35&r2=1.36

--- LVM2/VERSION	2010/02/15 23:53:15	1.226
+++ LVM2/VERSION	2010/02/16 00:27:01	1.227
@@ -1 +1 @@
-2.02.61(1)-cvs (2010-02-15)
+2.02.62(1)-cvs (2010-02-15)
--- LVM2/VERSION_DM	2010/02/15 23:53:15	1.38
+++ LVM2/VERSION_DM	2010/02/16 00:27:01	1.39
@@ -1 +1 @@
-1.02.44-cvs (2010-02-15)
+1.02.45-cvs (2010-02-15)
--- LVM2/WHATS_NEW	2010/02/15 23:53:15	1.1433
+++ LVM2/WHATS_NEW	2010/02/16 00:27:01	1.1434
@@ -1,3 +1,6 @@
+Version 2.02.62 -
+====================================
+
 Version 2.02.61 - 15th February 2010
 ====================================
   Fix some consts and floating point gcc warnings.
--- LVM2/WHATS_NEW_DM	2010/02/15 23:53:15	1.345
+++ LVM2/WHATS_NEW_DM	2010/02/16 00:27:01	1.346
@@ -1,3 +1,6 @@
+Version 1.02.45 -
+====================================
+
 Version 1.02.44 - 15th February 2010
 ====================================
   Add DM_UDEV_DISABLE_LIBRARY_FALLBACK udev flag to rely on udev only.
--- LVM2/liblvm/lvm_lv.c	2010/02/14 03:21:06	1.17
+++ LVM2/liblvm/lvm_lv.c	2010/02/16 00:27:02	1.18
@@ -26,7 +26,7 @@
 /* FIXME: have lib/report/report.c _disp function call lv_size()? */
 uint64_t lvm_lv_get_size(const lv_t lv)
 {
-	return SECTOR_SIZE*lv_size(lv);
+	return SECTOR_SIZE * lv_size(lv);
 }
 
 char *lvm_lv_get_uuid(const lv_t lv)
@@ -112,7 +112,8 @@
 	if (!vg_check_write_mode(vg))
 		return NULL;
 	memset(&lp, 0, sizeof(lp));
-	extents = extents_from_size(vg->cmd, size/SECTOR_SIZE, vg->extent_size);
+	extents = extents_from_size(vg->cmd, size / SECTOR_SIZE,
+				    vg->extent_size);
 	_lv_set_default_params(&lp, vg, name, extents);
 	_lv_set_default_linear_params(vg->cmd, &lp);
 	if (!lv_create_single(vg, &lp))
--- LVM2/liblvm/lvm_pv.c	2010/02/14 03:21:38	1.8
+++ LVM2/liblvm/lvm_pv.c	2010/02/16 00:27:02	1.9
@@ -45,17 +45,17 @@
 
 uint64_t lvm_pv_get_dev_size(const pv_t pv)
 {
-	return (uint64_t) SECTOR_SIZE*pv_dev_size(pv);
+	return (uint64_t) SECTOR_SIZE * pv_dev_size(pv);
 }
 
 uint64_t lvm_pv_get_size(const pv_t pv)
 {
-	return (uint64_t) SECTOR_SIZE*pv_size_field(pv);
+	return (uint64_t) SECTOR_SIZE * pv_size_field(pv);
 }
 
 uint64_t lvm_pv_get_free(const pv_t pv)
 {
-	return (uint64_t) SECTOR_SIZE*pv_free(pv);
+	return (uint64_t) SECTOR_SIZE * pv_free(pv);
 }
 
 int lvm_pv_resize(const pv_t pv, uint64_t new_size)
--- LVM2/liblvm/lvm_vg.c	2010/02/14 03:21:06	1.35
+++ LVM2/liblvm/lvm_vg.c	2010/02/16 00:27:02	1.36
@@ -86,7 +86,7 @@
 	if (!vg_check_write_mode(vg))
 		return -1;
 
-	if (!vg_set_extent_size(vg, new_size/SECTOR_SIZE))
+	if (!vg_set_extent_size(vg, new_size / SECTOR_SIZE))
 		return -1;
 	return 0;
 }
@@ -256,17 +256,17 @@
 /* FIXME: invalid handle? return INTMAX? */
 uint64_t lvm_vg_get_size(const vg_t vg)
 {
-	return SECTOR_SIZE*vg_size(vg);
+	return SECTOR_SIZE * vg_size(vg);
 }
 
 uint64_t lvm_vg_get_free_size(const vg_t vg)
 {
-	return SECTOR_SIZE*vg_free(vg);
+	return SECTOR_SIZE * vg_free(vg);
 }
 
 uint64_t lvm_vg_get_extent_size(const vg_t vg)
 {
-	return SECTOR_SIZE*vg_extent_size(vg);
+	return SECTOR_SIZE * vg_extent_size(vg);
 }
 
 uint64_t lvm_vg_get_extent_count(const vg_t vg)


