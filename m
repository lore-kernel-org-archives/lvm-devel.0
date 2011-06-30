From: agk@sourceware.org <agk@sourceware.org>
Date: 30 Jun 2011 00:57:29 -0000
Subject: LVM2/test/lib aux.sh test.sh
Message-ID: <20110630005729.21546.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-06-30 00:57:29

Modified files:
	test/lib       : aux.sh test.sh 

Log message:
	test attempt to remove stray loop devs

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/aux.sh.diff?cvsroot=lvm2&r1=1.19&r2=1.20
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/test.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/test/lib/aux.sh	2011/06/29 18:18:18	1.19
+++ LVM2/test/lib/aux.sh	2011/06/30 00:57:29	1.20
@@ -90,7 +90,9 @@
 	rm -f DEVICES # devs is set in prepare_devs()
 	rm -f LOOP
 
-	# Display any loop devices that failed to get torn down
+	# Remove any loop devices that failed to get torn down
+	losetup -a
+	echo losetup -d `losetup -a | grep $COMMON_PREFIX | cut -d: -f1` 2>/dev/null || true
 	losetup -a
 }
 
--- LVM2/test/lib/test.sh	2011/02/09 17:57:14	1.3
+++ LVM2/test/lib/test.sh	2011/06/30 00:57:29	1.4
@@ -19,11 +19,13 @@
 . lib/utils
 
 OLDPWD="`pwd`"
-PREFIX="LVMTEST$$"
+COMMON_PREFIX="LVMTEST"
+PREFIX="${COMMON_PREFIX}$$"
 
 TESTDIR=$(mkdtemp ${LVM_TEST_DIR-$(pwd)} $PREFIX.XXXXXXXXXX) \
 	|| { echo "failed to create temporary directory in ${LVM_TEST_DIR-$(pwd)}"; exit 1; }
 
+export COMMON_PREFIX
 export PREFIX
 export TESTDIR
 


