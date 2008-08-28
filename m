From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 28 Aug 2008 10:59:10 -0000
Subject: LVM2/test t-vgrename-usage.sh t-vgsplit-usage.sh
Message-ID: <20080828105910.13179.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2008-08-28 10:59:10

Modified files:
	test           : t-vgrename-usage.sh t-vgsplit-usage.sh 

Log message:
	add vgrename by uuid test (Jaroslav Stava)
	fix vgsplit rejects last mda copy test (Jaroslav Stava)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgrename-usage.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgsplit-usage.sh.diff?cvsroot=lvm2&r1=1.8&r2=1.9

--- LVM2/test/t-vgrename-usage.sh	2008/01/15 22:56:30	1.1
+++ LVM2/test/t-vgrename-usage.sh	2008/08/28 10:59:10	1.2
@@ -31,7 +31,8 @@
    f4=$(pwd)/4 && d4=$(loop_setup_ "$f4") &&
    vg1=$(this_test_)-1-$$          &&
    vg2=$(this_test_)-2-$$          &&
-   pvcreate $d1 $d2 $d3 $d4'
+   pvcreate $d1 $d2                &&
+   pvcreate --metadatacopies 0 $d3 $d4'
 
 test_expect_success \
   'vgrename normal operation - rename vg1 to vg2' \
@@ -40,6 +41,16 @@
    check_vg_field_ $vg2 vg_name $vg2 &&
    vgremove $vg2'
 
+test_expect_success \
+  "vgrename by uuid (bz231187)" '
+   vgcreate $vg1 $d1 $d3 &&
+   UUID=$(vgs --noheading -o vg_uuid $vg1) &&
+   check_vg_field_ $vg1 vg_uuid $UUID &&
+   vgrename $UUID $vg2 &&
+   check_vg_field_ $vg2 vg_name $vg2 &&
+   vgremove $vg2
+'
+
 test_done
 # Local Variables:
 # indent-tabs-mode: nil
--- LVM2/test/t-vgsplit-usage.sh	2008/08/12 10:01:56	1.8
+++ LVM2/test/t-vgsplit-usage.sh	2008/08/28 10:59:10	1.9
@@ -40,12 +40,11 @@
    lv2=$(this_test_)-test-lv2-$$          &&
    lv3=$(this_test_)-test-lv3-$$'
 
-for mdatype in 2
+for mdatype in 1 2
 do
 test_expect_success \
   "(lvm$mdatype) setup PVs" \
-  'pvcreate -M$mdatype $d1 $d2 $d3 $d4 &&
-   pvcreate -M$mdatype --metadatacopies 0 $d5'
+  'pvcreate -M$mdatype $d1 $d2 $d3 $d4'
 
 test_expect_success \
   "(lvm$mdatype) vgsplit accepts new vg as destination of split" \
@@ -200,19 +199,24 @@
    status=$?; echo status=$status; test $status = 5 &&
    vgremove -f $vg2 &&
    vgremove -f $vg1'
+done
+
+test_expect_success \
+  "(lvm2) setup PVs" '
+   pvcreate -M$mdatype --metadatacopies 0 $d5'
 
 test_expect_success \
   "(lvm2) vgsplit rejects to give away pv with the last mda copy" '
-   vgcreate -M$mdatype $vg1 $d5 $d2  &&
+   vgcreate -M2 $vg1 $d5 $d2  &&
    lvcreate -l 10 -n $lv1  $vg1 &&
    lvchange -an $vg1/$lv1 &&
    vg_validate_pvlv_counts_ $vg1 2 1 0 &&
-   vgsplit  $vg1 $vg2 $d5;
-   status=$?; echo status=$status; test $status != 0 &&
-   vg_validate_pvlv_counts_ $vg1 2 1 0 &&
-   vgremove -ff $vg1
+   { vgsplit  $vg1 $vg2 $d5;
+     status=$?; echo status=$status; test $status != 0 &&
+     vg_validate_pvlv_counts_ $vg1 2 1 0 &&
+     vgremove -ff $vg1
+   }
 '
-done
 
 test_expect_success \
   '(lvm2) vgsplit rejects split because metadata types differ' \


