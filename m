From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 11 May 2009 03:37:35 -0000
Subject: LVM2/test t-lvextend-percent-extents.sh
Message-ID: <20090511033735.26532.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-05-11 03:37:34

Modified files:
	test           : t-lvextend-percent-extents.sh 

Log message:
	Add test for seg_start, seg_count, seg_start_pe

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvextend-percent-extents.sh.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/test/t-lvextend-percent-extents.sh	2008/11/11 15:46:15	1.6
+++ LVM2/test/t-lvextend-percent-extents.sh	2009/05/11 03:37:34	1.7
@@ -80,3 +80,22 @@
 grep "^  Logical volume $lv successfully resized\$" out 
 check_lv_field_ $vg/$lv lv_size "72.00M"
 
+# Simple seg_count validation; initially create the LV with half the # of
+# extents (should be 1 lv segment), extend it (should go to 2 segments),
+# then reduce (should be back to 1)
+# FIXME: test other segment fields such as seg_size, pvseg_start, pvseg_size
+lvremove -f $vg/$lv
+pe_count=$(pvs -o pv_pe_count --noheadings $dev1)
+pe1=$(( $pe_count / 2 ))
+lvcreate -l $pe1 -n $lv $vg
+pesize=$(lvs -ovg_extent_size --units b --nosuffix --noheadings $vg/$lv)
+segsize=$(( $pe1 * $pesize / 1024 / 1024 ))M
+check_lv_field_ $vg/$lv seg_count 1
+check_lv_field_ $vg/$lv seg_start 0
+check_lv_field_ $vg/$lv seg_start_pe 0
+#check_lv_field_ $vg/$lv seg_size $segsize
+lvextend -l +$(( $pe_count * 1 )) $vg/$lv
+check_lv_field_ $vg/$lv seg_count 2
+lvreduce -f -l -$(( $pe_count * 1 )) $vg/$lv
+check_lv_field_ $vg/$lv seg_count 1
+


