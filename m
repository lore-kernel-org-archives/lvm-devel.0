From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 17 Feb 2014 21:26:44 +0000 (UTC)
Subject: master - tests: more clustered testing
Message-ID: <20140217212644.88B3C60520@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=18cac1654045a8eebc09ba418f2f8b4f6ebd9556
Commit:        18cac1654045a8eebc09ba418f2f8b4f6ebd9556
Parent:        37cf2019063aa34cddf88ae3e2ee0f974f97b105
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Feb 15 20:40:42 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 17 22:25:53 2014 +0100

tests: more clustered testing

---
 test/shell/pvmove-all-segtypes.sh |   25 +++++++++++++++----------
 1 files changed, 15 insertions(+), 10 deletions(-)

diff --git a/test/shell/pvmove-all-segtypes.sh b/test/shell/pvmove-all-segtypes.sh
index fcd8913..5e1c71c 100644
--- a/test/shell/pvmove-all-segtypes.sh
+++ b/test/shell/pvmove-all-segtypes.sh
@@ -13,12 +13,11 @@ test_description="ensure pvmove works with all common segment types"
 
 . lib/test
 
-test -e LOCAL_CLVMD && skip
 which mkfs.ext2 || skip
 which md5sum || skip
 
 aux prepare_pvs 5 20
-vgcreate -c n -s 256k $vg $(cat DEVICES)
+vgcreate -s 256k $vg $(cat DEVICES)
 
 # Each of the following tests does:
 # 1) Create two LVs - one linear and one other segment type
@@ -27,8 +26,8 @@ vgcreate -c n -s 256k $vg $(cat DEVICES)
 # 3) Move only the second LV by name
 
 # Testing pvmove of linear LV
-lvcreate -l 2 -n ${lv1}_foo $vg "$dev1"
-lvcreate -l 2 -n $lv1 $vg "$dev1"
+lvcreate -aey -l 2 -n ${lv1}_foo $vg "$dev1"
+lvcreate -aey -l 2 -n $lv1 $vg "$dev1"
 check lv_tree_on $vg ${lv1}_foo "$dev1"
 check lv_tree_on $vg $lv1 "$dev1"
 aux mkdev_md5sum $vg $lv1
@@ -43,8 +42,8 @@ check dev_md5sum $vg $lv1
 lvremove -ff $vg
 
 # Testing pvmove of stripe LV
-lvcreate -l 2 -n ${lv1}_foo $vg "$dev1"
-lvcreate -l 4 -i 2 -n $lv1 $vg "$dev1" "$dev2"
+lvcreate -aey -l 2 -n ${lv1}_foo $vg "$dev1"
+lvcreate -aey -l 4 -i 2 -n $lv1 $vg "$dev1" "$dev2"
 check lv_tree_on $vg ${lv1}_foo "$dev1"
 check lv_tree_on $vg $lv1 "$dev1" "$dev2"
 aux mkdev_md5sum $vg $lv1
@@ -58,9 +57,14 @@ check lv_tree_on $vg ${lv1}_foo "$dev5"
 check dev_md5sum $vg $lv1
 lvremove -ff $vg
 
+if test -e LOCAL_CLVMD ; then
+#FIXME these tests currently fail end require cmirrord
+echo "TEST WARNING, FIXME!!! pvmove in clustered VG not fully supported!"
+else
+
 # Testing pvmove of mirror LV
-lvcreate -l 2 -n ${lv1}_foo $vg "$dev1"
-lvcreate -l 2 --type mirror -m 1 -n $lv1 $vg "$dev1" "$dev2"
+lvcreate -aey -l 2 -n ${lv1}_foo $vg "$dev1"
+lvcreate -aey -l 2 --type mirror -m 1 -n $lv1 $vg "$dev1" "$dev2"
 check lv_tree_on $vg ${lv1}_foo "$dev1"
 check lv_tree_on $vg $lv1 "$dev1" "$dev2"
 aux mkdev_md5sum $vg $lv1
@@ -76,8 +80,8 @@ lvremove -ff $vg
 
 # Dummy LV and snap share dev1, while origin is on dev2
 # Testing pvmove of snapshot LV
-lvcreate -l 2 -n ${lv1}_foo $vg "$dev1"
-lvcreate -l 2 -n $lv1 $vg "$dev2"
+lvcreate -aey -l 2 -n ${lv1}_foo $vg "$dev1"
+lvcreate -aey -l 2 -n $lv1 $vg "$dev2"
 lvcreate -s $vg/$lv1 -l 2 -n snap "$dev1"
 check lv_tree_on $vg ${lv1}_foo "$dev1"
 check lv_tree_on $vg snap "$dev1"
@@ -91,3 +95,4 @@ check lv_tree_on $vg snap "$dev4"
 check lv_tree_on $vg ${lv1}_foo "$dev5"
 check dev_md5sum $vg snap
 lvremove -ff $vg
+fi


