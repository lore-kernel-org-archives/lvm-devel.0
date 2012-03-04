From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 4 Mar 2012 16:02:20 -0000
Subject: LVM2/test/shell lvconvert-mirror-basic.sh lvco ...
Message-ID: <20120304160220.17351.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-04 16:02:19

Modified files:
	test/shell     : lvconvert-mirror-basic.sh lvconvert-mirror.sh 
	                 lvconvert-raid.sh lvconvert-repair.sh 
	                 lvcreate-raid.sh lvextend-snapshot-dmeventd.sh 
	                 pvmove-basic.sh vgsplit-operation.sh 

Log message:
	Speedup test run by a few minutes
	
	Reduce disc excercise for some test and focus on LVM testing by
	using smaller extent size.
	
	Reduce number of teardown_devs calls and use vg/lvremove instead.
	
	Don't sleep for seconds on pvmove.
	
	FIXME: shell/lvconvert-mirror-basic.sh seems to need more checking.
	Test fails for smalled extent size then 512k.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvconvert-mirror-basic.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvconvert-mirror.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvconvert-raid.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvconvert-repair.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvcreate-raid.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvextend-snapshot-dmeventd.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/pvmove-basic.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/vgsplit-operation.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/test/shell/lvconvert-mirror-basic.sh	2011/11/21 00:15:46	1.1
+++ LVM2/test/shell/lvconvert-mirror-basic.sh	2012/03/04 16:02:19	1.2
@@ -121,7 +121,8 @@
 	fi
 }
 
-aux prepare_vg 5 16
+aux prepare_pvs 5 5
+vgcreate -c n -s 128k $vg $(cat DEVICES)
 
 test_many() {
 	i=$1
--- LVM2/test/shell/lvconvert-mirror.sh	2012/03/02 00:08:48	1.3
+++ LVM2/test/shell/lvconvert-mirror.sh	2012/03/04 16:02:19	1.4
@@ -17,13 +17,16 @@
 }
 
 # convert from linear to 2-way mirror
-aux prepare_vg 5
+aux prepare_pvs 5 10
+# FIXME - test fails with extent size < 512k
+vgcreate -c n -s 512k $vg $(cat DEVICES)
+
 lvcreate -l2 -n $lv1 $vg $dev1
 lvconvert -i1 -m+1 $vg/$lv1 $dev2 $dev3:0-1
 check mirror $vg $lv1 $dev3
+lvremove -ff $vg
 
 # convert from 2-way mirror to linear
-aux prepare_vg 5
 lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1
 lvconvert -m-1 $vg/$lv1
 check linear $vg $lv1
@@ -35,14 +38,12 @@
 lvremove -ff $vg
 
 # convert from disklog to corelog, active
-aux prepare_vg 5
 lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1
 lvconvert -f --mirrorlog core $vg/$lv1
 check mirror $vg $lv1 core
 lvremove -ff $vg
 
 # convert from corelog to disklog, active
-aux prepare_vg 5
 lvcreate -l2 -m1 --mirrorlog core -n $lv1 $vg $dev1 $dev2
 lvconvert --mirrorlog disk $vg/$lv1 $dev3:0-1
 check mirror $vg $lv1 $dev3
@@ -50,7 +51,6 @@
 
 # bz192865: lvconvert log of an inactive mirror lv
 # convert from disklog to corelog, inactive
-aux prepare_vg 5
 lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1
 lvchange -an $vg/$lv1
 echo y | lvconvert -f --mirrorlog core $vg/$lv1
@@ -58,7 +58,6 @@
 lvremove -ff $vg
 
 # convert from corelog to disklog, inactive
-aux prepare_vg 5
 lvcreate -l2 -m1 --mirrorlog core -n $lv1 $vg $dev1 $dev2
 lvchange -an $vg/$lv1
 lvconvert --mirrorlog disk $vg/$lv1 $dev3:0-1
@@ -66,7 +65,6 @@
 lvremove -ff $vg
 
 # convert linear to 2-way mirror with 1 PV
-aux prepare_vg 5
 lvcreate -l2 -n $lv1 $vg $dev1
 not lvconvert -m+1 --mirrorlog core $vg/$lv1 $dev1
 lvremove -ff $vg
@@ -90,10 +88,10 @@
 lvconvert -m-1 $vg/$lv1 $dev2
 check linear $vg $lv1
 check lv_on $vg $lv1 $dev4
+lvremove -ff $vg
 
 # No parallel lvconverts on a single LV please
 
-aux prepare_vg 5
 lvcreate -l5 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0
 check mirror $vg $lv1
 check mirror_legs $vg $lv1 2
@@ -107,29 +105,29 @@
 check mirror $vg $lv1 $dev3
 check mirror_no_temporaries $vg $lv1
 check mirror_legs $vg $lv1 3
+lvremove -ff $vg
 
 # add 1 mirror to core log mirror, but
 #  implicitly keep log as 'core'
-aux prepare_vg 5
 lvcreate -l2 -m1 --mirrorlog core -n $lv1 $vg $dev1 $dev2
 lvconvert -m +1 -i1 $vg/$lv1
 
 check mirror $vg $lv1 core
 check mirror_no_temporaries $vg $lv1
 check mirror_legs $vg $lv1 3
+lvremove -ff $vg
 
 # remove 1 mirror from corelog'ed mirror; should retain 'core' log type
-aux prepare_vg 5
 lvcreate -l2 -m2 --corelog -n $lv1 $vg
 lvconvert -m -1 -i1 $vg/$lv1
 
 check mirror $vg $lv1 core
 check mirror_no_temporaries $vg $lv1
 check mirror_legs $vg $lv1 2
+lvremove -ff $vg
 
 # add 1 mirror then add 1 more mirror during conversion
 # FIXME this has been explicitly forbidden?
-#aux prepare_vg 5
 #lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0
 #lvconvert -m+1 -b $vg/$lv1 $dev4
 #lvconvert -m+1 $vg/$lv1 $dev5
@@ -137,15 +135,15 @@
 #check mirror $vg $lv1 $dev3
 #check mirror_no_temporaries $vg $lv1
 #check mirror_legs $vg $lv1 4
+#lvremove -ff $vg
 
 # Linear to mirror with mirrored log using --alloc anywhere
-aux prepare_vg 5
 lvcreate -l2 -n $lv1 $vg $dev1
 lvconvert -m +1 --mirrorlog mirrored $vg/$lv1 $dev1 $dev2 --alloc anywhere
 should check mirror $vg $lv1
+lvremove -ff $vg
 
 # convert inactive mirror and start polling
-aux prepare_vg 5
 lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0
 lvchange -an $vg/$lv1
 lvconvert -m+1 $vg/$lv1 $dev4
@@ -153,12 +151,12 @@
 lvconvert $vg/$lv1 # wait
 check mirror $vg $lv1 $dev3
 check mirror_no_temporaries $vg $lv1
+lvremove -ff $vg
 
 # ---------------------------------------------------------------------
 # removal during conversion
 
 # "remove newly added mirror"
-aux prepare_vg 5
 lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0
 lvconvert -m+1 -b $vg/$lv1 $dev4
 lvconvert -m-1 $vg/$lv1 $dev4
@@ -167,9 +165,9 @@
 check mirror $vg $lv1 $dev3
 check mirror_no_temporaries $vg $lv1
 check mirror_legs $vg $lv1 2
+lvremove -ff $vg
 
 # "remove one of newly added mirrors"
-aux prepare_vg 5
 lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0
 lvconvert -m+2 -b $vg/$lv1 $dev4 $dev5
 lvconvert -m-1 $vg/$lv1 $dev4
@@ -178,9 +176,9 @@
 check mirror $vg $lv1 $dev3
 check mirror_no_temporaries $vg $lv1
 check mirror_legs $vg $lv1 3
+lvremove -ff $vg
 
 # "remove from original mirror (the original is still mirror)"
-aux prepare_vg 5
 lvcreate -l2 -m2 -n $lv1 $vg $dev1 $dev2 $dev5 $dev3:0
 lvconvert -m+1 -b $vg/$lv1 $dev4 
 lvconvert -m-1 $vg/$lv1 $dev2 
@@ -189,9 +187,9 @@
 check mirror $vg $lv1 $dev3
 check mirror_no_temporaries $vg $lv1
 check mirror_legs $vg $lv1 3
+lvremove -ff $vg
 
 # "remove from original mirror (the original becomes linear)"
-aux prepare_vg 5
 lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0
 lvconvert -m+1 -b $vg/$lv1 $dev4 
 lvconvert -m-1 $vg/$lv1 $dev2 
@@ -200,44 +198,44 @@
 check mirror $vg $lv1 $dev3
 check mirror_no_temporaries $vg $lv1
 check mirror_legs $vg $lv1 2
+lvremove -ff $vg
 
 # ---------------------------------------------------------------------
 
 # "rhbz440405: lvconvert -m0 incorrectly fails if all PEs allocated"
-aux prepare_vg 5
 lvcreate -l`pvs --noheadings -ope_count $dev1` -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0
 wait_for_mirror_in_sync_ $vg/$lv1
 lvconvert -m0 $vg/$lv1 $dev1
 check linear $vg $lv1
+lvremove -ff $vg
 
 # "rhbz264241: lvm mirror doesn't lose it's "M" --nosync attribute after being down and the up converted"
-aux prepare_vg 5
 lvcreate -l2 -m1 -n$lv1 --nosync $vg 
 lvconvert -m0 $vg/$lv1
 lvconvert -m1 $vg/$lv1
 lvs --noheadings -o attr $vg/$lv1 | grep '^ *m'
+lvremove -ff $vg
 
 # lvconvert from linear (on multiple PVs) to mirror
-aux prepare_vg 5
 lvcreate -l 8 -n $lv1 $vg $dev1:0-3 $dev2:0-3
 lvconvert -m1 $vg/$lv1
 
 should check mirror $vg $lv1
 check mirror_legs $vg $lv1 2
+lvremove -ff $vg
 
 # BZ 463272: disk log mirror convert option is lost if downconvert option is also given
-aux prepare_vg 5
 lvcreate -l1 -m2 --corelog -n $lv1 $vg $dev1 $dev2 $dev3
 wait_for_mirror_in_sync_ $vg/$lv1
 lvconvert -m1 --mirrorlog disk $vg/$lv1
 check mirror $vg $lv1
 not check mirror $vg $lv1 core
+lvremove -ff $vg
 
 # ---
 # add mirror and disk log
 
 # "add 1 mirror and disk log" 
-aux prepare_vg 5
 lvcreate -l2 -m1 --mirrorlog core -n $lv1 $vg $dev1 $dev2
 
 # FIXME on next line, specifying $dev3:0 $dev4 (i.e log device first) fails (!)
@@ -246,9 +244,9 @@
 check mirror $vg $lv1 $dev3
 check mirror_no_temporaries $vg $lv1
 check mirror_legs $vg $lv1 3
+lvremove -ff $vg
 
 # simple mirrored stripe
-aux prepare_vg 5
 lvcreate -i2 -l10 -n $lv1 $vg
 lvconvert -m1 -i1 $vg/$lv1
 lvreduce -f -l1 $vg/$lv1
@@ -258,4 +256,4 @@
 # extents must be divisible
 lvcreate -l15 -n $lv1 $vg
 not lvconvert -m1 --corelog --stripes 2 $vg/$lv1
-lvremove -ff $vg/$lv1
+lvremove -ff $vg
--- LVM2/test/shell/lvconvert-raid.sh	2012/01/24 14:33:39	1.2
+++ LVM2/test/shell/lvconvert-raid.sh	2012/03/04 16:02:19	1.3
@@ -100,7 +100,7 @@
 ########################################################
 # MAIN
 ########################################################
-is_raid_available || exit 200
+is_raid_available || skip
 
 aux prepare_vg 5 80
 
@@ -213,5 +213,3 @@
 	lvconvert --type raid1 $vg/$lv1
 	lvremove -ff $vg
 done
-
-exit 0
--- LVM2/test/shell/lvconvert-repair.sh	2011/11/21 00:15:46	1.1
+++ LVM2/test/shell/lvconvert-repair.sh	2012/03/04 16:02:19	1.2
@@ -11,6 +11,12 @@
 
 . lib/test
 
+recreate_vg_()
+{
+	vgremove -ff $vg
+	vgcreate -c n $vg $(cat DEVICES)
+}
+
 aux lvmconf 'allocation/maximise_cling = 0'
 aux lvmconf 'allocation/mirror_logs_require_separate_pvs = 1'
 
@@ -27,7 +33,7 @@
 check mirror $vg 4way $dev5
 
 # 3-way, disk log => linear
-aux prepare_vg 5
+recreate_vg_
 lvcreate -m 2 --ig -L 1 -n 3way $vg
 aux disable_dev $dev1 $dev2
 echo n | lvconvert --repair $vg/3way
@@ -42,7 +48,7 @@
 # fail just log and get it removed
 
 # 3-way, disk log => 3-way, core log
-aux prepare_vg 5
+recreate_vg_
 lvcreate -m 2 --ig -L 1 -n 3way $vg $dev1 $dev2 $dev3 $dev4:0
 aux disable_dev $dev4
 echo n | lvconvert --repair $vg/3way
@@ -54,7 +60,7 @@
 aux enable_dev $dev4
 
 # 3-way, mirrored log => 3-way, core log
-aux prepare_vg 5
+recreate_vg_
 lvcreate -m 2 --mirrorlog mirrored --ig -L 1 -n 3way $vg \
     $dev1 $dev2 $dev3 $dev4:0 $dev5:0
 aux disable_dev $dev4 $dev5
@@ -67,7 +73,7 @@
 aux enable_dev $dev4 $dev5
 
 # 2-way, disk log => 2-way, core log
-aux prepare_vg 5
+recreate_vg_
 lvcreate -m 1 --ig -L 1 -n 2way $vg $dev1 $dev2 $dev3:0
 aux disable_dev $dev3
 echo n | lvconvert --repair $vg/2way
@@ -79,7 +85,7 @@
 
 # fail single devices
 
-aux prepare_vg 5
+recreate_vg_
 vgreduce $vg $dev4
 
 lvcreate -m 1 --ig -L 1 -n mirror $vg
@@ -105,4 +111,4 @@
 vgreduce --removemissing $vg
 aux enable_dev $dev3
 vgextend $vg $dev3
-lvremove -ff $vg
+vgremove -ff $vg
--- LVM2/test/shell/lvcreate-raid.sh	2011/11/21 00:15:46	1.1
+++ LVM2/test/shell/lvcreate-raid.sh	2012/03/04 16:02:19	1.2
@@ -44,7 +44,7 @@
 	local i=0
 
 	while ! is_raid_in_sync $1; do
-		sleep 2
+		sleep .2
 		i=$(($i + 1))
 		if [ $i -gt 500 ]; then
 			echo "Sync is taking too long - assume stuck"
@@ -53,31 +53,13 @@
 	done
 }
 
-function is_raid_available()
-{
-	local a
-
-	modprobe dm-raid
-	a=(`dmsetup targets | grep raid`)
-	if [ -z $a ]; then
-		echo "RAID target not available"
-		return 1
-	fi
-	if [ ${a[1]} != "v1.1.0" ]; then
-		echo "Bad RAID version"
-		return 1
-	fi
-
-	return 0
-}
-
 ########################################################
 # MAIN
 ########################################################
-is_raid_available || exit 200
-
-aux prepare_vg 5 80
+aux target_at_least dm-raid 1 1 0 || skip
 
+aux prepare_pvs 5 20
+vgcreate -c n -s 512k $vg $(cat DEVICES)
 
 ###########################################
 # Create, wait for sync, remove tests
--- LVM2/test/shell/lvextend-snapshot-dmeventd.sh	2011/11/23 15:27:14	1.3
+++ LVM2/test/shell/lvextend-snapshot-dmeventd.sh	2012/03/04 16:02:19	1.4
@@ -25,7 +25,7 @@
 	lvs $vg/snap -o snap_percent --noheadings | cut -c4- | cut -d. -f1
 }
 
-which mkfs.ext2 || exit 200
+which mkfs.ext2 || skip
 
 aux prepare_vg 3
 aux prepare_dmeventd
--- LVM2/test/shell/pvmove-basic.sh	2011/11/21 00:15:46	1.1
+++ LVM2/test/shell/pvmove-basic.sh	2012/03/04 16:02:19	1.2
@@ -14,6 +14,9 @@
 
 . lib/test
 
+which mkfs.ext2 || skip
+which md5sum || skip
+
 # ---------------------------------------------------------------------
 # Utilities
 
@@ -33,17 +36,22 @@
 }
 
 save_dev_sum_() {
-  mkfs.ext3 $1 > /dev/null && md5sum $1 > md5.$(basename $1)
+  mkfs.ext2 $1 > /dev/null && md5sum $1 > md5.$(basename $1)
 }
 
 check_dev_sum_() {
-  md5sum $1 > md5.tmp && cmp md5.$(basename $1) md5.tmp
+  md5sum -c md5.$(basename $1)
 }
 
+create_vg_() {
+  vgcreate -c n -s 128k $vg $(cat DEVICES)
+}
 # ---------------------------------------------------------------------
 # Initialize PVs and VGs
 
-aux prepare_vg 5 40
+#aux prepare_vg 5 30
+aux prepare_pvs 5 5
+create_vg_
 
 # ---------------------------------------------------------------------
 # Common environment setup/cleanup for each sub testcases
@@ -85,11 +93,10 @@
   check_dev_sum_ $(lvdev_ $vg $lv3)
   lvs -a -o name $vg > out && ! grep ^pvmove out
   lvremove -ff $vg
-	if ! dmsetup table|not grep $vg; then
-		echo "ERROR: lvremove did leave some some mappings in DM behind!" && \
-			return 1
-	fi
-	:
+  if ! dmsetup table|not grep $vg; then
+	echo "ERROR: lvremove did leave some some mappings in DM behind!" && \
+		return 1
+  fi
 }
 
 #COMM "check environment setup/cleanup"
@@ -104,7 +111,7 @@
 
 #COMM "only specified LV is moved: from pv2 to pv5 only for lv1"
 prepare_lvs_ 
-pvmove -i1 -n $vg/$lv1 $dev2 $dev5 
+pvmove -i1 -n $vg/$lv1 $dev2 $dev5
 lv_is_on_ $vg/$lv1 $dev1 $dev5 $dev3 $dev1 
 lv_not_changed_ $vg/$lv2 
 lv_not_changed_ $vg/$lv3 
@@ -115,7 +122,7 @@
 
 #COMM "the 1st seg of 3-segs LV is moved: from pv1 of lv1 to pv4"
 prepare_lvs_ 
-pvmove -i1 -n $vg/$lv1 $dev1 $dev4 
+pvmove -i0 -n $vg/$lv1 $dev1 $dev4
 lv_is_on_ $vg/$lv1 $dev4 $dev2 $dev3 $dev4 
 lv_not_changed_ $vg/$lv2 
 lv_not_changed_ $vg/$lv3 
@@ -123,7 +130,7 @@
 
 #COMM "the 2nd seg of 3-segs LV is moved: from pv2 of lv1 to pv4"
 prepare_lvs_ 
-pvmove -i1 -n $vg/$lv1 $dev2 $dev4 
+pvmove -i0 -n $vg/$lv1 $dev2 $dev4
 lv_is_on_ $vg/$lv1 $dev1 $dev4 $dev3 $dev1 
 lv_not_changed_ $vg/$lv2 
 lv_not_changed_ $vg/$lv3 
@@ -131,7 +138,7 @@
 
 #COMM "the 3rd seg of 3-segs LV is moved: from pv3 of lv1 to pv4"
 prepare_lvs_ 
-pvmove -i1 -n $vg/$lv1 $dev3 $dev4 
+pvmove -i0 -n $vg/$lv1 $dev3 $dev4
 lv_is_on_ $vg/$lv1 $dev1 $dev2 $dev4 $dev1 
 lv_not_changed_ $vg/$lv2 
 lv_not_changed_ $vg/$lv3 
@@ -142,7 +149,7 @@
 
 #COMM "1 out of 3 LVs is moved: from pv4 to pv5"
 prepare_lvs_ 
-pvmove -i1 $dev4 $dev5 
+pvmove -i0 $dev4 $dev5
 lv_not_changed_ $vg/$lv1 
 lv_is_on_ $vg/$lv2 $dev2 $dev3 $dev5 
 lv_not_changed_ $vg/$lv3 
@@ -150,7 +157,7 @@
 
 #COMM "2 out of 3 LVs are moved: from pv3 to pv5"
 prepare_lvs_ 
-pvmove -i1 $dev3 $dev5 
+pvmove -i0 $dev3 $dev5
 lv_is_on_ $vg/$lv1 $dev1 $dev2 $dev5 $dev1 
 lv_is_on_ $vg/$lv2 $dev2 $dev5 $dev4 
 lv_not_changed_ $vg/$lv3 
@@ -158,7 +165,7 @@
 
 #COMM "3 out of 3 LVs are moved: from pv2 to pv5"
 prepare_lvs_ 
-pvmove -i1 $dev2 $dev5 
+pvmove -i0 $dev2 $dev5
 lv_is_on_ $vg/$lv1 $dev1 $dev5 $dev3 $dev1 
 lv_is_on_ $vg/$lv2 $dev5 $dev3 $dev4 
 lv_is_on_ $vg/$lv3 $dev5 
@@ -169,7 +176,7 @@
 
 #COMM "move the 1st stripe: from pv2 of lv2 to pv1"
 prepare_lvs_ 
-pvmove -i1 -n $vg/$lv2 $dev2 $dev1 
+pvmove -i0 -n $vg/$lv2 $dev2 $dev1
 lv_not_changed_ $vg/$lv1 
 lv_is_on_ $vg/$lv2 $dev1 $dev3 $dev4 
 lv_not_changed_ $vg/$lv3 
@@ -177,7 +184,7 @@
 
 #COMM "move the 2nd stripe: from pv3 of lv2 to pv1"
 prepare_lvs_ 
-pvmove -i1 -n $vg/$lv2 $dev3 $dev1 
+pvmove -i0 -n $vg/$lv2 $dev3 $dev1
 lv_not_changed_ $vg/$lv1 
 lv_is_on_ $vg/$lv2 $dev2 $dev1 $dev4 
 lv_not_changed_ $vg/$lv3 
@@ -185,7 +192,7 @@
 
 #COMM "move the 3rd stripe: from pv4 of lv2 to pv1"
 prepare_lvs_ 
-pvmove -i1 -n $vg/$lv2 $dev4 $dev1 
+pvmove -i0 -n $vg/$lv2 $dev4 $dev1
 lv_not_changed_ $vg/$lv1 
 lv_is_on_ $vg/$lv2 $dev2 $dev3 $dev1 
 lv_not_changed_ $vg/$lv3 
@@ -196,7 +203,7 @@
 
 #COMM "match to the start of segment:from pv2:0-0 to pv5"
 prepare_lvs_ 
-pvmove -i1 $dev2:0-0 $dev5 
+pvmove -i0 $dev2:0-0 $dev5
 lv_not_changed_ $vg/$lv1 
 lv_is_on_ $vg/$lv2 $dev5 $dev2 $dev3 $dev4 
 lv_not_changed_ $vg/$lv3 
@@ -204,7 +211,7 @@
 
 #COMM "match to the middle of segment: from pv2:1-1 to pv5"
 prepare_lvs_ 
-pvmove -i1 $dev2:1-1 $dev5 
+pvmove -i0 $dev2:1-1 $dev5
 lv_not_changed_ $vg/$lv1 
 lv_is_on_ $vg/$lv2 $dev2 $dev5 $dev2 $dev3 $dev4 
 lv_not_changed_ $vg/$lv3 
@@ -212,7 +219,7 @@
 
 #COMM "match to the end of segment: from pv2:2-2 to pv5"
 prepare_lvs_ 
-pvmove -i1 $dev2:2-2 $dev5 
+pvmove -i0 $dev2:2-2 $dev5
 lv_not_changed_ $vg/$lv1 
 lv_is_on_ $vg/$lv2 $dev2 $dev5 $dev3 $dev4 
 lv_not_changed_ $vg/$lv3 
@@ -223,7 +230,7 @@
 
 #COMM "no destination split: from pv2:0-2 to pv5"
 prepare_lvs_ 
-pvmove -i1 $dev2:0-2 $dev5 
+pvmove -i0 $dev2:0-2 $dev5
 lv_not_changed_ $vg/$lv1 
 lv_is_on_ $vg/$lv2 $dev5 $dev3 $dev4 
 lv_not_changed_ $vg/$lv3 
@@ -231,7 +238,7 @@
 
 #COMM "destination split into 2: from pv2:0-2 to pv5:5-5 and pv4:5-6"
 prepare_lvs_ 
-pvmove -i1 --alloc anywhere $dev2:0-2 $dev5:5-5 $dev4:5-6 
+pvmove -i0 --alloc anywhere $dev2:0-2 $dev5:5-5 $dev4:5-6
 lv_not_changed_ $vg/$lv1 
 lv_is_on_ $vg/$lv2 $dev5 $dev4 $dev3 $dev4 
 lv_not_changed_ $vg/$lv3 
@@ -239,7 +246,7 @@
 
 #COMM "destination split into 3: from pv2:0-2 to {pv3,4,5}:5-5"
 prepare_lvs_ 
-pvmove -i1 --alloc anywhere $dev2:0-2 $dev3:5-5 $dev4:5-5 $dev5:5-5 
+pvmove -i0 --alloc anywhere $dev2:0-2 $dev3:5-5 $dev4:5-5 $dev5:5-5
 lv_not_changed_ $vg/$lv1 
 lv_is_on_ $vg/$lv2 $dev3 $dev4 $dev5 $dev3 $dev4 
 lv_not_changed_ $vg/$lv3 
@@ -250,7 +257,7 @@
 
 #COMM "alloc normal on same PV for source and destination: from pv3:0-2 to pv3:5-7" 
 prepare_lvs_ 
-not pvmove -i1 $dev3:0-2 $dev3:5-7
+not pvmove -i0 $dev3:0-2 $dev3:5-7
 # "(cleanup previous test)"
 lv_not_changed_ $vg/$lv1 
 lv_not_changed_ $vg/$lv2 
@@ -259,7 +266,7 @@
 
 #COMM "alloc anywhere on same PV for source and destination: from pv3:0-2 to pv3:5-7"
 prepare_lvs_ 
-pvmove -i1 --alloc anywhere $dev3:0-2 $dev3:5-7 
+pvmove -i0 --alloc anywhere $dev3:0-2 $dev3:5-7
 lv_not_changed_ $vg/$lv1 
 lv_is_on_ $vg/$lv2 $dev2 $dev3 $dev4 
 lv_not_changed_ $vg/$lv3 
@@ -267,7 +274,7 @@
 
 #COMM "alloc anywhere but better area available: from pv3:0-2 to pv3:5-7 or pv5:5-6,pv4:5-5"
 prepare_lvs_ 
-pvmove -i1 --alloc anywhere $dev3:0-2 $dev3:5-7 $dev5:5-6 $dev4:5-5 
+pvmove -i0 --alloc anywhere $dev3:0-2 $dev3:5-7 $dev5:5-6 $dev4:5-5
 lv_not_changed_ $vg/$lv1 
 #lv_is_on_ $vg/$lv2 $dev2 $dev5 $dev4 $dev4 
 lv_not_changed_ $vg/$lv3 
@@ -275,7 +282,7 @@
 
 #COMM "alloc contiguous but area not available: from pv2:0-2 to pv5:5-5 and pv4:5-6"
 prepare_lvs_ 
-not pvmove -i1 --alloc contiguous $dev2:0-2 $dev5:5-5 $dev4:5-6
+not pvmove -i0 --alloc contiguous $dev2:0-2 $dev5:5-5 $dev4:5-6
 # "(cleanup previous test)"
 lv_not_changed_ $vg/$lv1 
 lv_not_changed_ $vg/$lv2 
@@ -284,7 +291,7 @@
 
 #COMM "alloc contiguous and contiguous area available: from pv2:0-2 to pv5:0-0,pv5:3-5 and pv4:5-6"
 prepare_lvs_ 
-pvmove -i1 --alloc contiguous $dev2:0-2 $dev5:0-0 $dev5:3-5 $dev4:5-6 
+pvmove -i0 --alloc contiguous $dev2:0-2 $dev5:0-0 $dev5:3-5 $dev4:5-6
 lv_not_changed_ $vg/$lv1 
 lv_is_on_ $vg/$lv2 $dev5 $dev3 $dev4 
 lv_not_changed_ $vg/$lv3 
@@ -295,7 +302,7 @@
 
 #COMM "multiple source LVs: from pv3 to pv5"
 prepare_lvs_ 
-pvmove -i1 $dev3 $dev5 
+pvmove -i0 $dev3 $dev5
 lv_is_on_ $vg/$lv1 $dev1 $dev2 $dev5 
 lv_is_on_ $vg/$lv2 $dev2 $dev5 $dev4 
 lv_not_changed_ $vg/$lv3 
@@ -308,7 +315,7 @@
 prepare_lvs_ 
 lvchange -an $vg/$lv1 
 lvchange -an $vg/$lv3 
-pvmove -i1 $dev2 $dev5 
+pvmove -i0 $dev2 $dev5
 lv_is_on_ $vg/$lv1 $dev1 $dev5 $dev3 
 lv_is_on_ $vg/$lv2 $dev5 $dev3 $dev4 
 lv_is_on_ $vg/$lv3 $dev5 
@@ -319,8 +326,8 @@
 
 #COMM "no PEs to move: from pv3 to pv1"
 prepare_lvs_ 
-pvmove -i1 $dev3 $dev1 
-not pvmove -i1 $dev3 $dev1
+pvmove -i0 $dev3 $dev1
+not pvmove -i0 $dev3 $dev1
 # "(cleanup previous test)"
 lv_is_on_ $vg/$lv1 $dev1 $dev2 $dev1 
 lv_is_on_ $vg/$lv2 $dev2 $dev1 $dev4 
@@ -329,7 +336,7 @@
 
 #COMM "no space available: from pv2:0-0 to pv1:0-0" 
 prepare_lvs_ 
-not pvmove -i1 $dev2:0-0 $dev1:0-0
+not pvmove -i0 $dev2:0-0 $dev1:0-0
 # "(cleanup previous test)"
 lv_not_changed_ $vg/$lv1 
 lv_not_changed_ $vg/$lv2 
@@ -338,7 +345,7 @@
 
 #COMM 'same source and destination: from pv1 to pv1'
 prepare_lvs_ 
-not pvmove -i1 $dev1 $dev1
+not pvmove -i0 $dev1 $dev1
 #"(cleanup previous test)"
 lv_not_changed_ $vg/$lv1 
 lv_not_changed_ $vg/$lv2 
@@ -359,7 +366,7 @@
 
 #COMM "pvmove abort"
 prepare_lvs_ 
-pvmove -i100 -b $dev1 $dev3 
+pvmove -i100 -b $dev1 $dev3
 pvmove --abort 
 check_and_cleanup_lvs_
 
@@ -367,7 +374,7 @@
 vgremove -ff $vg
 pvcreate $(cat DEVICES)
 pvcreate --metadatacopies 0 $dev1 $dev2
-vgcreate -c n $vg $(cat DEVICES)
+create_vg_
 lvcreate -l4 -n $lv1 $vg $dev1
 pvmove $dev1
 
--- LVM2/test/shell/vgsplit-operation.sh	2011/11/21 00:15:47	1.1
+++ LVM2/test/shell/vgsplit-operation.sh	2012/03/04 16:02:19	1.2
@@ -17,7 +17,11 @@
 	LAST_TEST="$@"
 }
 
-aux prepare_pvs 5 258
+create_vg_() {
+	vgcreate -c n -s 64k "$@"
+}
+
+aux prepare_pvs 5 10
 # FIXME: paramaterize lvm1 vs lvm2 metadata; most of these tests should run
 # fine with lvm1 metadata as well; for now, just add disks 5 and 6 as lvm1
 # metadata
@@ -33,10 +37,9 @@
 	for j in PV LV
 	do
 COMM "vgsplit correctly splits single linear LV into $i VG ($j args)"
-		vgcreate $vg1 $dev1 $dev2 
-		if [ $i = existing ]; then
-		   vgcreate $vg2 $dev3 $dev4
-		fi 
+		create_vg_ $vg1 $dev1 $dev2
+		test $i = existing && create_vg_ $vg2 $dev3 $dev4
+
 		lvcreate -l 4 -n $lv1 $vg1 $dev1 
 		vgchange -an $vg1 
 		if [ $j = PV ]; then
@@ -51,14 +54,12 @@
 		   check pvlv_counts $vg2 1 1 0
 		fi 
 		lvremove -f $vg2/$lv1 
-		vgremove -f $vg2 
-		vgremove -f $vg1
+		vgremove -f $vg2 $vg1
 
 COMM "vgsplit correctly splits single striped LV into $i VG ($j args)"
-		vgcreate $vg1 $dev1 $dev2 
-		if [ $i = existing ]; then
-		   vgcreate $vg2 $dev3 $dev4
-		fi 
+		create_vg_ $vg1 $dev1 $dev2
+		test $i = existing && create_vg_ $vg2 $dev3 $dev4
+
 		lvcreate -l 4 -i 2 -n $lv1 $vg1 $dev1 $dev2 
 		vgchange -an $vg1 
 		if [ $j = PV ]; then
@@ -75,10 +76,9 @@
 		vgremove -f $vg2
 
 COMM "vgsplit correctly splits mirror LV into $i VG ($j args)" 
-		vgcreate -c n $vg1 $dev1 $dev2 $dev3 
-		if [ $i = existing ]; then
-		  vgcreate -c n $vg2 $dev4
-		fi 
+		create_vg_ $vg1 $dev1 $dev2 $dev3
+		test $i = existing && create_vg_ $vg2 $dev4
+
 		lvcreate -l 64 -m1 -n $lv1 $vg1 $dev1 $dev2 $dev3 
 		vgchange -an $vg1 
 		if [ $j = PV ]; then
@@ -96,10 +96,8 @@
 # FIXME: ensure split /doesn't/ work when not all devs of mirror specified
 
 COMM "vgsplit correctly splits mirror LV with mirrored log into $i VG ($j args)"
-		vgcreate -c n $vg1 $dev1 $dev2 $dev3 $dev4
-		if [ $i = existing ]; then
-		  vgcreate -c n $vg2 $dev5
-		fi
+		create_vg_ $vg1 $dev1 $dev2 $dev3 $dev4
+		test $i = existing && create_vg_ $vg2 $dev5
 
 		lvcreate -l 64 --mirrorlog mirrored -m1 -n $lv1 $vg1 \
 		    $dev1 $dev2 $dev3 $dev4
@@ -120,10 +118,9 @@
 # FIXME: ensure split /doesn't/ work when not all devs of mirror specified
 
 COMM "vgsplit correctly splits origin and snapshot LV into $i VG ($j args)" 
-		vgcreate -c n $vg1 $dev1 $dev2 
-		if [ $i = existing ]; then
-		  vgcreate -c n $vg2 $dev3 $dev4
-		fi 
+		create_vg_ $vg1 $dev1 $dev2
+		test $i = existing && create_vg_ $vg2 $dev3 $dev4
+
 		lvcreate -l 64 -i 2 -n $lv1 $vg1 $dev1 $dev2 
 		lvcreate -l 4 -i 2 -s -n $lv2 $vg1/$lv1 
 		vgchange -an $vg1 
@@ -137,15 +134,14 @@
 		else
 		  check pvlv_counts $vg2 2 2 1
 		fi 
-		lvremove -f $vg2/$lv2 
-		lvremove -f $vg2/$lv1 
+		lvremove -f $vg2/$lv2
+		lvremove -f $vg2/$lv1
 		vgremove -f $vg2
 
 COMM "vgsplit correctly splits linear LV but not snap+origin LV into $i VG ($j args)" 
-		vgcreate -c n $vg1 $dev1 $dev2 
-		if [ $i = existing ]; then
-		  vgcreate -c n $vg2 $dev3
-		fi 
+		create_vg_ $vg1 $dev1 $dev2
+		test $i = existing && create_vg_ $vg2 $dev3
+
 		lvcreate -l 64 -i 2 -n $lv1 $vg1 
 		lvcreate -l 4 -i 2 -s -n $lv2 $vg1/$lv1 
 		vgextend $vg1 $dev4 
@@ -163,24 +159,18 @@
 		  check pvlv_counts $vg2 1 1 0
 		  check pvlv_counts $vg1 2 2 1
 		fi 
-		lvremove -f $vg1/$lv2 
-		lvremove -f $vg1/$lv1 
-		lvremove -f $vg2/$lv3 
-		vgremove -f $vg1 
-		vgremove -f $vg2
+		lvremove -f $vg1/$lv2
+		lvremove -f $vg1/$lv1 $vg2/$lv3
+		vgremove -f $vg1 $vg2
 
 COMM "vgsplit correctly splits linear LV but not mirror LV into $i VG ($j args)" 
-		vgcreate -c n $vg1 $dev1 $dev2 $dev3 
-		if [ $i = existing ]; then
-		  vgcreate -c n $vg2 $dev5
-		fi 
+		create_vg_ $vg1 $dev1 $dev2 $dev3 
+		test $i = existing && create_vg_ $vg2 $dev5
+
 		lvcreate -l 64 -m1 -n $lv1 $vg1 $dev1 $dev2 $dev3 
 		vgextend $vg1 $dev4 
 		lvcreate -l 64 -n $lv2 $vg1 $dev4 
 		vgchange -an $vg1 
-		vgs
-		lvs 
-		pvs
 		if [ $j = PV ]; then
 		  vgsplit $vg1 $vg2 $dev4
 		else
@@ -190,16 +180,11 @@
 		  check pvlv_counts $vg1 3 1 0
 		  check pvlv_counts $vg2 2 1 0
 		else
-		vgs
-		lvs 
-		pvs
 		  check pvlv_counts $vg1 3 1 0
 		  check pvlv_counts $vg2 1 1 0
 		fi 
-		lvremove -f $vg1/$lv1 
-		lvremove -f $vg2/$lv2 
-		vgremove -f $vg1 
-		vgremove -f $vg2
+		lvremove -f $vg1/$lv1 $vg2/$lv2
+		vgremove -f $vg1 $vg2
 
 	done
 done
@@ -209,7 +194,7 @@
 # LVs to split the VG correctly
 # 
 COMM "vgsplit fails splitting 3 striped LVs into VG when only 1 LV specified" 
-vgcreate $vg1 $dev1 $dev2 $dev3 $dev4 
+create_vg_ $vg1 $dev1 $dev2 $dev3 $dev4
 lvcreate -l 4 -n $lv1 -i 2 $vg1 $dev1 $dev2 
 lvcreate -l 4 -n $lv2 -i 2 $vg1 $dev2 $dev3 
 lvcreate -l 4 -n $lv3 -i 2 $vg1 $dev3 $dev4 
@@ -218,33 +203,31 @@
 vgremove -ff $vg1
 
 COMM "vgsplit fails splitting one LV with 2 snapshots, only origin LV specified" 
-vgcreate -c n $vg1 $dev1 $dev2 $dev3 $dev4 
+create_vg_ $vg1 $dev1 $dev2 $dev3 $dev4
 lvcreate -l 16 -n $lv1 $vg1 $dev1 $dev2 
 lvcreate -l 4 -n $lv2 -s $vg1/$lv1 $dev3
 lvcreate -l 4 -n $lv3 -s $vg1/$lv1 $dev4
 check pvlv_counts $vg1 4 3 2 
 vgchange -an $vg1 
 not vgsplit -n $lv1 $vg1 $vg2;
-lvremove -f $vg1/$lv2 
-lvremove -f $vg1/$lv3 
-lvremove -f $vg1/$lv1 
+lvremove -f $vg1/$lv2 $vg1/$lv3
+lvremove -f $vg1/$lv1
 vgremove -ff $vg1
 
 COMM "vgsplit fails splitting one LV with 2 snapshots, only snapshot LV specified" 
-vgcreate -c n $vg1 $dev1 $dev2 $dev3 $dev4 
+create_vg_ $vg1 $dev1 $dev2 $dev3 $dev4
 lvcreate -l 16 -n $lv1 $vg1 $dev1 $dev2 
 lvcreate -l 4 -n $lv2 -s $vg1/$lv1 $dev3
 lvcreate -l 4 -n $lv3 -s $vg1/$lv1 $dev4
 check pvlv_counts $vg1 4 3 2 
 vgchange -an $vg1 
 not vgsplit -n $lv2 $vg1 $vg2
-lvremove -f $vg1/$lv2 
-lvremove -f $vg1/$lv3 
-lvremove -f $vg1/$lv1 
+lvremove -f $vg1/$lv2 $vg1/$lv3
+lvremove -f $vg1/$lv1
 vgremove -ff $vg1
 
 COMM "vgsplit fails splitting one mirror LV, only one PV specified" 
-vgcreate -c n $vg1 $dev1 $dev2 $dev3 $dev4 
+create_vg_ $vg1 $dev1 $dev2 $dev3 $dev4
 lvcreate -l 16 -n $lv1 -m1 $vg1 $dev1 $dev2 $dev3 
 check pvlv_counts $vg1 4 1 0 
 vgchange -an $vg1 
@@ -252,7 +235,7 @@
 vgremove -ff $vg1
 
 COMM "vgsplit fails splitting 1 mirror + 1 striped LV, only striped LV specified" 
-vgcreate -c n $vg1 $dev1 $dev2 $dev3 $dev4 
+create_vg_ $vg1 $dev1 $dev2 $dev3 $dev4
 lvcreate -l 16 -n $lv1 -m1 $vg1 $dev1 $dev2 $dev3 
 lvcreate -l 16 -n $lv2 -i 2 $vg1 $dev3 $dev4 
 check pvlv_counts $vg1 4 2 0 
@@ -264,7 +247,7 @@
 # Verify vgsplit rejects active LVs only when active LVs involved in split
 #
 COMM "vgsplit fails, active mirror involved in split" 
-vgcreate -c n $vg1 $dev1 $dev2 $dev3 $dev4 
+create_vg_ $vg1 $dev1 $dev2 $dev3 $dev4
 lvcreate -l 16 -n $lv1 -m1 $vg1 $dev1 $dev2 $dev3 
 lvcreate -l 16 -n $lv2 $vg1 $dev4 
 lvchange -an $vg1/$lv2 
@@ -274,7 +257,7 @@
 vgremove -ff $vg1
 
 COMM "vgsplit succeeds, active mirror not involved in split" 
-vgcreate -c n $vg1 $dev1 $dev2 $dev3 $dev4 
+create_vg_ $vg1 $dev1 $dev2 $dev3 $dev4
 lvcreate -l 16 -n $lv1 -m1 $vg1 $dev1 $dev2 $dev3 
 lvcreate -l 16 -n $lv2 $vg1 $dev4 
 lvchange -an $vg1/$lv2 
@@ -282,11 +265,10 @@
 vgsplit -n $lv2 $vg1 $vg2 
 check pvlv_counts $vg1 3 1 0 
 check pvlv_counts $vg2 1 1 0 
-vgremove -ff $vg1 
-vgremove -ff $vg2
+vgremove -ff $vg1 $vg2
 
 COMM "vgsplit fails, active snapshot involved in split" 
-vgcreate -c n $vg1 $dev1 $dev2 $dev3 $dev4 
+create_vg_ $vg1 $dev1 $dev2 $dev3 $dev4
 lvcreate -l 64 -i 2 -n $lv1 $vg1 $dev1 $dev2 
 lvcreate -l 4 -i 2 -s -n $lv2 $vg1/$lv1 
 lvcreate -l 64 -i 2 -n $lv3 $vg1 $dev3 $dev4 
@@ -298,7 +280,7 @@
 vgremove -ff $vg1
 
 COMM "vgsplit succeeds, active snapshot not involved in split" 
-vgcreate -c n $vg1 $dev1 $dev2 $dev3 
+create_vg_ $vg1 $dev1 $dev2 $dev3
 lvcreate -l 64 -i 2 -n $lv1 $vg1 $dev1 $dev2 
 lvcreate -l 4 -s -n $lv2 $vg1/$lv1 
 vgextend $vg1 $dev4 
@@ -310,6 +292,4 @@
 check pvlv_counts $vg2 1 1 0 
 vgchange -an $vg1 
 lvremove -f $vg1/$lv2 
-vgremove -ff $vg1 
-vgremove -ff $vg2
-
+vgremove -ff $vg1 $vg2


