From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 23 Jul 2009 23:39:03 -0000
Subject: LVM2/liblvm .exported_symbols lvm.h lvm_vg.c
Message-ID: <20090723233903.20533.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-23 23:39:02

Modified files:
	liblvm         : .exported_symbols lvm.h lvm_vg.c 

Log message:
	Add lvm_vg_list_{pvs|lvs} - return lists of pv/lv handles for a vg.
	
	- Use vgmem pool to allocate a list of lvm_*_list structs
	- Allocate a new list each call (list may have changed since last call)
	- Add to liblvm's exported symbols
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
	Acked-by: Thomas Woerner <twoerner@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/.exported_symbols.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm.h.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_vg.c.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/liblvm/.exported_symbols	2009/07/22 22:24:16	1.4
+++ LVM2/liblvm/.exported_symbols	2009/07/23 23:39:02	1.5
@@ -10,3 +10,5 @@
 lvm_vg_remove
 lvm_errno
 lvm_errmsg
+lvm_vg_list_pvs
+lvm_vg_list_lvs
--- LVM2/liblvm/lvm.h	2009/07/23 23:37:24	1.8
+++ LVM2/liblvm/lvm.h	2009/07/23 23:39:02	1.9
@@ -44,6 +44,13 @@
 	lv_t *lv;
 } lv_list_t;
 
+/**
+ * Return a list of LV handles for a given VG handle.
+ *
+ * \return  A list of lv_list_t structures containing lv handles for this vg.
+ *          If no LVs exist on the given VG, NULL is returned.
+ */
+struct dm_list *lvm_vg_list_lvs(vg_t *vg);
 
 struct lvm; /* internal data */
 
@@ -225,4 +232,12 @@
 vg_t *lvm_vg_open(lvm_t libh, const char *vgname, const char *mode,
 		  uint32_t flags);
 
+/**
+ * Return a list of PV handles for a given VG handle.
+ *
+ * \return  A list of pv_list_t structures containing pv handles for this vg.
+ *          If no PVs exist on the given VG, NULL is returned.
+ */
+struct dm_list *lvm_vg_list_pvs(vg_t *vg);
+
 #endif /* _LIB_LVM_H */
--- LVM2/liblvm/lvm_vg.c	2009/07/23 01:20:22	1.4
+++ LVM2/liblvm/lvm_vg.c	2009/07/23 23:39:02	1.5
@@ -114,3 +114,55 @@
 
 	return vg;
 }
+
+struct dm_list *lvm_vg_list_pvs(vg_t *vg)
+{
+	struct dm_list *list;
+	pv_list_t *pvs;
+	struct pv_list *pvl;
+
+	if (dm_list_empty(&vg->pvs))
+		return NULL;
+
+	if (!(list = dm_pool_zalloc(vg->vgmem, sizeof(*list)))) {
+		log_error("Memory allocation fail for dm_list.\n");
+		return NULL;
+	}
+	dm_list_init(list);
+
+	dm_list_iterate_items(pvl, &vg->pvs) {
+		if (!(pvs = dm_pool_zalloc(vg->vgmem, sizeof(*pvs)))) {
+			log_error("Memory allocation fail for lvm_pv_list.\n");
+			return NULL;
+		}
+		pvs->pv = pvl->pv;
+		dm_list_add(list, &pvs->list);
+	}
+	return list;
+}
+
+struct dm_list *lvm_vg_list_lvs(vg_t *vg)
+{
+	struct dm_list *list;
+	lv_list_t *lvs;
+	struct lv_list *lvl;
+
+	if (dm_list_empty(&vg->lvs))
+		return NULL;
+
+	if (!(list = dm_pool_zalloc(vg->vgmem, sizeof(*list)))) {
+		log_error("Memory allocation fail for dm_list.\n");
+		return NULL;
+	}
+	dm_list_init(list);
+
+	dm_list_iterate_items(lvl, &vg->lvs) {
+		if (!(lvs = dm_pool_zalloc(vg->vgmem, sizeof(*lvs)))) {
+			log_error("Memory allocation fail for lvm_lv_list.\n");
+			return NULL;
+		}
+		lvs->lv = lvl->lv;
+		dm_list_add(list, &lvs->list);
+	}
+	return list;
+}


