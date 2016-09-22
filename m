From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Thu, 22 Sep 2016 21:35:53 +0000 (UTC)
Subject: master - tests: fix raid rebuild tests to work with older target versions
Message-ID: <20160922213553.2D32260D1E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f2efd04052c9cdd86d636e77e645db778935fdc8
Commit:        f2efd04052c9cdd86d636e77e645db778935fdc8
Parent:        38a6a39daa2967970da0017ac96e40af1c7fbc7b
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Sep 22 23:35:37 2016 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Sep 22 23:35:37 2016 +0200

tests: fix raid rebuild tests to work with older target versions

Pre 1.9 dm-raid targets status output was racy, which caused
the device status chars to be unreliable _during_ synchronization.
This shows paritcularly with tiny test devices used.

Enhance lvchange-rebuild-raid.sh to not check status
chars _during_ synchronization. Just check afterwards.
---
 WHATS_NEW                           |    1 +
 test/shell/lvchange-rebuild-raid.sh |   42 ++++++++++++++++++++++++----------
 2 files changed, 30 insertions(+), 13 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index aedacee..6a178e6 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.166 - 
 =====================================
+  Fix lvchange-rebuild-raid.sh to cope with older target versions.
   Use dm_config_parse_without_dup_node_check() to speedup metadata reading.
   Fix lvconvert --repair regression
   Fix reported origin lv field for cache volumes. (2.02.133)
diff --git a/test/shell/lvchange-rebuild-raid.sh b/test/shell/lvchange-rebuild-raid.sh
index f15c5ef..6b91941 100644
--- a/test/shell/lvchange-rebuild-raid.sh
+++ b/test/shell/lvchange-rebuild-raid.sh
@@ -18,7 +18,7 @@ aux have_raid 1 3 2 || skip
 
 aux prepare_vg 8
 
-# Delay 1st leg so that rebuilding status characters can be read
+# Delay legs so that rebuilding status characters can be read
 for d in $(< DEVICES)
 do
 	aux delay_dev "$d" 0 15 $(get first_extent_sector "$d")
@@ -37,92 +37,108 @@ aux wait_for_sync $vg $lv1
 not lvchange --yes --rebuild "$dev1" --rebuild "$dev2" $vg/$lv1
 not check raid_leg_status $vg $lv1 "aAaAAAAA"
 aux wait_for_sync $vg $lv1
+check raid_leg_status $vg $lv1 "AAAAAAAA"
 
-# Rebuild 1st and 3nd device from different mirror groups is fine.
+# Rebuild 1st and 3rd device from different mirror groups is fine.
 lvchange --yes --rebuild "$dev1" --rebuild "$dev3" $vg/$lv1
-check raid_leg_status $vg $lv1 "aAaAAAAA"
+aux have_raid 1 9 && check raid_leg_status $vg $lv1 "aAaAAAAA"
 aux wait_for_sync $vg $lv1
+check raid_leg_status $vg $lv1 "AAAAAAAA"
 
 # Rebuild devices 1, 3, 6 from different mirror groups is fine.
 lvchange --yes --rebuild "$dev1" --rebuild "$dev3" --rebuild "$dev6" $vg/$lv1
-check raid_leg_status $vg $lv1 "aAaAAaAA"
+aux have_raid 1 9 && check raid_leg_status $vg $lv1 "aAaAAaAA"
 aux wait_for_sync $vg $lv1
+check raid_leg_status $vg $lv1 "AAAAAAAA"
 
 # Rebuild devices 1, 3, 5 and 6 with 5+6 being
 # being a whole mirror group needs to be rejected.
 not lvchange --yes --rebuild "$dev1" --rebuild "$dev3" --rebuild "$dev6" --rebuild "$dev5" $vg/$lv1
 not check raid_leg_status $vg $lv1 "aAaAaaAA"
 aux wait_for_sync $vg $lv1
+check raid_leg_status $vg $lv1 "AAAAAAAA"
 
 # Rebuild devices 1, 3, 5 and 7 from different mirror groups is fine.
 lvchange --yes --rebuild "$dev1" --rebuild "$dev3" --rebuild "$dev5" --rebuild "$dev7" $vg/$lv1
-check raid_leg_status $vg $lv1 "aAaAaAaA"
+aux have_raid 1 9 && check raid_leg_status $vg $lv1 "aAaAaAaA"
 aux wait_for_sync $vg $lv1
 
 # Rebuild devices 2, 4, 6 and 8 from different mirror groups is fine.
 lvchange --yes --rebuild "$dev2" --rebuild "$dev4" --rebuild "$dev6" --rebuild "$dev8" $vg/$lv1
-check raid_leg_status $vg $lv1 "AaAaAaAa"
+aux have_raid 1 9 && check raid_leg_status $vg $lv1 "AaAaAaAa"
 aux wait_for_sync $vg $lv1
+check raid_leg_status $vg $lv1 "AAAAAAAA"
 
 ##############################################
 # Create an 8-legged raid1 and rebuild selected PVs
 lvremove --yes $vg/$lv1
 lvcreate --yes --type raid1 -m 7 -l 2 -n $lv1 $vg
 aux wait_for_sync $vg $lv1
+check raid_leg_status $vg $lv1 "AAAAAAAA"
 
 # Rebuilding all raid1 legs needs to be rejected.
 not lvchange --yes --rebuild "$dev1" --rebuild "$dev2" --rebuild "$dev3" --rebuild "$dev4" \
 		   --rebuild "$dev5" --rebuild "$dev6" --rebuild "$dev7" --rebuild "$dev8" $vg/$lv1
 not check raid_leg_status $vg $lv1 "aaaaaaaa"
 aux wait_for_sync $vg $lv1
+check raid_leg_status $vg $lv1 "AAAAAAAA"
 
 # Rebuilding all but the raid1 master leg is fine.
 lvchange --yes --rebuild "$dev2" --rebuild "$dev3" --rebuild "$dev4" \
 	       --rebuild "$dev5" --rebuild "$dev6" --rebuild "$dev7" --rebuild "$dev8" $vg/$lv1
-check raid_leg_status $vg $lv1 "Aaaaaaaa"
+aux have_raid 1 9 && check raid_leg_status $vg $lv1 "Aaaaaaaa"
 aux wait_for_sync $vg $lv1
+check raid_leg_status $vg $lv1 "AAAAAAAA"
 
 # Rebuilding the raid1 master leg is fine.
 lvchange --yes --rebuild "$dev1" $vg/$lv1
-check raid_leg_status $vg $lv1 "aAAAAAAA"
+aux have_raid 1 9 && check raid_leg_status $vg $lv1 "aAAAAAAA"
 aux wait_for_sync $vg $lv1
+check raid_leg_status $vg $lv1 "AAAAAAAA"
 
 # Rebuild legs on devices 2, 4, 6 and 8 is fine.
 lvchange --yes --rebuild "$dev2" --rebuild "$dev4" --rebuild "$dev6" --rebuild "$dev8" $vg/$lv1
-check raid_leg_status $vg $lv1 "AaAaAaAa"
+aux have_raid 1 9 && check raid_leg_status $vg $lv1 "AaAaAaAa"
 aux wait_for_sync $vg $lv1
+check raid_leg_status $vg $lv1 "AAAAAAAA"
 
 ##############################################
 # Create an 6-legged raid6 and rebuild selected PVs
 lvremove --yes $vg/$lv1
 lvcreate --yes --type raid6 -i 4 -l 2 -n $lv1 $vg
 aux wait_for_sync $vg $lv1
+check raid_leg_status $vg $lv1 "AAAAAA"
 
 # Rebuilding all raid6 stripes needs to be rejected.
 not lvchange --yes --rebuild "$dev1" --rebuild "$dev2" --rebuild "$dev3" \
 		   --rebuild "$dev4" --rebuild "$dev5" --rebuild "$dev6"  $vg/$lv1
 not check raid_leg_status $vg $lv1 "aaaaaa"
 aux wait_for_sync $vg $lv1
+check raid_leg_status $vg $lv1 "AAAAAA"
 
 # Rebuilding more than 2 raid6 stripes needs to be rejected.
 not lvchange --yes --rebuild "$dev2" --rebuild "$dev4" --rebuild "$dev6" $vg/$lv1
 not check raid_leg_status $vg $lv1 "AaAaAa"
 aux wait_for_sync $vg $lv1
+check raid_leg_status $vg $lv1 "AAAAAA"
 
 # Rebuilding any 1 raid6 stripe is fine.
 lvchange --yes --rebuild "$dev2" $vg/$lv1
-check raid_leg_status $vg $lv1 "AaAAAA"
+aux have_raid 1 9 && check raid_leg_status $vg $lv1 "AaAAAA"
 aux wait_for_sync $vg $lv1
 lvchange --yes --rebuild "$dev5"  $vg/$lv1
-check raid_leg_status $vg $lv1 "AAAAaA"
+aux have_raid 1 9 && check raid_leg_status $vg $lv1 "AAAAaA"
 aux wait_for_sync $vg $lv1
+check raid_leg_status $vg $lv1 "AAAAAA"
 
 # Rebuilding any 2 raid6 stripes is fine.
 lvchange --yes --rebuild "$dev2" --rebuild "$dev4" $vg/$lv1
-check raid_leg_status $vg $lv1 "AaAaAA"
+aux have_raid 1 9 && check raid_leg_status $vg $lv1 "AaAaAA"
 aux wait_for_sync $vg $lv1
+check raid_leg_status $vg $lv1 "AAAAAA"
 lvchange --yes --rebuild "$dev1" --rebuild "$dev5" $vg/$lv1
-check raid_leg_status $vg $lv1 "aAAAaA"
+aux have_raid 1 9 && check raid_leg_status $vg $lv1 "aAAAaA"
 aux wait_for_sync $vg $lv1
+check raid_leg_status $vg $lv1 "AAAAAA"
 
 vgremove -ff $vg


