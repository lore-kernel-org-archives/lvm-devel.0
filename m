From: David Teigland <teigland@sourceware.org>
Date: Thu, 8 Nov 2018 10:50:19 -0500
Subject: master - tests: enable cachepolicy cleaner in cache-single-options
Message-ID: <201811081550.wA8FoJfZ024040@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8794fb71dbc3db8bebf133e6048bcd6ffdad7568
Commit:        8794fb71dbc3db8bebf133e6048bcd6ffdad7568
Parent:        e1e33e75e7e1c1907017aa151be7253f63075f34
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Nov 8 09:43:23 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Nov 8 09:43:23 2018 -0600

tests: enable cachepolicy cleaner in cache-single-options

---
 test/shell/cache-single-options.sh |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/test/shell/cache-single-options.sh b/test/shell/cache-single-options.sh
index 00c1b1d..62cfeaf 100644
--- a/test/shell/cache-single-options.sh
+++ b/test/shell/cache-single-options.sh
@@ -186,11 +186,10 @@ check lv_field $vg/$lv1 cachepolicy "smq"
 
 mkfs_mount_umount $lv1
 
-# FIXME: lvchange_cachepolicy sets wrong lv
-#lvchange --cachepolicy cleaner $vg/$lv1
-#lvchange -ay $vg/$lv1
-#check lv_field $vg/$lv1 cachepolicy "cleaner"
-#lvchange -an $vg/$lv1
+lvchange --cachepolicy cleaner $vg/$lv1
+lvchange -ay $vg/$lv1
+check lv_field $vg/$lv1 cachepolicy "cleaner"
+lvchange -an $vg/$lv1
 
 lvconvert --splitcache $vg/$lv1
 check lv_field $vg/$lv1 segtype linear


