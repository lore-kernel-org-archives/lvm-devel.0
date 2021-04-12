From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 12 Apr 2021 07:55:34 +0000 (GMT)
Subject: main - makefiles: static linking enhancements
Message-ID: <20210412075534.BE7C839FCC4C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=aee0cd6530c6340f6f0a8256b887c8561f29dde6
Commit:        aee0cd6530c6340f6f0a8256b887c8561f29dde6
Parent:        01f108c4d03f848a84bff74104dd18b21c7a8e3f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 8 19:44:53 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 12 09:54:15 2021 +0200

makefiles: static linking enhancements

---
 Makefile.in                  |  3 +--
 daemons/dmeventd/Makefile.in |  8 ++++----
 daemons/lvmlockd/Makefile.in | 14 ++++++--------
 libdm/Makefile.in            |  6 ++----
 libdm/dm-tools/Makefile.in   | 25 +++++++++++++------------
 libdm/make.tmpl.in           |  6 ++----
 make.tmpl.in                 |  6 ++++--
 test/Makefile.in             |  2 +-
 test/unit/Makefile           |  9 ++++++---
 tools/Makefile.in            | 13 ++++++-------
 10 files changed, 45 insertions(+), 47 deletions(-)

diff --git a/Makefile.in b/Makefile.in
index 69c73598e..5dd642f63 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -18,7 +18,7 @@ top_builddir = @top_builddir@
 abs_top_builddir = @abs_top_builddir@
 abs_top_srcdir = @abs_top_srcdir@
 
-SUBDIRS = conf daemons include lib libdaemon libdm man scripts tools
+SUBDIRS = libdm conf daemons include lib libdaemon man scripts tools
 
 ifeq ("@UDEV_RULES@", "yes")
   SUBDIRS += udev
@@ -56,7 +56,6 @@ tools: lib libdaemon
 po: tools daemons
 man: tools
 all_man: tools
-scripts: libdm
 test: tools daemons
 unit-test  run-unit-test: test
 
diff --git a/daemons/dmeventd/Makefile.in b/daemons/dmeventd/Makefile.in
index d688a0d3b..af51198aa 100644
--- a/daemons/dmeventd/Makefile.in
+++ b/daemons/dmeventd/Makefile.in
@@ -47,6 +47,7 @@ endif
 
 LIB_VERSION = $(LIB_VERSION_DM)
 LIB_SHARED = $(LIB_NAME).$(LIB_SUFFIX)
+LIBS = $(PTHREAD_LIBS) -L$(interfacebuilddir) -ldevmapper
 
 CLEAN_TARGETS = dmeventd.static $(LIB_NAME).a
 
@@ -67,16 +68,15 @@ device-mapper: $(TARGETS)
 plugins.device-mapper: $(LIB_SHARED)
 
 CFLAGS_dmeventd.o += $(EXTRA_EXEC_CFLAGS)
-LIBS += $(PTHREAD_LIBS) -L$(top_builddir)/libdm -ldevmapper
 
 dmeventd: $(LIB_SHARED) dmeventd.o
 	@echo "    [CC] $@"
-	$(Q) $(CC) $(CFLAGS) -L. $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) dmeventd.o \
-		-o $@ $(DL_LIBS) $(DMEVENT_LIBS) $(LIBS) -lm
+	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) dmeventd.o \
+		-o $@ $(DL_LIBS) $(DMEVENT_LIBS) $(LIBS)
 
 dmeventd.static: $(LIB_STATIC) dmeventd.o
 	@echo "    [CC] $@"
-	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) -static -L. -L$(interfacebuilddir) dmeventd.o \
+	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) -static dmeventd.o \
 		-o $@ $(DL_LIBS) $(DMEVENT_LIBS) $(LIBS) $(STATIC_LIBS)
 
 ifeq ("@PKGCONFIG@", "yes")
diff --git a/daemons/lvmlockd/Makefile.in b/daemons/lvmlockd/Makefile.in
index ec5d5750a..e69ab9127 100644
--- a/daemons/lvmlockd/Makefile.in
+++ b/daemons/lvmlockd/Makefile.in
@@ -37,29 +37,27 @@ TARGETS = lvmlockd lvmlockctl
 CFLOW_SOURCES = $(addprefix $(srcdir)/, $(SOURCES))
 CFLOW_TARGET = lvmlockd
 
-.PHONY: install_lvmlockd
+.PHONY: install_lvmlockd install_lvmlockctl
 
 include $(top_builddir)/make.tmpl
 
 CFLAGS += $(EXTRA_EXEC_CFLAGS)
 INCLUDES += -I$(top_srcdir)/libdaemon/server
 LDFLAGS += -L$(top_builddir)/libdaemon/server $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS)
-LIBS += $(RT_LIBS) $(DAEMON_LIBS) $(PTHREAD_LIBS)
-
+LIBS += $(DAEMON_LIBS) $(PTHREAD_LIBS)
 
 ifeq ($(USE_SD_NOTIFY),yes)
 	CFLAGS += $(shell pkg-config --cflags libsystemd) -DUSE_SD_NOTIFY
 	LIBS += $(shell pkg-config --libs libsystemd)
 endif
 
-lvmlockd: $(OBJECTS) $(top_builddir)/libdaemon/client/libdaemonclient.a \
-		    $(top_builddir)/libdaemon/server/libdaemonserver.a
+lvmlockd: $(OBJECTS) $(top_builddir)/libdaemon/server/libdaemonserver.a $(INTERNAL_LIBS)
 	@echo "    [CC] $@"
-	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJECTS) $(LOCK_LIBS) -ldaemonserver $(INTERNAL_LIBS) $(LIBS)
+	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) -o $@ $+ $(LOCK_LIBS) $(LIBS)
 
-lvmlockctl: lvmlockctl.o $(top_builddir)/libdaemon/client/libdaemonclient.a
+lvmlockctl: lvmlockctl.o $(INTERNAL_LIBS)
 	@echo "    [CC] $@"
-	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) -o $@ $< $(INTERNAL_LIBS) $(LIBS)
+	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) -o $@ $+ $(LIBS)
 
 install_lvmlockd: lvmlockd
 	@echo "    [INSTALL] $<"
diff --git a/libdm/Makefile.in b/libdm/Makefile.in
index a78d2b517..35115d7f0 100644
--- a/libdm/Makefile.in
+++ b/libdm/Makefile.in
@@ -59,11 +59,9 @@ include $(top_builddir)/libdm/make.tmpl
 
 PROGS_CFLAGS = $(UDEV_CFLAGS)
 
-LIBS += $(SELINUX_LIBS) $(UDEV_LIBS) $(PTHREAD_LIBS) $(RT_LIBS) $(M_LIBS)
+device-mapper: $(TARGETS)
 
-device-mapper: all
-
-dm-tools.device-mapper: $(TARGETS)
+dm-tools.device-mapper: device-mapper
 
 libdevmapper.$(LIB_SUFFIX) libdevmapper.$(LIB_SUFFIX).$(LIB_VERSION): $(LIB_SHARED)
 	@echo "    [LN] $<"
diff --git a/libdm/dm-tools/Makefile.in b/libdm/dm-tools/Makefile.in
index 8fbdfc152..9ddb3c261 100644
--- a/libdm/dm-tools/Makefile.in
+++ b/libdm/dm-tools/Makefile.in
@@ -52,18 +52,19 @@ include $(top_builddir)/libdm/make.tmpl
 
 CFLAGS_dmsetup.o += $(UDEV_CFLAGS) $(EXTRA_EXEC_CFLAGS)
 CFLAGS_dmfilemapd.o += $(EXTRA_EXEC_CFLAGS)
-LDFLAGS += -L$(interfacebuilddir)
-DMLIBS = -ldevmapper
+LIBDM_LIBS = -L$(interfacebuilddir) -ldevmapper
+LIBDM_SHARED = $(interfacebuilddir)/libdevmapper.so
+LIBDM_STATIC = $(interfacebuilddir)/libdevmapper.a
 
-dmsetup: dmsetup.o
+dmsetup: dmsetup.o $(LIBDM_SHARED)
 	@echo "    [CC] $@"
 	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) \
-	      -o $@ $+ $(DMLIBS)
+	      -o $@ $< $(LIBDM_LIBS) $(LIBS)
 
-dmsetup.static: dmsetup.o
+dmsetup.static: dmsetup.o $(LIBDM_STATIC)
 	@echo "    [CC] $@"
 	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) -static \
-	      -o $@ $+ $(DMLIBS) $(STATIC_LIBS)
+	      -o $@ $< $(LIBDM_LIBS) $(LIBS) $(STATIC_LIBS)
 
 install_dmsetup_dynamic: dmsetup
 	@echo "    [INSTALL] $<"
@@ -73,18 +74,18 @@ install_dmsetup_dynamic: dmsetup
 install_dmsetup_static: dmsetup.static
 	@echo "    [INSTALL] $<"
 	$(Q) $(INSTALL_PROGRAM) -D $< $(staticdir)/$(<F)
-	$(Q) $(LN_S) -f $(<F) $(staticdir)/dmstats
+	$(Q) $(LN_S) -f $(<F) $(staticdir)/dmstats.static
 
 
-dmfilemapd: dmfilemapd.o $(LIB_SHARED)
+dmfilemapd: dmfilemapd.o $(LIBDM_SHARED)
 	@echo "    [CC] $@"
 	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) \
-	      -o $@ $+ $(DMLIBS)
+	      -o $@ $< $(LIBDM_LIBS) $(LIBS)
 
-dmfilemapd.static: dmfilemapd.o $(LIB_STATIC)
+dmfilemapd.static: dmfilemapd.o $(LIBDM_STATIC)
 	@echo "    [CC] $@"
-	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) $(ELDFLAGS) -static \
-	      -o $@ $+ $(DMLIBS) $(STATIC_LIBS)
+	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) -static \
+	      -o $@ $< $(LIBDM_LIBS) $(LIBS) $(STATIC_LIBS)
 
 install_dmfilemapd_dynamic: dmfilemapd
 	@echo "    [INSTALL] $<"
diff --git a/libdm/make.tmpl.in b/libdm/make.tmpl.in
index 9ef39fc0a..f7a5a7a73 100644
--- a/libdm/make.tmpl.in
+++ b/libdm/make.tmpl.in
@@ -53,11 +53,9 @@ WC = @WC@
 AR = @AR@
 RM = rm -f
 
-
-LIBS = @LIBS@
-LIBS += $(SELINUX_LIBS) $(UDEV_LIBS) $(BLKID_LIBS) $(RT_LIBS) -lm
+LIBS += @LIBS@ $(PTHREAD_LIBS) $(SELINUX_LIBS) $(UDEV_LIBS) $(RT_LIBS) $(M_LIBS)
 # Extra libraries always linked with static binaries
-STATIC_LIBS = $(SELINUX_LIBS) $(UDEV_LIBS) $(BLKID_LIBS)
+STATIC_LIBS = $(PTHREAD_LIBS)
 DEFS += @DEFS@
 # FIXME set this only where it's needed, not globally?
 CFLAGS ?= @COPTIMISE_FLAG@ @CFLAGS@
diff --git a/make.tmpl.in b/make.tmpl.in
index b28ef6f8f..14557c4c4 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -61,9 +61,10 @@ PYTHON2 = @PYTHON2@
 PYTHON3 = @PYTHON3@
 PYCOMPILE = $(top_srcdir)/autoconf/py-compile
 
-LIBS += @LIBS@ $(SELINUX_LIBS) $(UDEV_LIBS) $(BLKID_LIBS) $(RT_LIBS) $(M_LIBS)
+LIBS += @LIBS@ $(SELINUX_LIBS) $(UDEV_LIBS) $(RT_LIBS) $(M_LIBS)
+LVMLIBS = $(DMEVENT_LIBS) $(READLINE_LIBS) $(EDITLINE_LIBS) $(SYSTEMD_LIBS) $(BLKID_LIBS) $(AIO_LIBS) $(LIBS)
 # Extra libraries always linked with static binaries
-STATIC_LIBS = $(SELINUX_LIBS) $(UDEV_LIBS) $(BLKID_LIBS)
+STATIC_LIBS = $(PTHREAD_LIBS)
 DEFS += @DEFS@
 # FIXME set this only where it's needed, not globally?
 CFLAGS ?= @COPTIMISE_FLAG@ @CFLAGS@
@@ -146,6 +147,7 @@ vpath %.po $(srcdir)
 vpath %.exported_symbols $(srcdir)
 
 interface = @interface@
+interfacebuilddir = $(top_builddir)/libdm/$(interface)
 rpmbuilddir = $(abs_top_builddir)/build
 
 # The number of jobs to run, if blank, defaults to the make standard
diff --git a/test/Makefile.in b/test/Makefile.in
index 41ddb9d8e..e4cd3aac5 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -258,7 +258,7 @@ lib/dmsecuretest: lib/dmsecuretest.o .lib-dir-stamp $(INTERNAL_LIBS)
 
 lib/securetest: lib/dmsecuretest.o .lib-dir-stamp
 	@echo "    [CC] $@"
-	$(Q) $(CC) -g $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) -o $@ $< -L$(top_builddir)/libdm/ioctl -ldevmapper $(LIBS)
+	$(Q) $(CC) -g $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) -o $@ $< -L$(interfacebuilddir) -ldevmapper $(LIBS)
 
 lib/runner.o: $(wildcard $(srcdir)/lib/*.h)
 
diff --git a/test/unit/Makefile b/test/unit/Makefile
index 7bc711719..455c18d2a 100644
--- a/test/unit/Makefile
+++ b/test/unit/Makefile
@@ -42,16 +42,19 @@ CLEAN_TARGETS += $(UNIT_DEPENDS) $(UNIT_OBJECTS) \
 	$(UNIT_SOURCE:%.c=%.gcno) \
 	$(UNIT_TARGET)
 
+lib/liblvm-internal.a: lib
+libdaemon/client/libdaemonclient.a: libdaemon
+
 $(UNIT_TARGET): $(UNIT_OBJECTS) $(LVMINTERNAL_LIBS)
 	@echo "    [LD] $@"
 	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) \
-	      -o $@ $+ $(DMEVENT_LIBS) $(SYSTEMD_LIBS) -L$(top_builddir)/libdm -ldevmapper $(LIBS) -laio
+	      -o $@ $+ $(LVMLIBS)
 
-.PHONEY: run-unit-test unit-test
+.PHONY: run-unit-test unit-test
 unit-test: $(UNIT_TARGET)
 run-unit-test: $(UNIT_TARGET)
 	@echo "Running unit tests"
-	LD_LIBRARY_PATH=libdm $(UNIT_TARGET) run
+	LD_LIBRARY_PATH=$(top_builddir)/libdm $(UNIT_TARGET) run
 
 ifeq ("$(DEPENDS)","yes")
 -include $(UNIT_SOURCE:%.c=%.d)
diff --git a/tools/Makefile.in b/tools/Makefile.in
index e871fbddd..ec546ca63 100644
--- a/tools/Makefile.in
+++ b/tools/Makefile.in
@@ -83,7 +83,7 @@ TARGETS =\
 
 INSTALL_LVM_TARGETS = install_tools_dynamic
 INSTALL_DMSETUP_TARGETS =
-INSTALL_CMDLIB_TARGETS = install_cmdlib_dynamic install_cmdlib_include 
+INSTALL_CMDLIB_TARGETS = install_cmdlib_dynamic install_cmdlib_include
 
 ifeq ("@STATIC_LINK@", "yes")
   TARGETS += lvm.static
@@ -91,7 +91,6 @@ ifeq ("@STATIC_LINK@", "yes")
   INSTALL_CMDLIB_TARGETS += install_cmdlib_static
 endif
 
-LVMLIBS = $(SYSTEMD_LIBS) -L$(top_builddir)/libdm -ldevmapper $(LIBS) -laio
 LIB_VERSION = $(LIB_VERSION_LVM)
 INCLUDES = -I$(top_builddir)/tools
 
@@ -123,8 +122,8 @@ CFLAGS_lvm.o += $(EXTRA_EXEC_CFLAGS)
 
 lvm: $(OBJECTS) lvm.o $(LVMINTERNAL_LIBS)
 	@echo "    [CC] $@"
-	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) -o $@ $+ \
-		$(DMEVENT_LIBS) $(READLINE_LIBS) $(EDITLINE_LIBS) $(LVMLIBS)
+	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) \
+		-o $@ $+ $(LVMLIBS)
 
 DEFS_man-generator.o += -DMAN_PAGE_GENERATOR
 
@@ -138,8 +137,8 @@ man-generator: man-generator.o
 
 lvm.static: $(OBJECTS) lvm-static.o $(LVMINTERNAL_LIBS)
 	@echo "    [CC] $@"
-	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) -static -L$(interfacebuilddir) -o $@ $+ \
-	      $(DMEVENT_LIBS) $(STATIC_LIBS) $(LVMLIBS)
+	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) -static -L$(interfacebuilddir) \
+		-o $@ $+ $(LVMLIBS) $(STATIC_LIBS)
 
 liblvm2cmd.a: $(top_builddir)/lib/liblvm-internal.a $(OBJECTS) lvmcmdlib.o lvm2cmd.o
 	@echo "    [AR] $@"
@@ -156,7 +155,7 @@ liblvm2cmd.$(LIB_SUFFIX): liblvm2cmd.a $(LDDEPS)
 	$(Q) $(CC) -shared -Wl,-soname,$@.$(LIB_VERSION) \
 		$(CFLAGS) $(CLDFLAGS) -o $@ \
 		@CLDWHOLEARCHIVE@ $< @CLDNOWHOLEARCHIVE@ \
-		$(LVMINTERNAL_LIBS) $(LVMLIBS)
+		$(INTERNAL_LIBS) $(LVMLIBS)
 
 liblvm2cmd.$(LIB_SUFFIX).$(LIB_VERSION): liblvm2cmd.$(LIB_SUFFIX)
 	@echo "    [LN] $@"


