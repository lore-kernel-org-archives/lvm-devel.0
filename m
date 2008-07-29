From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 29 Jul 2008 21:05:23 -0000
Subject: LVM2 test/t-000-basic.sh test/t-pvcreate-opera ...
Message-ID: <20080729210523.13824.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-07-29 21:05:20

Modified files:
	test           : t-000-basic.sh t-pvcreate-operation.sh 
	tools          : pvcreate.c 

Log message:
	Add pvcreate tests to verify failure on md array detection.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-000-basic.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvcreate-operation.sh.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvcreate.c.diff?cvsroot=lvm2&r1=1.73&r2=1.74

--- LVM2/test/t-000-basic.sh	2007/12/05 09:49:08	1.2
+++ LVM2/test/t-000-basic.sh	2008/07/29 21:05:02	1.3
@@ -32,4 +32,9 @@
   'ensure they are the same' \
   'diff -u actual expected'
 
+# Need mdadm for some pvcreate tests
+test_expect_success \
+  'verify mdadm is installed and in path (needed for pvcreate tests)' \
+  'which mdadm'
+
 test_done
--- LVM2/test/t-pvcreate-operation.sh	2008/07/25 14:59:51	1.6
+++ LVM2/test/t-pvcreate-operation.sh	2008/07/29 21:05:10	1.7
@@ -54,6 +54,16 @@
    pvremove -f $d2 &&
    pvremove -f $d1'
 
+# NOTE: Force pvcreate after test completion to ensure clean device
+test_expect_success \
+  "pvcreate (lvm$mdatype) fails on md component device" \
+  'mdadm -C -l raid0 -n 2 /dev/md0 $d1 $d2 &&
+   pvcreate -M$mdatype $d1;
+   status=$?; echo status=$status; test $status != 0 &&
+   mdadm --stop /dev/md0 &&
+   pvcreate -ff -y -M$mdatype $d1 $d2 &&
+   pvremove -f $d1 $d2'
+
 done
 
 test_expect_success \
--- LVM2/tools/pvcreate.c	2008/07/25 14:59:51	1.73
+++ LVM2/tools/pvcreate.c	2008/07/29 21:05:20	1.74
@@ -106,6 +106,9 @@
 		return 0;
 	}
 
+	/*
+ 	 * This test will fail if the device belongs to an MD array.
+	 */
 	if (!dev_test_excl(dev)) {
 		/* FIXME Detect whether device-mapper itself is still using it */
 		log_error("Can't open %s exclusively.  Mounted filesystem?",


