From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 11 Oct 2010 11:14:30 -0400
Subject: [PATCH 06/14] Refactor and add code for (lv) 'lv_kernel_{major|minor}' get functions.
In-Reply-To: <1286810078-25769-1-git-send-email-dwysocha@redhat.com>
References: <1286810078-25769-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1286810078-25769-7-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/lv.c       |   17 +++++++++++++++++
 lib/metadata/lv.h       |    2 ++
 lib/report/properties.c |    4 ++--
 lib/report/report.c     |   12 ++++++------
 4 files changed, 27 insertions(+), 8 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index fd6d36d..af2b418 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -18,6 +18,23 @@
 #include "activate.h"
 #include "toolcontext.h"
 
+int lv_kernel_minor(const struct logical_volume *lv)
+{
+	struct lvinfo info;
+
+	if (lv_info(lv->vg->cmd, lv, 0, &info, 0, 0) && info.exists)
+		return info.minor;
+	return -1;
+}
+
+int lv_kernel_major(const struct logical_volume *lv)
+{
+	struct lvinfo info;
+	if (lv_info(lv->vg->cmd, lv, 0, &info, 0, 0) && info.exists)
+		return info.major;
+	return -1;
+}
+
 char *lv_convert_lv_dup(struct dm_pool *mem, const struct logical_volume *lv)
 {
 	struct lv_segment *seg;
diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index 1ba932b..557f54a 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -56,5 +56,7 @@ char *lv_path_dup(struct dm_pool *mem, const struct logical_volume *lv);
 uint64_t lv_origin_size(const struct logical_volume *lv);
 char *lv_move_pv_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_convert_lv_dup(struct dm_pool *mem, const struct logical_volume *lv);
+int lv_kernel_major(const struct logical_volume *lv);
+int lv_kernel_minor(const struct logical_volume *lv);
 
 #endif
diff --git a/lib/report/properties.c b/lib/report/properties.c
index db02683..5e42014 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -111,9 +111,9 @@ GET_LV_NUM_PROPERTY_FN(lv_minor, lv->minor)
 #define _lv_minor_set _not_implemented_set
 #define _lv_read_ahead_get _not_implemented_get
 #define _lv_read_ahead_set _not_implemented_set
-#define _lv_kernel_major_get _not_implemented_get
+GET_LV_NUM_PROPERTY_FN(lv_kernel_major, lv_kernel_major(lv))
 #define _lv_kernel_major_set _not_implemented_set
-#define _lv_kernel_minor_get _not_implemented_get
+GET_LV_NUM_PROPERTY_FN(lv_kernel_minor, lv_kernel_minor(lv))
 #define _lv_kernel_minor_set _not_implemented_set
 #define _lv_kernel_read_ahead_get _not_implemented_get
 #define _lv_kernel_read_ahead_set _not_implemented_set
diff --git a/lib/report/report.c b/lib/report/report.c
index bb2d4ce..f3e3e41 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -212,10 +212,10 @@ static int _lvkmaj_disp(struct dm_report *rh, struct dm_pool *mem __attribute__(
 			const void *data, void *private __attribute__((unused)))
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
-	struct lvinfo info;
+	int major;
 
-	if (lv_info(lv->vg->cmd, lv, 0, &info, 0, 0) && info.exists)
-		return dm_report_field_int(rh, field, &info.major);
+	if ((major = lv_kernel_major(lv)) >= 0)
+		return dm_report_field_int(rh, field, &major);
 
 	return dm_report_field_int32(rh, field, &_minusone32);
 }
@@ -225,10 +225,10 @@ static int _lvkmin_disp(struct dm_report *rh, struct dm_pool *mem __attribute__(
 			const void *data, void *private __attribute__((unused)))
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
-	struct lvinfo info;
+	int minor;
 
-	if (lv_info(lv->vg->cmd, lv, 0, &info, 0, 0) && info.exists)
-		return dm_report_field_int(rh, field, &info.minor);
+	if ((minor = lv_kernel_minor(lv)) >= 0)
+		return dm_report_field_int(rh, field, &minor);
 
 	return dm_report_field_int32(rh, field, &_minusone32);
 }
-- 
1.7.2.2


