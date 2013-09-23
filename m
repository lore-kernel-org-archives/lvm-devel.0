From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 23 Sep 2013 10:16:38 +0000 (UTC)
Subject: master - tests: drop extra loop
Message-ID: <20130923101638.5507760FFF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9658032cba4f6a2350bb35d5133a436bad84fec2
Commit:        9658032cba4f6a2350bb35d5133a436bad84fec2
Parent:        151f4ba64e5b7384ccb6ec7e603d05ba38dc561c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 19 14:04:18 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 23 12:14:21 2013 +0200

tests: drop extra loop

Loop was added as a result of unworking singlenode locking, since
this should be now fixed - remove this workaround.
---
 test/shell/snapshot-merge.sh |    7 -------
 1 files changed, 0 insertions(+), 7 deletions(-)

diff --git a/test/shell/snapshot-merge.sh b/test/shell/snapshot-merge.sh
index 0713934..8760e53 100644
--- a/test/shell/snapshot-merge.sh
+++ b/test/shell/snapshot-merge.sh
@@ -78,13 +78,6 @@ dm_table $vg-$lv1 | grep " snapshot-merge " || dm_table $vg-$lv1 | grep " linear
 #    may test stopping an active merge
 lvremove -f $vg/$lv1
 
-# wait a while if the merge and remove is still not finished
-# since it may still keep  $lv1  in vg being present
-for i in 1 2 3 4 ; do
-	lvs $vg/$lv1 2>/dev/null || break;
-	sleep .2
-done
-
 # "onactivate merge" test
 # -- deactivate/remove after disallowed merge attempt, tests
 #    to make sure preload of origin's metadata is _not_ performed


