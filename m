From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 28 Jan 2011 16:15:10 -0000
Subject: LVM2/test t-pvmove-basic.sh
Message-ID: <20110128161510.3196.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-01-28 16:15:09

Modified files:
	test           : t-pvmove-basic.sh 

Log message:
	Lower device size of pvmove test
	
	Lower the size of devices in this test for speedup.
	And check only once that  LVs are prepared properly.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvmove-basic.sh.diff?cvsroot=lvm2&r1=1.12&r2=1.13

--- LVM2/test/t-pvmove-basic.sh	2011/01/05 00:16:20	1.12
+++ LVM2/test/t-pvmove-basic.sh	2011/01/28 16:15:08	1.13
@@ -43,30 +43,34 @@
 # ---------------------------------------------------------------------
 # Initialize PVs and VGs
 
-aux prepare_vg 5 80
+aux prepare_vg 5 40
 
 # ---------------------------------------------------------------------
 # Common environment setup/cleanup for each sub testcases
+FIRST=""
 
 prepare_lvs_() {
   lvcreate -l2 -n $lv1 $vg $dev1 
-    lv_is_on_ $vg/$lv1 $dev1 
+    test -z "$FIRST" && lv_is_on_ $vg/$lv1 $dev1
   lvcreate -l9 -i3 -n $lv2 $vg $dev2 $dev3 $dev4 
-    lv_is_on_ $vg/$lv2 $dev2 $dev3 $dev4 
+    test -z "$FIRST" && lv_is_on_ $vg/$lv2 $dev2 $dev3 $dev4
   lvextend -l+2 $vg/$lv1 $dev2 
-    lv_is_on_ $vg/$lv1 $dev1 $dev2 
+    test -z "$FIRST" && lv_is_on_ $vg/$lv1 $dev1 $dev2
   lvextend -l+2 $vg/$lv1 $dev3 
-    lv_is_on_ $vg/$lv1 $dev1 $dev2 $dev3 
+    test -z "$FIRST" && lv_is_on_ $vg/$lv1 $dev1 $dev2 $dev3
   lvextend -l+2 $vg/$lv1 $dev1 
-    lv_is_on_ $vg/$lv1 $dev1 $dev2 $dev3 $dev1 
+    test -z "$FIRST" && lv_is_on_ $vg/$lv1 $dev1 $dev2 $dev3 $dev1
   lvcreate -l1 -n $lv3 $vg $dev2 
-    lv_is_on_ $vg/$lv3 $dev2 
+    test -z "$FIRST" && lv_is_on_ $vg/$lv3 $dev2
   save_dev_sum_ $(lvdev_ $vg $lv1) 
   save_dev_sum_ $(lvdev_ $vg $lv2) 
   save_dev_sum_ $(lvdev_ $vg $lv3) 
-  lvs -a -o devices --noheadings $vg/$lv1 > ${lv1}_devs 
-  lvs -a -o devices --noheadings $vg/$lv2 > ${lv2}_devs 
-  lvs -a -o devices --noheadings $vg/$lv3 > ${lv3}_devs
+  if test -z "$FIRST" ; then
+    lvs -a -o devices --noheadings $vg/$lv1 > ${lv1}_devs
+    lvs -a -o devices --noheadings $vg/$lv2 > ${lv2}_devs
+    lvs -a -o devices --noheadings $vg/$lv3 > ${lv3}_devs
+  fi
+  FIRST=done
 }
 
 lv_not_changed_() {


