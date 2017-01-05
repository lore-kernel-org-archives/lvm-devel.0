From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  5 Jan 2017 14:56:46 +0000 (UTC)
Subject: master - tests: slow down devs for raid more
Message-ID: <20170105145646.2995B60E3A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b92a9c3e1ab9972b059ef797136c7e04b4b9368f
Commit:        b92a9c3e1ab9972b059ef797136c7e04b4b9368f
Parent:        c64f4447d92c4c8bc72d33a9615ef62fcef41168
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jan 4 16:02:08 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jan 5 15:54:14 2017 +0100

tests: slow down devs for raid more

Since we still experience occasiaonal test failure - slow
things down even more to avoid race.

Add support for 'quick' table changes between normal & delayed tables.
---
 test/lib/aux.sh                     |   25 +++++++++++++
 test/shell/lvchange-rebuild-raid.sh |   68 ++++++++++++++++------------------
 2 files changed, 57 insertions(+), 36 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 174e05e..027e3f4 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -975,6 +975,31 @@ enable_dev() {
 	done
 }
 
+# Once there is $name.devtable
+# this is a quick way to restore to this table entry
+restore_from_devtable() {
+	local dev
+	local silent
+
+	if test "$1" = "--silent"; then
+	    silent=1
+	    shift
+	fi
+
+	rm -f debug.log strace.log
+	init_udev_transaction
+	for dev in "$@"; do
+		local name=$(echo "$dev" | sed -e 's,.*/,,')
+		dmsetup load "$name" "$name.devtable"
+		dmsetup resume "$name"
+	done
+	finish_udev_transaction
+
+	test -n "$silent" || for dev in "$@"; do
+		notify_lvmetad "$dev"
+	done
+}
+
 #
 # Convert device to device with errors
 # Takes the list of pairs of error segment from:len
diff --git a/test/shell/lvchange-rebuild-raid.sh b/test/shell/lvchange-rebuild-raid.sh
index df6a8cb..c90406c 100644
--- a/test/shell/lvchange-rebuild-raid.sh
+++ b/test/shell/lvchange-rebuild-raid.sh
@@ -18,10 +18,20 @@ aux have_raid 1 3 2 || skip
 
 aux prepare_vg 8
 
+_sync() {
+	aux enable_dev $(< DEVICES)
+
+	aux wait_for_sync $vg $lv1
+	test -z "$1" || check raid_leg_status $vg $lv1 $1
+
+	# restore to delay_dev tables for all devices
+	aux restore_from_devtable $(< DEVICES)
+}
+
 # Delay legs so that rebuilding status characters can be read
 for d in $(< DEVICES)
 do
-	aux delay_dev "$d" 0 20 $(get first_extent_sector "$d")
+	aux delay_dev "$d" 0 50 $(get first_extent_sector "$d")
 done
 
 # rhbz 1064592
@@ -30,115 +40,101 @@ done
 # Create an 8-way striped raid10 with 4 mirror
 # groups and rebuild selected PVs.
 lvcreate --type raid10 -m 1 -i 4 -l 2 -n $lv1 $vg
-aux wait_for_sync $vg $lv1
+_sync
 
 # Rebuild 1st and 2nd device would rebuild a
 # whole mirror group and needs to be rejected.
 not lvchange --yes --rebuild "$dev1" --rebuild "$dev2" $vg/$lv1
 not check raid_leg_status $vg $lv1 "aAaAAAAA"
-aux wait_for_sync $vg $lv1
-check raid_leg_status $vg $lv1 "AAAAAAAA"
+_sync "AAAAAAAA"
 
 # Rebuild 1st and 3rd device from different mirror groups is fine.
 lvchange --yes --rebuild "$dev1" --rebuild "$dev3" $vg/$lv1
 aux have_raid 1 9 && check raid_leg_status $vg $lv1 "aAaAAAAA"
-aux wait_for_sync $vg $lv1
-check raid_leg_status $vg $lv1 "AAAAAAAA"
+_sync "AAAAAAAA"
 
 # Rebuild devices 1, 3, 6 from different mirror groups is fine.
 lvchange --yes --rebuild "$dev1" --rebuild "$dev3" --rebuild "$dev6" $vg/$lv1
 aux have_raid 1 9 && check raid_leg_status $vg $lv1 "aAaAAaAA"
-aux wait_for_sync $vg $lv1
-check raid_leg_status $vg $lv1 "AAAAAAAA"
+_sync "AAAAAAAA"
 
 # Rebuild devices 1, 3, 5 and 6 with 5+6 being
 # being a whole mirror group needs to be rejected.
 not lvchange --yes --rebuild "$dev1" --rebuild "$dev3" --rebuild "$dev6" --rebuild "$dev5" $vg/$lv1
 not check raid_leg_status $vg $lv1 "aAaAaaAA"
-aux wait_for_sync $vg $lv1
-check raid_leg_status $vg $lv1 "AAAAAAAA"
+_sync "AAAAAAAA"
 
 # Rebuild devices 1, 3, 5 and 7 from different mirror groups is fine.
 lvchange --yes --rebuild "$dev1" --rebuild "$dev3" --rebuild "$dev5" --rebuild "$dev7" $vg/$lv1
 aux have_raid 1 9 && check raid_leg_status $vg $lv1 "aAaAaAaA"
-aux wait_for_sync $vg $lv1
+_sync
 
 # Rebuild devices 2, 4, 6 and 8 from different mirror groups is fine.
 lvchange --yes --rebuild "$dev2" --rebuild "$dev4" --rebuild "$dev6" --rebuild "$dev8" $vg/$lv1
 aux have_raid 1 9 && check raid_leg_status $vg $lv1 "AaAaAaAa"
-aux wait_for_sync $vg $lv1
-check raid_leg_status $vg $lv1 "AAAAAAAA"
+_sync "AAAAAAAA"
 
 ##############################################
 # Create an 8-legged raid1 and rebuild selected PVs
 lvremove --yes $vg/$lv1
 lvcreate --yes --type raid1 -m 7 -l 2 -n $lv1 $vg
-aux wait_for_sync $vg $lv1
-check raid_leg_status $vg $lv1 "AAAAAAAA"
+_sync "AAAAAAAA"
 
 # Rebuilding all raid1 legs needs to be rejected.
 not lvchange --yes --rebuild "$dev1" --rebuild "$dev2" --rebuild "$dev3" --rebuild "$dev4" \
 		   --rebuild "$dev5" --rebuild "$dev6" --rebuild "$dev7" --rebuild "$dev8" $vg/$lv1
 not check raid_leg_status $vg $lv1 "aaaaaaaa"
-aux wait_for_sync $vg $lv1
-check raid_leg_status $vg $lv1 "AAAAAAAA"
+_sync "AAAAAAAA"
 
 # Rebuilding all but the raid1 master leg is fine.
 lvchange --yes --rebuild "$dev2" --rebuild "$dev3" --rebuild "$dev4" \
 	       --rebuild "$dev5" --rebuild "$dev6" --rebuild "$dev7" --rebuild "$dev8" $vg/$lv1
 aux have_raid 1 9 && check raid_leg_status $vg $lv1 "Aaaaaaaa"
-aux wait_for_sync $vg $lv1
-check raid_leg_status $vg $lv1 "AAAAAAAA"
+_sync "AAAAAAAA"
 
 # Rebuilding the raid1 master leg is fine.
 lvchange --yes --rebuild "$dev1" $vg/$lv1
 aux have_raid 1 9 && check raid_leg_status $vg $lv1 "aAAAAAAA"
-aux wait_for_sync $vg $lv1
-check raid_leg_status $vg $lv1 "AAAAAAAA"
+_sync "AAAAAAAA"
 
 # Rebuild legs on devices 2, 4, 6 and 8 is fine.
 lvchange --yes --rebuild "$dev2" --rebuild "$dev4" --rebuild "$dev6" --rebuild "$dev8" $vg/$lv1
 aux have_raid 1 9 && check raid_leg_status $vg $lv1 "AaAaAaAa"
-aux wait_for_sync $vg $lv1
-check raid_leg_status $vg $lv1 "AAAAAAAA"
+_sync "AAAAAAAA"
 
 ##############################################
 # Create an 6-legged raid6 and rebuild selected PVs
 lvremove --yes $vg/$lv1
 lvcreate --yes --type raid6 -i 4 -l 2 -n $lv1 $vg
-aux wait_for_sync $vg $lv1
-check raid_leg_status $vg $lv1 "AAAAAA"
+_sync "AAAAAA"
 
 # Rebuilding all raid6 stripes needs to be rejected.
 not lvchange --yes --rebuild "$dev1" --rebuild "$dev2" --rebuild "$dev3" \
 		   --rebuild "$dev4" --rebuild "$dev5" --rebuild "$dev6"  $vg/$lv1
 not check raid_leg_status $vg $lv1 "aaaaaa"
-aux wait_for_sync $vg $lv1
-check raid_leg_status $vg $lv1 "AAAAAA"
+_sync "AAAAAA"
 
 # Rebuilding more than 2 raid6 stripes needs to be rejected.
 not lvchange --yes --rebuild "$dev2" --rebuild "$dev4" --rebuild "$dev6" $vg/$lv1
 not check raid_leg_status $vg $lv1 "AaAaAa"
-aux wait_for_sync $vg $lv1
-check raid_leg_status $vg $lv1 "AAAAAA"
+_sync "AAAAAA"
 
 # Rebuilding any 1 raid6 stripe is fine.
 lvchange --yes --rebuild "$dev2" $vg/$lv1
 aux have_raid 1 9 && check raid_leg_status $vg $lv1 "AaAAAA"
-aux wait_for_sync $vg $lv1
+_sync
+
 lvchange --yes --rebuild "$dev5"  $vg/$lv1
 aux have_raid 1 9 && check raid_leg_status $vg $lv1 "AAAAaA"
-aux wait_for_sync $vg $lv1
-check raid_leg_status $vg $lv1 "AAAAAA"
+_sync "AAAAAA"
 
 # Rebuilding any 2 raid6 stripes is fine.
 lvchange --yes --rebuild "$dev2" --rebuild "$dev4" $vg/$lv1
 aux have_raid 1 9 && check raid_leg_status $vg $lv1 "AaAaAA"
-aux wait_for_sync $vg $lv1
-check raid_leg_status $vg $lv1 "AAAAAA"
+_sync "AAAAAA"
+
 lvchange --yes --rebuild "$dev1" --rebuild "$dev5" $vg/$lv1
 aux have_raid 1 9 && check raid_leg_status $vg $lv1 "aAAAaA"
-aux wait_for_sync $vg $lv1
-check raid_leg_status $vg $lv1 "AAAAAA"
+_sync "AAAAAA"
 
 vgremove -ff $vg


