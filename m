From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  8 Sep 2020 22:03:46 +0000 (GMT)
Subject: master - tests: tune extend test
Message-ID: <20200908220346.2B3DD385702B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bb62af5b3db82e6558afd564acd3bcc0f2b94b50
Commit:        bb62af5b3db82e6558afd564acd3bcc0f2b94b50
Parent:        676ce4775464dbc2efbcfe09951c55991dc5be3d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 8 00:22:16 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 8 21:23:03 2020 +0200

tests: tune extend test

For proper checking of extension progress require version 1.15

It looks with older versoin extension happens during very slow
resume within lvm command - although speed is still somewhat slow
with latest version.
---
 test/shell/lvextend-raid.sh | 25 +++++++++++++++----------
 1 file changed, 15 insertions(+), 10 deletions(-)

diff --git a/test/shell/lvextend-raid.sh b/test/shell/lvextend-raid.sh
index abd4cc508..054f436ba 100644
--- a/test/shell/lvextend-raid.sh
+++ b/test/shell/lvextend-raid.sh
@@ -41,10 +41,14 @@ lvcreate -l1 $vg "$dev1"
 lvcreate -l1 $vg "$dev2"
 
 sector=$(( $(get first_extent_sector "$dev2") + 2048 ))
-aux delayzero_dev "$dev2"  0 50 "${sector}:"
+aux zero_dev "$dev1" "${sector}:"
+aux delayzero_dev "$dev2"  0 30 "${sector}:"
 
 # Create raid1 LV consuming 1 MD bitmap page
 lvcreate --yes --type raid1 --regionsize ${regionsize}K -L$(($lvsz-$lvext))M -n $lv1 $vg
+
+lvs -a $vg
+
 not check lv_field $vg/$lv1 sync_percent "100.00"
 check lv_field $vg/$lv1 size "$(($lvsz-$lvext)).00m" $vg/$lv1
 aux wait_for_sync $vg $lv1
@@ -52,16 +56,16 @@ check lv_field $vg/$lv1 sync_percent "100.00"
 check lv_field $vg/$lv1 region_size "4.00k"
 
 # to slow down extension - slowdown readings
-aux delayzero_dev "$dev1"  50 0 "${sector}:"
+aux delayzero_dev "$dev1"  100 0 "${sector}:"
+aux delayzero_dev "$dev2"  0 100 "${sector}:"
 
-dmsetup table
-dmsetup info -c
-dmsetup status
 # Extend so that full MD bitmap page is consumed
-lvextend -vvvv -y -L+${lvext}M $vg/$lv1
+lvextend -y -L+${lvext}M $vg/$lv1
+if [ $v1_15_0 -eq 1 ]
+then
 not check lv_field $vg/$lv1 sync_percent "100.00"
 check lv_field $vg/$lv1 size "$(($lvsz)).00m" $vg/$lv1
-lvs -a $vg
+fi
 aux wait_for_sync $vg $lv1
 check lv_field $vg/$lv1 sync_percent "100.00"
 
@@ -73,11 +77,12 @@ then
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


