From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:51:19 -0400
Subject: master - [device/bcache] stub a unit test
Message-ID: <201804231351.w3NDpJqp032330@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=46867a45d28ecb667d08df8d8cb497fffc10814d
Commit:        46867a45d28ecb667d08df8d8cb497fffc10814d
Parent:        cb2c4542a6028ef09d30bfdcdaef4e7ddb740ca7
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Thu Feb 1 09:54:56 2018 +0000
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:12:50 2018 -0500

[device/bcache] stub a unit test

---
 include/.symlinks.in  |    1 +
 lib/device/bcache.h   |    1 +
 test/unit/Makefile.in |    3 ++-
 test/unit/bcache_t.c  |   38 ++++++++++++++++++++++++++++++++++++++
 test/unit/run.c       |    1 +
 test/unit/units.h     |    1 +
 6 files changed, 44 insertions(+), 1 deletions(-)

diff --git a/include/.symlinks.in b/include/.symlinks.in
index a1b5c1e..3d50750 100644
--- a/include/.symlinks.in
+++ b/include/.symlinks.in
@@ -14,6 +14,7 @@
 @top_srcdir@/lib/config/defaults.h
 @top_srcdir@/lib/datastruct/btree.h
 @top_srcdir@/lib/datastruct/str_list.h
+ at top_srcdir@/lib/device/bcache.h
 @top_srcdir@/lib/device/dev-cache.h
 @top_srcdir@/lib/device/dev-ext-udev-constants.h
 @top_srcdir@/lib/device/dev-type.h
diff --git a/lib/device/bcache.h b/lib/device/bcache.h
index 3227744..0747b5a 100644
--- a/lib/device/bcache.h
+++ b/lib/device/bcache.h
@@ -16,6 +16,7 @@
 #define BCACHE_H
 
 #include <stdint.h>
+#include <stdbool.h>
 
 #include "libdevmapper.h"
 
diff --git a/test/unit/Makefile.in b/test/unit/Makefile.in
index 3de30f2..8127ec0 100644
--- a/test/unit/Makefile.in
+++ b/test/unit/Makefile.in
@@ -16,6 +16,7 @@ top_builddir = @top_builddir@
 
 VPATH = $(srcdir)
 UNITS = \
+	bcache_t.c \
 	bitset_t.c\
 	config_t.c\
 	dmlist_t.c\
@@ -37,7 +38,7 @@ SOURCES = $(UNITS)
 endif
 
 ifeq ("$(TESTING)", "yes")
-LDLIBS += -ldevmapper @CUNIT_LIBS@
+LDLIBS += $(LVMINTERNAL_LIBS) -ldevmapper -laio @CUNIT_LIBS@
 CFLAGS += @CUNIT_CFLAGS@
 
 check: unit
diff --git a/test/unit/bcache_t.c b/test/unit/bcache_t.c
new file mode 100644
index 0000000..da274a9
--- /dev/null
+++ b/test/unit/bcache_t.c
@@ -0,0 +1,38 @@
+/*
+ * Copyright (C) 2018 Red Hat, Inc. All rights reserved.
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
+#include "bcache.h"
+
+int bcache_init(void)
+{
+	return 0;
+}
+
+int bcache_fini(void)
+{
+	return 0;
+}
+
+static void test_create(void)
+{
+	struct bcache *cache = bcache_create(8, 16);
+	CU_ASSERT_PTR_NOT_NULL(cache);
+	bcache_destroy(cache);
+}
+
+CU_TestInfo bcache_list[] = {
+	{ (char*)"create", test_create },
+	CU_TEST_INFO_NULL
+};
diff --git a/test/unit/run.c b/test/unit/run.c
index 7372138..82090ba 100644
--- a/test/unit/run.c
+++ b/test/unit/run.c
@@ -13,6 +13,7 @@
 	.pTests = n##_list }
 
 CU_SuiteInfo suites[] = {
+	USE(bcache),
 	USE(bitset),
 	USE(config),
 	USE(dmlist),
diff --git a/test/unit/units.h b/test/unit/units.h
index 9eaa82f..319e7ce 100644
--- a/test/unit/units.h
+++ b/test/unit/units.h
@@ -23,6 +23,7 @@
 	int n ## _init(void); \
 	int n ## _fini(void);
 
+DECL(bcache);
 DECL(bitset);
 DECL(config);
 DECL(dmlist);


