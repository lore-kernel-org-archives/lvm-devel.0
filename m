From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 27 Feb 2014 12:01:32 +0000 (UTC)
Subject: master - tests: updates
Message-ID: <20140227120132.4A76B60311@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=47b15b805ed5f605cd9ce93137df409c05fb0b46
Commit:        47b15b805ed5f605cd9ce93137df409c05fb0b46
Parent:        d00fc1de784cee27d6ddb1b045a67c930f743074
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Feb 26 23:25:30 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Feb 27 13:01:04 2014 +0100

tests: updates

Add some vgremove calls.
Remove uneeded test for some unused commands.
Add tests for missing commands.
---
 test/shell/activate-minor.sh                  |    2 ++
 test/shell/activate-missing-segment.sh        |    2 ++
 test/shell/activate-missing.sh                |    2 ++
 test/shell/activate-partial.sh                |    2 +-
 test/shell/activation-skip.sh                 |    2 ++
 test/shell/covercmd.sh                        |    2 ++
 test/shell/fsadm.sh                           |    2 ++
 test/shell/inconsistent-metadata.sh           |    2 ++
 test/shell/listings.sh                        |    2 ++
 test/shell/lock-blocking.sh                   |    2 ++
 test/shell/lock-parallel.sh                   |    2 ++
 test/shell/lvchange-mirror.sh                 |    3 ++-
 test/shell/lvchange-partial-raid10.sh         |    3 ++-
 test/shell/lvchange-partial.sh                |    3 ++-
 test/shell/lvchange-raid.sh                   |    2 ++
 test/shell/lvconvert-mirror-basic-0.sh        |    3 +++
 test/shell/lvconvert-mirror-basic-1.sh        |    3 +++
 test/shell/lvconvert-mirror-basic-2.sh        |    3 +++
 test/shell/lvconvert-mirror-basic-3.sh        |    3 +++
 test/shell/lvconvert-mirror.sh                |    2 ++
 test/shell/lvconvert-raid.sh                  |    2 ++
 test/shell/lvconvert-raid10.sh                |    2 +-
 test/shell/lvconvert-repair-policy.sh         |    2 ++
 test/shell/lvconvert-repair-snapshot.sh       |    2 ++
 test/shell/lvconvert-repair-thin.sh           |    2 ++
 test/shell/lvconvert-twostep.sh               |    2 ++
 test/shell/lvcreate-cache.sh                  |    3 ++-
 test/shell/lvcreate-large-raid.sh             |    2 +-
 test/shell/lvcreate-large-raid10.sh           |    4 ++--
 test/shell/lvcreate-large.sh                  |    2 ++
 test/shell/lvcreate-mirror.sh                 |    2 ++
 test/shell/lvcreate-missing.sh                |    2 ++
 test/shell/lvcreate-operation.sh              |    2 ++
 test/shell/lvcreate-raid.sh                   |    3 ++-
 test/shell/lvcreate-raid10.sh                 |    1 +
 test/shell/lvcreate-thin-snap.sh              |    5 +++--
 test/shell/lvcreate-thin.sh                   |    2 +-
 test/shell/lvmcache-exercise.sh               |    2 ++
 test/shell/lvmetad-dump.sh                    |    2 ++
 test/shell/lvmetad-no-cluster.sh              |    2 ++
 test/shell/lvmetad-override.sh                |    1 +
 test/shell/lvmetad-pvscan-cache.sh            |    2 ++
 test/shell/lvmetad-pvscan-nomda.sh            |    2 ++
 test/shell/lvmetad-restart.sh                 |    2 ++
 test/shell/lvmetad-warning.sh                 |    2 ++
 test/shell/lvresize-mirror.sh                 |    2 ++
 test/shell/pvmove-all-segtypes.sh             |    3 ++-
 test/shell/pvmove-basic.sh                    |    1 -
 test/shell/pvmove-cache-segtypes.sh           |    1 -
 test/shell/pvmove-raid-segtypes.sh            |    4 ++--
 test/shell/pvmove-restart.sh                  |    2 ++
 test/shell/pvmove-thin-segtypes.sh            |    3 ++-
 test/shell/pvremove-usage.sh                  |    2 ++
 test/shell/read-ahead.sh                      |    3 ++-
 test/shell/snapshot-lvm1.sh                   |    2 ++
 test/shell/tags.sh                            |    2 ++
 test/shell/unknown-segment.sh                 |    2 ++
 test/shell/unlost-pv.sh                       |    2 ++
 test/shell/vg-name-from-env.sh                |    1 +
 test/shell/vgchange-many.sh                   |    2 ++
 test/shell/vgchange-maxlv.sh                  |    2 ++
 test/shell/vgchange-partial.sh                |    2 ++
 test/shell/vgchange-sysinit.sh                |    5 +++++
 test/shell/vgchange-usage.sh                  |    1 +
 test/shell/vgck.sh                            |    2 ++
 test/shell/vgextend-restoremissing.sh         |    2 ++
 test/shell/vgimportclone.sh                   |    2 ++
 test/shell/vgreduce-removemissing-snapshot.sh |    2 ++
 test/shell/vgreduce-usage.sh                  |    2 ++
 test/shell/vgsplit-stacked.sh                 |    2 ++
 70 files changed, 136 insertions(+), 20 deletions(-)

diff --git a/test/shell/activate-minor.sh b/test/shell/activate-minor.sh
index 3726faa..1cebda4 100644
--- a/test/shell/activate-minor.sh
+++ b/test/shell/activate-minor.sh
@@ -21,3 +21,5 @@ lvchange $vg/foo -My --major=255 --minor=123
 lvchange $vg/foo -a y
 dmsetup info $vg-foo | tee info
 egrep "^Major, minor: *[0-9]+, 123" info
+
+vgremove -ff $vg
diff --git a/test/shell/activate-missing-segment.sh b/test/shell/activate-missing-segment.sh
index 55ec7ec..afda20f 100644
--- a/test/shell/activate-missing-segment.sh
+++ b/test/shell/activate-missing-segment.sh
@@ -27,3 +27,5 @@ aux disable_dev "$dev1"
 not vgchange -a y $vg
 vgchange -a y --partial $vg
 check active $vg span
+
+vgremove -ff $vg
diff --git a/test/shell/activate-missing.sh b/test/shell/activate-missing.sh
index 6f7c7a2..fd57e1a 100644
--- a/test/shell/activate-missing.sh
+++ b/test/shell/activate-missing.sh
@@ -84,3 +84,5 @@ check active $vg linear2
 check active $vg linear12
 check active $vg mirror12
 check active $vg mirror123
+
+vgremove -ff $vg
diff --git a/test/shell/activate-partial.sh b/test/shell/activate-partial.sh
index 757c696..cbfa433 100644
--- a/test/shell/activate-partial.sh
+++ b/test/shell/activate-partial.sh
@@ -28,4 +28,4 @@ vgchange -a n --partial $vg
 vgchange -aey --partial $vg
 
 # check vgremove
-vgremove -f $vg
+vgremove -ff $vg
diff --git a/test/shell/activation-skip.sh b/test/shell/activation-skip.sh
index 7c80283..76680b2 100644
--- a/test/shell/activation-skip.sh
+++ b/test/shell/activation-skip.sh
@@ -30,3 +30,5 @@ get lv_field $vg/$lv1 lv_attr | grep -- "-wi------k"
 
 lvchange -ay -K $vg
 check active $vg $lv1
+
+vgremove -ff $vg
diff --git a/test/shell/covercmd.sh b/test/shell/covercmd.sh
index 7a24a9c..f9a04e9 100644
--- a/test/shell/covercmd.sh
+++ b/test/shell/covercmd.sh
@@ -122,3 +122,5 @@ lvcreate -l1 -an -Zn $vg3
 vgdisplay -s -A | grep $vg1
 vgdisplay -s -A | grep $vg2
 vgdisplay -s -A | not grep $vg3
+
+vgremove -ff $vg1 $vg2 $vg3
diff --git a/test/shell/fsadm.sh b/test/shell/fsadm.sh
index 8d4b37d..13e5304 100644
--- a/test/shell/fsadm.sh
+++ b/test/shell/fsadm.sh
@@ -17,10 +17,12 @@ aux prepare_vg 1 100
 
 # set to "skip" to avoid testing given fs and test warning result
 # i.e. check_reiserfs=skip
+check_ext2=
 check_ext3=
 check_xfs=
 check_reiserfs=
 
+which mkfs.ext2 || check_ext2=${check_ext2:-mkfs.ext2}
 which mkfs.ext3 || check_ext3=${check_ext3:-mkfs.ext3}
 which fsck.ext3 || check_ext3=${check_ext3:-fsck.ext3}
 which mkfs.xfs || check_xfs=${check_xfs:-mkfs.xfs}
diff --git a/test/shell/inconsistent-metadata.sh b/test/shell/inconsistent-metadata.sh
index 699fea7..06bd310 100644
--- a/test/shell/inconsistent-metadata.sh
+++ b/test/shell/inconsistent-metadata.sh
@@ -73,3 +73,5 @@ vgextend $vg "$dev2"
 aux restore_dev "$dev2"
 vgscan $cache
 should check compare_fields vgs $vg vg_mda_count pvs "$dev2" vg_mda_count
+
+vgremove -ff $vg
diff --git a/test/shell/listings.sh b/test/shell/listings.sh
index e5a3954..bb72055 100644
--- a/test/shell/listings.sh
+++ b/test/shell/listings.sh
@@ -72,3 +72,5 @@ not diff out out2
 
 aux disable_dev $dev1
 pvs -o +pv_uuid | grep BADBEE-BAAD-BAAD-BAAD-BAAD-BAAD-BADBEE
+
+vgremove -ff $vg
diff --git a/test/shell/lock-blocking.sh b/test/shell/lock-blocking.sh
index 480a73b..aaf2e0b 100644
--- a/test/shell/lock-blocking.sh
+++ b/test/shell/lock-blocking.sh
@@ -39,3 +39,5 @@ flock_pid=`jobs -p`
 not vgremove --config 'global { wait_for_locks = 0 }' $vg
 test -f $TESTDIR/var/lock/lvm/P_orphans # still running
 kill $flock_pid
+
+vgremove -ff $vg
diff --git a/test/shell/lock-parallel.sh b/test/shell/lock-parallel.sh
index 4820129..e7d15ef 100644
--- a/test/shell/lock-parallel.sh
+++ b/test/shell/lock-parallel.sh
@@ -38,3 +38,5 @@ aux enable_dev "$dev1"
 
 # Check removed $lv2 does not reappear
 not check lv_exists $vg $lv2
+
+vgremove -ff $vg
diff --git a/test/shell/lvchange-mirror.sh b/test/shell/lvchange-mirror.sh
index 1a0c06b..37a6e1b 100644
--- a/test/shell/lvchange-mirror.sh
+++ b/test/shell/lvchange-mirror.sh
@@ -31,4 +31,5 @@ lvchange -an $vg/$lv1
 check mirror $vg $lv1 "$dev3"
 lvchange --resync $vg/$lv1
 check mirror $vg $lv1 "$dev3"
-lvremove -ff $vg
+
+vgremove -ff $vg
diff --git a/test/shell/lvchange-partial-raid10.sh b/test/shell/lvchange-partial-raid10.sh
index 64a2389..3141add 100644
--- a/test/shell/lvchange-partial-raid10.sh
+++ b/test/shell/lvchange-partial-raid10.sh
@@ -26,4 +26,5 @@ lvchange -ay $vg/$lv1 --partial
 lvchange -an $vg/$lv1
 
 aux enable_dev "$dev1"
-lvremove -ff $vg
+
+vgremove -ff $vg
diff --git a/test/shell/lvchange-partial.sh b/test/shell/lvchange-partial.sh
index b79004d..7483d88 100644
--- a/test/shell/lvchange-partial.sh
+++ b/test/shell/lvchange-partial.sh
@@ -67,4 +67,5 @@ not lvchange --resync -ay $vg/$lv1
 not lvchange --resync --addtag foo $vg/$lv1
 
 aux enable_dev "$dev1"
-lvremove -ff $vg
+
+vgremove -ff $vg
diff --git a/test/shell/lvchange-raid.sh b/test/shell/lvchange-raid.sh
index 0ee5290..b6107b9 100644
--- a/test/shell/lvchange-raid.sh
+++ b/test/shell/lvchange-raid.sh
@@ -357,3 +357,5 @@ for i in "-" "snapshot" "thinpool_data" "thinpool_meta"; do
 	run_checks $vg $lv1 $i
 	lvremove -ff $vg
 done
+
+vgremove -ff $vg
diff --git a/test/shell/lvconvert-mirror-basic-0.sh b/test/shell/lvconvert-mirror-basic-0.sh
index dc71bb8..f08b58e 100644
--- a/test/shell/lvconvert-mirror-basic-0.sh
+++ b/test/shell/lvconvert-mirror-basic-0.sh
@@ -10,4 +10,7 @@
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 . ./shell/lvconvert-mirror-basic.sh
+
 test_many 0
+
+vgremove -ff $vg
diff --git a/test/shell/lvconvert-mirror-basic-1.sh b/test/shell/lvconvert-mirror-basic-1.sh
index b7ebf9e..f50f2e1 100644
--- a/test/shell/lvconvert-mirror-basic-1.sh
+++ b/test/shell/lvconvert-mirror-basic-1.sh
@@ -10,4 +10,7 @@
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 . ./shell/lvconvert-mirror-basic.sh
+
 test_many 1
+
+vgremove -ff $vg
diff --git a/test/shell/lvconvert-mirror-basic-2.sh b/test/shell/lvconvert-mirror-basic-2.sh
index d47f77d..480206c 100644
--- a/test/shell/lvconvert-mirror-basic-2.sh
+++ b/test/shell/lvconvert-mirror-basic-2.sh
@@ -10,4 +10,7 @@
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 . ./shell/lvconvert-mirror-basic.sh
+
 test_many 2
+
+vgremove -ff $vg
diff --git a/test/shell/lvconvert-mirror-basic-3.sh b/test/shell/lvconvert-mirror-basic-3.sh
index 732fb2d..ce906c8 100644
--- a/test/shell/lvconvert-mirror-basic-3.sh
+++ b/test/shell/lvconvert-mirror-basic-3.sh
@@ -10,4 +10,7 @@
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 . ./shell/lvconvert-mirror-basic.sh
+
 test_many 3
+
+vgremove -ff $vg
diff --git a/test/shell/lvconvert-mirror.sh b/test/shell/lvconvert-mirror.sh
index 097e0d4..1e9925a 100644
--- a/test/shell/lvconvert-mirror.sh
+++ b/test/shell/lvconvert-mirror.sh
@@ -305,3 +305,5 @@ lvchange -an $vg/$lv1
 lvconvert --mirrorlog disk $vg/$lv1 "$dev3:0-1"
 check mirror $vg $lv1 "$dev3"
 lvremove -ff $vg
+
+vgremove -ff $vg
diff --git a/test/shell/lvconvert-raid.sh b/test/shell/lvconvert-raid.sh
index 0bdb023..a2a7792 100644
--- a/test/shell/lvconvert-raid.sh
+++ b/test/shell/lvconvert-raid.sh
@@ -239,3 +239,5 @@ for i in 4 5 6; do
 
 	lvremove -ff $vg
 done
+
+vgremove -ff $vg
diff --git a/test/shell/lvconvert-raid10.sh b/test/shell/lvconvert-raid10.sh
index 4b3ceb4..6297f65 100644
--- a/test/shell/lvconvert-raid10.sh
+++ b/test/shell/lvconvert-raid10.sh
@@ -55,4 +55,4 @@ for i in 0 1; do
 	aux wait_for_sync $vg $lv1
 done
 
-lvremove -ff $vg
+vgremove -ff $vg
diff --git a/test/shell/lvconvert-repair-policy.sh b/test/shell/lvconvert-repair-policy.sh
index 49afb7b..f3fe139 100644
--- a/test/shell/lvconvert-repair-policy.sh
+++ b/test/shell/lvconvert-repair-policy.sh
@@ -89,3 +89,5 @@ repair 'activation { mirror_log_fault_policy = "remove" }'
 check mirror $vg mirror core
 not check lv_exists $vg mirror_mlog
 cleanup "$dev3" "$dev4"
+
+vgremove -ff $vg
diff --git a/test/shell/lvconvert-repair-snapshot.sh b/test/shell/lvconvert-repair-snapshot.sh
index 29576bb..77fd217 100644
--- a/test/shell/lvconvert-repair-snapshot.sh
+++ b/test/shell/lvconvert-repair-snapshot.sh
@@ -25,3 +25,5 @@ vgreduce --removemissing $vg
 aux enable_dev "$dev2" "$dev4"
 lvs -a -o +devices $vg
 check mirror $vg 4way "$dev5"
+
+vgremove -ff $vg
diff --git a/test/shell/lvconvert-repair-thin.sh b/test/shell/lvconvert-repair-thin.sh
index b80b855..37a24ff 100644
--- a/test/shell/lvconvert-repair-thin.sh
+++ b/test/shell/lvconvert-repair-thin.sh
@@ -114,3 +114,5 @@ should vgremove -ff  $vg
 # Let's do a final forced cleanup
 pvremove --yes -ff "$dev3"
 pvremove --yes -ff "$dev4"
+
+vgremove -ff $vg
diff --git a/test/shell/lvconvert-twostep.sh b/test/shell/lvconvert-twostep.sh
index 8417e6a..6b1dd51 100644
--- a/test/shell/lvconvert-twostep.sh
+++ b/test/shell/lvconvert-twostep.sh
@@ -26,3 +26,5 @@ test -e LOCAL_CLVMD && exit 0
 # FIXME  mirrored unsupported in cluster
 not lvconvert -m 1 --mirrorlog mirrored $vg/mirror "$dev3" "$dev4" 2>&1 | tee errs
 grep "two steps" errs
+
+vgremove -ff $vg
diff --git a/test/shell/lvcreate-cache.sh b/test/shell/lvcreate-cache.sh
index ccfb4ad..21ef5fe 100644
--- a/test/shell/lvcreate-cache.sh
+++ b/test/shell/lvcreate-cache.sh
@@ -127,7 +127,6 @@ lvremove -ff $vg
 # Attempt to create smaller cache than origin should fail
 lvcreate -l 1 -n $lv1 $vg
 not lvcreate --type cache -l 2 $vg/$lv1
-lvremove -ff $vg
 
 
 # Option testing
@@ -135,3 +134,5 @@ lvremove -ff $vg
 # --cachepolicy
 # --poolmetadatasize
 # --poolmetadataspare
+
+vgremove -ff $vg
diff --git a/test/shell/lvcreate-large-raid.sh b/test/shell/lvcreate-large-raid.sh
index e5d883c..3f06d04 100644
--- a/test/shell/lvcreate-large-raid.sh
+++ b/test/shell/lvcreate-large-raid.sh
@@ -71,4 +71,4 @@ lvremove -ff $vg1
 
 # bz837927 END
 
-lvremove -ff $vg
+vgremove -ff $vg
diff --git a/test/shell/lvcreate-large-raid10.sh b/test/shell/lvcreate-large-raid10.sh
index 3d02e81..635d7a3 100644
--- a/test/shell/lvcreate-large-raid10.sh
+++ b/test/shell/lvcreate-large-raid10.sh
@@ -38,6 +38,6 @@ vgcreate $vg1 "$DM_DEV_DIR"/$vg/$lv[12345]
 
 lvcreate --type raid10 -m 1 -i 2 -L 200T -n $lv1 $vg1 --nosync
 check lv_field $vg1/$lv1 size "200.00t"
-lvremove -ff $vg1
+vgremove -ff $vg1
 
-lvremove -ff $vg
+vgremove -ff $vg
diff --git a/test/shell/lvcreate-large.sh b/test/shell/lvcreate-large.sh
index f3d3f30..401191b 100644
--- a/test/shell/lvcreate-large.sh
+++ b/test/shell/lvcreate-large.sh
@@ -41,3 +41,5 @@ check lv_field $vg1/$lv1 size "737.28t"
 lvremove -ff $vg1/$lv1
 
 lvremove -ff $vg/$lv
+
+vgremove -ff $vg
diff --git a/test/shell/lvcreate-mirror.sh b/test/shell/lvcreate-mirror.sh
index 7826800..6b54081 100644
--- a/test/shell/lvcreate-mirror.sh
+++ b/test/shell/lvcreate-mirror.sh
@@ -34,3 +34,5 @@ lvremove -ff $vg
 
 # creating 2-way mirror with disklog from 2 PVs fails
 not lvcreate -aey -l2 --type mirror -m1 -n $lv1 $vg "$dev1" "$dev2"
+
+vgremove -ff $vg
diff --git a/test/shell/lvcreate-missing.sh b/test/shell/lvcreate-missing.sh
index 63471c3..dfc6e65 100644
--- a/test/shell/lvcreate-missing.sh
+++ b/test/shell/lvcreate-missing.sh
@@ -17,3 +17,5 @@ dmsetup remove -f "$dev1" || true
 finish_udev_transaction
 
 not lvcreate -n "foo" $vg -l 1
+
+vgremove -ff $vg
diff --git a/test/shell/lvcreate-operation.sh b/test/shell/lvcreate-operation.sh
index 6fc20b6..2aa96d2 100644
--- a/test/shell/lvcreate-operation.sh
+++ b/test/shell/lvcreate-operation.sh
@@ -42,3 +42,5 @@ cleanup_lvs
 # Create mirror on one dev with mirrored log using --alloc anywhere, should fail
 not lvcreate --type mirror -m 1 -l4 -n $lv1 --mirrorlog mirrored $vg --alloc anywhere "$dev1"
 cleanup_lvs
+
+vgremove -ff $vg
diff --git a/test/shell/lvcreate-raid.sh b/test/shell/lvcreate-raid.sh
index 2053d04..a8ae4f1 100644
--- a/test/shell/lvcreate-raid.sh
+++ b/test/shell/lvcreate-raid.sh
@@ -187,4 +187,5 @@ lvcreate --type raid5 -l2 -n raid5 $vg
 lv_devices $vg raid5 6
 lvcreate --type raid6 -l3 -n raid6 $vg
 lv_devices $vg raid6 6
-lvremove -ff $vg
+
+vgremove -ff $vg
diff --git a/test/shell/lvcreate-raid10.sh b/test/shell/lvcreate-raid10.sh
index ba35fdf..68a61f7 100644
--- a/test/shell/lvcreate-raid10.sh
+++ b/test/shell/lvcreate-raid10.sh
@@ -80,3 +80,4 @@ lvremove -ff $vg
 #
 # FIXME: Add tests that specify particular PVs to use for creation
 #
+vgremove -ff $vg
diff --git a/test/shell/lvcreate-thin-snap.sh b/test/shell/lvcreate-thin-snap.sh
index cfc801a..6a6a842 100644
--- a/test/shell/lvcreate-thin-snap.sh
+++ b/test/shell/lvcreate-thin-snap.sh
@@ -27,6 +27,7 @@ check_lv_field_modules_()
 # Main
 #
 aux have_thin 1 0 0 || skip
+which mkfs.ext4 || skip
 
 aux prepare_pvs 2 64
 
@@ -34,8 +35,8 @@ vgcreate $vg -s 64K $(cat DEVICES)
 
 lvcreate -L10M -V10M -T $vg/pool --name $lv1
 mkfs.ext4 "$DM_DEV_DIR/$vg/$lv1"
-# create thin snapshot of thin LV
-lvcreate -K -s $vg/$lv1 --name snap
+# create read-only thin snapshot of thin LV
+lvcreate -K -s $vg/$lv1 -pr --name snap
 # check snapshot filesystem was properly frozen before snapping
 fsck -n "$DM_DEV_DIR/$vg/snap"
 lvcreate -K -s $vg/$lv1 --name $lv2
diff --git a/test/shell/lvcreate-thin.sh b/test/shell/lvcreate-thin.sh
index a2811d2..721f3d1 100644
--- a/test/shell/lvcreate-thin.sh
+++ b/test/shell/lvcreate-thin.sh
@@ -25,11 +25,11 @@ check_lv_field_modules_()
 	done
 }
 
-
 #
 # Main
 #
 aux have_thin 1 0 0 || skip
+which mkfs.ext4 || skip
 
 aux prepare_pvs 2 64
 
diff --git a/test/shell/lvmcache-exercise.sh b/test/shell/lvmcache-exercise.sh
index 6e8efda..09522e3 100644
--- a/test/shell/lvmcache-exercise.sh
+++ b/test/shell/lvmcache-exercise.sh
@@ -34,3 +34,5 @@ lvs
 
 lvs -a $vg2 -o+devices 2>&1 | tee out
 not grep reappeared out
+
+vgremove -ff $vg1 $vg2
diff --git a/test/shell/lvmetad-dump.sh b/test/shell/lvmetad-dump.sh
index e49eb68..462de1c 100644
--- a/test/shell/lvmetad-dump.sh
+++ b/test/shell/lvmetad-dump.sh
@@ -36,3 +36,5 @@ lvmetad_dump() {
 lvmetad_dump ./lvmetad.socket | tee lvmetad.txt
 
 grep $vg1 lvmetad.txt
+
+vgremove -ff $vg1
diff --git a/test/shell/lvmetad-no-cluster.sh b/test/shell/lvmetad-no-cluster.sh
index db68e77..0c53822 100644
--- a/test/shell/lvmetad-no-cluster.sh
+++ b/test/shell/lvmetad-no-cluster.sh
@@ -17,3 +17,5 @@ aux prepare_lvmetad
 vgs -vv 2> errs
 cat errs
 grep 'use_lvmetad' errs
+
+vgremove -ff $vg
diff --git a/test/shell/lvmetad-override.sh b/test/shell/lvmetad-override.sh
index 3fb281a..8f6e641 100644
--- a/test/shell/lvmetad-override.sh
+++ b/test/shell/lvmetad-override.sh
@@ -23,3 +23,4 @@ lvchange -ay $vg1 --config 'global { use_lvmetad = 0 }' 2>&1 | not grep "Failed
 aux lvmconf "global/use_lvmetad = 0"
 lvchange -ay $vg1 --config 'global { use_lvmetad = 1 }' 2>&1 | grep "Failed to connect"
 
+vgremove -ff $vg1
diff --git a/test/shell/lvmetad-pvscan-cache.sh b/test/shell/lvmetad-pvscan-cache.sh
index a27b6ad..7b161aa 100644
--- a/test/shell/lvmetad-pvscan-cache.sh
+++ b/test/shell/lvmetad-pvscan-cache.sh
@@ -21,3 +21,5 @@ vgs | grep $vg1
 pvscan --cache
 
 vgs | grep $vg1
+
+vgremove -ff $vg1
diff --git a/test/shell/lvmetad-pvscan-nomda.sh b/test/shell/lvmetad-pvscan-nomda.sh
index c04a275..195b8d2 100644
--- a/test/shell/lvmetad-pvscan-nomda.sh
+++ b/test/shell/lvmetad-pvscan-nomda.sh
@@ -47,3 +47,5 @@ pvscan --cache $dev1 -aay
 aux lvmconf 'global/use_lvmetad = 0'
 check active $vg1 foo
 aux lvmconf 'global/use_lvmetad = 1'
+
+vgremove -ff $vg1
diff --git a/test/shell/lvmetad-restart.sh b/test/shell/lvmetad-restart.sh
index 10268c2..585d63b 100644
--- a/test/shell/lvmetad-restart.sh
+++ b/test/shell/lvmetad-restart.sh
@@ -21,3 +21,5 @@ kill $(cat LOCAL_LVMETAD)
 aux prepare_lvmetad
 
 vgs | grep $vg1
+
+vgremove -ff $vg1
diff --git a/test/shell/lvmetad-warning.sh b/test/shell/lvmetad-warning.sh
index 3a97a1b..6953165 100644
--- a/test/shell/lvmetad-warning.sh
+++ b/test/shell/lvmetad-warning.sh
@@ -25,3 +25,5 @@ lvchange -ay $vg1 --sysinit 2>&1 | not grep "Failed to connect"
 aux prepare_lvmetad
 lvchange -ay $vg1 2>&1 | not grep "Failed to connect"
 lvchange -ay $vg1 --sysinit 2>&1 | not grep "Failed to connect"
+
+vgremove -ff $vg
diff --git a/test/shell/lvresize-mirror.sh b/test/shell/lvresize-mirror.sh
index 68f0ff8..b4bbb04 100644
--- a/test/shell/lvresize-mirror.sh
+++ b/test/shell/lvresize-mirror.sh
@@ -41,3 +41,5 @@ for deactivate in true false; do
 
 	lvremove -ff $vg
 done
+
+vgremove -ff $vg
diff --git a/test/shell/pvmove-all-segtypes.sh b/test/shell/pvmove-all-segtypes.sh
index 5e1c71c..130a4e9 100644
--- a/test/shell/pvmove-all-segtypes.sh
+++ b/test/shell/pvmove-all-segtypes.sh
@@ -13,7 +13,6 @@ test_description="ensure pvmove works with all common segment types"
 
 . lib/test
 
-which mkfs.ext2 || skip
 which md5sum || skip
 
 aux prepare_pvs 5 20
@@ -96,3 +95,5 @@ check lv_tree_on $vg ${lv1}_foo "$dev5"
 check dev_md5sum $vg snap
 lvremove -ff $vg
 fi
+
+vgremove -ff $vg
diff --git a/test/shell/pvmove-basic.sh b/test/shell/pvmove-basic.sh
index 69244be..911bbf0 100644
--- a/test/shell/pvmove-basic.sh
+++ b/test/shell/pvmove-basic.sh
@@ -14,7 +14,6 @@ test_description="ensure that pvmove works with basic options"
 
 . lib/test
 
-which mkfs.ext2 || skip
 which md5sum || skip
 
 # ---------------------------------------------------------------------
diff --git a/test/shell/pvmove-cache-segtypes.sh b/test/shell/pvmove-cache-segtypes.sh
index 1c2423e..2b62b1f 100644
--- a/test/shell/pvmove-cache-segtypes.sh
+++ b/test/shell/pvmove-cache-segtypes.sh
@@ -20,7 +20,6 @@ test_description="ensure pvmove works with the cache segment types"
 # stacking complications to consider.
 
 test -e LOCAL_CLVMD && skip
-which mkfs.ext2 || skip
 which md5sum || skip
 
 aux target_at_least dm-cache 1 3 0 || skip
diff --git a/test/shell/pvmove-raid-segtypes.sh b/test/shell/pvmove-raid-segtypes.sh
index 4b720bb..1b0f129 100644
--- a/test/shell/pvmove-raid-segtypes.sh
+++ b/test/shell/pvmove-raid-segtypes.sh
@@ -14,7 +14,6 @@ test_description="ensure pvmove works with raid segment types"
 . lib/test
 
 test -e LOCAL_CLVMD && skip
-which mkfs.ext2 || skip
 which md5sum || skip
 
 aux target_at_least dm-raid 1 3 5 || skip
@@ -76,4 +75,5 @@ pvmove -n $lv1 "$dev5" "$dev4"
 check lv_tree_on $vg $lv1 "$dev2" "$dev3" "$dev4"
 check lv_tree_on $vg ${lv1}_foo "$dev5"
 check dev_md5sum $vg $lv1
-lvremove -ff $vg
+
+vgremove -ff $vg
diff --git a/test/shell/pvmove-restart.sh b/test/shell/pvmove-restart.sh
index e1d5381..3f9e151 100644
--- a/test/shell/pvmove-restart.sh
+++ b/test/shell/pvmove-restart.sh
@@ -71,3 +71,5 @@ pvmove --abort
 aux delay_dev "$dev3"
 
 lvs -a -o+devices $vg
+
+vgremove -ff $vg
diff --git a/test/shell/pvmove-thin-segtypes.sh b/test/shell/pvmove-thin-segtypes.sh
index fb29fe3..684b3f5 100644
--- a/test/shell/pvmove-thin-segtypes.sh
+++ b/test/shell/pvmove-thin-segtypes.sh
@@ -13,7 +13,6 @@ test_description="ensure pvmove works with thin segment types"
 
 . lib/test
 test -e LOCAL_CLVMD && skip
-which mkfs.ext2 || skip
 which md5sum || skip
 
 aux target_at_least dm-thin-pool 1 8 0 || skip
@@ -65,3 +64,5 @@ check lv_tree_on $vg $lv1 "$dev2" "$dev4"
 check lv_tree_on $vg ${lv1}_foo "$dev5"
 check dev_md5sum $vg $lv1
 lvremove -ff $vg
+
+vgremove -ff $vg
diff --git a/test/shell/pvremove-usage.sh b/test/shell/pvremove-usage.sh
index aa71215..4f7b35f 100644
--- a/test/shell/pvremove-usage.sh
+++ b/test/shell/pvremove-usage.sh
@@ -66,3 +66,5 @@ for mdacp in 0 1 2; do
     pvcreate --metadatacopies $mdacp "$dev1"
     vgextend $vg "$dev1"
 done
+
+vgremove -ff $vg
diff --git a/test/shell/read-ahead.sh b/test/shell/read-ahead.sh
index 264910c..26335f0 100644
--- a/test/shell/read-ahead.sh
+++ b/test/shell/read-ahead.sh
@@ -46,4 +46,5 @@ lvchange -r 512 $vg/$lv
 lvchange -ay $vg/$lv
 check lv_field $vg/$lv lv_read_ahead 256.00k
 check lv_field $vg/$lv lv_kernel_read_ahead 256.00k
-lvremove -ff $vg
+
+vgremove -ff $vg
diff --git a/test/shell/snapshot-lvm1.sh b/test/shell/snapshot-lvm1.sh
index 4d06f0a..642dd6f 100644
--- a/test/shell/snapshot-lvm1.sh
+++ b/test/shell/snapshot-lvm1.sh
@@ -26,3 +26,5 @@ lvcreate -s $vg/origin -n snap_with_lvm1_meta -l4
 
 # Remove volume snapper/snap_with_lvm1_meta
 lvremove -f $vg/snap_with_lvm1_meta
+
+vgremove -ff $vg
diff --git a/test/shell/tags.sh b/test/shell/tags.sh
index 2bf87a1..ee2f610 100644
--- a/test/shell/tags.sh
+++ b/test/shell/tags.sh
@@ -71,3 +71,5 @@ lvchange --deltag firstlvtag2 $vg1/$lv1
 lvchange --deltag firstlvtag2 $vg1/$lv1
 check lv_field $vg1/$lv1 tags "firstlvtag1,firstlvtag3"
 check lv_field $vg1/$lv2 tags "secondlvtag1,secondlvtag2,secondlvtag3"
+
+vgremove -ff $vg1
diff --git a/test/shell/unknown-segment.sh b/test/shell/unknown-segment.sh
index c3bba0a..8ec48d2 100644
--- a/test/shell/unknown-segment.sh
+++ b/test/shell/unknown-segment.sh
@@ -32,3 +32,5 @@ vgcfgbackup -f bak2 $vg
 egrep -v 'description|seqno|creation_time|Generated' < bak0.orig > a
 egrep -v 'description|seqno|creation_time|Generated' < bak2 > b
 diff -u a b
+
+vgremove -ff $vg
diff --git a/test/shell/unlost-pv.sh b/test/shell/unlost-pv.sh
index 3e74e0e..307a71b 100644
--- a/test/shell/unlost-pv.sh
+++ b/test/shell/unlost-pv.sh
@@ -42,3 +42,5 @@ aux enable_dev "$dev1"
 check_
 test -e LOCAL_LVMETAD && lvremove $vg/boo # FIXME trigger a write :-(
 check_ not
+
+vgremove -ff $vg
diff --git a/test/shell/vg-name-from-env.sh b/test/shell/vg-name-from-env.sh
index c8e8c76..dedbfd6 100644
--- a/test/shell/vg-name-from-env.sh
+++ b/test/shell/vg-name-from-env.sh
@@ -102,3 +102,4 @@ not grep $lv3 err
 grep $lv2 err
 not grep $lv4 err
 
+vgremove -ff $vg1 $vg2
diff --git a/test/shell/vgchange-many.sh b/test/shell/vgchange-many.sh
index 491c8b1..ba3d2b8 100644
--- a/test/shell/vgchange-many.sh
+++ b/test/shell/vgchange-many.sh
@@ -50,3 +50,5 @@ vgcfgrestore -f data_new $vg
 # Activate and deactivate all of them
 vgchange -ay $vg
 vgchange -an $vg
+
+vgremove -ff $vg
diff --git a/test/shell/vgchange-maxlv.sh b/test/shell/vgchange-maxlv.sh
index 9da08ed..99a6a79 100644
--- a/test/shell/vgchange-maxlv.sh
+++ b/test/shell/vgchange-maxlv.sh
@@ -28,3 +28,5 @@ not lvcreate -n three -l 1 $vg
 vgchange --monitor y $vg
 vgchange -an $vg 2>&1 | tee vgchange.out
 not grep "event server" vgchange.out
+
+vgremove -ff $vg
diff --git a/test/shell/vgchange-partial.sh b/test/shell/vgchange-partial.sh
index 5b21a40..ad99460 100644
--- a/test/shell/vgchange-partial.sh
+++ b/test/shell/vgchange-partial.sh
@@ -50,3 +50,5 @@ not vgchange --vgmetadatacopies 2 $vg
 # Ensure that allowed args don't cause disallowed args to get through
 #
 not vgchange -p 10 --addtag foo $vg
+
+vgremove -ff $vg
diff --git a/test/shell/vgchange-sysinit.sh b/test/shell/vgchange-sysinit.sh
index 67f07df..49c3bde 100644
--- a/test/shell/vgchange-sysinit.sh
+++ b/test/shell/vgchange-sysinit.sh
@@ -50,3 +50,8 @@ vgchange --sysinit -an $vg2
 test ! -b "$DM_DEV_DIR/$vg2/$lv2"
 
 vgchange --ignorelockingfailure -ay $vg2
+
+# TODO maybe also support --ignorelockingfailure ??
+vgremove --config 'global{locking_type=0}' -ff $vg2
+umount "$mount_dir" || true
+vgremove -ff $vg1
diff --git a/test/shell/vgchange-usage.sh b/test/shell/vgchange-usage.sh
index a7bd488..0ae9c14 100644
--- a/test/shell/vgchange-usage.sh
+++ b/test/shell/vgchange-usage.sh
@@ -42,3 +42,4 @@ not vgchange -l 1 $vg 2>err
 grep "MaxLogicalVolume is less than the current number $lv_count of LVs for"  err
 aux check vg_field $vg max_lv 128
 
+vgremove -ff $vg
diff --git a/test/shell/vgck.sh b/test/shell/vgck.sh
index 772233c..0dec605 100644
--- a/test/shell/vgck.sh
+++ b/test/shell/vgck.sh
@@ -29,3 +29,5 @@ fi
 dd if=/dev/urandom bs=512 seek=2 count=32 of=$dev2
 vgck $vg 2>&1 | tee vgck.out
 grep Incorrect vgck.out
+
+vgremove -ff $vg
diff --git a/test/shell/vgextend-restoremissing.sh b/test/shell/vgextend-restoremissing.sh
index 29273ed..143bff7 100644
--- a/test/shell/vgextend-restoremissing.sh
+++ b/test/shell/vgextend-restoremissing.sh
@@ -27,3 +27,5 @@ not lvcreate -aey --type mirror -m 1 -l 1 -n mirror $vg # write operations fail
 vgextend --restore $vg "$dev1" # restore the missing device
 vgck $vg
 lvcreate -an -Zn --type mirror -m 1 -l 1 -n mirror $vg
+
+vgremove -ff $vg
diff --git a/test/shell/vgimportclone.sh b/test/shell/vgimportclone.sh
index 0c81585..cf85518 100644
--- a/test/shell/vgimportclone.sh
+++ b/test/shell/vgimportclone.sh
@@ -43,3 +43,5 @@ aux notify_lvmetad "$dev1"
 # Verify we can activate / deactivate the LV from both VGs
 lvchange -ay $vg1/$lv1 $vg2/$lv1
 vgchange -an $vg1 $vg2
+
+vgremove -ff $vg1 $vg2
diff --git a/test/shell/vgreduce-removemissing-snapshot.sh b/test/shell/vgreduce-removemissing-snapshot.sh
index 3f24c7f..c587b17 100644
--- a/test/shell/vgreduce-removemissing-snapshot.sh
+++ b/test/shell/vgreduce-removemissing-snapshot.sh
@@ -33,3 +33,5 @@ vgreduce -v --removemissing --force $vg # "$dev2" "$dev4"
 lvs -a -o +devices $vg | not grep unknown
 lvs -a -o +devices $vg
 check mirror $vg 4way "$dev5"
+
+vgremove -ff $vg
diff --git a/test/shell/vgreduce-usage.sh b/test/shell/vgreduce-usage.sh
index 29475b2..fab7496 100644
--- a/test/shell/vgreduce-usage.sh
+++ b/test/shell/vgreduce-usage.sh
@@ -87,3 +87,5 @@ aux enable_dev "$dev1"
 pvs -P $(cat DEVICES) # for record
 lvs -P $vg1           # for record
 vgs -P $vg1           # for record
+
+vgremove -ff $vg1
diff --git a/test/shell/vgsplit-stacked.sh b/test/shell/vgsplit-stacked.sh
index c8b89b5..4373b20 100644
--- a/test/shell/vgsplit-stacked.sh
+++ b/test/shell/vgsplit-stacked.sh
@@ -25,3 +25,5 @@ vgchange -a n $vg $vg1
 
 # this should fail but not segfault, RHBZ 481793.
 not vgsplit $vg $vg1 "$dev3"
+
+vgremove -ff $vg $vg1


