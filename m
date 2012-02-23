From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 23 Feb 2012 14:21:18 -0000
Subject: LVM2/test/shell lvmcache-exercise.sh
Message-ID: <20120223142118.9920.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2012-02-23 14:21:18

Modified files:
	test/shell     : lvmcache-exercise.sh 

Log message:
	Kick out a debugging call to valgrind in lvmcache-exercise.sh.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvmcache-exercise.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/test/shell/lvmcache-exercise.sh	2012/02/23 13:11:10	1.2
+++ LVM2/test/shell/lvmcache-exercise.sh	2012/02/23 14:21:18	1.3
@@ -19,5 +19,4 @@
 pvscan
 vgcreate $vg1 $dev2
 aux enable_dev $dev1
-valgrind --trace-children=yes pvs
 pvs


