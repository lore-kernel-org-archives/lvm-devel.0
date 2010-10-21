From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 21 Oct 2010 14:49:33 -0000
Subject: LVM2/lib metadata/lv.c metadata/lv.h report/pr ...
Message-ID: <20101021144933.10272.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-10-21 14:49:32

Modified files:
	lib/metadata   : lv.c lv.h 
	lib/report     : properties.c report.c 

Log message:
	Add lv_read_ahead and lv_kernel_read_ahead 'get' functions.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv.c.diff?cvsroot=lvm2&r1=1.16&r2=1.17
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv.h.diff?cvsroot=lvm2&r1=1.14&r2=1.15
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/properties.c.diff?cvsroot=lvm2&r1=1.18&r2=1.19
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.138&r2=1.139

--- LVM2/lib/metadata/lv.c	2010/10/21 14:49:20	1.16
+++ LVM2/lib/metadata/lv.c	2010/10/21 14:49:31	1.17
@@ -20,6 +20,15 @@
 #include "segtype.h"
 #include "str_list.h"
 
+uint32_t lv_kernel_read_ahead(const struct logical_volume *lv)
+{
+	struct lvinfo info;
+
+	if (!lv_info(lv->vg->cmd, lv, 0, &info, 0, 1) || !info.exists)
+		return UINT32_MAX;
+	return info.read_ahead;
+}
+
 char *lv_origin_dup(struct dm_pool *mem, const struct logical_volume *lv)
 {
 	if (lv_is_cow(lv))
--- LVM2/lib/metadata/lv.h	2010/10/21 14:49:20	1.14
+++ LVM2/lib/metadata/lv.h	2010/10/21 14:49:31	1.15
@@ -62,5 +62,6 @@
 char *lv_modules_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_name_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_origin_dup(struct dm_pool *mem, const struct logical_volume *lv);
+uint32_t lv_kernel_read_ahead(const struct logical_volume *lv);
 
 #endif
--- LVM2/lib/report/properties.c	2010/10/21 14:49:20	1.18
+++ LVM2/lib/report/properties.c	2010/10/21 14:49:31	1.19
@@ -109,13 +109,13 @@
 #define _lv_major_set _not_implemented_set
 GET_LV_NUM_PROPERTY_FN(lv_minor, lv->minor)
 #define _lv_minor_set _not_implemented_set
-#define _lv_read_ahead_get _not_implemented_get
+GET_LV_NUM_PROPERTY_FN(lv_read_ahead, lv->read_ahead * SECTOR_SIZE)
 #define _lv_read_ahead_set _not_implemented_set
 GET_LV_NUM_PROPERTY_FN(lv_kernel_major, lv_kernel_major(lv))
 #define _lv_kernel_major_set _not_implemented_set
 GET_LV_NUM_PROPERTY_FN(lv_kernel_minor, lv_kernel_minor(lv))
 #define _lv_kernel_minor_set _not_implemented_set
-#define _lv_kernel_read_ahead_get _not_implemented_get
+GET_LV_NUM_PROPERTY_FN(lv_kernel_read_ahead, lv_kernel_read_ahead(lv) * SECTOR_SIZE)
 #define _lv_kernel_read_ahead_set _not_implemented_set
 GET_LV_NUM_PROPERTY_FN(lv_size, lv->size * SECTOR_SIZE)
 #define _lv_size_set _not_implemented_set
--- LVM2/lib/report/report.c	2010/10/12 16:13:07	1.138
+++ LVM2/lib/report/report.c	2010/10/21 14:49:31	1.139
@@ -469,12 +469,12 @@
 			      void *private)
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
-	struct lvinfo info;
+	uint32_t read_ahead;
 
-	if (!lv_info(lv->vg->cmd, lv, 0, &info, 0, 1) || !info.exists)
+	if ((read_ahead = lv_kernel_read_ahead(lv)) == UINT32_MAX)
 		return dm_report_field_int32(rh, field, &_minusone32);
 
-	return _size32_disp(rh, mem, field, &info.read_ahead, private);
+	return _size32_disp(rh, mem, field, &read_ahead, private);
 }
 
 static int _vgsize_disp(struct dm_report *rh, struct dm_pool *mem,


