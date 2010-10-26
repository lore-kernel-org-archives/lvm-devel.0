From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 26 Oct 2010 01:25:47 -0000
Subject: LVM2/test test-utils.sh
Message-ID: <20101026012547.3169.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-10-26 01:25:47

Modified files:
	test           : test-utils.sh 

Log message:
	Explicitly have grep print the matching filenames (needed to
	successfully determine scsi_debug device).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/test-utils.sh.diff?cvsroot=lvm2&r1=1.53&r2=1.54

--- LVM2/test/test-utils.sh	2010/10/20 15:14:13	1.53
+++ LVM2/test/test-utils.sh	2010/10/26 01:25:46	1.54
@@ -245,7 +245,7 @@
     modprobe scsi_debug dev_size_mb=$DEV_SIZE $SCSI_DEBUG_PARAMS num_tgts=1 || exit 200
     sleep 2 # allow for async Linux SCSI device registration
 
-    local DEBUG_DEV=/dev/$(grep scsi_debug /sys/block/*/device/model | cut -f4 -d /)
+    local DEBUG_DEV=/dev/$(grep -H scsi_debug /sys/block/*/device/model | cut -f4 -d /)
     [ -b $DEBUG_DEV ] || exit 1 # should not happen
 
     # Create symlink to scsi_debug device in $DM_DEV_DIR


