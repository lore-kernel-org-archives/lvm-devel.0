From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 17 Jan 2018 08:47:10 -0500
Subject: master - tests: properly test with clustered VG
Message-ID: <201801171347.w0HDlAYb030090@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8c7ec44bf0fb23e2c5e426c5d07b02e3d25f5b59
Commit:        8c7ec44bf0fb23e2c5e426c5d07b02e3d25f5b59
Parent:        3aedaa7f2aa3c8622538e2758bf905ceb156db4a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jan 11 16:05:44 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jan 17 14:45:48 2018 +0100

tests: properly test with clustered VG

Testing in cluster makes sense only with clustered VG.
---
 test/shell/pvmove-basic.sh         |   10 +++++-----
 test/shell/pvmove-raid-segtypes.sh |   14 +++++++-------
 test/shell/pvmove-thin-segtypes.sh |   14 +++++++-------
 3 files changed, 19 insertions(+), 19 deletions(-)

diff --git a/test/shell/pvmove-basic.sh b/test/shell/pvmove-basic.sh
index 056274d..42f165b 100644
--- a/test/shell/pvmove-basic.sh
+++ b/test/shell/pvmove-basic.sh
@@ -26,15 +26,15 @@ which md5sum || skip
 # Utilities
 
 create_vg_() {
-	vgcreate -c n -s 128k "$vg" "${DEVICES[@]}"
+	vgcreate -s 128k "$vg" "${DEVICES[@]}"
 }
 
 # ---------------------------------------------------------------------
 # Common environment setup/cleanup for each sub testcases
 prepare_lvs_() {
-	lvcreate -l2 -n $lv1 $vg "$dev1"
+	lvcreate -aey -l2 -n $lv1 $vg "$dev1"
 	check lv_on $vg $lv1 "$dev1"
-	lvcreate -l9 -i3 -n $lv2 $vg "$dev2" "$dev3" "$dev4"
+	lvcreate -aey -l9 -i3 -n $lv2 $vg "$dev2" "$dev3" "$dev4"
 	check lv_on $vg $lv2 "$dev2" "$dev3" "$dev4"
 	lvextend -l+2 $vg/$lv1 "$dev2"
 	check lv_on $vg $lv1 "$dev1" "$dev2"
@@ -57,7 +57,7 @@ prepare_lvs_() {
 # original content should be preserved
 restore_lvs_() {
 	vgcfgrestore -f bak-$$ $vg
-	vgchange -ay $vg
+	vgchange -aey $vg
 }
 
 lvs_not_changed_() {
@@ -348,7 +348,7 @@ vgremove -ff $vg
 pvcreate "${DEVICES[@]}"
 pvcreate --metadatacopies 0 "$dev1" "$dev2"
 create_vg_
-lvcreate -l4 -n $lv1 $vg "$dev1"
+lvcreate -aey -l4 -n $lv1 $vg "$dev1"
 pvmove $mode "$dev1"
 
 #COMM "pvmove fails activating mirror, properly restores state before pvmove"
diff --git a/test/shell/pvmove-raid-segtypes.sh b/test/shell/pvmove-raid-segtypes.sh
index be41547..6584b74 100644
--- a/test/shell/pvmove-raid-segtypes.sh
+++ b/test/shell/pvmove-raid-segtypes.sh
@@ -22,7 +22,7 @@ aux have_raid 1 3 5 || skip
 aux prepare_pvs 5 20
 get_devs
 
-vgcreate -c n -s 128k "$vg" "${DEVICES[@]}"
+vgcreate -s 128k "$vg" "${DEVICES[@]}"
 
 for mode in "--atomic" ""
 do
@@ -33,8 +33,8 @@ do
 # 3) Move only the second LV by name
 
 # Testing pvmove of RAID1 LV
-lvcreate -l 2 -n ${lv1}_foo $vg "$dev1"
-lvcreate --regionsize 16K -l 2 --type raid1 -m 1 -n $lv1 $vg "$dev1" "$dev2"
+lvcreate -aey -l 2 -n ${lv1}_foo $vg "$dev1"
+lvcreate -aey --regionsize 16K -l 2 --type raid1 -m 1 -n $lv1 $vg "$dev1" "$dev2"
 check lv_tree_on $vg ${lv1}_foo "$dev1"
 check lv_tree_on $vg $lv1 "$dev1" "$dev2"
 aux mkdev_md5sum $vg $lv1
@@ -49,8 +49,8 @@ check dev_md5sum $vg $lv1
 lvremove -ff $vg
 
 # Testing pvmove of RAID10 LV
-lvcreate -l 2 -n ${lv1}_foo $vg "$dev1"
-lvcreate -l 4 --type raid10 -i 2 -m 1 -n $lv1 $vg \
+lvcreate -aey -l 2 -n ${lv1}_foo $vg "$dev1"
+lvcreate -aey -l 4 --type raid10 -i 2 -m 1 -n $lv1 $vg \
                 "$dev1" "$dev2" "$dev3" "$dev4"
 check lv_tree_on $vg ${lv1}_foo "$dev1"
 check lv_tree_on $vg $lv1 "$dev1" "$dev2" "$dev3" "$dev4"
@@ -75,8 +75,8 @@ check dev_md5sum $vg $lv1
 lvremove -ff $vg
 
 # Testing pvmove of RAID5 LV
-lvcreate -l 2 -n ${lv1}_foo $vg "$dev1"
-lvcreate -l 4 --type raid5 -i 2 -n $lv1 $vg \
+lvcreate -aey -l 2 -n ${lv1}_foo $vg "$dev1"
+lvcreate -aey -l 4 --type raid5 -i 2 -n $lv1 $vg \
                 "$dev1" "$dev2" "$dev3"
 check lv_tree_on $vg ${lv1}_foo "$dev1"
 check lv_tree_on $vg $lv1 "$dev1" "$dev2" "$dev3"
diff --git a/test/shell/pvmove-thin-segtypes.sh b/test/shell/pvmove-thin-segtypes.sh
index 01d98b4..08685c8 100644
--- a/test/shell/pvmove-thin-segtypes.sh
+++ b/test/shell/pvmove-thin-segtypes.sh
@@ -24,7 +24,7 @@ aux have_raid 1 3 5 || skip
 aux prepare_pvs 5 20
 get_devs
 
-vgcreate -c n -s 128k "$vg" "${DEVICES[@]}" 
+vgcreate -s 128k "$vg" "${DEVICES[@]}"
 
 for mode in "--atomic" ""
 do
@@ -37,8 +37,8 @@ do
 
 
 # Testing pvmove of thin LV
-lvcreate -l 2 -n ${lv1}_foo $vg "$dev1"
-lvcreate -T $vg/${lv1}_pool -l 4 -V 8 -n $lv1 "$dev1"
+lvcreate -aey -l 2 -n ${lv1}_foo $vg "$dev1"
+lvcreate -aey -T $vg/${lv1}_pool -l 4 -V 8 -n $lv1 "$dev1"
 check lv_tree_on $vg ${lv1}_foo "$dev1"
 check lv_tree_on $vg $lv1 "$dev1"
 aux mkdev_md5sum $vg $lv1
@@ -53,12 +53,12 @@ check dev_md5sum $vg $lv1
 lvremove -ff $vg
 
 # Testing pvmove of thin LV on RAID
-lvcreate -l 2 -n ${lv1}_foo $vg "$dev1"
-lvcreate --type raid1 -m 1 -l 4 -n ${lv1}_raid1_pool $vg "$dev1" "$dev2"
-lvcreate --type raid1 -m 1 -L 2 -n ${lv1}_raid1_meta $vg "$dev1" "$dev2"
+lvcreate -aey -l 2 -n ${lv1}_foo $vg "$dev1"
+lvcreate -aey --type raid1 -m 1 -l 4 -n ${lv1}_raid1_pool $vg "$dev1" "$dev2"
+lvcreate -aey --type raid1 -m 1 -L 2 -n ${lv1}_raid1_meta $vg "$dev1" "$dev2"
 lvconvert --yes --thinpool $vg/${lv1}_raid1_pool \
         --poolmetadata ${lv1}_raid1_meta
-lvcreate -T $vg/${lv1}_raid1_pool -V 8 -n $lv1
+lvcreate -aey -T $vg/${lv1}_raid1_pool -V 8 -n $lv1
 check lv_tree_on $vg ${lv1}_foo "$dev1"
 check lv_tree_on $vg $lv1 "$dev1" "$dev2"
 aux mkdev_md5sum $vg $lv1


