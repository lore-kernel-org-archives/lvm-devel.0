From: agk@sourceware.org <agk@sourceware.org>
Date: 16 Jan 2007 18:06:12 -0000
Subject: LVM2 ./WHATS_NEW lib/mirror/mirrored.c lib/rep ...
Message-ID: <20070116180612.24921.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-01-16 18:06:12

Modified files:
	.              : WHATS_NEW 
	lib/mirror     : mirrored.c 
	lib/report     : report.c 
	tools          : lvmcmdlib.c reporter.c 

Log message:
	Move basic reporting functions into libdevmapper.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.542&r2=1.543
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mirror/mirrored.c.diff?cvsroot=lvm2&r1=1.40&r2=1.41
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.50&r2=1.51
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdlib.c.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/reporter.c.diff?cvsroot=lvm2&r1=1.16&r2=1.17

--- LVM2/WHATS_NEW	2007/01/15 21:55:11	1.542
+++ LVM2/WHATS_NEW	2007/01/16 18:06:10	1.543
@@ -1,5 +1,6 @@
 Version 2.02.19 - 
 ===================================
+  Move basic reporting functions into libdevmapper.
   Fix partition table processing after sparc changes (2.02.16).
   Fix cmdline PE range processing segfault (2.02.13).
   Some libdevmapper-event interface changes.
--- LVM2/lib/mirror/mirrored.c	2007/01/15 18:22:02	1.40
+++ LVM2/lib/mirror/mirrored.c	2007/01/16 18:06:11	1.41
@@ -444,7 +444,7 @@
 		return_0;
 
 	dm_event_handler_set_dso(dmevh, dso);
-	dm_event_handler_set_devname(dmevh, name);
+	dm_event_handler_set_dev_name(dmevh, name);
 	dm_event_handler_set_event_mask(dmevh, DM_EVENT_ALL_ERRORS);
 	if (!dm_event_register_handler(dmevh)) {
 		dm_event_handler_destroy(dmevh);
@@ -481,7 +481,7 @@
 		return_0;
 
 	dm_event_handler_set_dso(dmevh, dso);
-	dm_event_handler_set_devname(dmevh, name);
+	dm_event_handler_set_dev_name(dmevh, name);
 	dm_event_handler_set_event_mask(dmevh, DM_EVENT_ALL_ERRORS);
 	if (!dm_event_unregister_handler(dmevh)) {
 		dm_event_handler_destroy(dmevh);
--- LVM2/lib/report/report.c	2006/10/08 12:01:13	1.50
+++ LVM2/lib/report/report.c	2007/01/16 18:06:11	1.51
@@ -22,8 +22,17 @@
 #include "activate.h"
 #include "segtype.h"
 #include "str_list.h"
+#include "lvmcache.h"
 
-/* 
+struct lvm_report_object {
+	struct volume_group *vg;
+	struct logical_volume *lv;
+	struct physical_volume *pv;
+	struct lv_segment *seg;
+	struct pv_segment *pvseg;
+};
+
+/*
  * For macro use
  */
 static union {
@@ -34,71 +43,6 @@
 	struct pv_segment _pvseg;
 } _dummy;
 
-/*
- * Report handle flags
- */
-#define RH_SORT_REQUIRED	0x00000001
-#define RH_HEADINGS_PRINTED	0x00000002
-#define RH_BUFFERED		0x00000004
-#define RH_ALIGNED		0x00000008
-#define RH_HEADINGS		0x00000010
-
-struct report_handle {
-	struct cmd_context *cmd;
-	struct dm_pool *mem;
-
-	report_type_t type;
-	const char *field_prefix;
-	uint32_t flags;
-	const char *separator;
-
-	uint32_t keys_count;
-
-	/* Ordered list of fields needed for this report */
-	struct list field_props;
-
-	/* Rows of report data */
-	struct list rows;
-};
-
-/* 
- * Per-field flags
- */
-#define FLD_ALIGN_LEFT	0x00000001
-#define FLD_ALIGN_RIGHT	0x00000002
-#define FLD_STRING	0x00000004
-#define FLD_NUMBER	0x00000008
-#define FLD_HIDDEN	0x00000010
-#define FLD_SORT_KEY	0x00000020
-#define FLD_ASCENDING	0x00000040
-#define FLD_DESCENDING	0x00000080
-
-struct field_properties {
-	struct list list;
-	uint32_t field_num;
-	uint32_t sort_posn;
-	int width;
-	uint32_t flags;
-};
-
-/* 
- * Report data
- */
-struct field {
-	struct list list;
-	struct field_properties *props;
-
-	const char *report_string;	/* Formatted ready for display */
-	const void *sort_value;	/* Raw value for sorting */
-};
-
-struct row {
-	struct list list;
-	struct report_handle *rh;
-	struct list fields;	/* Fields in display order */
-	struct field *(*sort_fields)[];	/* Fields in sort order */
-};
-
 static char _alloc_policy_char(alloc_policy_t alloc)
 {
 	switch (alloc) {
@@ -118,31 +62,25 @@
 /*
  * Data-munging functions to prepare each data type for display and sorting
  */
-static int _string_disp(struct report_handle *rh, struct field *field,
-			const void *data)
+static int _string_disp(struct dm_report *rh, struct dm_pool *mem,
+			struct dm_report_field *field,
+			const void *data, void *private)
 {
-	if (!
-	    (field->report_string =
-	     dm_pool_strdup(rh->mem, *(const char **) data))) {
-		log_error("dm_pool_strdup failed");
-		return 0;
-	}
-
-	field->sort_value = (const void *) field->report_string;
-
-	return 1;
+	return dm_report_field_string(rh, mem, field, data);
 }
 
-static int _dev_name_disp(struct report_handle *rh, struct field *field,
-			  const void *data)
+static int _dev_name_disp(struct dm_report *rh, struct dm_pool *mem,
+			  struct dm_report_field *field,
+			  const void *data, void *private)
 {
 	const char *name = dev_name(*(const struct device **) data);
 
-	return _string_disp(rh, field, &name);
+	return dm_report_field_string(rh, mem, field, &name);
 }
 
-static int _devices_disp(struct report_handle *rh, struct field *field,
-			 const void *data)
+static int _devices_disp(struct dm_report *rh, struct dm_pool *mem,
+			 struct dm_report_field *field,
+			 const void *data, void *private)
 {
 	const struct lv_segment *seg = (const struct lv_segment *) data;
 	unsigned int s;
@@ -150,7 +88,7 @@
 	uint32_t extent = 0;
 	char extent_str[32];
 
-	if (!dm_pool_begin_object(rh->mem, 256)) {
+	if (!dm_pool_begin_object(mem, 256)) {
 		log_error("dm_pool_begin_object failed");
 		return 0;
 	}
@@ -170,7 +108,7 @@
 			extent = 0;
 		}
 
-		if (!dm_pool_grow_object(rh->mem, name, strlen(name))) {
+		if (!dm_pool_grow_object(mem, name, strlen(name))) {
 			log_error("dm_pool_grow_object failed");
 			return 0;
 		}
@@ -181,173 +119,143 @@
 			return 0;
 		}
 
-		if (!dm_pool_grow_object(rh->mem, extent_str, strlen(extent_str))) {
+		if (!dm_pool_grow_object(mem, extent_str, strlen(extent_str))) {
 			log_error("dm_pool_grow_object failed");
 			return 0;
 		}
 
 		if ((s != seg->area_count - 1) &&
-		    !dm_pool_grow_object(rh->mem, ",", 1)) {
+		    !dm_pool_grow_object(mem, ",", 1)) {
 			log_error("dm_pool_grow_object failed");
 			return 0;
 		}
 	}
 
-	if (!dm_pool_grow_object(rh->mem, "\0", 1)) {
+	if (!dm_pool_grow_object(mem, "\0", 1)) {
 		log_error("dm_pool_grow_object failed");
 		return 0;
 	}
 
-	field->report_string = dm_pool_end_object(rh->mem);
-	field->sort_value = (const void *) field->report_string;
+	dm_report_field_set_value(field, dm_pool_end_object(mem), NULL);
 
 	return 1;
 }
 
-static int _tags_disp(struct report_handle *rh, struct field *field,
-		      const void *data)
+static int _tags_disp(struct dm_report *rh, struct dm_pool *mem,
+		      struct dm_report_field *field,
+		      const void *data, void *private)
 {
 	const struct list *tags = (const struct list *) data;
 	struct str_list *sl;
 
-	if (!dm_pool_begin_object(rh->mem, 256)) {
+	if (!dm_pool_begin_object(mem, 256)) {
 		log_error("dm_pool_begin_object failed");
 		return 0;
 	}
 
 	list_iterate_items(sl, tags) {
-		if (!dm_pool_grow_object(rh->mem, sl->str, strlen(sl->str)) ||
-		    (sl->list.n != tags && !dm_pool_grow_object(rh->mem, ",", 1))) {
+		if (!dm_pool_grow_object(mem, sl->str, strlen(sl->str)) ||
+		    (sl->list.n != tags && !dm_pool_grow_object(mem, ",", 1))) {
 			log_error("dm_pool_grow_object failed");
 			return 0;
 		}
 	}
 
-	if (!dm_pool_grow_object(rh->mem, "\0", 1)) {
+	if (!dm_pool_grow_object(mem, "\0", 1)) {
 		log_error("dm_pool_grow_object failed");
 		return 0;
 	}
 
-	field->report_string = dm_pool_end_object(rh->mem);
-	field->sort_value = (const void *) field->report_string;
+	dm_report_field_set_value(field, dm_pool_end_object(mem), NULL);
 
 	return 1;
 }
 
-static int _modules_disp(struct report_handle *rh, struct field *field,
-			 const void *data)
+static int _modules_disp(struct dm_report *rh, struct dm_pool *mem,
+			 struct dm_report_field *field,
+			 const void *data, void *private)
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 	struct list *modules;
 
-	if (!(modules = str_list_create(rh->mem))) {
+	if (!(modules = str_list_create(mem))) {
 		log_error("modules str_list allocation failed");
 		return 0;
 	}
 
-	if (!list_lv_modules(rh->mem, lv, modules))
+	if (!list_lv_modules(mem, lv, modules))
 		return_0;
 
-	return _tags_disp(rh, field, modules);
+	return _tags_disp(rh, mem, field, modules, private);
 }
 
-static int _vgfmt_disp(struct report_handle *rh, struct field *field,
-		       const void *data)
+static int _vgfmt_disp(struct dm_report *rh, struct dm_pool *mem,
+		       struct dm_report_field *field,
+		       const void *data, void *private)
 {
 	const struct volume_group *vg = (const struct volume_group *) data;
 
 	if (!vg->fid) {
-		field->report_string = "";
-		field->sort_value = (const void *) field->report_string;
+		dm_report_field_set_value(field, "", NULL);
 		return 1;
 	}
 
-	return _string_disp(rh, field, &vg->fid->fmt->name);
+	return _string_disp(rh, mem, field, &vg->fid->fmt->name, private);
 }
 
-static int _pvfmt_disp(struct report_handle *rh, struct field *field,
-		       const void *data)
+static int _pvfmt_disp(struct dm_report *rh, struct dm_pool *mem,
+		       struct dm_report_field *field,
+		       const void *data, void *private)
 {
 	const struct physical_volume *pv =
 	    (const struct physical_volume *) data;
 
 	if (!pv->fmt) {
-		field->report_string = "";
-		field->sort_value = (const void *) field->report_string;
+		dm_report_field_set_value(field, "", NULL);
 		return 1;
 	}
 
-	return _string_disp(rh, field, &pv->fmt->name);
+	return _string_disp(rh, mem, field, &pv->fmt->name, private);
 }
 
-static int _int_disp(struct report_handle *rh, struct field *field,
-		     const void *data)
-{
-	const int value = *(const int *) data;
-	uint64_t *sortval;
-	char *repstr;
-
-	if (!(repstr = dm_pool_zalloc(rh->mem, 13))) {
-		log_error("dm_pool_alloc failed");
-		return 0;
-	}
-
-	if (!(sortval = dm_pool_alloc(rh->mem, sizeof(int64_t)))) {
-		log_error("dm_pool_alloc failed");
-		return 0;
-	}
-
-	if (dm_snprintf(repstr, 12, "%d", value) < 0) {
-		log_error("int too big: %d", value);
-		return 0;
-	}
-
-	*sortval = (const uint64_t) value;
-	field->sort_value = sortval;
-	field->report_string = repstr;
-
-	return 1;
-}
-
-static int _lvkmaj_disp(struct report_handle *rh, struct field *field,
-			const void *data)
+static int _lvkmaj_disp(struct dm_report *rh, struct dm_pool *mem,
+			struct dm_report_field *field,
+			const void *data, void *private)
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 	struct lvinfo info;
 	uint64_t minusone = UINT64_C(-1);
 
 	if (lv_info(lv->vg->cmd, lv, &info, 0) && info.exists)
-		return _int_disp(rh, field, &info.major);
-	else
-		return _int_disp(rh, field, &minusone);
+		return dm_report_field_int(rh, mem, field, &info.major);
 
-	return 1;
+	return dm_report_field_int(rh, mem, field, &minusone);
 }
 
-static int _lvkmin_disp(struct report_handle *rh, struct field *field,
-			const void *data)
+static int _lvkmin_disp(struct dm_report *rh, struct dm_pool *mem,
+			struct dm_report_field *field,
+			const void *data, void *private)
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 	struct lvinfo info;
 	uint64_t minusone = UINT64_C(-1);
 
 	if (lv_info(lv->vg->cmd, lv, &info, 0) && info.exists)
-		return _int_disp(rh, field, &info.minor);
-	else
-		return _int_disp(rh, field, &minusone);
+		return dm_report_field_int(rh, mem, field, &info.minor);
 
-	return 1;
+	return dm_report_field_int(rh, mem, field, &minusone);
 }
 
-static int _lvstatus_disp(struct report_handle *rh, struct field *field,
-			  const void *data)
+static int _lvstatus_disp(struct dm_report *rh, struct dm_pool *mem,
+			  struct dm_report_field *field,
+			  const void *data, void *private)
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 	struct lvinfo info;
 	char *repstr;
 	float snap_percent;
 
-	if (!(repstr = dm_pool_zalloc(rh->mem, 7))) {
+	if (!(repstr = dm_pool_zalloc(mem, 7))) {
 		log_error("dm_pool_alloc failed");
 		return 0;
 	}
@@ -419,19 +327,18 @@
 		repstr[5] = '-';
 	}
 
-	field->report_string = repstr;
-	field->sort_value = (const void *) field->report_string;
-
+	dm_report_field_set_value(field, repstr, NULL);
 	return 1;
 }
 
-static int _pvstatus_disp(struct report_handle *rh, struct field *field,
-			  const void *data)
+static int _pvstatus_disp(struct dm_report *rh, struct dm_pool *mem,
+			  struct dm_report_field *field,
+			  const void *data, void *private)
 {
 	const uint32_t status = *(const uint32_t *) data;
 	char *repstr;
 
-	if (!(repstr = dm_pool_zalloc(rh->mem, 4))) {
+	if (!(repstr = dm_pool_zalloc(mem, 4))) {
 		log_error("dm_pool_alloc failed");
 		return 0;
 	}
@@ -446,19 +353,18 @@
 	else
 		repstr[1] = '-';
 
-	field->report_string = repstr;
-	field->sort_value = (const void *) field->report_string;
-
+	dm_report_field_set_value(field, repstr, NULL);
 	return 1;
 }
 
-static int _vgstatus_disp(struct report_handle *rh, struct field *field,
-			  const void *data)
+static int _vgstatus_disp(struct dm_report *rh, struct dm_pool *mem,
+			  struct dm_report_field *field,
+			  const void *data, void *private)
 {
 	const struct volume_group *vg = (const struct volume_group *) data;
 	char *repstr;
 
-	if (!(repstr = dm_pool_zalloc(rh->mem, 7))) {
+	if (!(repstr = dm_pool_zalloc(mem, 7))) {
 		log_error("dm_pool_alloc failed");
 		return 0;
 	}
@@ -490,43 +396,43 @@
 	else
 		repstr[5] = '-';
 
-	field->report_string = repstr;
-	field->sort_value = (const void *) field->report_string;
-
+	dm_report_field_set_value(field, repstr, NULL);
 	return 1;
 }
 
-static int _segtype_disp(struct report_handle *rh __attribute((unused)),
-			 struct field *field,
-			 const void *data)
+static int _segtype_disp(struct dm_report *rh __attribute((unused)),
+			 struct dm_pool *mem,
+			 struct dm_report_field *field,
+			 const void *data, void *private)
 {
 	const struct lv_segment *seg = (const struct lv_segment *) data;
 
-	if (seg->area_count == 1)
-		field->report_string = "linear";
-	else
-		field->report_string = seg->segtype->ops->name(seg);
-	field->sort_value = (const void *) field->report_string;
+	if (seg->area_count == 1) {
+		dm_report_field_set_value(field, "linear", NULL);
+		return 1;
+	}
 
+	dm_report_field_set_value(field, seg->segtype->ops->name(seg), NULL);
 	return 1;
 }
 
-static int _origin_disp(struct report_handle *rh, struct field *field,
-			const void *data)
+static int _origin_disp(struct dm_report *rh, struct dm_pool *mem,
+			struct dm_report_field *field,
+			const void *data, void *private)
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 
 	if (lv_is_cow(lv))
-		return _string_disp(rh, field, &origin_from_cow(lv)->name);
-
-	field->report_string = "";
-	field->sort_value = (const void *) field->report_string;
+		return dm_report_field_string(rh, mem, field,
+					      &origin_from_cow(lv)->name);
 
+	dm_report_field_set_value(field, "", NULL);
 	return 1;
 }
 
-static int _loglv_disp(struct report_handle *rh, struct field *field,
-		       const void *data)
+static int _loglv_disp(struct dm_report *rh, struct dm_pool *mem,
+		       struct dm_report_field *field,
+		       const void *data, void *private)
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 	struct lv_segment *seg;
@@ -534,29 +440,29 @@
 	list_iterate_items(seg, &lv->segments) {
 		if (!seg_is_mirrored(seg) || !seg->log_lv)
 			continue;
-		return _string_disp(rh, field, &seg->log_lv->name);
+		return dm_report_field_string(rh, mem, field,
+					      &seg->log_lv->name);
 	}
 
-	field->report_string = "";
-	field->sort_value = (const void *) field->report_string;
-
+	dm_report_field_set_value(field, "", NULL);
 	return 1;
 }
 
-static int _lvname_disp(struct report_handle *rh, struct field *field,
-			const void *data)
+static int _lvname_disp(struct dm_report *rh, struct dm_pool *mem,
+			struct dm_report_field *field,
+			const void *data, void *private)
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
-	char *repstr;
+	char *repstr, *lvname;
 	size_t len;
 
 	if (lv_is_visible(lv)) {
 		repstr = lv->name;
-		return _string_disp(rh, field, &repstr);
+		return dm_report_field_string(rh, mem, field, &repstr);
 	}
 
 	len = strlen(lv->name) + 3;
-	if (!(repstr = dm_pool_zalloc(rh->mem, len))) {
+	if (!(repstr = dm_pool_zalloc(mem, len))) {
 		log_error("dm_pool_alloc failed");
 		return 0;
 	}
@@ -566,18 +472,19 @@
 		return 0;
 	}
 
-	field->report_string = repstr;
-
-	if (!(field->sort_value = dm_pool_strdup(rh->mem, lv->name))) {
+	if (!(lvname = dm_pool_strdup(mem, lv->name))) {
 		log_error("dm_pool_strdup failed");
 		return 0;
 	}
 
+	dm_report_field_set_value(field, repstr, lvname);
+
 	return 1;
 }
 
-static int _movepv_disp(struct report_handle *rh, struct field *field,
-			const void *data)
+static int _movepv_disp(struct dm_report *rh, struct dm_pool *mem,
+			struct dm_report_field *field,
+			const void *data, void *private)
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 	const char *name;
@@ -587,106 +494,111 @@
 		if (!(seg->status & PVMOVE))
 			continue;
 		name = dev_name(seg_dev(seg, 0));
-		return _string_disp(rh, field, &name);
+		return dm_report_field_string(rh, mem, field, &name);
 	}
 
-	field->report_string = "";
-	field->sort_value = (const void *) field->report_string;
-
+	dm_report_field_set_value(field, "", NULL);
 	return 1;
 }
 
-static int _size32_disp(struct report_handle *rh, struct field *field,
-			const void *data)
+static int _size32_disp(struct dm_report *rh, struct dm_pool *mem,
+			struct dm_report_field *field,
+			const void *data, void *private)
 {
 	const uint32_t size = *(const uint32_t *) data;
-	const char *disp;
+	const char *disp, *repstr;
 	uint64_t *sortval;
 
-	if (!*(disp = display_size_units(rh->cmd, (uint64_t) size))) {
+	if (!*(disp = display_size_units(private, (uint64_t) size))) {
 		stack;
 		return 0;
 	}
 
-	if (!(field->report_string = dm_pool_strdup(rh->mem, disp))) {
+	if (!(repstr = dm_pool_strdup(mem, disp))) {
 		log_error("dm_pool_strdup failed");
 		return 0;
 	}
 
-	if (!(sortval = dm_pool_alloc(rh->mem, sizeof(uint64_t)))) {
+	if (!(sortval = dm_pool_alloc(mem, sizeof(uint64_t)))) {
 		log_error("dm_pool_alloc failed");
 		return 0;
 	}
 
 	*sortval = (const uint64_t) size;
-	field->sort_value = (const void *) sortval;
+
+	dm_report_field_set_value(field, repstr, sortval);
 
 	return 1;
 }
 
-static int _size64_disp(struct report_handle *rh, struct field *field,
-			const void *data)
+static int _size64_disp(struct dm_report *rh, struct dm_pool *mem,
+			struct dm_report_field *field,
+			const void *data, void *private)
 {
 	const uint64_t size = *(const uint64_t *) data;
-	const char *disp;
+	const char *disp, *repstr;
 	uint64_t *sortval;
 
-	if (!*(disp = display_size_units(rh->cmd, size))) {
+	if (!*(disp = display_size_units(private, size))) {
 		stack;
 		return 0;
 	}
 
-	if (!(field->report_string = dm_pool_strdup(rh->mem, disp))) {
+	if (!(repstr = dm_pool_strdup(mem, disp))) {
 		log_error("dm_pool_strdup failed");
 		return 0;
 	}
 
-	if (!(sortval = dm_pool_alloc(rh->mem, sizeof(uint64_t)))) {
+	if (!(sortval = dm_pool_alloc(mem, sizeof(uint64_t)))) {
 		log_error("dm_pool_alloc failed");
 		return 0;
 	}
 
 	*sortval = size;
-	field->sort_value = sortval;
+	dm_report_field_set_value(field, repstr, sortval);
 
 	return 1;
 }
 
-static int _vgsize_disp(struct report_handle *rh, struct field *field,
-			const void *data)
+static int _vgsize_disp(struct dm_report *rh, struct dm_pool *mem,
+			struct dm_report_field *field,
+			const void *data, void *private)
 {
 	const struct volume_group *vg = (const struct volume_group *) data;
 	uint64_t size;
 
 	size = (uint64_t) vg->extent_count * vg->extent_size;
 
-	return _size64_disp(rh, field, &size);
+	return _size64_disp(rh, mem, field, &size, private);
 }
 
-static int _segstart_disp(struct report_handle *rh, struct field *field,
-			  const void *data)
+static int _segstart_disp(struct dm_report *rh, struct dm_pool *mem,
+			  struct dm_report_field *field,
+			  const void *data, void *private)
 {
 	const struct lv_segment *seg = (const struct lv_segment *) data;
 	uint64_t start;
 
 	start = (uint64_t) seg->le * seg->lv->vg->extent_size;
 
-	return _size64_disp(rh, field, &start);
+	return _size64_disp(rh, mem, field, &start, private);
 }
 
-static int _segsize_disp(struct report_handle *rh, struct field *field,
-			 const void *data)
+static int _segsize_disp(struct dm_report *rh, struct dm_pool *mem,
+			 struct dm_report_field *field,
+			 const void *data, void *private)
 {
 	const struct lv_segment *seg = (const struct lv_segment *) data;
 	uint64_t size;
 
 	size = (uint64_t) seg->len * seg->lv->vg->extent_size;
 
-	return _size64_disp(rh, field, &size);
+	return _size64_disp(rh, mem, field, &size, private);
 }
 
-static int _chunksize_disp(struct report_handle *rh, struct field *field,
-			   const void *data)
+static int _chunksize_disp(struct dm_report *rh, struct dm_pool *mem,
+			   struct dm_report_field *field,
+			   const void *data, void *private)
 {
 	const struct lv_segment *seg = (const struct lv_segment *) data;
 	uint64_t size;
@@ -696,11 +608,12 @@
 	else
 		size = 0;
 
-	return _size64_disp(rh, field, &size);
+	return _size64_disp(rh, mem, field, &size, private);
 }
 
-static int _pvused_disp(struct report_handle *rh, struct field *field,
-			const void *data)
+static int _pvused_disp(struct dm_report *rh, struct dm_pool *mem,
+			struct dm_report_field *field,
+			const void *data, void *private)
 {
 	const struct physical_volume *pv =
 	    (const struct physical_volume *) data;
@@ -711,11 +624,12 @@
 	else
 		used = (uint64_t) pv->pe_alloc_count * pv->pe_size;
 
-	return _size64_disp(rh, field, &used);
+	return _size64_disp(rh, mem, field, &used, private);
 }
 
-static int _pvfree_disp(struct report_handle *rh, struct field *field,
-			const void *data)
+static int _pvfree_disp(struct dm_report *rh, struct dm_pool *mem,
+			struct dm_report_field *field,
+			const void *data, void *private)
 {
 	const struct physical_volume *pv =
 	    (const struct physical_volume *) data;
@@ -726,11 +640,12 @@
 	else
 		freespace = (uint64_t) (pv->pe_count - pv->pe_alloc_count) * pv->pe_size;
 
-	return _size64_disp(rh, field, &freespace);
+	return _size64_disp(rh, mem, field, &freespace, private);
 }
 
-static int _pvsize_disp(struct report_handle *rh, struct field *field,
-			const void *data)
+static int _pvsize_disp(struct dm_report *rh, struct dm_pool *mem,
+			struct dm_report_field *field,
+			const void *data, void *private)
 {
 	const struct physical_volume *pv =
 	    (const struct physical_volume *) data;
@@ -741,11 +656,12 @@
 	else
 		size = (uint64_t) pv->pe_count * pv->pe_size;
 
-	return _size64_disp(rh, field, &size);
+	return _size64_disp(rh, mem, field, &size, private);
 }
 
-static int _devsize_disp(struct report_handle *rh, struct field *field,
-			const void *data)
+static int _devsize_disp(struct dm_report *rh, struct dm_pool *mem,
+			 struct dm_report_field *field,
+			 const void *data, void *private)
 {
 	const struct device *dev = *(const struct device **) data;
 	uint64_t size;
@@ -753,26 +669,28 @@
 	if (!dev_get_size(dev, &size))
 		size = 0;
 
-	return _size64_disp(rh, field, &size);
+	return _size64_disp(rh, mem, field, &size, private);
 }
 
-static int _vgfree_disp(struct report_handle *rh, struct field *field,
-			const void *data)
+static int _vgfree_disp(struct dm_report *rh, struct dm_pool *mem,
+			struct dm_report_field *field,
+			const void *data, void *private)
 {
 	const struct volume_group *vg = (const struct volume_group *) data;
 	uint64_t freespace;
 
 	freespace = (uint64_t) vg->free_count * vg->extent_size;
 
-	return _size64_disp(rh, field, &freespace);
+	return _size64_disp(rh, mem, field, &freespace, private);
 }
 
-static int _uuid_disp(struct report_handle *rh, struct field *field,
-		      const void *data)
+static int _uuid_disp(struct dm_report *rh, struct dm_pool *mem,
+		      struct dm_report_field *field,
+		      const void *data, void *private)
 {
 	char *repstr = NULL;
 
-	if (!(repstr = dm_pool_alloc(rh->mem, 40))) {
+	if (!(repstr = dm_pool_alloc(mem, 40))) {
 		log_error("dm_pool_alloc failed");
 		return 0;
 	}
@@ -782,83 +700,39 @@
 		return 0;
 	}
 
-	field->report_string = repstr;
-	field->sort_value = (const void *) field->report_string;
-
+	dm_report_field_set_value(field, repstr, NULL);
 	return 1;
 }
 
-static int _uint32_disp(struct report_handle *rh, struct field *field,
-			const void *data)
+static int _uint32_disp(struct dm_report *rh, struct dm_pool *mem,
+			struct dm_report_field *field,
+			const void *data, void *private)
 {
-	const uint32_t value = *(const uint32_t *) data;
-	uint64_t *sortval;
-	char *repstr;
-
-	if (!(repstr = dm_pool_zalloc(rh->mem, 12))) {
-		log_error("dm_pool_alloc failed");
-		return 0;
-	}
-
-	if (!(sortval = dm_pool_alloc(rh->mem, sizeof(uint64_t)))) {
-		log_error("dm_pool_alloc failed");
-		return 0;
-	}
-
-	if (dm_snprintf(repstr, 11, "%u", value) < 0) {
-		log_error("uint32 too big: %u", value);
-		return 0;
-	}
-
-	*sortval = (const uint64_t) value;
-	field->sort_value = sortval;
-	field->report_string = repstr;
-
-	return 1;
+	return dm_report_field_uint32(rh, mem, field, data);
 }
 
-static int _int32_disp(struct report_handle *rh, struct field *field,
-		       const void *data)
+static int _int32_disp(struct dm_report *rh, struct dm_pool *mem,
+		       struct dm_report_field *field,
+		       const void *data, void *private)
 {
-	const int32_t value = *(const int32_t *) data;
-	uint64_t *sortval;
-	char *repstr;
-
-	if (!(repstr = dm_pool_zalloc(rh->mem, 13))) {
-		log_error("dm_pool_alloc failed");
-		return 0;
-	}
-
-	if (!(sortval = dm_pool_alloc(rh->mem, sizeof(int64_t)))) {
-		log_error("dm_pool_alloc failed");
-		return 0;
-	}
-
-	if (dm_snprintf(repstr, 12, "%d", value) < 0) {
-		log_error("int32 too big: %d", value);
-		return 0;
-	}
-
-	*sortval = (const uint64_t) value;
-	field->sort_value = sortval;
-	field->report_string = repstr;
-
-	return 1;
+	return dm_report_field_int32(rh, mem, field, data);
 }
 
-static int _lvsegcount_disp(struct report_handle *rh, struct field *field,
-			    const void *data)
+static int _lvsegcount_disp(struct dm_report *rh, struct dm_pool *mem,
+			    struct dm_report_field *field,
+			    const void *data, void *private)
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 	uint32_t count;
 
 	count = list_size(&lv->segments);
 
-	return _uint32_disp(rh, field, &count);
+	return _uint32_disp(rh, mem, field, &count, private);
 }
 
-static int _snpercent_disp(struct report_handle *rh, struct field *field,
-			   const void *data)
+static int _snpercent_disp(struct dm_report *rh, struct dm_pool *mem,
+			   struct dm_report_field *field,
+			   const void *data, void *private)
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 	struct lvinfo info;
@@ -866,27 +740,31 @@
 	uint64_t *sortval;
 	char *repstr;
 
-	if (!(sortval = dm_pool_alloc(rh->mem, sizeof(uint64_t)))) {
+	/* Suppress snapshot percentage if not using driver */
+	if (!activation()) {
+		dm_report_field_set_value(field, "", NULL);
+		return 1;
+	}
+
+	if (!(sortval = dm_pool_alloc(mem, sizeof(uint64_t)))) {
 		log_error("dm_pool_alloc failed");
 		return 0;
 	}
 
 	if (!lv_is_cow(lv) ||
 	    (lv_info(lv->vg->cmd, lv, &info, 0) && !info.exists)) {
-		field->report_string = "";
 		*sortval = UINT64_C(0);
-		field->sort_value = sortval;
+		dm_report_field_set_value(field, "", sortval);
 		return 1;
 	}
 
 	if (!lv_snapshot_percent(lv, &snap_percent) || snap_percent < 0) {
-		field->report_string = "100.00";
 		*sortval = UINT64_C(100);
-		field->sort_value = sortval;
+		dm_report_field_set_value(field, "100.00", sortval);
 		return 1;
 	}
 
-	if (!(repstr = dm_pool_zalloc(rh->mem, 8))) {
+	if (!(repstr = dm_pool_zalloc(mem, 8))) {
 		log_error("dm_pool_alloc failed");
 		return 0;
 	}
@@ -897,36 +775,35 @@
 	}
 
 	*sortval = snap_percent * UINT64_C(1000);
-	field->sort_value = sortval;
-	field->report_string = repstr;
+	dm_report_field_set_value(field, repstr, sortval);
 
 	return 1;
 }
 
-static int _copypercent_disp(struct report_handle *rh, struct field *field,
-			     const void *data)
+static int _copypercent_disp(struct dm_report *rh, struct dm_pool *mem,
+			     struct dm_report_field *field,
+			     const void *data, void *private)
 {
 	struct logical_volume *lv = (struct logical_volume *) data;
 	float percent;
 	uint64_t *sortval;
 	char *repstr;
 
-	if (!(sortval = dm_pool_alloc(rh->mem, sizeof(uint64_t)))) {
+	if (!(sortval = dm_pool_alloc(mem, sizeof(uint64_t)))) {
 		log_error("dm_pool_alloc failed");
 		return 0;
 	}
 
 	if ((!(lv->status & PVMOVE) && !(lv->status & MIRRORED)) ||
 	    !lv_mirror_percent(lv->vg->cmd, lv, 0, &percent, NULL)) {
-		field->report_string = "";
 		*sortval = UINT64_C(0);
-		field->sort_value = sortval;
+		dm_report_field_set_value(field, "", sortval);
 		return 1;
 	}
 
 	percent = copy_percent(lv);
 
-	if (!(repstr = dm_pool_zalloc(rh->mem, 8))) {
+	if (!(repstr = dm_pool_zalloc(mem, 8))) {
 		log_error("dm_pool_alloc failed");
 		return 0;
 	}
@@ -937,330 +814,88 @@
 	}
 
 	*sortval = percent * UINT64_C(1000);
-	field->sort_value = sortval;
-	field->report_string = repstr;
+	dm_report_field_set_value(field, repstr, sortval);
 
 	return 1;
 }
 
-/*
- * Import column definitions
- */
-
-#define STR (FLD_STRING | FLD_ALIGN_LEFT)
-#define NUM (FLD_NUMBER | FLD_ALIGN_RIGHT)
-#define FIELD(type, strct, sorttype, head, field, width, func, id) {type, id, (off_t)((void *)&_dummy._ ## strct.field - (void *)&_dummy._ ## strct), head, width, sorttype, &_ ## func ## _disp},
+/* Report object types */
 
-static struct {
-	report_type_t type;
-	const char id[32];
-	off_t offset;
-	const char heading[32];
-	int width;
-	uint32_t flags;
-	field_report_fn report_fn;
-} _fields[] = {
-#include "columns.h"
+/* necessary for displaying something for PVs not belonging to VG */
+static struct volume_group _dummy_vg = {
+	.name = (char *) ORPHAN,
 };
 
-#undef STR
-#undef NUM
-#undef FIELD
-
-const unsigned int _num_fields = sizeof(_fields) / sizeof(_fields[0]);
-
-static void _display_fields(void)
+static void *_obj_get_vg(void *obj)
 {
-	uint32_t f;
-	const char *type, *last_type = "";
-
-	for (f = 0; f < _num_fields; f++) {
-		switch (_fields[f].type) {
-		case PVS:
-			type = "Physical Volume";
-			break;
-		case LVS:
-			type = "Logical Volume";
-			break;
-		case VGS:
-			type = "Volume Group";
-			break;
-		case SEGS:
-			type = "Logical Volume Segment";
-			break;
-		case PVSEGS:
-			type = "Physical Volume Segment";
-			break;
-		default:
-			type = " ";
-		}
+	struct volume_group *vg = ((struct lvm_report_object *)obj)->vg;
 
-		if (type != last_type) {
-			if (*last_type)
-				log_print(" ");
-			log_print("%s Fields", type);
-		}
-
-		log_print("- %s", _fields[f].id);
-
-		last_type = type;
-	}
+	return vg ? vg : &_dummy_vg;
 }
 
-/*
- * Initialise report handle
- */
-static int _field_match(struct report_handle *rh, const char *field, size_t len)
+static void *_obj_get_lv(void *obj)
 {
-	uint32_t f, l;
-	struct field_properties *fp;
-
-	if (!len)
-		return 0;
-
-	for (f = 0; f < _num_fields; f++) {
-		if ((!strncasecmp(_fields[f].id, field, len) &&
-		     strlen(_fields[f].id) == len) ||
-		    (l = strlen(rh->field_prefix),
-		     !strncasecmp(rh->field_prefix, _fields[f].id, l) &&
-		     !strncasecmp(_fields[f].id + l, field, len) &&
-		     strlen(_fields[f].id) == l + len)) {
-			rh->type |= _fields[f].type;
-			if (!(fp = dm_pool_zalloc(rh->mem, sizeof(*fp)))) {
-				log_error("struct field_properties allocation "
-					  "failed");
-				return 0;
-			}
-			fp->field_num = f;
-			fp->width = _fields[f].width;
-			fp->flags = _fields[f].flags;
-
-			/* Suppress snapshot percentage if not using driver */
-			if (!activation()
-			    && !strncmp(field, "snap_percent", len))
-				fp->flags |= FLD_HIDDEN;
-
-			list_add(&rh->field_props, &fp->list);
-			return 1;
-		}
-	}
-
-	return 0;
+	return ((struct lvm_report_object *)obj)->lv;
 }
 
-static int _add_sort_key(struct report_handle *rh, uint32_t field_num,
-			 uint32_t flags)
+static void *_obj_get_pv(void *obj)
 {
-	struct field_properties *fp, *found = NULL;
-
-	list_iterate_items(fp, &rh->field_props) {
-		if (fp->field_num == field_num) {
-			found = fp;
-			break;
-		}
-	}
-
-	if (!found) {
-		/* Add as a non-display field */
-		if (!(found = dm_pool_zalloc(rh->mem, sizeof(*found)))) {
-			log_error("struct field_properties allocation failed");
-			return 0;
-		}
-
-		rh->type |= _fields[field_num].type;
-		found->field_num = field_num;
-		found->width = _fields[field_num].width;
-		found->flags = _fields[field_num].flags | FLD_HIDDEN;
-
-		list_add(&rh->field_props, &found->list);
-	}
-
-	if (found->flags & FLD_SORT_KEY) {
-		log_error("Ignoring duplicate sort field: %s",
-			  _fields[field_num].id);
-		return 1;
-	}
-
-	found->flags |= FLD_SORT_KEY;
-	found->sort_posn = rh->keys_count++;
-	found->flags |= flags;
-
-	return 1;
+	return ((struct lvm_report_object *)obj)->pv;
 }
 
-static int _key_match(struct report_handle *rh, const char *key, size_t len)
+static void *_obj_get_seg(void *obj)
 {
-	uint32_t f, l;
-	uint32_t flags = 0;
-
-	if (!len)
-		return 0;
-
-	if (*key == '+') {
-		key++;
-		len--;
-		flags = FLD_ASCENDING;
-	} else if (*key == '-') {
-		key++;
-		len--;
-		flags = FLD_DESCENDING;
-	} else
-		flags = FLD_ASCENDING;
-
-	if (!len) {
-		log_error("Missing sort field name");
-		return 0;
-	}
-
-	for (f = 0; f < _num_fields; f++) {
-		if ((!strncasecmp(_fields[f].id, key, len) &&
-		     strlen(_fields[f].id) == len) ||
-		    (l = strlen(rh->field_prefix),
-		     !strncasecmp(rh->field_prefix, _fields[f].id, l) &&
-		     !strncasecmp(_fields[f].id + l, key, len) &&
-		     strlen(_fields[f].id) == l + len)) {
-			return _add_sort_key(rh, f, flags);
-		}
-	}
-
-	return 0;
+	return ((struct lvm_report_object *)obj)->seg;
 }
 
-static int _parse_options(struct report_handle *rh, const char *format)
+static void *_obj_get_pvseg(void *obj)
 {
-	const char *ws;		/* Word start */
-	const char *we = format;	/* Word end */
+	return ((struct lvm_report_object *)obj)->pvseg;
+}
 
-	while (*we) {
-		/* Allow consecutive commas */
-		while (*we && *we == ',')
-			we++;
-		ws = we;
-		while (*we && *we != ',')
-			we++;
-		if (!_field_match(rh, ws, (size_t) (we - ws))) {
-			_display_fields();
-			log_print(" ");
-			log_error("Unrecognised field: %.*s", (int) (we - ws),
-				  ws);
-			return 0;
-		}
-	}
+static const struct dm_report_object_type _report_types[] = {
+	{ VGS, "Volume Group", "vg_", _obj_get_vg },
+	{ LVS, "Logical Volume", "lv_", _obj_get_lv },
+	{ PVS, "Physical Volume", "pv_", _obj_get_pv },
+	{ SEGS, "Logical Volume Segment", "seg_", _obj_get_seg },
+	{ PVSEGS, "Physical Volume Segment", "pvseg_", _obj_get_pvseg },
+	{ 0, "", "", NULL },
+};
 
-	return 1;
-}
+/*
+ * Import column definitions
+ */
 
-static int _parse_keys(struct report_handle *rh, const char *keys)
-{
-	const char *ws;		/* Word start */
-	const char *we = keys;	/* Word end */
+#define STR (DM_REPORT_FIELD_STRING | DM_REPORT_FIELD_ALIGN_LEFT)
+#define NUM (DM_REPORT_FIELD_NUMBER | DM_REPORT_FIELD_ALIGN_RIGHT)
+#define FIELD(type, strct, sorttype, head, field, width, func, id) {type, id, (off_t)((void *)&_dummy._ ## strct.field - (void *)&_dummy._ ## strct), head, width, sorttype, &_ ## func ## _disp},
 
-	while (*we) {
-		/* Allow consecutive commas */
-		while (*we && *we == ',')
-			we++;
-		ws = we;
-		while (*we && *we != ',')
-			we++;
-		if (!_key_match(rh, ws, (size_t) (we - ws))) {
-			log_error("Unrecognised field: %.*s", (int) (we - ws),
-				  ws);
-			return 0;
-		}
-	}
+static struct dm_report_field_type _fields[] = {
+#include "columns.h"
+{0, "", 0, "", 0, 0, NULL},
+};
 
-	return 1;
-}
+#undef STR
+#undef NUM
+#undef FIELD
 
 void *report_init(struct cmd_context *cmd, const char *format, const char *keys,
-		  report_type_t *report_type, const char *separator,
-		  int aligned, int buffered, int headings)
+                  report_type_t *report_type, const char *separator,
+                  int aligned, int buffered, int headings)
 {
-	struct report_handle *rh;
-
-	if (!(rh = dm_pool_zalloc(cmd->mem, sizeof(*rh)))) {
-		log_error("report_handle dm_pool_zalloc failed");
-		return 0;
-	}
-
-	rh->cmd = cmd;
-	rh->type = *report_type;
-	rh->separator = separator;
+	uint32_t report_flags = 0;
 
 	if (aligned)
-		rh->flags |= RH_ALIGNED;
+		report_flags |= DM_REPORT_OUTPUT_ALIGNED;
 
 	if (buffered)
-		rh->flags |= RH_BUFFERED | RH_SORT_REQUIRED;
+		report_flags |= DM_REPORT_OUTPUT_BUFFERED;
 
 	if (headings)
-		rh->flags |= RH_HEADINGS;
-
-	list_init(&rh->field_props);
-	list_init(&rh->rows);
-
-	switch (rh->type) {
-	case PVS:
-		rh->field_prefix = "pv_";
-		break;
-	case LVS:
-		rh->field_prefix = "lv_";
-		break;
-	case VGS:
-		rh->field_prefix = "vg_";
-		break;
-	case SEGS:
-		rh->field_prefix = "seg_";
-		break;
-	case PVSEGS:
-		rh->field_prefix = "pvseg_";
-		break;
-	default:
-		rh->field_prefix = "";
-	}
-
-	if (!(rh->mem = dm_pool_create("report", 10 * 1024))) {
-		log_error("Allocation of memory pool for report failed");
-		return NULL;
-	}
-
-	/* Generate list of fields for output based on format string & flags */
-	if (!_parse_options(rh, format))
-		return NULL;
-
-	if (!_parse_keys(rh, keys))
-		return NULL;
-
-	/* Ensure options selected are compatible */
-	if (rh->type & SEGS)
-		rh->type |= LVS;
-	if (rh->type & PVSEGS)
-		rh->type |= PVS;
-	if ((rh->type & LVS) && (rh->type & PVS)) {
-		log_error("Can't report LV and PV fields at the same time");
-		return NULL;
-	}
-
-	/* Change report type if fields specified makes this necessary */
-	if (rh->type & SEGS)
-		*report_type = SEGS;
-	else if (rh->type & LVS)
-		*report_type = LVS;
-	else if (rh->type & PVSEGS)
-		*report_type = PVSEGS;
-	else if (rh->type & PVS)
-		*report_type = PVS;
-
-	return rh;
-}
-
-void report_free(void *handle)
-{
-	struct report_handle *rh = handle;
-
-	dm_pool_destroy(rh->mem);
+		report_flags |= DM_REPORT_OUTPUT_HEADINGS;
 
-	return;
+        return dm_report_init(report_type, _report_types, _fields, format,
+			      separator, report_flags, keys, cmd);
 }
 
 /*
@@ -1270,303 +905,13 @@
 		  struct logical_volume *lv, struct physical_volume *pv,
 		  struct lv_segment *seg, struct pv_segment *pvseg)
 {
-	struct report_handle *rh = handle;
-	struct field_properties *fp;
-	struct row *row;
-	struct field *field;
-	void *data = NULL;
-	int skip;
-
-	if (lv && pv) {
-		log_error("report_object: One of *lv and *pv must be NULL!");
-		return 0;
-	}
-
-	if (!(row = dm_pool_zalloc(rh->mem, sizeof(*row)))) {
-		log_error("struct row allocation failed");
-		return 0;
-	}
-
-	row->rh = rh;
-
-	if ((rh->flags & RH_SORT_REQUIRED) &&
-	    !(row->sort_fields = dm_pool_zalloc(rh->mem, sizeof(struct field *) *
-					     rh->keys_count))) {
-		log_error("row sort value structure allocation failed");
-		return 0;
-	}
-
-	list_init(&row->fields);
-	list_add(&rh->rows, &row->list);
-
-	/* For each field to be displayed, call its report_fn */
-	list_iterate_items(fp, &rh->field_props) {
-		skip = 0;
-
-		if (!(field = dm_pool_zalloc(rh->mem, sizeof(*field)))) {
-			log_error("struct field allocation failed");
-			return 0;
-		}
-		field->props = fp;
-
-		switch (_fields[fp->field_num].type) {
-		case LVS:
-			data = (void *) lv + _fields[fp->field_num].offset;
-			break;
-		case VGS:
-			if (!vg) {
-				skip = 1;
-				break;
-			}
-			data = (void *) vg + _fields[fp->field_num].offset;
-			break;
-		case PVS:
-			data = (void *) pv + _fields[fp->field_num].offset;
-			break;
-		case SEGS:
-			data = (void *) seg + _fields[fp->field_num].offset;
-			break;
-		case PVSEGS:
-			data = (void *) pvseg + _fields[fp->field_num].offset;
-		}
-
-		if (skip) {
-			field->report_string = "";
-			field->sort_value = (const void *) field->report_string;
-		} else if (!_fields[fp->field_num].report_fn(rh, field, data)) {
-			log_error("report function failed for field %s",
-				  _fields[fp->field_num].id);
-			return 0;
-		}
-
-		if ((strlen(field->report_string) > field->props->width))
-			field->props->width = strlen(field->report_string);
-
-		if ((rh->flags & RH_SORT_REQUIRED) &&
-		    (field->props->flags & FLD_SORT_KEY)) {
-			(*row->sort_fields)[field->props->sort_posn] = field;
-		}
-		list_add(&row->fields, &field->list);
-	}
-
-	if (!(rh->flags & RH_BUFFERED))
-		report_output(handle);
-
-	return 1;
-}
-
-/* 
- * Print row of headings 
- */
-static int _report_headings(void *handle)
-{
-	struct report_handle *rh = handle;
-	struct field_properties *fp;
-	const char *heading;
-	char buf[1024];
+	struct lvm_report_object obj;
 
-	if (rh->flags & RH_HEADINGS_PRINTED)
-		return 1;
-
-	rh->flags |= RH_HEADINGS_PRINTED;
-
-	if (!(rh->flags & RH_HEADINGS))
-		return 1;
-
-	if (!dm_pool_begin_object(rh->mem, 128)) {
-		log_error("dm_pool_begin_object failed for headings");
-		return 0;
-	}
-
-	/* First heading line */
-	list_iterate_items(fp, &rh->field_props) {
-		if (fp->flags & FLD_HIDDEN)
-			continue;
-
-		heading = _fields[fp->field_num].heading;
-		if (rh->flags & RH_ALIGNED) {
-			if (dm_snprintf(buf, sizeof(buf), "%-*.*s",
-					 fp->width, fp->width, heading) < 0) {
-				log_error("snprintf heading failed");
-				dm_pool_end_object(rh->mem);
-				return 0;
-			}
-			if (!dm_pool_grow_object(rh->mem, buf, fp->width))
-				goto bad;
-		} else if (!dm_pool_grow_object(rh->mem, heading, strlen(heading)))
-			goto bad;
-
-		if (!list_end(&rh->field_props, &fp->list))
-			if (!dm_pool_grow_object(rh->mem, rh->separator,
-					      strlen(rh->separator)))
-				goto bad;
-	}
-	if (!dm_pool_grow_object(rh->mem, "\0", 1)) {
-		log_error("dm_pool_grow_object failed");
-		goto bad;
-	}
-	log_print("%s", (char *) dm_pool_end_object(rh->mem));
-
-	return 1;
-
-      bad:
-	log_error("Failed to generate report headings for printing");
-
-	return 0;
-}
-
-/*
- * Sort rows of data
- */
-static int _row_compare(const void *a, const void *b)
-{
-	const struct row *rowa = *(const struct row **) a;
-	const struct row *rowb = *(const struct row **) b;
-	const struct field *sfa, *sfb;
-	int32_t cnt = -1;
-
-	for (cnt = 0; cnt < rowa->rh->keys_count; cnt++) {
-		sfa = (*rowa->sort_fields)[cnt];
-		sfb = (*rowb->sort_fields)[cnt];
-		if (sfa->props->flags & FLD_NUMBER) {
-			const uint64_t numa =
-			    *(const uint64_t *) sfa->sort_value;
-			const uint64_t numb =
-			    *(const uint64_t *) sfb->sort_value;
-
-			if (numa == numb)
-				continue;
-
-			if (sfa->props->flags & FLD_ASCENDING) {
-				return (numa > numb) ? 1 : -1;
-			} else {	/* FLD_DESCENDING */
-				return (numa < numb) ? 1 : -1;
-			}
-		} else {	/* FLD_STRING */
-			const char *stra = (const char *) sfa->sort_value;
-			const char *strb = (const char *) sfb->sort_value;
-			int cmp = strcmp(stra, strb);
-
-			if (!cmp)
-				continue;
-
-			if (sfa->props->flags & FLD_ASCENDING) {
-				return (cmp > 0) ? 1 : -1;
-			} else {	/* FLD_DESCENDING */
-				return (cmp < 0) ? 1 : -1;
-			}
-		}
-	}
-
-	return 0;		/* Identical */
-}
-
-static int _sort_rows(struct report_handle *rh)
-{
-	struct row *(*rows)[];
-	uint32_t count = 0;
-	struct row *row;
-
-	if (!(rows = dm_pool_alloc(rh->mem, sizeof(**rows) *
-				list_size(&rh->rows)))) {
-		log_error("sort array allocation failed");
-		return 0;
-	}
-
-	list_iterate_items(row, &rh->rows)
-		(*rows)[count++] = row;
-
-	qsort(rows, count, sizeof(**rows), _row_compare);
-
-	list_init(&rh->rows);
-	while (count--)
-		list_add_h(&rh->rows, &(*rows)[count]->list);
-
-	return 1;
-}
-
-/*
- * Produce report output
- */
-int report_output(void *handle)
-{
-	struct report_handle *rh = handle;
-	struct list *fh, *rowh, *ftmp, *rtmp;
-	struct row *row = NULL;
-	struct field *field;
-	const char *repstr;
-	char buf[4096];
-	int width;
-
-	if (list_empty(&rh->rows))
-		return 1;
-
-	/* Sort rows */
-	if ((rh->flags & RH_SORT_REQUIRED))
-		_sort_rows(rh);
-
-	/* If headings not printed yet, calculate field widths and print them */
-	if (!(rh->flags & RH_HEADINGS_PRINTED))
-		_report_headings(rh);
-
-	/* Print and clear buffer */
-	list_iterate_safe(rowh, rtmp, &rh->rows) {
-		if (!dm_pool_begin_object(rh->mem, 512)) {
-			log_error("dm_pool_begin_object failed for row");
-			return 0;
-		}
-		row = list_item(rowh, struct row);
-		list_iterate_safe(fh, ftmp, &row->fields) {
-			field = list_item(fh, struct field);
-			if (field->props->flags & FLD_HIDDEN)
-				continue;
-
-			repstr = field->report_string;
-			width = field->props->width;
-			if (!(rh->flags & RH_ALIGNED)) {
-				if (!dm_pool_grow_object(rh->mem, repstr,
-						      strlen(repstr)))
-					goto bad;
-			} else if (field->props->flags & FLD_ALIGN_LEFT) {
-				if (dm_snprintf(buf, sizeof(buf), "%-*.*s",
-						 width, width, repstr) < 0) {
-					log_error("snprintf repstr failed");
-					dm_pool_end_object(rh->mem);
-					return 0;
-				}
-				if (!dm_pool_grow_object(rh->mem, buf, width))
-					goto bad;
-			} else if (field->props->flags & FLD_ALIGN_RIGHT) {
-				if (dm_snprintf(buf, sizeof(buf), "%*.*s",
-						 width, width, repstr) < 0) {
-					log_error("snprintf repstr failed");
-					dm_pool_end_object(rh->mem);
-					return 0;
-				}
-				if (!dm_pool_grow_object(rh->mem, buf, width))
-					goto bad;
-			}
-
-			if (!list_end(&row->fields, fh))
-				if (!dm_pool_grow_object(rh->mem, rh->separator,
-						      strlen(rh->separator)))
-					goto bad;
-			list_del(&field->list);
-		}
-		if (!dm_pool_grow_object(rh->mem, "\0", 1)) {
-			log_error("dm_pool_grow_object failed for row");
-			return 0;
-		}
-		log_print("%s", (char *) dm_pool_end_object(rh->mem));
-		list_del(&row->list);
-	}
-
-	if (row)
-		dm_pool_free(rh->mem, row);
-
-	return 1;
+	obj.vg = vg;
+	obj.lv = lv;
+	obj.pv = pv;
+	obj.seg = seg;
+	obj.pvseg = pvseg;
 
-      bad:
-	log_error("Failed to generate row for printing");
-	return 0;
+	return dm_report_object(handle, &obj);
 }
--- LVM2/tools/lvmcmdlib.c	2007/01/08 14:24:20	1.3
+++ LVM2/tools/lvmcmdlib.c	2007/01/16 18:06:11	1.4
@@ -16,6 +16,7 @@
 #include "tools.h"
 #include "lvm2cmdline.h"
 #include "label.h"
+#include "memlock.h"
 #include "version.h"
 
 #include "lvm2cmd.h"
--- LVM2/tools/reporter.c	2006/09/02 01:18:17	1.16
+++ LVM2/tools/reporter.c	2007/01/16 18:06:12	1.17
@@ -25,7 +25,7 @@
 		return ECMD_FAILED;
 	}
 
-	if (!report_object(handle, vg, NULL, NULL, NULL, NULL))
+	if (!report_object(handle, vg, NULL, NULL, NULL, NULL));
 		return ECMD_FAILED;
 
 	check_current_backup(vg);
@@ -39,7 +39,7 @@
 	if (!arg_count(cmd, all_ARG) && !lv_is_visible(lv))
 		return ECMD_PROCESSED;
 
-	if (!report_object(handle, lv->vg, lv, NULL, NULL, NULL))
+	if (!report_object(handle, lv->vg, lv, NULL, NULL, NULL));
 		return ECMD_FAILED;
 
 	return ECMD_PROCESSED;
@@ -48,7 +48,7 @@
 static int _segs_single(struct cmd_context *cmd __attribute((unused)),
 			struct lv_segment *seg, void *handle)
 {
-	if (!report_object(handle, seg->lv->vg, seg->lv, NULL, seg, NULL))
+	if (!report_object(handle, seg->lv->vg, seg->lv, NULL, seg, NULL));
 		return ECMD_FAILED;
 
 	return ECMD_PROCESSED;
@@ -78,7 +78,7 @@
 		goto out;
 	}
 
-	if (!report_object(handle, vg, NULL, pv, NULL, pvseg))
+	if (!report_object(handle, vg, NULL, pv, NULL, pvseg));
 		ret = ECMD_FAILED;
 
 out:
@@ -128,7 +128,7 @@
 		}
 	}
 
-	if (!report_object(handle, vg, NULL, pv, NULL, NULL))
+	if (!report_object(handle, vg, NULL, pv, NULL, NULL));
 		ret = ECMD_FAILED;
 
 out:
@@ -262,6 +262,26 @@
 					  headings)))
 		return 0;
 
+	/* Ensure options selected are compatible */
+	if (report_type & SEGS)
+		report_type |= LVS;
+	if (report_type & PVSEGS)
+		report_type |= PVS;
+	if ((report_type & LVS) && (report_type & PVS)) {
+		log_error("Can't report LV and PV fields at the same time");
+		return 0;
+	}
+
+	/* Change report type if fields specified makes this necessary */
+	if (report_type & SEGS)
+		report_type = SEGS;
+	else if (report_type & LVS)
+		report_type = LVS;
+	else if (report_type & PVSEGS)
+		report_type = PVSEGS;
+	else if (report_type & PVS)
+		report_type = PVS;
+
 	switch (report_type) {
 	case LVS:
 		r = process_each_lv(cmd, argc, argv, LCK_VG_READ, report_handle,
@@ -285,9 +305,9 @@
 		break;
 	}
 
-	report_output(report_handle);
+	dm_report_output(report_handle);
 
-	report_free(report_handle);
+	dm_report_free(report_handle);
 	return r;
 }
 


