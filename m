From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 30 Sep 2008 21:43:55 -0000
Subject: LVM2/test t-vgsplit-usage.sh
Message-ID: <20080930214355.19516.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2008-09-30 21:43:55

Modified files:
	test           : t-vgsplit-usage.sh 

Log message:
	Cosmetic: get rid of trailing garbage on comments in t-vgslpit-usage.sh.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgsplit-usage.sh.diff?cvsroot=lvm2&r1=1.10&r2=1.11

--- LVM2/test/t-vgsplit-usage.sh	2008/09/30 15:20:09	1.10
+++ LVM2/test/t-vgsplit-usage.sh	2008/09/30 21:43:55	1.11
@@ -77,7 +77,7 @@
 vgremove $vg2 
 vgremove $vg1
 
-# vgsplit rejects split because alloc given with existing vg" \
+# vgsplit rejects split because alloc given with existing vg
 vgcreate -M$mdatype --alloc cling $vg1 $dev1 $dev2 
 vgcreate -M$mdatype --alloc cling $vg2 $dev3 $dev4 
 not vgsplit --alloc cling $vg1 $vg2 $dev1 2>err;
@@ -85,7 +85,7 @@
 vgremove $vg2 
 vgremove $vg1
 
-# vgsplit rejects split because clustered given with existing vg" \
+# vgsplit rejects split because clustered given with existing vg
 vgcreate -M$mdatype --clustered n $vg1 $dev1 $dev2 
 vgcreate -M$mdatype --clustered n $vg2 $dev3 $dev4 
 not vgsplit --clustered n $vg1 $vg2 $dev1 2>err
@@ -93,7 +93,7 @@
 vgremove $vg2 
 vgremove $vg1
 
-# vgsplit rejects vg with active lv" \
+# vgsplit rejects vg with active lv
 pvcreate -M$mdatype -ff $dev3 $dev4 
 vgcreate -M$mdatype $vg1 $dev1 $dev2 
 vgcreate -M$mdatype $vg2 $dev3 $dev4 
@@ -103,7 +103,7 @@
 vgremove -f $vg2 
 vgremove -f $vg1
 
-# vgsplit rejects split because max_lv is exceeded" \
+# vgsplit rejects split because max_lv is exceeded
 vgcreate -M$mdatype --maxlogicalvolumes 2 $vg1 $dev1 $dev2 
 vgcreate -M$mdatype --maxlogicalvolumes 2 $vg2 $dev3 $dev4 
 lvcreate -l 4 -n $lv1 $vg1 
@@ -143,7 +143,7 @@
 vgremove -f $vg2 
 vgremove -f $vg1
 
-# vgsplit rejects split because PV not in VG" \
+# vgsplit rejects split because PV not in VG
 vgcreate -M$mdatype $vg1 $dev1 $dev2 
 vgcreate -M$mdatype $vg2 $dev3 $dev4 
 lvcreate -l 4 -n $lv1 $vg1 


