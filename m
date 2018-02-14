From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 14 Feb 2018 07:36:30 -0500
Subject: master - test: mirrored mirrorlog is not supposed to work in cluster
Message-ID: <201802141236.w1ECaUVJ014868@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=dd6fbcbb6941b0d534689258f7f07f567ee6f352
Commit:        dd6fbcbb6941b0d534689258f7f07f567ee6f352
Parent:        c3642957c5427d69b6aac45d2d1088786967cabd
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue Feb 13 18:34:08 2018 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed Feb 14 13:10:52 2018 +0100

test: mirrored mirrorlog is not supposed to work in cluster

---
 test/shell/lvconvert-mirror.sh   |   11 ++++++++---
 test/shell/lvcreate-operation.sh |   11 ++++++++++-
 2 files changed, 18 insertions(+), 4 deletions(-)

diff --git a/test/shell/lvconvert-mirror.sh b/test/shell/lvconvert-mirror.sh
index 449f605..76ff166 100644
--- a/test/shell/lvconvert-mirror.sh
+++ b/test/shell/lvconvert-mirror.sh
@@ -293,15 +293,20 @@ lvcreate -aey -l15 -n $lv1 $vg
 not lvconvert --type mirror -m1 --corelog --stripes 2 $vg/$lv1
 lvremove -ff $vg
 
-test -e LOCAL_CLVMD && exit 0
-
-# FIXME - cases which needs to be fixed to work in cluster
 # Linear to mirror with mirrored log using --alloc anywhere
 lvcreate -aey -l2 -n $lv1 $vg "$dev1"
+if test -e LOCAL_CLVMD; then
+# This is not supposed to work in cluster
+not lvconvert --type mirror -m +1 --mirrorlog mirrored --alloc anywhere $vg/$lv1 "$dev1" "$dev2"
+else
 lvconvert --type mirror -m +1 --mirrorlog mirrored --alloc anywhere $vg/$lv1 "$dev1" "$dev2"
 should check mirror $vg $lv1
+fi
 lvremove -ff $vg
 
+# FIXME - cases which needs to be fixed to work in cluster
+test -e LOCAL_CLVMD && exit 0
+
 # Should not be able to add images to --nosync mirror
 # but should be able to after 'lvchange --resync'
 lvcreate -aey --type mirror -m 1 -l1 -n $lv1 $vg --nosync
diff --git a/test/shell/lvcreate-operation.sh b/test/shell/lvcreate-operation.sh
index 63d05db..38d50cd 100644
--- a/test/shell/lvcreate-operation.sh
+++ b/test/shell/lvcreate-operation.sh
@@ -37,7 +37,14 @@ lvcreate -n$lv3 -l4 --permission r -s $vg/$lv1
 cleanup_lvs
 
 # Skip the rest for cluster
-test -e LOCAL_CLVMD && exit 0
+if test -e LOCAL_CLVMD; then
+
+# ---
+# Create mirror on two devices with mirrored log using --alloc anywhere - should always fail in cluster
+not lvcreate --type mirror -m 1 -l4 -n $lv1 --mirrorlog mirrored $vg --alloc anywhere "$dev1" "$dev2"
+cleanup_lvs
+
+else
 
 # ---
 # Create mirror on two devices with mirrored log using --alloc anywhere
@@ -49,4 +56,6 @@ cleanup_lvs
 not lvcreate --type mirror -m 1 -l4 -n $lv1 --mirrorlog mirrored $vg --alloc anywhere "$dev1"
 cleanup_lvs
 
+fi
+
 vgremove -ff $vg


