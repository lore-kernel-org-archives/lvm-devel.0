From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 14 Jun 2018 18:49:22 -0400
Subject: master - tests: more tolerable makefile
Message-ID: <201806142249.w5EMnMgG023462@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2a7f2a3a244dd02cacb947b19f7400b53dd71ca4
Commit:        2a7f2a3a244dd02cacb947b19f7400b53dd71ca4
Parent:        7d8bd97187b5eb8bbea10d95bc62b4a14c5e4d4e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 15 00:46:54 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 15 00:46:54 2018 +0200

tests: more tolerable makefile

---
 test/Makefile.in |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index 48ecdd7..39093bf 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -239,7 +239,7 @@ LIB_LVMLOCKD_CONF = \
  test-dlm-conf \
  test-sanlock-conf
 
-LIB_LOCAL = paths runner
+LIB_LOCAL = paths runner mke2fs.conf
 LIB_NOT = not
 LIB_LINK_NOT = invalid fail should
 LIB_SHARED = check aux inittest utils get lvm-wrapper
@@ -250,8 +250,8 @@ install: .tests-stamp lib/paths-installed
 	$(INSTALL_DATA) shell/*.sh $(DATADIR)/shell
 	$(INSTALL_DATA) unit/*.sh $(DATADIR)/unit
 	$(INSTALL_DATA) lib/mke2fs.conf $(DATADIR)/lib
-	$(INSTALL_PROGRAM) unit/unit-test $(DATADIR)/unit
-	$(INSTALL_PROGRAM) dbus/*.py $(DATADIR)/dbus/
+	-$(INSTALL_PROGRAM) unit/unit-test $(DATADIR)/unit
+	-$(INSTALL_PROGRAM) dbus/*.py $(DATADIR)/dbus/
 	$(INSTALL_DATA) lib/paths-installed $(DATADIR)/lib/paths
 	cd lib && $(INSTALL_DATA) \
 		$(LIB_FLAVOURS) \
@@ -340,6 +340,9 @@ lib/version-expected: $(top_srcdir)/VERSION .lib-dir-stamp
 lib/dm-version-expected: $(top_srcdir)/VERSION_DM .lib-dir-stamp
 	cut -f 1 -d ' ' <$< >$@
 
+lib/mke2fs.conf: $(srcdir)/lib/mke2fs.conf
+	$(LN_S) -f $< $@
+
 CMDS = lvm $(shell cat $(top_builddir)/tools/.commands 2>/dev/null)
 LIB = $(addprefix lib/, $(LIB_SHARED) $(LIB_LOCAL) $(LIB_NOT) $(LIB_LINK_NOT) $(LIB_FLAVOURS))
 


