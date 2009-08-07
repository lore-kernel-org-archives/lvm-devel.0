From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 7 Aug 2009 21:22:38 -0000
Subject: LVM2/test/api test.c
Message-ID: <20090807212238.32206.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-08-07 21:22:37

Modified files:
	test/api       : test.c 

Log message:
	Update test/api/test.c to call lvm_vg_create and lvm_vg_remove.
	
	Also fix a couple bugs.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/test.c.diff?cvsroot=lvm2&r1=1.24&r2=1.25

--- LVM2/test/api/test.c	2009/07/29 14:06:31	1.24
+++ LVM2/test/api/test.c	2009/08/07 21:22:37	1.25
@@ -81,6 +81,10 @@
 	       "Issue a lvm_vg_open() API call on VG 'vgname'\n");
 	printf("'vg_close vgname': "
 	       "Issue a lvm_vg_close() API call on VG 'vgname'\n");
+	printf("'vg_create vgname: "
+	       "Issue a lvm_vg_create() to create VG 'vgname'\n");
+	printf("'vg_remove vgname: "
+	       "Issue a lvm_vg_remove() to remove VG 'vgname'\n");
 	printf("'config_reload': "
 	       "Issue a lvm_config_reload() API to reload LVM config\n");
 	printf("'config_override' device: "
@@ -351,24 +355,70 @@
 		return;
 	}
 	vg = _lookup_vg_by_name(argv, argc);
-	if (vg)
-		rc = lvm_vg_write(vg);
+	if (!vg) {
+		printf("Can't find vg_name %s\n", argv[1]);
+		return;
+	}
+	rc = lvm_vg_write(vg);
 	_lvm_status_to_pass_fail(rc);
 	printf("writing VG %s\n", lvm_vg_get_name(vg));
 }
 
+static void _vg_create(char **argv, int argc, lvm_t libh)
+{
+	vg_t *vg;
+
+	if (argc < 2) {
+		printf ("Please enter vg_name\n");
+		return;
+	}
+	vg = lvm_vg_create(libh, argv[1]);
+	if (!vg || !lvm_vg_get_name(vg)) {
+		printf("Error creating %s\n", argv[1]);
+		return;
+	}
+
+	printf("Success creating vg %s\n", argv[1]);
+	dm_hash_insert(_vgname_hash, lvm_vg_get_name(vg), vg);
+	dm_hash_insert(_vgid_hash, lvm_vg_get_uuid(vg), vg);
+}
+
+static void _vg_remove(char **argv, int argc)
+{
+	vg_t *vg;
+	int rc = 0;
+
+	if (argc < 2) {
+		printf ("Please enter vg_name\n");
+		return;
+	}
+	vg = _lookup_vg_by_name(argv, argc);
+	if (!vg) {
+		printf("Can't find vg_name %s\n", argv[1]);
+		return;
+	}
+	rc = lvm_vg_remove(vg);
+	_lvm_status_to_pass_fail(rc);
+	printf("removing VG\n");
+}
+
 static void _vg_close(char **argv, int argc)
 {
 	vg_t *vg;
+	int rc = 0;
 
 	if (argc < 2) {
 		printf ("Please enter vg_name\n");
 		return;
 	}
 	vg = _lookup_and_remove_vg(argv[1]);
-	if (vg)
-		lvm_vg_close(vg);
-	/* FIXME: remove LVs from lvname_hash */
+	if (!vg) {
+		printf("Can't find vg_name %s\n", argv[1]);
+		return;
+	}
+	rc = lvm_vg_close(vg);
+	_lvm_status_to_pass_fail(rc);
+	printf("closing VG\n");
 }
 
 static void _show_one_vg(vg_t *vg)
@@ -593,6 +643,10 @@
 			_vg_open(argv, argc, libh);
 		} else if (!strcmp(argv[0], "vg_close")) {
 			_vg_close(argv, argc);
+		} else if (!strcmp(argv[0], "vg_create")) {
+			_vg_create(argv, argc, libh);
+		} else if (!strcmp(argv[0], "vg_remove")) {
+			_vg_remove(argv, argc);
 		} else if (!strcmp(argv[0], "lv_activate")) {
 			_lv_activate(argv, argc);
 		} else if (!strcmp(argv[0], "lv_deactivate")) {


