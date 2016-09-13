From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 13 Sep 2016 10:26:13 +0000 (UTC)
Subject: master - tests: slightly bigger raid arrays
Message-ID: <20160913102613.C4DC160D27@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cebcc8a6040e44223e466572ee899c591b42e5d4
Commit:        cebcc8a6040e44223e466572ee899c591b42e5d4
Parent:        08c94de79895ac94ebc346fc440dbb23eaa98b45
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 13 12:23:46 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 13 12:25:36 2016 +0200

tests: slightly bigger raid arrays

Just to ensure we catch devices in sync.
---
 test/shell/lvcreate-raid-nosync.sh |   15 +++++++--------
 1 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/test/shell/lvcreate-raid-nosync.sh b/test/shell/lvcreate-raid-nosync.sh
index 801ef53..fdb4f68 100644
--- a/test/shell/lvcreate-raid-nosync.sh
+++ b/test/shell/lvcreate-raid-nosync.sh
@@ -32,7 +32,7 @@ do
 done
 
 # raid1 supports resynchronization
-lvcreate --yes --type raid1 -m 2 -l 1 -n $lv1 $vg
+lvcreate --yes --type raid1 -m 2 -l 2 -n $lv1 $vg
 check raid_leg_status $vg $lv1 "aaa"
 aux wait_for_sync $vg $lv1
 check raid_leg_status $vg $lv1 "AAA"
@@ -46,20 +46,19 @@ lvremove --yes $vg/$lv1
 for r in raid4 raid5
 do 
 	# raid4/5 support resynchronization
-	lvcreate --yes --type $r -i 3 -l 1 -n $lv1 $vg
+	lvcreate --yes --type $r -i 3 -l 2 -n $lv1 $vg
 	check raid_leg_status $vg $lv1 "aaaa"
 	aux wait_for_sync $vg $lv1
 	check raid_leg_status $vg $lv1 "AAAA"
-	lvremove --yes $vg/$lv1
 
 	# raid4/5 support --nosync
-	lvcreate --yes --type $r --nosync -i 3 -l 1 -n $lv1 $vg
-	check raid_leg_status $vg $lv1 "AAAA"
-	lvremove --yes $vg/$lv1
+	lvcreate --yes --type $r --nosync -i 3 -l 1 -n $lv2 $vg
+	check raid_leg_status $vg $lv2 "AAAA"
+	lvremove --yes $vg
 done
 
 # raid6 supports resynchronization
-lvcreate --yes --type raid6 -i 3 -l 1 -n $lv1 $vg
+lvcreate --yes --type raid6 -i 3 -l 2 -n $lv1 $vg
 check raid_leg_status $vg $lv1 "aaaaa"
 aux wait_for_sync $vg $lv1
 check raid_leg_status $vg $lv1 "AAAAA"
@@ -69,7 +68,7 @@ lvremove --yes $vg/$lv1
 not lvcreate --yes --type raid6 --nosync -i 3 -l 1 -n $lv1 $vg
 
 # raid10 supports resynchronization
-lvcreate --yes --type raid10 -m 1 -i 3 -l 1 -n $lv1 $vg
+lvcreate --yes --type raid10 -m 1 -i 3 -l 2 -n $lv1 $vg
 check raid_leg_status $vg $lv1 "aaaaaa"
 aux wait_for_sync $vg $lv1
 check raid_leg_status $vg $lv1 "AAAAAA"


