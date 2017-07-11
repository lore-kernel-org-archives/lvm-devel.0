From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 11 Jul 2017 11:22:22 -0400
Subject: master - tests: avoid unbound shell var usage
Message-ID: <201707111522.v6BFMMsF015523@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=429e613ba86386829d2bd3556d29158aff93a04f
Commit:        429e613ba86386829d2bd3556d29158aff93a04f
Parent:        f11e74ae3d1f5bd5221110fa08d502cc39365955
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jul 11 11:18:22 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jul 11 16:26:12 2017 +0200

tests: avoid unbound shell var usage

---
 test/shell/lvchange-rebuild-raid.sh        |    2 +-
 test/shell/profiles-thin.sh                |    1 +
 test/shell/snapshot-autoumount-dmeventd.sh |    2 +-
 test/shell/snapshots-of-mirrors.sh         |    1 +
 test/shell/topology-support.sh             |    1 +
 test/shell/unlost-pv.sh                    |    3 ++-
 6 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/test/shell/lvchange-rebuild-raid.sh b/test/shell/lvchange-rebuild-raid.sh
index 892d58d..4f535e6 100644
--- a/test/shell/lvchange-rebuild-raid.sh
+++ b/test/shell/lvchange-rebuild-raid.sh
@@ -24,7 +24,7 @@ _sync() {
 	aux enable_dev "${DEVICES[@]}"
 
 	aux wait_for_sync $vg $lv1
-	test -z "$1" || check raid_leg_status $vg $lv1 $1
+	test "$#" -eq 0 || check raid_leg_status $vg $lv1 "$@"
 
 	# restore to delay_dev tables for all devices
 	aux restore_from_devtable "${DEVICES[@]}"
diff --git a/test/shell/profiles-thin.sh b/test/shell/profiles-thin.sh
index 9c9fadf..df6fd73 100644
--- a/test/shell/profiles-thin.sh
+++ b/test/shell/profiles-thin.sh
@@ -35,6 +35,7 @@ aux prepare_pvs 1 "$DEV_SIZE"
 
 # Check we are not running on buggy kernel (broken lcm())
 # If so, turn chunk_size test into  'should'
+SHOULD=""
 check sysfs "$dev1" queue/optimal_io_size "$EXPECT" || SHOULD=should
 
 vgcreate $vg "$dev1"
diff --git a/test/shell/snapshot-autoumount-dmeventd.sh b/test/shell/snapshot-autoumount-dmeventd.sh
index 8e2781e..e2702bb 100644
--- a/test/shell/snapshot-autoumount-dmeventd.sh
+++ b/test/shell/snapshot-autoumount-dmeventd.sh
@@ -41,7 +41,7 @@ test "$(dmsetup info -c --noheadings -o open $vg-snap)" -eq 1
 grep "$mntdir" /proc/mounts
 
 # overfill 4M snapshot (with metadata)
-not dd if=/dev/zero of="$mntdir/file$1" bs=1M count=4 conv=fdatasync
+not dd if=/dev/zero of="$mntdir/file" bs=1M count=4 conv=fdatasync
 
 # Should be nearly instant check of dmeventd for invalid snapshot.
 # Wait here for umount and open_count drops to 0 as it may
diff --git a/test/shell/snapshots-of-mirrors.sh b/test/shell/snapshots-of-mirrors.sh
index a23cc58..7e3f736 100644
--- a/test/shell/snapshots-of-mirrors.sh
+++ b/test/shell/snapshots-of-mirrors.sh
@@ -38,6 +38,7 @@ lvconvert --mirrorlog core $vg/lv
 
 # Log conversion (core -> mirrored)
 # FIXME on cluster
+SHOULD=""
 test -e LOCAL_CLVMD && SHOULD=should
 $SHOULD lvconvert --mirrorlog mirrored $vg/lv
 
diff --git a/test/shell/topology-support.sh b/test/shell/topology-support.sh
index ffa3fe6..98a6d9f 100644
--- a/test/shell/topology-support.sh
+++ b/test/shell/topology-support.sh
@@ -116,6 +116,7 @@ aux prepare_pvs 1 $PER_DEV_SIZE
 
 # Kernel (3.19) could provide wrong results - in this case skip
 # test with incorrect result - lvm2 can't figure out good values.
+SHOULD=""
 check sysfs "$dev1" queue/optimal_io_size 786432 || SHOULD=should
 $SHOULD check pv_field "${DEVICES[@]}" pe_start 768.00k
 
diff --git a/test/shell/unlost-pv.sh b/test/shell/unlost-pv.sh
index 982e340..ffc22b8 100644
--- a/test/shell/unlost-pv.sh
+++ b/test/shell/unlost-pv.sh
@@ -16,10 +16,11 @@ SKIP_WITH_LVMPOLLD=1
 . lib/inittest
 
 check_() {
+	local cache=""
 	# vgscan needs --cache option for direct scan if lvmetad is used
 	test -e LOCAL_LVMETAD && cache="--cache"
 	vgscan $cache 2>&1 | tee vgscan.out
-	$1 grep "Inconsistent metadata found for VG $vg" vgscan.out
+	"$@" grep "Inconsistent metadata found for VG $vg" vgscan.out
 }
 
 aux prepare_vg 3


