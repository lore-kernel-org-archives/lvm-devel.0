From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 13 Apr 2010 07:02:15 -0000
Subject: LVM2/test test-utils.sh
Message-ID: <20100413070215.17786.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-04-13 07:02:15

Modified files:
	test           : test-utils.sh 

Log message:
	Disable the rather-dangerous prepare_scsi_debug_dev in the testsuite.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/test-utils.sh.diff?cvsroot=lvm2&r1=1.34&r2=1.35

--- LVM2/test/test-utils.sh	2010/04/13 06:24:20	1.34
+++ LVM2/test/test-utils.sh	2010/04/13 07:02:14	1.35
@@ -194,6 +194,12 @@
 # - scripts must take care not to use a DEV_SIZE that will enduce OOM-killer
 prepare_scsi_debug_dev()
 {
+    # FIXME this is extremely fragile and can cause data loss if an unrelated
+    # SCSI device appears at a wrong time... we need the code to reliably
+    # identify the scsi_debug device it has created before we can re-include
+    # this in the testsuite
+    exit 200
+
     local DEV_SIZE="$1"
     shift
     local SCSI_DEBUG_PARAMS="$@"


