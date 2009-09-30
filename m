From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 30 Sep 2009 16:13:54 -0000
Subject: LVM2/test t-lvcreate-usage.sh t-lvextend-perce ...
Message-ID: <20090930161354.31743.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-09-30 16:13:53

Modified files:
	test           : t-lvcreate-usage.sh 
	                 t-lvextend-percent-extents.sh 
	                 t-pvcreate-operation-md.sh t-pvcreate-usage.sh 
	                 t-read-ahead.sh t-vgcreate-usage.sh 

Log message:
	Update nightly tests to deal with unit changes.
	
	Now uppercase letters imply Si units, so use lowercase everywhere.
	We could stay with uppercase, but then we'd have to deal with rounding, etc.
	Also, some output / error messages change slightly (instead of "GB" we're
	now saying "GiB").
	One test enhancement might be to add some new tests for the units changes
	but for now let's just get the test back to passing.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvcreate-usage.sh.diff?cvsroot=lvm2&r1=1.15&r2=1.16
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvextend-percent-extents.sh.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvcreate-operation-md.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvcreate-usage.sh.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-read-ahead.sh.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgcreate-usage.sh.diff?cvsroot=lvm2&r1=1.9&r2=1.10

--- LVM2/test/t-lvcreate-usage.sh	2009/07/14 19:35:35	1.15
+++ LVM2/test/t-lvcreate-usage.sh	2009/09/30 16:13:53	1.16
@@ -25,35 +25,35 @@
 not lvremove -ff $vg/$lv
 
 # "lvcreate rejects a negative stripe_size"
-not lvcreate -L 64M -n $lv -i2 --stripesize -4 $vg 2>err;
+not lvcreate -L 64m -n $lv -i2 --stripesize -4 $vg 2>err;
 grep "^  Negative stripesize is invalid\$" err
 
 # 'lvcreate rejects a too-large stripesize'
-not lvcreate -L 64M -n $lv -i2 --stripesize 4294967291 $vg 2>err
-grep "^  Stripe size cannot be larger than 512.00 GB\$" err
+not lvcreate -L 64m -n $lv -i2 --stripesize 4294967291 $vg 2>err
+grep "^  Stripe size cannot be larger than" err
 
 # 'lvcreate w/single stripe succeeds with diagnostics to stdout' 
-lvcreate -L 64M -n $lv -i1 --stripesize 4 $vg >out 2>err 
+lvcreate -L 64m -n $lv -i1 --stripesize 4 $vg >out 2>err
 grep "^  Redundant stripes argument: default is 1\$" out 
 grep "^  Ignoring stripesize argument with single stripe\$" out 
 lvdisplay $vg 
 lvremove -ff $vg
 
 # 'lvcreate w/default (64KB) stripe size succeeds with diagnostics to stdout'
-lvcreate -L 64M -n $lv -i2 $vg > out
+lvcreate -L 64m -n $lv -i2 $vg > out
 grep "^  Using default stripesize" out 
 lvdisplay $vg 
-check_lv_field_ $vg/$lv stripesize "64.00K" 
+check_lv_field_ $vg/$lv stripesize "64.00k"
 lvremove -ff $vg
 
 # 'lvcreate rejects an invalid number of stripes' 
-not lvcreate -L 64M -n $lv -i129 $vg 2>err
+not lvcreate -L 64m -n $lv -i129 $vg 2>err
 grep "^  Number of stripes (129) must be between 1 and 128\$" err
 
 # The case on lvdisplay output is to verify that the LV was not created.
 # 'lvcreate rejects an invalid stripe size'
-not lvcreate -L 64M -n $lv -i2 --stripesize 3 $vg 2>err
-grep "^  Invalid stripe size 3\.00 KB\$" err
+not lvcreate -L 64m -n $lv -i2 --stripesize 3 $vg 2>err
+grep "^  Invalid stripe size" err
 case $(lvdisplay $vg) in "") true ;; *) false ;; esac
 
 # Setting max_lv works. (bz490298)
@@ -91,15 +91,15 @@
 # validate origin_size
 vgremove -ff $vg
 vgcreate -cn $vg $devs
-lvcreate -L 32M -n $lv1 $vg
-not lvcreate -L 8M -n $lv2 -s --chunksize 3K $vg/$lv1
-not lvcreate -L 8M -n $lv2 -s --chunksize 1024K $vg/$lv1
-lvcreate -L 8M -n $lv2 -s --chunksize 4K $vg/$lv1
-check_lv_field_ $vg/$lv2 chunk_size 4.00K
-check_lv_field_ $vg/$lv2 origin_size 32.00M
-lvcreate -L 8M -n $lv3 -s --chunksize 512K $vg/$lv1
-check_lv_field_ $vg/$lv3 chunk_size 512.00K
-check_lv_field_ $vg/$lv3 origin_size 32.00M
+lvcreate -L 32m -n $lv1 $vg
+not lvcreate -L 8m -n $lv2 -s --chunksize 3k $vg/$lv1
+not lvcreate -L 8m -n $lv2 -s --chunksize 1024k $vg/$lv1
+lvcreate -L 8m -n $lv2 -s --chunksize 4k $vg/$lv1
+check_lv_field_ $vg/$lv2 chunk_size 4.00k
+check_lv_field_ $vg/$lv2 origin_size 32.00m
+lvcreate -L 8m -n $lv3 -s --chunksize 512k $vg/$lv1
+check_lv_field_ $vg/$lv3 chunk_size 512.00k
+check_lv_field_ $vg/$lv3 origin_size 32.00m
 lvremove -ff $vg
 vgchange -l 0 $vg
 
@@ -107,21 +107,21 @@
 # - nonzero (bz186013)
 # - a power of 2 and a multiple of page size
 # - <= size of LV
-not lvcreate -L 32M -n $lv -R0 $vg 2>err
+not lvcreate -L 32m -n $lv -R0 $vg 2>err
 grep "Non-zero region size must be supplied." err
-not lvcreate -L 32M -n $lv -R 11k $vg
-not lvcreate -L 32M -n $lv -R 1k $vg
-lvcreate -L 32M -n $lv --regionsize 128M  -m 1 $vg
-check_lv_field_ $vg/$lv regionsize "32.00M"
+not lvcreate -L 32m -n $lv -R 11k $vg
+not lvcreate -L 32m -n $lv -R 1k $vg
+lvcreate -L 32m -n $lv --regionsize 128m  -m 1 $vg
+check_lv_field_ $vg/$lv regionsize "32.00m"
 lvremove -ff $vg
-lvcreate -L 32M -n $lv --regionsize 4M -m 1 $vg
-check_lv_field_ $vg/$lv regionsize "4.00M"
+lvcreate -L 32m -n $lv --regionsize 4m -m 1 $vg
+check_lv_field_ $vg/$lv regionsize "4.00m"
 lvremove -ff $vg
 
 # snapshot with virtual origin works
-lvcreate -s --virtualoriginsize 64M -L 32M -n $lv1 $vg
+lvcreate -s --virtualoriginsize 64m -L 32m -n $lv1 $vg
 lvrename $vg/$lv1 $vg/$lv2
-lvcreate -s --virtualoriginsize 64M -L 32M -n $lv1 $vg
+lvcreate -s --virtualoriginsize 64m -L 32m -n $lv1 $vg
 lvchange -a n $vg/$lv1
 lvremove $vg/$lv1
 lvremove -ff $vg
--- LVM2/test/t-lvextend-percent-extents.sh	2009/05/11 03:37:34	1.7
+++ LVM2/test/t-lvextend-percent-extents.sh	2009/09/30 16:13:53	1.8
@@ -15,14 +15,14 @@
 
 aux prepare_vg 2 128
 
-lvcreate -L 64M -n $lv $vg
+lvcreate -L 64m -n $lv $vg
 
 # 'lvextend rejects both size and extents without PVs'
-not lvextend -l 10 -L 64M $vg/$lv 2>err
+not lvextend -l 10 -L 64m $vg/$lv 2>err
 grep "^  Please specify either size or extents but not both.\$" err
 
 # 'lvextend rejects both size and extents with PVs'
-not lvextend -l 10 -L 64M $vg/$lv $dev1 2>err
+not lvextend -l 10 -L 64m $vg/$lv $dev1 2>err
 grep "^  Please specify either size or extents but not both.\$" err
 
 # 'lvextend accepts no size or extents but one PV - bz154691'
@@ -40,7 +40,7 @@
 
 # 'Reset LV to original size' 
 lvremove -f $vg/$lv 
-lvcreate -L 64M -n $lv $vg
+lvcreate -L 64m -n $lv $vg
 
 # 'lvextend accepts no size but extents 100%PVS and two PVs - bz154691'
 lvextend -l +100%PVS $vg/$lv $dev1 $dev2 >out
@@ -72,13 +72,13 @@
 create_pvs=`for i in $(seq 0 4 20); do echo -n "\$dev1:$i-$(($i + 1)) "; done` 
 lvremove -f $vg/$lv
 lvcreate -l 12 -n $lv $vg $create_pvs
-check_lv_field_ $vg/$lv lv_size "48.00M"
+check_lv_field_ $vg/$lv lv_size "48.00m"
 
 # 'lvextend with partially allocated PVs and extents 100%PVS with PE ranges' 
 extend_pvs=`for i in $(seq 0 6 18); do echo -n "\$dev1:$i-$(($i + 2)) "; done` 
 lvextend -l +100%PVS $vg/$lv $extend_pvs >out
 grep "^  Logical volume $lv successfully resized\$" out 
-check_lv_field_ $vg/$lv lv_size "72.00M"
+check_lv_field_ $vg/$lv lv_size "72.00m"
 
 # Simple seg_count validation; initially create the LV with half the # of
 # extents (should be 1 lv segment), extend it (should go to 2 segments),
@@ -89,7 +89,7 @@
 pe1=$(( $pe_count / 2 ))
 lvcreate -l $pe1 -n $lv $vg
 pesize=$(lvs -ovg_extent_size --units b --nosuffix --noheadings $vg/$lv)
-segsize=$(( $pe1 * $pesize / 1024 / 1024 ))M
+segsize=$(( $pe1 * $pesize / 1024 / 1024 ))m
 check_lv_field_ $vg/$lv seg_count 1
 check_lv_field_ $vg/$lv seg_start 0
 check_lv_field_ $vg/$lv seg_start_pe 0
--- LVM2/test/t-pvcreate-operation-md.sh	2009/09/13 19:28:00	1.2
+++ LVM2/test/t-pvcreate-operation-md.sh	2009/09/30 16:13:53	1.3
@@ -49,14 +49,14 @@
 
 # Test alignment of PV on MD without any MD-aware or topology-aware detection
 # - should treat $mddev just like any other block device
-pv_align="192.00K"
+pv_align="192.00k"
 pvcreate --metadatasize 128k \
     --config 'devices {md_chunk_alignment=0 data_alignment_detection=0 data_alignment_offset_detection=0}' \
     $mddev
 check_pv_field_ $mddev pe_start $pv_align
 
 # Test md_chunk_alignment independent of topology-aware detection
-pv_align="256.00K"
+pv_align="256.00k"
 pvcreate --metadatasize 128k \
     --config 'devices {data_alignment_detection=0 data_alignment_offset_detection=0}' \
     $mddev
@@ -67,7 +67,7 @@
 
 # Test newer topology-aware alignment detection
 if [ $linux_minor -gt 31 ]; then
-    pv_align="256.00K"
+    pv_align="256.00k"
     pvcreate --metadatasize 128k \
 	--config 'devices { md_chunk_alignment=0 }' $mddev
     check_pv_field_ $mddev pe_start $pv_align
@@ -100,12 +100,12 @@
 	alignment_offset=0
 
     if [ "$alignment_offset" = "512" ]; then
-	pv_align="256.50K"
+	pv_align="256.50k"
 	pvcreate --metadatasize 128k $mddev_p
 	check_pv_field_ $mddev_p pe_start $pv_align
 	pvremove $mddev_p
     elif [ "$alignment_offset" = "2048" ]; then
-	pv_align="258.00K"
+	pv_align="258.00k"
 	pvcreate --metadatasize 128k $mddev_p
 	check_pv_field_ $mddev_p pe_start $pv_align
 	pvremove $mddev_p
--- LVM2/test/t-pvcreate-usage.sh	2009/08/04 16:02:39	1.12
+++ LVM2/test/t-pvcreate-usage.sh	2009/09/30 16:13:53	1.13
@@ -31,8 +31,8 @@
 pvremove $dev1
 
 #Verify vg_mda_size is smaller pv_mda_size
-pvcreate --metadatasize 512K $dev1
-pvcreate --metadatasize 96K $dev2
+pvcreate --metadatasize 512k $dev1
+pvcreate --metadatasize 96k $dev2
 vgcreate $vg $dev1 $dev2
 compare_two_fields_ vgs $vg vg_mda_size pvs $dev2 pv_mda_size
 vgremove -ff $vg
@@ -81,33 +81,33 @@
 #COMM 'pvcreate basic dataalignment sanity checks'
 not pvcreate --dataalignment -1 $dev1
 not pvcreate -M 1 --dataalignment 1 $dev1
-not pvcreate --dataalignment 1E $dev1
+not pvcreate --dataalignment 1e $dev1
 
 #COMM 'pvcreate always rounded up to page size for start of device'
 #pvcreate --metadatacopies 0 --dataalignment 1 $dev1
 # amuse shell experts
-#check_pv_field_ $dev1 pe_start $(($(getconf PAGESIZE)/1024))".00K"
+#check_pv_field_ $dev1 pe_start $(($(getconf PAGESIZE)/1024))".00k"
 
 #COMM 'pvcreate sets data offset directly'
 pvcreate --dataalignment 512k $dev1
-check_pv_field_ $dev1 pe_start 512.00K
+check_pv_field_ $dev1 pe_start 512.00k
 
 #COMM 'vgcreate/vgremove do not modify data offset of existing PV'
 vgcreate $vg $dev1  --config 'devices { data_alignment = 1024 }'
-check_pv_field_ $dev1 pe_start 512.00K
+check_pv_field_ $dev1 pe_start 512.00k
 vgremove $vg --config 'devices { data_alignment = 1024 }'
-check_pv_field_ $dev1 pe_start 512.00K
+check_pv_field_ $dev1 pe_start 512.00k
 
 #COMM 'pvcreate sets data offset next to mda area'
 pvcreate --metadatasize 100k --dataalignment 100k $dev1
-check_pv_field_ $dev1 pe_start 200.00K
+check_pv_field_ $dev1 pe_start 200.00k
 
 # metadata area start is aligned according to pagesize
 # pagesize should be 64k or 4k ...
 if [ $PAGESIZE -eq 65536 ] ; then
-	pv_align="192.50K"
+	pv_align="192.50k"
 else
-	pv_align="133.00K"
+	pv_align="133.00k"
 fi
 
 pvcreate --metadatasize 128k --dataalignment 3.5k $dev1
@@ -118,7 +118,7 @@
 
 # data area is aligned to 64k by default,
 # data area start is shifted by the specified alignment_offset
-pv_align="195.50K"
+pv_align="195.50k"
 pvcreate --metadatasize 128k --dataalignmentoffset 7s $dev1
 check_pv_field_ $dev1 pe_start $pv_align
 
@@ -131,15 +131,15 @@
 #COMM 'pv with LVM1 compatible data alignment can be convereted'
 #compatible == LVM1_PE_ALIGN == 64k
 pvcreate --dataalignment 256k $dev1
-vgcreate -s 1M $vg $dev1
+vgcreate -s 1m $vg $dev1
 vgconvert -M1 $vg
 vgconvert -M2 $vg
-check_pv_field_ $dev1 pe_start 256.00K
+check_pv_field_ $dev1 pe_start 256.00k
 vgremove $vg
 
 #COMM 'pv with LVM1 incompatible data alignment cannot be convereted'
 pvcreate --dataalignment 10k $dev1
-vgcreate -s 1M $vg $dev1
+vgcreate -s 1m $vg $dev1
 not vgconvert -M1 $vg
 vgremove $vg
 
--- LVM2/test/t-read-ahead.sh	2009/06/06 16:40:39	1.8
+++ LVM2/test/t-read-ahead.sh	2009/09/30 16:13:53	1.9
@@ -45,7 +45,7 @@
 
 #COMM "read ahead is properly inherited from underlying PV"
 blockdev --setra 768 $dev1
-lvcreate -n $lv -L4M $vg $dev1
+lvcreate -n $lv -L4m $vg $dev1
 test $(blockdev --getra $G_dev_/$vg/$lv) -eq 768
 lvremove -ff $vg
 
@@ -56,6 +56,6 @@
 check_lv_field_ $vg/$lv lv_kernel_read_ahead -1
 lvchange -r 512 $vg/$lv
 lvchange -ay $vg/$lv
-check_lv_field_ $vg/$lv lv_read_ahead 256.00K
-check_lv_field_ $vg/$lv lv_kernel_read_ahead 256.00K
+check_lv_field_ $vg/$lv lv_read_ahead 256.00k
+check_lv_field_ $vg/$lv lv_kernel_read_ahead 256.00k
 lvremove -ff $vg
--- LVM2/test/t-vgcreate-usage.sh	2009/07/14 19:35:35	1.9
+++ LVM2/test/t-vgcreate-usage.sh	2009/09/30 16:13:53	1.10
@@ -17,9 +17,9 @@
 pvcreate $dev1 $dev2
 pvcreate --metadatacopies 0 $dev3
 
-#COMM 'vgcreate accepts 8.00M physicalextentsize for VG'
-vgcreate $vg --physicalextentsize 8.00M $dev1 $dev2 
-check_vg_field_ $vg vg_extent_size 8.00M 
+#COMM 'vgcreate accepts 8.00m physicalextentsize for VG'
+vgcreate $vg --physicalextentsize 8.00m $dev1 $dev2
+check_vg_field_ $vg vg_extent_size 8.00m
 vgremove $vg
 # try vgck and to remove it again - should fail (but not segfault)
 not vgremove $vg
@@ -71,18 +71,18 @@
 not vgcreate $vg $dev3
 
 # Test default (4MB) vg_extent_size as well as limits of extent_size
-not vgcreate --physicalextentsize 0K $vg $dev1 $dev2
-vgcreate --physicalextentsize 1K $vg $dev1 $dev2
-check_vg_field_ $vg vg_extent_size 1.00K
+not vgcreate --physicalextentsize 0k $vg $dev1 $dev2
+vgcreate --physicalextentsize 1k $vg $dev1 $dev2
+check_vg_field_ $vg vg_extent_size 1.00k
 vgremove -ff $vg
 not vgcreate --physicalextentsize 3K $vg $dev1 $dev2
-not vgcreate --physicalextentsize 1024T $vg $dev1 $dev2
+not vgcreate --physicalextentsize 1024t $vg $dev1 $dev2
 #not vgcreate --physicalextentsize 1T $vg $dev1 $dev2
 # FIXME: vgcreate allows physicalextentsize larger than pv size!
 
 # Test default max_lv, max_pv, extent_size, alloc_policy, clustered
 vgcreate $vg $dev1 $dev2
-check_vg_field_ $vg vg_extent_size 4.00M
+check_vg_field_ $vg vg_extent_size 4.00m
 check_vg_field_ $vg max_lv 0
 check_vg_field_ $vg max_pv 0
 check_vg_field_ $vg vg_attr "wz--n-"


