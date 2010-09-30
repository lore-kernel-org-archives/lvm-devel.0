From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 30 Sep 2010 14:08:46 -0000
Subject: LVM2/lib/report properties.c
Message-ID: <20100930140846.17845.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-09-30 14:08:46

Modified files:
	lib/report     : properties.c 

Log message:
	Make generic GET_*_PROPERTY_FN macros and define secondary macro for vg, pv, lv.
	
	Will need similar macros for VG, PV and LV, so define a generic one, and just
	pass in the struct name and variable name for the specific macro.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/properties.c.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/lib/report/properties.c	2010/09/09 19:38:03	1.4
+++ LVM2/lib/report/properties.c	2010/09/30 14:08:46	1.5
@@ -20,14 +20,35 @@
 #include "lvm-types.h"
 #include "metadata.h"
 
-#define GET_NUM_PROPERTY_FN(NAME, VALUE) \
+#define GET_NUM_PROPERTY_FN(NAME, VALUE, TYPE, VAR)			\
 static int _ ## NAME ## _get (void *obj, struct lvm_property_type *prop) \
 { \
-	struct volume_group *vg = (struct volume_group *)obj; \
+	struct TYPE *VAR = (struct TYPE *)obj; \
 \
 	prop->v.n_val = VALUE; \
 	return 1; \
 }
+#define GET_VG_NUM_PROPERTY_FN(NAME, VALUE) \
+	GET_NUM_PROPERTY_FN(NAME, VALUE, volume_group, vg)
+#define GET_PV_NUM_PROPERTY_FN(NAME, VALUE) \
+	GET_NUM_PROPERTY_FN(NAME, VALUE, physical_volume, pv)
+#define GET_LV_NUM_PROPERTY_FN(NAME, VALUE) \
+	GET_NUM_PROPERTY_FN(NAME, VALUE, logical_volume, lv)
+
+#define GET_STR_PROPERTY_FN(NAME, VALUE, TYPE, VAR)			\
+static int _ ## NAME ## _get (void *obj, struct lvm_property_type *prop) \
+{ \
+	struct TYPE *VAR = (struct TYPE *)obj; \
+\
+	prop->v.s_val = (char *)VALUE;	\
+	return 1; \
+}
+#define GET_VG_STR_PROPERTY_FN(NAME, VALUE) \
+	GET_STR_PROPERTY_FN(NAME, VALUE, volume_group, vg)
+#define GET_PV_STR_PROPERTY_FN(NAME, VALUE) \
+	GET_STR_PROPERTY_FN(NAME, VALUE, physical_volume, pv)
+#define GET_LV_STR_PROPERTY_FN(NAME, VALUE) \
+	GET_STR_PROPERTY_FN(NAME, VALUE, logical_volume, lv)
 
 static int _not_implemented(void *obj, struct lvm_property_type *prop)
 {
@@ -122,41 +143,41 @@
 #define _vg_name_set _not_implemented
 #define _vg_attr_get _not_implemented
 #define _vg_attr_set _not_implemented
-GET_NUM_PROPERTY_FN(vg_size, (SECTOR_SIZE * vg_size(vg)))
+GET_VG_NUM_PROPERTY_FN(vg_size, (SECTOR_SIZE * vg_size(vg)))
 #define _vg_size_set _not_implemented
-GET_NUM_PROPERTY_FN(vg_free, (SECTOR_SIZE * vg_free(vg)))
+GET_VG_NUM_PROPERTY_FN(vg_free, (SECTOR_SIZE * vg_free(vg)))
 #define _vg_free_set _not_implemented
 #define _vg_sysid_get _not_implemented
 #define _vg_sysid_set _not_implemented
-GET_NUM_PROPERTY_FN(vg_extent_size, vg->extent_size)
+GET_VG_NUM_PROPERTY_FN(vg_extent_size, vg->extent_size)
 #define _vg_extent_size_set _not_implemented
-GET_NUM_PROPERTY_FN(vg_extent_count, vg->extent_count)
+GET_VG_NUM_PROPERTY_FN(vg_extent_count, vg->extent_count)
 #define _vg_extent_count_set _not_implemented
-GET_NUM_PROPERTY_FN(vg_free_count, vg->free_count)
+GET_VG_NUM_PROPERTY_FN(vg_free_count, vg->free_count)
 #define _vg_free_count_set _not_implemented
-GET_NUM_PROPERTY_FN(max_lv, vg->max_lv)
+GET_VG_NUM_PROPERTY_FN(max_lv, vg->max_lv)
 #define _max_lv_set _not_implemented
-GET_NUM_PROPERTY_FN(max_pv, vg->max_pv)
+GET_VG_NUM_PROPERTY_FN(max_pv, vg->max_pv)
 #define _max_pv_set _not_implemented
-GET_NUM_PROPERTY_FN(pv_count, vg->pv_count)
+GET_VG_NUM_PROPERTY_FN(pv_count, vg->pv_count)
 #define _pv_count_set _not_implemented
-GET_NUM_PROPERTY_FN(lv_count, (vg_visible_lvs(vg)))
+GET_VG_NUM_PROPERTY_FN(lv_count, (vg_visible_lvs(vg)))
 #define _lv_count_set _not_implemented
-GET_NUM_PROPERTY_FN(snap_count, (snapshot_count(vg)))
+GET_VG_NUM_PROPERTY_FN(snap_count, (snapshot_count(vg)))
 #define _snap_count_set _not_implemented
-GET_NUM_PROPERTY_FN(vg_seqno, vg->seqno)
+GET_VG_NUM_PROPERTY_FN(vg_seqno, vg->seqno)
 #define _vg_seqno_set _not_implemented
 #define _vg_tags_get _not_implemented
 #define _vg_tags_set _not_implemented
-GET_NUM_PROPERTY_FN(vg_mda_count, (vg_mda_count(vg)))
+GET_VG_NUM_PROPERTY_FN(vg_mda_count, (vg_mda_count(vg)))
 #define _vg_mda_count_set _not_implemented
-GET_NUM_PROPERTY_FN(vg_mda_used_count, (vg_mda_used_count(vg)))
+GET_VG_NUM_PROPERTY_FN(vg_mda_used_count, (vg_mda_used_count(vg)))
 #define _vg_mda_used_count_set _not_implemented
-GET_NUM_PROPERTY_FN(vg_mda_free, (SECTOR_SIZE * vg_mda_free(vg)))
+GET_VG_NUM_PROPERTY_FN(vg_mda_free, (SECTOR_SIZE * vg_mda_free(vg)))
 #define _vg_mda_free_set _not_implemented
-GET_NUM_PROPERTY_FN(vg_mda_size, (SECTOR_SIZE * vg_mda_size(vg)))
+GET_VG_NUM_PROPERTY_FN(vg_mda_size, (SECTOR_SIZE * vg_mda_size(vg)))
 #define _vg_mda_size_set _not_implemented
-GET_NUM_PROPERTY_FN(vg_mda_copies, (vg_mda_copies(vg)))
+GET_VG_NUM_PROPERTY_FN(vg_mda_copies, (vg_mda_copies(vg)))
 #define _vg_mda_copies_set _not_implemented
 
 /* LVSEG */


