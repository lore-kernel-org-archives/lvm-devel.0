From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 7 Apr 2010 21:38:01 -0000
Subject: LVM2/test test-utils.sh
Message-ID: <20100407213801.18602.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-04-07 21:38:01

Modified files:
	test           : test-utils.sh 

Log message:
	Don't forget to cd into $TESTDIR in test-utils.sh / prepare_testdir.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/test-utils.sh.diff?cvsroot=lvm2&r1=1.32&r2=1.33

--- LVM2/test/test-utils.sh	2010/04/07 21:19:20	1.32
+++ LVM2/test/test-utils.sh	2010/04/07 21:38:01	1.33
@@ -86,6 +86,8 @@
 	export DM_DEV_DIR=$TESTDIR/dev
 	mkdir $LVM_SYSTEM_DIR $DM_DEV_DIR $DM_DEV_DIR/mapper $TESTDIR/lib
 
+	cd $TESTDIR
+
 	for i in `find $abs_top_builddir/daemons/dmeventd/plugins/ -name \*.so`; do
 		echo Setting up symlink from $i to $TESTDIR/lib
 		ln -s $i $TESTDIR/lib
@@ -381,7 +383,6 @@
 	prepare_testroot
 	prepare_lvmconf
 	prepare_clvmd
-	source ./lvm-utils.sh
 }
 
 LANG=C
@@ -390,6 +391,7 @@
 unset CDPATH
 
 . ./init.sh || { echo >&2 you must run make first; exit 1; }
+. ./lvm-utils.sh
 
 set -vexE -o pipefail
 aux prepare


