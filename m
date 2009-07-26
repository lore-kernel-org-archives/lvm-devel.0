From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 26 Jul 2009 02:35:48 -0000
Subject: LVM2/test/api test.c
Message-ID: <20090726023548.17547.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-26 02:35:47

Modified files:
	test/api       : test.c 

Log message:
	Update test/api/test.c to call lvm_vg_create_lv_linear.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/test.c.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/test/api/test.c	2009/07/26 02:35:19	1.6
+++ LVM2/test/api/test.c	2009/07/26 02:35:47	1.7
@@ -50,6 +50,8 @@
 
 static void _show_help(void)
 {
+	printf("'vg_create_lv_linear vgname lvname size_in_bytes': "
+	       "Create a linear LV\n");
 	printf("'scan_vgs': "
 	       "Scan the system for LVM metadata\n");
 	printf("'vg_list_names': "
@@ -292,6 +294,26 @@
 	}
 }
 
+static void _vg_create_lv_linear(char **argv, int argc)
+{
+	vg_t *vg;
+	lv_t *lv;
+
+	if (argc < 4) {
+		printf("Please enter vgname, lvname, and size\n");
+		return;
+	}
+	if (!(vg = _lookup_vg_by_name(argv, argc)))
+		return;
+	lv = lvm_vg_create_lv_linear(vg, argv[2], atol(argv[3]));
+	if (!lv)
+		printf("Error ");
+	else
+		printf("Success ");
+	printf("creating LV %s in VG %s\n",
+		argv[2], lvm_vg_get_name(vg));
+}
+
 static int lvmapi_test_shell(lvm_t libh)
 {
 	int argc;
@@ -349,6 +371,8 @@
 			_vg_list_ids(libh);
 		} else if (!strcmp(argv[0], "scan_vgs")) {
 			_scan_vgs(libh);
+		} else if (!strcmp(argv[0], "vg_create_lv_linear")) {
+			_vg_create_lv_linear(argv, argc);
 		} else {
 			printf ("Unrecognized command %s\n", argv[0]);
 		}


