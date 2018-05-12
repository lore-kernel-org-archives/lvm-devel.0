From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 12 May 2018 12:25:48 -0400
Subject: master - tests: try running tests over ramdisk
Message-ID: <201805121625.w4CGPmDx007817@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0cadfdd69dabcb76cab575d790233a36b763633a
Commit:        0cadfdd69dabcb76cab575d790233a36b763633a
Parent:        842b3074b7b186815ee8a200598f2e97f08c54af
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon May 7 11:35:35 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat May 12 17:48:31 2018 +0200

tests: try running tests over ramdisk

Currently usage of loop device over backend file in ramdisk (tmpfs)
is actually causing unnecassary memory consution, since just
reading such loop device is causing RAM provisioning.

This patch add another possible way how to use ramdisk directly
through 'brd' device when possible (and allowed).

This however has it's limitation as well -  brd does not support
TRIM, so the only way how to erase is to remove brd module ??

Alse there is 4K sector size limitation imposed by ramdisk.

Anyway - for some mirror test that were using large amount of
disk space (tens of MB) this brings noticable speed boost.
(But could be worth to solve the slowness of loop in kernel?)

To prevent using 'brd' for testing set LVM_TEST_PREFER_BRD=0
like this:

make check_local LVM_TEST_PREFER_BRD=0
---
 test/Makefile.in |    1 +
 test/lib/aux.sh  |   32 +++++++++++++++++++++++++++-----
 2 files changed, 28 insertions(+), 5 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index ccf1f31..de8e3a1 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -90,6 +90,7 @@ help:
 	@echo "  LVM_TEST_BACKING_DEVICE Set device used for testing (see also LVM_TEST_DIR)."
 	@echo "  LVM_TEST_CAN_CLOBBER_DMESG Allow to clobber dmesg buffer without /dev/kmsg. (1)"
 	@echo "  LVM_TEST_DEVDIR	Set to '/dev' to run on real /dev."
+	@echo "  LVM_TEST_PREFER_BRD	Prefer using brd (ramdisk) over loop for testing [1]."
 	@echo "  LVM_TEST_DIR		Where to create test files  [$(LVM_TEST_DIR)]."
 	@echo "  LVM_TEST_LOCKING	Normal (1), Cluster (3)."
 	@echo "  LVM_TEST_LVMETAD	Start lvmetad (1)."
diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 2984af3..1f83a00 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -477,6 +477,7 @@ teardown_devs() {
 
 	test ! -f MD_DEV || cleanup_md_dev
 	test ! -f DEVICES || teardown_devs_prefixed "$PREFIX"
+	test ! -f RAMDISK || { modprobe -r brd || true ; }
 
 	# NOTE: SCSI_DEBUG_DEV test must come before the LOOP test because
 	# prepare_scsi_debug_dev() also sets LOOP to short-circuit prepare_loop()
@@ -489,7 +490,7 @@ teardown_devs() {
 	fi
 
 	not diff LOOP BACKING_DEV >/dev/null 2>&1 || rm -f BACKING_DEV
-	rm -f DEVICES LOOP
+	rm -f DEVICES LOOP RAMDISK
 
 	# Attempt to remove any loop devices that failed to get torn down if earlier tests aborted
 	test "${LVM_TEST_PARALLEL:-0}" -eq 1 || test -z "$COMMON_PREFIX" || {
@@ -638,7 +639,7 @@ teardown() {
 }
 
 prepare_loop() {
-	local size=${1=32}
+	local size=$1
 	shift # all other params are directly passed to all 'losetup' calls
 	local i
 	local slash
@@ -691,6 +692,17 @@ prepare_loop() {
 	echo "ok ($LOOP)"
 }
 
+prepare_ramdisk() {
+	local size=$1
+
+	echo -n "## preparing ramdisk device..."
+	modprobe brd rd_size=$((size * 1024)) || return
+
+	BACKING_DEV=/dev/ram0
+	echo "ok ($BACKING_DEV)"
+	touch RAMDISK
+}
+
 # A drop-in replacement for prepare_loop() that uses scsi_debug to create
 # a ramdisk-based SCSI device upon which all LVM devices will be created
 # - scripts must take care not to use a DEV_SIZE that will enduce OOM-killer
@@ -818,14 +830,24 @@ cleanup_md_dev() {
 }
 
 prepare_backing_dev() {
+	local size=${1=32}
+	shift
+
 	if test -f BACKING_DEV; then
 		BACKING_DEV=$(< BACKING_DEV)
+		return 0
 	elif test -b "$LVM_TEST_BACKING_DEVICE"; then
 		BACKING_DEV=$LVM_TEST_BACKING_DEVICE
 		echo "$BACKING_DEV" > BACKING_DEV
-	else
-		prepare_loop "$@"
+		return 0
+	elif test "${LVM_TEST_PREFER_BRD-1}" = "1" && test ! -d /sys/block/ram0 && test "$size" -lt 16384; then
+		# try to use ramdisk if possible, but for
+		# big allocs (>16G) do not try to use ramdisk
+		prepare_ramdisk "$size" "$@" && return
+		echo "(failed)"
 	fi
+
+	prepare_loop "$size" "$@"
 }
 
 prepare_devs() {
@@ -870,7 +892,7 @@ prepare_devs() {
 	fi
 
 	# non-ephemeral devices need to be cleared between tests
-	test -f LOOP || for d in "${DEVICES[@]}"; do
+	test -f LOOP -o -f RAMDISK || for d in "${DEVICES[@]}"; do
 		blkdiscard "$d" 2>/dev/null || true
 		# ensure disk header is always zeroed
 		dd if=/dev/zero of="$d" bs=32k count=1


