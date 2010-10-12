From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 12 Oct 2010 16:11:49 -0000
Subject: LVM2/lib metadata/lv.c metadata/lv.h report/pr ...
Message-ID: <20101012161149.23554.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-10-12 16:11:48

Modified files:
	lib/metadata   : lv.c lv.h 
	lib/report     : properties.c report.c 

Log message:
	Refactor and add code for (lv) 'origin_size' get function.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
	Reviewed-By: Petr Rockai <prockai@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv.c.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv.h.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/properties.c.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.132&r2=1.133

--- LVM2/lib/metadata/lv.c	2010/10/12 16:11:34	1.7
+++ LVM2/lib/metadata/lv.c	2010/10/12 16:11:48	1.8
@@ -18,6 +18,15 @@
 #include "activate.h"
 #include "toolcontext.h"
 
+uint64_t lv_origin_size(const struct logical_volume *lv)
+{
+	if (lv_is_cow(lv))
+		return (uint64_t) find_cow(lv)->len * lv->vg->extent_size;
+	if (lv_is_origin(lv))
+		return lv->size;
+	return 0;
+}
+
 char *lv_path_dup(struct dm_pool *mem, const struct logical_volume *lv)
 {
 	char *repstr;
--- LVM2/lib/metadata/lv.h	2010/10/12 16:11:34	1.6
+++ LVM2/lib/metadata/lv.h	2010/10/12 16:11:48	1.7
@@ -53,5 +53,6 @@
 char *lv_uuid_dup(const struct logical_volume *lv);
 char *lv_tags_dup(const struct logical_volume *lv);
 char *lv_path_dup(struct dm_pool *mem, const struct logical_volume *lv);
+uint64_t lv_origin_size(const struct logical_volume *lv);
 
 #endif
--- LVM2/lib/report/properties.c	2010/10/12 16:11:34	1.10
+++ LVM2/lib/report/properties.c	2010/10/12 16:11:48	1.11
@@ -123,7 +123,7 @@
 #define _seg_count_set _not_implemented_set
 #define _origin_get _not_implemented_get
 #define _origin_set _not_implemented_set
-#define _origin_size_get _not_implemented_get
+GET_LV_NUM_PROPERTY_FN(origin_size, lv_origin_size(lv))
 #define _origin_size_set _not_implemented_set
 #define _snap_percent_get _not_implemented_get
 #define _snap_percent_set _not_implemented_set
--- LVM2/lib/report/report.c	2010/10/12 16:11:34	1.132
+++ LVM2/lib/report/report.c	2010/10/12 16:11:48	1.133
@@ -570,12 +570,7 @@
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 	uint64_t size;
 
-	if (lv_is_cow(lv))
-		size = (uint64_t) find_cow(lv)->len * lv->vg->extent_size;
-	else if (lv_is_origin(lv))
-		size = lv->size;
-	else
-		size = UINT64_C(0);
+	size = lv_origin_size(lv);
 
 	return _size64_disp(rh, mem, field, &size, private);
 }


