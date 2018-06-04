From: Joe Thornber <thornber@sourceware.org>
Date: Mon, 4 Jun 2018 08:56:23 -0400
Subject: master - build: libbase.a
Message-ID: <201806041256.w54CuNJD024645@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=232918fb86e1ee254ae5e4c9aece4615d828c9bb
Commit:        232918fb86e1ee254ae5e4c9aece4615d828c9bb
Parent:        29abba378520a270c3a9385724c8ef5df66497b1
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Mon Jun 4 13:53:07 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Mon Jun 4 13:53:07 2018 +0100

build: libbase.a

---
 Makefile.in                  |    1 +
 daemons/clvmd/Makefile.in    |    2 +-
 daemons/dmeventd/Makefile.in |    2 +-
 daemons/lvmetad/Makefile.in  |    8 ++++----
 daemons/lvmlockd/Makefile.in |    6 ++----
 daemons/lvmpolld/Makefile.in |    3 +--
 lib/Makefile.in              |    1 -
 libdm/make.tmpl.in           |    4 ++--
 make.tmpl.in                 |    8 ++++++--
 scripts/Makefile.in          |    4 ++--
 test/api/Makefile.in         |    3 +--
 test/unit/Makefile.in        |    2 +-
 tools/Makefile.in            |    8 ++++----
 13 files changed, 26 insertions(+), 26 deletions(-)

diff --git a/Makefile.in b/Makefile.in
index 851447e..7eb6460 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -214,6 +214,7 @@ endif
 
 include test/unit/Makefile
 include $(top_srcdir)/device_mapper/Makefile
+include $(top_srcdir)/base/Makefile
 
 ifneq ($(shell which ctags),)
 .PHONY: tags
diff --git a/daemons/clvmd/Makefile.in b/daemons/clvmd/Makefile.in
index 9e096b5..622a603 100644
--- a/daemons/clvmd/Makefile.in
+++ b/daemons/clvmd/Makefile.in
@@ -80,7 +80,7 @@ CFLAGS += -fno-strict-aliasing $(EXTRA_EXEC_CFLAGS)
 INSTALL_TARGETS = \
 	install_clvmd
 
-clvmd: $(OBJECTS) $(top_builddir)/lib/liblvm-internal.a $(top_builddir)/device_mapper/libdevice-mapper.a
+clvmd: $(OBJECTS) $(top_builddir)/lib/liblvm-internal.a $(INTERNAL_LIBS)
 	$(CC) $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) \
 	      -o clvmd $+ $(LMLIBS) $(LIBS)
 
diff --git a/daemons/dmeventd/Makefile.in b/daemons/dmeventd/Makefile.in
index e43bb2b..56a9e35 100644
--- a/daemons/dmeventd/Makefile.in
+++ b/daemons/dmeventd/Makefile.in
@@ -61,7 +61,7 @@ LIBS += $(PTHREAD_LIBS)
 
 dmeventd: $(LIB_SHARED) dmeventd.o
 	$(CC) $(CFLAGS) -L. $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) dmeventd.o \
-		-o $@ $(DL_LIBS) $(DMEVENT_LIBS) $(top_builddir)/device_mapper/libdevice-mapper.a $(LIBS) -lm
+		-o $@ $(DL_LIBS) $(DMEVENT_LIBS) $(INTERNAL_LIBS) $(LIBS) -lm
 
 dmeventd.static: $(LIB_STATIC) dmeventd.o
 	$(CC) $(CFLAGS) $(LDFLAGS) -static -L. -L$(interfacebuilddir) dmeventd.o \
diff --git a/daemons/lvmetad/Makefile.in b/daemons/lvmetad/Makefile.in
index f652db8..5738bbe 100644
--- a/daemons/lvmetad/Makefile.in
+++ b/daemons/lvmetad/Makefile.in
@@ -36,13 +36,13 @@ LIBS += $(RT_LIBS) $(DAEMON_LIBS) $(PTHREAD_LIBS) -lm
 
 lvmetad: $(OBJECTS) $(top_builddir)/libdaemon/client/libdaemonclient.a \
 		    $(top_builddir)/libdaemon/server/libdaemonserver.a \
-		    $(top_builddir)/device_mapper/libdevice-mapper.a
-	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJECTS) $(top_builddir)/device_mapper/libdevice-mapper.a -ldaemonserver $(LIBS)
+		    $(INTERNAL_LIBS)
+	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJECTS) -ldaemonserver $(INTERNAL_LIBS) $(LIBS)
 
 lvmetactl: lvmetactl.o $(top_builddir)/libdaemon/client/libdaemonclient.a \
 	$(top_builddir)/libdaemon/server/libdaemonserver.a \
-	$(top_builddir)/device_mapper/libdevice-mapper.a
-	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ lvmetactl.o $(top_builddir)/device_mapper/libdevice-mapper.a $(LIBS)
+	$(INTERNAL_LIBS)
+	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ lvmetactl.o $(INTERNAL_LIBS) $(LIBS)
 
 CLEAN_TARGETS += lvmetactl.o
 
diff --git a/daemons/lvmlockd/Makefile.in b/daemons/lvmlockd/Makefile.in
index 7c58fe2..6dcc207 100644
--- a/daemons/lvmlockd/Makefile.in
+++ b/daemons/lvmlockd/Makefile.in
@@ -42,12 +42,10 @@ LIBS += $(RT_LIBS) $(DAEMON_LIBS) $(PTHREAD_LIBS)
 
 lvmlockd: $(OBJECTS) $(top_builddir)/libdaemon/client/libdaemonclient.a \
 		    $(top_builddir)/libdaemon/server/libdaemonserver.a
-	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJECTS) $(LOCK_LIBS) -ldaemonserver \
-		$(top_builddir)/device_mapper/libdevice-mapper.a $(LIBS)
+	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJECTS) $(LOCK_LIBS) -ldaemonserver $(INTERNAL_LIBS) $(LIBS)
 
 lvmlockctl: lvmlockctl.o $(top_builddir)/libdaemon/client/libdaemonclient.a
-	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ lvmlockctl.o \
-		$(top_builddir)/device_mapper/libdevice-mapper.a $(LIBS)
+	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ lvmlockctl.o $(INTERNAL_LIBS) $(LIBS)
 
 install_lvmlockd: lvmlockd
 	$(INSTALL_PROGRAM) -D $< $(sbindir)/$(<F)
diff --git a/daemons/lvmpolld/Makefile.in b/daemons/lvmpolld/Makefile.in
index 229a87e..8bf2556 100644
--- a/daemons/lvmpolld/Makefile.in
+++ b/daemons/lvmpolld/Makefile.in
@@ -34,8 +34,7 @@ LIBS += $(DAEMON_LIBS) -ldaemonserver $(PTHREAD_LIBS)
 
 lvmpolld: $(OBJECTS) $(top_builddir)/libdaemon/client/libdaemonclient.a \
 		    $(top_builddir)/libdaemon/server/libdaemonserver.a
-	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJECTS) \
-		$(top_builddir)/device_mapper/libdevice-mapper.a $(LIBS)
+	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJECTS) $(INTERNAL_LIBS) $(LIBS)
 
 install_lvmpolld: lvmpolld
 	$(INSTALL_PROGRAM) -D $< $(sbindir)/$(<F)
diff --git a/lib/Makefile.in b/lib/Makefile.in
index 4fb4fcf..1d42235 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -21,7 +21,6 @@ ifeq ("@CLUSTER@", "shared")
 endif
 
 SOURCES =\
-	../base/data-struct/radix-tree.c \
 	activate/activate.c \
 	cache/lvmcache.c \
 	cache_segtype/cache.c \
diff --git a/libdm/make.tmpl.in b/libdm/make.tmpl.in
index b9672dc..fc29034 100644
--- a/libdm/make.tmpl.in
+++ b/libdm/make.tmpl.in
@@ -342,7 +342,7 @@ SUBDIRS.distclean := $(SUBDIRS:=.distclean)
 
 TARGETS += $(LIB_SHARED) $(LIB_STATIC)
 
-all: $(top_builddir)/device_mapper/libdevice-mapper.a $(SUBDIRS) $(TARGETS)
+all: $(SUBDIRS) $(TARGETS)
 
 install: all $(SUBDIRS.install)
 install_cluster: all $(SUBDIRS.install_cluster)
@@ -351,7 +351,7 @@ install_lvm2: $(SUBDIRS.install_lvm2)
 install_ocf: $(SUBDIRS.install_ocf)
 cflow: $(SUBDIRS.cflow)
 
-$(SUBDIRS): $(SUBDIRS.device-mapper) $(top_builddir)/device_mapper/libdevice-mapper.a
+$(SUBDIRS): $(SUBDIRS.device-mapper)
 	$(MAKE) -C $@
 
 $(SUBDIRS.device-mapper):
diff --git a/make.tmpl.in b/make.tmpl.in
index b9672dc..0790d7b 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -342,7 +342,11 @@ SUBDIRS.distclean := $(SUBDIRS:=.distclean)
 
 TARGETS += $(LIB_SHARED) $(LIB_STATIC)
 
-all: $(top_builddir)/device_mapper/libdevice-mapper.a $(SUBDIRS) $(TARGETS)
+INTERNAL_LIBS=\
+	$(top_builddir)/device_mapper/libdevice-mapper.a \
+	$(top_builddir)/base/libbase.a
+	
+all: $(INTERNAL_LIBS) $(SUBDIRS) $(TARGETS)
 
 install: all $(SUBDIRS.install)
 install_cluster: all $(SUBDIRS.install_cluster)
@@ -351,7 +355,7 @@ install_lvm2: $(SUBDIRS.install_lvm2)
 install_ocf: $(SUBDIRS.install_ocf)
 cflow: $(SUBDIRS.cflow)
 
-$(SUBDIRS): $(SUBDIRS.device-mapper) $(top_builddir)/device_mapper/libdevice-mapper.a
+$(SUBDIRS): $(SUBDIRS.device-mapper) $(INTERNAL_LIBS)
 	$(MAKE) -C $@
 
 $(SUBDIRS.device-mapper):
diff --git a/scripts/Makefile.in b/scripts/Makefile.in
index 194d2e2..ee39306 100644
--- a/scripts/Makefile.in
+++ b/scripts/Makefile.in
@@ -88,8 +88,8 @@ endif
 
 CFLAGS_lvm2_activation_generator_systemd_red_hat.o += $(EXTRA_EXEC_CFLAGS)
 
-lvm2_activation_generator_systemd_red_hat: $(OBJECTS) $(DEPLIBS) $(top_builddir)/device_mapper/libdevice-mapper.a
-	$(CC) -o $@ $(OBJECTS) $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) $(LVMLIBS) $(top_builddir)/device_mapper/libdevice-mapper.a $(LIBS)
+lvm2_activation_generator_systemd_red_hat: $(OBJECTS) $(DEPLIBS) $(INTERNAL_LIBS)
+	$(CC) -o $@ $(OBJECTS) $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) $(LVMLIBS) $(INTERNAL_LIBS) $(LIBS)
 
 install_systemd_generators:
 	$(INSTALL_DIR) $(systemd_generator_dir)
diff --git a/test/api/Makefile.in b/test/api/Makefile.in
index d010394..6872095 100644
--- a/test/api/Makefile.in
+++ b/test/api/Makefile.in
@@ -46,8 +46,7 @@ DEFS += -D_REENTRANT
 DEPLIBS += $(top_builddir)/liblvm/liblvm2app.so
 LDFLAGS+=\
 	-L$(top_builddir)/liblvm \
-	-L$(top_builddir)/daemons/dmeventd \
-	-L$(top_builddir)/device_mapper/libdevice-mapper.a
+	-L$(top_builddir)/daemons/dmeventd
 LIBS += @LVM2APP_LIB@ $(DMEVENT_LIBS)
 
 %.t: %.o $(DEPLIBS)
diff --git a/test/unit/Makefile.in b/test/unit/Makefile.in
index ca36c57..994968c 100644
--- a/test/unit/Makefile.in
+++ b/test/unit/Makefile.in
@@ -34,7 +34,7 @@ UNIT_OBJECTS=$(UNIT_SOURCE:%.c=%.o)
 CLEAN_TARGETS+=$(UNIT_DEPENDS) $(UNIT_OBJECTS)
 UNIT_LDLIBS += $(LVMINTERNAL_LIBS) -laio
 
-test/unit/unit-test: $(UNIT_OBJECTS) lib/liblvm-internal.a device_mapper/libdevice-mapper.a
+test/unit/unit-test: $(UNIT_OBJECTS) lib/liblvm-internal.a $(INTERNAL_LIBS)
 	@echo "    [LD] $@"
 	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) \
 	      -o $@ $+ $(UNIT_LDLIBS) -lm
diff --git a/tools/Makefile.in b/tools/Makefile.in
index d4514a2..2dbd93b 100644
--- a/tools/Makefile.in
+++ b/tools/Makefile.in
@@ -122,12 +122,12 @@ device-mapper: $(TARGETS_DM)
 
 CFLAGS_dmsetup.o += $(UDEV_CFLAGS) $(EXTRA_EXEC_CFLAGS)
 
-dmsetup: dmsetup.o $(top_builddir)/device_mapper/libdevice-mapper.a
+dmsetup: dmsetup.o $(INTERNAL_LIBS)
 	@echo "    [CC] $@"
 	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) \
 	      -o $@ $+ $(LIBS) -lm
 
-dmsetup.static: dmsetup.o $(top_builddir)/device_mapper/libdevice-mapper.a
+dmsetup.static: dmsetup.o $(INTERNAL_LIBS)
 	@echo "    [CC] $@"
 	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) -static -L$(interfacebuilddir) \
 	      -o $@ $+ $(M_LIBS) $(PTHREAD_LIBS) $(STATIC_LIBS) $(LIBS)
@@ -138,7 +138,7 @@ CFLAGS_lvm.o += $(EXTRA_EXEC_CFLAGS)
 
 INCLUDES += -I$(top_builddir)/tools
 
-lvm: $(OBJECTS) lvm.o $(top_builddir)/lib/liblvm-internal.a $(top_builddir)/device_mapper/libdevice-mapper.a
+lvm: $(OBJECTS) lvm.o $(top_builddir)/lib/liblvm-internal.a $(INTERNAL_LIBS)
 	@echo "    [CC] $@"
 	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) -o $@ $+ \
 		$(LVMLIBS) $(READLINE_LIBS) $(LIBS) -lm
@@ -157,7 +157,7 @@ ifeq ("@BUILD_LVMETAD@", "yes")
 lvm: $(top_builddir)/libdaemon/client/libdaemonclient.a
 endif
 
-lvm.static: $(OBJECTS) lvm-static.o $(top_builddir)/lib/liblvm-internal.a  $(top_builddir)/device_mapper/libdevice-mapper.a
+lvm.static: $(OBJECTS) lvm-static.o $(top_builddir)/lib/liblvm-internal.a $(INTERNAL_LIBS)
 	@echo "    [CC] $@"
 	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) -static -L$(interfacebuilddir) -o $@ \
 	      $(OBJECTS) lvm-static.o $(LVMLIBS) $(STATIC_LIBS) $(LIBS)


