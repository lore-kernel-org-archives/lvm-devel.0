From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Fri, 1 Dec 2017 12:57:39 -0500
Subject: master - test: reduce pv sizes, fix comment and stripe size
Message-ID: <201712011757.vB1HvdGp029491@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7aef59c6c332e5b9a983f5559acfa13834b2d064
Commit:        7aef59c6c332e5b9a983f5559acfa13834b2d064
Parent:        16fa9d9ed5569ac6b8f87375c2902de8280eefe4
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Dec 1 18:42:37 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Dec 1 18:42:37 2017 +0100

test: reduce pv sizes, fix comment and stripe size

---
 .../lvconvert-raid-reshape-striped_to_linear.sh    |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/test/shell/lvconvert-raid-reshape-striped_to_linear.sh b/test/shell/lvconvert-raid-reshape-striped_to_linear.sh
index ba90f57..5230b2b 100644
--- a/test/shell/lvconvert-raid-reshape-striped_to_linear.sh
+++ b/test/shell/lvconvert-raid-reshape-striped_to_linear.sh
@@ -22,7 +22,7 @@ aux have_raid 1 12 0 || skip
 # https://bugzilla.redhat.com/1443999 - AGK 2017/04/20
 aux have_multi_core || skip
 
-aux prepare_vg 5
+aux prepare_vg 5 20
 
 #
 # Test single step linear -> striped conversion
@@ -69,7 +69,7 @@ fsck -fn $DM_DEV_DIR/$vg/$lv1
 check lv_first_seg_field $vg/$lv1 segtype "raid5_n"
 check lv_first_seg_field $vg/$lv1 data_stripes 1
 check lv_first_seg_field $vg/$lv1 stripes 5
-check lv_first_seg_field $vg/$lv1 stripesize "64.00k"
+check lv_first_seg_field $vg/$lv1 stripesize "32.00k"
 check lv_first_seg_field $vg/$lv1 regionsize "1.00m"
 check lv_first_seg_field $vg/$lv1 reshape_len_le 10
 # for slv in {0..4}
@@ -84,7 +84,7 @@ lvconvert -y --stripes 1 $vg/$lv1
 check lv_first_seg_field $vg/$lv1 segtype "raid5_n"
 check lv_first_seg_field $vg/$lv1 data_stripes 1
 check lv_first_seg_field $vg/$lv1 stripes 2
-check lv_first_seg_field $vg/$lv1 stripesize "64.00k"
+check lv_first_seg_field $vg/$lv1 stripesize "32.00k"
 check lv_first_seg_field $vg/$lv1 regionsize "1.00m"
 check lv_first_seg_field $vg/$lv1 reshape_len_le 4
 
@@ -98,7 +98,7 @@ check lv_first_seg_field $vg/$lv1 stripesize "0"
 check lv_first_seg_field $vg/$lv1 regionsize "1.00m"
 check lv_first_seg_field $vg/$lv1 reshape_len_le ""
 
-# Convert raid5_n -> linear
+# Convert raid1 -> linear
 lvconvert -y --type linear $vg/$lv1
 fsck -fn $DM_DEV_DIR/$vg/$lv1
 check lv_first_seg_field $vg/$lv1 segtype "linear"


