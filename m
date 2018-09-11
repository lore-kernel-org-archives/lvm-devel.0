From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Tue, 11 Sep 2018 09:54:36 -0400
Subject: master - tests: adjust target version to enable reshape tests
Message-ID: <201809111354.w8BDsaNP013967@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=df67b1da4d5ee4cf4514f655dbc5a58193364cbd
Commit:        df67b1da4d5ee4cf4514f655dbc5a58193364cbd
Parent:        d0ff078e77e9f1018d14e824ae16b5d861a7f818
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Tue Sep 11 15:39:31 2018 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Tue Sep 11 15:53:25 2018 +0200

tests: adjust target version to enable reshape tests

Bump target version to 1.14.0 which contains fixes
for reshape deadlock/corruption to allow tests to
run once the respective fixes show up in kernels.

Remove now superfluous multi-core checks.

Resolves: rhbz1501145
Related: rhbz1514539
Related: rhbz1586123
Related: rhbz1613039
---
 ...ert-raid-reshape-linear_to_raid6-single-type.sh |    5 +----
 ...t-raid-reshape-linear_to_striped-single-type.sh |    7 +------
 .../lvconvert-raid-reshape-linear_to_striped.sh    |    5 +----
 ...t-raid-reshape-striped_to_linear-single-type.sh |    6 +-----
 .../lvconvert-raid-reshape-striped_to_linear.sh    |    6 +-----
 test/shell/lvconvert-raid-reshape.sh               |    7 +------
 test/shell/lvconvert-raid-restripe-linear.sh       |    5 +----
 7 files changed, 7 insertions(+), 34 deletions(-)

diff --git a/test/shell/lvconvert-raid-reshape-linear_to_raid6-single-type.sh b/test/shell/lvconvert-raid-reshape-linear_to_raid6-single-type.sh
index 05cb616..cbacf4a 100644
--- a/test/shell/lvconvert-raid-reshape-linear_to_raid6-single-type.sh
+++ b/test/shell/lvconvert-raid-reshape-linear_to_raid6-single-type.sh
@@ -19,11 +19,8 @@ SKIP_WITH_LVMPOLLD=1
 aux lvmconf 'activation/raid_region_size = 512'
 
 which mkfs.ext4 || skip
-aux have_raid 1 13 1 || skip
+aux have_raid 1 14 0 || skip
 
-# Temporarily skip reshape tests on single-core CPUs until there's a fix for
-# https://bugzilla.redhat.com/1443999 - AGK 2017/04/20
-aux have_multi_core || skip
 aux prepare_vg 5
 
 #
diff --git a/test/shell/lvconvert-raid-reshape-linear_to_striped-single-type.sh b/test/shell/lvconvert-raid-reshape-linear_to_striped-single-type.sh
index 7e31cb9..c9c4321 100644
--- a/test/shell/lvconvert-raid-reshape-linear_to_striped-single-type.sh
+++ b/test/shell/lvconvert-raid-reshape-linear_to_striped-single-type.sh
@@ -18,12 +18,7 @@ SKIP_WITH_LVMPOLLD=1
 aux lvmconf 'activation/raid_region_size = 512'
 
 which mkfs.ext4 || skip
-aux have_raid 1 13 1 || skip
-
-# Temporarily skip reshape tests on single-core CPUs until there's a fix for
-# https://bugzilla.redhat.com/1443999 - AGK 2017/04/20
-aux have_multi_core || skip
-aux prepare_vg 5
+aux have_raid 1 14 0 || skip
 
 #
 # Test multi step linear -> striped conversion
diff --git a/test/shell/lvconvert-raid-reshape-linear_to_striped.sh b/test/shell/lvconvert-raid-reshape-linear_to_striped.sh
index 04e2d62..c398c5e 100644
--- a/test/shell/lvconvert-raid-reshape-linear_to_striped.sh
+++ b/test/shell/lvconvert-raid-reshape-linear_to_striped.sh
@@ -17,11 +17,8 @@ SKIP_WITH_LVMPOLLD=1
 aux lvmconf 'activation/raid_region_size = 512'
 
 which mkfs.ext4 || skip
-aux have_raid 1 12 0 || skip
+aux have_raid 1 14 0 || skip
 
-# Temporarily skip reshape tests on single-core CPUs until there's a fix for
-# https://bugzilla.redhat.com/1443999 - AGK 2017/04/20
-aux have_multi_core || skip
 aux prepare_vg 5
 
 #
diff --git a/test/shell/lvconvert-raid-reshape-striped_to_linear-single-type.sh b/test/shell/lvconvert-raid-reshape-striped_to_linear-single-type.sh
index 476fb10..60fc59f 100644
--- a/test/shell/lvconvert-raid-reshape-striped_to_linear-single-type.sh
+++ b/test/shell/lvconvert-raid-reshape-striped_to_linear-single-type.sh
@@ -18,11 +18,7 @@ SKIP_WITH_LVMPOLLD=1
 aux lvmconf 'activation/raid_region_size = 512'
 
 which mkfs.ext4 || skip
-aux have_raid 1 13 1 || skip
-
-# Temporarily skip reshape tests on single-core CPUs until there's a fix for
-# https://bugzilla.redhat.com/1443999 - AGK 2017/04/20
-aux have_multi_core || skip
+aux have_raid 1 14 0 || skip
 
 aux prepare_vg 5
 
diff --git a/test/shell/lvconvert-raid-reshape-striped_to_linear.sh b/test/shell/lvconvert-raid-reshape-striped_to_linear.sh
index ccbe6ad..e217ea3 100644
--- a/test/shell/lvconvert-raid-reshape-striped_to_linear.sh
+++ b/test/shell/lvconvert-raid-reshape-striped_to_linear.sh
@@ -18,11 +18,7 @@ SKIP_WITH_LVMPOLLD=1
 aux lvmconf 'activation/raid_region_size = 512'
 
 which mkfs.ext4 || skip
-aux have_raid 1 12 0 || skip
-
-# Temporarily skip reshape tests on single-core CPUs until there's a fix for
-# https://bugzilla.redhat.com/1443999 - AGK 2017/04/20
-aux have_multi_core || skip
+aux have_raid 1 14 0 || skip
 
 aux prepare_vg 5 20
 
diff --git a/test/shell/lvconvert-raid-reshape.sh b/test/shell/lvconvert-raid-reshape.sh
index ab3ea4e..28c7e2d 100644
--- a/test/shell/lvconvert-raid-reshape.sh
+++ b/test/shell/lvconvert-raid-reshape.sh
@@ -18,12 +18,7 @@ LVM_SKIP_LARGE_TESTS=0
 . lib/inittest
 
 which mkfs.ext4 || skip
-aux have_raid 1 13 99 || skip # needed to address RHBZ#1501145
-
-# Temporarily skip reshape tests on single-core CPUs until there's a fix for
-# https://bugzilla.redhat.com/1443999 - AGK 2017/04/20
-#aux have_multi_core || skip
-# dropping single-core limitation with  1.12 target
+aux have_raid 1 14 0 || skip
 
 if [ $LVM_SKIP_LARGE_TESTS -eq 0 ]
 then
diff --git a/test/shell/lvconvert-raid-restripe-linear.sh b/test/shell/lvconvert-raid-restripe-linear.sh
index 0ac8a04..70d31db 100644
--- a/test/shell/lvconvert-raid-restripe-linear.sh
+++ b/test/shell/lvconvert-raid-restripe-linear.sh
@@ -16,11 +16,8 @@ SKIP_WITH_LVMPOLLD=1
 . lib/inittest
 
 which mkfs.ext4 || skip
-aux have_raid 1 12 0 || skip
+aux have_raid 1 14 0 || skip
 
-# Temporarily skip reshape tests on single-core CPUs until there's a fix for
-# https://bugzilla.redhat.com/1443999 - AGK 2017/04/20
-aux have_multi_core || skip
 aux prepare_vg 5
 
 #


