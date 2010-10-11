From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 11 Oct 2010 11:14:26 -0400
Subject: [PATCH 02/14] Refactor and add code for (lv) 'lv_path' get function.
In-Reply-To: <1286810078-25769-1-git-send-email-dwysocha@redhat.com>
References: <1286810078-25769-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1286810078-25769-3-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/lv.c       |   21 +++++++++++++++++++++
 lib/metadata/lv.h       |    1 +
 lib/report/properties.c |    2 +-
 lib/report/report.c     |   11 +----------
 4 files changed, 24 insertions(+), 11 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index add0a4d..f750f54 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -16,6 +16,27 @@
 #include "lib.h"
 #include "metadata.h"
 #include "activate.h"
+#include "toolcontext.h"
+
+char *lv_path_dup(struct dm_pool *mem, const struct logical_volume *lv)
+{
+	char *repstr;
+	size_t len;
+
+	len = strlen(lv->vg->cmd->dev_dir);
+	len += strlen(lv->vg->name) + strlen(lv->name) + 2;
+	if (!(repstr = dm_pool_zalloc(mem, len))) {
+		log_error("dm_pool_alloc failed");
+		return 0;
+	}
+
+	if (dm_snprintf(repstr, len, "%s%s/%s",
+			lv->vg->cmd->dev_dir, lv->vg->name, lv->name) < 0) {
+		log_error("lvpath snprintf failed");
+		return 0;
+	}
+	return repstr;
+}
 
 char *lv_uuid_dup(const struct logical_volume *lv)
 {
diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index 54ed7e0..eee2811 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -52,5 +52,6 @@ uint64_t lv_size(const struct logical_volume *lv);
 char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_uuid_dup(const struct logical_volume *lv);
 char *lv_tags_dup(const struct logical_volume *lv);
+char *lv_path_dup(struct dm_pool *mem, const struct logical_volume *lv);
 
 #endif
diff --git a/lib/report/properties.c b/lib/report/properties.c
index eec4c61..8890e27 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -101,7 +101,7 @@ GET_LV_STR_PROPERTY_FN(lv_uuid, lv_uuid_dup(lv))
 #define _lv_uuid_set _not_implemented_set
 #define _lv_name_get _not_implemented_get
 #define _lv_name_set _not_implemented_set
-#define _lv_path_get _not_implemented_get
+GET_LV_STR_PROPERTY_FN(lv_path, lv_path_dup(lv->vg->vgmem, lv))
 #define _lv_path_set _not_implemented_set
 GET_LV_STR_PROPERTY_FN(lv_attr, lv_attr_dup(lv->vg->vgmem, lv))
 #define _lv_attr_set _not_implemented_set
diff --git a/lib/report/report.c b/lib/report/report.c
index 95f4550..32559b8 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -350,18 +350,9 @@ static int _lvpath_disp(struct dm_report *rh, struct dm_pool *mem,
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 	char *repstr;
-	size_t len;
 
-	len = strlen(lv->vg->cmd->dev_dir) + strlen(lv->vg->name) + strlen(lv->name) + 2;
-	if (!(repstr = dm_pool_zalloc(mem, len))) {
-		log_error("dm_pool_alloc failed");
+	if (!(repstr = lv_path_dup(mem, lv)))
 		return 0;
-	}
-
-	if (dm_snprintf(repstr, len, "%s%s/%s", lv->vg->cmd->dev_dir, lv->vg->name, lv->name) < 0) {
-		log_error("lvpath snprintf failed");
-		return 0;
-	}
 
 	dm_report_field_set_value(field, repstr, NULL);
 
-- 
1.7.2.2


