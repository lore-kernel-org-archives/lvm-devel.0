From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 26 Jul 2009 16:44:06 -0000
Subject: LVM2 liblvm/.exported_symbols liblvm/lvm.h lib ...
Message-ID: <20090726164406.23895.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-26 16:44:05

Modified files:
	liblvm         : .exported_symbols lvm.h lvm_vg.c 
	test/api       : test.c 

Log message:
	Rename lvm_scan_vgs to lvm_scan.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/.exported_symbols.diff?cvsroot=lvm2&r1=1.14&r2=1.15
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm.h.diff?cvsroot=lvm2&r1=1.21&r2=1.22
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_vg.c.diff?cvsroot=lvm2&r1=1.14&r2=1.15
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/test.c.diff?cvsroot=lvm2&r1=1.12&r2=1.13

--- LVM2/liblvm/.exported_symbols	2009/07/26 16:06:46	1.14
+++ LVM2/liblvm/.exported_symbols	2009/07/26 16:44:05	1.15
@@ -22,7 +22,7 @@
 lvm_vg_open
 lvm_vg_close
 lvm_vg_remove
-lvm_scan_vgs
+lvm_scan
 lvm_errno
 lvm_errmsg
 lvm_vg_list_pvs
--- LVM2/liblvm/lvm.h	2009/07/26 16:35:57	1.21
+++ LVM2/liblvm/lvm.h	2009/07/26 16:44:05	1.22
@@ -176,7 +176,7 @@
  *
  * \return  Status code of 1 (success) or 0 (failure).
  */
-int lvm_scan_vgs(lvm_t libh);
+int lvm_scan(lvm_t libh);
 
 /*************************** volume group handling **************************/
 
@@ -184,7 +184,7 @@
  * Return the list of volume group names.
  *
  * NOTE: This function will _NOT_ scan devices in the system for LVM metadata.
- * To scan the system, use lvm_scan_vgs.
+ * To scan the system, use lvm_scan.
  *
  * To process the list, use the dm_list iterator functions.  For example:
  *      vg_t *vg;
@@ -211,7 +211,7 @@
  * Return the list of volume group uuids.
  *
  * NOTE: This function will _NOT_ scan devices in the system for LVM metadata.
- * To scan the system, use lvm_scan_vgs.
+ * To scan the system, use lvm_scan.
  *
  * \param   libh
  *          Handle obtained from lvm_create.
--- LVM2/liblvm/lvm_vg.c	2009/07/26 16:06:46	1.14
+++ LVM2/liblvm/lvm_vg.c	2009/07/26 16:44:05	1.15
@@ -252,7 +252,7 @@
 	return get_vgids((struct cmd_context *)libh, 0);
 }
 
-int lvm_scan_vgs(lvm_t libh)
+int lvm_scan(lvm_t libh)
 {
 	return lvmcache_label_scan((struct cmd_context *)libh, 2);
 }
--- LVM2/test/api/test.c	2009/07/26 16:06:46	1.12
+++ LVM2/test/api/test.c	2009/07/26 16:44:05	1.13
@@ -264,7 +264,7 @@
 
 static void _scan_vgs(lvm_t libh)
 {
-	lvm_scan_vgs(libh);
+	lvm_scan(libh);
 }
 
 static void _list_vg_names(lvm_t libh)


