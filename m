From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 18 Dec 2011 23:56:36 -0000
Subject: LVM2/test/unit config_t.c
Message-ID: <20111218235636.25983.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-12-18 23:56:36

Modified files:
	test/unit      : config_t.c 

Log message:
	Add a unit test for config cascade (overlay). Needs expanding though.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/unit/config_t.c.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/test/unit/config_t.c	2011/12/13 12:08:42	1.3
+++ LVM2/test/unit/config_t.c	2011/12/18 23:56:36	1.4
@@ -48,6 +48,18 @@
 	"    }\n"
 	"}\n";
 
+static const char *overlay =
+	"id = \"yoda-soda\"\n"
+	"flags = [\"FOO\"]\n"
+	"physical_volumes {\n"
+	"    pv1 {\n"
+	"        id = \"hgfe-dcba\"\n"
+	"    }\n"
+	"    pv3 {\n"
+	"        id = \"dbcd-efgh\"\n"
+	"    }\n"
+	"}\n";
+
 static void test_parse(void)
 {
 	struct dm_config_tree *tree = dm_config_from_string(conf);
@@ -119,8 +131,26 @@
 	dm_config_destroy(tree);
 }
 
+static void test_cascade()
+{
+	struct dm_config_tree *t1 = dm_config_from_string(conf),
+		              *t2 = dm_config_from_string(overlay),
+		              *tree = dm_config_insert_cascaded_tree(t2, t1);
+
+	CU_ASSERT(!strcmp(dm_config_tree_find_str(tree, "id", "foo"), "yoda-soda"));
+	CU_ASSERT(!strcmp(dm_config_tree_find_str(tree, "idt", "foo"), "foo"));
+
+	CU_ASSERT(!strcmp(dm_config_tree_find_str(tree, "physical_volumes/pv0/bb", "foo"), "foo"));
+	CU_ASSERT(!strcmp(dm_config_tree_find_str(tree, "physical_volumes/pv1/id", "foo"), "hgfe-dcba"));
+	CU_ASSERT(!strcmp(dm_config_tree_find_str(tree, "physical_volumes/pv3/id", "foo"), "dbcd-efgh"));
+
+	dm_config_destroy(t1);
+	dm_config_destroy(t2);
+}
+
 CU_TestInfo config_list[] = {
 	{ (char*)"parse", test_parse },
 	{ (char*)"clone", test_clone },
+	{ (char*)"cascade", test_cascade },
 	CU_TEST_INFO_NULL
 };


