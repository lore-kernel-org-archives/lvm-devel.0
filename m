From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 8 Mar 2009 18:10:39 -0000
Subject: LVM2/liblvm Makefile.in
Message-ID: <20090308181039.5040.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-03-08 18:10:39

Modified files:
	liblvm         : Makefile.in 

Log message:
	Fix liblvm version symlink.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/Makefile.in.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/liblvm/Makefile.in	2009/03/08 17:29:26	1.3
+++ LVM2/liblvm/Makefile.in	2009/03/08 18:10:39	1.4
@@ -21,6 +21,7 @@
 
 LIB_NAME = liblvm
 LIB_VERSION = $(LIB_VERSION_LVM)
+VERSIONED_SHLIB = $(LIB_NAME).$(LIB_SUFFIX).$(LIB_VERSION_LVM)
 
 LIB_STATIC = $(LIB_NAME).a
 LIB_SHARED = $(LIB_NAME).so
@@ -31,11 +32,9 @@
 
 LIBS += -ldevmapper -llvm-internal
 
-$(VERSIONED_SHLIB): %.$(LIB_SUFFIX).$(LIB_VERSION): $(interface)/%.$(LIB_SUFFIX)
+$(VERSIONED_SHLIB): %.$(LIB_SUFFIX).$(LIB_VERSION): %.$(LIB_SUFFIX)
 	rm -f $@
 	$(LN_S) $< $@
-	rm -f $(LIB_NAME).$(LIB_SUFFIX)
-	$(LN_S) $< $(LIB_NAME).$(LIB_SUFFIX)
 
 liblvm.cflow: $(SOURCES)
 	set -e; (echo -n "SOURCES += "; \


