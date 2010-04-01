From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu,  1 Apr 2010 12:11:43 +0200
Subject: [PATCH] INSTALL rules updates
Message-ID: <1270116703-7505-1-git-send-email-zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Patch tries to address multiple issues.
It is inspired from Debians separe patch but makes things more correct.

- removes OWNER & GROUP make vars they are parts of INSTALL command.
- adds INSTALL_PROGRAM for executable, uses $(INSTALL)
- adds INSTALL_DATA for non-executable data, uses ($INSTALL)
- adds INSTALL_WDATA for writable non-executable data, uses ($INSTALL)
- adds configure option --enable-write_install - to support writable
  files installation mode used by distribution
- replaces usage of ifeq @LIB_SUFFIX@ with $(LIB_SUFFIX)
- installs .a files from static builds without executable flag
- installs .a files to $(usrlibdir) instead of $(libdir)
- create .so links for devel package in $(usrlibdir) instead of
  $(libdir)
- makes only .so files within builddir (version is added to
  installed .so files)
- removes VERSIONED_SHLIB
- prints whole 'install' command during installation instead of less
  informative "Installing  $(something) $(somewhere)"
---
 configure.in                                  |   16 +++++----
 daemons/clvmd/Makefile.in                     |    3 +-
 daemons/cmirrord/Makefile.in                  |    7 ++--
 daemons/dmeventd/Makefile.in                  |   33 +++++------------
 daemons/dmeventd/plugins/lvm2/Makefile.in     |   14 +++-----
 daemons/dmeventd/plugins/mirror/Makefile.in   |   12 ++-----
 daemons/dmeventd/plugins/snapshot/Makefile.in |   12 ++-----
 doc/Makefile.in                               |    5 +--
 lib/Makefile.in                               |    2 +-
 lib/format1/Makefile.in                       |   11 +++---
 lib/format_pool/Makefile.in                   |   14 +++-----
 lib/locking/Makefile.in                       |   13 +++----
 lib/mirror/Makefile.in                        |   12 +++----
 lib/snapshot/Makefile.in                      |   13 +++----
 libdm/Makefile.in                             |   46 ++++++++-----------------
 liblvm/Makefile.in                            |   17 +++------
 make.tmpl.in                                  |   20 +++++++---
 man/Makefile.in                               |   35 +++++++------------
 po/Makefile.in                                |    4 +-
 scripts/Makefile.in                           |   11 ++----
 test/Makefile.in                              |    2 +-
 tools/Makefile.in                             |   38 ++++++++------------
 udev/Makefile.in                              |   18 ++++------
 23 files changed, 139 insertions(+), 219 deletions(-)

diff --git a/configure.in b/configure.in
index 6d55083..90fa07c 100644
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
@@ -736,6 +733,12 @@ AC_ARG_ENABLE(pkgconfig,   [  --enable-pkgconfig      Install pkgconfig support]
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
@@ -1083,7 +1086,6 @@ AC_SUBST(DM_IOCTLS)
 AC_SUBST(DM_LIB_VERSION)
 AC_SUBST(DM_LIB_PATCHLEVEL)
 AC_SUBST(FSADM)
-AC_SUBST(GROUP)
 AC_SUBST(GULM_CFLAGS)
 AC_SUBST(GULM_LIBS)
 AC_SUBST(HAVE_LIBDL)
@@ -1107,7 +1109,6 @@ AC_SUBST(LVM_RELEASE_DATE)
 AC_SUBST(MIRRORS)
 AC_SUBST(REPLICATORS)
 AC_SUBST(MSGFMT)
-AC_SUBST(OWNER)
 AC_SUBST(PKGCONFIG)
 AC_SUBST(POOL)
 AC_SUBST(PTHREAD_LIBS)
@@ -1125,6 +1126,7 @@ AC_SUBST(STATIC_LINK)
 AC_SUBST(UDEV_LIBS)
 AC_SUBST(UDEV_RULES)
 AC_SUBST(UDEV_SYNC)
+AC_SUBST(WRITE_INSTALL)
 AC_SUBST(interface)
 AC_SUBST(kerneldir)
 AC_SUBST(missingkernel)
diff --git a/daemons/clvmd/Makefile.in b/daemons/clvmd/Makefile.in
index e3f70d5..dfeb8d3 100644
--- a/daemons/clvmd/Makefile.in
+++ b/daemons/clvmd/Makefile.in
@@ -111,8 +111,7 @@ clvmd: $(OBJECTS) $(top_builddir)/lib/liblvm-internal.a
 .PHONY: install_clvmd
 
 install_clvmd: $(TARGETS)
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) clvmd \
-		$(usrsbindir)/clvmd
+	$(INSTALL_PROGRAM) -D clvmd $(sbindir)/clvmd
 
 install: $(INSTALL_TARGETS)
 
diff --git a/daemons/cmirrord/Makefile.in b/daemons/cmirrord/Makefile.in
index b8928c7..57310df 100644
--- a/daemons/cmirrord/Makefile.in
+++ b/daemons/cmirrord/Makefile.in
@@ -1,5 +1,5 @@
 #
-# Copyright (C) 2009 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2009-2010 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -32,9 +32,8 @@ LMLIBS += $(CPG_LIBS) $(SACKPT_LIBS)
 CFLAGS += $(CPG_CFLAGS) $(SACKPT_CFLAGS)
 
 cmirrord: $(OBJECTS) $(top_builddir)/lib/liblvm-internal.a
-	$(CC) $(CFLAGS) $(LDFLAGS) -o cmirrord $(OBJECTS) \
+	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJECTS) \
 		$(LVMLIBS) $(LMLIBS) $(LIBS)
 
 install: $(TARGETS)
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) cmirrord \
-		$(usrsbindir)/cmirrord
+	$(INSTALL_PROGRAM) -D $< $(usrsbindir)/$<
diff --git a/daemons/dmeventd/Makefile.in b/daemons/dmeventd/Makefile.in
index cd2a4d3..b8b83a9 100644
--- a/daemons/dmeventd/Makefile.in
+++ b/daemons/dmeventd/Makefile.in
@@ -37,13 +37,7 @@ ifeq ("@STATIC_LINK@", "yes")
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
 
@@ -62,11 +56,7 @@ device-mapper: $(TARGETS)
 
 LVMLIBS += -ldevmapper-event -ldevmapper $(PTHREAD_LIBS)
 
-$(VERSIONED_SHLIB): $(LIB_SHARED)
-	$(RM) -f $@
-	$(LN_S) $(LIB_SHARED) $@
-
-dmeventd: $(LIB_SHARED) $(VERSIONED_SHLIB) dmeventd.o
+dmeventd: $(LIB_SHARED) dmeventd.o
 	$(CC) $(CFLAGS) $(LDFLAGS) -L. -o $@ dmeventd.o \
 	$(DL_LIBS) $(LVMLIBS) $(LIBS) -rdynamic
 
@@ -88,31 +78,28 @@ CFLOW_SOURCES = $(addprefix $(srcdir)/, $(SOURCES))
 endif
 
 install_include:
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 444 $(srcdir)/libdevmapper-event.h \
+	$(INSTALL_DATA) -D $(srcdir)/libdevmapper-event.h \
 		$(includedir)/libdevmapper-event.h
 
 install_pkgconfig:
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 444 libdevmapper-event.pc \
+	$(INSTALL_DATA) -D libdevmapper-event.pc \
 		$(usrlibdir)/pkgconfig/devmapper-event.pc
 
 install_lib_dynamic: libdevmapper-event.$(LIB_SUFFIX)
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
-		$(libdir)/libdevmapper-event.$(LIB_SUFFIX).$(LIB_VERSION)
-	$(LN_S) -f libdevmapper-event.$(LIB_SUFFIX).$(LIB_VERSION) \
-		$(libdir)/libdevmapper-event.$(LIB_SUFFIX)
+	$(INSTALL_PROGRAM) -D $< $(libdir)/$<.$(LIB_VERSION)
+	$(INSTALL) -d $(usrlibdir)
+	$(LN_S) -f $(libdir)/$<.$(LIB_VERSION) $(usrlibdir)/$<
 
 install_lib_static: libdevmapper-event.a
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
-		$(libdir)/libdevmapper-event.a.$(LIB_VERSION)
-	$(LN_S) -f libdevmapper-event.a.$(LIB_VERSION) $(libdir)/libdevmapper-event.a
+	$(INSTALL_DATA) -D $< $(usrlibdir)/$<
 
 install_lib: $(INSTALL_LIB_TARGETS)
 
 install_dmeventd_dynamic: dmeventd
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< $(sbindir)/$<
+	$(INSTALL_PROGRAM) -D $< $(sbindir)/$<
 
 install_dmeventd_static: dmeventd.static
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< $(sbindir)/$<
+	$(INSTALL_PROGRAM) -D $< $(sbindir)/$<
 
 install_dmeventd: $(INSTALL_DMEVENTD_TARGETS)
 
diff --git a/daemons/dmeventd/plugins/lvm2/Makefile.in b/daemons/dmeventd/plugins/lvm2/Makefile.in
index 0f23c84..8a0d300 100644
--- a/daemons/dmeventd/plugins/lvm2/Makefile.in
+++ b/daemons/dmeventd/plugins/lvm2/Makefile.in
@@ -20,20 +20,16 @@ CLDFLAGS += -L$(top_builddir)/tools
 
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
+install_lvm2: $(LIB_SHARED)
+	$(INSTALL_PROGRAM) -D $< $(libdir)/$<.$(LIB_VERSION)
+	$(INSTALL) -d $(usrlibdir)
+	$(LN_S) -f $(libdir)/$<.$(LIB_VERSION) $(usrlibdir)/$<
 
 install: install_lvm2
diff --git a/daemons/dmeventd/plugins/mirror/Makefile.in b/daemons/dmeventd/plugins/mirror/Makefile.in
index 02c4e24..df85f76 100644
--- a/daemons/dmeventd/plugins/mirror/Makefile.in
+++ b/daemons/dmeventd/plugins/mirror/Makefile.in
@@ -23,12 +23,7 @@ CLDFLAGS += -L$(top_builddir)/tools -L$(top_builddir)/daemons/dmeventd/plugins/l
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
@@ -38,8 +33,7 @@ include $(top_builddir)/make.tmpl
 
 LIBS += @LVM2CMD_LIB@ -ldevmapper-event-lvm2 -ldevmapper $(PTHREAD_LIBS)
 
-install_lvm2: $(LIB_NAME).$(LIB_SUFFIX)
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
-		$(libdir)/$<
+install_lvm2: $(LIB_SHARED)
+	$(INSTALL_PROGRAM) -D $< $(libdir)/$<
 
 install: install_lvm2
diff --git a/daemons/dmeventd/plugins/snapshot/Makefile.in b/daemons/dmeventd/plugins/snapshot/Makefile.in
index 793fd38..00a5f6b 100644
--- a/daemons/dmeventd/plugins/snapshot/Makefile.in
+++ b/daemons/dmeventd/plugins/snapshot/Makefile.in
@@ -22,20 +22,14 @@ CLDFLAGS += -L$(top_builddir)/tools -L$(top_builddir)/daemons/dmeventd/plugins/l
 
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
+install_lvm2: $(LIB_SHARED)
+	$(INSTALL_PROGRAM) -D $< $(libdir)/$<
 
 install: install_lvm2
diff --git a/doc/Makefile.in b/doc/Makefile.in
index ce66209..5a68a16 100644
--- a/doc/Makefile.in
+++ b/doc/Makefile.in
@@ -1,5 +1,5 @@
 #
-# Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -24,8 +24,7 @@ include $(top_builddir)/make.tmpl
 install_lvm2: $(CONFSRC)
 	@if [ ! -e $(confdir)/$(CONFDEST) ]; then \
 		echo "Installing $(CONFSRC) as $(confdir)/$(CONFDEST)"; \
-		@INSTALL@ -D $(OWNER) $(GROUP) -m 644 $< \
-			$(confdir)/$(CONFDEST); \
+		$(INSTALL_WDATA) -D $< $(confdir)/$(CONFDEST); \
 	fi
 
 install: install_lvm2
diff --git a/lib/Makefile.in b/lib/Makefile.in
index bd3da89..5d423b4 100644
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
index f62ab7c..856555b 100644
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
@@ -26,13 +26,12 @@ SOURCES =\
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
+install: $(LIB_SHARED)
+	$(INSTALL_PROGRAM) -D $< $(libdir)/$<.$(LIB_VERSION)
+	$(LN_S) -f $<.$(LIB_VERSION) $(libdir)/$<
 
diff --git a/lib/format_pool/Makefile.in b/lib/format_pool/Makefile.in
index b0ebc36..7eef5ea 100644
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
@@ -23,15 +23,11 @@ SOURCES =\
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
+install: $(LIB_SHARED)
+	$(INSTALL_PROGRAM) -D $< $(libdir)/$<.$(LIB_VERSION)
+	$(LN_S) -f $<.$(LIB_VERSION) $(libdir)/$<
diff --git a/lib/locking/Makefile.in b/lib/locking/Makefile.in
index 399b0af..2116e63 100644
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
@@ -19,14 +19,11 @@ VPATH = @srcdir@
 
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
+install install_cluster: $(LIB_SHARED)
+	$(INSTALL_PROGRAM) -D $< $(libdir)/$<.$(LIB_VERSION)
+	$(LN_S) -f $<.$(LIB_VERSION) $(libdir)/$<
diff --git a/lib/mirror/Makefile.in b/lib/mirror/Makefile.in
index 038399a..716dbd7 100644
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
@@ -19,13 +19,11 @@ VPATH = @srcdir@
 
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
+install: $(LIB_SHARED)
+	$(INSTALL_PROGRAM) -D $< $(libdir)/$<.$(LIB_VERSION)
+	$(LN_S) -f $<.$(LIB_VERSION) $(libdir)/$<
diff --git a/lib/snapshot/Makefile.in b/lib/snapshot/Makefile.in
index 80728c7..9641e49 100644
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
@@ -19,14 +19,11 @@ VPATH = @srcdir@
 
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
+install: $(LIB_SHARED)
+	$(INSTALL_PROGRAM) -D $< $(libdir)/$<.$(LIB_VERSION)
+	$(LN_S) -f $<.$(LIB_VERSION) $(libdir)/$<
diff --git a/libdm/Makefile.in b/libdm/Makefile.in
index 63e6603..646b6cd 100644
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
@@ -39,13 +39,9 @@ ifeq ("@STATIC_LINK@", "yes")
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
+TARGETS += libdevmapper.$(LIB_SUFFIX)
 
 CFLOW_LIST = $(SOURCES)
 CFLOW_LIST_TARGET = libdevmapper.cflow
@@ -59,6 +55,9 @@ LIBS += $(SELINUX_LIBS) $(UDEV_LIBS)
 
 device-mapper: all
 
+libdevmapper.$(LIB_SUFFIX): $(LIB_SHARED)
+	$(LN_S) -f $< $@
+
 .PHONY: install_dynamic install_static install_include \
 	install_ioctl install_ioctl_static \
 	install_pkgconfig
@@ -78,39 +77,24 @@ install: $(INSTALL_TYPE) install_include
 install_device-mapper: install
 
 install_include:
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 444 $(srcdir)/libdevmapper.h \
+	$(INSTALL_DATA) -D $(srcdir)/libdevmapper.h \
 		$(includedir)/libdevmapper.h
 
 install_dynamic: install_ at interface@
-	$(LN_S) -f libdevmapper.$(LIB_SUFFIX).$(LIB_VERSION_DM) \
-		$(libdir)/libdevmapper.$(LIB_SUFFIX)
+	$(INSTALL) -d $(usrlibdir)
+	$(LN_S) -f $(libdir)/libdevmapper.$(LIB_SUFFIX).$(LIB_VERSION_DM) \
+		$(usrlibdir)/libdevmapper.$(LIB_SUFFIX)
 
 install_static: install_@interface@_static
-	$(LN_S) -f libdevmapper.a.$(LIB_VERSION_DM) $(libdir)/libdevmapper.a
 
 install_ioctl: ioctl/libdevmapper.$(LIB_SUFFIX)
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
-		$(libdir)/libdevmapper.$(LIB_SUFFIX).$(LIB_VERSION_DM)
+	$(INSTALL_PROGRAM) -D $< $(libdir)/libdevmapper.$(LIB_SUFFIX).$(LIB_VERSION_DM)
 
-install_pkgconfig:
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 444 libdevmapper.pc \
-		$(usrlibdir)/pkgconfig/devmapper.pc
+install_pkgconfig: libdevmapper.pc
+	$(INSTALL_DATA) -D libdevmapper.pc $(usrlibdir)/pkgconfig/devmapper.pc
 
 install_ioctl_static: ioctl/libdevmapper.a
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
-		$(libdir)/libdevmapper.a.$(LIB_VERSION_DM)
-
-$(VERSIONED_SHLIB): %.$(LIB_SUFFIX).$(LIB_VERSION_DM): $(interface)/%.$(LIB_SUFFIX)
-	rm -f $@
-	$(LN_S) $< $@
-	rm -f libdevmapper.$(LIB_SUFFIX)
-	$(LN_S) $< libdevmapper.$(LIB_SUFFIX)
+	$(INSTALL_DATA) -D $< $(usrlibdir)/libdevmapper.a
 
 CLEAN_TARGETS += libdevmapper.$(LIB_SUFFIX) ioctl/libdevmapper.a
-
-.PHONY: distclean_lib
-
-distclean_lib:
-	$(RM) libdevmapper.pc
-
-distclean: distclean_lib
+DISTCLEAN_TARGETS += libdevmapper.pc
diff --git a/liblvm/Makefile.in b/liblvm/Makefile.in
index 1b2b474..0e52365 100644
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
@@ -68,22 +68,17 @@ endif
 install: $(INSTALL_TYPE) install_include
 
 install_include:
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 444 $(srcdir)/lvm2app.h $(includedir)/lvm2app.h
+	$(INSTALL_DATA) -D $(srcdir)/lvm2app.h $(includedir)/lvm2app.h
 
 install_dynamic: $(LIB_SHARED)
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
-		$(libdir)/$(LIB_SHARED).$(LIB_VERSION_APP)
-	$(LN_S) -f $(LIB_SHARED).$(LIB_VERSION_APP) \
-		$(libdir)/$(LIB_SHARED)
+	$(INSTALL_PROGRAM) -D $< $(libdir)/$<.$(LIB_VERSION_APP)
+	$(LN_S) -f $<.$(LIB_VERSION_APP) $(libdir)/$<
 
 install_static: $(LIB_STATIC)
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
-		$(libdir)/$(LIB_STATIC).$(LIB_VERSION_APP)
-	$(LN_S) -f $(LIB_STATIC).$(LIB_VERSION_APP) $(libdir)/$(LIB_STATIC)
+	$(INSTALL_PROGRAM) -D $< $(usrlibdir)/$<
 
 install_pkgconfig:
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 444 $(LIB_NAME).pc \
-		$(usrlibdir)/pkgconfig/lvm2app.pc
+	$(INSTALL_DATA) -D $(LIB_NAME).pc $(usrlibdir)/pkgconfig/lvm2app.pc
 
 liblvm.cflow: $(SOURCES)
 	set -e; (echo -n "SOURCES += "; \
diff --git a/make.tmpl.in b/make.tmpl.in
index 8b93bb1..1aee355 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -66,16 +66,24 @@ udevdir = $(DESTDIR)@udevdir@
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
@@ -160,7 +168,7 @@ SUBDIRS.cflow := $(SUBDIRS:=.cflow)
 SUBDIRS.clean := $(SUBDIRS:=.clean)
 SUBDIRS.distclean := $(SUBDIRS:=.distclean)
 
-TARGETS += $(LIB_SHARED) $(LIB_STATIC) $(VERSIONED_SHLIB)
+TARGETS += $(LIB_SHARED) $(LIB_STATIC)
 
 all: $(SUBDIRS) $(TARGETS)
 
diff --git a/man/Makefile.in b/man/Makefile.in
index 446bbe6..ce84f95 100644
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
@@ -72,34 +72,25 @@ $(MAN5) $(MAN8) $(MAN8CLUSTER):	Makefile
 	esac
 
 install_lvm2:
-	@echo "Installing $(MAN8) in $(MAN8DIR)"
-	@for f in $(MAN8); \
-	do \
-	   $(RM) $(MAN8DIR)/$$f; \
-	   @INSTALL@ -D $(OWNER) $(GROUP) -m 444 $$f $(MAN8DIR)/$$f; \
+	@for f in $(MAN8); do \
+	   echo "$(INSTALL_DATA) -D $$f $(MAN8DIR)/$$f"; \
+	   $(INSTALL_DATA) -D $$f $(MAN8DIR)/$$f; \
 	done
-
-	@echo "Installing $(MAN5) in $(MAN5DIR)"
-	@for f in $(MAN5); \
-	do \
-	   $(RM) $(MAN5DIR)/$$f; \
-	   @INSTALL@ -D $(OWNER) $(GROUP) -m 444 $$f $(MAN5DIR)/$$f; \
+	@for f in $(MAN5); do \
+	   echo "$(INSTALL_DATA) -D $$f $(MAN5DIR)/$$f"; \
+	   $(INSTALL_DATA) -D $$f $(MAN5DIR)/$$f; \
 	done
 
 install_cluster:
-	@echo "Installing $(MAN8CLUSTER) in $(MAN8DIR)"
-	@for f in $(MAN8CLUSTER); \
-	do \
-	   $(RM) $(MAN8DIR)/$$f; \
-	   @INSTALL@ -D $(OWNER) $(GROUP) -m 444 $$f $(MAN8DIR)/$$f; \
+	@for f in $(MAN8CLUSTER); do \
+	   echo "$(INSTALL_DATA) -D $$f $(MAN8DIR)/$$f"; \
+	   $(INSTALL_DATA) -D $$f $(MAN8DIR)/$$f; \
 	done
 
 install_device-mapper:
-	@echo "Installing $(MAN8DM) in $(MAN8DIR)"
-	@for f in $(MAN8DM); \
-	do \
-	   $(RM) $(MAN8DIR)/$$f; \
-	   @INSTALL@ -D $(OWNER) $(GROUP) -m 444 $$f $(MAN8DIR)/$$f; \
+	@for f in $(MAN8DM); do \
+	   echo "$(INSTALL_DATA) -D $$f $(MAN8DIR)/$$f"; \
+	   $(INSTALL_DATA) -D $$f $(MAN8DIR)/$$f; \
 	done
 
 install: install_lvm2 install_device-mapper
diff --git a/po/Makefile.in b/po/Makefile.in
index 22184f1..12fd1c9 100644
--- a/po/Makefile.in
+++ b/po/Makefile.in
@@ -54,13 +54,13 @@ install: $(TARGETS)
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
index b79d312..375abe2 100644
--- a/scripts/Makefile.in
+++ b/scripts/Makefile.in
@@ -1,5 +1,5 @@
 #
-# Copyright (C) 2006 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2006-2010 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -19,13 +19,10 @@ VPATH = @srcdir@
 include $(top_builddir)/make.tmpl
 
 install:
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(srcdir)/lvm_dump.sh \
-		$(sbindir)/lvmdump
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(srcdir)/vgimportclone.sh \
-		$(sbindir)/vgimportclone
+	$(INSTALL_PROGRAM) -D $(srcdir)/lvm_dump.sh $(sbindir)/lvmdump
+	$(INSTALL_PROGRAM) -D $(srcdir)/vgimportclone.sh $(sbindir)/vgimportclone
 ifeq ("@FSADM@", "yes")
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(srcdir)/fsadm.sh \
-		$(sbindir)/fsadm
+	$(INSTALL_PROGRAM) -D $(srcdir)/fsadm.sh $(sbindir)/fsadm
 endif
 
 install_lvm2: install
diff --git a/test/Makefile.in b/test/Makefile.in
index 6ea6224..1e8d8a7 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -1,4 +1,4 @@
-# Copyright (C) 2007 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2007-2010 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
diff --git a/tools/Makefile.in b/tools/Makefile.in
index 8cab5c4..7bf85fd 100644
--- a/tools/Makefile.in
+++ b/tools/Makefile.in
@@ -93,7 +93,7 @@ LVMLIBS = $(LVMINTERNAL_LIBS)
 LIB_VERSION = $(LIB_VERSION_LVM)
 
 CLEAN_TARGETS = liblvm2cmd.$(LIB_SUFFIX) $(TARGETS_DM) \
-	liblvm2cmd-static.a dmsetup.static lvm.static
+	liblvm2cmd-static.a dmsetup.static lvm.static lvm-static.o
 
 ifeq ("@CMDLIB@", "yes")
 	TARGETS += liblvm2cmd.$(LIB_SUFFIX)
@@ -161,39 +161,31 @@ endif
 	install_dmsetup_dynamic install_dmsetup_static
 
 install_cmdlib_dynamic: liblvm2cmd.$(LIB_SUFFIX)
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
-		$(libdir)/liblvm2cmd.$(LIB_SUFFIX).$(LIB_VERSION)
-	$(LN_S) -f liblvm2cmd.$(LIB_SUFFIX).$(LIB_VERSION) $(libdir)/liblvm2cmd.$(LIB_SUFFIX)
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 444 $(srcdir)/lvm2cmd.h \
-		$(includedir)/lvm2cmd.h
+	$(INSTALL_PROGRAM) -D $< $(libdir)/$<.$(LIB_VERSION)
+	$(INSTALL) -d $(usrlibdir)
+	$(LN_S) -f $(libdir)/$<.$(LIB_VERSION) $(usrlibdir)/$<
+	$(INSTALL_DATA) -D $(srcdir)/lvm2cmd.h $(includedir)/lvm2cmd.h
 
 install_cmdlib_static: liblvm2cmd-static.a
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
-		$(libdir)/liblvm2cmd.a.$(LIB_VERSION)
-	$(LN_S) -f liblvm2cmd.a.$(LIB_VERSION) $(libdir)/liblvm2cmd.a
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 444 $(srcdir)/lvm2cmd.h \
-		$(includedir)/lvm2cmd.h
+	$(INSTALL_DATA) -D $< $(usrlibdir)/liblvm2cmd.a
+	$(INSTALL_DATA) -D $(srcdir)/lvm2cmd.h $(includedir)/lvm2cmd.h
 
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
+	$(INSTALL_PROGRAM) -D $< $(staticdir)/$<
 
 install_dmsetup_dynamic: dmsetup
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< $(sbindir)/$<
+	$(INSTALL_PROGRAM) -D $< $(sbindir)/$<
 
 install_dmsetup_static: dmsetup.static
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< $(sbindir)/$<
+	$(INSTALL_PROGRAM) -D $< $(sbindir)/$<
 
 install_device-mapper: $(INSTALL_DMSETUP_TARGETS)
 
diff --git a/udev/Makefile.in b/udev/Makefile.in
index 0d9e2ec..2cde9a5 100644
--- a/udev/Makefile.in
+++ b/udev/Makefile.in
@@ -1,5 +1,5 @@
 #
-# Copyright (C) 2009 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2009-2010 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -28,20 +28,16 @@ include $(top_builddir)/make.tmpl
 	$(SED) -e "s/(DM_DIR)/$(DM_DIR)/" $< >$@
 
 install_lvm2: $(LVM_RULES)
-	@echo "Installing $(LVM_RULES) in $(udevdir)"
-	@for f in $(LVM_RULES); \
-	do \
-	   $(RM) $(udevdir)/$$f; \
-	   $(INSTALL) -c -D $(OWNER) $(GROUP) -m 644 $(srcdir)/$$f $(udevdir)/$$f; \
+	@for f in $(LVM_RULES); do \
+	   echo "$(INSTALL_DATA) -D $(srcdir)/$$f $(udevdir)/$$f"; \
+	   $(INSTALL_DATA) -D $(srcdir)/$$f $(udevdir)/$$f; \
 	done
 
 install_device-mapper: $(DM_RULES)
-	@echo "Installing $(DM_RULES) in $(udevdir)"
-	@for f in $(DM_RULES); \
-	do \
-	   $(RM) $(udevdir)/$$f; \
+	@for f in $(DM_RULES); do \
 	   if test -f $$f; then file=$$f; else file=$(srcdir)/$$f; fi; \
-	   $(INSTALL) -c -D $(OWNER) $(GROUP) -m 644 $$file $(udevdir)/$$f; \
+	   echo "$(INSTALL_DATA) -D $$file $(udevdir)/$$f"; \
+	   $(INSTALL_DATA) -D $$file $(udevdir)/$$f; \
 	done
 
 install: install_lvm2 install_device-mapper
-- 
1.7.0.1


