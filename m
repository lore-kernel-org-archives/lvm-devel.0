From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 10 Jul 2017 08:37:37 -0400
Subject: master - tests: replace cat usage
Message-ID: <201707101237.v6ACbbx9023464@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=160cb1e713d1b48f579c26d393e83ee0fd0e6e7d
Commit:        160cb1e713d1b48f579c26d393e83ee0fd0e6e7d
Parent:        e11de5847d8f367c6c07221db560d3c82371ed81
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jul 6 19:41:25 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 10 14:23:53 2017 +0200

tests: replace cat usage

---
 test/shell/000-basic.sh                        |    3 ++-
 test/shell/covercmd.sh                         |    2 +-
 test/shell/discards-thin.sh                    |    3 ++-
 test/shell/inconsistent-metadata.sh            |    9 +++++----
 test/shell/lv-ancestry.sh                      |    3 ++-
 test/shell/lvchange-raid1-writemostly.sh       |    3 ++-
 test/shell/lvchange-rebuild-raid.sh            |    7 ++++---
 test/shell/lvconvert-mirror-updown.sh          |    3 ++-
 test/shell/lvconvert-mirror.sh                 |    4 +++-
 test/shell/lvconvert-raid-allocation.sh        |    4 +++-
 test/shell/lvconvert-raid-reshape.sh           |    2 +-
 test/shell/lvconvert-raid-status-validation.sh |    4 +++-
 test/shell/lvconvert-raid.sh                   |    6 ++++--
 test/shell/lvconvert-raid10.sh                 |    4 +++-
 test/shell/lvconvert-repair.sh                 |    4 +++-
 test/shell/lvconvert-snapshot.sh               |    3 ++-
 test/shell/lvconvert-thin-external.sh          |    3 ++-
 test/shell/lvconvert-thin.sh                   |    5 +++--
 test/shell/lvcreate-large-raid.sh              |    5 +++--
 test/shell/lvcreate-operation.sh               |    4 +++-
 test/shell/lvcreate-pvtags.sh                  |    6 ++++--
 test/shell/lvcreate-raid.sh                    |    4 +++-
 test/shell/lvcreate-small-snap.sh              |    3 ++-
 test/shell/lvcreate-thin-big.sh                |    4 +++-
 test/shell/lvcreate-thin-external-size.sh      |    3 ++-
 test/shell/lvcreate-thin-external.sh           |    3 ++-
 test/shell/lvcreate-thin-power2.sh             |    3 ++-
 test/shell/lvcreate-thin-snap.sh               |    3 ++-
 test/shell/lvcreate-thin.sh                    |    3 ++-
 test/shell/lvcreate-usage.sh                   |    4 +++-
 test/shell/lvextend-percent-extents.sh         |    4 +++-
 test/shell/lvextend-thin-data-dmeventd.sh      |    3 ++-
 test/shell/lvextend-thin-metadata-dmeventd.sh  |    3 ++-
 test/shell/lvmcache-exercise.sh                |    3 ++-
 test/shell/lvmetad-pvs.sh                      |    8 +++++---
 test/shell/lvresize-raid.sh                    |    3 ++-
 test/shell/lvresize-rounding.sh                |    3 ++-
 test/shell/metadata-dirs.sh                    |   13 +++++++------
 test/shell/metadata.sh                         |   11 ++++++-----
 test/shell/mirror-vgreduce-removemissing.sh    |    3 ++-
 test/shell/pvmove-basic.sh                     |    6 ++++--
 test/shell/pvmove-raid-segtypes.sh             |    4 +++-
 test/shell/pvmove-thin-segtypes.sh             |    4 +++-
 test/shell/snapshot-lvm1.sh                    |    3 ++-
 test/shell/snapshot-maxsize.sh                 |    3 ++-
 test/shell/snapshot-usage-exa.sh               |    3 ++-
 test/shell/snapshot-usage.sh                   |    4 +++-
 test/shell/stray-device-node.sh                |    4 +++-
 test/shell/vgcfgbackup-lvm1.sh                 |    5 +++--
 test/shell/vgcfgbackup-usage.sh                |    3 ++-
 test/shell/vgchange-many.sh                    |   11 ++++++-----
 test/shell/vgchange-maxlv.sh                   |    5 +++--
 test/shell/vgreduce-usage.sh                   |    7 ++++---
 test/shell/vgsplit-thin.sh                     |    3 ++-
 test/shell/vgsplit-usage.sh                    |    9 +++++----
 55 files changed, 158 insertions(+), 87 deletions(-)

diff --git a/test/shell/000-basic.sh b/test/shell/000-basic.sh
index 2222456..c4a1f4a 100644
--- a/test/shell/000-basic.sh
+++ b/test/shell/000-basic.sh
@@ -29,7 +29,8 @@ diff -u dmstats-version lib/dm-version-expected
 
 # ensure we can create devices (uses dmsetup, etc)
 aux prepare_devs 5
+get_devs
 
 # ensure we do not crash on a bug in config file
 aux lvmconf 'log/prefix = 1""'
-not lvs $(cat DEVICES)
+not lvs "${DEVICES[@]}"
diff --git a/test/shell/covercmd.sh b/test/shell/covercmd.sh
index dbf8205..711ca13 100644
--- a/test/shell/covercmd.sh
+++ b/test/shell/covercmd.sh
@@ -29,7 +29,7 @@ pvcreate --metadatacopies 0 "$dev3"
 # FIXME takes very long time
 #pvck "$dev1"
 
-vgcreate $vg "${DEVICES[@]}"
+vgcreate "$vg" "${DEVICES[@]}"
 
 lvcreate -l 5 -i5 -I256 -n $lv $vg
 lvcreate -aey -l 5 -n $lv1 $vg
diff --git a/test/shell/discards-thin.sh b/test/shell/discards-thin.sh
index 2efb060..92df211 100644
--- a/test/shell/discards-thin.sh
+++ b/test/shell/discards-thin.sh
@@ -26,6 +26,7 @@ export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
 aux have_thin 1 1 0 || skip
 
 aux prepare_vg 2 64
+get_devs
 
 aux extend_filter_LVMTEST
 
@@ -79,7 +80,7 @@ vgremove -ff $vg
 # device below does not support it, the kernel value
 # of discards actually used will be "nopassdown".
 # This is why we have "-o discards" and "-o kernel_discards".
-vgcreate -s 1m ${vg}_1 $(cat DEVICES)
+vgcreate -s 1m "${vg}_1" "${DEVICES[@]}"
 lvcreate -l 10 -T ${vg}_1/pool --discards ignore
 lvcreate -V 9m -T ${vg}_1/pool -n device_with_ignored_discards
 vgcreate -s 1m ${vg}_2 "$DM_DEV_DIR/${vg}_1/device_with_ignored_discards"
diff --git a/test/shell/inconsistent-metadata.sh b/test/shell/inconsistent-metadata.sh
index cbb8412..36d7038 100644
--- a/test/shell/inconsistent-metadata.sh
+++ b/test/shell/inconsistent-metadata.sh
@@ -16,15 +16,16 @@ SKIP_WITH_LVMPOLLD=1
 . lib/inittest
 
 aux prepare_vg 3 12
+get_devs
 
 lvcreate -aye --type mirror -m 1 -l 1 -n mirror $vg
 lvcreate -l 1 -n resized $vg
 lvchange -a n $vg/mirror
 
-aux backup_dev $(cat DEVICES)
+aux backup_dev "${DEVICES[@]}"
 
 init() {
-	aux restore_dev $(cat DEVICES)
+	aux restore_dev "${DEVICES[@]}"
 	not check lv_field $vg/resized lv_size "8.00m"
 	lvresize -L 8192K $vg/resized
 	aux restore_dev "$dev1"
@@ -69,8 +70,8 @@ fi
 
 echo Check auto-repair of failed vgextend - metadata written to original pv but not new pv
 vgremove -f $vg
-pvremove -ff $(cat DEVICES)
-pvcreate $(cat DEVICES)
+pvremove -ff "${DEVICES[@]}"
+pvcreate "${DEVICES[@]}"
 aux backup_dev "$dev2"
 vgcreate $vg "$dev1"
 vgextend $vg "$dev2"
diff --git a/test/shell/lv-ancestry.sh b/test/shell/lv-ancestry.sh
index e32dfa3..732499f 100644
--- a/test/shell/lv-ancestry.sh
+++ b/test/shell/lv-ancestry.sh
@@ -16,10 +16,11 @@ SKIP_WITH_LVMPOLLD=1
 
 aux have_thin 1 0 0 || skip
 aux prepare_pvs 1 16
+get_devs
 
 aux lvmconf "metadata/record_lvs_history=1"
 
-vgcreate $vg -s 64K $(cat DEVICES)
+vgcreate -s 64K "$vg" "${DEVICES[@]}"
 
 lvcreate -l100%FREE -T ${vg}/pool
 
diff --git a/test/shell/lvchange-raid1-writemostly.sh b/test/shell/lvchange-raid1-writemostly.sh
index 32e84db..6e508c4 100644
--- a/test/shell/lvchange-raid1-writemostly.sh
+++ b/test/shell/lvchange-raid1-writemostly.sh
@@ -19,6 +19,7 @@ which mkfs.ext4 || skip
 aux have_raid 1 3 5 || skip
 
 aux prepare_vg 4
+get_devs
 
 for d in "$dev1" "$dev2" "$dev3" "$dev4"
 do
@@ -35,7 +36,7 @@ not lvchange -y --writemostly "$dev1" "$vg/$lv1"
 check lv_field $vg/$lv1 segtype "raid1"
 check lv_field $vg/$lv1 stripes 4
 check lv_attr_bit health $vg/${lv1}_rimage_0 "-"
-aux enable_dev $(< DEVICES)
+aux enable_dev "${DEVICES[@]}"
 aux wait_for_sync $vg $lv1
 lvchange -y --writemostly "$dev1" "$vg/$lv1"
 check lv_attr_bit health $vg/${lv1}_rimage_0 "w"
diff --git a/test/shell/lvchange-rebuild-raid.sh b/test/shell/lvchange-rebuild-raid.sh
index d7fa7e7..892d58d 100644
--- a/test/shell/lvchange-rebuild-raid.sh
+++ b/test/shell/lvchange-rebuild-raid.sh
@@ -18,19 +18,20 @@ SKIP_WITH_LVMPOLLD=1
 aux have_raid 1 3 2 || skip
 
 aux prepare_vg 8
+get_devs
 
 _sync() {
-	aux enable_dev $(< DEVICES)
+	aux enable_dev "${DEVICES[@]}"
 
 	aux wait_for_sync $vg $lv1
 	test -z "$1" || check raid_leg_status $vg $lv1 $1
 
 	# restore to delay_dev tables for all devices
-	aux restore_from_devtable $(< DEVICES)
+	aux restore_from_devtable "${DEVICES[@]}"
 }
 
 # Delay legs so that rebuilding status characters can be read
-for d in $(< DEVICES)
+for d in "${DEVICES[@]}"
 do
 	aux delay_dev "$d" 0 50 "$(get first_extent_sector "$d")"
 done
diff --git a/test/shell/lvconvert-mirror-updown.sh b/test/shell/lvconvert-mirror-updown.sh
index b419f2e..5c7b130 100644
--- a/test/shell/lvconvert-mirror-updown.sh
+++ b/test/shell/lvconvert-mirror-updown.sh
@@ -17,8 +17,9 @@ SKIP_WITH_LVMLOCKD=1
 . lib/inittest
 
 aux prepare_pvs 3
+get_devs
 
-vgcreate -s 64k $vg $(cat DEVICES)
+vgcreate -s 64k "$vg" "${DEVICES[@]}"
 
 lvcreate -aey -l10 --type mirror -m1 -n $lv1 $vg "$dev1" "$dev2"
 
diff --git a/test/shell/lvconvert-mirror.sh b/test/shell/lvconvert-mirror.sh
index 4fc80ac..d9dfdfb 100644
--- a/test/shell/lvconvert-mirror.sh
+++ b/test/shell/lvconvert-mirror.sh
@@ -18,9 +18,11 @@ export LVM_TEST_LVMETAD_DEBUG_OPTS=${LVM_TEST_LVMETAD_DEBUG_OPTS-}
 . lib/inittest
 
 aux prepare_pvs 5 20
+get_devs
+
 # proper DEVRANGE needs to be set according to extent size
 DEVRANGE="0-32"
-vgcreate -s 32k $vg $(cat DEVICES)
+vgcreate -s 32k "$vg" "${DEVICES[@]}"
 
 # convert from linear to 2-way mirror ("mirror" default type)
 lvcreate -aey -l2 -n $lv1 $vg "$dev1"
diff --git a/test/shell/lvconvert-raid-allocation.sh b/test/shell/lvconvert-raid-allocation.sh
index 0d8c794..7529800 100644
--- a/test/shell/lvconvert-raid-allocation.sh
+++ b/test/shell/lvconvert-raid-allocation.sh
@@ -18,7 +18,9 @@ SKIP_WITH_LVMPOLLD=1
 aux have_raid 1 3 0 || skip
 
 aux prepare_pvs 5
-vgcreate -s 256k $vg $(cat DEVICES)
+get_devs
+
+vgcreate -s 256k "$vg" "${DEVICES[@]}"
 
 # Start with linear on 2 PV and ensure that converting to
 # RAID is not allowed to reuse PVs for different images.  (Bug 1113180)
diff --git a/test/shell/lvconvert-raid-reshape.sh b/test/shell/lvconvert-raid-reshape.sh
index 73d1365..740f4ba 100644
--- a/test/shell/lvconvert-raid-reshape.sh
+++ b/test/shell/lvconvert-raid-reshape.sh
@@ -24,7 +24,7 @@ aux have_multi_core || skip
 
 aux prepare_pvs 65 64
 
-vgcreate -s 1M $vg $(cat DEVICES)
+vgcreate -s 1M "$vg" "${DEVICES[@]}"
 
 function _lvcreate
 {
diff --git a/test/shell/lvconvert-raid-status-validation.sh b/test/shell/lvconvert-raid-status-validation.sh
index fb5912f..cee3bfe 100644
--- a/test/shell/lvconvert-raid-status-validation.sh
+++ b/test/shell/lvconvert-raid-status-validation.sh
@@ -27,7 +27,9 @@ export LVM_TEST_LVMETAD_DEBUG_OPTS=${LVM_TEST_LVMETAD_DEBUG_OPTS-}
 aux have_raid 1 9 0 || skip
 
 aux prepare_pvs 9
-vgcreate -s 2m $vg $(cat DEVICES)
+get_devs
+
+vgcreate -s 2m "$vg" "${DEVICES[@]}"
 
 ###########################################
 # Upconverted RAID1 should never have all 'a's in status output
diff --git a/test/shell/lvconvert-raid.sh b/test/shell/lvconvert-raid.sh
index 0e7b9f2..b4ba4c9 100644
--- a/test/shell/lvconvert-raid.sh
+++ b/test/shell/lvconvert-raid.sh
@@ -33,8 +33,10 @@ get_image_pvs() {
 aux have_raid 1 3 0 || skip
 
 aux prepare_pvs 9
-# vgcreate -s 256k $vg $(cat DEVICES)
-vgcreate -s 2m $vg $(cat DEVICES)
+get_devs
+
+# vgcreate -s 256k "$vg" "${DEVICES[@]}"
+vgcreate -s 2m "$vg" "${DEVICES[@]}"
 
 ###########################################
 # RAID1 convert tests
diff --git a/test/shell/lvconvert-raid10.sh b/test/shell/lvconvert-raid10.sh
index f4ccc5a..e37d73a 100644
--- a/test/shell/lvconvert-raid10.sh
+++ b/test/shell/lvconvert-raid10.sh
@@ -32,7 +32,9 @@ aux have_raid 1 3 1 || skip
 
 # 9 PVs needed for RAID10 testing (3-stripes/2-mirror - replacing 3 devs)
 aux prepare_pvs 9 80
-vgcreate -s 256k $vg $(cat DEVICES)
+get_devs
+
+vgcreate -s 256k "$vg" "${DEVICES[@]}"
 
 lvcreate --type raid10 -m 1 -i 3 -l 3 -n $lv1 $vg
 aux wait_for_sync $vg $lv1
diff --git a/test/shell/lvconvert-repair.sh b/test/shell/lvconvert-repair.sh
index e0916e7..b5ae206 100644
--- a/test/shell/lvconvert-repair.sh
+++ b/test/shell/lvconvert-repair.sh
@@ -17,7 +17,7 @@ SKIP_WITH_LVMLOCKD=1
 recreate_vg_()
 {
 	vgremove -ff $vg
-	vgcreate $vg "$@" $(cat DEVICES)
+	vgcreate "$vg" "$@" "${DEVICES[@]}"
 }
 
 _check_mlog()
@@ -36,6 +36,8 @@ aux lvmconf "allocation/maximise_cling = 0" \
 
 # 4-way, disk log => 2-way, disk log
 aux prepare_vg 8
+get_devs
+
 lvcreate -aey --type mirror -m 3 --ignoremonitoring -L 1 -n 4way $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5":0
 aux disable_dev "$dev2" "$dev4"
 echo n | lvconvert --repair $vg/4way 2>&1 | tee 4way.out
diff --git a/test/shell/lvconvert-snapshot.sh b/test/shell/lvconvert-snapshot.sh
index d63cc67..f751c30 100644
--- a/test/shell/lvconvert-snapshot.sh
+++ b/test/shell/lvconvert-snapshot.sh
@@ -18,8 +18,9 @@ SKIP_WITH_LVMPOLLD=1
 . lib/inittest
 
 aux prepare_pvs 1
+get_devs
 
-vgcreate -s 1k $vg $(cat DEVICES)
+vgcreate -s 1k "$vg" "${DEVICES[@]}"
 
 lvcreate --type snapshot -V50 -L1 -n $lv1 -s $vg
 
diff --git a/test/shell/lvconvert-thin-external.sh b/test/shell/lvconvert-thin-external.sh
index 333a718..ee0463c 100644
--- a/test/shell/lvconvert-thin-external.sh
+++ b/test/shell/lvconvert-thin-external.sh
@@ -28,8 +28,9 @@ which fsck || skip
 aux have_thin 1 5 0 || skip
 
 aux prepare_pvs 2 64
+get_devs
 
-vgcreate $vg --metadatasize 128K -s 64K $(cat DEVICES)
+vgcreate "$vg" --metadatasize 128K -s 64K "${DEVICES[@]}"
 
 if test 0 -eq 1 ; then
 # FIXME: needs patch to allow inactive old-snap creation
diff --git a/test/shell/lvconvert-thin.sh b/test/shell/lvconvert-thin.sh
index 6960cd8..587f922 100644
--- a/test/shell/lvconvert-thin.sh
+++ b/test/shell/lvconvert-thin.sh
@@ -29,9 +29,10 @@ prepare_lvs() {
 aux have_thin 1 0 0 || skip
 
 aux prepare_pvs 4 64
+get_devs
 
 # build one large PV
-vgcreate $vg1 $(head -n 3 DEVICES)
+vgcreate $vg1 "$dev1" "$dev2" "$dev3"
 
 # 32bit linux kernels are fragille with device size >= 16T
 # maybe  uname -m    [ x86_64 | i686 ]
@@ -41,7 +42,7 @@ lvcreate --type snapshot -l 100%FREE -n $lv $vg1 --virtualsize $TSIZE
 aux extend_filter_LVMTEST
 
 pvcreate "$DM_DEV_DIR/$vg1/$lv"
-vgcreate $vg -s 64K $(tail -n+4 DEVICES) "$DM_DEV_DIR/$vg1/$lv"
+vgcreate $vg -s 64K "$dev4" "$DM_DEV_DIR/$vg1/$lv"
 
 lvcreate -L1T -n $lv1 $vg
 invalid lvconvert --yes -c 8M --type thin --poolmetadatasize 1G $vg/$lv1
diff --git a/test/shell/lvcreate-large-raid.sh b/test/shell/lvcreate-large-raid.sh
index 5562ead..1082731 100644
--- a/test/shell/lvcreate-large-raid.sh
+++ b/test/shell/lvcreate-large-raid.sh
@@ -27,13 +27,14 @@ aux have_raid4 && segtypes="raid4 raid5"
 
 # Prepare 5x ~1P sized devices
 aux prepare_pvs 5 1000000000
+get_devs
 
-vgcreate $vg1 $(< DEVICES)
+vgcreate "$vg1" "${DEVICES[@]}"
 
 aux lvmconf 'devices/issue_discards = 1'
 
 # Delay PVs so that resynchronization doesn't fill too much space
-for device in $(< DEVICES)
+for device in "${DEVICES[@]}"
 do
 	aux delay_dev "$device" 0 10  "$(get first_extent_sector "$device")"
 done
diff --git a/test/shell/lvcreate-operation.sh b/test/shell/lvcreate-operation.sh
index 7094a61..63d05db 100644
--- a/test/shell/lvcreate-operation.sh
+++ b/test/shell/lvcreate-operation.sh
@@ -24,8 +24,10 @@ cleanup_lvs() {
 }
 
 aux prepare_pvs 2
+get_devs
+
 aux pvcreate --metadatacopies 0 "$dev1"
-aux vgcreate $vg $(cat DEVICES)
+aux vgcreate "$vg" "${DEVICES[@]}"
 
 # ---
 # Create snapshots of LVs on --metadatacopies 0 PV (bz450651)
diff --git a/test/shell/lvcreate-pvtags.sh b/test/shell/lvcreate-pvtags.sh
index ef6c422..893b3ef 100644
--- a/test/shell/lvcreate-pvtags.sh
+++ b/test/shell/lvcreate-pvtags.sh
@@ -16,14 +16,16 @@ SKIP_WITH_LVMPOLLD=1
 . lib/inittest
 
 aux prepare_pvs 3
+get_devs
+
 aux lvmconf 'allocation/maximise_cling = 0' \
 	    'allocation/mirror_logs_require_separate_pvs = 1'
 
 # not required, just testing
 aux pvcreate --metadatacopies 0 "$dev1"
 
-vgcreate $vg $(cat DEVICES)
-pvchange --addtag fast $(cat DEVICES)
+vgcreate "$vg" "${DEVICES[@]}"
+pvchange --addtag fast "${DEVICES[@]}"
 
 # 3 stripes with 3 PVs (selected by tag, @fast) is fine
 lvcreate -l3 -i3 $vg @fast
diff --git a/test/shell/lvcreate-raid.sh b/test/shell/lvcreate-raid.sh
index eedc3d1..f29e788 100644
--- a/test/shell/lvcreate-raid.sh
+++ b/test/shell/lvcreate-raid.sh
@@ -28,7 +28,9 @@ RAID4=""
 aux have_raid4 && RAID4=raid4
 
 aux prepare_pvs 6 20  # 6 devices for RAID10 (2-mirror,3-stripe) test
-vgcreate -s 512k $vg $(cat DEVICES)
+get_devs
+
+vgcreate -s 512k "$vg" "${DEVICES[@]}"
 
 ###########################################
 # Create, wait for sync, remove tests
diff --git a/test/shell/lvcreate-small-snap.sh b/test/shell/lvcreate-small-snap.sh
index be44dce..00ea0a0 100644
--- a/test/shell/lvcreate-small-snap.sh
+++ b/test/shell/lvcreate-small-snap.sh
@@ -16,8 +16,9 @@ SKIP_WITH_LVMPOLLD=1
 . lib/inittest
 
 aux prepare_pvs
+get_devs
 
-vgcreate -s 1k $vg $(cat DEVICES)
+vgcreate -s 1k "$vg" "${DEVICES[@]}"
 
 # 3 Chunks
 lvcreate -aey -n one -l 10 $vg
diff --git a/test/shell/lvcreate-thin-big.sh b/test/shell/lvcreate-thin-big.sh
index c6c4a19..46e017a 100644
--- a/test/shell/lvcreate-thin-big.sh
+++ b/test/shell/lvcreate-thin-big.sh
@@ -25,7 +25,9 @@ aux have_thin 1 0 0 || skip
 # Test --poolmetadatasize range
 # allocating large devices for testing
 aux prepare_pvs 10 16500
-vgcreate $vg -s 64K $(cat DEVICES)
+get_devs
+
+vgcreate -s 64K "$vg" "${DEVICES[@]}"
 
 # Size 0 is not valid
 invalid lvcreate -L4M --chunksize 128 --poolmetadatasize 0 -T $vg/pool1 2>out
diff --git a/test/shell/lvcreate-thin-external-size.sh b/test/shell/lvcreate-thin-external-size.sh
index d26f590..c744150 100644
--- a/test/shell/lvcreate-thin-external-size.sh
+++ b/test/shell/lvcreate-thin-external-size.sh
@@ -29,9 +29,10 @@ which cmp || skip
 aux have_thin 1 13 0 || skip
 
 aux prepare_pvs 2 640
+get_devs
 
 # Use 8K extent size
-vgcreate $vg -s 8K $(cat DEVICES)
+vgcreate -s 8K "$vg" "${DEVICES[@]}"
 
 # Prepare some numeric pattern with ~64K size
 seq -s ' ' -w 0 10922 > 64K
diff --git a/test/shell/lvcreate-thin-external.sh b/test/shell/lvcreate-thin-external.sh
index a24136e..e94ffe3 100644
--- a/test/shell/lvcreate-thin-external.sh
+++ b/test/shell/lvcreate-thin-external.sh
@@ -28,8 +28,9 @@ which fsck || skip
 aux have_thin 1 3 0 || skip
 
 aux prepare_pvs 2 64
+get_devs
 
-vgcreate $vg -s 64K $(cat DEVICES)
+vgcreate -s 64K "$vg" "${DEVICES[@]}"
 
 # Newer thin-pool target (>= 1.13) supports unaligned external origin
 # But this test is written to test and expect older behavior
diff --git a/test/shell/lvcreate-thin-power2.sh b/test/shell/lvcreate-thin-power2.sh
index 3c39d59..18b2853 100644
--- a/test/shell/lvcreate-thin-power2.sh
+++ b/test/shell/lvcreate-thin-power2.sh
@@ -26,8 +26,9 @@ export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
 aux have_thin 1 4 0 || skip
 
 aux prepare_pvs 2 64
+get_devs
 
-vgcreate $vg -s 64K $(cat DEVICES)
+vgcreate -s 64K "$vg" "${DEVICES[@]}"
 
 # create non-power-of-2 pool
 lvcreate -l100 -c 192 -T $vg/pool
diff --git a/test/shell/lvcreate-thin-snap.sh b/test/shell/lvcreate-thin-snap.sh
index 2b4ddc4..ac603d8 100644
--- a/test/shell/lvcreate-thin-snap.sh
+++ b/test/shell/lvcreate-thin-snap.sh
@@ -35,8 +35,9 @@ aux have_thin 1 0 0 || skip
 which mkfs.ext4 || skip
 
 aux prepare_pvs 2 64
+get_devs
 
-vgcreate $vg -s 64K $(cat DEVICES)
+vgcreate -s 64K "$vg" "${DEVICES[@]}"
 
 lvcreate -L10M -V10M -T $vg/pool --name $lv1
 mkfs.ext4 "$DM_DEV_DIR/$vg/$lv1"
diff --git a/test/shell/lvcreate-thin.sh b/test/shell/lvcreate-thin.sh
index 1b7c238..375d4c0 100644
--- a/test/shell/lvcreate-thin.sh
+++ b/test/shell/lvcreate-thin.sh
@@ -37,8 +37,9 @@ aux have_thin 1 0 0 || skip
 which mkfs.ext4 || skip
 
 aux prepare_pvs 2 64
+get_devs
 
-vgcreate $vg -s 64K $(cat DEVICES)
+vgcreate -s 64K "$vg" "${DEVICES[@]}"
 
 # Create named pool only
 lvcreate -l1 -T $vg/pool1
diff --git a/test/shell/lvcreate-usage.sh b/test/shell/lvcreate-usage.sh
index edae918..a6be443 100644
--- a/test/shell/lvcreate-usage.sh
+++ b/test/shell/lvcreate-usage.sh
@@ -17,8 +17,10 @@ SKIP_WITH_LVMLOCKD=1
 . lib/inittest
 
 aux prepare_pvs 4
+get_devs
+
 aux pvcreate --metadatacopies 0 "$dev1"
-vgcreate $vg $(cat DEVICES)
+aux vgcreate "$vg" "${DEVICES[@]}"
 
 invalid lvcreate --type free -l1 -n $lv1 $vg 2>err
 grep "Invalid argument for --type" err
diff --git a/test/shell/lvextend-percent-extents.sh b/test/shell/lvextend-percent-extents.sh
index 2a807fa..c737310 100644
--- a/test/shell/lvextend-percent-extents.sh
+++ b/test/shell/lvextend-percent-extents.sh
@@ -18,7 +18,9 @@ SKIP_WITH_LVMPOLLD=1
 . lib/inittest
 
 aux prepare_pvs 2 128
-vgcreate $vg $(cat DEVICES)
+get_devs
+
+aux vgcreate "$vg" "${DEVICES[@]}"
 
 lvcreate -L64 -n $lv $vg
 
diff --git a/test/shell/lvextend-thin-data-dmeventd.sh b/test/shell/lvextend-thin-data-dmeventd.sh
index b5b21eb..dce7e8c 100644
--- a/test/shell/lvextend-thin-data-dmeventd.sh
+++ b/test/shell/lvextend-thin-data-dmeventd.sh
@@ -36,8 +36,9 @@ aux lvmconf "activation/thin_pool_autoextend_percent = 10" \
 	    "activation/thin_pool_autoextend_threshold = 75"
 
 aux prepare_pvs 3 256
+get_devs
 
-vgcreate -s 256K $vg $(cat DEVICES)
+vgcreate -s 256K "$vg" "${DEVICES[@]}"
 
 lvcreate -L1M -c 64k -T $vg/pool
 lvcreate -V1M $vg/pool -n $lv1
diff --git a/test/shell/lvextend-thin-metadata-dmeventd.sh b/test/shell/lvextend-thin-metadata-dmeventd.sh
index eacacb3..212df4b 100644
--- a/test/shell/lvextend-thin-metadata-dmeventd.sh
+++ b/test/shell/lvextend-thin-metadata-dmeventd.sh
@@ -62,8 +62,9 @@ aux have_thin 1 10 0 || skip
 aux prepare_dmeventd
 
 aux prepare_pvs 3 256
+get_devs
 
-vgcreate -s 1M $vg $(cat DEVICES)
+vgcreate -s 1M "$vg" "${DEVICES[@]}"
 
 # Testing dmeventd does NOT autoresize when default threshold 100% is left
 lvcreate -L200M -V50M -n thin -T $vg/pool
diff --git a/test/shell/lvmcache-exercise.sh b/test/shell/lvmcache-exercise.sh
index ee1a9e3..908cdf8 100644
--- a/test/shell/lvmcache-exercise.sh
+++ b/test/shell/lvmcache-exercise.sh
@@ -16,6 +16,7 @@ SKIP_WITH_LVMPOLLD=1
 . lib/inittest
 
 aux prepare_pvs 5
+get_devs
 
 vgcreate $vg1 "$dev1"
 vgcreate $vg2 "$dev3" "$dev4" "$dev5"
@@ -25,7 +26,7 @@ UUID1=$(get vg_field $vg1 uuid)
 aux disable_dev "$dev1"
 pvscan
 # dev1 is missing
-fail pvs $(cat DEVICES)
+fail pvs "${DEVICES[@]}"
 
 # create a new vg1 on dev2,
 # so dev1 and dev2 have different VGs with the same name
diff --git a/test/shell/lvmetad-pvs.sh b/test/shell/lvmetad-pvs.sh
index ba52d8a..4389528 100644
--- a/test/shell/lvmetad-pvs.sh
+++ b/test/shell/lvmetad-pvs.sh
@@ -16,8 +16,10 @@ SKIP_WITH_LVMPOLLD=1
 . lib/inittest
 
 aux prepare_pvs 1 20000
-pvs $(cat DEVICES) | grep "$dev1"
+get_devs
+
+pvs "${DEVICES[@]}" | grep "$dev1"
 
 # check for PV size overflows
-pvs $(cat DEVICES) | grep 19.53g
-pvs $(cat DEVICES) | not grep 16.00e
+pvs "${DEVICES[@]}" | grep 19.53g
+pvs "${DEVICES[@]}" | not grep 16.00e
diff --git a/test/shell/lvresize-raid.sh b/test/shell/lvresize-raid.sh
index 51a20c4..fd210a0 100644
--- a/test/shell/lvresize-raid.sh
+++ b/test/shell/lvresize-raid.sh
@@ -22,8 +22,9 @@ aux have_raid4 && levels="4 $levels"
 aux have_raid 1 7 0 && levels="0 0_meta $levels"
 
 aux prepare_pvs 6
+get_devs
 
-vgcreate -s 256K $vg $(cat DEVICES)
+vgcreate -s 256K "$vg" "${DEVICES[@]}"
 
 for deactivate in true false; do
 
diff --git a/test/shell/lvresize-rounding.sh b/test/shell/lvresize-rounding.sh
index 754127b..9a917ce 100644
--- a/test/shell/lvresize-rounding.sh
+++ b/test/shell/lvresize-rounding.sh
@@ -16,8 +16,9 @@ SKIP_WITH_LVMPOLLD=1
 . lib/inittest
 
 aux prepare_pvs 3 22
+get_devs
 
-vgcreate -s 32K $vg $(cat DEVICES)
+vgcreate -s 32K "$vg" "${DEVICES[@]}"
 
 lvcreate -an -Zn -l4 -i3 -I64 $vg
 
diff --git a/test/shell/metadata-dirs.sh b/test/shell/metadata-dirs.sh
index 3c21ac8..d30e3c7 100644
--- a/test/shell/metadata-dirs.sh
+++ b/test/shell/metadata-dirs.sh
@@ -16,9 +16,10 @@ SKIP_WITH_LVMPOLLD=1
 . lib/inittest
 
 aux prepare_devs 3
+get_devs
 
-pvcreate --metadatacopies 0 $(cat DEVICES)
-not vgcreate $vg $(cat DEVICES)
+pvcreate --metadatacopies 0 "${DEVICES[@]}"
+not vgcreate "$vg" "${DEVICES[@]}"
 
 aux lvmconf "metadata/dirs = [ \"$TESTDIR/mda\" ]"
 
@@ -26,22 +27,22 @@ vgcreate $vg "$dev1"
 check vg_field $vg vg_mda_count 1
 vgremove -ff $vg
 
-vgcreate $vg $(cat DEVICES)
+vgcreate "$vg" "${DEVICES[@]}"
 check vg_field $vg vg_mda_count 1
 vgremove -ff $vg
 
 pvcreate --metadatacopies 1 --metadataignore y "$dev1"
-vgcreate $vg $(cat DEVICES)
+vgcreate "$vg" "${DEVICES[@]}"
 check vg_field $vg vg_mda_count 2
 vgremove -ff $vg
 
 pvcreate --metadatacopies 1 --metadataignore n "$dev1"
-vgcreate $vg $(cat DEVICES)
+vgcreate "$vg" "${DEVICES[@]}"
 check vg_field $vg vg_mda_count 2
 vgremove -ff $vg
 
 pvcreate --metadatacopies 0 "$dev1"
 aux lvmconf "metadata/dirs = [ \"$TESTDIR/mda\", \"$TESTDIR/mda2\" ]"
-vgcreate $vg $(cat DEVICES)
+vgcreate "$vg" "${DEVICES[@]}"
 check vg_field $vg vg_mda_count 2
 vgremove -ff $vg
diff --git a/test/shell/metadata.sh b/test/shell/metadata.sh
index aac4f12..9492bdc 100644
--- a/test/shell/metadata.sh
+++ b/test/shell/metadata.sh
@@ -16,6 +16,7 @@ SKIP_WITH_LVMPOLLD=1
 . lib/inittest
 
 aux prepare_devs 5
+get_devs
 
 pvcreate "$dev1"
 pvcreate --metadatacopies 0 "$dev2"
@@ -23,7 +24,7 @@ pvcreate --metadatacopies 0 "$dev3"
 pvcreate "$dev4"
 pvcreate --metadatacopies 0 "$dev5"
 
-vgcreate $vg $(cat DEVICES)
+vgcreate "$vg" "${DEVICES[@]}"
 lvcreate -n $lv -l 1 -i5 -I256 $vg
 
 pvchange -x n "$dev1"
@@ -35,9 +36,9 @@ vgremove -f $vg
 
 # check that PVs without metadata don't cause too many full device rescans (bz452606)
 for mdacp in 1 0; do
-	pvcreate --metadatacopies $mdacp $(cat DEVICES)
+	pvcreate --metadatacopies "$mdacp" "${DEVICES[@]}"
 	pvcreate "$dev1"
-	vgcreate $vg $(cat DEVICES)
+	vgcreate "$vg" "${DEVICES[@]}"
 	lvcreate -n $lv1 -l 2 -i5 -I256 $vg
 	lvcreate -aey -n $lv2 --type mirror -m2 -l 2  $vg
 	lvchange -an $vg/$lv1 $vg/$lv2
@@ -61,7 +62,7 @@ check pv_field "$dev1" pe_start $pv_align
 check pv_field "$dev2" pe_start $pv_align
 check pv_field "$dev3" pe_start $pv_align
 
-pvs --units k -o name,pe_start,vg_mda_size,vg_name $(cat DEVICES)
+pvs --units k -o name,pe_start,vg_mda_size,vg_name "${DEVICES[@]}"
 
 # upgrade from v1 to v2 metadata
 vgconvert -M2 $vg
@@ -71,7 +72,7 @@ check pv_field "$dev1" pe_start $pv_align
 check pv_field "$dev2" pe_start $pv_align
 check pv_field "$dev3" pe_start $pv_align
 
-pvs --units k -o name,pe_start,vg_mda_size,vg_name $(cat DEVICES)
+pvs --units k -o name,pe_start,vg_mda_size,vg_name "${DEVICES[@]}"
 
 # create backup and then restore $dev3
 vgcfgbackup -f "$TESTDIR/bak-%s" "$vg"
diff --git a/test/shell/mirror-vgreduce-removemissing.sh b/test/shell/mirror-vgreduce-removemissing.sh
index 3d9ecd5..7f0c190 100644
--- a/test/shell/mirror-vgreduce-removemissing.sh
+++ b/test/shell/mirror-vgreduce-removemissing.sh
@@ -95,8 +95,9 @@ rest_pvs_()
 # Initialize PVs and VGs
 
 aux prepare_pvs 5 80
+get_devs
 
-vgcreate -s 64k $vg $(cat DEVICES)
+vgcreate -s 64k "$vg" "${DEVICES[@]}"
 BLOCKS=0-7
 BLOCKS1=8-15
 # ---------------------------------------------------------------------
diff --git a/test/shell/pvmove-basic.sh b/test/shell/pvmove-basic.sh
index 1cc5595..056274d 100644
--- a/test/shell/pvmove-basic.sh
+++ b/test/shell/pvmove-basic.sh
@@ -26,7 +26,7 @@ which md5sum || skip
 # Utilities
 
 create_vg_() {
-	vgcreate -c n -s 128k $vg $(cat DEVICES)
+	vgcreate -c n -s 128k "$vg" "${DEVICES[@]}"
 }
 
 # ---------------------------------------------------------------------
@@ -84,6 +84,8 @@ check_and_cleanup_lvs_() {
 # Initialize PVs and VGs
 
 aux prepare_pvs 5 5
+get_devs
+
 create_vg_
 
 for mode in "--atomic" ""
@@ -343,7 +345,7 @@ check_and_cleanup_lvs_
 
 #COMM "pvmove out of --metadatacopies 0 PV (bz252150)"
 vgremove -ff $vg
-pvcreate $(cat DEVICES)
+pvcreate "${DEVICES[@]}"
 pvcreate --metadatacopies 0 "$dev1" "$dev2"
 create_vg_
 lvcreate -l4 -n $lv1 $vg "$dev1"
diff --git a/test/shell/pvmove-raid-segtypes.sh b/test/shell/pvmove-raid-segtypes.sh
index c11210d..28e3e56 100644
--- a/test/shell/pvmove-raid-segtypes.sh
+++ b/test/shell/pvmove-raid-segtypes.sh
@@ -21,7 +21,9 @@ which md5sum || skip
 aux have_raid 1 3 5 || skip
 
 aux prepare_pvs 5 20
-vgcreate -c n -s 128k $vg $(cat DEVICES)
+get_devs
+
+vgcreate -c n -s 128k "$vg" "${DEVICES[@]}"
 
 for mode in "--atomic" ""
 do
diff --git a/test/shell/pvmove-thin-segtypes.sh b/test/shell/pvmove-thin-segtypes.sh
index 9a480c1..28f5233 100644
--- a/test/shell/pvmove-thin-segtypes.sh
+++ b/test/shell/pvmove-thin-segtypes.sh
@@ -23,7 +23,9 @@ aux have_thin 1 8 0 || skip
 aux have_raid 1 3 5 || skip
 
 aux prepare_pvs 5 20
-vgcreate -c n -s 128k $vg $(cat DEVICES)
+get_devs
+
+vgcreate -c n -s 128k "$vg" "${DEVICES[@]}" 
 
 for mode in "--atomic" ""
 do
diff --git a/test/shell/snapshot-lvm1.sh b/test/shell/snapshot-lvm1.sh
index 3a078b5..75c97cb 100644
--- a/test/shell/snapshot-lvm1.sh
+++ b/test/shell/snapshot-lvm1.sh
@@ -19,8 +19,9 @@ SKIP_WITH_LVMPOLLD=1
 . lib/inittest
 
 aux prepare_devs 2
+get_devs
 
-vgcreate --metadatatype 1 $vg $(cat DEVICES)
+vgcreate --metadatatype 1 "$vg" "${DEVICES[@]}"
 
 # Make origin volume
 lvcreate -ae -l5 $vg -n origin
diff --git a/test/shell/snapshot-maxsize.sh b/test/shell/snapshot-maxsize.sh
index 51d9d6d..9d8305c 100644
--- a/test/shell/snapshot-maxsize.sh
+++ b/test/shell/snapshot-maxsize.sh
@@ -19,8 +19,9 @@ SKIP_WITH_LVMPOLLD=1
 . lib/inittest
 
 aux prepare_pvs 1
+get_devs
 
-vgcreate -s 1K $vg $(cat DEVICES)
+vgcreate -s 1K "$vg" "${DEVICES[@]}"
 
 lvcreate -aey -L1 -n $lv1 $vg
 # Snapshot should be large enough to handle any writes
diff --git a/test/shell/snapshot-usage-exa.sh b/test/shell/snapshot-usage-exa.sh
index 6c4cb7e..5d666bf 100644
--- a/test/shell/snapshot-usage-exa.sh
+++ b/test/shell/snapshot-usage-exa.sh
@@ -21,9 +21,10 @@ SKIP_WITH_LVMPOLLD=1
 aux can_use_16T || skip
 
 aux prepare_pvs 1
+get_devs
 
 # Prepare large enough backend device
-vgcreate -s 4M $vg $(cat DEVICES)
+vgcreate -s 4M "$vg" "${DEVICES[@]}"
 lvcreate --type snapshot -s -l 100%FREE -n $lv $vg --virtualsize 15P
 aux extend_filter_LVMTEST
 
diff --git a/test/shell/snapshot-usage.sh b/test/shell/snapshot-usage.sh
index 3661022..14f74a1 100644
--- a/test/shell/snapshot-usage.sh
+++ b/test/shell/snapshot-usage.sh
@@ -57,7 +57,9 @@ if aux target_at_least dm-snapshot 1 10 0 ; then
 fi
 
 aux prepare_pvs 1
-vgcreate -s 4M $vg $(cat DEVICES)
+get_devs
+
+vgcreate -s 4M "$vg" "${DEVICES[@]}"
 
 # Play with 1 extent
 lvcreate -aey -l1 -n $lv $vg
diff --git a/test/shell/stray-device-node.sh b/test/shell/stray-device-node.sh
index 162913b..2467a47 100644
--- a/test/shell/stray-device-node.sh
+++ b/test/shell/stray-device-node.sh
@@ -16,9 +16,11 @@ SKIP_WITH_LVMPOLLD=1
 . lib/inittest
 
 aux prepare_devs 3
+get_devs
+
 cp -r "$dev1" "$DM_DEV_DIR/stray"
 
-vgcreate $vg $(cat DEVICES)
+vgcreate "$vg" "${DEVICES[@]}"
 lvcreate -an -Zn --type mirror -m 1 -l 1 -n mirror $vg
 aux disable_dev "$dev1"
 # FIXME:
diff --git a/test/shell/vgcfgbackup-lvm1.sh b/test/shell/vgcfgbackup-lvm1.sh
index 644f9b3..e9738e8 100644
--- a/test/shell/vgcfgbackup-lvm1.sh
+++ b/test/shell/vgcfgbackup-lvm1.sh
@@ -16,6 +16,7 @@ SKIP_WITH_LVMPOLLD=1
 . lib/inittest
 
 aux prepare_pvs 4
+get_devs
 
 if test -n "$LVM_TEST_LVM1" ; then
 
@@ -26,8 +27,8 @@ aux lvmconf "backup/backup = 0"
 
 # vgcfgbackup correctly stores metadata LVM1 with missing PVs
 
-pvcreate -M1 $(cat DEVICES)
-vgcreate -M1 -c n $vg $(cat DEVICES)
+pvcreate -M1 "${DEVICES[@]}"
+vgcreate -M1 -c n "$vg" "${DEVICES[@]}"
 lvcreate -l1 -n $lv1 $vg "$dev1"
 pvremove -ff -y "$dev2"
 not lvcreate -l1 -n $lv1 $vg "$dev3"
diff --git a/test/shell/vgcfgbackup-usage.sh b/test/shell/vgcfgbackup-usage.sh
index 6bf6cea..c506a14 100644
--- a/test/shell/vgcfgbackup-usage.sh
+++ b/test/shell/vgcfgbackup-usage.sh
@@ -16,6 +16,7 @@ SKIP_WITH_LVMPOLLD=1
 . lib/inittest
 
 aux prepare_pvs 4
+get_devs
 
 pvcreate --metadatacopies 0 "$dev4"
 
@@ -57,7 +58,7 @@ vgremove -ff $vg1 $vg2
 # and vgcfgrestore able to restore them when device reappears
 pv1_uuid=$(get pv_field "$dev1" pv_uuid)
 pv2_uuid=$(get pv_field "$dev2" pv_uuid)
-vgcreate $vg $(cat DEVICES)
+vgcreate "$vg" "${DEVICES[@]}"
 lvcreate -l1 -n $lv1 $vg "$dev1"
 lvcreate -l1 -n $lv2 $vg "$dev2"
 lvcreate -l1 -n $lv3 $vg "$dev3"
diff --git a/test/shell/vgchange-many.sh b/test/shell/vgchange-many.sh
index 2c73e48..95bc868 100644
--- a/test/shell/vgchange-many.sh
+++ b/test/shell/vgchange-many.sh
@@ -19,21 +19,22 @@ SKIP_WITH_LVMPOLLD=1
 # FIXME: lvmetad fails with i.e. 1500 device on memory failure...
 
 # Number of LVs to create
-DEVICES=1000
+TEST_DEVS=1000
 # On low-memory boxes let's not stress too much
-test "$(aux total_mem)" -gt 524288 || DEVICES=256
+test "$(aux total_mem)" -gt 524288 || TEST_DEVS=256
 
 aux prepare_pvs 1 400
+get_devs
 
-vgcreate -s 128K $vg $(cat DEVICES)
+vgcreate -s 128K "$vg" "${DEVICES[@]}"
 
 vgcfgbackup -f data $vg
 
 # Generate a lot of devices (size of 1 extent)
-awk -v DEVICES=$DEVICES '/^\t\}/ {
+awk -v TEST_DEVS=$TEST_DEVS '/^\t\}/ {
     printf("\t}\n\tlogical_volumes {\n");
     cnt=0;
-    for (i = 0; i < DEVICES; i++) {
+    for (i = 0; i < TEST_DEVS; i++) {
 	printf("\t\tlvol%06d  {\n", i);
 	printf("\t\t\tid = \"%06d-1111-2222-3333-2222-1111-%06d\"\n", i, i);
 	print "\t\t\tstatus = [\"READ\", \"WRITE\", \"VISIBLE\"]";
diff --git a/test/shell/vgchange-maxlv.sh b/test/shell/vgchange-maxlv.sh
index 455dbfe..987fa9e 100644
--- a/test/shell/vgchange-maxlv.sh
+++ b/test/shell/vgchange-maxlv.sh
@@ -17,14 +17,15 @@ SKIP_WITH_LVMPOLLD=1
 
 aux prepare_dmeventd
 aux prepare_pvs 3
+get_devs
 
-vgcreate -l 2 $vg $(cat DEVICES)
+vgcreate -l 2 "$vg" "${DEVICES[@]}"
 lvcreate -aey -n one -l 1 $vg
 lvcreate -n two -l 1 $vg
 not lvcreate -n three -l 1 $vg
 vgremove -ff $vg
 
-vgcreate -l 3 $vg $(cat DEVICES)
+vgcreate -l 3 "$vg" "${DEVICES[@]}"
 lvcreate -aey -n one -l 1 $vg
 lvcreate -n snap -s -l 1 $vg/one
 lvcreate -n two -l 1 $vg
diff --git a/test/shell/vgreduce-usage.sh b/test/shell/vgreduce-usage.sh
index d721514..e24be36 100644
--- a/test/shell/vgreduce-usage.sh
+++ b/test/shell/vgreduce-usage.sh
@@ -16,6 +16,7 @@ SKIP_WITH_LVMPOLLD=1
 . lib/inittest
 
 aux prepare_devs 4
+get_devs
 
 if test -n "$LVM_TEST_LVM1" ; then
 mdatypes='1 2'
@@ -78,11 +79,11 @@ not vgs $vg1 # just double-check it's really gone
 
 #COMM "vgreduce rejects --removemissing --mirrorsonly --force when nonmirror lv lost too"
 # (lvm$mdatype) setup: create mirror + linear lvs
-vgcreate -M$mdatype $vg1 $(cat DEVICES)
+vgcreate -M$mdatype "$vg1" "${DEVICES[@]}"
 lvcreate -n $lv2 -l 4 $vg1
 lvcreate -aey --type mirror -m1 -n $lv1 -l 4 $vg1 "$dev1" "$dev2" "$dev3"
 lvcreate -n $lv3 -l 4 $vg1 "$dev3"
-pvs --segments -o +lv_name $(cat DEVICES) # for record only
+pvs --segments -o +lv_name "${DEVICES[@]}" # for record only
 # (lvm$mdatype) setup: damage one pv
 vgchange -an $vg1
 aux disable_dev "$dev1"
@@ -94,7 +95,7 @@ vgreduce --removemissing --mirrorsonly --force $vg1
 
 aux enable_dev "$dev1"
 
-pvs -P $(cat DEVICES) # for record
+pvs -P "${DEVICES[@]}" # for record
 lvs -P $vg1           # for record
 vgs -P $vg1           # for record
 
diff --git a/test/shell/vgsplit-thin.sh b/test/shell/vgsplit-thin.sh
index 4a71426..0e4572e 100644
--- a/test/shell/vgsplit-thin.sh
+++ b/test/shell/vgsplit-thin.sh
@@ -22,8 +22,9 @@ export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
 aux have_thin 1 0 0 || skip
 
 aux prepare_devs 5
+get_devs
 
-vgcreate $vg1 $(cat DEVICES)
+vgcreate "$vg1" "${DEVICES[@]}"
 lvcreate -T -L8M $vg1/pool1 -V10M -n $lv1 "$dev1" "$dev2"
 lvcreate -T -L8M $vg1/pool2 -V10M -n $lv2 "$dev3" "$dev4"
 
diff --git a/test/shell/vgsplit-usage.sh b/test/shell/vgsplit-usage.sh
index f49e13a..98818ab 100644
--- a/test/shell/vgsplit-usage.sh
+++ b/test/shell/vgsplit-usage.sh
@@ -18,6 +18,7 @@ SKIP_WITH_LVMPOLLD=1
 . lib/inittest
 
 aux prepare_devs 5
+get_devs
 
 if test -n "$LVM_TEST_LVM1" ; then
 mdatypes='1 2'
@@ -28,21 +29,21 @@ fi
 for mdatype in $mdatypes
 do
 
-pvcreate -M$mdatype $(cat DEVICES)
+pvcreate -M$mdatype "${DEVICES[@]}"
 
 # ensure name order does not matter
 # NOTE: if we're using lvm1, we must use -M on vgsplit
-vgcreate -M$mdatype $vg1 $(cat DEVICES)
+vgcreate -M$mdatype "$vg1" "${DEVICES[@]}"
 vgsplit -M$mdatype $vg1 $vg2 "$dev1"
 vgremove $vg1 $vg2
 
-vgcreate -M$mdatype $vg2 $(cat DEVICES)
+vgcreate -M$mdatype "$vg2" "${DEVICES[@]}"
 vgsplit -M$mdatype $vg2 $vg1 "$dev1"
 vgremove $vg1 $vg2
 
 # vgsplit accepts new vg as destination of split
 # lvm1 -- bz244792
-vgcreate -M$mdatype $vg1 $(cat DEVICES)
+vgcreate -M$mdatype "$vg1" "${DEVICES[@]}"
 vgsplit $vg1 $vg2 "$dev1" 1>err
 grep "New volume group \"$vg2\" successfully split from \"$vg1\"" err
 vgremove $vg1 $vg2


