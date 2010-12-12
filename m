From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 12 Dec 2010 20:49:39 -0000
Subject: LVM2/test/api Makefile.in
Message-ID: <20101212204939.17102.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-12-12 20:49:38

Modified files:
	test/api       : Makefile.in 

Log message:
	Do not build vgtest (superseded by vgtest.t). Fix the build line for .t files.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/Makefile.in.diff?cvsroot=lvm2&r1=1.15&r2=1.16

--- LVM2/test/api/Makefile.in	2010/12/12 20:36:38	1.15
+++ LVM2/test/api/Makefile.in	2010/12/12 20:49:38	1.16
@@ -19,9 +19,8 @@
 	DEFS += -DDEBUG
 endif
 
-TARGETS = vgtest
+TARGETS = 
 test_SOURCES = test.c
-vgtest_SOURCES = vgtest.c
 wrapper_SOURCES = test.c
 INCLUDES += -I../../include
 
@@ -42,9 +41,8 @@
 endif
 
 test_OBJECTS = $(test_SOURCES:.c=.o)
-vgtest_OBJECTS = $(vgtest_SOURCES:.c=.o)
 wrapper_OBJECTS = $(wrapper_SOURCES:.c=.o)
-OBJECTS = $(test_OBJECTS) $(vgtest_OBJECTS)
+OBJECTS = $(test_OBJECTS)
 
 all: $(UNIT) test
 
@@ -52,7 +50,7 @@
 	$(CC) -o test $(test_OBJECTS) $(CFLAGS) $(LDFLAGS) $(LVMLIBS) $(LIBS) $(READLINE_LIBS)
 
 %.o: $(srcdir)/%.c
-	$(CC) -o $@ $(CFLAGS) $(LDFLAGS) $(LVMLIBS) $(LIBS) $(READLINE_LIBS)
+	$(CC) -o $@ $(CFLAGS) $(INCLUDES)
 
 %.t: %.o $(DEPLIBS)
 	$(CC) -o $@ $(<) $(CFLAGS) $(LDFLAGS) $(LVMLIBS) $(LIBS)


