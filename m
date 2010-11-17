From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 17 Nov 2010 20:08:16 -0000
Subject: LVM2/lib metadata/lv.c metadata/lv.h report/pr ...
Message-ID: <20101117200816.7553.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-11-17 20:08:14

Modified files:
	lib/metadata   : lv.c lv.h 
	lib/report     : properties.c properties.h report.c 

Log message:
	Add the macro and specific 'get' functions for lvsegs.
	
	Signed-off-by: Dave Wysochanski <wysochanski@pobox.com>
	Reviewed-by: Petr Rockai <prockai@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv.c.diff?cvsroot=lvm2&r1=1.18&r2=1.19
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv.h.diff?cvsroot=lvm2&r1=1.16&r2=1.17
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/properties.c.diff?cvsroot=lvm2&r1=1.23&r2=1.24
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/properties.h.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.139&r2=1.140

--- LVM2/lib/metadata/lv.c	2010/10/25 13:54:29	1.18
+++ LVM2/lib/metadata/lv.c	2010/11/17 20:08:14	1.19
@@ -21,6 +21,41 @@
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
--- LVM2/lib/metadata/lv.h	2010/10/25 12:01:59	1.16
+++ LVM2/lib/metadata/lv.h	2010/11/17 20:08:14	1.17
@@ -63,5 +63,10 @@
 char *lv_name_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_origin_dup(struct dm_pool *mem, const struct logical_volume *lv);
 uint32_t lv_kernel_read_ahead(const struct logical_volume *lv);
+uint64_t lvseg_start(const struct lv_segment *seg);
+uint64_t lvseg_size(const struct lv_segment *seg);
+uint64_t lvseg_chunksize(const struct lv_segment *seg);
+char *lvseg_segtype_dup(const struct lv_segment *seg);
+char *lvseg_tags_dup(const struct lv_segment *seg);
 
 #endif /* _LVM_LV_H */
--- LVM2/lib/report/properties.c	2010/11/17 19:15:11	1.23
+++ LVM2/lib/report/properties.c	2010/11/17 20:08:14	1.24
@@ -34,6 +34,8 @@
 	GET_NUM_PROPERTY_FN(NAME, VALUE, physical_volume, pv)
 #define GET_LV_NUM_PROPERTY_FN(NAME, VALUE) \
 	GET_NUM_PROPERTY_FN(NAME, VALUE, logical_volume, lv)
+#define GET_LVSEG_NUM_PROPERTY_FN(NAME, VALUE) \
+	GET_NUM_PROPERTY_FN(NAME, VALUE, lv_segment, lvseg)
 
 #define SET_NUM_PROPERTY_FN(NAME, SETFN, TYPE, VAR)			\
 static int _ ## NAME ## _set (void *obj, struct lvm_property_type *prop) \
@@ -64,6 +66,8 @@
 	GET_STR_PROPERTY_FN(NAME, VALUE, physical_volume, pv)
 #define GET_LV_STR_PROPERTY_FN(NAME, VALUE) \
 	GET_STR_PROPERTY_FN(NAME, VALUE, logical_volume, lv)
+#define GET_LVSEG_STR_PROPERTY_FN(NAME, VALUE) \
+	GET_STR_PROPERTY_FN(NAME, VALUE, lv_segment, lvseg)
 
 static int _not_implemented_get(const void *obj, struct lvm_property_type *prop)
 {
@@ -202,29 +206,29 @@
 SET_VG_NUM_PROPERTY_FN(vg_mda_copies, vg_set_mda_copies)
 
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
@@ -318,6 +322,12 @@
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
--- LVM2/lib/report/properties.h	2010/11/17 19:50:15	1.7
+++ LVM2/lib/report/properties.h	2010/11/17 20:08:14	1.8
@@ -33,6 +33,8 @@
 	int (*set) (void *obj, struct lvm_property_type *prop);
 };
 
+int lvseg_get_property(const struct lv_segment *lvseg,
+		       struct lvm_property_type *prop);
 int lv_get_property(const struct logical_volume *lv,
 		    struct lvm_property_type *prop);
 int vg_get_property(const struct volume_group *vg,
--- LVM2/lib/report/report.c	2010/10/21 14:49:31	1.139
+++ LVM2/lib/report/report.c	2010/11/17 20:08:14	1.140
@@ -279,12 +279,9 @@
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
 
@@ -496,7 +493,7 @@
 	const struct lv_segment *seg = (const struct lv_segment *) data;
 	uint64_t start;
 
-	start = (uint64_t) seg->le * seg->lv->vg->extent_size;
+	start = lvseg_start(seg);
 
 	return _size64_disp(rh, mem, field, &start, private);
 }
@@ -519,7 +516,7 @@
 	const struct lv_segment *seg = (const struct lv_segment *) data;
 	uint64_t size;
 
-	size = (uint64_t) seg->len * seg->lv->vg->extent_size;
+	size = lvseg_size(seg);
 
 	return _size64_disp(rh, mem, field, &size, private);
 }
@@ -531,10 +528,7 @@
 	const struct lv_segment *seg = (const struct lv_segment *) data;
 	uint64_t size;
 
-	if (lv_is_cow(seg->lv))
-		size = (uint64_t) find_cow(seg->lv)->chunk_size;
-	else
-		size = UINT64_C(0);
+	size = lvseg_chunksize(seg);
 
 	return _size64_disp(rh, mem, field, &size, private);
 }


