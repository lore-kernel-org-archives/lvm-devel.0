From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 11 Nov 2008 15:46:20 -0000
Subject: LVM2/test t-metadata.sh t-lvextend-percent-ext ...
Message-ID: <20081111154620.17843.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2008-11-11 15:46:19

Modified files:
	test           : t-metadata.sh t-lvextend-percent-extents.sh 
	                 t-pvcreate-operation.sh 

Log message:
	Add a bunch of sub-tests aimed at testing various bugzillas, by jstava.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-metadata.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvextend-percent-extents.sh.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvcreate-operation.sh.diff?cvsroot=lvm2&r1=1.12&r2=1.13

--- LVM2/test/t-metadata.sh	2008/09/29 16:02:49	1.2
+++ LVM2/test/t-metadata.sh	2008/11/11 15:46:15	1.3
@@ -28,6 +28,26 @@
 pvchange --uuid $dev2
 vgremove -f $vg
 
+# check that PVs without metadata don't cause too many full device rescans (bz452606)
+for mdacp in 1 0; do
+	pvcreate --metadatacopies $mdacp $devs
+	pvcreate $dev1
+	vgcreate $vg $devs
+	lvcreate -n $lv1 -l 2 -i5 -I256 $vg
+	lvcreate -n $lv2 -m2 -l 2  $vg
+	#lvchange -an $vg
+	lvchange -an $vg/$lv1 >out$mdacp 2>&1 
+	lvchange -an $vg/$lv2 >>out$mdacp 2>&1 
+	test ! -s out$mdacp
+	vgchange -ay $vg
+	lvchange -vvvv -an $vg/$lv1 >out$mdacp 2>&1 
+	lvchange -vvvv -an $vg/$lv2 >>out$mdacp 2>&1 
+	eval run$mdacp=$(wc -l <out$mdacp)
+	vgremove -f $vg
+done
+not grep "Cached VG .* incorrect PV list" out0
+
+# some M1 metadata tests
 pvcreate -M1 $dev1
 pvcreate -M1 $dev2
 pvcreate -M1 $dev3
--- LVM2/test/t-lvextend-percent-extents.sh	2008/09/30 17:47:34	1.5
+++ LVM2/test/t-lvextend-percent-extents.sh	2008/11/11 15:46:15	1.6
@@ -30,6 +30,14 @@
 grep "^  Logical volume $lv successfully resized\$" out
 check_pv_field_ $dev1 pv_free "0"
 
+lvremove -f $vg/$lv 
+
+# 'lvextend computes necessary free space correctly - bz213552'
+vgsize=$(vgs -o vg_extent_count --noheadings)
+lvcreate -l $vgsize  -n $lv $vg
+yes | lvreduce -l $(( $vgsize / 2 )) $vg/$lv
+lvextend -l $vgsize $vg/$lv
+
 # 'Reset LV to original size' 
 lvremove -f $vg/$lv 
 lvcreate -L 64M -n $lv $vg
--- LVM2/test/t-pvcreate-operation.sh	2008/11/10 12:43:35	1.12
+++ LVM2/test/t-pvcreate-operation.sh	2008/11/11 15:46:15	1.13
@@ -14,6 +14,14 @@
 
 for mdatype in 1 2
 do
+# pvcreate (lvm$mdatype) refuses to overwrite an mounted filesystem (bz168330)
+	test ! -d $G_root_/mnt && mkdir $G_root_/mnt 
+	if mke2fs $dev1; then
+		mount $dev1 $G_root_/mnt
+		not pvcreate -M$mdatype $dev1 2>err
+		grep "Can't open $dev1 exclusively.  Mounted filesystem?" err
+		umount $dev1
+	fi
 
 # pvcreate (lvm$mdatype) succeeds when run repeatedly (pv not in a vg) (bz178216)
     pvcreate -M$mdatype $dev1


