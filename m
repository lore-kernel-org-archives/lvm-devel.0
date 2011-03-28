From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 28 Mar 2011 11:35:21 -0000
Subject: LVM2/test t-vgmerge-usage.sh t-vgsplit-usage.sh
Message-ID: <20110328113521.8093.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-03-28 11:35:20

Modified files:
	test           : t-vgmerge-usage.sh t-vgsplit-usage.sh 

Log message:
	Reduce amount of vgremove and vgchange calls
	
	A bit noticable time defference when whole test-suite is run through valgrind.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgmerge-usage.sh.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgsplit-usage.sh.diff?cvsroot=lvm2&r1=1.15&r2=1.16

--- LVM2/test/t-vgmerge-usage.sh	2011/01/05 00:16:20	1.8
+++ LVM2/test/t-vgmerge-usage.sh	2011/03/28 11:35:20	1.9
@@ -31,24 +31,21 @@
 vgcreate  $vg2 $dev3 $dev4 
 not vgmerge $vg1 $vg1 2>err
 grep "^  Duplicate volume group name \"$vg1\"\$" err 
-vgremove $vg2 
-vgremove $vg1
+vgremove $vg1 $vg2
 
 # 'vgmerge rejects vgs with incompatible extent_size'
 vgcreate  --physicalextentsize 4M $vg1 $dev1 $dev2 
 vgcreate  --physicalextentsize 8M $vg2 $dev3 $dev4 
 not vgmerge $vg1 $vg2 2>err
 grep "^  Extent sizes differ" err 
-vgremove $vg2 
-vgremove $vg1
+vgremove $vg1 $vg2
 
 # 'vgmerge rejects vgmerge because max_pv is exceeded'
 vgcreate  --maxphysicalvolumes 2 $vg1 $dev1 $dev2 
 vgcreate  --maxphysicalvolumes 2 $vg2 $dev3 $dev4 
 not vgmerge $vg1 $vg2 2>err
 grep "^  Maximum number of physical volumes (2) exceeded" err 
-vgremove $vg2 
-vgremove $vg1
+vgremove $vg1 $vg2
 
 # 'vgmerge rejects vg with active lv'
 vgcreate $vg1 $dev1 $dev2 
@@ -56,8 +53,7 @@
 lvcreate -l 4 -n lv1 $vg2 
 not vgmerge $vg1 $vg2 2>err
 grep "^  Logical volumes in \"$vg2\" must be inactive\$" err 
-vgremove -f $vg2 
-vgremove -f $vg1
+vgremove -f $vg1 $vg2
 
 # 'vgmerge rejects vgmerge because max_lv is exceeded' 
 vgcreate --maxlogicalvolumes 2 $vg1 $dev1 $dev2 
@@ -65,9 +61,7 @@
 lvcreate -l 4 -n lv1 $vg1 
 lvcreate -l 4 -n lv2 $vg1 
 lvcreate -l 4 -n lv3 $vg2 
-vgchange -an $vg1 
-vgchange -an $vg2 
+vgchange -an $vg1 $vg2
 not vgmerge $vg1 $vg2 2>err
 grep "^  Maximum number of logical volumes (2) exceeded" err 
-vgremove -f $vg2 
-vgremove -f $vg1
+vgremove -f $vg1 $vg2
--- LVM2/test/t-vgsplit-usage.sh	2011/01/05 00:16:20	1.15
+++ LVM2/test/t-vgsplit-usage.sh	2011/03/28 11:35:20	1.16
@@ -24,82 +24,72 @@
 # NOTE: if we're using lvm1, we must use -M on vgsplit
 vgcreate -M$mdatype $vg1 $(cat DEVICES)
 vgsplit -M$mdatype $vg1 $vg2 $dev1
-vgremove $vg1
-vgremove $vg2
+vgremove $vg1 $vg2
+
 vgcreate -M$mdatype $vg2 $(cat DEVICES)
 vgsplit -M$mdatype $vg2 $vg1 $dev1
-vgremove $vg1
-vgremove $vg2
+vgremove $vg1 $vg2
 
 # vgsplit accepts new vg as destination of split
 # lvm1 -- bz244792
 vgcreate -M$mdatype $vg1 $(cat DEVICES)
 vgsplit $vg1 $vg2 $dev1 1>err
 grep "New volume group \"$vg2\" successfully split from \"$vg1\"" err 
-vgremove $vg1 
-vgremove $vg2
+vgremove $vg1 $vg2
 
 # vgsplit accepts existing vg as destination of split
 vgcreate -M$mdatype $vg1 $dev1 $dev2 
 vgcreate -M$mdatype $vg2 $dev3 $dev4 
 vgsplit $vg1 $vg2 $dev1 1>err
 grep "Existing volume group \"$vg2\" successfully split from \"$vg1\"" err 
-vgremove $vg1 
-vgremove $vg2
+vgremove $vg1 $vg2
 
 # vgsplit accepts --maxphysicalvolumes 128 on new VG
 vgcreate -M$mdatype $vg1 $dev1 $dev2 
 vgsplit --maxphysicalvolumes 128 $vg1 $vg2 $dev1 
 check vg_field $vg2 max_pv 128 
-vgremove $vg1 
-vgremove $vg2
+vgremove $vg1 $vg2
 
 # vgsplit accepts --maxlogicalvolumes 128 on new VG
 vgcreate -M$mdatype $vg1 $dev1 $dev2 
 vgsplit --maxlogicalvolumes 128 $vg1 $vg2 $dev1 
 check vg_field $vg2 max_lv 128 
-vgremove $vg1 
-vgremove $vg2
+vgremove $vg1 $vg2
 
 # vgsplit rejects split because max_pv of destination would be exceeded
 vgcreate -M$mdatype --maxphysicalvolumes 2 $vg1 $dev1 $dev2
 vgcreate -M$mdatype --maxphysicalvolumes 2 $vg2 $dev3 $dev4
 not vgsplit $vg1 $vg2 $dev1 2>err;
 grep "^  Maximum number of physical volumes (2) exceeded" err
-vgremove $vg2
-vgremove $vg1
+vgremove $vg1 $vg2
 
 # vgsplit rejects split because maxphysicalvolumes given with existing vg
 vgcreate -M$mdatype --maxphysicalvolumes 2 $vg1 $dev1 $dev2 
 vgcreate -M$mdatype --maxphysicalvolumes 2 $vg2 $dev3 $dev4 
 not vgsplit --maxphysicalvolumes 2 $vg1 $vg2 $dev1 2>err;
 grep "^  Volume group \"$vg2\" exists, but new VG option specified" err 
-vgremove $vg2 
-vgremove $vg1
+vgremove $vg1 $vg2
 
 # vgsplit rejects split because maxlogicalvolumes given with existing vg
 vgcreate -M$mdatype --maxlogicalvolumes 2 $vg1 $dev1 $dev2 
 vgcreate -M$mdatype --maxlogicalvolumes 2 $vg2 $dev3 $dev4 
 not vgsplit --maxlogicalvolumes 2 $vg1 $vg2 $dev1 2>err
 grep "^  Volume group \"$vg2\" exists, but new VG option specified" err 
-vgremove $vg2 
-vgremove $vg1
+vgremove $vg1 $vg2
 
 # vgsplit rejects split because alloc given with existing vg
 vgcreate -M$mdatype --alloc cling $vg1 $dev1 $dev2 
 vgcreate -M$mdatype --alloc cling $vg2 $dev3 $dev4 
 not vgsplit --alloc cling $vg1 $vg2 $dev1 2>err;
 grep "^  Volume group \"$vg2\" exists, but new VG option specified" err 
-vgremove $vg2 
-vgremove $vg1
+vgremove $vg1 $vg2
 
 # vgsplit rejects split because clustered given with existing vg
 vgcreate -M$mdatype --clustered n $vg1 $dev1 $dev2 
 vgcreate -M$mdatype --clustered n $vg2 $dev3 $dev4 
 not vgsplit --clustered n $vg1 $vg2 $dev1 2>err
 grep "^  Volume group \"$vg2\" exists, but new VG option specified" err 
-vgremove $vg2 
-vgremove $vg1
+vgremove $vg1 $vg2
 
 # vgsplit rejects vg with active lv
 pvcreate -M$mdatype -ff $dev3 $dev4 
@@ -108,8 +98,7 @@
 lvcreate -l 4 -n $lv1 $vg1 
 not vgsplit $vg1 $vg2 $dev1 2>err;
 grep "^  Logical volumes in \"$vg1\" must be inactive\$" err 
-vgremove -f $vg2 
-vgremove -f $vg1
+vgremove -f $vg1 $vg2
 
 # vgsplit rejects split because max_lv is exceeded
 vgcreate -M$mdatype --maxlogicalvolumes 2 $vg1 $dev1 $dev2 
@@ -117,12 +106,10 @@
 lvcreate -l 4 -n $lv1 $vg1 
 lvcreate -l 4 -n $lv2 $vg1 
 lvcreate -l 4 -n $lv3 $vg2 
-vgchange -an $vg1 
-vgchange -an $vg2 
+vgchange -an $vg1 $vg2
 not vgsplit $vg1 $vg2 $dev1 2>err;
 grep "^  Maximum number of logical volumes (2) exceeded" err 
-vgremove -f $vg2 
-vgremove -f $vg1
+vgremove -f $vg1 $vg2
 
 # vgsplit verify default - max_lv attribute from new VG is same as source VG" \
 vgcreate -M$mdatype $vg1 $dev1 $dev2 
@@ -130,8 +117,7 @@
 vgchange -an $vg1 
 vgsplit $vg1 $vg2 $dev1 
 check compare_vg_field $vg1 $vg2 max_lv 
-vgremove -f $vg2 
-vgremove -f $vg1
+vgremove -f $vg1 $vg2
 
 # vgsplit verify default - max_pv attribute from new VG is same as source VG" \
 vgcreate -M$mdatype $vg1 $dev1 $dev2 
@@ -139,8 +125,7 @@
 vgchange -an $vg1 
 vgsplit $vg1 $vg2 $dev1 
 check compare_vg_field $vg1 $vg2 max_pv 
-vgremove -f $vg2 
-vgremove -f $vg1
+vgremove -f $vg1 $vg2
 
 # vgsplit verify default - vg_fmt attribute from new VG is same as source VG" \
 vgcreate -M$mdatype $vg1 $dev1 $dev2 
@@ -148,8 +133,7 @@
 vgchange -an $vg1 
 vgsplit $vg1 $vg2 $dev1 
 check compare_vg_field $vg1 $vg2 vg_fmt 
-vgremove -f $vg2 
-vgremove -f $vg1
+vgremove -f $vg2 $vg1
 
 # vgsplit rejects split because PV not in VG
 vgcreate -M$mdatype $vg1 $dev1 $dev2 
@@ -158,8 +142,7 @@
 lvcreate -l 4 -n $lv2 $vg1 
 vgchange -an $vg1 
 not vgsplit $vg1 $vg2 $dev3 2>err;
-vgremove -f $vg2 
-vgremove -f $vg1
+vgremove -f $vg2 $vg1
 done
 
 # ONLY LVM2 metadata
@@ -182,6 +165,4 @@
 vgcreate $vg2 $dev1 $dev2 
 not vgsplit $vg1 $vg2 $dev3 2>err;
 grep "^  Metadata types differ" err 
-vgremove $vg2 
-vgremove $vg1
-
+vgremove $vg1 $vg2


