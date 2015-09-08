From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  8 Sep 2015 13:41:41 +0000 (UTC)
Subject: master - tests: better check for compiled version
Message-ID: <20150908134141.627BB605B2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6cb7f21e385178a7928635fc9531e2f6d8a91aac
Commit:        6cb7f21e385178a7928635fc9531e2f6d8a91aac
Parent:        8ff43c3705573043e2fa8ce68c2f052273cce205
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 8 14:11:06 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 8 15:41:34 2015 +0200

tests: better check for compiled version

Use install /lib files to check for expected version.
---
 test/Makefile.in        |   15 ++++++++++-----
 test/shell/000-basic.sh |    9 ++-------
 2 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index 769f931..f258cde 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -197,15 +197,17 @@ LIB_NOT = not
 LIB_LINK_NOT = invalid fail should
 LIB_SHARED = check aux inittest utils get lvm-wrapper
 
-install: .tests-stamp lib/paths-installed
+install: .tests-stamp lib/paths-installed lib/version-expected
 	@echo $(srcdir)
 	$(INSTALL_DIR) $(DATADIR)/{shell,api,lib} $(EXECDIR)
 	$(INSTALL_DATA) shell/*.sh $(DATADIR)/shell
 	$(INSTALL_DATA) api/*.sh $(DATADIR)/api
 	$(INSTALL_PROGRAM) api/*.{t,py} $(DATADIR)/api
 	$(INSTALL_DATA) lib/paths-installed $(DATADIR)/lib/paths
-	cd lib && $(INSTALL_DATA) $(LIB_FLAVOURS) $(DATADIR)/lib
-	cd lib && $(INSTALL_DATA) $(LIB_LVMLOCKD_CONF) $(DATADIR)/lib
+	cd lib && $(INSTALL_DATA) \
+		$(LIB_FLAVOURS) \
+		$(LIB_LVMLOCKD_CONF) \
+		version-expected $(DATADIR)/lib
 	@for i in cache-mq cache-smq thin-performance ; do \
 		echo "$(INSTALL_DATA) $(abs_top_srcdir)/conf/$$i.profile $(DATADIR)/lib"; \
 		$(INSTALL_DATA) $(abs_top_srcdir)/conf/$$i.profile $(DATADIR)/lib; done
@@ -281,10 +283,13 @@ lib/paths: lib/paths-common
 	echo 'abs_builddir="$(abs_builddir)"' >> $@-t
 	mv $@-t $@
 
+lib/version-expected: $(top_srcdir)/VERSION .lib-dir-stamp
+	cut -f 1 -d ' ' <$< >$@
+
 CMDS = lvm $(shell cat $(top_builddir)/tools/.commands 2>/dev/null)
 LIB = $(addprefix lib/, $(LIB_SHARED) $(LIB_LOCAL) $(LIB_NOT) $(LIB_LINK_NOT) $(LIB_FLAVOURS))
 
-.tests-stamp: $(ALL) $(LIB) $(SUBDIRS)
+.tests-stamp: $(ALL) $(LIB) $(SUBDIRS) lib/version-expected
 	@if test "$(srcdir)" != . ; then \
 		echo "Linking tests to builddir."; \
 		$(MKDIR_P) shell; \
@@ -316,7 +321,7 @@ endif
 
 CLEAN_TARGETS += .lib-dir-stamp .tests-stamp $(LIB) $(addprefix lib/,\
 	$(CMDS) clvmd dmeventd dmsetup lvmetad lvmpolld \
-	harness thin-performance.profile fsadm vgimportclone \
+	harness thin-performance.profile fsadm vgimportclone version-expected \
 	paths-installed paths-installed-t paths-common paths-common-t)
 
 Makefile: $(srcdir)/Makefile.in $(top_builddir)/config.status
diff --git a/test/shell/000-basic.sh b/test/shell/000-basic.sh
index 573bbd1..582c5ef 100644
--- a/test/shell/000-basic.sh
+++ b/test/shell/000-basic.sh
@@ -15,15 +15,10 @@ test -e LOCAL_LVMPOLLD && skip
 
 lvm version
 
-test -n "$abs_top_builddir" || skip
-
-v=$abs_top_builddir/lib/misc/lvm-version.h
-sed -n "/#define LVM_VERSION ./s///p" "$v" | sed "s/ .*//" > expected
-
-lvm pvmove --version|sed -n "1s/.*: *\([0-9][^ ]*\) .*/\1/p" > actual
+lvm pvmove --version|sed -n "1s/.*: *\([0-9][^ ]*\) .*/\1/p" | tee version
 
 # ensure they are the same
-diff -u actual expected
+diff -u version lib/version-expected
 
 # ensure we can create devices (uses dmsetup, etc)
 aux prepare_devs 5


