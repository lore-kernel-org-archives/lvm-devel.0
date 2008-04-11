From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 11 Apr 2008 14:06:17 -0000
Subject: LVM2/test lvm-utils.sh t-vgmerge-operation.sh ...
Message-ID: <20080411140617.22959.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-04-11 14:06:16

Modified files:
	test           : lvm-utils.sh t-vgmerge-operation.sh 
	                 t-vgsplit-operation.sh 

Log message:
	Fix vgsplit and vgmerge tests for updated lv counting.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lvm-utils.sh.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgmerge-operation.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgsplit-operation.sh.diff?cvsroot=lvm2&r1=1.20&r2=1.21

--- LVM2/test/lvm-utils.sh	2008/03/28 18:02:22	1.9
+++ LVM2/test/lvm-utils.sh	2008/04/11 14:06:16	1.10
@@ -86,6 +86,18 @@
   return $(test $(lvs --noheadings -o $2 $1) == $3)
 }
 
+vg_validate_pvlv_counts_()
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
 dmsetup_has_dm_devdir_support_()
 {
   # Detect support for the envvar.  If it's supported, the
--- LVM2/test/t-vgmerge-operation.sh	2008/04/10 19:59:43	1.2
+++ LVM2/test/t-vgmerge-operation.sh	2008/04/11 14:06:16	1.3
@@ -23,18 +23,6 @@
   rm -f "$f1" "$f2" "$f3" "$f4"
 }
 
-vg_validate_pvlv_counts_()
-{
-	local local_vg=$1
-	local num_pvs=$2
-	local num_lvs=$3
-	local num_snaps=$4
-
-	check_vg_field_ $local_vg pv_count $num_pvs &&
-	check_vg_field_ $local_vg lv_count $num_lvs &&
-	check_vg_field_ $local_vg snap_count $num_snaps
-}
-
 test_expect_success \
   'set up temp files, loopback devices, PVs, vgnames' \
   'f1=$(pwd)/1 && d1=$(loop_setup_ "$f1") &&
@@ -81,10 +69,10 @@
    lvcreate -l 16 -n $lv1 $vg1 &&
    lvcreate -l 4 -s -n $lv2 $vg1/$lv1 &&
    vgchange -an $vg1 &&
-   vg_validate_pvlv_counts_ $vg1 2 1 1 &&
+   vg_validate_pvlv_counts_ $vg1 2 2 1 &&
    vg_validate_pvlv_counts_ $vg2 2 0 0 &&
    vgmerge $vg2 $vg1 &&
-   vg_validate_pvlv_counts_ $vg2 4 1 1 &&
+   vg_validate_pvlv_counts_ $vg2 4 2 1 &&
    lvremove -f $vg2/$lv2 &&
    vgremove -f $vg2'
 
@@ -94,10 +82,10 @@
    vgcreate $vg2 $d4 &&
    lvcreate -l 4 -n $lv1 -m1 $vg1 &&
    vgchange -an $vg1 &&
-   vg_validate_pvlv_counts_ $vg1 3 4 0 &&
+   vg_validate_pvlv_counts_ $vg1 3 1 0 &&
    vg_validate_pvlv_counts_ $vg2 1 0 0 &&
    vgmerge $vg2 $vg1 &&
-   vg_validate_pvlv_counts_ $vg2 4 4 0 &&
+   vg_validate_pvlv_counts_ $vg2 4 1 0 &&
    lvremove -f $vg2/$lv1 &&
    vgremove -f $vg2'
 
--- LVM2/test/t-vgsplit-operation.sh	2008/04/10 21:38:52	1.20
+++ LVM2/test/t-vgsplit-operation.sh	2008/04/11 14:06:16	1.21
@@ -24,18 +24,6 @@
   rm -f "$f1" "$f2" "$f3" "$f4" "$f5"
 }
 
-vg_validate_pvlv_counts_()
-{
-	local local_vg=$1
-	local num_pvs=$2
-	local num_lvs=$3
-	local num_snaps=$4
-
-	check_vg_field_ $local_vg pv_count $num_pvs &&
-	check_vg_field_ $local_vg lv_count $num_lvs &&
-	check_vg_field_ $local_vg snap_count $num_snaps
-}
-
 # FIXME: paramaterize lvm1 vs lvm2 metadata; most of these tests should run
 # fine with lvm1 metadata as well; for now, just add disks 5 and 6 as lvm1
 # metadata


