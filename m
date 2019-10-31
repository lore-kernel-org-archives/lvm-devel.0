From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 31 Oct 2019 10:44:37 -0400
Subject: master - tests: reduce space requirements
Message-ID: <201910311444.x9VEibn9018588@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=50b50039d927f1e30d769639022f1b483a909def
Commit:        50b50039d927f1e30d769639022f1b483a909def
Parent:        8689b4ed8217bab779a6136a0e3d3b963bac11f4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 31 13:14:50 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 31 15:31:30 2019 +0100

tests: reduce space requirements

Test well runs on smaller test machines.
---
 test/shell/lvconvert-raid-reshape-load.sh          |    5 +----
 .../lvconvert-raid-reshape-stripes-load-fail.sh    |    5 +----
 .../lvconvert-raid-reshape-stripes-load-reload.sh  |    2 +-
 test/shell/lvconvert-raid-reshape-stripes-load.sh  |    5 +----
 4 files changed, 4 insertions(+), 13 deletions(-)

diff --git a/test/shell/lvconvert-raid-reshape-load.sh b/test/shell/lvconvert-raid-reshape-load.sh
index 7cd149b..8fcbf54 100644
--- a/test/shell/lvconvert-raid-reshape-load.sh
+++ b/test/shell/lvconvert-raid-reshape-load.sh
@@ -17,9 +17,6 @@ SKIP_WITH_LVMPOLLD=1
 
 # Test reshaping under io load
 
-# FIXME: This test requires 3GB in /dev/shm!
-test $(aux total_mem) -gt $((4096*1024)) || skip
-
 which mkfs.ext4 || skip
 aux have_raid 1 13 2 || skip
 
@@ -40,7 +37,7 @@ vgcreate $SHARED -s 1M "$vg" "${DEVICES[@]}"
 trap 'cleanup_mounted_and_teardown' EXIT
 
 # Create 13-way striped raid5 (14 legs total)
-lvcreate --yes --type raid5_ls --stripes 13 -L190M -n$lv1 $vg
+lvcreate --yes --type raid5_ls --stripes 13 -L4 -n$lv1 $vg
 check lv_first_seg_field $vg/$lv1 segtype "raid5_ls"
 check lv_first_seg_field $vg/$lv1 data_stripes 13
 check lv_first_seg_field $vg/$lv1 stripes 14
diff --git a/test/shell/lvconvert-raid-reshape-stripes-load-fail.sh b/test/shell/lvconvert-raid-reshape-stripes-load-fail.sh
index 8dda252..cb94a66 100644
--- a/test/shell/lvconvert-raid-reshape-stripes-load-fail.sh
+++ b/test/shell/lvconvert-raid-reshape-stripes-load-fail.sh
@@ -17,9 +17,6 @@ SKIP_WITH_LVMPOLLD=1
 
 # Test reshaping under io load
 
-# FIXME: This test requires 3GB in /dev/shm!
-test $(aux total_mem) -gt $((4096*1024)) || skip
-
 which mkfs.ext4 || skip
 aux have_raid 1 13 2 || skip
 
@@ -40,7 +37,7 @@ vgcreate $SHARED -s 1M "$vg" "${DEVICES[@]}"
 trap 'cleanup_mounted_and_teardown' EXIT
 
 # Create 10-way striped raid5 (11 legs total)
-lvcreate --yes --type raid5_ls --stripesize 64K --stripes 10 -L200M -n$lv1 $vg
+lvcreate --yes --type raid5_ls --stripesize 64K --stripes 10 -L4 -n$lv1 $vg
 check lv_first_seg_field $vg/$lv1 segtype "raid5_ls"
 check lv_first_seg_field $vg/$lv1 stripesize "64.00k"
 check lv_first_seg_field $vg/$lv1 data_stripes 10
diff --git a/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh b/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh
index 7318561..185bb57 100644
--- a/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh
+++ b/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh
@@ -43,7 +43,7 @@ vgcreate $SHARED -s 1M "$vg" "${DEVICES[@]}"
 trap 'cleanup_mounted_and_teardown' EXIT
 
 # Create 10-way striped raid5 (11 legs total)
-lvcreate --yes --type raid5_ls --stripesize 64K --stripes 10 -L64M -n$lv1 $vg
+lvcreate --yes --type raid5_ls --stripesize 64K --stripes 10 -L4 -n$lv1 $vg
 check lv_first_seg_field $vg/$lv1 segtype "raid5_ls"
 check lv_first_seg_field $vg/$lv1 stripesize "64.00k"
 check lv_first_seg_field $vg/$lv1 data_stripes 10
diff --git a/test/shell/lvconvert-raid-reshape-stripes-load.sh b/test/shell/lvconvert-raid-reshape-stripes-load.sh
index 32c8174..ad8f373 100644
--- a/test/shell/lvconvert-raid-reshape-stripes-load.sh
+++ b/test/shell/lvconvert-raid-reshape-stripes-load.sh
@@ -17,9 +17,6 @@ SKIP_WITH_LVMPOLLD=1
 
 # Test reshaping under io load
 
-# FIXME: This test requires 3GB in /dev/shm!
-test $(aux total_mem) -gt $((4096*1024)) || skip
-
 which mkfs.ext4 || skip
 aux have_raid 1 13 2 || skip
 
@@ -40,7 +37,7 @@ vgcreate $SHARED -s 1M "$vg" "${DEVICES[@]}"
 trap 'cleanup_mounted_and_teardown' EXIT
 
 # Create 10-way striped raid5 (11 legs total)
-lvcreate --yes --type raid5_ls --stripesize 64K --stripes 10 -L200M -n$lv1 $vg
+lvcreate --yes --type raid5_ls --stripesize 64K --stripes 10 -L4 -n$lv1 $vg
 check lv_first_seg_field $vg/$lv1 segtype "raid5_ls"
 check lv_first_seg_field $vg/$lv1 stripesize "64.00k"
 check lv_first_seg_field $vg/$lv1 data_stripes 10


