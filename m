From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 24 Jul 2009 12:51:32 -0000
Subject: LVM2/test/api test.c
Message-ID: <20090724125132.22753.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-24 12:51:32

Modified files:
	test/api       : test.c 

Log message:
	Add tests for lvm_vg_name_list, lvm_vg_id_list and lvm_scan_vgs.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/test.c.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/test/api/test.c	2009/07/24 04:15:30	1.4
+++ LVM2/test/api/test.c	2009/07/24 12:51:32	1.5
@@ -50,6 +50,12 @@
 
 static void _show_help(void)
 {
+	printf("'scan_vgs': "
+	       "Scan the system for LVM metadata\n");
+	printf("'vg_list_names': "
+	       "List the names of the VGs that exist in the system\n");
+	printf("'vg_list_ids': "
+	       "List the uuids of the VGs that exist in the system\n");
 	printf("'vg_list_pvs vgname': "
 	       "List the PVs that exist in VG vgname\n");
 	printf("'vg_list_lvs vgname': "
@@ -230,6 +236,40 @@
 	}
 }
 
+static void _scan_vgs(lvm_t libh)
+{
+	lvm_scan_vgs(libh);
+}
+
+static void _vg_list_names(lvm_t libh)
+{
+	struct dm_list *list;
+	struct lvm_str_list *strl;
+	const char *tmp;
+
+	list = lvm_list_vg_names(libh);
+	printf("VG names:\n");
+	dm_list_iterate_items(strl, list) {
+		tmp = strl->str;
+		printf("%s\n", tmp);
+	}
+}
+
+static void _vg_list_ids(lvm_t libh)
+{
+	struct dm_list *list;
+	struct lvm_str_list *strl;
+	const char *tmp;
+
+	list = lvm_list_vg_ids(libh);
+	printf("VG uuids:\n");
+	dm_list_iterate_items(strl, list) {
+		tmp = strl->str;
+		printf("%s\n", tmp);
+	}
+}
+
+
 static void _lvs_in_vg(char **argv, int argc)
 {
 	struct dm_list *lvs;
@@ -301,6 +341,12 @@
 			_pvs_in_vg(argv, argc);
 		} else if (!strcmp(argv[0], "vg_list_lvs")) {
 			_lvs_in_vg(argv, argc);
+		} else if (!strcmp(argv[0], "vg_list_names")) {
+			_vg_list_names(libh);
+		} else if (!strcmp(argv[0], "vg_list_ids")) {
+			_vg_list_ids(libh);
+		} else if (!strcmp(argv[0], "scan_vgs")) {
+			_scan_vgs(libh);
 		} else {
 			printf ("Unrecognized command %s\n", argv[0]);
 		}


