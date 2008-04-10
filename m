From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 10 Apr 2008 21:38:52 -0000
Subject: LVM2 ./WHATS_NEW test/t-vgsplit-operation.sh
Message-ID: <20080410213852.15899.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-04-10 21:38:52

Modified files:
	.              : WHATS_NEW 
	test           : t-vgsplit-operation.sh 

Log message:
	Update vgsplit test to verify loosening of active LV restriction.
	
	This and prior 2 commits resolve Red Hat bz 252041:
	Ability to vgsplit an active Volume Group where the split involves only inactive LVs

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.846&r2=1.847
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgsplit-operation.sh.diff?cvsroot=lvm2&r1=1.19&r2=1.20

--- LVM2/WHATS_NEW	2008/04/10 20:07:19	1.846
+++ LVM2/WHATS_NEW	2008/04/10 21:38:52	1.847
@@ -1,5 +1,8 @@
 Version 2.02.35 - 
 =================================
+  Update vgsplit tests to verify loosening of active LV restriction.
+  Update vgsplit to only restrict split with active LVs involved in split.
+  Add lv_is_active() to determine whether an lv is active.
 
 Version 2.02.34 - 10th April 2008
 =================================
--- LVM2/test/t-vgsplit-operation.sh	2008/04/10 18:55:40	1.19
+++ LVM2/test/t-vgsplit-operation.sh	2008/04/10 21:38:52	1.20
@@ -276,6 +276,65 @@
    status=$?; echo status=$status; test $status = 5 &&
    vgremove -ff $vg1'
 
+#
+# Verify vgsplit rejects active LVs only when active LVs involved in split
+#
+test_expect_success \
+  "vgsplit fails, active mirror involved in split" \
+  'vgcreate $vg1 $d1 $d2 $d3 $d4 &&
+   lvcreate -l 16 -n $lv1 -m1 $vg1 $d1 $d2 $d3 &&
+   lvcreate -l 16 -n $lv2 $vg1 $d4 &&
+   lvchange -an $vg1/$lv2 &&
+   vg_validate_pvlv_counts_ $vg1 4 2 0 &&
+   vgsplit -n $lv1 $vg1 $vg2;
+   status=$?; echo status=$status; test $status = 5 &&
+   vg_validate_pvlv_counts_ $vg1 4 2 0 &&
+   vgremove -ff $vg1'
+
+test_expect_success \
+  "vgsplit succeeds, active mirror not involved in split" \
+  'vgcreate $vg1 $d1 $d2 $d3 $d4 &&
+   lvcreate -l 16 -n $lv1 -m1 $vg1 $d1 $d2 $d3 &&
+   lvcreate -l 16 -n $lv2 $vg1 $d4 &&
+   lvchange -an $vg1/$lv2 &&
+   vg_validate_pvlv_counts_ $vg1 4 2 0 &&
+   vgsplit -n $lv2 $vg1 $vg2 &&
+   vg_validate_pvlv_counts_ $vg1 3 1 0 &&
+   vg_validate_pvlv_counts_ $vg2 1 1 0 &&
+   vgremove -ff $vg1 &&
+   vgremove -ff $vg2'
+
+test_expect_success \
+  "vgsplit fails, active snapshot involved in split" \
+  'vgcreate $vg1 $d1 $d2 $d3 $d4 &&
+   lvcreate -l 64 -i 2 -n $lv1 $vg1 $d1 $d2 &&
+   lvcreate -l 4 -i 2 -s -n $lv2 $vg1/$lv1 &&
+   lvcreate -l 64 -i 2 -n $lv3 $vg1 $d3 $d4 &&
+   lvchange -an $vg1/$lv3 &&
+   vg_validate_pvlv_counts_ $vg1 4 3 1 &&
+   vgsplit -n $lv2 $vg1 $vg2;
+   status=$?; echo status=$status; test $status = 5 &&
+   vg_validate_pvlv_counts_ $vg1 4 3 1 &&
+   lvremove -f $vg1/$lv2 &&
+   vgremove -ff $vg1'
+
+test_expect_success \
+  "vgsplit succeeds, active snapshot not involved in split" \
+  'vgcreate $vg1 $d1 $d2 $d3 &&
+   lvcreate -l 64 -i 2 -n $lv1 $vg1 $d1 $d2 &&
+   lvcreate -l 4 -s -n $lv2 $vg1/$lv1 &&
+   vgextend $vg1 $d4 &&
+   lvcreate -l 64 -n $lv3 $vg1 $d4 &&
+   lvchange -an $vg1/$lv3 &&
+   vg_validate_pvlv_counts_ $vg1 4 3 1 &&
+   vgsplit -n $lv3 $vg1 $vg2 &&
+   vg_validate_pvlv_counts_ $vg1 3 2 1 &&
+   vg_validate_pvlv_counts_ $vg2 1 1 0 &&
+   vgchange -an $vg1 &&
+   lvremove -f $vg1/$lv2 &&
+   vgremove -ff $vg1 &&
+   vgremove -ff $vg2'
+
 
 test_done
 


