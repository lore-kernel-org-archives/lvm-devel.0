From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 23 Oct 2011 15:40:15 -0000
Subject: LVM2/test/lib aux.sh
Message-ID: <20111023154015.23161.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-23 15:40:15

Modified files:
	test/lib       : aux.sh 

Log message:
	Do not make link in the real /dev
	
	Skip trying to make link when real /dev dir is used for test.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/aux.sh.diff?cvsroot=lvm2&r1=1.31&r2=1.32

--- LVM2/test/lib/aux.sh	2011/09/24 21:15:13	1.31
+++ LVM2/test/lib/aux.sh	2011/10/23 15:40:15	1.32
@@ -265,7 +265,7 @@
     echo "$SCSI_DEBUG_DEV" > SCSI_DEBUG_DEV
     echo "$SCSI_DEBUG_DEV" > LOOP
     # Setting $LOOP provides means for prepare_devs() override
-    ln -snf $DEBUG_DEV $SCSI_DEBUG_DEV
+    test "$LVM_TEST_DEVDIR" != "/dev" && ln -snf $DEBUG_DEV $SCSI_DEBUG_DEV
     return 0
 }
 


