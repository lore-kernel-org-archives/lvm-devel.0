From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 27 Jul 2009 08:28:13 -0000
Subject: LVM2/liblvm lvm.h
Message-ID: <20090727082813.21162.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-27 08:28:13

Modified files:
	liblvm         : lvm.h 

Log message:
	More liblvm header file cleanups.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm.h.diff?cvsroot=lvm2&r1=1.26&r2=1.27

--- LVM2/liblvm/lvm.h	2009/07/26 20:58:11	1.26
+++ LVM2/liblvm/lvm.h	2009/07/27 08:28:13	1.27
@@ -38,11 +38,11 @@
 /**
  * Physical volume object.
  *
- * This object can be either a read-only object or a read-write object
- * depending on the mode it was returned by a function. This object can not be
- * written to disk independently, it is bound to a volume group and changes
- * will be written to disk when the volume group gets committed to disk. The
- * open mode is the same as the volume group object is was created of.
+ * This object can be either a read-only object or a read-write object and
+ * depends on the mode of the volume group.  This object can not be
+ * written to disk independently, and changes will be written to disk
+ * when the volume group gets committed to disk. The open mode is the
+ * same as the volume group object it was created from.
  */
 typedef struct physical_volume pv_t;
 
@@ -60,10 +60,10 @@
  * Logical Volume object.
  *
  * This object can be either a read-only object or a read-write object
- * depending on the mode it was returned by a function. This object can not be
+ * depending on the mode of the volume group. This object can not be
  * written to disk independently, it is bound to a volume group and changes
  * will be written to disk when the volume group gets committed to disk. The
- * open mode is the same as the volume group object is was created of.
+ * open mode is the same as the volume group object is was created from.
  */
 typedef struct logical_volume lv_t;
 
@@ -287,7 +287,7 @@
 int lvm_vg_remove(vg_t *vg);
 
 /**
- * Close a VG opened with lvm_vg_create
+ * Close a VG opened with lvm_vg_create or lvm_vg_open.
  *
  * This API releases a VG handle and any resources associated with the handle.
  *


