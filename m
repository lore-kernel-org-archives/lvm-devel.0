From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 17 Dec 2018 05:08:56 -0500
Subject: master - makefiles: correcting login of makefile
Message-ID: <201812171008.wBHA8uw4024861@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=94237354ddbf2abc0f04e7f06ee3c1263dfc6b6e
Commit:        94237354ddbf2abc0f04e7f06ee3c1263dfc6b6e
Parent:        0dc7abe013729b3b3560b67fcc37f3cc619f323d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Dec 15 01:55:11 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Dec 17 10:55:20 2018 +0100

makefiles: correcting login of makefile

Fixing some ordering issue with inclusion of common make.tmpl.
Correcting dependency calculation
Simplifying inclusive makefile
---
 Makefile.in            |   15 ++++++++-------
 base/Makefile          |   21 ++++++++-------------
 device_mapper/Makefile |   21 ++++++++-------------
 libdm/Makefile.in      |    2 +-
 make.tmpl.in           |   26 ++++++++++----------------
 scripts/Makefile.in    |    4 ++--
 test/unit/Makefile     |   25 +++++++++++++------------
 tools/Makefile.in      |   15 ++++++++-------
 8 files changed, 58 insertions(+), 71 deletions(-)

diff --git a/Makefile.in b/Makefile.in
index e64836f..a5eb004 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -43,16 +43,22 @@ DISTCLEAN_TARGETS += config.cache config.log config.status make.tmpl
 
 include make.tmpl
 
+include $(top_srcdir)/base/Makefile
+include $(top_srcdir)/device_mapper/Makefile
+include $(top_srcdir)/test/unit/Makefile
+
 libdm: include
 libdaemon: include
-lib: libdm libdaemon
+lib: libdaemon $(BASE_TARGET) $(DEVICE_MAPPER_TARGET)
 daemons: lib libdaemon tools
-tools: lib libdaemon device-mapper
+scripts: lib
+tools: lib libdaemon
 po: tools daemons
 man: tools
 all_man: tools
 scripts: libdm
 test: tools daemons
+unit-test  run-unit-test: test
 
 lib.device-mapper: include.device-mapper
 libdm.device-mapper: include.device-mapper
@@ -174,11 +180,6 @@ endif
 
 endif
 
-# FIXME: Drop once top-level make is resolved
--include $(top_srcdir)/test/unit/Makefile
-include $(top_srcdir)/device_mapper/Makefile
-include $(top_srcdir)/base/Makefile
-
 ifneq ($(shell which ctags 2>/dev/null),)
 .PHONY: tags
 tags:
diff --git a/base/Makefile b/base/Makefile
index 6050c3a..9f8bccc 100644
--- a/base/Makefile
+++ b/base/Makefile
@@ -14,7 +14,7 @@
 # Comment to build the advanced radix tree.
 #base/data-struct/radix-tree.o: CFLAGS += -DSIMPLE_RADIX_TREE
 
-# NOTE: this include only works as 'include' for toplevel Makefile
+# NOTE: this Makefile only works as 'include' for toplevel Makefile
 #       which defined all top_* variables
 
 BASE_SOURCE=\
@@ -22,24 +22,19 @@ BASE_SOURCE=\
 	base/data-struct/list.c \
 	base/data-struct/radix-tree.c
 
+BASE_TARGET = base/libbase.a
 BASE_DEPENDS = $(BASE_SOURCE:%.c=%.d)
 BASE_OBJECTS = $(BASE_SOURCE:%.c=%.o)
 CLEAN_TARGETS += $(BASE_DEPENDS) $(BASE_OBJECTS) \
 	$(BASE_SOURCE:%.c=%.gcda) \
-	$(BASE_SOURCE:%.c=%.gcno)
+	$(BASE_SOURCE:%.c=%.gcno) \
+	$(BASE_TARGET)
 
-ifeq ("$(USE_TRACKING)","yes")
-ifeq (,$(findstring $(MAKECMDGOALS),cscope.out cflow clean distclean lcov lcov-reset \
- help check check_local check_cluster check_lvmetad check_lvmpolld))
-	-include $(BASE_DEPENDS)
-endif
-endif
-
-$(BASE_OBJECTS): INCLUDES+=-I$(top_srcdir)/base/
-
-base/libbase.a: $(BASE_OBJECTS)
+$(BASE_TARGET): $(BASE_OBJECTS)
 	@echo "    [AR] $@"
 	$(Q) $(RM) $@
 	$(Q) $(AR) rsv $@ $(BASE_OBJECTS) > /dev/null
 
-CLEAN_TARGETS += base/libbase.a
+ifeq ("$(DEPENDS)","yes")
+-include $(BASE_DEPENDS)
+endif
diff --git a/device_mapper/Makefile b/device_mapper/Makefile
index fd2189a..d3b791e 100644
--- a/device_mapper/Makefile
+++ b/device_mapper/Makefile
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-# NOTE: this include only works as 'include' for toplevel Makefile
+# NOTE: this Makefile only works as 'include' for toplevel Makefile
 #       which defined all top_* variables
 
 DEVICE_MAPPER_SOURCE=\
@@ -31,27 +31,22 @@ DEVICE_MAPPER_SOURCE=\
 	device_mapper/vdo/status.c \
 	device_mapper/vdo/vdo_target.c
 
+DEVICE_MAPPER_TARGET = device_mapper/libdevice-mapper.a
 DEVICE_MAPPER_DEPENDS = $(DEVICE_MAPPER_SOURCE:%.c=%.d)
 DEVICE_MAPPER_OBJECTS = $(DEVICE_MAPPER_SOURCE:%.c=%.o)
 CLEAN_TARGETS += $(DEVICE_MAPPER_DEPENDS) $(DEVICE_MAPPER_OBJECTS) \
 	$(DEVICE_MAPPER_SOURCE:%.c=%.gcda) \
-	$(DEVICE_MAPPER_SOURCE:%.c=%.gcno)
+	$(DEVICE_MAPPER_SOURCE:%.c=%.gcno) \
+	$(DEVICE_MAPPER_TARGET)
 
 #$(DEVICE_MAPPER_DEPENDS): INCLUDES+=$(VDO_INCLUDES)
 #$(DEVICE_MAPPER_OBJECTS): INCLUDES+=$(VDO_INCLUDES)
 
-ifeq ("$(USE_TRACKING)","yes")
-ifeq (,$(findstring $(MAKECMDGOALS),cscope.out cflow clean distclean lcov lcov-reset \
- help check check_local check_cluster check_lvmetad check_lvmpolld))
-	-include $(DEVICE_MAPPER_DEPENDS)
-endif
-endif
-
-$(DEVICE_MAPPER_OBJECTS): INCLUDES+=-I$(top_srcdir)/device_mapper/
-
-device_mapper/libdevice-mapper.a: $(DEVICE_MAPPER_OBJECTS)
+$(DEVICE_MAPPER_TARGET): $(DEVICE_MAPPER_OBJECTS)
 	@echo "    [AR] $@"
 	$(Q) $(RM) $@
 	$(Q) $(AR) rsv $@ $(DEVICE_MAPPER_OBJECTS) > /dev/null
 
-CLEAN_TARGETS += device_mapper/libdevice-mapper.a
+ifeq ("$(DEPENDS)","yes")
+-include $(DEVICE_MAPPER_DEPENDS)
+endif
diff --git a/libdm/Makefile.in b/libdm/Makefile.in
index 4ea83d0..e9bb5ae 100644
--- a/libdm/Makefile.in
+++ b/libdm/Makefile.in
@@ -58,7 +58,7 @@ include $(top_builddir)/libdm/make.tmpl
 
 PROGS_CFLAGS = $(UDEV_CFLAGS)
 
-LIBS += $(RT_LIBS) $(SELINUX_LIBS) $(UDEV_LIBS) $(PTHREAD_LIBS) $(M_LIBS)
+LIBS += $(SELINUX_LIBS) $(UDEV_LIBS) $(PTHREAD_LIBS) $(RT_LIBS) $(M_LIBS)
 
 device-mapper: all
 
diff --git a/make.tmpl.in b/make.tmpl.in
index d7b6568..9158f0e 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -72,9 +72,6 @@ CLDFLAGS += @CLDFLAGS@
 ELDFLAGS += @ELDFLAGS@
 LDDEPS += @LDDEPS@
 LIB_SUFFIX = @LIB_SUFFIX@
-LVMINTERNAL_LIBS=\
-	-llvm-internal \
-	$(DAEMON_LIBS) $(DMEVENT_LIBS) $(SYSTEMD_LIBS) $(UDEV_LIBS) $(BLKID_LIBS)
 DL_LIBS = @DL_LIBS@
 RT_LIBS = @RT_LIBS@
 M_LIBS = @M_LIBS@
@@ -266,13 +263,6 @@ endif
 # end of fPIC protection
 endif
 
-LDFLAGS += -L$(top_builddir)/lib
-CLDFLAGS += -L$(top_builddir)/lib
-
-DAEMON_LIBS = -ldaemonclient
-LDFLAGS += -L$(top_builddir)/libdaemon/client
-CLDFLAGS += -L$(top_builddir)/libdaemon/client
-
 ifeq ("@BUILD_DMEVENTD@", "yes")
   DMEVENT_LIBS = -ldevmapper-event
   LDFLAGS += -L$(top_builddir)/daemons/dmeventd
@@ -338,11 +328,13 @@ SUBDIRS.distclean := $(SUBDIRS:=.distclean)
 
 TARGETS += $(LIB_SHARED) $(LIB_STATIC)
 
-INTERNAL_LIBS=\
+INTERNAL_LIBS = \
+	$(top_builddir)/libdaemon/client/libdaemonclient.a \
 	$(top_builddir)/device_mapper/libdevice-mapper.a \
 	$(top_builddir)/base/libbase.a
-	
-all: $(INTERNAL_LIBS) $(SUBDIRS) $(TARGETS)
+LVMINTERNAL_LIBS = $(top_builddir)/lib/liblvm-internal.a $(INTERNAL_LIBS)
+
+all: $(SUBDIRS) $(TARGETS)
 
 install: all $(SUBDIRS.install)
 install_cluster: all $(SUBDIRS.install_cluster)
@@ -351,7 +343,7 @@ install_lvm2: $(SUBDIRS.install_lvm2)
 install_ocf: $(SUBDIRS.install_ocf)
 cflow: $(SUBDIRS.cflow)
 
-$(SUBDIRS): $(SUBDIRS.device-mapper) $(INTERNAL_LIBS)
+$(SUBDIRS): $(SUBDIRS.device-mapper)
 	$(MAKE) -C $@
 
 $(SUBDIRS.device-mapper):
@@ -577,13 +569,15 @@ else
 endif
 
 ifeq ("$(USE_TRACKING)","yes")
-ifeq (,$(findstring $(MAKECMDGOALS),cscope.out cflow clean distclean lcov \
- help check check_local check_cluster check_lvmpolld))
+ifeq (,$(findstring $(MAKECMDGOALS),cscope.out cflow clean distclean lcov lcov-reset \
+ help check check_local check_cluster check_lvmpolld run-unit-test tags))
+# Note: no tabs before -include
     ifdef SOURCES
        -include $(SOURCES:.c=.d) $(CXXSOURCES:.cpp=.d)
     endif
     ifdef SOURCES2
        -include $(SOURCES2:.c=.d)
     endif
+    DEPENDS = yes
 endif
 endif
diff --git a/scripts/Makefile.in b/scripts/Makefile.in
index ffca04a..e384397 100644
--- a/scripts/Makefile.in
+++ b/scripts/Makefile.in
@@ -76,9 +76,9 @@ endif
 
 CFLAGS_lvm2_activation_generator_systemd_red_hat.o += $(EXTRA_EXEC_CFLAGS)
 
-lvm2_activation_generator_systemd_red_hat: $(OBJECTS) $(DEPLIBS) $(INTERNAL_LIBS)
+lvm2_activation_generator_systemd_red_hat: $(OBJECTS) $(LVMINTERNAL_LIBS)
 	@echo "    [CC] $@"
-	$(Q) $(CC) -o $@ $(OBJECTS) $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) $(LVMLIBS) $(INTERNAL_LIBS) $(LIBS)
+	$(Q) $(CC) -o $@ $(OBJECTS) $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) $(LVMINTERNAL_LIBS) $(LIBS)
 
 install_systemd_generators:
 	@echo "    [INSTALL] $<"
diff --git a/test/unit/Makefile b/test/unit/Makefile
index 5b71e1b..0ff128d 100644
--- a/test/unit/Makefile
+++ b/test/unit/Makefile
@@ -10,6 +10,9 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+# NOTE: this Makefile only works as 'include' for toplevel Makefile
+#       which defined all top_* variables
+
 UNIT_SOURCE=\
 	device_mapper/vdo/status.c \
 	\
@@ -31,27 +34,25 @@ UNIT_SOURCE=\
 
 test/unit/radix_tree_t.o: test/unit/rt_case1.c
 
+UNIT_TARGET = test/unit/unit-test
 UNIT_DEPENDS = $(UNIT_SOURCE:%.c=%.d)
 UNIT_OBJECTS = $(UNIT_SOURCE:%.c=%.o)
 CLEAN_TARGETS += $(UNIT_DEPENDS) $(UNIT_OBJECTS) \
 	$(UNIT_SOURCE:%.c=%.gcda) \
 	$(UNIT_SOURCE:%.c=%.gcno) \
-	test/unit/unit-test
+	$(UNIT_TARGET)
 
-test/unit/unit-test: $(UNIT_OBJECTS) lib/liblvm-internal.a libdaemon/client/libdaemonclient.a $(INTERNAL_LIBS)
+$(UNIT_TARGET): $(UNIT_OBJECTS) $(LVMINTERNAL_LIBS)
 	@echo "    [LD] $@"
 	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) \
-	      -o $@ $+ $(DMEVENT_LIBS) $(SYSTEMD_LIBS) $(LIBS) -laio
+	      -o $@ $+ $(DMEVENT_LIBS) $(LIBS) -laio
 
 .PHONEY: run-unit-test unit-test
-unit-test: test/unit/unit-test
-run-unit-test: test/unit/unit-test
-	@echo Running unit tests
-	LD_LIBRARY_PATH=libdm test/unit/unit-test run
+unit-test: $(UNIT_TARGET)
+run-unit-test: $(UNIT_TARGET)
+	@echo "Running unit tests"
+	LD_LIBRARY_PATH=libdm $(UNIT_TARGET) run
 
-ifeq ("$(USE_TRACKING)","yes")
-ifeq (,$(findstring $(MAKECMDGOALS),cscope.out cflow clean distclean lcov lcov-reset \
- help check check_local check_lvmpolld run-unit-test))
-	-include $(UNIT_DEPENDS)
-endif
+ifeq ("$(DEPENDS)","yes")
+-include $(UNIT_SOURCE:%.c=%.d)
 endif
diff --git a/tools/Makefile.in b/tools/Makefile.in
index 09768ed..b45798e 100644
--- a/tools/Makefile.in
+++ b/tools/Makefile.in
@@ -89,8 +89,9 @@ ifeq ("@STATIC_LINK@", "yes")
   INSTALL_CMDLIB_TARGETS += install_cmdlib_static
 endif
 
-LVMLIBS = $(LVMINTERNAL_LIBS) -laio
+LVMLIBS = $(LIBS) -laio
 LIB_VERSION = $(LIB_VERSION_LVM)
+INCLUDES = -I$(top_builddir)/tools
 
 CLEAN_TARGETS = liblvm2cmd.$(LIB_SUFFIX) $(TARGETS_DM) \
 	liblvm2cmd.$(LIB_SUFFIX).$(LIB_VERSION) lvm-static.o \
@@ -118,10 +119,10 @@ all: device-mapper
 
 CFLAGS_lvm.o += $(EXTRA_EXEC_CFLAGS)
 
-lvm: $(OBJECTS) lvm.o $(top_builddir)/lib/liblvm-internal.a $(INTERNAL_LIBS)
+lvm: $(OBJECTS) lvm.o $(LVMINTERNAL_LIBS)
 	@echo "    [CC] $@"
 	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) -o $@ $+ \
-		$(LVMLIBS) $(READLINE_LIBS) $(LIBS) -lm
+		$(DMEVENT_LIBS) $(READLINE_LIBS) $(LVMLIBS)
 
 DEFS_man-generator.o += -DMAN_PAGE_GENERATOR
 
@@ -133,10 +134,10 @@ man-generator: man-generator.o
 	@echo "    [CC] $@"
 	$(Q) $(CC) $(CFLAGS) -o $@ $<
 
-lvm.static: $(OBJECTS) lvm-static.o $(top_builddir)/lib/liblvm-internal.a $(INTERNAL_LIBS)
+lvm.static: $(OBJECTS) lvm-static.o $(LVMINTERNAL_LIBS)
 	@echo "    [CC] $@"
-	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) -static -L$(interfacebuilddir) -o $@ \
-	      $(OBJECTS) lvm-static.o $(LVMLIBS) $(STATIC_LIBS) $(LIBS)
+	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) -static -L$(interfacebuilddir) -o $@ $+ \
+	      $(DMEVENT_LIBS) $(STATIC_LIBS) $(LVMLIBS)
 
 liblvm2cmd.a: $(top_builddir)/lib/liblvm-internal.a $(OBJECTS) lvmcmdlib.o lvm2cmd.o
 	@echo "    [AR] $@"
@@ -153,7 +154,7 @@ liblvm2cmd.$(LIB_SUFFIX): liblvm2cmd.a $(LDDEPS)
 	$(Q) $(CC) -shared -Wl,-soname,$@.$(LIB_VERSION) \
 		$(CFLAGS) $(CLDFLAGS) -o $@ \
 		@CLDWHOLEARCHIVE@ liblvm2cmd.a @CLDNOWHOLEARCHIVE@ \
-		$(LVMLIBS) $(INTERNAL_LIBS) $(LIBS)
+		$(LVMINTERNAL_LIBS) $(LVMLIBS)
 
 liblvm2cmd.$(LIB_SUFFIX).$(LIB_VERSION): liblvm2cmd.$(LIB_SUFFIX)
 	@echo "    [LN] $@"


