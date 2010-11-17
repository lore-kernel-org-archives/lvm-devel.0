From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 17 Nov 2010 20:13:51 -0000
Subject: LVM2/test/api test.c
Message-ID: <20101117201351.9009.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-11-17 20:13:51

Modified files:
	test/api       : test.c 

Log message:
	Update interactive tests for lvm2app lvseg and pvseg apis.
	
	Signed-off-by: Dave Wysochanski <wysochanski@pobox.com>
	Reviewed-by: Petr Rockai <prockai@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/test.c.diff?cvsroot=lvm2&r1=1.32&r2=1.33

--- LVM2/test/api/test.c	2010/11/17 19:17:07	1.32
+++ LVM2/test/api/test.c	2010/11/17 20:13:51	1.33
@@ -67,8 +67,12 @@
 	       "List the uuids of the VGs that exist in the system\n");
 	printf("'vg_list_pvs vgname': "
 	       "List the PVs that exist in VG vgname\n");
+	printf("'pv_list_pvsegs pvname': "
+	       "List the PV segments that exist in PV pvname\n");
 	printf("'vg_list_lvs vgname': "
 	       "List the LVs that exist in VG vgname\n");
+	printf("'lv_list_lvsegs vgname lvname': "
+	       "List the LV segments that exist in LV vgname/lvname\n");
 	printf("'vgs_open': "
 	       "List the VGs that are currently open\n");
 	printf("'vgs': "
@@ -189,17 +193,13 @@
 	return vg;
 }
 
-static pv_t _lookup_pv_by_name(char **argv, int argc)
+static pv_t _lookup_pv_by_name(const char *name)
 {
 	pv_t pv;
 
-	if (argc < 2) {
-		printf ("Please enter vg_name\n");
-		return NULL;
-	}
-	if (!(pv = dm_hash_lookup(_pvname_hash, argv[1]))) {
+	if (!(pv = dm_hash_lookup(_pvname_hash, name))) {
 		printf ("Can't find %s in open PVs - run vg_open first\n",
-			argv[1]);
+			name);
 		return NULL;
 	}
 	return pv;
@@ -238,6 +238,7 @@
 			dm_hash_insert(_pvname_hash, name, pvl->pv);
 	}
 }
+
 static void _vg_reduce(char **argv, int argc, lvm_t libh)
 {
 	vg_t vg;
@@ -496,6 +497,40 @@
 	}
 }
 
+static void _print_property_value(const char *name,
+				  struct lvm_property_value v)
+{
+	if (!v.is_valid)
+		printf("%s = INVALID\n", name);
+	else if (v.is_string)
+		printf("%s = %s\n", name, v.value.string);
+	else
+		printf("%s = %"PRIu64"\n", name, v.value.integer);
+}
+
+static void _pvsegs_in_pv(char **argv, int argc)
+{
+	struct dm_list *pvsegs;
+	struct lvm_pvseg_list *pvl;
+	pv_t pv;
+
+	if (!(pv = _lookup_pv_by_name(argv[1])))
+		return;
+	pvsegs = lvm_pv_list_pvsegs(pv);
+	if (!pvsegs || dm_list_empty(pvsegs)) {
+		printf("No PV segments in pv %s\n", argv[1]);
+		return;
+	}
+	printf("PV segments in pv %s:\n", argv[1]);
+	dm_list_iterate_items(pvl, pvsegs) {
+		struct lvm_property_value v;
+		v = lvm_pvseg_get_property(pvl->pvseg, "pvseg_start");
+		_print_property_value("pvseg_start", v);
+		v = lvm_pvseg_get_property(pvl->pvseg, "pvseg_size");
+		_print_property_value("pvseg_size", v);
+	}
+}
+
 static void _scan_vgs(lvm_t libh)
 {
 	lvm_scan(libh);
@@ -571,14 +606,6 @@
 	       add ? "adding":"removing", argv[2], argv[1]);
 }
 
-static void _print_property_value(struct lvm_property_value value)
-{
-	if (value.is_string)
-		printf(", value = %s\n", value.value.string);
-	else
-		printf(", value = %"PRIu64"\n", value.value.integer);
-}
-
 static void _pv_get_property(char **argv, int argc)
 {
 	pv_t pv;
@@ -588,20 +615,10 @@
 		printf("Please enter pvname, field_id\n");
 		return;
 	}
-	if (!(pv = _lookup_pv_by_name(argv, argc)))
+	if (!(pv = _lookup_pv_by_name(argv[1])))
 		return;
 	v = lvm_pv_get_property(pv, argv[2]);
-	if (!v.is_valid)
-		printf("Error ");
-	else
-		printf("Success ");
-	printf("obtaining value of property %s in PV %s",
-	       argv[2], argv[1]);
-	if (!v.is_valid) {
-		printf("\n");
-		return;
-	}
-	_print_property_value(v);
+	_print_property_value(argv[2], v);
 }
 
 static void _vg_get_property(char **argv, int argc)
@@ -616,17 +633,7 @@
 	if (!(vg = _lookup_vg_by_name(argv, argc)))
 		return;
 	v =  lvm_vg_get_property(vg, argv[2]);
-	if (!v.is_valid)
-		printf("Error ");
-	else
-		printf("Success ");
-	printf("obtaining value of property %s in VG %s",
-	       argv[2], argv[1]);
-	if (!v.is_valid) {
-		printf("\n");
-		return;
-	}
-	_print_property_value(v);
+	_print_property_value(argv[2], v);
 }
 
 static void _lv_get_property(char **argv, int argc)
@@ -641,17 +648,7 @@
 	if (!(lv = _lookup_lv_by_name(argv[2])))
 		return;
 	v = lvm_lv_get_property(lv, argv[3]);
-	if (!v.is_valid)
-		printf("Error ");
-	else
-		printf("Success ");
-	printf("obtaining value of property %s in LV %s",
-	       argv[3], argv[2]);
-	if (!v.is_valid) {
-		printf("\n");
-		return;
-	}
-	_print_property_value(v);
+	_print_property_value(argv[3], v);
 }
 
 static void _vg_set_property(char **argv, int argc)
@@ -774,6 +771,31 @@
 	}
 }
 
+static void _lvsegs_in_lv(char **argv, int argc)
+{
+	struct dm_list *lvsegs;
+	struct lvm_lvseg_list *lvl;
+	lv_t lv;
+
+	if (!(lv = _lookup_lv_by_name(argv[2])))
+		return;
+	lvsegs = lvm_lv_list_lvsegs(lv);
+	if (!lvsegs || dm_list_empty(lvsegs)) {
+		printf("No LV segments in lv %s\n", lvm_lv_get_name(lv));
+		return;
+	}
+	printf("LV segments in lv %s:\n", lvm_lv_get_name(lv));
+	dm_list_iterate_items(lvl, lvsegs) {
+		struct lvm_property_value v;
+		v = lvm_lvseg_get_property(lvl->lvseg, "segtype");
+		_print_property_value("segtype", v);
+		v = lvm_lvseg_get_property(lvl->lvseg, "seg_start_pe");
+		_print_property_value("seg_start_pe", v);
+		v = lvm_lvseg_get_property(lvl->lvseg, "seg_size");
+		_print_property_value("seg_size", v);
+	}
+}
+
 static void _lv_deactivate(char **argv, int argc)
 {
 	lv_t lv;
@@ -918,8 +940,12 @@
 			_list_open_vgs();
 		} else if (!strcmp(argv[0], "vg_list_pvs")) {
 			_pvs_in_vg(argv, argc);
+		} else if (!strcmp(argv[0], "pv_list_pvsegs")) {
+			_pvsegs_in_pv(argv, argc);
 		} else if (!strcmp(argv[0], "vg_list_lvs")) {
 			_lvs_in_vg(argv, argc);
+		} else if (!strcmp(argv[0], "lv_list_lvsegs")) {
+			_lvsegs_in_lv(argv, argc);
 		} else if (!strcmp(argv[0], "list_vg_names")) {
 			_list_vg_names(libh);
 		} else if (!strcmp(argv[0], "list_vg_ids")) {


