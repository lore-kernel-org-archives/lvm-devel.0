From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 12 Jul 2016 11:23:29 +0000 (UTC)
Subject: master - tests: remove more test
Message-ID: <20160712112329.2D19760DD0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=957480f4b9e6cbcc0cfc87ed06d0c0283269e17f
Commit:        957480f4b9e6cbcc0cfc87ed06d0c0283269e17f
Parent:        1891fa827215a10085bda9c9b660791de997d198
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jul 12 10:37:40 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jul 12 13:20:56 2016 +0200

tests: remove more test

Try to remove more tests before confusing older driver to death.
---
 test/shell/lvchange-cache.sh |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/test/shell/lvchange-cache.sh b/test/shell/lvchange-cache.sh
index 25c59b1..fa7d24c 100644
--- a/test/shell/lvchange-cache.sh
+++ b/test/shell/lvchange-cache.sh
@@ -39,6 +39,10 @@ lvchange --cachepolicy mq --cachesettings migration_threshold=333 $vg/corigin
 check lv_field $vg/corigin kernel_cache_policy "mq"
 get lv_field $vg/corigin kernel_cache_settings | grep 'migration_threshold=333'
 
+# Skip these test on older cache driver as it shows errors with these lvchanges
+# device-mapper: space map common: index_check failed: blocknr 17179869216 != wanted 11
+if aux have_cache 1 5 0 ; then
+
 lvchange --refresh $vg/corigin
 get lv_field $vg/corigin kernel_cache_settings | grep 'migration_threshold=333'
 lvchange -an $vg
@@ -68,10 +72,6 @@ grep 'migration_threshold=2048' out
 grep 'sequential_threshold=13' out
 grep 'random_threshold=4' out
 
-# Skip these test on older cache driver as it shows errors with these lvchanges
-# device-mapper: space map common: index_check failed: blocknr 17179869216 != wanted 11
-if aux have_cache 1 5 0 ; then
-
 lvchange --cachesettings migration_threshold=233 --cachesettings sequential_threshold=13 --cachesettings random_threshold=1 $vg/corigin
 get lv_field $vg/corigin kernel_cache_settings | tee out
 grep 'migration_threshold=233' out


