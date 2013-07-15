From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 15 Jul 2013 14:03:14 +0000 (UTC)
Subject: master - tests: more thin external origin tests
Message-ID: <20130715140314.08D2460E80@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3498575b20c3dad46ba4e76fe8a9c3d95f75d1de
Commit:        3498575b20c3dad46ba4e76fe8a9c3d95f75d1de
Parent:        9a060948242e830555436678f5b15b84bca70b04
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 15 14:46:52 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 15 16:01:28 2013 +0200

tests: more thin external origin tests

---
 test/shell/lvconvert-thin-external.sh |   73 +++++++++++++++++++++-----------
 test/shell/lvcreate-thin-external.sh  |   20 +++++-----
 2 files changed, 58 insertions(+), 35 deletions(-)

diff --git a/test/shell/lvconvert-thin-external.sh b/test/shell/lvconvert-thin-external.sh
index 1bcf0b6..9f53fcb 100644
--- a/test/shell/lvconvert-thin-external.sh
+++ b/test/shell/lvconvert-thin-external.sh
@@ -24,12 +24,32 @@ aux have_thin 1 5 0 || skip
 
 aux prepare_pvs 2 64
 
-vgcreate $vg -s 64K $(cat DEVICES)
+vgcreate $vg --metadatasize 128K -s 64K $(cat DEVICES)
 
-# create thin pool
-lvcreate -L8M -T $vg/pool
+if test 0 -eq 1 ; then
+# FIXME: needs patch to allow inactive old-snap creation
+lvcreate -l10 -T $vg/pool
+lvcreate -an -pr --zero n -l10 --name $lv1 $vg
+lvcreate -s $vg/$lv1 --name $lv2 --thinpool $vg/pool
+vgchange -an $vg
+# oldstyle read-only inactive snapshot
+lvcreate -an -s $vg/$lv2 -l10 -p r --name $lv3
 
-# create plain LV
+lvcreate -s $vg/$lv3 --name $lv4 --thinpool $vg/pool
+lvremove -ff $vg/$lv3
+
+lvremove -ff $vg
+fi
+
+#lvcreate -L20M --name orig $vg
+#lvconvert -T  --thinpool $vg/pool $vg/orig
+#lvcreate -s -aey -L10M $vg/orig
+#lvremove -f $vg
+#exit 0
+
+lvcreate -l10 -T $vg/pool
+
+# create plain LV (will be used for external origin)
 lvcreate -L8M -n $lv1 $vg
 
 mkfs.ext2 $DM_DEV_DIR/$vg/$lv1
@@ -44,14 +64,17 @@ dd if=/dev/zero of=mnt/test1 bs=1M count=1
 lvconvert -T --originname extorg --thinpool $vg/pool $vg/$lv1
 
 check active $vg $lv1
+# FIXME  handling attr is ...
+get lv_field $vg/extorg attr | grep "^ori"
 check inactive $vg extorg
 
 touch mnt/test
 umount mnt
 
+# check fs is without errors
 fsck -n $DM_DEV_DIR/$vg/$lv1
 
-lvchange -ay $vg/extorg
+lvchange -aey $vg/extorg
 lvchange -an $vg/$lv1
 
 check active $vg extorg
@@ -60,43 +83,42 @@ check inactive $vg $lv1
 # fsck in read-only mode
 fsck -n $DM_DEV_DIR/$vg/extorg
 
-#not lvresize -l+8 $vg/extorg
-#not lvresize -l-4 $vg/extorg
-#not lvchange -p rw $vg/extorg
+not lvresize -l+8 $vg/extorg
+not lvresize -l-4 $vg/extorg
+not lvchange -p rw $vg/extorg
 
 #lvresize -L+8M $vg/$lv1
 #lvresize -L-4M $vg/$lv1
 #lvchange -p r $vg/$lv1
 #lvchange -p rw $vg/$lv1
 
-lvchange -ay $vg
+lvchange -aey $vg
 
 lvs -a -o+origin_size,seg_size $vg
-lvconvert --originname extorg1 --thinpool $vg/pool -T $vg/extorg
 
+# Chain external origins
+lvconvert --originname extorg1 --thinpool $vg/pool -T $vg/extorg
 check inactive $vg extorg1
 
-lvconvert --originname extorglv1 --thinpool $vg/pool -T $vg/extorg1
-
-lvs -a -o+origin_size,seg_size $vg
+lvconvert --originname extorg2 --thinpool $vg/pool -T $vg/extorg1
+check inactive $vg extorg1
+check inactive $vg extorg2
 
 lvchange -an $vg/extorg
-lvs -a -o+origin_size,seg_size $vg
-check inactive $vg extorglv1
-
 lvchange -ay $vg/extorg1
-lvs -a -o+origin_size,seg_size $vg
 
 lvcreate -l4 -s $vg/$lv1  -n $lv2
 lvcreate -l8 -s $vg/extorg -n $lv3
 lvcreate -l12 -s $vg/extorg1 -n $lv4
-lvcreate -l16 -s $vg/extorglv1 -n $lv5
-
-lvs -a -o+origin_size,seg_size,segtype $vg
-
+lvcreate -l16 -s $vg/extorg2 -n $lv5
+#vgchange -aey $vg
+#lvremove -f $vg/extorg2
+#exit 0
 # Converting old-snapshot into external origin is not supported
 not lvconvert -T --thinpool $vg/pool --originname lv5origin $vg/$lv4
 
+lvs -a -o +segtype $vg
+
 check lv_field $vg/$lv1 segtype thin
 check lv_field $vg/$lv2 segtype linear
 check lv_field $vg/$lv3 segtype linear
@@ -104,17 +126,18 @@ check lv_field $vg/$lv4 segtype linear
 check lv_field $vg/$lv5 segtype linear
 check lv_field $vg/extorg segtype thin
 check lv_field $vg/extorg1 segtype thin
-check lv_field $vg/extorglv1 segtype linear
+check lv_field $vg/extorg2 segtype linear
 
 vgchange -ay $vg
 
 lvs -a -o+origin_size,seg_size $vg
 
-lvchange -an $vg/extorglv1
-check inactive $vg extorglv1
+lvchange -an $vg/extorg2
+check inactive $vg extorg2
 
 # Remove all volumes dependent on external origin
-lvremove -f $vg/extorglv1
+lvs -a -o+origin_size,seg_size,segtype $vg
+lvremove -f $vg/extorg2
 # Only pool is left
 check vg_field $vg lv_count 1
 
diff --git a/test/shell/lvcreate-thin-external.sh b/test/shell/lvcreate-thin-external.sh
index fdc7528..c9aba6f 100644
--- a/test/shell/lvcreate-thin-external.sh
+++ b/test/shell/lvcreate-thin-external.sh
@@ -32,32 +32,32 @@ mkfs.ext2 $DM_DEV_DIR/$vg/$lv1
 lvcreate -L4M -n $lv2 $vg
 mkfs.ext2 $DM_DEV_DIR/$vg/$lv2
 
-# Fail to create snapshot of rw LV
-not lvcreate -s -K $vg/$lv2 --thinpool $vg/pool
+# Fail to create external origin snapshot of rw LV
+not lvcreate -s $vg/$lv2 --thinpool $vg/pool
 
 lvchange -p r $vg/$lv2
 
 # Fail to create snapshot of active r LV
 # FIXME: kernel update needed
-not lvcreate -s -K $vg/$lv2 --thinpool $vg/pool
+not lvcreate -s $vg/$lv2 --thinpool $vg/pool
 
 # Deactivate LV we want to use as external origin
 # once kernel will ensure read-only this condition may go away
 lvchange -an $vg/$lv2
 
-lvcreate -s -K $vg/$lv2 --thinpool $vg/pool
+lvcreate -s $vg/$lv2 --thinpool $vg/pool
 
 # Fail with --thin and --snapshot
-not lvcreate -s -K $vg/$lv5 --name $vg/$lv7 -T $vg/newpool
+not lvcreate -s $vg/$lv5 --name $vg/$lv7 -T $vg/newpool
 
 # Fail to create already existing pool
-not lvcreate -s -K $vg/$lv2 -L10 --thinpool $vg/pool
-not lvcreate -s -K $vg/$lv2 --chunksize 64 --thinpool $vg/pool
-not lvcreate -s -K $vg/$lv2 --zero y --thinpool $vg/pool
-not lvcreate -s -K $vg/$lv2 --poolmetadata $vg/$lv1 --thinpool $vg/pool
+not lvcreate -s $vg/$lv2 -L10 --thinpool $vg/pool
+not lvcreate -s $vg/$lv2 --chunksize 64 --thinpool $vg/pool
+not lvcreate -s $vg/$lv2 --zero y --thinpool $vg/pool
+not lvcreate -s $vg/$lv2 --poolmetadata $vg/$lv1 --thinpool $vg/pool
 
 # Fail with nonexistent pool
-not lvcreate -s -K $vg/$lv2 --thinpool $vg/newpool
+not lvcreate -s $vg/$lv2 --thinpool $vg/newpool
 
 # Create pool and snap
 lvcreate -s -K $vg/$lv2 --name $vg/$lv3 -L20 --chunksize 128 --thinpool $vg/newpool


