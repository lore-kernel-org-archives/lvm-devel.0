From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 19 Sep 2020 22:39:02 +0000 (GMT)
Subject: master - tests: use DIRECT io for zeroing whenver we can
Message-ID: <20200919223902.6BF09396E410@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f2878a801c7af73e9110650708f7fd741c22c3d2
Commit:        f2878a801c7af73e9110650708f7fd741c22c3d2
Parent:        531a475afcc602d573581eb11ecc572e427f0f35
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Sep 19 23:25:11 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Sep 20 00:37:21 2020 +0200

tests: use DIRECT io for zeroing whenver we can

Performance with direct I/O here is noticable better,
so use it instead of buffered write whenever we can.
---
 test/shell/integrity-blocksize.sh    |  15 ++--
 test/shell/integrity.sh              |  10 +--
 test/shell/lvchange-cache-mode.sh    |   4 +-
 test/shell/lvcreate-thin-big.sh      |   2 +-
 test/shell/metadata-bad-mdaheader.sh |   8 +--
 test/shell/pvck-dump.sh              |  20 +++---
 test/shell/pvck-repair.sh            | 135 +++++++++++++----------------------
 test/shell/pvcreate-operation.sh     |   2 +-
 test/shell/select-report.sh          |   4 +-
 test/shell/snapshot-maxsize.sh       |   2 +-
 test/shell/snapshot-merge-thin.sh    |   2 +-
 test/shell/thin-dmeventd-warns.sh    |   8 +--
 test/shell/thin-flags.sh             |   4 +-
 test/shell/thin-many-dmeventd.sh     |   4 +-
 test/shell/vg-check-devs-used.sh     |   4 +-
 15 files changed, 97 insertions(+), 127 deletions(-)

diff --git a/test/shell/integrity-blocksize.sh b/test/shell/integrity-blocksize.sh
index 03410c204..c28212d3c 100644
--- a/test/shell/integrity-blocksize.sh
+++ b/test/shell/integrity-blocksize.sh
@@ -46,10 +46,17 @@ vgremove -ff $vg
 
 trap 'cleanup_mounted_and_teardown' EXIT
 
-dd if=/dev/zero of=loopa bs=$((1024*1024)) count=64 2> /dev/null
-dd if=/dev/zero of=loopb bs=$((1024*1024)) count=64 2> /dev/null
-dd if=/dev/zero of=loopc bs=$((1024*1024)) count=64 2> /dev/null
-dd if=/dev/zero of=loopd bs=$((1024*1024)) count=64 2> /dev/null
+# Currently (5.9-rc5 hits  'blkdev_issue_discard()' kernel WARNING)
+#truncate -s 64M loopa
+#truncate -s 64M loopb
+#truncate -s 64M loopc
+#truncate -s 64M loopd
+
+dd if=/dev/zero of=loopa bs=1M count=64 oflag=sync
+dd if=/dev/zero of=loopb bs=1M count=64 oflag=sync
+dd if=/dev/zero of=loopc bs=1M count=64 oflag=sync
+dd if=/dev/zero of=loopd bs=1M count=64 oflag=sync
+
 LOOP1=$(losetup -f loopa --show)
 LOOP2=$(losetup -f loopb --show)
 LOOP3=$(losetup -f loopc --sector-size 4096 --show)
diff --git a/test/shell/integrity.sh b/test/shell/integrity.sh
index 4da40bcb4..7b119965b 100644
--- a/test/shell/integrity.sh
+++ b/test/shell/integrity.sh
@@ -37,11 +37,11 @@ dd if=/dev/urandom of=randC bs=512K count=4
 _prepare_vg() {
 	# zero devs so we are sure to find the correct file data
 	# on the underlying devs when corrupting it
-	dd if=/dev/zero of="$dev1" bs=1M || true
-	dd if=/dev/zero of="$dev2" bs=1M || true
-	dd if=/dev/zero of="$dev3" bs=1M || true
-	dd if=/dev/zero of="$dev4" bs=1M || true
-	dd if=/dev/zero of="$dev5" bs=1M || true
+	dd if=/dev/zero of="$dev1" bs=1M oflag=direct || true
+	dd if=/dev/zero of="$dev2" bs=1M oflag=direct || true
+	dd if=/dev/zero of="$dev3" bs=1M oflag=direct || true
+	dd if=/dev/zero of="$dev4" bs=1M oflag=direct || true
+	dd if=/dev/zero of="$dev5" bs=1M oflag=direct || true
 	vgcreate $SHARED $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
 	pvs
 }
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
diff --git a/test/shell/metadata-bad-mdaheader.sh b/test/shell/metadata-bad-mdaheader.sh
index e9e303dcd..2096dbba8 100644
--- a/test/shell/metadata-bad-mdaheader.sh
+++ b/test/shell/metadata-bad-mdaheader.sh
@@ -27,9 +27,9 @@ get_devs
 # is needed.
 #
 
-dd if=/dev/zero of="$dev1" || true
-dd if=/dev/zero of="$dev2" || true
-dd if=/dev/zero of="$dev3" || true
+dd if=/dev/zero of="$dev1" bs=1M count=1 oflag=direct
+dd if=/dev/zero of="$dev2" bs=1M count=1 oflag=direct
+dd if=/dev/zero of="$dev3" bs=1M count=1 oflag=direct
 
 vgcreate $SHARED $vg "$dev1" "$dev2" "$dev3"
 
@@ -74,5 +74,3 @@ pvs "$dev3"
 
 vgchange -an $vg
 vgremove -ff $vg
-
-
diff --git a/test/shell/pvck-dump.sh b/test/shell/pvck-dump.sh
index 3b6344d93..c27fcc471 100644
--- a/test/shell/pvck-dump.sh
+++ b/test/shell/pvck-dump.sh
@@ -17,11 +17,11 @@ SIZE_MB=80
 aux prepare_devs 4 $SIZE_MB
 get_devs
 
-dd if=/dev/zero of="$dev1" bs=1M count=2 conv=fdatasync
-dd if=/dev/zero of="$dev2" bs=1M count=2 conv=fdatasync
+dd if=/dev/zero of="$dev1" bs=1M count=2 oflag=direct
+dd if=/dev/zero of="$dev2" bs=1M count=2 oflag=direct
 # clear entire dev to cover mda2
-dd if=/dev/zero of="$dev3" bs=1M count=$SIZE_MB conv=fdatasync
-dd if=/dev/zero of="$dev4" bs=1M count=2 conv=fdatasync
+dd if=/dev/zero of="$dev3" bs=1M count=$SIZE_MB oflag=direct
+dd if=/dev/zero of="$dev4" bs=1M count=2 oflag=direct
 
 pvcreate "$dev1"
 pvcreate "$dev2"
@@ -136,10 +136,10 @@ vgremove -ff $vg
 
 
 # clear entire dev to cover mda2
-dd if=/dev/zero of="$dev1" bs=1M count=$SIZE_MB conv=fdatasync
-dd if=/dev/zero of="$dev2" bs=1M count=32 conv=fdatasync
-dd if=/dev/zero of="$dev3" bs=1M count=32 conv=fdatasync
-dd if=/dev/zero of="$dev4" bs=1M count=32 conv=fdatasync
+dd if=/dev/zero of="$dev1" bs=1M count=$SIZE_MB oflag=direct
+dd if=/dev/zero of="$dev2" bs=1M count=32 oflag=direct
+dd if=/dev/zero of="$dev3" bs=1M count=32 oflag=direct
+dd if=/dev/zero of="$dev4" bs=1M count=32 oflag=direct
 
 pvcreate --pvmetadatacopies 2 --metadatasize 32M "$dev1"
 
@@ -160,7 +160,7 @@ dd if="$dev1" of=dev1dd bs=1M count=34
 # Clear the header so that we force metadata_search to use
 # the settings instead of getting the mda_size/mda_offset
 # from the headers.
-dd if=/dev/zero of="$dev1" bs=4K count=1
+dd if=/dev/zero of="$dev1" bs=4K count=1 oflag=direct
 
 # Warning: these checks are based on copying specific numbers
 # seen when running these commands, but these numbers could
@@ -192,6 +192,6 @@ grep "seqno 477" m1b
 grep "seqno 478" m1b
 grep "seqno 500" m2
 
-dd if=dev1dd of="$dev1" bs=4K count=1
+dd if=dev1dd of="$dev1" bs=4K count=1 oflag=direct
 
 vgremove -ff $vg
diff --git a/test/shell/pvck-repair.sh b/test/shell/pvck-repair.sh
index 0e838483b..d48e25198 100644
--- a/test/shell/pvck-repair.sh
+++ b/test/shell/pvck-repair.sh
@@ -12,13 +12,33 @@
 
 . lib/inittest
 
-aux prepare_devs 2
+SIZE=34
+
+_prepare_vg() {
+	rm -f meta debug.log_DEBUG*
+	for i in "$@" ; do
+		dd if=/dev/zero of="$i" bs=1M count=1 oflag=direct
+	done
+	vgcreate $vg "$@"
+}
+
+_clear_devs() {
+	rm -f meta debug.log_DEBUG*
+	for i in "$@" ; do
+		dd if=/dev/zero of="$i" bs=1M count=$SIZE oflag=direct
+	done
+}
+
+_prepare_vg_with_copy() {
+        _clear_devs "$@"
+	vgcreate --pvmetadatacopies 2 $vg "$@"
+}
+
+aux prepare_devs 2 $SIZE
 get_devs
 
 # One PV, one mda, pv_header zeroed
-rm meta || true
-dd if=/dev/zero of="$dev1" || true
-vgcreate $vg "$dev1"
+_prepare_vg "$dev1"
 dd if=/dev/zero of="$dev1" bs=512 count=2
 pvck --dump headers "$dev1" || true
 pvck --dump metadata_search --settings seqno=1 -f meta "$dev1" || true
@@ -28,9 +48,7 @@ vgs $vg
 lvcreate -l1 -an $vg
 
 # One PV, one mda, mda_header zeroed
-rm meta || true
-dd if=/dev/zero of="$dev1" || true
-vgcreate $vg "$dev1"
+_prepare_vg "$dev1"
 dd if=/dev/zero of="$dev1" bs=512 count=1 seek=8
 pvck --dump headers "$dev1" || true
 pvck --dump metadata_search --settings seqno=1 -f meta "$dev1" || true
@@ -40,9 +58,7 @@ vgs $vg
 lvcreate -l1 -an $vg
 
 # One PV, one mda, pv_header and mda_header zeroed
-rm meta || true
-dd if=/dev/zero of="$dev1" || true
-vgcreate $vg "$dev1"
+_prepare_vg "$dev1"
 dd if=/dev/zero of="$dev1" bs=512 count=2
 dd if=/dev/zero of="$dev1" bs=512 count=1 seek=8
 pvck --dump headers "$dev1" || true
@@ -53,9 +69,7 @@ vgs $vg
 lvcreate -l1 -an $vg
 
 # One PV, one mda, metadata zeroed, use backup
-rm meta || true
-dd if=/dev/zero of="$dev1" || true
-vgcreate $vg "$dev1"
+_prepare_vg "$dev1"
 vgcfgbackup
 dd if=/dev/zero of="$dev1" bs=512 count=2 seek=9
 pvck --dump headers "$dev1" || true
@@ -67,9 +81,7 @@ vgs $vg
 lvcreate -l1 -an $vg
 
 # One PV, one mda, mda_header and metadata zeroed, use backup
-rm meta || true
-dd if=/dev/zero of="$dev1" || true
-vgcreate $vg "$dev1"
+_prepare_vg "$dev1"
 vgcfgbackup
 dd if=/dev/zero of="$dev1" bs=512 count=3 seek=8
 pvck --dump headers "$dev1" || true
@@ -81,9 +93,7 @@ vgs $vg
 lvcreate -l1 -an $vg
 
 # One PV, one mda, pv_header, mda_header and metadata zeroed, use backup
-rm meta || true
-dd if=/dev/zero of="$dev1" || true
-vgcreate $vg "$dev1"
+_prepare_vg "$dev1"
 vgcfgbackup
 dd if=/dev/zero of="$dev1" bs=512 count=2
 dd if=/dev/zero of="$dev1" bs=512 count=3 seek=8
@@ -96,9 +106,7 @@ vgs $vg
 lvcreate -l1 -an $vg
 
 # One PV, two mdas, pv_header zeroed
-rm meta || true
-dd if=/dev/zero of="$dev1" || true
-vgcreate --pvmetadatacopies 2 $vg "$dev1"
+_prepare_vg_with_copy "$dev1"
 dd if=/dev/zero of="$dev1" bs=512 count=2
 pvck --dump headers "$dev1" || true
 pvck --dump metadata_search --settings seqno=1 -f meta "$dev1" || true
@@ -108,9 +116,7 @@ vgs $vg
 lvcreate -l1 -an $vg
 
 # One PV, two mdas, mda_header1 zeroed
-rm meta || true
-dd if=/dev/zero of="$dev1" || true
-vgcreate --pvmetadatacopies 2 $vg "$dev1"
+_prepare_vg_with_copy "$dev1"
 pvck --dump headers "$dev1" || true
 dd if=/dev/zero of="$dev1" bs=512 count=1 seek=8
 pvck --dump headers "$dev1" || true
@@ -125,9 +131,7 @@ vgs $vg
 lvcreate -l1 -an $vg
 
 # One PV, two mdas, pv_header and mda_header1 zeroed
-rm meta || true
-dd if=/dev/zero of="$dev1" || true
-vgcreate --pvmetadatacopies 2 $vg "$dev1"
+_prepare_vg_with_copy "$dev1"
 pvck --dump headers "$dev1" || true
 dd if=/dev/zero of="$dev1" bs=512 count=2
 dd if=/dev/zero of="$dev1" bs=512 count=1 seek=8
@@ -143,9 +147,7 @@ vgs $vg
 lvcreate -l1 -an $vg
 
 # One PV, two mdas, metadata1 zeroed, use mda2
-rm meta || true
-dd if=/dev/zero of="$dev1" || true
-vgcreate --pvmetadatacopies 2 $vg "$dev1"
+_prepare_vg_with_copy "$dev1"
 pvck --dump headers "$dev1" || true
 dd if=/dev/zero of="$dev1" bs=512 count=2 seek=9
 pvck --dump headers "$dev1" || true
@@ -157,9 +159,7 @@ vgs $vg
 lvcreate -l1 -an $vg
 
 # One PV, two mdas, mda_header1 and metadata1 zeroed, use mda2
-rm meta || true
-dd if=/dev/zero of="$dev1" || true
-vgcreate --pvmetadatacopies 2 $vg "$dev1"
+_prepare_vg_with_copy "$dev1"
 pvck --dump headers "$dev1" || true
 dd if=/dev/zero of="$dev1" bs=512 count=3 seek=8
 pvck --dump headers "$dev1" || true
@@ -171,9 +171,7 @@ vgs $vg
 lvcreate -l1 -an $vg
 
 # One PV, two mdas, pv_header, mda_header1 and metadata1 zeroed, use mda2
-rm meta || true
-dd if=/dev/zero of="$dev1" || true
-vgcreate --pvmetadatacopies 2 $vg "$dev1"
+_prepare_vg_with_copy "$dev1"
 pvck --dump headers "$dev1" || true
 dd if=/dev/zero of="$dev1" bs=512 count=2
 dd if=/dev/zero of="$dev1" bs=512 count=3 seek=8
@@ -190,9 +188,7 @@ lvcreate -l1 -an $vg
 
 # One PV, two mdas, pv_header, both mda_header, and both metadata zeroed, use backup
 # only writes mda1 since there's no evidence that mda2 existed
-rm meta || true
-dd if=/dev/zero of="$dev1" || true
-vgcreate --pvmetadatacopies 2 $vg "$dev1"
+_prepare_vg_with_copy "$dev1"
 pvck --dump headers "$dev1" || true
 vgcfgbackup
 dd if=/dev/zero of="$dev1" bs=512 count=2
@@ -210,9 +206,7 @@ lvcreate -l1 -an $vg
 
 # One PV, two mdas, pv_header, both mda_header, and both metadata zeroed, use backup
 # writes mda1 and also mda2 because of the mda2 settings passed to repair
-rm meta || true
-dd if=/dev/zero of="$dev1" || true
-vgcreate --pvmetadatacopies 2 $vg "$dev1"
+_prepare_vg_with_copy "$dev1"
 pvck --dump headers "$dev1" || true
 vgcfgbackup
 dd if=/dev/zero of="$dev1" bs=512 count=2
@@ -229,10 +223,7 @@ vgs $vg
 lvcreate -l1 -an $vg
 
 # Two PV, one mda each, pv_header and mda_header zeroed on each
-rm meta || true
-dd if=/dev/zero of="$dev1" || true
-dd if=/dev/zero of="$dev2" || true
-vgcreate $vg "$dev1" "$dev2"
+_prepare_vg "$dev1" "$dev2"
 dd if=/dev/zero of="$dev1" bs=512 count=2
 dd if=/dev/zero of="$dev2" bs=512 count=2
 dd if=/dev/zero of="$dev1" bs=512 count=1 seek=8
@@ -248,10 +239,7 @@ vgs $vg
 lvcreate -l1 -an $vg
 
 # Two PV, one mda each, metadata zeroed on each, use backup
-rm meta || true
-dd if=/dev/zero of="$dev1" || true
-dd if=/dev/zero of="$dev2" || true
-vgcreate $vg "$dev1" "$dev2"
+_prepare_vg "$dev1" "$dev2"
 vgcfgbackup
 dd if=/dev/zero of="$dev1" bs=512 count=2 seek=9
 dd if=/dev/zero of="$dev2" bs=512 count=2 seek=9
@@ -265,10 +253,7 @@ vgs $vg
 lvcreate -l1 -an $vg
 
 # Two PV, one mda each, pv_header, mda_header and metadata zeroed on each, use backup
-rm meta || true
-dd if=/dev/zero of="$dev1" || true
-dd if=/dev/zero of="$dev2" || true
-vgcreate $vg "$dev1" "$dev2"
+_prepare_vg "$dev1" "$dev2"
 vgcfgbackup
 dd if=/dev/zero of="$dev1" bs=512 count=2
 dd if=/dev/zero of="$dev2" bs=512 count=2
@@ -284,10 +269,7 @@ vgs $vg
 lvcreate -l1 -an $vg
 
 # Two PV, one mda each, pv_header and mda_header zeroed on first
-rm meta || true
-dd if=/dev/zero of="$dev1" || true
-dd if=/dev/zero of="$dev2" || true
-vgcreate $vg "$dev1" "$dev2"
+_prepare_vg "$dev1" "$dev2"
 dd if=/dev/zero of="$dev1" bs=512 count=2
 dd if=/dev/zero of="$dev1" bs=512 count=1 seek=8
 pvck --dump headers "$dev1" || true
@@ -299,10 +281,7 @@ vgs $vg
 lvcreate -l1 -an $vg
 
 # Two PV, one mda each, metadata zeroed on first
-rm meta || true
-dd if=/dev/zero of="$dev1" || true
-dd if=/dev/zero of="$dev2" || true
-vgcreate $vg "$dev1" "$dev2"
+_prepare_vg "$dev1" "$dev2"
 dd if=/dev/zero of="$dev1" bs=512 count=2 seek=9
 pvck --dump headers "$dev1" || true
 pvck --dump headers "$dev2" || true
@@ -313,10 +292,7 @@ vgs $vg
 lvcreate -l1 -an $vg
 
 # Two PV, one mda each, pv_header, mda_header and metadata zeroed on first
-rm meta || true
-dd if=/dev/zero of="$dev1" || true
-dd if=/dev/zero of="$dev2" || true
-vgcreate $vg "$dev1" "$dev2"
+_prepare_vg "$dev1" "$dev2"
 dd if=/dev/zero of="$dev1" bs=512 count=2
 dd if=/dev/zero of="$dev1" bs=512 count=3 seek=8
 pvck --dump headers "$dev1" || true
@@ -328,9 +304,7 @@ vgs $vg
 lvcreate -l1 -an $vg
 
 # Two PV, one mda on first, no mda on second, zero header on first
-rm meta || true
-dd if=/dev/zero of="$dev1" || true
-dd if=/dev/zero of="$dev2" || true
+_clear_devs "$dev1" "$dev2"
 pvcreate "$dev1"
 pvcreate --pvmetadatacopies 0 "$dev2"
 vgcreate $vg "$dev1" "$dev2"
@@ -344,9 +318,7 @@ vgs $vg
 lvcreate -l1 -an $vg
 
 # Two PV, one mda on first, no mda on second, zero headers on both
-rm meta || true
-dd if=/dev/zero of="$dev1" || true
-dd if=/dev/zero of="$dev2" || true
+_clear_devs "$dev1" "$dev2"
 pvcreate "$dev1"
 pvcreate --pvmetadatacopies 0 "$dev2"
 vgcreate $vg "$dev1" "$dev2"
@@ -363,9 +335,7 @@ vgs $vg
 lvcreate -l1 -an $vg
 
 # Two PV, one mda on first, no mda on second, zero all on first
-rm meta || true
-dd if=/dev/zero of="$dev1" || true
-dd if=/dev/zero of="$dev2" || true
+_clear_devs "$dev1" "$dev2"
 pvcreate "$dev1"
 pvcreate --pvmetadatacopies 0 "$dev2"
 vgcreate $vg "$dev1" "$dev2"
@@ -382,9 +352,7 @@ vgs $vg
 lvcreate -l1 -an $vg
 
 # Two PV, two mda on each, pv_header and mda_header1 zeroed on both
-rm meta || true
-dd if=/dev/zero of="$dev1" || true
-dd if=/dev/zero of="$dev2" || true
+_clear_devs "$dev1" "$dev2"
 pvcreate --pvmetadatacopies 2 "$dev1"
 pvcreate --pvmetadatacopies 2 "$dev2"
 vgcreate $vg "$dev1" "$dev2"
@@ -407,9 +375,7 @@ lvcreate -l1 -an $vg
 
 # Two PV, one mda each, pv_header and mda_header zeroed on each,
 # non-standard data_offset/mda_size on first
-rm meta || true
-dd if=/dev/zero of="$dev1" || true
-dd if=/dev/zero of="$dev2" || true
+_clear_devs "$dev1" "$dev2"
 pvcreate --metadatasize 2048k --dataalignment 128k "$dev1"
 pvcreate "$dev2"
 vgcreate $vg "$dev1" "$dev2"
@@ -431,9 +397,7 @@ vgs $vg
 lvcreate -l1 -an $vg
 
 # One PV, one mda, pv_header zeroed, unmatching dev name requires specified uuid
-rm meta || true
-dd if=/dev/zero of="$dev1" || true
-dd if=/dev/zero of="$dev2" || true
+_clear_devs "$dev1" "$dev2"
 vgcreate $vg "$dev1"
 pvck --dump headers "$dev1" || true
 UUID1=`pvck --dump headers "$dev1" | grep pv_header.pv_uuid | awk '{print $2}'`
@@ -450,3 +414,4 @@ pvck --dump headers "$dev1" || true
 vgs $vg
 lvcreate -l1 -an $vg
 
+vgremove -f $vg
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
index 2e97fb1d8..2eb8e41cf 100644
--- a/test/shell/thin-dmeventd-warns.sh
+++ b/test/shell/thin-dmeventd-warns.sh
@@ -44,19 +44,19 @@ aux prepare_vg
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
@@ -71,7 +71,7 @@ sleep 11
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
index a40c75ab3..b93b0c60e 100644
--- a/test/shell/thin-many-dmeventd.sh
+++ b/test/shell/thin-many-dmeventd.sh
@@ -34,7 +34,7 @@ for i in $(seq 1 5)
 do
 	lvcreate --errorwhenfull y -Zn -T -L4M -V4M $vg/pool_${i} -n $lv${i}
         # Fill thin-pool to some capacity >50%
-	dd if=/dev/zero of="$DM_DEV_DIR/$vg/$lv${i}" bs=256K count=9 conv=fdatasync
+	dd if=/dev/zero of="$DM_DEV_DIR/$vg/$lv${i}" bs=256K count=9 oflag=direct
 done
 
 lvs -a $vg
@@ -63,7 +63,7 @@ do
 	DIFF=$(( END - START ))
 	test "$DIFF" -lt 8 || die "Creation of thin pool took more then 8 second! ($DIFF seconds)"
 	# Fill thin-pool to some capacity >50%
-	dd if=/dev/zero of="$DM_DEV_DIR/$vg/$lv${i}" bs=256K count=9 conv=fdatasync
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


