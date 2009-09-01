From: Mike Snitzer <snitzer@redhat.com>
Date: Tue, 1 Sep 2009 13:14:29 -0400
Subject: Re: [RFC][PATCH] lvm2 test for snapshots on a 4K drive
In-Reply-To: <20090901170347.GB18124@redhat.com>
References: <20090901170347.GB18124@redhat.com>
Message-ID: <20090901171429.GC18124@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Sep 01 2009 at  1:03pm -0400,
Mike Snitzer <snitzer@redhat.com> wrote:

> This patch adds a generic way to establish a scsi_debug-based 4K drive
> for use by an LVM2 test (rather than using the traditional loop device).
> 
> t-4k-drive.sh shows how this new 'prepare_scsi_debug_dev' function can
> be used repeatedly (within a script) to test LVM2 ontop of a
> ramdisk-based SCSI device w/ arbitrary scsi_debug features.
> 
> prepare_scsi_debug_dev currently assumes exclussive access to the
> scsi_debug module.  Any script will be skipped if it tries to use
> prepare_scsi_debug_dev when scsi_debug is unavailable or already loaded
> into the kernel.

And here is alternative way to allow a script to override the type of
underlying device that is used for all PVs in a test.

It is a bit more rigid to do this way (as compared to the original RFC
patch and its multiple calls to 'prepare_scsi_debug_dev').  Exposing the
'prepare_dev_' hook just enables a script a different way to formalize the
use of an alternative underlying device for LVM2 testing.

Not sure this is of any value but figured I'd share in the hopes of
clarifying the original RFC patch a bit more.

Mike

---
diff --git a/test/test-utils.sh b/test/test-utils.sh
index 19478b5..53c71b3 100644
--- a/test/test-utils.sh
+++ b/test/test-utils.sh
@@ -158,6 +158,16 @@ cleanup_scsi_debug_dev()
     unset SCSI_DEBUG_DEV
 }
 
+# This is a stub function that is run via prepare_devs().
+# Override it with a per-test function, e.g., to setup more
+# sophisticated physical volumes (e.g. with scsi_debug).
+# Any test that provides this override _must_ set $LOOP to the
+# full path of the device that was created under $G_dev_
+# - Setting $LOOP provides the means to short-circuit
+#   prepare_devs()'s use of prepare_loop()
+# - TODO: rename $LOOP to $LVMTEST_DEVICE?
+prepare_dev_() { :; }
+
 prepare_devs() {
 	local n="$1"
 	test -z "$n" && n=3
@@ -166,6 +176,9 @@ prepare_devs() {
 	local pvname="$3"
 	test -z "$pvname" && pvname="pv"
 
+	# prepare_dev_ is a user-overridable that prepares the test's
+	# underlying device (it _must_ set $LOOP to be effective)
+	prepare_dev_ $(($n*$devsize))
 	prepare_loop $(($n*$devsize))
 
 	PREFIX="LVMTEST$$"

diff --git a/test/t-4k-drive-prime.sh b/test/t-4k-drive-prime.sh
new file mode 100755
index 0000000..eb5a01a
--- /dev/null
+++ b/test/t-4k-drive-prime.sh
@@ -0,0 +1,71 @@
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
+prepare_dev_() {
+    DEV_SIZE=$1
+    test -z "$DEV_SIZE" && DEV_SIZE=33
+
+    # Create ramdisk-based "enterprise-class" 4K drive
+    # (logical_block_size=4096, physical_block_size=4096, alignment_offset=0):
+    LOGICAL_BLOCK_SIZE=4096
+    prepare_scsi_debug_dev $DEV_SIZE \
+	sector_size=$LOGICAL_BLOCK_SIZE
+
+    check_logical_block_size $SCSI_DEBUG_DEV $LOGICAL_BLOCK_SIZE
+}
+
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
+lvdev_() {
+  echo "$G_dev_/$1/$2"
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
+NUM_DEVS=1
+PER_DEV_SIZE=33
+aux prepare_vg $NUM_DEVS $PER_DEV_SIZE
+
+# test snapshot on 4K sector drive (logical_block_size=4096)
+test_snapshot_mount


