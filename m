From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 18 Aug 2010 09:52:02 -0400
Subject: [PATCH 11/11] Add tests for lvm_vg_get_property().
In-Reply-To: <1282139522-31240-1-git-send-email-dwysocha@redhat.com>
References: <1282139522-31240-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1282139522-31240-12-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 test/api/test.c |   34 ++++++++++++++++++++++++++++++++++
 1 files changed, 34 insertions(+), 0 deletions(-)

diff --git a/test/api/test.c b/test/api/test.c
index f89840c..6a1122c 100644
--- a/test/api/test.c
+++ b/test/api/test.c
@@ -18,6 +18,7 @@
 #include <readline/readline.h>
 
 #include "lvm2app.h"
+#include "libdevmapper.h"
 
 #define MAX_ARGS 64
 
@@ -91,6 +92,8 @@ static void _show_help(void)
 	       "Issue a lvm_config_override() with accept device filter\n");
 	printf("'vg_get_tags vgname': "
 	       "List the tags of a VG\n");
+	printf("'vg_get_property vgname property_name': "
+	       "Display the value of VG property\n");
 	printf("'lv_get_tags vgname lvname': "
 	       "List the tags of a LV\n");
 	printf("'vg_{add|remove}_tag vgname tag': "
@@ -546,6 +549,35 @@ static void _vg_tag(char **argv, int argc, int add)
 	       add ? "adding":"removing", argv[2], argv[1]);
 }
 
+static void _vg_get_property(char **argv, int argc)
+{
+	vg_t vg;
+	struct lvm_property_value value;
+	int rc;
+
+	if (argc < 3) {
+		printf("Please enter vgname, field_id\n");
+		return;
+	}
+	if (!(vg = _lookup_vg_by_name(argv, argc)))
+		return;
+	rc = lvm_vg_get_property(vg, argv[2], &value);
+	if (rc)
+		printf("Error ");
+	else
+		printf("Success ");
+	printf("Obtaining value of property %s in VG %s",
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
 static void _lv_get_tags(char **argv, int argc)
 {
 	lv_t lv;
@@ -796,6 +828,8 @@ static int lvmapi_test_shell(lvm_t libh)
 			_vg_tag(argv, argc, 0);
 		} else if (!strcmp(argv[0], "vg_get_tags")) {
 			_vg_get_tags(argv, argc);
+		} else if (!strcmp(argv[0], "vg_get_property")) {
+			_vg_get_property(argv, argc);
 		} else if (!strcmp(argv[0], "lv_add_tag")) {
 			_lv_tag(argv, argc, 1);
 		} else if (!strcmp(argv[0], "lv_remove_tag")) {
-- 
1.7.2.1


