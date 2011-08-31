From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 31 Aug 2011 12:42:56 -0000
Subject: LVM2/test/lib test.sh
Message-ID: <20110831124256.17688.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-08-31 12:42:55

Modified files:
	test/lib       : test.sh 

Log message:
	Do not call prepare_lvmetad just yet in tests.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/test.sh.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/test/lib/test.sh	2011/08/31 11:31:58	1.5
+++ LVM2/test/lib/test.sh	2011/08/31 12:42:55	1.6
@@ -54,7 +54,6 @@
 set -eE -o pipefail
 aux lvmconf
 aux prepare_clvmd
-aux prepare_lvmetad
 echo "@TESTDIR=$TESTDIR"
 echo "@PREFIX=$PREFIX"
 


