From: meyering@sourceware.org <meyering@sourceware.org>
Date: 24 Sep 2007 19:19:18 -0000
Subject: LVM2/test t-lvcreate-pvtags.sh t-lvcreate-usag ...
Message-ID: <20070924191918.15858.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	meyering at sourceware.org	2007-09-24 19:19:18

Modified files:
	test           : t-lvcreate-pvtags.sh t-lvcreate-usage.sh 
	                 t-lvextend-percent-extents.sh 
	                 t-pv-range-overflow.sh 

Log message:
	Avoid over-quoting in shell scripts.
	
	Do not use "..." around the RHS of VAR= assignment,
	nor on the argument of "case ... in ...".
	
	Author: Jim Meyering <jim@meyering.net>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvcreate-pvtags.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvcreate-usage.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvextend-percent-extents.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pv-range-overflow.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/test/t-lvcreate-pvtags.sh	2007/09/21 17:12:13	1.1
+++ LVM2/test/t-lvcreate-pvtags.sh	2007/09/24 19:19:18	1.2
@@ -35,7 +35,7 @@
 
 test_expect_success \
   'set up temp file and loopback device' \
-  'lofile="$(pwd)/lofile" && lodev=$(loop_setup_ "$lofile")'
+  'lofile=$(pwd)/lofile && lodev=$(loop_setup_ "$lofile")'
 
 offset=0
 pvs=
--- LVM2/test/t-lvcreate-usage.sh	2007/09/21 17:12:13	1.1
+++ LVM2/test/t-lvcreate-usage.sh	2007/09/24 19:19:18	1.2
@@ -28,8 +28,8 @@
 
 test_expect_success \
   'set up temp files, loopback devices, PVs, and a VG' \
-  'f1="$(pwd)/1" && d1=$(loop_setup_ "$f1") &&
-   f2="$(pwd)/2" && d2=$(loop_setup_ "$f2") &&
+  'f1=$(pwd)/1 && d1=$(loop_setup_ "$f1") &&
+   f2=$(pwd)/2 && d2=$(loop_setup_ "$f2") &&
    pvcreate $d1 $d2      &&
    vg=$(this_test_)-test-vg-$$  &&
    vgcreate $vg $d1 $d2'
@@ -71,7 +71,7 @@
   'lvcreate rejects an invalid stripe size' \
   'lvcreate -L 64M -n $lv -i2 --stripesize 3 $vg 2>err; test $? = 3 &&
    grep "^  Invalid stripe size 3\.00 KB\$" err &&
-   case "$(lvdisplay $vg)" in "") true ;; *) false ;; esac'
+   case $(lvdisplay $vg) in "") true ;; *) false ;; esac'
 
 test_done
 # Local Variables:
--- LVM2/test/t-lvextend-percent-extents.sh	2007/09/21 21:14:25	1.1
+++ LVM2/test/t-lvextend-percent-extents.sh	2007/09/24 19:19:18	1.2
@@ -28,8 +28,8 @@
 
 test_expect_success \
   'set up temp files, loopback devices, PVs, and a VG' \
-  'f1="$(pwd)/1" && d1=$(loop_setup_ "$f1") &&
-   f2="$(pwd)/2" && d2=$(loop_setup_ "$f2") &&
+  'f1=$(pwd)/1 && d1=$(loop_setup_ "$f1") &&
+   f2=$(pwd)/2 && d2=$(loop_setup_ "$f2") &&
    pvcreate $d1 $d2      &&
    vg=$(this_test_)-test-vg-$$  &&
    vgcreate $vg $d1 $d2 &&
@@ -65,7 +65,7 @@
   check_pv_size_ $d2 "0"'
 
 # Exercise the range overlap code.  Allocate every 2 extents.
-# 
+#
 #      Physical Extents
 #           1         2
 #012345678901234567890123
--- LVM2/test/t-pv-range-overflow.sh	2007/09/21 17:12:13	1.1
+++ LVM2/test/t-pv-range-overflow.sh	2007/09/24 19:19:18	1.2
@@ -28,8 +28,8 @@
 
 test_expect_success \
   'set up temp files, loopback devices, PVs, VG, LV' \
-  'f1="$(pwd)/1" && d1=$(loop_setup_ "$f1") &&
-   f2="$(pwd)/2" && d2=$(loop_setup_ "$f2") &&
+  'f1=$(pwd)/1 && d1=$(loop_setup_ "$f1") &&
+   f2=$(pwd)/2 && d2=$(loop_setup_ "$f2") &&
    pvcreate $d1 $d2              &&
    vg=pvmove-demo-vg-$$          &&
    vgcreate "$vg" $d1 $d2        &&


