From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 23 Jul 2009 23:37:25 -0000
Subject: LVM2/liblvm lvm.h
Message-ID: <20090723233725.19985.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-23 23:37:24

Modified files:
	liblvm         : lvm.h 

Log message:
	Add list structure definitions for liblvm objects.
	
	- pv_t, vg_t, lv_t
	- include libdevmapper.h: needed for struct dm_list
	
	These list structures will be needed in later APIs to return a list of
	handles to one object, given another object.  For example, lvm_vg_list_lvs()
	will return a list of LV handles (lv_t's) given a VG handle (vg_t).  We
	need a structure to do this so we define the LV structure, as well as the
	other structures at this point.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm.h.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/liblvm/lvm.h	2009/07/23 23:36:20	1.7
+++ LVM2/liblvm/lvm.h	2009/07/23 23:37:24	1.8
@@ -15,6 +15,7 @@
 #define _LIB_LVM_H
 
 #include "lvm-version.h"
+#include "libdevmapper.h"
 
 #include <stdint.h>
 
@@ -28,6 +29,22 @@
 typedef struct physical_volume pv_t;
 typedef struct logical_volume lv_t;
 
+typedef struct lvm_vg_list {
+	struct dm_list list;
+	vg_t *vg;
+} vg_list_t;
+
+typedef struct lvm_pv_list {
+	struct dm_list list;
+	pv_t *pv;
+} pv_list_t;
+
+typedef struct lvm_lv_list {
+	struct dm_list list;
+	lv_t *lv;
+} lv_list_t;
+
+
 struct lvm; /* internal data */
 
 /**


