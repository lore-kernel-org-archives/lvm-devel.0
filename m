From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 22 Sep 2010 17:06:24 -0400
Subject: [PATCH 12/20] Add 'get' functions for vg fields.
In-Reply-To: <1285189592-26525-1-git-send-email-dwysocha@redhat.com>
References: <1285189592-26525-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1285189592-26525-13-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add 'get' functions based on generic macros for VG, PV, and LV.
Add 'get' functions for vg string fields, vg_name, vg_fmt, vg_sysid,
vg_uuid, vg_attr, and vg_tags, and all numeric fields.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/report/properties.c |   44 ++++++++++++++++++++++----------------------
 1 files changed, 22 insertions(+), 22 deletions(-)

diff --git a/lib/report/properties.c b/lib/report/properties.c
index b39a979..89a462b 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -135,49 +135,49 @@ static int _not_implemented(void *obj, struct lvm_property_type *prop)
 #define _modules_set _not_implemented
 
 /* VG */
-#define _vg_fmt_get _not_implemented
+GET_VG_STR_PROPERTY_FN(vg_fmt, vg_fmt_dup(vg))
 #define _vg_fmt_set _not_implemented
-#define _vg_uuid_get _not_implemented
+GET_VG_STR_PROPERTY_FN(vg_uuid, vg_uuid_dup(vg))
 #define _vg_uuid_set _not_implemented
-#define _vg_name_get _not_implemented
+GET_VG_STR_PROPERTY_FN(vg_name, vg_name_dup(vg))
 #define _vg_name_set _not_implemented
-#define _vg_attr_get _not_implemented
+GET_VG_STR_PROPERTY_FN(vg_attr, vg_attr_dup(vg->vgmem, vg))
 #define _vg_attr_set _not_implemented
-GET_NUM_PROPERTY_FN(vg_size, (SECTOR_SIZE * vg_size(vg)))
+GET_VG_NUM_PROPERTY_FN(vg_size, (SECTOR_SIZE * vg_size(vg)))
 #define _vg_size_set _not_implemented
-GET_NUM_PROPERTY_FN(vg_free, (SECTOR_SIZE * vg_free(vg)))
+GET_VG_NUM_PROPERTY_FN(vg_free, (SECTOR_SIZE * vg_free(vg)))
 #define _vg_free_set _not_implemented
-#define _vg_sysid_get _not_implemented
+GET_VG_STR_PROPERTY_FN(vg_sysid, vg_system_id_dup(vg))
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
-#define _vg_tags_get _not_implemented
+GET_VG_STR_PROPERTY_FN(vg_tags, vg_tags_dup(vg))
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
1.7.2.2


