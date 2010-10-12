From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 12 Oct 2010 16:13:08 -0000
Subject: LVM2/lib metadata/lv.c metadata/lv.h report/pr ...
Message-ID: <20101012161308.24909.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-10-12 16:13:07

Modified files:
	lib/metadata   : lv.c lv.h 
	lib/report     : properties.c report.c 

Log message:
	Refactor and add code for (lv) 'modules' get function.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv.c.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv.h.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/properties.c.diff?cvsroot=lvm2&r1=1.15&r2=1.16
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.137&r2=1.138

--- LVM2/lib/metadata/lv.c	2010/10/12 16:12:50	1.12
+++ LVM2/lib/metadata/lv.c	2010/10/12 16:13:06	1.13
@@ -18,6 +18,21 @@
 #include "activate.h"
 #include "toolcontext.h"
 #include "segtype.h"
+#include "str_list.h"
+
+char *lv_modules_dup(struct dm_pool *mem, const struct logical_volume *lv)
+{
+	struct dm_list *modules;
+
+	if (!(modules = str_list_create(mem))) {
+		log_error("modules str_list allocation failed");
+		return NULL;
+	}
+
+	if (!list_lv_modules(mem, lv, modules))
+		return_NULL;
+	return tags_format_and_copy(lv->vg->vgmem, modules);
+}
 
 char *lv_mirror_log_dup(struct dm_pool *mem, const struct logical_volume *lv)
 {
--- LVM2/lib/metadata/lv.h	2010/10/12 16:12:50	1.11
+++ LVM2/lib/metadata/lv.h	2010/10/12 16:13:06	1.12
@@ -59,5 +59,6 @@
 int lv_kernel_major(const struct logical_volume *lv);
 int lv_kernel_minor(const struct logical_volume *lv);
 char *lv_mirror_log_dup(struct dm_pool *mem, const struct logical_volume *lv);
+char *lv_modules_dup(struct dm_pool *mem, const struct logical_volume *lv);
 
 #endif
--- LVM2/lib/report/properties.c	2010/10/12 16:12:50	1.15
+++ LVM2/lib/report/properties.c	2010/10/12 16:13:07	1.16
@@ -137,7 +137,7 @@
 #define _lv_tags_set _not_implemented_set
 GET_LV_STR_PROPERTY_FN(mirror_log, lv_mirror_log_dup(lv->vg->vgmem, lv))
 #define _mirror_log_set _not_implemented_set
-#define _modules_get _not_implemented_get
+GET_LV_STR_PROPERTY_FN(modules, lv_modules_dup(lv->vg->vgmem, lv))
 #define _modules_set _not_implemented_set
 
 /* VG */
--- LVM2/lib/report/report.c	2010/10/12 16:12:50	1.137
+++ LVM2/lib/report/report.c	2010/10/12 16:13:07	1.138
@@ -165,17 +165,13 @@
 			 const void *data, void *private)
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
-	struct dm_list *modules;
+	char *modules_str;
 
-	if (!(modules = str_list_create(mem))) {
-		log_error("modules str_list allocation failed");
+	if (!(modules_str = lv_modules_dup(mem, lv)))
 		return 0;
-	}
-
-	if (!list_lv_modules(mem, lv, modules))
-		return_0;
 
-	return _tags_disp(rh, mem, field, modules, private);
+	dm_report_field_set_value(field, modules_str, NULL);
+	return 1;
 }
 
 static int _vgfmt_disp(struct dm_report *rh, struct dm_pool *mem,


