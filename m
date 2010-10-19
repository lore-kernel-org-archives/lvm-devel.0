From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 19 Oct 2010 00:02:25 -0400
Subject: [PATCH 2/8] Refactor and add code for (lv) 'lv_origin' get function.
In-Reply-To: <1287460951-338-1-git-send-email-dwysocha@redhat.com>
References: <1287460951-338-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1287460951-338-3-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/lv.c       |    7 +++++++
 lib/metadata/lv.h       |    1 +
 lib/report/properties.c |    2 +-
 lib/report/report.c     |    5 +++--
 4 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index bbaeb64..9cd5bf8 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -20,6 +20,13 @@
 #include "segtype.h"
 #include "str_list.h"
 
+char *lv_origin_dup(struct dm_pool *mem, const struct logical_volume *lv)
+{
+	if (lv_is_cow(lv))
+		return lv_name_dup(mem, origin_from_cow(lv));
+	return NULL;
+}
+
 char *lv_name_dup(struct dm_pool *mem, const struct logical_volume *lv)
 {
 	return dm_pool_strdup(mem, lv->name);
diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index f80d2d5..1767551 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -61,5 +61,6 @@ int lv_kernel_minor(const struct logical_volume *lv);
 char *lv_mirror_log_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_modules_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_name_dup(struct dm_pool *mem, const struct logical_volume *lv);
+char *lv_origin_dup(struct dm_pool *mem, const struct logical_volume *lv);
 
 #endif
diff --git a/lib/report/properties.c b/lib/report/properties.c
index 8228193..250c7c9 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -121,7 +121,7 @@ GET_LV_NUM_PROPERTY_FN(lv_size, lv->size * SECTOR_SIZE)
 #define _lv_size_set _not_implemented_set
 GET_LV_NUM_PROPERTY_FN(seg_count, dm_list_size(&lv->segments))
 #define _seg_count_set _not_implemented_set
-#define _origin_get _not_implemented_get
+GET_LV_STR_PROPERTY_FN(origin, lv_origin_dup(lv->vg->vgmem, lv))
 #define _origin_set _not_implemented_set
 GET_LV_NUM_PROPERTY_FN(origin_size, lv_origin_size(lv))
 #define _origin_size_set _not_implemented_set
diff --git a/lib/report/report.c b/lib/report/report.c
index d155372..9d86b12 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -356,9 +356,10 @@ static int _origin_disp(struct dm_report *rh, struct dm_pool *mem,
 			const void *data, void *private)
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
+	const char *name;
 
-	if (lv_is_cow(lv))
-		return _lvname_disp(rh, mem, field, origin_from_cow(lv), private);
+	if ((name = lv_origin_dup(mem, lv)))
+		return dm_report_field_string(rh, field, &name);
 
 	dm_report_field_set_value(field, "", NULL);
 	return 1;
-- 
1.7.2.2


