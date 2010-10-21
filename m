From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 21 Oct 2010 14:49:11 -0000
Subject: LVM2/lib metadata/lv.c metadata/lv.h report/pr ...
Message-ID: <20101021144911.8734.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-10-21 14:49:11

Modified files:
	lib/metadata   : lv.c lv.h 
	lib/report     : properties.c 

Log message:
	Refactor and add code for (lv) 'lv_name' get function.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv.c.diff?cvsroot=lvm2&r1=1.14&r2=1.15
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv.h.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/properties.c.diff?cvsroot=lvm2&r1=1.16&r2=1.17

--- LVM2/lib/metadata/lv.c	2010/10/12 17:09:23	1.14
+++ LVM2/lib/metadata/lv.c	2010/10/21 14:49:10	1.15
@@ -20,6 +20,11 @@
 #include "segtype.h"
 #include "str_list.h"
 
+char *lv_name_dup(struct dm_pool *mem, const struct logical_volume *lv)
+{
+	return dm_pool_strdup(mem, lv->name);
+}
+
 char *lv_modules_dup(struct dm_pool *mem, const struct logical_volume *lv)
 {
 	struct dm_list *modules;
--- LVM2/lib/metadata/lv.h	2010/10/12 16:13:06	1.12
+++ LVM2/lib/metadata/lv.h	2010/10/21 14:49:10	1.13
@@ -60,5 +60,6 @@
 int lv_kernel_minor(const struct logical_volume *lv);
 char *lv_mirror_log_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_modules_dup(struct dm_pool *mem, const struct logical_volume *lv);
+char *lv_name_dup(struct dm_pool *mem, const struct logical_volume *lv);
 
 #endif
--- LVM2/lib/report/properties.c	2010/10/12 16:13:07	1.16
+++ LVM2/lib/report/properties.c	2010/10/21 14:49:10	1.17
@@ -99,7 +99,7 @@
 /* LV */
 GET_LV_STR_PROPERTY_FN(lv_uuid, lv_uuid_dup(lv))
 #define _lv_uuid_set _not_implemented_set
-#define _lv_name_get _not_implemented_get
+GET_LV_STR_PROPERTY_FN(lv_name, lv_name_dup(lv->vg->vgmem, lv))
 #define _lv_name_set _not_implemented_set
 GET_LV_STR_PROPERTY_FN(lv_path, lv_path_dup(lv->vg->vgmem, lv))
 #define _lv_path_set _not_implemented_set


