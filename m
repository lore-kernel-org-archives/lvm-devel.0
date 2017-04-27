From: Alasdair Kergon <agk@sourceware.org>
Date: Wed, 26 Apr 2017 21:58:48 -0400
Subject: master - test: Add -y to pvresize --setphysicalvolumesize
Message-ID: <201704270158.v3R1wmvP005598@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=813bcb24f0cfd664e539d4508ab3586c9b927ab3
Commit:        813bcb24f0cfd664e539d4508ab3586c9b927ab3
Parent:        cbc69f8c693edf0d1307c9447e2e66d07a04bfe9
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Apr 27 02:57:59 2017 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Apr 27 02:57:59 2017 +0100

test: Add -y to pvresize --setphysicalvolumesize

---
 test/shell/covercmd.sh                   |    6 +-
 test/shell/process-each-duplicate-pvs.sh |    4 +-
 test/shell/process-each-pvresize.sh      |  138 +++++++++++++++---------------
 test/shell/pvresize-mdas.sh              |    2 +-
 4 files changed, 75 insertions(+), 75 deletions(-)

diff --git a/test/shell/covercmd.sh b/test/shell/covercmd.sh
index 69ff8d6..00b1781 100644
--- a/test/shell/covercmd.sh
+++ b/test/shell/covercmd.sh
@@ -58,10 +58,10 @@ vgremove -f $vg
 # missing params
 not pvresize
 # negative size
-not pvresize --setphysicalvolumesize -10M "$dev1"
+not pvresize --setphysicalvolumesize -10M -y "$dev1"
 # not existing device
-not pvresize --setphysicalvolumesize 10M "$dev7"
-pvresize --setphysicalvolumesize 10M "$dev1"
+not pvresize --setphysicalvolumesize 10M -y "$dev7"
+pvresize --setphysicalvolumesize 10M -y "$dev1"
 pvresize "$dev1"
 
 
diff --git a/test/shell/process-each-duplicate-pvs.sh b/test/shell/process-each-duplicate-pvs.sh
index 9ab98dc..270fc52 100644
--- a/test/shell/process-each-duplicate-pvs.sh
+++ b/test/shell/process-each-duplicate-pvs.sh
@@ -26,7 +26,7 @@ pvcreate "$dev1"
 pvcreate "$dev2"
 vgcreate $vg1 "$dev1"
 vgcreate $vg2 "$dev2"
-pvresize --setphysicalvolumesize 8m "$dev2"
+pvresize --setphysicalvolumesize 8m -y "$dev2"
 lvcreate -an -l1 -n $lv1 $vg1
 
 # Both devs are shown and used by the VG
@@ -275,7 +275,7 @@ pvremove -ff -y "$dev2"
 
 pvcreate "$dev3"
 pvcreate "$dev4"
-pvresize --setphysicalvolumesize 8m "$dev4"
+pvresize --setphysicalvolumesize 8m -y "$dev4"
 
 UUID3=$(pvs --noheadings -o uuid $dev3 | xargs)
 UUID4=$(pvs --noheadings -o uuid $dev4 | xargs)
diff --git a/test/shell/process-each-pvresize.sh b/test/shell/process-each-pvresize.sh
index 86c2a7d..e1e4af3 100644
--- a/test/shell/process-each-pvresize.sh
+++ b/test/shell/process-each-pvresize.sh
@@ -78,7 +78,7 @@ old_reduced="28.00m"
 new_request="20.00m"
 new_reduced="16.00m"
 
-pvresize --setphysicalvolumesize $old_request "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
+pvresize --setphysicalvolumesize $old_request -y "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
 check pv_field "$dev10" pv_size $old_reduced
 check pv_field "$dev2" pv_size $old_reduced
 check pv_field "$dev3" pv_size $old_reduced
@@ -90,7 +90,7 @@ check pv_field "$dev8" pv_size $old_reduced
 check pv_field "$dev9" pv_size $old_reduced
 
 # one pv
-pvresize --setphysicalvolumesize $new_request "$dev10"
+pvresize --setphysicalvolumesize $new_request -y "$dev10"
 check pv_field "$dev10" pv_size $new_reduced
 # unchanged
 check pv_field "$dev2" pv_size $old_reduced
@@ -102,10 +102,10 @@ check pv_field "$dev7" pv_size $old_reduced
 check pv_field "$dev8" pv_size $old_reduced
 check pv_field "$dev9" pv_size $old_reduced
 # reset back to old size
-pvresize --setphysicalvolumesize $old_request "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
+pvresize --setphysicalvolumesize $old_request -y "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
 
 # two pvs in separate vgs
-pvresize --setphysicalvolumesize $new_request "$dev2" "$dev6"
+pvresize --setphysicalvolumesize $new_request -y "$dev2" "$dev6"
 check pv_field "$dev2" pv_size $new_reduced
 check pv_field "$dev6" pv_size $new_reduced
 # unchanged
@@ -117,10 +117,10 @@ check pv_field "$dev7" pv_size $old_reduced
 check pv_field "$dev8" pv_size $old_reduced
 check pv_field "$dev9" pv_size $old_reduced
 # reset back to old size
-pvresize --setphysicalvolumesize $old_request "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
+pvresize --setphysicalvolumesize $old_request -y "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
 
 # one tag on one pv
-pvresize --setphysicalvolumesize $new_request @V2D4
+pvresize --setphysicalvolumesize $new_request -y @V2D4
 check pv_field "$dev4" pv_size $new_reduced
 # unchanged
 check pv_field "$dev10" pv_size $old_reduced
@@ -132,10 +132,10 @@ check pv_field "$dev7" pv_size $old_reduced
 check pv_field "$dev8" pv_size $old_reduced
 check pv_field "$dev9" pv_size $old_reduced
 # reset back to old size
-pvresize --setphysicalvolumesize $old_request "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
+pvresize --setphysicalvolumesize $old_request -y "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
 
 # one tag on all pvs in one vg
-pvresize --setphysicalvolumesize $new_request @V3
+pvresize --setphysicalvolumesize $new_request -y @V3
 check pv_field "$dev6" pv_size $new_reduced
 check pv_field "$dev7" pv_size $new_reduced
 check pv_field "$dev8" pv_size $new_reduced
@@ -147,10 +147,10 @@ check pv_field "$dev3" pv_size $old_reduced
 check pv_field "$dev4" pv_size $old_reduced
 check pv_field "$dev5" pv_size $old_reduced
 # reset back to old size
-pvresize --setphysicalvolumesize $old_request "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
+pvresize --setphysicalvolumesize $old_request -y "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
 
 # one tag on some pvs in one vg
-pvresize --setphysicalvolumesize $new_request @V2D45
+pvresize --setphysicalvolumesize $new_request -y @V2D45
 check pv_field "$dev4" pv_size $new_reduced
 check pv_field "$dev5" pv_size $new_reduced
 # unchanged
@@ -162,11 +162,11 @@ check pv_field "$dev7" pv_size $old_reduced
 check pv_field "$dev8" pv_size $old_reduced
 check pv_field "$dev9" pv_size $old_reduced
 # reset back to old size
-pvresize --setphysicalvolumesize $old_request "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
+pvresize --setphysicalvolumesize $old_request -y "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
 
 # one tag on multiple pvs in separate vgs
 pvchange --addtag V12 "$dev10" "$dev2" "$dev3" "$dev4" "$dev5"
-pvresize --setphysicalvolumesize $new_request @V12
+pvresize --setphysicalvolumesize $new_request -y @V12
 check pv_field "$dev10" pv_size $new_reduced
 check pv_field "$dev2" pv_size $new_reduced
 check pv_field "$dev3" pv_size $new_reduced
@@ -178,10 +178,10 @@ check pv_field "$dev7" pv_size $old_reduced
 check pv_field "$dev8" pv_size $old_reduced
 check pv_field "$dev9" pv_size $old_reduced
 # reset back to old size
-pvresize --setphysicalvolumesize $old_request "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
+pvresize --setphysicalvolumesize $old_request -y "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
 
 # one pv and one tag on different pv
-pvresize --setphysicalvolumesize $new_request "$dev10" @V3D9
+pvresize --setphysicalvolumesize $new_request -y "$dev10" @V3D9
 check pv_field "$dev10" pv_size $new_reduced
 check pv_field "$dev9" pv_size $new_reduced
 # unchanged
@@ -193,10 +193,10 @@ check pv_field "$dev6" pv_size $old_reduced
 check pv_field "$dev7" pv_size $old_reduced
 check pv_field "$dev8" pv_size $old_reduced
 # reset back to old size
-pvresize --setphysicalvolumesize $old_request "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
+pvresize --setphysicalvolumesize $old_request -y "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
 
 # redundant pv and tag
-pvresize --setphysicalvolumesize $new_request "$dev9" @V3D9
+pvresize --setphysicalvolumesize $new_request -y "$dev9" @V3D9
 check pv_field "$dev9" pv_size $new_reduced
 # unchanged
 check pv_field "$dev10" pv_size $old_reduced
@@ -208,10 +208,10 @@ check pv_field "$dev6" pv_size $old_reduced
 check pv_field "$dev7" pv_size $old_reduced
 check pv_field "$dev8" pv_size $old_reduced
 # reset back to old size
-pvresize --setphysicalvolumesize $old_request "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
+pvresize --setphysicalvolumesize $old_request -y "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
 
 # two tags on pvs in separate vgs
-pvresize --setphysicalvolumesize $new_request @V3D9 @V2D3
+pvresize --setphysicalvolumesize $new_request -y @V3D9 @V2D3
 check pv_field "$dev9" pv_size $new_reduced
 check pv_field "$dev3" pv_size $new_reduced
 # unchanged
@@ -223,7 +223,7 @@ check pv_field "$dev6" pv_size $old_reduced
 check pv_field "$dev7" pv_size $old_reduced
 check pv_field "$dev8" pv_size $old_reduced
 # reset back to old size
-pvresize --setphysicalvolumesize $old_request "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
+pvresize --setphysicalvolumesize $old_request -y "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
 
 
 #
@@ -237,8 +237,8 @@ new_request="20.00m"
 new_reduced="16.00m"
 new_orphan="20.00m"
 
-pvresize --setphysicalvolumesize $old_request "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
-pvresize --setphysicalvolumesize $old_request "$dev11" "$dev14"
+pvresize --setphysicalvolumesize $old_request -y "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
+pvresize --setphysicalvolumesize $old_request -y "$dev11" "$dev14"
 check pv_field "$dev10" pv_size $old_reduced
 check pv_field "$dev2" pv_size $old_reduced
 check pv_field "$dev3" pv_size $old_reduced
@@ -252,7 +252,7 @@ check pv_field "$dev11" pv_size $old_orphan
 check pv_field "$dev14" pv_size $old_orphan
 
 # one orphan
-pvresize --setphysicalvolumesize $new_request "$dev11"
+pvresize --setphysicalvolumesize $new_request -y "$dev11"
 check pv_field "$dev11" pv_size $new_orphan
 # unchanged
 check pv_field "$dev10" pv_size $old_reduced
@@ -266,11 +266,11 @@ check pv_field "$dev8" pv_size $old_reduced
 check pv_field "$dev9" pv_size $old_reduced
 check pv_field "$dev14" pv_size $old_orphan
 # reset back to old size
-pvresize --setphysicalvolumesize $old_request "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
-pvresize --setphysicalvolumesize $old_request "$dev11" "$dev14"
+pvresize --setphysicalvolumesize $old_request -y "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
+pvresize --setphysicalvolumesize $old_request -y "$dev11" "$dev14"
 
 # two orphans
-pvresize --setphysicalvolumesize $new_request "$dev11" "$dev14"
+pvresize --setphysicalvolumesize $new_request -y "$dev11" "$dev14"
 check pv_field "$dev11" pv_size $new_orphan
 check pv_field "$dev14" pv_size $new_orphan
 # unchanged
@@ -284,11 +284,11 @@ check pv_field "$dev7" pv_size $old_reduced
 check pv_field "$dev8" pv_size $old_reduced
 check pv_field "$dev9" pv_size $old_reduced
 # reset back to old size
-pvresize --setphysicalvolumesize $old_request "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
-pvresize --setphysicalvolumesize $old_request "$dev11" "$dev14"
+pvresize --setphysicalvolumesize $old_request -y "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
+pvresize --setphysicalvolumesize $old_request -y "$dev11" "$dev14"
 
 # one orphan, one tag
-pvresize --setphysicalvolumesize $new_request @V3D9 "$dev14"
+pvresize --setphysicalvolumesize $new_request -y @V3D9 "$dev14"
 check pv_field "$dev9" pv_size $new_reduced
 check pv_field "$dev14" pv_size $new_orphan
 # unchanged
@@ -302,11 +302,11 @@ check pv_field "$dev7" pv_size $old_reduced
 check pv_field "$dev8" pv_size $old_reduced
 check pv_field "$dev11" pv_size $old_orphan
 # reset back to old size
-pvresize --setphysicalvolumesize $old_request "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
-pvresize --setphysicalvolumesize $old_request "$dev11" "$dev14"
+pvresize --setphysicalvolumesize $old_request -y "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
+pvresize --setphysicalvolumesize $old_request -y "$dev11" "$dev14"
 
 # one pv, one orphan, one tag
-pvresize --setphysicalvolumesize $new_request @V3D9 "$dev14" "$dev10"
+pvresize --setphysicalvolumesize $new_request -y @V3D9 "$dev14" "$dev10"
 check pv_field "$dev9" pv_size $new_reduced
 check pv_field "$dev10" pv_size $new_reduced
 check pv_field "$dev14" pv_size $new_orphan
@@ -320,8 +320,8 @@ check pv_field "$dev7" pv_size $old_reduced
 check pv_field "$dev8" pv_size $old_reduced
 check pv_field "$dev11" pv_size $old_orphan
 # reset back to old size
-pvresize --setphysicalvolumesize $old_request "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
-pvresize --setphysicalvolumesize $old_request "$dev11" "$dev14"
+pvresize --setphysicalvolumesize $old_request -y "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
+pvresize --setphysicalvolumesize $old_request -y "$dev11" "$dev14"
 
 
 #
@@ -329,7 +329,7 @@ pvresize --setphysicalvolumesize $old_request "$dev11" "$dev14"
 #
 
 # one dev (non-pv)
-not pvresize --setphysicalvolumesize $new_request "$dev13"
+not pvresize --setphysicalvolumesize $new_request -y "$dev13"
 # unchanged
 check pv_field "$dev10" pv_size $old_reduced
 check pv_field "$dev2" pv_size $old_reduced
@@ -344,7 +344,7 @@ check pv_field "$dev11" pv_size $old_orphan
 check pv_field "$dev14" pv_size $old_orphan
 
 # one orphan and one dev (non-pv)
-not pvresize --setphysicalvolumesize $new_request "$dev14" "$dev13"
+not pvresize --setphysicalvolumesize $new_request -y "$dev14" "$dev13"
 check pv_field "$dev14" pv_size $new_orphan
 # unchanged
 check pv_field "$dev10" pv_size $old_reduced
@@ -358,11 +358,11 @@ check pv_field "$dev8" pv_size $old_reduced
 check pv_field "$dev9" pv_size $old_reduced
 check pv_field "$dev11" pv_size $old_orphan
 # reset back to old size
-pvresize --setphysicalvolumesize $old_request "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
-pvresize --setphysicalvolumesize $old_request "$dev11" "$dev14"
+pvresize --setphysicalvolumesize $old_request -y "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
+pvresize --setphysicalvolumesize $old_request -y "$dev11" "$dev14"
 
 # one pv and one dev (non-pv)
-not pvresize --setphysicalvolumesize $new_request "$dev9" "$dev13"
+not pvresize --setphysicalvolumesize $new_request -y "$dev9" "$dev13"
 check pv_field "$dev9" pv_size $new_reduced
 # unchanged
 check pv_field "$dev10" pv_size $old_reduced
@@ -376,11 +376,11 @@ check pv_field "$dev8" pv_size $old_reduced
 check pv_field "$dev11" pv_size $old_orphan
 check pv_field "$dev14" pv_size $old_orphan
 # reset back to old size
-pvresize --setphysicalvolumesize $old_request "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
-pvresize --setphysicalvolumesize $old_request "$dev11" "$dev14"
+pvresize --setphysicalvolumesize $old_request -y "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
+pvresize --setphysicalvolumesize $old_request -y "$dev11" "$dev14"
 
 # one tag and one dev (non-pv)
-not pvresize --setphysicalvolumesize $new_request @V3D9 "$dev13"
+not pvresize --setphysicalvolumesize $new_request -y @V3D9 "$dev13"
 check pv_field "$dev9" pv_size $new_reduced
 # unchanged
 check pv_field "$dev10" pv_size $old_reduced
@@ -394,11 +394,11 @@ check pv_field "$dev8" pv_size $old_reduced
 check pv_field "$dev11" pv_size $old_orphan
 check pv_field "$dev14" pv_size $old_orphan
 # reset back to old size
-pvresize --setphysicalvolumesize $old_request "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
-pvresize --setphysicalvolumesize $old_request "$dev11" "$dev14"
+pvresize --setphysicalvolumesize $old_request -y "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
+pvresize --setphysicalvolumesize $old_request -y "$dev11" "$dev14"
 
 # one pv, one orphan, one tag, one dev
-not pvresize --setphysicalvolumesize $new_request @V3D9 "$dev13" "$dev14" "$dev10"
+not pvresize --setphysicalvolumesize $new_request -y @V3D9 "$dev13" "$dev14" "$dev10"
 check pv_field "$dev9" pv_size $new_reduced
 check pv_field "$dev10" pv_size $new_reduced
 check pv_field "$dev14" pv_size $new_orphan
@@ -412,16 +412,16 @@ check pv_field "$dev7" pv_size $old_reduced
 check pv_field "$dev8" pv_size $old_reduced
 check pv_field "$dev11" pv_size $old_orphan
 # reset back to old size
-pvresize --setphysicalvolumesize $old_request "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
-pvresize --setphysicalvolumesize $old_request "$dev11" "$dev14"
+pvresize --setphysicalvolumesize $old_request -y "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
+pvresize --setphysicalvolumesize $old_request -y "$dev11" "$dev14"
 
 
 #
 # pvresize including pvs without mdas
 #
 
-pvresize --setphysicalvolumesize $old_request "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
-pvresize --setphysicalvolumesize $old_request "$dev11" "$dev14"
+pvresize --setphysicalvolumesize $old_request -y "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
+pvresize --setphysicalvolumesize $old_request -y "$dev11" "$dev14"
 check pv_field "$dev10" pv_size $old_reduced
 check pv_field "$dev2" pv_size $old_reduced
 check pv_field "$dev3" pv_size $old_reduced
@@ -435,7 +435,7 @@ check pv_field "$dev11" pv_size $old_orphan
 check pv_field "$dev14" pv_size $old_orphan
 
 # one pv without mda
-pvresize --setphysicalvolumesize $new_request "$dev2"
+pvresize --setphysicalvolumesize $new_request -y "$dev2"
 check pv_field "$dev2" pv_size $new_reduced
 # unchanged
 check pv_field "$dev10" pv_size $old_reduced
@@ -449,11 +449,11 @@ check pv_field "$dev9" pv_size $old_reduced
 check pv_field "$dev11" pv_size $old_orphan
 check pv_field "$dev14" pv_size $old_orphan
 # reset back to old size
-pvresize --setphysicalvolumesize $old_request "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
-pvresize --setphysicalvolumesize $old_request "$dev11" "$dev14"
+pvresize --setphysicalvolumesize $old_request -y "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
+pvresize --setphysicalvolumesize $old_request -y "$dev11" "$dev14"
 
 # two pvs without mdas
-pvresize --setphysicalvolumesize $new_request "$dev6" "$dev7"
+pvresize --setphysicalvolumesize $new_request -y "$dev6" "$dev7"
 check pv_field "$dev6" pv_size $new_reduced
 check pv_field "$dev7" pv_size $new_reduced
 # unchanged
@@ -467,11 +467,11 @@ check pv_field "$dev9" pv_size $old_reduced
 check pv_field "$dev11" pv_size $old_orphan
 check pv_field "$dev14" pv_size $old_orphan
 # reset back to old size
-pvresize --setphysicalvolumesize $old_request "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
-pvresize --setphysicalvolumesize $old_request "$dev11" "$dev14"
+pvresize --setphysicalvolumesize $old_request -y "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
+pvresize --setphysicalvolumesize $old_request -y "$dev11" "$dev14"
 
 # one pv with mda and one pv without mda
-pvresize --setphysicalvolumesize $new_request "$dev8" "$dev9"
+pvresize --setphysicalvolumesize $new_request -y "$dev8" "$dev9"
 check pv_field "$dev8" pv_size $new_reduced
 check pv_field "$dev9" pv_size $new_reduced
 # unchanged
@@ -485,11 +485,11 @@ check pv_field "$dev7" pv_size $old_reduced
 check pv_field "$dev11" pv_size $old_orphan
 check pv_field "$dev14" pv_size $old_orphan
 # reset back to old size
-pvresize --setphysicalvolumesize $old_request "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
-pvresize --setphysicalvolumesize $old_request "$dev11" "$dev14"
+pvresize --setphysicalvolumesize $old_request -y "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
+pvresize --setphysicalvolumesize $old_request -y "$dev11" "$dev14"
 
 # one orphan with mda
-pvresize --setphysicalvolumesize $new_request "$dev11"
+pvresize --setphysicalvolumesize $new_request -y "$dev11"
 check pv_field "$dev11" pv_size $new_orphan
 # unchanged
 check pv_field "$dev10" pv_size $old_reduced
@@ -503,11 +503,11 @@ check pv_field "$dev8" pv_size $old_reduced
 check pv_field "$dev9" pv_size $old_reduced
 check pv_field "$dev14" pv_size $old_orphan
 # reset back to old size
-pvresize --setphysicalvolumesize $old_request "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
-pvresize --setphysicalvolumesize $old_request "$dev11" "$dev14"
+pvresize --setphysicalvolumesize $old_request -y "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
+pvresize --setphysicalvolumesize $old_request -y "$dev11" "$dev14"
 
 # one orphan without mda
-pvresize --setphysicalvolumesize $new_request "$dev14"
+pvresize --setphysicalvolumesize $new_request -y "$dev14"
 check pv_field "$dev14" pv_size $new_orphan
 # unchanged
 check pv_field "$dev10" pv_size $old_reduced
@@ -521,11 +521,11 @@ check pv_field "$dev8" pv_size $old_reduced
 check pv_field "$dev9" pv_size $old_reduced
 check pv_field "$dev11" pv_size $old_orphan
 # reset back to old size
-pvresize --setphysicalvolumesize $old_request "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
-pvresize --setphysicalvolumesize $old_request "$dev11" "$dev14"
+pvresize --setphysicalvolumesize $old_request -y "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
+pvresize --setphysicalvolumesize $old_request -y "$dev11" "$dev14"
 
 # one orphan with mda and one orphan without mda
-pvresize --setphysicalvolumesize $new_request "$dev14" "$dev11"
+pvresize --setphysicalvolumesize $new_request -y "$dev14" "$dev11"
 check pv_field "$dev11" pv_size $new_orphan
 check pv_field "$dev14" pv_size $new_orphan
 # unchanged
@@ -539,12 +539,12 @@ check pv_field "$dev7" pv_size $old_reduced
 check pv_field "$dev8" pv_size $old_reduced
 check pv_field "$dev9" pv_size $old_reduced
 # reset back to old size
-pvresize --setphysicalvolumesize $old_request "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
-pvresize --setphysicalvolumesize $old_request "$dev11" "$dev14"
+pvresize --setphysicalvolumesize $old_request -y "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
+pvresize --setphysicalvolumesize $old_request -y "$dev11" "$dev14"
 
 # one pv with mda and one pv without mda, and
 # one orphan with mda and one orphan without mda
-pvresize --setphysicalvolumesize $new_request "$dev8" "$dev9" "$dev14" "$dev11"
+pvresize --setphysicalvolumesize $new_request -y "$dev8" "$dev9" "$dev14" "$dev11"
 check pv_field "$dev8" pv_size $new_reduced
 check pv_field "$dev9" pv_size $new_reduced
 check pv_field "$dev11" pv_size $new_orphan
@@ -558,5 +558,5 @@ check pv_field "$dev5" pv_size $old_reduced
 check pv_field "$dev6" pv_size $old_reduced
 check pv_field "$dev7" pv_size $old_reduced
 # reset back to old size
-pvresize --setphysicalvolumesize $old_request "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
-pvresize --setphysicalvolumesize $old_request "$dev11" "$dev14"
+pvresize --setphysicalvolumesize $old_request -y "$dev10" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6" "$dev7" "$dev8" "$dev9"
+pvresize --setphysicalvolumesize $old_request -y "$dev11" "$dev14"
diff --git a/test/shell/pvresize-mdas.sh b/test/shell/pvresize-mdas.sh
index f7fdfc2..c2571f1 100644
--- a/test/shell/pvresize-mdas.sh
+++ b/test/shell/pvresize-mdas.sh
@@ -21,7 +21,7 @@ check pv_field "$dev1" pv_size 8.00m
 check pv_field "$dev1" pv_mda_count 2
 pvs "$dev1"
 
-pvresize --setphysicalvolumesize 4m "$dev1"
+pvresize --setphysicalvolumesize 4m -y "$dev1"
 check pv_field "$dev1" pv_size 4.00m
 check pv_field "$dev1" pv_mda_count 2
 pvs "$dev1"


