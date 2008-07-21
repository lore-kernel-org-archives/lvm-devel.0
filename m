From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 21 Jul 2008 18:50:11 -0000
Subject: LVM2/test t-pvcreate-operation.sh
Message-ID: <20080721185011.7527.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-07-21 18:50:10

Modified files:
	test           : t-pvcreate-operation.sh 

Log message:
	Add more pvcreate tests to validate writing lvm2 label using --labelsector.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvcreate-operation.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/test/t-pvcreate-operation.sh	2008/07/17 03:17:01	1.1
+++ LVM2/test/t-pvcreate-operation.sh	2008/07/21 18:50:10	1.2
@@ -66,6 +66,20 @@
    pvremove -f $d2 &&
    pvremove -f $d1'
 
+for i in 0 1 2 3 
+do
+ test_expect_success \
+  "pvcreate (lvm2) succeeds writing LVM label at sector $i" \
+  'pvcreate --labelsector $i $d1 &&
+  dd if=$d1 bs=512 skip=$i count=1 status=noxfer 2>&1 | strings | grep -q LABELONE;
+  test $? == 0 &&
+  pvremove -f $d1'
+done
+
+test_expect_failure \
+  "pvcreate (lvm2) fails writing LVM label at sector 4" \
+  'pvcreate --labelsector 4 $d1'
+
 test_done
 # Local Variables:
 # indent-tabs-mode: nil


