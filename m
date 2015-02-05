From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:41:10 +0000 (UTC)
Subject: master - test: Makefile updates.
Message-ID: <20150205134110.B70F760794@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0bd2a9b7b10640d9d16cceb9e753acff6356d5df
Commit:        0bd2a9b7b10640d9d16cceb9e753acff6356d5df
Parent:        b4215f956f4576ce38b19a9a9ca216e9d096fe5a
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Fri Jun 27 01:00:37 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:47:17 2015 +0100

test: Makefile updates.

- make check now uses the new test runner
- the testsuite can be installed (make -C test install)
---
 test/Makefile.in |   88 +++++++++++++++++++++++++++++++++++++----------------
 1 files changed, 61 insertions(+), 27 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index 88644f3..d930888 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -61,7 +61,7 @@ ifeq ("@UDEV_SYNC@", "yes")
 dm_udev_synchronisation = 1
 endif
 
-all: check
+all: .tests-stamp
 
 help:
 	@echo -e "\nAvailable targets:"
@@ -100,33 +100,56 @@ help:
 	@echo "  VERBOSE		Verbose output (1), timing (2)."
 
 check: .tests-stamp
-	VERBOSE=$(VERBOSE) ./lib/runner --testdir shell --outdir results
+	VERBOSE=$(VERBOSE) ./lib/runner \
+		--testdir . --outdir results \
+		--only $(T) --skip $(S)
 
 check_system: .tests-stamp
-	VERBOSE=$(VERBOSE) \
-	scluster_LVM_TEST_LOCKING=3 \
-	slvmetad_LVM_TEST_LVMETAD=1 \
-	snormal_LVM_TEST_DEVDIR=/dev \
-	scluster_LVM_TEST_DEVDIR=/dev \
-	slvmetad_LVM_TEST_DEVDIR=/dev \
-	./lib/harness $(patsubst %,snormal:%,$(RUN_BASE)) \
-		      $(patsubst %,scluster:%,$(RUN_BASE)) \
-		      $(patsubst %,slvmetad:%,$(LVMETAD_RUN_BASE))
+	VERBOSE=$(VERBOSE) ./lib/runner \
+		--testdir . --outdir results \
+		--only udev- --only $(T) --skip $(S)
 
 check_cluster: .tests-stamp
-	@echo Testing with locking_type 3
-	VERBOSE=$(VERBOSE) LVM_TEST_LOCKING=3 ./lib/harness $(RUN_BASE)
+	VERBOSE=$(VERBOSE) ./lib/runner \
+		--testdir . --outdir results \
+		--only ndev-cluster --only $(T) --skip $(S)
 
 check_local: .tests-stamp
-	@echo Testing with locking_type 1
-	VERBOSE=$(VERBOSE) LVM_TEST_LOCKING=1 ./lib/harness $(RUN_BASE)
+	VERBOSE=$(VERBOSE) ./lib/runner \
+		--testdir . --outdir results \
+		--only ndev- --only $(T) --skip $(S)
 
 ifeq ("@BUILD_LVMETAD@", "yes")
 check_lvmetad: .tests-stamp
-	@echo Testing with lvmetad on
-	VERBOSE=$(VERBOSE) LVM_TEST_LVMETAD=1 ./lib/harness $(RUN_BASE)
+	VERBOSE=$(VERBOSE) ./lib/runner \
+		--testdir . --outdir results \
+		--only ndev-lvmetad --only $(T) --skip $(S)
 endif
 
+DATADIR = $(datadir)/lvm2-testsuite
+EXECDIR = $(libexecdir)/lvm2-testsuite
+
+LIB_FLAVOURS = lib/flavour-ndev-vanilla lib/flavour-ndev-cluster lib/flavour-ndev-lvmetad \
+               lib/flavour-udev-vanilla lib/flavour-udev-cluster lib/flavour-udev-lvmetad
+
+LIB_LOCAL = lib/paths lib/runner
+LIB_EXEC  = lib/not lib/invalid lib/fail lib/should
+LIB_SHARED = lib/check lib/aux lib/inittest lib/utils lib/get lib/lvm-wrapper
+
+install: .tests-stamp lib/paths-installed
+	@echo $(srcdir)
+	@echo $(LIB_FLAVOURS)
+	$(INSTALL_DIR) $(DATADIR)/{shell,api,lib}
+	$(INSTALL_DATA) shell/*.sh $(DATADIR)/shell/
+	$(INSTALL_DATA) api/*.sh $(DATADIR)/api/
+	$(INSTALL_DATA) lib/paths-installed $(DATADIR)/lib/paths
+	$(INSTALL_DATA) $(LIB_FLAVOURS) $(DATADIR)/lib/
+	$(INSTALL_SCRIPT) $(LIB_SHARED) $(DATADIR)/lib/
+
+	$(INSTALL_DIR) $(EXECDIR)
+	$(INSTALL_PROGRAM) $(LIB_EXEC) $(EXECDIR)
+	$(INSTALL_PROGRAM) -D lib/runner $(bindir)/lvm2-testsuite
+
 lib/should: lib/not
 	ln -sf not lib/should
 
@@ -148,13 +171,10 @@ lib/%: $(srcdir)/lib/%.sh .lib-dir-stamp
 	cp $< $@
 	chmod +x $@
 
-lib/paths: $(srcdir)/Makefile.in .lib-dir-stamp Makefile
-	$(RM) $@-t
-	echo 'top_srcdir="$(top_srcdir)"' >> $@-t
-	echo 'abs_top_builddir="$(abs_top_builddir)"' >> $@-t
-	echo 'abs_top_srcdir="$(abs_top_srcdir)"' >> $@-t
-	echo 'abs_srcdir="$(abs_srcdir)"' >> $@-t
-	echo 'abs_builddir="$(abs_builddir)"' >> $@-t
+lib/flavour-%: $(srcdir)/lib/flavour-% .lib-dir-stamp
+	cp $< $@
+
+lib/paths-common: $(srcdir)/Makefile.in .lib-dir-stamp Makefile
 	echo 'export DM_UDEV_SYNCHRONISATION=$(dm_udev_synchronisation)' >> $@-t
 	echo 'export THIN=@THIN@' >> $@-t
 	echo 'export RAID=@RAID@' >> $@-t
@@ -172,11 +192,25 @@ lib/paths: $(srcdir)/Makefile.in .lib-dir-stamp Makefile
 	echo 'export LVM_TEST_CACHE_RESTORE_CMD=$${LVM_TEST_CACHE_RESTORE_CMD:- at CACHE_RESTORE_CMD@}' >> $@-t
 	mv $@-t $@
 
-LIB = lib/not lib/invalid lib/fail lib/should lib/harness \
-      lib/check lib/aux lib/inittest lib/utils lib/get lib/lvm-wrapper \
-      lib/paths lib/runner
+lib/paths-installed: lib/paths-common
+	$(RM) $@-t
+	cat lib/paths-common > $@-t
+	echo 'installed_testsuite=1' >> $@-t
+	echo 'export PATH=@libexecdir@/lvm2-testsuite:@datadir@/lvm2-testsuite/lib:$$PATH' >> $@-t
+	mv $@-t $@
+
+lib/paths: lib/paths-common
+	$(RM) $@-t
+	cat lib/paths-common > $@-t
+	echo 'top_srcdir="$(top_srcdir)"' >> $@-t
+	echo 'abs_top_builddir="$(abs_top_builddir)"' >> $@-t
+	echo 'abs_top_srcdir="$(abs_top_srcdir)"' >> $@-t
+	echo 'abs_srcdir="$(abs_srcdir)"' >> $@-t
+	echo 'abs_builddir="$(abs_builddir)"' >> $@-t
+	mv $@-t $@
 
 CMDS = lvm $(shell cat $(top_builddir)/tools/.commands)
+LIB = $(LIB_SHARED) $(LIB_LOCAL) $(LIB_EXEC) $(LIB_FLAVOURS)
 
 .tests-stamp: $(ALL) $(LIB) $(SUBDIRS)
 	@if test "$(srcdir)" != . ; then \


