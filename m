From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 30 Sep 2010 14:08:22 -0000
Subject: LVM2/lib/metadata lv.c lv.h pv.c pv.h vg.c vg.h
Message-ID: <20100930140822.17482.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-09-30 14:08:20

Modified files:
	lib/metadata   : lv.c lv.h pv.c pv.h vg.c vg.h 

Log message:
	Add pv_tags_dup, vg_tags_dup, lv_tags_dup functions that call tags_format_and_copy.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv.c.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv.h.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/pv.c.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/pv.h.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/vg.c.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/vg.h.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/lib/metadata/lv.c	2010/09/30 14:07:47	1.4
+++ LVM2/lib/metadata/lv.c	2010/09/30 14:08:19	1.5
@@ -21,6 +21,11 @@
 	return id_format_and_copy(lv->vg->vgmem, &lv->lvid.id[1]);
 }
 
+char *lv_tags_dup(const struct logical_volume *lv)
+{
+	return tags_format_and_copy(lv->vg->vgmem, &lv->tags);
+}
+
 uint64_t lv_size(const struct logical_volume *lv)
 {
 	return lv->size;
--- LVM2/lib/metadata/lv.h	2010/09/30 14:07:47	1.3
+++ LVM2/lib/metadata/lv.h	2010/09/30 14:08:20	1.4
@@ -50,5 +50,6 @@
 uint64_t lv_size(const struct logical_volume *lv);
 char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv);
 char *lv_uuid_dup(const struct logical_volume *lv);
+char *lv_tags_dup(const struct logical_volume *lv);
 
 #endif
--- LVM2/lib/metadata/pv.c	2010/09/30 14:07:47	1.4
+++ LVM2/lib/metadata/pv.c	2010/09/30 14:08:20	1.5
@@ -34,6 +34,11 @@
 	return id_format_and_copy(pv->vg->vgmem, &pv->id);
 }
 
+char *pv_tags_dup(const struct physical_volume *pv)
+{
+	return tags_format_and_copy(pv->vg->vgmem, &pv->tags);
+}
+
 const struct format_type *pv_format_type(const struct physical_volume *pv)
 {
 	return pv_field(pv, fmt);
--- LVM2/lib/metadata/pv.h	2010/09/30 14:07:47	1.3
+++ LVM2/lib/metadata/pv.h	2010/09/30 14:08:20	1.4
@@ -57,6 +57,7 @@
 char *pv_attr_dup(struct dm_pool *mem, const struct physical_volume *pv);
 const char *pv_dev_name(const struct physical_volume *pv);
 char *pv_uuid_dup(const struct physical_volume *pv);
+char *pv_tags_dup(const struct physical_volume *pv);
 uint64_t pv_size(const struct physical_volume *pv);
 uint64_t pv_size_field(const struct physical_volume *pv);
 uint64_t pv_dev_size(const struct physical_volume *pv);
--- LVM2/lib/metadata/vg.c	2010/09/30 14:07:47	1.4
+++ LVM2/lib/metadata/vg.c	2010/09/30 14:08:20	1.5
@@ -21,6 +21,11 @@
 	return id_format_and_copy(vg->vgmem, &vg->id);
 }
 
+char *vg_tags_dup(const struct volume_group *vg)
+{
+	return tags_format_and_copy(vg->vgmem, &vg->tags);
+}
+
 uint32_t vg_seqno(const struct volume_group *vg)
 {
 	return vg->seqno;
--- LVM2/lib/metadata/vg.h	2010/09/30 14:07:47	1.3
+++ LVM2/lib/metadata/vg.h	2010/09/30 14:08:20	1.4
@@ -125,5 +125,6 @@
 uint64_t vg_mda_free(const struct volume_group *vg);
 char *vg_attr_dup(struct dm_pool *mem, const struct volume_group *vg);
 char *vg_uuid_dup(const struct volume_group *vg);
+char *vg_tags_dup(const struct volume_group *vg);
 
 #endif


