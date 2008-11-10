From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 10 Nov 2008 12:41:55 -0000
Subject: LVM2/test t-mirror-lvconvert.sh t-mirror-names ...
Message-ID: <20081110124155.10288.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2008-11-10 12:41:52

Modified files:
	test           : t-mirror-lvconvert.sh t-mirror-names.sh 
	                 t-pvmove-basic.sh t-pvremove-usage.sh 
	                 t-vgmerge-operation.sh 

Log message:
	add bz264241 check
	remove lvconvert progress notifications (-i100)
	(by jstava)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-mirror-lvconvert.sh.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-mirror-names.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvmove-basic.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvremove-usage.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgmerge-operation.sh.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/test/t-mirror-lvconvert.sh	2008/11/10 12:32:00	1.6
+++ LVM2/test/t-mirror-lvconvert.sh	2008/11/10 12:41:52	1.7
@@ -193,7 +193,7 @@
 lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1
 check_mirror_count_ $vg/$lv1 2
 check_mirror_log_ $vg/$lv1
-lvconvert -m+1 -b -i100 $vg/$lv1 $dev4
+lvconvert -m+1 -b $vg/$lv1 $dev4
 lvconvert -m+1 -i3 $vg/$lv1 $dev5
 check_no_tmplvs_ $vg/$lv1
 check_mirror_count_ $vg/$lv1 4
@@ -240,7 +240,7 @@
 lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1 
 check_mirror_count_ $vg/$lv1 2 
 check_mirror_log_ $vg/$lv1 
-lvconvert -m+1 -b -i100 $vg/$lv1 $dev4 
+lvconvert -m+1 -b $vg/$lv1 $dev4 
 lvconvert -m-1 $vg/$lv1 $dev4 
 wait_conversion_ $vg/$lv1 
 check_no_tmplvs_ $vg/$lv1 
@@ -254,7 +254,7 @@
 lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1 
 check_mirror_count_ $vg/$lv1 2 
 check_mirror_log_ $vg/$lv1 
-lvconvert -m+2 -b -i100 $vg/$lv1 $dev4 $dev5 
+lvconvert -m+2 -b $vg/$lv1 $dev4 $dev5 
 lvconvert -m-1 $vg/$lv1 $dev4 
 lvconvert -i1 $vg/$lv1 
 wait_conversion_ $vg/$lv1 
@@ -269,7 +269,7 @@
 lvcreate -l2 -m2 -n $lv1 $vg $dev1 $dev2 $dev5 $dev3:0-1 
 check_mirror_count_ $vg/$lv1 3 
 check_mirror_log_ $vg/$lv1 
-lvconvert -m+1 -b -i100 $vg/$lv1 $dev4 
+lvconvert -m+1 -b $vg/$lv1 $dev4 
 lvconvert -m-1 $vg/$lv1 $dev2 
 lvconvert -i1 $vg/$lv1 
 wait_conversion_ $vg/$lv1 
@@ -284,7 +284,7 @@
 lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1 
 check_mirror_count_ $vg/$lv1 2 
 check_mirror_log_ $vg/$lv1 
-lvconvert -m+1 -b -i100 $vg/$lv1 $dev4 
+lvconvert -m+1 -b $vg/$lv1 $dev4 
 lvconvert -m-1 $vg/$lv1 $dev2 
 lvconvert -i1 $vg/$lv1 
 wait_conversion_ $vg/$lv1 
@@ -294,6 +294,8 @@
 mirrorlog_is_on_ $vg/$lv1 $dev3 
 check_and_cleanup_lvs_
 
+# ---------------------------------------------------------------------
+
 # "rhbz440405: lvconvert -m0 incorrectly fails if all PEs allocated"
 prepare_lvs_ 
 lvcreate -l`pvs --noheadings -ope_count $dev1` -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0 
@@ -304,5 +306,10 @@
 check_mirror_count_ $vg/$lv1 1 
 check_and_cleanup_lvs_
 
-# ---------------------------------------------------------------------
+# "rhbz264241: lvm mirror doesn't lose it's "M" --nosync attribute after being down and the up converted"
+prepare_lvs_
+lvcreate -l2 -m1 -n$lv1 --nosync $vg 
+lvconvert -m0 $vg/$lv1
+lvconvert -m1 $vg/$lv1
+lvs --noheadings -o attr $vg/$lv1 | grep '^ *m'
 
--- LVM2/test/t-mirror-names.sh	2008/11/10 12:32:00	1.3
+++ LVM2/test/t-mirror-names.sh	2008/11/10 12:41:52	1.4
@@ -90,7 +90,13 @@
 #COMM "mirror log is ${lv1}_mlog"
 lv_mirror_log_ $vg/$lv1 "$lv1"_mlog
 
-#COMM "cleanup" 
+# "cleanup" 
+check_and_cleanup_lvs_
+
+#COMM "mirror with name longer than 22 characters (bz221322)"
+name="LVwithanamelogerthan22characters_butidontwonttocounthem"
+lvcreate -m1 -l2 -n"$name" $vg
+lvs $vg/"$name"
 check_and_cleanup_lvs_
 
 # ---------------------------------------------------------------------
--- LVM2/test/t-pvmove-basic.sh	2008/11/10 12:32:00	1.3
+++ LVM2/test/t-pvmove-basic.sh	2008/11/10 12:41:52	1.4
@@ -362,3 +362,11 @@
 pvmove --abort 
 check_and_cleanup_lvs_
 
+#COMM "pvmove out of --metadatacopies 0 PV (bz252150)"
+vgremove -ff $vg
+pvcreate $devs
+pvcreate --metadatacopies 0 $dev1 $dev2
+vgcreate $vg $devs
+lvcreate -l4 -n $lv1 $vg $dev1
+pvmove $dev1
+
--- LVM2/test/t-pvremove-usage.sh	2008/09/30 13:19:56	1.2
+++ LVM2/test/t-pvremove-usage.sh	2008/11/10 12:41:52	1.3
@@ -34,6 +34,10 @@
     pvremove $dev3
     pvscan | not grep $dev3
 
+	# bz179473 refuse to wipe non-PV device without -f
+    not pvremove $dev3
+    pvremove -f $dev3
+
     # reset setup
     vgremove -ff $vg
     pvcreate --metadatacopies $mdacp $dev1
--- LVM2/test/t-vgmerge-operation.sh	2008/10/06 16:47:07	1.4
+++ LVM2/test/t-vgmerge-operation.sh	2008/11/10 12:41:52	1.5
@@ -64,3 +64,18 @@
 lvremove -f $vg2/$lv1 
 vgremove -f $vg2
 
+# 'vgmerge rejects LV name collision'
+vgcreate $vg1 $dev1 $dev2
+vgcreate $vg2 $dev3 $dev4
+lvcreate -l 4 -n $lv1 $vg1
+lvcreate -l 4 -n $lv1 $vg2
+vgchange -an $vg1
+aux vg_validate_pvlv_counts_ $vg1 2 1 0
+aux vg_validate_pvlv_counts_ $vg2 2 1 0
+not vgmerge $vg2 $vg1 2>err
+grep "Duplicate logical volume name \"$lv1\" in \"$vg2\" and \"$vg1" err
+aux vg_validate_pvlv_counts_ $vg1 2 1 0
+aux vg_validate_pvlv_counts_ $vg2 2 1 0
+vgremove -f $vg1
+vgremove -f $vg2
+


