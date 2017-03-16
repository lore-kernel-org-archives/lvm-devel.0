From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Thu, 16 Mar 2017 16:18:25 -0400
Subject: master - test: adjust to proper dm-raid target version
Message-ID: <201703162018.v2GKIPbr009316@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=76b843a4bfa89d4c518d35495dbe13e35614acea
Commit:        76b843a4bfa89d4c518d35495dbe13e35614acea
Parent:        a37bb7b2a509f2d27800470af1a7a339a7c73794
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Mar 16 21:17:58 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Mar 16 21:17:58 2017 +0100

test: adjust to proper dm-raid target version

Adjust to final target version 1.10.1 supporting reshape
properly and to recently changed report field specifications
(e.g. rehape_len_le) to allow these tests to run.

Lower mirror region size to suite the tiny test VG.
---
 test/shell/lvconvert-mirror.sh                     |    2 +-
 .../lvconvert-raid-reshape-linear_to_striped.sh    |    3 ++-
 .../lvconvert-raid-reshape-striped_to_linear.sh    |   18 +++++++++---------
 test/shell/lvconvert-raid-reshape.sh               |    6 +++---
 4 files changed, 15 insertions(+), 14 deletions(-)

diff --git a/test/shell/lvconvert-mirror.sh b/test/shell/lvconvert-mirror.sh
index 5008f15..1f059ca 100644
--- a/test/shell/lvconvert-mirror.sh
+++ b/test/shell/lvconvert-mirror.sh
@@ -23,7 +23,7 @@ vgcreate -s 32k $vg $(cat DEVICES)
 
 # convert from linear to 2-way mirror ("mirror" default type)
 lvcreate -aey -l2 -n $lv1 $vg "$dev1"
-lvconvert -i1 -m+1 $vg/$lv1 "$dev2" "$dev3:0-1" \
+lvconvert -i1 -m+1 -R32k $vg/$lv1 "$dev2" "$dev3:0-1" \
 	--config 'global { mirror_segtype_default = "mirror" }'
 lvs --noheadings -o attr $vg/$lv1 | grep '^[[:space:]]*m'
 lvremove -ff $vg
diff --git a/test/shell/lvconvert-raid-reshape-linear_to_striped.sh b/test/shell/lvconvert-raid-reshape-linear_to_striped.sh
index 5a266ee..29a293e 100644
--- a/test/shell/lvconvert-raid-reshape-linear_to_striped.sh
+++ b/test/shell/lvconvert-raid-reshape-linear_to_striped.sh
@@ -15,7 +15,7 @@ SKIP_WITH_LVMPOLLD=1
 . lib/inittest
 
 which mkfs.ext4 || skip
-aux have_raid 1 10 2 || skip
+aux have_raid 1 10 1 || skip
 
 aux prepare_vg 5
 
@@ -58,6 +58,7 @@ check lv_first_seg_field $vg/$lv1 data_stripes 4
 check lv_first_seg_field $vg/$lv1 stripes 5
 check lv_first_seg_field $vg/$lv1 stripesize "64.00k"
 check lv_first_seg_field $vg/$lv1 regionsize "512.00k"
+check lv_first_seg_field $vg/$lv1 reshape_len_le 10
 aux wait_for_sync $vg $lv1
 fsck -fn $DM_DEV_DIR/$vg/$lv1
 
diff --git a/test/shell/lvconvert-raid-reshape-striped_to_linear.sh b/test/shell/lvconvert-raid-reshape-striped_to_linear.sh
index dd857c1..357763e 100644
--- a/test/shell/lvconvert-raid-reshape-striped_to_linear.sh
+++ b/test/shell/lvconvert-raid-reshape-striped_to_linear.sh
@@ -15,7 +15,7 @@ SKIP_WITH_LVMPOLLD=1
 . lib/inittest
 
 which mkfs.ext4 || skip
-aux have_raid 1 10 2 || skip
+aux have_raid 1 10 1 || skip
 
 aux prepare_vg 5
 
@@ -29,7 +29,7 @@ check lv_field $vg/$lv1 segtype "striped"
 check lv_field $vg/$lv1 data_stripes 4
 check lv_field $vg/$lv1 stripes 4
 check lv_field $vg/$lv1 stripesize "32.00k"
-check lv_field $vg/$lv1 reshape_len "" 
+check lv_field $vg/$lv1 reshape_len_le ""
 echo y|mkfs -t ext4 $DM_DEV_DIR/$vg/$lv1
 fsck -fn $DM_DEV_DIR/$vg/$lv1
 
@@ -41,7 +41,7 @@ check lv_field $vg/$lv1 data_stripes 4
 check lv_field $vg/$lv1 stripes 5
 check lv_field $vg/$lv1 stripesize "32.00k"
 check lv_field $vg/$lv1 regionsize "128.00k"
-check lv_field $vg/$lv1 reshape_len ""
+check lv_field $vg/$lv1 reshape_len_le 0
 aux wait_for_sync $vg $lv1
 fsck -fn $DM_DEV_DIR/$vg/$lv1
 
@@ -52,7 +52,7 @@ check lv_field $vg/$lv1 data_stripes 4
 check lv_field $vg/$lv1 stripes 5
 check lv_field $vg/$lv1 stripesize "32.00k"
 check lv_field $vg/$lv1 regionsize "128.00k"
-check lv_field $vg/$lv1 reshape_len ""
+check lv_field $vg/$lv1 reshape_len_le "0"
 aux wait_for_sync $vg $lv1
 fsck -fn $DM_DEV_DIR/$vg/$lv1
 
@@ -66,10 +66,10 @@ check lv_first_seg_field $vg/$lv1 data_stripes 1
 check lv_first_seg_field $vg/$lv1 stripes 5
 check lv_first_seg_field $vg/$lv1 stripesize "64.00k"
 check lv_first_seg_field $vg/$lv1 regionsize "1.00m"
-check lv_first_seg_field $vg/$lv1 reshape_len 10
+check lv_first_seg_field $vg/$lv1 reshape_len_le 10
 # for slv in {0..4}
 # do
-#	check lv_first_seg_field $vg/${lv1}_rimage_${slv} reshape_len 2
+#	check lv_first_seg_field $vg/${lv1}_rimage_${slv} reshape_len_le 2
 # done
 aux wait_for_sync $vg $lv1 1
 fsck -fn $DM_DEV_DIR/$vg/$lv1
@@ -81,7 +81,7 @@ check lv_first_seg_field $vg/$lv1 data_stripes 1
 check lv_first_seg_field $vg/$lv1 stripes 2
 check lv_first_seg_field $vg/$lv1 stripesize "64.00k"
 check lv_first_seg_field $vg/$lv1 regionsize "1.00m"
-check lv_first_seg_field $vg/$lv1 reshape_len 4
+check lv_first_seg_field $vg/$lv1 reshape_len_le 4
 
 # Convert raid5_n to raid1
 lvconvert -y --type raid1 $vg/$lv1
@@ -91,7 +91,7 @@ check lv_first_seg_field $vg/$lv1 data_stripes 2
 check lv_first_seg_field $vg/$lv1 stripes 2
 check lv_first_seg_field $vg/$lv1 stripesize "0"
 check lv_first_seg_field $vg/$lv1 regionsize "1.00m"
-check lv_first_seg_field $vg/$lv1 reshape_len ""
+check lv_first_seg_field $vg/$lv1 reshape_len_le ""
 
 # Convert raid5_n -> linear
 lvconvert -y --type linear $vg/$lv1
@@ -101,6 +101,6 @@ check lv_first_seg_field $vg/$lv1 data_stripes 1
 check lv_first_seg_field $vg/$lv1 stripes 1
 check lv_first_seg_field $vg/$lv1 stripesize "0"
 check lv_first_seg_field $vg/$lv1 regionsize "0"
-check lv_first_seg_field $vg/$lv1 reshape_len ""
+check lv_first_seg_field $vg/$lv1 reshape_len_le ""
 
 vgremove -ff $vg
diff --git a/test/shell/lvconvert-raid-reshape.sh b/test/shell/lvconvert-raid-reshape.sh
index 6764d30..05c4784 100644
--- a/test/shell/lvconvert-raid-reshape.sh
+++ b/test/shell/lvconvert-raid-reshape.sh
@@ -15,7 +15,7 @@ SKIP_WITH_LVMPOLLD=1
 . lib/inittest
 
 which mkfs.ext4 || skip
-aux have_raid 1 10 2 || skip
+aux have_raid 1 10 1 || skip
 
 aux prepare_pvs 65 64
 
@@ -197,11 +197,11 @@ _lvconvert raid10 raid10 4 8 $vg $lv1
 # Convert raid10 to 10 stripes and 64K stripesize
 # FIXME: change once we support odd numbers of raid10 stripes
 not _reshape_layout raid10 4 9 $vg $lv1 --stripes 9 --stripesize 64K
-_reshape_layout raid10 5 10 $vg $lv1 --stripes 10 --stripesize 64K
+_reshape_layout raid10 10 20 $vg $lv1 --stripes 10 --stripesize 64K
 check lv_first_seg_field $vg/$lv1 stripesize "64.00k"
 
 # Convert raid6_n_6 -> striped
-_lvconvert striped striped 5 5 $vg $lv1
+_lvconvert striped striped 10 10 $vg $lv1
 check lv_first_seg_field $vg/$lv1 stripesize "64.00k"
 
 vgremove -ff $vg


