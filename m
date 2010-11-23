From: Dave Wysochanski <wysochanski@pobox.com>
Date: Mon, 22 Nov 2010 22:07:44 -0500
Subject: [PATCH 1/3] Refactor _format_pvsegs to allow for re-use in lvm2app.
In-Reply-To: <1290481666-11149-1-git-send-email-wysochanski@pobox.com>
References: <1290481666-11149-1-git-send-email-wysochanski@pobox.com>
Message-ID: <1290481666-11149-2-git-send-email-wysochanski@pobox.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Refactor _format_pvsegs to allow for re-use in lvm2app for 'devices'
and 'seg_pe_ranges' fields of lv_segments.

Should be no functional change.

Signed-off-by: Dave Wysochanski <wysochanski@pobox.com>
---
 lib/report/report.c |   41 +++++++++++++++++++++++++----------------
 1 files changed, 25 insertions(+), 16 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index 837ef0b..83550fe 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -56,10 +56,9 @@ static int _dev_name_disp(struct dm_report *rh, struct dm_pool *mem __attribute_
 	return dm_report_field_string(rh, field, &name);
 }
 
-static int _format_pvsegs(struct dm_pool *mem, struct dm_report_field *field,
-			  const void *data, int range_format)
+static char *_format_pvsegs(struct dm_pool *mem, const struct lv_segment *seg,
+			     int range_format)
 {
-	const struct lv_segment *seg = (const struct lv_segment *) data;
 	unsigned int s;
 	const char *name = NULL;
 	uint32_t extent = 0;
@@ -67,7 +66,7 @@ static int _format_pvsegs(struct dm_pool *mem, struct dm_report_field *field,
 
 	if (!dm_pool_begin_object(mem, 256)) {
 		log_error("dm_pool_begin_object failed");
-		return 0;
+		return NULL;
 	}
 
 	for (s = 0; s < seg->area_count; s++) {
@@ -87,7 +86,7 @@ static int _format_pvsegs(struct dm_pool *mem, struct dm_report_field *field,
 
 		if (!dm_pool_grow_object(mem, name, strlen(name))) {
 			log_error("dm_pool_grow_object failed");
-			return 0;
+			return NULL;
 		}
 
 		if (dm_snprintf(extent_str, sizeof(extent_str),
@@ -95,54 +94,64 @@ static int _format_pvsegs(struct dm_pool *mem, struct dm_report_field *field,
 				range_format ? ":" : "(", extent,
 				range_format ? "-"  : ")") < 0) {
 			log_error("Extent number dm_snprintf failed");
-			return 0;
+			return NULL;
 		}
 		if (!dm_pool_grow_object(mem, extent_str, strlen(extent_str))) {
 			log_error("dm_pool_grow_object failed");
-			return 0;
+			return NULL;
 		}
 
 		if (range_format) {
 			if (dm_snprintf(extent_str, sizeof(extent_str),
 					"%" PRIu32, extent + seg->area_len - 1) < 0) {
 				log_error("Extent number dm_snprintf failed");
-				return 0;
+				return NULL;
 			}
 			if (!dm_pool_grow_object(mem, extent_str, strlen(extent_str))) {
 				log_error("dm_pool_grow_object failed");
-				return 0;
+				return NULL;
 			}
 		}
 
 		if ((s != seg->area_count - 1) &&
 		    !dm_pool_grow_object(mem, range_format ? " " : ",", 1)) {
 			log_error("dm_pool_grow_object failed");
-			return 0;
+			return NULL;
 		}
 	}
 
 	if (!dm_pool_grow_object(mem, "\0", 1)) {
 		log_error("dm_pool_grow_object failed");
-		return 0;
+		return NULL;
 	}
 
-	dm_report_field_set_value(field, dm_pool_end_object(mem), NULL);
-
-	return 1;
+	return dm_pool_end_object(mem);
 }
 
 static int _devices_disp(struct dm_report *rh __attribute__((unused)), struct dm_pool *mem,
 			 struct dm_report_field *field,
 			 const void *data, void *private __attribute__((unused)))
 {
-	return _format_pvsegs(mem, field, data, 0);
+	char *str;
+	if (!(str = _format_pvsegs(mem, (const struct lv_segment *) data, 0)))
+		return 0;
+
+	dm_report_field_set_value(field, str, NULL);
+
+	return 1;
 }
 
 static int _peranges_disp(struct dm_report *rh __attribute__((unused)), struct dm_pool *mem,
 			  struct dm_report_field *field,
 			  const void *data, void *private __attribute__((unused)))
 {
-	return _format_pvsegs(mem, field, data, 1);
+	char *str;
+	if (!(str = _format_pvsegs(mem, (const struct lv_segment *) data, 1)))
+		return 0;
+
+	dm_report_field_set_value(field, str, NULL);
+
+	return 1;
 }
 
 static int _tags_disp(struct dm_report *rh __attribute__((unused)), struct dm_pool *mem,
-- 
1.7.2.2


