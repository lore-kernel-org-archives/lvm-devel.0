From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 11 Oct 2010 11:14:33 -0400
Subject: [PATCH 09/14] Refactor and add code for (lv) 'lv_name' get function.
In-Reply-To: <1286810078-25769-1-git-send-email-dwysocha@redhat.com>
References: <1286810078-25769-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1286810078-25769-10-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/lv.c       |   27 +++++++++++++++++++++++++++
 lib/metadata/lv.h       |    1 +
 lib/report/properties.c |    2 +-
 lib/report/report.c     |   28 +++++-----------------------
 4 files changed, 34 insertions(+), 24 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 329a3be..63851f6 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -20,6 +20,33 @@
 #include "segtype.h"
 #include "str_list.h"
 
+char *lv_name_dup(struct dm_pool *mem, const struct logical_volume *lv)
+{
+	char *repstr, *lvname;
+	size_t len;
+
+	if (lv_is_visible(lv)) {
+		goto dup;
+	}
+
+	len = strlen(lv->name) + 3;
+	if (!(repstr = dm_pool_zalloc(mem, len))) {
+		log_error("dm_pool_alloc failed");
+		return NULL;
+	}
+
+	if (dm_snprintf(repstr, len, "[%s]", lv->name) < 0) {
+		log_error("lvname snprintf failed");
+		return NULL;
+	}
+dup:
+	if (!(lvname = dm_pool_strdup(mem, lv->name))) {
+		log_error("dm_pool_strdup failed");
+		return NULL;
+	}
+	return lvname;
+}
+
 char *lv_modules_dup(struct dm_pool *mem, const struct logical_volume *lv)
 {
 	struct dm_list *modules;
diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index 2f0ebee..f80d2d5 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -60,5 +60,6 @@ int lv_kernel_major(const struct logical_volume *lv);
 int lv_kernel_minor(const struct logical_volume *lv);
 char *lv_mirror_log_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_modules_dup(struct dm_pool *mem, const struct logical_volume *lv);
+char *lv_name_dup(struct dm_pool *mem, const struct logical_volume *lv);
 
 #endif
diff --git a/lib/report/properties.c b/lib/report/properties.c
index ce1d2f7..8228193 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -99,7 +99,7 @@ GET_PV_NUM_PROPERTY_FN(pv_mda_used_count, pv_mda_used_count(pv))
 /* LV */
 GET_LV_STR_PROPERTY_FN(lv_uuid, lv_uuid_dup(lv))
 #define _lv_uuid_set _not_implemented_set
-#define _lv_name_get _not_implemented_get
+GET_LV_STR_PROPERTY_FN(lv_name, lv_name_dup(lv->vg->vgmem, lv))
 #define _lv_name_set _not_implemented_set
 GET_LV_STR_PROPERTY_FN(lv_path, lv_path_dup(lv->vg->vgmem, lv))
 #define _lv_path_set _not_implemented_set
diff --git a/lib/report/report.c b/lib/report/report.c
index 012659e..ffca851 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -308,31 +308,13 @@ static int _lvname_disp(struct dm_report *rh, struct dm_pool *mem,
 			const void *data, void *private __attribute__((unused)))
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
-	char *repstr, *lvname;
-	size_t len;
-
-	if (lv_is_visible(lv)) {
-		repstr = lv->name;
-		return dm_report_field_string(rh, field, (const char **) &repstr);
-	}
-
-	len = strlen(lv->name) + 3;
-	if (!(repstr = dm_pool_zalloc(mem, len))) {
-		log_error("dm_pool_alloc failed");
-		return 0;
-	}
-
-	if (dm_snprintf(repstr, len, "[%s]", lv->name) < 0) {
-		log_error("lvname snprintf failed");
-		return 0;
-	}
+	const char *name;
 
-	if (!(lvname = dm_pool_strdup(mem, lv->name))) {
-		log_error("dm_pool_strdup failed");
-		return 0;
-	}
+	name = lv_name_dup(mem, lv);
+	if (name)
+		return dm_report_field_string(rh, field, &name);
 
-	dm_report_field_set_value(field, repstr, lvname);
+	dm_report_field_set_value(field, "", NULL);
 
 	return 1;
 }
-- 
1.7.2.2


