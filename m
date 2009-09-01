From: Mike Snitzer <snitzer@redhat.com>
Date: Tue, 1 Sep 2009 13:03:48 -0400
Subject: [RFC][PATCH] lvm2 test for snapshots on a 4K drive
Message-ID: <20090901170347.GB18124@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch adds a generic way to establish a scsi_debug-based 4K drive
for use by an LVM2 test (rather than using the traditional loop device).

t-4k-drive.sh shows how this new 'prepare_scsi_debug_dev' function can
be used repeatedly (within a script) to test LVM2 ontop of a
ramdisk-based SCSI device w/ arbitrary scsi_debug features.

prepare_scsi_debug_dev currently assumes exclussive access to the
scsi_debug module.  Any script will be skipped if it tries to use
prepare_scsi_debug_dev when scsi_debug is unavailable or already loaded
into the kernel.

Signed-off-by: Mike Snitzer <snitzer@redhat.com>

---
diff --git a/test/t-4k-drive.sh b/test/t-4k-drive.sh
new file mode 100644
index 0000000..8e06388
--- /dev/null
+++ b/test/t-4k-drive.sh
@@ -0,0 +1,98 @@
+# Copyright (C) 2009 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+which awk || exit 200
+which mkfs.ext3 || exit 200
+
+. ./test-utils.sh
+
+check_logical_block_size()
+{
+    local DEV_=$1
+    local LOGICAL_BS=$2
+    # Verify logical_block_size - requires Linux >= 2.6.31
+    SYSFS_LOGICAL_BLOCK_SIZE=`echo /sys/block/$(basename $DEV_)/queue/logical_block_size`
+    if [ -f "$SYSFS_LOGICAL_BLOCK_SIZE" ] ; then
+	ACTUAL_LOGICAL_BLOCK_SIZE=`cat $SYSFS_LOGICAL_BLOCK_SIZE`
+	test $ACTUAL_LOGICAL_BLOCK_SIZE = $LOGICAL_BS
+    fi
+}
+
+lvdev_() 
+{
+    echo "$G_dev_/$1/$2"
+}
+
+test_snapshot_mount()
+{
+    lvcreate -L 16M -n $lv1 $vg $dev1
+    mkfs.ext3 $(lvdev_ $vg $lv1)
+    mkdir test_mnt
+    mount $(lvdev_ $vg $lv1) test_mnt
+    lvcreate -L 16M -n $lv2 -s $vg/$lv1
+    umount test_mnt
+    # mount the origin
+    mount $(lvdev_ $vg $lv1) test_mnt
+    umount test_mnt
+    # mount the snapshot
+    mount $(lvdev_ $vg $lv2) test_mnt
+    umount test_mnt
+    rm -r test_mnt
+    #sleep 1 # needed so 'vgchange -an' works reliably within KVM (cache=off)
+    vgchange -an $vg
+    #sleep 1 # needed so 'lvremove -f' works reliably within KVM (cache=off)
+    lvremove -f $vg/$lv2
+    lvremove -f $vg/$lv1
+}
+
+
+NUM_DEVS=1
+PER_DEV_SIZE=33
+DEV_SIZE=$(($NUM_DEVS*$PER_DEV_SIZE))
+
+# ---------------------------------------------
+# Create "desktop-class" 4K drive
+# (logical_block_size=512, physical_block_size=4096, alignment_offset=0):
+LOGICAL_BLOCK_SIZE=512
+prepare_scsi_debug_dev $DEV_SIZE \
+    sector_size=$LOGICAL_BLOCK_SIZE physblk_exp=3
+check_logical_block_size $SCSI_DEBUG_DEV $LOGICAL_BLOCK_SIZE
+
+aux prepare_vg $NUM_DEVS $PER_DEV_SIZE
+test_snapshot_mount
+vgremove $vg
+
+cleanup_scsi_debug_dev
+
+# ---------------------------------------------
+# Create "desktop-class" 4K drive w/ 63-sector DOS partition compensation
+# (logical_block_size=512, physical_block_size=4096, alignment_offset=3584):
+LOGICAL_BLOCK_SIZE=512
+prepare_scsi_debug_dev $DEV_SIZE \
+    sector_size=$LOGICAL_BLOCK_SIZE physblk_exp=3 lowest_aligned=7
+check_logical_block_size $SCSI_DEBUG_DEV $LOGICAL_BLOCK_SIZE
+
+aux prepare_vg $NUM_DEVS $PER_DEV_SIZE
+test_snapshot_mount
+vgremove $vg
+
+cleanup_scsi_debug_dev
+
+# ---------------------------------------------
+# Create "enterprise-class" 4K drive
+# (logical_block_size=4096, physical_block_size=4096, alignment_offset=0):
+LOGICAL_BLOCK_SIZE=4096
+prepare_scsi_debug_dev $DEV_SIZE \
+    sector_size=$LOGICAL_BLOCK_SIZE
+check_logical_block_size $SCSI_DEBUG_DEV $LOGICAL_BLOCK_SIZE
+
+prepare_vg $NUM_DEVS $PER_DEV_SIZE
+test_snapshot_mount
+vgremove $vg
diff --git a/test/test-utils.sh b/test/test-utils.sh
index fa1f2c5..19478b5 100644
--- a/test/test-utils.sh
+++ b/test/test-utils.sh
@@ -40,8 +40,13 @@ teardown() {
 		done
 	}
 
-	test -n "$LOOP" && losetup -d $LOOP
-	test -n "$LOOPFILE" && rm -f $LOOPFILE
+	if [ -n "$SCSI_DEBUG_DEV" ] ; then
+		modprobe -r scsi_debug
+	elif [ -n "$LOOP" ] ; then
+		losetup -d $LOOP
+		test -n "$LOOPFILE" && rm -f $LOOPFILE
+	fi	
+	unset devs # devs is set in prepare_devs()
 }
 
 teardown_() {
@@ -94,6 +99,65 @@ prepare_loop() {
 	exit 1 # should not happen
 }
 
+get_sd_devs_()
+{
+    # prepare_scsi_debug_dev() requires the ability to lookup
+    # the scsi_debug created SCSI device in /dev/
+    local _devs=$(lvmdiskscan --config 'devices { filter = [ "a|/dev/sd.*|", "r|.*|" ] scan = "/dev/" }' | grep /dev/sd | awk '{ print $1 }')
+    echo $_devs
+}
+
+# A drop-in replacement for prepare_loop() that uses scsi_debug to create
+# a ramdisk-based SCSI device upon which all LVM devices will be created
+# - scripts must take care not to use a DEV_SIZE that will enduce OOM-killer
+prepare_scsi_debug_dev()
+{
+    local DEV_SIZE="$1"
+    shift
+    local SCSI_DEBUG_PARAMS="$@"
+
+    test -n "$SCSI_DEBUG_DEV" && return 0
+    trap 'aux teardown_' EXIT # don't forget to clean up
+    trap 'set +vex; STACKTRACE; set -vex' ERR
+
+    # Skip test if scsi_debug module is unavailable or is already in use
+    modinfo scsi_debug || exit 200
+    lsmod | grep -q scsi_debug && exit 200
+
+    # Create the scsi_debug device and determine the new scsi device's name
+    local devs_before=`get_sd_devs_`
+    # NOTE: it will _never_ make sense to pass num_tgts param;
+    # last param wins.. so num_tgts=1 is imposed
+    modprobe scsi_debug dev_size_mb=$DEV_SIZE $SCSI_DEBUG_PARAMS num_tgts=1
+    sleep 2 # allow for async Linux SCSI device registration
+
+    local devs_after=`get_sd_devs_`
+    for dev1 in $devs_after; do
+	FOUND=0
+	for dev2 in $devs_before; do
+	    if [ "$dev1" = "$dev2" ]; then
+		FOUND=1
+		break
+	    fi
+	done
+	if [ $FOUND -eq 0 ]; then
+	    # Create symlink to scsi_debug device in $G_dev_
+	    SCSI_DEBUG_DEV=$G_dev_/$(basename $dev1)
+	    # Setting $LOOP provides means for prepare_devs() override
+	    LOOP=$SCSI_DEBUG_DEV
+	    ln -snf $dev1 $SCSI_DEBUG_DEV
+	    return 0
+	fi
+    done
+    exit 1 # should not happen
+}
+
+cleanup_scsi_debug_dev()
+{
+    aux teardown
+    unset SCSI_DEBUG_DEV
+}
+
 prepare_devs() {
 	local n="$1"
 	test -z "$n" && n=3


