From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 17 Nov 2010 20:10:43 -0000
Subject: LVM2/liblvm lvm2app.h lvm_pv.c
Message-ID: <20101117201043.8200.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-11-17 20:10:42

Modified files:
	liblvm         : lvm2app.h lvm_pv.c 

Log message:
	Add a new type and function to lvm2app to enumerate pvsegs.
	
	Signed-off-by: Dave Wysochanski <wysochanski@pobox.com>
	Reviewed-by: Petr Rockai <prockai@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm2app.h.diff?cvsroot=lvm2&r1=1.26&r2=1.27
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_pv.c.diff?cvsroot=lvm2&r1=1.15&r2=1.16

--- LVM2/liblvm/lvm2app.h	2010/11/17 20:09:42	1.26
+++ LVM2/liblvm/lvm2app.h	2010/11/17 20:10:42	1.27
@@ -96,6 +96,7 @@
 struct volume_group;
 struct logical_volume;
 struct lv_segment;
+struct pv_segment;
 
 /**
  * \class lvm_t
@@ -145,6 +146,13 @@
 typedef struct lv_segment *lvseg_t;
 
 /**
+ * \class pvseg_t
+ *
+ * This pv segment object is bound to a pv_t.
+ */
+typedef struct pv_segment *pvseg_t;
+
+/**
  * Logical Volume object list.
  *
  * Lists of these structures are returned by lvm_vg_list_lvs().
@@ -175,6 +183,16 @@
 } pv_list_t;
 
 /**
+ * Physical Volume Segment object list.
+ *
+ * Lists of these structures are returned by lvm_pv_list_pvsegs().
+ */
+typedef struct lvm_pvseg_list {
+	struct dm_list list;
+	pvseg_t pvseg;
+} pvseg_list_t;
+
+/**
  * String list.
  *
  * This string list contains read-only strings.
@@ -1419,6 +1437,19 @@
 struct lvm_property_value lvm_pv_get_property(const pv_t pv, const char *name);
 
 /**
+ * Return a list of pvseg handles for a given PV handle.
+ *
+ * \memberof pv_t
+ *
+ * \param   pv
+ * Physical volume handle.
+ *
+ * \return
+ * A list of lvm_pvseg_list structures containing pvseg handles for this pv.
+ */
+struct dm_list *lvm_pv_list_pvsegs(pv_t pv);
+
+/**
  * Resize physical volume to new_size bytes.
  *
  * \memberof pv_t
--- LVM2/liblvm/lvm_pv.c	2010/11/17 20:09:42	1.15
+++ LVM2/liblvm/lvm_pv.c	2010/11/17 20:10:42	1.16
@@ -54,6 +54,33 @@
 	return get_property(pv, NULL, NULL, NULL, name);
 }
 
+struct dm_list *lvm_pv_list_pvsegs(pv_t pv)
+{
+	struct dm_list *list;
+	pvseg_list_t *pvseg;
+	struct pv_segment *pvl;
+
+	if (dm_list_empty(&pv->segments))
+		return NULL;
+
+	if (!(list = dm_pool_zalloc(pv->vg->vgmem, sizeof(*list)))) {
+		log_errno(ENOMEM, "Memory allocation fail for dm_list.");
+		return NULL;
+	}
+	dm_list_init(list);
+
+	dm_list_iterate_items(pvl, &pv->segments) {
+		if (!(pvseg = dm_pool_zalloc(pv->vg->vgmem, sizeof(*pvseg)))) {
+			log_errno(ENOMEM,
+				"Memory allocation fail for lvm_pvseg_list.");
+			return NULL;
+		}
+		pvseg->pvseg = pvl;
+		dm_list_add(list, &pvseg->list);
+	}
+	return list;
+}
+
 int lvm_pv_resize(const pv_t pv, uint64_t new_size)
 {
 	/* FIXME: add pv resize code here */


