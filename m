From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 11 Oct 2010 11:14:29 -0400
Subject: [PATCH 05/14] Refactor and add code for (lv) 'convert_lv' get function.
In-Reply-To: <1286810078-25769-1-git-send-email-dwysocha@redhat.com>
References: <1286810078-25769-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1286810078-25769-6-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/lv.c       |   20 ++++++++++++++++++++
 lib/metadata/lv.h       |    1 +
 lib/report/properties.c |    2 +-
 lib/report/report.c     |   13 +------------
 4 files changed, 23 insertions(+), 13 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 8f4c95a..fd6d36d 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -18,6 +18,26 @@
 #include "activate.h"
 #include "toolcontext.h"
 
+char *lv_convert_lv_dup(struct dm_pool *mem, const struct logical_volume *lv)
+{
+	struct lv_segment *seg;
+	const char *name = NULL;
+
+	if (lv->status & CONVERTING) {
+		if (lv->status & MIRRORED) {
+			seg = first_seg(lv);
+
+			/* Temporary mirror is always area_num == 0 */
+			if (seg_type(seg, 0) == AREA_LV &&
+			    is_temporary_mirror_layer(seg_lv(seg, 0)))
+				name = seg_lv(seg, 0)->name;
+		}
+	}
+	if (name)
+		return dm_pool_strndup(mem, name, strlen(name) + 1);
+	return NULL;
+}
+
 char *lv_move_pv_dup(struct dm_pool *mem, const struct logical_volume *lv)
 {
 	const char *name;
diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index bfb38f9..1ba932b 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -55,5 +55,6 @@ char *lv_tags_dup(const struct logical_volume *lv);
 char *lv_path_dup(struct dm_pool *mem, const struct logical_volume *lv);
 uint64_t lv_origin_size(const struct logical_volume *lv);
 char *lv_move_pv_dup(struct dm_pool *mem, const struct logical_volume *lv);
+char *lv_convert_lv_dup(struct dm_pool *mem, const struct logical_volume *lv);
 
 #endif
diff --git a/lib/report/properties.c b/lib/report/properties.c
index bcec0c8..db02683 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -131,7 +131,7 @@ GET_LV_NUM_PROPERTY_FN(origin_size, lv_origin_size(lv))
 #define _copy_percent_set _not_implemented_set
 GET_LV_STR_PROPERTY_FN(move_pv, lv_move_pv_dup(lv->vg->vgmem, lv))
 #define _move_pv_set _not_implemented_set
-#define _convert_lv_get _not_implemented_get
+GET_LV_STR_PROPERTY_FN(convert_lv, lv_convert_lv_dup(lv->vg->vgmem, lv))
 #define _convert_lv_set _not_implemented_set
 GET_LV_STR_PROPERTY_FN(lv_tags, lv_tags_dup(lv))
 #define _lv_tags_set _not_implemented_set
diff --git a/lib/report/report.c b/lib/report/report.c
index 26ff879..bb2d4ce 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -392,19 +392,8 @@ static int _convertlv_disp(struct dm_report *rh, struct dm_pool *mem __attribute
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 	const char *name = NULL;
-	struct lv_segment *seg;
-
-	if (lv->status & CONVERTING) {
-		if (lv->status & MIRRORED) {
-			seg = first_seg(lv);
-
-			/* Temporary mirror is always area_num == 0 */
-			if (seg_type(seg, 0) == AREA_LV &&
-			    is_temporary_mirror_layer(seg_lv(seg, 0)))
-				name = seg_lv(seg, 0)->name;
-		}
-	}
 
+	name = lv_convert_lv_dup(mem, lv);
 	if (name)
 		return dm_report_field_string(rh, field, &name);
 
-- 
1.7.2.2


