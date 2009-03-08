From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 8 Mar 2009 17:29:27 -0000
Subject: LVM2 liblvm/Makefile.in test/api/Makefile.in
Message-ID: <20090308172927.13070.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-03-08 17:29:27

Modified files:
	liblvm         : Makefile.in 
	test/api       : Makefile.in 

Log message:
	Remove unnecessary linker flags for liblvm.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/Makefile.in.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/Makefile.in.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/liblvm/Makefile.in	2009/03/08 17:06:55	1.2
+++ LVM2/liblvm/Makefile.in	2009/03/08 17:29:26	1.3
@@ -29,7 +29,6 @@
 
 include $(top_srcdir)/make.tmpl
 
-CLDFLAGS += -z now
 LIBS += -ldevmapper -llvm-internal
 
 $(VERSIONED_SHLIB): %.$(LIB_SUFFIX).$(LIB_VERSION): $(interface)/%.$(LIB_SUFFIX)
--- LVM2/test/api/Makefile.in	2009/03/08 17:06:56	1.2
+++ LVM2/test/api/Makefile.in	2009/03/08 17:29:27	1.3
@@ -25,7 +25,7 @@
 
 TARGETS = test
 
-LVMLIBS = -llvm -ldevmapper
+LVMLIBS = -llvm
 
 DEFS += -D_REENTRANT
 CFLAGS += -fno-strict-aliasing


