From: Lukas Czerner <lczerner@redhat.com>
Date: Tue, 27 Sep 2011 13:15:28 +0200
Subject: [PATCH 14/16] test: Add test for fsadm create command
In-Reply-To: <1317122130-13790-1-git-send-email-lczerner@redhat.com>
References: <1317122130-13790-1-git-send-email-lczerner@redhat.com>
Message-ID: <1317122130-13790-15-git-send-email-lczerner@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The tests exercises the fsadm "create" functionality, by trying various
combinations of arguments and checking the desired results. It also
tries to create volumes with various supported file systems.

Signed-off-by: Lukas Czerner <lczerner@redhat.com>
---
 test/t-fsadm-create.sh |  128 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 128 insertions(+), 0 deletions(-)
 create mode 100644 test/t-fsadm-create.sh

diff --git a/test/t-fsadm-create.sh b/test/t-fsadm-create.sh
new file mode 100644
index 0000000..7a6f446
--- /dev/null
+++ b/test/t-fsadm-create.sh
@@ -0,0 +1,128 @@
+#!/bin/bash
+# Copyright 2011 (C) Red Hat, Inc., Lukas Czerner <lczerner@redhat.com>
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+test_description='Exercise fsadm create'
+
+. lib/test
+
+DEV_COUNT=10
+DEV_SIZE=10
+TEST_MAX_SIZE=$(($DEV_COUNT*$DEV_SIZE))
+aux prepare_devs $DEV_COUNT $DEV_SIZE
+TEST_DEVS=$(cat DEVICES)
+export DEFAULT_DEVICE_POOL=$vg1
+export LVOL_PREFIX="lvol"
+lvol1=${LVOL_PREFIX}001
+lvol2=${LVOL_PREFIX}002
+lvol3=${LVOL_PREFIX}003
+
+pool1=$vg2
+pool2=$vg3
+
+TEST_FS=
+which mkfs.ext2 && TEST_FS+="ext2 "
+which mkfs.ext3 && TEST_FS+="ext3 "
+which mkfs.ext4 && TEST_FS+="ext4 "
+which mkfs.xfs  && TEST_FS+="xfs"
+
+_do_fsck() {
+	case $1 in
+		ext[234]) call="fsck.$1 -F -n" ;;
+		xfs) call="xfs_check" ;;
+		*) return 1 ;;
+	esac
+	$call $DM_DEV_DIR/$2
+}
+
+# Create volume with all devices at once
+fsadm create $TEST_DEVS
+not fsadm create $TEST_DEVS
+not fsadm create $TEST_DEVS $pool1
+not fsadm create size=$DEV_SIZE $TEST_DEVS
+check lv_field $DEFAULT_DEVICE_POOL/$lvol1 pv_count $DEV_COUNT
+fsadm -f remove $DEFAULT_DEVICE_POOL
+
+# Create the group first and then create volume using the whole group
+fsadm add $TEST_DEVS
+fsadm create
+check lv_field $DEFAULT_DEVICE_POOL/$lvol1 pv_count $DEV_COUNT
+fsadm -f remove $DEFAULT_DEVICE_POOL
+
+# Create a logical volume of fixed size
+size=$(($DEV_SIZE*6))
+fsadm create size=${size}M $TEST_DEVS
+not fsadm create size=$TEST_MAX_SIZE
+size=$(align_size_up $size)
+check lv_field $DEFAULT_DEVICE_POOL/$lvol1 lv_size ${size}.00m
+fsadm -f remove $DEFAULT_DEVICE_POOL
+
+# Create a striped logical volume
+fsadm create stripesize=32 $TEST_DEVS
+not fsadm create stripesize=32 size=$TEST_MAX_SIZE
+check lv_field $DEFAULT_DEVICE_POOL/$lvol1 stripesize 32.00k
+fsadm  -f remove $DEFAULT_DEVICE_POOL
+
+# Create several volumes with different parameters
+fsadm  add $TEST_DEVS
+fsadm create stripesize=8 stripes=$(($DEV_COUNT/2)) size=$(($DEV_SIZE*2))M
+fsadm create stripes=$(($DEV_COUNT)) size=$(($DEV_SIZE))M
+not fsadm create stripesize=32 size=$(($DEV_SIZE*2))M
+fsadm list
+fsadm create
+check lv_field $DEFAULT_DEVICE_POOL/$lvol1 stripesize 8.00k
+check lv_field $DEFAULT_DEVICE_POOL/$lvol1 stripes $(($DEV_COUNT/2))
+check lv_field $DEFAULT_DEVICE_POOL/$lvol2 stripes $DEV_COUNT
+check lv_field $DEFAULT_DEVICE_POOL/$lvol3 segtype linear
+fsadm  -f remove $DEFAULT_DEVICE_POOL
+
+# Create several volumes with different parameters from different groups
+fsadm add $dev1 $dev2 $dev3 $pool1
+fsadm create $dev1 $dev2 $dev3
+fsadm add $dev4 $dev5 $dev6 $pool2
+fsadm create stripesize=32 stripes=3 size=$(($DEV_SIZE*2))M $pool2
+fsadm create $dev7 $dev8 $dev9 stripesize=8
+not fsadm create size=$DEV_SIZE $pool1
+check lv_field $DEFAULT_DEVICE_POOL/$lvol1 stripesize 8.00k
+check lv_field $pool1/$lvol1 pv_count 3
+check lv_field $pool2/$lvol1 stripesize 32.00k
+check lv_field $pool2/$lvol1 stripes 3
+fsadm  -f remove --all
+
+# Create logical volumes with file system
+for fs in $TEST_FS; do
+	fsadm create fs=$fs size=$(($DEV_SIZE*6))M $TEST_DEVS
+	check lv_field $DEFAULT_DEVICE_POOL/$lvol1 pv_count $DEV_COUNT
+	fsadm -f check ${DEFAULT_DEVICE_POOL}/$lvol1
+	_do_fsck $fs ${DEFAULT_DEVICE_POOL}/$lvol1
+	fsadm  -f remove $DEFAULT_DEVICE_POOL
+
+	fsadm create fs=$fs stripesize=32 size=$(($DEV_SIZE*6))M $TEST_DEVS
+	check lv_field $DEFAULT_DEVICE_POOL/$lvol1 pv_count $DEV_COUNT
+	check lv_field $DEFAULT_DEVICE_POOL/$lvol1 stripesize 32.00k
+	_do_fsck $fs ${DEFAULT_DEVICE_POOL}/$lvol1
+	fsadm  -f remove $DEFAULT_DEVICE_POOL
+
+	fsadm add $TEST_DEVS
+	fsadm create fs=$fs stripesize=8 stripes=$((DEV_COUNT/5)) size=$(($DEV_SIZE*2))M
+	check lv_field $DEFAULT_DEVICE_POOL/$lvol1 stripes $(($DEV_COUNT/5))
+	check lv_field $DEFAULT_DEVICE_POOL/$lvol1 stripesize 8.00k
+	_do_fsck $fs ${DEFAULT_DEVICE_POOL}/$lvol1
+	fsadm  -f remove $DEFAULT_DEVICE_POOL
+done
+
+fsadm create --help
+
+# Some cases which should fail
+not fsadm create
+fsadm add $TEST_DEVS
+not fsadm create $pool1
+not fsadm create stripesize=16 stripes=3 $dev1 $dev2
+fsadm  -f remove --all
-- 
1.7.4.4


