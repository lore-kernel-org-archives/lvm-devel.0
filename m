From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 26 Jul 2009 14:37:16 -0000
Subject: LVM2/test/api test.c
Message-ID: <20090726143716.16821.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-26 14:37:15

Modified files:
	test/api       : test.c 

Log message:
	Update test/api/test.c to call lvm_lv_remove.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/test.c.diff?cvsroot=lvm2&r1=1.9&r2=1.10

--- LVM2/test/api/test.c	2009/07/26 13:08:00	1.9
+++ LVM2/test/api/test.c	2009/07/26 14:37:15	1.10
@@ -50,6 +50,8 @@
 
 static void _show_help(void)
 {
+	printf("'vg_remove_lv vgname lvname': "
+	       "Remove a LV\n");
 	printf("'vg_create_lv_linear vgname lvname size_in_bytes': "
 	       "Create a linear LV\n");
 	printf("'scan_vgs': "
@@ -116,6 +118,23 @@
 	return 1;
 }
 
+/* FIXME: this should be per vg */
+static lv_t *_lookup_lv_by_name(const char *name)
+{
+	lv_t *lv;
+
+	if (!name) {
+		printf ("Invalid LV name\n");
+		return NULL;
+	}
+	if (!(lv = dm_hash_lookup(_lvname_hash, name))) {
+		printf ("Can't find %s in LVs - run vg_create_lv first\n",
+			name);
+		return NULL;
+	}
+	return lv;
+}
+
 static vg_t *_lookup_vg_by_name(char **argv, int argc)
 {
 	vg_t *vg;
@@ -206,6 +225,7 @@
 		dm_hash_remove(_vgname_hash, lvm_vg_get_name(vg));
 		lvm_vg_close(vg);
 	}
+	/* FIXME: remove LVs from lvname_hash */
 }
 
 static void _show_one_vg(vg_t *vg)
@@ -297,6 +317,26 @@
 	}
 }
 
+static void _vg_remove_lv(char **argv, int argc)
+{
+	lv_t *lv;
+
+	if (argc < 3) {
+		printf("Please enter vgname, lvname\n");
+		return;
+	}
+	if (!(lv = _lookup_lv_by_name(argv[2])))
+		return;
+	if (!lvm_vg_remove_lv(lv))
+		printf("Error ");
+	else {
+		printf("Success ");
+		dm_hash_remove(_lvname_hash, argv[2]);
+	}
+	printf("removing LV %s in VG %s\n",
+		argv[2], argv[1]);
+}
+
 static void _vg_create_lv_linear(char **argv, int argc)
 {
 	vg_t *vg;
@@ -311,10 +351,12 @@
 	lv = lvm_vg_create_lv_linear(vg, argv[2], atol(argv[3]));
 	if (!lv)
 		printf("Error ");
-	else
+	else {
 		printf("Success ");
+		dm_hash_insert(_lvname_hash, argv[2], lv);
+	}
 	printf("creating LV %s in VG %s\n",
-		argv[2], lvm_vg_get_name(vg));
+		argv[2], argv[1]);
 }
 
 static int lvmapi_test_shell(lvm_t libh)
@@ -362,6 +404,8 @@
 			_vg_open(argv, argc, libh);
 		} else if (!strcmp(argv[0], "vg_close")) {
 			_vg_close(argv, argc);
+		} else if (!strcmp(argv[0], "vg_remove_lv")) {
+			_vg_remove_lv(argv, argc);
 		} else if (!strcmp(argv[0], "vgs_open")) {
 			_list_open_vgs();
 		} else if (!strcmp(argv[0], "vg_list_pvs")) {


