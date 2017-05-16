From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Tue, 16 May 2017 11:53:28 -0400
Subject: master - test: add missing yes option to lvconvert stripe removal
Message-ID: <201705161553.v4GFrSrl009792@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=48408ece6ddd730c394e3081f9a2d78d1771f129
Commit:        48408ece6ddd730c394e3081f9a2d78d1771f129
Parent:        f4f408610c6801a50395f95b8116e2037a58761e
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Tue May 16 17:51:58 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Tue May 16 17:52:54 2017 +0200

test: add missing yes option to lvconvert stripe removal

---
 .../lvconvert-raid-reshape-striped_to_linear.sh    |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvconvert-raid-reshape-striped_to_linear.sh b/test/shell/lvconvert-raid-reshape-striped_to_linear.sh
index 4051862..d926827 100644
--- a/test/shell/lvconvert-raid-reshape-striped_to_linear.sh
+++ b/test/shell/lvconvert-raid-reshape-striped_to_linear.sh
@@ -79,7 +79,7 @@ aux wait_for_sync $vg $lv1 1
 fsck -fn $DM_DEV_DIR/$vg/$lv1
 
 # Remove the now freed legs
-lvconvert --stripes 1 $vg/$lv1
+lvconvert -y --stripes 1 $vg/$lv1
 check lv_first_seg_field $vg/$lv1 segtype "raid5_n"
 check lv_first_seg_field $vg/$lv1 data_stripes 1
 check lv_first_seg_field $vg/$lv1 stripes 2


