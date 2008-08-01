From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 1 Aug 2008 15:44:56 -0000
Subject: LVM2/test t-pvcreate-operation.sh
Message-ID: <20080801154456.32576.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2008-08-01 15:44:55

Modified files:
	test           : t-pvcreate-operation.sh 

Log message:
	disable mdadm test-case until a better solution is found

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvcreate-operation.sh.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/test/t-pvcreate-operation.sh	2008/07/29 21:05:10	1.7
+++ LVM2/test/t-pvcreate-operation.sh	2008/08/01 15:44:53	1.8
@@ -55,14 +55,14 @@
    pvremove -f $d1'
 
 # NOTE: Force pvcreate after test completion to ensure clean device
-test_expect_success \
-  "pvcreate (lvm$mdatype) fails on md component device" \
-  'mdadm -C -l raid0 -n 2 /dev/md0 $d1 $d2 &&
-   pvcreate -M$mdatype $d1;
-   status=$?; echo status=$status; test $status != 0 &&
-   mdadm --stop /dev/md0 &&
-   pvcreate -ff -y -M$mdatype $d1 $d2 &&
-   pvremove -f $d1 $d2'
+#test_expect_success \
+#  "pvcreate (lvm$mdatype) fails on md component device" \
+#  'mdadm -C -l raid0 -n 2 /dev/md0 $d1 $d2 &&
+#   pvcreate -M$mdatype $d1;
+#   status=$?; echo status=$status; test $status != 0 &&
+#   mdadm --stop /dev/md0 &&
+#   pvcreate -ff -y -M$mdatype $d1 $d2 &&
+#   pvremove -f $d1 $d2'
 
 done
 


