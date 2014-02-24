From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 24 Feb 2014 20:17:23 +0000 (UTC)
Subject: master - tests: add some quotes
Message-ID: <20140224201723.1C4ED609F7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9c9f4515ae433beb2e6a582aacc422feb73c09dd
Commit:        9c9f4515ae433beb2e6a582aacc422feb73c09dd
Parent:        f8780e2d79596fcb3197e922247597d77336257e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Feb 22 23:08:55 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 24 21:13:36 2014 +0100

tests: add some quotes

Use quotes for DM_DEV_DIR
---
 test/shell/lvconvert-repair-dmeventd.sh           |    2 +-
 test/shell/lvconvert-repair-thin.sh               |   26 ++++++++++----------
 test/shell/lvconvert-repair-transient-dmeventd.sh |    2 +-
 test/shell/lvconvert-repair-transient.sh          |    2 +-
 test/shell/lvconvert-thin-external.sh             |    8 +++---
 test/shell/lvcreate-large-raid.sh                 |    4 +-
 test/shell/lvcreate-large-raid10.sh               |    4 +-
 test/shell/lvcreate-large.sh                      |    4 +-
 test/shell/lvcreate-pvtags.sh                     |    2 +-
 test/shell/lvcreate-thin-external.sh              |    8 +++---
 test/shell/lvcreate-thin-snap.sh                  |    8 +++---
 test/shell/lvcreate-thin.sh                       |    4 +-
 test/shell/name-mangling.sh                       |    4 +-
 test/shell/read-ahead.sh                          |    2 +-
 test/shell/snapshot-usage.sh                      |   12 +++++-----
 test/shell/thin-merge.sh                          |   16 ++++++------
 test/shell/vgsplit-stacked.sh                     |    4 +-
 17 files changed, 56 insertions(+), 56 deletions(-)

diff --git a/test/shell/lvconvert-repair-dmeventd.sh b/test/shell/lvconvert-repair-dmeventd.sh
index 1604ecb..a2d3ef8 100644
--- a/test/shell/lvconvert-repair-dmeventd.sh
+++ b/test/shell/lvconvert-repair-dmeventd.sh
@@ -20,7 +20,7 @@ aux prepare_vg 5
 lvcreate -aey --type mirror -m 3 --ignoremonitoring -L 1 -n 4way $vg
 lvchange --monitor y $vg/4way
 aux disable_dev "$dev2" "$dev4"
-mkfs.ext2 $DM_DEV_DIR/$vg/4way
+mkfs.ext2 "$DM_DEV_DIR/$vg/4way"
 sleep 10 # FIXME: need a "poll" utility, akin to "check"
 aux enable_dev "$dev2" "$dev4"
 check mirror $vg 4way
diff --git a/test/shell/lvconvert-repair-thin.sh b/test/shell/lvconvert-repair-thin.sh
index aa301d6..b80b855 100644
--- a/test/shell/lvconvert-repair-thin.sh
+++ b/test/shell/lvconvert-repair-thin.sh
@@ -10,7 +10,7 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-# Test repairing of broken thin pool metadata 
+# Test repairing of broken thin pool metadata
 
 . lib/test
 
@@ -34,8 +34,8 @@ aux prepare_vg 4
 lvcreate -T -L20 -V10 -n $lv1 $vg/pool  "$dev1" "$dev2"
 lvcreate -T -V10 -n $lv2 $vg/pool
 
-mkfs.ext2 $DM_DEV_DIR/$vg/$lv1
-mkfs.ext2 $DM_DEV_DIR/$vg/$lv2
+mkfs.ext2 "$DM_DEV_DIR/$vg/$lv1"
+mkfs.ext2 "$DM_DEV_DIR/$vg/$lv2"
 
 lvcreate -L20 -n repair $vg
 lvcreate -L2 -n fixed $vg
@@ -55,26 +55,26 @@ lvconvert -y -f --poolmetadata $vg/repair --thinpool $vg/pool
 
 lvchange -aey $vg/repair $vg/fixed
 
-#dd if=$DM_DEV_DIR/$vg/repair of=back bs=1M
+#dd if="$DM_DEV_DIR/$vg/repair" of=back bs=1M
 
 # Make some 'repairable' damage??
-dd if=/dev/zero of=$DM_DEV_DIR/$vg/repair bs=1 seek=40960 count=1
+dd if=/dev/zero of="$DM_DEV_DIR/$vg/repair" bs=1 seek=40960 count=1
 
-#dd if=$DM_DEV_DIR/$vg/repair of=back_trashed bs=1M
+#dd if="$DM_DEV_DIR/$vg/repair" of=back_trashed bs=1M
 #not vgchange -ay $vg
 
 #lvconvert --repair $vg/pool
 
 # Using now SHOULD - since thin tools currently do not seem to work
-should not $THIN_CHECK $DM_DEV_DIR/$vg/repair
+should not "$THIN_CHECK" "$DM_DEV_DIR/$vg/repair"
 
-should not $LVM_TEST_THIN_DUMP_CMD $DM_DEV_DIR/$vg/repair | tee dump
+should not "$LVM_TEST_THIN_DUMP_CMD" "$DM_DEV_DIR/$vg/repair" | tee dump
 
-should $LVM_TEST_THIN_REPAIR_CMD -i $DM_DEV_DIR/$vg/repair -o $DM_DEV_DIR/$vg/fixed
+should "$LVM_TEST_THIN_REPAIR_CMD" -i "$DM_DEV_DIR/$vg/repair" -o "$DM_DEV_DIR/$vg/fixed"
 
-should $LVM_TEST_THIN_DUMP_CMD --repair $DM_DEV_DIR/$vg/repair | tee repaired_xml
+should "$LVM_TEST_THIN_DUMP_CMD" --repair "$DM_DEV_DIR/$vg/repair" | tee repaired_xml
 
-should $LVM_TEST_THIN_CHECK_CMD $DM_DEV_DIR/$vg/fixed
+should "$LVM_TEST_THIN_CHECK_CMD" "$DM_DEV_DIR/$vg/fixed"
 
 # Swap repaired metadata back
 lvconvert -y -f --poolmetadata $vg/fixed --thinpool $vg/pool
@@ -83,7 +83,7 @@ lvs -a $vg
 # Activate pool - this should now work
 should vgchange -ay $vg
 
-lvs -a -o+devices $vg 
+lvs -a -o+devices $vg
 dmsetup table
 dmsetup info -c
 dmsetup ls --tree
@@ -99,7 +99,7 @@ dmsetup remove $vg-pool_tmeta || true
 
 dmsetup table
 
-# FIXME: needs  also --yes with double force 
+# FIXME: needs  also --yes with double force
 pvremove --yes -ff "$dev1"
 pvremove --yes -ff "$dev2"
 
diff --git a/test/shell/lvconvert-repair-transient-dmeventd.sh b/test/shell/lvconvert-repair-transient-dmeventd.sh
index 699195a..6bd1442 100644
--- a/test/shell/lvconvert-repair-transient-dmeventd.sh
+++ b/test/shell/lvconvert-repair-transient-dmeventd.sh
@@ -18,7 +18,7 @@ aux prepare_dmeventd
 lvcreate -aey --type mirror -m 3 --ignoremonitoring -L 1 -n 4way $vg
 lvchange --monitor y $vg/4way
 aux disable_dev "$dev2" "$dev4"
-mkfs.ext3 $DM_DEV_DIR/$vg/4way
+mkfs.ext3 "$DM_DEV_DIR/$vg/4way"
 aux enable_dev "$dev2" "$dev4"
 sleep 3
 lvs -a -o +devices $vg | tee out
diff --git a/test/shell/lvconvert-repair-transient.sh b/test/shell/lvconvert-repair-transient.sh
index 28b06c6..3baa293 100644
--- a/test/shell/lvconvert-repair-transient.sh
+++ b/test/shell/lvconvert-repair-transient.sh
@@ -16,7 +16,7 @@ aux prepare_vg 5
 
 lvcreate -aey --type mirror -m 3 --ignoremonitoring -L 1 -n 4way $vg
 aux disable_dev "$dev2" "$dev4"
-mkfs.ext3 $DM_DEV_DIR/$vg/4way &
+mkfs.ext3 "$DM_DEV_DIR/$vg/4way" &
 sleep 1
 aux enable_dev "$dev2" "$dev4"
 echo n | lvconvert --repair $vg/4way 2>&1 | tee 4way.out
diff --git a/test/shell/lvconvert-thin-external.sh b/test/shell/lvconvert-thin-external.sh
index dbe5972..00712bd 100644
--- a/test/shell/lvconvert-thin-external.sh
+++ b/test/shell/lvconvert-thin-external.sh
@@ -64,9 +64,9 @@ lvcreate -L8M -n $lv1 $vg
 not lvconvert --thinpool $vg/$lv1 -T $vg/$lv1
 check lv_field $vg/$lv1 segtype linear
 
-mkfs.ext2 $DM_DEV_DIR/$vg/$lv1
+mkfs.ext2 "$DM_DEV_DIR/$vg/$lv1"
 mkdir mnt
-mount $DM_DEV_DIR/$vg/$lv1 mnt
+mount "$DM_DEV_DIR/$vg/$lv1" mnt
 
 dd if=/dev/zero of=mnt/test1 bs=1M count=1
 
@@ -84,7 +84,7 @@ touch mnt/test
 umount mnt
 
 # check fs is without errors
-fsck -n $DM_DEV_DIR/$vg/$lv1
+fsck -n "$DM_DEV_DIR/$vg/$lv1"
 
 lvchange -aey $vg/extorg
 lvchange -an $vg/$lv1
@@ -93,7 +93,7 @@ check active $vg extorg
 check inactive $vg $lv1
 
 # fsck in read-only mode
-fsck -n $DM_DEV_DIR/$vg/extorg
+fsck -n "$DM_DEV_DIR/$vg/extorg"
 
 not lvresize -l+8 $vg/extorg
 not lvresize -l-4 $vg/extorg
diff --git a/test/shell/lvcreate-large-raid.sh b/test/shell/lvcreate-large-raid.sh
index 395cf2b..e5d883c 100644
--- a/test/shell/lvcreate-large-raid.sh
+++ b/test/shell/lvcreate-large-raid.sh
@@ -31,8 +31,8 @@ lvcreate -s -l 20%FREE -n $lv5 $vg --virtualsize 256T
 
 aux extend_filter_LVMTEST
 
-pvcreate $DM_DEV_DIR/$vg/$lv[12345]
-vgcreate $vg1 $DM_DEV_DIR/$vg/$lv[12345]
+pvcreate "$DM_DEV_DIR"/$vg/$lv[12345]
+vgcreate $vg1 "$DM_DEV_DIR"/$vg/$lv[12345]
 
 # bz837927 START
 
diff --git a/test/shell/lvcreate-large-raid10.sh b/test/shell/lvcreate-large-raid10.sh
index 4f97997..3d02e81 100644
--- a/test/shell/lvcreate-large-raid10.sh
+++ b/test/shell/lvcreate-large-raid10.sh
@@ -28,8 +28,8 @@ lvcreate -s -l 20%FREE -n $lv5 $vg --virtualsize 256T
 
 aux extend_filter_LVMTEST
 
-pvcreate $DM_DEV_DIR/$vg/$lv[12345]
-vgcreate $vg1 $DM_DEV_DIR/$vg/$lv[12345]
+pvcreate "$DM_DEV_DIR"/$vg/$lv[12345]
+vgcreate $vg1 "$DM_DEV_DIR"/$vg/$lv[12345]
 
 #
 # Create large RAID LVs
diff --git a/test/shell/lvcreate-large.sh b/test/shell/lvcreate-large.sh
index c8790f1..f3d3f30 100644
--- a/test/shell/lvcreate-large.sh
+++ b/test/shell/lvcreate-large.sh
@@ -25,8 +25,8 @@ lvcreate -s -l 100%FREE -n $lv $vg --virtualsize 1024T
 
 aux extend_filter_LVMTEST
 
-pvcreate $DM_DEV_DIR/$vg/$lv
-vgcreate $vg1 $DM_DEV_DIR/$vg/$lv
+pvcreate "$DM_DEV_DIR/$vg/$lv"
+vgcreate $vg1 "$DM_DEV_DIR/$vg/$lv"
 
 lvcreate -l 100%FREE -n $lv1 $vg1
 check lv_field $vg1/$lv1 size "1024.00t"
diff --git a/test/shell/lvcreate-pvtags.sh b/test/shell/lvcreate-pvtags.sh
index 20a241c..340a4f4 100644
--- a/test/shell/lvcreate-pvtags.sh
+++ b/test/shell/lvcreate-pvtags.sh
@@ -28,7 +28,7 @@ lvcreate -l3 -i3 $vg @fast
 not lvcreate -l4 -i4 $vg @fast
 
 # 2 stripes is too many with just one PV
-not lvcreate -l2 -i2 $vg $DM_DEV_DIR/mapper/pv1
+not lvcreate -l2 -i2 $vg "$DM_DEV_DIR/mapper/pv1"
 
 # lvcreate mirror
 lvcreate -aey -l1 --type mirror -m1 $vg @fast
diff --git a/test/shell/lvcreate-thin-external.sh b/test/shell/lvcreate-thin-external.sh
index 14c7f82..1e5b333 100644
--- a/test/shell/lvcreate-thin-external.sh
+++ b/test/shell/lvcreate-thin-external.sh
@@ -37,10 +37,10 @@ lvremove -f $vg
 
 # Prepare pool and external origin with filesystem
 lvcreate -L10M -V10M -T $vg/pool --name $lv1
-mkfs.ext2 $DM_DEV_DIR/$vg/$lv1
+mkfs.ext2 "$DM_DEV_DIR/$vg/$lv1"
 
 lvcreate -L4M -n $lv2 $vg
-mkfs.ext2 $DM_DEV_DIR/$vg/$lv2
+mkfs.ext2 "$DM_DEV_DIR/$vg/$lv2"
 
 # Fail to create external origin snapshot of rw LV
 not lvcreate -s $vg/$lv2 --thinpool $vg/pool
@@ -90,7 +90,7 @@ check active $vg $lv5
 check active $vg $lv6
 check active $vg $lv7
 
-fsck -n $DM_DEV_DIR/$vg/$lv1
-fsck -n $DM_DEV_DIR/$vg/$lv7
+fsck -n "$DM_DEV_DIR/$vg/$lv1"
+fsck -n "$DM_DEV_DIR/$vg/$lv7"
 
 vgremove -ff $vg
diff --git a/test/shell/lvcreate-thin-snap.sh b/test/shell/lvcreate-thin-snap.sh
index b7511e7..cfc801a 100644
--- a/test/shell/lvcreate-thin-snap.sh
+++ b/test/shell/lvcreate-thin-snap.sh
@@ -33,11 +33,11 @@ aux prepare_pvs 2 64
 vgcreate $vg -s 64K $(cat DEVICES)
 
 lvcreate -L10M -V10M -T $vg/pool --name $lv1
-mkfs.ext4 $DM_DEV_DIR/$vg/$lv1
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv1"
 # create thin snapshot of thin LV
 lvcreate -K -s $vg/$lv1 --name snap
 # check snapshot filesystem was properly frozen before snapping
-fsck -n $DM_DEV_DIR/$vg/snap
+fsck -n "$DM_DEV_DIR/$vg/snap"
 lvcreate -K -s $vg/$lv1 --name $lv2
 lvcreate -K -s $vg/$lv1 --name $vg/$lv3
 lvcreate --type snapshot $vg/$lv1
@@ -57,8 +57,8 @@ lvcreate -K -s --name sn4 $vg/sn3
 lvremove -ff $vg
 
 lvcreate -L10M --zero n -T $vg/pool -V10M --name $lv1
-mkfs.ext4 $DM_DEV_DIR/$vg/$lv1
+mkfs.ext4 "$DM_DEV_DIR/$vg/$lv1"
 lvcreate -K -s $vg/$lv1 --name snap
-fsck -n $DM_DEV_DIR/$vg/snap
+fsck -n "$DM_DEV_DIR/$vg/snap"
 
 vgremove -ff $vg
diff --git a/test/shell/lvcreate-thin.sh b/test/shell/lvcreate-thin.sh
index 98ab7eb..a2811d2 100644
--- a/test/shell/lvcreate-thin.sh
+++ b/test/shell/lvcreate-thin.sh
@@ -136,9 +136,9 @@ check vg_field $vg lv_count 0
 
 # Create thin snapshot of thinLV
 lvcreate -L10M -V10M -T $vg/pool --name lv1
-mkfs.ext4 $DM_DEV_DIR/$vg/lv1
+mkfs.ext4 "$DM_DEV_DIR/$vg/lv1"
 lvcreate -K -s $vg/lv1 --name snap_lv1
-fsck -n $DM_DEV_DIR/$vg/snap_lv1
+fsck -n "$DM_DEV_DIR/$vg/snap_lv1"
 lvcreate -s $vg/lv1 --name lv2
 lvcreate -s $vg/lv1 --name $vg/lv3
 lvcreate --type snapshot $vg/lv1 --name lv6
diff --git a/test/shell/name-mangling.sh b/test/shell/name-mangling.sh
index 5b92e60..76d90fa 100644
--- a/test/shell/name-mangling.sh
+++ b/test/shell/name-mangling.sh
@@ -164,8 +164,8 @@ function check_mangle_cmd()
 # check dmsetup can process path where the last component is not equal dm name (rhbz #797322)
 r=0
 create_dm_dev auto "abc"
-ln -s ${DM_DEV_DIR}/mapper/${name_prefix}abc ${DM_DEV_DIR}/${name_prefix}xyz
-dmsetup status ${DM_DEV_DIR}/${name_prefix}xyz || r=1
+ln -s "$DM_DEV_DIR/mapper/${name_prefix}abc" "$DM_DEV_DIR/${name_prefix}xyz"
+dmsetup status "$DM_DEV_DIR/${name_prefix}xyz" || r=1
 remove_dm_dev auto "abc"
 if [ r = 1 ]; then
 	exit 1
diff --git a/test/shell/read-ahead.sh b/test/shell/read-ahead.sh
index 8c8f42c..264910c 100644
--- a/test/shell/read-ahead.sh
+++ b/test/shell/read-ahead.sh
@@ -34,7 +34,7 @@ lvremove -ff $vg
 blockdev --setra 768 "$dev1"
 vgscan
 lvcreate -n $lv -L4m $vg "$dev1"
-test $(blockdev --getra $DM_DEV_DIR/$vg/$lv) -eq 768
+test $(blockdev --getra "$DM_DEV_DIR/$vg/$lv") -eq 768
 lvremove -ff $vg
 
 # Check default, active/inactive values for read_ahead / kernel_read_ahead
diff --git a/test/shell/snapshot-usage.sh b/test/shell/snapshot-usage.sh
index 14a87c0..fb88ae1 100644
--- a/test/shell/snapshot-usage.sh
+++ b/test/shell/snapshot-usage.sh
@@ -14,7 +14,7 @@
 . lib/test
 
 fill() {
-	dd if=/dev/zero of=$DM_DEV_DIR/$vg1/lvol0 bs=$1 count=1
+	dd if=/dev/zero of="$DM_DEV_DIR/$vg1/lvol0" bs=$1 count=1
 }
 
 cleanup_tail()
@@ -37,8 +37,8 @@ aux lvmconf "activation/snapshot_autoextend_percent = 20" \
             "activation/snapshot_autoextend_threshold = 50"
 
 # Check usability with smallest extent size
-pvcreate --setphysicalvolumesize 4T $DM_DEV_DIR/$vg/$lv
-vgcreate -s 1K $vg1 $DM_DEV_DIR/$vg/$lv
+pvcreate --setphysicalvolumesize 4T "$DM_DEV_DIR/$vg/$lv"
+vgcreate -s 1K $vg1 "$DM_DEV_DIR/$vg/$lv"
 
 # Test removal of opened snapshot
 lvcreate -V50 -L10 -n $lv1 -s $vg1
@@ -52,7 +52,7 @@ lvs -a -o+lv_active $vg1
 
 trap 'cleanup_tail' EXIT
 # Keep device busy (but not mounted) for a while
-sleep 30 < $DM_DEV_DIR/$vg1/$lv1 &
+sleep 30 < "$DM_DEV_DIR/$vg1/$lv1" &
 SLEEP_PID=$!
 
 # give some short time to lock file above
@@ -116,8 +116,8 @@ vgremove -ff $vg1
 if test "$TSIZE" -eq 15P ; then
 
 # Check usability with largest extent size
-pvcreate $DM_DEV_DIR/$vg/$lv
-vgcreate -s 4G $vg1 $DM_DEV_DIR/$vg/$lv
+pvcreate "$DM_DEV_DIR/$vg/$lv"
+vgcreate -s 4G $vg1 "$DM_DEV_DIR/$vg/$lv"
 
 lvcreate -an -Zn -l50%FREE -n $lv1 $vg1
 lvcreate -s -l100%FREE -n $lv2 $vg1/$lv1
diff --git a/test/shell/thin-merge.sh b/test/shell/thin-merge.sh
index 0bb5ee7..7eb137e 100644
--- a/test/shell/thin-merge.sh
+++ b/test/shell/thin-merge.sh
@@ -28,14 +28,14 @@ lvcreate -T -L8M $vg/pool -V10M -n $lv1
 lvchange --addtag tagL $vg/$lv1
 
 mkdir mnt
-$MKFS $DM_DEV_DIR/$vg/$lv1
-mount $DM_DEV_DIR/$vg/$lv1 mnt
+$MKFS "$DM_DEV_DIR/$vg/$lv1"
+mount "$DM_DEV_DIR/$vg/$lv1" mnt
 touch mnt/test
 
 lvcreate -K -s -n snap --addtag tagS $vg/$lv1
 mkdir mntsnap
-$MKFS $DM_DEV_DIR/$vg/snap
-mount $DM_DEV_DIR/$vg/snap mntsnap
+$MKFS "$DM_DEV_DIR/$vg/snap"
+mount "$DM_DEV_DIR/$vg/snap" mntsnap
 touch mntsnap/test_snap
 
 lvs -o+tags,thin_id $vg
@@ -85,8 +85,8 @@ check lv_field  $vg/$lv1 thin_id "2"
 check lv_field $vg/$lv1 tags "tagL"
 check lv_not_exists $vg snap
 
-fsck -n $DM_DEV_DIR/$vg/$lv1
-mount $DM_DEV_DIR/$vg/$lv1 mnt
+fsck -n "$DM_DEV_DIR/$vg/$lv1"
+mount "$DM_DEV_DIR/$vg/$lv1" mnt
 test -e mnt/test_snap
 umount mnt
 
@@ -98,9 +98,9 @@ lvcreate -s -n snap $vg/$lv1
 # Also add old snapshot to thin origin
 lvcreate -s -L10 -n oldsnapof_${lv1} $vg/$lv1
 not lvconvert --merge $vg/snap
-$MKFS $DM_DEV_DIR/$vg/oldsnapof_${lv1}
+$MKFS "$DM_DEV_DIR/$vg/oldsnapof_${lv1}"
 lvconvert --merge $vg/oldsnapof_${lv1}
-fsck -n $DM_DEV_DIR/$vg/$lv1
+fsck -n "$DM_DEV_DIR/$vg/$lv1"
 check lv_not_exists $vg oldsnapof_${lv1}
 # Add old snapshot to thin snapshot
 lvcreate -s -L10 -n oldsnapof_snap $vg/snap
diff --git a/test/shell/vgsplit-stacked.sh b/test/shell/vgsplit-stacked.sh
index 3256191..c8b89b5 100644
--- a/test/shell/vgsplit-stacked.sh
+++ b/test/shell/vgsplit-stacked.sh
@@ -18,8 +18,8 @@ vgcreate $vg1 "$dev1" "$dev2"
 lvcreate -n $lv1 -l 100%FREE $vg1
 
 #top VG
-pvcreate $DM_DEV_DIR/$vg1/$lv1
-vgcreate $vg $DM_DEV_DIR/$vg1/$lv1 "$dev3"
+pvcreate "$DM_DEV_DIR/$vg1/$lv1"
+vgcreate $vg "$DM_DEV_DIR/$vg1/$lv1" "$dev3"
 
 vgchange -a n $vg $vg1
 


