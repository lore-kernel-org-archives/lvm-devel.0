From: Joe Thornber <thornber@redhat.com>
Date: Mon, 28 Mar 2011 16:16:46 +0100
Subject: [PATH 1/1] unit test for pool locking
Message-ID: <1301325406.3086.104.camel@ubuntu>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Kabi,

Can you add this to your pool locking patchset please?
Is it worth factoring the checksum code out and doing a separate test
for that?

Thanks,

- Joe




commit be4dd46d27d8bbe0170ed58c2baf9f73b2531f18
Author: Joe Thornber <joe.thornber@gmail.com>
Date:   Mon Mar 28 16:09:17 2011 +0100

    add a unit test for the pool locking api (not set/restore)

diff --git a/unit-tests/mm/Makefile.in b/unit-tests/mm/Makefile.in
index 1b3499e..29eaf0f 100644
--- a/unit-tests/mm/Makefile.in
+++ b/unit-tests/mm/Makefile.in
@@ -18,10 +18,14 @@ top_builddir = @top_builddir@
 VPATH = @srcdir@
 
 SOURCES=\
-	pool_valgrind_t.c
+	pool_valgrind_t.c \
+	pool_locking_bad_t.c \
+	pool_locking_t.c
 
 TARGETS=\
-	pool_valgrind_t
+	pool_valgrind_t \
+	pool_locking_bad_t \
+	pool_locking_t
 
 include $(top_builddir)/make.tmpl
 DM_LIBS = -ldevmapper $(LIBS)
@@ -29,3 +33,8 @@ DM_LIBS = -ldevmapper $(LIBS)
 pool_valgrind_t: pool_valgrind_t.o
 	$(CC) $(CFLAGS) -o $@ pool_valgrind_t.o $(LDFLAGS) $(DM_LIBS)
 
+pool_locking_bad_t: pool_locking_bad_t.o
+	$(CC) $(CFLAGS) -o $@ pool_locking_bad_t.o $(LDFLAGS) $(DM_LIBS)
+
+pool_locking_t: pool_locking_t.o
+	$(CC) $(CFLAGS) -o $@ pool_locking_t.o $(LDFLAGS) $(DM_LIBS)
diff --git a/unit-tests/mm/TESTS b/unit-tests/mm/TESTS
index 3bf3154..310c661 100644
--- a/unit-tests/mm/TESTS
+++ b/unit-tests/mm/TESTS
@@ -1 +1,3 @@
 valgrind pool awareness:valgrind ./pool_valgrind_t 2>&1
| ./check_results
+pool locking (bad case):./expect-failure ./pool_locking_bad_t
+pool locking (good case):./pool_locking_t
diff --git a/unit-tests/mm/expect-failure b/unit-tests/mm/expect-failure
new file mode 100755
index 0000000..0a75e9c
--- /dev/null
+++ b/unit-tests/mm/expect-failure
@@ -0,0 +1,6 @@
+#!/bin/sh
+
+if $@
+then
+    exit 1
+fi
\ No newline at end of file
diff --git a/unit-tests/mm/pool_locking_bad_t.c
b/unit-tests/mm/pool_locking_bad_t.c
new file mode 100644
index 0000000..6cd0992
--- /dev/null
+++ b/unit-tests/mm/pool_locking_bad_t.c
@@ -0,0 +1,39 @@
+#include "libdevmapper.h"
+
+#include <assert.h>
+
+static void check_lock_spots_mutation()
+{
+	struct dm_pool *p;
+	char *data = NULL;
+	unsigned i;
+
+	p = dm_pool_create("", 34);
+	assert(p);
+
+	for (i = 0; i < 677; i++) {
+		char *ptr = dm_pool_alloc(p, 3);
+		assert(ptr);
+
+		if (i == 123)
+			data = ptr;
+	}
+
+	data[0] = 'o';
+	data[1] = 'n';
+	data[2] = 'e';
+
+	assert(dm_pool_lock(p, 1));
+	data[0] = 't';
+	data[1] = 'w';
+	data[2] = 'o';
+	assert(dm_pool_unlock(p));
+	dm_pool_destroy(p);
+}
+
+int main(int argc, char **argv)
+{
+	/* we expect this to fail, hence the need */
+	check_lock_spots_mutation();
+	return 0;
+}
diff --git a/unit-tests/mm/pool_locking_t.c
b/unit-tests/mm/pool_locking_t.c
new file mode 100644
index 0000000..bf082d3
--- /dev/null
+++ b/unit-tests/mm/pool_locking_t.c
@@ -0,0 +1,39 @@
+#include "libdevmapper.h"
+
+#include <assert.h>
+
+static void check_unlock_allows_mutation()
+{
+	struct dm_pool *p;
+	char *data = NULL;
+	unsigned i;
+
+	p = dm_pool_create("", 34);
+	assert(p);
+
+	for (i = 0; i < 677; i++) {
+		char *ptr = dm_pool_alloc(p, 3);
+		assert(ptr);
+
+		if (i == 123)
+			data = ptr;
+	}
+
+	data[0] = 'o';
+	data[1] = 'n';
+	data[2] = 'e';
+
+	assert(dm_pool_lock(p, 1));
+	assert(dm_pool_locked(p));
+	assert(dm_pool_unlock(p));
+	data[0] = 't';
+	data[1] = 'w';
+	data[2] = 'o';
+	dm_pool_destroy(p);
+}
+
+int main(int argc, char **argv)
+{
+	check_unlock_allows_mutation();
+	return 0;
+}



