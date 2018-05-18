From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 18 May 2018 10:27:57 -0400
Subject: master - build: set clean vars earlier
Message-ID: <201805181427.w4IERvos012355@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5b86b0e3dca804fce7c3e6adcd636c0a6d341a9b
Commit:        5b86b0e3dca804fce7c3e6adcd636c0a6d341a9b
Parent:        f7435cd8c7bf4c245c9efabbae1274989d2e49ed
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 18 16:15:25 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 18 16:25:44 2018 +0200

build: set clean vars earlier

For better cleaning of test dirs.
---
 daemons/lvmdbusd/Makefile.in |    2 ++
 test/Makefile.in             |   23 ++++++++++++-----------
 2 files changed, 14 insertions(+), 11 deletions(-)

diff --git a/daemons/lvmdbusd/Makefile.in b/daemons/lvmdbusd/Makefile.in
index 7cd7724..7b62e7e 100644
--- a/daemons/lvmdbusd/Makefile.in
+++ b/daemons/lvmdbusd/Makefile.in
@@ -44,6 +44,8 @@ LVMDBUS_BUILDDIR_FILES = \
 
 LVMDBUSD = lvmdbusd
 
+CLEAN_DIRS += __pycache__
+
 include $(top_builddir)/make.tmpl
 
 .PHONY: install_lvmdbusd
diff --git a/test/Makefile.in b/test/Makefile.in
index 407babd..f6345a5 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -32,6 +32,18 @@ SOURCES = lib/not.c lib/harness.c
 CXXSOURCES = lib/runner.cpp
 CXXFLAGS += $(EXTRA_EXEC_CFLAGS)
 
+CLEAN_DIRS += dbus/__pycache__ $(LVM_TEST_RESULTS)
+ifneq (.,$(firstword $(srcdir)))
+CLEAN_TARGETS += $(RUN_BASE) $(addprefix lib/,$(LIB_LVMLOCKD_CONF))
+endif
+
+CLEAN_TARGETS += .lib-dir-stamp .tests-stamp $(LIB) $(addprefix lib/,\
+	$(CMDS) clvmd dmeventd dmsetup dmstats lvmetad lvmpolld \
+	harness lvmdbusd.profile thin-performance.profile fsadm \
+	dm-version-expected version-expected \
+	paths-installed paths-installed-t paths-common paths-common-t)
+
+
 include $(top_builddir)/make.tmpl
 
 T ?= .
@@ -352,17 +364,6 @@ LIB = $(addprefix lib/, $(LIB_SHARED) $(LIB_LOCAL) $(LIB_NOT) $(LIB_LINK_NOT) $(
 		$(LN_S) -f $(abs_top_srcdir)/test/lib/$$i lib/; done
 	touch $@
 
-CLEAN_DIRS += $(LVM_TEST_RESULTS)
-ifneq (.,$(firstword $(srcdir)))
-CLEAN_TARGETS += $(RUN_BASE) $(addprefix lib/,$(LIB_LVMLOCKD_CONF))
-endif
-
-CLEAN_TARGETS += .lib-dir-stamp .tests-stamp $(LIB) $(addprefix lib/,\
-	$(CMDS) clvmd dmeventd dmsetup dmstats lvmetad lvmpolld \
-	harness lvmdbusd.profile thin-performance.profile fsadm \
-	dm-version-expected version-expected \
-	paths-installed paths-installed-t paths-common paths-common-t)
-
 Makefile: $(srcdir)/Makefile.in $(top_builddir)/config.status
 	cd $(top_builddir) && $(SHELL) ./config.status $(subdir)/$@
 


