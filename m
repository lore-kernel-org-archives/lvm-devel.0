From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed,  7 Sep 2022 13:04:51 +0000 (GMT)
Subject: main - tests: rework makefile
Message-ID: <20220907130451.B1B643858428@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=acbeaa7a8d86acc0f0e3c04723d066d995f29fe5
Commit:        acbeaa7a8d86acc0f0e3c04723d066d995f29fe5
Parent:        2c7b9130499d17a657684fb3c762d608b50d139e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 1 10:06:14 2022 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 7 14:58:01 2022 +0200

tests: rework makefile

Improve dependency tracking
Use 'foreach()' with better tracing support
Link whole 'shell' dir instead of linking individual *.sh files
---
 test/Makefile.in | 213 +++++++++++++++++++++++++------------------------------
 1 file changed, 95 insertions(+), 118 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index f69dc97b6..1cad634b8 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -28,28 +28,27 @@ datarootdir = @datarootdir@
 LVM_TEST_RESULTS ?= results
 
 # FIXME: resolve testing of: unit
-SOURCES = lib/not.c lib/harness.c lib/dmsecuretest.c
-CXXSOURCES = lib/runner.cpp
+SOURCES := lib/not.c lib/harness.c lib/dmsecuretest.c
+CXXSOURCES := lib/runner.cpp
 CXXFLAGS += $(EXTRA_EXEC_CFLAGS)
 
 CLEAN_DIRS += dbus/__pycache__ $(LVM_TEST_RESULTS)
 ifneq (.,$(firstword $(srcdir)))
 CLEAN_TARGETS += $(RUN_BASE) $(addprefix lib/,$(LIB_LVMLOCKD_CONF) $(LIB_MKE2FS_CONF))
 endif
+CLEAN_TARGETS += $(shell find -H lib -type l) \
+	$(CXXSOURCES:%.cpp=%.o) $(CXXSOURCES:%.cpp=%.d) $(CXXSOURCES:%.cpp=%.gcno) $(CXXSOURCES:%.cpp=%.gcda)
 
 CLEAN_TARGETS += .lib-dir-stamp .tests-stamp $(LIB) $(addprefix lib/,\
-	$(CMDS) clvmd dmeventd dmsetup dmstats lvmpolld \
-	harness lvmdbusd.profile thin-performance.profile fsadm \
-	dm-version-expected version-expected \
+	clvmd harness dmeventd dmsetup dmstats lvmpolld \
+	$(LVM_PROFILES) $(LVM_SCRIPTS) \
 	paths-installed paths-installed-t paths-common paths-common-t)
 
-
 include $(top_builddir)/make.tmpl
 
 T ?= .
 S ?= @ # never match anything by default
 VERBOSE ?= 0
-ALL := $(shell find -L $(srcdir) \( -path \*/shell/\*.sh -or -path \*/api/\*.sh -or -path \*/unit/\*.sh \) | $(SORT))
 comma = ,
 RUN := $(shell find -L $(srcdir) -regextype posix-egrep \( -path \*/shell/\*.sh -or -path \*/api/\*.sh -or -path \*/unit/\*.sh \) -and -regex "$(srcdir)/.*($(subst $(comma),|,$(T))).*" -and -not -regex "$(srcdir)/.*($(subst $(comma),|,$(S))).*" | $(SORT))
 RUN_BASE = $(subst $(srcdir)/,,$(RUN))
@@ -161,38 +160,32 @@ check_lvmlockd_sanlock: .tests-stamp
 	VERBOSE=$(VERBOSE) ./lib/runner \
 		--testdir . --outdir $(LVM_TEST_RESULTS) \
 		--flavours udev-lvmlockd-sanlock --only shell/aa-lvmlockd-sanlock-prepare.sh,$(T),shell/zz-lvmlockd-sanlock-remove.sh --skip $(S)
-endif
 
-ifeq ("@BUILD_LVMLOCKD@", "yes")
 check_lvmlockd_dlm: .tests-stamp
 	VERBOSE=$(VERBOSE) ./lib/runner \
 		--testdir . --outdir $(LVM_TEST_RESULTS) \
 		--flavours udev-lvmlockd-dlm --only shell/aa-lvmlockd-dlm-prepare.sh,$(T),shell/zz-lvmlockd-dlm-remove.sh --skip $(S)
-endif
 
-ifeq ("@BUILD_LVMLOCKD@", "yes")
 check_lvmlockd_idm: .tests-stamp lib/idm_inject_failure
 	$(INSTALL_PROGRAM) lib/idm_inject_failure $(EXECDIR)
 	VERBOSE=$(VERBOSE) ./lib/runner \
 		--testdir . --outdir $(LVM_TEST_RESULTS) \
 		--flavours udev-lvmlockd-idm --only shell/aa-lvmlockd-idm-prepare.sh,$(T),shell/zz-lvmlockd-idm-remove.sh --skip $(S)
-endif
 
-ifeq ("@BUILD_LVMLOCKD@", "yes")
 check_lvmlockd_test: .tests-stamp
 	VERBOSE=$(VERBOSE) ./lib/runner \
 		--testdir . --outdir $(LVM_TEST_RESULTS) \
 		--flavours udev-lvmlockd-test --only $(T) --skip $(S)
 endif
 
-run-unit-test unit-test:
-	@echo "    [MAKE] $<"
-	$(Q) $(MAKE) -C $(top_builddir) $(@)
+run-unit-test unit-test unit/unit-test:
+	@echo "    [MAKE] $(@F)"
+	$(Q) $(MAKE) -C $(top_builddir) $(@F)
 
-DATADIR = $(datadir)/lvm2-testsuite
-EXECDIR = $(libexecdir)/lvm2-testsuite
+DATADIR := $(datadir)/lvm2-testsuite
+EXECDIR := $(libexecdir)/lvm2-testsuite
 
-LIB_FLAVOURS = \
+LIB_FLAVOURS :=\
  flavour-ndev-lvmpolld\
  flavour-ndev-vanilla\
  flavour-ndev-devicesfile\
@@ -203,98 +196,96 @@ LIB_FLAVOURS = \
  flavour-udev-lvmlockd-test\
  flavour-udev-vanilla
 
-LIB_LVMLOCKD_CONF = \
+LIB_LVMLOCKD_CONF :=\
  test-corosync-conf \
  test-dlm-conf \
  test-sanlock-conf
 
-LIB_MKE2FS_CONF = \
-  mke2fs.conf
+LIB_MKE2FS_CONF := mke2fs.conf
+
+LVM_TOOLS :=\
+ daemons/dmeventd/dmeventd\
+ daemons/lvmpolld/lvmpolld\
+ libdm/dm-tools/dmsetup
+
+LVM_PROFILES := $(addsuffix .profile,\
+ cache-mq\
+ cache-smq\
+ lvmdbusd\
+ thin-performance)
 
-LIB_SECURETEST = securetest
-LIB_DMSECURETEST = dmsecuretest
-LIB_LOCAL = paths runner
-LIB_NOT = not
-LIB_LINK_NOT = invalid fail should
-LIB_SHARED = check aux inittest utils get lvm-wrapper
+LIB_LINK_NOT := invalid fail should
+LIB_LOCAL := paths runner
+LIB_NOT := not
+LIB_SHARED := check aux inittest utils get lvm-wrapper lvm_vdo_wrapper
+LIB_CONF := $(LIB_LVMLOCKD_CONF) $(LIB_MKE2FS_CONF)
+LIB_DATA := $(LIB_FLAVOURS) dm-version-expected version-expected
+LIB_EXEC := $(LIB_NOT) dmsecuretest securetest
+LVM_SCRIPTS := fsadm lvm_import_vdo
 
 install: .tests-stamp lib/paths-installed
-	@echo $(srcdir)
+	$(SHOW) "    [INSTALL] tests"
 	$(Q) $(INSTALL_DIR) $(DATADIR)/{shell,api,unit,lib,dbus} $(EXECDIR)
 	$(Q) $(INSTALL_DATA) shell/*.sh $(DATADIR)/shell
-	$(INSTALL_DATA) api/*.sh $(DATADIR)/api
+	$(Q) $(INSTALL_DATA) api/*.sh $(DATADIR)/api
 	$(Q) $(INSTALL_DATA) unit/*.sh $(DATADIR)/unit
-	-$(Q) $(INSTALL_PROGRAM) unit/unit-test $(DATADIR)/unit
-	-$(Q) $(INSTALL_PROGRAM) dbus/*.py $(DATADIR)/dbus/
-	$(INSTALL_DATA) lib/paths-installed $(DATADIR)/lib/paths
-	cd lib && $(INSTALL_DATA) \
-		$(LIB_FLAVOURS) \
-		$(LIB_LVMLOCKD_CONF) \
-		$(LIB_MKE2FS_CONF) \
-		dm-version-expected \
-		version-expected \
-		$(DATADIR)/lib
-	@for i in cache-mq cache-smq thin-performance lvmdbusd ; do \
-		echo "$(INSTALL_DATA) $(abs_top_srcdir)/conf/$$i.profile $(DATADIR)/lib"; \
-		$(INSTALL_DATA) $(abs_top_srcdir)/conf/$$i.profile $(DATADIR)/lib; done
-	cd lib && $(INSTALL_SCRIPT) $(LIB_SHARED) $(DATADIR)/lib
-	@cd $(DATADIR)/lib && for i in $(CMDS); do \
-		echo "$(LN_S) -f lvm-wrapper $$i"; \
-		$(LN_S) -f lvm-wrapper $$i; done
-	$(INSTALL_PROGRAM) lib/$(LIB_NOT) lib/$(LIB_SECURETEST) lib/$(LIB_DMSECURETEST) $(EXECDIR)
-	@cd $(EXECDIR) && for i in $(LIB_LINK_NOT); do \
-		echo "$(LN_S) -f not $$i"; \
-		$(LN_S) -f not $$i; done
+	$(Q)- $(INSTALL_PROGRAM) unit/unit-test $(DATADIR)/unit
+	$(Q)- $(INSTALL_PROGRAM) dbus/*.py $(DATADIR)/dbus/
+	$(Q) $(INSTALL_DATA) lib/paths-installed $(DATADIR)/lib/paths
+	$(Q) cd lib &&\
+		$(INSTALL_DATA) $(LIB_DATA) $(DATADIR)/lib
+	$(Q) cd lib &&\
+		$(INSTALL_SCRIPT) $(LIB_SHARED) $(DATADIR)/lib
+	$(Q) cd lib &&\
+		$(INSTALL_PROGRAM) -D $(LIB_EXEC) $(EXECDIR)
+	$(Q) cd $(abs_top_srcdir)/conf &&\
+		$(INSTALL_DATA) $(LVM_PROFILES) $(DATADIR)/lib
+	$(Q) cd $(DATADIR)/lib &&\
+		$(foreach FILE, $(CMDS), $(LN_S) -f lvm-wrapper $(FILE) $(newline))
+	$(Q) cd $(EXECDIR) &&\
+		$(foreach FILE, $(LIB_LINK_NOT), $(LN_S) -f $(LIB_NOT) $(FILE) $(newline))
 	$(Q) $(INSTALL_PROGRAM) -D lib/runner $(bindir)/lvm2-testsuite
 
-lib/should: lib/not
-	@echo "    [LN] $@"
-	$(Q) $(LN_S) -f not lib/should
-
-lib/invalid: lib/not
-	@echo "    [LN] $@"
-	$(Q) $(LN_S) -f not lib/invalid
-
-lib/fail: lib/not
-	@echo "    [LN] $@"
-	$(Q) $(LN_S) -f not lib/fail
+lib/should lib/invalid lib/fail: lib/not
+	$(SHOW) "    [LN] $@"
+	$(Q) $(LN_S) -f $(<F) $@
 
 lib/runner: lib/runner.o .lib-dir-stamp
-	@echo "    [CXX] $@"
-	$(Q) $(CXX) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) -o $@ $<
-
-lib/dmsecuretest: lib/dmsecuretest.o .lib-dir-stamp $(INTERNAL_LIBS)
-	@echo "    [CC] $@"
-	$(Q) $(CC) -g $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) -o $@ $< $(INTERNAL_LIBS) $(LIBS)
+	$(SHOW) "    [LD] $@"
+	$(Q) $(CXX) $(CXXFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) -o $@ $<
 
 lib/securetest: lib/dmsecuretest.o .lib-dir-stamp
-	@echo "    [CC] $@"
-	$(Q) $(CC) -g $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) -o $@ $< -L$(interfacebuilddir) -ldevmapper $(LIBS)
-
-lib/idm_inject_failure: lib/idm_inject_failure.o .lib-dir-stamp
-	@echo "    [CC] $@"
-	$(Q) $(CC) -g $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) -o $@ $< $(INTERNAL_LIBS) $(LIBS) -lseagate_ilm
+	$(SHOW) "    [LD] $@"
+	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) -o $@ $< -L$(interfacebuilddir) -ldevmapper $(LIBS)
 
+lib/not: lib/not.o
 lib/runner.o: $(wildcard $(srcdir)/lib/*.h)
 
-CFLAGS_runner.o += $(EXTRA_EXEC_CFLAGS)
-CFLAGS_dmsecuretest.o += $(EXTRA_EXEC_CFLAGS)
+CFLAGS_lib/runner.o += $(EXTRA_EXEC_CFLAGS)
+CFLAGS_lib/dmsecuretest.o += $(EXTRA_EXEC_CFLAGS)
+LDFLAGS_lib/dmsecuretest += $(EXTRA_EXEC_LDFLAGS) $(INTERNAL_LIBS) $(LIBS)
+LDFLAGS_lib/idm_inject_failure += $(INTERNAL_LIBS) $(LIBS) -lseagate_ilm
 
 lib/%: lib/%.o .lib-dir-stamp
-	@echo "    [CC] $@"
-	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) $(ELDFLAGS) -o $@ $<
+	$(SHOW) "    [LD] $@"
+	$(Q) $(CC) $(CFLAGS) $(LDFLAGS) $(ELDFLAGS) -o $@ $< $(LDFLAGS_$@)
 
 lib/%: $(srcdir)/lib/%.sh .lib-dir-stamp
-	@echo "    [CP] $@"
+	$(SHOW) "    [CP] $@"
+	$(Q) cp $< $@
+	$(Q) $(CHMOD) +x $@
+
+lib/%: $(top_srcdir)/scripts/%.sh .lib-dir-stamp
+	$(SHOW) "    [CP] $@"
 	$(Q) cp $< $@
 	$(Q) $(CHMOD) +x $@
 
 lib/flavour-%: $(srcdir)/lib/flavour-%.sh .lib-dir-stamp
-	@echo "    [FLAVOUR] $<"
+	$(SHOW) "    [FLAVOUR] $<"
 	$(Q) cp $< $@
 
-lib/paths-common: $(srcdir)/Makefile.in .lib-dir-stamp Makefile
-	@echo "    [PATHS] $@"
+lib/paths-common: $(srcdir)/Makefile.in Makefile .lib-dir-stamp
+	$(SHOW) "    [PATHS] $@"
 	$(Q) echo 'DM_UDEV_SYNCHRONISATION=$(dm_udev_synchronisation)' >> $@-t
 	$(Q) echo 'LVMPOLLD_PIDFILE="@LVMPOLLD_PIDFILE@"' >> $@-t
 	$(Q) echo 'DMEVENTD_PIDFILE="@DMEVENTD_PIDFILE@"' >> $@-t
@@ -312,7 +303,7 @@ lib/paths-common: $(srcdir)/Makefile.in .lib-dir-stamp Makefile
 	$(Q) mv $@-t $@
 
 lib/paths-installed: lib/paths-common
-	@echo "    [PATHS] $@"
+	$(SHOW) "    [PATHS] $@"
 	$(Q) $(RM) $@-t
 	$(Q) cat lib/paths-common > $@-t
 	$(Q) echo 'installed_testsuite=1' >> $@-t
@@ -320,7 +311,7 @@ lib/paths-installed: lib/paths-common
 	$(Q) mv $@-t $@
 
 lib/paths: lib/paths-common
-	@echo "    [PATHS] $@"
+	$(SHOW) "    [PATHS] $@"
 	$(Q) $(RM) $@-t
 	$(Q) cat lib/paths-common > $@-t
 	$(Q) echo 'top_srcdir="$(top_srcdir)"' >> $@-t
@@ -336,44 +327,30 @@ lib/version-expected: $(top_srcdir)/VERSION .lib-dir-stamp
 lib/dm-version-expected: $(top_srcdir)/VERSION_DM .lib-dir-stamp
 	$(Q) cut -f 1 -d ' ' <$< >$@
 
-CMDS = lvm $(shell cat $(top_builddir)/tools/.commands 2>/dev/null)
-LIB = $(addprefix lib/, $(LIB_SECURETEST) $(LIB_DMSECURETEST) $(LIB_SHARED) $(LIB_LOCAL) $(LIB_NOT) $(LIB_LINK_NOT) $(LIB_FLAVOURS))
-
-.tests-stamp: .lib-dir-stamp $(ALL) $(LIB) $(SUBDIRS) lib/version-expected lib/dm-version-expected unit-test
-	@echo "    [TEST-STAMP]"
-	@if test "$(srcdir)" != . ; then \
-		echo "Linking tests to builddir."; \
-		$(MKDIR_P) shell; \
-		for f in $(subst $(srcdir)/,,$(ALL)); do \
-			test -n "$(Q)" || echo "$(LN_S) -f $(abs_top_srcdir)/test/$$f $$f"; \
-			$(LN_S) -f $(abs_top_srcdir)/test/$$f $$f; \
-		done; \
-	fi
+CMDS := lvm $(shell cat $(abs_top_builddir)/tools/.commands 2>/dev/null)
+LIB := $(addprefix lib/, $(LVM_SCRIPTS) $(LIB_SHARED) $(LIB_LOCAL) $(LIB_EXEC) $(LIB_LINK_NOT) $(LIB_DATA))
+
+.tests-stamp: .lib-dir-stamp $(LIB) $(SUBDIRS)
+	$(SHOW) "    [TESTS-STAMP]"
+ifneq (.,$(firstword $(srcdir)))
+	$(SHOW) "    Linking tests to builddir."
+	$(Q) $(LN_S) -f $(srcdir)/shell
+endif
 	$(Q) $(MKDIR_P) -m a=rwx $(LVM_TEST_RESULTS)
 	$(Q) touch $@
 
-.lib-dir-stamp:
-	@echo "    [LIB-STAMP]"
-	$(Q) $(MKDIR_P) lib unit
+.lib-dir-stamp: unit/unit-test
+	$(SHOW) "    [LIB-DIR-STAMP]"
+	$(Q) $(MKDIR_P) api lib unit
 	$(Q) $(RM) lib/clvmd
-	@for i in $(CMDS); do \
-		test -n "$(Q)" || echo "$(LN_S) -f lvm-wrapper lib/$$i"; \
-		$(LN_S) -f lvm-wrapper lib/$$i; done
-	@for i in daemons/dmeventd/dmeventd \
-		libdm/dm-tools/dmsetup \
-		daemons/lvmpolld/lvmpolld ; do \
-		test -n "$(Q)" || echo "$(LN_S) -f $(abs_top_builddir)/$$i lib/"; \
-		$(LN_S) -f $(abs_top_builddir)/$$i lib/; done
-	$(Q) $(LN_S) -f $(abs_top_builddir)/libdm/dm-tools/dmsetup lib/dmstats
-	$(Q) $(LN_S) -f $(abs_top_srcdir)/conf/lvmdbusd.profile lib/
-	$(Q) $(LN_S) -f $(abs_top_srcdir)/conf/thin-performance.profile lib/
-	$(Q) $(LN_S) -f $(abs_top_srcdir)/scripts/fsadm.sh lib/fsadm
-	$(Q) $(LN_S) -f $(abs_top_srcdir)/scripts/lvm_import_vdo.sh lib/lvm_import_vdo
-	$(Q) which vdo || $(LN_S) -f $(abs_top_srcdir)/test/lib/lvm_vdo_wrapper.sh lib/vdo
-	@test "$(srcdir)" = . || \
-		for i in $(LIB_LVMLOCKD_CONF) $(LIB_MKE2FS_CONF); do \
-			test -n "$(Q)" || echo "$(LN_S) -f $(abs_top_srcdir)/test/lib/$$i lib/"; \
-			$(LN_S) -f $(abs_top_srcdir)/test/lib/$$i lib/; done
+	$(Q) $(LN_S) -f dmsetup lib/dmstats
+	$(Q) $(foreach FILE, $(CMDS), $(LN_S) -f lvm-wrapper lib/$(FILE) $(newline))
+	$(Q) $(foreach FILE, $(LVM_TOOLS), $(LN_S) -f $(abs_top_builddir)/$(FILE) lib/ $(newline))
+	$(Q) $(LN_S) -f $(addprefix $(abs_top_srcdir)/conf/, $(LVM_PROFILES)) lib/
+ifneq (.,$(firstword $(srcdir)))
+	$(Q) $(LN_S) -f $(addprefix $(abs_top_srcdir)/test/lib/,\
+			$(LIB_LVMLOCKD_CONF) $(LIB_MKE2FS_CONF)) lib/
+endif
 	$(Q) touch $@
 
 Makefile: $(srcdir)/Makefile.in $(top_builddir)/config.status

