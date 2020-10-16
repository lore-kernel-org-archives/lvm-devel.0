From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:11:45 +0000 (GMT)
Subject: stable-2.02 - tests: use DIRECT io for zeroing whenver we can
Message-ID: <20201016191145.2E95E396EC8A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=05ba12350c8530395d675538b8b3b741274e041d
Commit:        05ba12350c8530395d675538b8b3b741274e041d
Parent:        688c72411e206008d5cd7553ed0b126549b7f987
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Sep 19 23:25:11 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 17:07:59 2020 +0200

tests: use DIRECT io for zeroing whenver we can

Performance with direct I/O here is noticable better,
so use it instead of buffered write whenever we can.
---
 test/shell/lvchange-cache-mode.sh |  4 ++--
 test/shell/lvcreate-thin-big.sh   |  2 +-
 test/shell/pvcreate-operation.sh  |  2 +-
 test/shell/select-report.sh       |  4 ++--
 test/shell/snapshot-maxsize.sh    |  2 +-
 test/shell/snapshot-merge-thin.sh |  2 +-
 test/shell/thin-dmeventd-warns.sh |  8 ++++----
 test/shell/thin-flags.sh          |  4 ++--
 test/shell/thin-many-dmeventd.sh  | 17 +++++++++++------
 test/shell/vg-check-devs-used.sh  |  4 ++--
 10 files changed, 27 insertions(+), 22 deletions(-)

diff --git a/test/shell/lvchange-cache-mode.sh b/test/shell/lvchange-cache-mode.sh
index a34e51750..a50dfd450 100644
--- a/test/shell/lvchange-cache-mode.sh
+++ b/test/shell/lvchange-cache-mode.sh
@@ -32,9 +32,9 @@ lvcreate -H -L14 -n $lv1 --cachemode writeback --cachesettings migration_thresho
 
 for i in $(seq 1 10) ; do 
 echo 3 >/proc/sys/vm/drop_caches
-dd if=/dev/zero of="$DM_DEV_DIR/$vg/$lv1" bs=64K count=20 conv=fdatasync || true
+dd if=/dev/zero of="$DM_DEV_DIR/$vg/$lv1" bs=64K count=20 oflag=direct || true
 echo 3 >/proc/sys/vm/drop_caches
-dd if="$DM_DEV_DIR/$vg/$lv1" of=/dev/null bs=64K count=20 || true
+dd if="$DM_DEV_DIR/$vg/$lv1" of=/dev/null bs=64K count=20 oflag=direct || true
 done
 
 lvs -o+cache_dirty_blocks,cache_read_hits,cache_read_misses,cache_write_hits,cache_write_misses $vg/$lv1
diff --git a/test/shell/lvcreate-thin-big.sh b/test/shell/lvcreate-thin-big.sh
index 595b8a937..0b622b7a9 100644
--- a/test/shell/lvcreate-thin-big.sh
+++ b/test/shell/lvcreate-thin-big.sh
@@ -49,7 +49,7 @@ lvcreate -V10G $vg/pool3 -n $lv1
 lvcreate -V2G $vg/pool3 -n $lv2
 dd if=/dev/zero of="$DM_DEV_DIR/$vg/$lv1" bs=512b count=1 conv=fdatasync
 # ...excercise write speed to 'zero' device ;)
-dd if=/dev/zero of="$DM_DEV_DIR/$vg/$lv2" bs=64K count=32767 conv=fdatasync
+dd if=/dev/zero of="$DM_DEV_DIR/$vg/$lv2" bs=64K count=32767 oflag=direct
 lvs -a $vg
 # Check the percentage is not shown as 0.00
 check lv_field $vg/$lv1 data_percent "0.01"
diff --git a/test/shell/pvcreate-operation.sh b/test/shell/pvcreate-operation.sh
index c449438e6..5cf4fd675 100644
--- a/test/shell/pvcreate-operation.sh
+++ b/test/shell/pvcreate-operation.sh
@@ -181,7 +181,7 @@ grep "Not enough space available for metadata area with index 1 on PV $dev1" err
 rm -f "$backupfile"
 
 # pvcreate wipes swap signature when forced
-dd if=/dev/zero of="$dev1" bs=1024 count=64
+dd if=/dev/zero of="$dev1" bs=64k count=1 oflag=direct
 mkswap "$dev1"
 blkid -c /dev/null "$dev1" | grep "swap"
 pvcreate -f "$dev1"
diff --git a/test/shell/select-report.sh b/test/shell/select-report.sh
index f404be58b..b717c1031 100644
--- a/test/shell/select-report.sh
+++ b/test/shell/select-report.sh
@@ -152,11 +152,11 @@ if aux target_at_least dm-snapshot 1 10 0; then
 	# Before 1.10.0, the snap percent included metadata size.
 	sel lv 'snap_percent=0' snap
 fi
-dd if=/dev/zero of="$DM_DEV_DIR/$vg3/snap" bs=1M count=1 conv=fdatasync
+dd if=/dev/zero of="$DM_DEV_DIR/$vg3/snap" bs=1M count=1 oflag=direct
 sel lv 'snap_percent<50' snap
 sel lv 'snap_percent>50'
 # overflow snapshot -> invalidated, but still showing 100%
-not dd if=/dev/zero of="$DM_DEV_DIR/$vg3/snap" bs=1M count=4 conv=fdatasync
+not dd if=/dev/zero of="$DM_DEV_DIR/$vg3/snap" bs=1M count=4 oflag=direct
 sel lv 'snap_percent=100' snap
 # % char is accepted as suffix for percent values
 sel lv 'snap_percent=100%' snap
diff --git a/test/shell/snapshot-maxsize.sh b/test/shell/snapshot-maxsize.sh
index 9427566d5..43d4db1f1 100644
--- a/test/shell/snapshot-maxsize.sh
+++ b/test/shell/snapshot-maxsize.sh
@@ -27,7 +27,7 @@ lvcreate -aey -L1 -n $lv1 $vg
 # Snapshot should be large enough to handle any writes
 lvcreate -L2 -s $vg/$lv1 -n $lv2
 
-dd if=/dev/zero of="$DM_DEV_DIR/$vg/$lv2" bs=1M count=1 conv=fdatasync
+dd if=/dev/zero of="$DM_DEV_DIR/$vg/$lv2" bs=1M count=1 oflag=direct
 
 # Snapshot must not be 'I'nvalid here
 check lv_attr_bit state $vg/$lv2 "a"
diff --git a/test/shell/snapshot-merge-thin.sh b/test/shell/snapshot-merge-thin.sh
index 80969d146..26fae904d 100644
--- a/test/shell/snapshot-merge-thin.sh
+++ b/test/shell/snapshot-merge-thin.sh
@@ -23,7 +23,7 @@ aux prepare_vg 2
 
 lvcreate -T -L1 -V1 -n $lv1 $vg/pool "$dev1"
 lvcreate -s -n $lv2 -L2 $vg/$lv1 "$dev2"
-dd if=/dev/zero of="$DM_DEV_DIR/$vg/$lv2" bs=1M count=1 conv=fdatasync
+dd if=/dev/zero of="$DM_DEV_DIR/$vg/$lv2" bs=1M count=1 oflag=direct
 
 # Initiate background merge
 lvconvert -b --merge $vg/$lv2
diff --git a/test/shell/thin-dmeventd-warns.sh b/test/shell/thin-dmeventd-warns.sh
index a8002ae99..f7b1475b2 100644
--- a/test/shell/thin-dmeventd-warns.sh
+++ b/test/shell/thin-dmeventd-warns.sh
@@ -46,19 +46,19 @@ aux prepare_vg
 lvcreate -L8 -V8 -T $vg/pool -n $lv1
 
 
-dd if=/dev/zero of="$DM_DEV_DIR/$vg/$lv1" bs=256K count=26
+dd if=/dev/zero of="$DM_DEV_DIR/$vg/$lv1" bs=256K count=26 oflag=direct
 test "$(percent_)" -gt 80
 
 # Give it some time to dmeventd to log WARNING
 wait_warn_ 1
 
-dd if=/dev/zero of="$DM_DEV_DIR/$vg/$lv1" bs=256K count=30
+dd if=/dev/zero of="$DM_DEV_DIR/$vg/$lv1" bs=256K count=30 oflag=direct
 test "$(percent_)" -gt 90
 
 # Give it some time to dmeventd to log WARNING
 wait_warn_ 2
 
-dd if=/dev/zero of="$DM_DEV_DIR/$vg/$lv1" bs=1M count=8
+dd if=/dev/zero of="$DM_DEV_DIR/$vg/$lv1" bs=1M count=8 oflag=direct
 test "$(percent_)" -eq 100
 
 wait_warn_ 3
@@ -73,7 +73,7 @@ sleep 11
 # below 'WARNED' threshold.
 
 
-dd if=/dev/zero of="$DM_DEV_DIR/$vg/$lv1" bs=256K count=30
+dd if=/dev/zero of="$DM_DEV_DIR/$vg/$lv1" bs=256K count=30 oflag=direct
 test "$(percent_)" -gt 90
 
 lvs -a $vg
diff --git a/test/shell/thin-flags.sh b/test/shell/thin-flags.sh
index 12b1b75dd..df139b211 100644
--- a/test/shell/thin-flags.sh
+++ b/test/shell/thin-flags.sh
@@ -47,7 +47,7 @@ lvchange -an $vg
 
 # Overfill data area
 lvchange -ay $vg
-dd if=/dev/zero of="$DM_DEV_DIR/mapper/$vg-$lv2" bs=1M count=2
+dd if=/dev/zero of="$DM_DEV_DIR/mapper/$vg-$lv2" bs=1M count=2 oflag=direct
 check lv_attr_bit health $vg/pool "D"
 # TODO use spaces ??
 check lv_field $vg/pool lv_health_status "out_of_data"
@@ -78,7 +78,7 @@ lvchange -ay $vg
 
 lvchange -ay $vg/$lv2
 # Provisiong and last free bits in metadata
-dd if=/dev/zero of="$DM_DEV_DIR/mapper/$vg-$lv2" bs=32K count=1
+dd if=/dev/zero of="$DM_DEV_DIR/mapper/$vg-$lv2" bs=32K count=1 oflag=direct
 
 check lv_attr_bit health $vg/pool "M"
 # TODO - use spaces ??
diff --git a/test/shell/thin-many-dmeventd.sh b/test/shell/thin-many-dmeventd.sh
index 2a1fe7445..dc873e893 100644
--- a/test/shell/thin-many-dmeventd.sh
+++ b/test/shell/thin-many-dmeventd.sh
@@ -35,7 +35,7 @@ for i in $(seq 1 5)
 do
 	lvcreate --errorwhenfull y -Zn -T -L4M -V4M $vg/pool_${i} -n $lv${i}
         # Fill thin-pool to some capacity >50%
-	dd if=/dev/zero of="$DM_DEV_DIR/$vg/$lv${i}" bs=256K count=9 conv=fdatasync
+	dd if=/dev/zero of="$DM_DEV_DIR/$vg/$lv${i}" bs=256K count=9 oflag=direct
 done
 
 lvs -a $vg
@@ -55,11 +55,16 @@ sleep 9
 # new thin-pool registration.
 for i in $(seq 11 15)
 do
-	"$TIME" -o TM -f %e lvcreate --errorwhenfull y -Zn -T -L4M -V4M $vg/pool_${i} -n $lv${i}
-        read -r t < TM
-        test ${t%%.*} -lt 8 || die "Creation of thin pool took more then 8 second! ($t seconds)"
-        # Fill thin-pool to some capacity >50%
-	dd if=/dev/zero of="$DM_DEV_DIR/$vg/$lv${i}" bs=256K count=9 conv=fdatasync
+	#/usr/bin/time -o TM -f %e lvcreate --errorwhenfull y -Zn -T -L4M -V4M $vg/pool_${i} -n $lv${i}
+	#read -r t < TM
+	#test ${t%%.*} -lt 8 || die "Creation of thin pool took more then 8 second! ($t seconds)"
+	START=$(date +%s)
+	lvcreate --errorwhenfull y -Zn -T -L4M -V4M $vg/pool_${i} -n $lv${i}
+	END=$(date +%s)
+	DIFF=$(( END - START ))
+	test "$DIFF" -lt 8 || die "Creation of thin pool took more then 8 second! ($DIFF seconds)"
+	# Fill thin-pool to some capacity >50%
+	dd if=/dev/zero of="$DM_DEV_DIR/$vg/$lv${i}" bs=256K count=9 oflag=direct
 done
 
 vgremove -f $vg
diff --git a/test/shell/vg-check-devs-used.sh b/test/shell/vg-check-devs-used.sh
index f62799e20..3b911bc10 100644
--- a/test/shell/vg-check-devs-used.sh
+++ b/test/shell/vg-check-devs-used.sh
@@ -22,11 +22,11 @@ aux prepare_devs 3 8
 
 vgcreate $SHARED "$vg" "$dev1" "$dev2"
 lvcreate -l100%FREE -n $lv $vg
-dd if="$dev1" of="$dev3" bs=1M
+dd if="$dev1" of="$dev3" bs=1M oflag=direct
 pvs --config "devices/global_filter = [ \"a|$dev2|\", \"a|$dev3|\", \"r|.*|\" ]" 2>err
 grep "WARNING: Device mismatch detected for $vg/$lv which is accessing $dev1 instead of $dev3" err
 
-dd if=/dev/zero of="$dev3" bs=1M count=8
+dd if=/dev/zero of="$dev3" bs=1M count=8 oflag=direct
 lvremove -ff $vg
 
 # Also test if sub LVs with suffixes are correctly processed.


