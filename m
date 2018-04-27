From: Joe Thornber <thornber@sourceware.org>
Date: Fri, 27 Apr 2018 09:25:46 -0400
Subject: master - bcache: write some sanity checks for the asyn io engine
Message-ID: <201804271325.w3RDPkwF014065@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=54856b2965f4dc9fa05201af6407c1ed89577bb8
Commit:        54856b2965f4dc9fa05201af6407c1ed89577bb8
Parent:        e890c37704be3482a5d66e59baa2811d99e3eb93
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Fri Apr 27 14:24:05 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Fri Apr 27 14:24:05 2018 +0100

bcache: write some sanity checks for the asyn io engine

Mainly checks aio is installed properly.
---
 unit-test/Makefile.in   |    1 +
 unit-test/io_engine_t.c |  145 +++++++++++++++++++++++++++++++++++++++++++++++
 unit-test/units.h       |    2 +
 3 files changed, 148 insertions(+), 0 deletions(-)

diff --git a/unit-test/Makefile.in b/unit-test/Makefile.in
index 5577706..ad7c549 100644
--- a/unit-test/Makefile.in
+++ b/unit-test/Makefile.in
@@ -16,6 +16,7 @@ UNIT_SOURCE=\
 	unit-test/config_t.c \
 	unit-test/dmlist_t.c \
 	unit-test/dmstatus_t.c \
+	unit-test/io_engine_t.c \
 	unit-test/matcher_t.c \
 	unit-test/framework.c \
 	unit-test/percent_t.c \
diff --git a/unit-test/io_engine_t.c b/unit-test/io_engine_t.c
new file mode 100644
index 0000000..6219d79
--- /dev/null
+++ b/unit-test/io_engine_t.c
@@ -0,0 +1,145 @@
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
+#define _GNU_SOURCE
+
+#include <errno.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <sys/types.h>
+#include <sys/stat.h>
+#include <fcntl.h>
+#include <unistd.h>
+
+#include "bcache.h"
+#include "framework.h"
+#include "units.h"
+
+//----------------------------------------------------------------
+
+#define SECTOR_SIZE 512
+#define BLOCK_SIZE_SECTORS 64
+
+struct fixture {
+	struct io_engine *e;
+	void *data;
+
+	char fname[64];
+	int fd;
+};
+
+static void *_fix_init(void)
+{
+        struct fixture *f = malloc(sizeof(*f));
+
+        T_ASSERT(f);
+        f->e = create_async_io_engine();
+        T_ASSERT(f->e);
+        f->data = aligned_alloc(4096, SECTOR_SIZE * BLOCK_SIZE_SECTORS);
+        T_ASSERT(f->data);
+
+        snprintf(f->fname, sizeof(f->fname), "unit-test-XXXXXX");
+	f->fd = mkostemp(f->fname, O_RDWR | O_CREAT | O_EXCL);
+	T_ASSERT(f->fd >= 0);
+
+	memset(f->data, 0, SECTOR_SIZE * BLOCK_SIZE_SECTORS);
+	write(f->fd, f->data, SECTOR_SIZE * BLOCK_SIZE_SECTORS);
+	lseek(f->fd, 0, SEEK_SET);
+        return f;
+}
+
+static void _fix_exit(void *fixture)
+{
+        struct fixture *f = fixture;
+
+	close(f->fd);
+	unlink(f->fname);
+        free(f->data);
+        f->e->destroy(f->e);
+        free(f);
+}
+
+static void _test_create(void *fixture)
+{
+	// empty
+}
+
+struct io {
+	bool completed;
+	int error;
+};
+
+static void _io_init(struct io *io)
+{
+	io->completed = false;
+	io->error = 0;
+}
+
+static void _complete_io(void *context, int io_error)
+{
+	struct io *io = context;
+	io->completed = true;
+	io->error = io_error;
+}
+
+static void _test_read(void *fixture)
+{
+	struct fixture *f = fixture;
+
+	struct io io;
+
+	_io_init(&io);
+	T_ASSERT(f->e->issue(f->e, DIR_READ, f->fd, 0, BLOCK_SIZE_SECTORS, f->data, &io));
+	T_ASSERT(f->e->wait(f->e, _complete_io));
+	T_ASSERT(io.completed);
+	T_ASSERT(!io.error);
+}
+
+static void _test_write(void *fixture)
+{
+	struct fixture *f = fixture;
+
+	struct io io;
+
+	_io_init(&io);
+	T_ASSERT(f->e->issue(f->e, DIR_WRITE, f->fd, 0, BLOCK_SIZE_SECTORS, f->data, &io));
+	T_ASSERT(f->e->wait(f->e, _complete_io));
+	T_ASSERT(io.completed);
+	T_ASSERT(!io.error);
+}
+
+//----------------------------------------------------------------
+
+#define T(path, desc, fn) register_test(ts, "/base/device/bcache/io-engine/" path, desc, fn)
+
+static struct test_suite *_tests(void)
+{
+        struct test_suite *ts = test_suite_create(_fix_init, _fix_exit);
+        if (!ts) {
+                fprintf(stderr, "out of memory\n");
+                exit(1);
+        }
+
+        T("create-destroy", "simple create/destroy", _test_create);
+        T("create-read", "read sanity check", _test_read);
+        T("create-write", "write sanity check", _test_write);
+
+        return ts;
+}
+
+void io_engine_tests(struct dm_list *all_tests)
+{
+	dm_list_add(all_tests, &_tests()->list);
+}
+
diff --git a/unit-test/units.h b/unit-test/units.h
index 47f04c2..dbbd41e 100644
--- a/unit-test/units.h
+++ b/unit-test/units.h
@@ -25,6 +25,7 @@ void bitset_tests(struct dm_list *suites);
 void config_tests(struct dm_list *suites);
 void dm_list_tests(struct dm_list *suites);
 void dm_status_tests(struct dm_list *suites);
+void io_engine_tests(struct dm_list *suites);
 void regex_tests(struct dm_list *suites);
 void percent_tests(struct dm_list *suites);
 void string_tests(struct dm_list *suites);
@@ -37,6 +38,7 @@ static inline void register_all_tests(struct dm_list *suites)
 	config_tests(suites);
 	dm_list_tests(suites);
 	dm_status_tests(suites);
+	io_engine_tests(suites);
 	regex_tests(suites);
 	percent_tests(suites);
 	string_tests(suites);


