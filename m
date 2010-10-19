From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 19 Oct 2010 09:24:54 -0400
Subject: [PATCH 2/4] Add lvseg 'get' functions.
In-Reply-To: <1287494696-18310-1-git-send-email-dwysocha@redhat.com>
References: <1287494696-18310-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1287494696-18310-3-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/lv.c       |   35 +++++++++++++++++++++++++++++++++++
 lib/metadata/lv.h       |    5 +++++
 lib/report/properties.c |   34 ++++++++++++++++++++++------------
 lib/report/properties.h |    2 ++
 lib/report/report.c     |   18 ++++++------------
 5 files changed, 70 insertions(+), 24 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index b7a8700..eca046f 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -20,6 +20,41 @@
 #include "segtype.h"
 #include "str_list.h"
 
+char *lvseg_tags_dup(const struct lv_segment *seg)
+{
+	return tags_format_and_copy(seg->lv->vg->vgmem, &seg->tags);
+}
+
+char *lvseg_segtype_dup(const struct lv_segment *seg)
+{
+	if (seg->area_count == 1) {
+		return (char *)"linear";
+	}
+
+	return dm_pool_strdup(seg->lv->vg->vgmem, seg->segtype->ops->name(seg));
+}
+
+uint64_t lvseg_chunksize(const struct lv_segment *seg)
+{
+	uint64_t size;
+
+	if (lv_is_cow(seg->lv))
+		size = (uint64_t) find_cow(seg->lv)->chunk_size;
+	else
+		size = UINT64_C(0);
+	return size;
+}
+
+uint64_t lvseg_start(const struct lv_segment *seg)
+{
+	return (uint64_t) seg->le * seg->lv->vg->extent_size;
+}
+
+uint64_t lvseg_size(const struct lv_segment *seg)
+{
+	return (uint64_t) seg->len * seg->lv->vg->extent_size;
+}
+
 uint32_t lv_kernel_read_ahead(const struct logical_volume *lv)
 {
 	struct lvinfo info;
diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index d77c362..afe6da0 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -63,5 +63,10 @@ char *lv_modules_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_name_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_origin_dup(struct dm_pool *mem, const struct logical_volume *lv);
 uint32_t lv_kernel_read_ahead(const struct logical_volume *lv);
+uint64_t lvseg_start(const struct lv_segment *seg);
+uint64_t lvseg_size(const struct lv_segment *seg);
+uint64_t lvseg_chunksize(const struct lv_segment *seg);
+char *lvseg_segtype_dup(const struct lv_segment *seg);
+char *lvseg_tags_dup(const struct lv_segment *seg);
 
 #endif
diff --git a/lib/report/properties.c b/lib/report/properties.c
index c08ddfd..c3315b9 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -34,6 +34,8 @@ static int _ ## NAME ## _get (const void *obj, struct lvm_property_type *prop) \
 	GET_NUM_PROPERTY_FN(NAME, VALUE, physical_volume, pv)
 #define GET_LV_NUM_PROPERTY_FN(NAME, VALUE) \
 	GET_NUM_PROPERTY_FN(NAME, VALUE, logical_volume, lv)
+#define GET_LVSEG_NUM_PROPERTY_FN(NAME, VALUE) \
+	GET_NUM_PROPERTY_FN(NAME, VALUE, lv_segment, lvseg)
 
 #define GET_STR_PROPERTY_FN(NAME, VALUE, TYPE, VAR)			\
 static int _ ## NAME ## _get (const void *obj, struct lvm_property_type *prop) \
@@ -49,6 +51,8 @@ static int _ ## NAME ## _get (const void *obj, struct lvm_property_type *prop) \
 	GET_STR_PROPERTY_FN(NAME, VALUE, physical_volume, pv)
 #define GET_LV_STR_PROPERTY_FN(NAME, VALUE) \
 	GET_STR_PROPERTY_FN(NAME, VALUE, logical_volume, lv)
+#define GET_LVSEG_STR_PROPERTY_FN(NAME, VALUE) \
+	GET_STR_PROPERTY_FN(NAME, VALUE, lv_segment, lvseg)
 
 static int _not_implemented_get(const void *obj, struct lvm_property_type *prop)
 {
@@ -187,29 +191,29 @@ GET_VG_NUM_PROPERTY_FN(vg_mda_copies, (vg_mda_copies(vg)))
 #define _vg_mda_copies_set _not_implemented_set
 
 /* LVSEG */
-#define _segtype_get _not_implemented_get
+GET_LVSEG_STR_PROPERTY_FN(segtype, lvseg_segtype_dup(lvseg))
 #define _segtype_set _not_implemented_set
-#define _stripes_get _not_implemented_get
+GET_LVSEG_NUM_PROPERTY_FN(stripes, lvseg->area_count)
 #define _stripes_set _not_implemented_set
-#define _stripesize_get _not_implemented_get
+GET_LVSEG_NUM_PROPERTY_FN(stripesize, lvseg->stripe_size)
 #define _stripesize_set _not_implemented_set
-#define _stripe_size_get _not_implemented_get
+GET_LVSEG_NUM_PROPERTY_FN(stripe_size, lvseg->stripe_size)
 #define _stripe_size_set _not_implemented_set
-#define _regionsize_get _not_implemented_get
+GET_LVSEG_NUM_PROPERTY_FN(regionsize, lvseg->region_size)
 #define _regionsize_set _not_implemented_set
-#define _region_size_get _not_implemented_get
+GET_LVSEG_NUM_PROPERTY_FN(region_size, lvseg->region_size)
 #define _region_size_set _not_implemented_set
-#define _chunksize_get _not_implemented_get
+GET_LVSEG_NUM_PROPERTY_FN(chunksize, lvseg_chunksize(lvseg))
 #define _chunksize_set _not_implemented_set
-#define _chunk_size_get _not_implemented_get
+GET_LVSEG_NUM_PROPERTY_FN(chunk_size, lvseg_chunksize(lvseg))
 #define _chunk_size_set _not_implemented_set
-#define _seg_start_get _not_implemented_get
+GET_LVSEG_NUM_PROPERTY_FN(seg_start, lvseg_start(lvseg))
 #define _seg_start_set _not_implemented_set
-#define _seg_start_pe_get _not_implemented_get
+GET_LVSEG_NUM_PROPERTY_FN(seg_start_pe, lvseg->le)
 #define _seg_start_pe_set _not_implemented_set
-#define _seg_size_get _not_implemented_get
+GET_LVSEG_NUM_PROPERTY_FN(seg_size, lvseg_size(lvseg))
 #define _seg_size_set _not_implemented_set
-#define _seg_tags_get _not_implemented_get
+GET_LVSEG_STR_PROPERTY_FN(seg_tags, lvseg_tags_dup(lvseg))
 #define _seg_tags_set _not_implemented_set
 #define _seg_pe_ranges_get _not_implemented_get
 #define _seg_pe_ranges_set _not_implemented_set
@@ -267,6 +271,12 @@ static int _get_property(const void *obj, struct lvm_property_type *prop,
 	return 1;
 }
 
+int lvseg_get_property(const struct lv_segment *lvseg,
+		       struct lvm_property_type *prop)
+{
+	return _get_property(lvseg, prop, SEGS);
+}
+
 int lv_get_property(const struct logical_volume *lv,
 		    struct lvm_property_type *prop)
 {
diff --git a/lib/report/properties.h b/lib/report/properties.h
index 18e5ab9..68d387f 100644
--- a/lib/report/properties.h
+++ b/lib/report/properties.h
@@ -32,6 +32,8 @@ struct lvm_property_type {
 	int (*set) (void *obj, struct lvm_property_type *prop);
 };
 
+int lvseg_get_property(const struct lv_segment *lvseg,
+		       struct lvm_property_type *prop);
 int lv_get_property(const struct logical_volume *lv,
 		    struct lvm_property_type *prop);
 int vg_get_property(const struct volume_group *vg,
diff --git a/lib/report/report.c b/lib/report/report.c
index dbeef21..c7f141f 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -279,12 +279,9 @@ static int _segtype_disp(struct dm_report *rh __attribute__((unused)),
 {
 	const struct lv_segment *seg = (const struct lv_segment *) data;
 
-	if (seg->area_count == 1) {
-		dm_report_field_set_value(field, "linear", NULL);
-		return 1;
-	}
-
-	dm_report_field_set_value(field, seg->segtype->ops->name(seg), NULL);
+	char *name;
+	name = lvseg_segtype_dup(seg);
+	dm_report_field_set_value(field, name, NULL);
 	return 1;
 }
 
@@ -497,7 +494,7 @@ static int _segstart_disp(struct dm_report *rh, struct dm_pool *mem,
 	const struct lv_segment *seg = (const struct lv_segment *) data;
 	uint64_t start;
 
-	start = (uint64_t) seg->le * seg->lv->vg->extent_size;
+	start = lvseg_start(seg);
 
 	return _size64_disp(rh, mem, field, &start, private);
 }
@@ -520,7 +517,7 @@ static int _segsize_disp(struct dm_report *rh, struct dm_pool *mem,
 	const struct lv_segment *seg = (const struct lv_segment *) data;
 	uint64_t size;
 
-	size = (uint64_t) seg->len * seg->lv->vg->extent_size;
+	size = lvseg_size(seg);
 
 	return _size64_disp(rh, mem, field, &size, private);
 }
@@ -532,10 +529,7 @@ static int _chunksize_disp(struct dm_report *rh, struct dm_pool *mem,
 	const struct lv_segment *seg = (const struct lv_segment *) data;
 	uint64_t size;
 
-	if (lv_is_cow(seg->lv))
-		size = (uint64_t) find_cow(seg->lv)->chunk_size;
-	else
-		size = UINT64_C(0);
+	size = lvseg_chunksize(seg);
 
 	return _size64_disp(rh, mem, field, &size, private);
 }
-- 
1.7.2.2


