From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  7 Sep 2015 15:45:28 +0000 (UTC)
Subject: master - tests: update install rules
Message-ID: <20150907154528.2E2FB60E5D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fa4d2ec24139ddc9e5ce69dde20155f308e09335
Commit:        fa4d2ec24139ddc9e5ce69dde20155f308e09335
Parent:        acfc56957c008d30c98ced5fae5f7888ec2a5a22
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 4 16:34:34 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 7 17:44:08 2015 +0200

tests: update install rules

Enhnace 'make install' rules for test suite (used for rpm packaging).
Install lvmlockd conf files.
Compile runner with correct CXXFLAGS.
---
 test/Makefile.in |  106 ++++++++++++++++++++++++++++++------------------------
 1 files changed, 59 insertions(+), 47 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index 2119509..e6860e1 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -30,6 +30,7 @@ LVM_TEST_RESULTS ?= results
 SUBDIRS = api unit
 SOURCES = lib/not.c lib/harness.c
 CXXSOURCES = lib/runner.cpp
+CXXFLAGS += $(EXTRA_EXEC_CFLAGS)
 
 include $(top_builddir)/make.tmpl
 
@@ -171,41 +172,51 @@ DATADIR = $(datadir)/lvm2-testsuite
 EXECDIR = $(libexecdir)/lvm2-testsuite
 
 LIB_FLAVOURS = \
- lib/flavour-ndev-cluster-lvmpolld\
- lib/flavour-ndev-cluster\
- lib/flavour-ndev-lvmetad-lvmpolld\
- lib/flavour-ndev-lvmetad\
- lib/flavour-ndev-lvmpolld\
- lib/flavour-ndev-vanilla\
- lib/flavour-udev-cluster-lvmpolld\
- lib/flavour-udev-cluster\
- lib/flavour-udev-lvmetad-lvmpolld\
- lib/flavour-udev-lvmetad\
- lib/flavour-udev-lvmpolld\
- lib/flavour-udev-lvmlockd-sanlock\
- lib/flavour-udev-lvmlockd-dlm\
- lib/flavour-udev-vanilla
-
-LIB_LOCAL = lib/paths lib/runner
-LIB_EXEC  = lib/not lib/invalid lib/fail lib/should
-LIB_SHARED = lib/check lib/aux lib/inittest lib/utils lib/get lib/lvm-wrapper
+ flavour-ndev-cluster-lvmpolld\
+ flavour-ndev-cluster\
+ flavour-ndev-lvmetad-lvmpolld\
+ flavour-ndev-lvmetad\
+ flavour-ndev-lvmpolld\
+ flavour-ndev-vanilla\
+ flavour-udev-cluster-lvmpolld\
+ flavour-udev-cluster\
+ flavour-udev-lvmetad-lvmpolld\
+ flavour-udev-lvmetad\
+ flavour-udev-lvmpolld\
+ flavour-udev-lvmlockd-sanlock\
+ flavour-udev-lvmlockd-dlm\
+ flavour-udev-vanilla
+
+LIB_LVMLOCKD_CONF = \
+ test-corosync-conf \
+ test-dlm-conf \
+ test-sanlock-conf
+
+LIB_LOCAL = paths runner
+LIB_NOT = not
+LIB_LINK_NOT = invalid fail should
+LIB_SHARED = check aux inittest utils get lvm-wrapper
 
 install: .tests-stamp lib/paths-installed
 	@echo $(srcdir)
-	@echo $(LIB_FLAVOURS)
-	$(INSTALL_DIR) $(DATADIR)/{shell,api,lib}
-	$(INSTALL_DATA) shell/*.sh $(DATADIR)/shell/
-	$(INSTALL_DATA) api/*.sh $(DATADIR)/api/
-	$(INSTALL_PROGRAM) api/*.{t,py} $(DATADIR)/api/
+	$(INSTALL_DIR) $(DATADIR)/{shell,api,lib} $(EXECDIR)
+	$(INSTALL_DATA) shell/*.sh $(DATADIR)/shell
+	$(INSTALL_DATA) api/*.sh $(DATADIR)/api
+	$(INSTALL_PROGRAM) api/*.{t,py} $(DATADIR)/api
 	$(INSTALL_DATA) lib/paths-installed $(DATADIR)/lib/paths
-	$(INSTALL_DATA) $(LIB_FLAVOURS) $(DATADIR)/lib/
-	for i in cache-mq cache-smq thin-performance ; do \
-		$(INSTALL_DATA) $(abs_top_srcdir)/conf/$$i.profile $(DATADIR)/lib/$$i.profile; done
-	$(INSTALL_SCRIPT) $(LIB_SHARED) $(DATADIR)/lib/
-	for i in $(CMDS); do (cd $(DATADIR)/lib && $(LN_S) -f lvm-wrapper $$i); done
-
-	$(INSTALL_DIR) $(EXECDIR)
-	$(INSTALL_PROGRAM) $(LIB_EXEC) $(EXECDIR)
+	cd lib && $(INSTALL_DATA) $(LIB_FLAVOURS) $(DATADIR)/lib
+	cd lib && $(INSTALL_DATA) $(LIB_LVMLOCKD_CONF) $(DATADIR)/lib
+	@for i in cache-mq cache-smq thin-performance ; do \
+		echo "$(INSTALL_DATA) $(abs_top_srcdir)/conf/$$i.profile $(DATADIR)/lib"; \
+		$(INSTALL_DATA) $(abs_top_srcdir)/conf/$$i.profile $(DATADIR)/lib; done
+	cd lib && $(INSTALL_SCRIPT) $(LIB_SHARED) $(DATADIR)/lib
+	@cd $(DATADIR)/lib && for i in $(CMDS); do \
+		echo "$(LN_S) -f lvm-wrapper $$i"; \
+		$(LN_S) -f lvm-wrapper $$i; done
+	$(INSTALL_PROGRAM) lib/$(LIB_NOT) $(EXECDIR)
+	@cd $(EXECDIR) && for i in $(LIB_LINK_NOT); do \
+		echo "$(LN_S) -f not $$i"; \
+		$(LN_S) -f not $$i; done
 	$(INSTALL_PROGRAM) -D lib/runner $(bindir)/lvm2-testsuite
 
 lib/should: lib/not
@@ -218,10 +229,12 @@ lib/fail: lib/not
 	$(LN_S) -f not lib/fail
 
 lib/runner: lib/runner.o .lib-dir-stamp
-	$(CXX) $(LDFLAGS) -o $@ $<
+	$(CXX) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) -o $@ $<
 
 lib/runner.o: $(wildcard $(srcdir)/lib/*.h)
 
+CFLAGS_runner.o += $(EXTRA_EXEC_CFLAGS)
+
 lib/%: lib/%.o .lib-dir-stamp
 	$(CC) $(LDFLAGS) -o $@ $<
 
@@ -269,7 +282,7 @@ lib/paths: lib/paths-common
 	mv $@-t $@
 
 CMDS = lvm $(shell cat $(top_builddir)/tools/.commands)
-LIB = $(LIB_SHARED) $(LIB_LOCAL) $(LIB_EXEC) $(LIB_FLAVOURS)
+LIB = $(addprefix lib/, $(LIB_SHARED) $(LIB_LOCAL) $(LIB_NOT) $(LIB_LINK_NOT) $(LIB_FLAVOURS))
 
 .tests-stamp: $(ALL) $(LIB) $(SUBDIRS)
 	@if test "$(srcdir)" != . ; then \
@@ -285,27 +298,26 @@ LIB = $(LIB_SHARED) $(LIB_LOCAL) $(LIB_EXEC) $(LIB_FLAVOURS)
 .lib-dir-stamp:
 	$(MKDIR_P) lib
 	for i in $(CMDS); do $(LN_S) -f lvm-wrapper lib/$$i; done
-	$(LN_S) -f $(abs_top_builddir)/tools/dmsetup lib/dmsetup
-	$(LN_S) -f $(abs_top_builddir)/daemons/clvmd/clvmd lib/clvmd
-	$(LN_S) -f $(abs_top_builddir)/daemons/dmeventd/dmeventd lib/dmeventd
-	$(LN_S) -f $(abs_top_builddir)/daemons/lvmetad/lvmetad lib/lvmetad
-	$(LN_S) -f $(abs_top_builddir)/daemons/lvmpolld/lvmpolld lib/lvmpolld
-	$(LN_S) -f $(abs_top_srcdir)/scripts/vgimportclone.sh lib/vgimportclone
+	for i in daemons/clvmd/clvmd daemons/dmeventd/dmeventd \
+		tools/dmsetup daemons/lvmetad/lvmetad \
+		daemons/lvmpolld/lvmpolld ; do \
+		$(LN_S) -f $(abs_top_builddir)/$$i lib/; done
+	$(LN_S) -f $(abs_top_srcdir)/conf/thin-performance.profile lib/
 	$(LN_S) -f $(abs_top_srcdir)/scripts/fsadm.sh lib/fsadm
-	$(LN_S) -f $(abs_top_srcdir)/conf/thin-performance.profile lib/thin-performance.profile
+	$(LN_S) -f $(abs_top_srcdir)/scripts/vgimportclone.sh lib/vgimportclone
+	test "$(srcdir)" = . || for i in $(LIB_LVMLOCKD_CONF); do \
+		$(LN_S) -f $(abs_top_srcdir)/test/lib/$$i lib/; done
 	touch $@
 
 CLEAN_DIRS += $(LVM_TEST_RESULTS)
 ifneq (.,$(firstword $(srcdir)))
-CLEAN_TARGETS += $(RUN_BASE)
+CLEAN_TARGETS += $(RUN_BASE) $(addprefix lib/,$(LIB_LVMLOCKD_CONF))
 endif
 
-CLEAN_TARGETS += .lib-dir-stamp .tests-stamp $(LIB) $(addprefix lib/,$(CMDS)) \
-	lib/clvmd lib/dmeventd lib/dmsetup lib/lvmetad lib/fsadm lib/vgimportclone \
-	lib/thin-performance.profile lib/harness \
-	lib/paths-installed lib/paths-installed-t \
-	lib/paths-common lib/paths-common-t \
-	lib/lvmpolld
+CLEAN_TARGETS += .lib-dir-stamp .tests-stamp $(LIB) $(addprefix lib/,\
+	$(CMDS) clvmd dmeventd dmsetup lvmetad lvmpolld \
+	harness thin-performance.profile fsadm vgimportclone \
+	paths-installed paths-installed-t paths-common paths-common-t)
 
 Makefile: $(srcdir)/Makefile.in $(top_builddir)/config.status
 	cd $(top_builddir) && $(SHELL) ./config.status $(subdir)/$@


