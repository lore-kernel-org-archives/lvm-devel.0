From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 4 Mar 2008 22:49:00 -0000
Subject: LVM2/test t-vgsplit-operation.sh
Message-ID: <20080304224900.20503.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-03-04 22:49:00

Modified files:
	test           : t-vgsplit-operation.sh 

Log message:
	Update vgsplit tests.
	- Add validation on pv_count, lv_count, and snap_count after split
	NOTE: Some of these counts are misleading.  If you compare "lvs" output
	with these counts you will be left scratching your head what a "logical volume"
	really is.  ;-)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgsplit-operation.sh.diff?cvsroot=lvm2&r1=1.11&r2=1.12

--- LVM2/test/t-vgsplit-operation.sh	2008/03/04 19:48:32	1.11
+++ LVM2/test/t-vgsplit-operation.sh	2008/03/04 22:49:00	1.12
@@ -23,6 +23,18 @@
   rm -f "$f1" "$f2" "$f3" "$f4"
 }
 
+validate_vg_pvlv_counts_()
+{
+	local local_vg=$1
+	local num_pvs=$2
+	local num_lvs=$3
+	local num_snaps=$4
+
+	check_vg_field_ $local_vg pv_count $num_pvs &&
+	check_vg_field_ $local_vg lv_count $num_lvs &&
+	check_vg_field_ $local_vg snap_count $num_snaps
+}
+
 # FIXME: paramaterize lvm1 vs lvm2 metadata; most of these tests should run
 # fine with lvm1 metadata as well; for now, just add disks 5 and 6 as lvm1
 # metadata
@@ -46,6 +58,8 @@
    lvcreate -l 4 -n $lv1 $vg1 $d1 &&
    vgchange -an $vg1 &&
    vgsplit $vg1 $vg2 $d1 &&
+   validate_vg_pvlv_counts_ $vg1 1 0 0 &&
+   validate_vg_pvlv_counts_ $vg2 3 1 0 &&
    lvremove -f $vg2/$lv1 &&
    vgremove -f $vg2 &&
    vgremove -f $vg1'
@@ -57,6 +71,7 @@
    lvcreate -l 4 -i 2 -n $lv1 $vg1 $d1 $d2 &&
    vgchange -an $vg1 &&
    vgsplit $vg1 $vg2 $d1 $d2 &&
+   validate_vg_pvlv_counts_ $vg2 4 1 0 &&
    lvremove -f $vg2/$lv1 &&
    vgremove -f $vg2'
 
@@ -68,6 +83,7 @@
    lvcreate -l 4 -i 2 -s -n $lv2 $vg1/$lv1 &&
    vgchange -an $vg1 &&
    vgsplit $vg1 $vg2 $d1 $d2 &&
+   validate_vg_pvlv_counts_ $vg2 4 1 1 &&
    lvremove -f $vg2/$lv2 &&
    lvremove -f $vg2/$lv1 &&
    vgremove -f $vg2'
@@ -79,6 +95,7 @@
    lvcreate -l 64 -m1 -n $lv1 $vg1 $d1 $d2 $d3 &&
    vgchange -an $vg1 &&
    vgsplit $vg1 $vg2 $d1 $d2 $d3 &&
+   validate_vg_pvlv_counts_ $vg2 4 4 0 &&
    lvremove -f $vg2/$lv1 &&
    vgremove -f $vg2'
 


