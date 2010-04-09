From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri,  9 Apr 2010 17:42:54 +0200
Subject: [PATCH 2/3] INSTALL rules updates
In-Reply-To: <cover.1270827575.git.zkabelac@redhat.com>
References: <cover.1270827575.git.zkabelac@redhat.com>
Message-ID: <654f5a44f4226b38d17027a7b432335fe6bd948d.1270827575.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Patch tries to address multiple issues.
It is inspired by Debian's extra patch but makes things more correct.

- removes OWNER & GROUP make vars they are parts of INSTALL command.
- adds INSTALL_PROGRAM for executable, uses $(INSTALL)
- adds INSTALL_DATA for non-executable data, uses ($INSTALL)
- adds INSTALL_WDATA for writable non-executable data, uses ($INSTALL)
- adds configure option --enable-write_install - to support
  installatin of writable files used by distribution
- replaces usage of ifeq @LIB_SUFFIX@ with $(LIB_SUFFIX)
- installs .a files from static builds without executable flag
- installs .a files to $(usrlibdir) instead of $(libdir)
- installs all static binaries to $(staticdir)
- create .so links for devel package in $(usrlibdir) instead of
  $(libdir)
- makes .so and .so.LIB_VERSION files within builddir
- removes VERSIONED_SHLIB and created versioned LIB_SHARED automagicaly
- install LIB_SHARED via install_lib_shared target
- install plugins via install_lib_shared_plugin target
- prints whole 'install' command during installation instead of less
  informative "Installing  $(something) $(somewhere)"
- install multiple man pages with one INSTALL command
- use DISTCLEAN_TARGETS instead of creating multiple distclean targets

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 configure.in                                  |   16 ++++---
 daemons/clvmd/Makefile.in                     |    3 +-
 daemons/cmirrord/Makefile.in                  |    7 +--
 daemons/dmeventd/Makefile.in                  |   47 ++++++-----------------
 daemons/dmeventd/plugins/lvm2/Makefile.in     |   11 +----
 daemons/dmeventd/plugins/mirror/Makefile.in   |   11 +----
 daemons/dmeventd/plugins/snapshot/Makefile.in |   11 +----
 doc/Makefile.in                               |    7 +--
 lib/Makefile.in                               |    2 +-
 lib/format1/Makefile.in                       |   10 +---
 lib/format_pool/Makefile.in                   |   12 +----
 lib/locking/Makefile.in                       |   11 +----
 lib/mirror/Makefile.in                        |   10 +---
 lib/snapshot/Makefile.in                      |   11 +----
 libdm/Makefile.in                             |   51 +++++++-----------------
 liblvm/Makefile.in                            |   44 +++++----------------
 make.tmpl.in                                  |   47 +++++++++++++++++------
 man/Makefile.in                               |   51 +++++++++---------------
 po/Makefile.in                                |    4 +-
 scripts/Makefile.in                           |   20 +++++----
 test/Makefile.in                              |    2 +-
 tools/Makefile.in                             |   47 +++++++++++------------
 22 files changed, 166 insertions(+), 269 deletions(-)

diff --git a/configure.in b/configure.in
index ede1a74..ed9e631 100644
--- a/configure.in
+++ b/configure.in
@@ -144,28 +144,25 @@ AC_PREFIX_DEFAULT(/usr)
 ################################################################################
 dnl -- Setup the ownership of the files
 AC_MSG_CHECKING(file owner)
-OWNER=""
-
 AC_ARG_WITH(user,
   [  --with-user=USER        Set the owner of installed files [[USER=]] ],
   [ OWNER="$withval" ])
 AC_MSG_RESULT($OWNER)
 
 if test x$OWNER != x; then
-	OWNER="-o $OWNER"
+	INSTALL="$INSTALL -o $OWNER"
 fi
 
 ################################################################################
 dnl -- Setup the group ownership of the files
 AC_MSG_CHECKING(group owner)
-GROUP=""
 AC_ARG_WITH(group,
   [  --with-group=GROUP      Set the group owner of installed files [[GROUP=]] ],
   [ GROUP="$withval" ])
 AC_MSG_RESULT($GROUP)
 
 if test x$GROUP != x; then
-	GROUP="-g $GROUP"
+	INSTALL="$INSTALL -g $GROUP"
 fi
 
 ################################################################################
@@ -733,6 +730,12 @@ AC_ARG_ENABLE(pkgconfig,   [  --enable-pkgconfig      Install pkgconfig support]
   PKGCONFIG=$enableval, PKGCONFIG=no)
 
 ################################################################################
+dnl -- Enable installation of writable files by user
+AC_ARG_ENABLE(write_install, AC_HELP_STRING([--enable-write_install],
+	[Install user writable files]), 
+	[WRITE_INSTALL=$enableval], [WRITE_INSTALL=no])
+
+################################################################################
 dnl -- Enable fsadm
 AC_MSG_CHECKING(whether to install fsadm)
 AC_ARG_ENABLE(fsadm, [AC_HELP_STRING([--disable-fsadm], [Disable fsadm])],
@@ -1080,7 +1083,6 @@ AC_SUBST(DM_IOCTLS)
 AC_SUBST(DM_LIB_VERSION)
 AC_SUBST(DM_LIB_PATCHLEVEL)
 AC_SUBST(FSADM)
-AC_SUBST(GROUP)
 AC_SUBST(GULM_CFLAGS)
 AC_SUBST(GULM_LIBS)
 AC_SUBST(HAVE_LIBDL)
@@ -1103,7 +1105,6 @@ AC_SUBST(LVM_RELEASE)
 AC_SUBST(LVM_RELEASE_DATE)
 AC_SUBST(MIRRORS)
 AC_SUBST(MSGFMT)
-AC_SUBST(OWNER)
 AC_SUBST(PKGCONFIG)
 AC_SUBST(POOL)
 AC_SUBST(PTHREAD_LIBS)
@@ -1121,6 +1122,7 @@ AC_SUBST(STATIC_LINK)
 AC_SUBST(UDEV_LIBS)
 AC_SUBST(UDEV_RULES)
 AC_SUBST(UDEV_SYNC)
+AC_SUBST(WRITE_INSTALL)
 AC_SUBST(interface)
 AC_SUBST(kerneldir)
 AC_SUBST(missingkernel)
diff --git a/daemons/clvmd/Makefile.in b/daemons/clvmd/Makefile.in
index 773c368..ee19e6c 100644
--- a/daemons/clvmd/Makefile.in
+++ b/daemons/clvmd/Makefile.in
@@ -110,8 +110,7 @@ clvmd: $(OBJECTS) $(top_builddir)/lib/liblvm-internal.a
 .PHONY: install_clvmd
 
 install_clvmd: $(TARGETS)
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) clvmd \
-		$(usrsbindir)/clvmd
+	$(INSTALL_PROGRAM) -D clvmd $(usrsbindir)/clvmd
 
 install: $(INSTALL_TARGETS)
 
diff --git a/daemons/cmirrord/Makefile.in b/daemons/cmirrord/Makefile.in
index 583c454..0efc8d4 100644
--- a/daemons/cmirrord/Makefile.in
+++ b/daemons/cmirrord/Makefile.in
@@ -1,5 +1,5 @@
 #
-# Copyright (C) 2009 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2009-2010 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -31,9 +31,8 @@ LMLIBS += $(CPG_LIBS) $(SACKPT_LIBS)
 CFLAGS += $(CPG_CFLAGS) $(SACKPT_CFLAGS)
 
 cmirrord: $(OBJECTS) $(top_builddir)/lib/liblvm-internal.a
-	$(CC) $(CFLAGS) $(LDFLAGS) -o cmirrord $(OBJECTS) \
+	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJECTS) \
 		$(LVMLIBS) $(LMLIBS) $(LIBS)
 
 install: $(TARGETS)
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) cmirrord \
-		$(usrsbindir)/cmirrord
+	$(INSTALL_PROGRAM) -D cmirrord $(usrsbindir)/cmirrord
diff --git a/daemons/dmeventd/Makefile.in b/daemons/dmeventd/Makefile.in
index e0a6349..fb4f8f5 100644
--- a/daemons/dmeventd/Makefile.in
+++ b/daemons/dmeventd/Makefile.in
@@ -36,13 +36,7 @@ ifeq ("@STATIC_LINK@", "yes")
 endif
 
 LIB_VERSION = $(LIB_VERSION_DM)
-
-ifeq ("@LIB_SUFFIX@","dylib")
-  LIB_SHARED = $(LIB_NAME).dylib
-else
-  LIB_SHARED = $(LIB_NAME).so
-  VERSIONED_SHLIB = $(LIB_SHARED).$(LIB_VERSION)
-endif
+LIB_SHARED = $(LIB_NAME).$(LIB_SUFFIX)
 
 CLEAN_TARGETS = dmeventd.static $(LIB_NAME).a
 
@@ -61,11 +55,7 @@ device-mapper: $(TARGETS)
 
 LVMLIBS += -ldevmapper-event -ldevmapper $(PTHREAD_LIBS)
 
-$(VERSIONED_SHLIB): $(LIB_SHARED)
-	$(RM) -f $@
-	$(LN_S) $(LIB_SHARED) $@
-
-dmeventd: $(LIB_SHARED) $(VERSIONED_SHLIB) dmeventd.o
+dmeventd: $(LIB_SHARED) dmeventd.o
 	$(CC) $(CFLAGS) $(LDFLAGS) -L. -o $@ dmeventd.o \
 	$(DL_LIBS) $(LVMLIBS) $(LIBS) -rdynamic
 
@@ -86,32 +76,24 @@ CFLOW_SOURCES = $(addprefix $(srcdir)/, $(SOURCES))
 -include $(top_builddir)/daemons/dmeventd/plugins/mirror/$(LIB_NAME)-lvm2mirror.cflow
 endif
 
-install_include:
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 444 $(srcdir)/libdevmapper-event.h \
-		$(includedir)/libdevmapper-event.h
+install_include: $(srcdir)/libdevmapper-event.h
+	$(INSTALL_DATA) -D $< $(includedir)/$(<F)
 
-install_pkgconfig:
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 444 libdevmapper-event.pc \
-		$(usrlibdir)/pkgconfig/devmapper-event.pc
+install_pkgconfig: libdevmapper-event.pc
+	$(INSTALL_DATA) -D $< $(usrlibdir)/pkgconfig/devmapper-event.pc
 
-install_lib_dynamic: libdevmapper-event.$(LIB_SUFFIX)
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
-		$(libdir)/libdevmapper-event.$(LIB_SUFFIX).$(LIB_VERSION)
-	$(LN_S) -f libdevmapper-event.$(LIB_SUFFIX).$(LIB_VERSION) \
-		$(libdir)/libdevmapper-event.$(LIB_SUFFIX)
+install_lib_dynamic: install_lib_shared
 
-install_lib_static: libdevmapper-event.a
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
-		$(libdir)/libdevmapper-event.a.$(LIB_VERSION)
-	$(LN_S) -f libdevmapper-event.a.$(LIB_VERSION) $(libdir)/libdevmapper-event.a
+install_lib_static: $(LIB_STATIC)
+	$(INSTALL_DATA) -D $< $(usrlibdir)/$(<F)
 
 install_lib: $(INSTALL_LIB_TARGETS)
 
 install_dmeventd_dynamic: dmeventd
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< $(sbindir)/$<
+	$(INSTALL_PROGRAM) -D $< $(sbindir)/$(<F)
 
 install_dmeventd_static: dmeventd.static
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< $(sbindir)/$<
+	$(INSTALL_PROGRAM) -D $< $(staticdir)/$(<F)
 
 install_dmeventd: $(INSTALL_DMEVENTD_TARGETS)
 
@@ -119,9 +101,4 @@ install: install_include install_lib install_dmeventd
 
 install_device-mapper: install_include install_lib install_dmeventd
 
-.PHONY: distclean_lib
-
-distclean_lib: 
-	$(RM) libdevmapper-event.pc
-
-distclean: distclean_lib
+DISTCLEAN_TARGETS += libdevmapper-event.pc
diff --git a/daemons/dmeventd/plugins/lvm2/Makefile.in b/daemons/dmeventd/plugins/lvm2/Makefile.in
index f44a562..7535868 100644
--- a/daemons/dmeventd/plugins/lvm2/Makefile.in
+++ b/daemons/dmeventd/plugins/lvm2/Makefile.in
@@ -19,20 +19,13 @@ CLDFLAGS += -L$(top_builddir)/tools
 
 SOURCES = dmeventd_lvm.c
 
-ifeq ("@LIB_SUFFIX@","dylib")
-  LIB_SHARED = libdevmapper-event-lvm2.dylib
-else
-  LIB_SHARED = libdevmapper-event-lvm2.so
-endif
+LIB_SHARED = libdevmapper-event-lvm2.$(LIB_SUFFIX)
 LIB_VERSION = $(LIB_VERSION_LVM)
 
 include $(top_builddir)/make.tmpl
 
 LIBS += @LVM2CMD_LIB@ -ldevmapper $(PTHREAD_LIBS)
 
-install_lvm2: libdevmapper-event-lvm2.$(LIB_SUFFIX)
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
-		$(libdir)/$<.$(LIB_VERSION)
-	$(LN_S) -f $<.$(LIB_VERSION) $(libdir)/$<
+install_lvm2: install_lib_shared
 
 install: install_lvm2
diff --git a/daemons/dmeventd/plugins/mirror/Makefile.in b/daemons/dmeventd/plugins/mirror/Makefile.in
index 3dfc3a2..146361f 100644
--- a/daemons/dmeventd/plugins/mirror/Makefile.in
+++ b/daemons/dmeventd/plugins/mirror/Makefile.in
@@ -22,12 +22,7 @@ CLDFLAGS += -L$(top_builddir)/tools -L$(top_builddir)/daemons/dmeventd/plugins/l
 SOURCES = dmeventd_mirror.c
 
 LIB_NAME = libdevmapper-event-lvm2mirror
-ifeq ("@LIB_SUFFIX@","dylib")
-  LIB_SHARED = $(LIB_NAME).dylib
-else
-  LIB_SHARED = $(LIB_NAME).so
-endif
-
+LIB_SHARED = $(LIB_NAME).$(LIB_SUFFIX)
 LIB_VERSION = $(LIB_VERSION_LVM)
 
 CFLOW_LIST = $(SOURCES)
@@ -37,8 +32,6 @@ include $(top_builddir)/make.tmpl
 
 LIBS += @LVM2CMD_LIB@ -ldevmapper-event-lvm2 -ldevmapper $(PTHREAD_LIBS)
 
-install_lvm2: $(LIB_NAME).$(LIB_SUFFIX)
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
-		$(libdir)/$<
+install_lvm2: install_lib_shared_plugin
 
 install: install_lvm2
diff --git a/daemons/dmeventd/plugins/snapshot/Makefile.in b/daemons/dmeventd/plugins/snapshot/Makefile.in
index 0f202b3..f36f916 100644
--- a/daemons/dmeventd/plugins/snapshot/Makefile.in
+++ b/daemons/dmeventd/plugins/snapshot/Makefile.in
@@ -21,20 +21,13 @@ CLDFLAGS += -L$(top_builddir)/tools -L$(top_builddir)/daemons/dmeventd/plugins/l
 
 SOURCES = dmeventd_snapshot.c
 
-ifeq ("@LIB_SUFFIX@","dylib")
-  LIB_SHARED = libdevmapper-event-lvm2snapshot.dylib
-else
-  LIB_SHARED = libdevmapper-event-lvm2snapshot.so
-endif
-
+LIB_SHARED = libdevmapper-event-lvm2snapshot.$(LIB_SUFFIX)
 LIB_VERSION = $(LIB_VERSION_LVM)
 
 include $(top_builddir)/make.tmpl
 
 LIBS += @LVM2CMD_LIB@ -ldevmapper-event-lvm2 -ldevmapper $(PTHREAD_LIBS)
 
-install_lvm2: libdevmapper-event-lvm2snapshot.$(LIB_SUFFIX)
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
-		$(libdir)/$<
+install_lvm2: install_lib_shared_plugin
 
 install: install_lvm2
diff --git a/doc/Makefile.in b/doc/Makefile.in
index 61b32e9..742cac0 100644
--- a/doc/Makefile.in
+++ b/doc/Makefile.in
@@ -1,5 +1,5 @@
 #
-# Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -22,9 +22,8 @@ include $(top_builddir)/make.tmpl
 
 install_lvm2: $(CONFSRC)
 	@if [ ! -e $(confdir)/$(CONFDEST) ]; then \
-		echo "Installing $(CONFSRC) as $(confdir)/$(CONFDEST)"; \
-		@INSTALL@ -D $(OWNER) $(GROUP) -m 644 $< \
-			$(confdir)/$(CONFDEST); \
+		echo "$(INSTALL_WDATA) -D $< $(confdir)/$(CONFDEST)"; \
+		$(INSTALL_WDATA) -D $< $(confdir)/$(CONFDEST); \
 	fi
 
 install: install_lvm2
diff --git a/lib/Makefile.in b/lib/Makefile.in
index 9662120..3498141 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -1,6 +1,6 @@
 #
 # Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
-# Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
diff --git a/lib/format1/Makefile.in b/lib/format1/Makefile.in
index 327a1c2..f0f04d2 100644
--- a/lib/format1/Makefile.in
+++ b/lib/format1/Makefile.in
@@ -1,6 +1,6 @@
 #
 # Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.
-# Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -25,13 +25,9 @@ SOURCES =\
 	lvm1-label.c \
 	vg_number.c
 
-LIB_SHARED = liblvm2format1.so
+LIB_SHARED = liblvm2format1.$(LIB_SUFFIX)
 LIB_VERSION = $(LIB_VERSION_LVM)
 
 include $(top_builddir)/make.tmpl
 
-install: liblvm2format1.so
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
-		$(libdir)/liblvm2format1.so.$(LIB_VERSION)
-	$(LN_S) -f liblvm2format1.so.$(LIB_VERSION) $(libdir)/liblvm2format1.so
-
+install: install_lib_shared_plugin
diff --git a/lib/format_pool/Makefile.in b/lib/format_pool/Makefile.in
index d9cedf0..0671ee8 100644
--- a/lib/format_pool/Makefile.in
+++ b/lib/format_pool/Makefile.in
@@ -1,6 +1,6 @@
 #
 # Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved.
-# Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -22,15 +22,9 @@ SOURCES =\
 	import_export.c \
 	pool_label.c
 
-LIB_SHARED = liblvm2formatpool.so
+LIB_SHARED = liblvm2formatpool.$(LIB_SUFFIX)
 LIB_VERSION = $(LIB_VERSION_LVM)
 
 include $(top_builddir)/make.tmpl
 
-install: liblvm2formatpool.so
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
-		$(libdir)/liblvm2formatpool.so.$(LIB_VERSION)
-	$(LN_S) -f liblvm2formatpool.so.$(LIB_VERSION) \
-		$(libdir)/liblvm2formatpool.so
-
-
+install: install_lib_shared_plugin
diff --git a/lib/locking/Makefile.in b/lib/locking/Makefile.in
index 99cc206..fee0382 100644
--- a/lib/locking/Makefile.in
+++ b/lib/locking/Makefile.in
@@ -1,6 +1,6 @@
 #
 # Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved.
-# Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -18,14 +18,9 @@ top_builddir = @top_builddir@
 
 SOURCES = cluster_locking.c
 
-LIB_SHARED = liblvm2clusterlock.so
+LIB_SHARED = liblvm2clusterlock.$(LIB_SUFFIX)
 LIB_VERSION = $(LIB_VERSION_LVM)
 
 include $(top_builddir)/make.tmpl
 
-install install_cluster: liblvm2clusterlock.so
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
-		$(libdir)/liblvm2clusterlock.so.$(LIB_VERSION)
-	$(LN_S) -f liblvm2clusterlock.so.$(LIB_VERSION) \
-		$(libdir)/liblvm2clusterlock.so
-
+install install_cluster: install_lib_shared_plugin
diff --git a/lib/mirror/Makefile.in b/lib/mirror/Makefile.in
index 233fa96..2769d44 100644
--- a/lib/mirror/Makefile.in
+++ b/lib/mirror/Makefile.in
@@ -1,6 +1,6 @@
 #
 # Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved.
-# Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -18,13 +18,9 @@ top_builddir = @top_builddir@
 
 SOURCES = mirrored.c
 
-LIB_SHARED = liblvm2mirror.so
+LIB_SHARED = liblvm2mirror.$(LIB_SUFFIX)
 LIB_VERSION = $(LIB_VERSION_LVM)
 
 include $(top_builddir)/make.tmpl
 
-install: liblvm2mirror.so
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
-		$(libdir)/liblvm2mirror.so.$(LIB_VERSION)
-	$(LN_S) -f liblvm2mirror.so.$(LIB_VERSION) $(libdir)/liblvm2mirror.so
-
+install: install_lib_shared_plugin
diff --git a/lib/snapshot/Makefile.in b/lib/snapshot/Makefile.in
index e2c2b10..7f8a544 100644
--- a/lib/snapshot/Makefile.in
+++ b/lib/snapshot/Makefile.in
@@ -1,6 +1,6 @@
 #
 # Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.
-# Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -18,14 +18,9 @@ top_builddir = @top_builddir@
 
 SOURCES = snapshot.c
 
-LIB_SHARED = liblvm2snapshot.so
+LIB_SHARED = liblvm2snapshot.$(LIB_SUFFIX)
 LIB_VERSION = $(LIB_VERSION_LVM)
 
 include $(top_builddir)/make.tmpl
 
-install: liblvm2snapshot.so
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
-		$(libdir)/liblvm2snapshot.so.$(LIB_VERSION)
-	$(LN_S) -f liblvm2snapshot.so.$(LIB_VERSION) \
-		$(libdir)/liblvm2snapshot.so
-
+install: install_lib_shared_plugin
diff --git a/libdm/Makefile.in b/libdm/Makefile.in
index 1e9284a..ba62984 100644
--- a/libdm/Makefile.in
+++ b/libdm/Makefile.in
@@ -1,6 +1,6 @@
 #
 # Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
-# Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
 #
 # This file is part of the device-mapper userspace tools.
 #
@@ -38,13 +38,9 @@ ifeq ("@STATIC_LINK@", "yes")
 LIB_STATIC = $(interface)/libdevmapper.a
 endif
 
-ifeq ("@LIB_SUFFIX@","dylib")
-  LIB_SHARED = $(interface)/libdevmapper.dylib
-else
-  LIB_SHARED = $(interface)/libdevmapper.so
-endif
-VERSIONED_SHLIB = libdevmapper.$(LIB_SUFFIX).$(LIB_VERSION_DM)
+LIB_SHARED = $(interface)/libdevmapper.$(LIB_SUFFIX)
 LIB_VERSION = $(LIB_VERSION_DM)
+TARGETS += libdevmapper.$(LIB_SUFFIX) libdevmapper.$(LIB_SUFFIX).$(LIB_VERSION)
 
 CFLOW_LIST = $(SOURCES)
 CFLOW_LIST_TARGET = libdevmapper.cflow
@@ -58,6 +54,9 @@ LIBS += $(SELINUX_LIBS) $(UDEV_LIBS)
 
 device-mapper: all
 
+libdevmapper.$(LIB_SUFFIX) libdevmapper.$(LIB_SUFFIX).$(LIB_VERSION): $(LIB_SHARED)
+	$(LN_S) -f $< $@
+
 .PHONY: install_dynamic install_static install_include \
 	install_ioctl install_ioctl_static \
 	install_pkgconfig
@@ -76,40 +75,20 @@ install: $(INSTALL_TYPE) install_include
 
 install_device-mapper: install
 
-install_include:
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 444 $(srcdir)/libdevmapper.h \
-		$(includedir)/libdevmapper.h
+install_include: $(srcdir)/libdevmapper.h
+	$(INSTALL_DATA) -D $< $(includedir)/$(<F)
 
 install_dynamic: install_ at interface@
-	$(LN_S) -f libdevmapper.$(LIB_SUFFIX).$(LIB_VERSION_DM) \
-		$(libdir)/libdevmapper.$(LIB_SUFFIX)
 
 install_static: install_@interface@_static
-	$(LN_S) -f libdevmapper.a.$(LIB_VERSION_DM) $(libdir)/libdevmapper.a
-
-install_ioctl: ioctl/libdevmapper.$(LIB_SUFFIX)
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
-		$(libdir)/libdevmapper.$(LIB_SUFFIX).$(LIB_VERSION_DM)
-
-install_pkgconfig:
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 444 libdevmapper.pc \
-		$(usrlibdir)/pkgconfig/devmapper.pc
-
-install_ioctl_static: ioctl/libdevmapper.a
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
-		$(libdir)/libdevmapper.a.$(LIB_VERSION_DM)
-
-$(VERSIONED_SHLIB): %.$(LIB_SUFFIX).$(LIB_VERSION_DM): $(interface)/%.$(LIB_SUFFIX)
-	rm -f $@
-	$(LN_S) $< $@
-	rm -f libdevmapper.$(LIB_SUFFIX)
-	$(LN_S) $< libdevmapper.$(LIB_SUFFIX)
 
-CLEAN_TARGETS += libdevmapper.$(LIB_SUFFIX) ioctl/libdevmapper.a
+install_ioctl: install_lib_shared
 
-.PHONY: distclean_lib
+install_pkgconfig: libdevmapper.pc
+	$(INSTALL_DATA) -D $< $(usrlibdir)/pkgconfig/devmapper.pc
 
-distclean_lib:
-	$(RM) libdevmapper.pc
+install_ioctl_static: $(LIB_STATIC)
+	$(INSTALL_DATA) -D $< $(usrlibdir)/$(<F)
 
-distclean: distclean_lib
+CLEAN_TARGETS += ioctl/libdevmapper.a
+DISTCLEAN_TARGETS += libdevmapper.pc
diff --git a/liblvm/Makefile.in b/liblvm/Makefile.in
index 165ce46..6690429 100644
--- a/liblvm/Makefile.in
+++ b/liblvm/Makefile.in
@@ -1,6 +1,6 @@
 #
 # Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
-# Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -25,19 +25,14 @@ SOURCES =\
 
 LIB_NAME = liblvm2app
 LIB_VERSION = $(LIB_VERSION_APP)
-VERSIONED_SHLIB = $(LIB_NAME).$(LIB_SUFFIX).$(LIB_VERSION_APP)
 
 ifeq ("@STATIC_LINK@", "yes")
   LIB_STATIC = $(LIB_NAME).a
 endif
 
-ifeq ("@LIB_SUFFIX@","dylib")
-  LIB_SHARED = $(LIB_NAME).dylib
-else
-  LIB_SHARED = $(LIB_NAME).so
-endif
+LIB_SHARED = $(LIB_NAME).$(LIB_SUFFIX)
 
-CLEAN_TARGETS += liblvm.cflow
+CLEAN_TARGETS += liblvm.cflow $(LIB_NAME).a
 
 include $(top_builddir)/make.tmpl
 
@@ -47,12 +42,7 @@ ifeq ("@DMEVENTD@", "yes")
   LIBS += -ldevmapper-event
 endif
 
-$(VERSIONED_SHLIB): %.$(LIB_SUFFIX).$(LIB_VERSION_APP): %.$(LIB_SUFFIX)
-	rm -f $@
-	$(LN_S) $< $@
-
-.PHONY: install_dynamic install_static install_include install_pkgconfig \
-	distclean_lib distclean
+.PHONY: install_dynamic install_static install_include install_pkgconfig
 
 INSTALL_TYPE = install_dynamic
 
@@ -66,23 +56,16 @@ endif
 
 install: $(INSTALL_TYPE) install_include
 
-install_include:
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 444 $(srcdir)/lvm2app.h $(includedir)/lvm2app.h
+install_include: $(srcdir)/lvm2app.h
+	$(INSTALL_DATA) -D $< $(includedir)/$(<F)
 
-install_dynamic: $(LIB_SHARED)
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
-		$(libdir)/$(LIB_SHARED).$(LIB_VERSION_APP)
-	$(LN_S) -f $(LIB_SHARED).$(LIB_VERSION_APP) \
-		$(libdir)/$(LIB_SHARED)
+install_dynamic: install_lib_shared
 
 install_static: $(LIB_STATIC)
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
-		$(libdir)/$(LIB_STATIC).$(LIB_VERSION_APP)
-	$(LN_S) -f $(LIB_STATIC).$(LIB_VERSION_APP) $(libdir)/$(LIB_STATIC)
+	$(INSTALL_DATA) -D $< $(usrlibdir)/$(<F)
 
-install_pkgconfig:
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 444 $(LIB_NAME).pc \
-		$(usrlibdir)/pkgconfig/lvm2app.pc
+install_pkgconfig: $(LIB_NAME).pc
+	$(INSTALL_DATA) -D $< $(usrlibdir)/pkgconfig/lvm2app.pc
 
 liblvm.cflow: $(SOURCES)
 	set -e; (echo -n "SOURCES += "; \
@@ -92,9 +75,4 @@ liblvm.cflow: $(SOURCES)
 
 cflow: liblvm.cflow
 
-CLEAN_TARGETS += $(LIB_NAME).$(LIB_SUFFIX)
-
-distclean_lib:
-	$(RM) $(LIB_NAME).pc
-
-distclean: distclean_lib
+DISTCLEAN_TARGETS += $(LIB_NAME).pc
diff --git a/make.tmpl.in b/make.tmpl.in
index 6a79551..da8b020 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -72,16 +72,24 @@ vpath %.exported_symbols $(srcdir)
 interface = @interface@
 interfacebuilddir = $(top_builddir)/libdm/$(interface)
 
-# setup misc variables
-# define the ownership variables for the binaries and man pages
-OWNER = @OWNER@
-GROUP = @GROUP@
-
 # The number of jobs to run, if blank, defaults to the make standard
 ifndef MAKEFLAGS
 MAKEFLAGS = @JOBS@
 endif
 
+# Handle installation of files
+ifeq ("@WRITE_INSTALL@", "yes")
+# leaving defaults
+M_INSTALL_PROGRAM =
+M_INSTALL_DATA = -m 644
+else
+M_INSTALL_PROGRAM = -m 555
+M_INSTALL_DATA = -m 444
+endif
+INSTALL_PROGRAM = $(INSTALL) $(M_INSTALL_PROGRAM) $(STRIP)
+INSTALL_DATA = $(INSTALL) -p $(M_INSTALL_DATA)
+INSTALL_WDATA = $(INSTALL) -p -m 644
+
 .SUFFIXES: .c .d .o .so .a .po .pot .mo .dylib
 
 CFLAGS += -fPIC -Wall -Wundef -Wshadow -Wcast-align -Wwrite-strings -Wmissing-prototypes -Wmissing-declarations -Wnested-externs -Winline -Wmissing-noreturn -Wformat-security
@@ -152,6 +160,7 @@ POTFILES = $(SOURCES:%.c=%.pot)
 
 .PHONY: all pofile distclean clean cleandir cflow device-mapper
 .PHONY: install install_cluster install_device-mapper install_lvm2
+.PHONY: install_lib_shared install_lib_shared_plugin
 .PHONY: $(SUBDIRS) $(SUBDIRS.install) $(SUBDIRS.clean) $(SUBDIRS.distclean)
 .PHONY: $(SUBDIRS.pofile) $(SUBDIRS.install_cluster) $(SUBDIRS.cflow)
 .PHONY: $(SUBDIRS.device-mapper) $(SUBDIRS.install-device-mapper)
@@ -166,7 +175,7 @@ SUBDIRS.cflow := $(SUBDIRS:=.cflow)
 SUBDIRS.clean := $(SUBDIRS:=.clean)
 SUBDIRS.distclean := $(SUBDIRS:=.distclean)
 
-TARGETS += $(LIB_SHARED) $(LIB_STATIC) $(VERSIONED_SHLIB)
+TARGETS += $(LIB_SHARED) $(LIB_STATIC)
 
 all: $(SUBDIRS) $(TARGETS)
 
@@ -273,16 +282,30 @@ $(TARGETS): $(OBJECTS)
 %.so: %.o
 	$(CC) -c $(INCLUDES) $(DEFS) $(CFLAGS) $(CLDFLAGS) $< $(LIBS) -o $@
 
+ifneq (,$(LIB_SHARED))
+
+TARGETS += $(LIB_SHARED).$(LIB_VERSION)
+$(LIB_SHARED).$(LIB_VERSION): $(OBJECTS) $(LDDEPS)
 ifeq ("@LIB_SUFFIX@","so")
-$(LIB_SHARED): $(OBJECTS) $(LDDEPS)
-	$(CC) -shared -Wl,-soname,$(notdir $@).$(LIB_VERSION) \
-	$(CFLAGS) $(CLDFLAGS) $(OBJECTS) $(LIBS) -o $@
+	$(CC) -shared -Wl,-soname,$(notdir $@) \
+		$(CFLAGS) $(CLDFLAGS) $(OBJECTS) $(LIBS) -o $@
 endif
-
 ifeq ("@LIB_SUFFIX@","dylib")
-$(LIB_SHARED): $(OBJECTS) $(LDDEPS)
 	$(CC) -dynamiclib -dylib_current_version,$(LIB_VERSION) \
-	$(CFLAGS) $(CLDFLAGS) $(OBJECTS) $(LIBS) -o $@
+		$(CFLAGS) $(CLDFLAGS) $(OBJECTS) $(LIBS) -o $@
+endif
+
+$(LIB_SHARED): $(LIB_SHARED).$(LIB_VERSION)
+	$(LN_S) -f $(<F) $@
+
+install_lib_shared: $(LIB_SHARED)
+	$(INSTALL_PROGRAM) -D $< $(libdir)/$(<F).$(LIB_VERSION)
+	$(INSTALL) -d $(usrlibdir)
+	$(LN_S) -f $(libdir)/$(<F).$(LIB_VERSION) $(usrlibdir)/$(<F)
+
+# FIXME: plugins are currently installed with .so suffix only
+install_lib_shared_plugin: $(LIB_SHARED)
+	$(INSTALL_PROGRAM) -D $< $(libdir)/$(<F)
 endif
 
 %.so: %.a
diff --git a/man/Makefile.in b/man/Makefile.in
index f34014e..9b53841 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -1,6 +1,6 @@
 #
 # Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
-# Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -56,7 +56,7 @@ endif
 
 all: man
 
-.PHONY: man
+.PHONY: man install_man5 install_man8
 
 device-mapper: $(MAN8DM)
 
@@ -70,35 +70,22 @@ $(MAN5) $(MAN8) $(MAN8CLUSTER):	Makefile
 	  *) echo "Creating $@" ; $(SED) -e "s/#VERSION#/$(LVM_VERSION)/" $< > $@ ;; \
 	esac
 
-install_lvm2:
-	@echo "Installing $(MAN8) in $(MAN8DIR)"
-	@for f in $(MAN8); \
-	do \
-	   $(RM) $(MAN8DIR)/$$f; \
-	   @INSTALL@ -D $(OWNER) $(GROUP) -m 444 $$f $(MAN8DIR)/$$f; \
-	done
-
-	@echo "Installing $(MAN5) in $(MAN5DIR)"
-	@for f in $(MAN5); \
-	do \
-	   $(RM) $(MAN5DIR)/$$f; \
-	   @INSTALL@ -D $(OWNER) $(GROUP) -m 444 $$f $(MAN5DIR)/$$f; \
-	done
-
-install_cluster:
-	@echo "Installing $(MAN8CLUSTER) in $(MAN8DIR)"
-	@for f in $(MAN8CLUSTER); \
-	do \
-	   $(RM) $(MAN8DIR)/$$f; \
-	   @INSTALL@ -D $(OWNER) $(GROUP) -m 444 $$f $(MAN8DIR)/$$f; \
-	done
-
-install_device-mapper:
-	@echo "Installing $(MAN8DM) in $(MAN8DIR)"
-	@for f in $(MAN8DM); \
-	do \
-	   $(RM) $(MAN8DIR)/$$f; \
-	   @INSTALL@ -D $(OWNER) $(GROUP) -m 444 $$f $(MAN8DIR)/$$f; \
-	done
+install_man5: $(MAN5)
+	$(INSTALL) -d $(MAN5DIR)
+	$(INSTALL_DATA) $(MAN5) $(MAN5DIR)/
+
+install_man8: $(MAN8)
+	$(INSTALL) -d $(MAN8DIR)
+	$(INSTALL_DATA) $(MAN8) $(MAN8DIR)/
+
+install_lvm2: install_man5 install_man8
+
+install_cluster: $(MAN8CLUSTER)
+	$(INSTALL) -d $(MAN8DIR)
+	$(INSTALL_DATA) $(MAN8CLUSTER) $(MAN8DIR)/
+
+install_device-mapper: $(MAN8DM)
+	$(INSTALL) -d $(MAN8DIR)
+	$(INSTALL_DATA) $(MAN8DM) $(MAN8DIR)/
 
 install: install_lvm2 install_device-mapper
diff --git a/po/Makefile.in b/po/Makefile.in
index 79bd340..a4f57a6 100644
--- a/po/Makefile.in
+++ b/po/Makefile.in
@@ -53,13 +53,13 @@ install: $(TARGETS)
 	@echo Installing translation files in $(localedir)
 	@( \
 		for lang in $(LANGS); do \
-			$(INSTALL) -D $(OWNER) $(GROUP) -m 444 $$lang.mo \
+			$(INSTALL_DATA) -D $$lang.mo \
 			    $(localedir)/$$lang/LC_MESSAGES/lvm2.mo;\
 	  done; \
 	)
 	@( \
 		for lang in $(LANGS); do \
-			$(INSTALL) -D $(OWNER) $(GROUP) -m 444 $$lang.mo \
+			$(INSTALL_DATA) -D $$lang.mo \
 			    $(localedir)/$$lang/LC_MESSAGES/device-mapper.mo;\
 	  done; \
 	)
diff --git a/scripts/Makefile.in b/scripts/Makefile.in
index 4b1ab7f..b76e339 100644
--- a/scripts/Makefile.in
+++ b/scripts/Makefile.in
@@ -1,5 +1,5 @@
 #
-# Copyright (C) 2006 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2006-2010 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -17,16 +17,18 @@ top_builddir = @top_builddir@
 
 include $(top_builddir)/make.tmpl
 
-install:
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(srcdir)/lvm_dump.sh \
-		$(sbindir)/lvmdump
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(srcdir)/vgimportclone.sh \
-		$(sbindir)/vgimportclone
+SCRIPTS = lvm_dump.sh vgimportclone.sh
 ifeq ("@FSADM@", "yes")
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(srcdir)/fsadm.sh \
-		$(sbindir)/fsadm
+	SCRIPTS += fsadm.sh
 endif
 
-install_lvm2: install
+vpath %.sh $(srcdir)
+
+%_install: %.sh
+	$(INSTALL_PROGRAM) -D $< $(sbindir)/$(basename $(<F))
+
+install_lvm2: $(SCRIPTS:.sh=_install)
+
+install: install_lvm2
 
 DISTCLEAN_TARGETS += clvmd_init_red_hat cmirrord_init_red_hat lvm2_monitoring_init_red_hat
diff --git a/test/Makefile.in b/test/Makefile.in
index 90ce1f7..25cb487 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -1,4 +1,4 @@
-# Copyright (C) 2007 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2007-2010 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
diff --git a/tools/Makefile.in b/tools/Makefile.in
index b048fad..0a4d75f 100644
--- a/tools/Makefile.in
+++ b/tools/Makefile.in
@@ -78,7 +78,7 @@ TARGETS_DM = dmsetup
 
 INSTALL_LVM_TARGETS = install_tools_dynamic
 INSTALL_DMSETUP_TARGETS = install_dmsetup_dynamic
-INSTALL_CMDLIB_TARGETS = install_cmdlib_dynamic
+INSTALL_CMDLIB_TARGETS = install_cmdlib_dynamic install_cmdlib_include 
 
 ifeq ("@STATIC_LINK@", "yes")
   TARGETS += lvm.static
@@ -92,10 +92,11 @@ LVMLIBS = $(LVMINTERNAL_LIBS)
 LIB_VERSION = $(LIB_VERSION_LVM)
 
 CLEAN_TARGETS = liblvm2cmd.$(LIB_SUFFIX) $(TARGETS_DM) \
+	liblvm2cmd.$(LIB_SUFFIX).$(LIB_VERSION) lvm-static.o \
 	liblvm2cmd-static.a dmsetup.static lvm.static
 
 ifeq ("@CMDLIB@", "yes")
-	TARGETS += liblvm2cmd.$(LIB_SUFFIX)
+	TARGETS += liblvm2cmd.$(LIB_SUFFIX).$(LIB_VERSION)
 	INSTALL_LVM_TARGETS += $(INSTALL_CMDLIB_TARGETS)
 endif
 
@@ -145,6 +146,9 @@ liblvm2cmd-static.a: $(top_builddir)/lib/liblvm-internal.a $(OBJECTS) lvmcmdlib.
 
 liblvm2cmd.$(LIB_SUFFIX): liblvm2cmd.a $(LDDEPS)
 
+liblvm2cmd.$(LIB_SUFFIX).$(LIB_VERSION): liblvm2cmd.$(LIB_SUFFIX)
+	$(LN_S) -f $< $@
+
 .commands: $(srcdir)/commands.h $(srcdir)/cmdnames.h Makefile
 	$(CC) -E -P $(srcdir)/cmdnames.h 2> /dev/null | \
 		egrep -v '^ *(|#.*|dumpconfig|formats|help|pvdata|segtypes|version) *$$' > .commands
@@ -155,44 +159,37 @@ CFLOW_SOURCES = $(addprefix $(srcdir)/, $(SOURCES))
 -include $(top_builddir)/lib/liblvm-internal.cflow
 endif
 
-.PHONY: install_cmdlib_dynamic install_cmdlib_static \
+.PHONY: install_cmdlib_dynamic install_cmdlib_static install_cmdlib_include \
 	install_tools_dynamic install_tools_static \
 	install_dmsetup_dynamic install_dmsetup_static
 
+install_cmdlib_include: $(srcdir)/lvm2cmd.h
+	$(INSTALL_DATA) -D $< $(includedir)/$(<F)
+
 install_cmdlib_dynamic: liblvm2cmd.$(LIB_SUFFIX)
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
-		$(libdir)/liblvm2cmd.$(LIB_SUFFIX).$(LIB_VERSION)
-	$(LN_S) -f liblvm2cmd.$(LIB_SUFFIX).$(LIB_VERSION) $(libdir)/liblvm2cmd.$(LIB_SUFFIX)
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 444 $(srcdir)/lvm2cmd.h \
-		$(includedir)/lvm2cmd.h
+	$(INSTALL_PROGRAM) -D $< $(libdir)/$(<F).$(LIB_VERSION)
+	$(INSTALL) -d $(usrlibdir)
+	$(LN_S) -f $(libdir)/$<.$(LIB_VERSION) $(usrlibdir)/$(<F)
 
 install_cmdlib_static: liblvm2cmd-static.a
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
-		$(libdir)/liblvm2cmd.a.$(LIB_VERSION)
-	$(LN_S) -f liblvm2cmd.a.$(LIB_VERSION) $(libdir)/liblvm2cmd.a
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 444 $(srcdir)/lvm2cmd.h \
-		$(includedir)/lvm2cmd.h
+	$(INSTALL_DATA) -D $< $(usrlibdir)/liblvm2cmd.a
 
 install_tools_dynamic: lvm .commands
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) lvm \
-		$(sbindir)/lvm
+	$(INSTALL_PROGRAM) -D lvm $(sbindir)/lvm
 	@echo Creating symbolic links for individual commands in $(sbindir)
-	@( \
-		for v in `cat .commands`; do \
-			cd $(sbindir); \
-			$(LN_S) -f lvm $$v; \
-		done; \
-	)
+	@for v in `cat .commands`; do \
+		echo "$(LN_S) -f lvm $(sbindir)/$$v"; \
+		$(LN_S) -f lvm $(sbindir)/$$v; \
+	done;
 
 install_tools_static: lvm.static
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
-		$(staticdir)/lvm.static
+	$(INSTALL_PROGRAM) -D $< $(staticdir)/$(<F)
 
 install_dmsetup_dynamic: dmsetup
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< $(sbindir)/$<
+	$(INSTALL_PROGRAM) -D $< $(sbindir)/$(<F)
 
 install_dmsetup_static: dmsetup.static
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< $(sbindir)/$<
+	$(INSTALL_PROGRAM) -D $< $(staticdir)/$(<F)
 
 install_device-mapper: $(INSTALL_DMSETUP_TARGETS)
 
-- 
1.7.0.1


