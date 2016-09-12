From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 12 Sep 2016 14:52:52 +0000 (UTC)
Subject: master - tests: add check function for raid leg status
Message-ID: <20160912145252.EF1BD60E22@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5b55f9616df036078a2cfbfc6b7a19a1f31d7f22
Commit:        5b55f9616df036078a2cfbfc6b7a19a1f31d7f22
Parent:        44f1f45e16d4e6111e1dfd79a485697385e04160
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 12 15:44:09 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 12 16:51:53 2016 +0200

tests: add check function for raid leg status

2 new check test functions:

raid_leg_status    - to just compare
raid_leg_status_is - to compare and die when different
---
 test/lib/aux.sh                     |    6 ------
 test/lib/check.sh                   |   12 ++++++++++++
 test/shell/lvchange-rebuild-raid.sh |   32 ++++++++++++++++----------------
 test/shell/lvcreate-large-raid.sh   |   18 +++++++++---------
 test/shell/lvcreate-raid-nosync.sh  |   24 ++++++++++++------------
 5 files changed, 49 insertions(+), 43 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 7dffdcb..3d84e86 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1264,12 +1264,6 @@ wait_for_sync() {
 	return 1
 }
 
-# aux check_status_chars $vg $lv "Aaaaa"
-check_status_chars() {
-	[ `dmsetup status $1-$2|awk '{print $6}'` = $3 ] && return
-	return 1
-}
-
 # Check if tests are running on 64bit architecture
 can_use_16T() {
 	test "$(getconf LONG_BIT)" -eq 64
diff --git a/test/lib/check.sh b/test/lib/check.sh
index e729ab2..f0e4f0b 100644
--- a/test/lib/check.sh
+++ b/test/lib/check.sh
@@ -392,6 +392,18 @@ sysfs() {
 		die "$1: $P = $val differs from expected value $3!"
 }
 
+# check status_chars $vg $lv "Aaaaa"
+raid_leg_status() {
+	local st=$(dmsetup status $1-$2)
+	local val=$(echo "$st" | cut -d ' ' -f 6)
+	test "$val" = "$3"
+}
+
+raid_leg_status_is() {
+	raid_leg_status "$@" || \
+		die "Raid leg status $val differs from expected value $3 ($1-$2 $st)!"
+}
+
 #set -x
 unset LVM_VALGRIND
 "$@"
diff --git a/test/shell/lvchange-rebuild-raid.sh b/test/shell/lvchange-rebuild-raid.sh
index e1eb6b4..e4c579e 100644
--- a/test/shell/lvchange-rebuild-raid.sh
+++ b/test/shell/lvchange-rebuild-raid.sh
@@ -35,33 +35,33 @@ aux wait_for_sync $vg $lv1
 # Rebuild 1st and 2nd device would rebuild a
 # whole mirror group and needs to be rejected.
 not lvchange --yes --rebuild "$dev1" --rebuild "$dev2" $vg/$lv1
-not aux check_status_chars $vg $lv1 "aAaAAAAA"
+not check raid_leg_status $vg $lv1 "aAaAAAAA"
 aux wait_for_sync $vg $lv1
 
 # Rebuild 1st and 3nd device from different mirror groups is fine.
 lvchange --yes --rebuild "$dev1" --rebuild "$dev3" $vg/$lv1
-aux check_status_chars $vg $lv1 "aAaAAAAA"
+check raid_leg_status_is $vg $lv1 "aAaAAAAA"
 aux wait_for_sync $vg $lv1
 
 # Rebuild devices 1, 3, 6 from different mirror groups is fine.
 lvchange --yes --rebuild "$dev1" --rebuild "$dev3" --rebuild "$dev6" $vg/$lv1
-aux check_status_chars $vg $lv1 "aAaAAaAA"
+check raid_leg_status_is $vg $lv1 "aAaAAaAA"
 aux wait_for_sync $vg $lv1
 
 # Rebuild devices 1, 3, 5 and 6 with 5+6 being
 # being a whole mirror group needs to be rejected.
 not lvchange --yes --rebuild "$dev1" --rebuild "$dev3" --rebuild "$dev6" --rebuild "$dev5" $vg/$lv1
-not aux check_status_chars $vg $lv1 "aAaAaaAA"
+not check raid_leg_status $vg $lv1 "aAaAaaAA"
 aux wait_for_sync $vg $lv1
 
 # Rebuild devices 1, 3, 5 and 7 from different mirror groups is fine.
 lvchange --yes --rebuild "$dev1" --rebuild "$dev3" --rebuild "$dev5" --rebuild "$dev7" $vg/$lv1
-aux check_status_chars $vg $lv1 "aAaAaAaA"
+check raid_leg_status_is $vg $lv1 "aAaAaAaA"
 aux wait_for_sync $vg $lv1
 
 # Rebuild devices 2, 4, 6 and 8 from different mirror groups is fine.
 lvchange --yes --rebuild "$dev2" --rebuild "$dev4" --rebuild "$dev6" --rebuild "$dev8" $vg/$lv1
-aux check_status_chars $vg $lv1 "AaAaAaAa"
+check raid_leg_status_is $vg $lv1 "AaAaAaAa"
 aux wait_for_sync $vg $lv1
 
 ##############################################
@@ -73,23 +73,23 @@ aux wait_for_sync $vg $lv1
 # Rebuilding all raid1 legs needs to be rejected.
 not lvchange --yes --rebuild "$dev1" --rebuild "$dev2" --rebuild "$dev3" --rebuild "$dev4" \
 		   --rebuild "$dev5" --rebuild "$dev6" --rebuild "$dev7" --rebuild "$dev8" $vg/$lv1
-not aux check_status_chars $vg $lv1 "aaaaaaaa"
+not check raid_leg_status $vg $lv1 "aaaaaaaa"
 aux wait_for_sync $vg $lv1
 
 # Rebuilding all but the raid1 master leg is fine.
 lvchange --yes --rebuild "$dev2" --rebuild "$dev3" --rebuild "$dev4" \
 	       --rebuild "$dev5" --rebuild "$dev6" --rebuild "$dev7" --rebuild "$dev8" $vg/$lv1
-aux check_status_chars $vg $lv1 "Aaaaaaaa"
+check raid_leg_status_is $vg $lv1 "Aaaaaaaa"
 aux wait_for_sync $vg $lv1
 
 # Rebuilding the raid1 master leg is fine.
 lvchange --yes --rebuild "$dev1" $vg/$lv1
-aux check_status_chars $vg $lv1 "aAAAAAAA"
+check raid_leg_status_is $vg $lv1 "aAAAAAAA"
 aux wait_for_sync $vg $lv1
 
 # Rebuild legs on devices 2, 4, 6 and 8 is fine.
 lvchange --yes --rebuild "$dev2" --rebuild "$dev4" --rebuild "$dev6" --rebuild "$dev8" $vg/$lv1
-aux check_status_chars $vg $lv1 "AaAaAaAa"
+check raid_leg_status_is $vg $lv1 "AaAaAaAa"
 aux wait_for_sync $vg $lv1
 
 ##############################################
@@ -101,28 +101,28 @@ aux wait_for_sync $vg $lv1
 # Rebuilding all raid6 stripes needs to be rejected.
 not lvchange --yes --rebuild "$dev1" --rebuild "$dev2" --rebuild "$dev3" \
 		   --rebuild "$dev4" --rebuild "$dev5" --rebuild "$dev6"  $vg/$lv1
-not aux check_status_chars $vg $lv1 "aaaaaa"
+not check raid_leg_status $vg $lv1 "aaaaaa"
 aux wait_for_sync $vg $lv1
 
 # Rebuilding more than 2 raid6 stripes needs to be rejected.
 not lvchange --yes --rebuild "$dev2" --rebuild "$dev4" --rebuild "$dev6" $vg/$lv1
-not aux check_status_chars $vg $lv1 "AaAaAa"
+not check raid_leg_status $vg $lv1 "AaAaAa"
 aux wait_for_sync $vg $lv1
 
 # Rebuilding any 1 raid6 stripe is fine.
 lvchange --yes --rebuild "$dev2" $vg/$lv1
-aux check_status_chars $vg $lv1 "AaAAAA"
+check raid_leg_status_is $vg $lv1 "AaAAAA"
 aux wait_for_sync $vg $lv1
 lvchange --yes --rebuild "$dev5"  $vg/$lv1
-aux check_status_chars $vg $lv1 "AAAAaA"
+check raid_leg_status_is $vg $lv1 "AAAAaA"
 aux wait_for_sync $vg $lv1
 
 # Rebuilding any 2 raid6 stripes is fine.
 lvchange --yes --rebuild "$dev2" --rebuild "$dev4" $vg/$lv1
-aux check_status_chars $vg $lv1 "AaAaAA"
+check raid_leg_status_is $vg $lv1 "AaAaAA"
 aux wait_for_sync $vg $lv1
 lvchange --yes --rebuild "$dev1" --rebuild "$dev5" $vg/$lv1
-aux check_status_chars $vg $lv1 "aAAAaA"
+check raid_leg_status_is $vg $lv1 "aAAAaA"
 aux wait_for_sync $vg $lv1
 
 vgremove -ff $vg
diff --git a/test/shell/lvcreate-large-raid.sh b/test/shell/lvcreate-large-raid.sh
index c2e9b7e..d8d077c 100644
--- a/test/shell/lvcreate-large-raid.sh
+++ b/test/shell/lvcreate-large-raid.sh
@@ -43,20 +43,20 @@ done
 # 200 TiB raid1
 lvcreate --type raid1 -m 1 -L 200T -n $lv1 $vg1 --nosync
 check lv_field $vg1/$lv1 size "200.00t"
-aux check_status_chars $vg1 $lv1 "AA"
+check raid_leg_status_is $vg1 $lv1 "AA"
 lvremove -ff $vg1
 
 # 1 PiB raid1
 lvcreate --type raid1 -m 1 -L 1P -n $lv1 $vg1 --nosync
 check lv_field $vg1/$lv1 size "1.00p"
-aux check_status_chars $vg1 $lv1 "AA"
+check raid_leg_status_is $vg1 $lv1 "AA"
 lvremove -ff $vg1
 
 # 750 TiB raid4/5
 for segtype in raid4 raid5; do
         lvcreate --type $segtype -i 3 -L 750T -n $lv1 $vg1 --nosync
         check lv_field $vg1/$lv1 size "750.00t"
-        aux check_status_chars $vg1 $lv1 "AAAA"
+        check raid_leg_status_is $vg1 $lv1 "AAAA"
         lvremove -ff $vg1
 done
 
@@ -65,10 +65,10 @@ done
 #
 lvcreate --type raid1 -m 1 -L 200T -n $lv1 $vg1 --nosync
 check lv_field $vg1/$lv1 size "200.00t"
-aux check_status_chars $vg1 $lv1 "AA"
+check raid_leg_status_is $vg1 $lv1 "AA"
 lvextend -L +200T $vg1/$lv1
 check lv_field $vg1/$lv1 size "400.00t"
-aux check_status_chars $vg1 $lv1 "AA"
+check raid_leg_status_is $vg1 $lv1 "AA"
 lvremove -ff $vg1
 
 
@@ -80,16 +80,16 @@ fi
 # 750 TiB raid6
 lvcreate --type raid6 -i 3 -L 750T -n $lv1 $vg1
 check lv_field $vg1/$lv1 size "750.00t"
-aux check_status_chars $vg1 $lv1 "aaaaa"
+check raid_leg_status_is $vg1 $lv1 "aaaaa"
 lvremove -ff $vg1
 
 # 1 PiB raid6, then extend up to 2 PiB
 lvcreate --type raid6 -i 3 -L 1P -n $lv1 $vg1
 check lv_field $vg1/$lv1 size "1.00p"
-aux check_status_chars $vg1 $lv1 "aaaaa"
+check raid_leg_status_is $vg1 $lv1 "aaaaa"
 lvextend -L +1P $vg1/$lv1
 check lv_field $vg1/$lv1 size "2.00p"
-aux check_status_chars $vg1 $lv1 "aaaaa"
+check raid_leg_status_is $vg1 $lv1 "aaaaa"
 lvremove -ff $vg1
 
 #
@@ -98,7 +98,7 @@ lvremove -ff $vg1
 lvcreate -aey -L 200T -n $lv1 $vg1
 lvconvert --type raid1 -m 1 $vg1/$lv1
 check lv_field $vg1/$lv1 size "200.00t"
-aux check_status_chars $vg1 $lv1 "aa"
+check raid_leg_status_is $vg1 $lv1 "aa"
 lvremove -ff $vg1
 
 # bz837927 END
diff --git a/test/shell/lvcreate-raid-nosync.sh b/test/shell/lvcreate-raid-nosync.sh
index 71eeefc..14ea8af 100644
--- a/test/shell/lvcreate-raid-nosync.sh
+++ b/test/shell/lvcreate-raid-nosync.sh
@@ -27,42 +27,42 @@ aux delay_dev "$dev1" 0 10 $(get first_extent_sector "$dev1")
 for r in raid0 raid0_meta
 do
 	lvcreate --yes --type raid0 -i 3 -l 1 -n $lv1 $vg
-	aux check_status_chars $vg $lv1 "AAA"
+	check raid_leg_status_is $vg $lv1 "AAA"
 	lvremove --yes $vg/$lv1
 done
 
 # raid1 supports resynchronization
 lvcreate --yes --type raid1 -m 2 -l 1 -n $lv1 $vg
-aux check_status_chars $vg $lv1 "aaa"
+check raid_leg_status_is $vg $lv1 "aaa"
 aux wait_for_sync $vg $lv1
-aux check_status_chars $vg $lv1 "AAA"
+check raid_leg_status_is $vg $lv1 "AAA"
 lvremove --yes $vg/$lv1
 
 # raid1 supports --nosync
 lvcreate --yes --type raid1 --nosync -m 2 -l 1 -n $lv1 $vg
-aux check_status_chars $vg $lv1 "AAA"
+check raid_leg_status_is $vg $lv1 "AAA"
 lvremove --yes $vg/$lv1
 
 for r in raid4 raid5
 do 
 	# raid4/5 support resynchronization
 	lvcreate --yes --type $r -i 3 -l 1 -n $lv1 $vg
-	aux check_status_chars $vg $lv1 "aaaa"
+	check raid_leg_status_is $vg $lv1 "aaaa"
 	aux wait_for_sync $vg $lv1
-	aux check_status_chars $vg $lv1 "AAAA"
+	check raid_leg_status_is $vg $lv1 "AAAA"
 	lvremove --yes $vg/$lv1
 
 	# raid4/5 support --nosync
 	lvcreate --yes --type $r --nosync -i 3 -l 1 -n $lv1 $vg
-	aux check_status_chars $vg $lv1 "AAAA"
+	check raid_leg_status_is $vg $lv1 "AAAA"
 	lvremove --yes $vg/$lv1
 done
 
 # raid6 supports resynchronization
 lvcreate --yes --type raid6 -i 3 -l 1 -n $lv1 $vg
-aux check_status_chars $vg $lv1 "aaaaa"
+check raid_leg_status_is $vg $lv1 "aaaaa"
 aux wait_for_sync $vg $lv1
-aux check_status_chars $vg $lv1 "AAAAA"
+check raid_leg_status_is $vg $lv1 "AAAAA"
 lvremove --yes $vg/$lv1
 
 # raid6 rejects --nosync; it has to initialize P- and Q-Syndromes
@@ -70,15 +70,15 @@ not lvcreate --yes --type raid6 --nosync -i 3 -l 1 -n $lv1 $vg
 
 # raid10 supports resynchronization
 lvcreate --yes --type raid10 -m 1 -i 3 -l 1 -n $lv1 $vg
-aux check_status_chars $vg $lv1 "aaaaaa"
+check raid_leg_status_is $vg $lv1 "aaaaaa"
 aux wait_for_sync $vg $lv1
-aux check_status_chars $vg $lv1 "AAAAAA"
+check raid_leg_status_is $vg $lv1 "AAAAAA"
 aux wait_for_sync $vg $lv1
 lvremove --yes $vg/$lv1
 
 # raid10 supports --nosync
 lvcreate --yes --type raid10 --nosync -m 1 -i 3 -l 1 -n $lv1 $vg
-aux check_status_chars $vg $lv1 "AAAAAA"
+check raid_leg_status_is $vg $lv1 "AAAAAA"
 aux wait_for_sync $vg $lv1
 lvremove --yes $vg/$lv1
 


