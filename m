From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 27 Jul 2009 17:44:29 -0000
Subject: LVM2/liblvm .exported_symbols lvm.h lvm_vg.c
Message-ID: <20090727174429.22237.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-27 17:44:29

Modified files:
	liblvm         : .exported_symbols lvm.h lvm_vg.c 

Log message:
	Add lvm_vg_reduce to liblvm2app
	
	Extend lvm_vg_write to remove pvs removed in lvm_vg_reduce. The lvm
	volume_group internal structure removed_pvs is used for that. The list is
	empty afterwards.
	
	Add new test for vg->pvs emptyness to lvm_vg_write to prevent to write empty
	vgs. This is needed because of lvm_vg_reduce and lv_vg_create, which creates
	empty vgs.
	
	Signed-off-by: Thomas Woerner <twoerner@redhat.com>
	Acked-by: Dave Wysochanski <dwysocha@redhat.com>
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/.exported_symbols.diff?cvsroot=lvm2&r1=1.17&r2=1.18
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm.h.diff?cvsroot=lvm2&r1=1.29&r2=1.30
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_vg.c.diff?cvsroot=lvm2&r1=1.18&r2=1.19

--- LVM2/liblvm/.exported_symbols	2009/07/26 20:58:11	1.17
+++ LVM2/liblvm/.exported_symbols	2009/07/27 17:44:29	1.18
@@ -21,6 +21,7 @@
 lvm_lv_is_suspended
 lvm_vg_create
 lvm_vg_extend
+lvm_vg_reduce
 lvm_vg_set_extent_size
 lvm_vg_write
 lvm_vg_open
--- LVM2/liblvm/lvm.h	2009/07/27 11:00:18	1.29
+++ LVM2/liblvm/lvm.h	2009/07/27 17:44:29	1.30
@@ -331,6 +331,24 @@
 int lvm_vg_extend(vg_t *vg, const char *device);
 
 /**
+ * Reduce a VG by removing an unused device.
+ *
+ * This API requires calling lvm_vg_write to commit the change to disk.
+ * After successfully removing a device, use lvm_vg_write to commit the new VG
+ * to disk.  Upon failure, retry the operation or release the VG handle with
+ * lvm_vg_close.
+ *
+ * \param   vg
+ *          VG handle obtained from lvm_vg_create or lvm_vg_open.
+ *
+ * \param   device
+ *          Name of device to remove from VG.
+ *
+ * \return  0 (success) or -1 (failure).
+ */
+int lvm_vg_reduce(vg_t *vg, const char *device);
+
+/**
  * Set the extent size of a VG.
  *
  * This API requires calling lvm_vg_write to commit the change to disk.
--- LVM2/liblvm/lvm_vg.c	2009/07/27 11:00:18	1.18
+++ LVM2/liblvm/lvm_vg.c	2009/07/27 17:44:29	1.19
@@ -68,6 +68,16 @@
 	return 0;
 }
 
+int lvm_vg_reduce(vg_t *vg, const char *device)
+{
+	if (vg_read_error(vg))
+		return -1;
+
+	if (!vg_reduce(vg, (char *)device))
+		return -1;
+	return 0;
+}
+
 int lvm_vg_set_extent_size(vg_t *vg, uint32_t new_size)
 {
 	if (vg_read_error(vg))
@@ -80,15 +90,40 @@
 
 int lvm_vg_write(vg_t *vg)
 {
+	struct pv_list *pvl;
+
 	if (vg_read_error(vg))
 		return -1;
 
+	if (dm_list_empty(&vg->pvs)) {
+		log_error("Volume group %s does not contain any "
+			  "physical volumes.\n", vg->name);
+		return -1;
+	}
+
+	if (! dm_list_empty(&vg->removed_pvs)) {
+		if (!lock_vol(vg->cmd, VG_ORPHANS, LCK_VG_WRITE)) {
+			log_error("Can't get lock for orphan PVs");
+			return 0;
+		}
+	}
+
 	if (!archive(vg))
 		return -1;
 
 	/* Store VG on disk(s) */
 	if (!vg_write(vg) || !vg_commit(vg))
 		return -1;
+
+	if (! dm_list_empty(&vg->removed_pvs)) {
+		dm_list_iterate_items(pvl, &vg->removed_pvs) {
+			pv_write_orphan(vg->cmd, pvl->pv);
+			/* FIXME: do pvremove / label_remove()? */
+		}
+		dm_list_init(&vg->removed_pvs);
+		unlock_vg(vg->cmd, VG_ORPHANS);
+	}
+
 	return 0;
 }
 


