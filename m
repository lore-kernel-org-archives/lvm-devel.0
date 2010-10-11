From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 11 Oct 2010 11:14:28 -0400
Subject: [PATCH 04/14] Refactor and add code for (lv) 'move_pv' get function.
In-Reply-To: <1286810078-25769-1-git-send-email-dwysocha@redhat.com>
References: <1286810078-25769-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1286810078-25769-5-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/lv.c       |   15 +++++++++++++++
 lib/metadata/lv.h       |    1 +
 lib/report/properties.c |    2 +-
 lib/report/report.c     |   11 +++--------
 4 files changed, 20 insertions(+), 9 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index ae8a4fb..8f4c95a 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -18,6 +18,21 @@
 #include "activate.h"
 #include "toolcontext.h"
 
+char *lv_move_pv_dup(struct dm_pool *mem, const struct logical_volume *lv)
+{
+	const char *name;
+	struct lv_segment *seg;
+
+	dm_list_iterate_items(seg, &lv->segments) {
+		if (!(seg->status & PVMOVE))
+			continue;
+		name = dev_name(seg_dev(seg, 0));
+	}
+	if (name)
+		return dm_pool_strndup(mem, name, strlen(name) + 1);
+	return NULL;
+}
+
 uint64_t lv_origin_size(const struct logical_volume *lv)
 {
 	uint64_t size;
diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index 69c4077..bfb38f9 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -54,5 +54,6 @@ char *lv_uuid_dup(const struct logical_volume *lv);
 char *lv_tags_dup(const struct logical_volume *lv);
 char *lv_path_dup(struct dm_pool *mem, const struct logical_volume *lv);
 uint64_t lv_origin_size(const struct logical_volume *lv);
+char *lv_move_pv_dup(struct dm_pool *mem, const struct logical_volume *lv);
 
 #endif
diff --git a/lib/report/properties.c b/lib/report/properties.c
index 27503a9..bcec0c8 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -129,7 +129,7 @@ GET_LV_NUM_PROPERTY_FN(origin_size, lv_origin_size(lv))
 #define _snap_percent_set _not_implemented_set
 #define _copy_percent_get _not_implemented_get
 #define _copy_percent_set _not_implemented_set
-#define _move_pv_get _not_implemented_get
+GET_LV_STR_PROPERTY_FN(move_pv, lv_move_pv_dup(lv->vg->vgmem, lv))
 #define _move_pv_set _not_implemented_set
 #define _convert_lv_get _not_implemented_get
 #define _convert_lv_set _not_implemented_set
diff --git a/lib/report/report.c b/lib/report/report.c
index 83216b2..26ff879 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -378,16 +378,11 @@ static int _movepv_disp(struct dm_report *rh, struct dm_pool *mem __attribute__(
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 	const char *name;
-	struct lv_segment *seg;
 
-	dm_list_iterate_items(seg, &lv->segments) {
-		if (!(seg->status & PVMOVE))
-			continue;
-		name = dev_name(seg_dev(seg, 0));
+	if (!(name = lv_move_pv_dup(mem, lv)))
+		dm_report_field_set_value(field, "", NULL);
+	else
 		return dm_report_field_string(rh, field, &name);
-	}
-
-	dm_report_field_set_value(field, "", NULL);
 	return 1;
 }
 
-- 
1.7.2.2


