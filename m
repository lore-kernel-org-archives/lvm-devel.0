From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Nov 2018 17:12:30 -0500
Subject: master - makefiles: updates for less verbosity
Message-ID: <201811292212.wATMCUcM016566@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ceb2f0ad3b2c162a78f7ad1c86de9fd3f1dd0923
Commit:        ceb2f0ad3b2c162a78f7ad1c86de9fd3f1dd0923
Parent:        483ed8f76700ad6d7c479c0e41c58970cc266ee7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 29 17:09:27 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 29 23:05:43 2018 +0100

makefiles: updates for less verbosity

---
 daemons/cmirrord/Makefile.in |    6 +-
 daemons/dmeventd/Makefile.in |   21 ++++--
 daemons/lvmdbusd/Makefile.in |   19 +++---
 daemons/lvmlockd/Makefile.in |   12 +++-
 daemons/lvmpolld/Makefile.in |    6 +-
 libdm/Makefile.in            |   12 +++-
 libdm/dm-tools/Makefile.in   |   12 +++-
 libdm/make.tmpl.in           |   10 ++-
 make.tmpl.in                 |   12 ++--
 scripts/Makefile.in          |   59 ++++++++++--------
 test/Makefile.in             |  138 ++++++++++++++++++++++++------------------
 tools/Makefile.in            |    4 +-
 udev/Makefile.in             |    5 +-
 13 files changed, 185 insertions(+), 131 deletions(-)

diff --git a/daemons/cmirrord/Makefile.in b/daemons/cmirrord/Makefile.in
index a78dafe..0bcd73c 100644
--- a/daemons/cmirrord/Makefile.in
+++ b/daemons/cmirrord/Makefile.in
@@ -29,8 +29,10 @@ CFLAGS += $(CPG_CFLAGS) $(EXTRA_EXEC_CFLAGS)
 LDFLAGS += $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS)
 
 cmirrord: $(OBJECTS) $(top_builddir)/lib/liblvm-internal.a
-	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJECTS) \
+	@echo "    [CC] $@"
+	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJECTS) \
 		$(LVMLIBS) $(LMLIBS) $(INTERNAL_LIBS) $(LIBS)
 
 install: $(TARGETS)
-	$(INSTALL_PROGRAM) -D cmirrord $(usrsbindir)/cmirrord
+	@echo "    [INSTALL] $<"
+	$(Q) $(INSTALL_PROGRAM) -D cmirrord $(usrsbindir)/cmirrord
diff --git a/daemons/dmeventd/Makefile.in b/daemons/dmeventd/Makefile.in
index 56a9e35..2d856f7 100644
--- a/daemons/dmeventd/Makefile.in
+++ b/daemons/dmeventd/Makefile.in
@@ -60,11 +60,13 @@ CFLAGS_dmeventd.o += $(EXTRA_EXEC_CFLAGS)
 LIBS += $(PTHREAD_LIBS)
 
 dmeventd: $(LIB_SHARED) dmeventd.o
-	$(CC) $(CFLAGS) -L. $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) dmeventd.o \
+	@echo "    [CC] $@"
+	$(Q) $(CC) $(CFLAGS) -L. $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) dmeventd.o \
 		-o $@ $(DL_LIBS) $(DMEVENT_LIBS) $(INTERNAL_LIBS) $(LIBS) -lm
 
 dmeventd.static: $(LIB_STATIC) dmeventd.o
-	$(CC) $(CFLAGS) $(LDFLAGS) -static -L. -L$(interfacebuilddir) dmeventd.o \
+	@echo "    [CC] $@"
+	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) -static -L. -L$(interfacebuilddir) dmeventd.o \
 		-o $@ $(DL_LIBS) $(DMEVENT_LIBS) $(LIBS) $(STATIC_LIBS)
 
 ifeq ("@PKGCONFIG@", "yes")
@@ -80,23 +82,28 @@ CFLOW_SOURCES = $(addprefix $(srcdir)/, $(SOURCES))
 endif
 
 install_include: $(srcdir)/libdevmapper-event.h
-	$(INSTALL_DATA) -D $< $(includedir)/$(<F)
+	@echo "    [INSTALL] $<"
+	$(Q) $(INSTALL_DATA) -D $< $(includedir)/$(<F)
 
 install_pkgconfig: libdevmapper-event.pc
-	$(INSTALL_DATA) -D $< $(pkgconfigdir)/devmapper-event.pc
+	@echo "    [INSTALL] $<"
+	$(Q) $(INSTALL_DATA) -D $< $(pkgconfigdir)/devmapper-event.pc
 
 install_lib_dynamic: install_lib_shared
 
 install_lib_static: $(LIB_STATIC)
-	$(INSTALL_DATA) -D $< $(usrlibdir)/$(<F)
+	@echo "    [INSTALL] $<"
+	$(Q) $(INSTALL_DATA) -D $< $(usrlibdir)/$(<F)
 
 install_lib: $(INSTALL_LIB_TARGETS)
 
 install_dmeventd_dynamic: dmeventd
-	$(INSTALL_PROGRAM) -D $< $(sbindir)/$(<F)
+	@echo "    [INSTALL] $<"
+	$(Q) $(INSTALL_PROGRAM) -D $< $(sbindir)/$(<F)
 
 install_dmeventd_static: dmeventd.static
-	$(INSTALL_PROGRAM) -D $< $(staticdir)/$(<F)
+	@echo "    [INSTALL] $<"
+	$(Q) $(INSTALL_PROGRAM) -D $< $(staticdir)/$(<F)
 
 install_dmeventd: $(INSTALL_DMEVENTD_TARGETS)
 
diff --git a/daemons/lvmdbusd/Makefile.in b/daemons/lvmdbusd/Makefile.in
index 7b62e7e..8d5de28 100644
--- a/daemons/lvmdbusd/Makefile.in
+++ b/daemons/lvmdbusd/Makefile.in
@@ -51,17 +51,18 @@ include $(top_builddir)/make.tmpl
 .PHONY: install_lvmdbusd
 
 all:
-	test -x $(LVMDBUSD) || chmod 755 $(LVMDBUSD)
+	$(Q) test -x $(LVMDBUSD) || chmod 755 $(LVMDBUSD)
 
 install_lvmdbusd:
-	$(INSTALL_DIR) $(sbindir)
-	$(INSTALL_SCRIPT) $(LVMDBUSD) $(sbindir)
-	$(INSTALL_DIR) $(DESTDIR)$(lvmdbusdir)
-	(cd $(srcdir); $(INSTALL_DATA) $(LVMDBUS_SRCDIR_FILES) $(DESTDIR)$(lvmdbusdir))
-	$(INSTALL_DATA) $(LVMDBUS_BUILDDIR_FILES) $(DESTDIR)$(lvmdbusdir)
-	PYTHON=$(PYTHON3) $(PYCOMPILE) --destdir "$(DESTDIR)" --basedir "$(lvmdbusdir)" $(LVMDBUS_SRCDIR_FILES) $(LVMDBUS_BUILDDIR_FILES)
-	$(CHMOD) 755 $(DESTDIR)$(lvmdbusdir)/__pycache__
-	$(CHMOD) 444 $(DESTDIR)$(lvmdbusdir)/__pycache__/*.py[co]
+	@echo "    [INSTALL] $<"
+	$(Q) $(INSTALL_DIR) $(sbindir)
+	$(Q) $(INSTALL_SCRIPT) $(LVMDBUSD) $(sbindir)
+	$(Q) $(INSTALL_DIR) $(DESTDIR)$(lvmdbusdir)
+	$(Q) (cd $(srcdir); $(INSTALL_DATA) $(LVMDBUS_SRCDIR_FILES) $(DESTDIR)$(lvmdbusdir))
+	$(Q) $(INSTALL_DATA) $(LVMDBUS_BUILDDIR_FILES) $(DESTDIR)$(lvmdbusdir)
+	$(Q) PYTHON=$(PYTHON3) $(PYCOMPILE) --destdir "$(DESTDIR)" --basedir "$(lvmdbusdir)" $(LVMDBUS_SRCDIR_FILES) $(LVMDBUS_BUILDDIR_FILES)
+	$(Q) $(CHMOD) 755 $(DESTDIR)$(lvmdbusdir)/__pycache__
+	$(Q) $(CHMOD) 444 $(DESTDIR)$(lvmdbusdir)/__pycache__/*.py[co]
 
 install_lvm2: install_lvmdbusd
 
diff --git a/daemons/lvmlockd/Makefile.in b/daemons/lvmlockd/Makefile.in
index 0f1386b..17fcb40 100644
--- a/daemons/lvmlockd/Makefile.in
+++ b/daemons/lvmlockd/Makefile.in
@@ -50,16 +50,20 @@ endif
 
 lvmlockd: $(OBJECTS) $(top_builddir)/libdaemon/client/libdaemonclient.a \
 		    $(top_builddir)/libdaemon/server/libdaemonserver.a
-	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJECTS) $(LOCK_LIBS) -ldaemonserver $(INTERNAL_LIBS) $(LIBS)
+	@echo "    [CC] $@"
+	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJECTS) $(LOCK_LIBS) -ldaemonserver $(INTERNAL_LIBS) $(LIBS)
 
 lvmlockctl: lvmlockctl.o $(top_builddir)/libdaemon/client/libdaemonclient.a
-	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ lvmlockctl.o $(INTERNAL_LIBS) $(LIBS)
+	@echo "    [CC] $@"
+	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) -o $@ lvmlockctl.o $(INTERNAL_LIBS) $(LIBS)
 
 install_lvmlockd: lvmlockd
-	$(INSTALL_PROGRAM) -D $< $(sbindir)/$(<F)
+	@echo "    [INSTALL] $<"
+	$(Q) $(INSTALL_PROGRAM) -D $< $(sbindir)/$(<F)
 
 install_lvmlockctl: lvmlockctl
-	$(INSTALL_PROGRAM) -D $< $(sbindir)/$(<F)
+	@echo "    [INSTALL] $<"
+	$(Q) $(INSTALL_PROGRAM) -D $< $(sbindir)/$(<F)
 
 install_lvm2: install_lvmlockd install_lvmlockctl
 
diff --git a/daemons/lvmpolld/Makefile.in b/daemons/lvmpolld/Makefile.in
index 8bf2556..cfda0f6 100644
--- a/daemons/lvmpolld/Makefile.in
+++ b/daemons/lvmpolld/Makefile.in
@@ -34,10 +34,12 @@ LIBS += $(DAEMON_LIBS) -ldaemonserver $(PTHREAD_LIBS)
 
 lvmpolld: $(OBJECTS) $(top_builddir)/libdaemon/client/libdaemonclient.a \
 		    $(top_builddir)/libdaemon/server/libdaemonserver.a
-	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJECTS) $(INTERNAL_LIBS) $(LIBS)
+	@echo "    [CC] $@"
+	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJECTS) $(INTERNAL_LIBS) $(LIBS)
 
 install_lvmpolld: lvmpolld
-	$(INSTALL_PROGRAM) -D $< $(sbindir)/$(<F)
+	@echo "    [INSTALL] $<"
+	$(Q) $(INSTALL_PROGRAM) -D $< $(sbindir)/$(<F)
 
 install_lvm2: install_lvmpolld
 
diff --git a/libdm/Makefile.in b/libdm/Makefile.in
index 8c8334a..2a117e6 100644
--- a/libdm/Makefile.in
+++ b/libdm/Makefile.in
@@ -65,7 +65,8 @@ device-mapper: all
 dm-tools.device-mapper: $(TARGETS)
 
 libdevmapper.$(LIB_SUFFIX) libdevmapper.$(LIB_SUFFIX).$(LIB_VERSION): $(LIB_SHARED)
-	$(LN_S) -f $< $@
+	@echo "    [LN] $<"
+	$(Q) $(LN_S) -f $< $@
 
 .PHONY: install_dynamic install_static install_include \
 	install_ioctl install_ioctl_static \
@@ -86,7 +87,8 @@ install: $(INSTALL_TYPE) install_include
 install_device-mapper: install
 
 install_include: $(srcdir)/libdevmapper.h
-	$(INSTALL_DATA) -D $< $(includedir)/$(<F)
+	@echo "    [INSTALL] $<"
+	$(Q) $(INSTALL_DATA) -D $< $(includedir)/$(<F)
 
 install_dynamic: install_ at interface@
 
@@ -95,10 +97,12 @@ install_static: install_ at interface@_static
 install_ioctl: install_lib_shared
 
 install_pkgconfig: libdevmapper.pc
-	$(INSTALL_DATA) -D $< $(pkgconfigdir)/devmapper.pc
+	@echo "    [INSTALL] $<"
+	$(Q) $(INSTALL_DATA) -D $< $(pkgconfigdir)/devmapper.pc
 
 install_ioctl_static: $(LIB_STATIC)
-	$(INSTALL_DATA) -D $< $(usrlibdir)/$(<F)
+	@echo "    [INSTALL] $<"
+	$(Q) $(INSTALL_DATA) -D $< $(usrlibdir)/$(<F)
 
 CLEAN_TARGETS += ioctl/libdevmapper.a
 DISTCLEAN_TARGETS += libdevmapper.pc
diff --git a/libdm/dm-tools/Makefile.in b/libdm/dm-tools/Makefile.in
index 39d411d..abb0e95 100644
--- a/libdm/dm-tools/Makefile.in
+++ b/libdm/dm-tools/Makefile.in
@@ -80,18 +80,22 @@ ifeq ("@BUILD_DMFILEMAPD@", "yes")
   CFLAGS_dmfilemapd.o += $(EXTRA_EXEC_CFLAGS)
 
   dmfilemapd: $(LIB_SHARED) dmfilemapd.o
-	$(CC) $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) \
+	@echo "    [CC] $<"
+	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) \
 		-o $@ dmfilemapd.o -L$(top_builddir)/libdm -ldevmapper $(DL_LIBS) $(LIBS)
 
   dmfilemapd.static: $(LIB_STATIC) dmfilemapd.o
-	$(CC) $(CFLAGS) $(LDFLAGS) $(ELDFLAGS) -static -L$(interfacebuilddir) \
+	@echo "    [CC] $<"
+	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) $(ELDFLAGS) -static -L$(interfacebuilddir) \
 		-o $@ dmfilemapd.o $(DL_LIBS) $(LIBS) $(STATIC_LIBS)
 
   install_dmfilemapd_dynamic: dmfilemapd
-	$(INSTALL_PROGRAM) -D $< $(sbindir)/$(<F)
+	@echo "    [INSTALL] $<"
+	$(Q) $(INSTALL_PROGRAM) -D $< $(sbindir)/$(<F)
 
   install_dmfilemapd_static: dmfilemapd.static
-	$(INSTALL_PROGRAM) -D $< $(staticdir)/$(<F)
+	@echo "    [INSTALL] $<"
+	$(Q) $(INSTALL_PROGRAM) -D $< $(staticdir)/$(<F)
 
   install_dmfilemapd: $(INSTALL_DMFILEMAPD_TARGETS)
 
diff --git a/libdm/make.tmpl.in b/libdm/make.tmpl.in
index 1365fd1..451ef94 100644
--- a/libdm/make.tmpl.in
+++ b/libdm/make.tmpl.in
@@ -484,18 +484,20 @@ CLEAN_TARGETS += \
 	$(POTFILES) $(CLEAN_CFLOW)
 
 cleandir:
+	@echo "    [CLEANDIR]"
 ifneq (,$(firstword $(CLEAN_DIRS)))
-	$(RM) -r $(CLEAN_DIRS)
+	$(Q) $(RM) -r $(CLEAN_DIRS)
 endif
-	$(RM) $(OBJECTS) $(TARGETS) $(CLEAN_TARGETS) core
+	$(Q) $(RM) $(OBJECTS) $(TARGETS) $(CLEAN_TARGETS) core
 
 clean: $(SUBDIRS.clean) cleandir
 
 distclean: cleandir $(SUBDIRS.distclean)
+	@echo "    [DISTCLEAN]"
 ifneq (,$(firstword $(DISTCLEAN_DIRS)))
-	$(RM) -r $(DISTCLEAN_DIRS)
+	$(Q) $(RM) -r $(DISTCLEAN_DIRS)
 endif
-	$(RM) $(DISTCLEAN_TARGETS) Makefile
+	$(Q) $(RM) $(DISTCLEAN_TARGETS) Makefile
 
 .exported_symbols_generated: $(EXPORTED_HEADER) .exported_symbols $(DEPS)
 	$(Q) set -e; \
diff --git a/make.tmpl.in b/make.tmpl.in
index a6642f2..f52a65a 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -481,7 +481,7 @@ ifeq ("@LIB_SUFFIX@","dylib")
 endif
 
 $(LIB_SHARED): $(LIB_SHARED).$(LIB_VERSION)
-	@echo "    [LN] $<"
+	@echo "    [LN] $@"
 	$(Q) $(LN_S) -f $(<F) $@
 
 CLEAN_TARGETS += $(LDDEPS) .exported_symbols_generated
@@ -534,18 +534,20 @@ CLEAN_TARGETS += \
 	$(POTFILES) $(CLEAN_CFLOW)
 
 cleandir:
+	@echo "    [CLEANDIR]"
 ifneq (,$(firstword $(CLEAN_DIRS)))
-	$(RM) -r $(CLEAN_DIRS)
+	$(Q) $(RM) -r $(CLEAN_DIRS)
 endif
-	$(RM) $(OBJECTS) $(TARGETS) $(CLEAN_TARGETS) core
+	$(Q) $(RM) $(OBJECTS) $(TARGETS) $(CLEAN_TARGETS) core
 
 clean: $(SUBDIRS.clean) cleandir
 
 distclean: cleandir $(SUBDIRS.distclean)
+	@echo "    [DISTCLEAN]"
 ifneq (,$(firstword $(DISTCLEAN_DIRS)))
-	$(RM) -r $(DISTCLEAN_DIRS)
+	$(Q) $(RM) -r $(DISTCLEAN_DIRS)
 endif
-	$(RM) $(DISTCLEAN_TARGETS) Makefile
+	$(Q) $(RM) $(DISTCLEAN_TARGETS) Makefile
 
 .exported_symbols_generated: $(EXPORTED_HEADER) .exported_symbols $(DEPS)
 	$(Q) set -e; \
diff --git a/scripts/Makefile.in b/scripts/Makefile.in
index 12d37d0..99acfbc 100644
--- a/scripts/Makefile.in
+++ b/scripts/Makefile.in
@@ -44,11 +44,11 @@ vpath %.sh $(srcdir)
 vpath %.ocf $(srcdir)
 
 %_install: %.sh
-	$(INSTALL_PROGRAM) -D $< $(sbindir)/$(basename $(<F))
+	$(Q) $(INSTALL_PROGRAM) -D $< $(sbindir)/$(basename $(<F))
 
 %_install: %.ocf
-	$(INSTALL_DIR) $(ocf_scriptdir)
-	$(INSTALL_SCRIPT) $< $(ocf_scriptdir)/$(basename $(<F))
+	$(Q) $(INSTALL_DIR) $(ocf_scriptdir)
+	$(Q) $(INSTALL_SCRIPT) $< $(ocf_scriptdir)/$(basename $(<F))
 
 install_lvm2: $(LVM_SCRIPTS:.sh=_install)
 install_device-mapper: $(DM_SCRIPTS:.sh=_install)
@@ -59,61 +59,66 @@ install: install_lvm2 install_ocf install_device-mapper
 
 # FIXME Customise for other distributions
 install_initscripts:
-	$(INSTALL_DIR) $(initdir)
+	@echo "    [INSTALL] $<"
+	$(Q) $(INSTALL_DIR) $(initdir)
 ifeq ("@BUILD_DMEVENTD@", "yes")
-	$(INSTALL_SCRIPT) lvm2_monitoring_init_red_hat $(initdir)/lvm2-monitor
+	$(Q) $(INSTALL_SCRIPT) lvm2_monitoring_init_red_hat $(initdir)/lvm2-monitor
 endif
 ifeq ("@BUILD_LVMPOLLD@", "yes")
-	$(INSTALL_SCRIPT) lvm2_lvmpolld_init_red_hat $(initdir)/lvm2-lvmpolld
+	$(Q) $(INSTALL_SCRIPT) lvm2_lvmpolld_init_red_hat $(initdir)/lvm2-lvmpolld
 endif
 ifeq ("@BUILD_CMIRRORD@", "yes")
-	$(INSTALL_SCRIPT) cmirrord_init_red_hat $(initdir)/cmirrord
+	$(Q) $(INSTALL_SCRIPT) cmirrord_init_red_hat $(initdir)/cmirrord
 endif
 ifeq ("@BLKDEACTIVATE@", "yes")
-	$(INSTALL_SCRIPT) blk_availability_init_red_hat $(initdir)/blk-availability
+	$(Q) $(INSTALL_SCRIPT) blk_availability_init_red_hat $(initdir)/blk-availability
 endif
 
 CFLAGS_lvm2_activation_generator_systemd_red_hat.o += $(EXTRA_EXEC_CFLAGS)
 
 lvm2_activation_generator_systemd_red_hat: $(OBJECTS) $(DEPLIBS) $(INTERNAL_LIBS)
-	$(CC) -o $@ $(OBJECTS) $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) $(LVMLIBS) $(INTERNAL_LIBS) $(LIBS)
+	@echo "    [CC] $@"
+	$(Q) $(CC) -o $@ $(OBJECTS) $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) $(LVMLIBS) $(INTERNAL_LIBS) $(LIBS)
 
 install_systemd_generators:
-	$(INSTALL_DIR) $(systemd_generator_dir)
-	$(INSTALL_PROGRAM) lvm2_activation_generator_systemd_red_hat $(systemd_generator_dir)/lvm2-activation-generator
+	@echo "    [INSTALL] $<"
+	$(Q) $(INSTALL_DIR) $(systemd_generator_dir)
+	$(Q) $(INSTALL_PROGRAM) lvm2_activation_generator_systemd_red_hat $(systemd_generator_dir)/lvm2-activation-generator
 
 install_systemd_units:	install_dbus_service
-	$(INSTALL_DIR) $(systemd_unit_dir)
-	$(INSTALL_DATA) lvm2-pvscan.service $(systemd_unit_dir)/lvm2-pvscan at .service
+	@echo "    [INSTALL] $<"
+	$(Q) $(INSTALL_DIR) $(systemd_unit_dir)
+	$(Q) $(INSTALL_DATA) lvm2-pvscan.service $(systemd_unit_dir)/lvm2-pvscan@.service
 ifeq ("@BUILD_DMEVENTD@", "yes")
-	$(INSTALL_DATA) dm_event_systemd_red_hat.socket $(systemd_unit_dir)/dm-event.socket
-	$(INSTALL_DATA) dm_event_systemd_red_hat.service $(systemd_unit_dir)/dm-event.service
-	$(INSTALL_DATA) lvm2_monitoring_systemd_red_hat.service $(systemd_unit_dir)/lvm2-monitor.service
+	$(Q) $(INSTALL_DATA) dm_event_systemd_red_hat.socket $(systemd_unit_dir)/dm-event.socket
+	$(Q) $(INSTALL_DATA) dm_event_systemd_red_hat.service $(systemd_unit_dir)/dm-event.service
+	$(Q) $(INSTALL_DATA) lvm2_monitoring_systemd_red_hat.service $(systemd_unit_dir)/lvm2-monitor.service
 endif
 ifeq ("@BLKDEACTIVATE@", "yes")
-	$(INSTALL_DATA) blk_availability_systemd_red_hat.service $(systemd_unit_dir)/blk-availability.service
+	$(Q) $(INSTALL_DATA) blk_availability_systemd_red_hat.service $(systemd_unit_dir)/blk-availability.service
 endif
 ifeq ("@BUILD_LVMPOLLD@", "yes")
-	$(INSTALL_DATA) lvm2_lvmpolld_systemd_red_hat.socket $(systemd_unit_dir)/lvm2-lvmpolld.socket
-	$(INSTALL_DATA) lvm2_lvmpolld_systemd_red_hat.service $(systemd_unit_dir)/lvm2-lvmpolld.service
+	$(Q) $(INSTALL_DATA) lvm2_lvmpolld_systemd_red_hat.socket $(systemd_unit_dir)/lvm2-lvmpolld.socket
+	$(Q) $(INSTALL_DATA) lvm2_lvmpolld_systemd_red_hat.service $(systemd_unit_dir)/lvm2-lvmpolld.service
 endif
 ifeq ("@BUILD_LVMLOCKD@", "yes")
-	$(INSTALL_DATA) lvmlockd.service $(systemd_unit_dir)/lvmlockd.service
-	$(INSTALL_DATA) lvmlocks.service $(systemd_unit_dir)/lvmlocks.service
+	$(Q) $(INSTALL_DATA) lvmlockd.service $(systemd_unit_dir)/lvmlockd.service
+	$(Q) $(INSTALL_DATA) lvmlocks.service $(systemd_unit_dir)/lvmlocks.service
 endif
 ifeq ("@BUILD_CMIRRORD@", "yes")
-	$(INSTALL_DATA) lvm2_cmirrord_systemd_red_hat.service $(systemd_unit_dir)/lvm2-cmirrord.service
+	$(Q) $(INSTALL_DATA) lvm2_cmirrord_systemd_red_hat.service $(systemd_unit_dir)/lvm2-cmirrord.service
 endif
 ifeq ("@BUILD_LVMDBUSD@", "yes")
-	$(INSTALL_DATA) lvm2_lvmdbusd_systemd_red_hat.service $(systemd_unit_dir)/lvm2-lvmdbusd.service
+	$(Q) $(INSTALL_DATA) lvm2_lvmdbusd_systemd_red_hat.service $(systemd_unit_dir)/lvm2-lvmdbusd.service
 endif
 
 ifeq ("@BUILD_LVMDBUSD@", "yes")
 install_dbus_service:
-	$(INSTALL_DIR) $(dbusconfdir)
-	$(INSTALL_DIR) $(dbusservicedir)
-	$(INSTALL_DATA) $(top_srcdir)/scripts/com.redhat.lvmdbus1.conf $(dbusconfdir)
-	$(INSTALL_DATA) com.redhat.lvmdbus1.service $(dbusservicedir)
+	@echo "    [INSTALL] $<"
+	$(Q) $(INSTALL_DIR) $(dbusconfdir)
+	$(Q) $(INSTALL_DIR) $(dbusservicedir)
+	$(Q) $(INSTALL_DATA) $(top_srcdir)/scripts/com.redhat.lvmdbus1.conf $(dbusconfdir)
+	$(Q) $(INSTALL_DATA) com.redhat.lvmdbus1.service $(dbusservicedir)
 
 install_systemd_units:	install_dbus_service
 endif
diff --git a/test/Makefile.in b/test/Makefile.in
index df61f0a..e471a11 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -168,7 +168,8 @@ check_lvmlockd_test: .tests-stamp
 endif
 
 run-unit-test unit-test:
-	$(MAKE) -C unit $(@)
+	@echo "    [MAKE] $<"
+	$(Q) $(MAKE) -C unit $(@)
 
 DATADIR = $(datadir)/lvm2-testsuite
 EXECDIR = $(libexecdir)/lvm2-testsuite
@@ -199,11 +200,11 @@ LIB_SHARED = check aux inittest utils get lvm-wrapper
 
 install: .tests-stamp lib/paths-installed
 	@echo $(srcdir)
-	$(INSTALL_DIR) $(DATADIR)/{shell,unit,lib,dbus} $(EXECDIR)
-	$(INSTALL_DATA) shell/*.sh $(DATADIR)/shell
-	$(INSTALL_DATA) unit/*.sh $(DATADIR)/unit
-	-$(INSTALL_PROGRAM) unit/unit-test $(DATADIR)/unit
-	-$(INSTALL_PROGRAM) dbus/*.py $(DATADIR)/dbus/
+	$(Q) $(INSTALL_DIR) $(DATADIR)/{shell,unit,lib,dbus} $(EXECDIR)
+	$(Q) $(INSTALL_DATA) shell/*.sh $(DATADIR)/shell
+	$(Q) $(INSTALL_DATA) unit/*.sh $(DATADIR)/unit
+	-$(Q) $(INSTALL_PROGRAM) unit/unit-test $(DATADIR)/unit
+	-$(Q) $(INSTALL_PROGRAM) dbus/*.py $(DATADIR)/dbus/
 	$(INSTALL_DATA) lib/paths-installed $(DATADIR)/lib/paths
 	cd lib && $(INSTALL_DATA) \
 		$(LIB_FLAVOURS) \
@@ -223,25 +224,31 @@ install: .tests-stamp lib/paths-installed
 	@cd $(EXECDIR) && for i in $(LIB_LINK_NOT); do \
 		echo "$(LN_S) -f not $$i"; \
 		$(LN_S) -f not $$i; done
-	$(INSTALL_PROGRAM) -D lib/runner $(bindir)/lvm2-testsuite
+	$(Q) $(INSTALL_PROGRAM) -D lib/runner $(bindir)/lvm2-testsuite
 
 lib/should: lib/not
-	$(LN_S) -f not lib/should
+	@echo "    [LN] $@"
+	$(Q) $(LN_S) -f not lib/should
 
 lib/invalid: lib/not
-	$(LN_S) -f not lib/invalid
+	@echo "    [LN] $@"
+	$(Q) $(LN_S) -f not lib/invalid
 
 lib/fail: lib/not
-	$(LN_S) -f not lib/fail
+	@echo "    [LN] $@"
+	$(Q) $(LN_S) -f not lib/fail
 
 lib/runner: lib/runner.o .lib-dir-stamp
-	$(CXX) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) -o $@ $<
+	@echo "    [CXX] $@"
+	$(Q) $(CXX) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) -o $@ $<
 
 lib/dmsecuretest: lib/dmsecuretest.o .lib-dir-stamp $(INTERNAL_LIBS)
-	$(CC) -g $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) -o $@ $< $(INTERNAL_LIBS) $(LIBS)
+	@echo "    [CC] $@"
+	$(Q) $(CC) -g $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) -o $@ $< $(INTERNAL_LIBS) $(LIBS)
 
 lib/securetest: lib/dmsecuretest.o .lib-dir-stamp
-	$(CC) -g $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) -o $@ $< -L$(top_builddir)/libdm/ioctl -ldevmapper $(LIBS)
+	@echo "    [CC] $@"
+	$(Q) $(CC) -g $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) -o $@ $< -L$(top_builddir)/libdm/ioctl -ldevmapper $(LIBS)
 
 lib/runner.o: $(wildcard $(srcdir)/lib/*.h)
 
@@ -249,85 +256,98 @@ CFLAGS_runner.o += $(EXTRA_EXEC_CFLAGS)
 CFLAGS_dmsecuretest.o += $(EXTRA_EXEC_CFLAGS)
 
 lib/%: lib/%.o .lib-dir-stamp
-	$(CC) $(CFLAGS) $(LDFLAGS) $(ELDFLAGS) -o $@ $<
+	@echo "    [CC] $@"
+	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) $(ELDFLAGS) -o $@ $<
 
 lib/%: $(srcdir)/lib/%.sh .lib-dir-stamp
-	cp $< $@
-	$(CHMOD) +x $@
+	@echo "    [CP] $@"
+	$(Q) cp $< $@
+	$(Q) $(CHMOD) +x $@
 
 lib/flavour-%: $(srcdir)/lib/flavour-%.sh .lib-dir-stamp
-	cp $< $@
+	@echo "    [FLAVOUR] $<"
+	$(Q) cp $< $@
 
 lib/paths-common: $(srcdir)/Makefile.in .lib-dir-stamp Makefile
-	echo 'DM_UDEV_SYNCHRONISATION=$(dm_udev_synchronisation)' >> $@-t
-	echo 'LVMPOLLD_PIDFILE="@LVMPOLLD_PIDFILE@"' >> $@-t
-	echo 'DMEVENTD_PIDFILE="@DMEVENTD_PIDFILE@"' >> $@-t
-	echo 'LVM_TEST_THIN_CHECK_CMD=$${LVM_TEST_THIN_CHECK_CMD- at THIN_CHECK_CMD@}' >> $@-t
-	echo 'LVM_TEST_THIN_DUMP_CMD=$${LVM_TEST_THIN_DUMP_CMD- at THIN_DUMP_CMD@}' >> $@-t
-	echo 'LVM_TEST_THIN_REPAIR_CMD=$${LVM_TEST_THIN_REPAIR_CMD- at THIN_REPAIR_CMD@}' >> $@-t
-	echo 'LVM_TEST_THIN_RESTORE_CMD=$${LVM_TEST_THIN_RESTORE_CMD- at THIN_RESTORE_CMD@}' >> $@-t
-	echo 'LVM_TEST_CACHE_CHECK_CMD=$${LVM_TEST_CACHE_CHECK_CMD- at CACHE_CHECK_CMD@}' >> $@-t
-	echo 'LVM_TEST_CACHE_DUMP_CMD=$${LVM_TEST_CACHE_DUMP_CMD- at CACHE_DUMP_CMD@}' >> $@-t
-	echo 'LVM_TEST_CACHE_REPAIR_CMD=$${LVM_TEST_CACHE_REPAIR_CMD- at CACHE_REPAIR_CMD@}' >> $@-t
-	echo 'LVM_TEST_CACHE_RESTORE_CMD=$${LVM_TEST_CACHE_RESTORE_CMD- at CACHE_RESTORE_CMD@}' >> $@-t
-	echo 'export DM_UDEV_SYNCHRONISATION THIN RAID CACHE\' >> $@-t
-	echo ' LVM_TEST_THIN_CHECK_CMD LVM_TEST_THIN_DUMP_CMD LVM_TEST_THIN_REPAIR_CMD LVM_TEST_THIN_RESTORE_CMD\' >> $@-t
-	echo ' LVM_TEST_CACHE_CHECK_CMD LVM_TEST_CACHE_DUMP_CMD LVM_TEST_CACHE_REPAIR_CMD LVM_TEST_CACHE_RESTORE_CMD' >> $@-t
-	mv $@-t $@
+	@echo "    [PATHS] $@"
+	$(Q) echo 'DM_UDEV_SYNCHRONISATION=$(dm_udev_synchronisation)' >> $@-t
+	$(Q) echo 'LVMPOLLD_PIDFILE="@LVMPOLLD_PIDFILE@"' >> $@-t
+	$(Q) echo 'DMEVENTD_PIDFILE="@DMEVENTD_PIDFILE@"' >> $@-t
+	$(Q) echo 'LVM_TEST_THIN_CHECK_CMD=$${LVM_TEST_THIN_CHECK_CMD- at THIN_CHECK_CMD@}' >> $@-t
+	$(Q) echo 'LVM_TEST_THIN_DUMP_CMD=$${LVM_TEST_THIN_DUMP_CMD- at THIN_DUMP_CMD@}' >> $@-t
+	$(Q) echo 'LVM_TEST_THIN_REPAIR_CMD=$${LVM_TEST_THIN_REPAIR_CMD- at THIN_REPAIR_CMD@}' >> $@-t
+	$(Q) echo 'LVM_TEST_THIN_RESTORE_CMD=$${LVM_TEST_THIN_RESTORE_CMD- at THIN_RESTORE_CMD@}' >> $@-t
+	$(Q) echo 'LVM_TEST_CACHE_CHECK_CMD=$${LVM_TEST_CACHE_CHECK_CMD- at CACHE_CHECK_CMD@}' >> $@-t
+	$(Q) echo 'LVM_TEST_CACHE_DUMP_CMD=$${LVM_TEST_CACHE_DUMP_CMD- at CACHE_DUMP_CMD@}' >> $@-t
+	$(Q) echo 'LVM_TEST_CACHE_REPAIR_CMD=$${LVM_TEST_CACHE_REPAIR_CMD- at CACHE_REPAIR_CMD@}' >> $@-t
+	$(Q) echo 'LVM_TEST_CACHE_RESTORE_CMD=$${LVM_TEST_CACHE_RESTORE_CMD- at CACHE_RESTORE_CMD@}' >> $@-t
+	$(Q) echo 'export DM_UDEV_SYNCHRONISATION THIN RAID CACHE\' >> $@-t
+	$(Q) echo ' LVM_TEST_THIN_CHECK_CMD LVM_TEST_THIN_DUMP_CMD LVM_TEST_THIN_REPAIR_CMD LVM_TEST_THIN_RESTORE_CMD\' >> $@-t
+	$(Q) echo ' LVM_TEST_CACHE_CHECK_CMD LVM_TEST_CACHE_DUMP_CMD LVM_TEST_CACHE_REPAIR_CMD LVM_TEST_CACHE_RESTORE_CMD' >> $@-t
+	$(Q) mv $@-t $@
 
 lib/paths-installed: lib/paths-common
-	$(RM) $@-t
-	cat lib/paths-common > $@-t
-	echo 'installed_testsuite=1' >> $@-t
-	echo 'export PATH=@libexecdir@/lvm2-testsuite:@datadir@/lvm2-testsuite/lib:$$PATH' >> $@-t
-	mv $@-t $@
+	@echo "    [PATHS] $@"
+	$(Q) $(RM) $@-t
+	$(Q) cat lib/paths-common > $@-t
+	$(Q) echo 'installed_testsuite=1' >> $@-t
+	$(Q) echo 'export PATH=@libexecdir@/lvm2-testsuite:@datadir@/lvm2-testsuite/lib:$$PATH' >> $@-t
+	$(Q) mv $@-t $@
 
 lib/paths: lib/paths-common
-	$(RM) $@-t
-	cat lib/paths-common > $@-t
-	echo 'top_srcdir="$(top_srcdir)"' >> $@-t
-	echo 'abs_top_builddir="$(abs_top_builddir)"' >> $@-t
-	echo 'abs_top_srcdir="$(abs_top_srcdir)"' >> $@-t
-	echo 'abs_srcdir="$(abs_srcdir)"' >> $@-t
-	echo 'abs_builddir="$(abs_builddir)"' >> $@-t
-	mv $@-t $@
+	@echo "    [PATHS] $@"
+	$(Q) $(RM) $@-t
+	$(Q) cat lib/paths-common > $@-t
+	$(Q) echo 'top_srcdir="$(top_srcdir)"' >> $@-t
+	$(Q) echo 'abs_top_builddir="$(abs_top_builddir)"' >> $@-t
+	$(Q) echo 'abs_top_srcdir="$(abs_top_srcdir)"' >> $@-t
+	$(Q) echo 'abs_srcdir="$(abs_srcdir)"' >> $@-t
+	$(Q) echo 'abs_builddir="$(abs_builddir)"' >> $@-t
+	$(Q) mv $@-t $@
 
 lib/version-expected: $(top_srcdir)/VERSION .lib-dir-stamp
-	cut -f 1 -d ' ' <$< >$@
+	$(Q) cut -f 1 -d ' ' <$< >$@
 
 lib/dm-version-expected: $(top_srcdir)/VERSION_DM .lib-dir-stamp
-	cut -f 1 -d ' ' <$< >$@
+	$(Q) cut -f 1 -d ' ' <$< >$@
 
 CMDS = lvm $(shell cat $(top_builddir)/tools/.commands 2>/dev/null)
 LIB = $(addprefix lib/, $(LIB_SECURETEST) $(LIB_DMSECURETEST) $(LIB_SHARED) $(LIB_LOCAL) $(LIB_NOT) $(LIB_LINK_NOT) $(LIB_FLAVOURS))
 
 .tests-stamp: $(ALL) $(LIB) $(SUBDIRS) lib/version-expected lib/dm-version-expected
+	@echo "    [TEST-STAMP]"
 	@if test "$(srcdir)" != . ; then \
 		echo "Linking tests to builddir."; \
 		$(MKDIR_P) shell; \
 		for f in $(subst $(srcdir)/,,$(ALL)); do \
+			test -n "$(Q)" || echo "$(LN_S) -f $(abs_top_srcdir)/test/$$f $$f"; \
 			$(LN_S) -f $(abs_top_srcdir)/test/$$f $$f; \
 		done; \
 	fi
-	@$(MKDIR_P) -m a=rwx $(LVM_TEST_RESULTS)
-	touch $@
+	$(Q) $(MKDIR_P) -m a=rwx $(LVM_TEST_RESULTS)
+	$(Q) touch $@
 
 .lib-dir-stamp:
-	$(MKDIR_P) lib unit
-	$(RM) lib/clvmd
-	for i in $(CMDS); do $(LN_S) -f lvm-wrapper lib/$$i; done
-	for i in daemons/dmeventd/dmeventd \
+	@echo "    [LIB-STAMP]"
+	$(Q) $(MKDIR_P) lib unit
+	$(Q) $(RM) lib/clvmd
+	@for i in $(CMDS); do \
+		test -n "$(Q)" || echo "$(LN_S) -f lvm-wrapper lib/$$i"; \
+		$(LN_S) -f lvm-wrapper lib/$$i; done
+	@for i in daemons/dmeventd/dmeventd \
 		libdm/dm-tools/dmsetup \
 		daemons/lvmpolld/lvmpolld ; do \
+		test -n "$(Q)" || echo "$(LN_S) -f $(abs_top_builddir)/$$i lib/"; \
 		$(LN_S) -f $(abs_top_builddir)/$$i lib/; done
-	$(LN_S) -f $(abs_top_builddir)/libdm/dm-tools/dmsetup lib/dmstats
-	$(LN_S) -f $(abs_top_srcdir)/conf/lvmdbusd.profile lib/
-	$(LN_S) -f $(abs_top_srcdir)/conf/thin-performance.profile lib/
-	$(LN_S) -f $(abs_top_srcdir)/scripts/fsadm.sh lib/fsadm
-	test "$(srcdir)" = . || \
+	$(Q) $(LN_S) -f $(abs_top_builddir)/libdm/dm-tools/dmsetup lib/dmstats
+	$(Q) $(LN_S) -f $(abs_top_srcdir)/conf/lvmdbusd.profile lib/
+	$(Q) $(LN_S) -f $(abs_top_srcdir)/conf/thin-performance.profile lib/
+	$(Q) $(LN_S) -f $(abs_top_srcdir)/scripts/fsadm.sh lib/fsadm
+	@test "$(srcdir)" = . || \
 		for i in $(LIB_LVMLOCKD_CONF) $(LIB_MKE2FS_CONF); do \
+			test -n "$(Q)" || echo "$(LN_S) -f $(abs_top_srcdir)/test/lib/$$i lib/"; \
 			$(LN_S) -f $(abs_top_srcdir)/test/lib/$$i lib/; done
-	touch $@
+	$(Q) touch $@
 
 Makefile: $(srcdir)/Makefile.in $(top_builddir)/config.status
 	cd $(top_builddir) && $(SHELL) ./config.status $(subdir)/$@
diff --git a/tools/Makefile.in b/tools/Makefile.in
index e21ca63..4be1f72 100644
--- a/tools/Makefile.in
+++ b/tools/Makefile.in
@@ -133,7 +133,7 @@ man-generator.c: command.c
 
 man-generator: man-generator.o
 	@echo "    [CC] $@"
-	$(CC) $(CFLAGS) -o $@ $<
+	$(Q) $(CC) $(CFLAGS) -o $@ $<
 
 lvm.static: $(OBJECTS) lvm-static.o $(top_builddir)/lib/liblvm-internal.a $(INTERNAL_LIBS)
 	@echo "    [CC] $@"
@@ -225,7 +225,7 @@ install_tools_dynamic: lvm .commands
 	$(Q) $(INSTALL_PROGRAM) -D lvm $(sbindir)/lvm
 	@echo Creating symbolic links for individual commands in $(sbindir)
 	@for v in `cat .commands`; do \
-		echo "$(LN_S) -f lvm $(sbindir)/$$v"; \
+		test -n "$(Q)" || echo "$(LN_S) -f lvm $(sbindir)/$$v"; \
 		$(LN_S) -f lvm $(sbindir)/$$v; \
 	done;
 
diff --git a/udev/Makefile.in b/udev/Makefile.in
index 6f57d46..81c2c7b 100644
--- a/udev/Makefile.in
+++ b/udev/Makefile.in
@@ -55,10 +55,11 @@ PVSCAN_ACTION=add
 endif
 
 %.rules: $(srcdir)/%.rules.in
-	$(SED) -e "s+(DM_DIR)+$(DM_DIR)+;s+(BINDIR)+$(BINDIR)+;s+(BLKID_RULE)+$(BLKID_RULE)+;s+(PVSCAN_RULE)+$(PVSCAN_RULE)+;s+(PVSCAN_ACTION)+$(PVSCAN_ACTION)+;s+(DM_EXEC_RULE)+$(DM_EXEC_RULE)+;s+(DM_EXEC)+$(DM_EXEC)+;s+(LVM_EXEC_RULE)+$(LVM_EXEC_RULE)+;s+(LVM_EXEC)+$(LVM_EXEC)+;" $< >$@
+	$(Q) $(SED) -e "s+(DM_DIR)+$(DM_DIR)+;s+(BINDIR)+$(BINDIR)+;s+(BLKID_RULE)+$(BLKID_RULE)+;s+(PVSCAN_RULE)+$(PVSCAN_RULE)+;s+(PVSCAN_ACTION)+$(PVSCAN_ACTION)+;s+(DM_EXEC_RULE)+$(DM_EXEC_RULE)+;s+(DM_EXEC)+$(DM_EXEC)+;s+(LVM_EXEC_RULE)+$(LVM_EXEC_RULE)+;s+(LVM_EXEC)+$(LVM_EXEC)+;" $< >$@
 
 %_install: %.rules
-	$(INSTALL_DATA) -D $< $(udevdir)/$(<F)
+	@echo "    [INSTALL] $<"
+	$(Q) $(INSTALL_DATA) -D $< $(udevdir)/$(<F)
 
 all: $(DM_RULES) $(LVM_RULES)
 CLEAN_TARGETS = $(DM_RULES) $(LVM_RULES)


