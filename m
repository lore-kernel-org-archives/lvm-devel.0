From: David Teigland <teigland@sourceware.org>
Date: Mon,  8 Mar 2021 23:24:36 +0000 (GMT)
Subject: main - tests: check_devicesfile
Message-ID: <20210308232436.1DF39385802A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d5f3239de4aa33f51cc8db7fc2e29db41cab9152
Commit:        d5f3239de4aa33f51cc8db7fc2e29db41cab9152
Parent:        843ee943ab4ff9d05817c6b59bd778cc4182ccc2
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Mar 8 17:19:26 2021 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Mar 8 17:19:26 2021 -0600

tests: check_devicesfile

make check_devicesfile T=...

(A number of tests should probably get a new
SKIP_WITH_DEVICES_FILE.)
---
 test/Makefile.in                     |  7 +++++++
 test/lib/aux.sh                      | 23 ++++++++++++++++-------
 test/lib/flavour-ndev-devicesfile.sh |  2 ++
 test/lib/inittest.sh                 |  2 ++
 4 files changed, 27 insertions(+), 7 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index 882620362..41ddb9d8e 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -81,6 +81,7 @@ help:
 	@echo "  check_system		Run all tests using udev."
 	@echo "  check_local		Run tests."
 	@echo "  check_lvmpolld         Run tests with lvmpolld daemon."
+	@echo "  check_devicesfile	Run tests using a devices file."
 	@echo "  check_all_lvmpolld     Run all tests with lvmpolld daemon."
 	@echo "  check_lvmlockd_sanlock Run tests with lvmlockd and sanlock."
 	@echo "  check_lvmlockd_dlm     Run tests with lvmlockd and dlm."
@@ -148,6 +149,11 @@ check_all_lvmpolld: .tests-stamp
 		--flavours ndev-lvmpolld --only $(T) --skip $(S)
 endif
 
+check_devicesfile: .tests-stamp
+	VERBOSE=$(VERBOSE) ./lib/runner \
+		--testdir . --outdir $(LVM_TEST_RESULTS) \
+		--flavours ndev-devicesfile --only $(T) --skip $(S)
+
 ifeq ("@BUILD_LVMLOCKD@", "yes")
 check_lvmlockd_sanlock: .tests-stamp
 	VERBOSE=$(VERBOSE) ./lib/runner \
@@ -179,6 +185,7 @@ EXECDIR = $(libexecdir)/lvm2-testsuite
 LIB_FLAVOURS = \
  flavour-ndev-lvmpolld\
  flavour-ndev-vanilla\
+ flavour-ndev-devicesfile\
  flavour-udev-lvmpolld\
  flavour-udev-lvmlockd-sanlock\
  flavour-udev-lvmlockd-dlm\
diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 1500e1f6a..0e10a06dd 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -822,7 +822,9 @@ wipefs_a() {
 	local dev=$1
 	shift
 
-#	lvmdevices --deldev $dev || true
+	if test -n "$LVM_TEST_DEVICES_FILE"; then
+		lvmdevices --deldev $dev || true
+	fi
 
 	if wipefs -V >/dev/null; then
 		wipefs -a "$dev"
@@ -831,7 +833,10 @@ wipefs_a() {
 		mdadm --zero-superblock "$dev" || true
 	fi
 
-#	lvmdevices --adddev $dev || true
+	if test -n "$LVM_TEST_DEVICES_FILE"; then
+		lvmdevices --adddev $dev || true
+	fi
+
 }
 
 prepare_backing_dev() {
@@ -917,11 +922,13 @@ prepare_devs() {
 		wipefs -a "$d" 2>/dev/null || true
 	done
 
-#	mkdir -p $TESTDIR/etc/lvm/devices || true
-#	rm $TESTDIR/etc/lvm/devices/system.devices || true
-#	for d in "${DEVICES[@]}"; do
-#		lvmdevices --adddev $dev || true
-#	done
+	if test -n "$LVM_TEST_DEVICES_FILE"; then
+		mkdir -p $TESTDIR/etc/lvm/devices || true
+		rm $TESTDIR/etc/lvm/devices/system.devices || true
+		for d in "${DEVICES[@]}"; do
+			lvmdevices --adddev $dev || true
+		done
+	fi
 
 	#for i in `seq 1 $n`; do
 	#	local name="${PREFIX}$pvname$i"
@@ -1276,6 +1283,7 @@ generate_config() {
 	LVM_TEST_LOCKING=${LVM_TEST_LOCKING:-1}
 	LVM_TEST_LVMPOLLD=${LVM_TEST_LVMPOLLD:-0}
 	LVM_TEST_LVMLOCKD=${LVM_TEST_LVMLOCKD:-0}
+	LVM_TEST_DEVICES_FILE=${LVM_TEST_DEVICES_FILE:-0}
         # FIXME:dct: This is harmful! Variables are unused here and are tested not being empty elsewhere:
 	#LVM_TEST_LOCK_TYPE_SANLOCK=${LVM_TEST_LOCK_TYPE_SANLOCK:-0}
 	#LVM_TEST_LOCK_TYPE_DLM=${LVM_TEST_LOCK_TYPE_DLM:-0}
@@ -1310,6 +1318,7 @@ devices/md_component_detection = 0
 devices/scan = "$DM_DEV_DIR"
 devices/sysfs_scan = 1
 devices/write_cache_state = 0
+devices/use_devicesfile = $LVM_TEST_DEVICES_FILE
 global/abort_on_internal_errors = 1
 global/cache_check_executable = "$LVM_TEST_CACHE_CHECK_CMD"
 global/cache_dump_executable = "$LVM_TEST_CACHE_DUMP_CMD"
diff --git a/test/lib/flavour-ndev-devicesfile.sh b/test/lib/flavour-ndev-devicesfile.sh
new file mode 100644
index 000000000..21168fdcc
--- /dev/null
+++ b/test/lib/flavour-ndev-devicesfile.sh
@@ -0,0 +1,2 @@
+export LVM_TEST_LOCKING=1
+export LVM_TEST_DEVICES_FILE=1
diff --git a/test/lib/inittest.sh b/test/lib/inittest.sh
index 44000b951..ee049fb79 100644
--- a/test/lib/inittest.sh
+++ b/test/lib/inittest.sh
@@ -37,6 +37,7 @@ SHARED=${SHARED-}
 LVM_TEST_LVMLOCKD=${LVM_TEST_LVMLOCKD-}
 LVM_TEST_LVMLOCKD_TEST=${LVM_TEST_LVMLOCKD_TEST-}
 LVM_TEST_LVMPOLLD=${LVM_TEST_LVMPOLLD-}
+LVM_TEST_DEVICES_FILE=${LVM_TEST_DEVICES_FILE-}
 LVM_TEST_LOCK_TYPE_DLM=${LVM_TEST_LOCK_TYPE_DLM-}
 LVM_TEST_LOCK_TYPE_SANLOCK=${LVM_TEST_LOCK_TYPE_SANLOCK-}
 
@@ -64,6 +65,7 @@ unset CDPATH
 export LVM_TEST_BACKING_DEVICE LVM_TEST_DEVDIR LVM_TEST_NODEBUG
 export LVM_TEST_LVMLOCKD LVM_TEST_LVMLOCKD_TEST
 export LVM_TEST_LVMPOLLD LVM_TEST_LOCK_TYPE_DLM LVM_TEST_LOCK_TYPE_SANLOCK
+export LVM_TEST_DEVICES_FILE
 # grab some common utilities
 . lib/utils
 


