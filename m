From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 20 May 2014 19:53:57 +0000 (UTC)
Subject: master - tests: update lvconvert test
Message-ID: <20140520195357.6D541603F2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=205be247689d7be38b4341401516a1881e09c6aa
Commit:        205be247689d7be38b4341401516a1881e09c6aa
Parent:        16424fed543ee6d4841c1e44ba252ae976c28cbb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue May 20 21:11:11 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue May 20 21:50:29 2014 +0200

tests: update lvconvert test

Split raid test to separate file
Add --yes flag to automated testing
---
 test/shell/lvconvert-thin-raid.sh  |   31 +++++++++++++++++++++++
 test/shell/lvconvert-thin.sh       |   47 ++++++++++++++++--------------------
 test/shell/pvmove-thin-segtypes.sh |    2 +-
 3 files changed, 53 insertions(+), 27 deletions(-)

diff --git a/test/shell/lvconvert-thin-raid.sh b/test/shell/lvconvert-thin-raid.sh
new file mode 100644
index 0000000..ae3d2ef
--- /dev/null
+++ b/test/shell/lvconvert-thin-raid.sh
@@ -0,0 +1,31 @@
+#!/bin/sh
+
+# Copyright (C) 2014 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/test
+
+aux have_thin 1 0 0 || skip
+aux have_raid 1 4 0 || skip
+
+aux prepare_vg 4
+
+# create RAID LVs for data and metadata volumes
+lvcreate -aey --nosync -L10M --type raid1 -m1 -n $lv1 $vg
+lvcreate -aey --nosync -L8M --type raid1 -m1 -n $lv2 $vg
+lvchange -an $vg/$lv1
+
+# conversion fails for internal volumes
+fail lvconvert --thinpool $vg/${lv1}_rimage_0
+fail lvconvert --yes --thinpool $vg/$lv1 --poolmetadata $vg/${lv2}_rimage_0
+
+lvconvert --yes --thinpool $vg/$lv1 --poolmetadata $vg/$lv2
+
+vgremove -ff $vg
diff --git a/test/shell/lvconvert-thin.sh b/test/shell/lvconvert-thin.sh
index d177f9a..8c3b903 100644
--- a/test/shell/lvconvert-thin.sh
+++ b/test/shell/lvconvert-thin.sh
@@ -44,29 +44,23 @@ lvcreate -aey -L10M -n $lv2 $vg
 lvchange -an $vg/$lv1
 
 # conversion fails for mirror segment type
-not lvconvert --thinpool $vg/$lv1
-not lvconvert --thinpool $vg/$lv2 --poolmetadata $vg/$lv2
-lvremove -f $vg
+fail lvconvert --thinpool $vg/$lv1
+# cannot use same LV
+fail lvconvert --yes --thinpool $vg/$lv2 --poolmetadata $vg/$lv2
 
-# create RAID LVs for data and metadata volumes
-lvcreate -aey -L10M --type raid1 -m1 -n $lv1 $vg
-lvcreate -aey -L10M --type raid1 -m1 -n $lv2 $vg
-lvchange -an $vg/$lv1
+prepare_lvs
 
 # conversion fails for internal volumes
-not lvconvert --thinpool $vg/${lv1}_rimage_0
-not lvconvert --thinpool $vg/$lv1 --poolmetadata $vg/${lv2}_rimage_0
 # can't use --readahead with --poolmetadata
-not lvconvert --thinpool $vg/$lv1 --poolmetadata $vg/$lv2 --readahead 512
-
-lvconvert --thinpool $vg/$lv1 --poolmetadata $vg/$lv2
+invalid lvconvert --thinpool $vg/$lv1 --poolmetadata $vg/$lv2 --readahead 512
+lvconvert --yes --thinpool $vg/$lv1 --poolmetadata $vg/$lv2
 
 prepare_lvs
-lvconvert -c 64 --stripes 2 --thinpool $vg/$lv1 --readahead 48
+lvconvert --yes -c 64 --stripes 2 --thinpool $vg/$lv1 --readahead 48
 
 lvremove -f $vg
 lvcreate -L1T -n $lv1 $vg
-lvconvert -c 8M --thinpool $vg/$lv1
+lvconvert --yes -c 8M --thinpool $vg/$lv1
 
 lvremove -f $vg
 # test with bigger sizes
@@ -75,29 +69,30 @@ lvcreate -L8M -n $lv2 $vg
 lvcreate -L1M -n $lv3 $vg
 
 # chunk size is bigger then size of thin pool data
-not lvconvert -c 1G --thinpool $vg/$lv3
+fail lvconvert --yes -c 1G --thinpool $vg/$lv3
 # stripes can't be used with poolmetadata
-not lvconvert --stripes 2 --thinpool $vg/$lv1 --poolmetadata $vg/$lv2
+invalid lvconvert --stripes 2 --thinpool $vg/$lv1 --poolmetadata $vg/$lv2
 # too small metadata (<2M)
-not lvconvert -c 64 --thinpool $vg/$lv1 --poolmetadata $vg/$lv3
+fail lvconvert --yes -c 64 --thinpool $vg/$lv1 --poolmetadata $vg/$lv3
 # too small chunk size fails
-not lvconvert -c 4 --thinpool $vg/$lv1 --poolmetadata $vg/$lv2
+# 'fail' because profiles need to read VG
+fail lvconvert -c 4 --thinpool $vg/$lv1 --poolmetadata $vg/$lv2
 # too big chunk size fails
-not lvconvert -c 2G --thinpool $vg/$lv1 --poolmetadata $vg/$lv2
+fail lvconvert -c 2G --thinpool $vg/$lv1 --poolmetadata $vg/$lv2
 # negative chunk size fails
-not lvconvert -c -256 --thinpool $vg/$lv1 --poolmetadata $vg/$lv2
+fail lvconvert -c -256 --thinpool $vg/$lv1 --poolmetadata $vg/$lv2
 # non power of 2 fails
-not lvconvert -c 88 --thinpool $vg/$lv1 --poolmetadata $vg/$lv2
+fail lvconvert -c 88 --thinpool $vg/$lv1 --poolmetadata $vg/$lv2
 
 # Warning about smaller then suggested
-lvconvert -c 256 --thinpool $vg/$lv1 --poolmetadata $vg/$lv2 |& tee err
+lvconvert --yes -c 256 --thinpool $vg/$lv1 --poolmetadata $vg/$lv2 |& tee err
 grep "WARNING: Chunk size is smaller" err
 
 lvremove -f $vg
 lvcreate -L1T -n $lv1 $vg
 lvcreate -L32G -n $lv2 $vg
 # Warning about bigger then needed
-lvconvert --thinpool $vg/$lv1 --poolmetadata $vg/$lv2 |& tee err
+lvconvert --yes --thinpool $vg/$lv1 --poolmetadata $vg/$lv2 |& tee err
 grep "WARNING: Maximum size" err
 
 lvremove -f $vg
@@ -105,14 +100,14 @@ lvremove -f $vg
 if test "$TSIZE" -eq 64T; then
 lvcreate -L24T -n $lv1 $vg
 # Warning about bigger then needed (24T data and 16G -> 128K chunk)
-lvconvert -c 64 --thinpool $vg/$lv1 |& tee err
+lvconvert --yes -c 64 --thinpool $vg/$lv1 |& tee err
 grep "WARNING: Chunk size is too small" err
 fi
 
 #lvs -a -o+chunk_size,stripe_size,seg_pe_ranges
 
 # Convertions of pool to mirror or RAID is unsupported
-not lvconvert --type mirror -m1 $vg/$lv1
-not lvconvert --type raid1 -m1 $vg/$lv1
+fail lvconvert --type mirror -m1 $vg/$lv1
+fail lvconvert --type raid1 -m1 $vg/$lv1
 
 vgremove -ff $vg
diff --git a/test/shell/pvmove-thin-segtypes.sh b/test/shell/pvmove-thin-segtypes.sh
index 684b3f5..c514bb5 100644
--- a/test/shell/pvmove-thin-segtypes.sh
+++ b/test/shell/pvmove-thin-segtypes.sh
@@ -49,7 +49,7 @@ lvremove -ff $vg
 lvcreate -l 2 -n ${lv1}_foo $vg "$dev1"
 lvcreate --type raid1 -m 1 -l 4 -n ${lv1}_raid1_pool $vg "$dev1" "$dev2"
 lvcreate --type raid1 -m 1 -L 2 -n ${lv1}_raid1_meta $vg "$dev1" "$dev2"
-lvconvert --thinpool $vg/${lv1}_raid1_pool \
+lvconvert --yes --thinpool $vg/${lv1}_raid1_pool \
         --poolmetadata ${lv1}_raid1_meta
 lvcreate -T $vg/${lv1}_raid1_pool -V 8 -n $lv1
 check lv_tree_on $vg ${lv1}_foo "$dev1"


