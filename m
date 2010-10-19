From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 19 Oct 2010 07:32:55 -0400
Subject: [PATCH 8/8] Add interactive tests for lvm_{pv|vg|lv}_get_property().
In-Reply-To: <1287487975-26572-1-git-send-email-dwysocha@redhat.com>
References: <1287487975-26572-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1287487975-26572-9-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 test/api/test.c |  112 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 112 insertions(+), 0 deletions(-)

diff --git a/test/api/test.c b/test/api/test.c
index f89840c..fea3d0d 100644
--- a/test/api/test.c
+++ b/test/api/test.c
@@ -91,6 +91,12 @@ static void _show_help(void)
 	       "Issue a lvm_config_override() with accept device filter\n");
 	printf("'vg_get_tags vgname': "
 	       "List the tags of a VG\n");
+	printf("'lv_get_property vgname lvname property_name': "
+	       "Display the value of LV property\n");
+	printf("'vg_get_property vgname property_name': "
+	       "Display the value of VG property\n");
+	printf("'pv_get_property pvname property_name': "
+	       "Display the value of PV property\n");
 	printf("'lv_get_tags vgname lvname': "
 	       "List the tags of a LV\n");
 	printf("'vg_{add|remove}_tag vgname tag': "
@@ -180,6 +186,23 @@ static vg_t _lookup_vg_by_name(char **argv, int argc)
 	}
 	return vg;
 }
+
+static pv_t _lookup_pv_by_name(char **argv, int argc)
+{
+	pv_t pv;
+
+	if (argc < 2) {
+		printf ("Please enter vg_name\n");
+		return NULL;
+	}
+	if (!(pv = dm_hash_lookup(_pvname_hash, argv[1]))) {
+		printf ("Can't find %s in open PVs - run vg_open first\n",
+			argv[1]);
+		return NULL;
+	}
+	return pv;
+}
+
 static void _add_lvs_to_lvname_hash(struct dm_list *lvs)
 {
 	struct lvm_lv_list *lvl;
@@ -546,6 +569,89 @@ static void _vg_tag(char **argv, int argc, int add)
 	       add ? "adding":"removing", argv[2], argv[1]);
 }
 
+static void _print_property_value(struct lvm_property_value value)
+{
+	if (value.is_string)
+		printf(", value = %s\n", value.value.string);
+	else
+		printf(", value = %"PRIu64"\n", value.value.integer);
+}
+
+static void _pv_get_property(char **argv, int argc)
+{
+	pv_t pv;
+	struct lvm_property_value v;
+
+	if (argc < 3) {
+		printf("Please enter pvname, field_id\n");
+		return;
+	}
+	if (!(pv = _lookup_pv_by_name(argv, argc)))
+		return;
+	v = lvm_pv_get_property(pv, argv[2]);
+	if (!v.is_valid)
+		printf("Error ");
+	else
+		printf("Success ");
+	printf("obtaining value of property %s in PV %s",
+	       argv[2], argv[1]);
+	if (!v.is_valid) {
+		printf("\n");
+		return;
+	}
+	_print_property_value(v);
+}
+
+static void _vg_get_property(char **argv, int argc)
+{
+	vg_t vg;
+	struct lvm_property_value v;
+
+	if (argc < 3) {
+		printf("Please enter vgname, field_id\n");
+		return;
+	}
+	if (!(vg = _lookup_vg_by_name(argv, argc)))
+		return;
+	v =  lvm_vg_get_property(vg, argv[2]);
+	if (!v.is_valid)
+		printf("Error ");
+	else
+		printf("Success ");
+	printf("obtaining value of property %s in VG %s",
+	       argv[2], argv[1]);
+	if (!v.is_valid) {
+		printf("\n");
+		return;
+	}
+	_print_property_value(v);
+}
+
+static void _lv_get_property(char **argv, int argc)
+{
+	lv_t lv;
+	struct lvm_property_value v;
+
+	if (argc < 4) {
+		printf("Please enter vgname, lvname, field_id\n");
+		return;
+	}
+	if (!(lv = _lookup_lv_by_name(argv[2])))
+		return;
+	v = lvm_lv_get_property(lv, argv[3]);
+	if (!v.is_valid)
+		printf("Error ");
+	else
+		printf("Success ");
+	printf("obtaining value of property %s in LV %s",
+	       argv[3], argv[2]);
+	if (!v.is_valid) {
+		printf("\n");
+		return;
+	}
+	_print_property_value(v);
+}
+
 static void _lv_get_tags(char **argv, int argc)
 {
 	lv_t lv;
@@ -796,6 +902,12 @@ static int lvmapi_test_shell(lvm_t libh)
 			_vg_tag(argv, argc, 0);
 		} else if (!strcmp(argv[0], "vg_get_tags")) {
 			_vg_get_tags(argv, argc);
+		} else if (!strcmp(argv[0], "lv_get_property")) {
+			_lv_get_property(argv, argc);
+		} else if (!strcmp(argv[0], "vg_get_property")) {
+			_vg_get_property(argv, argc);
+		} else if (!strcmp(argv[0], "pv_get_property")) {
+			_pv_get_property(argv, argc);
 		} else if (!strcmp(argv[0], "lv_add_tag")) {
 			_lv_tag(argv, argc, 1);
 		} else if (!strcmp(argv[0], "lv_remove_tag")) {
-- 
1.7.2.2


