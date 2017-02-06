From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  6 Feb 2017 12:17:41 +0000 (UTC)
Subject: master - tests: drop zeroing
Message-ID: <20170206121741.02C9C60302@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=51d03acb1c910a65ff05a0a339ed6a4ff957c0db
Commit:        51d03acb1c910a65ff05a0a339ed6a4ff957c0db
Parent:        48abbdf4524f316aa93b2d8b857b59803095ace3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 6 13:15:39 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 6 13:15:39 2017 +0100

tests: drop zeroing

Well waiting for zeroing may take enough time to finish 'raid' sync.
So make the test running faster without zeroing and better avoid race
to have chance to happen (i.e. lvcreate is finished after array
gets already in sync).
---
 test/shell/lvcreate-raid-nosync.sh |   22 +++++++++++-----------
 1 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/test/shell/lvcreate-raid-nosync.sh b/test/shell/lvcreate-raid-nosync.sh
index 40baa17..1f01f47 100644
--- a/test/shell/lvcreate-raid-nosync.sh
+++ b/test/shell/lvcreate-raid-nosync.sh
@@ -16,8 +16,8 @@ SKIP_WITH_LVMPOLLD=1
 
 aux have_raid 1 7 0 || skip
 
-segtypes=raid5
-aux have_raid4 && segtypes="raid4 raid5"
+segtypes="raid5"
+aux have_raid4 && segtypes="raid4 $segtypes"
 
 aux prepare_vg 6
 
@@ -40,49 +40,49 @@ aux delay_dev "$dev1" 0 90 $(get first_extent_sector "$dev1")
 # raid0/raid0_meta don't support resynchronization
 for r in raid0 raid0_meta
 do
-	lvcreate --type $r -i 3 -l 1 -n $lv1 $vg
+	lvcreate --type $r -Zn -i 3 -l 1 -n $lv1 $vg
 	check raid_leg_status $vg $lv1 "AAA"
 	lvremove --yes $vg/$lv1
 done
 
 # raid1 supports resynchronization
-lvcreate --type raid1 -m 2 -l 4 -n $lv1 $vg
+lvcreate --type raid1 -m 2 -Zn -l 4 -n $lv1 $vg
 check raid_leg_status $vg $lv1 "aaa"
 _sync "AAA"
 
 # raid1 supports --nosync
-lvcreate --type raid1 --nosync -m 2 -l 1 -n $lv1 $vg
+lvcreate --type raid1 --nosync -Zn -m 2 -l 1 -n $lv1 $vg
 check raid_leg_status $vg $lv1 "AAA"
 lvremove --yes $vg/$lv1
 
 for r in $segtypes
 do
 	# raid4/5 support resynchronization
-	lvcreate --type $r -i 3 -l 4 -n $lv1 $vg
+	lvcreate --type $r -Zn -i 3 -l 4 -n $lv1 $vg
 	check raid_leg_status $vg $lv1 "aaaa"
 	_sync "AAAA"
 
 	# raid4/5 support --nosync
-	lvcreate --type $r --nosync -i 3 -l 1 -n $lv2 $vg
+	lvcreate --type $r -Zn --nosync -i 3 -l 1 -n $lv2 $vg
 	check raid_leg_status $vg $lv2 "AAAA"
 	lvremove --yes $vg
 done
 
 # raid6 supports resynchronization
-lvcreate --type raid6 -i 3 -l 4 -n $lv1 $vg
+lvcreate --type raid6 -Zn -i 3 -l 4 -n $lv1 $vg
 check raid_leg_status $vg $lv1 "aaaaa"
 _sync "AAAAA"
 
 # raid6 rejects --nosync; it has to initialize P- and Q-Syndromes
-not lvcreate --type raid6 --nosync -i 3 -l 1 -n $lv1 $vg
+not lvcreate --type raid6 --nosync -Zn -i 3 -l 1 -n $lv1 $vg
 
 # raid10 supports resynchronization
-lvcreate --type raid10 -m 1 -i 3 -l 4 -n $lv1 $vg
+lvcreate --type raid10 -m 1 -Zn -i 3 -l 4 -n $lv1 $vg
 check raid_leg_status $vg $lv1 "aaaaaa"
 _sync "AAAAAA"
 
 # raid10 supports --nosync
-lvcreate --type raid10 --nosync -m 1 -i 3 -l 1 -n $lv1 $vg
+lvcreate --type raid10 --nosync -m 1 -Zn -i 3 -l 1 -n $lv1 $vg
 check raid_leg_status $vg $lv1 "AAAAAA"
 
 vgremove -ff $vg


