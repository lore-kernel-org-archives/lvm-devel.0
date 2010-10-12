From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 12 Oct 2010 16:12:04 -0000
Subject: LVM2/lib metadata/lv.c metadata/lv.h report/pr ...
Message-ID: <20101012161204.23760.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-10-12 16:12:03

Modified files:
	lib/metadata   : lv.c lv.h 
	lib/report     : properties.c report.c 

Log message:
	Refactor and add code for (lv) 'move_pv' get function.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
	Reviewed-By: Petr Rockai <prockai@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv.c.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv.h.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/properties.c.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.133&r2=1.134

--- LVM2/lib/metadata/lv.c	2010/10/12 16:11:48	1.8
+++ LVM2/lib/metadata/lv.c	2010/10/12 16:12:02	1.9
@@ -18,6 +18,17 @@
 #include "activate.h"
 #include "toolcontext.h"
 
+char *lv_move_pv_dup(struct dm_pool *mem, const struct logical_volume *lv)
+{
+	struct lv_segment *seg;
+
+	dm_list_iterate_items(seg, &lv->segments) {
+		if (seg->status & PVMOVE)
+			return dm_pool_strdup(mem, dev_name(seg_dev(seg, 0)));
+	}
+	return NULL;
+}
+
 uint64_t lv_origin_size(const struct logical_volume *lv)
 {
 	if (lv_is_cow(lv))
--- LVM2/lib/metadata/lv.h	2010/10/12 16:11:48	1.7
+++ LVM2/lib/metadata/lv.h	2010/10/12 16:12:02	1.8
@@ -54,5 +54,6 @@
 char *lv_tags_dup(const struct logical_volume *lv);
 char *lv_path_dup(struct dm_pool *mem, const struct logical_volume *lv);
 uint64_t lv_origin_size(const struct logical_volume *lv);
+char *lv_move_pv_dup(struct dm_pool *mem, const struct logical_volume *lv);
 
 #endif
--- LVM2/lib/report/properties.c	2010/10/12 16:11:48	1.11
+++ LVM2/lib/report/properties.c	2010/10/12 16:12:02	1.12
@@ -129,7 +129,7 @@
 #define _snap_percent_set _not_implemented_set
 #define _copy_percent_get _not_implemented_get
 #define _copy_percent_set _not_implemented_set
-#define _move_pv_get _not_implemented_get
+GET_LV_STR_PROPERTY_FN(move_pv, lv_move_pv_dup(lv->vg->vgmem, lv))
 #define _move_pv_set _not_implemented_set
 #define _convert_lv_get _not_implemented_get
 #define _convert_lv_set _not_implemented_set
--- LVM2/lib/report/report.c	2010/10/12 16:11:48	1.133
+++ LVM2/lib/report/report.c	2010/10/12 16:12:02	1.134
@@ -378,16 +378,11 @@
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 	const char *name;
-	struct lv_segment *seg;
 
-	dm_list_iterate_items(seg, &lv->segments) {
-		if (!(seg->status & PVMOVE))
-			continue;
-		name = dev_name(seg_dev(seg, 0));
+	if (!(name = lv_move_pv_dup(mem, lv)))
+		dm_report_field_set_value(field, "", NULL);
+	else
 		return dm_report_field_string(rh, field, &name);
-	}
-
-	dm_report_field_set_value(field, "", NULL);
 	return 1;
 }
 


