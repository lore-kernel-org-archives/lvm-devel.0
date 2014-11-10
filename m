From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 10 Nov 2014 21:06:50 +0000 (UTC)
Subject: master - tests: reach cache params
Message-ID: <20141110210650.F3BB360789@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=094596cfd2001a8714923dd87abb2feacd116a13
Commit:        094596cfd2001a8714923dd87abb2feacd116a13
Parent:        10ebabdd2a8c686d814205fd923229572eebdd3a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 10 21:29:20 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 10 22:05:49 2014 +0100

tests: reach cache params

---
 test/shell/lvcreate-cache.sh |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/test/shell/lvcreate-cache.sh b/test/shell/lvcreate-cache.sh
index b37f321..eeba827 100644
--- a/test/shell/lvcreate-cache.sh
+++ b/test/shell/lvcreate-cache.sh
@@ -206,14 +206,17 @@ lvremove -f $vg
 # Validate args are properly preserved #
 ########################################
 lvcreate --type cache-pool -L10 --chunksize 256 --cachemode writeback $vg/cpool1
-lvcreate -H -L10 $vg/cpool1
 check lv_field $vg/cpool1 chunksize "256.00k"
 check lv_field $vg/cpool1 cachemode "writeback"
+lvcreate -H -L10 -n $lv1 $vg/cpool1
+lvs -a -o+cachemode,chunksize $vg
+check lv_field $vg/$lv1 chunksize "256.00k"
+check lv_field $vg/$lv1 cachemode "writeback"
 
 lvcreate --type cache-pool -L10 --chunksize 256 --cachemode writethrough $vg/cpool2
-lvcreate -H -L10 --chunksize 512 --cachemode writeback $vg/cpool2
-check lv_field $vg/cpool2 chunksize "512.00k"
-check lv_field $vg/cpool2 cachemode "writeback"
+lvcreate -H -L10 --chunksize 512 --cachemode writeback -n $lv2 $vg/cpool2
+check lv_field $vg/$lv2 chunksize "512.00k"
+check lv_field $vg/$lv2 cachemode "writeback"
 
 # Chunk bigger then pool size
 fail lvcreate --type cache-pool -l1 --chunksize 1G $vg/cpool3


