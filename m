From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 28 Nov 2017 03:22:02 -0500
Subject: master - tests: Fix aux delay_dev calls
Message-ID: <201711280822.vAS8M2tA013343@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=591ac0828af73ac9a134660a643ef234ff57c02e
Commit:        591ac0828af73ac9a134660a643ef234ff57c02e
Parent:        a9812ec9d3469edbe24a2d08ccb1dda209cf66a5
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue Nov 28 08:51:12 2017 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Nov 28 08:51:12 2017 +0100

tests: Fix aux delay_dev calls

All these cases were supposed to create delay device till the end of
underlying device.
---
 test/shell/lvchange-raid1-writemostly.sh |    2 +-
 test/shell/lvchange-rebuild-raid.sh      |    2 +-
 test/shell/lvconvert-repair-raid.sh      |    2 +-
 test/shell/lvcreate-large-raid.sh        |    2 +-
 test/shell/lvcreate-raid-nosync.sh       |    2 +-
 5 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/test/shell/lvchange-raid1-writemostly.sh b/test/shell/lvchange-raid1-writemostly.sh
index 6e508c4..32829f9 100644
--- a/test/shell/lvchange-raid1-writemostly.sh
+++ b/test/shell/lvchange-raid1-writemostly.sh
@@ -23,7 +23,7 @@ get_devs
 
 for d in "$dev1" "$dev2" "$dev3" "$dev4"
 do
-	aux delay_dev "$d" 0 20 "$(get first_extent_sector "$d")"
+	aux delay_dev "$d" 0 20 "$(get first_extent_sector "$d"):"
 done
 
 #
diff --git a/test/shell/lvchange-rebuild-raid.sh b/test/shell/lvchange-rebuild-raid.sh
index 5579106..4b67f7a 100644
--- a/test/shell/lvchange-rebuild-raid.sh
+++ b/test/shell/lvchange-rebuild-raid.sh
@@ -35,7 +35,7 @@ _sync() {
 # Delay legs so that rebuilding status characters can be read
 for d in "${DEVICES[@]}"
 do
-	aux delay_dev "$d" 0 50 "$(get first_extent_sector "$d")"
+	aux delay_dev "$d" 0 50 "$(get first_extent_sector "$d"):"
 done
 
 # rhbz 1064592
diff --git a/test/shell/lvconvert-repair-raid.sh b/test/shell/lvconvert-repair-raid.sh
index c866455..e76a113 100644
--- a/test/shell/lvconvert-repair-raid.sh
+++ b/test/shell/lvconvert-repair-raid.sh
@@ -28,7 +28,7 @@ get_devs
 function delay
 {
 	for d in "${DEVICES[@]}"; do
-		aux delay_dev "$d" 0 $1 "$(get first_extent_sector "$d")"
+		aux delay_dev "$d" 0 $1 "$(get first_extent_sector "$d"):"
 	done
 }
 
diff --git a/test/shell/lvcreate-large-raid.sh b/test/shell/lvcreate-large-raid.sh
index 3488db4..8b2b395 100644
--- a/test/shell/lvcreate-large-raid.sh
+++ b/test/shell/lvcreate-large-raid.sh
@@ -38,7 +38,7 @@ aux lvmconf 'devices/issue_discards = 1'
 # Delay PVs so that resynchronization doesn't fill too much space
 for device in "${DEVICES[@]}"
 do
-	aux delay_dev "$device" 0 10  "$(get first_extent_sector "$device")"
+	aux delay_dev "$device" 0 10  "$(get first_extent_sector "$device"):"
 done
 
 # bz837927 START
diff --git a/test/shell/lvcreate-raid-nosync.sh b/test/shell/lvcreate-raid-nosync.sh
index c0e23bb..ce61cf7 100644
--- a/test/shell/lvcreate-raid-nosync.sh
+++ b/test/shell/lvcreate-raid-nosync.sh
@@ -36,7 +36,7 @@ _sync() {
 
 # Delay 1st leg so that rebuilding status characters
 #  can be read before resync finished too quick.
-aux delay_dev "$dev1" 0 100 "$(get first_extent_sector "$dev1")"
+aux delay_dev "$dev1" 0 100 "$(get first_extent_sector "$dev1"):"
 
 # raid0/raid0_meta don't support resynchronization
 for r in raid0 raid0_meta


