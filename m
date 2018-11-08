From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 8 Nov 2018 06:23:46 -0500
Subject: master - tests: keep results configurable
Message-ID: <201811081123.wA8BNk5S013977@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f86f01a3a15115d0ad808a14a1ca5665451cce1a
Commit:        f86f01a3a15115d0ad808a14a1ca5665451cce1a
Parent:        3a557dcfbf42b9124ab17ba3dcd71b417aee9be1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 8 10:01:21 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 8 12:22:18 2018 +0100

tests: keep results configurable

---
 test/Makefile.in |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index bb736a6..f8571b7 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -137,33 +137,33 @@ check_local: .tests-stamp
 ifeq ("@BUILD_LVMPOLLD@", "yes")
 check_lvmpolld: .tests-stamp
 	VERBOSE=$(VERBOSE) ./lib/runner \
-		--testdir . --outdir results \
+		--testdir . --outdir $(LVM_TEST_RESULTS) \
 		--flavours ndev-lvmpolld --only $(T) --skip $(S)
 
 check_all_lvmpolld: .tests-stamp
 	VERBOSE=$(VERBOSE) ./lib/runner \
-		--testdir . --outdir results \
+		--testdir . --outdir $(LVM_TEST_RESULTS) \
 		--flavours ndev-lvmpolld --only $(T) --skip $(S)
 endif
 
 ifeq ("@BUILD_LVMLOCKD@", "yes")
 check_lvmlockd_sanlock: .tests-stamp
 	VERBOSE=$(VERBOSE) ./lib/runner \
-		--testdir . --outdir results \
+		--testdir . --outdir $(LVM_TEST_RESULTS) \
 		--flavours udev-lvmlockd-sanlock --only shell/aa-lvmlockd-sanlock-prepare.sh,$(T),shell/zz-lvmlockd-sanlock-remove.sh --skip $(S)
 endif
 
 ifeq ("@BUILD_LVMLOCKD@", "yes")
 check_lvmlockd_dlm: .tests-stamp
 	VERBOSE=$(VERBOSE) ./lib/runner \
-		--testdir . --outdir results \
+		--testdir . --outdir $(LVM_TEST_RESULTS) \
 		--flavours udev-lvmlockd-dlm --only shell/aa-lvmlockd-dlm-prepare.sh,$(T),shell/zz-lvmlockd-dlm-remove.sh --skip $(S)
 endif
 
 ifeq ("@BUILD_LVMLOCKD@", "yes")
 check_lvmlockd_test: .tests-stamp
 	VERBOSE=$(VERBOSE) ./lib/runner \
-		--testdir . --outdir results \
+		--testdir . --outdir $(LVM_TEST_RESULTS) \
 		--flavours udev-lvmlockd-test --only $(T) --skip $(S)
 endif
 


