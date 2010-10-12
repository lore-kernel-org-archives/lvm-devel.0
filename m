From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 12 Oct 2010 16:12:19 -0000
Subject: LVM2/lib metadata/lv.c metadata/lv.h report/pr ...
Message-ID: <20101012161219.23977.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-10-12 16:12:18

Modified files:
	lib/metadata   : lv.c lv.h 
	lib/report     : properties.c report.c 

Log message:
	Refactor and add code for (lv) 'convert_lv' get function.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
	Reviewed-By: Petr Rockai <prockai@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv.c.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv.h.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/properties.c.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.134&r2=1.135

--- LVM2/lib/metadata/lv.c	2010/10/12 16:12:02	1.9
+++ LVM2/lib/metadata/lv.c	2010/10/12 16:12:18	1.10
@@ -18,6 +18,21 @@
 #include "activate.h"
 #include "toolcontext.h"
 
+char *lv_convert_lv_dup(struct dm_pool *mem, const struct logical_volume *lv)
+{
+	struct lv_segment *seg;
+
+	if (lv->status & (CONVERTING|MIRRORED)) {
+		seg = first_seg(lv);
+
+		/* Temporary mirror is always area_num == 0 */
+		if (seg_type(seg, 0) == AREA_LV &&
+		    is_temporary_mirror_layer(seg_lv(seg, 0)))
+			return dm_pool_strdup(mem, seg_lv(seg, 0)->name);
+	}
+	return NULL;
+}
+
 char *lv_move_pv_dup(struct dm_pool *mem, const struct logical_volume *lv)
 {
 	struct lv_segment *seg;
--- LVM2/lib/metadata/lv.h	2010/10/12 16:12:02	1.8
+++ LVM2/lib/metadata/lv.h	2010/10/12 16:12:18	1.9
@@ -55,5 +55,6 @@
 char *lv_path_dup(struct dm_pool *mem, const struct logical_volume *lv);
 uint64_t lv_origin_size(const struct logical_volume *lv);
 char *lv_move_pv_dup(struct dm_pool *mem, const struct logical_volume *lv);
+char *lv_convert_lv_dup(struct dm_pool *mem, const struct logical_volume *lv);
 
 #endif
--- LVM2/lib/report/properties.c	2010/10/12 16:12:02	1.12
+++ LVM2/lib/report/properties.c	2010/10/12 16:12:18	1.13
@@ -131,7 +131,7 @@
 #define _copy_percent_set _not_implemented_set
 GET_LV_STR_PROPERTY_FN(move_pv, lv_move_pv_dup(lv->vg->vgmem, lv))
 #define _move_pv_set _not_implemented_set
-#define _convert_lv_get _not_implemented_get
+GET_LV_STR_PROPERTY_FN(convert_lv, lv_convert_lv_dup(lv->vg->vgmem, lv))
 #define _convert_lv_set _not_implemented_set
 GET_LV_STR_PROPERTY_FN(lv_tags, lv_tags_dup(lv))
 #define _lv_tags_set _not_implemented_set
--- LVM2/lib/report/report.c	2010/10/12 16:12:02	1.134
+++ LVM2/lib/report/report.c	2010/10/12 16:12:18	1.135
@@ -392,19 +392,8 @@
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 	const char *name = NULL;
-	struct lv_segment *seg;
-
-	if (lv->status & CONVERTING) {
-		if (lv->status & MIRRORED) {
-			seg = first_seg(lv);
-
-			/* Temporary mirror is always area_num == 0 */
-			if (seg_type(seg, 0) == AREA_LV &&
-			    is_temporary_mirror_layer(seg_lv(seg, 0)))
-				name = seg_lv(seg, 0)->name;
-		}
-	}
 
+	name = lv_convert_lv_dup(mem, lv);
 	if (name)
 		return dm_report_field_string(rh, field, &name);
 


