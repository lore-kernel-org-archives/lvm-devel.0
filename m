From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 16 Sep 2020 12:14:56 +0000 (GMT)
Subject: master - tests: smaller delay and lowered version
Message-ID: <20200916121456.89773398640C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=52d3c4de6e989ee0bef3df65593e567051cc6cec
Commit:        52d3c4de6e989ee0bef3df65593e567051cc6cec
Parent:        49292bccc3ce15a729086cc34cbe8b8230948b3b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Sep 16 13:21:16 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 16 14:08:05 2020 +0200

tests: smaller delay and lowered version

See if this will still work. Some boxes are delayed too much.
Also try to check for raid extend progress from version 1.13.
---
 test/shell/lvextend-raid.sh | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/test/shell/lvextend-raid.sh b/test/shell/lvextend-raid.sh
index 054f436ba..e8bd7deea 100644
--- a/test/shell/lvextend-raid.sh
+++ b/test/shell/lvextend-raid.sh
@@ -16,8 +16,8 @@ SKIP_WITH_LVMPOLLD=1
 . lib/inittest
 
 aux have_raid 1 3 0 || skip
-v1_15_0=0
-aux have_raid 1 15 0 && v1_15_0=1
+PROGRESS=0
+aux have_raid 1 13 0 && PROGRESS=1
 
 # Use smallest regionsize to save VG space
 regionsize=$(getconf PAGESIZE) # in bytes
@@ -42,7 +42,7 @@ lvcreate -l1 $vg "$dev2"
 
 sector=$(( $(get first_extent_sector "$dev2") + 2048 ))
 aux zero_dev "$dev1" "${sector}:"
-aux delayzero_dev "$dev2"  0 30 "${sector}:"
+aux delayzero_dev "$dev2"  0 10 "${sector}:"
 
 # Create raid1 LV consuming 1 MD bitmap page
 lvcreate --yes --type raid1 --regionsize ${regionsize}K -L$(($lvsz-$lvext))M -n $lv1 $vg
@@ -56,12 +56,12 @@ check lv_field $vg/$lv1 sync_percent "100.00"
 check lv_field $vg/$lv1 region_size "4.00k"
 
 # to slow down extension - slowdown readings
-aux delayzero_dev "$dev1"  100 0 "${sector}:"
-aux delayzero_dev "$dev2"  0 100 "${sector}:"
+aux delayzero_dev "$dev1"  50 0 "${sector}:"
+aux delayzero_dev "$dev2"  0 50 "${sector}:"
 
 # Extend so that full MD bitmap page is consumed
 lvextend -y -L+${lvext}M $vg/$lv1
-if [ $v1_15_0 -eq 1 ]
+if [ $PROGRESS -eq 1 ]
 then
 not check lv_field $vg/$lv1 sync_percent "100.00"
 check lv_field $vg/$lv1 size "$(($lvsz)).00m" $vg/$lv1
@@ -71,7 +71,7 @@ check lv_field $vg/$lv1 sync_percent "100.00"
 
 # Extend so that another MD bitmap page is allocated
 lvextend -y -L+${lvext}M $vg/$lv1
-if [ $v1_15_0 -eq 1 ]
+if [ $PROGRESS -eq 1 ]
 then
 	not check lv_field $vg/$lv1 sync_percent "100.00"
 else


