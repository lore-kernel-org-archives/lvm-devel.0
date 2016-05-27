From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 27 May 2016 13:48:00 +0000 (UTC)
Subject: master - tests: check cache_mode change on cachepool
Message-ID: <20160527134800.5E411600E4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a67adbfe2ea99ca5ae3e9e0712f3e4499e4480e0
Commit:        a67adbfe2ea99ca5ae3e9e0712f3e4499e4480e0
Parent:        090ecaabed9df1ead8781c6d504e1fe38ebcf7a4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 25 16:24:58 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 27 15:47:24 2016 +0200

tests: check cache_mode change on cachepool

---
 test/shell/lvchange-cache-mode.sh |   20 ++++++++++++++++++++
 1 files changed, 20 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvchange-cache-mode.sh b/test/shell/lvchange-cache-mode.sh
index 8a056d6..239960c 100644
--- a/test/shell/lvchange-cache-mode.sh
+++ b/test/shell/lvchange-cache-mode.sh
@@ -58,7 +58,13 @@ vgcfgbackup -f /tmp/ooo $vg
 #dmsetup resume $vg-$lv1
 
 #dmsetup load --table "0 28672 cache 253:4 253:3 253:5 128 1 passthrough smq 2 migration_threshold 204800" $vg-$lv1
+#dmsetup status $vg-$lv1
+#dmsetup load --table "0 28672 cache 253:4 253:3 253:5 128 1 writethrough smq 2 migration_threshold 204800" $vg-$lv1
 #dmsetup resume $vg-$lv1
+#dmsetup status $vg-$lv1
+#dmsetup table  $vg-$lv1
+#dmsetup ls --tree
+#exit
 
 check lv_field $vg/$lv1 cache_mode "writeback"
 lvchange --cachemode passthrough $vg/$lv1
@@ -68,4 +74,18 @@ check lv_field  $vg/$lv1 cache_mode "writethrough"
 lvchange --cachemode writeback $vg/$lv1
 check lv_field  $vg/$lv1 cache_mode "writeback"
 
+lvconvert --splitcache $vg/$lv1
+
+lvs -a $vg
+
+check lv_field $vg/cpool cache_mode "writeback"
+lvchange --cachemode passthrough $vg/cpool
+check lv_field  $vg/cpool cache_mode "passthrough"
+lvchange --cachemode writethrough $vg/cpool
+check lv_field  $vg/cpool cache_mode "writethrough"
+lvchange --cachemode writeback $vg/cpool
+check lv_field  $vg/cpool cache_mode "writeback"
+
+lvs -a $vg
+
 vgremove -f $vg


