From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 31 Mar 2010 03:56:25 -0000
Subject: LVM2/test t-mirror-vgreduce-removemissing.sh
Message-ID: <20100331035625.26573.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2010-03-31 03:56:25

Modified files:
	test           : t-mirror-vgreduce-removemissing.sh 

Log message:
	We only need one extent for the mirror log.  So, when specifying
	the devices on which to place the individual mirror parts, we can
	specify the log devices as $dev:x instead of $dev:x-y.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-mirror-vgreduce-removemissing.sh.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/test/t-mirror-vgreduce-removemissing.sh	2010/03/25 12:16:17	1.7
+++ LVM2/test/t-mirror-vgreduce-removemissing.sh	2010/03/31 03:56:25	1.8
@@ -151,7 +151,7 @@
 {
 	local index=$1
 
-	lvcreate -l2 -m2 -n $lv1 $vg $dev1 $dev2 $dev3 $dev4:0-1
+	lvcreate -l2 -m2 -n $lv1 $vg $dev1 $dev2 $dev3 $dev4:0
 	lvchange -an $vg/$lv1
 	aux mimages_are_on_ $lv1 $dev1 $dev2 $dev3
 	mirrorlog_is_on_ $lv1 $dev4
@@ -178,7 +178,7 @@
 {
 	local index=$1
 
-	lvcreate -l2 -m2 -n $lv1 $vg $dev1 $dev2 $dev3 $dev4:0-1
+	lvcreate -l2 -m2 -n $lv1 $vg $dev1 $dev2 $dev3 $dev4:0
 	lvchange -an $vg/$lv1
 	mimages_are_on_ $lv1 $dev1 $dev2 $dev3
 	mirrorlog_is_on_ $lv1 $dev4
@@ -206,7 +206,7 @@
 {
 	local index=$1
 
-	lvcreate -l2 -m2 -n $lv1 $vg $dev1 $dev2 $dev3 $dev5:0-1 
+	lvcreate -l2 -m2 -n $lv1 $vg $dev1 $dev2 $dev3 $dev5:0
 	lvchange -an $vg/$lv1 
 	lvconvert -m+1 $vg/$lv1 $dev4 
 	mimages_are_on_ $lv1 $dev1 $dev2 $dev3 $dev4 
@@ -234,7 +234,7 @@
 {
 	local index=$1
 
-	lvcreate -l2 -m2 -n $lv1 $vg $dev1 $dev2 $dev3 $dev5:0-1 
+	lvcreate -l2 -m2 -n $lv1 $vg $dev1 $dev2 $dev3 $dev5:0
 	lvchange -an $vg/$lv1 
 	lvconvert -m+1 $vg/$lv1 $dev4 
 	mimages_are_on_ $lv1 $dev1 $dev2 $dev3 $dev4 
@@ -263,7 +263,7 @@
 {
 	local index=$1
 
-	lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev5:0-1 
+	lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev5:0
 	lvchange -an $vg/$lv1 
 	lvconvert -m+2 $vg/$lv1 $dev3 $dev4 
 	mimages_are_on_ $lv1 $dev1 $dev2 $dev3 $dev4 
@@ -291,7 +291,7 @@
 {
 	local index=$1
 
-	lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev5:0-1 
+	lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev5:0
 	lvchange -an $vg/$lv1 
 	lvconvert -m+2 $vg/$lv1 $dev3 $dev4 
 	mimages_are_on_ $lv1 $dev1 $dev2 $dev3 $dev4 
@@ -316,7 +316,7 @@
 
 #COMM "fail mirror log of 2-way mirrored LV" 
 prepare_lvs_ 
-lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev5:0-1 
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev5:0
 lvchange -an $vg/$lv1 
 mimages_are_on_ $lv1 $dev1 $dev2 
 mirrorlog_is_on_ $lv1 $dev5 
@@ -328,7 +328,7 @@
 
 #COMM "fail mirror log of 3-way (1 converting) mirrored LV" 
 prepare_lvs_ 
-lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev5:0-1 
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev5:0
 lvchange -an $vg/$lv1 
 lvconvert -m+1 $vg/$lv1 $dev3 
 mimages_are_on_ $lv1 $dev1 $dev2 $dev3 
@@ -344,7 +344,7 @@
 
 #COMM "fail all mirror images of 2-way mirrored LV"
 prepare_lvs_ 
-lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev5:0-1 
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev5:0
 lvchange -an $vg/$lv1 
 mimages_are_on_ $lv1 $dev1 $dev2 
 mirrorlog_is_on_ $lv1 $dev5 
@@ -355,7 +355,7 @@
 
 #COMM "fail all mirror images of 3-way (1 converting) mirrored LV"
 prepare_lvs_ 
-lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev5:0-1 
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev5:0
 lvchange -an $vg/$lv1 
 lvconvert -m+1 $vg/$lv1 $dev3 
 mimages_are_on_ $lv1 $dev1 $dev2 $dev3 
@@ -370,9 +370,9 @@
 
 #COMM "fail a mirror image of one of mirrored LV"
 prepare_lvs_ 
-lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev5:0-1 
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev5:0
 lvchange -an $vg/$lv1 
-lvcreate -l2 -m1 -n $lv2 $vg $dev3 $dev4 $dev5:1-1 
+lvcreate -l2 -m1 -n $lv2 $vg $dev3 $dev4 $dev5:1 
 lvchange -an $vg/$lv2 
 mimages_are_on_ $lv1 $dev1 $dev2 
 mimages_are_on_ $lv2 $dev3 $dev4 
@@ -388,9 +388,9 @@
 
 #COMM "fail mirror images, one for each mirrored LV"
 prepare_lvs_ 
-lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev5:0-1 
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev5:0
 lvchange -an $vg/$lv1 
-lvcreate -l2 -m1 -n $lv2 $vg $dev3 $dev4 $dev5:1-1 
+lvcreate -l2 -m1 -n $lv2 $vg $dev3 $dev4 $dev5:1 
 lvchange -an $vg/$lv2 
 mimages_are_on_ $lv1 $dev1 $dev2 
 mimages_are_on_ $lv2 $dev3 $dev4 
@@ -410,7 +410,7 @@
 
 #COMM "no failures"
 prepare_lvs_ 
-lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev5:0-1 
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev5:0
 lvchange -an $vg/$lv1 
 mimages_are_on_ $lv1 $dev1 $dev2 
 mirrorlog_is_on_ $lv1 $dev5 


