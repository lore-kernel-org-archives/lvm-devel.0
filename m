From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  3 Apr 2015 18:15:44 +0000 (UTC)
Subject: master - tests: slow down devices in outer loop
Message-ID: <20150403181544.DED686103B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=32a0f625a555140adc95a6dc394e6723e5897ea3
Commit:        32a0f625a555140adc95a6dc394e6723e5897ea3
Parent:        4f94669eca3c2a90577a972fd748f4b0c4e89928
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 3 19:38:28 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 3 19:40:42 2015 +0200

tests: slow down devices in outer loop

Since now we have metadata parts running with normal speed,
we could avoid reinitilising delayed dev for every test.
(Saving seconds on cookie waits...)
---
 test/shell/pvmove-abort-all.sh |   16 ++++++++--------
 test/shell/pvmove-abort.sh     |   12 ++++++------
 test/shell/pvmove-restart.sh   |   14 +++++++-------
 3 files changed, 21 insertions(+), 21 deletions(-)

diff --git a/test/shell/pvmove-abort-all.sh b/test/shell/pvmove-abort-all.sh
index cf0985d..dddf210 100644
--- a/test/shell/pvmove-abort-all.sh
+++ b/test/shell/pvmove-abort-all.sh
@@ -22,6 +22,10 @@ vgcreate -s 128k $vg1 "$dev4" "$dev5"
 pvcreate --metadatacopies 0 "$dev6"
 vgextend $vg1 "$dev6"
 
+# Slowdown writes
+aux delay_dev "$dev3" 100 100 $(get first_extent_sector "$dev3"):
+aux delay_dev "$dev6" 100 100 $(get first_extent_sector "$dev6"):
+
 for mode in "--atomic" "" ;
 do
 for backgroundarg in "-b" "" ;
@@ -33,10 +37,6 @@ lvcreate -an -Zn -l30 -n $lv2 $vg "$dev2"
 lvcreate -an -Zn -l30 -n $lv1 $vg1 "$dev4"
 lvextend -l+30 -n $vg1/$lv1 "$dev5"
 
-# Slowdown writes
-aux delay_dev "$dev3" 100 100 $(get first_extent_sector "$dev3"):
-aux delay_dev "$dev6" 100 100 $(get first_extent_sector "$dev6"):
-
 pvmove -i1 $backgroundarg "$dev1" "$dev3" $mode &
 aux wait_pvmove_lv_ready "$vg-pvmove0" 300
 pvmove -i1 $backgroundarg "$dev2" "$dev3" $mode &
@@ -54,14 +54,14 @@ not grep "^\[pvmove" out
 get lv_field $vg1 name -a | tee out
 not grep "^\[pvmove" out
 
-# Restore delayed device back
-aux enable_dev "$dev3"
-aux enable_dev "$dev6"
-
 lvremove -ff $vg $vg1
 
 wait
 done
 done
 
+# Restore delayed device back
+aux enable_dev "$dev3"
+aux enable_dev "$dev6"
+
 vgremove -ff $vg $vg1
diff --git a/test/shell/pvmove-abort.sh b/test/shell/pvmove-abort.sh
index 4ad3e62..0efecea 100644
--- a/test/shell/pvmove-abort.sh
+++ b/test/shell/pvmove-abort.sh
@@ -19,6 +19,9 @@ vgcreate -s 128k $vg "$dev1" "$dev2"
 pvcreate --metadatacopies 0 "$dev3"
 vgextend $vg "$dev3"
 
+# Slowdown read/writes
+aux delay_dev "$dev3" 100 100 $(get first_extent_sector "$dev3"):
+
 for mode in "--atomic" "" ;
 do
 for backgroundarg in "-b" "" ;
@@ -28,9 +31,6 @@ do
 lvcreate -an -Zn -l30 -n $lv1 $vg "$dev1"
 lvcreate -an -Zn -l30 -n $lv2 $vg "$dev2"
 
-# Slowdown writes
-aux delay_dev "$dev3" 0 200
-
 pvmove -i1 $backgroundarg "$dev1" "$dev3" $mode &
 aux wait_pvmove_lv_ready "$vg-pvmove0" 300
 pvmove -i1 $backgroundarg "$dev2" "$dev3" $mode &
@@ -47,9 +47,6 @@ get lv_field $vg name -a | tee out
 not grep "^\[pvmove0\]" out
 grep "^\[pvmove1\]" out
 
-# Restore delayed device back
-aux enable_dev "$dev3"
-
 # remove any remaining pvmoves in progress
 pvmove --abort
 
@@ -59,4 +56,7 @@ wait
 done
 done
 
+# Restore delayed device back
+aux enable_dev "$dev3"
+
 vgremove -ff $vg
diff --git a/test/shell/pvmove-restart.sh b/test/shell/pvmove-restart.sh
index 9426d52..92e46bf 100644
--- a/test/shell/pvmove-restart.sh
+++ b/test/shell/pvmove-restart.sh
@@ -19,6 +19,10 @@ vgcreate -s 128k $vg "$dev1" "$dev2"
 pvcreate --metadatacopies 0 "$dev3"
 vgextend $vg "$dev3"
 
+# Slowdown writes
+# (FIXME: generates interesting race when not used)
+aux delay_dev "$dev3" 100 100 $(get first_extent_sector "$dev3"):
+
 for mode in "--atomic" ""
 do
 
@@ -28,10 +32,6 @@ lvextend -l+10 $vg/$lv1 "$dev2"
 lvextend -l+5 $vg/$lv1 "$dev1"
 lvextend -l+10 $vg/$lv1 "$dev2"
 
-# Slowdown writes
-# (FIXME: generates interesting race when not used)
-aux delay_dev "$dev3" 100 100 $(get first_extent_sector "$dev3"):
-
 pvmove -i0 -n $vg/$lv1 "$dev1" "$dev3" $mode &
 PVMOVE=$!
 # Let's wait a bit till pvmove starts and kill it
@@ -87,12 +87,12 @@ pvmove --abort
 
 pvmove --abort
 
-# Restore delayed device back
-aux delay_dev "$dev3"
-
 lvs -a -o+devices $vg
 
 lvremove -ff $vg
 done
 
+# Restore delayed device back
+aux delay_dev "$dev3"
+
 vgremove -ff $vg


