From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 24 May 2010 17:19:53 -0000
Subject: LVM2/test test-utils.sh
Message-ID: <20100524171953.1639.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-05-24 17:19:50

Modified files:
	test           : test-utils.sh 

Log message:
	Use mv -f for replace config in test.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/test-utils.sh.diff?cvsroot=lvm2&r1=1.45&r2=1.46

--- LVM2/test/test-utils.sh	2010/05/24 17:18:05	1.45
+++ LVM2/test/test-utils.sh	2010/05/24 17:19:50	1.46
@@ -392,7 +392,7 @@
   }
 EOF
 	# FIXME remove this workaround after mmap & truncating file problems solved
-	mv $TESTDIR/etc/lvm.conf.new $TESTDIR/etc/lvm.conf
+	mv -f $TESTDIR/etc/lvm.conf.new $TESTDIR/etc/lvm.conf
 	cat $TESTDIR/etc/lvm.conf
 }
 


