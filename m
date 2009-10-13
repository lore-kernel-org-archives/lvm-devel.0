From: agk@sourceware.org <agk@sourceware.org>
Date: 13 Oct 2009 02:35:27 -0000
Subject: LVM2 ./WHATS_NEW daemons/dmeventd/Makefile.in
Message-ID: <20091013023527.1495.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-10-13 02:35:26

Modified files:
	.              : WHATS_NEW 
	daemons/dmeventd: Makefile.in 

Log message:
	Attempt to build dmeventd.static.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1294&r2=1.1295
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/Makefile.in.diff?cvsroot=lvm2&r1=1.28&r2=1.29

--- LVM2/WHATS_NEW	2009/10/12 16:59:20	1.1294
+++ LVM2/WHATS_NEW	2009/10/13 02:35:26	1.1295
@@ -1,5 +1,6 @@
 Version 2.02.54 -
 =====================================
+  Add dmeventd.static to the build.
   Disable realtime support code by default.
   Make clvmd return 0 on success rather than 1.
   Add --pvmetadatacopies for pvcreate, vgcreate, vgextend, vgconvert.
--- LVM2/daemons/dmeventd/Makefile.in	2009/10/13 01:31:10	1.28
+++ LVM2/daemons/dmeventd/Makefile.in	2009/10/13 02:35:26	1.29
@@ -17,10 +17,22 @@
 VPATH = @srcdir@
 
 SOURCES = libdevmapper-event.c
+TARGETS = dmeventd
+
+.PHONY: install_lib_dynamic install_lib_static install_include \
+	install_pkgconfig install_dmeventd_dynamic install_dmeventd_static \
+	install_lib install_dmeventd
+
+INSTALL_DMEVENTD_TARGETS = install_dmeventd_dynamic
+INSTALL_LIB_TARGETS = install_lib_dynamic
 
 ifeq ("@STATIC_LINK@", "yes")
-LIB_STATIC = libdevmapper-event.a
+  LIB_STATIC = libdevmapper-event.a
+  TARGETS += dmeventd.static
+  INSTALL_DMEVENTD_TARGETS += install_dmeventd_static
+  INSTALL_LIB_TARGETS += install_lib_static
 endif
+
 LIB_VERSION = $(LIB_VERSION_DM)
 
 ifeq ("@LIB_SUFFIX@","dylib")
@@ -30,8 +42,7 @@
   VERSIONED_SHLIB = $(LIB_SHARED).$(LIB_VERSION)
 endif
 
-TARGETS = dmeventd
-CLEAN_TARGETS = dmeventd.o
+CLEAN_TARGETS = dmeventd.o dmeventd.static
 
 ifneq ($(MAKECMDGOALS),device-mapper)
   SUBDIRS+=plugins
@@ -39,57 +50,60 @@
 
 include ../../make.tmpl
 
-all: dmeventd
-device-mapper: dmeventd $(LIB_STATIC)
+all: device-mapper
+device-mapper: $(TARGETS)
 
-LIBS += -ldl -ldevmapper -lpthread
+LIBS += -ldl
+LVMLIBS += -ldevmapper-event -lpthread -ldevmapper
+
+$(VERSIONED_SHLIB): $(LIB_SHARED)
+	$(RM) -f $@
+	$(LN_S) $(LIB_SHARED) $@
 
 dmeventd: $(LIB_SHARED) $(VERSIONED_SHLIB) dmeventd.o
 	$(CC) $(CFLAGS) $(LDFLAGS) -L. -o $@ dmeventd.o \
-	-ldevmapper-event $(LIBS) -rdynamic
+	$(LVMLIBS) $(LIBS) -rdynamic
 
-.PHONY: install_dynamic install_static install_include \
-	install_pkgconfig install_dmeventd
-
-INSTALL_TYPE = install_dynamic
-
-ifeq ("@STATIC_LINK@", "yes")
-  INSTALL_TYPE += install_static
-endif
+dmeventd.static: $(LIB_STATIC) dmeventd.o $(interfacedir)/libdevmapper.a
+	$(CC) $(CFLAGS) $(LDFLAGS) -static -L. -L$(interfacedir) -o $@ \
+	dmeventd.o $(LVMLIBS) $(LIBS) -rdynamic
 
 ifeq ("@PKGCONFIG@", "yes")
-  INSTALL_TYPE += install_pkgconfig
+  INSTALL_LIB_TARGETS += install_pkgconfig
 endif
 
-install: $(INSTALL_TYPE) install_include install_dmeventd
-
-install_device-mapper: $(INSTALL_TYPE) install_include install_dmeventd
-
 install_include:
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 444 $(srcdir)/libdevmapper-event.h \
 		$(includedir)/libdevmapper-event.h
 
-install_dynamic: libdevmapper-event.$(LIB_SUFFIX)
+install_pkgconfig:
+	$(INSTALL) -D $(OWNER) $(GROUP) -m 444 libdevmapper-event.pc \
+		$(usrlibdir)/pkgconfig/devmapper-event.pc
+
+install_lib_dynamic: libdevmapper-event.$(LIB_SUFFIX)
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
 		$(libdir)/libdevmapper-event.$(LIB_SUFFIX).$(LIB_VERSION)
 	$(LN_S) -f libdevmapper-event.$(LIB_SUFFIX).$(LIB_VERSION) \
 		$(libdir)/libdevmapper-event.$(LIB_SUFFIX)
 
-install_dmeventd: dmeventd
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< $(sbindir)/$<
-
-install_pkgconfig:
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 444 libdevmapper-event.pc \
-		$(usrlibdir)/pkgconfig/devmapper-event.pc
-
-install_static: libdevmapper-event.a
+install_lib_static: libdevmapper-event.a
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
 		$(libdir)/libdevmapper-event.a.$(LIB_VERSION)
 	$(LN_S) -f libdevmapper-event.a.$(LIB_VERSION) $(libdir)/libdevmapper-event.a
 
-$(VERSIONED_SHLIB): $(LIB_SHARED)
-	$(RM) -f $@
-	$(LN_S) $(LIB_SHARED) $@
+install_lib: $(INSTALL_LIB_TARGETS)
+
+install_dmeventd_dynamic: dmeventd
+	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< $(sbindir)/$<
+
+install_dmeventd_static: dmeventd.static
+	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< $(sbindir)/$<
+
+install_dmeventd: $(INSTALL_DMEVENTD_TARGETS)
+
+install: install_include install_lib install_dmeventd
+
+install_device-mapper: install
 
 .PHONY: distclean_lib distclean
 


