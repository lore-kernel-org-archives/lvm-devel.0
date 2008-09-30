From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 30 Sep 2008 17:17:04 -0000
Subject: LVM2/test t-vgreduce-usage.sh
Message-ID: <20080930171704.4102.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2008-09-30 17:17:04

Modified files:
	test           : t-vgreduce-usage.sh 

Log message:
	Port over t-vgreduce-usage. Should fix testsuite hangs where pvremove -ff would
	have waited for input on certain test failures.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgreduce-usage.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/test/t-vgreduce-usage.sh	2008/09/19 16:12:25	1.3
+++ LVM2/test/t-vgreduce-usage.sh	2008/09/30 17:17:04	1.4
@@ -9,149 +9,77 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-test_description='Test vgreduce command options for validity'
-privileges_required_=1
+. ./test-utils.sh
 
-. ./test-lib.sh
-
-cleanup_()
-{
-  test -n "$d1" && losetup -d "$d1"
-  test -n "$d2" && losetup -d "$d2"
-  test -n "$d3" && losetup -d "$d3"
-  test -n "$d4" && losetup -d "$d4"
-  rm -f "$f1" "$f2" "$f3" "$f4"
-}
-
-test_expect_success \
-  'set up temp files, loopback devices, PVs, vgnames' \
-  'f1=$(pwd)/1 && d1=$(loop_setup_ "$f1") &&
-   f2=$(pwd)/2 && d2=$(loop_setup_ "$f2") &&
-   f3=$(pwd)/3 && d3=$(loop_setup_ "$f3") &&
-   f4=$(pwd)/4 && d4=$(loop_setup_ "$f4") &&
-   vg1=$(this_test_)-test-vg1-$$          &&
-   vg2=$(this_test_)-test-vg2-$$          &&
-   lv1=$(this_test_)-test-lv1-$$          &&
-   lv2=$(this_test_)-test-lv2-$$          &&
-   lv3=$(this_test_)-test-lv3-$$'
+aux prepare_devs 4
 
 for mdatype in 1 2
 do
-test_expect_success \
-  "(lvm$mdatype) setup PVs" '
-   pvcreate -M$mdatype $d1 $d2 
-'
-
-test_expect_success \
-  "(lvm$mdatype) vgreduce removes only the specified pv from vg (bz427382)" '
-   vgcreate -M$mdatype $vg1 $d1 $d2 &&
-   vgreduce $vg1 $d1 &&
-   check_pv_field_ $d2 vg_name $vg1 &&
-   vgremove -f $vg1
-'
-
-test_expect_success \
-  "(lvm$mdatype) vgreduce rejects removing the last pv (--all)" '
-   vgcreate -M$mdatype $vg1 $d1 $d2 &&
-   { vgreduce --all $vg1;
-     status=$?; echo status=$status; test $status != 0 &&
-     vgremove -f $vg1
-   }
-'
-
-test_expect_success \
-  "(lvm$mdatype) vgreduce rejects removing the last pv" '
-   vgcreate -M$mdatype $vg1 $d1 $d2 &&
-   { vgreduce $vg1 $d1 $d2;
-     status=$?; echo status=$status; test $status = 5 &&
-     vgremove -f $vg1
-   }
-'
-
-test_expect_success \
-  "(lvm$mdatype) remove PVs " '
-   pvremove -ff $d1 $d2 
-'
-done
+    # setup PVs
+    pvcreate -M$mdatype $dev1 $dev2 
 
-for mdatype in 2
-do
-test_expect_success \
-  "(lvm$mdatype) setup PVs (--metadatacopies 0)" '
-   pvcreate -M$mdatype $d1 $d2 &&
-   pvcreate --metadatacopies 0 -M$mdatype $d3 $d4
-'
-
-test_expect_success \
-  "(lvm$mdatype) vgreduce rejects removing pv with the last mda copy" '
-   vgcreate -M$mdatype $vg1 $d1 $d3 &&
-   { vgreduce $vg1 $d1;
-     status=$?; echo status=$status; test $status != 0 &&
-     vgremove -f $vg1
-   }
-'
-
-test_expect_success \
-  "cleanup" '
-   vgremove -ff $vg1; true
-'
-test_expect_success \
-  "(lvm$mdatype) setup: create mirror & damage one pv" '
-   vgcreate -M$mdatype $vg1 $d1 $d2 $d3 &&
-   lvcreate -n $lv1 -m1 -l 16 $vg1 &&
-   lvcreate -n $lv2  -l 16 $vg1 $d2 &&
-   lvcreate -n $lv3 -l 16 $vg1 $d3 &&
-   vgchange -an $vg1 &&
-   pvcreate -ff -y $d1 
-'
-test_expect_success \
-  "(lvm$mdatype) vgreduce --removemissing --force repares to linear" '
-   vgreduce --removemissing --force $vg1 &&
-   check_lv_field_ $vg1/$lv1 segtype linear &&
-   vg_validate_pvlv_counts_ $vg1 2 3 0
-'
-test_expect_success \
-  "cleanup" '
-   vgremove -ff $vg1
-'
-
-test_expect_success \
-  "(lvm$mdatype) setup: create mirror + linear lvs" '
-   vgcreate -M$mdatype $vg1 $d1 &&
-   lvcreate -n $lv2 -l 16 $vg1 &&
-   lvcreate -n $lv1 -l 4 $vg1 &&
-   vgextend $vg1 $d2 $d3 &&
-   lvcreate -n $lv3 -l 16 $vg1 $d3 &&
-   lvconvert -m1 $vg1/$lv1
-'
-test_debug '
-   pvs --segments -o +lv_name
-'
-test_expect_success \
-  "(lvm$mdatype) setup: damage one pv" '
-   vgchange -an $vg1 &&
-   pvcreate -ff -y $d1 
-'
-test_expect_failure \
-  "(lvm$mdatype) vgreduce rejects --removemissing --mirrorsonly --force when nonmirror lv lost too" '
-    vgreduce --removemissing --mirrorsonly --force $vg1
-'
-
-test_debug '
-   pvs -P
-   lvs -P
-   vgs -P
-'
-
-test_expect_success \
-  "cleanup" '
-   vgreduce --removemissing --force $vg1
-   vgremove -ff $vg1
-'
+    # (lvm$mdatype) vgreduce removes only the specified pv from vg (bz427382)" '
+    vgcreate -M$mdatype $vg1 $dev1 $dev2
+    vgreduce $vg1 $dev1
+    check_pv_field_ $dev2 vg_name $vg1
+    vgremove -f $vg1
+
+    # (lvm$mdatype) vgreduce rejects removing the last pv (--all)
+    vgcreate -M$mdatype $vg1 $dev1 $dev2
+    not vgreduce --all $vg1
+    vgremove -f $vg1
+
+    # (lvm$mdatype) vgreduce rejects removing the last pv
+    vgcreate -M$mdatype $vg1 $dev1 $dev2
+    not vgreduce $vg1 $dev1 $dev2
+    vgremove -f $vg1
+
+    pvremove -ff $dev1 $dev2
 done
 
+mdatype=2 # we only expect the following to work for lvm2 metadata
 
-test_done
-# Local Variables:
-# indent-tabs-mode: nil
-# End:
+# (lvm$mdatype) setup PVs (--metadatacopies 0)
+pvcreate -M$mdatype $dev1 $dev2
+pvcreate --metadatacopies 0 -M$mdatype $dev3 $dev4
+
+# (lvm$mdatype) vgreduce rejects removing pv with the last mda copy
+vgcreate -M$mdatype $vg1 $dev1 $dev3
+not vgreduce $vg1 $dev1
+vgremove -f $vg1
+
+# (lvm$mdatype) setup: create mirror & damage one pv
+vgcreate -M$mdatype $vg1 $dev1 $dev2 $dev3
+lvcreate -n $lv1 -m1 -l 4 $vg1
+lvcreate -n $lv2  -l 4 $vg1 $dev2
+lvcreate -n $lv3 -l 4 $vg1 $dev3
+vgchange -an $vg1
+pvcreate -ff -y $dev1 
+
+# (lvm$mdatype) vgreduce --removemissing --force repares to linear
+vgreduce --removemissing --force $vg1
+check_lv_field_ $vg1/$lv1 segtype linear
+vg_validate_pvlv_counts_ $vg1 2 3 0
+
+vgremove -ff $vg1
+
+# (lvm$mdatype) setup: create mirror + linear lvs
+vgcreate -M$mdatype $vg1 $dev1
+lvcreate -n $lv2 -l 4 $vg1
+lvcreate -n $lv1 -l 4 $vg1
+vgextend $vg1 $dev2 $dev3
+lvcreate -n $lv3 -l 4 $vg1 $dev3
+lvconvert -m1 $vg1/$lv1
+
+pvs --segments -o +lv_name # for record only
+
+# (lvm$mdatype) setup: damage one pv
+vgchange -an $vg1 &&
+pvcreate -ff -y $dev1
+
+# vgreduce rejects --removemissing --mirrorsonly --force when nonmirror lv lost too
+not vgreduce --removemissing --mirrorsonly --force $vg1
+
+pvs -P # for record
+lvs -P # for record
+vgs -P # for record


