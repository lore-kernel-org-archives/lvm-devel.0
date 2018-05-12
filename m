From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 12 May 2018 12:26:02 -0400
Subject: master - tests: using throttling
Message-ID: <201805121626.w4CGQ2fE007877@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=86c8f0f01f07a1516f5a3f20e2a3c282b52c25dc
Commit:        86c8f0f01f07a1516f5a3f20e2a3c282b52c25dc
Parent:        7362ed68be4a292fd51ad32fd8960c1c8ef765d9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon May 7 13:09:46 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat May 12 17:48:31 2018 +0200

tests: using throttling

---
 test/shell/pvmove-abort-all.sh |   18 ++++++++----------
 test/shell/pvmove-abort.sh     |   18 ++++++++----------
 2 files changed, 16 insertions(+), 20 deletions(-)

diff --git a/test/shell/pvmove-abort-all.sh b/test/shell/pvmove-abort-all.sh
index 7cb549f..5a86a37 100644
--- a/test/shell/pvmove-abort-all.sh
+++ b/test/shell/pvmove-abort-all.sh
@@ -20,18 +20,19 @@ export DM_ABORT_ON_INTERNAL_ERRORS=0
 
 . lib/inittest
 
+aux lvmconf 'activation/raid_region_size = 16'
+
 aux prepare_pvs 6 60
 
-vgcreate -s 128k $vg "$dev1" "$dev2"
+vgcreate -s 512k $vg "$dev1" "$dev2"
 pvcreate --metadatacopies 0 "$dev3"
 vgextend $vg "$dev3"
-vgcreate -s 128k $vg1 "$dev4" "$dev5"
+vgcreate -s 512k $vg1 "$dev4" "$dev5"
 pvcreate --metadatacopies 0 "$dev6"
 vgextend $vg1 "$dev6"
 
-# Slowdown writes
-aux delay_dev "$dev3" 0 800 "$(get first_extent_sector "$dev3"):"
-aux delay_dev "$dev6" 0 800 "$(get first_extent_sector "$dev6"):"
+# Throttle mirroring
+aux throttle_dm_mirror
 
 for mode in "--atomic" "" ;
 do
@@ -48,7 +49,6 @@ cmd1=(pvmove -i1 $backgroundarg $mode "$dev1" "$dev3")
 cmd2=(pvmove -i1 $backgroundarg $mode "$dev2" "$dev3")
 cmd3=(pvmove -i1 $backgroundarg $mode -n $vg1/$lv1 "$dev4" "$dev6")
 
-if test -e HAVE_DM_DELAY; then
 
 if test -z "$backgroundarg" ; then
 	"${cmd1[@]}" &
@@ -64,8 +64,6 @@ else
 	LVM_TEST_TAG="kill_me_$PREFIX" "${cmd3[@]}"
 fi
 
-fi
-
 # test removal of all pvmove LVs
 pvmove --abort
 
@@ -82,7 +80,7 @@ aux kill_tagged_processes
 done
 done
 
-# Restore delayed device back
-aux enable_dev "$dev3" "$dev6"
+# Restore throttling
+aux restore_dm_mirror
 
 vgremove -ff $vg $vg1
diff --git a/test/shell/pvmove-abort.sh b/test/shell/pvmove-abort.sh
index 0b8960b..5ca993b 100644
--- a/test/shell/pvmove-abort.sh
+++ b/test/shell/pvmove-abort.sh
@@ -16,14 +16,16 @@ SKIP_WITH_LVMLOCKD=1
 
 . lib/inittest
 
+aux lvmconf 'activation/raid_region_size = 16'
+
 aux prepare_pvs 3 60
 
-vgcreate -s 128k $vg "$dev1" "$dev2"
+vgcreate -s 512k $vg "$dev1" "$dev2"
 pvcreate --metadatacopies 0 "$dev3"
 vgextend $vg "$dev3"
 
-# Slowdown read/writes
-aux delay_dev "$dev3" 0 800 "$(get first_extent_sector "$dev3"):"
+# Throttle mirroring
+aux throttle_dm_mirror
 
 for mode in "--atomic" "" ;
 do
@@ -32,13 +34,11 @@ do
 
 # Create multisegment LV
 lvcreate -an -Zn -l30 -n $lv1 $vg "$dev1"
-lvcreate -an -Zn -l30 -n $lv2 $vg "$dev2"
+lvcreate -an -Zn -l40 -n $lv2 $vg "$dev2"
 
 cmd1=(pvmove -i1 $backgroundarg $mode "$dev1" "$dev3")
 cmd2=(pvmove -i1 $backgroundarg $mode "$dev2" "$dev3")
 
-if test -e HAVE_DM_DELAY; then
-
 if test -z "$backgroundarg" ; then
 	"${cmd1[@]}" &
 	aux wait_pvmove_lv_ready "$vg-pvmove0"
@@ -57,8 +57,6 @@ get lv_field $vg name -a | tee out
 not grep -E "^\[?pvmove0" out
 grep -E "^\[?pvmove1" out
 
-fi
-
 # remove any remaining pvmoves in progress
 pvmove --abort
 
@@ -69,7 +67,7 @@ aux kill_tagged_processes
 done
 done
 
-# Restore delayed device back
-aux enable_dev "$dev3"
+# Restore throttling
+aux restore_dm_mirror
 
 vgremove -ff $vg


