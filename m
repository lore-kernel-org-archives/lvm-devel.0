From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 19 Jan 2010 16:44:58 -0000
Subject: LVM2/test test-utils.sh t-topology-support.sh
Message-ID: <20100119164458.29905.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-01-19 16:44:57

Modified files:
	test           : test-utils.sh 
Added files:
	test           : t-topology-support.sh 

Log message:
	Add a common way to establish a scsi_debug-based 4K drive for use by an
	LVM2 test (rather than using the traditional loop device).
	
	prepare_scsi_debug_dev currently assumes exclussive access to the
	scsi_debug module.  Any script that tries to use prepare_scsi_debug_dev
	when scsi_debug is unavailable or already loaded into the kernel will be
	skipped.
	
	t-topology-support.sh shows how prepare_scsi_debug_dev function can be
	used repeatedly (within a script) to test LVM2 ontop of a ramdisk-based
	SCSI device w/ arbitrary scsi_debug features.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-topology-support.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/test-utils.sh.diff?cvsroot=lvm2&r1=1.17&r2=1.18

/cvs/lvm2/LVM2/test/t-topology-support.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-topology-support.sh
+++ -	2010-01-19 16:44:58.048289000 +0000
@@ -0,0 +1,96 @@
+# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
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
+    vgchange -an $vg
+    lvremove -f $vg/$lv2
+    lvremove -f $vg/$lv1
+}
+
+# FIXME add more topology-specific tests and validation (striped LVs, etc)
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
+aux prepare_vg $NUM_DEVS $PER_DEV_SIZE
+test_snapshot_mount
+vgremove $vg
--- LVM2/test/test-utils.sh	2010/01/11 15:43:19	1.17
+++ LVM2/test/test-utils.sh	2010/01/19 16:44:57	1.18
@@ -40,8 +40,15 @@
 		done
 	}
 
-	test -n "$LOOP" && losetup -d $LOOP
-	test -n "$LOOPFILE" && rm -f $LOOPFILE
+	# NOTE: SCSI_DEBUG_DEV test must come before the LOOP test because
+	# prepare_scsi_debug_dev() also sets LOOP to short-circuit prepare_loop()
+	if [ -n "$SCSI_DEBUG_DEV" ] ; then
+		modprobe -r scsi_debug
+	else
+		test -n "$LOOP" && losetup -d $LOOP
+		test -n "$LOOPFILE" && rm -f $LOOPFILE
+	fi
+	unset devs # devs is set in prepare_devs()
 }
 
 teardown_() {
@@ -94,6 +101,68 @@
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
+    # Skip test if awk isn't available (required for get_sd_devs_)
+    which awk || exit 200
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


