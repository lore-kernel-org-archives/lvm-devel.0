From: Petr Rockai <prockai@redhat.com>
Date: Mon, 15 Dec 2014 23:32:40 +0100
Subject: [PATCH 4/4] test: Check that cache settings properly survive LV reactivation.
In-Reply-To: <1418682760-16427-1-git-send-email-prockai@redhat.com>
References: <1418682760-16427-1-git-send-email-prockai@redhat.com>
Message-ID: <1418682760-16427-4-git-send-email-prockai@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

---
 test/shell/lvcreate-cache.sh | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/test/shell/lvcreate-cache.sh b/test/shell/lvcreate-cache.sh
index f709d8b..89efc4d 100644
--- a/test/shell/lvcreate-cache.sh
+++ b/test/shell/lvcreate-cache.sh
@@ -230,6 +230,9 @@ lvcreate --type cache-pool -L10 $vg/cpool
 lvcreate --type cache -l 1 --cachepool $vg/cpool -n corigin $vg --cachepolicy mq --cachesettings migration_threshold=233
 dmsetup status | grep $vg
 dmsetup status | grep $vg-corigin | grep 'migration_threshold 233'
+lvchange -an $vg
+lvchange -ay $vg
+dmsetup status | grep $vg-corigin | grep 'migration_threshold 233'
 
 lvremove -f $vg
 
-- 
2.1.2


