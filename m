From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 10 Nov 2008 12:32:01 -0000
Subject: LVM2/test t-mirror-basic.sh t-mirror-lvconvert ...
Message-ID: <20081110123201.26266.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2008-11-10 12:32:00

Modified files:
	test           : t-mirror-basic.sh t-mirror-lvconvert.sh 
	                 t-mirror-names.sh 
	                 t-mirror-vgreduce-removemissing.sh 
	                 t-pvmove-basic.sh 

Log message:
	Explicitly check after lvremove -ff vg that it did its job. By jstava.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-mirror-basic.sh.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-mirror-lvconvert.sh.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-mirror-names.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-mirror-vgreduce-removemissing.sh.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvmove-basic.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/test/t-mirror-basic.sh	2008/10/14 19:41:12	1.4
+++ LVM2/test/t-mirror-basic.sh	2008/11/10 12:32:00	1.5
@@ -121,6 +121,10 @@
 prepare_lvs_()
 {
   lvremove -ff $vg;
+	if dmsetup table|grep $vg; then
+		echo "ERROR: lvremove did leave some some mappings in DM behind!"
+		return 1
+	fi
   :
 }
 
@@ -128,6 +132,10 @@
 {
   lvs -a -o+devices $vg
   lvremove -ff $vg
+	if dmsetup table|grep $vg; then
+		echo "ERROR: lvremove did leave some some mappings in DM behind!"
+		return 1
+	fi
 }
 
 #COMM "check environment setup/cleanup"
--- LVM2/test/t-mirror-lvconvert.sh	2008/09/30 17:47:34	1.5
+++ LVM2/test/t-mirror-lvconvert.sh	2008/11/10 12:32:00	1.6
@@ -111,12 +111,21 @@
 prepare_lvs_()
 {
   lvremove -ff $vg
+	if dmsetup table|grep $vg; then
+		echo "ERROR: lvremove did leave some some mappings in DM behind!"
+		return 1
+	fi
+	:
 }
 
 check_and_cleanup_lvs_()
 {
   lvs -a -o+devices $vg
   lvremove -ff $vg
+	if dmsetup table|grep $vg; then
+		echo "ERROR: lvremove did leave some some mappings in DM behind!"
+		return 1
+	fi
 }
 
 prepare_lvs_
--- LVM2/test/t-mirror-names.sh	2008/10/06 16:47:07	1.2
+++ LVM2/test/t-mirror-names.sh	2008/11/10 12:32:00	1.3
@@ -57,13 +57,21 @@
 # Common environment setup/cleanup for each sub testcases
 
 prepare_lvs_() {
-  lvremove -ff $vg;
+	lvremove -ff $vg
+	if dmsetup table|grep $vg; then
+		echo "ERROR: lvremove did leave some some mappings in DM behind!"
+		return 1
+	fi
   :
 }
 
 check_and_cleanup_lvs_() {
   lvs -a -o+devices $vg 
   lvremove -ff $vg
+	if dmsetup table|grep $vg; then
+		echo "ERROR: lvremove did leave some some mappings in DM behind!"
+		return 1
+	fi
 }
 
 prepare_lvs_ 
--- LVM2/test/t-mirror-vgreduce-removemissing.sh	2008/10/14 19:41:12	1.4
+++ LVM2/test/t-mirror-vgreduce-removemissing.sh	2008/11/10 12:32:00	1.5
@@ -94,6 +94,10 @@
 prepare_lvs_()
 {
 	lvremove -ff $vg;
+	if dmsetup table|grep $vg; then
+		echo "ERROR: lvremove did leave some some mappings in DM behind!"
+		return 1
+	fi
 	:
 }
 
@@ -101,6 +105,10 @@
 {
 	lvs -a -o+devices $vg 
 	lvremove -ff $vg
+	if dmsetup table|grep $vg; then
+		echo "ERROR: lvremove did leave some some mappings in DM behind!"
+		return 1
+	fi
 }
 
 recover_vg_()
--- LVM2/test/t-pvmove-basic.sh	2008/10/06 16:47:07	1.2
+++ LVM2/test/t-pvmove-basic.sh	2008/11/10 12:32:00	1.3
@@ -84,6 +84,11 @@
   check_dev_sum_ $(lvdev_ $vg $lv3)
   lvs -a -o name $vg > out && ! grep ^pvmove out
   lvremove -ff $vg
+	if ! dmsetup table|not grep $vg; then
+		echo "ERROR: lvremove did leave some some mappings in DM behind!" &&
+		return 1
+	fi
+	:
 }
 
 #COMM "check environment setup/cleanup"


