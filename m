From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 12 May 2015 10:41:31 +0000 (UTC)
Subject: master - makefiles: use LN_S
Message-ID: <20150512104131.E71BB60E21@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=13e87045fdca702e727fe287d66aaf2035cb6318
Commit:        13e87045fdca702e727fe287d66aaf2035cb6318
Parent:        9c2a6de68f776be2b6839960d955c75e749ccc0c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon May 11 21:47:39 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue May 12 12:40:37 2015 +0200

makefiles: use LN_S

---
 test/Makefile.in |   30 +++++++++++++++---------------
 1 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index 91805c2..bf34201 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -1,4 +1,4 @@
-# Copyright (C) 2007-2013 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2007-2015 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -179,20 +179,20 @@ install: .tests-stamp lib/paths-installed
 	$(INSTALL_DATA) $(LIB_FLAVOURS) $(DATADIR)/lib/
 	$(INSTALL_DATA) $(abs_top_srcdir)/conf/thin-performance.profile $(DATADIR)/lib/thin-performance.profile
 	$(INSTALL_SCRIPT) $(LIB_SHARED) $(DATADIR)/lib/
-	for i in $(CMDS); do (cd $(DATADIR)/lib && ln -fs lvm-wrapper $$i); done
+	for i in $(CMDS); do (cd $(DATADIR)/lib && $(LN_S) -f lvm-wrapper $$i); done
 
 	$(INSTALL_DIR) $(EXECDIR)
 	$(INSTALL_PROGRAM) $(LIB_EXEC) $(EXECDIR)
 	$(INSTALL_PROGRAM) -D lib/runner $(bindir)/lvm2-testsuite
 
 lib/should: lib/not
-	ln -sf not lib/should
+	$(LN_S) -f not lib/should
 
 lib/invalid: lib/not
-	ln -sf not lib/invalid
+	$(LN_S) -f not lib/invalid
 
 lib/fail: lib/not
-	ln -sf not lib/fail
+	$(LN_S) -f not lib/fail
 
 lib/runner: lib/runner.o .lib-dir-stamp
 	$(CXX) $(LDFLAGS) -o $@ $<
@@ -253,7 +253,7 @@ LIB = $(LIB_SHARED) $(LIB_LOCAL) $(LIB_EXEC) $(LIB_FLAVOURS)
 		echo "Linking tests to builddir."; \
 		$(MKDIR_P) shell; \
 		for f in $(subst $(srcdir)/,,$(ALL)); do \
-			ln -sf $(abs_top_srcdir)/test/$$f $$f; \
+			$(LN_S) -f $(abs_top_srcdir)/test/$$f $$f; \
 		done; \
 	fi
 	@$(MKDIR_P) -m a=rwx $(LVM_TEST_RESULTS)
@@ -261,15 +261,15 @@ LIB = $(LIB_SHARED) $(LIB_LOCAL) $(LIB_EXEC) $(LIB_FLAVOURS)
 
 .lib-dir-stamp:
 	$(MKDIR_P) lib
-	for i in $(CMDS); do ln -fs lvm-wrapper lib/$$i; done
-	ln -fs $(abs_top_builddir)/tools/dmsetup lib/dmsetup
-	ln -fs $(abs_top_builddir)/daemons/clvmd/clvmd lib/clvmd
-	ln -fs $(abs_top_builddir)/daemons/dmeventd/dmeventd lib/dmeventd
-	ln -fs $(abs_top_builddir)/daemons/lvmetad/lvmetad lib/lvmetad
-	ln -fs $(abs_top_builddir)/daemons/lvmpolld/lvmpolld lib/lvmpolld
-	ln -fs $(abs_top_srcdir)/scripts/vgimportclone.sh lib/vgimportclone
-	ln -fs $(abs_top_srcdir)/scripts/fsadm.sh lib/fsadm
-	ln -fs $(abs_top_srcdir)/conf/thin-performance.profile lib/thin-performance.profile
+	for i in $(CMDS); do $(LN_S) -f lvm-wrapper lib/$$i; done
+	$(LN_S) -f $(abs_top_builddir)/tools/dmsetup lib/dmsetup
+	$(LN_S) -f $(abs_top_builddir)/daemons/clvmd/clvmd lib/clvmd
+	$(LN_S) -f $(abs_top_builddir)/daemons/dmeventd/dmeventd lib/dmeventd
+	$(LN_S) -f $(abs_top_builddir)/daemons/lvmetad/lvmetad lib/lvmetad
+	$(LN_S) -f $(abs_top_builddir)/daemons/lvmpolld/lvmpolld lib/lvmpolld
+	$(LN_S) -f $(abs_top_srcdir)/scripts/vgimportclone.sh lib/vgimportclone
+	$(LN_S) -f $(abs_top_srcdir)/scripts/fsadm.sh lib/fsadm
+	$(LN_S) -f $(abs_top_srcdir)/conf/thin-performance.profile lib/thin-performance.profile
 	touch $@
 
 cleantest:


