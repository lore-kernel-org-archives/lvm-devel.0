From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 14 Sep 2009 15:45:25 -0000
Subject: LVM2 lib/metadata/metadata-exported.h lib/meta ...
Message-ID: <20090914154525.3817.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-09-14 15:45:24

Modified files:
	lib/metadata   : metadata-exported.h metadata.c 
	liblvm         : lvm2app.h lvm_vg.c 

Log message:
	Add max_pv and max_lv vg 'get' lvm2app exports.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.109&r2=1.110
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.282&r2=1.283
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm2app.h.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_vg.c.diff?cvsroot=lvm2&r1=1.28&r2=1.29

--- LVM2/lib/metadata/metadata-exported.h	2009/09/02 21:39:29	1.109
+++ LVM2/lib/metadata/metadata-exported.h	2009/09/14 15:45:23	1.110
@@ -717,6 +717,8 @@
 uint64_t vg_extent_count(const struct volume_group *vg);
 uint64_t vg_free_count(const struct volume_group *vg);
 uint64_t vg_pv_count(const struct volume_group *vg);
+uint64_t vg_max_pv(const struct volume_group *vg);
+uint64_t vg_max_lv(const struct volume_group *vg);
 int vg_check_write_mode(struct volume_group *vg);
 #define vg_is_clustered(vg) (vg_status((vg)) & CLUSTERED)
 
--- LVM2/lib/metadata/metadata.c	2009/09/02 21:39:49	1.282
+++ LVM2/lib/metadata/metadata.c	2009/09/14 15:45:23	1.283
@@ -3525,6 +3525,16 @@
 	return (uint64_t) vg->pv_count;
 }
 
+uint64_t vg_max_pv(const struct volume_group *vg)
+{
+	return (uint64_t) vg->max_pv;
+}
+
+uint64_t vg_max_lv(const struct volume_group *vg)
+{
+	return (uint64_t) vg->max_lv;
+}
+
 uint64_t lv_size(const struct logical_volume *lv)
 {
 	return lv->size;
--- LVM2/liblvm/lvm2app.h	2009/09/02 21:40:10	1.7
+++ LVM2/liblvm/lvm2app.h	2009/09/14 15:45:23	1.8
@@ -589,6 +589,28 @@
  */
 uint64_t lvm_vg_get_pv_count(const vg_t vg);
 
+/**
+ * Get the maximum number of physical volumes allowed in a volume group.
+ *
+ * \param   vg
+ * VG handle obtained from lvm_vg_create or lvm_vg_open.
+ *
+ * \return
+ * Maximum number of physical volumes allowed in a volume group.
+ */
+uint64_t lvm_vg_get_max_pv(const vg_t vg);
+
+/**
+ * Get the maximum number of logical volumes allowed in a volume group.
+ *
+ * \param   vg
+ * VG handle obtained from lvm_vg_create or lvm_vg_open.
+ *
+ * \return
+ * Maximum number of logical volumes allowed in a volume group.
+ */
+uint64_t lvm_vg_get_max_lv(const vg_t vg);
+
 /************************** logical volume handling *************************/
 
 /**
--- LVM2/liblvm/lvm_vg.c	2009/09/02 21:40:10	1.28
+++ LVM2/liblvm/lvm_vg.c	2009/09/14 15:45:23	1.29
@@ -274,6 +274,16 @@
 	return vg_pv_count(vg);
 }
 
+uint64_t lvm_vg_get_max_pv(const vg_t vg)
+{
+	return vg_max_pv(vg);
+}
+
+uint64_t lvm_vg_get_max_lv(const vg_t vg)
+{
+	return vg_max_lv(vg);
+}
+
 char *lvm_vg_get_uuid(const vg_t vg)
 {
 	char uuid[64] __attribute((aligned(8)));


