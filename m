From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 17 Jan 2018 08:47:13 -0500
Subject: master - tests: check pvmove is merging segments
Message-ID: <201801171347.w0HDlDlX030104@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e16d309d5651d1697f5246855ae816302cd8516f
Commit:        e16d309d5651d1697f5246855ae816302cd8516f
Parent:        5baf2de8986ceeb353c39ccf0503f9fefcb6eb92
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 1 11:58:38 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jan 17 14:45:48 2018 +0100

tests: check pvmove is merging segments

pvmove was imporoved to properly merge consqutive segments after pvmove
so check it's working.
---
 test/shell/pvmove-all-segtypes.sh |   20 +++++++++++++++-----
 1 files changed, 15 insertions(+), 5 deletions(-)

diff --git a/test/shell/pvmove-all-segtypes.sh b/test/shell/pvmove-all-segtypes.sh
index e10586e..f672290 100644
--- a/test/shell/pvmove-all-segtypes.sh
+++ b/test/shell/pvmove-all-segtypes.sh
@@ -29,12 +29,22 @@ aux prepare_vg 5 20
 # Testing pvmove of linear LV
 lvcreate -aey -l 2 -n ${lv1}_foo $vg "$dev1"
 lvcreate -aey -l 2 -n $lv1 $vg "$dev1"
-check lv_tree_on $vg ${lv1}_foo "$dev1"
-check lv_tree_on $vg $lv1 "$dev1"
+lvextend -l+2 $vg/${lv1}_foo "$dev1"
+lvextend -l+2 $vg/${lv1} "$dev1"
+lvextend -l+2 $vg/${lv1}_foo "$dev2"
+lvextend -l+2 $vg/${lv1} "$dev3"
+check lv_tree_on $vg ${lv1}_foo "$dev1" "$dev2"
+check lv_tree_on $vg $lv1 "$dev1" "$dev3"
+check lv_field $vg/${lv1}_foo seg_count 3
+check lv_field $vg/$lv1 seg_count 3
 aux mkdev_md5sum $vg $lv1
-pvmove "$dev1" "$dev5"
-check lv_tree_on $vg ${lv1}_foo "$dev5"
-check lv_tree_on $vg $lv1 "$dev5"
+dmsetup table
+pvmove --atomic "$dev1" "$dev5"
+check lv_tree_on $vg ${lv1}_foo "$dev2" "$dev5"
+check lv_tree_on $vg $lv1 "$dev3" "$dev5"
+# Also check 2 segments from $dev1 were merged on $dev5
+check lv_field $vg/${lv1}_foo seg_count 2
+check lv_field $vg/$lv1 seg_count 2
 check dev_md5sum $vg $lv1
 pvmove -n $lv1 "$dev5" "$dev4"
 check lv_tree_on $vg $lv1 "$dev4"


