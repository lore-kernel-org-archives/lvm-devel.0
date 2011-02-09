From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 9 Feb 2011 17:57:14 -0000
Subject: LVM2/test/lib test.sh
Message-ID: <20110209175714.24658.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-02-09 17:57:14

Modified files:
	test/lib       : test.sh 

Log message:
	Allow overriding the DM_DEV_DIR used by the test suite (fixes BZ 672796). Use
	like this:
	
	# LVM_TEST_DEVDIR=/tmp/dev make check

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/test.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/test/lib/test.sh	2011/01/05 00:26:19	1.2
+++ LVM2/test/lib/test.sh	2011/02/09 17:57:14	1.3
@@ -31,8 +31,11 @@
 trap 'aux teardown' EXIT # don't forget to clean up
 
 export LVM_SYSTEM_DIR=$TESTDIR/etc
-export DM_DEV_DIR=$TESTDIR/dev
-mkdir $LVM_SYSTEM_DIR $DM_DEV_DIR $DM_DEV_DIR/mapper $TESTDIR/lib
+DM_DEV_DIR=$TESTDIR/dev
+test -n "$LVM_TEST_DEVDIR" && DM_DEV_DIR="$LVM_TEST_DEVDIR"
+export DM_DEV_DIR
+mkdir $LVM_SYSTEM_DIR $TESTDIR/lib
+mkdir -p $DM_DEV_DIR $DM_DEV_DIR/mapper
 
 cd $TESTDIR
 


