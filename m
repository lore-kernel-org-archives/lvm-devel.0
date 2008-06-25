From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 25 Jun 2008 16:51:27 -0000
Subject: LVM2/test lvm-utils.sh
Message-ID: <20080625165127.15553.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-06-25 16:51:26

Modified files:
	test           : lvm-utils.sh 

Log message:
	Test script cleanup.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lvm-utils.sh.diff?cvsroot=lvm2&r1=1.12&r2=1.13

--- LVM2/test/lvm-utils.sh	2008/06/06 13:48:57	1.12
+++ LVM2/test/lvm-utils.sh	2008/06/25 16:51:26	1.13
@@ -52,38 +52,64 @@
 
 compare_vg_field_()
 {
+    local vg1=$1;
+    local vg2=$2;
+    local field=$3;
+    local val1;
+    local val2;
+
+    val1=$(vgs --noheadings -o $field $vg1)
+    val2=$(vgs --noheadings -o $field $vg2)
 if test "$verbose" = "t"
 then
-  echo "compare_vg_field_ VG1: `vgs --noheadings -o $3 $1` VG2: `vgs --noheadings -o $3 $2`"
+  echo "compare_vg_field_ VG1: $val1 VG2: $val2"
 fi
-  return $(test $(vgs --noheadings -o $3 $1) == $(vgs --noheadings -o $3 $2) )
+  return $(test $val1 == $val2 )
 }
 
 check_vg_field_()
 {
+    local vg=$1;
+    local field=$2;
+    local expected=$3;
+    local actual;
+
+    actual=$(vgs --noheadings -o $field $vg)
 if test "$verbose" = "t"
 then
-  echo "check_vg_field_ VG=$1, field=$2, actual=`vgs --noheadings -o $2 $1`, expected=$3"
+  echo "check_vg_field_ VG=$vg, field=$field, actual=$actual, expected=$expected"
 fi
-  return $(test $(vgs --noheadings -o $2 $1) == $3)
+  return $(test $actual == $expected)
 }
 
 check_pv_field_()
 {
+    local pv=$1;
+    local field=$2;
+    local expected=$3;
+    local actual;
+
+    actual=$(pvs --noheadings -o $field $pv)
 if test "$verbose" = "t"
 then
-  echo "check_pv_field_ PV=$1, field=$2, actual=`pvs --noheadings -o $2 $1`, expected=$3"
+  echo "check_pv_field_ PV=$pv, field=$field, actual=$actual, expected=$expected"
 fi
-  return $(test $(pvs --noheadings -o $2 $1) == $3)
+  return $(test $actual == $expected)
 }
 
 check_lv_field_()
 {
+    local lv=$1;
+    local field=$2;
+    local expected=$3;
+    local actual;
+
+    actual=$(lvs --noheadings -o $field $lv)
 if test "$verbose" = "t"
 then
-  echo "check_lv_field_ LV=$1, field=$2, actual=`lvs --noheadings -o $2 $1`, expected=$3"
+  echo "check_lv_field_ LV=$lv, field=$field, actual=$actual, expected=$expected"
 fi
-  return $(test $(lvs --noheadings -o $2 $1) == $3)
+  return $(test $actual == $expected)
 }
 
 vg_validate_pvlv_counts_()


