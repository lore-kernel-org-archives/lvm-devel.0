From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 28 Dec 2009 18:33:05 -0000
Subject: LVM2/test t-lvconvert-repair.sh t-lvcreate-ope ...
Message-ID: <20091228183305.16103.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-12-28 18:33:04

Modified files:
	test           : t-lvconvert-repair.sh t-lvcreate-operation.sh 
	                 t-lvcreate-pvtags.sh t-metadata.sh 
	                 t-pvmove-basic.sh t-read-ahead.sh 
	                 t-vgcreate-usage.sh t-vgmerge-operation.sh 
	                 t-vgmerge-usage.sh t-vgreduce-usage.sh 
	                 t-vgsplit-operation.sh test-utils.sh 

Log message:
	Explicitly use non-clustered vgcreate in test.
	(So the tests can run under cluster locking and do not require
	cluster mirror or snapshots.)
	
	Add vgscan before block device readahead change
	(flush long running process - clvmd - dev cache.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-repair.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvcreate-operation.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvcreate-pvtags.sh.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-metadata.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvmove-basic.sh.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-read-ahead.sh.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgcreate-usage.sh.diff?cvsroot=lvm2&r1=1.13&r2=1.14
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgmerge-operation.sh.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgmerge-usage.sh.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgreduce-usage.sh.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgsplit-operation.sh.diff?cvsroot=lvm2&r1=1.23&r2=1.24
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/test-utils.sh.diff?cvsroot=lvm2&r1=1.15&r2=1.16

--- LVM2/test/t-lvconvert-repair.sh	2009/12/17 15:38:29	1.3
+++ LVM2/test/t-lvconvert-repair.sh	2009/12/28 18:33:04	1.4
@@ -25,7 +25,7 @@
 lvchange -a n $vg/3way
 
 vgremove -ff $vg
-vgcreate $vg $dev1 $dev2 $dev3 $dev4
+vgcreate -c n $vg $dev1 $dev2 $dev3 $dev4
 
 lvcreate -m 2 -L 1 -n 4way $vg
 disable_dev $dev1 $dev2
@@ -39,7 +39,7 @@
 # fail single devices
 
 vgremove -ff $vg
-vgcreate $vg $dev1 $dev2 $dev3
+vgcreate -c n $vg $dev1 $dev2 $dev3
 
 lvcreate -m 1 -L 1 -n mirror $vg
 
--- LVM2/test/t-lvcreate-operation.sh	2008/11/11 15:29:24	1.1
+++ LVM2/test/t-lvcreate-operation.sh	2009/12/28 18:33:04	1.2
@@ -23,7 +23,7 @@
 
 aux prepare_pvs 2
 aux pvcreate --metadatacopies 0 $dev1
-aux vgcreate $vg $devs
+aux vgcreate -c n $vg $devs
 
 #COMM create snapshots of LVs on --metadatacopies 0 PV (bz450651)
 lvcreate -n$lv1 -l4 $vg $dev1
--- LVM2/test/t-lvcreate-pvtags.sh	2008/11/10 12:43:35	1.5
+++ LVM2/test/t-lvcreate-pvtags.sh	2009/12/28 18:33:04	1.6
@@ -14,7 +14,7 @@
 # not required, just testing
 aux pvcreate --metadatacopies 0 $dev1
 
-vgcreate $vg $devs
+vgcreate -c n $vg $devs
 pvchange --addtag fast $devs
 
 # 3 stripes with 3 PVs (selected by tag, @fast) is fine
--- LVM2/test/t-metadata.sh	2008/11/11 15:46:15	1.3
+++ LVM2/test/t-metadata.sh	2009/12/28 18:33:04	1.4
@@ -32,7 +32,7 @@
 for mdacp in 1 0; do
 	pvcreate --metadatacopies $mdacp $devs
 	pvcreate $dev1
-	vgcreate $vg $devs
+	vgcreate -c n $vg $devs
 	lvcreate -n $lv1 -l 2 -i5 -I256 $vg
 	lvcreate -n $lv2 -m2 -l 2  $vg
 	#lvchange -an $vg
@@ -51,5 +51,5 @@
 pvcreate -M1 $dev1
 pvcreate -M1 $dev2
 pvcreate -M1 $dev3
-vgcreate -M1 $vg $dev1 $dev2 $dev3
+vgcreate -M1 -c n $vg $dev1 $dev2 $dev3
 pvchange --uuid $dev1
--- LVM2/test/t-pvmove-basic.sh	2009/05/19 09:51:03	1.5
+++ LVM2/test/t-pvmove-basic.sh	2009/12/28 18:33:04	1.6
@@ -366,7 +366,7 @@
 vgremove -ff $vg
 pvcreate $devs
 pvcreate --metadatacopies 0 $dev1 $dev2
-vgcreate $vg $devs
+vgcreate -c n $vg $devs
 lvcreate -l4 -n $lv1 $vg $dev1
 pvmove $dev1
 
--- LVM2/test/t-read-ahead.sh	2009/09/30 16:13:53	1.9
+++ LVM2/test/t-read-ahead.sh	2009/12/28 18:33:04	1.10
@@ -45,6 +45,7 @@
 
 #COMM "read ahead is properly inherited from underlying PV"
 blockdev --setra 768 $dev1
+vgscan
 lvcreate -n $lv -L4m $vg $dev1
 test $(blockdev --getra $G_dev_/$vg/$lv) -eq 768
 lvremove -ff $vg
--- LVM2/test/t-vgcreate-usage.sh	2009/10/31 16:43:07	1.13
+++ LVM2/test/t-vgcreate-usage.sh	2009/12/28 18:33:04	1.14
@@ -18,7 +18,7 @@
 pvcreate --metadatacopies 0 $dev3
 
 #COMM 'vgcreate accepts 8.00m physicalextentsize for VG'
-vgcreate $vg --physicalextentsize 8.00m $dev1 $dev2
+vgcreate -c n $vg --physicalextentsize 8.00m $dev1 $dev2
 check_vg_field_ $vg vg_extent_size 8.00m
 vgremove $vg
 # try vgck and to remove it again - should fail (but not segfault)
@@ -26,31 +26,31 @@
 not vgck $vg
 
 #COMM 'vgcreate accepts smaller (128) maxlogicalvolumes for VG'
-vgcreate $vg --maxlogicalvolumes 128 $dev1 $dev2 
+vgcreate -c n $vg --maxlogicalvolumes 128 $dev1 $dev2 
 check_vg_field_ $vg max_lv 128 
 vgremove $vg
 
 #COMM 'vgcreate accepts smaller (128) maxphysicalvolumes for VG'
-vgcreate $vg --maxphysicalvolumes 128 $dev1 $dev2
+vgcreate -c n $vg --maxphysicalvolumes 128 $dev1 $dev2
 check_vg_field_ $vg max_pv 128
 vgremove $vg
 
 #COMM 'vgcreate rejects a zero physical extent size'
-not vgcreate --physicalextentsize 0 $vg $dev1 $dev2 2>err
+not vgcreate -c n --physicalextentsize 0 $vg $dev1 $dev2 2>err
 grep "^  Physical extent size may not be zero\$" err
 
 #COMM 'vgcreate rejects "inherit" allocation policy'
-not vgcreate --alloc inherit $vg $dev1 $dev2 2>err
+not vgcreate -c n --alloc inherit $vg $dev1 $dev2 2>err
 grep "^  Volume Group allocation policy cannot inherit from anything\$" err
 
 #COMM 'vgcreate rejects vgname "."'
 vginvalid=.; 
-not vgcreate $vginvalid $dev1 $dev2 2>err
+not vgcreate -c n $vginvalid $dev1 $dev2 2>err
 grep "New volume group name \"$vginvalid\" is invalid\$" err
 
 #COMM 'vgcreate rejects vgname greater than 128 characters'
 vginvalid=thisnameisridiculouslylongtotestvalidationcodecheckingmaximumsizethisiswhathappenswhenprogrammersgetboredandorarenotcreativedonttrythisathome
-not vgcreate $vginvalid $dev1 $dev2 2>err
+not vgcreate -c n $vginvalid $dev1 $dev2 2>err
 grep "New volume group name \"$vginvalid\" is invalid\$" err
 
 #COMM 'vgcreate rejects already existing vgname "/tmp/$vg"'
@@ -59,29 +59,29 @@
 #grep "New volume group name \"$vg\" is invalid\$" err
 
 #COMM "vgcreate rejects repeated invocation (run 2 times) (bz178216)"
-vgcreate $vg $dev1 $dev2
-not vgcreate $vg $dev1 $dev2
+vgcreate -c n $vg $dev1 $dev2
+not vgcreate -c n $vg $dev1 $dev2
 vgremove -ff $vg
 
 #COMM 'vgcreate rejects MaxLogicalVolumes > 255'
-not vgcreate --metadatatype 1 --maxlogicalvolumes 1024 $vg $dev1 $dev2 2>err
+not vgcreate -c n --metadatatype 1 --maxlogicalvolumes 1024 $vg $dev1 $dev2 2>err
 grep "^  Number of volumes may not exceed 255\$" err
 
 #COMM "vgcreate fails when the only pv has --metadatacopies 0"
-not vgcreate $vg $dev3
+not vgcreate -c n $vg $dev3
 
 # Test default (4MB) vg_extent_size as well as limits of extent_size
-not vgcreate --physicalextentsize 0k $vg $dev1 $dev2
-vgcreate --physicalextentsize 1k $vg $dev1 $dev2
+not vgcreate -c n --physicalextentsize 0k $vg $dev1 $dev2
+vgcreate -c n --physicalextentsize 1k $vg $dev1 $dev2
 check_vg_field_ $vg vg_extent_size 1.00k
 vgremove -ff $vg
-not vgcreate --physicalextentsize 3K $vg $dev1 $dev2
-not vgcreate --physicalextentsize 1024t $vg $dev1 $dev2
+not vgcreate -c n --physicalextentsize 3K $vg $dev1 $dev2
+not vgcreate -c n --physicalextentsize 1024t $vg $dev1 $dev2
 #not vgcreate --physicalextentsize 1T $vg $dev1 $dev2
 # FIXME: vgcreate allows physicalextentsize larger than pv size!
 
 # Test default max_lv, max_pv, extent_size, alloc_policy, clustered
-vgcreate $vg $dev1 $dev2
+vgcreate -c n $vg $dev1 $dev2
 check_vg_field_ $vg vg_extent_size 4.00m
 check_vg_field_ $vg max_lv 0
 check_vg_field_ $vg max_pv 0
@@ -92,14 +92,14 @@
 # --force, --yes, --metadata{size|copies|type}, --zero
 # --dataalignment[offset]
 pvremove $dev1 $dev2
-vgcreate --force --yes --zero y $vg $dev1 $dev2
+vgcreate -c n --force --yes --zero y $vg $dev1 $dev2
 vgremove -f $vg
 pvremove -f $dev1
 
 for i in 0 1 2 3
 do
 # vgcreate (lvm2) succeeds writing LVM label at sector $i
-    vgcreate --labelsector $i $vg $dev1
+    vgcreate -c n --labelsector $i $vg $dev1
     dd if=$dev1 bs=512 skip=$i count=1 2>/dev/null | strings | grep -q LABELONE;
     vgremove -f $vg
     pvremove -f $dev1
@@ -108,14 +108,14 @@
 # pvmetadatacopies
 for i in 1 2
 do
-    vgcreate --pvmetadatacopies $i $vg $dev1
+    vgcreate -c n --pvmetadatacopies $i $vg $dev1
     check_pv_field_ $dev1 pv_mda_count $i
     vgremove -f $vg
     pvremove -f $dev1
 done
-not vgcreate --metadatacopies 0 $vg $dev1
+not vgcreate -c n --metadatacopies 0 $vg $dev1
 pvcreate --metadatacopies 1 $dev2
-vgcreate --pvmetadatacopies 0 $vg $dev1 $dev2
+vgcreate -c n --pvmetadatacopies 0 $vg $dev1 $dev2
 check_pv_field_ $dev1 pv_mda_count 0
 check_pv_field_ $dev2 pv_mda_count 1
 vgremove -f $vg
@@ -123,7 +123,7 @@
 
 # metadatasize, dataalignment, dataalignmentoffset
 #COMM 'pvcreate sets data offset next to mda area'
-vgcreate --metadatasize 100k --dataalignment 100k $vg $dev1
+vgcreate -c n --metadatasize 100k --dataalignment 100k $vg $dev1
 check_pv_field_ $dev1 pe_start 200.00k
 vgremove -f $vg
 pvremove -f $dev1
@@ -131,7 +131,7 @@
 # data area is aligned to 64k by default,
 # data area start is shifted by the specified alignment_offset
 pv_align="195.50k"
-vgcreate --metadatasize 128k --dataalignmentoffset 7s $vg $dev1
+vgcreate -c n --metadatasize 128k --dataalignmentoffset 7s $vg $dev1
 check_pv_field_ $dev1 pe_start $pv_align
 vgremove -f $vg
 pvremove -f $dev1
@@ -139,21 +139,21 @@
 # metadatatype
 for i in 1 2
 do
-    vgcreate -M $i $vg $dev1
+    vgcreate -c n -M $i $vg $dev1
     check_vg_field_ $vg vg_fmt lvm$i
     vgremove -f $vg
     pvremove -f $dev1
 done
 
 # vgcreate fails if pv belongs to existing vg
-vgcreate $vg1 $dev1 $dev2
+vgcreate -c n $vg1 $dev1 $dev2
 not vgcreate $vg2 $dev2
 vgremove -f $vg1
 pvremove -f $dev1 $dev2
 
 # all PVs exist in the VG after created
 pvcreate $dev1
-vgcreate $vg1 $dev1 $dev2 $dev3
+vgcreate -c n $vg1 $dev1 $dev2 $dev3
 check_pv_field_ $dev1 vg_name $vg1
 check_pv_field_ $dev2 vg_name $vg1
 check_pv_field_ $dev3 vg_name $vg1
--- LVM2/test/t-vgmerge-operation.sh	2008/11/10 12:41:52	1.5
+++ LVM2/test/t-vgmerge-operation.sh	2009/12/28 18:33:04	1.6
@@ -16,8 +16,8 @@
 aux prepare_pvs 4 64
 
 # 'vgmerge succeeds with single linear LV in source VG'
-vgcreate $vg1 $dev1 $dev2 
-vgcreate $vg2 $dev3 $dev4 
+vgcreate -c n $vg1 $dev1 $dev2 
+vgcreate -c n $vg2 $dev3 $dev4 
 lvcreate -l 4 -n $lv1 $vg1 $dev1 
 vgchange -an $vg1 
 vg_validate_pvlv_counts_ $vg1 2 1 0 
@@ -27,8 +27,8 @@
 vgremove -f $vg2
 
 # 'vgmerge succeeds with single linear LV in source and destination VG'
-vgcreate $vg1 $dev1 $dev2 
-vgcreate $vg2 $dev3 $dev4 
+vgcreate -c n $vg1 $dev1 $dev2 
+vgcreate -c n $vg2 $dev3 $dev4 
 lvcreate -l 4 -n $lv1 $vg1 
 lvcreate -l 4 -n $lv2 $vg2 
 vgchange -an $vg1 
@@ -40,8 +40,8 @@
 vgremove -f $vg2
 
 # 'vgmerge succeeds with linear LV + snapshots in source VG'
-vgcreate $vg1 $dev1 $dev2 
-vgcreate $vg2 $dev3 $dev4 
+vgcreate -c n $vg1 $dev1 $dev2 
+vgcreate -c n $vg2 $dev3 $dev4 
 lvcreate -l 16 -n $lv1 $vg1 
 lvcreate -l 4 -s -n $lv2 $vg1/$lv1 
 vgchange -an $vg1 
@@ -53,8 +53,8 @@
 vgremove -f $vg2
 
 # 'vgmerge succeeds with mirrored LV in source VG'
-vgcreate $vg1 $dev1 $dev2 $dev3 
-vgcreate $vg2 $dev4 
+vgcreate -c n $vg1 $dev1 $dev2 $dev3 
+vgcreate -c n $vg2 $dev4 
 lvcreate -l 4 -n $lv1 -m1 $vg1 
 vgchange -an $vg1 
 vg_validate_pvlv_counts_ $vg1 3 1 0 
@@ -65,8 +65,8 @@
 vgremove -f $vg2
 
 # 'vgmerge rejects LV name collision'
-vgcreate $vg1 $dev1 $dev2
-vgcreate $vg2 $dev3 $dev4
+vgcreate -c n $vg1 $dev1 $dev2
+vgcreate -c n $vg2 $dev3 $dev4
 lvcreate -l 4 -n $lv1 $vg1
 lvcreate -l 4 -n $lv1 $vg2
 vgchange -an $vg1
--- LVM2/test/t-vgmerge-usage.sh	2009/09/02 18:31:11	1.6
+++ LVM2/test/t-vgmerge-usage.sh	2009/12/28 18:33:04	1.7
@@ -17,34 +17,34 @@
 
 # 'vgmerge normal operation'
 # ensure ordering does not matter
-vgcreate $vg1 $dev1 $dev2 
-vgcreate $vg2 $dev3 $dev4 
+vgcreate  $vg1 $dev1 $dev2 
+vgcreate  $vg2 $dev3 $dev4 
 vgmerge $vg1 $vg2 
 vgremove $vg1
-vgcreate $vg2 $dev1 $dev2
-vgcreate $vg1 $dev3 $dev4
+vgcreate -c n $vg2 $dev1 $dev2
+vgcreate -c n $vg1 $dev3 $dev4
 vgmerge $vg2 $vg1
 vgremove $vg2
 
 # 'vgmerge rejects duplicate vg name'
-vgcreate $vg1 $dev1 $dev2 
-vgcreate $vg2 $dev3 $dev4 
+vgcreate  $vg1 $dev1 $dev2 
+vgcreate  $vg2 $dev3 $dev4 
 not vgmerge $vg1 $vg1 2>err
 grep "^  Duplicate volume group name \"$vg1\"\$" err 
 vgremove $vg2 
 vgremove $vg1
 
 # 'vgmerge rejects vgs with incompatible extent_size'
-vgcreate --physicalextentsize 4M $vg1 $dev1 $dev2 
-vgcreate --physicalextentsize 8M $vg2 $dev3 $dev4 
+vgcreate  --physicalextentsize 4M $vg1 $dev1 $dev2 
+vgcreate  --physicalextentsize 8M $vg2 $dev3 $dev4 
 not vgmerge $vg1 $vg2 2>err
 grep "^  Extent sizes differ" err 
 vgremove $vg2 
 vgremove $vg1
 
 # 'vgmerge rejects vgmerge because max_pv is exceeded'
-vgcreate --maxphysicalvolumes 2 $vg1 $dev1 $dev2 
-vgcreate --maxphysicalvolumes 2 $vg2 $dev3 $dev4 
+vgcreate  --maxphysicalvolumes 2 $vg1 $dev1 $dev2 
+vgcreate  --maxphysicalvolumes 2 $vg2 $dev3 $dev4 
 not vgmerge $vg1 $vg2 2>err
 grep "^  Maximum number of physical volumes (2) exceeded" err 
 vgremove $vg2 
@@ -71,4 +71,3 @@
 grep "^  Maximum number of logical volumes (2) exceeded" err 
 vgremove -f $vg2 
 vgremove -f $vg1
-
--- LVM2/test/t-vgreduce-usage.sh	2008/11/10 12:43:35	1.5
+++ LVM2/test/t-vgreduce-usage.sh	2009/12/28 18:33:04	1.6
@@ -19,18 +19,18 @@
     pvcreate -M$mdatype $dev1 $dev2 
 
     # (lvm$mdatype) vgreduce removes only the specified pv from vg (bz427382)" '
-    vgcreate -M$mdatype $vg1 $dev1 $dev2
+    vgcreate -c n -M$mdatype $vg1 $dev1 $dev2
     vgreduce $vg1 $dev1
     check_pv_field_ $dev2 vg_name $vg1
     vgremove -f $vg1
 
     # (lvm$mdatype) vgreduce rejects removing the last pv (--all)
-    vgcreate -M$mdatype $vg1 $dev1 $dev2
+    vgcreate -c n -M$mdatype $vg1 $dev1 $dev2
     not vgreduce --all $vg1
     vgremove -f $vg1
 
     # (lvm$mdatype) vgreduce rejects removing the last pv
-    vgcreate -M$mdatype $vg1 $dev1 $dev2
+    vgcreate -c n -M$mdatype $vg1 $dev1 $dev2
     not vgreduce $vg1 $dev1 $dev2
     vgremove -f $vg1
 
@@ -44,13 +44,13 @@
 pvcreate --metadatacopies 0 -M$mdatype $dev3 $dev4
 
 # (lvm$mdatype) vgreduce rejects removing pv with the last mda copy (bz247448)
-vgcreate -M$mdatype $vg1 $dev1 $dev3
+vgcreate -c n -M$mdatype $vg1 $dev1 $dev3
 not vgreduce $vg1 $dev1
 vgremove -f $vg1
 
 #COMM "(lvm$mdatype) vgreduce --removemissing --force repares to linear (bz221921)"
 # (lvm$mdatype) setup: create mirror & damage one pv
-vgcreate -M$mdatype $vg1 $dev1 $dev2 $dev3
+vgcreate -c n -M$mdatype $vg1 $dev1 $dev2 $dev3
 lvcreate -n $lv1 -m1 -l 4 $vg1
 lvcreate -n $lv2  -l 4 $vg1 $dev2
 lvcreate -n $lv3 -l 4 $vg1 $dev3
@@ -66,7 +66,7 @@
 
 #COMM "vgreduce rejects --removemissing --mirrorsonly --force when nonmirror lv lost too"
 # (lvm$mdatype) setup: create mirror + linear lvs
-vgcreate -M$mdatype $vg1 $devs
+vgcreate -c n -M$mdatype $vg1 $devs
 lvcreate -n $lv2 -l 4 $vg1
 lvcreate -m1 -n $lv1 -l 4 $vg1 $dev1 $dev2 $dev3
 lvcreate -n $lv3 -l 4 $vg1 $dev3
@@ -76,7 +76,7 @@
 aux disable_dev $dev1
 #pvcreate -ff -y $dev1
 # vgreduce rejects --removemissing --mirrorsonly --force when nonmirror lv lost too
-not vgreduce --removemissing --mirrorsonly --force $vg1
+not vgreduce -c n --removemissing --mirrorsonly --force $vg1
 
 aux enable_dev $dev1
 
--- LVM2/test/t-vgsplit-operation.sh	2008/09/30 18:29:10	1.23
+++ LVM2/test/t-vgsplit-operation.sh	2009/12/28 18:33:04	1.24
@@ -75,9 +75,9 @@
 		vgremove -f $vg2
 
 COMM "vgsplit correctly splits mirror LV into $i VG ($j args)" 
-		vgcreate $vg1 $dev1 $dev2 $dev3 
+		vgcreate -c n $vg1 $dev1 $dev2 $dev3 
 		if [ $i = existing ]; then
-		  vgcreate $vg2 $dev4
+		  vgcreate -c n $vg2 $dev4
 		fi 
 		lvcreate -l 64 -m1 -n $lv1 $vg1 $dev1 $dev2 $dev3 
 		vgchange -an $vg1 
@@ -95,9 +95,9 @@
 		vgremove -f $vg2
 
 COMM "vgsplit correctly splits origin and snapshot LV into $i VG ($j args)" 
-		vgcreate $vg1 $dev1 $dev2 
+		vgcreate -c n $vg1 $dev1 $dev2 
 		if [ $i = existing ]; then
-		  vgcreate $vg2 $dev3 $dev4
+		  vgcreate -c n $vg2 $dev3 $dev4
 		fi 
 		lvcreate -l 64 -i 2 -n $lv1 $vg1 $dev1 $dev2 
 		lvcreate -l 4 -i 2 -s -n $lv2 $vg1/$lv1 
@@ -117,9 +117,9 @@
 		vgremove -f $vg2
 
 COMM "vgsplit correctly splits linear LV but not snap+origin LV into $i VG ($j args)" 
-		vgcreate $vg1 $dev1 $dev2 
+		vgcreate -c n $vg1 $dev1 $dev2 
 		if [ $i = existing ]; then
-		  vgcreate $vg2 $dev3
+		  vgcreate -c n $vg2 $dev3
 		fi 
 		lvcreate -l 64 -i 2 -n $lv1 $vg1 
 		lvcreate -l 4 -i 2 -s -n $lv2 $vg1/$lv1 
@@ -145,9 +145,9 @@
 		vgremove -f $vg2
 
 COMM "vgsplit correctly splits linear LV but not mirror LV into $i VG ($j args)" 
-		vgcreate $vg1 $dev1 $dev2 $dev3 
+		vgcreate -c n $vg1 $dev1 $dev2 $dev3 
 		if [ $i = existing ]; then
-		  vgcreate $vg2 $dev5
+		  vgcreate -c n $vg2 $dev5
 		fi 
 		lvcreate -l 64 -m1 -n $lv1 $vg1 $dev1 $dev2 $dev3 
 		vgextend $vg1 $dev4 
@@ -193,7 +193,7 @@
 vgremove -ff $vg1
 
 COMM "vgsplit fails splitting one LV with 2 snapshots, only origin LV specified" 
-vgcreate $vg1 $dev1 $dev2 $dev3 $dev4 
+vgcreate -c n $vg1 $dev1 $dev2 $dev3 $dev4 
 lvcreate -l 16 -n $lv1 $vg1 $dev1 $dev2 
 lvcreate -l 4 -n $lv2 -s $vg1/$lv1 
 lvcreate -l 4 -n $lv3 -s $vg1/$lv1 
@@ -206,7 +206,7 @@
 vgremove -ff $vg1
 
 COMM "vgsplit fails splitting one LV with 2 snapshots, only snapshot LV specified" 
-vgcreate $vg1 $dev1 $dev2 $dev3 $dev4 
+vgcreate -c n $vg1 $dev1 $dev2 $dev3 $dev4 
 lvcreate -l 16 -n $lv1 $vg1 $dev1 $dev2 
 lvcreate -l 4 -n $lv2 -s $vg1/$lv1 
 lvcreate -l 4 -n $lv3 -s $vg1/$lv1 
@@ -219,7 +219,7 @@
 vgremove -ff $vg1
 
 COMM "vgsplit fails splitting one mirror LV, only one PV specified" 
-vgcreate $vg1 $dev1 $dev2 $dev3 $dev4 
+vgcreate -c n $vg1 $dev1 $dev2 $dev3 $dev4 
 lvcreate -l 16 -n $lv1 -m1 $vg1 $dev1 $dev2 $dev3 
 vg_validate_pvlv_counts_ $vg1 4 1 0 
 vgchange -an $vg1 
@@ -227,7 +227,7 @@
 vgremove -ff $vg1
 
 COMM "vgsplit fails splitting 1 mirror + 1 striped LV, only striped LV specified" 
-vgcreate $vg1 $dev1 $dev2 $dev3 $dev4 
+vgcreate -c n $vg1 $dev1 $dev2 $dev3 $dev4 
 lvcreate -l 16 -n $lv1 -m1 $vg1 $dev1 $dev2 $dev3 
 lvcreate -l 16 -n $lv2 -i 2 $vg1 $dev3 $dev4 
 vg_validate_pvlv_counts_ $vg1 4 2 0 
@@ -239,7 +239,7 @@
 # Verify vgsplit rejects active LVs only when active LVs involved in split
 #
 COMM "vgsplit fails, active mirror involved in split" 
-vgcreate $vg1 $dev1 $dev2 $dev3 $dev4 
+vgcreate -c n $vg1 $dev1 $dev2 $dev3 $dev4 
 lvcreate -l 16 -n $lv1 -m1 $vg1 $dev1 $dev2 $dev3 
 lvcreate -l 16 -n $lv2 $vg1 $dev4 
 lvchange -an $vg1/$lv2 
@@ -249,7 +249,7 @@
 vgremove -ff $vg1
 
 COMM "vgsplit succeeds, active mirror not involved in split" 
-vgcreate $vg1 $dev1 $dev2 $dev3 $dev4 
+vgcreate -c n $vg1 $dev1 $dev2 $dev3 $dev4 
 lvcreate -l 16 -n $lv1 -m1 $vg1 $dev1 $dev2 $dev3 
 lvcreate -l 16 -n $lv2 $vg1 $dev4 
 lvchange -an $vg1/$lv2 
@@ -261,7 +261,7 @@
 vgremove -ff $vg2
 
 COMM "vgsplit fails, active snapshot involved in split" 
-vgcreate $vg1 $dev1 $dev2 $dev3 $dev4 
+vgcreate -c n $vg1 $dev1 $dev2 $dev3 $dev4 
 lvcreate -l 64 -i 2 -n $lv1 $vg1 $dev1 $dev2 
 lvcreate -l 4 -i 2 -s -n $lv2 $vg1/$lv1 
 lvcreate -l 64 -i 2 -n $lv3 $vg1 $dev3 $dev4 
@@ -273,7 +273,7 @@
 vgremove -ff $vg1
 
 COMM "vgsplit succeeds, active snapshot not involved in split" 
-vgcreate $vg1 $dev1 $dev2 $dev3 
+vgcreate -c n $vg1 $dev1 $dev2 $dev3 
 lvcreate -l 64 -i 2 -n $lv1 $vg1 $dev1 $dev2 
 lvcreate -l 4 -s -n $lv2 $vg1/$lv1 
 vgextend $vg1 $dev4 
--- LVM2/test/test-utils.sh	2009/11/30 17:17:12	1.15
+++ LVM2/test/test-utils.sh	2009/12/28 18:33:04	1.16
@@ -174,7 +174,7 @@
 
 prepare_vg() {
 	prepare_pvs "$@"
-	vgcreate $vg $devs
+	vgcreate -c n $vg $devs
 }
 
 prepare_lvmconf() {


