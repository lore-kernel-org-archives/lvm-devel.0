From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Tue, 14 Nov 2017 08:15:42 -0500
Subject: master - test: avoid have_raid overhead
Message-ID: <201711141315.vAEDFgUe030420@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=80f5fb7ebb677f875df172451def5544c17c3c8d
Commit:        80f5fb7ebb677f875df172451def5544c17c3c8d
Parent:        bda0790949dccdd68b304437afa6a83bddc3ffca
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Tue Nov 14 14:15:09 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Tue Nov 14 14:15:09 2017 +0100

test: avoid have_raid overhead

---
 test/shell/lvchange-rebuild-raid.sh |   26 ++++++++++++++------------
 1 files changed, 14 insertions(+), 12 deletions(-)

diff --git a/test/shell/lvchange-rebuild-raid.sh b/test/shell/lvchange-rebuild-raid.sh
index 4f535e6..5579106 100644
--- a/test/shell/lvchange-rebuild-raid.sh
+++ b/test/shell/lvchange-rebuild-raid.sh
@@ -16,6 +16,8 @@ SKIP_WITH_LVMPOLLD=1
 . lib/inittest
 
 aux have_raid 1 3 2 || skip
+v1_9_0=0
+aux have_raid 1 9 && v1_9_0=1
 
 aux prepare_vg 8
 get_devs
@@ -47,17 +49,17 @@ _sync
 # Rebuild 1st and 2nd device would rebuild a
 # whole mirror group and needs to be rejected.
 not lvchange --yes --rebuild "$dev1" --rebuild "$dev2" $vg/$lv1
-not check raid_leg_status $vg $lv1 "aAaAAAAA"
+not check raid_leg_status $vg $lv1 "aaAAAAA"
 _sync "AAAAAAAA"
 
 # Rebuild 1st and 3rd device from different mirror groups is fine.
 lvchange --yes --rebuild "$dev1" --rebuild "$dev3" $vg/$lv1
-aux have_raid 1 9 && check raid_leg_status $vg $lv1 "aAaAAAAA"
+[ $v1_9_0 -eq 1 ] && check raid_leg_status $vg $lv1 "aAaAAAAA"
 _sync "AAAAAAAA"
 
 # Rebuild devices 1, 3, 6 from different mirror groups is fine.
 lvchange --yes --rebuild "$dev1" --rebuild "$dev3" --rebuild "$dev6" $vg/$lv1
-aux have_raid 1 9 && check raid_leg_status $vg $lv1 "aAaAAaAA"
+[ $v1_9_0 -eq 1 ] && check raid_leg_status $vg $lv1 "aAaAAaAA"
 _sync "AAAAAAAA"
 
 # Rebuild devices 1, 3, 5 and 6 with 5+6 being
@@ -68,12 +70,12 @@ _sync "AAAAAAAA"
 
 # Rebuild devices 1, 3, 5 and 7 from different mirror groups is fine.
 lvchange --yes --rebuild "$dev1" --rebuild "$dev3" --rebuild "$dev5" --rebuild "$dev7" $vg/$lv1
-aux have_raid 1 9 && check raid_leg_status $vg $lv1 "aAaAaAaA"
+[ $v1_9_0 -eq 1 ] && check raid_leg_status $vg $lv1 "aAaAaAaA"
 _sync
 
 # Rebuild devices 2, 4, 6 and 8 from different mirror groups is fine.
 lvchange --yes --rebuild "$dev2" --rebuild "$dev4" --rebuild "$dev6" --rebuild "$dev8" $vg/$lv1
-aux have_raid 1 9 && check raid_leg_status $vg $lv1 "AaAaAaAa"
+[ $v1_9_0 -eq 1 ] && check raid_leg_status $vg $lv1 "AaAaAaAa"
 _sync "AAAAAAAA"
 
 ##############################################
@@ -91,17 +93,17 @@ _sync "AAAAAAAA"
 # Rebuilding all but the raid1 master leg is fine.
 lvchange --yes --rebuild "$dev2" --rebuild "$dev3" --rebuild "$dev4" \
 	       --rebuild "$dev5" --rebuild "$dev6" --rebuild "$dev7" --rebuild "$dev8" $vg/$lv1
-aux have_raid 1 9 && check raid_leg_status $vg $lv1 "Aaaaaaaa"
+[ $v1_9_0 -eq 1 ] && check raid_leg_status $vg $lv1 "Aaaaaaaa"
 _sync "AAAAAAAA"
 
 # Rebuilding the raid1 master leg is fine.
 lvchange --yes --rebuild "$dev1" $vg/$lv1
-aux have_raid 1 9 && check raid_leg_status $vg $lv1 "aAAAAAAA"
+[ $v1_9_0 -eq 1 ] && check raid_leg_status $vg $lv1 "aAAAAAAA"
 _sync "AAAAAAAA"
 
 # Rebuild legs on devices 2, 4, 6 and 8 is fine.
 lvchange --yes --rebuild "$dev2" --rebuild "$dev4" --rebuild "$dev6" --rebuild "$dev8" $vg/$lv1
-aux have_raid 1 9 && check raid_leg_status $vg $lv1 "AaAaAaAa"
+[ $v1_9_0 -eq 1 ] && check raid_leg_status $vg $lv1 "AaAaAaAa"
 _sync "AAAAAAAA"
 
 ##############################################
@@ -123,20 +125,20 @@ _sync "AAAAAA"
 
 # Rebuilding any 1 raid6 stripe is fine.
 lvchange --yes --rebuild "$dev2" $vg/$lv1
-aux have_raid 1 9 && check raid_leg_status $vg $lv1 "AaAAAA"
+[ $v1_9_0 -eq 1 ] && check raid_leg_status $vg $lv1 "AaAAAA"
 _sync
 
 lvchange --yes --rebuild "$dev5"  $vg/$lv1
-aux have_raid 1 9 && check raid_leg_status $vg $lv1 "AAAAaA"
+[ $v1_9_0 -eq 1 ] && check raid_leg_status $vg $lv1 "AAAAaA"
 _sync "AAAAAA"
 
 # Rebuilding any 2 raid6 stripes is fine.
 lvchange --yes --rebuild "$dev2" --rebuild "$dev4" $vg/$lv1
-aux have_raid 1 9 && check raid_leg_status $vg $lv1 "AaAaAA"
+[ $v1_9_0 -eq 1 ] && check raid_leg_status $vg $lv1 "AaAaAA"
 _sync "AAAAAA"
 
 lvchange --yes --rebuild "$dev1" --rebuild "$dev5" $vg/$lv1
-aux have_raid 1 9 && check raid_leg_status $vg $lv1 "aAAAaA"
+[ $v1_9_0 -eq 1 ] && check raid_leg_status $vg $lv1 "aAAAaA"
 _sync "AAAAAA"
 
 vgremove -ff $vg


