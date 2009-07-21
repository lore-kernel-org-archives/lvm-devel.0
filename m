From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 21 Jul 2009 13:51:06 -0000
Subject: LVM2/test/api Makefile.in
Message-ID: <20090721135106.29782.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-21 13:51:05

Modified files:
	test/api       : Makefile.in 

Log message:
	Fix build environment of test/api: Make it usable for more than one test case.
	
	Author: Thomas Woerner <twoerner@redhat.com>
	Committer: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/Makefile.in.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/test/api/Makefile.in	2009/05/22 14:45:00	1.6
+++ LVM2/test/api/Makefile.in	2009/07/21 13:51:05	1.7
@@ -1,6 +1,5 @@
 #
-# Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
-# Copyright (C) 2004-2008 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2009 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -10,31 +9,36 @@
 #
 # You should have received a copy of the GNU General Public License
 # along with this program; if not, write to the Free Software Foundation,
-# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
 
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 VPATH = @srcdir@
 
-SOURCES = test.c
-INCLUDES += -I${top_srcdir}/lib
-
 ifeq ("@DEBUG@", "yes")
 	DEFS += -DDEBUG
 endif
 
-TARGETS = test
+TARGETS = test vgtest
+test_SOURCES = test.c
+vgtest_SOURCES = vgtest.c
+INCLUDES += -I${top_srcdir}/include
 
 LVMLIBS = @LVM2APP_LIB@ -ldevmapper
+DEPLIBS = $(top_srcdir)/liblvm/liblvm2app.so $(top_srcdir)/libdm/libdevmapper.so
 
 DEFS += -D_REENTRANT
-CFLAGS += -fno-strict-aliasing
 
 include $(top_srcdir)/make.tmpl
 
 LDFLAGS = -L$(top_srcdir)/libdm -L$(top_srcdir)/liblvm
-CLDFLAGS = -L$(top_srcdir)/libdm -L$(top_srcdir)/liblvm
 
-test: $(OBJECTS) $(top_srcdir)/liblvm/liblvm2app.so $(top_srcdir)/libdm/libdevmapper.so
-	$(CC) -o test $(OBJECTS) $(CFLAGS) $(LDFLAGS) $(LVMLIBS) $(LIBS)
+test_OBJECTS = $(test_SOURCES:.c=.o)
+vgtest_OBJECTS = $(vgtest_SOURCES:.c=.o)
+OBJECTS = $(test_OBJECTS) $(vgtest_OBJECTS)
+
+test: $(test_OBJECTS) $(DEPLIBS)
+	$(CC) -o test $(test_OBJECTS) $(CFLAGS) $(LDFLAGS) $(LVMLIBS) $(LIBS)
 
+vgtest: $(vgtest_OBJECTS) $(DEPLIBS)
+	$(CC) -o vgtest $(vgtest_OBJECTS) $(CFLAGS) $(LDFLAGS) $(LVMLIBS) $(LIBS)


