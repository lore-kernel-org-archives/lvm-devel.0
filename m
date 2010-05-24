From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 24 May 2010 19:27:39 -0000
Subject: LVM2/test t-topology-support.sh
Message-ID: <20100524192739.1100.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-05-24 19:27:38

Modified files:
	test           : t-topology-support.sh 

Log message:
	Fix topology test after last changes to not leak loop devices.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-topology-support.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/test/t-topology-support.sh	2010/04/07 14:46:27	1.3
+++ LVM2/test/t-topology-support.sh	2010/05/24 19:27:38	1.4
@@ -68,7 +68,8 @@
     sector_size=$LOGICAL_BLOCK_SIZE physblk_exp=3
 check_logical_block_size $SCSI_DEBUG_DEV $LOGICAL_BLOCK_SIZE
 
-aux prepare_vg $NUM_DEVS $PER_DEV_SIZE
+aux prepare_pvs $NUM_DEVS $PER_DEV_SIZE
+vgcreate -c n $vg $devs
 test_snapshot_mount
 vgremove $vg
 
@@ -82,7 +83,8 @@
     sector_size=$LOGICAL_BLOCK_SIZE physblk_exp=3 lowest_aligned=7
 check_logical_block_size $SCSI_DEBUG_DEV $LOGICAL_BLOCK_SIZE
 
-aux prepare_vg $NUM_DEVS $PER_DEV_SIZE
+aux prepare_pvs $NUM_DEVS $PER_DEV_SIZE
+vgcreate -c n $vg $devs
 test_snapshot_mount
 vgremove $vg
 
@@ -96,6 +98,7 @@
     sector_size=$LOGICAL_BLOCK_SIZE
 check_logical_block_size $SCSI_DEBUG_DEV $LOGICAL_BLOCK_SIZE
 
-aux prepare_vg $NUM_DEVS $PER_DEV_SIZE
+aux prepare_pvs $NUM_DEVS $PER_DEV_SIZE
+vgcreate -c n $vg $devs
 test_snapshot_mount
 vgremove $vg


