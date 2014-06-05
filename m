From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  5 Jun 2014 21:09:31 +0000 (UTC)
Subject: master - tests: fix test compare
Message-ID: <20140605210931.4976960B42@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7b8133e0b2cf43ef8221ce14eb140bda7490ab15
Commit:        7b8133e0b2cf43ef8221ce14eb140bda7490ab15
Parent:        eb7ca96b5901d3bf70f0ba193bee55fc616b1805
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 5 23:06:45 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 5 23:06:45 2014 +0200

tests: fix test compare

Comparing 64T can't use -eq
---
 test/shell/lvconvert-thin.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvconvert-thin.sh b/test/shell/lvconvert-thin.sh
index a7bbe9f..2ce43b8 100644
--- a/test/shell/lvconvert-thin.sh
+++ b/test/shell/lvconvert-thin.sh
@@ -97,7 +97,7 @@ grep "WARNING: Maximum size" err
 
 lvremove -f $vg
 
-if test "$TSIZE" -eq 64T; then
+if test "$TSIZE" = 64T; then
 lvcreate -L24T -n $lv1 $vg
 # Warning about bigger then needed (24T data and 16G -> 128K chunk)
 lvconvert --yes -c 64 --thinpool $vg/$lv1 |& tee err


