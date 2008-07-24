From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 24 Jul 2008 17:33:40 -0000
Subject: LVM2/test t-pvcreate-operation.sh
Message-ID: <20080724173340.30965.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-07-24 17:33:40

Modified files:
	test           : t-pvcreate-operation.sh 

Log message:
	Add pvcreate tests for uuid and restorefile.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvcreate-operation.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/test/t-pvcreate-operation.sh	2008/07/21 18:50:10	1.2
+++ LVM2/test/t-pvcreate-operation.sh	2008/07/24 17:33:40	1.3
@@ -80,6 +80,33 @@
   "pvcreate (lvm2) fails writing LVM label at sector 4" \
   'pvcreate --labelsector 4 $d1'
 
+backupfile=mybackupfile-$(this_test_)
+uuid1=freddy-fred-fred-fred-fred-fred-freddy
+uuid2=freddy-fred-fred-fred-fred-fred-fredie
+bogusuuid=fred
+
+test_expect_failure \
+  'pvcreate rejects uuid option with less than 32 characters' \
+  'pvcreate --uuid $bogusuuid $d1'
+
+test_expect_success \
+  'pvcreate rejects uuid already in use' \
+  'pvcreate --uuid freddy-fred-fred-fred-fred-fred-freddy $d1 &&
+   pvcreate --uuid freddy-fred-fred-fred-fred-fred-freddy $d2;
+   status=$?; echo status=$status; test $status != 0'
+
+test_expect_success \
+  'pvcreate rejects non-existent file given with restorefile' \
+  'pvcreate --uuid $uuid1 --restorefile $backupfile $d1;
+   status=$?; echo status=$status; test $status != 0'
+
+test_expect_success \
+  'pvcreate rejects restorefile with uuid not found in file' \
+  'pvcreate --uuid $uuid1 $d1 &&
+   vgcfgbackup -f $backupfile &&
+   pvcreate --uuid $uuid2 --restorefile $backupfile $d2;
+   status=$?; echo status=$status; test $status != 0'
+
 test_done
 # Local Variables:
 # indent-tabs-mode: nil


