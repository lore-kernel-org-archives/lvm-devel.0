From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 29 Feb 2008 00:09:21 -0000
Subject: LVM2/test t-vgsplit-operation.sh
Message-ID: <20080229000921.4295.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-02-29 00:09:21

Modified files:
	test           : t-vgsplit-operation.sh 

Log message:
	Add vgsplit test to check failure when PV not in source volume group.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgsplit-operation.sh.diff?cvsroot=lvm2&r1=1.9&r2=1.10

--- LVM2/test/t-vgsplit-operation.sh	2008/02/28 17:39:47	1.9
+++ LVM2/test/t-vgsplit-operation.sh	2008/02/29 00:09:21	1.10
@@ -163,6 +163,19 @@
    vgremove -f $vg2 &&
    vgremove -f $vg1'
 
+test_expect_success \
+  'vgsplit rejects split because PV not in VG' \
+  'vgcreate $vg1 $d1 $d2 &&
+   vgcreate $vg2 $d3 $d4 &&
+   lvcreate -l 4 -n $lv1 $vg1 &&
+   lvcreate -l 4 -n $lv2 $vg1 &&
+   vgchange -an $vg1 &&
+   vgsplit $vg1 $vg2 $d3 2>err;
+   status=$?; echo status=$?; test $status = 5 &&
+   grep "^  Physical volume $d3 not in volume group $vg1" err &&
+   vgremove -f $vg2 &&
+   vgremove -f $vg1'
+
 test_done
 # Local Variables:
 # indent-tabs-mode: nil


