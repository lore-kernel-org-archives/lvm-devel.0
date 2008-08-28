From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 28 Aug 2008 11:20:49 -0000
Subject: LVM2/test t-vgreduce-usage.sh
Message-ID: <20080828112049.1776.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2008-08-28 11:20:49

Modified files:
	test           : t-vgreduce-usage.sh 

Log message:
	fix vgreduce tests to detect partial command failure (Jaroslav Stava)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgreduce-usage.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/test/t-vgreduce-usage.sh	2008/08/12 10:04:31	1.1
+++ LVM2/test/t-vgreduce-usage.sh	2008/08/28 11:20:49	1.2
@@ -35,28 +35,39 @@
    lv2=$(this_test_)-test-lv2-$$          &&
    lv3=$(this_test_)-test-lv3-$$'
 
+#TODO --removemissing (+ -- mirrorsonly)
 
 for mdatype in 1 2
 do
 test_expect_success \
   "(lvm$mdatype) setup PVs" '
-  pvcreate -M$mdatype $d1 $d2 
+   pvcreate -M$mdatype $d1 $d2 
 '
 
 test_expect_success \
-  "(lvm$mdatype) vgreduce rejects removing the last pv (--all)" '
+  "(lvm$mdatype) vgreduce removes only the specified pv from vg (bz427382)" '
    vgcreate -M$mdatype $vg1 $d1 $d2 &&
-   vgreduce --all $vg1  2>err;
+   vgreduce $vg1 $d1 &&
+   check_pv_field_ $d2 vg_name $vg1 &&
    vgremove -f $vg1
 '
-   #status=$?; echo status=$status; test $status = 5 &&
+
+test_expect_success \
+  "(lvm$mdatype) vgreduce rejects removing the last pv (--all)" '
+   vgcreate -M$mdatype $vg1 $d1 $d2 &&
+   { vgreduce --all $vg1;
+     status=$?; echo status=$status; test $status != 0 &&
+     vgremove -f $vg1
+   }
+'
 
 test_expect_success \
   "(lvm$mdatype) vgreduce rejects removing the last pv" '
    vgcreate -M$mdatype $vg1 $d1 $d2 &&
-   vgreduce $vg1 $d1 $d2 2>err;
-   status=$?; echo status=$status; test $status = 5 &&
-   vgremove -f $vg1
+   { vgreduce $vg1 $d1 $d2;
+     status=$?; echo status=$status; test $status = 5 &&
+     vgremove -f $vg1
+   }
 '
 
 test_expect_success \
@@ -65,21 +76,21 @@
 '
 done
 
-## TODO --mirrorsonly ?
 for mdatype in 2
 do
 test_expect_success \
   "(lvm$mdatype) setup PVs (--metadatacopies 0)" '
-  pvcreate -M$mdatype $d1 $d2 
+  pvcreate -M$mdatype $d1 $d2 &&
   pvcreate --metadatacopies 0 -M$mdatype $d3 $d4
 '
 
 test_expect_success \
   "(lvm$mdatype) vgreduce rejects removing pv with the last mda copy" '
    vgcreate -M$mdatype $vg1 $d1 $d3 &&
-   vgreduce $vg1 $d1 2>err;
-   status=$?; echo status=$status; test $status != 0 &&
-   vgremove -f $vg1
+   { vgreduce $vg1 $d1;
+     status=$?; echo status=$status; test $status != 0 &&
+     vgremove -f $vg1
+   }
 '
 done
 


