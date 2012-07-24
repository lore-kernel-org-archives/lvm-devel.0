From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Tue, 24 Jul 2012 19:22:08 +0000 (UTC)
Subject: master - TEST: Replace old sync test/wait functions with new library functions
Message-ID: <20120724192208.E14172304@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=407198e17dc805dd9ce0583c8b1dbade71572af6
Commit:        407198e17dc805dd9ce0583c8b1dbade71572af6
Parent:        753cb9204d24ceb4d9f8184ceb4c0262b9aacb42
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Tue Jul 24 14:20:30 2012 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Tue Jul 24 14:20:30 2012 -0500

TEST:  Replace old sync test/wait functions with new library functions

Generic sync test/wait functions have replaced the old mirror/raid functions.
---
 test/shell/lvconvert-mirror.sh |   10 ++----
 test/shell/lvconvert-raid.sh   |   74 ++++-----------------------------------
 test/shell/lvcreate-raid.sh    |   47 ++-----------------------
 3 files changed, 15 insertions(+), 116 deletions(-)

diff --git a/test/shell/lvconvert-mirror.sh b/test/shell/lvconvert-mirror.sh
index 3f572e5..4d587d9 100644
--- a/test/shell/lvconvert-mirror.sh
+++ b/test/shell/lvconvert-mirror.sh
@@ -11,10 +11,6 @@
 
 . lib/test
 
-wait_for_mirror_in_sync_() {
-	while test $(get lv_field $1 copy_percent) != "100.00"; do sleep 1; done
-}
-
 aux prepare_pvs 5 10
 # FIXME - test fails with extent size < 512k
 vgcreate -c n -s 512k $vg $(cat DEVICES)
@@ -93,7 +89,7 @@ should not lvconvert -m-1 $vg/$lv1 "$dev1"
 lvconvert $vg/$lv1 # wait
 lvconvert -m2 $vg/$lv1 "$dev1" "$dev2" "$dev4" "$dev3:0" # If the above "should" failed...
 
-wait_for_mirror_in_sync_ $vg/$lv1
+aux wait_for_sync $vg $lv1
 lvconvert -m-1 $vg/$lv1 "$dev1"
 check mirror_images_on $lv1 "$dev2" "$dev4"
 lvconvert -m-1 $vg/$lv1 "$dev2"
@@ -215,7 +211,7 @@ lvremove -ff $vg
 
 # "rhbz440405: lvconvert -m0 incorrectly fails if all PEs allocated"
 lvcreate -l`pvs --noheadings -ope_count "$dev1"` -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:0"
-wait_for_mirror_in_sync_ $vg/$lv1
+aux wait_for_sync $vg $lv1
 lvconvert -m0 $vg/$lv1 "$dev1"
 check linear $vg $lv1
 lvremove -ff $vg
@@ -237,7 +233,7 @@ lvremove -ff $vg
 
 # BZ 463272: disk log mirror convert option is lost if downconvert option is also given
 lvcreate -l1 -m2 --corelog -n $lv1 $vg "$dev1" "$dev2" "$dev3"
-wait_for_mirror_in_sync_ $vg/$lv1
+aux wait_for_sync $vg $lv1
 lvconvert -m1 --mirrorlog disk $vg/$lv1
 check mirror $vg $lv1
 not check mirror $vg $lv1 core
diff --git a/test/shell/lvconvert-raid.sh b/test/shell/lvconvert-raid.sh
index a4ebac9..c63c141 100644
--- a/test/shell/lvconvert-raid.sh
+++ b/test/shell/lvconvert-raid.sh
@@ -11,65 +11,6 @@
 
 . lib/test
 
-# is_in_sync <VG/LV>
-is_in_sync_() {
-	local a
-	local b
-	local idx
-	local dm_name=$(echo $1 | sed s:-:--: | sed s:/:-:)
-
-	if ! a=(`dmsetup status $dm_name`); then
-		echo "Unable to get sync status of $1"
-		return 1
-	elif [ ${a[2]} = "snapshot-origin" ]; then
-		if ! a=(`dmsetup status ${dm_name}-real`); then
-			echo "Unable to get sync status of $1"
-			return 1
-		fi
-	fi
-
-	# 6th argument is the sync ratio for RAID and mirror
-	if [ ${a[2]} = "raid" ]; then
-		# Last argument is the sync ratio for RAID
-		idx=$((${#a[@]} - 1))
-	elif [ ${a[2]} = "mirror" ]; then
-		# 4th Arg tells us how far to the sync ratio
-		idx=$((${a[3]} + 4))
-	else
-		echo "Unable to get sync ratio for target type '${a[2]}'"
-		return 1
-	fi
-	b=( $(echo ${a[$idx]} | sed s:/:' ':) )
-
-	if [ ${b[0]} != ${b[1]} ]; then
-		echo "$dm_name (${a[3]}) is not in-sync"
-		return 1
-	fi
-
-	if [[ ${a[$(($idx - 1))]} =~ a ]]; then
-		echo "$dm_name in-sync, but 'a' characters in health status"
-		return 1
-	fi
-
-	if [ ${a[2]} = "raid" ]; then
-		echo "$dm_name (${a[3]}) is in-sync"
-	else
-		echo "$dm_name (${a[2]}) is in-sync"
-	fi
-}
-
-# wait_for_sync <VG/LV>
-wait_for_sync_() {
-	local i
-	for i in {1..100} ; do
-		is_in_sync_ $1 && return
-		sleep 1
-	done
-
-	echo "Sync is taking too long - assume stuck"
-	return 1
-}
-
 ########################################################
 # MAIN
 ########################################################
@@ -108,7 +49,7 @@ for i in 1 2 3 4; do
 			lvcreate -l 2 -n $lv1 $vg
 		else
 			lvcreate --type raid1 -m $(($i - 1)) -l 2 -n $lv1 $vg
-			wait_for_sync_ $vg/$lv1
+			aux wait_for_sync $vg $lv1
 		fi
 
 		if $under_snap; then
@@ -129,7 +70,7 @@ done
 
 # 3-way to 2-way convert while specifying devices
 lvcreate --type raid1 -m 2 -l 2 -n $lv1 $vg $dev1 $dev2 $dev3
-wait_for_sync_ $vg/$lv1
+aux wait_for_sync $vg $lv1
 lvconvert -m1 $vg/$lv1 $dev2
 lvremove -ff $vg
 
@@ -142,7 +83,7 @@ lvremove -ff $vg
 ###########################################
 # 3-way to 2-way/linear
 lvcreate --type raid1 -m 2 -l 2 -n $lv1 $vg
-wait_for_sync_ $vg/$lv1
+aux wait_for_sync $vg $lv1
 lvconvert --splitmirrors 1 -n $lv2 $vg/$lv1
 check lv_exists $vg $lv1
 check linear $vg $lv2
@@ -151,7 +92,7 @@ lvremove -ff $vg
 
 # 2-way to linear/linear
 lvcreate --type raid1 -m 1 -l 2 -n $lv1 $vg
-wait_for_sync_ $vg/$lv1
+aux wait_for_sync $vg $lv1
 lvconvert --splitmirrors 1 -n $lv2 $vg/$lv1
 check linear $vg $lv1
 check linear $vg $lv2
@@ -160,8 +101,9 @@ lvremove -ff $vg
 
 # 3-way to linear/2-way
 lvcreate --type raid1 -m 2 -l 2 -n $lv1 $vg
-wait_for_sync_ $vg/$lv1
+aux wait_for_sync $vg $lv1
 # FIXME: Can't split off a RAID1 from a RAID1 yet
+# 'should' results in "warnings"
 should lvconvert --splitmirrors 2 -n $lv2 $vg/$lv1
 #check linear $vg $lv1
 #check lv_exists $vg $lv2
@@ -173,7 +115,7 @@ lvremove -ff $vg
 ###########################################
 # 3-way to 2-way/linear
 lvcreate --type raid1 -m 2 -l 2 -n $lv1 $vg
-wait_for_sync_ $vg/$lv1
+aux wait_for_sync $vg $lv1
 lvconvert --splitmirrors 1 --trackchanges $vg/$lv1
 check lv_exists $vg $lv1
 check linear $vg ${lv1}_rimage_2
@@ -186,7 +128,7 @@ lvremove -ff $vg
 ###########################################
 for i in 1 2 3 ; do
 	lvcreate --type mirror -m $i -l 2 -n $lv1 $vg
-	wait_for_sync_ $vg/$lv1
+	aux wait_for_sync $vg $lv1
 	lvconvert --type raid1 $vg/$lv1
 	lvremove -ff $vg
 done
diff --git a/test/shell/lvcreate-raid.sh b/test/shell/lvcreate-raid.sh
index b6792c5..c26f694 100644
--- a/test/shell/lvcreate-raid.sh
+++ b/test/shell/lvcreate-raid.sh
@@ -11,45 +11,6 @@
 
 . lib/test
 
-# is_raid_in_sync <VG/LV>
-function is_raid_in_sync()
-{
-	local dm_name=$(echo $1 | sed s:-:--: | sed s:/:-:)
-	local a
-	local b
-	local idx
-
-	if ! a=(`dmsetup status $dm_name`); then
-		echo "Unable to get sync status of $1"
-		exit 1
-	fi
-	idx=$((${#a[@]} - 1))
-	b=(`echo ${a[$idx]} | sed s:/:' ':`)
-
-	if [ ${b[0]} != ${b[1]} ]; then
-		echo "$dm_name (${a[3]}) is not in-sync"
-		return 1
-	fi
-
-	echo "$dm_name (${a[3]}) is in-sync"
-	return 0
-}
-
-# wait_for_raid_sync <VG/LV>
-function wait_for_raid_sync()
-{
-	local i=0
-
-	while ! is_raid_in_sync $1; do
-		sleep 1
-		i=$(($i + 1))
-		if [ $i -gt 500 ]; then
-			echo "Sync is taking too long - assume stuck"
-			exit 1
-		fi
-	done
-}
-
 ########################################################
 # MAIN
 ########################################################
@@ -64,17 +25,17 @@ vgcreate -c n -s 512k $vg $(cat DEVICES)
 
 # Create RAID1 (implicit 2-way)
 lvcreate --type raid1 -l 2 -n $lv1 $vg
-wait_for_raid_sync $vg/$lv1
+aux wait_for_sync $vg $lv1
 lvremove -ff $vg
 
 # Create RAID1 (explicit 2-way)
 lvcreate --type raid1 -m 1 -l 2 -n $lv1 $vg
-wait_for_raid_sync $vg/$lv1
+aux wait_for_sync $vg $lv1
 lvremove -ff $vg
 
 # Create RAID1 (explicit 3-way)
 lvcreate --type raid1 -m 2 -l 2 -n $lv1 $vg
-wait_for_raid_sync $vg/$lv1
+aux wait_for_sync $vg $lv1
 lvremove -ff $vg
 
 # Create RAID 4/5/6 (explicit 3-stripe + parity devs)
@@ -83,7 +44,7 @@ for i in raid4 \
 	raid6 raid6_zr raid6_nr raid6_nc; do
 
 	lvcreate --type $i -l 3 -i 3 -n $lv1 $vg
-	wait_for_raid_sync $vg/$lv1
+	aux wait_for_sync $vg $lv1
 	lvremove -ff $vg
 done
 


