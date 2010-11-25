From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 25 Nov 2010 14:33:52 -0000
Subject: LVM2/liblvm lvm2app.h lvm_lv.c lvm_pv.c
Message-ID: <20101125143352.8667.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-11-25 14:33:45

Modified files:
	liblvm         : lvm2app.h lvm_lv.c lvm_pv.c 

Log message:
	This patch adds helpers to allow users to lookup a lv or pv handle by
	name (given a vg_t of course).
	
	Signed-off-by: Dave Wysochanski <wysochanski@pobox.com>
	Reviewed-by: Petr Rockai <prockai@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm2app.h.diff?cvsroot=lvm2&r1=1.28&r2=1.29
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_lv.c.diff?cvsroot=lvm2&r1=1.31&r2=1.32
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_pv.c.diff?cvsroot=lvm2&r1=1.17&r2=1.18

--- LVM2/liblvm/lvm2app.h	2010/11/17 20:12:39	1.28
+++ LVM2/liblvm/lvm2app.h	2010/11/25 14:33:44	1.29
@@ -1015,6 +1015,23 @@
 struct dm_list *lvm_lv_list_lvsegs(lv_t lv);
 
 /**
+ * Lookup an LV handle in a VG by the LV name.
+ *
+ * \memberof lv_t
+ *
+ * \param   vg
+ * VG handle obtained from lvm_vg_create() or lvm_vg_open().
+ *
+ * \param   name
+ * Name of LV to lookup.
+ *
+ * \return
+ * non-NULL handle to the LV 'name' attached to the VG.
+ * NULL is returned if the LV name is not associated with the VG handle.
+ */
+lv_t lvm_lv_from_name(vg_t vg, const char *name);
+
+/**
  * Activate a logical volume.
  *
  * \memberof lv_t
@@ -1489,6 +1506,23 @@
 struct dm_list *lvm_pv_list_pvsegs(pv_t pv);
 
 /**
+ * Lookup an PV handle in a VG by the PV name.
+ *
+ * \memberof pv_t
+ *
+ * \param   vg
+ * VG handle obtained from lvm_vg_create() or lvm_vg_open().
+ *
+ * \param   name
+ * Name of PV to lookup.
+ *
+ * \return
+ * non-NULL handle to the PV 'name' attached to the VG.
+ * NULL is returned if the PV name is not associated with the VG handle.
+ */
+pv_t lvm_pv_from_name(vg_t vg, const char *name);
+
+/**
  * Resize physical volume to new_size bytes.
  *
  * \memberof pv_t
--- LVM2/liblvm/lvm_lv.c	2010/11/17 20:12:39	1.31
+++ LVM2/liblvm/lvm_lv.c	2010/11/25 14:33:44	1.32
@@ -249,6 +249,17 @@
 	return list;
 }
 
+lv_t lvm_lv_from_name(vg_t vg, const char *name)
+{
+	struct lv_list *lvl;
+
+	dm_list_iterate_items(lvl, &vg->lvs) {
+		if (!strcmp(name, lvl->lv->name))
+			return lvl->lv;
+	}
+	return NULL;
+}
+
 int lvm_lv_resize(const lv_t lv, uint64_t new_size)
 {
 	/* FIXME: add lv resize code here */
--- LVM2/liblvm/lvm_pv.c	2010/11/17 20:12:40	1.17
+++ LVM2/liblvm/lvm_pv.c	2010/11/25 14:33:44	1.18
@@ -87,6 +87,18 @@
 	return list;
 }
 
+pv_t lvm_pv_from_name(vg_t vg, const char *name)
+{
+	struct pv_list *pvl;
+
+	dm_list_iterate_items(pvl, &vg->pvs) {
+		if (!strcmp(name, pv_dev_name(pvl->pv)))
+			return pvl->pv;
+	}
+	return NULL;
+}
+
+
 int lvm_pv_resize(const pv_t pv, uint64_t new_size)
 {
 	/* FIXME: add pv resize code here */


