From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 12 Oct 2010 16:11:35 -0000
Subject: LVM2/lib metadata/lv.c metadata/lv.h report/pr ...
Message-ID: <20101012161135.23383.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-10-12 16:11:34

Modified files:
	lib/metadata   : lv.c lv.h 
	lib/report     : properties.c report.c 

Log message:
	Refactor and add code for (lv) 'lv_path' get function.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv.c.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv.h.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/properties.c.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.131&r2=1.132

--- LVM2/lib/metadata/lv.c	2010/09/30 20:47:18	1.6
+++ LVM2/lib/metadata/lv.c	2010/10/12 16:11:34	1.7
@@ -16,6 +16,28 @@
 #include "lib.h"
 #include "metadata.h"
 #include "activate.h"
+#include "toolcontext.h"
+
+char *lv_path_dup(struct dm_pool *mem, const struct logical_volume *lv)
+{
+	char *repstr;
+	size_t len;
+
+	len = strlen(lv->vg->cmd->dev_dir) + strlen(lv->vg->name) +
+		strlen(lv->name) + 2;
+
+	if (!(repstr = dm_pool_zalloc(mem, len))) {
+		log_error("dm_pool_alloc failed");
+		return 0;
+	}
+
+	if (dm_snprintf(repstr, len, "%s%s/%s",
+			lv->vg->cmd->dev_dir, lv->vg->name, lv->name) < 0) {
+		log_error("lvpath snprintf failed");
+		return 0;
+	}
+	return repstr;
+}
 
 char *lv_uuid_dup(const struct logical_volume *lv)
 {
--- LVM2/lib/metadata/lv.h	2010/09/30 20:47:18	1.5
+++ LVM2/lib/metadata/lv.h	2010/10/12 16:11:34	1.6
@@ -52,5 +52,6 @@
 char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_uuid_dup(const struct logical_volume *lv);
 char *lv_tags_dup(const struct logical_volume *lv);
+char *lv_path_dup(struct dm_pool *mem, const struct logical_volume *lv);
 
 #endif
--- LVM2/lib/report/properties.c	2010/10/12 16:11:20	1.9
+++ LVM2/lib/report/properties.c	2010/10/12 16:11:34	1.10
@@ -101,7 +101,7 @@
 #define _lv_uuid_set _not_implemented_set
 #define _lv_name_get _not_implemented_get
 #define _lv_name_set _not_implemented_set
-#define _lv_path_get _not_implemented_get
+GET_LV_STR_PROPERTY_FN(lv_path, lv_path_dup(lv->vg->vgmem, lv))
 #define _lv_path_set _not_implemented_set
 GET_LV_STR_PROPERTY_FN(lv_attr, lv_attr_dup(lv->vg->vgmem, lv))
 #define _lv_attr_set _not_implemented_set
--- LVM2/lib/report/report.c	2010/09/30 14:09:10	1.131
+++ LVM2/lib/report/report.c	2010/10/12 16:11:34	1.132
@@ -350,18 +350,9 @@
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
 	char *repstr;
-	size_t len;
 
-	len = strlen(lv->vg->cmd->dev_dir) + strlen(lv->vg->name) + strlen(lv->name) + 2;
-	if (!(repstr = dm_pool_zalloc(mem, len))) {
-		log_error("dm_pool_alloc failed");
+	if (!(repstr = lv_path_dup(mem, lv)))
 		return 0;
-	}
-
-	if (dm_snprintf(repstr, len, "%s%s/%s", lv->vg->cmd->dev_dir, lv->vg->name, lv->name) < 0) {
-		log_error("lvpath snprintf failed");
-		return 0;
-	}
 
 	dm_report_field_set_value(field, repstr, NULL);
 


