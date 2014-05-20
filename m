From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 20 May 2014 20:53:16 +0000 (UTC)
Subject: master - tests: lvconvert needs --yes
Message-ID: <20140520205316.A5163601FB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f919a255b7875db0049eb71e10a2638842541415
Commit:        f919a255b7875db0049eb71e10a2638842541415
Parent:        e538354e281c7b00667b3385878b4c32693359b5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue May 20 22:50:33 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue May 20 22:50:33 2014 +0200

tests: lvconvert needs --yes

---
 test/shell/pvmove-cache-segtypes.sh |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/test/shell/pvmove-cache-segtypes.sh b/test/shell/pvmove-cache-segtypes.sh
index db3bde5..c9f2078 100644
--- a/test/shell/pvmove-cache-segtypes.sh
+++ b/test/shell/pvmove-cache-segtypes.sh
@@ -110,7 +110,7 @@ lvremove -ff $vg
 lvcreate -l 2 -n ${lv1}_foo $vg "$dev1"
 lvcreate --type raid1 -L 2M -n meta $vg "$dev1" "$dev2"
 lvcreate --type raid1 -L 4M -n ${lv1}_pool $vg "$dev1" "$dev2"
-lvconvert --type cache-pool $vg/${lv1}_pool --poolmetadata $vg/meta
+lvconvert --yes --type cache-pool $vg/${lv1}_pool --poolmetadata $vg/meta
 lvcreate --type cache -n $lv1 -L 8M $vg/${lv1}_pool "$dev5"
 
 check lv_tree_on $vg ${lv1}_foo "$dev1"
@@ -142,7 +142,7 @@ lvcreate -l 2 -n ${lv1}_foo $vg "$dev1"
 # RAID for cachepool
 lvcreate --type raid1 -m 1 -L 2M -n meta $vg "$dev1" "$dev2"
 lvcreate --type raid1 -m 1 -L 4M -n cachepool $vg "$dev1" "$dev2"
-lvconvert --type cache-pool $vg/cachepool --poolmetadata $vg/meta
+lvconvert --yes --type cache-pool $vg/cachepool --poolmetadata $vg/meta
 # RAID for thin pool data LV
 lvcreate --type raid1 -m 1 -L 8 -n thinpool $vg "$dev3" "$dev4"
 # Convert thin pool data to a cached LV
@@ -150,7 +150,7 @@ lvconvert --type cache $vg/thinpool --cachepool $vg/cachepool
 # Create simple thin pool meta
 lvcreate -L 2M -n meta $vg "$dev1"
 # Use thin pool data LV to build a thin pool
-lvconvert --thinpool $vg/thinpool --poolmetadata $vg/meta
+lvconvert --yes --thinpool $vg/thinpool --poolmetadata $vg/meta
 # Create a thin lv for fun
 lvcreate -T $vg/thinpool -V 20 -n thin_lv
 
@@ -174,4 +174,4 @@ check lv_tree_on $vg thinpool "$dev3" "$dev4" "$dev5" # Move non-cache tmeta
 #check lv_tree_on $vg $vg/thinpool "$dev3" "$dev4"
 #check dev_md5sum $vg/thin_lv
 
-lvremove -ff $vg
\ No newline at end of file
+lvremove -ff $vg


