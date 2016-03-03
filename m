From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  3 Mar 2016 09:20:14 +0000 (UTC)
Subject: master - tests: check kernel_cache_ funcs
Message-ID: <20160303092014.D2E31605CD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=49839b6d9677f40993b2468bc85e8cc8c82f9a8e
Commit:        49839b6d9677f40993b2468bc85e8cc8c82f9a8e
Parent:        e04a0184cb046c28428c65e52afc28ec591c50cf
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 2 11:12:14 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 3 10:17:03 2016 +0100

tests: check kernel_cache_ funcs

---
 test/shell/lvchange-cache.sh |   52 ++++++++++++++++++++++++-----------------
 1 files changed, 30 insertions(+), 22 deletions(-)

diff --git a/test/shell/lvchange-cache.sh b/test/shell/lvchange-cache.sh
index 3fd326a..ca7522a 100644
--- a/test/shell/lvchange-cache.sh
+++ b/test/shell/lvchange-cache.sh
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2014 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2014-2016 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -31,44 +31,52 @@ not lvchange --cachepolicy mq $vg/noncache
 not lvchange --cachesettings foo=bar $vg/noncache
 
 lvchange --cachepolicy cleaner $vg/corigin
-dmsetup status | grep $vg-corigin | grep 'cleaner'
+check lv_field  $vg/corigin kernel_cache_policy "cleaner"
 
 lvchange --cachepolicy mq --cachesettings migration_threshold=333 $vg/corigin
-dmsetup status | grep $vg-corigin | not grep 'cleaner'
-dmsetup status | grep $vg-corigin | grep 'mq'
-dmsetup status | grep $vg-corigin | grep 'migration_threshold 333'
+
+# TODO once mq->smq happens we will get here some 0 for mq settings
+check lv_field $vg/corigin kernel_cache_policy "mq"
+get lv_field $vg/corigin kernel_cache_settings | grep 'migration_threshold=333'
+
 lvchange --refresh $vg/corigin
-dmsetup status | grep $vg-corigin | grep 'migration_threshold 333'
+get lv_field $vg/corigin kernel_cache_settings | grep 'migration_threshold=333'
 lvchange -an $vg
 lvchange -ay $vg
-dmsetup status | grep $vg-corigin | grep 'migration_threshold 333'
+get lv_field $vg/corigin kernel_cache_settings | grep 'migration_threshold=333'
 
 lvchange --cachesettings 'migration_threshold = 233 sequential_threshold = 13' $vg/corigin
-dmsetup status | grep $vg-corigin | grep 'migration_threshold 233'
-dmsetup status | grep $vg-corigin | grep 'sequential_threshold 13'
+get lv_field $vg/corigin kernel_cache_settings | tee out
+grep 'migration_threshold=233' out
+grep 'sequential_threshold=13' out
 
 lvchange --cachesettings 'migration_threshold = 17' $vg/corigin
-dmsetup status | grep $vg-corigin | grep 'migration_threshold 17'
-dmsetup status | grep $vg-corigin | grep 'sequential_threshold 13'
+get lv_field $vg/corigin kernel_cache_settings | tee out
+grep 'migration_threshold=17' out
+grep 'sequential_threshold=13' out
 
 lvchange --cachesettings 'migration_threshold = default' $vg/corigin
-dmsetup status | grep $vg-corigin | grep 'migration_threshold 2048'
-dmsetup status | grep $vg-corigin | grep 'sequential_threshold 13'
+get lv_field $vg/corigin kernel_cache_settings | tee out
+grep 'migration_threshold=2048' out
+grep 'sequential_threshold=13' out
 
 lvchange --cachesettings 'migration_threshold = 233 sequential_threshold = 13 random_threshold = 1' $vg/corigin
 lvchange --cachesettings 'random_threshold = default migration_threshold = default' $vg/corigin
-dmsetup status | grep $vg-corigin | grep 'migration_threshold 2048'
-dmsetup status | grep $vg-corigin | grep 'sequential_threshold 13'
-dmsetup status | grep $vg-corigin | grep 'random_threshold 4'
+get lv_field $vg/corigin kernel_cache_settings | tee out
+grep 'migration_threshold=2048' out
+grep 'sequential_threshold=13' out
+grep 'random_threshold=4' out
 
 lvchange --cachesettings migration_threshold=233 --cachesettings sequential_threshold=13 --cachesettings random_threshold=1 $vg/corigin
-dmsetup status | grep $vg-corigin | grep 'migration_threshold 233 '
-dmsetup status | grep $vg-corigin | grep 'sequential_threshold 13 '
-dmsetup status | grep $vg-corigin | grep 'random_threshold 1 '
+get lv_field $vg/corigin kernel_cache_settings | tee out
+grep 'migration_threshold=233' out
+grep 'sequential_threshold=13' out
+grep 'random_threshold=1' out
 
 lvchange --cachesettings random_threshold=default --cachesettings migration_threshold=default $vg/corigin
-dmsetup status | grep $vg-corigin | grep 'migration_threshold 2048 '
-dmsetup status | grep $vg-corigin | grep 'sequential_threshold 13 '
-dmsetup status | grep $vg-corigin | grep 'random_threshold 4 '
+get lv_field $vg/corigin kernel_cache_settings | tee out
+grep 'migration_threshold=2048' out
+grep 'sequential_threshold=13' out
+grep 'random_threshold=4' out
 
 vgremove -f $vg


