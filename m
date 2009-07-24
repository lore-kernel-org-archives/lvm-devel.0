From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 24 Jul 2009 12:48:21 -0000
Subject: LVM2/liblvm .exported_symbols lvm.h lvm_vg.c
Message-ID: <20090724124821.21938.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-24 12:48:21

Modified files:
	liblvm         : .exported_symbols lvm.h lvm_vg.c 

Log message:
	Add lvm_scan_vgs liblvm fn to scan the system for LVM metadata.
	
	The lvm_list_vg_{names|ids} functions do not do a scan so we provide
	a liblvm function that does a scan.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/.exported_symbols.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm.h.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_vg.c.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/liblvm/.exported_symbols	2009/07/24 12:47:15	1.7
+++ LVM2/liblvm/.exported_symbols	2009/07/24 12:48:21	1.8
@@ -14,6 +14,7 @@
 lvm_vg_open
 lvm_vg_close
 lvm_vg_remove
+lvm_scan_vgs
 lvm_errno
 lvm_errmsg
 lvm_vg_list_pvs
--- LVM2/liblvm/lvm.h	2009/07/24 12:47:15	1.11
+++ LVM2/liblvm/lvm.h	2009/07/24 12:48:21	1.12
@@ -265,6 +265,8 @@
  * Return a list of VG names or VG uuids in the system.
  *
  * NOTE: This function will _NOT_ scan devices in the system for LVM metadata.
+ * To scan the system, use lvm_scan_vgs.
+ *
  * To process the list, use the dm_list iterator functions.  For example:
  *      vg_t *vg;
  *      struct dm_list *vgnames;
@@ -286,5 +288,11 @@
 struct dm_list *lvm_list_vg_names(lvm_t libh);
 struct dm_list *lvm_list_vg_ids(lvm_t libh);
 
+/**
+ * Scan all devices on the system for VGs and LVM metadata.
+ *
+ * \return  Status code of 1 (success) or 0 (failure).
+ */
+int lvm_scan_vgs(lvm_t libh);
 
 #endif /* _LIB_LVM_H */
--- LVM2/liblvm/lvm_vg.c	2009/07/24 12:47:15	1.7
+++ LVM2/liblvm/lvm_vg.c	2009/07/24 12:48:21	1.8
@@ -22,6 +22,7 @@
 #include "archiver.h"
 #include "locking.h"
 #include "lvm-string.h"
+#include "lvmcache.h"
 
 vg_t *lvm_vg_create(lvm_t libh, const char *vg_name)
 {
@@ -198,3 +199,8 @@
 {
 	return get_vgids((struct cmd_context *)libh, 0);
 }
+
+int lvm_scan_vgs(lvm_t libh)
+{
+	return lvmcache_label_scan((struct cmd_context *)libh, 2);
+}


