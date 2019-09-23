From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Sep 2019 15:22:05 -0400
Subject: master - tests: update cache-single-split
Message-ID: <201909231922.x8NJM5cD026206@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a353bfdd9f5f612967e514240b8c4cb06d924a19
Commit:        a353bfdd9f5f612967e514240b8c4cb06d924a19
Parent:        5191057d9df3e5b92db3f80c412b99aea1074358
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Sep 23 14:20:01 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Sep 23 14:21:09 2019 -0500

tests: update cache-single-split

enable splitting while LV is active which works
again since the cvol suffix was dropped.
---
 test/shell/cache-single-split.sh |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/test/shell/cache-single-split.sh b/test/shell/cache-single-split.sh
index edfa087..90c3ddb 100644
--- a/test/shell/cache-single-split.sh
+++ b/test/shell/cache-single-split.sh
@@ -113,7 +113,7 @@ check lv_field $vg/$lv1 cachemode "writethrough"
 
 mkfs_mount_umount $lv1
 
-# lvchange -ay $vg/$lv1
+lvchange -ay $vg/$lv1
 
 lvconvert --splitcache $vg/$lv1
 lvs -o segtype $vg/$lv1 | grep linear
@@ -135,7 +135,7 @@ lvchange -an $vg/$lv2
 
 mkfs_mount_umount $lv1
 
-# lvchange -ay $vg/$lv1
+lvchange -ay $vg/$lv1
 
 lvconvert --splitcache $vg/$lv1
 lvs -o segtype $vg/$lv1 | grep linear
@@ -160,7 +160,7 @@ lvchange -an $vg/$lv2
 
 mkfs_mount_umount $lv1
 
-# lvchange -ay $vg/$lv1
+lvchange -ay $vg/$lv1
 
 aux disable_dev "$dev2"
 


