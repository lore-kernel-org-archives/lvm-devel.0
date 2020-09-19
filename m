From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 19 Sep 2020 22:38:59 +0000 (GMT)
Subject: master - tests: check for cvol
Message-ID: <20200919223859.03950395CC7C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e556c7b7c641c78f7bdd94120d6e79860a6220aa
Commit:        e556c7b7c641c78f7bdd94120d6e79860a6220aa
Parent:        6c769eb460c70556ba4bf2b3e6801fc846b2d4dd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Sep 19 23:02:17 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Sep 19 23:02:17 2020 +0200

tests: check for cvol

Check for cvol.
Add check for cmeta.
---
 test/shell/integrity.sh | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/test/shell/integrity.sh b/test/shell/integrity.sh
index be435976e..1f031e0ed 100644
--- a/test/shell/integrity.sh
+++ b/test/shell/integrity.sh
@@ -782,7 +782,7 @@ lvcreate --type raid1 -m1 -n $lv1 -l 8 $vg
 lvcreate --type raid1 -m1 -n $lv2 -l 8 $vg
 lvconvert -y --type cache --cachevol $lv2 $vg/$lv1
 not lvconvert --raidintegrity y $vg/${lv1}_corig
-not lvconvert --raidintegrity y $vg/${lv2}_vol
+not lvconvert --raidintegrity y $vg/${lv2}_cvol
 lvremove -y $vg/$lv1
 
 lvcreate --type raid1 -m1 -n $lv1 -l 8 $vg
@@ -790,6 +790,7 @@ lvcreate --type raid1 -m1 -n $lv2 -l 8 $vg
 lvconvert -y --type cache --cachepool $lv2 $vg/$lv1
 not lvconvert --raidintegrity y $vg/${lv1}_corig
 not lvconvert --raidintegrity y $vg/${lv2}_cpool_cdata
+not lvconvert --raidintegrity y $vg/${lv2}_cpool_cmeta
 lvremove -y $vg/$lv1
 
 # cannot add integrity to raid that has a snapshot


