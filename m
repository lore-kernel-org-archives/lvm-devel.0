From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 17 Dec 2018 05:08:41 -0500
Subject: master - makefiles: dm-tools improve Makefile
Message-ID: <201812171008.wBHA8f8l024843@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0dc7abe013729b3b3560b67fcc37f3cc619f323d
Commit:        0dc7abe013729b3b3560b67fcc37f3cc619f323d
Parent:        b5366b1d8d9edf8a21de4e256ff89774c6b87f16
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Dec 17 02:07:29 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Dec 17 10:55:20 2018 +0100

makefiles: dm-tools improve Makefile

---
 libdm/dm-tools/Makefile.in |   87 ++++++++++++++++++++------------------------
 1 files changed, 39 insertions(+), 48 deletions(-)

diff --git a/libdm/dm-tools/Makefile.in b/libdm/dm-tools/Makefile.in
index 33110dc..15a9d8e 100644
--- a/libdm/dm-tools/Makefile.in
+++ b/libdm/dm-tools/Makefile.in
@@ -1,6 +1,6 @@
 #
 # Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
-# Copyright (C) 2004-2012 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2004-2018 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -16,39 +16,49 @@ srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 
-SOURCES2=\
-	dmsetup.c
+all: device-mapper
 
+SOURCES2 = dmsetup.c
 TARGETS_DM = dmsetup
-
-INSTALL_DMSETUP_TARGETS = install_dmsetup_dynamic
+install_device-mapper: install_dmsetup_dynamic
 
 ifeq ("@STATIC_LINK@", "yes")
   TARGETS_DM += dmsetup.static
-  INSTALL_DMSETUP_TARGETS += install_dmsetup_static
+  install_device-mapper: install_dmsetup_static
+endif
+
+# dmfilemapd support
+ifeq ("@BUILD_DMFILEMAPD@", "yes")
+  SOURCES2 += dmfilemapd.c
+  TARGETS_DM += dmfilemapd
+  install_dmfilemapd: install_dmfilemapd_dynamic
+
+  ifeq ("@STATIC_LINK@", "yes")
+    TARGETS_DM += dmfilemapd.static
+    install_dmfilemapd: install_dmfilemapd_static
+  endif
 endif
 
-CLEAN_TARGETS = $(TARGETS_DM) \
-	dmsetup.static \
-	$(LDDEPS) .exported_symbols_generated
+CLEAN_TARGETS = $(LDDEPS) .exported_symbols_generated \
+	dmfilemapd dmfilemapd.static \
+	dmsetup dmsetup.static
 
 include $(top_builddir)/libdm/make.tmpl
 
 CFLAGS_dmsetup.o += $(UDEV_CFLAGS) $(EXTRA_EXEC_CFLAGS)
+CFLAGS_dmfilemapd.o += $(EXTRA_EXEC_CFLAGS)
+LDFLAGS += -L$(interfacebuilddir)
+DMLIBS = -ldevmapper
 
 dmsetup: dmsetup.o
 	@echo "    [CC] $@"
 	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) \
-	      -o $@ $+ $(LIBS) -L$(top_builddir)/libdm -ldevmapper -lm
+	      -o $@ $+ $(DMLIBS)
 
-dmsetup.static: dmsetup.o $(INTERNAL_LIBS)
+dmsetup.static: dmsetup.o
 	@echo "    [CC] $@"
-	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) -static -L$(interfacebuilddir) \
-	      -o $@ $+ $(M_LIBS) $(PTHREAD_LIBS) $(STATIC_LIBS) $(LIBS)
-
-all: device-mapper
-
-.PHONY: install_dmsetup_dynamic install_dmsetup_static
+	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) -static \
+	      -o $@ $+ $(DMLIBS) $(STATIC_LIBS)
 
 install_dmsetup_dynamic: dmsetup
 	@echo "    [INSTALL] $<"
@@ -60,48 +70,29 @@ install_dmsetup_static: dmsetup.static
 	$(Q) $(INSTALL_PROGRAM) -D $< $(staticdir)/$(<F)
 	$(Q) $(LN_S) -f $(<F) $(staticdir)/dmstats
 
-install_device-mapper: $(INSTALL_DMSETUP_TARGETS)
-
-install: install_device-mapper
 
-# dmfilemapd support
-ifeq ("@BUILD_DMFILEMAPD@", "yes")
-  SOURCES += dmfilemapd.c
-  TARGETS_DM += dmfilemapd
-  .PHONY: install_dmfilemapd install_dmfilemapd_static
-  INSTALL_DMFILEMAPD_TARGETS = install_dmfilemapd_dynamic
-  ifeq ("@STATIC_LINK@", "yes")
-    TARGETS_DM += dmfilemapd.static
-  else
-    TARGETS_DM += dmfilemapd
-  endif
-  CLEAN_TARGETS+= dmfilemapd.static
-  
-  CFLAGS_dmfilemapd.o += $(EXTRA_EXEC_CFLAGS)
-
-  dmfilemapd: $(LIB_SHARED) dmfilemapd.o
-	@echo "    [CC] $<"
+dmfilemapd: $(LIB_SHARED) dmfilemapd.o
+	@echo "    [CC] $@"
 	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) \
-		-o $@ dmfilemapd.o -L$(top_builddir)/libdm -ldevmapper $(LIBS)
+	      -o $@ $+ $(DMLIBS)
 
-  dmfilemapd.static: $(LIB_STATIC) dmfilemapd.o
-	@echo "    [CC] $<"
-	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) $(ELDFLAGS) -static -L$(interfacebuilddir) \
-		-o $@ dmfilemapd.o $(LIBS) $(STATIC_LIBS)
+dmfilemapd.static: $(LIB_STATIC) dmfilemapd.o
+	@echo "    [CC] $@"
+	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) $(ELDFLAGS) -static \
+	      -o $@ $+ $(DMLIBS) $(STATIC_LIBS)
 
-  install_dmfilemapd_dynamic: dmfilemapd
+install_dmfilemapd_dynamic: dmfilemapd
 	@echo "    [INSTALL] $<"
 	$(Q) $(INSTALL_PROGRAM) -D $< $(sbindir)/$(<F)
 
-  install_dmfilemapd_static: dmfilemapd.static
+install_dmfilemapd_static: dmfilemapd.static
 	@echo "    [INSTALL] $<"
 	$(Q) $(INSTALL_PROGRAM) -D $< $(staticdir)/$(<F)
 
-  install_dmfilemapd: $(INSTALL_DMFILEMAPD_TARGETS)
 
-  install_device-mapper: install_dmfilemapd
+.PHONY: install_dmsetup_dynamic install_dmsetup_static
+.PHONY: install_dmfilemapd install_dmfilemapd_static
 
-  install: install_dmfilemapd
-endif
+install: install_device-mapper install_dmfilemapd
 
 device-mapper: $(TARGETS_DM)


