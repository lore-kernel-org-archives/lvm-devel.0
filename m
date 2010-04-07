From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 7 Apr 2010 21:19:21 -0000
Subject: LVM2/test test-utils.sh
Message-ID: <20100407211921.12252.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-04-07 21:19:21

Modified files:
	test           : test-utils.sh 

Log message:
	Fix a mis-override of $PWD in test-utils.sh.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/test-utils.sh.diff?cvsroot=lvm2&r1=1.31&r2=1.32

--- LVM2/test/test-utils.sh	2010/04/07 16:04:22	1.31
+++ LVM2/test/test-utils.sh	2010/04/07 21:19:20	1.32
@@ -75,7 +75,7 @@
 }
 
 prepare_testroot() {
-	PWD="`pwd`"
+	OLDPWD="`pwd`"
 	PREFIX="LVMTEST$$"
 
 	trap_teardown
@@ -122,7 +122,7 @@
 	unset devs # devs is set in prepare_devs()
 
 	test -n "$TESTDIR" && {
-		cd $PWD
+		cd $OLDPWD
 		rm -rf $TESTDIR || echo BLA
 	}
 }


