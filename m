From: Dave Wysochanski <wysochanski@pobox.com>
Date: Fri, 05 Nov 2010 20:36:17 -0000
Subject: [PATCH 3/3] Add tests for vg 'set' property function.
In-Reply-To: <1288987522-13757-1-git-send-email-wysochanski@pobox.com>
References: <1288987522-13757-1-git-send-email-wysochanski@pobox.com>
Message-ID: <1288987522-13757-4-git-send-email-wysochanski@pobox.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Signed-off-by: Dave Wysochanski <wysochanski@pobox.com>
---
 test/api/test.c |   34 ++++++++++++++++++++++++++++++++++
 1 files changed, 34 insertions(+), 0 deletions(-)

diff --git a/test/api/test.c b/test/api/test.c
index fea3d0d..b675a52 100644
--- a/test/api/test.c
+++ b/test/api/test.c
@@ -97,6 +97,8 @@ static void _show_help(void)
 	       "Display the value of VG property\n");
 	printf("'pv_get_property pvname property_name': "
 	       "Display the value of PV property\n");
+	printf("'vg_set_property vgname property_name': "
+	       "Set the value of VG property\n");
 	printf("'lv_get_tags vgname lvname': "
 	       "List the tags of a LV\n");
 	printf("'vg_{add|remove}_tag vgname tag': "
@@ -652,6 +654,36 @@ static void _lv_get_property(char **argv, int argc)
 	_print_property_value(v);
 }
 
+static void _vg_set_property(char **argv, int argc)
+{
+	vg_t vg;
+	struct lvm_property_value value;
+	int rc;
+
+	if (argc < 4) {
+		printf("Please enter vgname, field_id, value\n");
+		return;
+	}
+	if (!(vg = _lookup_vg_by_name(argv, argc)))
+		return;
+	value = lvm_vg_get_property(vg, argv[2]);
+	if (!value.is_valid) {
+		printf("Error obtaining property value\n");
+		return;
+	}
+	if (value.is_string)
+		value.value.string = argv[3];
+	else
+		value.value.integer = atoi(argv[3]);
+	rc = lvm_vg_set_property(vg, argv[2], &value);
+	if (rc)
+		printf("Error ");
+	else
+		printf("Success ");
+	printf("setting value of property %s in VG %s\n",
+	       argv[2], argv[1]);
+}
+
 static void _lv_get_tags(char **argv, int argc)
 {
 	lv_t lv;
@@ -908,6 +940,8 @@ static int lvmapi_test_shell(lvm_t libh)
 			_vg_get_property(argv, argc);
 		} else if (!strcmp(argv[0], "pv_get_property")) {
 			_pv_get_property(argv, argc);
+		} else if (!strcmp(argv[0], "vg_set_property")) {
+			_vg_set_property(argv, argc);
 		} else if (!strcmp(argv[0], "lv_add_tag")) {
 			_lv_tag(argv, argc, 1);
 		} else if (!strcmp(argv[0], "lv_remove_tag")) {
-- 
1.7.2.2


