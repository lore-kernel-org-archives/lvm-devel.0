From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 11 Oct 2010 11:14:27 -0400
Subject: [PATCH 03/14] Refactor and add code for (lv) 'origin_size' get function.
In-Reply-To: <1286810078-25769-1-git-send-email-dwysocha@redhat.com>
References: <1286810078-25769-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1286810078-25769-4-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/lv.c       |   13 +++++++++++++
 lib/metadata/lv.h       |    1 +
 lib/report/properties.c |    2 +-
 lib/report/report.c     |    7 +------
 4 files changed, 16 insertions(+), 7 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index f750f54..ae8a4fb 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -18,6 +18,19 @@
 #include "activate.h"
 #include "toolcontext.h"
 
+uint64_t lv_origin_size(const struct logical_volume *lv)
+{
+	uint64_t size;
+
+	if (lv_is_cow(lv))
+		size = (uint64_t) find_cow(lv)->len * lv->vg->extent_size;
+	else if (lv_is_origin(lv))
+		size = lv->size;
+	else
+		size = UINT64_C(0);
+	return size;
+}
+
 char *lv_path_dup(struct dm_pool *mem, const struct logical_volume *lv)
 {
 	char *repstr;
diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index eee2811..69c4077 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -53,5 +53,6 @@ char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_uuid_dup(const struct logical_volume *lv);
 char *lv_tags_dup(const struct logical_volume *lv);
 char *lv_path_dup(struct dm_pool *mem, const struct logical_volume *lv);
+uint64_t lv_origin_size(const struct logical_volume *lv);
 
 #endif
diff --git a/lib/report/properties.c b/lib/report/properties.c
index 8890e27..27503a9 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -123,7 +123,7 @@ GET_LV_NUM_PROPERTY_FN(seg_count, dm_list_size(&lv->segments))
 #define _seg_count_set _not_implemented_set
 #define _origin_get _not_implemented_get
 #define _origin_set _not_implemented_set
-#define _origin_size_get _not_implemented_get
+GET_LV_NUM_PROPERTY_FN(origin_size, lv_origin_size(lv))
 #define _origin_size_set _not_implemented_set
 #define _snap_percent_get _not_implemented_get
 #define _snap_percent_set _not_implemented_set
diff --git a/lib/report/report.c b/lib/report/report.c
index 32559b8..83216b2 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -570,12 +570,7 @@ static int _originsize_disp(struct dm_report *rh, struct dm_pool *mem,
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 	uint64_t size;
 
-	if (lv_is_cow(lv))
-		size = (uint64_t) find_cow(lv)->len * lv->vg->extent_size;
-	else if (lv_is_origin(lv))
-		size = lv->size;
-	else
-		size = UINT64_C(0);
+	size = lv_origin_size(lv);
 
 	return _size64_disp(rh, mem, field, &size, private);
 }
-- 
1.7.2.2


