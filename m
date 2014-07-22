From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 22 Jul 2014 22:26:27 +0000 (UTC)
Subject: master - tests: support cluster run
Message-ID: <20140722222627.E584A61052@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=22be7c441784fd89cf76cb6ed56fd50da126864d
Commit:        22be7c441784fd89cf76cb6ed56fd50da126864d
Parent:        3a8bb8d3a4ef379298e97ca5f087a1c8908841ed
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jul 23 00:25:49 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 23 00:25:49 2014 +0200

tests: support cluster run

needs exclusive activation
---
 test/shell/lvcreate-cache.sh |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/test/shell/lvcreate-cache.sh b/test/shell/lvcreate-cache.sh
index 4274897..03ff214 100644
--- a/test/shell/lvcreate-cache.sh
+++ b/test/shell/lvcreate-cache.sh
@@ -71,14 +71,14 @@ lvremove -f $vg/cache_pool
 
 # Bug 1110026
 # Create origin, then cache_pool and cache
-lvcreate -l 2 -n $lv1 $vg
+lvcreate -aey -l 2 -n $lv1 $vg
 lvcreate --type cache -l 1 $vg/$lv1
 #should dmsetup table ${vg}-$lv1 | grep cache  # ensure it is loaded in kernel
 lvremove -ff $vg
 
 # Bug 1110026 & Bug 1095843
 # Create RAID1 origin, then cache_pool and cache
-lvcreate -l 2 -n $lv1 $vg
+lvcreate -aey -l 2 -n $lv1 $vg
 lvcreate --type cache -l 1 $vg/$lv1
 #should lvs -a $vg/${lv1}_corig_rimage_0        # ensure images are properly renamed
 #should dmsetup table ${vg}-$lv1 | grep cache  # ensure it is loaded in kernel
@@ -101,7 +101,7 @@ done
 ##############################
 
 # Attempt to create smaller cache than origin should fail
-lvcreate -l 1 -n $lv1 $vg
+lvcreate -aey -l 1 -n $lv1 $vg
 not lvcreate --type cache -l 2 $vg/$lv1
 
 


