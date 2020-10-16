From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:11:15 +0000 (GMT)
Subject: stable-2.02 - tests: use delayzero_dev
Message-ID: <20201016191115.90597396E814@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8ad7c344cd06e14f40bd66a98315db68665cd79e
Commit:        8ad7c344cd06e14f40bd66a98315db68665cd79e
Parent:        5ac48c0655c9b0da6846dca30e1250f9a1f78f70
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 4 18:05:01 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 17:07:58 2020 +0200

tests: use delayzero_dev

Speed-up a bit the first synchronization with just 50ms write delay,
but later set also delay on read to slowdown lvextend.

FIXME: there are still things to look at:

0 229376 raid raid1 2 AA 229376/229376 idle 0 0
0 229376 raid raid1 2 AA 0/229376 frozen 0 0 -
0 262144 raid raid1 2 AA 229376/262144 repair 0 0 -
0 262144 raid raid1 2 AA 229376/262144 repair 0 0 -
0 262144 raid raid1 2 AA 245888/262144 repair 0 0 -
---
 test/shell/lvextend-raid.sh | 23 ++++++++++++++++++++---
 1 file changed, 20 insertions(+), 3 deletions(-)

diff --git a/test/shell/lvextend-raid.sh b/test/shell/lvextend-raid.sh
index 471097e45..04e9adf87 100644
--- a/test/shell/lvextend-raid.sh
+++ b/test/shell/lvextend-raid.sh
@@ -21,7 +21,7 @@ v1_15_0=0
 aux have_raid 1 15 0 && v1_15_0=1
 
 # Use smallest regionsize to save VG space
-regionsize=`getconf PAGESIZE` # in bytes
+regionsize=$(getconf PAGESIZE) # in bytes
 let pageregions=regionsize*8  # number of regions per MD bitmap page
 
 # in KiB
@@ -35,7 +35,14 @@ aux prepare_pvs 2 $(($lvsz + 3 * $lvext))
 get_devs
 vgcreate -s 4k $vg ${DEVICES[@]}
 
-aux delay_dev "$dev1"  0 150
+# Keep $dev1 & $dev2 always open via small active LVs.
+# This trick avoids race on system with scanning udev service
+# when device is 'in-use' and we cleared _rimage & _rmeta.
+lvcreate -l1 $vg "$dev1"
+lvcreate -l1 $vg "$dev2"
+
+sector=$(( $(get first_extent_sector "$dev2") + 2048 ))
+aux delayzero_dev "$dev2"  0 50 "${sector}:"
 
 # Create raid1 LV consuming 1 MD bitmap page
 lvcreate --yes --type raid1 --regionsize ${regionsize}K -L$(($lvsz-$lvext))M -n $lv1 $vg
@@ -45,10 +52,17 @@ aux wait_for_sync $vg $lv1
 check lv_field $vg/$lv1 sync_percent "100.00"
 check lv_field $vg/$lv1 region_size "4.00k"
 
+# to slow down extension - slowdown readings
+aux delayzero_dev "$dev1"  50 0 "${sector}:"
+
+dmsetup table
+dmsetup info -c
+dmsetup status
 # Extend so that full MD bitmap page is consumed
-lvextend -y -L+${lvext}M $vg/$lv1
+lvextend -vvvv -y -L+${lvext}M $vg/$lv1
 not check lv_field $vg/$lv1 sync_percent "100.00"
 check lv_field $vg/$lv1 size "$(($lvsz)).00m" $vg/$lv1
+lvs -a $vg
 aux wait_for_sync $vg $lv1
 check lv_field $vg/$lv1 sync_percent "100.00"
 
@@ -64,4 +78,7 @@ aux wait_for_sync $vg $lv1
 check lv_field $vg/$lv1 sync_percent "100.00"
 check lv_field $vg/$lv1 size "$(($lvsz+$lvext)).00m" $vg/$lv1
 
+aux enable_dev "$dev1"
+aux enable_dev "$dev2"
+
 vgremove -ff $vg


