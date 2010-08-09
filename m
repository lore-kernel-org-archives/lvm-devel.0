From: thornber@sourceware.org <thornber@sourceware.org>
Date: 9 Aug 2010 10:56:04 -0000
Subject: LVM2 ./Makefile.in ./configure.in libdm/mm/dbg ...
Message-ID: <20100809105604.27966.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	thornber at sourceware.org	2010-08-09 10:56:03

Modified files:
	.              : Makefile.in configure.in 
	libdm/mm       : dbg_malloc.c pool-fast.c 
Added files:
	unit-tests/mm  : Makefile.in TESTS check_results 
	                 pool_valgrind_t.c 

Log message:
	[MM] Make valgrind aware of the pool allocators
	
	./configure with --enable-valgrind-pool to enable this.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/Makefile.in.diff?cvsroot=lvm2&r1=1.61&r2=1.62
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.151&r2=1.152
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/mm/dbg_malloc.c.diff?cvsroot=lvm2&r1=1.19&r2=1.20
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/mm/pool-fast.c.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/unit-tests/mm/Makefile.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/unit-tests/mm/TESTS.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/unit-tests/mm/check_results.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/unit-tests/mm/pool_valgrind_t.c.diff?cvsroot=lvm2&r1=NONE&r2=1.1

--- LVM2/Makefile.in	2010/08/02 13:56:34	1.61
+++ LVM2/Makefile.in	2010/08/09 10:56:01	1.62
@@ -137,9 +137,11 @@
 
 .PHONEY: unit-test ruby-test test-programs
 
+# FIXME: put dependencies on libdm and liblvm
 test-programs:
 	cd unit-tests/regex && $(MAKE)
 	cd unit-tests/datastruct && $(MAKE)
+	cd unit-tests/mm && $(MAKE)
 
 unit-test: test-programs
 	$(RUBY) report-generators/unit_test.rb $(shell find . -name TESTS)
--- LVM2/configure.in	2010/07/31 00:43:42	1.151
+++ LVM2/configure.in	2010/08/09 10:56:01	1.152
@@ -717,6 +717,19 @@
 fi
 
 ################################################################################
+dnl -- Enable valgrind awareness of memory pools
+AC_MSG_CHECKING(whether to enable valgrind awareness of pools)
+AC_ARG_ENABLE(valgrind_pool,
+              AC_HELP_STRING(--enable-valgrind-pool, [enable valgrind awareness of pools]),
+	      VALGRIND_POOL=$enableval, VALGRIND_POOL=no)
+AC_MSG_RESULT($VALGRIND_POOL)
+
+if test "$VALGRIND_POOL" = yes; then
+    AC_CHECK_HEADERS([valgrind/memcheck.h], , [AC_MSG_ERROR(bailing out)])
+    AC_DEFINE([VALGRIND_POOL], 1, [Enable a valgrind aware build of pool])
+fi
+
+################################################################################
 dnl -- Disable devmapper
 AC_MSG_CHECKING(whether to use device-mapper)
 AC_ARG_ENABLE(devmapper,
@@ -1343,6 +1356,7 @@
 udev/Makefile
 unit-tests/datastruct/Makefile
 unit-tests/regex/Makefile
+unit-tests/mm/Makefile
 ])
 AC_OUTPUT
 
--- LVM2/libdm/mm/dbg_malloc.c	2010/08/03 13:24:07	1.19
+++ LVM2/libdm/mm/dbg_malloc.c	2010/08/09 10:56:01	1.20
@@ -193,6 +193,13 @@
 		log_very_verbose("You have a memory leak:");
 
 	for (mb = _head; mb; mb = mb->next) {
+#ifdef VALGRIND_POOL
+		/*
+		 * We can't look at the memory in case it has had
+		 * VALGRIND_MAKE_MEM_NOACCESS called on it.
+		 */
+		str[0] = '\0';
+#else
 		for (c = 0; c < sizeof(str) - 1; c++) {
 			if (c >= mb->length)
 				str[c] = ' ';
@@ -204,6 +211,7 @@
 				str[c] = ((char *)mb->magic)[c];
 		}
 		str[sizeof(str) - 1] = '\0';
+#endif
 
 		LOG_MESG(_LOG_INFO, mb->file, mb->line, 0,
 			 "block %d at %p, size %" PRIsize_t "\t [%s]",
--- LVM2/libdm/mm/pool-fast.c	2010/03/25 18:22:04	1.8
+++ LVM2/libdm/mm/pool-fast.c	2010/08/09 10:56:01	1.9
@@ -1,6 +1,6 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.   
- * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
+ * Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
  *
  * This file is part of the device-mapper userspace tools.
  *
@@ -13,6 +13,10 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
+#ifdef VALGRIND_POOL
+#include "valgrind/memcheck.h"
+#endif
+
 #include "dmlib.h"
 
 struct chunk {
@@ -31,6 +35,7 @@
 
 void _align_chunk(struct chunk *c, unsigned alignment);
 struct chunk *_new_chunk(struct dm_pool *p, size_t s);
+static void _free_chunk(struct chunk *c);
 
 /* by default things come out aligned for doubles */
 #define DEFAULT_ALIGNMENT __alignof__ (double)
@@ -59,11 +64,11 @@
 void dm_pool_destroy(struct dm_pool *p)
 {
 	struct chunk *c, *pr;
-	dm_free(p->spare_chunk);
+	_free_chunk(p->spare_chunk);
 	c = p->chunk;
 	while (c) {
 		pr = c->prev;
-		dm_free(c);
+		_free_chunk(c);
 		c = pr;
 	}
 
@@ -100,6 +105,11 @@
 
 	r = c->begin;
 	c->begin += s;
+
+#ifdef VALGRIND_POOL
+	VALGRIND_MAKE_MEM_UNDEFINED(r, s);
+#endif
+
 	return r;
 }
 
@@ -122,11 +132,20 @@
 		if (((char *) c < (char *) ptr) &&
 		    ((char *) c->end > (char *) ptr)) {
 			c->begin = ptr;
+#ifdef VALGRIND_POOL
+			VALGRIND_MAKE_MEM_NOACCESS(c->begin, c->end - c->begin);
+#endif
 			break;
 		}
 
 		if (p->spare_chunk)
-			dm_free(p->spare_chunk);
+			_free_chunk(p->spare_chunk);
+
+		c->begin = (char *) (c + 1);
+#ifdef VALGRIND_POOL
+                VALGRIND_MAKE_MEM_NOACCESS(c->begin, c->end - c->begin);
+#endif
+
 		p->spare_chunk = c;
 		c = c->prev;
 	}
@@ -183,10 +202,24 @@
 			return 0;
 
 		_align_chunk(p->chunk, p->object_alignment);
+
+#ifdef VALGRIND_POOL
+		VALGRIND_MAKE_MEM_UNDEFINED(p->chunk->begin, p->object_len);
+#endif
+
 		memcpy(p->chunk->begin, c->begin, p->object_len);
+
+#ifdef VALGRIND_POOL
+		VALGRIND_MAKE_MEM_NOACCESS(c->begin, p->object_len);
+#endif
+
 		c = p->chunk;
 	}
 
+#ifdef VALGRIND_POOL
+	VALGRIND_MAKE_MEM_UNDEFINED(p->chunk->begin + p->object_len, delta);
+#endif
+
 	memcpy(c->begin + p->object_len, extra, delta);
 	p->object_len += delta;
 	return 1;
@@ -218,7 +251,7 @@
 	struct chunk *c;
 
 	if (p->spare_chunk &&
-	    ((p->spare_chunk->end - (char *) p->spare_chunk) >= s)) {
+	    ((p->spare_chunk->end - p->spare_chunk->begin) >= s)) {
 		/* reuse old chunk */
 		c = p->spare_chunk;
 		p->spare_chunk = 0;
@@ -229,12 +262,26 @@
 			return NULL;
 		}
 
+		c->begin = (char *) (c + 1);
 		c->end = (char *) c + s;
+
+#ifdef VALGRIND_POOL
+		VALGRIND_MAKE_MEM_NOACCESS(c->begin, c->end - c->begin);
+#endif
 	}
 
 	c->prev = p->chunk;
-	c->begin = (char *) (c + 1);
 	p->chunk = c;
-
 	return c;
 }
+
+static void _free_chunk(struct chunk *c)
+{
+	if (c) {
+#ifdef VALGRIND_POOL
+		VALGRIND_MAKE_MEM_UNDEFINED(c, c->end - (char *) c);
+#endif
+
+		dm_free(c);
+	}
+}
/cvs/lvm2/LVM2/unit-tests/mm/Makefile.in,v  -->  standard output
revision 1.1
--- LVM2/unit-tests/mm/Makefile.in
+++ -	2010-08-09 10:56:04.462442000 +0000
@@ -0,0 +1,31 @@
+#
+# Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
+# Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+#
+# This file is part of LVM2.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+srcdir = @srcdir@
+top_srcdir = @top_srcdir@
+top_builddir = @top_builddir@
+VPATH = @srcdir@
+
+SOURCES=\
+	pool_valgrind_t.c
+
+TARGETS=\
+	pool_valgrind_t
+
+include $(top_builddir)/make.tmpl
+DM_LIBS = -ldevmapper $(LIBS)
+
+pool_valgrind_t: pool_valgrind_t.o
+	$(CC) $(CFLAGS) -o $@ pool_valgrind_t.o $(LDFLAGS) $(DM_LIBS)
+
/cvs/lvm2/LVM2/unit-tests/mm/TESTS,v  -->  standard output
revision 1.1
--- LVM2/unit-tests/mm/TESTS
+++ -	2010-08-09 10:56:04.543312000 +0000
@@ -0,0 +1 @@
+valgrind pool awareness:valgrind ./pool_valgrind_t 2>&1 | ./check_results
/cvs/lvm2/LVM2/unit-tests/mm/check_results,v  -->  standard output
revision 1.1
--- LVM2/unit-tests/mm/check_results
+++ -	2010-08-09 10:56:04.625927000 +0000
@@ -0,0 +1,31 @@
+#!/usr/bin/env ruby1.9
+
+require 'pp'
+
+patterns = [
+            /Invalid read of size 1/,
+            /Invalid write of size 1/,
+            /Invalid read of size 1/,
+            /still reachable: [0-9,]+ bytes in 3 blocks/
+           ]
+
+lines = STDIN.readlines
+pp lines
+
+result = catch(:done) do
+  patterns.each do |pat|
+    loop do
+      throw(:done, false) if lines.size == 0
+
+      line = lines.shift
+      if line =~ pat
+        STDERR.puts "matched #{pat}"
+        break;
+      end
+    end
+  end
+
+  throw(:done, true)
+end
+
+exit(result ? 0 : 1)
/cvs/lvm2/LVM2/unit-tests/mm/pool_valgrind_t.c,v  -->  standard output
revision 1.1
--- LVM2/unit-tests/mm/pool_valgrind_t.c
+++ -	2010-08-09 10:56:04.730900000 +0000
@@ -0,0 +1,183 @@
+#include "libdevmapper.h"
+
+#include <assert.h>
+
+/*
+ * Checks that valgrind is picking up unallocated pool memory as
+ * uninitialised, even if the chunk has been recycled.
+ *
+ *     $ valgrind --track-origins=yes ./pool_valgrind_t
+ *
+ *     ==7023== Memcheck, a memory error detector
+ *     ==7023== Copyright (C) 2002-2009, and GNU GPL'd, by Julian Seward et al.
+ *     ==7023== Using Valgrind-3.6.0.SVN-Debian and LibVEX; rerun with -h for copyright info
+ *     ==7023== Command: ./pool_valgrind_t
+ *     ==7023==
+ *     first branch worked (as expected)
+ *     ==7023== Conditional jump or move depends on uninitialised value(s)
+ *     ==7023==    at 0x4009AC: main (in /home/ejt/work/lvm2/unit-tests/mm/pool_valgrind_t)
+ *     ==7023==  Uninitialised value was created by a client request
+ *     ==7023==    at 0x4E40CB8: dm_pool_free (in /home/ejt/work/lvm2/libdm/ioctl/libdevmapper.so.1.02)
+ *     ==7023==    by 0x4009A8: main (in /home/ejt/work/lvm2/unit-tests/mm/pool_valgrind_t)
+ *     ==7023==
+ *     second branch worked (valgrind should have flagged this as an error)
+ *     ==7023==
+ *     ==7023== HEAP SUMMARY:
+ *     ==7023==     in use at exit: 0 bytes in 0 blocks
+ *     ==7023==   total heap usage: 2 allocs, 2 frees, 2,104 bytes allocated
+ *     ==7023==
+ *     ==7023== All heap blocks were freed -- no leaks are possible
+ *     ==7023==
+ *     ==7023== For counts of detected and suppressed errors, rerun with: -v
+ *     ==7023== ERROR SUMMARY: 1 errors from 1 contexts (suppressed: 4 from 4)
+ */
+
+#define COUNT 10
+
+static void check_free()
+{
+        int i;
+        char *blocks[COUNT];
+        struct dm_pool *p = dm_pool_create("blah", 1024);
+
+        for (i = 0; i < COUNT; i++)
+                blocks[i] = dm_pool_alloc(p, 37);
+
+        /* check we can access the last block */
+        blocks[COUNT - 1][0] = 'E';
+        if (blocks[COUNT - 1][0] == 'E')
+                printf("first branch worked (as expected)\n");
+
+        dm_pool_free(p, blocks[5]);
+
+        if (blocks[COUNT - 1][0] == 'E')
+                printf("second branch worked (valgrind should have flagged this as an error)\n");
+
+        dm_pool_destroy(p);
+}
+
+/* Checks that freed chunks are marked NOACCESS */
+static void check_free2()
+{
+	struct dm_pool *p = dm_pool_create("", 900); /* 900 will get
+						      * rounded up to 1024,
+						      * 1024 would have got
+						      * rounded up to
+						      * 2048 */
+	char *data1, *data2;
+
+	assert(p);
+	data1 = dm_pool_alloc(p, 123);
+	assert(data1);
+
+	data1 = dm_pool_alloc(p, 1024);
+	assert(data1);
+
+	data2 = dm_pool_alloc(p, 123);
+	assert(data2);
+
+	data2[0] = 'A';		/* should work fine */
+
+	dm_pool_free(p, data1);
+
+	/*
+	 * so now the first chunk is active, the second chunk has become
+	 * the free one.
+	 */
+	data2[0] = 'B';		/* should prompt an invalid write error */
+
+	dm_pool_destroy(p);
+}
+
+static void check_alignment()
+{
+	/*
+	 * Pool always tries to allocate blocks with particular alignment.
+	 * So there are potentially small gaps between allocations.  This
+	 * test checks that valgrind is spotting illegal accesses to these
+	 * gaps.
+	 */
+
+	int i, sum;
+	struct dm_pool *p = dm_pool_create("blah", 1024);
+	char *data1, *data2;
+	char buffer[16];
+
+
+	data1 = dm_pool_alloc_aligned(p, 1, 4);
+	assert(data1);
+	data2 = dm_pool_alloc_aligned(p, 1, 4);
+	assert(data1);
+
+	snprintf(buffer, sizeof(buffer), "%c", *(data1 + 1)); /* invalid read size 1 */
+	dm_pool_destroy(p);
+}
+
+/*
+ * Looking at the code I'm not sure allocations that are near the chunk
+ * size are working.  So this test is trying to exhibit a specific problem.
+ */
+static void check_allocation_near_chunk_size()
+{
+	int i;
+	char *data;
+	struct dm_pool *p = dm_pool_create("", 900);
+
+	/*
+	 * allocate a lot and then free everything so we know there
+	 * is a spare chunk.
+	 */
+	for (i = 0; i < 1000; i++) {
+		data = dm_pool_alloc(p, 37);
+		memset(data, 0, 37);
+		assert(data);
+	}
+
+	dm_pool_empty(p);
+
+	/* now we allocate something close to the chunk size ... */
+	data = dm_pool_alloc(p, 1020);
+	assert(data);
+	memset(data, 0, 1020);
+
+	dm_pool_destroy(p);
+}
+
+/* FIXME: test the dbg_malloc@exit (this test should be in dbg_malloc) */
+static void check_leak_detection()
+{
+	int i;
+	struct dm_pool *p = dm_pool_create("", 1024);
+
+	for (i = 0; i < 10; i++)
+		dm_pool_alloc(p, (i + 1) * 37);
+}
+
+/* we shouldn't get any errors from this one */
+static void check_object_growth()
+{
+	int i;
+	struct dm_pool *p = dm_pool_create("", 32);
+	char data[100];
+	void *obj;
+
+	memset(data, 0, sizeof(data));
+
+	dm_pool_begin_object(p, 43);
+	for (i = 1; i < 100; i++)
+		dm_pool_grow_object(p, data, i);
+	obj = dm_pool_end_object(p);
+
+	dm_pool_destroy(p);
+}
+
+int main(int argc, char **argv)
+{
+	check_free();
+	check_free2();
+	check_alignment();
+	check_allocation_near_chunk_size();
+	check_leak_detection();
+	check_object_growth();
+        return 0;
+}


