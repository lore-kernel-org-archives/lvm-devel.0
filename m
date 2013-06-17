From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 17 Jun 2013 07:38:16 +0000 (UTC)
Subject: master - snapshot: fix max size limit check for COW device
Message-ID: <20130617073816.796AF60FDA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d4308a558d93bf5ed4b61f65b12f4f0fdfc45102
Commit:        d4308a558d93bf5ed4b61f65b12f4f0fdfc45102
Parent:        2f334b16d2d89c85d1bd46538c80729c490df7f9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Jun 16 21:32:11 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jun 17 09:37:50 2013 +0200

snapshot: fix max size limit check for COW device

Use proper max size as a multiple of extent size.
And use 64bit arithmentic for validation of minsize.
(in release fix).
---
 lib/metadata/lv_manip.c       |    3 +-
 lib/metadata/snapshot_manip.c |    5 +-
 test/shell/snapshot-usage.sh  |   87 +++++++++++++++++++++++++++++++++++++++++
 test/shell/snapshots-usage.sh |   87 -----------------------------------------
 4 files changed, 92 insertions(+), 90 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 966b8fa..b7c538b 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4544,7 +4544,8 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg, struct l
 	}
 
 	if (lp->snapshot && !seg_is_thin(lp) &&
-	    ((uint64_t)(lp->extents * vg->extent_size) < (SNAPSHOT_MIN_CHUNKS * lp->chunk_size))) {
+	    (((uint64_t)lp->extents * vg->extent_size) <
+	     (SNAPSHOT_MIN_CHUNKS * lp->chunk_size))) {
 		log_error("Unable to create a snapshot smaller than "
 			  DM_TO_STRING(SNAPSHOT_MIN_CHUNKS) " chunks (%u extents, %s).",
 			  (unsigned) (((uint64_t) SNAPSHOT_MIN_CHUNKS * lp->chunk_size +
diff --git a/lib/metadata/snapshot_manip.c b/lib/metadata/snapshot_manip.c
index c3d1112..e0d2f5b 100644
--- a/lib/metadata/snapshot_manip.c
+++ b/lib/metadata/snapshot_manip.c
@@ -56,12 +56,13 @@ uint32_t cow_max_extents(const struct logical_volume *origin, uint32_t chunk_siz
 {
 	uint64_t size = _cow_max_size(origin->size, chunk_size);
 	uint32_t extent_size = origin->vg->extent_size;
+	uint64_t max_size = (uint64_t) MAX_EXTENT_COUNT * extent_size;
 
 	if (size % extent_size)
 		size += extent_size - size % extent_size;
 
-	if (size > UINT32_MAX)
-		size = UINT32_MAX; /* Origin is too big for 100% snapshot anyway */
+	if (size > max_size)
+		size = max_size; /* Origin is too big for 100% snapshot anyway */
 
 	return (uint32_t) (size / extent_size);
 }
diff --git a/test/shell/snapshot-usage.sh b/test/shell/snapshot-usage.sh
new file mode 100644
index 0000000..9c1c2f6
--- /dev/null
+++ b/test/shell/snapshot-usage.sh
@@ -0,0 +1,87 @@
+#!/bin/bash
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
+# no automatic extensions please
+
+. lib/test
+
+fill() {
+	dd if=/dev/zero of=$DM_DEV_DIR/$vg1/lvol0 bs=$1 count=1
+}
+
+aux prepare_pvs 1
+vgcreate -s 4M $vg $(cat DEVICES)
+
+lvcreate -s -l 100%FREE -n $lv $vg --virtualsize 15P
+
+aux extend_filter_LVMTEST
+aux lvmconf "activation/snapshot_autoextend_percent = 20" \
+            "activation/snapshot_autoextend_threshold = 50"
+
+# Check usability with smallest extent size
+pvcreate --setphysicalvolumesize 4T $DM_DEV_DIR/$vg/$lv
+vgcreate -s 1K $vg1 $DM_DEV_DIR/$vg/$lv
+
+# Check border size
+lvcreate -aey -L4095G $vg1
+lvcreate -s -L100K $vg1/lvol0
+fill 1K
+check lv_field $vg1/lvol1 data_percent "12.00"
+lvremove -ff $vg1
+
+# Create 1KB snapshot, no need to be active active here
+lvcreate -an -Zn -l1 -n $lv1 $vg1
+not lvcreate -s -l1 $vg1/$lv1
+not lvcreate -s -l3 $vg1/$lv1
+lvcreate -s -l30 -n $lv2 $vg1/$lv1
+check lv_field $vg1/$lv2 size "12.00k"
+
+not lvcreate -s -c512 -l512 $vg1/$lv1
+lvcreate -s -c128 -l1700 -n $lv3 $vg1/$lv1
+# 3 * 128
+check lv_field $vg1/$lv3 size "384.00k"
+lvremove -ff $vg1
+
+lvcreate -aey -l20 $vg1
+lvcreate -s -l12 $vg1/lvol0
+
+# Fill 1KB -> 100% snapshot (1x 4KB chunk)
+fill 1K
+check lv_field $vg1/lvol1 data_percent "100.00"
+
+# Check it resizes 100% full valid snapshot
+lvextend --use-policies $vg1/lvol1
+check lv_field $vg1/lvol1 data_percent "80.00"
+
+fill 4K
+lvextend --use-policies $vg1/lvol1
+check lv_field $vg1/lvol1 size "18.00k"
+
+lvextend -l+33 $vg1/lvol1
+check lv_field $vg1/lvol1 size "28.00k"
+
+fill 20K
+vgremove -ff $vg1
+
+# Check usability with largest extent size
+pvcreate $DM_DEV_DIR/$vg/$lv
+vgcreate -s 4G $vg1 $DM_DEV_DIR/$vg/$lv
+
+lvcreate -an -Zn -l50%FREE -n $lv1 $vg1
+lvcreate -s -l100%FREE -n $lv2 $vg1/$lv1
+check lv_field $vg1/$lv2 size "7.50p"
+lvremove -ff $vg1
+ 
+lvcreate -aey -V15E -l1 -n $lv1 -s $vg1
+check lv_field $vg1/$lv1 origin_size "15.00e"
+
+vgremove -ff $vg1
+vgremove -ff $vg
diff --git a/test/shell/snapshots-usage.sh b/test/shell/snapshots-usage.sh
deleted file mode 100644
index 3c0f457..0000000
--- a/test/shell/snapshots-usage.sh
+++ /dev/null
@@ -1,87 +0,0 @@
-#!/bin/bash
-# Copyright (C) 2013 Red Hat, Inc. All rights reserved.
-#
-# This copyrighted material is made available to anyone wishing to use,
-# modify, copy, or redistribute it subject to the terms and conditions
-# of the GNU General Public License v.2.
-#
-# You should have received a copy of the GNU General Public License
-# along with this program; if not, write to the Free Software Foundation,
-# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
-
-# no automatic extensions please
-
-. lib/test
-
-fill() {
-	dd if=/dev/zero of=$DM_DEV_DIR/$vg1/lvol0 bs=$1 count=1
-}
-
-aux prepare_pvs 1
-vgcreate -s 4M $vg $(cat DEVICES)
-
-lvcreate -s -l 100%FREE -n $lv $vg --virtualsize 15P
-
-aux extend_filter_LVMTEST
-aux lvmconf "activation/snapshot_autoextend_percent = 20" \
-            "activation/snapshot_autoextend_threshold = 50"
-
-# Check usability with smallest extent size
-pvcreate --setphysicalvolumesize 4T $DM_DEV_DIR/$vg/$lv
-vgcreate -s 1K $vg1 $DM_DEV_DIR/$vg/$lv
-
-# Check border size
-lvcreate -aey -L4095G $vg1
-lvcreate -s -L100K $vg1/lvol0
-fill 1K
-check lv_field $vg1/lvol1 data_percent "12.00"
-lvremove -ff $vg1
-
-# Create 1KB snapshot
-lvcreate -aey -l1 $vg1
-not lvcreate -s -l1 $vg1/lvol0
-not lvcreate -s -l3 $vg1/lvol0
-lvcreate -s -l30 $vg1/lvol0
-check lv_field $vg1/lvol1 size "12.00k"
-
-not lvcreate -s -c512 -l512 $vg1/lvol0
-lvcreate -aey -s -c128 -l1700 $vg1/lvol0
-# 3 * 128
-check lv_field $vg1/lvol2 size "384.00k"
-
-lvremove -ff $vg1
-
-lvcreate -aey -l20 $vg1
-lvcreate -s -l12 $vg1/lvol0
-
-# Fill 1KB -> 100% snapshot (1x 4KB chunk)
-fill 1K
-check lv_field $vg1/lvol1 data_percent "100.00"
-
-# Check it resizes 100% full valid snapshot
-lvextend --use-policies $vg1/lvol1
-check lv_field $vg1/lvol1 data_percent "80.00"
-
-fill 4K
-lvextend --use-policies $vg1/lvol1
-check lv_field $vg1/lvol1 size "18.00k"
-
-lvextend -l+33 $vg1/lvol1
-check lv_field $vg1/lvol1 size "28.00k"
-
-fill 20K
-vgremove -ff $vg1
-
-# Check usability with large extent size
-pvcreate $DM_DEV_DIR/$vg/$lv
-vgcreate -s 4G $vg1 $DM_DEV_DIR/$vg/$lv
-
-lvcreate -aey -l1 $vg1
-lvcreate -s -l1 $vg1/lvol0
-check lv_field $vg1/lvol1 size "4.00g"
-
-lvcreate -aey -V15E -l1 -s $vg1
-check lv_field $vg1/lvol2 origin_size "15.00e"
-
-vgremove -ff $vg1
-vgremove -ff $vg


