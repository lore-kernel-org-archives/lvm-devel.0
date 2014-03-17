From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 17 Mar 2014 13:33:32 +0000 (UTC)
Subject: master - tests: enhance snapshot test
Message-ID: <20140317133332.D2D5060EAF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=27d556de9e895291f7c57b956cdb0036ff5d6e51
Commit:        27d556de9e895291f7c57b956cdb0036ff5d6e51
Parent:        1a0fea104b4d0d81f8fc6edd2802e025a9172d41
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 17 13:08:23 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 17 14:31:45 2014 +0100

tests: enhance snapshot test

Improve cleanup routine and use it also for vg removal.
---
 test/shell/snapshot-usage.sh |   37 ++++++++++++++++++-------------------
 1 files changed, 18 insertions(+), 19 deletions(-)

diff --git a/test/shell/snapshot-usage.sh b/test/shell/snapshot-usage.sh
index 13be4ee..a50eeb2 100644
--- a/test/shell/snapshot-usage.sh
+++ b/test/shell/snapshot-usage.sh
@@ -20,7 +20,7 @@ fill() {
 	dd if=/dev/zero of="$DM_DEV_DIR/$vg1/lvol0" bs=$1 count=1
 }
 
-# give some short time to lock file above
+# Wait until device is opened
 wait_for_open_() {
 	for i in $(seq 1 50) ; do
 		test $(dmsetup info --noheadings -c -o open $1) -ne 0 && return
@@ -32,8 +32,10 @@ wait_for_open_() {
 
 cleanup_tail()
 {
-	test -z "$SLEEP_PID" || kill $SLEEP_PID
+	test -z "$SLEEP_PID" || kill $SLEEP_PID || true
 	wait
+	vgremove -ff $vg1 || true
+	vgremove -ff $vg
 	aux teardown
 }
 
@@ -69,22 +71,23 @@ aux extend_filter_LVMTEST
 aux lvmconf "activation/snapshot_autoextend_percent = 20" \
             "activation/snapshot_autoextend_threshold = 50"
 
-# Check usability with smallest extent size
+# Check usability with smallest (1k) extent size ($lv has 15P)
 pvcreate --setphysicalvolumesize 4T "$DM_DEV_DIR/$vg/$lv"
+trap 'cleanup_tail' EXIT
 vgcreate -s 1K $vg1 "$DM_DEV_DIR/$vg/$lv"
 
-# Test removal of opened snapshot
+# Test virtual snapshot over /dev/zero
 lvcreate -V50 -L10 -n $lv1 -s $vg1
-
-lvs -a -o+lv_active $vg1
+CHECK_ACTIVE="active"
+test ! -e LOCAL_CLVMD || CHECK_ACTIVE="local exclusive"
+check lv_field $vg1/$lv1 lv_active ${CHECK_ACTIVE}
 lvchange -an $vg1
 
-# Snapshot get exclusive activation
+# On cluster snapshot gets exclusive activation
 lvchange -ay $vg1
-lvs -a -o+lv_active $vg1
+check lv_field $vg1/$lv1 lv_active ${CHECK_ACTIVE}
 
-trap 'cleanup_tail' EXIT
-# Keep device busy (but not mounted) for a while
+# Test removal of opened (bug unmounted) snapshot (device busy) for a while
 sleep 120 < "$DM_DEV_DIR/$vg1/$lv1" &
 SLEEP_PID=$!
 
@@ -100,17 +103,17 @@ SLEEP_PID=
 wait
 
 lvremove -f $vg1/$lv1
-not dmsetup info $vg1-$lv1 >/dev/null || \
-	die "$vg1/$lv1 expected to be removed, but there are mappings!"
+check lv_not_exists $vg1 $lv1
 
 # Check border size
 lvcreate -aey -L4095G $vg1
 lvcreate -s -L100K $vg1/lvol0
 fill 1K
 check lv_field $vg1/lvol1 data_percent "12.00"
+
 lvremove -ff $vg1
 
-# Create 1KB snapshot, no need to be active active here
+# Create 1KB snapshot, does not need to be active here
 lvcreate -an -Zn -l1 -n $lv1 $vg1
 not lvcreate -s -l1 $vg1/$lv1
 not lvcreate -s -l3 $vg1/$lv1
@@ -169,11 +172,11 @@ fsck -n "$DM_DEV_DIR/$vg1/snap"
 # we have 2 valid results  (unsure about correct version number)
 check lv_field $vg1/snap data_percent "$EXPECT4"
 
-vgremove -ff $vg1
-
 # Can't test >= 16T devices on 32bit
 if test "$TSIZE" = 15P ; then
 
+vgremove -ff $vg1
+
 # Check usability with largest extent size
 pvcreate "$DM_DEV_DIR/$vg/$lv"
 vgcreate -s 4G $vg1 "$DM_DEV_DIR/$vg/$lv"
@@ -186,8 +189,4 @@ lvremove -ff $vg1
 lvcreate -V15E -l1 -n $lv1 -s $vg1
 check lv_field $vg1/$lv1 origin_size "15.00e"
 
-vgremove -ff $vg1
-
 fi
-
-vgremove -ff $vg


