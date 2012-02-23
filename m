From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 23 Feb 2012 14:55:31 -0000
Subject: LVM2/test/shell lvcreate-repair.sh
Message-ID: <20120223145531.21091.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2012-02-23 14:55:31

Modified files:
	test/shell     : lvcreate-repair.sh 

Log message:
	Add a vgscan to lvcreate-repair.sh. The old test applied device filter hacks to
	make devices invisible to lvm, but the behaviour of those is slightly different
	than of actual missing devices. Running vgscan after re-enabling the device
	triggers a metadata repair which is not done by vgremove -ff. This is not a
	regression, merely an odd behaviour that has been around even before lvmetad.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvcreate-repair.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/test/shell/lvcreate-repair.sh	2012/02/23 13:11:10	1.2
+++ LVM2/test/shell/lvcreate-repair.sh	2012/02/23 14:55:29	1.3
@@ -38,6 +38,7 @@
 		check lv_exists $vg $lv2
 
 		aux enable_dev $i $j
+		vgscan
 
 		test $i != $dev1 && check lv_exists $vg $lv1
 		check lv_exists $vg $lv2


