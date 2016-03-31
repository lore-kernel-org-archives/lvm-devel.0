From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 31 Mar 2016 10:22:20 +0000 (UTC)
Subject: master - tests: do not test settings when MQ is emulated by SMQ
Message-ID: <20160331102220.2315C60DEB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bc5376b151f4a5993c223de51f0218aa95184471
Commit:        bc5376b151f4a5993c223de51f0218aa95184471
Parent:        5034bb8d180a496fc24cd0ac0d8dde2332d28bc2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 31 11:59:55 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 31 12:21:40 2016 +0200

tests: do not test settings when MQ is emulated by SMQ

---
 test/shell/lvchange-cache.sh |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvchange-cache.sh b/test/shell/lvchange-cache.sh
index ca7522a..06d2f09 100644
--- a/test/shell/lvchange-cache.sh
+++ b/test/shell/lvchange-cache.sh
@@ -48,7 +48,8 @@ get lv_field $vg/corigin kernel_cache_settings | grep 'migration_threshold=333'
 lvchange --cachesettings 'migration_threshold = 233 sequential_threshold = 13' $vg/corigin
 get lv_field $vg/corigin kernel_cache_settings | tee out
 grep 'migration_threshold=233' out
-grep 'sequential_threshold=13' out
+
+if grep 'sequential_threshold=13' out ; then
 
 lvchange --cachesettings 'migration_threshold = 17' $vg/corigin
 get lv_field $vg/corigin kernel_cache_settings | tee out
@@ -79,4 +80,10 @@ grep 'migration_threshold=2048' out
 grep 'sequential_threshold=13' out
 grep 'random_threshold=4' out
 
+else
+# When MQ is emulated by SMQ policy it does not hold settings.
+# So just skip testing of param changes when sequential_threshold=0
+grep 'sequential_threshold=0' out
+fi
+
 vgremove -f $vg


