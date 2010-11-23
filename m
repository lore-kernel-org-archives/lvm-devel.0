From: Dave Wysochanski <wysochanski@pobox.com>
Date: Mon, 22 Nov 2010 22:07:45 -0500
Subject: [PATCH 2/3] Move _format_pvsegs to lv.c and export lvseg_devices and lvseg_seg_pe_ranges.
In-Reply-To: <1290481666-11149-1-git-send-email-wysochanski@pobox.com>
References: <1290481666-11149-1-git-send-email-wysochanski@pobox.com>
Message-ID: <1290481666-11149-3-git-send-email-wysochanski@pobox.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Export two new functions to cover lvseg 'devices' and 'seg_pe_ranges'.
Call the new functions from the reporting infrastructure as well as
lvm2app properties functions.

Signed-off-by: Dave Wysochanski <wysochanski@pobox.com>
---
 lib/metadata/lv.c       |   82 +++++++++++++++++++++++++++++++++++++++++++++++
 lib/metadata/lv.h       |    2 +
 lib/report/properties.c |    5 ++-
 lib/report/report.c     |   76 +------------------------------------------
 4 files changed, 89 insertions(+), 76 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index df132fe..e7060ea 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -21,6 +21,88 @@
 #include "segtype.h"
 #include "str_list.h"
 
+static char *_format_pvsegs(struct dm_pool *mem, const struct lv_segment *seg,
+			     int range_format)
+{
+	unsigned int s;
+	const char *name = NULL;
+	uint32_t extent = 0;
+	char extent_str[32];
+
+	if (!dm_pool_begin_object(mem, 256)) {
+		log_error("dm_pool_begin_object failed");
+		return NULL;
+	}
+
+	for (s = 0; s < seg->area_count; s++) {
+		switch (seg_type(seg, s)) {
+		case AREA_LV:
+			name = seg_lv(seg, s)->name;
+			extent = seg_le(seg, s);
+			break;
+		case AREA_PV:
+			name = dev_name(seg_dev(seg, s));
+			extent = seg_pe(seg, s);
+			break;
+		case AREA_UNASSIGNED:
+			name = "unassigned";
+			extent = 0;
+		}
+
+		if (!dm_pool_grow_object(mem, name, strlen(name))) {
+			log_error("dm_pool_grow_object failed");
+			return NULL;
+		}
+
+		if (dm_snprintf(extent_str, sizeof(extent_str),
+				"%s%" PRIu32 "%s",
+				range_format ? ":" : "(", extent,
+				range_format ? "-"  : ")") < 0) {
+			log_error("Extent number dm_snprintf failed");
+			return NULL;
+		}
+		if (!dm_pool_grow_object(mem, extent_str, strlen(extent_str))) {
+			log_error("dm_pool_grow_object failed");
+			return NULL;
+		}
+
+		if (range_format) {
+			if (dm_snprintf(extent_str, sizeof(extent_str),
+					"%" PRIu32, extent + seg->area_len - 1) < 0) {
+				log_error("Extent number dm_snprintf failed");
+				return NULL;
+			}
+			if (!dm_pool_grow_object(mem, extent_str, strlen(extent_str))) {
+				log_error("dm_pool_grow_object failed");
+				return NULL;
+			}
+		}
+
+		if ((s != seg->area_count - 1) &&
+		    !dm_pool_grow_object(mem, range_format ? " " : ",", 1)) {
+			log_error("dm_pool_grow_object failed");
+			return NULL;
+		}
+	}
+
+	if (!dm_pool_grow_object(mem, "\0", 1)) {
+		log_error("dm_pool_grow_object failed");
+		return NULL;
+	}
+
+	return dm_pool_end_object(mem);
+}
+
+char *lvseg_devices(struct dm_pool *mem, const struct lv_segment *seg)
+{
+	return _format_pvsegs(mem, seg, 0);
+}
+
+char *lvseg_seg_pe_ranges(struct dm_pool *mem, const struct lv_segment *seg)
+{
+	return _format_pvsegs(mem, seg, 1);
+}
+
 char *lvseg_tags_dup(const struct lv_segment *seg)
 {
 	return tags_format_and_copy(seg->lv->vg->vgmem, &seg->tags);
diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index bff36d2..c3509f5 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -68,5 +68,7 @@ uint64_t lvseg_size(const struct lv_segment *seg);
 uint64_t lvseg_chunksize(const struct lv_segment *seg);
 char *lvseg_segtype_dup(const struct lv_segment *seg);
 char *lvseg_tags_dup(const struct lv_segment *seg);
+char *lvseg_devices(struct dm_pool *mem, const struct lv_segment *seg);
+char *lvseg_seg_pe_ranges(struct dm_pool *mem, const struct lv_segment *seg);
 
 #endif /* _LVM_LV_H */
diff --git a/lib/report/properties.c b/lib/report/properties.c
index b93f419..967c00e 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -234,9 +234,10 @@ GET_LVSEG_NUM_PROPERTY_FN(seg_size, lvseg_size(lvseg))
 #define _seg_size_set _not_implemented_set
 GET_LVSEG_STR_PROPERTY_FN(seg_tags, lvseg_tags_dup(lvseg))
 #define _seg_tags_set _not_implemented_set
-#define _seg_pe_ranges_get _not_implemented_get
+GET_LVSEG_STR_PROPERTY_FN(seg_pe_ranges,
+			  lvseg_seg_pe_ranges(lvseg->lv->vg->vgmem, lvseg))
 #define _seg_pe_ranges_set _not_implemented_set
-#define _devices_get _not_implemented_get
+GET_LVSEG_STR_PROPERTY_FN(devices, lvseg_devices(lvseg->lv->vg->vgmem, lvseg))
 #define _devices_set _not_implemented_set
 
 
diff --git a/lib/report/report.c b/lib/report/report.c
index 83550fe..20302ac 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -56,84 +56,12 @@ static int _dev_name_disp(struct dm_report *rh, struct dm_pool *mem __attribute_
 	return dm_report_field_string(rh, field, &name);
 }
 
-static char *_format_pvsegs(struct dm_pool *mem, const struct lv_segment *seg,
-			     int range_format)
-{
-	unsigned int s;
-	const char *name = NULL;
-	uint32_t extent = 0;
-	char extent_str[32];
-
-	if (!dm_pool_begin_object(mem, 256)) {
-		log_error("dm_pool_begin_object failed");
-		return NULL;
-	}
-
-	for (s = 0; s < seg->area_count; s++) {
-		switch (seg_type(seg, s)) {
-		case AREA_LV:
-			name = seg_lv(seg, s)->name;
-			extent = seg_le(seg, s);
-			break;
-		case AREA_PV:
-			name = dev_name(seg_dev(seg, s));
-			extent = seg_pe(seg, s);
-			break;
-		case AREA_UNASSIGNED:
-			name = "unassigned";
-			extent = 0;
-		}
-
-		if (!dm_pool_grow_object(mem, name, strlen(name))) {
-			log_error("dm_pool_grow_object failed");
-			return NULL;
-		}
-
-		if (dm_snprintf(extent_str, sizeof(extent_str),
-				"%s%" PRIu32 "%s",
-				range_format ? ":" : "(", extent,
-				range_format ? "-"  : ")") < 0) {
-			log_error("Extent number dm_snprintf failed");
-			return NULL;
-		}
-		if (!dm_pool_grow_object(mem, extent_str, strlen(extent_str))) {
-			log_error("dm_pool_grow_object failed");
-			return NULL;
-		}
-
-		if (range_format) {
-			if (dm_snprintf(extent_str, sizeof(extent_str),
-					"%" PRIu32, extent + seg->area_len - 1) < 0) {
-				log_error("Extent number dm_snprintf failed");
-				return NULL;
-			}
-			if (!dm_pool_grow_object(mem, extent_str, strlen(extent_str))) {
-				log_error("dm_pool_grow_object failed");
-				return NULL;
-			}
-		}
-
-		if ((s != seg->area_count - 1) &&
-		    !dm_pool_grow_object(mem, range_format ? " " : ",", 1)) {
-			log_error("dm_pool_grow_object failed");
-			return NULL;
-		}
-	}
-
-	if (!dm_pool_grow_object(mem, "\0", 1)) {
-		log_error("dm_pool_grow_object failed");
-		return NULL;
-	}
-
-	return dm_pool_end_object(mem);
-}
-
 static int _devices_disp(struct dm_report *rh __attribute__((unused)), struct dm_pool *mem,
 			 struct dm_report_field *field,
 			 const void *data, void *private __attribute__((unused)))
 {
 	char *str;
-	if (!(str = _format_pvsegs(mem, (const struct lv_segment *) data, 0)))
+	if (!(str = lvseg_devices(mem, (const struct lv_segment *) data)))
 		return 0;
 
 	dm_report_field_set_value(field, str, NULL);
@@ -146,7 +74,7 @@ static int _peranges_disp(struct dm_report *rh __attribute__((unused)), struct d
 			  const void *data, void *private __attribute__((unused)))
 {
 	char *str;
-	if (!(str = _format_pvsegs(mem, (const struct lv_segment *) data, 1)))
+	if (!(str = lvseg_seg_pe_ranges(mem, (const struct lv_segment *) data)))
 		return 0;
 
 	dm_report_field_set_value(field, str, NULL);
-- 
1.7.2.2


