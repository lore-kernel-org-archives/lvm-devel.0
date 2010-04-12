From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 12 Apr 2010 19:00:26 -0000
Subject: LVM2/test t-vgcfgbackup-usage.sh
Message-ID: <20100412190026.7948.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-04-12 19:00:25

Modified files:
	test           : t-vgcfgbackup-usage.sh 

Log message:
	Do not pollute /tmp with testing byproducts.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgcfgbackup-usage.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/test/t-vgcfgbackup-usage.sh	2009/05/19 09:48:32	1.2
+++ LVM2/test/t-vgcfgbackup-usage.sh	2010/04/12 19:00:23	1.3
@@ -18,7 +18,7 @@
 vg2=${PREFIX}vg01
 vgcreate $vg1 $dev1
 vgcreate $vg2 $dev2
-vgcfgbackup -f /tmp/bak-%s >out
+vgcfgbackup -f $TESTDIR/bak-%s >out
 grep "Volume group \"$vg1\" successfully backed up." out
 grep "Volume group \"$vg2\" successfully backed up." out
 vgremove -ff $vg1


