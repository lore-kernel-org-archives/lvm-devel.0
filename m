From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  7 Oct 2014 07:32:57 +0000 (UTC)
Subject: master - test: Creating a cache on top of active RAID works now.
Message-ID: <20141007073257.DC90560C85@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b836525d9cc267a04881b82935a6a045753631bf
Commit:        b836525d9cc267a04881b82935a6a045753631bf
Parent:        888da17495bc4b8a62833315cf7ad1a0bfd8fe2a
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Oct 7 09:31:21 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Tue Oct 7 09:32:24 2014 +0200

test: Creating a cache on top of active RAID works now.

---
 test/shell/lvconvert-cache.sh |    3 ---
 test/shell/lvcreate-cache.sh  |    5 +----
 2 files changed, 1 insertions(+), 7 deletions(-)

diff --git a/test/shell/lvconvert-cache.sh b/test/shell/lvconvert-cache.sh
index 1c62309..d2f591f 100644
--- a/test/shell/lvconvert-cache.sh
+++ b/test/shell/lvconvert-cache.sh
@@ -90,11 +90,8 @@ fail lvconvert --type cache --cachepool $vg/pool $vg/corigin
 lvconvert --yes --cache --cachepool $vg/pool $vg/corigin
 lvremove -ff $vg
 
-
-# TODO: creating a cache on top of active RAID appears to be broken
 lvcreate -n corigin -m 1 --type raid1 -l 10 $vg
 lvcreate -n cpool --type cache $vg/corigin -l 10
-lvchange --refresh $vg # fix up DM tables
 lvconvert --splitmirrors 1 --name split $vg/corigin $dev1
 
 lvremove -f $vg
diff --git a/test/shell/lvcreate-cache.sh b/test/shell/lvcreate-cache.sh
index 63591c4..3bc8f40 100644
--- a/test/shell/lvcreate-cache.sh
+++ b/test/shell/lvcreate-cache.sh
@@ -156,13 +156,10 @@ grep "is bigger" out
 # --poolmetadatasize
 # --poolmetadataspare
 
-# TODO: creating a cache on top of active RAID appears to be broken
 lvremove -f $vg
 lvcreate -n corigin -m 1 --type raid1 -l 10 $vg
 lvcreate -n cpool --type cache $vg/corigin -l 10
-should check active $vg corigin_corig
-dmsetup table | grep ^$PREFIX | should grep corigin_corig
-lvchange --refresh $vg
+check active $vg corigin_corig
 dmsetup table | grep ^$PREFIX | grep corigin_corig
 
 vgremove -ff $vg


