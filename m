From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 17 Jan 2008 18:05:58 -0000
Subject: LVM2/test lvm-utils.sh t-lvcreate-usage.sh t-l ...
Message-ID: <20080117180558.4753.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-01-17 18:05:58

Modified files:
	test           : lvm-utils.sh t-lvcreate-usage.sh 
	                 t-lvextend-percent-extents.sh 

Log message:
	More test script fixes.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lvm-utils.sh.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvcreate-usage.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvextend-percent-extents.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/test/lvm-utils.sh	2008/01/16 21:21:22	1.6
+++ LVM2/test/lvm-utils.sh	2008/01/17 18:05:57	1.7
@@ -52,17 +52,29 @@
 
 check_vg_field_()
 {
+if test "$verbose" = "t"
+then
+  echo "check_vg_field_ actual: `vgs --noheadings -o $2 $1` expected $3"
+fi
   return $(test $(vgs --noheadings -o $2 $1) == $3)
 }
 
-check_pv_size_()
+check_pv_field_()
 {
-  return $(test $(pvs --noheadings -o pv_free $1) == $2)
+if test "$verbose" = "t"
+then
+  echo "check_pv_field_ actual: `pvs --noheadings -o $2 $1` expected $3"
+fi
+  return $(test $(pvs --noheadings -o $2 $1) == $3)
 }
 
-check_lv_size_()
+check_lv_field_()
 {
-  return $(test $(lvs --noheadings -o lv_size $1) == $2)
+if test "$verbose" = "t"
+then
+  echo "check_lv_field_ actual: `lvs --noheadings -o $2 $1` expected $3"
+fi
+  return $(test $(lvs --noheadings -o $2 $1) == $3)
 }
 
 dmsetup_has_dm_devdir_support_()
--- LVM2/test/t-lvcreate-usage.sh	2007/10/09 13:13:06	1.3
+++ LVM2/test/t-lvcreate-usage.sh	2008/01/17 18:05:57	1.4
@@ -37,7 +37,7 @@
 lv=lvcreate-usage-$$
 
 test_expect_success \
-  'lvcreate rejects a negative stripesize' \
+  'lvcreate rejects a negative stripe_size' \
   'lvcreate -L 64M -n $lv -i2 --stripesize -4 $vg 2>err;
    status=$?; echo status=$?; test $status = 3 &&
    grep "^  Negative stripesize is invalid\$" err'
@@ -56,10 +56,11 @@
    lvremove -ff $vg'
 
 test_expect_success \
-  'lvcreate w/no stripe size succeeds with diagnostics to stdout' \
+  'lvcreate w/default (64KB) stripe size succeeds with diagnostics to stdout' \
   'lvcreate -L 64M -n $lv -i2 $vg > out &&
    grep "^  Using default stripesize" out &&
    lvdisplay $vg &&
+   check_lv_field_ $vg/$lv stripesize "64.00K" &&
    lvremove -ff $vg'
 
 test_expect_success \
--- LVM2/test/t-lvextend-percent-extents.sh	2008/01/17 15:56:53	1.3
+++ LVM2/test/t-lvextend-percent-extents.sh	2008/01/17 18:05:57	1.4
@@ -50,7 +50,7 @@
   'lvextend accepts no size or extents but one PV - bz154691' \
   'lvextend $vg/$lv $d1 >out; test $? = 0 &&
   grep "^  Logical volume $lv successfully resized\$" out &&
-  check_pv_size_ $d1 "0"'
+  check_pv_field_ $d1 pv_free "0"'
 
 test_expect_success \
   'Reset LV to original size' \
@@ -61,8 +61,8 @@
   'lvextend accepts no size but extents 100%PVS and two PVs - bz154691' \
   'lvextend -l +100%PVS $vg/$lv $d1 $d2 >out; test $? = 0 &&
   grep "^  Logical volume $lv successfully resized\$" out &&
-  check_pv_size_ $d1 "0" &&
-  check_pv_size_ $d2 "0"'
+  check_pv_field_ $d1 pv_free "0" &&
+  check_pv_field_ $d2 pv_free "0"'
 
 # Exercise the range overlap code.  Allocate every 2 extents.
 #
@@ -89,14 +89,14 @@
   'create_pvs=`for i in $(seq 0 4 20); do echo -n "\$d1:$i-$(($i + 1)) "; done` &&
    lvremove -f $vg/$lv; test $? = 0 &&
    lvcreate -l 12 -n $lv $vg $create_pvs; test $? = 0 &&
-   check_lv_size_ $vg/$lv "48.00M"'
+   check_lv_field_ $vg/$lv lv_size "48.00M"'
 
 test_expect_success \
   'lvextend with partially allocated PVs and extents 100%PVS with PE ranges' \
   'extend_pvs=`for i in $(seq 0 6 18); do echo -n "\$d1:$i-$(($i + 2)) "; done` &&
   lvextend -l +100%PVS $vg/$lv $extend_pvs >out; test $? = 0 &&
   grep "^  Logical volume $lv successfully resized\$" out &&
-  check_lv_size_ $vg/$lv "72.00M"'
+  check_lv_field_ $vg/$lv lv_size "72.00M"'
 
 
 test_done


