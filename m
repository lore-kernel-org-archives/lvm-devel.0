From: Lukas Czerner <lczerner@redhat.com>
Date: Tue, 27 Sep 2011 13:15:30 +0200
Subject: [PATCH 16/16] test: Add test for fsadm remove command
In-Reply-To: <1317122130-13790-1-git-send-email-lczerner@redhat.com>
References: <1317122130-13790-1-git-send-email-lczerner@redhat.com>
Message-ID: <1317122130-13790-17-git-send-email-lczerner@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The tests exercises the fsadm "remove" functionality, by trying various
combinations of arguments and checking the desired results.

Signed-off-by: Lukas Czerner <lczerner@redhat.com>
---
 test/t-fsadm-remove.sh |  115 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 115 insertions(+), 0 deletions(-)
 create mode 100644 test/t-fsadm-remove.sh

diff --git a/test/t-fsadm-remove.sh b/test/t-fsadm-remove.sh
new file mode 100644
index 0000000..9bec936
--- /dev/null
+++ b/test/t-fsadm-remove.sh
@@ -0,0 +1,115 @@
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
+test_description='Exercise fsadm remove'
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
+DEFAULT_VOLUME=${DEFAULT_DEVICE_POOL}/$lvol1
+
+_FS=
+which mkfs.ext2 && _FS="ext2"
+which mkfs.ext3 && _FS="ext3"
+which mkfs.ext4 && _FS="ext4"
+which mkfs.xfs  && _FS="xfs"
+
+
+TEST_MNT=$TESTDIR/mnt
+
+# Remove logical volume
+fsadm create $TEST_DEVS
+check lv_field $DEFAULT_VOLUME lv_name $lvol1
+fsadm -f remove $DEFAULT_VOLUME
+not check lv_field $DEFAULT_VOLUME lv_name $lvol1
+
+# Remove volume group
+fsadm create $TEST_DEVS
+check vg_field $DEFAULT_DEVICE_POOL vg_name $DEFAULT_DEVICE_POOL
+fsadm -f remove $DEFAULT_DEVICE_POOL
+not check vg_field $DEFAULT_DEVICE_POOL vg_name $DEFAULT_DEVICE_POOL
+
+if [ "$_FS" ]; then
+	[ ! -d $TEST_MNT ] && mkdir $TEST_MNT &> /dev/null
+	# Remove logical volume by mount point
+	fsadm create fs=$_FS $TEST_DEVS
+	mount ${DM_DEV_DIR}/$DEFAULT_VOLUME $TEST_MNT
+	check lv_field $DEFAULT_VOLUME lv_name $lvol1
+	fsadm -f remove $TEST_MNT
+	not check lv_field $DEFAULT_VOLUME lv_name $lvol1
+	fsadm -f remove $DEFAULT_DEVICE_POOL
+fi
+
+# Remove unused devices from the pool
+fsadm create $dev1 $dev2 $dev3
+fsadm add $TEST_DEVS
+check vg_field $DEFAULT_DEVICE_POOL pv_count $DEV_COUNT
+fsadm -f remove $TEST_DEVS
+check vg_field $DEFAULT_DEVICE_POOL pv_count 3
+fsadm -f remove --all
+
+# Remove multiple things
+fsadm add $dev1 $dev2 $pool1
+fsadm add $dev3 $dev4 $pool2
+fsadm create $pool2
+fsadm create $dev5 $dev6
+fsadm create $dev7 $dev8
+fsadm add $dev9
+check vg_field $pool1 pv_count 2
+check vg_field $pool2 pv_count 2
+check vg_field $pool2 lv_count 1
+check vg_field $DEFAULT_DEVICE_POOL pv_count 5
+check vg_field $DEFAULT_DEVICE_POOL lv_count 2
+check vg_field $pool1 vg_name $pool1
+check lv_field ${pool2}/$lvol1 lv_name $lvol1
+fsadm -f remove $pool1 ${pool2}/$lvol1 $DEFAULT_VOLUME $dev9
+not check vg_field $pool1 vg_name $pool1
+not check lv_field ${pool2}/$lvol1 lv_name $lvol1
+not check lv_field $DEFAULT_VOLUME lv_name $lvol1
+check vg_field $DEFAULT_DEVICE_POOL pv_count 4
+fsadm -f remove --all
+
+# Remove all
+fsadm add $dev1 $dev2 $pool1
+fsadm add $dev3 $dev4 $pool2
+fsadm create $pool2
+fsadm create $dev5 $dev6
+fsadm create $dev7 $dev8
+fsadm add $dev9
+check vg_field $pool1 pv_count 2
+check vg_field $pool2 pv_count 2
+check vg_field $pool2 lv_count 1
+check vg_field $DEFAULT_DEVICE_POOL pv_count 5
+check vg_field $DEFAULT_DEVICE_POOL lv_count 2
+check vg_field $pool1 vg_name $pool1
+check vg_field $pool2 vg_name $pool2
+check vg_field $DEFAULT_DEVICE_POOL vg_name $DEFAULT_DEVICE_POOL
+fsadm -f remove --all
+not check vg_field $pool1 vg_name $pool1
+not check vg_field $pool2 vg_name $pool2
+not check vg_field $DEFAULT_DEVICE_POOL vg_name $DEFAULT_DEVICE_POOL
+
+fsadm remove --help
+
+# Some cases which should fail
+not fsadm remove
-- 
1.7.4.4


