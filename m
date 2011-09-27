From: Lukas Czerner <lczerner@redhat.com>
Date: Tue, 27 Sep 2011 15:42:50 +0200
Subject: [PATCH v3 17/18] test: Add test for fsadm resize command
In-Reply-To: <1317130971-24173-1-git-send-email-lczerner@redhat.com>
References: <1317130971-24173-1-git-send-email-lczerner@redhat.com>
Message-ID: <1317130971-24173-18-git-send-email-lczerner@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The tests exercises the fsadm "resize" functionality, by trying various
combinations of arguments and checking the desired results. It also
tries to create and resize volumes with various supported file systems,
checking the resulting size.

Signed-off-by: Lukas Czerner <lczerner@redhat.com>
---
 test/t-fsadm-resize.sh |  125 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 125 insertions(+), 0 deletions(-)
 create mode 100644 test/t-fsadm-resize.sh

diff --git a/test/t-fsadm-resize.sh b/test/t-fsadm-resize.sh
new file mode 100644
index 0000000..130bd54
--- /dev/null
+++ b/test/t-fsadm-resize.sh
@@ -0,0 +1,125 @@
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
+DEFAULT_VOLUME=${DEFAULT_DEVICE_POOL}/$lvol1
+
+TEST_FS=
+which mkfs.ext2 && TEST_FS+="ext2 "
+which mkfs.ext3 && TEST_FS+="ext3 "
+which mkfs.ext4 && TEST_FS+="ext4 "
+which mkfs.xfs  && TEST_FS+="xfs"
+
+TEST_MNT=$TESTDIR/mnt
+
+_test_resize()
+{
+	size=$((TEST_MAX_SIZE/2))
+	fsadm -f resize size=${size}M ${DM_DEV_DIR}/$DEFAULT_VOLUME
+	size=$(align_size_up $size)
+	check lv_field $DEFAULT_DEVICE_POOL/$lvol1 lv_size ${size}.00m
+
+	# xfs does not support shrinking (xfs only grows big!! :))
+	if [ "$fs" != "xfs" ]; then
+		fsadm -f -v resize size=-$(($TEST_MAX_SIZE/4))M $DEFAULT_VOLUME
+		size=$(align_size_up $(($size-($TEST_MAX_SIZE/4))))
+		check lv_field $DEFAULT_DEVICE_POOL/$lvol1 lv_size ${size}.00m
+	fi
+	fsadm -f -v resize size=+$(($TEST_MAX_SIZE/5))M $DEFAULT_VOLUME
+	size=$(align_size_up $(($size+($TEST_MAX_SIZE/5))))
+	check lv_field $DEFAULT_DEVICE_POOL/$lvol1 lv_size ${size}.00m
+}
+
+fsadm add $TEST_DEVS
+size=$((TEST_MAX_SIZE/3))
+fsadm create size=${size}M $TEST_DEVS
+size=$(align_size_up $size)
+check lv_field $DEFAULT_DEVICE_POOL/$lvol1 lv_size ${size}.00m
+
+fsadm -f resize size=+$(($TEST_MAX_SIZE/3))M ${DM_DEV_DIR}/$DEFAULT_VOLUME
+size=$(align_size_up $(($size+($TEST_MAX_SIZE/3))))
+check lv_field $DEFAULT_DEVICE_POOL/$lvol1 lv_size ${size}.00m
+
+fsadm -f resize size=-$(($TEST_MAX_SIZE/2))M $DEFAULT_VOLUME
+size=$(align_size_up $(($size-($TEST_MAX_SIZE/2))))
+check lv_field $DEFAULT_DEVICE_POOL/$lvol1 lv_size ${size}.00m
+
+fsadm -f resize size=$(($TEST_MAX_SIZE/2))M $DEFAULT_VOLUME
+size=$(align_size_up $(($TEST_MAX_SIZE/2)))
+check lv_field $DEFAULT_DEVICE_POOL/$lvol1 lv_size ${size}.00m
+fsadm -f remove $DEFAULT_DEVICE_POOL
+
+fsadm create $dev1
+check lv_field $DEFAULT_DEVICE_POOL/$lvol1 pv_count 1
+devs=${TEST_DEVS##*$dev1 }
+fsadm resize size=+$((TEST_MAX_SIZE/2))M $DEFAULT_VOLUME $devs
+check lv_field $DEFAULT_DEVICE_POOL/$lvol1 pv_count $DEV_COUNT
+fsadm -f remove $DEFAULT_DEVICE_POOL
+
+fsadm create $dev1
+check lv_field $DEFAULT_DEVICE_POOL/$lvol1 pv_count 1
+devs=${TEST_DEVS##*$dev1 }
+fsadm resize size=$((TEST_MAX_SIZE/2))M ${DM_DEV_DIR}/$DEFAULT_VOLUME $devs
+check lv_field $DEFAULT_DEVICE_POOL/$lvol1 pv_count $DEV_COUNT
+fsadm -f remove $DEFAULT_DEVICE_POOL
+
+[ ! -d $TEST_MNT ] && mkdir $TEST_MNT &> /dev/null
+for fs in $TEST_FS; do
+	# umounted test
+	fsadm add $TEST_DEVS
+	size=$((TEST_MAX_SIZE/4))
+	fsadm create fs=$fs size=${size}M $TEST_DEVS
+
+	_test_resize
+	fsadm -f check $DEFAULT_VOLUME
+	fsadm -f remove $DEFAULT_DEVICE_POOL
+
+	# mounted test
+	fsadm add $TEST_DEVS
+	size=$((TEST_MAX_SIZE/4))
+	fsadm create fs=$fs size=${size}M $TEST_DEVS
+
+	mount ${DM_DEV_DIR}/$DEFAULT_VOLUME $TEST_MNT
+
+	_test_resize
+
+	umount $TEST_MNT
+	fsadm -f check $DEFAULT_VOLUME
+	fsadm -f remove $DEFAULT_DEVICE_POOL
+done
+fsadm  -f remove --all
+
+fsadm resize --help
+
+# Some cases which should fail
+not fsadm resize
+not fsadm resize _garbage_
+not fsadm resize $dev1
+fsadm create $TEST_DEVS
+not fsadm resize $DEFAULT_VOLUME
+not fsadm -f resize size=+10G $DEFAULT_VOLUME
+not fsadm -f resize size=-10G $DEFAULT_VOLUME
-- 
1.7.4.4


