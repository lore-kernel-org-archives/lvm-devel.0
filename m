From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 13 Apr 2010 06:24:21 -0000
Subject: LVM2/test test-utils.sh
Message-ID: <20100413062421.12969.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-04-13 06:24:21

Modified files:
	test           : test-utils.sh 

Log message:
	For the testsuite, set a default polling interval to 0 in lvm.conf. Cuts down
	testing time considerably.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/test-utils.sh.diff?cvsroot=lvm2&r1=1.33&r2=1.34

--- LVM2/test/test-utils.sh	2010/04/07 21:38:01	1.33
+++ LVM2/test/test-utils.sh	2010/04/13 06:24:20	1.34
@@ -373,6 +373,7 @@
   activation {
     udev_sync = 1
     udev_rules = 1
+    polling_interval = 0
   }
 EOF
 	cat $TESTDIR/etc/lvm.conf


