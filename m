From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 16 Feb 2010 14:39:49 -0500
Subject: [PATCH 7/7] Update lvm2app interactive unit test for vg/lv tags.
In-Reply-To: <1266349189-23166-7-git-send-email-dwysocha@redhat.com>
References: <1266349189-23166-1-git-send-email-dwysocha@redhat.com>
	<1266349189-23166-2-git-send-email-dwysocha@redhat.com>
	<1266349189-23166-3-git-send-email-dwysocha@redhat.com>
	<1266349189-23166-4-git-send-email-dwysocha@redhat.com>
	<1266349189-23166-5-git-send-email-dwysocha@redhat.com>
	<1266349189-23166-6-git-send-email-dwysocha@redhat.com>
	<1266349189-23166-7-git-send-email-dwysocha@redhat.com>
Message-ID: <1266349189-23166-8-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Simple test of vg/lv tag addition/deletion.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 test/api/test.c |  105 +++++++++++++++++++++++++++++++++++++++++++++++++++---
 1 files changed, 99 insertions(+), 6 deletions(-)

diff --git a/test/api/test.c b/test/api/test.c
index 6e222da..98f77e4 100644
--- a/test/api/test.c
+++ b/test/api/test.c
@@ -89,6 +89,14 @@ static void _show_help(void)
 	       "Issue a lvm_config_reload() API to reload LVM config\n");
 	printf("'config_override' device: "
 	       "Issue a lvm_config_override() with accept device filter\n");
+	printf("'vg_get_tags vgname': "
+	       "List the tags of a VG\n");
+	printf("'lv_get_tags vgname lvname': "
+	       "List the tags of a LV\n");
+	printf("'vg_{add|remove}_tag vgname tag': "
+	       "Add/remove a tag from a VG\n");
+	printf("'lv_{add|remove}_tag vgname lvname tag': "
+	       "Add/remove a tag from a LV\n");
 	printf("'quit': exit the program\n");
 }
 
@@ -468,13 +476,11 @@ static void _list_vg_names(lvm_t libh)
 {
 	struct dm_list *list;
 	struct lvm_str_list *strl;
-	const char *tmp;
 
 	list = lvm_list_vg_names(libh);
 	printf("VG names:\n");
 	dm_list_iterate_items(strl, list) {
-		tmp = strl->str;
-		printf("%s\n", tmp);
+		printf("%s\n", strl->str);
 	}
 }
 
@@ -482,17 +488,91 @@ static void _list_vg_ids(lvm_t libh)
 {
 	struct dm_list *list;
 	struct lvm_str_list *strl;
-	const char *tmp;
 
 	list = lvm_list_vg_uuids(libh);
 	printf("VG uuids:\n");
 	dm_list_iterate_items(strl, list) {
-		tmp = strl->str;
-		printf("%s\n", tmp);
+		printf("%s\n", strl->str);
 	}
 }
 
+static void _display_tags(struct dm_list *list)
+{
+	struct lvm_str_list *strl;
+	if (!list || dm_list_empty(list)) {
+		printf("No tags exist\n");
+		return;
+	}
+	dm_list_iterate_items(strl, list) {
+		printf("%s\n", strl->str);
+	}
+}
+
+static void _vg_get_tags(char **argv, int argc)
+{
+	vg_t vg;
+
+	if (!(vg = _lookup_vg_by_name(argv, argc)))
+		return;
+	printf("VG tags:\n");
+	_display_tags(lvm_vg_get_tags(vg));
+}
+
+static void _vg_tag(char **argv, int argc, int add)
+{
+	vg_t vg;
+
+	if (argc < 3) {
+		printf("Please enter vgname, tag\n");
+		return;
+	}
+	if (!(vg = _lookup_vg_by_name(argv, argc)))
+		return;
+	if (add && lvm_vg_add_tag(vg, argv[2]))
+		printf("Error ");
+	else if (!add && lvm_vg_remove_tag(vg, argv[2])){
+		printf("Error ");
+	} else {
+		printf("Success ");
+	}
+	printf("%s tag %s to VG %s\n",
+	       add ? "adding":"removing", argv[2], argv[1]);
+}
+
+static void _lv_get_tags(char **argv, int argc)
+{
+	lv_t lv;
+
+	if (argc < 3) {
+		printf("Please enter vgname, lvname\n");
+		return;
+	}
+	if (!(lv = _lookup_lv_by_name(argv[2])))
+		return;
+	printf("LV tags:\n");
+	_display_tags(lvm_lv_get_tags(lv));
+}
 
+static void _lv_tag(char **argv, int argc, int add)
+{
+	lv_t lv;
+
+	if (argc < 3) {
+		printf("Please enter vgname, lvname\n");
+		return;
+	}
+	if (!(lv = _lookup_lv_by_name(argv[2])))
+		return;
+	if (add && lvm_lv_add_tag(lv, argv[3]))
+		printf("Error ");
+	else if (!add && lvm_lv_remove_tag(lv, argv[3])){
+		printf("Error ");
+	} else {
+		printf("Success ");
+	}
+	printf("%s tag %s to LV %s\n",
+	       add ? "adding":"removing", argv[3], argv[2]);
+}
 static void _lvs_in_vg(char **argv, int argc)
 {
 	struct dm_list *lvs;
@@ -549,6 +629,7 @@ static void _lv_activate(char **argv, int argc)
 	printf("activating LV %s in VG %s\n",
 		argv[2], argv[1]);
 }
+
 static void _vg_remove_lv(char **argv, int argc)
 {
 	lv_t lv;
@@ -670,6 +751,18 @@ static int lvmapi_test_shell(lvm_t libh)
 			_scan_vgs(libh);
 		} else if (!strcmp(argv[0], "vg_create_lv_linear")) {
 			_vg_create_lv_linear(argv, argc);
+		} else if (!strcmp(argv[0], "vg_add_tag")) {
+			_vg_tag(argv, argc, 1);
+		} else if (!strcmp(argv[0], "vg_remove_tag")) {
+			_vg_tag(argv, argc, 0);
+		} else if (!strcmp(argv[0], "vg_get_tags")) {
+			_vg_get_tags(argv, argc);
+		} else if (!strcmp(argv[0], "lv_add_tag")) {
+			_lv_tag(argv, argc, 1);
+		} else if (!strcmp(argv[0], "lv_remove_tag")) {
+			_lv_tag(argv, argc, 0);
+		} else if (!strcmp(argv[0], "lv_get_tags")) {
+			_lv_get_tags(argv, argc);
 		} else {
 			printf ("Unrecognized command %s\n", argv[0]);
 		}
-- 
1.6.0.6


