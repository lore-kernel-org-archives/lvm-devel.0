From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 28 Jul 2010 11:15:50 +0200
Subject: [PATCH 04/14] Testsuit: test variables with quotes
In-Reply-To: <cover.1280307502.git.zkabelac@redhat.com>
References: <cover.1280307502.git.zkabelac@redhat.com>
Message-ID: <abf3a34848f66b1197049eb54acc2dc5faef2ccf.1280307502.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add shell function to trim spaces.
Test values as "$val" to avoid weird results when spaces are in output.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 test/lvm-utils.sh        |   24 ++++++++++++++++--------
 test/t-pvchange-usage.sh |    2 +-
 2 files changed, 17 insertions(+), 9 deletions(-)

diff --git a/test/lvm-utils.sh b/test/lvm-utils.sh
index 6c00084..486f2d8 100644
--- a/test/lvm-utils.sh
+++ b/test/lvm-utils.sh
@@ -16,6 +16,14 @@ export LVM_SUPPRESS_FD_WARNINGS=1
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
@@ -33,7 +41,7 @@ if test "$verbose" = "t"
 then
   echo "compare_two_fields_ $obj1($field1): $val1 $obj2($field2): $val2"
 fi
-  test $val1 = $val2
+  test "$val1" = "$val2"
 }
 
 compare_vg_field_()
@@ -50,7 +58,7 @@ if test "$verbose" = "t"
 then
   echo "compare_vg_field_ VG1: $val1 VG2: $val2"
 fi
-  test $val1 = $val2
+  test "$val1" = "$val2"
 }
 
 
@@ -82,12 +90,12 @@ check_vg_field_()
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
@@ -97,12 +105,12 @@ check_pv_field_()
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
@@ -112,12 +120,12 @@ check_lv_field_()
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
diff --git a/test/t-pvchange-usage.sh b/test/t-pvchange-usage.sh
index 4c28c62..0f69249 100755
--- a/test/t-pvchange-usage.sh
+++ b/test/t-pvchange-usage.sh
@@ -26,7 +26,7 @@ do
 	pvchange $dev1 --addtag test$mda 
 	check_pv_field_ $dev1 pv_tags test$mda 
 	pvchange $dev1 --deltag test$mda 
-	check_pv_field_ $dev1 pv_tags " "
+	check_pv_field_ $dev1 pv_tags ""
 
 # "vgchange disable/enable allocation for pvs with metadatacopies = $mda (bz452982)"
 	pvchange $dev1 -x n 
-- 
1.7.2


