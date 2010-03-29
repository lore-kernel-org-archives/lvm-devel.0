From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 29 Mar 2010 14:11:19 -0000
Subject: LVM2 ./Makefile.in ./make.tmpl.in daemons/Make ...
Message-ID: <20100329141119.18553.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-03-29 14:11:18

Modified files:
	.              : Makefile.in make.tmpl.in 
	daemons        : Makefile.in 
	daemons/dmeventd: Makefile.in 
	daemons/dmeventd/plugins/mirror: Makefile.in 
	include        : Makefile.in 
	lib            : Makefile.in 
	libdm          : Makefile.in 
	tools          : Makefile.in 

Log message:
	Update cflow file generation - support build dir and use $(top_srcdir)
	to obtain sources. Create make.tmpl target for
	simplier generation of cflow files with the help of
	CFLOW_LIST, CFLOW_LIST_TARGET, CFLOW_TARGET.
	Still cflow usage is not perfect.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/Makefile.in.diff?cvsroot=lvm2&r1=1.45&r2=1.46
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.84&r2=1.85
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/Makefile.in.diff?cvsroot=lvm2&r1=1.14&r2=1.15
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/Makefile.in.diff?cvsroot=lvm2&r1=1.37&r2=1.38
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/mirror/Makefile.in.diff?cvsroot=lvm2&r1=1.16&r2=1.17
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/include/Makefile.in.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/Makefile.in.diff?cvsroot=lvm2&r1=1.98&r2=1.99
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/Makefile.in.diff?cvsroot=lvm2&r1=1.50&r2=1.51
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/Makefile.in.diff?cvsroot=lvm2&r1=1.111&r2=1.112

--- LVM2/Makefile.in	2010/03/29 14:09:25	1.45
+++ LVM2/Makefile.in	2010/03/29 14:11:17	1.46
@@ -65,9 +65,10 @@
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
--- LVM2/make.tmpl.in	2010/03/29 14:09:25	1.84
+++ LVM2/make.tmpl.in	2010/03/29 14:11:17	1.85
@@ -168,6 +168,7 @@
 install_cluster: all $(SUBDIRS.install_cluster)
 install_device-mapper: $(SUBDIRS.install_device-mapper)
 install_lvm2: $(SUBDIRS.install_lvm2)
+cflow: $(SUBDIRS.cflow)
 
 $(SUBDIRS): $(SUBDIRS.device-mapper)
 	$(MAKE) -C $@
@@ -193,6 +194,9 @@
 $(SUBDIRS.distclean):
 	-$(MAKE) -C $(@:.distclean=) distclean
 
+$(SUBDIRS.cflow):
+	$(MAKE) -C $(@:.cflow=) cflow
+
 ifeq ("@INTL@", "yes")
 pofile: $(SUBDIRS.pofile) $(POTFILES)
 
@@ -200,11 +204,55 @@
 	$(MAKE) -C $(@:.pofile=) pofile
 endif
 
-ifneq ("@CFLOW_CMD@", "")
-cflow: $(SUBDIRS.cflow)
+ifneq ("$(CFLOW_LIST_TARGET)", "")
+CLEAN_CFLOW += $(CFLOW_LIST_TARGET)
+$(CFLOW_LIST_TARGET): $(CFLOW_LIST)
+	echo "CFLOW_SOURCES += $(addprefix \
+		\$$(top_srcdir)$(subst $(top_srcdir),,$(srcdir))/, $(CFLOW_LIST))" > $@
+cflow: $(CFLOW_LIST_TARGET)
+endif
 
-$(SUBDIRS.cflow):
-	$(MAKE) -C $(@:.cflow=) cflow
+ifneq ("$(CFLOW_TARGET)", "")
+CLEAN_CFLOW += \
+	$(CFLOW_TARGET).cflow \
+	$(CFLOW_TARGET).xref \
+	$(CFLOW_TARGET).tree \
+	$(CFLOW_TARGET).rtree \
+	$(CFLOW_TARGET).rxref
+
+ifneq ("$(CFLOW_CMD)", "")
+CFLOW_FLAGS +=\
+ --cpp="$(CC) -E" \
+ --symbol _ISbit:wrapper \
+ --symbol __attribute__:wrapper \
+ --symbol __const__:wrapper \
+ --symbol __const:type \
+ --symbol __restrict:type \
+ --symbol __extension__:wrapper \
+ --symbol __nonnull:wrapper \
+ --symbol __nothrow__:wrapper \
+ --symbol __pure__:wrapper \
+ --symbol __REDIRECT:wrapper \
+ --symbol __REDIRECT_NTH:wrapper \
+ --symbol __wur:wrapper \
+ -I$(top_srcdir)/libdm \
+ -I$(top_srcdir)/libdm/ioctl \
+ -I$(top_srcdir)/daemons/dmeventd/plugins/lvm2/ \
+ $(INCLUDES) $(DEFS)
+
+$(CFLOW_TARGET).cflow: $(CFLOW_SOURCES)
+	$(CFLOW_CMD) -o$@ $(CFLOW_FLAGS) $(CFLOW_SOURCES)
+$(CFLOW_TARGET).rxref: $(CFLOW_SOURCES)
+	$(CFLOW_CMD) -o$@ $(CFLOW_FLAGS) -r --omit-arguments $(CFLOW_SOURCES)
+$(CFLOW_TARGET).tree: $(CFLOW_SOURCES)
+	$(CFLOW_CMD) -o$@ $(CFLOW_FLAGS) --omit-arguments -T -b $(CFLOW_SOURCES)
+$(CFLOW_TARGET).xref: $(CFLOW_SOURCES)
+	$(CFLOW_CMD) -o$@ $(CFLOW_FLAGS) --omit-arguments -x $(CFLOW_SOURCES)
+#$(CFLOW_TARGET).rtree:  $(CFLOW_SOURCES)
+#	$(CFLOW_CMD) -o$@ $(CFLOW_FLAGS) -r --omit-arguments -T -b $(CFLOW_SOURCES)
+cflow: $(CFLOW_TARGET).cflow $(CFLOW_TARGET).tree $(CFLOW_TARGET).rxref $(CFLOW_TARGET).xref
+#$(CFLOW_TARGET).rtree
+endif
 endif
 
 $(TARGETS): $(OBJECTS)
@@ -255,7 +303,7 @@
 clean: $(SUBDIRS.clean)
 	$(RM) $(OBJECTS) $(TARGETS) $(CLEAN_TARGETS) $(SOURCES:%.c=%.d) \
 	      $(SOURCES2:%.c=%.d) $(SOURCES:%.c=%.pot) $(SOURCES:%.c=%.gcno) \
-	      $(SOURCES:%.c=%.gcda) $(LDDEPS)
+	      $(SOURCES:%.c=%.gcda) $(LDDEPS) $(CLEAN_CFLOW)
 
 distclean: clean $(SUBDIRS.distclean)
 	$(RM) -rf $(DISTCLEAN_DIRS)
@@ -269,6 +317,7 @@
 		 sed "s/^/		/;s/$$/;/" < $<; \
 		 echo "	local:"; echo "		*;"; echo "};") > $@
 
+ifneq ($(MAKECMDGOALS),cflow)
 ifneq ($(MAKECMDGOALS),clean)
   ifneq ($(MAKECMDGOALS),distclean)
     ifdef SOURCES
@@ -279,4 +328,4 @@
     endif
   endif
 endif
-
+endif
--- LVM2/daemons/Makefile.in	2010/03/29 14:09:25	1.14
+++ LVM2/daemons/Makefile.in	2010/03/29 14:11:17	1.15
@@ -1,5 +1,5 @@
 #
-# Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -28,6 +28,9 @@
 
 ifeq ("@BUILD_DMEVENTD@", "yes")
   SUBDIRS += dmeventd
+ifneq ("$(CFLOW_CMD)", "")
+daemons.cflow: dmeventd.cflow
+endif
 endif
 
 ifeq ($(MAKECMDGOALS),distclean)
--- LVM2/daemons/dmeventd/Makefile.in	2010/03/29 14:07:01	1.37
+++ LVM2/daemons/dmeventd/Makefile.in	2010/03/29 14:11:17	1.38
@@ -1,5 +1,5 @@
 #
-# Copyright (C) 2005-2007 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2005-2010 Red Hat, Inc. All rights reserved.
 #
 # This file is part of the device-mapper userspace tools.
 #
@@ -43,12 +43,16 @@
   VERSIONED_SHLIB = $(LIB_SHARED).$(LIB_VERSION)
 endif
 
-CLEAN_TARGETS = dmeventd.o dmeventd.static dmeventd.gcda dmeventd.gcno
+CLEAN_TARGETS = dmeventd.static $(LIB_NAME).a
 
 ifneq ($(MAKECMDGOALS),device-mapper)
   SUBDIRS+=plugins
 endif
 
+CFLOW_LIST = $(SOURCES)
+CFLOW_LIST_TARGET = $(LIB_NAME).cflow
+CFLOW_TARGET = dmeventd
+
 include $(top_builddir)/make.tmpl
 
 all: device-mapper
@@ -72,6 +76,15 @@
   INSTALL_LIB_TARGETS += install_pkgconfig
 endif
 
+ifneq ("$(CFLOW_CMD)", "")
+CFLOW_SOURCES = $(addprefix $(srcdir)/, $(SOURCES))
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
--- LVM2/daemons/dmeventd/plugins/mirror/Makefile.in	2010/03/04 11:21:06	1.16
+++ LVM2/daemons/dmeventd/plugins/mirror/Makefile.in	2010/03/29 14:11:18	1.17
@@ -22,19 +22,23 @@
 
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
 
+CFLOW_LIST = $(SOURCES)
+CFLOW_LIST_TARGET = $(LIB_NAME).cflow
+
 include $(top_builddir)/make.tmpl
 
 LIBS += @LVM2CMD_LIB@ -ldevmapper-event-lvm2 -ldevmapper $(PTHREAD_LIBS)
 
-install_lvm2: libdevmapper-event-lvm2mirror.$(LIB_SUFFIX)
+install_lvm2: $(LIB_NAME).$(LIB_SUFFIX)
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
 		$(libdir)/$<
 
--- LVM2/include/Makefile.in	2009/10/02 19:10:34	1.12
+++ LVM2/include/Makefile.in	2010/03/29 14:11:18	1.13
@@ -48,5 +48,4 @@
 
 install_lvm2:
 
-cflow:
-
+cflow: all
--- LVM2/lib/Makefile.in	2010/03/29 14:09:26	1.98
+++ LVM2/lib/Makefile.in	2010/03/29 14:11:18	1.99
@@ -150,8 +150,6 @@
 LIB_NAME = liblvm-internal
 LIB_STATIC = $(LIB_NAME).a
 
-CLEAN_TARGETS += $(LIB_NAME).cflow
-
 ifeq ($(MAKECMDGOALS),distclean)
   SUBDIRS =\
 	format1 \
@@ -161,14 +159,9 @@
 	locking
 endif
 
+CFLOW_LIST = $(SOURCES)
+CFLOW_LIST_TARGET = $(LIB_NAME).cflow
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
--- LVM2/libdm/Makefile.in	2010/03/04 12:12:34	1.50
+++ LVM2/libdm/Makefile.in	2010/03/29 14:11:18	1.51
@@ -47,6 +47,9 @@
 VERSIONED_SHLIB = libdevmapper.$(LIB_SUFFIX).$(LIB_VERSION_DM)
 LIB_VERSION = $(LIB_VERSION_DM)
 
+CFLOW_LIST = $(SOURCES)
+CFLOW_LIST_TARGET = libdevmapper.cflow
+
 include $(top_builddir)/make.tmpl
 
 DEFS += -DDM_DEVICE_UID=@DM_DEVICE_UID@ -DDM_DEVICE_GID=@DM_DEVICE_GID@ \
--- LVM2/tools/Makefile.in	2010/03/04 12:12:34	1.111
+++ LVM2/tools/Makefile.in	2010/03/29 14:11:18	1.112
@@ -89,7 +89,6 @@
 
 CLEAN_TARGETS = liblvm2cmd.$(LIB_SUFFIX) liblvm2cmd.a liblvm2cmd-static.a lvm lvm.o \
 		lvm2cmd.o lvm2cmd-static.o lvm2cmdlib.o lvm.static \
-		lvm.cflow lvm.xref lvm.tree lvm.rxref lvm.rtree \
 		lvmcmdlib.o lvm-static.o dmsetup.o $(TARGETS_DM)
 
 ifeq ("@CMDLIB@", "yes")
@@ -105,6 +104,10 @@
 
 DEFS += -DLVM_SHARED_PATH=\"$(exec_prefix)/sbin/lvm\"
 
+CFLOW_LIST = lvmcmdlib.c lvm2cmd.c
+CFLOW_LIST_TARGET = liblvm2cmd.cflow
+CFLOW_TARGET = lvm
+
 include $(top_builddir)/make.tmpl
 
 LIBS += $(UDEV_LIBS)
@@ -147,20 +150,9 @@
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
+CFLOW_SOURCES = $(addprefix $(srcdir)/, $(SOURCES))
+-include $(top_builddir)/libdm/libdevmapper.cflow
+-include $(top_builddir)/lib/liblvm-internal.cflow
 endif
 
 install_cmdlib_dynamic: liblvm2cmd.$(LIB_SUFFIX)


