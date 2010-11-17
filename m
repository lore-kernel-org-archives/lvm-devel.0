From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 17 Nov 2010 20:07:02 -0000
Subject: LVM2/liblvm lvm2app.h lvm_lv.c
Message-ID: <20101117200702.6896.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-11-17 20:07:01

Modified files:
	liblvm         : lvm2app.h lvm_lv.c 

Log message:
	Add a new type and function to lvm2app to enumerate lvsegs.
	
	Signed-off-by: Dave Wysochanski <wysochanski@pobox.com>
	Reviewed-by: Petr Rockai <prockai@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm2app.h.diff?cvsroot=lvm2&r1=1.24&r2=1.25
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_lv.c.diff?cvsroot=lvm2&r1=1.28&r2=1.29

--- LVM2/liblvm/lvm2app.h	2010/11/17 19:16:05	1.24
+++ LVM2/liblvm/lvm2app.h	2010/11/17 20:07:01	1.25
@@ -95,6 +95,7 @@
 struct physical_volume;
 struct volume_group;
 struct logical_volume;
+struct lv_segment;
 
 /**
  * \class lvm_t
@@ -137,6 +138,13 @@
 typedef struct physical_volume *pv_t;
 
 /**
+ * \class lvseg_t
+ *
+ * This lv segment object is bound to a lv_t.
+ */
+typedef struct lv_segment *lvseg_t;
+
+/**
  * Logical Volume object list.
  *
  * Lists of these structures are returned by lvm_vg_list_lvs().
@@ -147,6 +155,16 @@
 } lv_list_t;
 
 /**
+ * Logical Volume Segment object list.
+ *
+ * Lists of these structures are returned by lvm_lv_list_lvsegs().
+ */
+typedef struct lvm_lvseg_list {
+	struct dm_list list;
+	lvseg_t lvseg;
+} lvseg_list_t;
+
+/**
  * Physical volume object list.
  *
  * Lists of these structures are returned by lvm_vg_list_pvs().
@@ -966,6 +984,19 @@
 lv_t lvm_vg_create_lv_linear(vg_t vg, const char *name, uint64_t size);
 
 /**
+ * Return a list of lvseg handles for a given LV handle.
+ *
+ * \memberof lv_t
+ *
+ * \param   lv
+ * Logical volume handle.
+ *
+ * \return
+ * A list of lvm_lvseg_list structures containing lvseg handles for this lv.
+ */
+struct dm_list *lvm_lv_list_lvsegs(lv_t lv);
+
+/**
  * Activate a logical volume.
  *
  * \memberof lv_t
--- LVM2/liblvm/lvm_lv.c	2010/11/11 17:29:06	1.28
+++ LVM2/liblvm/lvm_lv.c	2010/11/17 20:07:01	1.29
@@ -216,6 +216,33 @@
 	return 0;
 }
 
+struct dm_list *lvm_lv_list_lvsegs(lv_t lv)
+{
+	struct dm_list *list;
+	lvseg_list_t *lvseg;
+	struct lv_segment *lvl;
+
+	if (dm_list_empty(&lv->segments))
+		return NULL;
+
+	if (!(list = dm_pool_zalloc(lv->vg->vgmem, sizeof(*list)))) {
+		log_errno(ENOMEM, "Memory allocation fail for dm_list.");
+		return NULL;
+	}
+	dm_list_init(list);
+
+	dm_list_iterate_items(lvl, &lv->segments) {
+		if (!(lvseg = dm_pool_zalloc(lv->vg->vgmem, sizeof(*lvseg)))) {
+			log_errno(ENOMEM,
+				"Memory allocation fail for lvm_lvseg_list.");
+			return NULL;
+		}
+		lvseg->lvseg = lvl;
+		dm_list_add(list, &lvseg->list);
+	}
+	return list;
+}
+
 int lvm_lv_resize(const lv_t lv, uint64_t new_size)
 {
 	/* FIXME: add lv resize code here */


