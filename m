From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 6 Mar 2009 16:17:28 -0000
Subject: LVM2 lib/Makefile.in tools/Makefile.in
Message-ID: <20090306161728.18627.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-03-06 16:17:28

Modified files:
	lib            : Makefile.in 
	tools          : Makefile.in 

Log message:
	Rename liblvm to liblvm-internal.
	
	Make preparation for using liblvm for new application library.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/Makefile.in.diff?cvsroot=lvm2&r1=1.88&r2=1.89
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/Makefile.in.diff?cvsroot=lvm2&r1=1.91&r2=1.92

--- LVM2/lib/Makefile.in	2009/02/24 13:03:45	1.88
+++ LVM2/lib/Makefile.in	2009/03/06 16:17:28	1.89
@@ -140,18 +140,19 @@
   CLDFLAGS += -ldevmapper-event
 endif
 
-LIB_STATIC = liblvm.a
+LIB_NAME = liblvm-internal
+LIB_STATIC = $(LIB_NAME).a
 
 $(SUBDIRS): $(LIB_STATIC)
 
-CLEAN_TARGETS += liblvm.cflow
+CLEAN_TARGETS += $(LIB_NAME).cflow
 
 include $(top_srcdir)/make.tmpl
 
-liblvm.cflow: $(SOURCES)
+$(LIB_NAME).cflow: $(SOURCES)
 	set -e; (echo -n "SOURCES += "; \
 		 echo $(SOURCES) | \
 		 sed "s/^/ /;s/ / $(top_srcdir)\/lib\//g;s/$$//"; \
 		 ) > $@
 
-cflow: liblvm.cflow
+cflow: $(LIB_NAME).cflow
--- LVM2/tools/Makefile.in	2009/02/17 11:07:59	1.91
+++ LVM2/tools/Makefile.in	2009/03/06 16:17:28	1.92
@@ -77,7 +77,7 @@
   INSTALL_CMDLIB_TARGETS += install_cmdlib_static
 endif
 
-LVMLIBS = -llvm
+LVMLIBS = -llvm-internal
 
 CLEAN_TARGETS = liblvm2cmd.$(LIB_SUFFIX) liblvm2cmd.a liblvm2cmd-static.a lvm lvm.o \
 		lvm2cmd.o lvm2cmd-static.o lvm2cmdlib.o lvm.static \
@@ -112,21 +112,21 @@
 
 all: device-mapper
 
-lvm: $(OBJECTS) lvm.o $(top_srcdir)/lib/liblvm.a
+lvm: $(OBJECTS) lvm.o $(top_srcdir)/lib/liblvm-internal.a
 	$(CC) -o $@ $(CFLAGS) $(OBJECTS) lvm.o \
 		$(LDFLAGS) $(LVMLIBS) $(LIBS) -rdynamic
 
 LIB_PTHREAD = @LIB_PTHREAD@
-lvm.static: $(OBJECTS) lvm-static.o $(top_srcdir)/lib/liblvm.a  $(interfacedir)/libdevmapper.a
+lvm.static: $(OBJECTS) lvm-static.o $(top_srcdir)/lib/liblvm-internal.a  $(interfacedir)/libdevmapper.a
 	$(CC) -o $@ $(CFLAGS) $(OBJECTS) lvm-static.o -static \
 		-L$(interfacedir) $(LDFLAGS) $(LVMLIBS) $(LIBS) $(LIB_PTHREAD) -rdynamic
 
-liblvm2cmd.a: $(top_srcdir)/lib/liblvm.a $(OBJECTS) lvmcmdlib.o lvm2cmd.o
-	cat $(top_srcdir)/lib/liblvm.a > $@
+liblvm2cmd.a: $(top_srcdir)/lib/liblvm-internal.a $(OBJECTS) lvmcmdlib.o lvm2cmd.o
+	cat $(top_srcdir)/lib/liblvm-internal.a > $@
 	$(AR) rs $@ $(OBJECTS) lvmcmdlib.o lvm2cmd.o
 
-liblvm2cmd-static.a: $(top_srcdir)/lib/liblvm.a $(OBJECTS) lvmcmdlib.o lvm2cmd-static.o
-	cat $(top_srcdir)/lib/liblvm.a > $@
+liblvm2cmd-static.a: $(top_srcdir)/lib/liblvm-internal.a $(OBJECTS) lvmcmdlib.o lvm2cmd-static.o
+	cat $(top_srcdir)/lib/liblvm-internal.a > $@
 	$(AR) rs $@ $(OBJECTS) lvmcmdlib.o lvm2cmd-static.o
 
 liblvm2cmd.$(LIB_SUFFIX): liblvm2cmd.a $(LDDEPS)
@@ -141,7 +141,7 @@
 ifneq ("@CFLOW_CMD@", "")
 CFLOW_FLAGS += --cpp="$(CC) -E"
 .PHONY: lvm.cflow
--include $(top_srcdir)/lib/liblvm.cflow
+-include $(top_srcdir)/lib/liblvm-internal.cflow
 lvm.cflow: $(SOURCES)
 	@CFLOW_CMD@ -o$@ $(CFLOW_FLAGS) $(INCLUDES) $(DEFS) $(SOURCES)
 lvm.rxref: $(SOURCES)


