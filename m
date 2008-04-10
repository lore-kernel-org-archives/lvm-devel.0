From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 10 Apr 2008 01:06:49 -0000
Subject: LVM2/test t-lvcreate-usage.sh t-mdata-strings. ...
Message-ID: <20080410010649.26097.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-04-10 01:06:48

Modified files:
	test           : t-lvcreate-usage.sh t-mdata-strings.sh 
	                 t-vgcreate-usage.sh t-vgmerge-usage.sh 
	                 t-vgsplit-operation.sh t-vgsplit-usage.sh 

Log message:
	Fix lvm tool exit code display in some tests.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvcreate-usage.sh.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-mdata-strings.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgcreate-usage.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgmerge-usage.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgsplit-operation.sh.diff?cvsroot=lvm2&r1=1.17&r2=1.18
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgsplit-usage.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/test/t-lvcreate-usage.sh	2008/01/17 18:05:57	1.4
+++ LVM2/test/t-lvcreate-usage.sh	2008/04/10 01:06:48	1.5
@@ -39,7 +39,7 @@
 test_expect_success \
   'lvcreate rejects a negative stripe_size' \
   'lvcreate -L 64M -n $lv -i2 --stripesize -4 $vg 2>err;
-   status=$?; echo status=$?; test $status = 3 &&
+   status=$?; echo status=$status; test $status = 3 &&
    grep "^  Negative stripesize is invalid\$" err'
 
 test_expect_success \
--- LVM2/test/t-mdata-strings.sh	2008/03/12 17:34:58	1.1
+++ LVM2/test/t-mdata-strings.sh	2008/04/10 01:06:48	1.2
@@ -42,7 +42,7 @@
   'no parse errors and VG really exists' \
   'vgs 2>err                                    &&
   grep "Parse error" err;
-  status=$?; echo status=$?; test $status -ne 0 &&
+  status=$?; echo status=$status; test $status -ne 0 &&
   vgs $vg'
 
 test_done
--- LVM2/test/t-vgcreate-usage.sh	2008/01/14 21:07:58	1.2
+++ LVM2/test/t-vgcreate-usage.sh	2008/04/10 01:06:48	1.3
@@ -51,32 +51,32 @@
 test_expect_success \
   'vgcreate rejects a zero physical extent size' \
   'vgcreate --physicalextentsize 0 $vg $d1 $d2 2>err;
-   status=$?; echo status=$?; test $status = 3 &&
+   status=$?; echo status=$status; test $status = 3 &&
    grep "^  Physical extent size may not be zero\$" err'
 
 test_expect_success \
   'vgcreate rejects "inherit" allocation policy' \
   'vgcreate --alloc inherit $vg $d1 $d2 2>err;
-   status=$?; echo status=$?; test $status = 3 &&
+   status=$?; echo status=$status; test $status = 3 &&
    grep "^  Volume Group allocation policy cannot inherit from anything\$" err'
 
 test_expect_success \
   'vgcreate rejects vgname "."' \
   'vg=.; vgcreate $vg $d1 $d2 2>err;
-   status=$?; echo status=$?; test $status = 3 &&
+   status=$?; echo status=$status; test $status = 3 &&
    grep "New volume group name \"$vg\" is invalid\$" err'
 
 test_expect_success \
   'vgcreate rejects vgname greater than 128 characters' \
   'vginvalid=thisnameisridiculouslylongtotestvalidationcodecheckingmaximumsizethisiswhathappenswhenprogrammersgetboredandorarenotcreativedonttrythisathome;
    vgcreate $vginvalid $d1 $d2 2>err;
-   status=$?; echo status=$?; test $status = 3 &&
+   status=$?; echo status=$status; test $status = 3 &&
    grep "New volume group name \"$vginvalid\" is invalid\$" err'
 
 test_expect_success \
   'vgcreate rejects already existing vgname "/tmp/$vg"' \
   'touch /tmp/$vg; vgcreate $vg $d1 $d2 2>err;
-   status=$?; echo status=$?; test $status = 3 &&
+   status=$?; echo status=$status; test $status = 3 &&
    grep "New volume group name \"$vg\" is invalid\$" err'
 
 # FIXME: Not sure why this fails
@@ -84,7 +84,7 @@
 #  'vgcreate rejects MaxLogicalVolumes > 255' \
 #  'vgcreate --metadatatype 1 --maxlogicalvolumes 1024 $vg $d1 $d2 2>err;
 #   cp err save;
-#   status=$?; echo status=$?; test $status = 3 &&
+#   status=$?; echo status=$status; test $status = 3 &&
 #   grep "^  Number of volumes may not exceed 255\$" err'
 
 test_done
--- LVM2/test/t-vgmerge-usage.sh	2008/03/26 18:03:35	1.3
+++ LVM2/test/t-vgmerge-usage.sh	2008/04/10 01:06:48	1.4
@@ -45,7 +45,7 @@
   'vgcreate $vg1 $d1 $d2 &&
    vgcreate $vg2 $d3 $d4 &&
    vgmerge $vg1 $vg1 2>err;
-   status=$?; echo status=$?; test $status = 5 &&
+   status=$?; echo status=$status; test $status = 5 &&
    grep "^  Duplicate volume group name \"$vg1\"\$" err &&
    vgremove $vg2 &&
    vgremove $vg1'
@@ -55,7 +55,7 @@
   'vgcreate --physicalextentsize 4M $vg1 $d1 $d2 &&
    vgcreate --physicalextentsize 8M $vg2 $d3 $d4 &&
    vgmerge $vg1 $vg2 2>err;
-   status=$?; echo status=$?; test $status = 5 &&
+   status=$?; echo status=$status; test $status = 5 &&
    grep "^  Extent sizes differ" err &&
    vgremove $vg2 &&
    vgremove $vg1'
@@ -65,7 +65,7 @@
   'vgcreate --maxphysicalvolumes 2 $vg1 $d1 $d2 &&
    vgcreate --maxphysicalvolumes 2 $vg2 $d3 $d4 &&
    vgmerge $vg1 $vg2 2>err;
-   status=$?; echo status=$?; test $status = 5 &&
+   status=$?; echo status=$status; test $status = 5 &&
    grep "^  Maximum number of physical volumes (2) exceeded" err &&
    vgremove $vg2 &&
    vgremove $vg1'
@@ -76,7 +76,7 @@
    vgcreate $vg2 $d3 $d4 &&
    lvcreate -l 4 -n lv1 $vg2 &&
    vgmerge $vg1 $vg2 2>err;
-   status=$?; echo status=$?; test $status = 5 &&
+   status=$?; echo status=$status; test $status = 5 &&
    grep "^  Logical volumes in \"$vg2\" must be inactive\$" err &&
    vgremove -f $vg2 &&
    vgremove -f $vg1'
@@ -91,7 +91,7 @@
    vgchange -an $vg1 &&
    vgchange -an $vg2 &&
    vgmerge $vg1 $vg2 2>err;
-   status=$?; echo status=$?; test $status = 5 &&
+   status=$?; echo status=$status; test $status = 5 &&
    grep "^  Maximum number of logical volumes (2) exceeded" err &&
    vgremove -f $vg2 &&
    vgremove -f $vg1'
--- LVM2/test/t-vgsplit-operation.sh	2008/04/09 21:10:13	1.17
+++ LVM2/test/t-vgsplit-operation.sh	2008/04/10 01:06:48	1.18
@@ -222,7 +222,7 @@
    lvcreate -l 4 -n $lv3 -i 2 $vg1 $d3 $d4 &&
    vgchange -an $vg1 &&
    vgsplit -n $lv1 $vg1 $vg2;
-   status=$?; echo status=$?; test $status = 5 &&
+   status=$?; echo status=$status; test $status = 5 &&
    vgremove -ff $vg1'
 
 test_expect_success \
@@ -234,7 +234,7 @@
    vg_validate_pvlv_counts_ $vg1 4 1 2 &&
    vgchange -an $vg1 &&
    vgsplit -n $lv1 $vg1 $vg2;
-   status=$?; echo status=$?; test $status = 5 &&
+   status=$?; echo status=$status; test $status = 5 &&
    lvremove -f $vg1/$lv2 &&
    lvremove -f $vg1/$lv3 &&
    lvremove -f $vg1/$lv1 &&
@@ -249,7 +249,7 @@
    vg_validate_pvlv_counts_ $vg1 4 1 2 &&
    vgchange -an $vg1 &&
    vgsplit -n $lv2 $vg1 $vg2;
-   status=$?; echo status=$?; test $status = 5 &&
+   status=$?; echo status=$status; test $status = 5 &&
    lvremove -f $vg1/$lv2 &&
    lvremove -f $vg1/$lv3 &&
    lvremove -f $vg1/$lv1 &&
@@ -262,7 +262,7 @@
    vg_validate_pvlv_counts_ $vg1 4 4 0 &&
    vgchange -an $vg1 &&
    vgsplit $vg1 $vg2 $d2 &&
-   status=$?; echo status=$?; test $status = 5 &&
+   status=$?; echo status=$status; test $status = 5 &&
    vgremove -ff $vg1'
 
 test_expect_success \
@@ -273,7 +273,7 @@
    vg_validate_pvlv_counts_ $vg1 4 5 0 &&
    vgchange -an $vg1 &&
    vgsplit -n $lv2 $vg1 $vg2 2>err;
-   status=$?; echo status=$?; test $status = 5 &&
+   status=$?; echo status=$status; test $status = 5 &&
    vgremove -ff $vg1'
 
 
--- LVM2/test/t-vgsplit-usage.sh	2008/03/23 15:40:35	1.3
+++ LVM2/test/t-vgsplit-usage.sh	2008/04/10 01:06:48	1.4
@@ -43,7 +43,7 @@
   'vgsplit accepts new vg as destination of split' \
   'vgcreate $vg1 $d1 $d2 &&
    vgsplit $vg1 $vg2 $d1 1>err;
-   status=$?; echo status=$?; test $status = 0 &&
+   status=$?; echo status=$status; test $status = 0 &&
    grep "New volume group \"$vg2\" successfully split from \"$vg1\"" err &&
    vgremove $vg1 &&
    vgremove $vg2'
@@ -53,7 +53,7 @@
   'vgcreate $vg1 $d1 $d2 &&
    vgcreate $vg2 $d3 $d4 &&
    vgsplit $vg1 $vg2 $d1 1>err;
-   status=$?; echo status=$?; test $status = 0 &&
+   status=$?; echo status=$status; test $status = 0 &&
    grep "Existing volume group \"$vg2\" successfully split from \"$vg1\"" err &&
    vgremove $vg1 &&
    vgremove $vg2'
@@ -79,7 +79,7 @@
   'vgcreate --maxphysicalvolumes 2 $vg1 $d1 $d2 &&
    vgcreate --maxphysicalvolumes 2 $vg2 $d3 $d4 &&
    vgsplit $vg1 $vg2 $d1 2>err;
-   status=$?; echo status=$?; test $status = 5 &&
+   status=$?; echo status=$status; test $status = 5 &&
    grep "^  Maximum number of physical volumes (2) exceeded" err &&
    vgremove $vg2 &&
    vgremove $vg1'
@@ -89,7 +89,7 @@
   'vgcreate --maxphysicalvolumes 2 $vg1 $d1 $d2 &&
    vgcreate --maxphysicalvolumes 2 $vg2 $d3 $d4 &&
    vgsplit --maxphysicalvolumes 2 $vg1 $vg2 $d1 2>err;
-   status=$?; echo status=$?; test $status = 5 &&
+   status=$?; echo status=$status; test $status = 5 &&
    grep "^  Volume group \"$vg2\" exists, but new VG option specified" err &&
    vgremove $vg2 &&
    vgremove $vg1'
@@ -99,7 +99,7 @@
   'vgcreate --maxlogicalvolumes 2 $vg1 $d1 $d2 &&
    vgcreate --maxlogicalvolumes 2 $vg2 $d3 $d4 &&
    vgsplit --maxlogicalvolumes 2 $vg1 $vg2 $d1 2>err;
-   status=$?; echo status=$?; test $status = 5 &&
+   status=$?; echo status=$status; test $status = 5 &&
    grep "^  Volume group \"$vg2\" exists, but new VG option specified" err &&
    vgremove $vg2 &&
    vgremove $vg1'
@@ -109,7 +109,7 @@
   'vgcreate --alloc cling $vg1 $d1 $d2 &&
    vgcreate --alloc cling $vg2 $d3 $d4 &&
    vgsplit --alloc cling $vg1 $vg2 $d1 2>err;
-   status=$?; echo status=$?; test $status = 5 &&
+   status=$?; echo status=$status; test $status = 5 &&
    grep "^  Volume group \"$vg2\" exists, but new VG option specified" err &&
    vgremove $vg2 &&
    vgremove $vg1'
@@ -119,7 +119,7 @@
   'vgcreate --clustered n $vg1 $d1 $d2 &&
    vgcreate --clustered n $vg2 $d3 $d4 &&
    vgsplit --clustered n $vg1 $vg2 $d1 2>err;
-   status=$?; echo status=$?; test $status = 5 &&
+   status=$?; echo status=$status; test $status = 5 &&
    grep "^  Volume group \"$vg2\" exists, but new VG option specified" err &&
    vgremove $vg2 &&
    vgremove $vg1'
@@ -131,7 +131,7 @@
    vgcreate -M1 $vg1 $d3 $d4 &&
    vgcreate -M2 $vg2 $d1 $d2 &&
    vgsplit $vg1 $vg2 $d3 2>err;
-   status=$?; echo status=$?; test $status = 5 &&
+   status=$?; echo status=$status; test $status = 5 &&
    grep "^  Metadata types differ" err &&
    vgremove $vg2 &&
    vgremove $vg1'
@@ -143,7 +143,7 @@
    vgcreate $vg2 $d3 $d4 &&
    lvcreate -l 4 -n $lv1 $vg1 &&
    vgsplit $vg1 $vg2 $d1 2>err;
-   status=$?; echo status=$?; test $status = 5 &&
+   status=$?; echo status=$status; test $status = 5 &&
    grep "^  Logical volumes in \"$vg1\" must be inactive\$" err &&
    vgremove -f $vg2 &&
    vgremove -f $vg1'
@@ -158,7 +158,7 @@
    vgchange -an $vg1 &&
    vgchange -an $vg2 &&
    vgsplit $vg1 $vg2 $d1 2>err;
-   status=$?; echo status=$?; test $status = 5 &&
+   status=$?; echo status=$status; test $status = 5 &&
    grep "^  Maximum number of logical volumes (2) exceeded" err &&
    vgremove -f $vg2 &&
    vgremove -f $vg1'
@@ -201,7 +201,7 @@
    lvcreate -l 4 -n $lv2 $vg1 &&
    vgchange -an $vg1 &&
    vgsplit $vg1 $vg2 $d3 2>err;
-   status=$?; echo status=$?; test $status = 5 &&
+   status=$?; echo status=$status; test $status = 5 &&
    vgremove -f $vg2 &&
    vgremove -f $vg1'
 


