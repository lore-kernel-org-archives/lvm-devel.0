From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 26 Jul 2009 16:11:58 -0000
Subject: LVM2/liblvm lvm.h
Message-ID: <20090726161158.13572.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-26 16:11:58

Modified files:
	liblvm         : lvm.h 

Log message:
	Update lvm.h handle and handle list comments.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm.h.diff?cvsroot=lvm2&r1=1.19&r2=1.20

--- LVM2/liblvm/lvm.h	2009/07/26 16:06:46	1.19
+++ LVM2/liblvm/lvm.h	2009/07/26 16:11:58	1.20
@@ -19,31 +19,92 @@
 
 #include <stdint.h>
 
-/* Internal object structures */
-struct volume_group;
+/******************************** structures ********************************/
+
+/* Internal object structures - do not use directly */
+struct lvm;
 struct physical_volume;
+struct volume_group;
 struct logical_volume;
 
-/* liblvm handles to objects pv, vg, lv, pvseg, lvseg */
-typedef struct volume_group vg_t;
+/**
+ * lvm handle.
+ *
+ * This is the base handle that is needed to open and create objects. Also
+ * error handling is bound to this handle.
+ */
+typedef struct lvm *lvm_t;
+
+/**
+ * Physical volume object.
+ *
+ * This object can be either a read-only object or a read-write object and
+ * depends on the mode of the volume group.  This object can not be
+ * written to disk independently, and changes will be written to disk
+ * when the volume group gets committed to disk. The open mode is the
+ * same as the volume group object it was created from.
+ */
 typedef struct physical_volume pv_t;
-typedef struct logical_volume lv_t;
 
-typedef struct lvm_vg_list {
-	struct dm_list list;
-	vg_t *vg;
-} vg_list_t;
+/**
+ * Volume group object.
+ *
+ * This object can be either a read-only object or a read-write object
+ * depending on the mode it was returned by a function. Create functions
+ * return a read-write object, but open functions have the argument mode to
+ * define if the object can be modified or not.
+ */
+typedef struct volume_group vg_t;
+
+/**
+ * Logical Volume object.
+ *
+ * This object can be either a read-only object or a read-write object
+ * depending on the mode it was returned by a function. This object can not be
+ * written to disk independently, it is bound to a volume group and changes
+ * will be written to disk when the volume group gets committed to disk. The
+ * open mode is the same as the volume group object is was created of.
+ */
+typedef struct logical_volume lv_t;
 
+/**
+ * Physical volume object list.
+ *
+ * The properties of physical volume objects also applies to the list of
+ * physical volumes.
+ */
 typedef struct lvm_pv_list {
 	struct dm_list list;
 	pv_t *pv;
 } pv_list_t;
 
+/**
+ * Volume group object list.
+ *
+ * The properties of volume group objects also applies to the list of
+ * volume groups.
+ */
+typedef struct lvm_vg_list {
+	struct dm_list list;
+	vg_t *vg;
+} vg_list_t;
+
+/**
+ * Logical Volume object list.
+ *
+ * The properties of logical volume objects also applies to the list of
+ * logical volumes.
+ */
 typedef struct lvm_lv_list {
 	struct dm_list list;
 	lv_t *lv;
 } lv_list_t;
 
+/**
+ * String list.
+ *
+ * This string list contains read-only strings.
+ */
 struct lvm_str_list {
 	struct dm_list list;
 	const char *str;
@@ -56,13 +117,7 @@
  *          If no LVs exist on the given VG, NULL is returned.
  */
 struct dm_list *lvm_vg_list_lvs(vg_t *vg);
-
-struct lvm; /* internal data */
-
-/**
- * The lvm handle.
- */
-typedef struct lvm *lvm_t;
+/*************************** generic lvm handling ***************************/
 
 /**
  * Create a LVM handle.


