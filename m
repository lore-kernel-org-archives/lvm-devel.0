From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 26 Jul 2009 20:29:00 -0000
Subject: LVM2/liblvm lvm.h lvm_base.c lvm_lv.c lvm_vg.c
Message-ID: <20090726202900.22468.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-26 20:29:00

Modified files:
	liblvm         : lvm.h lvm_base.c lvm_lv.c lvm_vg.c 

Log message:
	Update liblvm status return codes to be consistent.
	
	For now, we use the following scheme.
	For APIs that return an int, success is 0, fail is -1.
	APIs that return handles, success is non-NULL, fail is NULL.
	At this early stage, liblvm error handling mechanism is subject to change,
	but for now we go with this simple scheme consistent with system
	programming.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm.h.diff?cvsroot=lvm2&r1=1.23&r2=1.24
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_base.c.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_lv.c.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_vg.c.diff?cvsroot=lvm2&r1=1.15&r2=1.16

--- LVM2/liblvm/lvm.h	2009/07/26 16:49:52	1.23
+++ LVM2/liblvm/lvm.h	2009/07/26 20:28:59	1.24
@@ -144,6 +144,7 @@
  *
  * \param   libh
  *          Handle obtained from lvm_create.
+ * \return  0 (success) or -1 (failure).
  */
 int lvm_reload_config(lvm_t libh);
 
@@ -174,7 +175,7 @@
 /**
  * Scan all devices on the system for VGs and LVM metadata.
  *
- * \return  Status code of 1 (success) or 0 (failure).
+ * \return  0 (success) or -1 (failure).
  */
 int lvm_scan(lvm_t libh);
 
@@ -217,6 +218,7 @@
  *          Handle obtained from lvm_create.
  *
  * \return  List of copied uuid strings.
+ *          If no VGs exist on the system, NULL is returned.
  */
 struct dm_list *lvm_list_vg_uuids(lvm_t libh);
 
@@ -268,7 +270,7 @@
  *
  * \param   vg
  *          VG handle obtained from lvm_vg_create or lvm_vg_open.
- * \return  Status code of 1 (success) or 0 (failure).
+ * \return  0 (success) or -1 (failure).
  */
 int lvm_vg_write(vg_t *vg);
 
@@ -280,7 +282,7 @@
  *
  * \param   vg
  *          VG handle obtained from lvm_vg_create or lvm_vg_open.
- * \return  Status code of 1 (success) or 0 (failure).
+ * \return  0 (success) or -1 (failure).
  */
 int lvm_vg_remove(vg_t *vg);
 
@@ -291,7 +293,7 @@
  *
  * \param   vg
  *          VG handle obtained from lvm_vg_create or lvm_vg_open.
- * \return  Status code of 1 (success) or 0 (failure).
+ * \return  0 (success) or -1 (failure).
  */
 int lvm_vg_close(vg_t *vg);
 
@@ -311,7 +313,7 @@
  *          VG handle obtained from lvm_vg_create or lvm_vg_open.
  * \param   device
  *          Name of device to add to VG.
- * \return  Status code of 1 (success) or 0 (failure).
+ * \return  0 (success) or -1 (failure).
  */
 int lvm_vg_extend(vg_t *vg, const char *device);
 
@@ -327,7 +329,7 @@
  *          VG handle obtained from lvm_vg_create or lvm_vg_open.
  * \param   new_size
  *          New extent size in bytes.
- * \return  Status code of 1 (success) or 0 (failure).
+ * \return  0 (success) or -1 (failure).
  */
 int lvm_vg_set_extent_size(vg_t *vg, uint32_t new_size);
 
@@ -452,7 +454,7 @@
  *
  * \param   lv
  *          Logical volume handle.
- * \return  Status code of 1 (success) or 0 (failure).
+ * \return  0 (success) or -1 (failure).
  */
 int lvm_vg_remove_lv(lv_t *lv);
 
--- LVM2/liblvm/lvm_base.c	2009/07/16 00:37:00	1.4
+++ LVM2/liblvm/lvm_base.c	2009/07/26 20:28:59	1.5
@@ -61,14 +61,15 @@
 
 void lvm_destroy(lvm_t libh)
 {
-	/* FIXME: error handling */
 	destroy_toolcontext((struct cmd_context *)libh);
 }
 
 int lvm_reload_config(lvm_t libh)
 {
 	/* FIXME: re-init locking needed here? */
-	return refresh_toolcontext((struct cmd_context *)libh);
+	if (refresh_toolcontext((struct cmd_context *)libh))
+		return -1;
+	return 0;
 }
 
 int lvm_errno(lvm_t libh)
--- LVM2/liblvm/lvm_lv.c	2009/07/26 14:36:52	1.4
+++ LVM2/liblvm/lvm_lv.c	2009/07/26 20:28:59	1.5
@@ -99,6 +99,8 @@
 int lvm_vg_remove_lv(lv_t *lv)
 {
 	if (!lv || !lv->vg || vg_read_error(lv->vg))
-		return 0;
-	return lv_remove_single(lv->vg->cmd, lv, DONT_PROMPT);
+		return -1;
+	if (!lv_remove_single(lv->vg->cmd, lv, DONT_PROMPT))
+		return -1;
+	return 0;
 }
--- LVM2/liblvm/lvm_vg.c	2009/07/26 16:44:05	1.15
+++ LVM2/liblvm/lvm_vg.c	2009/07/26 20:28:59	1.16
@@ -41,11 +41,11 @@
 int lvm_vg_extend(vg_t *vg, const char *device)
 {
 	if (vg_read_error(vg))
-		return 0;
+		return -1;
 
 	if (!lock_vol(vg->cmd, VG_ORPHANS, LCK_VG_WRITE)) {
 		log_error("Can't get lock for orphan PVs");
-		return 0;
+		return -1;
 	}
 
 	/* If device not initialized, pvcreate it */
@@ -53,46 +53,42 @@
 	   (!pvcreate_single(vg->cmd, device, NULL))) {
 		log_error("Unable to initialize device for LVM use\n");
 		unlock_vg(vg->cmd, VG_ORPHANS);
-		return 0;
+		return -1;
 	}
 
 	if (!vg_extend(vg, 1, (char **) &device)) {
 		unlock_vg(vg->cmd, VG_ORPHANS);
-		return 0;
+		return -1;
 	}
 	/*
 	 * FIXME: Either commit to disk, or keep holding VG_ORPHANS and
 	 * release in lvm_vg_close().
 	 */
 	unlock_vg(vg->cmd, VG_ORPHANS);
-	return 1;
+	return 0;
 }
 
 int lvm_vg_set_extent_size(vg_t *vg, uint32_t new_size)
 {
 	if (vg_read_error(vg))
-		goto_bad;
+		return -1;
 
-	return vg_set_extent_size(vg, new_size);
-bad:
+	if (!vg_set_extent_size(vg, new_size))
+		return -1;
 	return 0;
 }
 
 int lvm_vg_write(vg_t *vg)
 {
 	if (vg_read_error(vg))
-		goto_bad;
+		return -1;
 
-	if (!archive(vg)) {
-		goto_bad;
-	}
+	if (!archive(vg))
+		return -1;
 
 	/* Store VG on disk(s) */
-	if (!vg_write(vg) || !vg_commit(vg)) {
-		goto_bad;
-	}
-	return 1;
-bad:
+	if (!vg_write(vg) || !vg_commit(vg))
+		return -1;
 	return 0;
 }
 
@@ -102,16 +98,16 @@
 		vg_release(vg);
 	else
 		unlock_and_release_vg(vg->cmd, vg, vg->name);
-	return 1;
+	return 0;
 }
 
 int lvm_vg_remove(vg_t *vg)
 {
 	if (vg_read_error(vg))
-		goto_bad;
+		return -1;
 
-	return vg_remove_single(vg);
-bad:
+	if (!vg_remove_single(vg))
+		return -1;
 	return 0;
 }
 
@@ -254,5 +250,7 @@
 
 int lvm_scan(lvm_t libh)
 {
-	return lvmcache_label_scan((struct cmd_context *)libh, 2);
+	if (!lvmcache_label_scan((struct cmd_context *)libh, 2))
+		return -1;
+	return 0;
 }


