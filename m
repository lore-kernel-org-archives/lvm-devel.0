From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 14 Sep 2009 19:43:13 -0000
Subject: LVM2 lib/metadata/metadata-exported.h liblvm/l ...
Message-ID: <20090914194313.5318.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-09-14 19:43:12

Modified files:
	lib/metadata   : metadata-exported.h 
	liblvm         : lvm2app.h lvm_vg.c 

Log message:
	Add most relevant vg_attr fields as lvm2app 'get' functions.
	
	Of the vgs field vg_attr, a few of the most likely to be used attributes
	are clustered, exported, and partial.  This patch adds the following 3
	functions:
	uint64_t lvm_vg_is_clustered(const vg_t vg)
	uint64_t lvm_vg_is_exported(const vg_t vg)
	uint64_t lvm_vg_is_partial(const vg_t vg)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.110&r2=1.111
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm2app.h.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_vg.c.diff?cvsroot=lvm2&r1=1.29&r2=1.30

--- LVM2/lib/metadata/metadata-exported.h	2009/09/14 15:45:23	1.110
+++ LVM2/lib/metadata/metadata-exported.h	2009/09/14 19:43:11	1.111
@@ -721,6 +721,7 @@
 uint64_t vg_max_lv(const struct volume_group *vg);
 int vg_check_write_mode(struct volume_group *vg);
 #define vg_is_clustered(vg) (vg_status((vg)) & CLUSTERED)
+#define vg_is_exported(vg) (vg_status((vg)) & EXPORTED_VG)
 
 struct vgcreate_params {
 	char *vg_name;
--- LVM2/liblvm/lvm2app.h	2009/09/14 15:45:23	1.8
+++ LVM2/liblvm/lvm2app.h	2009/09/14 19:43:12	1.9
@@ -481,6 +481,43 @@
 int lvm_vg_set_extent_size(vg_t vg, uint32_t new_size);
 
 /**
+ * Get whether or not a volume group is clustered.
+ *
+ * \param   vg
+ * VG handle obtained from lvm_vg_create or lvm_vg_open.
+ *
+ * \return
+ * 1 if the VG is clustered, 0 if not
+ */
+uint64_t lvm_vg_is_clustered(vg_t vg);
+
+/**
+ * Get whether or not a volume group is exported.
+ *
+ * \param   vg
+ * VG handle obtained from lvm_vg_create or lvm_vg_open.
+ *
+ * \return
+ * 1 if the VG is exported, 0 if not
+ */
+uint64_t lvm_vg_is_exported(vg_t vg);
+
+/**
+ * Get whether or not a volume group is a partial volume group.
+ *
+ * When one or more physical volumes belonging to the volume group
+ * are missing from the system the volume group is a partial volume
+ * group.
+ *
+ * \param   vg
+ * VG handle obtained from lvm_vg_create or lvm_vg_open.
+ *
+ * \return
+ * 1 if the VG is PVs, 0 if not
+ */
+uint64_t lvm_vg_is_partial(vg_t vg);
+
+/**
  * Get the current metadata sequence number of a volume group.
  *
  * The metadata sequence number is incrented for each metadata change.
--- LVM2/liblvm/lvm_vg.c	2009/09/14 15:45:23	1.29
+++ LVM2/liblvm/lvm_vg.c	2009/09/14 19:43:12	1.30
@@ -243,6 +243,21 @@
 	return vg_seqno(vg);
 }
 
+uint64_t lvm_vg_is_clustered(const vg_t vg)
+{
+	return vg_is_clustered(vg);
+}
+
+uint64_t lvm_vg_is_exported(const vg_t vg)
+{
+	return vg_is_exported(vg);
+}
+
+uint64_t lvm_vg_is_partial(const vg_t vg)
+{
+	return (vg_missing_pv_count(vg) != 0);
+}
+
 /* FIXME: invalid handle? return INTMAX? */
 uint64_t lvm_vg_get_size(const vg_t vg)
 {


