From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 11 Jul 2014 11:34:49 +0000 (UTC)
Subject: master - tests: updates for new lvconvert
Message-ID: <20140711113449.CD7A960E3D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d7065f154e497ffe26006bf47b533b23383a8810
Commit:        d7065f154e497ffe26006bf47b533b23383a8810
Parent:        9f703d35a0ac4f74934ff8c7dc9e5610986caff6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jul 11 13:13:56 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jul 11 13:32:52 2014 +0200

tests: updates for new lvconvert

---
 test/shell/lvconvert-thin-raid.sh   |    4 ++--
 test/shell/lvconvert-thin.sh        |    4 ++--
 test/shell/pvmove-cache-segtypes.sh |    4 ++--
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/test/shell/lvconvert-thin-raid.sh b/test/shell/lvconvert-thin-raid.sh
index 7e5efbd..d7a353b 100644
--- a/test/shell/lvconvert-thin-raid.sh
+++ b/test/shell/lvconvert-thin-raid.sh
@@ -23,8 +23,8 @@ lvcreate -aey --nosync -L8M --type raid1 -m1 -n $lv2 $vg
 lvchange -an $vg/$lv1
 
 # conversion fails for internal volumes
-fail lvconvert --thinpool $vg/${lv1}_rimage_0
-fail lvconvert --yes --thinpool $vg/$lv1 --poolmetadata $vg/${lv2}_rimage_0
+invalid lvconvert --thinpool $vg/${lv1}_rimage_0
+invalid lvconvert --yes --thinpool $vg/$lv1 --poolmetadata $vg/${lv2}_rimage_0
 
 lvconvert --yes --thinpool $vg/$lv1 --poolmetadata $vg/$lv2
 
diff --git a/test/shell/lvconvert-thin.sh b/test/shell/lvconvert-thin.sh
index 4a200bb..80f55dd 100644
--- a/test/shell/lvconvert-thin.sh
+++ b/test/shell/lvconvert-thin.sh
@@ -80,7 +80,7 @@ fail lvconvert -c 4 --thinpool $vg/$lv1 --poolmetadata $vg/$lv2
 # too big chunk size fails
 fail lvconvert -c 2G --thinpool $vg/$lv1 --poolmetadata $vg/$lv2
 # negative chunk size fails
-fail lvconvert -c -256 --thinpool $vg/$lv1 --poolmetadata $vg/$lv2
+invalid lvconvert -c -256 --thinpool $vg/$lv1 --poolmetadata $vg/$lv2
 # non power of 2 fails
 fail lvconvert -c 88 --thinpool $vg/$lv1 --poolmetadata $vg/$lv2
 
@@ -93,7 +93,7 @@ lvcreate -L1T -n $lv1 $vg
 lvcreate -L32G -n $lv2 $vg
 # Warning about bigger then needed
 lvconvert --yes --thinpool $vg/$lv1 --poolmetadata $vg/$lv2 |& tee err
-grep "WARNING: Maximum size" err
+grep "WARNING: Maximum" err
 
 lvremove -f $vg
 
diff --git a/test/shell/pvmove-cache-segtypes.sh b/test/shell/pvmove-cache-segtypes.sh
index 94a3848..1f5c6d9 100644
--- a/test/shell/pvmove-cache-segtypes.sh
+++ b/test/shell/pvmove-cache-segtypes.sh
@@ -110,7 +110,7 @@ lvremove -ff $vg
 # Testing pvmove of a RAID cachepool (metadata and data)
 ########################################################
 lvcreate -l 2 -n ${lv1}_foo $vg "$dev1"
-lvcreate --type raid1 -L 2M -n meta $vg "$dev1" "$dev2"
+lvcreate --type raid1 -L 6M -n meta $vg "$dev1" "$dev2"
 lvcreate --type raid1 -L 4M -n ${lv1}_pool $vg "$dev1" "$dev2"
 lvconvert --yes --type cache-pool $vg/${lv1}_pool --poolmetadata $vg/meta
 lvcreate --type cache -n $lv1 -L 8M $vg/${lv1}_pool "$dev5"
@@ -142,7 +142,7 @@ lvremove -ff $vg
 #################################################
 lvcreate -l 2 -n ${lv1}_foo $vg "$dev1"
 # RAID for cachepool
-lvcreate --type raid1 -m 1 -L 2M -n meta $vg "$dev1" "$dev2"
+lvcreate --type raid1 -m 1 -L 4M -n meta $vg "$dev1" "$dev2"
 lvcreate --type raid1 -m 1 -L 4M -n cachepool $vg "$dev1" "$dev2"
 lvconvert --yes --type cache-pool $vg/cachepool --poolmetadata $vg/meta
 # RAID for thin pool data LV


