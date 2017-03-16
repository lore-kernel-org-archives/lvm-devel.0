From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 16 Mar 2017 03:53:25 -0400
Subject: master - tests: add missing --yes
Message-ID: <201703160753.v2G7rPZI009704@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7fa08ae4e80e37e102d77f8fe02902a68bf52d9c
Commit:        7fa08ae4e80e37e102d77f8fe02902a68bf52d9c
Parent:        e9b5a455e1ce1eebcf949be20c1dd282fdb00d75
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 16 08:44:44 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 16 08:44:44 2017 +0100

tests: add missing --yes

---
 test/shell/lvconvert-cache-chunks.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvconvert-cache-chunks.sh b/test/shell/lvconvert-cache-chunks.sh
index 918b55d..7fa5b72 100644
--- a/test/shell/lvconvert-cache-chunks.sh
+++ b/test/shell/lvconvert-cache-chunks.sh
@@ -33,7 +33,7 @@ test $(get lv_field $vg/cpool chunk_size --units s --nosuffix) -gt 1000
 lvcreate -L1M -n $lv1 $vg
 
 # Not let pass small chunks when caching origin
-fail lvconvert -H --chunksize 128K --cachepool $vg/cpool $vg/$lv1 >out 2>&1
+fail lvconvert -y -H --chunksize 128K --cachepool $vg/cpool $vg/$lv1 >out 2>&1
 cat out
 grep "too small chunk size" out
 


