From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 21 Oct 2010 14:49:21 -0000
Subject: LVM2/lib metadata/lv.c metadata/lv.h report/pr ...
Message-ID: <20101021144921.8916.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-10-21 14:49:20

Modified files:
	lib/metadata   : lv.c lv.h 
	lib/report     : properties.c 

Log message:
	Refactor and add code for (lv) 'lv_origin' get function.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv.c.diff?cvsroot=lvm2&r1=1.15&r2=1.16
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv.h.diff?cvsroot=lvm2&r1=1.13&r2=1.14
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/properties.c.diff?cvsroot=lvm2&r1=1.17&r2=1.18

--- LVM2/lib/metadata/lv.c	2010/10/21 14:49:10	1.15
+++ LVM2/lib/metadata/lv.c	2010/10/21 14:49:20	1.16
@@ -20,6 +20,13 @@
 #include "segtype.h"
 #include "str_list.h"
 
+char *lv_origin_dup(struct dm_pool *mem, const struct logical_volume *lv)
+{
+	if (lv_is_cow(lv))
+		return lv_name_dup(mem, origin_from_cow(lv));
+	return NULL;
+}
+
 char *lv_name_dup(struct dm_pool *mem, const struct logical_volume *lv)
 {
 	return dm_pool_strdup(mem, lv->name);
--- LVM2/lib/metadata/lv.h	2010/10/21 14:49:10	1.13
+++ LVM2/lib/metadata/lv.h	2010/10/21 14:49:20	1.14
@@ -61,5 +61,6 @@
 char *lv_mirror_log_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_modules_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_name_dup(struct dm_pool *mem, const struct logical_volume *lv);
+char *lv_origin_dup(struct dm_pool *mem, const struct logical_volume *lv);
 
 #endif
--- LVM2/lib/report/properties.c	2010/10/21 14:49:10	1.17
+++ LVM2/lib/report/properties.c	2010/10/21 14:49:20	1.18
@@ -121,7 +121,7 @@
 #define _lv_size_set _not_implemented_set
 GET_LV_NUM_PROPERTY_FN(seg_count, dm_list_size(&lv->segments))
 #define _seg_count_set _not_implemented_set
-#define _origin_get _not_implemented_get
+GET_LV_STR_PROPERTY_FN(origin, lv_origin_dup(lv->vg->vgmem, lv))
 #define _origin_set _not_implemented_set
 GET_LV_NUM_PROPERTY_FN(origin_size, lv_origin_size(lv))
 #define _origin_size_set _not_implemented_set


