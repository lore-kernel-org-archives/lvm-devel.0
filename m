From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 15 Sep 2010 11:36:11 -0400
Subject: [PATCH 19/19] Add pv_get_property to interactive test.
In-Reply-To: <1284564971-26060-1-git-send-email-dwysocha@redhat.com>
References: <1284564971-26060-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1284564971-26060-20-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 test/api/test.c |   52 +++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 51 insertions(+), 1 deletions(-)

diff --git a/test/api/test.c b/test/api/test.c
index 4560655..2579ff0 100644
--- a/test/api/test.c
+++ b/test/api/test.c
@@ -93,6 +93,8 @@ static void _show_help(void)
 	       "List the tags of a VG\n");
 	printf("'vg_get_property vgname property_name': "
 	       "Display the value of VG property\n");
+	printf("'pv_get_property pvname property_name': "
+	       "Display the value of PV property\n");
 	printf("'lv_get_tags vgname lvname': "
 	       "List the tags of a LV\n");
 	printf("'vg_{add|remove}_tag vgname tag': "
@@ -182,6 +184,23 @@ static vg_t _lookup_vg_by_name(char **argv, int argc)
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
@@ -548,6 +567,35 @@ static void _vg_tag(char **argv, int argc, int add)
 	       add ? "adding":"removing", argv[2], argv[1]);
 }
 
+static void _pv_get_property(char **argv, int argc)
+{
+	pv_t pv;
+	struct lvm_property_value value;
+	int rc;
+
+	if (argc < 3) {
+		printf("Please enter vgname, field_id\n");
+		return;
+	}
+	if (!(pv = _lookup_pv_by_name(argv, argc)))
+		return;
+	rc = lvm_pv_get_property(pv, argv[2], &value);
+	if (rc)
+		printf("Error ");
+	else
+		printf("Success ");
+	printf("obtaining value of property %s in VG %s",
+	       argv[2], argv[1]);
+	if (rc) {
+		printf("\n");
+		return;
+	}
+	if (value.is_string)
+		printf(", value = %s\n", value.v.s_val);
+	else
+		printf(", value = %"PRIu64"\n", value.v.n_val);
+}
+
 static void _vg_get_property(char **argv, int argc)
 {
 	vg_t vg;
@@ -565,7 +613,7 @@ static void _vg_get_property(char **argv, int argc)
 		printf("Error ");
 	else
 		printf("Success ");
-	printf("Obtaining value of property %s in VG %s",
+	printf("obtaining value of property %s in VG %s",
 	       argv[2], argv[1]);
 	if (rc) {
 		printf("\n");
@@ -829,6 +877,8 @@ static int lvmapi_test_shell(lvm_t libh)
 			_vg_get_tags(argv, argc);
 		} else if (!strcmp(argv[0], "vg_get_property")) {
 			_vg_get_property(argv, argc);
+		} else if (!strcmp(argv[0], "pv_get_property")) {
+			_pv_get_property(argv, argc);
 		} else if (!strcmp(argv[0], "lv_add_tag")) {
 			_lv_tag(argv, argc, 1);
 		} else if (!strcmp(argv[0], "lv_remove_tag")) {
-- 
1.7.2.1


