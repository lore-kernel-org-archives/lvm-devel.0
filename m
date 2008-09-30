From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 30 Sep 2008 13:19:57 -0000
Subject: LVM2/test t-pvremove-usage.sh
Message-ID: <20080930131957.13656.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2008-09-30 13:19:56

Modified files:
	test           : t-pvremove-usage.sh 

Log message:
	Convert t-pvremove-usage to use the new test-utils.sh.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvremove-usage.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/test/t-pvremove-usage.sh	2008/08/28 10:24:55	1.1
+++ LVM2/test/t-pvremove-usage.sh	2008/09/30 13:19:56	1.2
@@ -9,103 +9,56 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
-test_description='Test pvremove'
-privileges_required_=1
+. ./test-utils.sh
 
-. ./test-lib.sh
-
-cleanup_()
-{
-  test -n "$d1" && losetup -d "$d1"
-  test -n "$d2" && losetup -d "$d2"
-  test -n "$d3" && losetup -d "$d3"
-  rm -f "$f1" "$f2"
-}
-
-test_expect_success "set up temp files, loopback devices" \
-  'f1=$(pwd)/1 && d1=$(loop_setup_ "$f1") &&
-   f2=$(pwd)/2 && d2=$(loop_setup_ "$f2") &&
-   f3=$(pwd)/3 && d3=$(loop_setup_ "$f3") &&
-   vg=$(this_test_)-test-vg-$$            &&
-   pvcreate "$d1"                         &&
-   pvcreate --metadatacopies 0 "$d2"      &&
-   pvcreate --metadatacopies 2 "$d3"
-'
-
-test_expect_success "check pvremove fails when bogus pv given" '
-   pvremove "$d2" bogus;
-   status=$?; echo $status; test $status != 0 
-'
-
-#failing, but still removing everything what can be removed
-#is somewhat odd as default, what do we have -f for?
-test_expect_failure "but still removes the valid pv that was given too :-/" '
-   pvs | grep "$d2"; status=$?;
-   pvcreate  --metadatacopies 0 "$d2";
-   echo $status; test $status = 0
-'
-
-test_expect_success "check pvremove refuses to remove pv in a vg" '
-   vgcreate -c n "$vg" "$d1" "$d2" &&
-   { pvremove "$d2" "$d3";
-     status=$?; echo $status; test $status != 0
-   }
-'
+aux prepare_devs 3
+pvcreate $dev1
+pvcreate --metadatacopies 0 $dev2
+pvcreate --metadatacopies 2 $dev3
+
+# check pvremove fails when bogus pv given
+not pvremove $dev2 bogus
+
+# failing, but still removing everything what can be removed
+# is somewhat odd as default, what do we have -f for?
+pvs | not grep $dev2
+pvcreate  --metadatacopies 0 $dev2
+
+# check pvremove refuses to remove pv in a vg
+vgcreate -c n $vg $dev1 $dev2
+not pvremove $dev2 $dev3
 
 for mdacp in 0 1 2; do
-test_expect_success \
-  "check pvremove truly wipes the label (pvscan wont find) (---metadatacopies $mdacp)" '
-   pvcreate --metadatacopies $mdacp "$d3" &&
-   pvremove "$d3" &&
-   { pvscan |grep "$d3"; 
-     status=$?; echo $status; test $status != 0 
-   }
-'
-
-test_expect_success "reset setup" '
-   vgremove -ff $vg &&
-   pvcreate --metadatacopies $mdacp "$d1" &&
-   pvcreate "$d2" &&
-   vgcreate $vg $d1 $d2 
-'
-test_expect_success "pvremove -f fails when pv in a vg (---metadatacopies $mdacp)" '
-   pvremove -f $d1;
-   status=$?; echo $status; test $status != 0 &&
-   pvs $d1
-'
-test_expect_success \
-  "pvremove -ff fails without confirmation when pv in a vg (---metadatacopies $mdacp)" '
-   echo n|eval pvremove -ff $d1;
-   status=$?; echo $status; test $status != 0
-'
-test_expect_success \
-  "pvremove -ff succeds with confirmation when pv in a vg (---metadatacopies $mdacp)" '
-   yes | pvremove -ff $d1 &&
-   pvs $d1;
-   status=$?; echo $status; test $status != 0
-'
-test_expect_success "cleanup & setup" '
-  vgreduce --removemissing $vg &&
-  pvcreate --metadatacopies $mdacp "$d1" &&
-  vgextend $vg $d1
-'
-test_expect_success \
-  "pvremove -ff -y is sufficient when pv in a vg (---metadatacopies $mdacp)" '
-   echo n | pvremove -ff -y $d1
-'
-test_expect_success "cleanup & setup" '
-  vgreduce --removemissing $vg &&
-  pvcreate --metadatacopies $mdacp "$d1" &&
-  vgextend $vg $d1
-'
+    # check pvremove truly wipes the label (pvscan wont find) (---metadatacopies $mdacp)
+    pvcreate --metadatacopies $mdacp $dev3
+    pvremove $dev3
+    pvscan | not grep $dev3
+
+    # reset setup
+    vgremove -ff $vg
+    pvcreate --metadatacopies $mdacp $dev1
+    pvcreate $dev2
+    vgcreate $vg $dev1 $dev2 
+
+    # pvremove -f fails when pv in a vg (---metadatacopies $mdacp)
+    not pvremove -f $dev1
+    pvs $dev1
+
+    # pvremove -ff fails without confirmation when pv in a vg (---metadatacopies $mdacp)
+    echo n | not pvremove -ff $dev1
+
+    # pvremove -ff succeds with confirmation when pv in a vg (---metadatacopies $mdacp)
+    yes | pvremove -ff $dev1
+    not pvs $dev1
+
+    vgreduce --removemissing $vg
+    pvcreate --metadatacopies $mdacp $dev1
+    vgextend $vg $dev1
+
+    # pvremove -ff -y is sufficient when pv in a vg (---metadatacopies $mdacp)" '
+    echo n | pvremove -ff -y $dev1
+
+    vgreduce --removemissing $vg
+    pvcreate --metadatacopies $mdacp $dev1
+    vgextend $vg $dev1
 done
-
-test_expect_success "cleanup" '
-   vgremove -ff "$vg"
-'
-
-test_done
-
-# Local Variables:
-# indent-tabs-mode: nil
-# End:


