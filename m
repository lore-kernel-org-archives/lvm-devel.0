From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 15 Sep 2010 11:36:06 -0400
Subject: [PATCH 14/19] Make generic GET_*_PROPERTY_FN macros and define secondary macro for vg, pv, lv.
In-Reply-To: <1284564971-26060-1-git-send-email-dwysocha@redhat.com>
References: <1284564971-26060-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1284564971-26060-15-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Will need similar macros for VG, PV and LV, so define a generic one, and just
pass in the struct name and variable name for the specific macro.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/report/properties.c |   64 ++++++++++++++++++++++++++++-------------------
 1 files changed, 38 insertions(+), 26 deletions(-)

diff --git a/lib/report/properties.c b/lib/report/properties.c
index 1880ef7..0352489 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -20,23 +20,35 @@
 #include "lvm-types.h"
 #include "metadata.h"
 
-#define GET_NUM_PROPERTY_FN(NAME, VALUE) \
+#define GET_NUM_PROPERTY_FN(NAME, VALUE, STRUCT, VAR)			\
 static int _ ## NAME ## _get (void *obj, struct lvm_property_type *prop) \
 { \
-	struct volume_group *vg = (struct volume_group *)obj; \
+	struct STRUCT *VAR = (struct STRUCT *)obj; \
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
 
-#define GET_STR_PROPERTY_FN(NAME, VALUE) \
+#define GET_STR_PROPERTY_FN(NAME, VALUE, STRUCT, VAR)			\
 static int _ ## NAME ## _get (void *obj, struct lvm_property_type *prop) \
 { \
-	struct volume_group *vg = (struct volume_group *)obj; \
+	struct STRUCT *VAR = (struct STRUCT *)obj; \
 \
 	prop->v.s_val = (char *)VALUE;	\
 	return 1; \
 }
+#define GET_VG_STR_PROPERTY_FN(NAME, VALUE) \
+	GET_STR_PROPERTY_FN(NAME, VALUE, volume_group, vg)
+#define GET_PV_STR_PROPERTY_FN(NAME, VALUE) \
+	GET_STR_PROPERTY_FN(NAME, VALUE, physical_volume, pv)
+#define GET_LV_STR_PROPERTY_FN(NAME, VALUE) \
+	GET_STR_PROPERTY_FN(NAME, VALUE, logical_volume, lv)
 
 static int _not_implemented(void *obj, struct lvm_property_type *prop)
 {
@@ -140,49 +152,49 @@ static char *vg_system_id(const struct volume_group *vg)
 #define _modules_set _not_implemented
 
 /* VG */
-GET_STR_PROPERTY_FN(vg_fmt, vg_fmt(vg))
+GET_VG_STR_PROPERTY_FN(vg_fmt, vg_fmt(vg))
 #define _vg_fmt_set _not_implemented
-GET_STR_PROPERTY_FN(vg_uuid, vg_uuid(vg))
+GET_VG_STR_PROPERTY_FN(vg_uuid, vg_uuid(vg))
 #define _vg_uuid_set _not_implemented
-GET_STR_PROPERTY_FN(vg_name, vg_name(vg))
+GET_VG_STR_PROPERTY_FN(vg_name, vg_name(vg))
 #define _vg_name_set _not_implemented
-GET_STR_PROPERTY_FN(vg_attr, vg_attr(vg->vgmem, vg))
+GET_VG_STR_PROPERTY_FN(vg_attr, vg_attr(vg->vgmem, vg))
 #define _vg_attr_set _not_implemented
-GET_NUM_PROPERTY_FN(vg_size, (SECTOR_SIZE * vg_size(vg)))
+GET_VG_NUM_PROPERTY_FN(vg_size, (SECTOR_SIZE * vg_size(vg)))
 #define _vg_size_set _not_implemented
-GET_NUM_PROPERTY_FN(vg_free, (SECTOR_SIZE * vg_free(vg)))
+GET_VG_NUM_PROPERTY_FN(vg_free, (SECTOR_SIZE * vg_free(vg)))
 #define _vg_free_set _not_implemented
-GET_STR_PROPERTY_FN(vg_sysid, vg_system_id(vg))
+GET_VG_STR_PROPERTY_FN(vg_sysid, vg_system_id(vg))
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
-GET_STR_PROPERTY_FN(vg_tags, vg_tags(vg))
+GET_VG_STR_PROPERTY_FN(vg_tags, vg_tags(vg))
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
-- 
1.7.2.1


