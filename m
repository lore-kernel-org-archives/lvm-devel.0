From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 1 Mar 2011 21:30:44 -0000
Subject: LVM2/test/api Makefile.in
Message-ID: <20110301213044.4373.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-03-01 21:30:43

Modified files:
	test/api       : Makefile.in 

Log message:
	Quick fix to compile lvm2api tests when possible
	
	Do not build lvm2api tests when lvm2api lib is not enabled.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/Makefile.in.diff?cvsroot=lvm2&r1=1.20&r2=1.21

--- LVM2/test/api/Makefile.in	2011/01/07 13:07:10	1.20
+++ LVM2/test/api/Makefile.in	2011/03/01 21:30:43	1.21
@@ -20,11 +20,14 @@
 endif
 
 TARGETS = 
+ifeq ("@APPLIB@", "yes")
+TARGETS += test
 test_SOURCES = test.c
 wrapper_SOURCES = test.c
 INCLUDES += -I../../include
 
-UNIT = vgtest.t percent.t
+TARGETS += vgtest.t percent.t
+endif
 
 LVMLIBS = @LVM2APP_LIB@ -ldevmapper
 DEPLIBS = $(top_builddir)/liblvm/liblvm2app.so $(top_builddir)/libdm/libdevmapper.so
@@ -44,9 +47,9 @@
 wrapper_OBJECTS = $(wrapper_SOURCES:.c=.o)
 OBJECTS = $(test_OBJECTS)
 
-all: tests test
+all: tests
 
-tests: $(UNIT)
+tests: $(TARGETS)
 
 test: $(test_OBJECTS) $(DEPLIBS)
 	$(CC) -o test $(test_OBJECTS) $(CFLAGS) $(LDFLAGS) $(LVMLIBS) $(LIBS) $(READLINE_LIBS)


