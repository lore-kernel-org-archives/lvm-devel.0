From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  8 Nov 2016 15:01:56 +0000 (UTC)
Subject: master - tests: test raid0_meta type
Message-ID: <20161108150156.8AC8D60DCC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2ec3e7dca8822770b3eb832488b9897b7d372e01
Commit:        2ec3e7dca8822770b3eb832488b9897b7d372e01
Parent:        ada5733c5652d456ffa138b0d07e6897824813b0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 7 11:05:50 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Nov 8 16:01:35 2016 +0100

tests: test raid0_meta type

Enable testing of raid0_meta type.
Also slow down devices a bit more.
---
 test/shell/lvcreate-raid-nosync.sh |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/test/shell/lvcreate-raid-nosync.sh b/test/shell/lvcreate-raid-nosync.sh
index 1343e8f..b1916f5 100644
--- a/test/shell/lvcreate-raid-nosync.sh
+++ b/test/shell/lvcreate-raid-nosync.sh
@@ -24,12 +24,12 @@ aux prepare_vg 6
 
 # Delay 1st leg so that rebuilding status characters
 #  can be read before resync finished too quick.
-aux delay_dev "$dev1" 0 10 $(get first_extent_sector "$dev1")
+aux delay_dev "$dev1" 0 50 $(get first_extent_sector "$dev1")
 
 # raid0/raid0_meta don't support resynchronization
 for r in raid0 raid0_meta
 do
-	lvcreate --yes --type raid0 -i 3 -l 1 -n $lv1 $vg
+	lvcreate --yes --type $r -i 3 -l 1 -n $lv1 $vg
 	check raid_leg_status $vg $lv1 "AAA"
 	lvremove --yes $vg/$lv1
 done
@@ -47,7 +47,7 @@ check raid_leg_status $vg $lv1 "AAA"
 lvremove --yes $vg/$lv1
 
 for r in $segtypes
-do 
+do
 	# raid4/5 support resynchronization
 	lvcreate --yes --type $r -i 3 -l 2 -n $lv1 $vg
 	check raid_leg_status $vg $lv1 "aaaa"


