From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 2 Aug 2010 13:20:50 -0000
Subject: LVM2/test lvm-utils.sh t-pvchange-usage.sh
Message-ID: <20100802132050.10347.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-08-02 13:20:50

Modified files:
	test           : lvm-utils.sh t-pvchange-usage.sh 

Log message:
	Add shell function to trim spaces.
	Test values as "$val" to avoid weird results when spaces are in output.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lvm-utils.sh.diff?cvsroot=lvm2&r1=1.25&r2=1.26
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvchange-usage.sh.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/test/lvm-utils.sh	2010/08/02 13:18:01	1.25
+++ LVM2/test/lvm-utils.sh	2010/08/02 13:20:50	1.26
@@ -16,6 +16,14 @@
 ME=$(basename "$0")
 warn() { echo >&2 "$ME: $@"; }
 
+trim()
+{
+    trimmed=${1%% }
+    trimmed=${trimmed## }
+
+    echo "$trimmed"
+}
+
 compare_two_fields_()
 {
     local cmd1=$1;
@@ -33,7 +41,7 @@
 then
   echo "compare_two_fields_ $obj1($field1): $val1 $obj2($field2): $val2"
 fi
-  test $val1 = $val2
+  test "$val1" = "$val2"
 }
 
 compare_vg_field_()
@@ -50,7 +58,7 @@
 then
   echo "compare_vg_field_ VG1: $val1 VG2: $val2"
 fi
-  test $val1 = $val2
+  test "$val1" = "$val2"
 }
 
 
@@ -82,12 +90,12 @@
     local expected=$3;
     local actual;
 
-    actual=$(vgs --noheadings -o $field $vg)
+    actual=$(trim $(vgs --noheadings -o $field $vg))
 if test "$verbose" = "t"
 then
   echo "check_vg_field_ VG=$vg, field=$field, actual=$actual, expected=$expected"
 fi
-  test $actual = $expected
+  test "$actual" = "$expected"
 }
 
 check_pv_field_()
@@ -97,12 +105,12 @@
     local expected=$3;
     local actual;
 
-    actual=$(pvs --noheadings -o $field $pv)
+    actual=$(trim $(pvs --noheadings -o $field $pv))
 if test "$verbose" = "t"
 then
   echo "check_pv_field_ PV=$pv, field=$field, actual=$actual, expected=$expected"
 fi
-    test $actual = $expected
+    test "$actual" = "$expected"
 }
 
 check_lv_field_()
@@ -112,12 +120,12 @@
     local expected=$3;
     local actual;
 
-    actual=$(lvs --noheadings -o $field $lv)
+    actual=$(trim $(lvs --noheadings -o $field $lv))
 if test "$verbose" = "t"
 then
   echo "check_lv_field_ LV=$lv, field=$field, actual=$actual, expected=$expected"
 fi
-  test $actual = $expected
+  test "$actual" = "$expected"
 }
 
 vg_validate_pvlv_counts_()
--- LVM2/test/t-pvchange-usage.sh	2010/03/17 17:02:01	1.4
+++ LVM2/test/t-pvchange-usage.sh	2010/08/02 13:20:50	1.5
@@ -26,7 +26,7 @@
 	pvchange $dev1 --addtag test$mda 
 	check_pv_field_ $dev1 pv_tags test$mda 
 	pvchange $dev1 --deltag test$mda 
-	check_pv_field_ $dev1 pv_tags " "
+	check_pv_field_ $dev1 pv_tags ""
 
 # "vgchange disable/enable allocation for pvs with metadatacopies = $mda (bz452982)"
 	pvchange $dev1 -x n 


