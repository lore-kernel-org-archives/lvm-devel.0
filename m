From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 14 Jul 2009 03:00:32 -0000
Subject: LVM2 lib/metadata/metadata-exported.h liblvm/lvm.h
Message-ID: <20090714030032.29643.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-14 03:00:31

Modified files:
	lib/metadata   : metadata-exported.h 
	liblvm         : lvm.h 

Log message:
	Define handles to liblvm objects for pv, vg, lv, lvseg, pvseg.
	
	Define the 5 main liblvm objects to be the pv, vg, lv, lvseg, and pvseg.
	We need handles defined to all these objects in order for liblvm to be
	equivalent to the reporting commands pvs, vgs, and lvs.
	
	- move vg_t, lv_t, and pv_t from metadata-exported.h into lvm.h
	- move lv_segment and pv_segment forward declarations into lvm.h
	- add lvseg_t and pvseg_t to lvm.h
	
	NOTE: We currently have an inconsistency in handle definitions.
	lvm_t is defined as a pointer, while these other handles are just
	structures.  We should pick one scheme and be consistent - perhaps
	define all handles as pointers (this is what I've seen elsewhere).
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
	Acked-by: Alasdair G Kergon <agk@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.92&r2=1.93
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm.h.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/lib/metadata/metadata-exported.h	2009/07/14 02:19:19	1.92
+++ LVM2/lib/metadata/metadata-exported.h	2009/07/14 03:00:30	1.93
@@ -22,16 +22,7 @@
 #define _LVM_METADATA_EXPORTED_H
 
 #include "uuid.h"
-
-struct physical_volume;
-typedef struct physical_volume pv_t;
-struct volume_group;
-typedef struct volume_group vg_t;
-
-struct logical_volume;
-
-struct lv_segment;
-struct pv_segment;
+#include "lvm.h"
 
 #define MAX_STRIPES 128U
 #define SECTOR_SHIFT 9L
--- LVM2/liblvm/lvm.h	2009/03/06 22:49:49	1.1
+++ LVM2/liblvm/lvm.h	2009/07/14 03:00:31	1.2
@@ -18,6 +18,20 @@
 
 #include <stdint.h>
 
+/* Internal object structures */
+struct volume_group;
+struct physical_volume;
+struct logical_volume;
+struct lv_segment;
+struct pv_segment;
+
+/* liblvm handles to objects pv, vg, lv, pvseg, lvseg */
+typedef struct volume_group vg_t;
+typedef struct physical_volume pv_t;
+typedef struct logical_volume lv_t;
+typedef struct pv_segment pvseg_t;
+typedef struct lv_segment lvseg_t;
+
 struct lvm; /* internal data */
 
 /**
@@ -54,4 +68,5 @@
  */
 int lvm_reload_config(lvm_t libh);
 
+
 #endif /* _LIB_LVM_H */


