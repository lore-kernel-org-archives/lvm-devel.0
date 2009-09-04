From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 4 Sep 2009 14:26:17 -0000
Subject: LVM2/test lvm2app.sh
Message-ID: <20090904142617.27442.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-09-04 14:26:17

Modified files:
	test           : lvm2app.sh 

Log message:
	Fix path to test/api/vgtest in nightly testsuite.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lvm2app.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/test/lvm2app.sh	2009/09/04 12:54:23	1.1
+++ LVM2/test/lvm2app.sh	2009/09/04 14:26:16	1.2
@@ -20,4 +20,4 @@
 
 echo `pwd`
 ls -lR `pwd`
-../api/vgtest $vg1 $dev1 $dev2
+$abs_srcdir/api/vgtest $vg1 $dev1 $dev2


