From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 27 Nov 2015 10:42:21 +0000 (UTC)
Subject: master - tests: make unit testing usable again
Message-ID: <20151127104221.718A96104A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1fb8d746d62aa14c5ed18bb917b5b0d447d436ae
Commit:        1fb8d746d62aa14c5ed18bb917b5b0d447d436ae
Parent:        ec647f1d431214264aaa396b6d0ba8e97738f00b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 27 10:54:57 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 27 11:22:21 2015 +0100

tests: make unit testing usable again

Make unit tests usable/compilable with newer header files.
Add 'initial' dmlist_t  for list tests.
More will come...
---
 test/unit/Makefile.in |   13 +++++++++++--
 test/unit/bitset_t.c  |    6 +-----
 test/unit/config_t.c  |    6 +-----
 test/unit/dmlist_t.c  |   49 +++++++++++++++++++++++++++++++++++++++++++++++++
 test/unit/matcher_t.c |   17 +----------------
 test/unit/run.c       |   33 ++++++++++++++++++++-------------
 test/unit/string_t.c  |    7 +------
 test/unit/units.h     |   32 ++++++++++++++++++++++++++++++++
 8 files changed, 116 insertions(+), 47 deletions(-)

diff --git a/test/unit/Makefile.in b/test/unit/Makefile.in
index 62a0077..13d2f3c 100644
--- a/test/unit/Makefile.in
+++ b/test/unit/Makefile.in
@@ -15,7 +15,15 @@ top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 
 VPATH = $(srcdir)
-UNITS = bitset_t.c matcher_t.c config_t.c string_t.c run.c
+UNITS = \
+	bitset_t.c\
+	config_t.c\
+	dmlist_t.c\
+	matcher_t.c\
+	string_t.c\
+	run.c
+
+include $(top_builddir)/make.tmpl
 
 ifeq ($(MAKECMDGOALS),distclean)
 SOURCES = $(UNITS)
@@ -26,13 +34,14 @@ SOURCES = $(UNITS)
 TARGETS = run
 endif
 
-include $(top_builddir)/make.tmpl
 ifeq ("$(TESTING)", "yes")
 LDLIBS += -ldevmapper @CUNIT_LIBS@
 CFLAGS += @CUNIT_CFLAGS@
 
 check: unit
 
+$(TARGETS): $(OBJECTS)
+
 unit: $(TARGETS)
 	@echo Running unit tests
 	LD_LIBRARY_PATH=$(top_builddir)/libdm ./$(TARGETS)
diff --git a/test/unit/bitset_t.c b/test/unit/bitset_t.c
index 499de32..8ef040d 100644
--- a/test/unit/bitset_t.c
+++ b/test/unit/bitset_t.c
@@ -12,11 +12,7 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
-#include "libdevmapper.h"
-#include <CUnit/CUnit.h>
-
-int bitset_init(void);
-int bitset_fini(void);
+#include "units.h"
 
 enum {
         NR_BITS = 137
diff --git a/test/unit/config_t.c b/test/unit/config_t.c
index 9a8b693..d2d2926 100644
--- a/test/unit/config_t.c
+++ b/test/unit/config_t.c
@@ -12,11 +12,7 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
-#include "libdevmapper.h"
-#include <CUnit/CUnit.h>
-
-int config_init(void);
-int config_fini(void);
+#include "units.h"
 
 static struct dm_pool *mem;
 
diff --git a/test/unit/dmlist_t.c b/test/unit/dmlist_t.c
new file mode 100644
index 0000000..3930720
--- /dev/null
+++ b/test/unit/dmlist_t.c
@@ -0,0 +1,49 @@
+/*
+ * Copyright (C) 2015 Red Hat, Inc. All rights reserved.
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
+#include "units.h"
+
+int dmlist_init(void)
+{
+	return 0;
+}
+
+int dmlist_fini(void)
+{
+	return 0;
+}
+
+static void test_dmlist_splice(void)
+{
+	struct dm_list a[10];
+	struct dm_list list1;
+	struct dm_list list2;
+	unsigned i;
+
+	dm_list_init(&list1);
+	dm_list_init(&list2);
+
+	for (i = 0; i < DM_ARRAY_SIZE@; i++)
+		dm_list_add(&list1, &a[i]);
+
+	dm_list_splice(&list2, &list1);
+	CU_ASSERT_EQUAL(dm_list_size(&list1), 0);
+	CU_ASSERT_EQUAL(dm_list_size(&list2), 10);
+}
+
+CU_TestInfo dmlist_list[] = {
+	{ (char*)"dmlist_splice", test_dmlist_splice },
+	//{ (char*)"dmlist", test_strncpy },
+	CU_TEST_INFO_NULL
+};
diff --git a/test/unit/matcher_t.c b/test/unit/matcher_t.c
index 7331a82..7b68554 100644
--- a/test/unit/matcher_t.c
+++ b/test/unit/matcher_t.c
@@ -13,24 +13,10 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
-#include "libdevmapper.h"
-#include "log.h"
+#include "units.h"
 
-#include <stdio.h>
-#include <ctype.h>
-#include <string.h>
-#include <sys/types.h>
-#include <sys/stat.h>
-#include <unistd.h>
-#include <fcntl.h>
-#include <sys/mman.h>
-
-#include <CUnit/CUnit.h>
 #include "matcher_data.h"
 
-int regex_init(void);
-int regex_fini(void);
-
 static struct dm_pool *mem = NULL;
 
 int regex_init(void) {
@@ -82,4 +68,3 @@ CU_TestInfo regex_list[] = {
 	{ (char*)"matching", test_matching },
 	CU_TEST_INFO_NULL
 };
-
diff --git a/test/unit/run.c b/test/unit/run.c
index 482498a..c46266d 100644
--- a/test/unit/run.c
+++ b/test/unit/run.c
@@ -1,29 +1,36 @@
-#include <CUnit/CUnit.h>
+#include "units.h"
 #include <CUnit/Basic.h>
 
-#define DECL(n) \
-	extern CU_TestInfo n ## _list[]; \
-	int n ## _init(void); \
-	int n ## _fini(void);
-#define USE(n) { (char*) #n, n##_init, n##_fini, n##_list }
+#include <stdio.h>
+#include <stdlib.h>
 
-DECL(bitset);
-DECL(regex);
-DECL(config);
-DECL(string);
+/* Setup SuiteInfo struct in a  compatible way across different CUnit versions */
+/* old version of CUnit has used char* for .pName, so using cast here */
+#define USE(n) { \
+	.pName = (char*) #n, \
+	.pInitFunc = n##_init, \
+	.pCleanupFunc = n##_fini, \
+	.pTests = n##_list }
 
 CU_SuiteInfo suites[] = {
 	USE(bitset),
-	USE(regex),
 	USE(config),
+	USE(dmlist),
+	USE(regex),
 	USE(string),
 	CU_SUITE_INFO_NULL
 };
 
 int main(int argc, char **argv) {
-	CU_initialize_registry();
+	if (CU_initialize_registry() != CUE_SUCCESS) {
+		printf("Initialization of Test Registry failed.\n");
+		return CU_get_error();
+	}
+
 	CU_register_suites(suites);
 	CU_basic_set_mode(CU_BRM_VERBOSE);
 	CU_basic_run_tests();
-	return CU_get_number_of_failures() != 0;
+	CU_cleanup_registry();
+
+	return (CU_get_number_of_failures() != 0);
 }
diff --git a/test/unit/string_t.c b/test/unit/string_t.c
index df72505..4b1b1bf 100644
--- a/test/unit/string_t.c
+++ b/test/unit/string_t.c
@@ -12,16 +12,11 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
-#include "libdevmapper.h"
+#include "units.h"
 
 #include <stdio.h>
 #include <string.h>
 
-#include <CUnit/CUnit.h>
-
-int string_init(void);
-int string_fini(void);
-
 static struct dm_pool *mem = NULL;
 
 int string_init(void)
diff --git a/test/unit/units.h b/test/unit/units.h
new file mode 100644
index 0000000..4ae66b9
--- /dev/null
+++ b/test/unit/units.h
@@ -0,0 +1,32 @@
+/*
+ * Copyright (C) 2015 Red Hat, Inc. All rights reserved.
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
+#ifndef _UNITS_H
+#define _UNITS_H
+
+#include "libdevmapper.h"
+#include <CUnit/CUnit.h>
+
+#define DECL(n) \
+	extern CU_TestInfo n ## _list[];\
+	int n ## _init(void); \
+	int n ## _fini(void);
+
+DECL(bitset);
+DECL(config);
+DECL(dmlist);
+DECL(regex);
+DECL(string);
+
+#endif


