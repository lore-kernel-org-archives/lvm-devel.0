From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 6 Apr 2010 14:24:17 -0000
Subject: LVM2/test t-lvcreate-operation.sh
Message-ID: <20100406142417.14575.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-04-06 14:24:17

Modified files:
	test           : t-lvcreate-operation.sh 

Log message:
	Using 'not' if the test 'should' fail.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvcreate-operation.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/test/t-lvcreate-operation.sh	2010/03/26 22:15:44	1.3
+++ LVM2/test/t-lvcreate-operation.sh	2010/04/06 14:24:13	1.4
@@ -38,5 +38,5 @@
 
 # --
 # Create mirror on one dev with mirrored log using --alloc anywhere, should fail
-lvcreate -m 1 -l4 -n $lv1 --mirrorlog mirrored $vg --alloc anywhere $dev1
+not lvcreate -m 1 -l4 -n $lv1 --mirrorlog mirrored $vg --alloc anywhere $dev1
 cleanup_lvs


