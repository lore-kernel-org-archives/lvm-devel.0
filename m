From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 11 Oct 2010 11:14:32 -0400
Subject: [PATCH 08/14] Refactor and add code for (lv) 'modules' get function.
In-Reply-To: <1286810078-25769-1-git-send-email-dwysocha@redhat.com>
References: <1286810078-25769-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1286810078-25769-9-git-send-email-dwysocha@redhat.com>
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
 lib/report/report.c     |   12 ++++--------
 4 files changed, 21 insertions(+), 9 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 4fad293..329a3be 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -18,6 +18,21 @@
 #include "activate.h"
 #include "toolcontext.h"
 #include "segtype.h"
+#include "str_list.h"
+
+char *lv_modules_dup(struct dm_pool *mem, const struct logical_volume *lv)
+{
+	struct dm_list *modules;
+
+	if (!(modules = str_list_create(mem))) {
+		log_error("modules str_list allocation failed");
+		return NULL;
+	}
+
+	if (!list_lv_modules(mem, lv, modules))
+		return_NULL;
+	return tags_format_and_copy(lv->vg->vgmem, modules);
+}
 
 char *lv_mirror_log_dup(struct dm_pool *mem, const struct logical_volume *lv)
 {
diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index 8d069af..2f0ebee 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -59,5 +59,6 @@ char *lv_convert_lv_dup(struct dm_pool *mem, const struct logical_volume *lv);
 int lv_kernel_major(const struct logical_volume *lv);
 int lv_kernel_minor(const struct logical_volume *lv);
 char *lv_mirror_log_dup(struct dm_pool *mem, const struct logical_volume *lv);
+char *lv_modules_dup(struct dm_pool *mem, const struct logical_volume *lv);
 
 #endif
diff --git a/lib/report/properties.c b/lib/report/properties.c
index eba2b59..ce1d2f7 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -137,7 +137,7 @@ GET_LV_STR_PROPERTY_FN(lv_tags, lv_tags_dup(lv))
 #define _lv_tags_set _not_implemented_set
 GET_LV_STR_PROPERTY_FN(mirror_log, lv_mirror_log_dup(lv->vg->vgmem, lv))
 #define _mirror_log_set _not_implemented_set
-#define _modules_get _not_implemented_get
+GET_LV_STR_PROPERTY_FN(modules, lv_modules_dup(lv->vg->vgmem, lv))
 #define _modules_set _not_implemented_set
 
 /* VG */
diff --git a/lib/report/report.c b/lib/report/report.c
index 65becaf..012659e 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -165,17 +165,13 @@ static int _modules_disp(struct dm_report *rh, struct dm_pool *mem,
 			 const void *data, void *private)
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
-	struct dm_list *modules;
+	char *modules_str;
 
-	if (!(modules = str_list_create(mem))) {
-		log_error("modules str_list allocation failed");
+	if (!(modules_str = lv_modules_dup(mem, lv)))
 		return 0;
-	}
-
-	if (!list_lv_modules(mem, lv, modules))
-		return_0;
 
-	return _tags_disp(rh, mem, field, modules, private);
+	dm_report_field_set_value(field, modules_str, NULL);
+	return 1;
 }
 
 static int _vgfmt_disp(struct dm_report *rh, struct dm_pool *mem,
-- 
1.7.2.2


