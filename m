From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 9 Jun 2011 14:26:48 -0000
Subject: LVM2/test t-topology-support.sh
Message-ID: <20110609142648.3300.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2011-06-09 14:26:47

Modified files:
	test           : t-topology-support.sh 

Log message:
	Fix topology test.
	
	Kernel version is misparsed in Fedora rawhide, just test sysfs file.
	
	SCSI_DEBUG_DEV is no longer exported, use provided file instead.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-topology-support.sh.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/test/t-topology-support.sh	2011/01/05 00:16:20	1.6
+++ LVM2/test/t-topology-support.sh	2011/06/09 14:26:47	1.7
@@ -10,22 +10,16 @@
 
 which mkfs.ext3 || exit 200
 
-# Get linux minor version
-linux_minor=$(echo `uname -r` | cut -d'.' -f3 | cut -d'-' -f1)
-
-test $linux_minor -ge 31 || exit 200
-
 . lib/test
 
 check_logical_block_size()
 {
-    local DEV_=$1
-    local LOGICAL_BS=$2
+    local DEV_=$(cat SCSI_DEBUG_DEV)
     # Verify logical_block_size - requires Linux >= 2.6.31
     SYSFS_LOGICAL_BLOCK_SIZE=`echo /sys/block/$(basename $DEV_)/queue/logical_block_size`
     if [ -f "$SYSFS_LOGICAL_BLOCK_SIZE" ] ; then
 	ACTUAL_LOGICAL_BLOCK_SIZE=`cat $SYSFS_LOGICAL_BLOCK_SIZE`
-	test $ACTUAL_LOGICAL_BLOCK_SIZE = $LOGICAL_BS
+	test $ACTUAL_LOGICAL_BLOCK_SIZE = $1
     fi
 }
 
@@ -60,13 +54,21 @@
 PER_DEV_SIZE=34
 DEV_SIZE=$(($NUM_DEVS*$PER_DEV_SIZE))
 
+# Test that kernel supports topology
+aux prepare_scsi_debug_dev $DEV_SIZE
+if [ ! -e /sys/block/$(basename $(cat SCSI_DEBUG_DEV))/alignment_offset ] ; then
+	aux cleanup_scsi_debug_dev
+	exit 200
+fi
+aux cleanup_scsi_debug_dev
+
 # ---------------------------------------------
 # Create "desktop-class" 4K drive
 # (logical_block_size=512, physical_block_size=4096, alignment_offset=0):
 LOGICAL_BLOCK_SIZE=512
 aux prepare_scsi_debug_dev $DEV_SIZE \
     sector_size=$LOGICAL_BLOCK_SIZE physblk_exp=3
-check_logical_block_size $SCSI_DEBUG_DEV $LOGICAL_BLOCK_SIZE
+check_logical_block_size $LOGICAL_BLOCK_SIZE
 
 aux prepare_pvs $NUM_DEVS $PER_DEV_SIZE
 vgcreate -c n $vg $(cat DEVICES)
@@ -81,7 +83,7 @@
 LOGICAL_BLOCK_SIZE=512
 aux prepare_scsi_debug_dev $DEV_SIZE \
     sector_size=$LOGICAL_BLOCK_SIZE physblk_exp=3 lowest_aligned=7
-check_logical_block_size $SCSI_DEBUG_DEV $LOGICAL_BLOCK_SIZE
+check_logical_block_size $LOGICAL_BLOCK_SIZE
 
 aux prepare_pvs $NUM_DEVS $PER_DEV_SIZE
 vgcreate -c n $vg $(cat DEVICES)
@@ -96,7 +98,7 @@
 LOGICAL_BLOCK_SIZE=4096
 aux prepare_scsi_debug_dev $DEV_SIZE \
     sector_size=$LOGICAL_BLOCK_SIZE
-check_logical_block_size $SCSI_DEBUG_DEV $LOGICAL_BLOCK_SIZE
+check_logical_block_size $LOGICAL_BLOCK_SIZE
 
 aux prepare_pvs $NUM_DEVS $PER_DEV_SIZE
 vgcreate -c n $vg $(cat DEVICES)


