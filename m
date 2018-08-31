From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Fri, 31 Aug 2018 09:10:15 -0400
Subject: master - test: comment fixes
Message-ID: <201808311310.w7VDAFd3020510@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=61600f8fa7e150b02c1be5e1f8ee1b008b4efa90
Commit:        61600f8fa7e150b02c1be5e1f8ee1b008b4efa90
Parent:        fa0a04236c613fb82e3cd559c6b451f5eb7102ad
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Aug 31 15:07:24 2018 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Aug 31 15:09:55 2018 +0200

test: comment fixes

Fix comments in

   test/shell/lvconvert-raid-reshape-stripes-load-fail.sh
   test/shell/lvconvert-raid-reshape-stripes-load-reload.sh
   test/shell/lvconvert-raid-reshape-stripes-load.sh
---
 .../lvconvert-raid-reshape-stripes-load-fail.sh    |    2 +-
 .../lvconvert-raid-reshape-stripes-load-reload.sh  |    2 +-
 test/shell/lvconvert-raid-reshape-stripes-load.sh  |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/test/shell/lvconvert-raid-reshape-stripes-load-fail.sh b/test/shell/lvconvert-raid-reshape-stripes-load-fail.sh
index c7ccad8..5fa21dc 100644
--- a/test/shell/lvconvert-raid-reshape-stripes-load-fail.sh
+++ b/test/shell/lvconvert-raid-reshape-stripes-load-fail.sh
@@ -39,7 +39,7 @@ vgcreate $SHARED -s 1M "$vg" "${DEVICES[@]}"
 
 trap 'cleanup_mounted_and_teardown' EXIT
 
-# Create 13-way striped raid5 (14 legs total)
+# Create 10-way striped raid5 (11 legs total)
 lvcreate --yes --type raid5_ls --stripesize 64K --stripes 10 -L200M -n$lv1 $vg
 check lv_first_seg_field $vg/$lv1 segtype "raid5_ls"
 check lv_first_seg_field $vg/$lv1 stripesize "64.00k"
diff --git a/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh b/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh
index 839e704..f317b7e 100644
--- a/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh
+++ b/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh
@@ -39,7 +39,7 @@ vgcreate $SHARED -s 1M "$vg" "${DEVICES[@]}"
 
 trap 'cleanup_mounted_and_teardown' EXIT
 
-# Create 13-way striped raid5 (14 legs total)
+# Create 10-way striped raid5 (11 legs total)
 lvcreate --yes --type raid5_ls --stripesize 64K --stripes 10 -L200M -n$lv1 $vg
 check lv_first_seg_field $vg/$lv1 segtype "raid5_ls"
 check lv_first_seg_field $vg/$lv1 stripesize "64.00k"
diff --git a/test/shell/lvconvert-raid-reshape-stripes-load.sh b/test/shell/lvconvert-raid-reshape-stripes-load.sh
index 29790aa..dd04798 100644
--- a/test/shell/lvconvert-raid-reshape-stripes-load.sh
+++ b/test/shell/lvconvert-raid-reshape-stripes-load.sh
@@ -39,7 +39,7 @@ vgcreate $SHARED -s 1M "$vg" "${DEVICES[@]}"
 
 trap 'cleanup_mounted_and_teardown' EXIT
 
-# Create 13-way striped raid5 (14 legs total)
+# Create 10-way striped raid5 (11 legs total)
 lvcreate --yes --type raid5_ls --stripesize 64K --stripes 10 -L200M -n$lv1 $vg
 check lv_first_seg_field $vg/$lv1 segtype "raid5_ls"
 check lv_first_seg_field $vg/$lv1 stripesize "64.00k"


