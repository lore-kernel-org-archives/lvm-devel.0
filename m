From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 11 Dec 2011 15:19:41 -0000
Subject: LVM2/test/unit Makefile.in run.c config_t.c
Message-ID: <20111211151941.6609.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-12-11 15:19:41

Modified files:
	test/unit      : Makefile.in run.c 
Added files:
	test/unit      : config_t.c 

Log message:
	Start a rudimentary unit test for the dm_config_* interface.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/unit/config_t.c.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/unit/Makefile.in.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/unit/run.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2

/cvs/lvm2/LVM2/test/unit/config_t.c,v  -->  standard output
revision 1.1
--- LVM2/test/unit/config_t.c
+++ -	2011-12-11 15:19:41.326250000 +0000
@@ -0,0 +1,83 @@
+/*
+ * Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU General Public License v.2.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#include "libdevmapper.h"
+#include <CUnit/CUnit.h>
+
+static struct dm_pool *mem;
+
+int config_init() {
+	mem = dm_pool_create("config test", 1024);
+	return mem == NULL;
+}
+
+int config_fini() {
+	dm_pool_destroy(mem);
+	return 0;
+}
+
+static void test_parse()
+{
+	const char *conf =
+		"id = \"yada-yada\"\n"
+		"seqno = 15\n"
+		"status = [\"READ\", \"WRITE\"]\n"
+		"flags = []\n"
+		"extent_size = 8192\n"
+		"physical_volumes {\n"
+		"    pv0 {\n"
+		"        id = \"abcd-efgh\"\n"
+		"    }\n"
+		"    pv1 {\n"
+		"        id = \"bbcd-efgh\"\n"
+		"    }\n"
+		"    pv2 {\n"
+		"        id = \"cbcd-efgh\"\n"
+		"    }\n"
+		"}\n";
+	struct dm_config_tree *tree = dm_config_from_string(conf);
+	struct dm_config_value *value;
+
+	CU_ASSERT(tree);
+	CU_ASSERT(dm_config_has_node(tree->root, "id"));
+	CU_ASSERT(dm_config_has_node(tree->root, "physical_volumes"));
+	CU_ASSERT(dm_config_has_node(tree->root, "physical_volumes/pv0"));
+	CU_ASSERT(dm_config_has_node(tree->root, "physical_volumes/pv0/id"));
+
+	CU_ASSERT(!strcmp(dm_config_find_str(tree->root, "id", "foo"), "yada-yada"));
+	CU_ASSERT(!strcmp(dm_config_find_str(tree->root, "idt", "foo"), "foo"));
+
+	CU_ASSERT(!strcmp(dm_config_find_str(tree->root, "physical_volumes/pv0/bb", "foo"), "foo"));
+	CU_ASSERT(!strcmp(dm_config_find_str(tree->root, "physical_volumes/pv0/id", "foo"), "abcd-efgh"));
+
+	CU_ASSERT(!dm_config_get_uint32(tree->root, "id", NULL));
+	CU_ASSERT(dm_config_get_uint32(tree->root, "extent_size", NULL));
+
+	/* FIXME: Currently everything parses as a list, even if it's not */
+	// CU_ASSERT(!dm_config_get_list(tree->root, "id", NULL));
+	// CU_ASSERT(!dm_config_get_list(tree->root, "extent_size", NULL));
+
+	CU_ASSERT(dm_config_get_list(tree->root, "flags", &value));
+	CU_ASSERT(value->next == NULL);
+	CU_ASSERT(dm_config_get_list(tree->root, "status", &value));
+	CU_ASSERT(value->next != NULL);
+
+	dm_config_destroy(tree);
+}
+
+CU_TestInfo config_list[] = {
+	{ (char*)"parse", test_parse },
+	CU_TEST_INFO_NULL
+};
+
--- LVM2/test/unit/Makefile.in	2011/12/11 15:15:57	1.4
+++ LVM2/test/unit/Makefile.in	2011/12/11 15:19:41	1.5
@@ -15,7 +15,7 @@
 top_builddir = @top_builddir@
 
 VPATH = $(srcdir)
-SOURCES = bitset_t.c matcher_t.c run.c
+SOURCES = bitset_t.c matcher_t.c config_t.c run.c
 TARGETS = run
 
 include $(top_builddir)/make.tmpl
--- LVM2/test/unit/run.c	2011/11/20 21:43:20	1.1
+++ LVM2/test/unit/run.c	2011/12/11 15:19:41	1.2
@@ -9,10 +9,12 @@
 
 DECL(bitset);
 DECL(regex);
+DECL(config);
 
 CU_SuiteInfo suites[] = {
 	USE(bitset),
 	USE(regex),
+	USE(config),
 	CU_SUITE_INFO_NULL
 };
 


