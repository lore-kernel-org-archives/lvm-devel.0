From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 9 Jun 2017 07:05:00 -0400
Subject: master - tests: no longer allowed too big thin-pools for small chunks
Message-ID: <201706091105.v59B50CT003861@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b6945b85106620cb79730070e9a38ed93e7fc35a
Commit:        b6945b85106620cb79730070e9a38ed93e7fc35a
Parent:        5017284709102834c21bed408e54fccde8523d51
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 9 12:58:25 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 9 13:03:42 2017 +0200

tests: no longer allowed too big thin-pools for small chunks

---
 test/shell/lvconvert-thin.sh    |    2 +-
 test/shell/lvcreate-thin-big.sh |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/shell/lvconvert-thin.sh b/test/shell/lvconvert-thin.sh
index c08b95a..992a1f2 100644
--- a/test/shell/lvconvert-thin.sh
+++ b/test/shell/lvconvert-thin.sh
@@ -135,7 +135,7 @@ lvremove -f $vg
 if test "$TSIZE" = 64T; then
 lvcreate -L24T -n $lv1 $vg
 # Warning about bigger then needed (24T data and 16G -> 128K chunk)
-lvconvert --yes -c 64 --thinpool $vg/$lv1 2>&1 | tee err
+fail lvconvert --yes -c 64 --thinpool $vg/$lv1 2>&1 | tee err
 grep "WARNING: Chunk size is too small" err
 lvremove -f $vg
 fi
diff --git a/test/shell/lvcreate-thin-big.sh b/test/shell/lvcreate-thin-big.sh
index da7812f..9c84288 100644
--- a/test/shell/lvcreate-thin-big.sh
+++ b/test/shell/lvcreate-thin-big.sh
@@ -36,7 +36,7 @@ grep "WARNING: Minimum" out
 lvcreate -L4M --chunksize 64k --poolmetadatasize 17G -T $vg/pool2 2>out
 grep "WARNING: Maximum" out
 check lv_field $vg/pool1_tmeta size "2.00m"
-check lv_field $vg/pool2_tmeta size "16.00g"
+check lv_field $vg/pool2_tmeta size "15.81g"
 
 # Check can start and see thinpool with metadata size above kernel limit
 lvcreate -L4M --poolmetadatasize 16G -T $vg/poolM


