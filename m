From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 14 Apr 2010 12:04:24 -0000
Subject: LVM2/test test-utils.sh
Message-ID: <20100414120424.24613.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-04-14 12:04:24

Modified files:
	test           : test-utils.sh 

Log message:
	SIGTERM testing clvmd before SIGKILL-ing it.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/test-utils.sh.diff?cvsroot=lvm2&r1=1.36&r2=1.37

--- LVM2/test/test-utils.sh	2010/04/13 08:01:53	1.36
+++ LVM2/test/test-utils.sh	2010/04/14 12:04:23	1.37
@@ -96,7 +96,11 @@
 	echo $LOOP
 	echo $PREFIX
 
-	test -n "$LOCAL_CLVMD" && kill -9 "$LOCAL_CLVMD"
+	test -n "$LOCAL_CLVMD" && {
+		kill "$LOCAL_CLVMD"
+		sleep .1
+		kill -9 "$LOCAL_CLVMD" || true
+	}
 
 	test -n "$PREFIX" && {
 		rm -rf $TESTDIR/dev/$PREFIX*


