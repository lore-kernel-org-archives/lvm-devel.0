From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  6 Jan 2017 22:40:23 +0000 (UTC)
Subject: master - tests: make test more race immune
Message-ID: <20170106224023.4BA7660506@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d757b2431a56bd5ae45fe863423942d89e14cbf9
Commit:        d757b2431a56bd5ae45fe863423942d89e14cbf9
Parent:        a4be2be5a441e3a85d50ce5728b9d1b82e7d1fc6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jan 6 21:46:58 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jan 6 23:39:53 2017 +0100

tests: make test more race immune

Add more delay and increase raid size.
Speedup volume during wait for sync.
Drop --yes from lvcreate.
---
 test/shell/lvcreate-raid-nosync.sh |   49 ++++++++++++++++++-----------------
 1 files changed, 25 insertions(+), 24 deletions(-)

diff --git a/test/shell/lvcreate-raid-nosync.sh b/test/shell/lvcreate-raid-nosync.sh
index b1916f5..40baa17 100644
--- a/test/shell/lvcreate-raid-nosync.sh
+++ b/test/shell/lvcreate-raid-nosync.sh
@@ -21,67 +21,68 @@ aux have_raid4 && segtypes="raid4 raid5"
 
 aux prepare_vg 6
 
+_sync() {
+	aux enable_dev "$dev1"
+
+	aux wait_for_sync $vg $lv1
+	test -z "$1" || check raid_leg_status $vg $lv1 $1
+	lvremove --yes $vg/$lv1
+
+	# restore to delay_dev tables for all devices
+	aux restore_from_devtable "$dev1"
+}
+
 
 # Delay 1st leg so that rebuilding status characters
 #  can be read before resync finished too quick.
-aux delay_dev "$dev1" 0 50 $(get first_extent_sector "$dev1")
+aux delay_dev "$dev1" 0 90 $(get first_extent_sector "$dev1")
 
 # raid0/raid0_meta don't support resynchronization
 for r in raid0 raid0_meta
 do
-	lvcreate --yes --type $r -i 3 -l 1 -n $lv1 $vg
+	lvcreate --type $r -i 3 -l 1 -n $lv1 $vg
 	check raid_leg_status $vg $lv1 "AAA"
 	lvremove --yes $vg/$lv1
 done
 
 # raid1 supports resynchronization
-lvcreate --yes --type raid1 -m 2 -l 2 -n $lv1 $vg
+lvcreate --type raid1 -m 2 -l 4 -n $lv1 $vg
 check raid_leg_status $vg $lv1 "aaa"
-aux wait_for_sync $vg $lv1
-check raid_leg_status $vg $lv1 "AAA"
-lvremove --yes $vg/$lv1
+_sync "AAA"
 
 # raid1 supports --nosync
-lvcreate --yes --type raid1 --nosync -m 2 -l 1 -n $lv1 $vg
+lvcreate --type raid1 --nosync -m 2 -l 1 -n $lv1 $vg
 check raid_leg_status $vg $lv1 "AAA"
 lvremove --yes $vg/$lv1
 
 for r in $segtypes
 do
 	# raid4/5 support resynchronization
-	lvcreate --yes --type $r -i 3 -l 2 -n $lv1 $vg
+	lvcreate --type $r -i 3 -l 4 -n $lv1 $vg
 	check raid_leg_status $vg $lv1 "aaaa"
-	aux wait_for_sync $vg $lv1
-	check raid_leg_status $vg $lv1 "AAAA"
+	_sync "AAAA"
 
 	# raid4/5 support --nosync
-	lvcreate --yes --type $r --nosync -i 3 -l 1 -n $lv2 $vg
+	lvcreate --type $r --nosync -i 3 -l 1 -n $lv2 $vg
 	check raid_leg_status $vg $lv2 "AAAA"
 	lvremove --yes $vg
 done
 
 # raid6 supports resynchronization
-lvcreate --yes --type raid6 -i 3 -l 2 -n $lv1 $vg
+lvcreate --type raid6 -i 3 -l 4 -n $lv1 $vg
 check raid_leg_status $vg $lv1 "aaaaa"
-aux wait_for_sync $vg $lv1
-check raid_leg_status $vg $lv1 "AAAAA"
-lvremove --yes $vg/$lv1
+_sync "AAAAA"
 
 # raid6 rejects --nosync; it has to initialize P- and Q-Syndromes
-not lvcreate --yes --type raid6 --nosync -i 3 -l 1 -n $lv1 $vg
+not lvcreate --type raid6 --nosync -i 3 -l 1 -n $lv1 $vg
 
 # raid10 supports resynchronization
-lvcreate --yes --type raid10 -m 1 -i 3 -l 2 -n $lv1 $vg
+lvcreate --type raid10 -m 1 -i 3 -l 4 -n $lv1 $vg
 check raid_leg_status $vg $lv1 "aaaaaa"
-aux wait_for_sync $vg $lv1
-check raid_leg_status $vg $lv1 "AAAAAA"
-aux wait_for_sync $vg $lv1
-lvremove --yes $vg/$lv1
+_sync "AAAAAA"
 
 # raid10 supports --nosync
-lvcreate --yes --type raid10 --nosync -m 1 -i 3 -l 1 -n $lv1 $vg
+lvcreate --type raid10 --nosync -m 1 -i 3 -l 1 -n $lv1 $vg
 check raid_leg_status $vg $lv1 "AAAAAA"
-aux wait_for_sync $vg $lv1
-lvremove --yes $vg/$lv1
 
 vgremove -ff $vg


