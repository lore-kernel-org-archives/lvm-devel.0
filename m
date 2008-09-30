From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 30 Sep 2008 21:45:43 -0000
Subject: LVM2/test harness.sh
Message-ID: <20080930214543.20363.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2008-09-30 21:45:42

Modified files:
	test           : harness.sh 

Log message:
	Make harness.sh exit with non-zero status when tests fail.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/harness.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/test/harness.sh	2008/09/30 21:43:16	1.2
+++ LVM2/test/harness.sh	2008/09/30 21:45:42	1.3
@@ -29,6 +29,7 @@
     for t in $failed; do
 	printf "\t%s\n" $t
     done
+    exit 1
 else
     echo "All tests passed."
 fi


