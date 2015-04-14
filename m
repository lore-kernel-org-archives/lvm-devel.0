From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 14 Apr 2015 08:11:59 +0000 (UTC)
Subject: master - makefiles: skip lvmetad tests
Message-ID: <20150414081200.04FBB60E5E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ee6fc17663c777f7276c56fd224fd3cecc0f77e4
Commit:        ee6fc17663c777f7276c56fd224fd3cecc0f77e4
Parent:        d5651f44e3056c0e0e5f0c3d05c29c575782379e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 14 09:45:36 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 14 10:11:35 2015 +0200

makefiles: skip lvmetad tests

When build without lvmetad, skip  n/udev-lvmetad flavour execution.
Update help test.
---
 test/Makefile.in |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index 93ab24c..da09a6c 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -52,6 +52,8 @@ RUN_BASE = $(subst $(srcdir)/,,$(RUN))
 
 ifeq ("@BUILD_LVMETAD@", "yes")
 LVMETAD_RUN_BASE = $(RUN_BASE)
+LVMETAD_NDEV_FLAVOUR = ,ndev-lvmetad
+LVMETAD_UDEV_FLAVOUR = ,udev-lvmetad
 endif
 
 
@@ -91,10 +93,12 @@ help:
 	@echo "  LVM_TEST_CACHE_REPAIR_CMD  Command for cache_repair  [$(LVM_TEST_CACHE_REPAIR_CMD)]."
 	@echo "  LVM_TEST_CACHE_RESTORE_CMD Command for cache_restore [$(LVM_TEST_CACHE_RESTORE_CMD)]."
 	@echo "  LVM_TEST_UNLIMITED	Set to get unlimited test log (>32MB)"
-	@echo "  LVM_VALGRIND		Enable valgrind testing (1,2,3) execs $$"VALGRIND
+	@echo "  LVM_VALGRIND		Enable valgrind testing, execs $$"VALGRIND.
 	@echo "  LVM_VALGRIND_CLVMD	Enable valgrind testing of clvmd (1)."
 	@echo "  LVM_VALGRIND_DMEVENTD	Enable valgrind testing of dmeventd (1)."
 	@echo "  LVM_VALGRIND_LVMETAD	Enable valgrind testing of lvmetad (1)."
+	@echo "  LVM_STRACE		Enable strace logging."
+	@echo "  LVM_DEBUG_LEVEL	Sets debuging level for valgrind/strace (use > 0)."
 	@echo "  LVM_VERIFY_UDEV	Default verify state for lvm.conf."
 	@echo "  S			Skip given test (regex)."
 	@echo "  T			Run given test (regex)."
@@ -103,12 +107,12 @@ help:
 check: .tests-stamp
 	VERBOSE=$(VERBOSE) ./lib/runner \
 		--testdir . --outdir $(LVM_TEST_RESULTS) \
-		--flavours ndev-vanilla,ndev-cluster,ndev-lvmetad --only $(T) --skip $(S)
+		--flavours ndev-vanilla,ndev-cluster$(LVMETAD_NDEV_FLAVOUR) --only $(T) --skip $(S)
 
 check_system: .tests-stamp
 	VERBOSE=$(VERBOSE) ./lib/runner \
 		--testdir . --outdir $(LVM_TEST_RESULTS) \
-		--flavours udev-vanilla,udev-cluster,udev-lvmetad --only $(T) --skip $(S)
+		--flavours udev-vanilla,udev-cluster$(LVMETAD_UDEV_FLAVOUR) --only $(T) --skip $(S)
 
 check_cluster: .tests-stamp
 	VERBOSE=$(VERBOSE) ./lib/runner \


