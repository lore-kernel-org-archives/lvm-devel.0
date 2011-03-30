From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 30 Mar 2011 13:39:25 -0000
Subject: LVM2/test t-mirror-names.sh t-mirror-vgreduce- ...
Message-ID: <20110330133925.17218.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-03-30 13:39:24

Modified files:
	test           : t-mirror-names.sh 
	                 t-mirror-vgreduce-removemissing.sh 
	                 t-pvcreate-operation.sh t-snapshot-merge.sh 
	                 t-vgcreate-usage.sh t-vgextend-usage.sh 

Log message:
	Testing: remove -q from grep
	
	to avoid any problems with pipe breaking.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-mirror-names.sh.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-mirror-vgreduce-removemissing.sh.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvcreate-operation.sh.diff?cvsroot=lvm2&r1=1.20&r2=1.21
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-snapshot-merge.sh.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgcreate-usage.sh.diff?cvsroot=lvm2&r1=1.18&r2=1.19
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgextend-usage.sh.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/test/t-mirror-names.sh	2011/03/02 20:14:39	1.9
+++ LVM2/test/t-mirror-names.sh	2011/03/30 13:39:24	1.10
@@ -27,7 +27,7 @@
                sed 's/ //g' | sed 's/,/ /g')
 
   for d in $devs; do
-    (echo $devices | grep -q $d)  || return 1
+    (echo $devices | grep $d >/dev/null)  || return 1
     devices=$(echo $devices | sed "s/$d//")
   done
 
--- LVM2/test/t-mirror-vgreduce-removemissing.sh	2011/03/03 15:46:05	1.11
+++ LVM2/test/t-mirror-vgreduce-removemissing.sh	2011/03/30 13:39:24	1.12
@@ -66,7 +66,7 @@
 {
 	echo "Check if $1 is linear LV (i.e. not a mirror)"
 	lvs -o stripes,attr --noheadings $vg/$1 | sed 's/ //g'
-	lvs -o stripes,attr --noheadings $vg/$1 | sed 's/ //g' | grep -q '^1-'
+	lvs -o stripes,attr --noheadings $vg/$1 | sed 's/ //g' | grep '^1-' >/dev/null
 }
 
 rest_pvs_()
--- LVM2/test/t-pvcreate-operation.sh	2011/01/05 00:16:20	1.20
+++ LVM2/test/t-pvcreate-operation.sh	2011/03/30 13:39:24	1.21
@@ -82,7 +82,7 @@
 do
 # pvcreate (lvm2) succeeds writing LVM label at sector $i
     pvcreate --labelsector $i $dev1
-    dd if=$dev1 bs=512 skip=$i count=1 2>/dev/null | strings | grep -q LABELONE;
+    dd if=$dev1 bs=512 skip=$i count=1 2>/dev/null | strings | grep LABELONE >/dev/null
     pvremove -f $dev1
 done
 
--- LVM2/test/t-snapshot-merge.sh	2011/01/05 00:16:20	1.8
+++ LVM2/test/t-snapshot-merge.sh	2011/03/30 13:39:24	1.9
@@ -47,7 +47,7 @@
 # test full merge of a single LV
 setup_merge $vg $lv1
 # now that snapshot LV is created: test if snapshot-merge target is available
-$(dmsetup targets | grep -q snapshot-merge) || exit 200
+$(dmsetup targets | grep snapshot-merge >/dev/null) || exit 200
 lvs -a
 # make sure lvconvert --merge requires explicit LV listing
 not lvconvert --merge 2>err
@@ -73,11 +73,12 @@
 lvchange --refresh $vg/$lv1
 umount test_mnt
 rm -r test_mnt
-dmsetup table ${vg}-${lv1} | grep -q " snapshot-origin "
+dmsetup table ${vg}-${lv1} | grep " snapshot-origin "
+
 # -- refresh LV to start merge (now that FS is unmounted),
 #    an active merge uses the 'snapshot-merge' target
 lvchange --refresh $vg/$lv1
-dmsetup table ${vg}-${lv1} | grep -q " snapshot-merge "
+dmsetup table ${vg}-${lv1} | grep " snapshot-merge "
 # -- don't care if merge is still active; lvremove at this point
 #    may test stopping an active merge
 lvremove -f $vg/$lv1
@@ -96,7 +97,7 @@
 lvchange --refresh $vg/$lv1
 umount test_mnt
 rm -r test_mnt
-dmsetup table ${vg}-${lv1} | grep -q " snapshot-origin "
+dmsetup table ${vg}-${lv1} | grep " snapshot-origin " >/dev/null
 lvremove -f $vg/$lv1
 
 
--- LVM2/test/t-vgcreate-usage.sh	2011/01/05 00:16:20	1.18
+++ LVM2/test/t-vgcreate-usage.sh	2011/03/30 13:39:24	1.19
@@ -102,7 +102,7 @@
 do
 # vgcreate (lvm2) succeeds writing LVM label at sector $i
     vgcreate -c n --labelsector $i $vg $dev1
-    dd if=$dev1 bs=512 skip=$i count=1 2>/dev/null | strings | grep -q LABELONE;
+    dd if=$dev1 bs=512 skip=$i count=1 2>/dev/null | strings | grep LABELONE >/dev/null
     vgremove -f $vg
     pvremove -f $dev1
 done
--- LVM2/test/t-vgextend-usage.sh	2011/01/05 00:16:20	1.6
+++ LVM2/test/t-vgextend-usage.sh	2011/03/30 13:39:24	1.7
@@ -46,7 +46,7 @@
 do
 # vgcreate (lvm2) succeeds writing LVM label at sector $i
     vgextend --labelsector $i $vg $dev1
-    dd if=$dev1 bs=512 skip=$i count=1 2>/dev/null | strings | grep -q LABELONE;
+    dd if=$dev1 bs=512 skip=$i count=1 2>/dev/null | strings | grep LABELONE >/dev/null
     vgreduce $vg $dev1
     pvremove -f $dev1
 done


