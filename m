From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  2 Apr 2013 13:18:31 +0000 (UTC)
Subject: master - tests: lvconvert external origin
Message-ID: <20130402131831.8DC7B1297@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6ac4cba276e8d7842e4efedc117f4b9aafa90c71
Commit:        6ac4cba276e8d7842e4efedc117f4b9aafa90c71
Parent:        d24c01a414506f0cdc04b5c8589f61d288b25273
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 5 14:24:05 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 2 15:17:31 2013 +0200

tests: lvconvert external origin

Add tests for thin external origin support
---
 test/shell/lvconvert-thin-external.sh |  121 +++++++++++++++++++++++++++++++++
 test/shell/lvcreate-thin-external.sh  |   86 +++++++++++++++++++++++
 2 files changed, 207 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvconvert-thin-external.sh b/test/shell/lvconvert-thin-external.sh
new file mode 100644
index 0000000..1bcf0b6
--- /dev/null
+++ b/test/shell/lvconvert-thin-external.sh
@@ -0,0 +1,121 @@
+#!/bin/sh
+
+# Copyright (C) 2013 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+# Test conversion to thin external origin
+
+. lib/test
+
+which mkfs.ext2 || skip
+which fsck || skip
+
+#
+# Main
+#
+aux have_thin 1 5 0 || skip
+
+aux prepare_pvs 2 64
+
+vgcreate $vg -s 64K $(cat DEVICES)
+
+# create thin pool
+lvcreate -L8M -T $vg/pool
+
+# create plain LV
+lvcreate -L8M -n $lv1 $vg
+
+mkfs.ext2 $DM_DEV_DIR/$vg/$lv1
+mkdir mnt
+mount $DM_DEV_DIR/$vg/$lv1 mnt
+
+dd if=/dev/zero of=mnt/test1 bs=1M count=1
+
+# convert plain LV into thin external snapshot volume
+# during conversion dd above could be still flushed
+
+lvconvert -T --originname extorg --thinpool $vg/pool $vg/$lv1
+
+check active $vg $lv1
+check inactive $vg extorg
+
+touch mnt/test
+umount mnt
+
+fsck -n $DM_DEV_DIR/$vg/$lv1
+
+lvchange -ay $vg/extorg
+lvchange -an $vg/$lv1
+
+check active $vg extorg
+check inactive $vg $lv1
+
+# fsck in read-only mode
+fsck -n $DM_DEV_DIR/$vg/extorg
+
+#not lvresize -l+8 $vg/extorg
+#not lvresize -l-4 $vg/extorg
+#not lvchange -p rw $vg/extorg
+
+#lvresize -L+8M $vg/$lv1
+#lvresize -L-4M $vg/$lv1
+#lvchange -p r $vg/$lv1
+#lvchange -p rw $vg/$lv1
+
+lvchange -ay $vg
+
+lvs -a -o+origin_size,seg_size $vg
+lvconvert --originname extorg1 --thinpool $vg/pool -T $vg/extorg
+
+check inactive $vg extorg1
+
+lvconvert --originname extorglv1 --thinpool $vg/pool -T $vg/extorg1
+
+lvs -a -o+origin_size,seg_size $vg
+
+lvchange -an $vg/extorg
+lvs -a -o+origin_size,seg_size $vg
+check inactive $vg extorglv1
+
+lvchange -ay $vg/extorg1
+lvs -a -o+origin_size,seg_size $vg
+
+lvcreate -l4 -s $vg/$lv1  -n $lv2
+lvcreate -l8 -s $vg/extorg -n $lv3
+lvcreate -l12 -s $vg/extorg1 -n $lv4
+lvcreate -l16 -s $vg/extorglv1 -n $lv5
+
+lvs -a -o+origin_size,seg_size,segtype $vg
+
+# Converting old-snapshot into external origin is not supported
+not lvconvert -T --thinpool $vg/pool --originname lv5origin $vg/$lv4
+
+check lv_field $vg/$lv1 segtype thin
+check lv_field $vg/$lv2 segtype linear
+check lv_field $vg/$lv3 segtype linear
+check lv_field $vg/$lv4 segtype linear
+check lv_field $vg/$lv5 segtype linear
+check lv_field $vg/extorg segtype thin
+check lv_field $vg/extorg1 segtype thin
+check lv_field $vg/extorglv1 segtype linear
+
+vgchange -ay $vg
+
+lvs -a -o+origin_size,seg_size $vg
+
+lvchange -an $vg/extorglv1
+check inactive $vg extorglv1
+
+# Remove all volumes dependent on external origin
+lvremove -f $vg/extorglv1
+# Only pool is left
+check vg_field $vg lv_count 1
+
+vgremove -ff $vg
diff --git a/test/shell/lvcreate-thin-external.sh b/test/shell/lvcreate-thin-external.sh
new file mode 100644
index 0000000..c469265
--- /dev/null
+++ b/test/shell/lvcreate-thin-external.sh
@@ -0,0 +1,86 @@
+#!/bin/sh
+
+# Copyright (C) 2013 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+# Test creation of thin snapshots using external origin
+
+. lib/test
+
+which mkfs.ext2 || skip
+which fsck || skip
+
+#
+# Main
+#
+aux have_thin 1 3 0 || skip
+
+aux prepare_pvs 2 64
+
+vgcreate $vg -s 64K $(cat DEVICES)
+
+lvcreate -L10M -V10M -T $vg/pool --name $lv1
+mkfs.ext2 $DM_DEV_DIR/$vg/$lv1
+
+lvcreate -L4M -n $lv2 $vg
+mkfs.ext2 $DM_DEV_DIR/$vg/$lv2
+
+# Fail to create snapshot of rw LV
+not lvcreate -s $vg/$lv2 --thinpool $vg/pool
+
+lvchange -p r $vg/$lv2
+
+# Fail to create snapshot of active r LV
+# FIXME: kernel update needed
+not lvcreate -s $vg/$lv2 --thinpool $vg/pool
+
+# Deactivate LV we want to use as external origin
+# once kernel will ensure read-only this condition may go away
+lvchange -an $vg/$lv2
+
+lvcreate -s $vg/$lv2 --thinpool $vg/pool
+
+# Fail with --thin and --snapshot
+not lvcreate -s $vg/$lv5 --name $vg/$lv7 -T $vg/newpool
+
+# Fail to create already existing pool
+not lvcreate -s $vg/$lv2 -L10 --thinpool $vg/pool
+not lvcreate -s $vg/$lv2 --chunksize 64 --thinpool $vg/pool
+not lvcreate -s $vg/$lv2 --zero y --thinpool $vg/pool
+not lvcreate -s $vg/$lv2 --poolmetadata $vg/$lv1 --thinpool $vg/pool
+
+# Fail with nonexistent pool
+not lvcreate -s $vg/$lv2 --thinpool $vg/newpool
+
+# Create pool and snap
+lvcreate -s $vg/$lv2 --name $vg/$lv3 -L20 --chunksize 128 --thinpool $vg/newpool
+lvcreate -s $vg/$lv3 --name $vg/$lv4
+lvcreate -s $vg/$lv2 --name $vg/$lv5 --thinpool $vg/newpool
+# Make normal thin snapshot
+lvcreate -s $vg/$lv5 --name $vg/$lv6
+# We do not need to specify thinpool when doing thin snap, but it should work
+lvcreate -s $vg/$lv5 --name $vg/$lv7 --thinpool $vg/newpool
+
+check inactive $vg $lv2
+lvchange -ay $vg/$lv2
+lvcreate -s $vg/$lv2 --name $vg/$lv8 --thinpool $vg/newpool
+
+lvs -o+chunksize $vg
+
+check active $vg $lv3
+check active $vg $lv4
+check active $vg $lv5
+check active $vg $lv6
+check active $vg $lv7
+
+fsck -n $DM_DEV_DIR/$vg/$lv1
+fsck -n $DM_DEV_DIR/$vg/$lv7
+
+vgremove -ff $vg


