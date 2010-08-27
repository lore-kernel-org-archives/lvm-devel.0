From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 27 Aug 2010 08:52:56 -0000
Subject: LVM2/test test-utils.sh
Message-ID: <20100827085256.15644.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-08-27 08:52:55

Modified files:
	test           : test-utils.sh 

Log message:
	Do not run singlenode clvmd tests if support for singlenode not compiled in.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/test-utils.sh.diff?cvsroot=lvm2&r1=1.49&r2=1.50

--- LVM2/test/test-utils.sh	2010/08/27 07:59:40	1.49
+++ LVM2/test/test-utils.sh	2010/08/27 08:52:54	1.50
@@ -70,6 +70,9 @@
 	# skip if we don't have our own clvmd...
 	(which clvmd | grep $abs_builddir) || exit 200
 
+	# skip if we singlenode is not compiled in
+	(clvmd --help 2>&1 | grep "Available cluster managers" | grep singlenode) || exit 200
+
 	trap_teardown
 
 	clvmd -Isinglenode -d 1 &


