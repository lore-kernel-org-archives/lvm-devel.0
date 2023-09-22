From: Adam Joseph <adam@westernsemico.com>
Date: Thu, 21 Sep 2023 23:47:38 -0700
Subject: [PATCH] autoconf: handle the standard --disable-shared flag
Message-ID: <20230922064737.31282-2-adam@westernsemico.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Since LVM 2.02 it appears that compiling LVM on a platform which
lacks a shared library linker/loader will fail to produce any
binaries (dmsetup, lvm2, etc).

This commit adds support for the standard --disable-shared flag, and
uses it to disable attempts at building shared libraries.
---
 configure.ac               | 9 +++++++++
 libdm/Makefile.in          | 7 +++++++
 libdm/dm-tools/Makefile.in | 9 +++++++++
 libdm/make.tmpl.in         | 6 ++++++
 make.tmpl.in               | 4 ++++
 5 files changed, 35 insertions(+)

diff --git a/configure.ac b/configure.ac
index b43d8b9be..78aee5a9a 100644
--- a/configure.ac
+++ b/configure.ac
@@ -185,6 +185,15 @@ AC_ARG_ENABLE(static_link,
 	      STATIC_LINK=$enableval, STATIC_LINK="no")
 AC_MSG_RESULT([$STATIC_LINK])
 
+AC_ARG_ENABLE(shared, AS_HELP_STRING([--enable-shared],[whether to build shared libraries [default=yes]]),
+  shared=$enableval, shared=yes)
+if test "$shared" = yes; then
+  AC_SUBST(ENABLE_SHARED, "yes", [whether to build shared libraries.])
+else
+  AC_SUBST(ENABLE_SHARED, "no", [whether to build shared libraries.])
+fi
+
+
 ################################################################################
 dnl -- Check if compiler/linker supports PIE and RELRO
 AC_TRY_CCFLAG([-pie], [HAVE_PIE], [], [])
diff --git a/libdm/Makefile.in b/libdm/Makefile.in
index 2758648e6..30b2c798b 100644
--- a/libdm/Makefile.in
+++ b/libdm/Makefile.in
@@ -47,7 +47,9 @@ endif
 
 LIB_SHARED = $(interface)/libdevmapper.$(LIB_SUFFIX)
 LIB_VERSION = $(LIB_VERSION_DM)
+ifeq ("@ENABLE_SHARED@", "yes")
 TARGETS = libdevmapper.$(LIB_SUFFIX) libdevmapper.$(LIB_SUFFIX).$(LIB_VERSION) .symver_check
+endif
 
 CFLOW_LIST = $(SOURCES)
 CFLOW_LIST_TARGET = libdevmapper.cflow
@@ -103,7 +105,12 @@ install_dynamic: install_ at interface@
 
 install_static: install_ at interface@_static
 
+ifeq ("@STATIC_LINK@", "yes")
+install_ioctl: install_ioctl_static
+endif
+ifeq ("@ENABLE_SHARED@", "yes")
 install_ioctl: install_lib_shared
+endif
 
 install_pkgconfig: libdevmapper.pc
 	@echo "    [INSTALL] $<"
diff --git a/libdm/dm-tools/Makefile.in b/libdm/dm-tools/Makefile.in
index 78d2d719d..325f180c0 100644
--- a/libdm/dm-tools/Makefile.in
+++ b/libdm/dm-tools/Makefile.in
@@ -19,13 +19,17 @@ top_builddir = @top_builddir@
 all: device-mapper
 
 SOURCES2 = dmsetup.c
+ifeq ("@ENABLE_SHARED@", "yes")
 TARGETS_DM = dmsetup
+endif
 
 CFLOW_SOURCES = $(addprefix $(srcdir)/, $(SOURCES2))
 CFLOW_TARGET := $(TARGETS_DM)
 -include $(top_builddir)/libdm/libdevmapper.cflow
 
+ifeq ("@ENABLE_SHARED@", "yes")
 install_device-mapper: install_dmsetup_dynamic
+endif
 
 ifeq ("@STATIC_LINK@", "yes")
   TARGETS_DM += dmsetup.static
@@ -99,6 +103,11 @@ install_dmfilemapd_static: dmfilemapd.static
 .PHONY: install_dmsetup_dynamic install_dmsetup_static
 .PHONY: install_dmfilemapd install_dmfilemapd_static
 
+ifeq ("@ENABLE_SHARED@", "yes")
 install: install_device-mapper install_dmfilemapd
+endif
+ifeq ("@STATIC_LINK@", "yes")
+install: install_dmsetup_static install_dmfilemapd_static
+endif
 
 device-mapper: $(TARGETS_DM)
diff --git a/libdm/make.tmpl.in b/libdm/make.tmpl.in
index cc28e73cb..454e23512 100644
--- a/libdm/make.tmpl.in
+++ b/libdm/make.tmpl.in
@@ -318,7 +318,11 @@ SUBDIRS.cflow := $(SUBDIRS:=.cflow)
 SUBDIRS.clean := $(SUBDIRS:=.clean)
 SUBDIRS.distclean := $(SUBDIRS:=.distclean)
 
+ifeq ("@ENABLE_SHARED@", "yes")
 TARGETS += $(LIB_SHARED) $(LIB_STATIC)
+else
+TARGETS += $(LIB_STATIC)
+endif
 
 all: $(SUBDIRS) $(TARGETS)
 
@@ -435,7 +439,9 @@ DEFS+=-D_FILE_OFFSET_BITS=64
 
 ifneq (,$(LIB_SHARED))
 
+ifeq ("@ENABLE_SHARED@", "yes")
 TARGETS += $(LIB_SHARED).$(LIB_VERSION)
+endif
 $(LIB_SHARED).$(LIB_VERSION): $(OBJECTS) $(LDDEPS)
 	@echo "    [CC] $@"
 ifeq ("@LIB_SUFFIX@","so")
diff --git a/make.tmpl.in b/make.tmpl.in
index fcb62f78a..f61307b31 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -372,7 +372,11 @@ SUBDIRS.cflow := $(SUBDIRS:=.cflow)
 SUBDIRS.clean := $(SUBDIRS:=.clean)
 SUBDIRS.distclean := $(SUBDIRS:=.distclean)
 
+ifeq ("@ENABLE_SHARED@", "yes")
 TARGETS += $(LIB_SHARED) $(LIB_STATIC)
+else
+TARGETS += $(LIB_STATIC)
+endif
 
 INTERNAL_LIBS = \
 	$(top_builddir)/libdaemon/client/libdaemonclient.a \
-- 
2.41.0

