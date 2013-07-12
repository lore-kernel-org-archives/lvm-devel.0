From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 12 Jul 2013 19:39:13 +0000 (UTC)
Subject: master - tests: use lvcreate -s -K for thin snapshots
Message-ID: <20130712193913.34074612BC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4e680ff3ab36816cbccce793cc69c2e0cae68330
Commit:        4e680ff3ab36816cbccce793cc69c2e0cae68330
Parent:        55d418fb2045e715a2ad5689fac48c32089d016a
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Jul 12 13:54:53 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jul 12 20:54:17 2013 +0200

tests: use lvcreate -s -K for thin snapshots

Thin snapshots are not activated now by default so this needs
to be explicitly overridden with -K now.
---
 test/api/thin_percent.sh             |    2 +-
 test/shell/lvcreate-thin-external.sh |   30 +++++++++++++++---------------
 test/shell/lvcreate-thin-snap.sh     |   14 +++++++-------
 test/shell/lvcreate-thin.sh          |   22 +++++++++++-----------
 4 files changed, 34 insertions(+), 34 deletions(-)

diff --git a/test/api/thin_percent.sh b/test/api/thin_percent.sh
index e14e807..50ad8f6 100644
--- a/test/api/thin_percent.sh
+++ b/test/api/thin_percent.sh
@@ -27,7 +27,7 @@ lvcreate -L5M -T $vg/pool
 lvcreate -V1M -T $vg/pool -n thin
 dd if=/dev/urandom of="$DM_DEV_DIR/$vg/thin" count=2 bs=256K
 
-lvcreate -s $vg/thin -n snap
+lvcreate -s $vg/thin -K -n snap
 dd if=/dev/urandom of="$DM_DEV_DIR/$vg/snap" count=3 bs=256K
 
 lvs -o+discards $vg
diff --git a/test/shell/lvcreate-thin-external.sh b/test/shell/lvcreate-thin-external.sh
index c469265..fdc7528 100644
--- a/test/shell/lvcreate-thin-external.sh
+++ b/test/shell/lvcreate-thin-external.sh
@@ -33,44 +33,44 @@ lvcreate -L4M -n $lv2 $vg
 mkfs.ext2 $DM_DEV_DIR/$vg/$lv2
 
 # Fail to create snapshot of rw LV
-not lvcreate -s $vg/$lv2 --thinpool $vg/pool
+not lvcreate -s -K $vg/$lv2 --thinpool $vg/pool
 
 lvchange -p r $vg/$lv2
 
 # Fail to create snapshot of active r LV
 # FIXME: kernel update needed
-not lvcreate -s $vg/$lv2 --thinpool $vg/pool
+not lvcreate -s -K $vg/$lv2 --thinpool $vg/pool
 
 # Deactivate LV we want to use as external origin
 # once kernel will ensure read-only this condition may go away
 lvchange -an $vg/$lv2
 
-lvcreate -s $vg/$lv2 --thinpool $vg/pool
+lvcreate -s -K $vg/$lv2 --thinpool $vg/pool
 
 # Fail with --thin and --snapshot
-not lvcreate -s $vg/$lv5 --name $vg/$lv7 -T $vg/newpool
+not lvcreate -s -K $vg/$lv5 --name $vg/$lv7 -T $vg/newpool
 
 # Fail to create already existing pool
-not lvcreate -s $vg/$lv2 -L10 --thinpool $vg/pool
-not lvcreate -s $vg/$lv2 --chunksize 64 --thinpool $vg/pool
-not lvcreate -s $vg/$lv2 --zero y --thinpool $vg/pool
-not lvcreate -s $vg/$lv2 --poolmetadata $vg/$lv1 --thinpool $vg/pool
+not lvcreate -s -K $vg/$lv2 -L10 --thinpool $vg/pool
+not lvcreate -s -K $vg/$lv2 --chunksize 64 --thinpool $vg/pool
+not lvcreate -s -K $vg/$lv2 --zero y --thinpool $vg/pool
+not lvcreate -s -K $vg/$lv2 --poolmetadata $vg/$lv1 --thinpool $vg/pool
 
 # Fail with nonexistent pool
-not lvcreate -s $vg/$lv2 --thinpool $vg/newpool
+not lvcreate -s -K $vg/$lv2 --thinpool $vg/newpool
 
 # Create pool and snap
-lvcreate -s $vg/$lv2 --name $vg/$lv3 -L20 --chunksize 128 --thinpool $vg/newpool
-lvcreate -s $vg/$lv3 --name $vg/$lv4
-lvcreate -s $vg/$lv2 --name $vg/$lv5 --thinpool $vg/newpool
+lvcreate -s -K $vg/$lv2 --name $vg/$lv3 -L20 --chunksize 128 --thinpool $vg/newpool
+lvcreate -s -K $vg/$lv3 --name $vg/$lv4
+lvcreate -s -K $vg/$lv2 --name $vg/$lv5 --thinpool $vg/newpool
 # Make normal thin snapshot
-lvcreate -s $vg/$lv5 --name $vg/$lv6
+lvcreate -s -K $vg/$lv5 --name $vg/$lv6
 # We do not need to specify thinpool when doing thin snap, but it should work
-lvcreate -s $vg/$lv5 --name $vg/$lv7 --thinpool $vg/newpool
+lvcreate -s -K $vg/$lv5 --name $vg/$lv7 --thinpool $vg/newpool
 
 check inactive $vg $lv2
 lvchange -ay $vg/$lv2
-lvcreate -s $vg/$lv2 --name $vg/$lv8 --thinpool $vg/newpool
+lvcreate -s -K $vg/$lv2 --name $vg/$lv8 --thinpool $vg/newpool
 
 lvs -o+chunksize $vg
 
diff --git a/test/shell/lvcreate-thin-snap.sh b/test/shell/lvcreate-thin-snap.sh
index 23f91f9..6dd16d7 100644
--- a/test/shell/lvcreate-thin-snap.sh
+++ b/test/shell/lvcreate-thin-snap.sh
@@ -35,11 +35,11 @@ vgcreate $vg -s 64K $(cat DEVICES)
 lvcreate -L10M -V10M -T $vg/pool --name $lv1
 mkfs.ext4 $DM_DEV_DIR/$vg/$lv1
 # create thin snapshot of thin LV
-lvcreate -s $vg/$lv1
+lvcreate -K -s $vg/$lv1
 # check snapshot filesystem was properly frozen before snapping
 fsck -p $DM_DEV_DIR/$vg/lvol0
-lvcreate -s $vg/$lv1 --name $lv2
-lvcreate -s $vg/$lv1 --name $vg/$lv3
+lvcreate -K -s $vg/$lv1 --name $lv2
+lvcreate -K -s $vg/$lv1 --name $vg/$lv3
 lvcreate --type snapshot $vg/$lv1
 lvcreate --type snapshot $vg/$lv1 --name $lv4
 lvcreate --type snapshot $vg/$lv1 --name $vg/$lv5
@@ -49,9 +49,9 @@ lvcreate -s -L10M --name oldsnap1 $vg/$lv2
 lvcreate -s -L10M --name oldsnap2 $vg/$lv2
 
 # thin snap of snap of snap...
-lvcreate -s --name sn1 $vg/$lv2
-lvcreate -s --name sn2 $vg/sn1
-lvcreate -s --name sn3 $vg/sn2
-lvcreate -s --name sn4 $vg/sn3
+lvcreate -K -s --name sn1 $vg/$lv2
+lvcreate -K -s --name sn2 $vg/sn1
+lvcreate -K -s --name sn3 $vg/sn2
+lvcreate -K -s --name sn4 $vg/sn3
 
 vgremove -ff $vg
diff --git a/test/shell/lvcreate-thin.sh b/test/shell/lvcreate-thin.sh
index e651a81..8daa923 100644
--- a/test/shell/lvcreate-thin.sh
+++ b/test/shell/lvcreate-thin.sh
@@ -136,13 +136,13 @@ check vg_field $vg lv_count 0
 # Create thin snapshot of thinLV
 lvcreate -L10M -V10M -T $vg/pool --name lv1
 mkfs.ext4 $DM_DEV_DIR/$vg/lv1
-lvcreate -s $vg/lv1
+lvcreate -s -K $vg/lv1
 fsck -p $DM_DEV_DIR/$vg/lvol0
-lvcreate -s $vg/lv1 --name lv2
-lvcreate -s $vg/lv1 --name $vg/lv3
-lvcreate --type snapshot $vg/lv1
-lvcreate --type snapshot $vg/lv1 --name lv4
-lvcreate --type snapshot $vg/lv1 --name $vg/lv5
+lvcreate -s -K $vg/lv1 --name lv2
+lvcreate -s -K $vg/lv1 --name $vg/lv3
+lvcreate --type snapshot -K $vg/lv1
+lvcreate --type snapshot -K $vg/lv1 --name lv4
+lvcreate --type snapshot -K $vg/lv1 --name $vg/lv5
 
 check_lv_field_modules_ thin-pool lv1 lvol0 lv2 lv3 lvol1 lv4 lv5
 check vg_field $vg lv_count 8
@@ -151,10 +151,10 @@ lvremove -ff $vg
 
 # Normal Snapshots of thinLV
 lvcreate -L4M -V2G -T $vg/pool --name lv1
-lvcreate -s $vg/lv1 -l1
-lvcreate -s $vg/lv1 -l1 --name lv2
-lvcreate -s $vg/lv1 -l1 --name $vg/lv3
-lvcreate -s lv1 -L4M --name $vg/lv4
+lvcreate -s -K $vg/lv1 -l1
+lvcreate -s -K $vg/lv1 -l1 --name lv2
+lvcreate -s -K $vg/lv1 -l1 --name $vg/lv3
+lvcreate -s -K lv1 -L4M --name $vg/lv4
 
 check_lv_field_modules_ snapshot lvol0 lv2 lv3 lv4
 check vg_field $vg lv_count 6
@@ -174,7 +174,7 @@ not lvcreate -L4M --chunksize 2G -T $vg/pool1
 
 lvcreate -L4M -V2G --name lv1 -T $vg/pool1
 # Origin name is not accepted
-not lvcreate -s $vg/lv1 -L4M -V2G --name $vg/lv4
+not lvcreate -s -K $vg/lv1 -L4M -V2G --name $vg/lv4
 
 # Check we cannot create mirror and thin or thinpool together
 not lvcreate -T mirpool -L4M --alloc anywhere -m1 $vg


