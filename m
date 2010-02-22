From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 22 Feb 2010 14:47:56 -0000
Subject: LVM2/test t-pvcreate-operation.sh
Message-ID: <20100222144756.3616.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-02-22 14:47:56

Modified files:
	test           : t-pvcreate-operation.sh 

Log message:
	Relax a check on blkid exit value, which seems to be different in different
	versions. Fixes a spurious test failure introduced with -o pipefail.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvcreate-operation.sh.diff?cvsroot=lvm2&r1=1.16&r2=1.17

--- LVM2/test/t-pvcreate-operation.sh	2009/06/06 16:40:39	1.16
+++ LVM2/test/t-pvcreate-operation.sh	2010/02/22 14:47:55	1.17
@@ -114,4 +114,5 @@
 mkswap $dev1
 blkid -c /dev/null $dev1 | grep "swap"
 pvcreate -f $dev1
-blkid -c /dev/null $dev1 | not grep "swap"
+# blkid cannot make up its mind whether not finding anything it knows is a failure or not
+(blkid -c /dev/null $dev1 || true) | not grep "swap"


