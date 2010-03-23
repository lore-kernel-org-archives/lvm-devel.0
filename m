From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 23 Mar 2010 17:27:39 +0100
Subject: [PATCH 6/6] Update cflow
In-Reply-To: <cover.1269361453.git.zkabelac@redhat.com>
References: <cover.1269361453.git.zkabelac@redhat.com>
Message-ID: <90aad631fccb74f278f1b7496af0960d8fb9251a.1269361453.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Update cflow file generation - support build dir and properly use
top_srcdir to obtain sources. Create make.tmpl target for
simplier generation of cflow files with the help of
CFLOW_DIR, CFLOW_LIST, CFLOW_TARGET, CFLOW_GEN

Add support for dmeventd.

Try to avoid generation too many warnings from cflow execution.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 Makefile.in                                 |    7 ++--
 daemons/Makefile.in                         |    5 ++-
 daemons/dmeventd/Makefile.in                |   16 ++++++++-
 daemons/dmeventd/plugins/mirror/Makefile.in |   11 ++++--
 include/Makefile.in                         |    3 +-
 lib/Makefile.in                             |   12 ++----
 libdm/Makefile.in                           |    4 ++
 make.tmpl.in                                |   51 +++++++++++++++++++++++++--
 tools/Makefile.in                           |   23 ++++--------
 9 files changed, 96 insertions(+), 36 deletions(-)

diff --git a/Makefile.in b/Makefile.in
index 5c64a9a..ae52ff6 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -65,9 +65,10 @@ po.pofile: tools.pofile daemons.pofile
 pofile: po.pofile
 endif
 
-ifneq ("@CFLOW_CMD@", "")
-tools.cflow: lib.cflow
-cflow: tools.cflow
+ifneq ("$(CFLOW_CMD)", "")
+tools.cflow: libdm.cflow lib.cflow
+daemons.cflow: tools.cflow
+cflow: include.cflow
 endif
 
 ifneq ("@CSCOPE_CMD@", "")
diff --git a/daemons/Makefile.in b/daemons/Makefile.in
index 1b4bcbb..2f5837a 100644
--- a/daemons/Makefile.in
+++ b/daemons/Makefile.in
@@ -1,5 +1,5 @@
 #
-# Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -28,6 +28,9 @@ endif
 
 ifeq ("@BUILD_DMEVENTD@", "yes")
   SUBDIRS += dmeventd
+ifneq ("$(CFLOW_CMD)", "")
+daemons.cflow: dmeventd.cflow
+endif
 endif
 
 ifeq ($(MAKECMDGOALS),distclean)
diff --git a/daemons/dmeventd/Makefile.in b/daemons/dmeventd/Makefile.in
index 948d908..22100f9 100644
--- a/daemons/dmeventd/Makefile.in
+++ b/daemons/dmeventd/Makefile.in
@@ -1,5 +1,5 @@
 #
-# Copyright (C) 2005-2007 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2005-2010 Red Hat, Inc. All rights reserved.
 #
 # This file is part of the device-mapper userspace tools.
 #
@@ -49,6 +49,11 @@ ifneq ($(MAKECMDGOALS),device-mapper)
   SUBDIRS+=plugins
 endif
 
+CFLOW_DIR = daemons/dmeventd
+CFLOW_LIST = $(SOURCES)
+CFLOW_TARGET = $(LIB_NAME).cflow
+CFLOW_GEN = dmeventd
+
 include $(top_builddir)/make.tmpl
 
 all: device-mapper
@@ -72,6 +77,15 @@ ifeq ("@PKGCONFIG@", "yes")
   INSTALL_LIB_TARGETS += install_pkgconfig
 endif
 
+ifneq ("$(CFLOW_CMD)", "")
+CFLOW_SOURCES = $(addprefix $(top_srcdir)/daemons/dmeventd/, $(SOURCES))
+-include $(top_builddir)/libdm/libdevmapper.cflow
+-include $(top_builddir)/lib/liblvm-internal.cflow
+-include $(top_builddir)/lib/liblvm2cmd.cflow
+-include $(top_builddir)/daemons/dmeventd/$(LIB_NAME).cflow
+-include $(top_builddir)/daemons/dmeventd/plugins/mirror/$(LIB_NAME)-lvm2mirror.cflow
+endif
+
 install_include:
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 444 $(srcdir)/libdevmapper-event.h \
 		$(includedir)/libdevmapper-event.h
diff --git a/daemons/dmeventd/plugins/mirror/Makefile.in b/daemons/dmeventd/plugins/mirror/Makefile.in
index bd85a6f..d4c9c7e 100644
--- a/daemons/dmeventd/plugins/mirror/Makefile.in
+++ b/daemons/dmeventd/plugins/mirror/Makefile.in
@@ -22,19 +22,24 @@ CLDFLAGS += -L$(top_builddir)/tools -L$(top_builddir)/daemons/dmeventd/plugins/l
 
 SOURCES = dmeventd_mirror.c
 
+LIB_NAME = libdevmapper-event-lvm2mirror
 ifeq ("@LIB_SUFFIX@","dylib")
-  LIB_SHARED = libdevmapper-event-lvm2mirror.dylib
+  LIB_SHARED = $(LIB_NAME).dylib
 else
-  LIB_SHARED = libdevmapper-event-lvm2mirror.so
+  LIB_SHARED = $(LIB_NAME).so
 endif
 
 LIB_VERSION = $(LIB_VERSION_LVM)
 
+CFLOW_DIR = daemons/dmeventd/plugins/mirror
+CFLOW_LIST = $(SOURCES)
+CFLOW_TARGET = $(LIB_NAME).cflow
+
 include $(top_builddir)/make.tmpl
 
 LIBS += @LVM2CMD_LIB@ -ldevmapper-event-lvm2 -ldevmapper $(PTHREAD_LIBS)
 
-install_lvm2: libdevmapper-event-lvm2mirror.$(LIB_SUFFIX)
+install_lvm2: $(LIB_NAME).$(LIB_SUFFIX)
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
 		$(libdir)/$<
 
diff --git a/include/Makefile.in b/include/Makefile.in
index 55add36..3023d4a 100644
--- a/include/Makefile.in
+++ b/include/Makefile.in
@@ -48,5 +48,4 @@ install_device-mapper:
 
 install_lvm2:
 
-cflow:
-
+cflow: all
diff --git a/lib/Makefile.in b/lib/Makefile.in
index c83dc89..f2cfdf7 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -161,14 +161,10 @@ ifeq ($(MAKECMDGOALS),distclean)
 	locking
 endif
 
+CFLOW_DIR = lib
+CFLOW_LIST = $(SOURCES)
+CFLOW_TARGET = $(LIB_NAME).cflow
+
 include $(top_builddir)/make.tmpl
 
 $(SUBDIRS): $(LIB_STATIC)
-
-$(LIB_NAME).cflow: $(SOURCES)
-	set -e; (echo -n "SOURCES += "; \
-		 echo $(SOURCES) | \
-		 sed "s/^/ /;s/ / $(top_srcdir)\/lib\//g;s/$$//"; \
-		 ) > $@
-
-cflow: $(LIB_NAME).cflow
diff --git a/libdm/Makefile.in b/libdm/Makefile.in
index 85e19ea..8874b2b 100644
--- a/libdm/Makefile.in
+++ b/libdm/Makefile.in
@@ -47,6 +47,10 @@ endif
 VERSIONED_SHLIB = libdevmapper.$(LIB_SUFFIX).$(LIB_VERSION_DM)
 LIB_VERSION = $(LIB_VERSION_DM)
 
+CFLOW_DIR = libdm
+CFLOW_LIST = $(SOURCES)
+CFLOW_TARGET = libdevmapper.cflow
+
 include $(top_builddir)/make.tmpl
 
 DEFS += -DDM_DEVICE_UID=@DM_DEVICE_UID@ -DDM_DEVICE_GID=@DM_DEVICE_GID@ \
diff --git a/make.tmpl.in b/make.tmpl.in
index df4eafa..a59b9c0 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -200,8 +200,52 @@ $(SUBDIRS.pofile):
 	$(MAKE) -C $(@:.pofile=) pofile
 endif
 
-ifneq ("@CFLOW_CMD@", "")
+ifneq ("$(CFLOW_CMD)", "")
 cflow: $(SUBDIRS.cflow)
+ifneq ("$(CFLOW_TARGET)", "")
+CLEAN_CFLOW += $(CFLOW_TARGET)
+# use 't' to print in verbatim $(top_srcdir) - any better way ?
+$(CFLOW_TARGET): $(CFLOW_LIST)
+	echo "CFLOW_SOURCES += $(addprefix\
+		\$$(top_srcdir)/$(CFLOW_DIR)/, $(CFLOW_LIST))" > $@
+cflow: $(CFLOW_TARGET)
+.PHONY: $(CFLOW_TARGET)
+endif
+
+ifneq ("$(CFLOW_GEN)", "")
+CFLOW_FLAGS +=\
+ --cpp="$(CC) -E"\
+ --symbol _ISbit:wrapper\
+ --symbol __attribute__:wrapper\
+ --symbol __const__:wrapper\
+ --symbol __extension__:wrapper\
+ --symbol __nonnull:wrapper\
+ --symbol __nothrow__:wrapper\
+ --symbol __pure__:wrapper\
+ --symbol __REDIRECT:wrapper\
+ --symbol __REDIRECT_NTH:wrapper\
+ --symbol __wur:wrapper\
+ -I$(top_srcdir)/libdm\
+ -I$(top_srcdir)/libdm/ioctl\
+ -I$(top_srcdir)/tools/ioctl\
+ -I$(top_srcdir)/daemons/dmeventd/plugins/lvm2/\
+ $(INCLUDES) $(DEFS)
+
+.PHONY: $(CFLOW_GEN).cflow $(CFLOW_GEN).xref $(CFLOW_GEN).tree $(CFLOW_GEN).rtree $(CFLOW_GEN).rxref
+CLEAN_CFLOW += $(CFLOW_GEN).cflow $(CFLOW_GEN).xref $(CFLOW_GEN).tree $(CFLOW_GEN).rtree $(CFLOW_GEN).rxref
+$(CFLOW_GEN).cflow: $(CFLOW_SOURCES)
+	$(CFLOW_CMD) -o$@ $(CFLOW_FLAGS) $(CFLOW_SOURCES)
+$(CFLOW_GEN).rxref: $(CFLOW_SOURCES)
+	$(CFLOW_CMD) -o$@ $(CFLOW_FLAGS) -r --omit-arguments -x $(CFLOW_SOURCES)
+$(CFLOW_GEN).tree: $(SOURCES)
+	$(CFLOW_CMD) -o$@ $(CFLOW_FLAGS) --omit-arguments -T -b -x $(CFLOW_SOURCES)
+$(CFLOW_GEN).xref: $(SOURCES)
+	$(CFLOW_CMD) -o$@ $(CFLOW_FLAGS) --omit-arguments -x $(CFLOW_SOURCES)
+#$(CFLOW_GEN).rtree: $(SOURCES)
+#	$(CFLOW_CMD) -o$@ $(CFLOW_FLAGS) -r --omit-arguments -T -b $(CFLOW_SOURCES)
+cflow: $(CFLOW_GEN).cflow $(CFLOW_GEN).tree $(CFLOW_GEN).rxref $(CFLOW_GEN).xref
+#$(CFLOW_GEN).rtree
+endif
 
 $(SUBDIRS.cflow):
 	$(MAKE) -C $(@:.cflow=) cflow
@@ -255,7 +299,7 @@ $(LIB_STATIC): $(OBJECTS)
 clean: $(SUBDIRS.clean)
 	$(RM) $(OBJECTS) $(TARGETS) $(CLEAN_TARGETS) $(SOURCES:%.c=%.d) \
 	      $(SOURCES2:%.c=%.d) $(SOURCES:%.c=%.pot) $(SOURCES:%.c=%.gcno) \
-	      $(SOURCES:%.c=%.gcda) $(LDDEPS)
+	      $(SOURCES:%.c=%.gcda) $(LDDEPS) $(CLEAN_CFLOW)
 
 distclean: $(SUBDIRS.clean) $(SUBDIRS.distclean)
 	$(RM) -rf $(DISTCLEAN_DIRS)
@@ -269,6 +313,7 @@ distclean: $(SUBDIRS.clean) $(SUBDIRS.distclean)
 		 sed "s/^/		/;s/$$/;/" < $<; \
 		 echo "	local:"; echo "		*;"; echo "};") > $@
 
+ifneq ($(MAKECMDGOALS),cflow)
 ifneq ($(MAKECMDGOALS),clean)
   ifneq ($(MAKECMDGOALS),distclean)
     ifdef SOURCES
@@ -279,4 +324,4 @@ ifneq ($(MAKECMDGOALS),clean)
     endif
   endif
 endif
-
+endif
diff --git a/tools/Makefile.in b/tools/Makefile.in
index 5106327..b3e5299 100644
--- a/tools/Makefile.in
+++ b/tools/Makefile.in
@@ -89,7 +89,6 @@ LIB_VERSION = $(LIB_VERSION_LVM)
 
 CLEAN_TARGETS = liblvm2cmd.$(LIB_SUFFIX) liblvm2cmd.a liblvm2cmd-static.a lvm lvm.o \
 		lvm2cmd.o lvm2cmd-static.o lvm2cmdlib.o lvm.static \
-		lvm.cflow lvm.xref lvm.tree lvm.rxref lvm.rtree \
 		lvmcmdlib.o lvm-static.o dmsetup.o $(TARGETS_DM)
 
 ifeq ("@CMDLIB@", "yes")
@@ -105,6 +104,11 @@ LVMLIBS += -ldevmapper
 
 DEFS += -DLVM_SHARED_PATH=\"$(exec_prefix)/sbin/lvm\"
 
+CFLOW_DIR = tools
+CFLOW_LIST = lvmcmdlib.c lvm2cmd.c
+CFLOW_TARGET = liblvm2cmd.cflow
+CFLOW_GEN = lvm
+
 include $(top_builddir)/make.tmpl
 
 LIBS += $(UDEV_LIBS)
@@ -147,20 +151,9 @@ liblvm2cmd.$(LIB_SUFFIX): liblvm2cmd.a $(LDDEPS)
 	install_tools_dynamic install_tools_static
 
 ifneq ("$(CFLOW_CMD)", "")
-CFLOW_FLAGS += --cpp="$(CC) -E"
-.PHONY: lvm.cflow
--include $(top_srcdir)/lib/liblvm-internal.cflow
-lvm.cflow: $(SOURCES)
-	$(CFLOW_CMD) -o$@ $(CFLOW_FLAGS) $(INCLUDES) $(DEFS) $(SOURCES)
-lvm.rxref: $(SOURCES)
-	$(CFLOW_CMD) -o$@ --cpp="$(CC) -E" -r --omit-arguments -x $(INCLUDES) $(DEFS) $(SOURCES)
-lvm.xref: $(SOURCES)
-	$(CFLOW_CMD) -o$@ --cpp="$(CC) -E" --omit-arguments -x $(INCLUDES) $(DEFS) $(SOURCES)
-lvm.rtree: $(SOURCES)
-	$(CFLOW_CMD) -o$@ --cpp="$(CC) -E" -r --omit-arguments -T -b $(INCLUDES) $(DEFS) $(SOURCES)
-lvm.tree: $(SOURCES)
-	$(CFLOW_CMD) -o$@ --cpp="$(CC) -E" --omit-arguments -T -b $(INCLUDES) $(DEFS) $(SOURCES)
-cflow: lvm.cflow lvm.xref lvm.tree lvm.rtree lvm.rxref
+CFLOW_SOURCES = $(addprefix $(top_srcdir)/tools/, $(SOURCES))
+-include $(top_builddir)/libdm/libdevmapper.cflow
+-include $(top_builddir)/lib/liblvm-internal.cflow
 endif
 
 install_cmdlib_dynamic: liblvm2cmd.$(LIB_SUFFIX)
-- 
1.7.0.1


