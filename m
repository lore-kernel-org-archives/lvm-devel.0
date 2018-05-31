From: David Teigland <teigland@sourceware.org>
Date: Thu, 31 May 2018 10:14:00 -0400
Subject: master - tests: separate lvmlockd tests with or without lvmetad
Message-ID: <201805311414.w4VEE0mC031125@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cd369d8a7fc5324f66d9965528ef9b92828b1a19
Commit:        cd369d8a7fc5324f66d9965528ef9b92828b1a19
Parent:        0c1d3db8dbe45df9f4311f5c19014680ecf26613
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed May 23 13:56:49 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed May 30 09:25:45 2018 -0500

tests: separate lvmlockd tests with or without lvmetad

---
 test/Makefile.in                          |    9 +++++++++
 test/lib/flavour-udev-lvmlockd-dlm.sh     |    1 -
 test/lib/flavour-udev-lvmlockd-sanlock.sh |    1 -
 test/lib/flavour-udev-lvmlockd-test.sh    |    1 -
 4 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index f6345a5..2b115b4 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -95,6 +95,7 @@ help:
 	@echo "  check_lvmlockd_sanlock Run tests with lvmlockd and sanlock."
 	@echo "  check_lvmlockd_dlm     Run tests with lvmlockd and dlm."
 	@echo "  check_lvmlockd_test    Run tests with lvmlockd --test."
+	@echo "  check_lvmlockd_test_lvmetad Run tests with lvmlockd --test and lvmetad."
 	@echo "  run-unit-test          Run only unit tests (root not needed)."
 	@echo "  clean			Clean dir."
 	@echo "  help			Display callable targets."
@@ -203,6 +204,13 @@ check_lvmlockd_test: .tests-stamp
 		--flavours udev-lvmlockd-test --only $(T) --skip $(S)
 endif
 
+ifeq ("@BUILD_LVMLOCKD@", "yes")
+check_lvmlockd_test_lvmetad: .tests-stamp
+	VERBOSE=$(VERBOSE) ./lib/runner \
+		--testdir . --outdir results \
+		--flavours udev-lvmlockd-test-lvmetad --only $(T) --skip $(S)
+endif
+
 run-unit-test unit-test:
 	$(MAKE) -C unit $(@)
 
@@ -224,6 +232,7 @@ LIB_FLAVOURS = \
  flavour-udev-lvmlockd-sanlock\
  flavour-udev-lvmlockd-dlm\
  flavour-udev-lvmlockd-test\
+ flavour-udev-lvmlockd-test-lvmetad\
  flavour-udev-vanilla
 
 LIB_LVMLOCKD_CONF = \
diff --git a/test/lib/flavour-udev-lvmlockd-dlm.sh b/test/lib/flavour-udev-lvmlockd-dlm.sh
index 5bd2749..198ec56 100644
--- a/test/lib/flavour-udev-lvmlockd-dlm.sh
+++ b/test/lib/flavour-udev-lvmlockd-dlm.sh
@@ -1,5 +1,4 @@
 export LVM_TEST_LOCKING=1
-export LVM_TEST_LVMETAD=1
 export LVM_TEST_LVMPOLLD=1
 export LVM_TEST_LVMLOCKD=1
 export LVM_TEST_LOCK_TYPE_DLM=1
diff --git a/test/lib/flavour-udev-lvmlockd-sanlock.sh b/test/lib/flavour-udev-lvmlockd-sanlock.sh
index 859ee2e..52f3cea 100644
--- a/test/lib/flavour-udev-lvmlockd-sanlock.sh
+++ b/test/lib/flavour-udev-lvmlockd-sanlock.sh
@@ -1,5 +1,4 @@
 export LVM_TEST_LOCKING=1
-export LVM_TEST_LVMETAD=1
 export LVM_TEST_LVMPOLLD=1
 export LVM_TEST_LVMLOCKD=1
 export LVM_TEST_LOCK_TYPE_SANLOCK=1
diff --git a/test/lib/flavour-udev-lvmlockd-test.sh b/test/lib/flavour-udev-lvmlockd-test.sh
index d2a7b4a..f9cd527 100644
--- a/test/lib/flavour-udev-lvmlockd-test.sh
+++ b/test/lib/flavour-udev-lvmlockd-test.sh
@@ -1,5 +1,4 @@
 export LVM_TEST_LOCKING=1
-export LVM_TEST_LVMETAD=1
 export LVM_TEST_LVMPOLLD=1
 export LVM_TEST_LVMLOCKD=1
 export LVM_TEST_LVMLOCKD_TEST=1


