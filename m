From: Dave Wysochanski <wysochanski@pobox.com>
Date: Wed, 10 Nov 2010 11:12:00 -0500
Subject: [PATCH 7/7] Update tests for lvseg and pvseg apis.
In-Reply-To: <1289405520-19964-1-git-send-email-wysochanski@pobox.com>
References: <1289405520-19964-1-git-send-email-wysochanski@pobox.com>
Message-ID: <1289405520-19964-8-git-send-email-wysochanski@pobox.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: Dave Wysochanski <dwysocha@redhat.com>

Update interactive tests for lvm2app lvseg and pvseg apis.

Signed-off-by: Dave Wysochanski <wysochanski@pobox.com>
---
 test/api/test.c |  124 +++++++++++++++++++++++++++++++++----------------------
 1 files changed, 75 insertions(+), 49 deletions(-)

diff --git a/test/api/test.c b/test/api/test.c
index fea3d0d..bfe32b7 100644
--- a/test/api/test.c
+++ b/test/api/test.c
@@ -67,8 +67,12 @@ static void _show_help(void)
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
@@ -187,17 +191,13 @@ static vg_t _lookup_vg_by_name(char **argv, int argc)
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
@@ -236,6 +236,7 @@ static void _add_device_to_pvname_hash(struct dm_list *pvs, const char *name)
 			dm_hash_insert(_pvname_hash, name, pvl->pv);
 	}
 }
+
 static void _vg_reduce(char **argv, int argc, lvm_t libh)
 {
 	vg_t vg;
@@ -494,6 +495,40 @@ static void _pvs_in_vg(char **argv, int argc)
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
@@ -569,14 +604,6 @@ static void _vg_tag(char **argv, int argc, int add)
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
@@ -586,20 +613,10 @@ static void _pv_get_property(char **argv, int argc)
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
@@ -614,17 +631,7 @@ static void _vg_get_property(char **argv, int argc)
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
@@ -639,17 +646,7 @@ static void _lv_get_property(char **argv, int argc)
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
 
 static void _lv_get_tags(char **argv, int argc)
@@ -742,6 +739,31 @@ static void _lvs_in_vg(char **argv, int argc)
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
@@ -886,8 +908,12 @@ static int lvmapi_test_shell(lvm_t libh)
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
-- 
1.7.2.2


