From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 28 Jul 2009 13:49:29 -0000
Subject: LVM2/test/api test.c
Message-ID: <20090728134929.24072.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-28 13:49:29

Modified files:
	test/api       : test.c 

Log message:
	Update interactive unit test for liblvm - add vg_write, general cleanup.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/test.c.diff?cvsroot=lvm2&r1=1.21&r2=1.22

--- LVM2/test/api/test.c	2009/07/28 13:17:04	1.21
+++ LVM2/test/api/test.c	2009/07/28 13:49:28	1.22
@@ -225,6 +225,15 @@
 		_remove_device_from_pvname_hash(pvs, argv[2]);
 }
 
+/* Print "Error" or "Success" depending on lvm status */
+static int _lvm_status_to_pass_fail(int rc)
+{
+	if (rc)
+		printf("Error ");
+	else
+		printf("Success ");
+	return rc;
+}
 static void _config_override(char **argv, int argc, lvm_t libh)
 {
 	int rc;
@@ -236,10 +245,7 @@
 	}
 	snprintf(tmp, 63, "devices{filter=[\"a|%s|\", \"r|.*|\"]}", argv[1]);
 	rc = lvm_config_override(libh, tmp);
-	if (rc)
-		printf("Error ");
-	else
-		printf("Success ");
+	_lvm_status_to_pass_fail(rc);
 	printf("overriding LVM configuration\n");
 }
 
@@ -247,10 +253,7 @@
 {
 	int rc;
 	rc = lvm_config_reload(libh);
-	if (rc)
-		printf("Error ");
-	else
-		printf("Success ");
+	_lvm_status_to_pass_fail(rc);
 	printf("reloading LVM configuration\n");
 }
 
@@ -321,25 +324,49 @@
 	if (pvs && !dm_list_empty(pvs))
 		_add_pvs_to_pvname_hash(pvs);
 }
+/* Lookup the vg and remove it from the vgname and vgid hashes */
+static vg_t *_lookup_and_remove_vg(const char *vgname)
+{
+	vg_t *vg=NULL;
 
-static void _vg_close(char **argv, int argc)
+	while((vg = dm_hash_lookup(_vgname_hash, vgname))) {
+		dm_hash_remove(_vgid_hash, lvm_vg_get_uuid(vg));
+		dm_hash_remove(_vgname_hash, lvm_vg_get_name(vg));
+	}
+	while(vg && (vg = dm_hash_lookup(_vgid_hash, vgname))) {
+		dm_hash_remove(_vgid_hash, lvm_vg_get_uuid(vg));
+		dm_hash_remove(_vgname_hash, lvm_vg_get_name(vg));
+	}
+	return vg;
+}
+
+static void _vg_write(char **argv, int argc)
 {
 	vg_t *vg;
+	int rc = 0;
 
 	if (argc < 2) {
 		printf ("Please enter vg_name\n");
 		return;
 	}
-	while((vg = dm_hash_lookup(_vgname_hash, argv[1]))) {
-		dm_hash_remove(_vgid_hash, lvm_vg_get_uuid(vg));
-		dm_hash_remove(_vgname_hash, lvm_vg_get_name(vg));
-		lvm_vg_close(vg);
+	vg = _lookup_vg_by_name(argv, argc);
+	if (vg)
+		rc = lvm_vg_write(vg);
+	_lvm_status_to_pass_fail(rc);
+	printf("writing VG %s\n", lvm_vg_get_name(vg));
+}
+
+static void _vg_close(char **argv, int argc)
+{
+	vg_t *vg;
+
+	if (argc < 2) {
+		printf ("Please enter vg_name\n");
+		return;
 	}
-	while((vg = dm_hash_lookup(_vgid_hash, argv[1]))) {
-		dm_hash_remove(_vgid_hash, lvm_vg_get_uuid(vg));
-		dm_hash_remove(_vgname_hash, lvm_vg_get_name(vg));
+	vg = _lookup_and_remove_vg(argv[1]);
+	if (vg)
 		lvm_vg_close(vg);
-	}
 	/* FIXME: remove LVs from lvname_hash */
 }
 
@@ -439,6 +466,7 @@
 static void _lv_deactivate(char **argv, int argc)
 {
 	lv_t *lv;
+	int rc=0;
 
 	if (argc < 3) {
 		printf("Please enter vgname, lvname\n");
@@ -446,17 +474,15 @@
 	}
 	if (!(lv = _lookup_lv_by_name(argv[2])))
 		return;
-	if (lvm_lv_deactivate(lv))
-		printf("Error ");
-	else {
-		printf("Success ");
-	}
+	rc = lvm_lv_deactivate(lv);
+	_lvm_status_to_pass_fail(rc);
 	printf("De-activating LV %s in VG %s\n",
 		argv[2], argv[1]);
 }
 static void _lv_activate(char **argv, int argc)
 {
 	lv_t *lv;
+	int rc=0;
 
 	if (argc < 3) {
 		printf("Please enter vgname, lvname\n");
@@ -464,11 +490,8 @@
 	}
 	if (!(lv = _lookup_lv_by_name(argv[2])))
 		return;
-	if (lvm_lv_activate(lv))
-		printf("Error ");
-	else {
-		printf("Success ");
-	}
+	rc = lvm_lv_activate(lv);
+	_lvm_status_to_pass_fail(rc);
 	printf("activating LV %s in VG %s\n",
 		argv[2], argv[1]);
 }
@@ -563,6 +586,8 @@
 			_vg_extend(argv, argc, libh);
 		} else if (!strcmp(argv[0], "vg_reduce")) {
 			_vg_reduce(argv, argc, libh);
+		} else if (!strcmp(argv[0], "vg_write")) {
+			_vg_write(argv, argc);
 		} else if (!strcmp(argv[0], "vg_open")) {
 			_vg_open(argv, argc, libh);
 		} else if (!strcmp(argv[0], "vg_close")) {


