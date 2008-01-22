From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 22 Jan 2008 03:30:14 -0000
Subject: LVM2/test t-vgsplit-operation.sh
Message-ID: <20080122033014.11245.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-01-22 03:30:14

Modified files:
	test           : t-vgsplit-operation.sh 

Log message:
	Fix vgsplit tests 12-13

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgsplit-operation.sh.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/test/t-vgsplit-operation.sh	2008/01/22 03:25:45	1.6
+++ LVM2/test/t-vgsplit-operation.sh	2008/01/22 03:30:14	1.7
@@ -135,7 +135,8 @@
 
 test_expect_success \
   'vgsplit rejects vg with active lv' \
-  'vgcreate $vg1 $d1 $d2 &&
+  'pvcreate -ff -M2 $d3 $d4 &&
+   vgcreate $vg1 $d1 $d2 &&
    vgcreate $vg2 $d3 $d4 &&
    lvcreate -l 4 -n lv1 $vg1 &&
    vgsplit $vg1 $vg2 $d1 2>err;


