From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 31 Oct 2019 08:18:08 -0400
Subject: stable-2.02 - tests: reduce space requirements
Message-ID: <201910311218.x9VCI8Mj010858@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=50ab7b3ceb6698db215d644d0ec4caca20b8e1b5
Commit:        50ab7b3ceb6698db215d644d0ec4caca20b8e1b5
Parent:        719ab4da054b17df767a17dddd87d2cc62ec084b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 31 13:14:50 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 31 13:14:50 2019 +0100

tests: reduce space requirements

Test well runs on smaller test machines.
---
 test/shell/lvconvert-raid-reshape-load.sh          |    5 +----
 .../lvconvert-raid-reshape-stripes-load-fail.sh    |    5 +----
 .../lvconvert-raid-reshape-stripes-load-reload.sh  |    5 +----
 test/shell/lvconvert-raid-reshape-stripes-load.sh  |    5 +----
 4 files changed, 4 insertions(+), 16 deletions(-)

diff --git a/test/shell/lvconvert-raid-reshape-load.sh b/test/shell/lvconvert-raid-reshape-load.sh
index 11af24d..c42154a 100644
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
index c7ccad8..cadacb5 100644
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
 
 # Create 13-way striped raid5 (14 legs total)
-lvcreate --yes --type raid5_ls --stripesize 64K --stripes 10 -L200M -n$lv1 $vg
+lvcreate --yes --type raid5_ls --stripesize 64K --stripes 10 -L4 -n$lv1 $vg
 check lv_first_seg_field $vg/$lv1 segtype "raid5_ls"
 check lv_first_seg_field $vg/$lv1 stripesize "64.00k"
 check lv_first_seg_field $vg/$lv1 data_stripes 10
diff --git a/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh b/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh
index 839e704..d439a7c 100644
--- a/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh
+++ b/test/shell/lvconvert-raid-reshape-stripes-load-reload.sh
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
-lvcreate --yes --type raid5_ls --stripesize 64K --stripes 10 -L200M -n$lv1 $vg
+lvcreate --yes --type raid5_ls --stripesize 64K --stripes 10 -L4 -n$lv1 $vg
 check lv_first_seg_field $vg/$lv1 segtype "raid5_ls"
 check lv_first_seg_field $vg/$lv1 stripesize "64.00k"
 check lv_first_seg_field $vg/$lv1 data_stripes 10
diff --git a/test/shell/lvconvert-raid-reshape-stripes-load.sh b/test/shell/lvconvert-raid-reshape-stripes-load.sh
index 29790aa..aa6913f 100644
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
 
 # Create 13-way striped raid5 (14 legs total)
-lvcreate --yes --type raid5_ls --stripesize 64K --stripes 10 -L200M -n$lv1 $vg
+lvcreate --yes --type raid5_ls --stripesize 64K --stripes 10 -L4 -n$lv1 $vg
 check lv_first_seg_field $vg/$lv1 segtype "raid5_ls"
 check lv_first_seg_field $vg/$lv1 stripesize "64.00k"
 check lv_first_seg_field $vg/$lv1 data_stripes 10


