From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 11 Mar 2015 20:17:45 +0000 (UTC)
Subject: master - tests: update makefile
Message-ID: <20150311201745.F3CF460F1C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1ad9677cb363f0f38b07a7d82add0f4479c08411
Commit:        1ad9677cb363f0f38b07a7d82add0f4479c08411
Parent:        bbe4f7e4c58a660694e5fdee0a981d67000a09de
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 11 21:11:09 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 11 21:17:23 2015 +0100

tests: update makefile

Respect $LVM_TEST_RESULT dir
Share same target for  clean: & distclean:
Cleanup path-common
---
 test/Makefile.in |   17 ++++++++++-------
 1 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index 9e8e484..93ab24c 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -102,28 +102,28 @@ help:
 
 check: .tests-stamp
 	VERBOSE=$(VERBOSE) ./lib/runner \
-		--testdir . --outdir results \
+		--testdir . --outdir $(LVM_TEST_RESULTS) \
 		--flavours ndev-vanilla,ndev-cluster,ndev-lvmetad --only $(T) --skip $(S)
 
 check_system: .tests-stamp
 	VERBOSE=$(VERBOSE) ./lib/runner \
-		--testdir . --outdir results \
+		--testdir . --outdir $(LVM_TEST_RESULTS) \
 		--flavours udev-vanilla,udev-cluster,udev-lvmetad --only $(T) --skip $(S)
 
 check_cluster: .tests-stamp
 	VERBOSE=$(VERBOSE) ./lib/runner \
-		--testdir . --outdir results \
+		--testdir . --outdir $(LVM_TEST_RESULTS) \
 		--flavours ndev-cluster --only $(T) --skip $(S)
 
 check_local: .tests-stamp
 	VERBOSE=$(VERBOSE) ./lib/runner \
-		--testdir . --outdir results \
+		--testdir . --outdir $(LVM_TEST_RESULTS) \
 		--flavours ndev-vanilla --only $(T) --skip $(S)
 
 ifeq ("@BUILD_LVMETAD@", "yes")
 check_lvmetad: .tests-stamp
 	VERBOSE=$(VERBOSE) ./lib/runner \
-		--testdir . --outdir results \
+		--testdir . --outdir $(LVM_TEST_RESULTS) \
 		--flavours ndev-lvmetad --only $(T) --skip $(S)
 endif
 
@@ -237,13 +237,16 @@ LIB = $(LIB_SHARED) $(LIB_LOCAL) $(LIB_EXEC) $(LIB_FLAVOURS)
 	ln -fs $(abs_top_srcdir)/conf/thin-performance.profile lib/thin-performance.profile
 	touch $@
 
-clean:
+cleantest:
 	test "$(srcdir)" = . || $(RM) $(RUN_BASE)
 	$(RM) -r $(LVM_TEST_RESULTS)
 
+clean: cleantest
+distclean: cleantest
+
 CLEAN_TARGETS += .lib-dir-stamp .tests-stamp $(LIB) $(addprefix lib/,$(CMDS)) \
 	lib/clvmd lib/dmeventd lib/dmsetup lib/lvmetad lib/fsadm lib/vgimportclone \
-	lib/thin-performance.profile
+	lib/thin-performance.profile lib/paths-common
 
 Makefile: $(srcdir)/Makefile.in $(top_builddir)/config.status
 	cd $(top_builddir) && $(SHELL) ./config.status $(subdir)/$@


