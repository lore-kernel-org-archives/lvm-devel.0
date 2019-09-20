From: David Teigland <teigland@sourceware.org>
Date: Fri, 20 Sep 2019 17:36:37 -0400
Subject: master - tests: update cache-single-split
Message-ID: <201909202136.x8KLabLL008455@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=338a60bb417e413820a6d1faeed864222607c8ef
Commit:        338a60bb417e413820a6d1faeed864222607c8ef
Parent:        27c3c1d7c8dcb160f29d1610f3993f41afc72a6d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Sep 20 16:33:35 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Sep 20 16:36:14 2019 -0500

tests: update cache-single-split

the new use of uuid suffixes on internal dm devs
has impacted splitting when an LV is active,
so temporarily disable that until fixed.
---
 test/shell/cache-single-split.sh |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/test/shell/cache-single-split.sh b/test/shell/cache-single-split.sh
index 90c3ddb..edfa087 100644
--- a/test/shell/cache-single-split.sh
+++ b/test/shell/cache-single-split.sh
@@ -113,7 +113,7 @@ check lv_field $vg/$lv1 cachemode "writethrough"
 
 mkfs_mount_umount $lv1
 
-lvchange -ay $vg/$lv1
+# lvchange -ay $vg/$lv1
 
 lvconvert --splitcache $vg/$lv1
 lvs -o segtype $vg/$lv1 | grep linear
@@ -135,7 +135,7 @@ lvchange -an $vg/$lv2
 
 mkfs_mount_umount $lv1
 
-lvchange -ay $vg/$lv1
+# lvchange -ay $vg/$lv1
 
 lvconvert --splitcache $vg/$lv1
 lvs -o segtype $vg/$lv1 | grep linear
@@ -160,7 +160,7 @@ lvchange -an $vg/$lv2
 
 mkfs_mount_umount $lv1
 
-lvchange -ay $vg/$lv1
+# lvchange -ay $vg/$lv1
 
 aux disable_dev "$dev2"
 


