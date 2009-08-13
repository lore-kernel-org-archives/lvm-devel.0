From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 13 Aug 2009 12:18:15 -0000
Subject: LVM2/liblvm lvm2app.h lvm_pv.c
Message-ID: <20090813121815.8191.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-08-13 12:18:15

Modified files:
	liblvm         : lvm2app.h lvm_pv.c 

Log message:
	Make lvm2app pv_t handle definition consistent with lvm_t.
	
	This patch update pv_t handle to be consistent with lvm_t - define as a pointer
	to internal struct physical_volume.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm2app.h.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_pv.c.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/liblvm/lvm2app.h	2009/08/13 12:17:32	1.5
+++ LVM2/liblvm/lvm2app.h	2009/08/13 12:18:15	1.6
@@ -130,7 +130,7 @@
  * group.  Changes will be written to disk when the volume group gets
  * committed to disk.
  */
-typedef struct physical_volume pv_t;
+typedef struct physical_volume *pv_t;
 
 /**
  * Logical Volume object list.
@@ -149,7 +149,7 @@
  */
 typedef struct lvm_pv_list {
 	struct dm_list list;
-	pv_t *pv;
+	pv_t pv;
 } pv_list_t;
 
 /**
@@ -781,7 +781,7 @@
  * \return
  * Copy of the uuid string.
  */
-char *lvm_pv_get_uuid(const pv_t *pv);
+char *lvm_pv_get_uuid(const pv_t pv);
 
 /**
  * Get the current name of a logical volume.
@@ -795,7 +795,7 @@
  * \return
  * Copy of the name.
  */
-char *lvm_pv_get_name(const pv_t *pv);
+char *lvm_pv_get_name(const pv_t pv);
 
 /**
  * Get the current number of metadata areas in the physical volume.
@@ -806,7 +806,7 @@
  * \return
  * Number of metadata areas in the PV.
  */
-uint64_t lvm_pv_get_mda_count(const pv_t *pv);
+uint64_t lvm_pv_get_mda_count(const pv_t pv);
 
 /**
  * Resize physical volume to new_size bytes.
@@ -822,6 +822,6 @@
  * \return
  * 0 (success) or -1 (failure).
  */
-int lvm_pv_resize(const pv_t *pv, uint64_t new_size);
+int lvm_pv_resize(const pv_t pv, uint64_t new_size);
 
 #endif /* _LIB_LVM2APP_H */
--- LVM2/liblvm/lvm_pv.c	2009/07/29 13:26:01	1.6
+++ LVM2/liblvm/lvm_pv.c	2009/08/13 12:18:15	1.7
@@ -17,7 +17,7 @@
 #include "metadata-exported.h"
 #include "lvm-string.h"
 
-char *lvm_pv_get_uuid(const pv_t *pv)
+char *lvm_pv_get_uuid(const pv_t pv)
 {
 	char uuid[64] __attribute((aligned(8)));
 
@@ -28,7 +28,7 @@
 	return strndup((const char *)uuid, 64);
 }
 
-char *lvm_pv_get_name(const pv_t *pv)
+char *lvm_pv_get_name(const pv_t pv)
 {
 	char *name;
 
@@ -38,12 +38,12 @@
 	return name;
 }
 
-uint64_t lvm_pv_get_mda_count(const pv_t *pv)
+uint64_t lvm_pv_get_mda_count(const pv_t pv)
 {
 	return (uint64_t) pv_mda_count(pv);
 }
 
-int lvm_pv_resize(const pv_t *pv, uint64_t new_size)
+int lvm_pv_resize(const pv_t pv, uint64_t new_size)
 {
 	/* FIXME: add pv resize code here */
 	log_error("NOT IMPLEMENTED YET");


