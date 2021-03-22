From: David Teigland <teigland@sourceware.org>
Date: Mon, 22 Mar 2021 15:39:39 +0000 (GMT)
Subject: dev-next - make: cflow target works again
Message-ID: <20210322153939.4B7EC385781A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3d26bde1c02b5b3cdfe6bbf87dcad8ce552b0bba
Commit:        3d26bde1c02b5b3cdfe6bbf87dcad8ce552b0bba
Parent:        e86798203e4d2775aa418db6a17b908de7e15130
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 19 23:10:55 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Mar 20 00:05:01 2021 +0100

make: cflow target works again

Restored 'make cflow' functinality.
Produces some quick referece of function chaining and usage.
---
 daemons/cmirrord/Makefile.in                |  3 +++
 daemons/dmeventd/Makefile.in                | 19 ++++++++++---------
 daemons/dmeventd/plugins/mirror/Makefile.in |  3 ---
 daemons/dmeventd/plugins/raid/Makefile.in   |  3 ---
 daemons/dmeventd/plugins/thin/Makefile.in   |  3 ---
 daemons/dmeventd/plugins/vdo/Makefile.in    |  3 ---
 daemons/lvmlockd/Makefile.in                |  3 +++
 daemons/lvmpolld/Makefile.in                |  7 +++----
 lib/Makefile.in                             |  1 +
 libdm/Makefile.in                           |  1 +
 libdm/dm-tools/Makefile.in                  |  5 +++++
 libdm/make.tmpl.in                          | 18 ++++++++----------
 make.tmpl.in                                | 14 ++++++--------
 tools/Makefile.in                           | 10 +++-------
 14 files changed, 43 insertions(+), 50 deletions(-)

diff --git a/daemons/cmirrord/Makefile.in b/daemons/cmirrord/Makefile.in
index 301e6c6a2..8f68ba91c 100644
--- a/daemons/cmirrord/Makefile.in
+++ b/daemons/cmirrord/Makefile.in
@@ -22,6 +22,9 @@ SOURCES = clogd.c cluster.c compat.c functions.c link_mon.c local.c logging.c
 
 TARGETS = cmirrord
 
+CFLOW_SOURCES = $(addprefix $(srcdir)/, $(SOURCES))
+CFLOW_TARGET := $(TARGETS)
+
 include $(top_builddir)/make.tmpl
 
 LMLIBS += $(CPG_LIBS)
diff --git a/daemons/dmeventd/Makefile.in b/daemons/dmeventd/Makefile.in
index 99e4a816f..c737ca40d 100644
--- a/daemons/dmeventd/Makefile.in
+++ b/daemons/dmeventd/Makefile.in
@@ -14,11 +14,21 @@
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
+abs_srcdir = @abs_srcdir@
 
 SOURCES = libdevmapper-event.c
 SOURCES2 = dmeventd.c
 
 TARGETS = dmeventd
+CFLOW_SOURCES = $(addprefix $(srcdir)/, $(SOURCES) $(SOURCES2) \
+	plugins/lvm2/dmeventd_lvm.c \
+	plugins/mirror/dmeventd_mirror.c \
+	plugins/raid/dmeventd_raid.c \
+	plugins/snapshot/dmeventd_snapshot.c \
+	plugins/thin/dmeventd_thin.c \
+	plugins/vdo/dmeventd_vdo.c \
+	)
+CFLOW_TARGET := $(TARGETS)
 
 .PHONY: install_lib_dynamic install_lib_static install_include \
 	install_pkgconfig install_dmeventd_dynamic install_dmeventd_static \
@@ -46,7 +56,6 @@ endif
 
 CFLOW_LIST = $(SOURCES)
 CFLOW_LIST_TARGET = $(LIB_NAME).cflow
-CFLOW_TARGET = dmeventd
 
 EXPORTED_HEADER = $(srcdir)/libdevmapper-event.h
 EXPORTED_FN_PREFIX = dm_event
@@ -73,14 +82,6 @@ ifeq ("@PKGCONFIG@", "yes")
   INSTALL_LIB_TARGETS += install_pkgconfig
 endif
 
-ifneq ("$(CFLOW_CMD)", "")
-CFLOW_SOURCES = $(addprefix $(srcdir)/, $(SOURCES))
--include $(top_builddir)/lib/liblvm-internal.cflow
--include $(top_builddir)/lib/liblvm2cmd.cflow
--include $(top_builddir)/daemons/dmeventd/$(LIB_NAME).cflow
--include $(top_builddir)/daemons/dmeventd/plugins/mirror/$(LIB_NAME)-lvm2mirror.cflow
-endif
-
 install_include: $(srcdir)/libdevmapper-event.h
 	@echo "    [INSTALL] $(<F)"
 	$(Q) $(INSTALL_DATA) -D $< $(includedir)/$(<F)
diff --git a/daemons/dmeventd/plugins/mirror/Makefile.in b/daemons/dmeventd/plugins/mirror/Makefile.in
index 62d94c996..1552d9746 100644
--- a/daemons/dmeventd/plugins/mirror/Makefile.in
+++ b/daemons/dmeventd/plugins/mirror/Makefile.in
@@ -25,9 +25,6 @@ LIB_NAME = libdevmapper-event-lvm2mirror
 LIB_SHARED = $(LIB_NAME).$(LIB_SUFFIX)
 LIB_VERSION = $(LIB_VERSION_LVM)
 
-CFLOW_LIST = $(SOURCES)
-CFLOW_LIST_TARGET = $(LIB_NAME).cflow
-
 include $(top_builddir)/make.tmpl
 
 install_lvm2: install_dm_plugin
diff --git a/daemons/dmeventd/plugins/raid/Makefile.in b/daemons/dmeventd/plugins/raid/Makefile.in
index abc935d45..2082351c8 100644
--- a/daemons/dmeventd/plugins/raid/Makefile.in
+++ b/daemons/dmeventd/plugins/raid/Makefile.in
@@ -24,9 +24,6 @@ LIB_NAME = libdevmapper-event-lvm2raid
 LIB_SHARED = $(LIB_NAME).$(LIB_SUFFIX)
 LIB_VERSION = $(LIB_VERSION_LVM)
 
-CFLOW_LIST = $(SOURCES)
-CFLOW_LIST_TARGET = $(LIB_NAME).cflow
-
 include $(top_builddir)/make.tmpl
 
 install_lvm2: install_dm_plugin
diff --git a/daemons/dmeventd/plugins/thin/Makefile.in b/daemons/dmeventd/plugins/thin/Makefile.in
index c1cbee792..b98e42636 100644
--- a/daemons/dmeventd/plugins/thin/Makefile.in
+++ b/daemons/dmeventd/plugins/thin/Makefile.in
@@ -24,9 +24,6 @@ LIB_NAME = libdevmapper-event-lvm2thin
 LIB_SHARED = $(LIB_NAME).$(LIB_SUFFIX)
 LIB_VERSION = $(LIB_VERSION_LVM)
 
-CFLOW_LIST = $(SOURCES)
-CFLOW_LIST_TARGET = $(LIB_NAME).cflow
-
 include $(top_builddir)/make.tmpl
 
 install_lvm2: install_dm_plugin
diff --git a/daemons/dmeventd/plugins/vdo/Makefile.in b/daemons/dmeventd/plugins/vdo/Makefile.in
index 84adb7445..44942ea2d 100644
--- a/daemons/dmeventd/plugins/vdo/Makefile.in
+++ b/daemons/dmeventd/plugins/vdo/Makefile.in
@@ -24,9 +24,6 @@ LIB_NAME = libdevmapper-event-lvm2vdo
 LIB_SHARED = $(LIB_NAME).$(LIB_SUFFIX)
 LIB_VERSION = $(LIB_VERSION_LVM)
 
-CFLOW_LIST = $(SOURCES)
-CFLOW_LIST_TARGET = $(LIB_NAME).cflow
-
 include $(top_builddir)/make.tmpl
 
 install_lvm2: install_dm_plugin
diff --git a/daemons/lvmlockd/Makefile.in b/daemons/lvmlockd/Makefile.in
index bd577d1e6..ec5d5750a 100644
--- a/daemons/lvmlockd/Makefile.in
+++ b/daemons/lvmlockd/Makefile.in
@@ -34,6 +34,9 @@ SOURCES2 = lvmlockctl.c
 
 TARGETS = lvmlockd lvmlockctl
 
+CFLOW_SOURCES = $(addprefix $(srcdir)/, $(SOURCES))
+CFLOW_TARGET = lvmlockd
+
 .PHONY: install_lvmlockd
 
 include $(top_builddir)/make.tmpl
diff --git a/daemons/lvmpolld/Makefile.in b/daemons/lvmpolld/Makefile.in
index 05b12ff2c..3e85644d7 100644
--- a/daemons/lvmpolld/Makefile.in
+++ b/daemons/lvmpolld/Makefile.in
@@ -19,11 +19,10 @@ SOURCES = lvmpolld-core.c lvmpolld-data-utils.c lvmpolld-cmd-utils.c
 
 TARGETS = lvmpolld
 
-.PHONY: install_lvmpolld
+CFLOW_SOURCES = $(addprefix $(srcdir)/, $(SOURCES))
+CFLOW_TARGET := $(TARGETS)
 
-CFLOW_LIST = $(SOURCES)
-CFLOW_LIST_TARGET = $(LIB_NAME).cflow
-CFLOW_TARGET = lvmpolld
+.PHONY: install_lvmpolld
 
 include $(top_builddir)/make.tmpl
 
diff --git a/lib/Makefile.in b/lib/Makefile.in
index 3409cbd8c..900ae2f83 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -15,6 +15,7 @@
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
+abs_srcdir = @abs_srcdir@
 
 SOURCES =\
 	activate/activate.c \
diff --git a/libdm/Makefile.in b/libdm/Makefile.in
index e9bb5ae2f..12fec06b4 100644
--- a/libdm/Makefile.in
+++ b/libdm/Makefile.in
@@ -15,6 +15,7 @@
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
+abs_srcdir = @abs_srcdir@
 
 SUBDIRS=dm-tools
 
diff --git a/libdm/dm-tools/Makefile.in b/libdm/dm-tools/Makefile.in
index 0b2ef9605..8fbdfc152 100644
--- a/libdm/dm-tools/Makefile.in
+++ b/libdm/dm-tools/Makefile.in
@@ -20,6 +20,11 @@ all: device-mapper
 
 SOURCES2 = dmsetup.c
 TARGETS_DM = dmsetup
+
+CFLOW_SOURCES = $(addprefix $(srcdir)/, $(SOURCES2))
+CFLOW_TARGET := $(TARGETS_DM)
+-include $(top_builddir)/libdm/libdevmapper.cflow
+
 install_device-mapper: install_dmsetup_dynamic
 
 ifeq ("@STATIC_LINK@", "yes")
diff --git a/libdm/make.tmpl.in b/libdm/make.tmpl.in
index 549ef79d9..70edcf91d 100644
--- a/libdm/make.tmpl.in
+++ b/libdm/make.tmpl.in
@@ -347,8 +347,7 @@ $(SUBDIRS.generate):
 ifneq ("$(CFLOW_LIST_TARGET)", "")
 CLEAN_CFLOW += $(CFLOW_LIST_TARGET)
 $(CFLOW_LIST_TARGET): $(CFLOW_LIST)
-	echo "CFLOW_SOURCES += $(addprefix \
-		\$$(top_srcdir)$(subst $(top_srcdir),,$(srcdir))/, $(CFLOW_LIST))" > $@
+	echo "CFLOW_SOURCES += $(addprefix $(abs_srcdir)/, $(CFLOW_LIST))" > $@
 cflow: $(CFLOW_LIST_TARGET)
 endif
 
@@ -362,23 +361,22 @@ CLEAN_CFLOW += \
 
 ifneq ("$(CFLOW_CMD)", "")
 CFLOW_FLAGS +=\
- --cpp="$(CC) -E" \
+ --cpp="$(CC) -E $(INCLUDES) $(VALGRIND_CFLAGS) $(BLKID_CFLAGS) $(DEFS) \
+ -I$(top_srcdir)/libdm/ioctl \
+ -I$(top_srcdir)/libdm" \
  --symbol _ISbit:wrapper \
  --symbol __attribute__:wrapper \
- --symbol __const__:wrapper \
  --symbol __const:type \
- --symbol __restrict:type \
+ --symbol __const__:wrapper \
  --symbol __extension__:wrapper \
+ --symbol __leaf__:wrapper \
  --symbol __nonnull:wrapper \
  --symbol __nothrow__:wrapper \
  --symbol __pure__:wrapper \
  --symbol __REDIRECT:wrapper \
  --symbol __REDIRECT_NTH:wrapper \
- --symbol __wur:wrapper \
- -I$(top_srcdir)/libdm \
- -I$(top_srcdir)/libdm/ioctl \
- -I$(top_srcdir)/daemons/dmeventd/plugins/lvm2/ \
- $(INCLUDES) $(DEFS)
+ --symbol __restrict:type \
+ --symbol __wur:wrapper
 
 $(CFLOW_TARGET).cflow: $(CFLOW_SOURCES)
 	$(CFLOW_CMD) -o$@ $(CFLOW_FLAGS) $(CFLOW_SOURCES)
diff --git a/make.tmpl.in b/make.tmpl.in
index 75bb4f243..d95d956fa 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -388,8 +388,7 @@ $(SUBDIRS.generate):
 ifneq ("$(CFLOW_LIST_TARGET)", "")
 CLEAN_CFLOW += $(CFLOW_LIST_TARGET)
 $(CFLOW_LIST_TARGET): $(CFLOW_LIST)
-	echo "CFLOW_SOURCES += $(addprefix \
-		\$$(top_srcdir)$(subst $(top_srcdir),,$(srcdir))/, $(CFLOW_LIST))" > $@
+	echo "CFLOW_SOURCES += $(addprefix $(abs_srcdir)/, $(CFLOW_LIST))" > $@
 cflow: $(CFLOW_LIST_TARGET)
 endif
 
@@ -403,21 +402,20 @@ CLEAN_CFLOW += \
 
 ifneq ("$(CFLOW_CMD)", "")
 CFLOW_FLAGS +=\
- --cpp="$(CC) -E" \
+ --cpp="$(CC) -E $(INCLUDES) $(VALGRIND_CFLAGS) $(BLKID_CFLAGS) $(DEFS)" \
  --symbol _ISbit:wrapper \
  --symbol __attribute__:wrapper \
- --symbol __const__:wrapper \
  --symbol __const:type \
- --symbol __restrict:type \
+ --symbol __const__:wrapper \
  --symbol __extension__:wrapper \
+ --symbol __leaf__:wrapper \
  --symbol __nonnull:wrapper \
  --symbol __nothrow__:wrapper \
  --symbol __pure__:wrapper \
  --symbol __REDIRECT:wrapper \
  --symbol __REDIRECT_NTH:wrapper \
- --symbol __wur:wrapper \
- -I$(top_srcdir)/daemons/dmeventd/plugins/lvm2/ \
- $(INCLUDES) $(DEFS)
+ --symbol __restrict:type \
+ --symbol __wur:wrapper
 
 $(CFLOW_TARGET).cflow: $(CFLOW_SOURCES)
 	$(CFLOW_CMD) -o$@ $(CFLOW_FLAGS) $(CFLOW_SOURCES)
diff --git a/tools/Makefile.in b/tools/Makefile.in
index a099973e1..e871fbddd 100644
--- a/tools/Makefile.in
+++ b/tools/Makefile.in
@@ -109,9 +109,9 @@ endif
 EXPORTED_HEADER = $(srcdir)/lvm2cmd.h
 EXPORTED_FN_PREFIX = lvm2
 
-CFLOW_LIST = lvmcmdlib.c lvm2cmd.c
-CFLOW_LIST_TARGET = liblvm2cmd.cflow
 CFLOW_TARGET = lvm
+CFLOW_SOURCES = $(addprefix $(srcdir)/, $(SOURCES) lvmcmdlib.c lvm2cmd.c)
+-include $(top_builddir)/lib/liblvm-internal.cflow
 
 include $(top_builddir)/make.tmpl
 
@@ -198,11 +198,7 @@ command-lines-input.h: $(srcdir)/command-lines.in Makefile
 
 $(SOURCES:%.c=%.d) $(SOURCES2:%.c=%.d): command-lines-input.h command-count.h cmds.h
 $(SOURCES:%.c=%.o) $(SOURCES2:%.c=%.o): command-lines-input.h command-count.h cmds.h
-
-ifneq ("$(CFLOW_CMD)", "")
-CFLOW_SOURCES = $(addprefix $(srcdir)/, $(SOURCES))
--include $(top_builddir)/lib/liblvm-internal.cflow
-endif
+lvm.cflow lvm.xref lvm.tree lvm.xref: command-lines-input.h command-count.h cmds.h
 
 .PHONY: install_cmdlib_dynamic install_cmdlib_static install_cmdlib_include \
 	install_tools_dynamic install_tools_static


