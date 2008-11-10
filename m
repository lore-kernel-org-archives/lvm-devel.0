From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 10 Nov 2008 12:43:39 -0000
Subject: LVM2/test t-lvcreate-pvtags.sh t-pvcreate-oper ...
Message-ID: <20081110124339.25695.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2008-11-10 12:43:35

Modified files:
	test           : t-lvcreate-pvtags.sh t-pvcreate-operation.sh 
	                 t-pvcreate-usage.sh t-read-ahead.sh 
	                 t-unlost-pv.sh t-vgcreate-usage.sh 
	                 t-vgreduce-usage.sh t-vgsplit-usage.sh 

Log message:
	Minor code and documentation cleanups and changes by jstava.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvcreate-pvtags.sh.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvcreate-operation.sh.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvcreate-usage.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-read-ahead.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-unlost-pv.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgcreate-usage.sh.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgreduce-usage.sh.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgsplit-usage.sh.diff?cvsroot=lvm2&r1=1.11&r2=1.12

--- LVM2/test/t-lvcreate-pvtags.sh	2008/09/29 16:02:49	1.4
+++ LVM2/test/t-lvcreate-pvtags.sh	2008/11/10 12:43:35	1.5
@@ -11,6 +11,8 @@
 . ./test-utils.sh
 
 aux prepare_pvs 3
+# not required, just testing
+aux pvcreate --metadatacopies 0 $dev1
 
 vgcreate $vg $devs
 pvchange --addtag fast $devs
--- LVM2/test/t-pvcreate-operation.sh	2008/09/30 17:47:34	1.11
+++ LVM2/test/t-pvcreate-operation.sh	2008/11/10 12:43:35	1.12
@@ -15,7 +15,7 @@
 for mdatype in 1 2
 do
 
-# pvcreate (lvm$mdatype) succeeds when run repeatedly (pv not in a vg)
+# pvcreate (lvm$mdatype) succeeds when run repeatedly (pv not in a vg) (bz178216)
     pvcreate -M$mdatype $dev1
     pvcreate -M$mdatype $dev1
     pvremove -f $dev1
--- LVM2/test/t-pvcreate-usage.sh	2008/10/06 16:47:07	1.3
+++ LVM2/test/t-pvcreate-usage.sh	2008/11/10 12:43:35	1.4
@@ -31,7 +31,6 @@
 
 # x. metadatasize too large
 # For some reason we allow this, even though there's no room for data?
-#test_expect_success \
 ##COMM  'pvcreate rejects metadatasize too large' 
 #not pvcreate --metadatasize 100000000000000 $dev1
 
--- LVM2/test/t-read-ahead.sh	2008/10/06 16:47:07	1.3
+++ LVM2/test/t-read-ahead.sh	2008/11/10 12:43:35	1.4
@@ -19,7 +19,11 @@
 
 
 get_lvs_() {
-   case $(lvs --units s --nosuffix --noheadings -o $1_read_ahead "$vg"/"$lv") in
+   lvs --units s --nosuffix --noheadings -o $1 "$vg"/"$lv"
+}
+
+check_lvs_() {
+   case $(get_lvs_ $1) in
     *$2) true ;;
     *) false ;;
    esac
@@ -27,13 +31,15 @@
 
 aux prepare_vg 5
 
-#COMM "test various read ahead settings"
+#COMM "test various read ahead settings (bz450922)"
 lvcreate -n "$lv" -l 100%FREE -i5 -I256 "$vg"     
+ra="$(get_lvs_ lv_kernel_read_ahead)"
+test "$(( ( $ra / 5 ) * 5 ))" -eq $ra
 lvdisplay "$vg"/"$lv"                             
 lvchange -r auto "$vg"/"$lv" 2>&1 | grep auto     
-get_lvs_ lv auto                                  
-get_lvs_ lv_kernel 5120                           
+check_lvs_ lv_read_ahead auto                                  
+check_lvs_ lv_kernel_read_ahead 5120                           
 lvchange -r 400 "$vg/$lv"                         
-get_lvs_ lv 400                                   
-vgremove -f "$vg"
+check_lvs_ lv_read_ahead 400                                   
+lvremove -ff "$vg"
 
--- LVM2/test/t-unlost-pv.sh	2008/09/29 16:06:10	1.1
+++ LVM2/test/t-unlost-pv.sh	2008/11/10 12:43:35	1.2
@@ -1,3 +1,14 @@
+#!/bin/sh
+# Copyright (C) 2008 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
 . ./test-utils.sh
 
 aux prepare_vg 3
@@ -12,7 +23,7 @@
 not grep "Inconsistent metadata found for VG $vg" vgscan.out
 }
 
-# try orphaning a missing PV
+# try orphaning a missing PV (bz45867)
 disable_dev $dev1
 vgreduce --removemissing --force $vg
 enable_dev $dev1
--- LVM2/test/t-vgcreate-usage.sh	2008/10/06 16:47:07	1.5
+++ LVM2/test/t-vgcreate-usage.sh	2008/11/10 12:43:35	1.6
@@ -55,7 +55,7 @@
 #not vgcreate $vg $dev1 $dev2 2>err
 #grep "New volume group name \"$vg\" is invalid\$" err
 
-#COMM "vgcreate rejects repeated invocation (run 2 times)"
+#COMM "vgcreate rejects repeated invocation (run 2 times) (bz178216)"
 vgcreate $vg $dev1 $dev2
 not vgcreate $vg $dev1 $dev2
 vgremove -ff $vg
--- LVM2/test/t-vgreduce-usage.sh	2008/09/30 17:17:04	1.4
+++ LVM2/test/t-vgreduce-usage.sh	2008/11/10 12:43:35	1.5
@@ -43,43 +43,43 @@
 pvcreate -M$mdatype $dev1 $dev2
 pvcreate --metadatacopies 0 -M$mdatype $dev3 $dev4
 
-# (lvm$mdatype) vgreduce rejects removing pv with the last mda copy
+# (lvm$mdatype) vgreduce rejects removing pv with the last mda copy (bz247448)
 vgcreate -M$mdatype $vg1 $dev1 $dev3
 not vgreduce $vg1 $dev1
 vgremove -f $vg1
 
+#COMM "(lvm$mdatype) vgreduce --removemissing --force repares to linear (bz221921)"
 # (lvm$mdatype) setup: create mirror & damage one pv
 vgcreate -M$mdatype $vg1 $dev1 $dev2 $dev3
 lvcreate -n $lv1 -m1 -l 4 $vg1
 lvcreate -n $lv2  -l 4 $vg1 $dev2
 lvcreate -n $lv3 -l 4 $vg1 $dev3
 vgchange -an $vg1
-pvcreate -ff -y $dev1 
-
+aux disable_dev $dev1
 # (lvm$mdatype) vgreduce --removemissing --force repares to linear
 vgreduce --removemissing --force $vg1
 check_lv_field_ $vg1/$lv1 segtype linear
 vg_validate_pvlv_counts_ $vg1 2 3 0
-
+# cleanup
+aux enable_dev $dev1
 vgremove -ff $vg1
 
+#COMM "vgreduce rejects --removemissing --mirrorsonly --force when nonmirror lv lost too"
 # (lvm$mdatype) setup: create mirror + linear lvs
-vgcreate -M$mdatype $vg1 $dev1
+vgcreate -M$mdatype $vg1 $devs
 lvcreate -n $lv2 -l 4 $vg1
-lvcreate -n $lv1 -l 4 $vg1
-vgextend $vg1 $dev2 $dev3
+lvcreate -m1 -n $lv1 -l 4 $vg1 $dev1 $dev2 $dev3
 lvcreate -n $lv3 -l 4 $vg1 $dev3
-lvconvert -m1 $vg1/$lv1
-
 pvs --segments -o +lv_name # for record only
-
 # (lvm$mdatype) setup: damage one pv
-vgchange -an $vg1 &&
-pvcreate -ff -y $dev1
-
+vgchange -an $vg1 
+aux disable_dev $dev1
+#pvcreate -ff -y $dev1
 # vgreduce rejects --removemissing --mirrorsonly --force when nonmirror lv lost too
 not vgreduce --removemissing --mirrorsonly --force $vg1
 
+aux enable_dev $dev1
+
 pvs -P # for record
 lvs -P # for record
 vgs -P # for record
--- LVM2/test/t-vgsplit-usage.sh	2008/09/30 21:43:55	1.11
+++ LVM2/test/t-vgsplit-usage.sh	2008/11/10 12:43:35	1.12
@@ -25,6 +25,7 @@
 pvcreate -M$mdatype $devs
 
 # vgsplit accepts new vg as destination of split
+# lvm1 -- bz244792
 vgcreate -M$mdatype $vg1 $devs
 vgsplit $vg1 $vg2 $dev1 1>err
 grep "New volume group \"$vg2\" successfully split from \"$vg1\"" err 


