From: thornber@sourceware.org <thornber@sourceware.org>
Date: 20 Jul 2010 15:25:40 -0000
Subject: LVM2 ./Makefile.in ./configure.in unit-tests/d ...
Message-ID: <20100720152540.21033.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	thornber at sourceware.org	2010-07-20 15:25:40

Modified files:
	.              : Makefile.in configure.in 
Added files:
	unit-tests/datastruct: Makefile.in TESTS bitset_t.c 

Log message:
	Add a unit test for the recent changes to dm_bit_get_next()

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/Makefile.in.diff?cvsroot=lvm2&r1=1.57&r2=1.58
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.148&r2=1.149
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/unit-tests/datastruct/Makefile.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/unit-tests/datastruct/TESTS.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/unit-tests/datastruct/bitset_t.c.diff?cvsroot=lvm2&r1=NONE&r2=1.1

--- LVM2/Makefile.in	2010/07/20 15:21:32	1.57
+++ LVM2/Makefile.in	2010/07/20 15:25:39	1.58
@@ -135,7 +135,8 @@
 .PHONEY: unit-test ruby-test test-programs
 
 test-programs:
-	$(MAKE) unit-tests/regex
+	cd unit-tests/regex && $(MAKE)
+	cd unit-tests/datastruct && $(MAKE)
 
 unit-test: test-programs
 	$(RUBY) report-generators/unit_test.rb $(shell find . -name TESTS)
--- LVM2/configure.in	2010/07/20 15:21:32	1.148
+++ LVM2/configure.in	2010/07/20 15:25:39	1.149
@@ -1333,6 +1333,7 @@
 test/api/Makefile
 tools/Makefile
 udev/Makefile
+unit-tests/datastruct/Makefile
 unit-tests/regex/Makefile
 ])
 AC_OUTPUT
/cvs/lvm2/LVM2/unit-tests/datastruct/Makefile.in,v  -->  standard output
revision 1.1
--- LVM2/unit-tests/datastruct/Makefile.in
+++ -	2010-07-20 15:25:40.539278000 +0000
@@ -0,0 +1,32 @@
+#
+# Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
+# Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
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
+
+SOURCES=\
+	bitset_t.c
+
+TARGETS=\
+	bitset_t
+
+include $(top_builddir)/make.tmpl
+
+INCLUDES += -I$(top_srcdir)/libdm
+DM_DEPS = $(top_builddir)/libdm/libdevmapper.so
+DM_LIBS = -ldevmapper $(LIBS)
+
+bitset_t: bitset_t.o $(DM_DEPS)
+	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ bitset_t.o $(DM_LIBS)
/cvs/lvm2/LVM2/unit-tests/datastruct/TESTS,v  -->  standard output
revision 1.1
--- LVM2/unit-tests/datastruct/TESTS
+++ -	2010-07-20 15:25:40.769440000 +0000
@@ -0,0 +1 @@
+bitset iteration:$TEST_TOOL ./bitset_t
\ No newline at end of file
/cvs/lvm2/LVM2/unit-tests/datastruct/bitset_t.c,v  -->  standard output
revision 1.1
--- LVM2/unit-tests/datastruct/bitset_t.c
+++ -	2010-07-20 15:25:40.878828000 +0000
@@ -0,0 +1,40 @@
+#include "libdevmapper.h"
+
+#include <assert.h>
+
+enum {
+        NR_BITS = 137
+};
+
+int main(int argc, char **argv)
+{
+        int i, j, last, first;
+        dm_bitset_t bs;
+        struct dm_pool *mem = dm_pool_create("bitset test", 1024);
+
+        assert(mem);
+        bs = dm_bitset_create(mem, NR_BITS);
+
+        for (i = 0; i < NR_BITS; i++)
+                assert(!dm_bit(bs, i));
+
+        for (i = 0, j = 1; i < NR_BITS; i += j, j++)
+                dm_bit_set(bs, i);
+
+        first = 1;
+        for (i = 0, j = 1; i < NR_BITS; i += j, j++) {
+                if (first) {
+                        last = dm_bit_get_first(bs);
+                        first = 0;
+                } else
+                        last = dm_bit_get_next(bs, last);
+
+                assert(last == i);
+        }
+
+        assert(dm_bit_get_next(bs, last) == -1);
+        dm_pool_destroy(mem);
+
+        return 0;
+}
+


