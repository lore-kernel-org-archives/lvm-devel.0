From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 24 Oct 2017 10:17:47 -0400
Subject: master - tests:check lvconvert with /dev in vglvname
Message-ID: <201710241417.v9OEHlSQ025810@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=10c76ce35a294b3d5fc84bc8af3ff118168282d7
Commit:        10c76ce35a294b3d5fc84bc8af3ff118168282d7
Parent:        ea63a38f5a883238bfdabdb3f4af5d08f4499424
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 24 15:05:13 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 24 16:16:08 2017 +0200

tests:check lvconvert with /dev in vglvname

---
 test/shell/lvconvert-cache.sh |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvconvert-cache.sh b/test/shell/lvconvert-cache.sh
index df72f4f..c3742af 100644
--- a/test/shell/lvconvert-cache.sh
+++ b/test/shell/lvconvert-cache.sh
@@ -93,6 +93,12 @@ check lv_exists $vg $lv1 ${lv1}_cachepool
 lvremove -f $vg
 
 
+lvcreate -L 2 -n $lv1 $vg
+lvcreate --type cache-pool -l 1 -n ${lv1}_cachepool "$DM_DEV_DIR/$vg"
+lvconvert --cache --cachepool "$DM_DEV_DIR/$vg/${lv1}_cachepool" --cachemode writeback -Zy "$DM_DEV_DIR/$vg/$lv1"
+lvremove -f $vg
+
+
 lvcreate -n corigin -l 10 $vg
 lvcreate -n pool -l 10 $vg
 lvs -a -o +devices
@@ -124,8 +130,10 @@ invalid lvconvert --cache --cachepool $vg/$lv1
 INVALID=not
 # Single vg is required
 $INVALID lvconvert --type cache --cachepool $vg/$lv1 --poolmetadata $vg1/$lv2 $vg/$lv3
+$INVALID lvconvert --type cache --cachepool "$DM_DEV_DIR/$vg/$lv1" --poolmetadata "$DM_DEV_DIR/$vg1/$lv2" $vg/$lv3
 $INVALID lvconvert --type cache --cachepool $vg/$lv1 --poolmetadata $lv2 $vg1/$lv3
 $INVALID lvconvert --type cache --cachepool $vg1/$lv1 --poolmetadata $vg2/$lv2 $vg/$lv3
+$INVALID lvconvert --type cache --cachepool $vg1/$lv1 --poolmetadata $vg2/$lv2 "$DM_DEV_DIR/$vg/$lv3"
 $INVALID lvconvert --type cache-pool --poolmetadata $vg2/$lv2 $vg1/$lv1
 
 $INVALID lvconvert --cachepool $vg1/$lv1 --poolmetadata $vg2/$lv2


