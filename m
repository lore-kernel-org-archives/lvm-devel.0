From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 18 Jul 2017 07:16:47 -0400
Subject: master - tests: aux.sh limit device
Message-ID: <201707181116.v6IBGlNX019104@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9599645bb6a295aafd6cdf6f793fc9068c5d437f
Commit:        9599645bb6a295aafd6cdf6f793fc9068c5d437f
Parent:        4fa739faf2d30beea5a8423806594f506644a540
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jul 18 13:14:02 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jul 18 13:14:02 2017 +0200

tests: aux.sh limit device

During test do a more close selection of visible devices.
If some test leaks a device with LVMTEST prefix, next
test should not be influnced (or parallel running one).

If the test is running in non-/dev  dir - it's already protected
by full path with $PREFIX in it - however it test is running
in real /dev dir - there was no such protection and test
were confused when they have seen such leaked device.
---
 test/lib/aux.sh |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 20a8a1e..93345bf 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -475,7 +475,7 @@ teardown_devs() {
 	rm -f DEVICES LOOP
 
 	# Attempt to remove any loop devices that failed to get torn down if earlier tests aborted
-	test "${LVM_TEST_PARALLEL:-0}" -eq 1 -o -z "$COMMON_PREFIX" || {
+	test "${LVM_TEST_PARALLEL:-0}" -eq 1 || test -z "$COMMON_PREFIX" || {
 		local stray_loops=( $(losetup -a | grep "$COMMON_PREFIX" | cut -d: -f1) )
 		test ${#stray_loops[@]} -eq 0 || {
 			teardown_devs_prefixed "$COMMON_PREFIX" 1
@@ -678,7 +678,7 @@ prepare_loop() {
 # - scripts must take care not to use a DEV_SIZE that will enduce OOM-killer
 prepare_scsi_debug_dev() {
 	local DEV_SIZE=$1
-	local SCSI_DEBUG_PARAMS=( ${@:2} )
+	shift # rest of params directly passed to modprobe
 	local DEBUG_DEV
 
 	rm -f debug.log strace.log
@@ -694,7 +694,7 @@ prepare_scsi_debug_dev() {
 	# NOTE: it will _never_ make sense to pass num_tgts param;
 	# last param wins.. so num_tgts=1 is imposed
 	touch SCSI_DEBUG_DEV
-	modprobe scsi_debug dev_size_mb="$DEV_SIZE" "${SCSI_DEBUG_PARAMS[@]}" num_tgts=1 || skip
+	modprobe scsi_debug dev_size_mb="$DEV_SIZE" "$@" num_tgts=1 || skip
 
 	for i in {1..20} ; do
 		DEBUG_DEV="/dev/$(grep -H scsi_debug /sys/block/*/device/model | cut -f4 -d /)"
@@ -1159,7 +1159,7 @@ devices/cache_dir = "$TESTDIR/etc"
 devices/default_data_alignment = 1
 devices/dir = "$DM_DEV_DIR"
 devices/filter = "a|.*|"
-devices/global_filter = [ "a|$DM_DEV_DIR/mapper/.*pv[0-9_]*$|", "r|.*|" ]
+devices/global_filter = [ "a|$DM_DEV_DIR/mapper/${PREFIX}.*pv[0-9_]*$|", "r|.*|" ]
 devices/md_component_detection  = 0
 devices/scan = "$DM_DEV_DIR"
 devices/sysfs_scan = 1


