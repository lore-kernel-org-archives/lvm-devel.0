From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 23 Mar 2008 15:40:36 -0000
Subject: LVM2/test lvm-utils.sh t-vgsplit-usage.sh
Message-ID: <20080323154036.10495.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-03-23 15:40:35

Modified files:
	test           : lvm-utils.sh t-vgsplit-usage.sh 

Log message:
	Add vgsplit tests to verfy attributes of new VG match source VG.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lvm-utils.sh.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgsplit-usage.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/test/lvm-utils.sh	2008/01/17 18:05:57	1.7
+++ LVM2/test/lvm-utils.sh	2008/03/23 15:40:35	1.8
@@ -50,6 +50,15 @@
   return 0;
 }
 
+compare_vg_field_()
+{
+if test "$verbose" = "t"
+then
+  echo "compare_vg_field_ VG1: `vgs --noheadings -o $3 $1` VG2: `vgs --noheadings -o $3 $2`"
+fi
+  return $(test $(vgs --noheadings -o $3 $1) == $(vgs --noheadings -o $3 $2) )
+}
+
 check_vg_field_()
 {
 if test "$verbose" = "t"
--- LVM2/test/t-vgsplit-usage.sh	2008/03/21 22:00:29	1.2
+++ LVM2/test/t-vgsplit-usage.sh	2008/03/23 15:40:35	1.3
@@ -164,6 +164,36 @@
    vgremove -f $vg1'
 
 test_expect_success \
+  'verify default - max_lv attribute from new VG is same as source VG' \
+  'vgcreate $vg1 $d1 $d2 &&
+   lvcreate -l 4 -n $lv1 $vg1 &&
+   vgchange -an $vg1 &&
+   vgsplit $vg1 $vg2 $d1 &&
+   compare_vg_field_ $vg1 $vg2 max_lv &&
+   vgremove -f $vg2 &&
+   vgremove -f $vg1'
+
+test_expect_success \
+  'verify default - max_pv attribute from new VG is same as source VG' \
+  'vgcreate $vg1 $d1 $d2 &&
+   lvcreate -l 4 -n $lv1 $vg1 &&
+   vgchange -an $vg1 &&
+   vgsplit $vg1 $vg2 $d1 &&
+   compare_vg_field_ $vg1 $vg2 max_pv &&
+   vgremove -f $vg2 &&
+   vgremove -f $vg1'
+
+test_expect_success \
+  'verify default - vg_fmt attribute from new VG is same as source VG' \
+  'vgcreate $vg1 $d1 $d2 &&
+   lvcreate -l 4 -n $lv1 $vg1 &&
+   vgchange -an $vg1 &&
+   vgsplit $vg1 $vg2 $d1 &&
+   compare_vg_field_ $vg1 $vg2 vg_fmt &&
+   vgremove -f $vg2 &&
+   vgremove -f $vg1'
+
+test_expect_success \
   'vgsplit rejects split because PV not in VG' \
   'vgcreate $vg1 $d1 $d2 &&
    vgcreate $vg2 $d3 $d4 &&


