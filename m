From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 12 Apr 2011 12:24:31 -0000
Subject: LVM2 lib/metadata/lv.c lib/metadata/lv.h lib/r ...
Message-ID: <20110412122431.26467.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-04-12 12:24:30

Modified files:
	lib/metadata   : lv.c lv.h 
	lib/report     : properties.c report.c 
	test/api       : test.c 

Log message:
	This patchset refactors some reporting code and completes the remaining
	lvseg properties for lvm2app, 'devices' and 'seg_pe_ranges'.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
	Reviewed-by: Petr Rockai <prockai@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv.c.diff?cvsroot=lvm2&r1=1.23&r2=1.24
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv.h.diff?cvsroot=lvm2&r1=1.19&r2=1.20
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/properties.c.diff?cvsroot=lvm2&r1=1.30&r2=1.31
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.143&r2=1.144
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/test.c.diff?cvsroot=lvm2&r1=1.36&r2=1.37

--- LVM2/lib/metadata/lv.c	2011/03/29 12:51:57	1.23
+++ LVM2/lib/metadata/lv.c	2011/04/12 12:24:29	1.24
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
--- LVM2/lib/metadata/lv.h	2011/03/05 12:14:00	1.19
+++ LVM2/lib/metadata/lv.h	2011/04/12 12:24:29	1.20
@@ -68,5 +68,7 @@
 uint64_t lvseg_chunksize(const struct lv_segment *seg);
 char *lvseg_segtype_dup(struct dm_pool *mem, const struct lv_segment *seg);
 char *lvseg_tags_dup(const struct lv_segment *seg);
+char *lvseg_devices(struct dm_pool *mem, const struct lv_segment *seg);
+char *lvseg_seg_pe_ranges(struct dm_pool *mem, const struct lv_segment *seg);
 
 #endif /* _LVM_LV_H */
--- LVM2/lib/report/properties.c	2011/03/05 12:14:00	1.30
+++ LVM2/lib/report/properties.c	2011/04/12 12:24:29	1.31
@@ -249,9 +249,10 @@
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
 
 
--- LVM2/lib/report/report.c	2011/03/05 12:14:00	1.143
+++ LVM2/lib/report/report.c	2011/04/12 12:24:29	1.144
@@ -56,93 +56,30 @@
 	return dm_report_field_string(rh, field, &name);
 }
 
-static int _format_pvsegs(struct dm_pool *mem, struct dm_report_field *field,
-			  const void *data, int range_format)
+static int _devices_disp(struct dm_report *rh __attribute__((unused)), struct dm_pool *mem,
+			 struct dm_report_field *field,
+			 const void *data, void *private __attribute__((unused)))
 {
-	const struct lv_segment *seg = (const struct lv_segment *) data;
-	unsigned int s;
-	const char *name = NULL;
-	uint32_t extent = 0;
-	char extent_str[32];
-
-	if (!dm_pool_begin_object(mem, 256)) {
-		log_error("dm_pool_begin_object failed");
-		return 0;
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
-			return 0;
-		}
-
-		if (dm_snprintf(extent_str, sizeof(extent_str),
-				"%s%" PRIu32 "%s",
-				range_format ? ":" : "(", extent,
-				range_format ? "-"  : ")") < 0) {
-			log_error("Extent number dm_snprintf failed");
-			return 0;
-		}
-		if (!dm_pool_grow_object(mem, extent_str, strlen(extent_str))) {
-			log_error("dm_pool_grow_object failed");
-			return 0;
-		}
-
-		if (range_format) {
-			if (dm_snprintf(extent_str, sizeof(extent_str),
-					"%" PRIu32, extent + seg->area_len - 1) < 0) {
-				log_error("Extent number dm_snprintf failed");
-				return 0;
-			}
-			if (!dm_pool_grow_object(mem, extent_str, strlen(extent_str))) {
-				log_error("dm_pool_grow_object failed");
-				return 0;
-			}
-		}
-
-		if ((s != seg->area_count - 1) &&
-		    !dm_pool_grow_object(mem, range_format ? " " : ",", 1)) {
-			log_error("dm_pool_grow_object failed");
-			return 0;
-		}
-	}
-
-	if (!dm_pool_grow_object(mem, "\0", 1)) {
-		log_error("dm_pool_grow_object failed");
+	char *str;
+	if (!(str = lvseg_devices(mem, (const struct lv_segment *) data)))
 		return 0;
-	}
 
-	dm_report_field_set_value(field, dm_pool_end_object(mem), NULL);
+	dm_report_field_set_value(field, str, NULL);
 
 	return 1;
 }
 
-static int _devices_disp(struct dm_report *rh __attribute__((unused)), struct dm_pool *mem,
-			 struct dm_report_field *field,
-			 const void *data, void *private __attribute__((unused)))
-{
-	return _format_pvsegs(mem, field, data, 0);
-}
-
 static int _peranges_disp(struct dm_report *rh __attribute__((unused)), struct dm_pool *mem,
 			  struct dm_report_field *field,
 			  const void *data, void *private __attribute__((unused)))
 {
-	return _format_pvsegs(mem, field, data, 1);
+	char *str;
+	if (!(str = lvseg_seg_pe_ranges(mem, (const struct lv_segment *) data)))
+		return 0;
+
+	dm_report_field_set_value(field, str, NULL);
+
+	return 1;
 }
 
 static int _tags_disp(struct dm_report *rh __attribute__((unused)), struct dm_pool *mem,
--- LVM2/test/api/test.c	2011/03/01 23:29:14	1.36
+++ LVM2/test/api/test.c	2011/04/12 12:24:29	1.37
@@ -873,6 +873,10 @@
 		_print_property_value("seg_start_pe", v);
 		v = lvm_lvseg_get_property(lvl->lvseg, "seg_size");
 		_print_property_value("seg_size", v);
+		v = lvm_lvseg_get_property(lvl->lvseg, "devices");
+		_print_property_value("devices", v);
+		v = lvm_lvseg_get_property(lvl->lvseg, "seg_pe_ranges");
+		_print_property_value("seg_pe_ranges", v);
 	}
 }
 


