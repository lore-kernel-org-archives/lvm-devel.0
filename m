From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 30 Sep 2010 14:07:50 -0000
Subject: LVM2 lib/metadata/lv.c lib/metadata/lv.h lib/m ...
Message-ID: <20100930140750.16486.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-09-30 14:07:48

Modified files:
	lib/metadata   : lv.c lv.h pv.c pv.h vg.c vg.h 
	liblvm         : lvm_lv.c lvm_pv.c lvm_vg.c 

Log message:
	Add pv_uuid_dup, vg_uuid_dup, and lv_uuid_dup, and call id_format_and_copy.
	
	Add supporting functions for pv_uuid, vg_uuid, and lv_uuid.
	Call new function id_format_and_copy.  Use 'const' where appropriate.
	Add "_dup" suffix to indicate memory is being allocated.
	Call {pv|vg|lv}_uuid_dup from lvm2app uuid functions.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv.c.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv.h.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/pv.c.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/pv.h.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/vg.c.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/vg.h.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_lv.c.diff?cvsroot=lvm2&r1=1.25&r2=1.26
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_pv.c.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_vg.c.diff?cvsroot=lvm2&r1=1.43&r2=1.44

--- LVM2/lib/metadata/lv.c	2010/09/30 14:07:19	1.3
+++ LVM2/lib/metadata/lv.c	2010/09/30 14:07:47	1.4
@@ -16,6 +16,11 @@
 #include "metadata.h"
 #include "activate.h"
 
+char *lv_uuid_dup(const struct logical_volume *lv)
+{
+	return id_format_and_copy(lv->vg->vgmem, &lv->lvid.id[1]);
+}
+
 uint64_t lv_size(const struct logical_volume *lv)
 {
 	return lv->size;
--- LVM2/lib/metadata/lv.h	2010/09/30 13:52:56	1.2
+++ LVM2/lib/metadata/lv.h	2010/09/30 14:07:47	1.3
@@ -49,5 +49,6 @@
 
 uint64_t lv_size(const struct logical_volume *lv);
 char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv);
+char *lv_uuid_dup(const struct logical_volume *lv);
 
 #endif
--- LVM2/lib/metadata/pv.c	2010/09/30 14:07:19	1.3
+++ LVM2/lib/metadata/pv.c	2010/09/30 14:07:47	1.4
@@ -29,6 +29,11 @@
 	return pv_field(pv, id);
 }
 
+char *pv_uuid_dup(const struct physical_volume *pv)
+{
+	return id_format_and_copy(pv->vg->vgmem, &pv->id);
+}
+
 const struct format_type *pv_format_type(const struct physical_volume *pv)
 {
 	return pv_field(pv, fmt);
--- LVM2/lib/metadata/pv.h	2010/09/30 13:52:56	1.2
+++ LVM2/lib/metadata/pv.h	2010/09/30 14:07:47	1.3
@@ -56,6 +56,7 @@
 const char *pv_vg_name(const struct physical_volume *pv);
 char *pv_attr_dup(struct dm_pool *mem, const struct physical_volume *pv);
 const char *pv_dev_name(const struct physical_volume *pv);
+char *pv_uuid_dup(const struct physical_volume *pv);
 uint64_t pv_size(const struct physical_volume *pv);
 uint64_t pv_size_field(const struct physical_volume *pv);
 uint64_t pv_dev_size(const struct physical_volume *pv);
--- LVM2/lib/metadata/vg.c	2010/09/30 14:07:19	1.3
+++ LVM2/lib/metadata/vg.c	2010/09/30 14:07:47	1.4
@@ -16,6 +16,11 @@
 #include "metadata.h"
 #include "activate.h"
 
+char *vg_uuid_dup(const struct volume_group *vg)
+{
+	return id_format_and_copy(vg->vgmem, &vg->id);
+}
+
 uint32_t vg_seqno(const struct volume_group *vg)
 {
 	return vg->seqno;
--- LVM2/lib/metadata/vg.h	2010/09/30 13:52:56	1.2
+++ LVM2/lib/metadata/vg.h	2010/09/30 14:07:47	1.3
@@ -124,5 +124,6 @@
 uint64_t vg_mda_size(const struct volume_group *vg);
 uint64_t vg_mda_free(const struct volume_group *vg);
 char *vg_attr_dup(struct dm_pool *mem, const struct volume_group *vg);
+char *vg_uuid_dup(const struct volume_group *vg);
 
 #endif
--- LVM2/liblvm/lvm_lv.c	2010/08/17 16:25:35	1.25
+++ LVM2/liblvm/lvm_lv.c	2010/09/30 14:07:48	1.26
@@ -14,7 +14,7 @@
 
 #include "lib.h"
 #include "lvm2app.h"
-#include "metadata-exported.h"
+#include "metadata.h"
 #include "lvm-string.h"
 #include "defaults.h"
 #include "segtype.h"
@@ -39,13 +39,7 @@
 
 const char *lvm_lv_get_uuid(const lv_t lv)
 {
-	char uuid[64] __attribute__((aligned(8)));
-
-	if (!id_write_format(&lv->lvid.id[1], uuid, sizeof(uuid))) {
-		log_error(INTERNAL_ERROR "unable to convert uuid");
-		return NULL;
-	}
-	return dm_pool_strndup(lv->vg->vgmem, (const char *)uuid, 64);
+	return lv_uuid_dup(lv);
 }
 
 const char *lvm_lv_get_name(const lv_t lv)
--- LVM2/liblvm/lvm_pv.c	2010/07/09 15:34:47	1.12
+++ LVM2/liblvm/lvm_pv.c	2010/09/30 14:07:48	1.13
@@ -14,18 +14,12 @@
 
 #include "lib.h"
 #include "lvm2app.h"
-#include "metadata-exported.h"
+#include "metadata.h"
 #include "lvm-string.h"
 
 const char *lvm_pv_get_uuid(const pv_t pv)
 {
-	char uuid[64] __attribute__((aligned(8)));
-
-	if (!id_write_format(&pv->id, uuid, sizeof(uuid))) {
-		log_error(INTERNAL_ERROR "Unable to convert uuid");
-		return NULL;
-	}
-	return dm_pool_strndup(pv->vg->vgmem, (const char *)uuid, 64);
+	return pv_uuid_dup(pv);
 }
 
 const char *lvm_pv_get_name(const pv_t pv)
--- LVM2/liblvm/lvm_vg.c	2010/07/09 16:57:34	1.43
+++ LVM2/liblvm/lvm_vg.c	2010/09/30 14:07:48	1.44
@@ -327,13 +327,7 @@
 
 const char *lvm_vg_get_uuid(const vg_t vg)
 {
-	char uuid[64] __attribute__((aligned(8)));
-
-	if (!id_write_format(&vg->id, uuid, sizeof(uuid))) {
-		log_error(INTERNAL_ERROR "Unable to convert uuid");
-		return NULL;
-	}
-	return dm_pool_strndup(vg->vgmem, (const char *)uuid, 64);
+	return vg_uuid_dup(vg);
 }
 
 const char *lvm_vg_get_name(const vg_t vg)


