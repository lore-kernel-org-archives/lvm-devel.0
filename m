From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 8 Mar 2009 17:06:56 -0000
Subject: LVM2 liblvm/Makefile.in test/api/Makefile.in
Message-ID: <20090308170656.7088.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-03-08 17:06:56

Modified files:
	liblvm         : Makefile.in 
	test/api       : Makefile.in 

Log message:
	Add DSO generation for new LVM application library.
	
	Fix test/api/test build.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/Makefile.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/Makefile.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/liblvm/Makefile.in	2009/03/06 16:19:53	1.1
+++ LVM2/liblvm/Makefile.in	2009/03/08 17:06:55	1.2
@@ -19,14 +19,25 @@
 SOURCES =\
 	lvm_base.c
 
-LIB_STATIC = liblvm.a
+LIB_NAME = liblvm
+LIB_VERSION = $(LIB_VERSION_LVM)
 
-$(SUBDIRS): $(LIB_STATIC)
+LIB_STATIC = $(LIB_NAME).a
+LIB_SHARED = $(LIB_NAME).so
 
 CLEAN_TARGETS += liblvm.cflow
 
 include $(top_srcdir)/make.tmpl
 
+CLDFLAGS += -z now
+LIBS += -ldevmapper -llvm-internal
+
+$(VERSIONED_SHLIB): %.$(LIB_SUFFIX).$(LIB_VERSION): $(interface)/%.$(LIB_SUFFIX)
+	rm -f $@
+	$(LN_S) $< $@
+	rm -f $(LIB_NAME).$(LIB_SUFFIX)
+	$(LN_S) $< $(LIB_NAME).$(LIB_SUFFIX)
+
 liblvm.cflow: $(SOURCES)
 	set -e; (echo -n "SOURCES += "; \
 		 echo $(SOURCES) | \
--- LVM2/test/api/Makefile.in	2008/12/07 19:37:07	1.1
+++ LVM2/test/api/Makefile.in	2009/03/08 17:06:56	1.2
@@ -30,10 +30,11 @@
 DEFS += -D_REENTRANT
 CFLAGS += -fno-strict-aliasing
 
-LDFLAGS += -L$(top_srcdir)/api/lib
-
 include $(top_srcdir)/make.tmpl
 
-test: $(OBJECTS) $(top_srcdir)/lib/liblvm.a $(top_srcdir)/libdm/libdevmapper.so
+LDFLAGS = -L$(top_srcdir)/libdm -L$(top_srcdir)/liblvm
+CLDFLAGS = -L$(top_srcdir)/libdm -L$(top_srcdir)/liblvm
+
+test: $(OBJECTS) $(top_srcdir)/liblvm/liblvm.a $(top_srcdir)/libdm/libdevmapper.so
 	$(CC) -o test $(OBJECTS) $(CFLAGS) $(LDFLAGS) $(LVMLIBS) $(LIBS)
 


