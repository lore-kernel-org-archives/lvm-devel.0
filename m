From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 23 Feb 2012 22:47:18 -0000
Subject: LVM2/test/unit Makefile.in run.c string_t.c
Message-ID: <20120223224718.12710.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-23 22:47:18

Modified files:
	test/unit      : Makefile.in run.c 
Added files:
	test/unit      : string_t.c 

Log message:
	Unit testing for some string libdm functions
	
	TODO: more functions need to be unit tested.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/unit/string_t.c.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/unit/Makefile.in.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/unit/run.c.diff?cvsroot=lvm2&r1=1.3&r2=1.4

/cvs/lvm2/LVM2/test/unit/string_t.c,v  -->  standard output
revision 1.1
--- LVM2/test/unit/string_t.c
+++ -	2012-02-23 22:47:18.303865000 +0000
@@ -0,0 +1,83 @@
+/*
+ * Copyright (C) 2012 Red Hat, Inc. All rights reserved.
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
+
+#include <stdio.h>
+#include <string.h>
+
+#include <CUnit/CUnit.h>
+
+int string_init(void);
+int string_fini(void);
+
+static struct dm_pool *mem = NULL;
+
+int string_init(void)
+{
+	mem = dm_pool_create("string test", 1024);
+
+	return (mem == NULL);
+}
+
+int string_fini(void)
+{
+	dm_pool_destroy(mem);
+
+	return 0;
+}
+
+/* TODO: Add more string unit tests here */
+
+static void test_strncpy(void)
+{
+	const char st[] = "1234567890";
+	char buf[sizeof(st)];
+
+	CU_ASSERT_EQUAL(dm_strncpy(buf, st, sizeof(buf)), 1);
+	CU_ASSERT_EQUAL(strcmp(buf, st), 0);
+
+	CU_ASSERT_EQUAL(dm_strncpy(buf, st, sizeof(buf) - 1), 0);
+	CU_ASSERT_EQUAL(strlen(buf) + 1, sizeof(buf) - 1);
+}
+
+static void test_asprint(void)
+{
+	const char st0[] = "";
+	const char st1[] = "12345678901";
+	const char st2[] = "1234567890123456789012345678901234567890123456789012345678901234567";
+	char *buf;
+	int a;
+
+	a = dm_asprintf(&buf, "%s", st0);
+	CU_ASSERT_EQUAL(strcmp(buf, st0), 0);
+	CU_ASSERT_EQUAL(a, sizeof(st0));
+	free(buf);
+
+	a = dm_asprintf(&buf, "%s", st1);
+	CU_ASSERT_EQUAL(strcmp(buf, st1), 0);
+	CU_ASSERT_EQUAL(a, sizeof(st1));
+	free(buf);
+
+	a = dm_asprintf(&buf, "%s", st2);
+	CU_ASSERT_EQUAL(a, sizeof(st2));
+	CU_ASSERT_EQUAL(strcmp(buf, st2), 0);
+	free(buf);
+}
+
+CU_TestInfo string_list[] = {
+	{ (char*)"asprint", test_asprint },
+	{ (char*)"strncpy", test_strncpy },
+	CU_TEST_INFO_NULL
+};
--- LVM2/test/unit/Makefile.in	2012/02/23 13:11:11	1.8
+++ LVM2/test/unit/Makefile.in	2012/02/23 22:47:17	1.9
@@ -15,7 +15,7 @@
 top_builddir = @top_builddir@
 
 VPATH = $(srcdir)
-SOURCES = bitset_t.c matcher_t.c config_t.c run.c
+SOURCES = bitset_t.c matcher_t.c config_t.c string_t.c run.c
 ifeq ("@TESTING@", "yes")
 TARGETS = run
 endif
--- LVM2/test/unit/run.c	2011/12/13 12:08:42	1.3
+++ LVM2/test/unit/run.c	2012/02/23 22:47:17	1.4
@@ -10,11 +10,13 @@
 DECL(bitset);
 DECL(regex);
 DECL(config);
+DECL(string);
 
 CU_SuiteInfo suites[] = {
 	USE(bitset),
 	USE(regex),
 	USE(config),
+	USE(string),
 	CU_SUITE_INFO_NULL
 };
 


