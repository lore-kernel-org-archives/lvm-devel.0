From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 14 Sep 2009 22:56:27 -0000
Subject: LVM2 liblvm/Makefile.in test/api/Makefile.in
Message-ID: <20090914225627.32090.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-09-14 22:56:27

Modified files:
	liblvm         : Makefile.in 
	test/api       : Makefile.in 

Log message:
	Fix build failure when enabling dmeventd and applib.
	
	This patch fixes a build with options similar to the following:
	./configure --enable-debug --enable-applib --enable-dmeventd --enable-cmdlib

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/Makefile.in.diff?cvsroot=lvm2&r1=1.15&r2=1.16
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/Makefile.in.diff?cvsroot=lvm2&r1=1.8&r2=1.9

--- LVM2/liblvm/Makefile.in	2009/09/03 18:19:07	1.15
+++ LVM2/liblvm/Makefile.in	2009/09/14 22:56:27	1.16
@@ -42,6 +42,10 @@
 
 LIBS += -ldevmapper -llvm-internal
 
+ifeq ("@DMEVENTD@", "yes")
+  LIBS += -ldevmapper-event
+endif
+
 $(VERSIONED_SHLIB): %.$(LIB_SUFFIX).$(LIB_VERSION_APP): %.$(LIB_SUFFIX)
 	rm -f $@
 	$(LN_S) $< $@
--- LVM2/test/api/Makefile.in	2009/09/04 13:49:02	1.8
+++ LVM2/test/api/Makefile.in	2009/09/14 22:56:27	1.9
@@ -33,6 +33,11 @@
 
 LDFLAGS = -L$(top_srcdir)/libdm -L$(top_srcdir)/liblvm
 
+ifeq ("@DMEVENTD@", "yes")
+	LVMLIBS += -ldevmapper-event -lpthread
+	LDFLAGS += -L$(top_srcdir)/daemons/dmeventd
+endif
+
 test_OBJECTS = $(test_SOURCES:.c=.o)
 vgtest_OBJECTS = $(vgtest_SOURCES:.c=.o)
 OBJECTS = $(test_OBJECTS) $(vgtest_OBJECTS)


