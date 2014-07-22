From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 22 Jul 2014 20:42:09 +0000 (UTC)
Subject: master - tests: new lvconvert features
Message-ID: <20140722204209.E3C73605FC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=653fd7bee3d9f765fdf81743331f2d9e91ea28bf
Commit:        653fd7bee3d9f765fdf81743331f2d9e91ea28bf
Parent:        ee11bb841612ec4dba173c31bf795a8560ca134e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jul 11 12:15:46 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jul 22 22:41:41 2014 +0200

tests: new lvconvert features

---
 test/shell/lvconvert-cache.sh         |   44 +++++++++++++++++++++++++++++++-
 test/shell/lvconvert-thin-external.sh |    2 +-
 test/shell/lvconvert-thin.sh          |   12 ++++++--
 3 files changed, 52 insertions(+), 6 deletions(-)

diff --git a/test/shell/lvconvert-cache.sh b/test/shell/lvconvert-cache.sh
index 79d5fd1..6c2acd9 100644
--- a/test/shell/lvconvert-cache.sh
+++ b/test/shell/lvconvert-cache.sh
@@ -16,10 +16,50 @@ aux have_cache 1 3 0 || skip
 aux prepare_vg 5 80
 
 # lvcreate origin, lvcreate cache-pool, and lvconvert to cache
-lvcreate -l 2 -n $lv1 $vg
+lvcreate -L 2 -n $lv1 $vg
+lvcreate -L 8 -n $lv2 $vg
+lvcreate -L 8 -n $lv3 $vg
+
+# undefined cachepool
+invalid lvconvert --type cache --poolmetadata $vg/$lv2 $vg/$lv1
+
+# cannot mix with thins
+invalid lvconvert --type cache --poolmetadata $vg/$lv2 --thinpool $vg/$lv1
+invalid lvconvert --type cache --thin --poolmetadata $vg/$lv2 $vg/$lv1
+
+# undefined cached volume
+invalid lvconvert --type cache --cachepool $vg/$lv1
+invalid lvconvert --cache --cachepool $vg/$lv1
+
+# single vg
+invalid lvconvert --type cache --cachepool $vg/$lv1 --poolmetadata $vg1/$lv2 $vg/$lv3
+invalid lvconvert --type cache --cachepool $vg/$lv1 --poolmetadata $lv2 $vg1/$lv3
+invalid lvconvert --type cache --cachepool $vg1/$lv1 --poolmetadata $vg2/$lv2 $vg/$lv3
+
+invalid lvconvert --cachepool $vg1/$lv1 --poolmetadata $vg2/$lv2
+invalid lvconvert --type cache-pool --poolmetadata $vg2/$lv2 $vg1/$lv1
+
+fail lvconvert --yes --type cache-pool --chunksize 16M --poolmetadata $lv2 $vg/$lv1
+
+lvconvert --yes --type cache-pool --cachepool $vg/$lv1
+
+#fail lvconvert --cachepool $vg/$lv1 --poolmetadata $vg/$lv2
+#lvconvert --yes --type cache-pool --poolmetadata $vg/$lv2 $vg/$lv1
+#lvconvert --yes --poolmetadata $vg/$lv2 --cachepool $vg/$lv1
+
+lvremove -ff $vg
+
+lvcreate -L 2 -n $lv1 $vg
 lvcreate --type cache-pool -l 1 -n ${lv1}_cachepool $vg
-lvconvert --type cache --cachepool $vg/${lv1}_cachepool $vg/$lv1
+
+lvconvert --cache --cachepool $vg/${lv1}_cachepool $vg/$lv1
 dmsetup table ${vg}-$lv1 | grep cache  # ensure it is loaded in kernel
+
+#lvconvert --cachepool $vg/${lv1}_cachepool $vg/$lv1
+#lvconvert --cachepool $vg/${lv1}_cachepool --poolmetadatasize 20 "$dev3"
+
+
+fail lvconvert --type cache --cachepool $vg/${lv1}_cachepool $vg/$lv1
 lvremove -ff $vg
 
 # Bug 1095843
diff --git a/test/shell/lvconvert-thin-external.sh b/test/shell/lvconvert-thin-external.sh
index 676851e..1e9887a 100644
--- a/test/shell/lvconvert-thin-external.sh
+++ b/test/shell/lvconvert-thin-external.sh
@@ -109,7 +109,7 @@ lvchange -aey $vg
 lvs -a -o+origin_size,seg_size $vg
 
 # Chain external origins
-lvconvert --originname extorg1 --thinpool $vg/pool -T $vg/extorg
+lvconvert --type thin --originname extorg1 --thinpool $vg/pool $vg/extorg
 check inactive $vg extorg1
 
 lvconvert --originname extorg2 --thinpool $vg/pool -T $vg/extorg1
diff --git a/test/shell/lvconvert-thin.sh b/test/shell/lvconvert-thin.sh
index 80f55dd..4aee7d2 100644
--- a/test/shell/lvconvert-thin.sh
+++ b/test/shell/lvconvert-thin.sh
@@ -12,8 +12,7 @@
 
 . lib/inittest
 
-prepare_lvs()
-{
+prepare_lvs() {
 	lvremove -f $vg
 	lvcreate -L10M -n $lv1 $vg
 	lvcreate -L8M -n $lv2 $vg
@@ -38,6 +37,13 @@ aux extend_filter_LVMTEST
 pvcreate "$DM_DEV_DIR/$vg1/$lv"
 vgcreate $vg -s 64K $(tail -n+4 DEVICES) "$DM_DEV_DIR/$vg1/$lv"
 
+lvcreate -L1T -n $lv1 $vg
+invalid lvconvert --yes -c 8M --type thin --poolmetadatasize 1G $vg/$lv1
+
+# needs some --cachepool or --thinpool
+invalid lvconvert --yes --poolmetadatasize 1G $vg/$lv1
+lvremove -f $vg
+
 # create mirrored LVs for data and metadata volumes
 lvcreate -aey -L10M --type mirror -m1 --mirrorlog core -n $lv1 $vg
 lvcreate -aey -L10M -n $lv2 $vg
@@ -60,7 +66,7 @@ lvconvert --yes -c 64 --stripes 2 --thinpool $vg/$lv1 --readahead 48
 
 lvremove -f $vg
 lvcreate -L1T -n $lv1 $vg
-lvconvert --yes -c 8M --thinpool $vg/$lv1
+lvconvert --yes -c 8M --type thin-pool $vg/$lv1
 
 lvremove -f $vg
 # test with bigger sizes


