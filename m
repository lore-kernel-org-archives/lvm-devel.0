From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 26 Jul 2009 13:08:00 -0000
Subject: LVM2/test/api test.c
Message-ID: <20090726130800.7194.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-26 13:08:00

Modified files:
	test/api       : test.c 

Log message:
	Update test/api/test.c - correct list_vg_names and list_vg_ids.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/test.c.diff?cvsroot=lvm2&r1=1.8&r2=1.9

--- LVM2/test/api/test.c	2009/07/26 13:07:41	1.8
+++ LVM2/test/api/test.c	2009/07/26 13:08:00	1.9
@@ -54,9 +54,9 @@
 	       "Create a linear LV\n");
 	printf("'scan_vgs': "
 	       "Scan the system for LVM metadata\n");
-	printf("'vg_list_names': "
+	printf("'list_vg_names': "
 	       "List the names of the VGs that exist in the system\n");
-	printf("'vg_list_ids': "
+	printf("'list_vg_ids': "
 	       "List the uuids of the VGs that exist in the system\n");
 	printf("'vg_list_pvs vgname': "
 	       "List the PVs that exist in VG vgname\n");
@@ -247,7 +247,7 @@
 	lvm_scan_vgs(libh);
 }
 
-static void _vg_list_names(lvm_t libh)
+static void _list_vg_names(lvm_t libh)
 {
 	struct dm_list *list;
 	struct lvm_str_list *strl;
@@ -261,7 +261,7 @@
 	}
 }
 
-static void _vg_list_ids(lvm_t libh)
+static void _list_vg_ids(lvm_t libh)
 {
 	struct dm_list *list;
 	struct lvm_str_list *strl;
@@ -368,10 +368,10 @@
 			_pvs_in_vg(argv, argc);
 		} else if (!strcmp(argv[0], "vg_list_lvs")) {
 			_lvs_in_vg(argv, argc);
-		} else if (!strcmp(argv[0], "vg_list_names")) {
-			_vg_list_names(libh);
-		} else if (!strcmp(argv[0], "vg_list_ids")) {
-			_vg_list_ids(libh);
+		} else if (!strcmp(argv[0], "list_vg_names")) {
+			_list_vg_names(libh);
+		} else if (!strcmp(argv[0], "list_vg_ids")) {
+			_list_vg_ids(libh);
 		} else if (!strcmp(argv[0], "scan_vgs")) {
 			_scan_vgs(libh);
 		} else if (!strcmp(argv[0], "vg_create_lv_linear")) {


