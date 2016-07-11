From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 11 Jul 2016 13:48:06 +0000 (UTC)
Subject: master - tests: skip some tests for older cache driver
Message-ID: <20160711134806.A218F60B68@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=06a9dab730f5b1636c19ffd47124d76e60447efd
Commit:        06a9dab730f5b1636c19ffd47124d76e60447efd
Parent:        6336b5dedf2a7adbc32fb7ae4f7f7aa1d9cda75a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 11 15:45:28 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 11 15:45:28 2016 +0200

tests: skip some tests for older cache driver

Cache target 1.4 on f19 kernel shows error, skipping some tests...
---
 test/shell/lvchange-cache.sh |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvchange-cache.sh b/test/shell/lvchange-cache.sh
index 06d2f09..25c59b1 100644
--- a/test/shell/lvchange-cache.sh
+++ b/test/shell/lvchange-cache.sh
@@ -68,6 +68,10 @@ grep 'migration_threshold=2048' out
 grep 'sequential_threshold=13' out
 grep 'random_threshold=4' out
 
+# Skip these test on older cache driver as it shows errors with these lvchanges
+# device-mapper: space map common: index_check failed: blocknr 17179869216 != wanted 11
+if aux have_cache 1 5 0 ; then
+
 lvchange --cachesettings migration_threshold=233 --cachesettings sequential_threshold=13 --cachesettings random_threshold=1 $vg/corigin
 get lv_field $vg/corigin kernel_cache_settings | tee out
 grep 'migration_threshold=233' out
@@ -80,6 +84,8 @@ grep 'migration_threshold=2048' out
 grep 'sequential_threshold=13' out
 grep 'random_threshold=4' out
 
+fi
+
 else
 # When MQ is emulated by SMQ policy it does not hold settings.
 # So just skip testing of param changes when sequential_threshold=0


