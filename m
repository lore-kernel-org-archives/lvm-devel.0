From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 28 Jul 2009 13:17:05 -0000
Subject: LVM2 lib/metadata/metadata-exported.h lib/meta ...
Message-ID: <20090728131705.1453.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-28 13:17:04

Modified files:
	lib/metadata   : metadata-exported.h metadata.c 
	liblvm         : .exported_symbols lvm.h lvm_vg.c 
	test/api       : test.c 

Log message:
	Add lvm_vg_get_seqno, updating lvm.h and unit test.
	
	Adding the ability to get the seqno is important for an application to
	determine if something has changed in a VG.  Otherwise, the only way to
	know is to open the VG with write permission and hold the handle.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.103&r2=1.104
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.270&r2=1.271
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/.exported_symbols.diff?cvsroot=lvm2&r1=1.21&r2=1.22
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm.h.diff?cvsroot=lvm2&r1=1.39&r2=1.40
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_vg.c.diff?cvsroot=lvm2&r1=1.21&r2=1.22
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/test.c.diff?cvsroot=lvm2&r1=1.20&r2=1.21

--- LVM2/lib/metadata/metadata-exported.h	2009/07/27 17:43:40	1.103
+++ LVM2/lib/metadata/metadata-exported.h	2009/07/28 13:17:04	1.104
@@ -705,6 +705,7 @@
 uint64_t lv_size(const lv_t *lv);
 
 int vg_missing_pv_count(const vg_t *vg);
+uint32_t vg_seqno(const vg_t *vg);
 uint32_t vg_status(const vg_t *vg);
 uint64_t vg_size(const vg_t *vg);
 uint64_t vg_free(const vg_t *vg);
--- LVM2/lib/metadata/metadata.c	2009/07/27 17:43:40	1.270
+++ LVM2/lib/metadata/metadata.c	2009/07/28 13:17:04	1.271
@@ -3424,6 +3424,11 @@
 	return info ? dm_list_size(&info->mdas) : UINT64_C(0);
 }
 
+uint32_t vg_seqno(const vg_t *vg)
+{
+	return vg->seqno;
+}
+
 uint32_t vg_status(const vg_t *vg)
 {
 	return vg->status;
--- LVM2/liblvm/.exported_symbols	2009/07/28 11:03:28	1.21
+++ LVM2/liblvm/.exported_symbols	2009/07/28 13:17:04	1.22
@@ -6,6 +6,7 @@
 lvm_pv_get_name
 lvm_pv_get_uuid
 lvm_pv_get_mda_count
+lvm_vg_get_seqno
 lvm_vg_get_name
 lvm_vg_get_uuid
 lvm_vg_get_size
--- LVM2/liblvm/lvm.h	2009/07/28 13:16:40	1.39
+++ LVM2/liblvm/lvm.h	2009/07/28 13:17:04	1.40
@@ -49,6 +49,17 @@
  * A volume group handle may be obtained with read or write permission.
  * Any attempt to change a property of a pv_t, vg_t, or lv_t without
  * obtaining write permission on the vg_t will fail with EPERM.
+ *
+ * An application first opening a VG read-only, then later wanting to change
+ * a property of an object must first close the VG and re-open with write
+ * permission. Currently liblvm provides no mechanism to determine whether
+ * the VG has changed on-disk in between these operations - this is the
+ * application's responsiblity. One way the application can ensure the VG
+ * has not changed is to save the "vg_seqno" field after opening the VG with
+ * READ permission. If the application later needs to modify the VG, it can
+ * close the VG and re-open with WRITE permission. It should then check
+ * whether the original "vg_seqno" obtained with READ permission matches
+ * the new one obtained with WRITE permission.
  */
 
 /**
@@ -470,6 +481,21 @@
 int lvm_vg_set_extent_size(vg_t *vg, uint32_t new_size);
 
 /**
+ * Get the current metadata sequence number of a volume group.
+ *
+ * The metadata sequence number is incrented for each metadata change.
+ * Applications may use the sequence number to determine if any LVM objects
+ * have changed from a prior query.
+ *
+ * \param   vg
+ * VG handle obtained from lvm_vg_create or lvm_vg_open.
+ *
+ * \return
+ * Metadata sequence number.
+ */
+uint64_t lvm_vg_get_seqno(const vg_t *vg);
+
+/**
  * Get the current name of a volume group.
  *
  * Memory is allocated using dm_malloc() and caller must free the memory
--- LVM2/liblvm/lvm_vg.c	2009/07/28 09:56:48	1.21
+++ LVM2/liblvm/lvm_vg.c	2009/07/28 13:17:04	1.22
@@ -223,6 +223,11 @@
 	return list;
 }
 
+uint64_t lvm_vg_get_seqno(const vg_t *vg)
+{
+	return vg_seqno(vg);
+}
+
 /* FIXME: invalid handle? return INTMAX? */
 uint64_t lvm_vg_get_size(const vg_t *vg)
 {
--- LVM2/test/api/test.c	2009/07/28 11:03:29	1.20
+++ LVM2/test/api/test.c	2009/07/28 13:17:04	1.21
@@ -345,10 +345,11 @@
 
 static void _show_one_vg(vg_t *vg)
 {
-	printf("%s (%s): size=%"PRIu64", free=%"PRIu64", #pv=%"PRIu64"\n",
+	printf("%s (%s): sz=%"PRIu64", free=%"PRIu64", #pv=%"PRIu64
+		", seq#=%"PRIu64"\n",
 		lvm_vg_get_name(vg), lvm_vg_get_uuid(vg),
 		lvm_vg_get_size(vg), lvm_vg_get_free_size(vg),
-		lvm_vg_get_pv_count(vg));
+		lvm_vg_get_pv_count(vg), lvm_vg_get_seqno(vg));
 }
 
 static void _list_open_vgs(void)


