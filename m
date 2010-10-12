From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 12 Oct 2010 16:12:35 -0000
Subject: LVM2/lib metadata/lv.c metadata/lv.h report/pr ...
Message-ID: <20101012161235.24148.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-10-12 16:12:34

Modified files:
	lib/metadata   : lv.c lv.h 
	lib/report     : properties.c report.c 

Log message:
	Refactor and add code for (lv) 'lv_kernel_{major|minor}' get functions.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
	Reviewed-By: Petr Rockai <prockai@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv.c.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv.h.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/properties.c.diff?cvsroot=lvm2&r1=1.13&r2=1.14
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.135&r2=1.136

--- LVM2/lib/metadata/lv.c	2010/10/12 16:12:18	1.10
+++ LVM2/lib/metadata/lv.c	2010/10/12 16:12:33	1.11
@@ -18,6 +18,23 @@
 #include "activate.h"
 #include "toolcontext.h"
 
+int lv_kernel_minor(const struct logical_volume *lv)
+{
+	struct lvinfo info;
+
+	if (lv_info(lv->vg->cmd, lv, 0, &info, 0, 0) && info.exists)
+		return info.minor;
+	return -1;
+}
+
+int lv_kernel_major(const struct logical_volume *lv)
+{
+	struct lvinfo info;
+	if (lv_info(lv->vg->cmd, lv, 0, &info, 0, 0) && info.exists)
+		return info.major;
+	return -1;
+}
+
 char *lv_convert_lv_dup(struct dm_pool *mem, const struct logical_volume *lv)
 {
 	struct lv_segment *seg;
--- LVM2/lib/metadata/lv.h	2010/10/12 16:12:18	1.9
+++ LVM2/lib/metadata/lv.h	2010/10/12 16:12:33	1.10
@@ -56,5 +56,7 @@
 uint64_t lv_origin_size(const struct logical_volume *lv);
 char *lv_move_pv_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_convert_lv_dup(struct dm_pool *mem, const struct logical_volume *lv);
+int lv_kernel_major(const struct logical_volume *lv);
+int lv_kernel_minor(const struct logical_volume *lv);
 
 #endif
--- LVM2/lib/report/properties.c	2010/10/12 16:12:18	1.13
+++ LVM2/lib/report/properties.c	2010/10/12 16:12:34	1.14
@@ -111,9 +111,9 @@
 #define _lv_minor_set _not_implemented_set
 #define _lv_read_ahead_get _not_implemented_get
 #define _lv_read_ahead_set _not_implemented_set
-#define _lv_kernel_major_get _not_implemented_get
+GET_LV_NUM_PROPERTY_FN(lv_kernel_major, lv_kernel_major(lv))
 #define _lv_kernel_major_set _not_implemented_set
-#define _lv_kernel_minor_get _not_implemented_get
+GET_LV_NUM_PROPERTY_FN(lv_kernel_minor, lv_kernel_minor(lv))
 #define _lv_kernel_minor_set _not_implemented_set
 #define _lv_kernel_read_ahead_get _not_implemented_get
 #define _lv_kernel_read_ahead_set _not_implemented_set
--- LVM2/lib/report/report.c	2010/10/12 16:12:18	1.135
+++ LVM2/lib/report/report.c	2010/10/12 16:12:34	1.136
@@ -212,10 +212,10 @@
 			const void *data, void *private __attribute__((unused)))
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
-	struct lvinfo info;
+	int major;
 
-	if (lv_info(lv->vg->cmd, lv, 0, &info, 0, 0) && info.exists)
-		return dm_report_field_int(rh, field, &info.major);
+	if ((major = lv_kernel_major(lv)) >= 0)
+		return dm_report_field_int(rh, field, &major);
 
 	return dm_report_field_int32(rh, field, &_minusone32);
 }
@@ -225,10 +225,10 @@
 			const void *data, void *private __attribute__((unused)))
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
-	struct lvinfo info;
+	int minor;
 
-	if (lv_info(lv->vg->cmd, lv, 0, &info, 0, 0) && info.exists)
-		return dm_report_field_int(rh, field, &info.minor);
+	if ((minor = lv_kernel_minor(lv)) >= 0)
+		return dm_report_field_int(rh, field, &minor);
 
 	return dm_report_field_int32(rh, field, &_minusone32);
 }


