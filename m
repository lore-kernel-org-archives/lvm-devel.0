From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 10 Jul 2017 08:37:32 -0400
Subject: master - tests: fix array usage
Message-ID: <201707101237.v6ACbW49023408@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f818a83a1dea3d67ad4bc710ed0552a7175b38d7
Commit:        f818a83a1dea3d67ad4bc710ed0552a7175b38d7
Parent:        85e5a8803cee25aa676d30b478e9a3bd02c7d9ca
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Jul 8 22:29:50 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 10 14:23:53 2017 +0200

tests: fix array usage

Use bash arrays to pass devs.
---
 test/shell/lvchange-raid-transient-failures.sh |    6 +++---
 test/shell/lvconvert-raid.sh                   |   15 ++++++++-------
 2 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/test/shell/lvchange-raid-transient-failures.sh b/test/shell/lvchange-raid-transient-failures.sh
index a478204..2ac14b0 100644
--- a/test/shell/lvchange-raid-transient-failures.sh
+++ b/test/shell/lvchange-raid-transient-failures.sh
@@ -32,14 +32,14 @@ function _check_raid
 	shift
 	local good=$1
 	shift
-	local devs=$*
+	local devs=( "$@" )
 
 	aux wait_for_sync $vg $lv
-	aux disable_dev --error --silent "$devs"
+	aux disable_dev --error --silent "${devs[@]}"
 	mkfs.ext4 "$DM_DEV_DIR/$vg/$lv"
 	fsck.ext4 -fn "$DM_DEV_DIR/$vg/$lv"
 	check raid_leg_status $vg $lv "$fail"
-	aux enable_dev --silent "$devs"
+	aux enable_dev --silent "${devs[@]}"
 	lvs -a -o +devices $vg | tee out
 	not grep unknown out
 	lvchange --refresh $vg/$lv
diff --git a/test/shell/lvconvert-raid.sh b/test/shell/lvconvert-raid.sh
index b4ba4c9..c5e6159 100644
--- a/test/shell/lvconvert-raid.sh
+++ b/test/shell/lvconvert-raid.sh
@@ -21,10 +21,10 @@ export LVM_TEST_LVMETAD_DEBUG_OPTS=${LVM_TEST_LVMETAD_DEBUG_OPTS-}
 
 get_image_pvs() {
 	local d
-	local images
+	local images=()
 
-	images=$(dmsetup ls | grep "${1}-${2}_.image_.*" | cut -f1 | sed -e s:-:/:)
-	lvs --noheadings -a -o devices "$images" | sed s/\(.\)//
+	images=( $(dmsetup ls | grep "${1}-${2}_.image_.*" | cut -f1 | sed -e s:-:/:) )
+	lvs --noheadings -a -o devices "${images[@]}" | sed s/\(.\)//
 }
 
 ########################################################
@@ -296,21 +296,22 @@ for i in {1..3}; do
 
 	for j in $(seq $(( i + 1 ))); do # The number of devs to replace at once
 	for o in $(seq 0 $i); do        # The offset into the device list
-		replace=""
+		replace=()
 
 		devices=( $(get_image_pvs $vg $lv1) )
 
 		for k in $(seq "$j"); do
 			index=$(( ( k +  o ) % ( i + 1 ) ))
-			replace="$replace --replace ${devices[$index]}"
+			replace+=( "--replace" )
+			replace+=( "${devices[$index]}" )
 		done
 		aux wait_for_sync $vg $lv1
 
 		if [ "$j" -ge $(( i + 1 )) ]; then
 			# Can't replace all at once.
-			not lvconvert "$replace" $vg/$lv1
+			not lvconvert "${replace[@]}" $vg/$lv1
 		else
-			lvconvert "$replace" $vg/$lv1
+			lvconvert "${replace[@]}" $vg/$lv1
 		fi
 	done
 	done


