From: meyering@sourceware.org <meyering@sourceware.org>
Date: 5 Dec 2007 09:49:08 -0000
Subject: LVM2/test t-000-basic.sh
Message-ID: <20071205094908.25773.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	meyering at sourceware.org	2007-12-05 09:49:08

Modified files:
	test           : t-000-basic.sh 

Log message:
	Avoid spurious test failure when compiled with readline support.
	
	* test/t-000-basic.sh: Invoke initial test of lvm with its "version"
	argument, so that the behavior of the tool doesn't depend on whether
	readline was enabled at configure time.
	
	Author: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
	Committer: Jim Meyering <meyering@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-000-basic.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/test/t-000-basic.sh	2007/09/21 17:12:13	1.1
+++ LVM2/test/t-000-basic.sh	2007/12/05 09:49:08	1.2
@@ -13,8 +13,8 @@
 
 . ./test-lib.sh
 
-lvm >/dev/null 2>&1
-if test $? != 3; then
+lvm version >/dev/null 2>&1
+if test $? != 0; then
     echo >&2 'You do not seem to have built lvm yet.'
     exit 1
 fi


