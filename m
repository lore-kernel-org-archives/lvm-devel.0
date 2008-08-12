From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 12 Aug 2008 10:01:56 -0000
Subject: LVM2/test t-vgsplit-usage.sh
Message-ID: <20080812100156.5184.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2008-08-12 10:01:56

Modified files:
	test           : t-vgsplit-usage.sh 

Log message:
	test vgsplit: reject to give away pv with the last mda copy (Jaroslav Stava)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgsplit-usage.sh.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/test/t-vgsplit-usage.sh	2008/07/17 04:03:04	1.7
+++ LVM2/test/t-vgsplit-usage.sh	2008/08/12 10:01:56	1.8
@@ -20,7 +20,8 @@
   test -n "$d2" && losetup -d "$d2"
   test -n "$d3" && losetup -d "$d3"
   test -n "$d4" && losetup -d "$d4"
-  rm -f "$f1" "$f2" "$f3" "$f4"
+  test -n "$d5" && losetup -d "$d5"
+  rm -f "$f1" "$f2" "$f3" "$f4" "$f5"
 }
 
 # FIXME: paramaterize lvm1 vs lvm2 metadata; most of these tests should run
@@ -32,6 +33,7 @@
    f2=$(pwd)/2 && d2=$(loop_setup_ "$f2") &&
    f3=$(pwd)/3 && d3=$(loop_setup_ "$f3") &&
    f4=$(pwd)/4 && d4=$(loop_setup_ "$f4") &&
+   f5=$(pwd)/5 && d5=$(loop_setup_ "$f5") &&
    vg1=$(this_test_)-test-vg1-$$          &&
    vg2=$(this_test_)-test-vg2-$$          &&
    lv1=$(this_test_)-test-lv1-$$          &&
@@ -42,7 +44,8 @@
 do
 test_expect_success \
   "(lvm$mdatype) setup PVs" \
-  'pvcreate -M$mdatype $d1 $d2 $d3 $d4'
+  'pvcreate -M$mdatype $d1 $d2 $d3 $d4 &&
+   pvcreate -M$mdatype --metadatacopies 0 $d5'
 
 test_expect_success \
   "(lvm$mdatype) vgsplit accepts new vg as destination of split" \
@@ -197,6 +200,18 @@
    status=$?; echo status=$status; test $status = 5 &&
    vgremove -f $vg2 &&
    vgremove -f $vg1'
+
+test_expect_success \
+  "(lvm2) vgsplit rejects to give away pv with the last mda copy" '
+   vgcreate -M$mdatype $vg1 $d5 $d2  &&
+   lvcreate -l 10 -n $lv1  $vg1 &&
+   lvchange -an $vg1/$lv1 &&
+   vg_validate_pvlv_counts_ $vg1 2 1 0 &&
+   vgsplit  $vg1 $vg2 $d5;
+   status=$?; echo status=$status; test $status != 0 &&
+   vg_validate_pvlv_counts_ $vg1 2 1 0 &&
+   vgremove -ff $vg1
+'
 done
 
 test_expect_success \


