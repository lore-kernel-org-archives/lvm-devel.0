From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 26 Jul 2009 16:49:52 -0000
Subject: LVM2/liblvm lvm.h
Message-ID: <20090726164952.26214.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-26 16:49:52

Modified files:
	liblvm         : lvm.h 

Log message:
	A few more lvm.h updates that got missed.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm.h.diff?cvsroot=lvm2&r1=1.22&r2=1.23

--- LVM2/liblvm/lvm.h	2009/07/26 16:44:05	1.22
+++ LVM2/liblvm/lvm.h	2009/07/26 16:49:52	1.23
@@ -38,11 +38,11 @@
 /**
  * Physical volume object.
  *
- * This object can be either a read-only object or a read-write object and
- * depends on the mode of the volume group.  This object can not be
- * written to disk independently, and changes will be written to disk
- * when the volume group gets committed to disk. The open mode is the
- * same as the volume group object it was created from.
+ * This object can be either a read-only object or a read-write object
+ * depending on the mode it was returned by a function. This object can not be
+ * written to disk independently, it is bound to a volume group and changes
+ * will be written to disk when the volume group gets committed to disk. The
+ * open mode is the same as the volume group object is was created of.
  */
 typedef struct physical_volume pv_t;
 
@@ -326,7 +326,7 @@
  * \param   vg
  *          VG handle obtained from lvm_vg_create or lvm_vg_open.
  * \param   new_size
- *          New extent size to set (in sectors).
+ *          New extent size in bytes.
  * \return  Status code of 1 (success) or 0 (failure).
  */
 int lvm_vg_set_extent_size(vg_t *vg, uint32_t new_size);


