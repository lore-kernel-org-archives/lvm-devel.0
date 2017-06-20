From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 20 Jun 2017 12:25:53 -0400
Subject: master - tests: test also different lock holder
Message-ID: <201706201625.v5KGPrfY006849@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=710f51e7f24bfc6c4e4300e4bec3316796bf0c78
Commit:        710f51e7f24bfc6c4e4300e4bec3316796bf0c78
Parent:        3d591ac376b369de78d8471c2651256c5eb52b1f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 20 18:22:17 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 20 18:25:10 2017 +0200

tests: test also different lock holder

---
 test/shell/lvconvert-raid-takeover-thin.sh |   26 +++++++++++++++++++++++---
 1 files changed, 23 insertions(+), 3 deletions(-)

diff --git a/test/shell/lvconvert-raid-takeover-thin.sh b/test/shell/lvconvert-raid-takeover-thin.sh
index 93d887d..647b133 100644
--- a/test/shell/lvconvert-raid-takeover-thin.sh
+++ b/test/shell/lvconvert-raid-takeover-thin.sh
@@ -22,10 +22,10 @@ aux have_raid 1 9 0 || skip
 
 aux prepare_vg 6
 
-lvcreate -L4  -i3 -T  $vg/pool  -V10
+lvcreate -L4 -i3 -T $vg/pool -V10
 
 for i in 1 2 ; do
-lvconvert --type raid10 -y  $vg/pool_tdata
+lvconvert --type raid10 -y $vg/pool_tdata
 check grep_dmsetup table $vg-pool_tdata "raid10"
 aux wait_for_sync $vg pool_tdata
 
@@ -35,7 +35,27 @@ done
 
 lvremove -f $vg
 
-lvcreate -L4  -T $vg/pool -V10
+lvcreate -L4  -T $vg/pool -V10 -n $lv1
+
+for j in data meta ; do
+  LV=pool_t${j}
+  for i in 1 2 ; do
+    lvconvert --type raid1 -m1 -y  $vg/$LV
+    check grep_dmsetup table $vg-${LV} "raid1"
+    aux wait_for_sync $vg $LV
+
+    lvconvert --type raid1 -m0 -y  $vg/$LV
+    check grep_dmsetup table ${vg}-${LV} "linear"
+  done
+done
+
+
+#
+# Now same test again, when lock holding LV is not a thin-poll
+# but thinLV $lv1
+#
+lvchange -an $vg
+lvchange -ay $vg/$lv1
 
 for j in data meta ; do
   LV=pool_t${j}


