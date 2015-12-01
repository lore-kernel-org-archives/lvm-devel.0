From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  1 Dec 2015 12:04:47 +0000 (UTC)
Subject: master - tests: unit test for mirror status
Message-ID: <20151201120447.4883060CF9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c717ea5fc0b5096a1655313017611b4305e883d3
Commit:        c717ea5fc0b5096a1655313017611b4305e883d3
Parent:        fa87979004a0bbce2e4e3eacaeab0c4e0e0827eb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 30 20:54:52 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Dec 1 13:00:52 2015 +0100

tests: unit test for mirror status

---
 test/unit/Makefile.in  |    5 ++-
 test/unit/dmstatus_t.c |   72 ++++++++++++++++++++++++++++++++++++++++++++++++
 test/unit/run.c        |    1 +
 test/unit/units.h      |    1 +
 4 files changed, 77 insertions(+), 2 deletions(-)

diff --git a/test/unit/Makefile.in b/test/unit/Makefile.in
index 13d2f3c..87eaf2b 100644
--- a/test/unit/Makefile.in
+++ b/test/unit/Makefile.in
@@ -1,4 +1,4 @@
-# Copyright (C) 2011-2013 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2011-2015 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -19,6 +19,7 @@ UNITS = \
 	bitset_t.c\
 	config_t.c\
 	dmlist_t.c\
+	dmstatus_t.c\
 	matcher_t.c\
 	string_t.c\
 	run.c
@@ -40,7 +41,7 @@ CFLAGS += @CUNIT_CFLAGS@
 
 check: unit
 
-$(TARGETS): $(OBJECTS)
+$(TARGETS): $(OBJECTS) $(top_builddir)/libdm/libdevmapper.$(LIB_SUFFIX)
 
 unit: $(TARGETS)
 	@echo Running unit tests
diff --git a/test/unit/dmstatus_t.c b/test/unit/dmstatus_t.c
new file mode 100644
index 0000000..de6defa
--- /dev/null
+++ b/test/unit/dmstatus_t.c
@@ -0,0 +1,72 @@
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
+static struct dm_pool *_mem;
+
+int dmstatus_init(void)
+{
+	_mem = dm_pool_create("dmstatus test", 1024);
+	return (_mem == NULL);
+}
+
+int dmstatus_fini(void)
+{
+	dm_pool_destroy(_mem);
+	return 0;
+}
+
+static void _test_mirror_status(void)
+{
+	struct dm_status_mirror *s = NULL;
+
+	CU_ASSERT(dm_get_status_mirror(_mem,
+				       "2 253:1 253:2 80/81 1 AD 3 disk 253:0 A",
+				       &s));
+	if (s) {
+		CU_ASSERT_EQUAL(s->total_regions, 81);
+		CU_ASSERT_EQUAL(s->insync_regions, 80);
+		CU_ASSERT_EQUAL(s->dev_count, 2);
+		CU_ASSERT_EQUAL(s->devs[0].health, 'A');
+		CU_ASSERT_EQUAL(s->devs[0].major, 253);
+		CU_ASSERT_EQUAL(s->devs[0].minor, 1);
+		CU_ASSERT_EQUAL(s->devs[1].health, 'D');
+		CU_ASSERT_EQUAL(s->devs[1].major, 253);
+		CU_ASSERT_EQUAL(s->devs[1].minor, 2);
+		CU_ASSERT_EQUAL(s->log_count, 1);
+		CU_ASSERT_EQUAL(s->logs[0].major, 253);
+		CU_ASSERT_EQUAL(s->logs[0].minor, 0);
+		CU_ASSERT_EQUAL(s->logs[0].health, 'A');
+		CU_ASSERT(!strcmp(s->log_type, "disk"));
+	}
+
+	CU_ASSERT(dm_get_status_mirror(_mem,
+				       "4 253:1 253:2 253:3 253:4 10/10 1 ADFF 1 core",
+				       &s));
+	if (s) {
+		CU_ASSERT_EQUAL(s->total_regions, 10);
+		CU_ASSERT_EQUAL(s->insync_regions, 10);
+		CU_ASSERT_EQUAL(s->dev_count, 4);
+		CU_ASSERT_EQUAL(s->devs[3].minor, 4);
+		CU_ASSERT_EQUAL(s->devs[3].health, 'F');
+		CU_ASSERT_EQUAL(s->log_count, 0);
+		CU_ASSERT(!strcmp(s->log_type, "core"));
+	}
+}
+
+CU_TestInfo dmstatus_list[] = {
+	{ (char*)"mirror_status", _test_mirror_status },
+	CU_TEST_INFO_NULL
+};
diff --git a/test/unit/run.c b/test/unit/run.c
index c46266d..5364107 100644
--- a/test/unit/run.c
+++ b/test/unit/run.c
@@ -16,6 +16,7 @@ CU_SuiteInfo suites[] = {
 	USE(bitset),
 	USE(config),
 	USE(dmlist),
+	USE(dmstatus),
 	USE(regex),
 	USE(string),
 	CU_SUITE_INFO_NULL
diff --git a/test/unit/units.h b/test/unit/units.h
index 4ae66b9..5eed535 100644
--- a/test/unit/units.h
+++ b/test/unit/units.h
@@ -26,6 +26,7 @@
 DECL(bitset);
 DECL(config);
 DECL(dmlist);
+DECL(dmstatus);
 DECL(regex);
 DECL(string);
 


