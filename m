From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 26 Jul 2009 20:58:38 -0000
Subject: LVM2/test/api test.c
Message-ID: <20090726205838.541.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-26 20:58:38

Modified files:
	test/api       : test.c 

Log message:
	Update test/api/test.c to call lv_deactivate and lv_activate.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/test.c.diff?cvsroot=lvm2&r1=1.14&r2=1.15

--- LVM2/test/api/test.c	2009/07/26 20:29:56	1.14
+++ LVM2/test/api/test.c	2009/07/26 20:58:38	1.15
@@ -50,6 +50,10 @@
 
 static void _show_help(void)
 {
+	printf("'lv_activate vgname lvname: "
+	       "Activate an LV\n");
+	printf("'lv_deactivate vgname lvname: "
+	       "Deactivate an LV\n");
 	printf("'vg_remove_lv vgname lvname': "
 	       "Remove a LV\n");
 	printf("'vg_create_lv_linear vgname lvname size_in_bytes': "
@@ -317,6 +321,42 @@
 	}
 }
 
+static void _lv_deactivate(char **argv, int argc)
+{
+	lv_t *lv;
+
+	if (argc < 3) {
+		printf("Please enter vgname, lvname\n");
+		return;
+	}
+	if (!(lv = _lookup_lv_by_name(argv[2])))
+		return;
+	if (lvm_lv_deactivate(lv))
+		printf("Error ");
+	else {
+		printf("Success ");
+	}
+	printf("De-activating LV %s in VG %s\n",
+		argv[2], argv[1]);
+}
+static void _lv_activate(char **argv, int argc)
+{
+	lv_t *lv;
+
+	if (argc < 3) {
+		printf("Please enter vgname, lvname\n");
+		return;
+	}
+	if (!(lv = _lookup_lv_by_name(argv[2])))
+		return;
+	if (lvm_lv_activate(lv))
+		printf("Error ");
+	else {
+		printf("Success ");
+	}
+	printf("activating LV %s in VG %s\n",
+		argv[2], argv[1]);
+}
 static void _vg_remove_lv(char **argv, int argc)
 {
 	lv_t *lv;
@@ -404,6 +444,10 @@
 			_vg_open(argv, argc, libh);
 		} else if (!strcmp(argv[0], "vg_close")) {
 			_vg_close(argv, argc);
+		} else if (!strcmp(argv[0], "lv_activate")) {
+			_lv_activate(argv, argc);
+		} else if (!strcmp(argv[0], "lv_deactivate")) {
+			_lv_deactivate(argv, argc);
 		} else if (!strcmp(argv[0], "vg_remove_lv")) {
 			_vg_remove_lv(argv, argc);
 		} else if (!strcmp(argv[0], "vgs_open")) {


