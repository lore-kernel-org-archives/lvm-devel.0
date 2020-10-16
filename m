From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:11:39 +0000 (GMT)
Subject: stable-2.02 - tests: smaller delay and lowered version
Message-ID: <20201016191139.799E538618E8@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f9327d040c4a9b525117b40adea796a8072a25c7
Commit:        f9327d040c4a9b525117b40adea796a8072a25c7
Parent:        238da8ddd9c7dd9e9c9413564d67e8bd7055b4ec
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 16 13:33:28 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 17:07:59 2020 +0200

tests: smaller delay and lowered version

See if this will still work. Some boxes are delayed too much.
Also try to check for raid extend progress from version 1.13.
---
 test/shell/lvextend-raid.sh | 32 ++++++++++++++++++--------------
 1 file changed, 18 insertions(+), 14 deletions(-)

diff --git a/test/shell/lvextend-raid.sh b/test/shell/lvextend-raid.sh
index 04e9adf87..e8bd7deea 100644
--- a/test/shell/lvextend-raid.sh
+++ b/test/shell/lvextend-raid.sh
@@ -15,10 +15,9 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
-aux have_raid 1 7 0 || skip
-
-v1_15_0=0
-aux have_raid 1 15 0 && v1_15_0=1
+aux have_raid 1 3 0 || skip
+PROGRESS=0
+aux have_raid 1 13 0 && PROGRESS=1
 
 # Use smallest regionsize to save VG space
 regionsize=$(getconf PAGESIZE) # in bytes
@@ -42,10 +41,14 @@ lvcreate -l1 $vg "$dev1"
 lvcreate -l1 $vg "$dev2"
 
 sector=$(( $(get first_extent_sector "$dev2") + 2048 ))
-aux delayzero_dev "$dev2"  0 50 "${sector}:"
+aux zero_dev "$dev1" "${sector}:"
+aux delayzero_dev "$dev2"  0 10 "${sector}:"
 
 # Create raid1 LV consuming 1 MD bitmap page
 lvcreate --yes --type raid1 --regionsize ${regionsize}K -L$(($lvsz-$lvext))M -n $lv1 $vg
+
+lvs -a $vg
+
 not check lv_field $vg/$lv1 sync_percent "100.00"
 check lv_field $vg/$lv1 size "$(($lvsz-$lvext)).00m" $vg/$lv1
 aux wait_for_sync $vg $lv1
@@ -54,31 +57,32 @@ check lv_field $vg/$lv1 region_size "4.00k"
 
 # to slow down extension - slowdown readings
 aux delayzero_dev "$dev1"  50 0 "${sector}:"
+aux delayzero_dev "$dev2"  0 50 "${sector}:"
 
-dmsetup table
-dmsetup info -c
-dmsetup status
 # Extend so that full MD bitmap page is consumed
-lvextend -vvvv -y -L+${lvext}M $vg/$lv1
+lvextend -y -L+${lvext}M $vg/$lv1
+if [ $PROGRESS -eq 1 ]
+then
 not check lv_field $vg/$lv1 sync_percent "100.00"
 check lv_field $vg/$lv1 size "$(($lvsz)).00m" $vg/$lv1
-lvs -a $vg
+fi
 aux wait_for_sync $vg $lv1
 check lv_field $vg/$lv1 sync_percent "100.00"
 
 # Extend so that another MD bitmap page is allocated
 lvextend -y -L+${lvext}M $vg/$lv1
-if [ $v1_15_0 -eq 1 ]
+if [ $PROGRESS -eq 1 ]
 then
 	not check lv_field $vg/$lv1 sync_percent "100.00"
 else
 	check lv_field $vg/$lv1 sync_percent "100.00"
 fi
-aux wait_for_sync $vg $lv1
-check lv_field $vg/$lv1 sync_percent "100.00"
-check lv_field $vg/$lv1 size "$(($lvsz+$lvext)).00m" $vg/$lv1
 
 aux enable_dev "$dev1"
 aux enable_dev "$dev2"
 
+aux wait_for_sync $vg $lv1
+check lv_field $vg/$lv1 sync_percent "100.00"
+check lv_field $vg/$lv1 size "$(($lvsz+$lvext)).00m" $vg/$lv1
+
 vgremove -ff $vg


