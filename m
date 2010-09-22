From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 22 Sep 2010 17:06:29 -0400
Subject: [PATCH 17/20] Add pv 'get' functions for all pv properties.
In-Reply-To: <1285189592-26525-1-git-send-email-dwysocha@redhat.com>
References: <1285189592-26525-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1285189592-26525-18-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add 'get' functions for all pv properties.
Multiply by SECTOR_SIZE for pv properties pv_mda_free, pv_mda_size,
pe_start, pv_size, pv_free, pv_used.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/report/properties.c |   32 ++++++++++++++++----------------
 1 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/lib/report/properties.c b/lib/report/properties.c
index 89a462b..18a5d09 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -57,37 +57,37 @@ static int _not_implemented(void *obj, struct lvm_property_type *prop)
 }
 
 /* PV */
-#define _pv_fmt_get _not_implemented
+GET_PV_STR_PROPERTY_FN(pv_fmt, pv_fmt_dup(pv))
 #define _pv_fmt_set _not_implemented
-#define _pv_uuid_get _not_implemented
+GET_PV_STR_PROPERTY_FN(pv_uuid, pv_uuid_dup(pv))
 #define _pv_uuid_set _not_implemented
-#define _dev_size_get _not_implemented
+GET_PV_NUM_PROPERTY_FN(dev_size, SECTOR_SIZE * pv_dev_size(pv))
 #define _dev_size_set _not_implemented
-#define _pv_name_get _not_implemented
+GET_PV_STR_PROPERTY_FN(pv_name, pv_name_dup(pv))
 #define _pv_name_set _not_implemented
-#define _pv_mda_free_get _not_implemented
+GET_PV_NUM_PROPERTY_FN(pv_mda_free, SECTOR_SIZE * pv_mda_free(pv))
 #define _pv_mda_free_set _not_implemented
-#define _pv_mda_size_get _not_implemented
+GET_PV_NUM_PROPERTY_FN(pv_mda_size, SECTOR_SIZE * pv_mda_size(pv))
 #define _pv_mda_size_set _not_implemented
-#define _pe_start_get _not_implemented
+GET_PV_NUM_PROPERTY_FN(pe_start, SECTOR_SIZE * pv->pe_start)
 #define _pe_start_set _not_implemented
-#define _pv_size_get _not_implemented
+GET_PV_NUM_PROPERTY_FN(pv_size, SECTOR_SIZE * pv_size_field(pv))
 #define _pv_size_set _not_implemented
-#define _pv_free_get _not_implemented
+GET_PV_NUM_PROPERTY_FN(pv_free, SECTOR_SIZE * pv_free(pv))
 #define _pv_free_set _not_implemented
-#define _pv_used_get _not_implemented
+GET_PV_NUM_PROPERTY_FN(pv_used, SECTOR_SIZE * pv_used(pv))
 #define _pv_used_set _not_implemented
-#define _pv_attr_get _not_implemented
+GET_PV_STR_PROPERTY_FN(pv_attr, pv_attr_dup(pv->vg->vgmem, pv))
 #define _pv_attr_set _not_implemented
-#define _pv_pe_count_get _not_implemented
+GET_PV_NUM_PROPERTY_FN(pv_pe_count, pv->pe_count)
 #define _pv_pe_count_set _not_implemented
-#define _pv_pe_alloc_count_get _not_implemented
+GET_PV_NUM_PROPERTY_FN(pv_pe_alloc_count, pv->pe_alloc_count)
 #define _pv_pe_alloc_count_set _not_implemented
-#define _pv_tags_get _not_implemented
+GET_PV_STR_PROPERTY_FN(pv_tags, pv_tags_dup(pv))
 #define _pv_tags_set _not_implemented
-#define _pv_mda_count_get _not_implemented
+GET_PV_NUM_PROPERTY_FN(pv_mda_count, pv_mda_count(pv))
 #define _pv_mda_count_set _not_implemented
-#define _pv_mda_used_count_get _not_implemented
+GET_PV_NUM_PROPERTY_FN(pv_mda_used_count, pv_mda_used_count(pv))
 #define _pv_mda_used_count_set _not_implemented
 
 /* LV */
-- 
1.7.2.2


