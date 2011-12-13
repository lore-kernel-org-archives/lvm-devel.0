From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 13 Dec 2011 12:08:43 -0000
Subject: LVM2/test/unit bitset_t.c config_t.c matcher_t ...
Message-ID: <20111213120843.28777.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-12-13 12:08:42

Modified files:
	test/unit      : bitset_t.c config_t.c matcher_t.c run.c 

Log message:
	Cleanup test compile warning
	
	Add some declaration and cast to cleanup gcc warnings.
	Add missing dm_config_destroy() to cleanup pool leak report.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/unit/bitset_t.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/unit/config_t.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/unit/matcher_t.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/unit/run.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/test/unit/bitset_t.c	2011/11/21 13:15:40	1.2
+++ LVM2/test/unit/bitset_t.c	2011/12/13 12:08:42	1.3
@@ -24,17 +24,17 @@
 
 static struct dm_pool *mem;
 
-int bitset_init() {
+int bitset_init(void) {
 	mem = dm_pool_create("bitset test", 1024);
 	return mem == NULL;
 }
 
-int bitset_fini() {
+int bitset_fini(void) {
 	dm_pool_destroy(mem);
 	return 0;
 }
 
-static void test_get_next()
+static void test_get_next(void)
 {
         int i, j, last = 0, first;
         dm_bitset_t bs = dm_bitset_create(mem, NR_BITS);
@@ -68,7 +68,7 @@
                 dm_bit_set(bs, bit);
 }
 
-static void test_equal()
+static void test_equal(void)
 {
         dm_bitset_t bs1 = dm_bitset_create(mem, NR_BITS);
         dm_bitset_t bs2 = dm_bitset_create(mem, NR_BITS);
@@ -92,7 +92,7 @@
         }
 }
 
-static void test_and()
+static void test_and(void)
 {
         dm_bitset_t bs1 = dm_bitset_create(mem, NR_BITS);
         dm_bitset_t bs2 = dm_bitset_create(mem, NR_BITS);
@@ -131,4 +131,3 @@
 	{ (char*)"and", test_and },
 	CU_TEST_INFO_NULL
 };
-
--- LVM2/test/unit/config_t.c	2011/12/11 15:45:14	1.2
+++ LVM2/test/unit/config_t.c	2011/12/13 12:08:42	1.3
@@ -15,14 +15,17 @@
 #include "libdevmapper.h"
 #include <CUnit/CUnit.h>
 
+int config_init(void);
+int config_fini(void);
+
 static struct dm_pool *mem;
 
-int config_init() {
+int config_init(void) {
 	mem = dm_pool_create("config test", 1024);
 	return mem == NULL;
 }
 
-int config_fini() {
+int config_fini(void) {
 	dm_pool_destroy(mem);
 	return 0;
 }
@@ -45,12 +48,12 @@
 	"    }\n"
 	"}\n";
 
-static void test_parse()
+static void test_parse(void)
 {
 	struct dm_config_tree *tree = dm_config_from_string(conf);
-	struct dm_config_value *value;
+	const struct dm_config_value *value;
 
-	CU_ASSERT(tree);
+	CU_ASSERT((long) tree);
 	CU_ASSERT(dm_config_has_node(tree->root, "id"));
 	CU_ASSERT(dm_config_has_node(tree->root, "physical_volumes"));
 	CU_ASSERT(dm_config_has_node(tree->root, "physical_volumes/pv0"));
@@ -77,11 +80,11 @@
 	dm_config_destroy(tree);
 }
 
-static void test_clone()
+static void test_clone(void)
 {
 	struct dm_config_tree *tree = dm_config_from_string(conf);
 	struct dm_config_node *n = dm_config_clone_node(tree, tree->root, 1);
-	struct dm_config_value *value;
+	const struct dm_config_value *value;
 
 	/* Check that the nodes are actually distinct. */
 	CU_ASSERT(n != tree->root);
@@ -112,6 +115,8 @@
 	CU_ASSERT(value->next == NULL); /* an empty list */
 	CU_ASSERT(dm_config_get_list(n, "status", &value));
 	CU_ASSERT(value->next != NULL); /* a non-empty list */
+
+	dm_config_destroy(tree);
 }
 
 CU_TestInfo config_list[] = {
@@ -119,4 +124,3 @@
 	{ (char*)"clone", test_clone },
 	CU_TEST_INFO_NULL
 };
-
--- LVM2/test/unit/matcher_t.c	2011/11/20 21:43:20	1.1
+++ LVM2/test/unit/matcher_t.c	2011/12/13 12:08:42	1.2
@@ -33,27 +33,28 @@
 
 static struct dm_pool *mem = NULL;
 
-int regex_init() {
+int regex_init(void) {
 	mem = dm_pool_create("bitset test", 1024);
 	return mem == NULL;
 }
 
-int regex_fini() {
+int regex_fini(void) {
 	dm_pool_destroy(mem);
 	return 0;
 }
 
 static struct dm_regex *make_scanner(const char **rx)
 {
+	struct dm_regex *scanner;
 	int nrx = 0;
 	for (; rx[nrx]; ++nrx);
 
-	struct dm_regex *scanner = dm_regex_create(mem, rx, nrx);
+	scanner = dm_regex_create(mem, rx, nrx);
 	CU_ASSERT_FATAL(scanner != NULL);
 	return scanner;
 }
 
-static void test_fingerprints() {
+static void test_fingerprints(void) {
 	struct dm_regex *scanner;
 
 	scanner = make_scanner(dev_patterns);
@@ -63,7 +64,7 @@
 	CU_ASSERT_EQUAL(dm_regex_fingerprint(scanner), 0xeed8ceb8);
 }
 
-static void test_matching() {
+static void test_matching(void) {
 	struct dm_regex *scanner;
 	int i;
 
--- LVM2/test/unit/run.c	2011/12/11 15:19:41	1.2
+++ LVM2/test/unit/run.c	2011/12/13 12:08:42	1.3
@@ -3,8 +3,8 @@
 
 #define DECL(n) \
 	extern CU_TestInfo n ## _list[]; \
-	int n ## _init(); \
-	int n ## _fini();
+	int n ## _init(void); \
+	int n ## _fini(void);
 #define USE(n) { (char*) #n, n##_init, n##_fini, n##_list }
 
 DECL(bitset);
@@ -18,7 +18,7 @@
 	CU_SUITE_INFO_NULL
 };
 
-int main() {
+int main(int argc, char **argv) {
 	CU_initialize_registry();
 	CU_register_suites(suites);
 	CU_basic_set_mode(CU_BRM_VERBOSE);


