From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 12 Oct 2010 16:12:52 -0000
Subject: LVM2/lib metadata/lv.c metadata/lv.h report/pr ...
Message-ID: <20101012161252.24392.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-10-12 16:12:50

Modified files:
	lib/metadata   : lv.c lv.h 
	lib/report     : properties.c report.c 

Log message:
	Refactor and add code for (lv) 'mirror_log' get function.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
	Reviewed-By: Petr Rockai <prockai@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv.c.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv.h.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/properties.c.diff?cvsroot=lvm2&r1=1.14&r2=1.15
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.136&r2=1.137

--- LVM2/lib/metadata/lv.c	2010/10/12 16:12:33	1.11
+++ LVM2/lib/metadata/lv.c	2010/10/12 16:12:50	1.12
@@ -17,6 +17,19 @@
 #include "metadata.h"
 #include "activate.h"
 #include "toolcontext.h"
+#include "segtype.h"
+
+char *lv_mirror_log_dup(struct dm_pool *mem, const struct logical_volume *lv)
+{
+	struct lv_segment *seg;
+
+	dm_list_iterate_items(seg, &lv->segments) {
+		if (!seg_is_mirrored(seg) || !seg->log_lv)
+			continue;
+		return dm_pool_strdup(mem, seg->log_lv->name);
+	}
+	return NULL;
+}
 
 int lv_kernel_minor(const struct logical_volume *lv)
 {
--- LVM2/lib/metadata/lv.h	2010/10/12 16:12:33	1.10
+++ LVM2/lib/metadata/lv.h	2010/10/12 16:12:50	1.11
@@ -58,5 +58,6 @@
 char *lv_convert_lv_dup(struct dm_pool *mem, const struct logical_volume *lv);
 int lv_kernel_major(const struct logical_volume *lv);
 int lv_kernel_minor(const struct logical_volume *lv);
+char *lv_mirror_log_dup(struct dm_pool *mem, const struct logical_volume *lv);
 
 #endif
--- LVM2/lib/report/properties.c	2010/10/12 16:12:34	1.14
+++ LVM2/lib/report/properties.c	2010/10/12 16:12:50	1.15
@@ -135,7 +135,7 @@
 #define _convert_lv_set _not_implemented_set
 GET_LV_STR_PROPERTY_FN(lv_tags, lv_tags_dup(lv))
 #define _lv_tags_set _not_implemented_set
-#define _mirror_log_get _not_implemented_get
+GET_LV_STR_PROPERTY_FN(mirror_log, lv_mirror_log_dup(lv->vg->vgmem, lv))
 #define _mirror_log_set _not_implemented_set
 #define _modules_get _not_implemented_get
 #define _modules_set _not_implemented_set
--- LVM2/lib/report/report.c	2010/10/12 16:12:34	1.136
+++ LVM2/lib/report/report.c	2010/10/12 16:12:50	1.137
@@ -297,14 +297,10 @@
 		       const void *data, void *private __attribute__((unused)))
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
-	struct lv_segment *seg;
+	const char *name;
 
-	dm_list_iterate_items(seg, &lv->segments) {
-		if (!seg_is_mirrored(seg) || !seg->log_lv)
-			continue;
-		return dm_report_field_string(rh, field,
-					      (const char **) &seg->log_lv->name);
-	}
+	if ((name = lv_mirror_log_dup(mem, lv)))
+		return dm_report_field_string(rh, field, &name);
 
 	dm_report_field_set_value(field, "", NULL);
 	return 1;


