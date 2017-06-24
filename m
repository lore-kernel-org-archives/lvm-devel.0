From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 24 Jun 2017 11:59:48 -0400
Subject: master - tests: unit test for percent printing
Message-ID: <201706241559.v5OFxmWr026784@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cefb8bcfc4daf56309038088325c056b0860d5a1
Commit:        cefb8bcfc4daf56309038088325c056b0860d5a1
Parent:        1bd4b0059bbfebe912115f0889e8f3489422f5fc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Jun 24 13:33:36 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Jun 24 17:44:42 2017 +0200

tests: unit test for percent printing

---
 test/unit/Makefile.in |    1 +
 test/unit/percent_t.c |  101 +++++++++++++++++++++++++++++++++++++++++++++++++
 test/unit/run.c       |    1 +
 test/unit/units.h     |    3 +-
 4 files changed, 105 insertions(+), 1 deletions(-)

diff --git a/test/unit/Makefile.in b/test/unit/Makefile.in
index 7aa180f..3de30f2 100644
--- a/test/unit/Makefile.in
+++ b/test/unit/Makefile.in
@@ -21,6 +21,7 @@ UNITS = \
 	dmlist_t.c\
 	dmstatus_t.c\
 	matcher_t.c\
+	percent_t.c\
 	string_t.c\
 	run.c
 
diff --git a/test/unit/percent_t.c b/test/unit/percent_t.c
new file mode 100644
index 0000000..650f381
--- /dev/null
+++ b/test/unit/percent_t.c
@@ -0,0 +1,101 @@
+/*
+ * Copyright (C) 2017 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU General Public License v.2.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+ */
+
+#include "units.h"
+
+#include <stdio.h>
+#include <string.h>
+
+int percent_init(void)
+{
+	return 0;
+}
+
+int percent_fini(void)
+{
+	return 0;
+}
+
+static void test_percent_100(void)
+{
+	char buf[32];
+
+        /* Check 100% is shown only for DM_PERCENT_100*/
+	dm_percent_t p_100 = dm_make_percent(100, 100);
+        dm_percent_t p1_100 = dm_make_percent(100000, 100000);
+        dm_percent_t n_100 = dm_make_percent(999999, 1000000);
+
+	CU_ASSERT_EQUAL(p_100, DM_PERCENT_100);
+	CU_ASSERT_EQUAL(p1_100, DM_PERCENT_100);
+	CU_ASSERT_NOT_EQUAL(n_100, DM_PERCENT_100);
+
+        dm_snprintf(buf, sizeof(buf), "%.2f", dm_percent_to_float(p_100));
+	CU_ASSERT_EQUAL(strcmp(buf, "100.00"), 0);
+
+	dm_snprintf(buf, sizeof(buf), "%.2f", dm_percent_to_float(p1_100));
+	CU_ASSERT_EQUAL(strcmp(buf, "100.00"), 0);
+
+	dm_snprintf(buf, sizeof(buf), "%.2f", dm_percent_to_float(n_100));
+	CU_ASSERT_NOT_EQUAL(strcmp(buf, "99.99"), 0); /* Would like to gett */
+
+	dm_snprintf(buf, sizeof(buf), "%.2f", dm_percent_to_round_float(n_100, 2));
+	CU_ASSERT_EQUAL(strcmp(buf, "99.99"), 0);
+
+	dm_snprintf(buf, sizeof(buf), "%.3f", dm_percent_to_round_float(n_100, 3));
+	CU_ASSERT_EQUAL(strcmp(buf, "99.999"), 0);
+
+	dm_snprintf(buf, sizeof(buf), "%.4f", dm_percent_to_round_float(n_100, 4));
+	CU_ASSERT_EQUAL(strcmp(buf, "99.9999"), 0);
+
+	dm_snprintf(buf, sizeof(buf), "%d", (int)dm_percent_to_round_float(n_100, 0));
+	CU_ASSERT_EQUAL(strcmp(buf, "99"), 0);
+}
+
+static void test_percent_0(void)
+{
+	char buf[32];
+
+	/* Check 0% is shown only for DM_PERCENT_0 */
+	dm_percent_t p_0 = dm_make_percent(0, 100);
+        dm_percent_t p1_0 = dm_make_percent(0, 100000);
+        dm_percent_t n_0 = dm_make_percent(1, 1000000);
+
+	CU_ASSERT_EQUAL(p_0, DM_PERCENT_0);
+	CU_ASSERT_EQUAL(p1_0, DM_PERCENT_0);
+	CU_ASSERT_NOT_EQUAL(n_0, DM_PERCENT_0);
+
+        dm_snprintf(buf, sizeof(buf), "%.2f", dm_percent_to_float(p_0));
+	CU_ASSERT_EQUAL(strcmp(buf, "0.00"), 0);
+
+	dm_snprintf(buf, sizeof(buf), "%.2f", dm_percent_to_float(p1_0));
+	CU_ASSERT_EQUAL(strcmp(buf, "0.00"), 0);
+
+	dm_snprintf(buf, sizeof(buf), "%.2f", dm_percent_to_float(n_0));
+	CU_ASSERT_NOT_EQUAL(strcmp(buf, "0.01"), 0);
+
+	dm_snprintf(buf, sizeof(buf), "%.2f", dm_percent_to_round_float(n_0, 2));
+	CU_ASSERT_EQUAL(strcmp(buf, "0.01"), 0);
+
+	dm_snprintf(buf, sizeof(buf), "%.3f", dm_percent_to_round_float(n_0, 3));
+	CU_ASSERT_EQUAL(strcmp(buf, "0.001"), 0);
+
+	dm_snprintf(buf, sizeof(buf), "%d", (int)dm_percent_to_round_float(n_0, 0));
+	CU_ASSERT_EQUAL(strcmp(buf, "1"), 0);
+}
+
+CU_TestInfo percent_list[] = {
+	{ (char*)"percent_100", test_percent_100 },
+	{ (char*)"percent_0", test_percent_0 },
+	CU_TEST_INFO_NULL
+};
diff --git a/test/unit/run.c b/test/unit/run.c
index 5364107..7372138 100644
--- a/test/unit/run.c
+++ b/test/unit/run.c
@@ -18,6 +18,7 @@ CU_SuiteInfo suites[] = {
 	USE(dmlist),
 	USE(dmstatus),
 	USE(regex),
+	USE(percent),
 	USE(string),
 	CU_SUITE_INFO_NULL
 };
diff --git a/test/unit/units.h b/test/unit/units.h
index 208ff7a..9eaa82f 100644
--- a/test/unit/units.h
+++ b/test/unit/units.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2015 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2015-2017 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -28,6 +28,7 @@ DECL(config);
 DECL(dmlist);
 DECL(dmstatus);
 DECL(regex);
+DECL(percent);
 DECL(string);
 
 #endif


