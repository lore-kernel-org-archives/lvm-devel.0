From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  7 Oct 2014 08:20:33 +0000 (UTC)
Subject: master - tests: check for cache and raid
Message-ID: <20141007082033.88583602D9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=75c4d268e9b0b70c58f8b8b018fe200aca7b8bb2
Commit:        75c4d268e9b0b70c58f8b8b018fe200aca7b8bb2
Parent:        c59ef732067988b708c7f809719ff887596a1e9f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 7 10:12:49 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 7 10:19:33 2014 +0200

tests: check for cache and raid

Skip some tests on systems without cache or raid.
---
 test/shell/lvconvert-cache.sh |    4 ++--
 test/shell/lvconvert-thin.sh  |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/test/shell/lvconvert-cache.sh b/test/shell/lvconvert-cache.sh
index ae2de35..4f266ba 100644
--- a/test/shell/lvconvert-cache.sh
+++ b/test/shell/lvconvert-cache.sh
@@ -121,10 +121,10 @@ fail lvconvert --yes --type cache $vg/$lv2 --cachepool $vg/$lv1
 fail lvconvert --yes --type cache $vg/$lv1 --cachepool $vg/$lv2
 fail lvconvert --yes --type cache-pool $vg/$lv1
 fail lvconvert --yes --type mirror -m1 $vg/$lv1
-fail lvconvert --yes --type raid1 -m1 $vg/$lv1
+not aux have_raid 1 0 0 || fail lvconvert --yes --type raid1 -m1 $vg/$lv1
 fail lvconvert --yes --type snapshot $vg/$lv1 $vg/$lv2
 fail lvconvert --yes --type snapshot $vg/$lv2 $vg/$lv1
-fail lvconvert --yes -T --thinpool $vg/$lv2 $vg/$lv1
+not aux have_thin 1 0 0 || fail lvconvert --yes -T --thinpool $vg/$lv2 $vg/$lv1
 
 lvremove -f $vg
 
diff --git a/test/shell/lvconvert-thin.sh b/test/shell/lvconvert-thin.sh
index bd43d58..e61e470 100644
--- a/test/shell/lvconvert-thin.sh
+++ b/test/shell/lvconvert-thin.sh
@@ -134,9 +134,9 @@ lvcreate -L32 -n $lv1 $vg
 lvcreate -L16 -n $lv2 $vg
 lvconvert --yes --thinpool $vg/$lv1
 
-fail lvconvert --yes --type cache-pool $vg/$lv1
+not aux have_cache 1 3 0 || fail lvconvert --yes --type cache-pool $vg/$lv1
 fail lvconvert --yes --type mirror -m1 $vg/$lv1
-fail lvconvert --yes --type raid1 -m1 $vg/$lv1
+not aux have_raid 1 0 0 || fail lvconvert --yes --type raid1 -m1 $vg/$lv1
 fail lvconvert --yes --type snapshot $vg/$lv1 $vg/$lv2
 fail lvconvert --yes --type snapshot $vg/$lv2 $vg/$lv1
 fail lvconvert --yes --type thin-pool $vg/$lv1


