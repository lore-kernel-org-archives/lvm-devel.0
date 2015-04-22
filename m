From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 22 Apr 2015 09:20:32 +0000 (UTC)
Subject: master - tests: install also api test
Message-ID: <20150422092032.C869860B34@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d8874556cde1e0be4ee1d9cf40835d8ee7fe89f2
Commit:        d8874556cde1e0be4ee1d9cf40835d8ee7fe89f2
Parent:        3216a9a8195eb25e369781a4068015ef7c061845
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 22 10:57:42 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 22 10:57:42 2015 +0200

tests: install also api test

Install .t & .py binaries.
On 'make clean'  ensure also -t files are removed.
---
 test/Makefile.in |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index c99f8f2..bf9b58e 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -147,8 +147,10 @@ install: .tests-stamp lib/paths-installed
 	$(INSTALL_DIR) $(DATADIR)/{shell,api,lib}
 	$(INSTALL_DATA) shell/*.sh $(DATADIR)/shell/
 	$(INSTALL_DATA) api/*.sh $(DATADIR)/api/
+	$(INSTALL_PROGRAM) api/*.{t,py} $(DATADIR)/api/
 	$(INSTALL_DATA) lib/paths-installed $(DATADIR)/lib/paths
 	$(INSTALL_DATA) $(LIB_FLAVOURS) $(DATADIR)/lib/
+	$(INSTALL_DATA) $(abs_top_srcdir)/conf/thin-performance.profile $(DATADIR)/lib/thin-performance.profile
 	$(INSTALL_SCRIPT) $(LIB_SHARED) $(DATADIR)/lib/
 	for i in $(CMDS); do (cd $(DATADIR)/lib && ln -fs lvm-wrapper $$i); done
 
@@ -250,7 +252,9 @@ distclean: cleantest
 
 CLEAN_TARGETS += .lib-dir-stamp .tests-stamp $(LIB) $(addprefix lib/,$(CMDS)) \
 	lib/clvmd lib/dmeventd lib/dmsetup lib/lvmetad lib/fsadm lib/vgimportclone \
-	lib/thin-performance.profile lib/paths-common
+	lib/thin-performance.profile lib/harness \
+	lib/paths-installed lib/paths-installed-t \
+	lib/paths-common lib/paths-common-t
 
 Makefile: $(srcdir)/Makefile.in $(top_builddir)/config.status
 	cd $(top_builddir) && $(SHELL) ./config.status $(subdir)/$@


