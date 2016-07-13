From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 13 Jul 2016 19:56:19 +0000 (UTC)
Subject: master - tests: skip more cache tests for older driver
Message-ID: <20160713195619.4172660370@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0b773eecd967599b38214fe321fc7e493046c880
Commit:        0b773eecd967599b38214fe321fc7e493046c880
Parent:        07587c2699b04058b6dd044adb69c854a6458e24
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jul 13 16:13:29 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 13 21:52:14 2016 +0200

tests: skip more cache tests for older driver

---
 test/shell/lvchange-cache.sh |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/test/shell/lvchange-cache.sh b/test/shell/lvchange-cache.sh
index fa7d24c..385fcf4 100644
--- a/test/shell/lvchange-cache.sh
+++ b/test/shell/lvchange-cache.sh
@@ -33,16 +33,16 @@ not lvchange --cachesettings foo=bar $vg/noncache
 lvchange --cachepolicy cleaner $vg/corigin
 check lv_field  $vg/corigin kernel_cache_policy "cleaner"
 
+# Skip these test on older cache driver as it shows errors with these lvchanges
+# device-mapper: space map common: index_check failed: blocknr 17179869216 != wanted 11
+if aux have_cache 1 5 0 ; then
+
 lvchange --cachepolicy mq --cachesettings migration_threshold=333 $vg/corigin
 
 # TODO once mq->smq happens we will get here some 0 for mq settings
 check lv_field $vg/corigin kernel_cache_policy "mq"
 get lv_field $vg/corigin kernel_cache_settings | grep 'migration_threshold=333'
 
-# Skip these test on older cache driver as it shows errors with these lvchanges
-# device-mapper: space map common: index_check failed: blocknr 17179869216 != wanted 11
-if aux have_cache 1 5 0 ; then
-
 lvchange --refresh $vg/corigin
 get lv_field $vg/corigin kernel_cache_settings | grep 'migration_threshold=333'
 lvchange -an $vg
@@ -84,12 +84,12 @@ grep 'migration_threshold=2048' out
 grep 'sequential_threshold=13' out
 grep 'random_threshold=4' out
 
-fi
-
 else
 # When MQ is emulated by SMQ policy it does not hold settings.
 # So just skip testing of param changes when sequential_threshold=0
 grep 'sequential_threshold=0' out
 fi
 
+fi  # have_cache 1 5 0
+
 vgremove -f $vg


