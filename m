From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 28 Mar 2010 15:52:05 -0000
Subject: LVM2/test test-utils.sh
Message-ID: <20100328155205.29791.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-03-28 15:52:04

Modified files:
	test           : test-utils.sh 

Log message:
	When a scsi_debug modprobe fails, skip the test instead of failing it.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/test-utils.sh.diff?cvsroot=lvm2&r1=1.25&r2=1.26

--- LVM2/test/test-utils.sh	2010/03/23 14:47:35	1.25
+++ LVM2/test/test-utils.sh	2010/03/28 15:52:04	1.26
@@ -188,7 +188,7 @@
     local devs_before=`get_sd_devs_`
     # NOTE: it will _never_ make sense to pass num_tgts param;
     # last param wins.. so num_tgts=1 is imposed
-    modprobe scsi_debug dev_size_mb=$DEV_SIZE $SCSI_DEBUG_PARAMS num_tgts=1
+    modprobe scsi_debug dev_size_mb=$DEV_SIZE $SCSI_DEBUG_PARAMS num_tgts=1 || exit 200
     sleep 2 # allow for async Linux SCSI device registration
 
     local devs_after=`get_sd_devs_`


