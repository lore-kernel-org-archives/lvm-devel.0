From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 30 Sep 2008 18:29:10 -0000
Subject: LVM2/test t-vgsplit-operation.sh
Message-ID: <20080930182910.4544.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2008-09-30 18:29:10

Modified files:
	test           : t-vgsplit-operation.sh 

Log message:
	Fix [ a = b ] usage in t-vgsplit-operation: string comparison is '=', not '=='.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgsplit-operation.sh.diff?cvsroot=lvm2&r1=1.22&r2=1.23

--- LVM2/test/t-vgsplit-operation.sh	2008/09/30 17:56:54	1.22
+++ LVM2/test/t-vgsplit-operation.sh	2008/09/30 18:29:10	1.23
@@ -34,18 +34,18 @@
 	do
 COMM "vgsplit correctly splits single linear LV into $i VG ($j args)"
 		vgcreate $vg1 $dev1 $dev2 
-		if [ $i == existing ]; then
+		if [ $i = existing ]; then
 		   vgcreate $vg2 $dev3 $dev4
 		fi 
 		lvcreate -l 4 -n $lv1 $vg1 $dev1 
 		vgchange -an $vg1 
-		if [ $j == PV ]; then
+		if [ $j = PV ]; then
 		  vgsplit $vg1 $vg2 $dev1
 		else
 		  vgsplit -n $lv1 $vg1 $vg2
 		fi 
 		vg_validate_pvlv_counts_ $vg1 1 0 0 
-		if [ $i == existing ]; then
+		if [ $i = existing ]; then
 		   aux vg_validate_pvlv_counts_ $vg2 3 1 0
 		else
 		   aux vg_validate_pvlv_counts_ $vg2 1 1 0
@@ -56,17 +56,17 @@
 
 COMM "vgsplit correctly splits single striped LV into $i VG ($j args)"
 		vgcreate $vg1 $dev1 $dev2 
-		if [ $i == existing ]; then
+		if [ $i = existing ]; then
 		   vgcreate $vg2 $dev3 $dev4
 		fi 
 		lvcreate -l 4 -i 2 -n $lv1 $vg1 $dev1 $dev2 
 		vgchange -an $vg1 
-		if [ $j == PV ]; then
+		if [ $j = PV ]; then
 		  vgsplit $vg1 $vg2 $dev1 $dev2
 		else
 		  vgsplit -n $lv1 $vg1 $vg2
 		fi 
-		if [ $i == existing ]; then
+		if [ $i = existing ]; then
 		  aux vg_validate_pvlv_counts_ $vg2 4 1 0
 		else
 		  aux vg_validate_pvlv_counts_ $vg2 2 1 0
@@ -76,17 +76,17 @@
 
 COMM "vgsplit correctly splits mirror LV into $i VG ($j args)" 
 		vgcreate $vg1 $dev1 $dev2 $dev3 
-		if [ $i == existing ]; then
+		if [ $i = existing ]; then
 		  vgcreate $vg2 $dev4
 		fi 
 		lvcreate -l 64 -m1 -n $lv1 $vg1 $dev1 $dev2 $dev3 
 		vgchange -an $vg1 
-		if [ $j == PV ]; then
+		if [ $j = PV ]; then
 		  vgsplit $vg1 $vg2 $dev1 $dev2 $dev3
 		else
 		  vgsplit -n $lv1 $vg1 $vg2
 		fi 
-		if [ $i == existing ]; then
+		if [ $i = existing ]; then
 		  aux vg_validate_pvlv_counts_ $vg2 4 1 0
 		else
 		  aux vg_validate_pvlv_counts_ $vg2 3 1 0
@@ -96,18 +96,18 @@
 
 COMM "vgsplit correctly splits origin and snapshot LV into $i VG ($j args)" 
 		vgcreate $vg1 $dev1 $dev2 
-		if [ $i == existing ]; then
+		if [ $i = existing ]; then
 		  vgcreate $vg2 $dev3 $dev4
 		fi 
 		lvcreate -l 64 -i 2 -n $lv1 $vg1 $dev1 $dev2 
 		lvcreate -l 4 -i 2 -s -n $lv2 $vg1/$lv1 
 		vgchange -an $vg1 
-		if [ $j == PV ]; then
+		if [ $j = PV ]; then
 		  vgsplit $vg1 $vg2 $dev1 $dev2
 		else
 		  vgsplit -n $lv1 $vg1 $vg2
 		fi 
-		if [ $i == existing ]; then
+		if [ $i = existing ]; then
 		  aux vg_validate_pvlv_counts_ $vg2 4 2 1
 		else
 		  aux vg_validate_pvlv_counts_ $vg2 2 2 1
@@ -118,7 +118,7 @@
 
 COMM "vgsplit correctly splits linear LV but not snap+origin LV into $i VG ($j args)" 
 		vgcreate $vg1 $dev1 $dev2 
-		if [ $i == existing ]; then
+		if [ $i = existing ]; then
 		  vgcreate $vg2 $dev3
 		fi 
 		lvcreate -l 64 -i 2 -n $lv1 $vg1 
@@ -126,12 +126,12 @@
 		vgextend $vg1 $dev4 
 		lvcreate -l 64 -n $lv3 $vg1 $dev4 
 		vgchange -an $vg1 
-		if [ $j == PV ]; then
+		if [ $j = PV ]; then
 		  vgsplit $vg1 $vg2 $dev4
 		else
 		  vgsplit -n $lv3 $vg1 $vg2
 		fi 
-		if [ $i == existing ]; then
+		if [ $i = existing ]; then
 		  aux vg_validate_pvlv_counts_ $vg2 2 1 0
 		  aux vg_validate_pvlv_counts_ $vg1 2 2 1
 		else
@@ -146,7 +146,7 @@
 
 COMM "vgsplit correctly splits linear LV but not mirror LV into $i VG ($j args)" 
 		vgcreate $vg1 $dev1 $dev2 $dev3 
-		if [ $i == existing ]; then
+		if [ $i = existing ]; then
 		  vgcreate $vg2 $dev5
 		fi 
 		lvcreate -l 64 -m1 -n $lv1 $vg1 $dev1 $dev2 $dev3 
@@ -156,12 +156,12 @@
 		vgs
 		lvs 
 		pvs
-		if [ $j == PV ]; then
+		if [ $j = PV ]; then
 		  vgsplit $vg1 $vg2 $dev4
 		else
 		  vgsplit -n $lv2 $vg1 $vg2
 		fi 
-		if [ $i == existing ]; then
+		if [ $i = existing ]; then
 		  aux vg_validate_pvlv_counts_ $vg1 3 1 0
 		  aux vg_validate_pvlv_counts_ $vg2 2 1 0
 		else


