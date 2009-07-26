From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 26 Jul 2009 16:06:21 -0000
Subject: LVM2 liblvm/.exported_symbols liblvm/lvm.h lib ...
Message-ID: <20090726160621.12102.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-26 16:06:21

Modified files:
	liblvm         : .exported_symbols lvm.h lvm_vg.c 
	test/api       : test.c 

Log message:
	Rename lvm_list_vg_ids to lvm_list_vg_uuids.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/.exported_symbols.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm.h.diff?cvsroot=lvm2&r1=1.17&r2=1.18
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_vg.c.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/test.c.diff?cvsroot=lvm2&r1=1.10&r2=1.11

--- LVM2/liblvm/.exported_symbols	2009/07/26 16:05:49	1.12
+++ LVM2/liblvm/.exported_symbols	2009/07/26 16:06:21	1.13
@@ -28,6 +28,6 @@
 lvm_vg_list_pvs
 lvm_vg_list_lvs
 lvm_list_vg_names
-lvm_list_vg_ids
+lvm_list_vg_uuids
 lvm_vg_create_lv_linear
 lvm_vg_remove_lv
--- LVM2/liblvm/lvm.h	2009/07/26 16:05:49	1.17
+++ LVM2/liblvm/lvm.h	2009/07/26 16:06:21	1.18
@@ -336,7 +336,7 @@
  * FIXME: handle list memory cleanup
  */
 struct dm_list *lvm_list_vg_names(lvm_t libh);
-struct dm_list *lvm_list_vg_ids(lvm_t libh);
+struct dm_list *lvm_list_vg_uuids(lvm_t libh);
 
 /**
  * Scan all devices on the system for VGs and LVM metadata.
--- LVM2/liblvm/lvm_vg.c	2009/07/26 16:05:49	1.12
+++ LVM2/liblvm/lvm_vg.c	2009/07/26 16:06:21	1.13
@@ -247,7 +247,7 @@
 	return get_vgnames((struct cmd_context *)libh, 0);
 }
 
-struct dm_list *lvm_list_vg_ids(lvm_t libh)
+struct dm_list *lvm_list_vg_uuids(lvm_t libh)
 {
 	return get_vgids((struct cmd_context *)libh, 0);
 }
--- LVM2/test/api/test.c	2009/07/26 14:37:15	1.10
+++ LVM2/test/api/test.c	2009/07/26 16:06:21	1.11
@@ -287,7 +287,7 @@
 	struct lvm_str_list *strl;
 	const char *tmp;
 
-	list = lvm_list_vg_ids(libh);
+	list = lvm_list_vg_uuids(libh);
 	printf("VG uuids:\n");
 	dm_list_iterate_items(strl, list) {
 		tmp = strl->str;


