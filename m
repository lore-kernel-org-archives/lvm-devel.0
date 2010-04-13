From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 13 Apr 2010 06:25:09 -0000
Subject: LVM2/test t-lvcreate-usage.sh
Message-ID: <20100413062509.13455.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-04-13 06:25:08

Modified files:
	test           : t-lvcreate-usage.sh 

Log message:
	Fix t-lvcreate-usage, as lvcreate ... -i1 no longer prints "Redundant stripes
	argument: default is 1".

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvcreate-usage.sh.diff?cvsroot=lvm2&r1=1.17&r2=1.18

--- LVM2/test/t-lvcreate-usage.sh	2009/12/03 01:48:07	1.17
+++ LVM2/test/t-lvcreate-usage.sh	2010/04/13 06:25:08	1.18
@@ -33,8 +33,7 @@
 grep "^  Stripe size cannot be larger than" err
 
 # 'lvcreate w/single stripe succeeds with diagnostics to stdout' 
-lvcreate -L 64m -n $lv -i1 --stripesize 4 $vg >out 2>err
-grep "^  Redundant stripes argument: default is 1\$" out 
+lvcreate -L 64m -n $lv -i1 --stripesize 4 $vg 2> err | tee out
 grep "^  Ignoring stripesize argument with single stripe\$" out 
 lvdisplay $vg 
 lvremove -ff $vg


