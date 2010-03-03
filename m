From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed,  3 Mar 2010 21:42:50 +0100
Subject: [PATCH 04/15] Fix usage of $(top_builddir)
In-Reply-To: <cover.1267648294.git.zkabelac@redhat.com>
References: <cover.1267648294.git.zkabelac@redhat.com>
Message-ID: <816979f689a062f2a14495f628aa59174b5c8455.1267648294.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 daemons/Makefile.in                  |    2 +-
 daemons/clvmd/Makefile.in            |    2 +-
 daemons/cmirrord/Makefile.in         |    2 +-
 daemons/dmeventd/Makefile.in         |    2 +-
 daemons/dmeventd/plugins/Makefile.in |    2 +-
 doc/Makefile.in                      |    2 +-
 lib/Makefile.in                      |    4 ++--
 lib/format1/Makefile.in              |    2 +-
 lib/format_pool/Makefile.in          |    2 +-
 lib/locking/Makefile.in              |    2 +-
 lib/mirror/Makefile.in               |    2 +-
 lib/snapshot/Makefile.in             |    2 +-
 libdm/Makefile.in                    |    2 +-
 liblvm/Makefile.in                   |    2 +-
 man/Makefile.in                      |    2 +-
 old-tests/device/Makefile.in         |    4 ++--
 old-tests/filters/Makefile.in        |    6 +++---
 old-tests/format1/Makefile.in        |   22 +++++++++++-----------
 old-tests/mm/Makefile.in             |    6 +++---
 old-tests/regex/Makefile.in          |   10 +++++-----
 po/Makefile.in                       |    2 +-
 scripts/Makefile.in                  |    2 +-
 tools/Makefile.in                    |    2 +-
 udev/Makefile.in                     |    2 +-
 24 files changed, 44 insertions(+), 44 deletions(-)

diff --git a/daemons/Makefile.in b/daemons/Makefile.in
index 92773bb..a0e7268 100644
--- a/daemons/Makefile.in
+++ b/daemons/Makefile.in
@@ -30,7 +30,7 @@ ifeq ("@BUILD_DMEVENTD@", "yes")
   SUBDIRS += dmeventd
 endif
 
-include ../make.tmpl
+include $(top_builddir)/make.tmpl
 
 ifeq ("@BUILD_DMEVENTD@", "yes")
 device-mapper: dmeventd.device-mapper
diff --git a/daemons/clvmd/Makefile.in b/daemons/clvmd/Makefile.in
index dad568e..905f1c9 100644
--- a/daemons/clvmd/Makefile.in
+++ b/daemons/clvmd/Makefile.in
@@ -86,7 +86,7 @@ LVMLIBS += -ldevmapper
 DEFS += -D_REENTRANT
 CFLAGS += -fno-strict-aliasing
 
-include ../../make.tmpl
+include $(top_builddir)/make.tmpl
 
 INSTALL_TARGETS = \
 	install_clvmd
diff --git a/daemons/cmirrord/Makefile.in b/daemons/cmirrord/Makefile.in
index b33aa6a..b8928c7 100644
--- a/daemons/cmirrord/Makefile.in
+++ b/daemons/cmirrord/Makefile.in
@@ -25,7 +25,7 @@ SOURCES = clogd.c cluster.c compat.c functions.c link_mon.c local.c logging.c
 
 TARGETS = cmirrord
 
-include ../../make.tmpl
+include $(top_builddir)/make.tmpl
 
 LIBS += -ldevmapper
 LMLIBS += $(CPG_LIBS) $(SACKPT_LIBS)
diff --git a/daemons/dmeventd/Makefile.in b/daemons/dmeventd/Makefile.in
index d185205..fc72c21 100644
--- a/daemons/dmeventd/Makefile.in
+++ b/daemons/dmeventd/Makefile.in
@@ -48,7 +48,7 @@ ifneq ($(MAKECMDGOALS),device-mapper)
   SUBDIRS+=plugins
 endif
 
-include ../../make.tmpl
+include $(top_builddir)/make.tmpl
 
 all: device-mapper
 device-mapper: $(TARGETS)
diff --git a/daemons/dmeventd/plugins/Makefile.in b/daemons/dmeventd/plugins/Makefile.in
index 48ae9e9..6b25235 100644
--- a/daemons/dmeventd/plugins/Makefile.in
+++ b/daemons/dmeventd/plugins/Makefile.in
@@ -19,7 +19,7 @@ VPATH = @srcdir@
 
 SUBDIRS += lvm2 mirror snapshot
 
-include ../../../make.tmpl
+include $(top_builddir)/make.tmpl
 
 mirror: lvm2
 snapshot: lvm2
diff --git a/doc/Makefile.in b/doc/Makefile.in
index b4689af..ce66209 100644
--- a/doc/Makefile.in
+++ b/doc/Makefile.in
@@ -19,7 +19,7 @@ VPATH = @srcdir@
 CONFSRC=example.conf
 CONFDEST=lvm.conf
 
-include ../make.tmpl
+include $(top_builddir)/make.tmpl
 
 install_lvm2: $(CONFSRC)
 	@if [ ! -e $(confdir)/$(CONFDEST) ]; then \
diff --git a/lib/Makefile.in b/lib/Makefile.in
index 6c29a5e..a2e66f3 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -143,7 +143,7 @@ ifeq ("@HAVE_LIBDL@", "yes")
 endif
 
 ifeq ("@DMEVENTD@", "yes")
-  CLDFLAGS += -L../daemons/dmeventd
+  CLDFLAGS += -L$(top_builddir)/daemons/dmeventd
   LIBS += -ldevmapper-event
 endif
 
@@ -152,7 +152,7 @@ LIB_STATIC = $(LIB_NAME).a
 
 CLEAN_TARGETS += $(LIB_NAME).cflow
 
-include ../make.tmpl
+include $(top_builddir)/make.tmpl
 
 $(SUBDIRS): $(LIB_STATIC)
 
diff --git a/lib/format1/Makefile.in b/lib/format1/Makefile.in
index e12cc6f..f62ab7c 100644
--- a/lib/format1/Makefile.in
+++ b/lib/format1/Makefile.in
@@ -29,7 +29,7 @@ SOURCES =\
 LIB_SHARED = liblvm2format1.so
 LIB_VERSION = $(LIB_VERSION_LVM)
 
-include ../../make.tmpl
+include $(top_builddir)/make.tmpl
 
 install: liblvm2format1.so
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
diff --git a/lib/format_pool/Makefile.in b/lib/format_pool/Makefile.in
index d67c982..b0ebc36 100644
--- a/lib/format_pool/Makefile.in
+++ b/lib/format_pool/Makefile.in
@@ -26,7 +26,7 @@ SOURCES =\
 LIB_SHARED = liblvm2formatpool.so
 LIB_VERSION = $(LIB_VERSION_LVM)
 
-include ../../make.tmpl
+include $(top_builddir)/make.tmpl
 
 install: liblvm2formatpool.so
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
diff --git a/lib/locking/Makefile.in b/lib/locking/Makefile.in
index 584c8d6..399b0af 100644
--- a/lib/locking/Makefile.in
+++ b/lib/locking/Makefile.in
@@ -22,7 +22,7 @@ SOURCES = cluster_locking.c
 LIB_SHARED = liblvm2clusterlock.so
 LIB_VERSION = $(LIB_VERSION_LVM)
 
-include ../../make.tmpl
+include $(top_builddir)/make.tmpl
 
 install install_cluster: liblvm2clusterlock.so
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
diff --git a/lib/mirror/Makefile.in b/lib/mirror/Makefile.in
index d5b678b..038399a 100644
--- a/lib/mirror/Makefile.in
+++ b/lib/mirror/Makefile.in
@@ -22,7 +22,7 @@ SOURCES = mirrored.c
 LIB_SHARED = liblvm2mirror.so
 LIB_VERSION = $(LIB_VERSION_LVM)
 
-include ../../make.tmpl
+include $(top_builddir)/make.tmpl
 
 install: liblvm2mirror.so
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
diff --git a/lib/snapshot/Makefile.in b/lib/snapshot/Makefile.in
index 3f960fb..80728c7 100644
--- a/lib/snapshot/Makefile.in
+++ b/lib/snapshot/Makefile.in
@@ -22,7 +22,7 @@ SOURCES = snapshot.c
 LIB_SHARED = liblvm2snapshot.so
 LIB_VERSION = $(LIB_VERSION_LVM)
 
-include ../../make.tmpl
+include $(top_builddir)/make.tmpl
 
 install: liblvm2snapshot.so
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
diff --git a/libdm/Makefile.in b/libdm/Makefile.in
index 6dd25ff..ce3e058 100644
--- a/libdm/Makefile.in
+++ b/libdm/Makefile.in
@@ -50,7 +50,7 @@ LIB_VERSION = $(LIB_VERSION_DM)
 DEFS += -DDM_DEVICE_UID=@DM_DEVICE_UID@ -DDM_DEVICE_GID=@DM_DEVICE_GID@ \
 	-DDM_DEVICE_MODE=@DM_DEVICE_MODE@
 
-include ../make.tmpl
+include $(top_builddir)/make.tmpl
 
 device-mapper: all
 
diff --git a/liblvm/Makefile.in b/liblvm/Makefile.in
index 5e6dfd4..25906e1 100644
--- a/liblvm/Makefile.in
+++ b/liblvm/Makefile.in
@@ -40,7 +40,7 @@ endif
 
 CLEAN_TARGETS += liblvm.cflow
 
-include ../make.tmpl
+include $(top_builddir)/make.tmpl
 
 LIBS += -ldevmapper -llvm-internal
 
diff --git a/man/Makefile.in b/man/Makefile.in
index dfe95e6..f49d4c8 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -48,7 +48,7 @@ MAN8DIR=${mandir}/man8
 
 CLEAN_TARGETS=$(MAN5) $(MAN8) $(MAN8CLUSTER) $(FSADMMAN) $(MAN8DM)
 
-include ../make.tmpl
+include $(top_builddir)/make.tmpl
 
 ifneq ("@CLVMD@", "none")
   install: install_cluster
diff --git a/old-tests/device/Makefile.in b/old-tests/device/Makefile.in
index 4bf15a9..5c9479e 100644
--- a/old-tests/device/Makefile.in
+++ b/old-tests/device/Makefile.in
@@ -22,8 +22,8 @@ SOURCES=\
 
 TARGETS=dev_cache_t
 
-include ../../make.tmpl
+include $(top_builddir)/make.tmpl
 
 dev_cache_t: dev_cache_t.o $(top_srcdir)/lib/liblvm.a
-	$(CC) -o dev_cache_t dev_cache_t.o -L$(top_srcdir)/lib -llvm
+	$(CC) -o dev_cache_t dev_cache_t.o -L$(top_builddir)/lib -llvm
 
diff --git a/old-tests/filters/Makefile.in b/old-tests/filters/Makefile.in
index 01de934..62e13c0 100644
--- a/old-tests/filters/Makefile.in
+++ b/old-tests/filters/Makefile.in
@@ -25,11 +25,11 @@ TARGETS=\
 	rfilter_t \
 	pfilter_t
 
-include ../../make.tmpl
+include $(top_builddir)/make.tmpl
 
 rfilter_t: rfilter_t.o $(top_srcdir)/lib/liblvm.a
-	$(CC) -o rfilter_t rfilter_t.o -L$(top_srcdir)/lib -llvm
+	$(CC) -o rfilter_t rfilter_t.o -L$(top_builddir)/lib -llvm
 
 pfilter_t: pfilter_t.o $(top_srcdir)/lib/liblvm.a
-	$(CC) -o pfilter_t pfilter_t.o -L$(top_srcdir)/lib -llvm
+	$(CC) -o pfilter_t pfilter_t.o -L$(top_builddir)/lib -llvm
 
diff --git a/old-tests/format1/Makefile.in b/old-tests/format1/Makefile.in
index 1ccb56d..b82e065 100644
--- a/old-tests/format1/Makefile.in
+++ b/old-tests/format1/Makefile.in
@@ -32,21 +32,21 @@ TARGETS=\
 	read_pv_t \
 	get_vgs_t
 
-include ../../make.tmpl
+include $(top_builddir)/make.tmpl
 
-read_vg_t: read_vg_t.o pretty_print.o $(top_srcdir)/lib/liblvm.a
-	$(CC) -o read_vg_t read_vg_t.o pretty_print.o -L$(top_srcdir)/lib -llvm
+read_vg_t: read_vg_t.o pretty_print.o $(top_builddir)/lib/liblvm.a
+	$(CC) -o read_vg_t read_vg_t.o pretty_print.o -L$(top_builddir)/lib -llvm
 
-write_vg_t: write_vg_t.o pretty_print.o $(top_srcdir)/lib/liblvm.a
+write_vg_t: write_vg_t.o pretty_print.o $(top_builddir)/lib/liblvm.a
 	$(CC) -o write_vg_t write_vg_t.o pretty_print.o \
-	-L$(top_srcdir)/lib -llvm
+	-L$(top_builddir)/lib -llvm
 
-get_pvs_t: get_pvs_t.o pretty_print.o $(top_srcdir)/lib/liblvm.a
-	$(CC) -o get_pvs_t get_pvs_t.o pretty_print.o -L$(top_srcdir)/lib -llvm
+get_pvs_t: get_pvs_t.o pretty_print.o $(top_builddir)/lib/liblvm.a
+	$(CC) -o get_pvs_t get_pvs_t.o pretty_print.o -L$(top_builddir)/lib -llvm
 
-read_pv_t: read_pv_t.o pretty_print.o $(top_srcdir)/lib/liblvm.a
-	$(CC) -o read_pv_t read_pv_t.o pretty_print.o -L$(top_srcdir)/lib -llvm
+read_pv_t: read_pv_t.o pretty_print.o $(top_builddir)/lib/liblvm.a
+	$(CC) -o read_pv_t read_pv_t.o pretty_print.o -L$(top_builddir)/lib -llvm
 
-get_vgs_t: get_vgs_t.o pretty_print.o $(top_srcdir)/lib/liblvm.a
-	$(CC) -o get_vgs_t get_vgs_t.o pretty_print.o -L$(top_srcdir)/lib -llvm
+get_vgs_t: get_vgs_t.o pretty_print.o $(top_builddir)/lib/liblvm.a
+	$(CC) -o get_vgs_t get_vgs_t.o pretty_print.o -L$(top_builddir)/lib -llvm
 
diff --git a/old-tests/mm/Makefile.in b/old-tests/mm/Makefile.in
index 997f0d3..62c341f 100644
--- a/old-tests/mm/Makefile.in
+++ b/old-tests/mm/Makefile.in
@@ -22,12 +22,12 @@ SOURCES=\
 
 TARGETS=dbg_malloc_t
 
-include ../../make.tmpl
+include $(top_builddir)/make.tmpl
 
 dbg_malloc_t: dbg_malloc_t.o
 	$(CC) $(CFLAGS) -o dbg_malloc_t dbg_malloc_t.o \
-		-L$(top_srcdir)/lib -llvm
+		-L$(top_builddir)/lib -llvm
 
 pool_t: pool_t.o
-	$(CC) $(CFLAGS) -o pool_t pool_t.o -L$(top_srcdir)/lib -llvm
+	$(CC) $(CFLAGS) -o pool_t pool_t.o -L$(top_builddir)/lib -llvm
 
diff --git a/old-tests/regex/Makefile.in b/old-tests/regex/Makefile.in
index 28783ae..7696c48 100644
--- a/old-tests/regex/Makefile.in
+++ b/old-tests/regex/Makefile.in
@@ -25,11 +25,11 @@ TARGETS=\
 	parse_t \
 	matcher_t
 
-include ../../make.tmpl
+include $(top_builddir)/make.tmpl
 
-parse_t: parse_t.o $(top_srcdir)/lib/liblvm.a
-	$(CC) -o parse_t parse_t.o -L$(top_srcdir)/lib -llvm
+parse_t: parse_t.o $(top_builddir)/lib/liblvm.a
+	$(CC) -o parse_t parse_t.o -L$(top_builddir)/lib -llvm
 
-matcher_t: matcher_t.o $(top_srcdir)/lib/liblvm.a
-	$(CC) -o matcher_t matcher_t.o -L$(top_srcdir)/lib -llvm
+matcher_t: matcher_t.o $(top_builddir)/lib/liblvm.a
+	$(CC) -o matcher_t matcher_t.o -L$(top_builddir)/lib -llvm
 
diff --git a/po/Makefile.in b/po/Makefile.in
index c9f8400..22184f1 100644
--- a/po/Makefile.in
+++ b/po/Makefile.in
@@ -25,7 +25,7 @@ DM_POSOURCES = $(top_srcdir)/dmsetup/*.pot $(top_srcdir)/libdm/*.pot \
 
 LVM_POSOURCES = $(top_srcdir)/tools/*.pot $(top_srcdir)/lib/*/*.pot
 
-include ../make.tmpl
+include $(top_builddir)/make.tmpl
 
 lvm2.po: Makefile $(LVM_POSOURCES)
 	@echo Compiling string table
diff --git a/scripts/Makefile.in b/scripts/Makefile.in
index 867f0ee..b79d312 100644
--- a/scripts/Makefile.in
+++ b/scripts/Makefile.in
@@ -16,7 +16,7 @@ top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 VPATH = @srcdir@
 
-include ../make.tmpl
+include $(top_builddir)/make.tmpl
 
 install:
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(srcdir)/lvm_dump.sh \
diff --git a/tools/Makefile.in b/tools/Makefile.in
index b650c67..880ea89 100644
--- a/tools/Makefile.in
+++ b/tools/Makefile.in
@@ -107,7 +107,7 @@ LVMLIBS += -ldevmapper
 
 DEFS += -DLVM_SHARED_PATH=\"$(exec_prefix)/sbin/lvm\"
 
-include ../make.tmpl
+include $(top_builddir)/make.tmpl
 
 device-mapper: $(TARGETS_DM)
 
diff --git a/udev/Makefile.in b/udev/Makefile.in
index 0a0050a..d4006b9 100644
--- a/udev/Makefile.in
+++ b/udev/Makefile.in
@@ -22,7 +22,7 @@ DM_DIR=$(shell grep "\#define DM_DIR" $(top_srcdir)/libdm/misc/dm-ioctl.h | awk
 
 CLEAN_TARGETS=10-dm.rules
 
-include ../make.tmpl
+include $(top_builddir)/make.tmpl
 
 %: %.in
 	$(SED) -e "s/(DM_DIR)/$(DM_DIR)/" $< >$@
-- 
1.7.0


