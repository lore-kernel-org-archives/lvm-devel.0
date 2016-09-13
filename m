From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 13 Sep 2016 10:26:09 +0000 (UTC)
Subject: master - tests: use just single raid_leg_status
Message-ID: <20160913102609.A6F67610D9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d34e315b8dbe3bd469499e62feb02b27aaf7b179
Commit:        d34e315b8dbe3bd469499e62feb02b27aaf7b179
Parent:        5314d36f3d186efb05a051e80444332f743194ef
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 13 11:27:36 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 13 12:25:36 2016 +0200

tests: use just single raid_leg_status

Simplify 'check' test actualy and correct printed tracing output
---
 test/lib/check.sh                   |   10 +++-------
 test/shell/lvchange-rebuild-raid.sh |   22 +++++++++++-----------
 test/shell/lvcreate-large-raid.sh   |   18 +++++++++---------
 test/shell/lvcreate-raid-nosync.sh  |   24 ++++++++++++------------
 4 files changed, 35 insertions(+), 39 deletions(-)

diff --git a/test/lib/check.sh b/test/lib/check.sh
index f0e4f0b..9dd8635 100644
--- a/test/lib/check.sh
+++ b/test/lib/check.sh
@@ -392,16 +392,12 @@ sysfs() {
 		die "$1: $P = $val differs from expected value $3!"
 }
 
-# check status_chars $vg $lv "Aaaaa"
+# check raid_leg_status $vg $lv "Aaaaa"
 raid_leg_status() {
 	local st=$(dmsetup status $1-$2)
 	local val=$(echo "$st" | cut -d ' ' -f 6)
-	test "$val" = "$3"
-}
-
-raid_leg_status_is() {
-	raid_leg_status "$@" || \
-		die "Raid leg status $val differs from expected value $3 ($1-$2 $st)!"
+	test "$val" = "$3" || \
+		die "$1-$2 status $val != $3  ($st)"
 }
 
 #set -x
diff --git a/test/shell/lvchange-rebuild-raid.sh b/test/shell/lvchange-rebuild-raid.sh
index 6cc500d..f15c5ef 100644
--- a/test/shell/lvchange-rebuild-raid.sh
+++ b/test/shell/lvchange-rebuild-raid.sh
@@ -40,12 +40,12 @@ aux wait_for_sync $vg $lv1
 
 # Rebuild 1st and 3nd device from different mirror groups is fine.
 lvchange --yes --rebuild "$dev1" --rebuild "$dev3" $vg/$lv1
-check raid_leg_status_is $vg $lv1 "aAaAAAAA"
+check raid_leg_status $vg $lv1 "aAaAAAAA"
 aux wait_for_sync $vg $lv1
 
 # Rebuild devices 1, 3, 6 from different mirror groups is fine.
 lvchange --yes --rebuild "$dev1" --rebuild "$dev3" --rebuild "$dev6" $vg/$lv1
-check raid_leg_status_is $vg $lv1 "aAaAAaAA"
+check raid_leg_status $vg $lv1 "aAaAAaAA"
 aux wait_for_sync $vg $lv1
 
 # Rebuild devices 1, 3, 5 and 6 with 5+6 being
@@ -56,12 +56,12 @@ aux wait_for_sync $vg $lv1
 
 # Rebuild devices 1, 3, 5 and 7 from different mirror groups is fine.
 lvchange --yes --rebuild "$dev1" --rebuild "$dev3" --rebuild "$dev5" --rebuild "$dev7" $vg/$lv1
-check raid_leg_status_is $vg $lv1 "aAaAaAaA"
+check raid_leg_status $vg $lv1 "aAaAaAaA"
 aux wait_for_sync $vg $lv1
 
 # Rebuild devices 2, 4, 6 and 8 from different mirror groups is fine.
 lvchange --yes --rebuild "$dev2" --rebuild "$dev4" --rebuild "$dev6" --rebuild "$dev8" $vg/$lv1
-check raid_leg_status_is $vg $lv1 "AaAaAaAa"
+check raid_leg_status $vg $lv1 "AaAaAaAa"
 aux wait_for_sync $vg $lv1
 
 ##############################################
@@ -79,17 +79,17 @@ aux wait_for_sync $vg $lv1
 # Rebuilding all but the raid1 master leg is fine.
 lvchange --yes --rebuild "$dev2" --rebuild "$dev3" --rebuild "$dev4" \
 	       --rebuild "$dev5" --rebuild "$dev6" --rebuild "$dev7" --rebuild "$dev8" $vg/$lv1
-check raid_leg_status_is $vg $lv1 "Aaaaaaaa"
+check raid_leg_status $vg $lv1 "Aaaaaaaa"
 aux wait_for_sync $vg $lv1
 
 # Rebuilding the raid1 master leg is fine.
 lvchange --yes --rebuild "$dev1" $vg/$lv1
-check raid_leg_status_is $vg $lv1 "aAAAAAAA"
+check raid_leg_status $vg $lv1 "aAAAAAAA"
 aux wait_for_sync $vg $lv1
 
 # Rebuild legs on devices 2, 4, 6 and 8 is fine.
 lvchange --yes --rebuild "$dev2" --rebuild "$dev4" --rebuild "$dev6" --rebuild "$dev8" $vg/$lv1
-check raid_leg_status_is $vg $lv1 "AaAaAaAa"
+check raid_leg_status $vg $lv1 "AaAaAaAa"
 aux wait_for_sync $vg $lv1
 
 ##############################################
@@ -111,18 +111,18 @@ aux wait_for_sync $vg $lv1
 
 # Rebuilding any 1 raid6 stripe is fine.
 lvchange --yes --rebuild "$dev2" $vg/$lv1
-check raid_leg_status_is $vg $lv1 "AaAAAA"
+check raid_leg_status $vg $lv1 "AaAAAA"
 aux wait_for_sync $vg $lv1
 lvchange --yes --rebuild "$dev5"  $vg/$lv1
-check raid_leg_status_is $vg $lv1 "AAAAaA"
+check raid_leg_status $vg $lv1 "AAAAaA"
 aux wait_for_sync $vg $lv1
 
 # Rebuilding any 2 raid6 stripes is fine.
 lvchange --yes --rebuild "$dev2" --rebuild "$dev4" $vg/$lv1
-check raid_leg_status_is $vg $lv1 "AaAaAA"
+check raid_leg_status $vg $lv1 "AaAaAA"
 aux wait_for_sync $vg $lv1
 lvchange --yes --rebuild "$dev1" --rebuild "$dev5" $vg/$lv1
-check raid_leg_status_is $vg $lv1 "aAAAaA"
+check raid_leg_status $vg $lv1 "aAAAaA"
 aux wait_for_sync $vg $lv1
 
 vgremove -ff $vg
diff --git a/test/shell/lvcreate-large-raid.sh b/test/shell/lvcreate-large-raid.sh
index d8d077c..11a69d4 100644
--- a/test/shell/lvcreate-large-raid.sh
+++ b/test/shell/lvcreate-large-raid.sh
@@ -43,20 +43,20 @@ done
 # 200 TiB raid1
 lvcreate --type raid1 -m 1 -L 200T -n $lv1 $vg1 --nosync
 check lv_field $vg1/$lv1 size "200.00t"
-check raid_leg_status_is $vg1 $lv1 "AA"
+check raid_leg_status $vg1 $lv1 "AA"
 lvremove -ff $vg1
 
 # 1 PiB raid1
 lvcreate --type raid1 -m 1 -L 1P -n $lv1 $vg1 --nosync
 check lv_field $vg1/$lv1 size "1.00p"
-check raid_leg_status_is $vg1 $lv1 "AA"
+check raid_leg_status $vg1 $lv1 "AA"
 lvremove -ff $vg1
 
 # 750 TiB raid4/5
 for segtype in raid4 raid5; do
         lvcreate --type $segtype -i 3 -L 750T -n $lv1 $vg1 --nosync
         check lv_field $vg1/$lv1 size "750.00t"
-        check raid_leg_status_is $vg1 $lv1 "AAAA"
+        check raid_leg_status $vg1 $lv1 "AAAA"
         lvremove -ff $vg1
 done
 
@@ -65,10 +65,10 @@ done
 #
 lvcreate --type raid1 -m 1 -L 200T -n $lv1 $vg1 --nosync
 check lv_field $vg1/$lv1 size "200.00t"
-check raid_leg_status_is $vg1 $lv1 "AA"
+check raid_leg_status $vg1 $lv1 "AA"
 lvextend -L +200T $vg1/$lv1
 check lv_field $vg1/$lv1 size "400.00t"
-check raid_leg_status_is $vg1 $lv1 "AA"
+check raid_leg_status $vg1 $lv1 "AA"
 lvremove -ff $vg1
 
 
@@ -80,16 +80,16 @@ fi
 # 750 TiB raid6
 lvcreate --type raid6 -i 3 -L 750T -n $lv1 $vg1
 check lv_field $vg1/$lv1 size "750.00t"
-check raid_leg_status_is $vg1 $lv1 "aaaaa"
+check raid_leg_status $vg1 $lv1 "aaaaa"
 lvremove -ff $vg1
 
 # 1 PiB raid6, then extend up to 2 PiB
 lvcreate --type raid6 -i 3 -L 1P -n $lv1 $vg1
 check lv_field $vg1/$lv1 size "1.00p"
-check raid_leg_status_is $vg1 $lv1 "aaaaa"
+check raid_leg_status $vg1 $lv1 "aaaaa"
 lvextend -L +1P $vg1/$lv1
 check lv_field $vg1/$lv1 size "2.00p"
-check raid_leg_status_is $vg1 $lv1 "aaaaa"
+check raid_leg_status $vg1 $lv1 "aaaaa"
 lvremove -ff $vg1
 
 #
@@ -98,7 +98,7 @@ lvremove -ff $vg1
 lvcreate -aey -L 200T -n $lv1 $vg1
 lvconvert --type raid1 -m 1 $vg1/$lv1
 check lv_field $vg1/$lv1 size "200.00t"
-check raid_leg_status_is $vg1 $lv1 "aa"
+check raid_leg_status $vg1 $lv1 "aa"
 lvremove -ff $vg1
 
 # bz837927 END
diff --git a/test/shell/lvcreate-raid-nosync.sh b/test/shell/lvcreate-raid-nosync.sh
index 14ea8af..801ef53 100644
--- a/test/shell/lvcreate-raid-nosync.sh
+++ b/test/shell/lvcreate-raid-nosync.sh
@@ -27,42 +27,42 @@ aux delay_dev "$dev1" 0 10 $(get first_extent_sector "$dev1")
 for r in raid0 raid0_meta
 do
 	lvcreate --yes --type raid0 -i 3 -l 1 -n $lv1 $vg
-	check raid_leg_status_is $vg $lv1 "AAA"
+	check raid_leg_status $vg $lv1 "AAA"
 	lvremove --yes $vg/$lv1
 done
 
 # raid1 supports resynchronization
 lvcreate --yes --type raid1 -m 2 -l 1 -n $lv1 $vg
-check raid_leg_status_is $vg $lv1 "aaa"
+check raid_leg_status $vg $lv1 "aaa"
 aux wait_for_sync $vg $lv1
-check raid_leg_status_is $vg $lv1 "AAA"
+check raid_leg_status $vg $lv1 "AAA"
 lvremove --yes $vg/$lv1
 
 # raid1 supports --nosync
 lvcreate --yes --type raid1 --nosync -m 2 -l 1 -n $lv1 $vg
-check raid_leg_status_is $vg $lv1 "AAA"
+check raid_leg_status $vg $lv1 "AAA"
 lvremove --yes $vg/$lv1
 
 for r in raid4 raid5
 do 
 	# raid4/5 support resynchronization
 	lvcreate --yes --type $r -i 3 -l 1 -n $lv1 $vg
-	check raid_leg_status_is $vg $lv1 "aaaa"
+	check raid_leg_status $vg $lv1 "aaaa"
 	aux wait_for_sync $vg $lv1
-	check raid_leg_status_is $vg $lv1 "AAAA"
+	check raid_leg_status $vg $lv1 "AAAA"
 	lvremove --yes $vg/$lv1
 
 	# raid4/5 support --nosync
 	lvcreate --yes --type $r --nosync -i 3 -l 1 -n $lv1 $vg
-	check raid_leg_status_is $vg $lv1 "AAAA"
+	check raid_leg_status $vg $lv1 "AAAA"
 	lvremove --yes $vg/$lv1
 done
 
 # raid6 supports resynchronization
 lvcreate --yes --type raid6 -i 3 -l 1 -n $lv1 $vg
-check raid_leg_status_is $vg $lv1 "aaaaa"
+check raid_leg_status $vg $lv1 "aaaaa"
 aux wait_for_sync $vg $lv1
-check raid_leg_status_is $vg $lv1 "AAAAA"
+check raid_leg_status $vg $lv1 "AAAAA"
 lvremove --yes $vg/$lv1
 
 # raid6 rejects --nosync; it has to initialize P- and Q-Syndromes
@@ -70,15 +70,15 @@ not lvcreate --yes --type raid6 --nosync -i 3 -l 1 -n $lv1 $vg
 
 # raid10 supports resynchronization
 lvcreate --yes --type raid10 -m 1 -i 3 -l 1 -n $lv1 $vg
-check raid_leg_status_is $vg $lv1 "aaaaaa"
+check raid_leg_status $vg $lv1 "aaaaaa"
 aux wait_for_sync $vg $lv1
-check raid_leg_status_is $vg $lv1 "AAAAAA"
+check raid_leg_status $vg $lv1 "AAAAAA"
 aux wait_for_sync $vg $lv1
 lvremove --yes $vg/$lv1
 
 # raid10 supports --nosync
 lvcreate --yes --type raid10 --nosync -m 1 -i 3 -l 1 -n $lv1 $vg
-check raid_leg_status_is $vg $lv1 "AAAAAA"
+check raid_leg_status $vg $lv1 "AAAAAA"
 aux wait_for_sync $vg $lv1
 lvremove --yes $vg/$lv1
 


