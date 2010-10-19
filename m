From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 19 Oct 2010 07:32:50 -0400
Subject: [PATCH 3/8] Add lv_read_ahead and lv_kernel_read_ahead 'get' functions.
In-Reply-To: <1287487975-26572-1-git-send-email-dwysocha@redhat.com>
References: <1287487975-26572-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1287487975-26572-4-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/lv.c       |    9 +++++++++
 lib/metadata/lv.h       |    1 +
 lib/report/properties.c |    4 ++--
 lib/report/report.c     |    6 +++---
 4 files changed, 15 insertions(+), 5 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 9cd5bf8..b7a8700 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -20,6 +20,15 @@
 #include "segtype.h"
 #include "str_list.h"
 
+uint32_t lv_kernel_read_ahead(const struct logical_volume *lv)
+{
+	struct lvinfo info;
+
+	if (!lv_info(lv->vg->cmd, lv, 0, &info, 0, 1) || !info.exists)
+		return UINT32_MAX;
+	return info.read_ahead;
+}
+
 char *lv_origin_dup(struct dm_pool *mem, const struct logical_volume *lv)
 {
 	if (lv_is_cow(lv))
diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index 1767551..d77c362 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -62,5 +62,6 @@ char *lv_mirror_log_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_modules_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_name_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_origin_dup(struct dm_pool *mem, const struct logical_volume *lv);
+uint32_t lv_kernel_read_ahead(const struct logical_volume *lv);
 
 #endif
diff --git a/lib/report/properties.c b/lib/report/properties.c
index 250c7c9..587f11d 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -109,13 +109,13 @@ GET_LV_NUM_PROPERTY_FN(lv_major, lv->major)
 #define _lv_major_set _not_implemented_set
 GET_LV_NUM_PROPERTY_FN(lv_minor, lv->minor)
 #define _lv_minor_set _not_implemented_set
-#define _lv_read_ahead_get _not_implemented_get
+GET_LV_NUM_PROPERTY_FN(lv_read_ahead, lv->read_ahead * SECTOR_SIZE)
 #define _lv_read_ahead_set _not_implemented_set
 GET_LV_NUM_PROPERTY_FN(lv_kernel_major, lv_kernel_major(lv))
 #define _lv_kernel_major_set _not_implemented_set
 GET_LV_NUM_PROPERTY_FN(lv_kernel_minor, lv_kernel_minor(lv))
 #define _lv_kernel_minor_set _not_implemented_set
-#define _lv_kernel_read_ahead_get _not_implemented_get
+GET_LV_NUM_PROPERTY_FN(lv_kernel_read_ahead, lv_kernel_read_ahead(lv) * SECTOR_SIZE)
 #define _lv_kernel_read_ahead_set _not_implemented_set
 GET_LV_NUM_PROPERTY_FN(lv_size, lv->size * SECTOR_SIZE)
 #define _lv_size_set _not_implemented_set
diff --git a/lib/report/report.c b/lib/report/report.c
index 9d86b12..dbeef21 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -470,12 +470,12 @@ static int _lvkreadahead_disp(struct dm_report *rh, struct dm_pool *mem,
 			      void *private)
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
-	struct lvinfo info;
+	uint32_t read_ahead;
 
-	if (!lv_info(lv->vg->cmd, lv, 0, &info, 0, 1) || !info.exists)
+	if ((read_ahead = lv_kernel_read_ahead(lv)) == UINT32_MAX)
 		return dm_report_field_int32(rh, field, &_minusone32);
 
-	return _size32_disp(rh, mem, field, &info.read_ahead, private);
+	return _size32_disp(rh, mem, field, &read_ahead, private);
 }
 
 static int _vgsize_disp(struct dm_report *rh, struct dm_pool *mem,
-- 
1.7.2.2


