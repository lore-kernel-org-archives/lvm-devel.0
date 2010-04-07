From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 7 Apr 2010 16:04:23 -0000
Subject: LVM2/test test-utils.sh
Message-ID: <20100407160423.2733.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-04-07 16:04:23

Modified files:
	test           : test-utils.sh 

Log message:
	Set ulimit -c to unlimited to allow coredumps to be collected and analysed in
	the testsuite.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/test-utils.sh.diff?cvsroot=lvm2&r1=1.30&r2=1.31

--- LVM2/test/test-utils.sh	2010/04/07 14:46:27	1.30
+++ LVM2/test/test-utils.sh	2010/04/07 16:04:22	1.31
@@ -377,6 +377,7 @@
 }
 
 prepare() {
+	ulimit -c unlimited
 	prepare_testroot
 	prepare_lvmconf
 	prepare_clvmd


