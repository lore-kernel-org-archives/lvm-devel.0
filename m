From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 22 Jun 2018 17:38:44 -0400
Subject: master - tests: fix rules for mke2fs.conf install
Message-ID: <201806222138.w5MLcisS018643@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8215e3503d0799211d268c3e2a0f1b648d5f9584
Commit:        8215e3503d0799211d268c3e2a0f1b648d5f9584
Parent:        fa58fc32576a08bf11fa98623473f5e6ec5b6d68
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 22 22:43:58 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 22 23:36:54 2018 +0200

tests: fix rules for mke2fs.conf install

---
 test/Makefile.in |   17 +++++++++--------
 1 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index 39093bf..5b7578c 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -34,7 +34,7 @@ CXXFLAGS += $(EXTRA_EXEC_CFLAGS)
 
 CLEAN_DIRS += dbus/__pycache__ $(LVM_TEST_RESULTS)
 ifneq (.,$(firstword $(srcdir)))
-CLEAN_TARGETS += $(RUN_BASE) $(addprefix lib/,$(LIB_LVMLOCKD_CONF))
+CLEAN_TARGETS += $(RUN_BASE) $(addprefix lib/,$(LIB_LVMLOCKD_CONF) $(LIB_MKE2FS_CONF))
 endif
 
 CLEAN_TARGETS += .lib-dir-stamp .tests-stamp $(LIB) $(addprefix lib/,\
@@ -239,7 +239,10 @@ LIB_LVMLOCKD_CONF = \
  test-dlm-conf \
  test-sanlock-conf
 
-LIB_LOCAL = paths runner mke2fs.conf
+LIB_MKE2FS_CONF = \
+  mke2fs.conf
+
+LIB_LOCAL = paths runner
 LIB_NOT = not
 LIB_LINK_NOT = invalid fail should
 LIB_SHARED = check aux inittest utils get lvm-wrapper
@@ -249,13 +252,13 @@ install: .tests-stamp lib/paths-installed
 	$(INSTALL_DIR) $(DATADIR)/{shell,unit,lib,dbus} $(EXECDIR)
 	$(INSTALL_DATA) shell/*.sh $(DATADIR)/shell
 	$(INSTALL_DATA) unit/*.sh $(DATADIR)/unit
-	$(INSTALL_DATA) lib/mke2fs.conf $(DATADIR)/lib
 	-$(INSTALL_PROGRAM) unit/unit-test $(DATADIR)/unit
 	-$(INSTALL_PROGRAM) dbus/*.py $(DATADIR)/dbus/
 	$(INSTALL_DATA) lib/paths-installed $(DATADIR)/lib/paths
 	cd lib && $(INSTALL_DATA) \
 		$(LIB_FLAVOURS) \
 		$(LIB_LVMLOCKD_CONF) \
+		$(LIB_MKE2FS_CONF) \
 		dm-version-expected \
 		version-expected \
 		$(DATADIR)/lib
@@ -340,9 +343,6 @@ lib/version-expected: $(top_srcdir)/VERSION .lib-dir-stamp
 lib/dm-version-expected: $(top_srcdir)/VERSION_DM .lib-dir-stamp
 	cut -f 1 -d ' ' <$< >$@
 
-lib/mke2fs.conf: $(srcdir)/lib/mke2fs.conf
-	$(LN_S) -f $< $@
-
 CMDS = lvm $(shell cat $(top_builddir)/tools/.commands 2>/dev/null)
 LIB = $(addprefix lib/, $(LIB_SHARED) $(LIB_LOCAL) $(LIB_NOT) $(LIB_LINK_NOT) $(LIB_FLAVOURS))
 
@@ -369,8 +369,9 @@ LIB = $(addprefix lib/, $(LIB_SHARED) $(LIB_LOCAL) $(LIB_NOT) $(LIB_LINK_NOT) $(
 	$(LN_S) -f $(abs_top_srcdir)/conf/lvmdbusd.profile lib/
 	$(LN_S) -f $(abs_top_srcdir)/conf/thin-performance.profile lib/
 	$(LN_S) -f $(abs_top_srcdir)/scripts/fsadm.sh lib/fsadm
-	test "$(srcdir)" = . || for i in $(LIB_LVMLOCKD_CONF); do \
-		$(LN_S) -f $(abs_top_srcdir)/test/lib/$$i lib/; done
+	test "$(srcdir)" = . || \
+		for i in $(LIB_LVMLOCKD_CONF) $(LIB_MKE2FS_CONF); do \
+			$(LN_S) -f $(abs_top_srcdir)/test/lib/$$i lib/; done
 	touch $@
 
 Makefile: $(srcdir)/Makefile.in $(top_builddir)/config.status


