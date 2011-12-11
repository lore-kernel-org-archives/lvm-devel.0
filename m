From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 11 Dec 2011 15:45:15 -0000
Subject: LVM2/test/unit config_t.c
Message-ID: <20111211154515.4563.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-12-11 15:45:15

Modified files:
	test/unit      : config_t.c 

Log message:
	Add a unit test for dm_config_clone_node.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/unit/config_t.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/test/unit/config_t.c	2011/12/11 15:19:41	1.1
+++ LVM2/test/unit/config_t.c	2011/12/11 15:45:14	1.2
@@ -27,25 +27,26 @@
 	return 0;
 }
 
+static const char *conf =
+	"id = \"yada-yada\"\n"
+	"seqno = 15\n"
+	"status = [\"READ\", \"WRITE\"]\n"
+	"flags = []\n"
+	"extent_size = 8192\n"
+	"physical_volumes {\n"
+	"    pv0 {\n"
+	"        id = \"abcd-efgh\"\n"
+	"    }\n"
+	"    pv1 {\n"
+	"        id = \"bbcd-efgh\"\n"
+	"    }\n"
+	"    pv2 {\n"
+	"        id = \"cbcd-efgh\"\n"
+	"    }\n"
+	"}\n";
+
 static void test_parse()
 {
-	const char *conf =
-		"id = \"yada-yada\"\n"
-		"seqno = 15\n"
-		"status = [\"READ\", \"WRITE\"]\n"
-		"flags = []\n"
-		"extent_size = 8192\n"
-		"physical_volumes {\n"
-		"    pv0 {\n"
-		"        id = \"abcd-efgh\"\n"
-		"    }\n"
-		"    pv1 {\n"
-		"        id = \"bbcd-efgh\"\n"
-		"    }\n"
-		"    pv2 {\n"
-		"        id = \"cbcd-efgh\"\n"
-		"    }\n"
-		"}\n";
 	struct dm_config_tree *tree = dm_config_from_string(conf);
 	struct dm_config_value *value;
 
@@ -69,15 +70,53 @@
 	// CU_ASSERT(!dm_config_get_list(tree->root, "extent_size", NULL));
 
 	CU_ASSERT(dm_config_get_list(tree->root, "flags", &value));
-	CU_ASSERT(value->next == NULL);
+	CU_ASSERT(value->next == NULL); /* an empty list */
 	CU_ASSERT(dm_config_get_list(tree->root, "status", &value));
-	CU_ASSERT(value->next != NULL);
+	CU_ASSERT(value->next != NULL); /* a non-empty list */
 
 	dm_config_destroy(tree);
 }
 
+static void test_clone()
+{
+	struct dm_config_tree *tree = dm_config_from_string(conf);
+	struct dm_config_node *n = dm_config_clone_node(tree, tree->root, 1);
+	struct dm_config_value *value;
+
+	/* Check that the nodes are actually distinct. */
+	CU_ASSERT(n != tree->root);
+	CU_ASSERT(n->sib != tree->root->sib);
+	CU_ASSERT(dm_config_find_node(n, "physical_volumes") != NULL);
+	CU_ASSERT(dm_config_find_node(tree->root, "physical_volumes") != NULL);
+	CU_ASSERT(dm_config_find_node(n, "physical_volumes") != dm_config_find_node(tree->root, "physical_volumes"));
+
+	CU_ASSERT(dm_config_has_node(n, "id"));
+	CU_ASSERT(dm_config_has_node(n, "physical_volumes"));
+	CU_ASSERT(dm_config_has_node(n, "physical_volumes/pv0"));
+	CU_ASSERT(dm_config_has_node(n, "physical_volumes/pv0/id"));
+
+	CU_ASSERT(!strcmp(dm_config_find_str(n, "id", "foo"), "yada-yada"));
+	CU_ASSERT(!strcmp(dm_config_find_str(n, "idt", "foo"), "foo"));
+
+	CU_ASSERT(!strcmp(dm_config_find_str(n, "physical_volumes/pv0/bb", "foo"), "foo"));
+	CU_ASSERT(!strcmp(dm_config_find_str(n, "physical_volumes/pv0/id", "foo"), "abcd-efgh"));
+
+	CU_ASSERT(!dm_config_get_uint32(n, "id", NULL));
+	CU_ASSERT(dm_config_get_uint32(n, "extent_size", NULL));
+
+	/* FIXME: Currently everything parses as a list, even if it's not */
+	// CU_ASSERT(!dm_config_get_list(tree->root, "id", NULL));
+	// CU_ASSERT(!dm_config_get_list(tree->root, "extent_size", NULL));
+
+	CU_ASSERT(dm_config_get_list(n, "flags", &value));
+	CU_ASSERT(value->next == NULL); /* an empty list */
+	CU_ASSERT(dm_config_get_list(n, "status", &value));
+	CU_ASSERT(value->next != NULL); /* a non-empty list */
+}
+
 CU_TestInfo config_list[] = {
 	{ (char*)"parse", test_parse },
+	{ (char*)"clone", test_clone },
 	CU_TEST_INFO_NULL
 };
 


