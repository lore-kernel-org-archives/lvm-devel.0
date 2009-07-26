From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 26 Jul 2009 20:58:12 -0000
Subject: LVM2/liblvm .exported_symbols lvm.h lvm_lv.c
Message-ID: <20090726205812.390.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-26 20:58:11

Modified files:
	liblvm         : .exported_symbols lvm.h lvm_lv.c 

Log message:
	Add lvm_lv_is_active and lvm_lv_is_suspended.
	
	Return whether an LV is active in the kernel (live table) or suspended
	(table suspend).
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/.exported_symbols.diff?cvsroot=lvm2&r1=1.16&r2=1.17
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm.h.diff?cvsroot=lvm2&r1=1.25&r2=1.26
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_lv.c.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/liblvm/.exported_symbols	2009/07/26 20:57:37	1.16
+++ LVM2/liblvm/.exported_symbols	2009/07/26 20:58:11	1.17
@@ -17,6 +17,8 @@
 lvm_lv_get_uuid
 lvm_lv_get_name
 lvm_lv_get_size
+lvm_lv_is_active
+lvm_lv_is_suspended
 lvm_vg_create
 lvm_vg_extend
 lvm_vg_set_extent_size
--- LVM2/liblvm/lvm.h	2009/07/26 20:57:37	1.25
+++ LVM2/liblvm/lvm.h	2009/07/26 20:58:11	1.26
@@ -516,6 +516,24 @@
  */
 uint64_t lvm_lv_get_size(const lv_t *lv);
 
+/**
+ * Get the current activation state of a logical volume.
+ *
+ * \param   lv
+ *          Logical volume handle.
+ * \return  1 if the LV is active in the kernel, 0 if not
+ */
+uint64_t lvm_lv_is_active(const lv_t *lv);
+
+/**
+ * Get the current suspended state of a logical volume.
+ *
+ * \param   lv
+ *          Logical volume handle.
+ * \return  1 if the LV is suspended in the kernel, 0 if not
+ */
+uint64_t lvm_lv_is_suspended(const lv_t *lv);
+
 /************************** physical volume handling ************************/
 
 /**
--- LVM2/liblvm/lvm_lv.c	2009/07/26 20:57:37	1.6
+++ LVM2/liblvm/lvm_lv.c	2009/07/26 20:58:11	1.7
@@ -19,6 +19,7 @@
 #include "defaults.h"
 #include "segtype.h"
 #include "locking.h"
+#include "activate.h"
 
 #include <string.h>
 
@@ -49,6 +50,24 @@
 	return name;
 }
 
+uint64_t lvm_lv_is_active(const lv_t *lv)
+{
+	struct lvinfo info;
+	if (lv_info(lv->vg->cmd, lv, &info, 1, 0) &&
+	    info.exists && info.live_table)
+		return 1;
+	return 0;
+}
+
+uint64_t lvm_lv_is_suspended(const lv_t *lv)
+{
+	struct lvinfo info;
+	if (lv_info(lv->vg->cmd, lv, &info, 1, 0) &&
+	    info.exists && info.suspended)
+		return 1;
+	return 0;
+}
+
 /* Set defaults for non-segment specific LV parameters */
 static void _lv_set_default_params(struct lvcreate_params *lp,
 				   vg_t *vg, const char *lvname,


